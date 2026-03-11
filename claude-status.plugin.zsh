#!/usr/bin/env zsh
# claude-status.plugin.zsh
# Installs claude-status into $PATH via ~/.local/bin/

_claude_statusline_dir="${0:h}"
_local_bin="${HOME}/.local/bin"

mkdir -p "$_local_bin"

chmod +x "${_claude_statusline_dir}/claude-status.sh"
ln -sf "${_claude_statusline_dir}/claude-status.sh" "${_local_bin}/claude-status"

unset _claude_statusline_dir _local_bin
