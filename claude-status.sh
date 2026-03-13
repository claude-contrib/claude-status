#!/usr/bin/env bash
# claude-status.sh — Claude Code status line
# Requires: jq

# Capture stdin immediately before any subcommand can consume it
_input=$(cat)
# Resolve the directory containing this script, following symlinks (e.g. ~/.local/bin)
_source_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

# parse_input
#
# Parses the Claude Code JSON status payload into global variables via eval.
# Reads from $_input captured at startup.
#
# Globals (set): claude_model, current_dir, cost_usd, cost_duration_ms,
#                cost_lines_added, cost_lines_removed, context_used,
#                claude_agent, worktree_name, worktree_branch
# Inputs: $_input (JSON payload captured from stdin)
parse_input() {
  claude_model="" current_dir="." cost_usd=0 cost_duration_ms=0
  cost_lines_added=0 cost_lines_removed=0 context_used=0
  claude_agent="" worktree_name="" worktree_branch=""

  eval "$(jq -r -f "$_source_dir/claude-status.jq" <<<"$_input")"

  # Detect linked worktree when the JSON payload has no worktree info
  if [ -z "$worktree_name" ] && [ -n "$current_dir" ]; then
    local git_dir git_common_dir
    git_dir=$(git -C "$current_dir" rev-parse --git-dir 2>/dev/null)
    git_common_dir=$(git -C "$current_dir" rev-parse --git-common-dir 2>/dev/null)
    if [ -n "$git_dir" ] && [ -n "$git_common_dir" ] \
      && [ "$(realpath "$git_dir" 2>/dev/null)" != "$(realpath "$git_common_dir" 2>/dev/null)" ]; then
      worktree_name=$(basename "$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null)")
    fi
  fi
}

# ── Theme ─────────────────────────────────────────────────────────────────────────────────
# Set CLAUDE_CODE_STATUS_THEME to a built-in name (catppuccin-mocha, catppuccin-macchiato,
# catppuccin-frappe, catppuccin-latte) or a path to a custom theme JSON file.
# Default: catppuccin-mocha

_theme="${CLAUDE_CODE_STATUS_THEME:-catppuccin-mocha}"
[[ "$_theme" != */* ]] && _theme="$_source_dir/themes/${_theme}.json"

eval "$(jq -r -f "$_source_dir/claude-theme.jq" "$_theme")"
readonly theme_sep_fg theme_muted_fg theme_cost_fg theme_agent_fg theme_model_fg theme_dir_fg theme_branch_fg theme_worktree_fg theme_add_fg theme_del_fg theme_bar_yellow

# ── Template helper ──────────────────────────────────────────────────────────────────────────

# _printf_color COLOR VALUE
#
# Outputs text with ANSI color. COLOR is either a 256-color index or
# an exact "R;G;B" truecolor value.
_printf_color() { printf '\033[38;2;%sm%s\033[0m' "$1" "$2"; }

# ── Segments ────────────────────────────────────────────────────────────────────────────────

# context_segment
#
# Renders a 10-char progress bar showing context window usage, followed
# by the usage percentage. Bar color shifts green → yellow → red as
# usage crosses 70% and 90% thresholds.
#
# Globals: context_used
# Outputs: gum template fragment to stdout
context_segment() {
  local bar_width=10
  local filled=$((context_used * bar_width / 100))
  [ "$filled" -gt "$bar_width" ] && filled="$bar_width"
  local empty=$((bar_width - filled))
  local bar_on bar_off bar_fg

  bar_on=$(printf "%${filled}s" | tr ' ' '⣿')
  bar_off=$(printf "%${empty}s" | tr ' ' '⣀')

  if [ "$context_used" -ge 90 ]; then
    bar_fg=$theme_del_fg
  elif [ "$context_used" -ge 70 ]; then
    bar_fg=$theme_bar_yellow
  else
    bar_fg=$theme_add_fg
  fi

  local out=""
  [ -n "$bar_on" ] && out+="$(_printf_color "$bar_fg" "$bar_on")"
  [ -n "$bar_off" ] && out+="$(_printf_color "$theme_sep_fg" "$bar_off")"
  out+=" $(_printf_color "$theme_muted_fg" "${context_used}%")"
  printf '%s' "$out"
}

# cost_segment
#
# Renders the total session cost in USD, formatted as $ X.XX (2 decimal places).
#
# Globals: cost_usd
# Outputs: gum template fragment to stdout
cost_segment() {
  local cost_fmt
  cost_fmt=$(printf '$%.2f' "$cost_usd")
  _printf_color "$theme_cost_fg" "$cost_fmt"
}

# agent_segment
#
# Renders the active agent name prefixed with ⚡ when running in agent mode.
# Outputs nothing when no agent is active.
#
# Globals: claude_agent
# Outputs: gum template fragment to stdout, or empty
agent_segment() {
  [ -n "$claude_agent" ] && _printf_color "$theme_agent_fg" "⚡ $claude_agent"
}

# model_segment
#
# Renders the active model name.
#
# Globals: claude_model
# Outputs: gum template fragment to stdout
model_segment() {
  _printf_color "$theme_model_fg" "$claude_model"
}

# dir_segment
#
# Renders the current working directory basename.
#
# Globals: current_dir
# Outputs: gum template fragment to stdout
dir_segment() {
  _printf_color "$theme_dir_fg" "  ${current_dir##*/}"
}

