#!/usr/bin/env bash
# Claude Code status line
# Reads JSON from stdin and outputs a formatted status line

# Force C numeric locale so `printf '%.0f'` accepts dot decimals (fixes FR-locale "invalid number")
export LC_NUMERIC=C

input=$(cat)

# --- Session context ---
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
session_name=$(echo "$input" | jq -r '.session_name // empty')

# --- Shorten cwd (replace $HOME with ~) ---
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# --- Git branch (non-blocking, skip locks) ---
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# --- Context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_part=""
if [ -n "$used_pct" ]; then
  used_int=${used_pct%%.*}
  ctx_part=" ctx:${used_int}%"
fi

# --- Rate limits (Claude.ai subscribers only) ---
rate_part=""
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five_pct" ]; then
  five_int=${five_pct%%.*}
  rate_part=" 5h:${five_int}%"
fi

# --- Vim mode ---
vim_part=""
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
if [ -n "$vim_mode" ]; then
  vim_part=" [${vim_mode}]"
fi

# --- Worktree ---
worktree_part=""
wt_name=$(echo "$input" | jq -r '.worktree.name // empty')
if [ -n "$wt_name" ]; then
  worktree_part=" wt:${wt_name}"
fi

# --- Build output ---
# Format: memo  ~/projects/echo/echotravel  develop  Claude 3.5 Sonnet  ctx:42%
parts=""

# user + dir
printf '\033[0;32m%s\033[0m' "$(whoami)"
printf ' \033[0;34m%s\033[0m' "$short_cwd"

# git branch
if [ -n "$git_branch" ]; then
  printf ' \033[0;33m%s\033[0m' "$git_branch"
fi

# worktree
if [ -n "$worktree_part" ]; then
  printf ' \033[0;35m%s\033[0m' "wt:${wt_name}"
fi

# session name (if renamed)
if [ -n "$session_name" ]; then
  printf ' \033[0;36m[%s]\033[0m' "$session_name"
fi

# model
printf ' \033[0;90m%s\033[0m' "$model"

# context
if [ -n "$ctx_part" ]; then
  # Color-code by usage: green < 50%, yellow < 80%, red >= 80%
  used_int=${used_pct%%.*}
  if [ "$used_int" -ge 80 ]; then
    printf ' \033[0;31mctx:%d%%\033[0m' "$used_int"
  elif [ "$used_int" -ge 50 ]; then
    printf ' \033[0;33mctx:%d%%\033[0m' "$used_int"
  else
    printf ' \033[0;32mctx:%d%%\033[0m' "$used_int"
  fi
fi

# rate limits
if [ -n "$rate_part" ]; then
  five_int=${five_pct%%.*}
  printf ' \033[0;90m5h:%d%%\033[0m' "$five_int"
fi

# vim mode
if [ -n "$vim_part" ]; then
  printf ' \033[0;36m[%s]\033[0m' "$vim_mode"
fi

# --- ccusage cost segment (graceful: only if installed; never breaks the line) ---
if command -v ccusage >/dev/null 2>&1; then
  # Split ccusage output on ASCII " | " (robust); keep fields 2 (cost) + 3 (burn), drop model + brain.
  cost_seg=$(printf '%s' "$input" | ccusage statusline 2>/dev/null | awk -F' \\| ' 'NF>=2{s=$2; if(NF>=3)s=s" | "$3; print s}')
  if [ -n "$cost_seg" ]; then
    printf ' \033[0;90m%s\033[0m' "$cost_seg"
  fi
fi

printf '\n'
