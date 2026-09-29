# zcopyall

**Copy the complete retained scrollback of the currently focused Zellij pane to the system clipboard with one keypress.**

`zcopyall` is a small Zellij WebAssembly plugin for the thing that is awkward to do with a mouse: copy everything Zellij still retains for the current pane, not just the visible viewport.

The intended workflow is simply:

```text
Alt+A
```

Then paste normally.

## Why

Terminal selection works well until the output is hundreds or thousands of lines long. Dragging a mouse through scrollback is slow, fragile, and especially unpleasant when terminal/Zellij autoscroll behavior changes.

`zcopyall` asks Zellij for the focused pane's retained scrollback and sends it directly to Zellij's clipboard API. It does not create a temporary shell pane and does not depend on `xclip` or another external clipboard owner.

## Status

Version **0.1.0** is intentionally small and pinned to:

```text
zellij-tile = 0.44.3
```

It was initially developed and verified with Zellij 0.44.3 on Debian 12/XFCE.

### Compatibility

Zellij 0.39.x is **not supported**. The plugin depends on host/plugin APIs that are present in 0.44.3 but absent in 0.39.2, including full pane-scrollback access, current-client/pane discovery, and direct clipboard access.

The installer checks the local Zellij version before building and refuses versions older than 0.44.3 with a clear error instead of installing a plugin that cannot run.

## Requirements

- Zellij 0.44.3 or newer (0.44.3 is the validated baseline)
- Rust/Cargo installed through `rustup`
- the Rust `wasm32-wasip1` target (the installer adds it automatically)

## Install

```bash
git clone https://github.com/Gardlok/zcopyall.git
cd zcopyall
./install.sh
```

The installer:

1. installs the `wasm32-wasip1` Rust standard-library target if needed;
2. builds the plugin in release mode;
3. installs `zcopyall.wasm` into `${ZELLIJ_CONFIG_DIR:-$HOME/.config/zellij}/plugins/`;
4. prints the exact Zellij configuration entries for that machine.

It deliberately does **not** rewrite your existing `config.kdl`.

## Configure Zellij

Add the following to `~/.config/zellij/config.kdl`. If any of these top-level blocks already exist, add the entry to the existing block rather than creating a second copy.

Replace `/home/YOU` with the absolute path printed by `./install.sh`.

```kdl
plugins {
    zcopyall location="file:/home/YOU/.config/zellij/plugins/zcopyall.wasm"
}

load_plugins {
    zcopyall
}

keybinds {
    shared_except "locked" {
        bind "Alt a" {
            MessagePlugin "zcopyall" {
                name "copy_all"
            }
        }
    }
}
```

Plugin aliases are loaded at Zellij startup, so restart Zellij after first adding or changing the `zcopyall` alias.

On first load, Zellij will ask the plugin for these permissions:

- `ReadApplicationState`
- `ReadPaneContents`
- `WriteToClipboard`

Those are the only permissions the plugin requests.

After granting them, focus any terminal pane and press:

```text
Alt+A
```

The full retained pane buffer should now be on the system clipboard.

Because the example binding uses `shared_except "locked"`, it intentionally does nothing while Zellij is in Locked mode.

## Manual test

Before configuring a keybinding, the installed plugin can be loaded directly:

```bash
zellij action start-or-reload-plugin \
    "file:$HOME/.config/zellij/plugins/zcopyall.wasm"
```

Then trigger the same operation through a pipe:

```bash
zellij pipe \
    --plugin "file:$HOME/.config/zellij/plugins/zcopyall.wasm" \
    --name copy_all \
    -- ""
```

Paste into an editor or another application to verify the result.

## Build manually

From the repository root:

```bash
rustup target add wasm32-wasip1
cargo build --release --target wasm32-wasip1
```

The resulting plugin is:

```text
target/wasm32-wasip1/release/zcopyall.wasm
```

The repository also contains `.cargo/config.toml`, so a normal `cargo build --release` from the repository root targets `wasm32-wasip1` automatically. The explicit `--target` form is used in the installer to avoid depending on Cargo config discovery from another working directory.

## What gets copied

The plugin requests the current pane's full scrollback from Zellij and combines:

- lines above the viewport;
- the current viewport;
- lines below the viewport.

"Full" therefore means **everything still retained by Zellij for that pane**. Text that has already fallen outside Zellij's configured scrollback buffer cannot be recovered by the plugin.

## Design

The plugin stays deliberately narrow:

- identify the current Zellij client;
- obtain that client's focused pane;
- request the pane's retained scrollback;
- send the resulting text to Zellij's clipboard API.

It does not execute shell commands, read arbitrary files, or manage the clipboard through an external process.

## License

MIT. See [LICENSE](LICENSE).
