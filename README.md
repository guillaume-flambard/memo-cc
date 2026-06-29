# memo — personal Claude Code plugin

Guillaume's AI-driven layer for `~/memo`. Turns the recurring workflows of his setup (Obsidian Vault
at `~/Vault`, projects in `~/projects`, personal docs in `~/Documents`) into reusable skills + agents.

## Contents

| Type | Name | What it does |
|------|------|--------------|
| Skill | `vault-enrich` (`/vault-enrich`) | Promote a durable learning into the Vault as a conforming atomic note (frontmatter, MOC, commit+push). |
| Skill | `new-project` (`/new-project <name>`) | Scaffold `~/projects/<name>` (asks the stack each time) + register in the Vault & `~/myprojects.md`. |
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
- Vault contract: `~/Vault/AGENTS.md`, `99-System/frontmatter-spec.md`, `conventions.md`, `tagging.md`.
- Home map & golden rules: `~/AGENTS.md`.
- Security: personal docs are local-only; secrets never enter the Vault/git.
