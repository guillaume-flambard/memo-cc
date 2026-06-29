# Design — `memo` Claude Code plugin (Guillaume's personal AI-driven layer)

**Date:** 2026-06-29 · **Status:** approved (brainstorm) → ready for implementation plan

## Context

Guillaume's home (`~/memo`) was made AI-navigable earlier this session (root `~/AGENTS.md`, zone
markers, Vault tooling notes, memory). This plugin turns the **recurring manual workflows** of that
setup into reusable, packaged tooling so any session (and any of his machines) gets them. It encodes
conventions that currently live only in docs (Vault `AGENTS.md`, `frontmatter-spec.md`, the
`~/Documents` security posture) as executable skills and constrained agents.

## Goals
- Codify the four highest-frequency workflows: enrich the Vault, start a project, manage personal
  documents safely, maintain the Vault.
- Package them cohesively (one versioned plugin) — reusable across machines.
- Bake the **security boundary** (local-only, never transmit, no secrets in git) into the document agent.

## Non-goals
- No physical home cleanup here (that's the separate staged `~/Vault/99-System/home-cleanup-plan.md`).
- No `/home-cleanup` command in v1 (easy to add later; not selected).

## Architecture

A dedicated git repo `~/projects/memo-cc/`, structured as a Claude Code plugin, installed via a
**local marketplace** so its skills/commands/agents load globally:

```
memo-cc/
├── .claude-plugin/
│   ├── plugin.json          # manifest: name "memo", version, description
│   └── marketplace.json     # local marketplace entry pointing at this repo
├── skills/
│   ├── vault-enrich/SKILL.md
│   └── new-project/SKILL.md
├── agents/
│   ├── personal-archivist.md
│   └── vault-librarian.md
├── commands/
│   ├── vault-enrich.md      # /vault-enrich slash trigger
│   └── new-project.md       # /new-project slash trigger
└── docs/specs/2026-06-29-memo-plugin-design.md
```

Install: register the local marketplace (`claude plugin marketplace add ~/projects/memo-cc`) then
enable the `memo` plugin. Verify during implementation against the running Claude Code plugin model.

## Components

### 1. Skill `vault-enrich` (`/vault-enrich`)
**Purpose:** promote a durable learning/decision/pattern into the Vault as a conforming atomic note.
**Procedure (deterministic checklist):**
1. Apply the Golden Rule — if the fact answers no future question, stop and say so.
2. Search the Vault (mgrep / ripgrep over `*.md`) for an existing note → if found, **update it** (never duplicate); else continue.
3. Pick the folder by type and copy the matching template from `~/Vault/99-System/templates/`.
4. Fill frontmatter per `~/Vault/99-System/frontmatter-spec.md` (title, type, status, created, updated, tags, related).
5. Add `[[wikilinks]]` to related notes and **register the note in the correct `00-Dashboard/*-MOC.md`**.
6. `git -C ~/Vault add -A && git commit -m "<what>" && git push` (one atomic commit).
**Inputs:** the knowledge (from args or current context). **Depends on:** Vault conventions files.

### 2. Skill `new-project` (`/new-project <name>`)
**Purpose:** scaffold a new project under `~/projects/` and register it everywhere.
**Procedure:**
1. **Ask the stack each time** (no default) — language/framework/DB/payments as relevant.
2. Create `~/projects/<name>/` with: `README.md`, local `CLAUDE.md` + `AGENTS.md` (pointing to `~/AGENTS.md` + project specifics), `.gitignore`, `git init`.
3. Register in the Vault: create `01-Projects/<name>.md` (frontmatter `type: project, status: active`, stack fields) + add a line to `00-Dashboard/Projects-MOC.md` + append to `~/myprojects.md`.
4. Commit the Vault.
**Inputs:** project name (arg) + interactive stack answers.

### 3. Agent `personal-archivist` (subagent)
**Purpose:** safely operate on `~/Documents` — locate docs, file new scans into the numbered system, keep `~/Documents/INDEX.md` current.
**Hard rules in system prompt:**
- 🔴 Local-only. **Never** upload/paste/send any content, scan, or extract to any external service, web tool, or cloud LLM.
- 🔴 **Never** copy raw secret values (IDs, bank/RIB, 2FA, full financials) into the Vault or any git-tracked file.
- French official docs keep their names; English for the rest. **Move, never delete.** Confirm large reorganizations.
- Write scope limited to `~/Documents/INDEX.md` and reversible file moves within `~/Documents`.
**Tools (restricted to prevent exfiltration):** Read, Glob, Grep, Edit/Write (INDEX only), Bash (local fs ops). **No WebFetch/WebSearch, no cloud MCP.**

### 4. Agent `vault-librarian` (subagent)
**Purpose:** maintain the Vault — dedupe, validate frontmatter + links, keep MOCs current, fill empty/placeholder notes, commit.
**Procedure highlights:** scan for missing/invalid frontmatter, orphan notes (no MOC/link), duplicate concepts (suggest merge via link), bump `updated`, then commit+push.
**Tools:** Read, Edit, Write, Glob, Grep, mgrep, Bash (git in `~/Vault`).

## Data flow
`/vault-enrich` and `vault-librarian` write to `~/Vault` (git-pushed). `/new-project` writes to
`~/projects/<name>` **and** `~/Vault`. `personal-archivist` writes only inside `~/Documents` (local,
never pushed). All four read the conventions in `~/AGENTS.md` + `~/Vault/99-System/`.

## Error handling
- `vault-enrich`: if a near-duplicate note exists, stop and propose updating it instead of creating.
- `new-project`: if `~/projects/<name>` exists, abort (no overwrite).
- `personal-archivist`: on any action that would transmit data or touch a secret value, refuse and report.
- Git push failure: report; never leave a partial commit unpushed silently.

## Testing / verification
1. `claude plugin marketplace add ~/projects/memo-cc` + enable → `/vault-enrich` and `/new-project` appear; agents listed as subagent types.
2. `/vault-enrich` on a throwaway fact → atomic note created with valid frontmatter, registered in a MOC, committed; re-run on the same fact → updates, no duplicate.
3. `/new-project test-xyz` → folder scaffolded, Vault note + MOC line + myprojects.md line added, committed; reject when run twice.
4. Dispatch `personal-archivist` to "find my passport doc" → locates via INDEX without transmitting; attempt a web tool → refuses.
5. Dispatch `vault-librarian` to "check frontmatter" → reports issues, fixes, commits.
6. Confirm no secret values landed in any git-tracked file (`git -C ~/Vault log -p` spot check).

## Open items (resolved)
- Default stack for `new-project`: **ask each time** (decided 2026-06-29).
- Archivist write scope: **INDEX.md + reversible moves only** (decided).
- 5th `/home-cleanup` command: **deferred** to a later version.
