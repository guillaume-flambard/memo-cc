# memo — personal Claude Code plugin

Guillaume's AI-driven layer for `~/memo`. Turns the recurring workflows of his setup (Obsidian Vault
at `~/Vault`, projects in `~/projects`, personal docs in `~/Documents`) into reusable skills + agents.

## Contents

| Type | Name | What it does |
|------|------|--------------|
| Skill | `vault-enrich` (`/vault-enrich`) | Promote a durable learning into the Vault as a conforming atomic note (frontmatter, MOC, commit+push). |
| Skill | `star-relay` (/star-relay) | One spec-scoped STAR cycle per authorized project; tests, proof, explicit handoff, portfolio scan. |\n| Skill | `new-project` (`/new-project <name>`) | Scaffold `~/projects/<name>` (asks the stack each time) + register in the Vault & `~/myprojects.md`. |
| Agent | `personal-archivist` | Local-only document archivist for `~/Documents`. Never transmits externally, never copies secrets into git. |
| Agent | `vault-librarian` | Maintains the Vault: frontmatter, links, MOCs, duplicates, placeholders → commit. |

## Install (local marketplace)

```bash
claude plugin marketplace add ~/projects/memo-cc
claude plugin install memo@memo-marketplace
```

Then `/vault-enrich` and `/new-project` are available, and `personal-archivist` / `vault-librarian`
appear as subagent types.

## Canonical config (the "general truth")

This repo also encodes Guillaume's standard, reproducible Claude Code setup so any machine matches it:

- **`setup/CANONICAL-CONFIG.md`** — the truth: lean enabled-plugins set (14), on-demand list (13),
  global-MCP policy (`shadcn` only), efficiency tooling (rtk/mgrep/ccusage), security (secrets in
  Keychain), and the manual `/plugin` steps for Cowork bundles.
- **`setup/bootstrap.sh`** — idempotent applier (backs up everything; `--check` for a dry-run):
  ```bash
  bash setup/bootstrap.sh --check   # preview
  bash setup/bootstrap.sh           # apply, then restart Claude Code
  ```
- **`setup/statusline-command.sh`** — canonical statusline (ccusage cost segment + FR-locale-safe).

## Design
See `docs/specs/2026-06-29-memo-plugin-design.md`.

## Conventions it encodes
- Vault contract: `~/Vault/AGENTS.md`, `4-Tools/frontmatter-spec.md`, `conventions.md`, `tagging.md`.
- Home map & golden rules: `~/AGENTS.md`.
- Security: personal docs are local-only; secrets never enter the Vault/git.


## Multi-project STAR engineering relay

The cross-project method lives in skills/star-relay/SKILL.md. Read the central
~/projects/PROJECTS.md registry, project-specific AGENTS.md, actual spec and existing
SHARED_TASK_NOTES.md before starting. STAR means **Situation → Task → Action → Result**.
One cycle does one independently testable change; the result, evidence and next
task are appended to the existing relay notes. Stasis determines the priority.
A blocked or failed cycle stops, never spins indefinitely.

This versioned, standard-library helper offers a read-only portfolio audit and
safe bookkeeping, without executing arbitrary agent commands:

    python3 scripts/star_relay.py inventory
    python3 scripts/star_relay.py start --project intentlane --workspace ~/projects/_worktrees/intentlane/task-a --situation "Verified baseline" --task "One scoped requirement"
    python3 scripts/star_relay.py finish --project intentlane --workspace ~/projects/_worktrees/intentlane/task-a --status PASSED --action "Implemented x" --result "Observed y" --verification "Exact test command and result" --next-task "Next single task"
    python3 -m unittest discover -s tests -v

Start/finish require a registered project and an existing Git worktree under
~/projects/_worktrees. Start also requires an existing real spec in the worktree;
missing specs are a blocker, not a reason to invent one. Earlier notes are
preserved and a second cycle cannot start while the first remains unfinished.
The inventory counts relay notes from both canonical and historical worktrees,
but the standard spec detector intentionally reports only known conventional paths.
No daemon or continuous background agent is installed by this skill.
