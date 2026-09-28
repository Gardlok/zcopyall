#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${ZELLIJ_CONFIG_DIR:-$HOME/.config/zellij}"
PLUGIN_DIR="$CONFIG_DIR/plugins"
PLUGIN_PATH="$PLUGIN_DIR/zcopyall.wasm"
TARGET="wasm32-wasip1"

die() {
    printf 'zcopyall: %s\n' "$*" >&2
    exit 1
}

command -v cargo >/dev/null 2>&1 || die "cargo is required"
command -v rustup >/dev/null 2>&1 || die "rustup is required"

printf '==> Ensuring Rust target %s\n' "$TARGET"
rustup target add "$TARGET"

printf '==> Building zcopyall\n'
cd "$ROOT"
cargo build --release --target "$TARGET"

WASM="$ROOT/target/$TARGET/release/zcopyall.wasm"
[[ -s "$WASM" ]] || die "build completed without producing $WASM"

printf '==> Installing %s\n' "$PLUGIN_PATH"
mkdir -p "$PLUGIN_DIR"
install -m 0644 "$WASM" "$PLUGIN_PATH"

printf '\nInstalled zcopyall to:\n  %s\n\n' "$PLUGIN_PATH"
printf '%s\n' 'Add the following entries to your Zellij config.'
printf '%s\n' 'If plugins/load_plugins/keybinds blocks already exist, merge these entries into them.'
printf '\nplugins {\n'
printf '    zcopyall location="file:%s"\n' "$PLUGIN_PATH"
printf '}\n\n'
printf 'load_plugins {\n'
printf '    zcopyall\n'
printf '}\n\n'
printf 'keybinds {\n'
printf '    shared_except "locked" {\n'
printf '        bind "Alt a" {\n'
printf '            MessagePlugin "zcopyall" {\n'
printf '                name "copy_all"\n'
printf '            }\n'
printf '        }\n'
printf '    }\n'
printf '}\n\n'
printf '%s\n' 'Restart Zellij after adding/changing the plugin alias, grant the requested permissions once, then press Alt+A.'
