---
name: vault-enrich
description: "Use when a durable, reusable learning, decision, fix, or pattern emerges that belongs in Guillaume's Obsidian Vault (~/Vault). Promotes it into ONE conforming atomic note (frontmatter, wikilinks, MOC registration) and commits+pushes. Trigger: /vault-enrich, or whenever you learn something worth keeping across sessions."
---

# vault-enrich — promote knowledge into the Vault

Turn a durable learning into a single atomic note in `~/Vault`, following the vault's own contract
(`~/Vault/AGENTS.md`, `99-System/conventions.md`, `99-System/frontmatter-spec.md`). Human-first,
source-of-truth, atomic. Do NOT dump session chatter — only durable, reusable knowledge.

## Checklist (do in order)

1. **Golden Rule gate.** Ask: does this note answer at least one *future* question? If not, STOP and
   tell the user it's not worth a note.
2. **Search first (anti-duplicate).** Search the vault for the concept:
   `mgrep "<concept>"` (or `rg -i "<concept>" ~/Vault --glob '*.md'`). If a note already covers it,
   **update that note** (bump `updated`, add to it) — never create a duplicate. Link, don't repeat.
3. **Pick the folder** by type: `01-Projects` `02-Clients` `03-Technologies` `04-Business`
   `05-Learning` `06-Ideas` `07-Research` `08-Career` `09-Life` `10-Resources` (system → `99-System`).
4. **Start from the template** in `~/Vault/99-System/templates/` for that type if one exists.
5. **Frontmatter** per `~/Vault/99-System/frontmatter-spec.md`:
   `title, type, status, created (today), updated (today), tags (controlled — see 99-System/tagging.md), related [[...]]`.
   Filename = the concept in Title Case (e.g. `Vector Databases.md`); projects use the repo name.
6. **Write the note atomically** — one concept. Add `[[wikilinks]]` to related notes.
7. **Register in the right MOC** in `~/Vault/00-Dashboard/*-MOC.md` (add a bullet linking the note).
8. **Never copy secrets** (IDs, bank/RIB, 2FA, raw financials) into the vault — status/metadata only.
9. **Commit + push** (one atomic commit):
   `git -C ~/Vault add -A && git -C ~/Vault commit -m "<what changed>" && git -C ~/Vault push`.

## Notes
- Today's date comes from the environment; convert relative dates to absolute.
- If unsure which folder/type, ask the user one short question rather than guessing.
- Respect `~/AGENTS.md` (home map) and the English-naming rule.
