#!/usr/bin/env bash
# ~/.claude/statusline.sh — Claude Code status line
# Requires: jq, gum

# Force color output — gum disables colors when stdout is not a TTY
export CLICOLOR_FORCE=1

# Capture stdin immediately before any subcommand can consume it
_input=$(cat)

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

  eval "$(jq -r -f ~/.config/claude/statusline.jq <<<"$_input")"
}

# ── Segments ──────────────────────────────────────────────────────────────────

# context_segment
#
# Renders a 10-char progress bar showing context window usage, followed
# by the usage percentage. Bar color shifts green → yellow → red as
# usage crosses 70% and 90% thresholds.
#
# Globals: context_used
# Outputs: gum-styled bar + percentage to stdout
context_segment() {
  local bar_width=10
  local filled=$((context_used * bar_width / 100))
  [ "$filled" -gt "$bar_width" ] && filled="$bar_width"
  local empty=$((bar_width - filled))
  local bar_on bar_off bar_fg

  bar_on=$(printf "%${filled}s" | tr ' ' '⣿')
  bar_off=$(printf "%${empty}s" | tr ' ' '⣀')

  if [ "$context_used" -ge 90 ]; then
    bar_fg=203 # red
  elif [ "$context_used" -ge 70 ]; then
    bar_fg=220 # yellow
  else
    bar_fg=114 # green
  fi

  local filled_s="" empty_s=""
  [ -n "$bar_on" ] && filled_s=$(gum style --foreground "$bar_fg" -- "$bar_on")
  [ -n "$bar_off" ] && empty_s=$(gum style --foreground 238 -- "$bar_off")

  printf '%s' "${filled_s}${empty_s} $(gum style --foreground 103 -- "${context_used}%")"
}

# cost_segment
#
# Renders the total session cost in USD, formatted as $X.XX (2 decimal places).
#
# Globals: cost_usd
# Outputs: gum-styled cost string to stdout
cost_segment() {
  local cost_fmt
  cost_fmt=$(printf ' %.2f' "$cost_usd")
  gum style --foreground 215 -- "$cost_fmt"
}

# agent_segment
#
# Renders the active agent name prefixed with ⚡ when running in agent mode.
# Outputs nothing when no agent is active.
#
# Globals: claude_agent
# Outputs: gum-styled agent string to stdout, or empty
agent_segment() {
  [ -n "$claude_agent" ] && gum style --foreground 87 -- "⚡ $claude_agent"
}

# model_segment
#
# Renders the active model name.
#
# Globals: claude_model
# Outputs: gum-styled model string to stdout
model_segment() {
  gum style --foreground 123 -- "$claude_model"
}

# dir_segment
#
# Renders the current working directory basename.
#
# Globals: current_dir
# Outputs: gum-styled directory string to stdout
dir_segment() {
  gum style --foreground 111 -- "  ${current_dir##*/}"
}

# branch_segment
#
# Renders the current git branch. Uses worktree_branch when inside a
# worktree, otherwise falls back to the active git branch.
# Outputs nothing when the branch cannot be determined.
#
# Globals: current_dir, worktree_branch
# Outputs: gum-styled branch string to stdout, or empty
branch_segment() {
  local branch="$worktree_branch"
  [ -z "$branch" ] && branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
  [ -n "$branch" ] && gum style --foreground 213 -- " $branch"
}

# worktree_segment
#
# Renders the active worktree name prefixed with 󰙅.
# Outputs nothing when not inside a worktree.
#
# Globals: worktree_name
# Outputs: gum-styled worktree string to stdout, or empty
worktree_segment() {
  [ -n "$worktree_name" ] && gum style --foreground 208 -- "󰙅 $worktree_name"
}

# time_segment
#
# Renders the total session duration as Xm Ys, or Xh Ym Ys when over an hour.
#
# Globals: cost_duration_ms
# Outputs: gum-styled duration string to stdout
time_segment() {
  local hours mins secs fmt
  hours=$((cost_duration_ms / 3600000))
  mins=$(((cost_duration_ms % 3600000) / 60000))
  secs=$(((cost_duration_ms % 60000) / 1000))
  [ "$hours" -gt 0 ] && fmt="${hours}h ${mins}m ${secs}s" || fmt="${mins}m ${secs}s"
  gum style --foreground 103 -- "󱑓 ${fmt}"
}

# diff_segment
#
# Renders lines added and removed during the session.
# Added in green, removed in red.
#
# Globals: cost_lines_added, cost_lines_removed
# Outputs: two gum-styled strings concatenated to stdout
diff_segment() {
  printf '%s' "$(gum style --foreground 114 -- "+${cost_lines_added}") $(gum style --foreground 203 -- "-${cost_lines_removed}")"
}

# main
#
# Parses input then assembles all segments into a single status line.
# Optional segments (agent, branch, worktree) are skipped when not active.
# Order: bar% | cost | ⚡ agent | model | dir | branch | worktree | time | +/-
#
# Outputs: status line to stdout
main() {
  parse_input

  local sep
  sep=$(gum style --foreground 238 -- "  ")

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

  gum join --horizontal "${segments[@]}"
}

main