# branch_segment
#
# Renders the current git branch. Uses worktree_branch when inside a
# worktree, otherwise falls back to the active git branch.
# Outputs nothing when the branch cannot be determined.
#
# Globals: current_dir, worktree_branch
# Outputs: gum template fragment to stdout, or empty
branch_segment() {
  local branch="$worktree_branch"
  [ -z "$branch" ] && branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
  [ -n "$branch" ] && _printf_color "$theme_branch_fg" " $branch"
}

# worktree_segment
#
# Renders the active worktree name prefixed with 󰉅.
# Outputs nothing when not inside a worktree.
#
# Globals: worktree_name
# Outputs: gum template fragment to stdout, or empty
worktree_segment() {
  [ -n "$worktree_name" ] && _printf_color "$theme_worktree_fg" "󰙅 $worktree_name"
}

# time_segment
#
# Renders the total session duration as Xm Ys, or Xh Ym Ys when over an hour.
#
# Globals: cost_duration_ms
# Outputs: gum template fragment to stdout
time_segment() {
  local hours mins secs fmt
  hours=$((cost_duration_ms / 3600000))
  mins=$(((cost_duration_ms % 3600000) / 60000))
  secs=$(((cost_duration_ms % 60000) / 1000))
  [ "$hours" -gt 0 ] && fmt="${hours}h ${mins}m ${secs}s" || fmt="${mins}m ${secs}s"
  _printf_color "$theme_muted_fg" "󱑓 ${fmt}"
}

# diff_segment
#
# Renders lines added and removed during the session.
# Added in green, removed in red.
#
# Globals: cost_lines_added, cost_lines_removed
# Outputs: two gum template fragments concatenated to stdout
diff_segment() {
  printf '%s %s' "$(_printf_color "$theme_add_fg" "+${cost_lines_added}")" "$(_printf_color "$theme_del_fg" "-${cost_lines_removed}")"
}

# main
#
# Parses input then assembles all segment template fragments into a single
# status line rendered with one gum format --type template call.
# Optional segments (agent, branch, worktree) are skipped when not active.
# Order: bar% | cost | ⚡ agent | model | dir | branch | worktree | time | +/-
#
# Outputs: status line to stdout
main() {
  parse_input

  local sep
  sep=$(_printf_color "$theme_sep_fg" "  ")

  local segments=()
  segments+=("$(context_segment)")
  segments+=("$sep")
  segments+=("$(cost_segment)")

  local agent
  agent=$(agent_segment)
  [ -n "$agent" ] && segments+=("$sep" "$agent")

  segments+=("$sep")
  segments+=("$(model_segment)")
  segments+=("$sep")
  segments+=("$(dir_segment)")

  local branch
  branch=$(branch_segment)
  [ -n "$branch" ] && segments+=("$sep" "$branch")

  local worktree
  worktree=$(worktree_segment)
  [ -n "$worktree" ] && segments+=("$sep" "$worktree")

  segments+=("$sep")
  segments+=("$(time_segment)")
  segments+=("$sep")
  segments+=("$(diff_segment)")

  printf '%s' "${segments[@]}"
  printf '\n'
}

main
