#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${ZELLIJ_CONFIG_DIR:-$HOME/.config/zellij}"
PLUGIN_DIR="$CONFIG_DIR/plugins"
PLUGIN_PATH="$PLUGIN_DIR/zcopyall.wasm"
TARGET="wasm32-wasip1"
MIN_ZELLIJ="0.44.3"

die() {
    printf 'zcopyall: %s\n' "$*" >&2
    exit 1
}

command -v zellij >/dev/null 2>&1 || die "zellij is required"
command -v cargo >/dev/null 2>&1 || die "cargo is required"
command -v rustup >/dev/null 2>&1 || die "rustup is required"
command -v sort >/dev/null 2>&1 || die "GNU sort is required for version checking"

ZELLIJ_VERSION="$(zellij --version | awk '{print $2}')"
[[ -n "$ZELLIJ_VERSION" ]] || die "could not determine Zellij version"

if [[ "$(printf '%s\n' "$MIN_ZELLIJ" "$ZELLIJ_VERSION" | sort -V | head -n1)" != "$MIN_ZELLIJ" ]]; then
    die "Zellij $ZELLIJ_VERSION is too old; zcopyall requires Zellij >= $MIN_ZELLIJ"
fi

printf '==> Zellij %s (minimum %s)\n' "$ZELLIJ_VERSION" "$MIN_ZELLIJ"

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
