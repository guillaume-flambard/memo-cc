---
name: weekly-home-hygiene
description: Monday morning report-only hygiene sweep of the Mac home directory
---

You are running the weekly home-hygiene sweep on Guillaume's Mac (user `memo`). REPORT ONLY — never delete, move, or modify anything in this task. Reply in French, caveman-terse.

Context: read `~/AGENTS.md` first (home map + rules). 🔴 Never read or index: `~/Documents`, `~/Downloads/_SECRETS-to-secure/`, `~/.gnupg`, `~/.aws`, `~/.ssh`.

Checks to run:
1. Loose files at `~` root (anything that is not a known dir from ~/AGENTS.md map, dotfiles excluded).
2. `~/Downloads` root: files outside the staging dirs (`_Apps`, `_Docs`, `_Echo-data`, `_Installers`, `_SECRETS-to-secure`) and AGENTS.md.
3. `~/Desktop` clutter (count + biggest items).
4. New entries in `~/projects` (top level) that have NO row in `~/projects/PROJECTS.md` — the manifest rule. Also: broken symlinks (`find ~/projects -maxdepth 1 -type l ! -exec test -e {} \; -print` style check).
5. Disk: `df -h /` + top cache consumers (`du -sh ~/Library/Caches ~/.npm ~/.cache 2>/dev/null`).
6. `~/Archive` growth vs last week: read the last row in `baseline.md`, run `du -sh ~/Archive`, report the delta (⚠️ if it grew notably), then append a new dated row to `baseline.md`. Appending this row is the one write this task is allowed — nothing else.

Output: short report — ✅ per clean check, ⚠️ per finding with exact paths. If actions are warranted, END with a proposed command list under "En attente de ton go:" — do not execute them. If everything is clean, one line: "Maison propre."