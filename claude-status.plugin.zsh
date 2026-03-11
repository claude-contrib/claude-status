#!/usr/bin/env zsh
# claude-status.plugin.zsh
# Installs Claude Code statusline to ~/.config/claude/

_claude_statusline_dir="${0:h}"
_claude_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/claude"

mkdir -p "$_claude_config_dir"

# Symlinks so `zinit update` automatically reflects upstream changes
ln -sf "${_claude_statusline_dir}/statusline.sh" "${_claude_config_dir}/statusline.sh"
ln -sf "${_claude_statusline_dir}/statusline.jq" "${_claude_config_dir}/statusline.jq"
chmod +x "${_claude_statusline_dir}/statusline.sh"

unset _claude_statusline_dir _claude_config_dir
