# zcopyall

`zcopyall` is a small Zellij plugin that copies the **entire retained scrollback of the current pane** to your system clipboard.

Instead of dragging the mouse through hundreds or thousands of lines, press:

```text
Alt+A
```

Then paste normally.

## Requirements

- Zellij **0.44.3 or newer**
- Rust/Cargo installed through `rustup`

Zellij 0.39.x is too old for the plugin API used by `zcopyall`.

## Install

```bash
git clone https://github.com/Gardlok/zcopyall.git
cd zcopyall
./install.sh
```

The installer builds the plugin and installs it here:

```text
~/.config/zellij/plugins/zcopyall.wasm
```

It also installs the Rust `wasm32-wasip1` target if you do not already have it.

## First run

Start the plugin once from inside Zellij:

```bash
zellij action start-or-reload-plugin \
    "file:$HOME/.config/zellij/plugins/zcopyall.wasm"
```

Zellij will ask for three permissions:

- `ReadApplicationState`
- `ReadPaneContents`
- `WriteToClipboard`

Grant them.

## Add the Alt+A shortcut

Add this to `~/.config/zellij/config.kdl`:

```kdl
keybinds {
    shared_except "locked" {
        bind "Alt a" {
            MessagePlugin "file:/home/YOU/.config/zellij/plugins/zcopyall.wasm" {
                name "copy_all"
            }
        }
    }
}
```

Replace `/home/YOU` with your actual home directory.

If your config already has a `keybinds` block, add the `shared_except` section inside it instead of creating a second `keybinds` block.

Restart Zellij after changing the config.

## Use

Focus the pane you want to copy and press:

```text
Alt+A
```

Everything Zellij still has in that pane's scrollback buffer is copied to the clipboard.

This includes text above the visible screen. Text that Zellij has already discarded because it exceeded the scrollback limit cannot be recovered.

The shortcut does not run while Zellij is in Locked mode.

## License

MIT. See [LICENSE](LICENSE).
