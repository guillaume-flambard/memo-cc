---
name: new-project
description: "Use when Guillaume wants to start a new code project. Scaffolds $MEMOLABS_ROOT/<domain>/<name>/ (default ~/memolabs) with his conventions, registers it by name in PROJECTS.md (local AGENTS.md/CLAUDE.md, README, git), ASKS for the stack each time, then registers it in the Vault (1-Projects + Projects-MOC) and ~/myprojects.md. Trigger: /new-project <name>."
---

# new-project — scaffold and register a new project

Create a new project under the one root `$MEMOLABS_ROOT` (default `~/memolabs`), register it by name in
`$MEMOLABS_ROOT/PROJECTS.md` (the one registry), and wire it into the knowledge base. `~/projects` was retired on
2026-10-14: never create it, as a folder or a link.

## Checklist (do in order)

1. **Name and domain.** Take `<name>` (kebab-case, English) and its domain (`os`, `lab`, `products`, `research`,
   `clients`, `studio`). If `proj path <name>` resolves or `$MEMOLABS_ROOT/<domain>/<name>/` exists, STOP (no overwrite).
2. **Ask the stack — every time (no default).** One compact question covering: language/framework,
   DB/backend, payments if relevant (e.g. Next.js + Tailwind + Supabase + Stripe). Wait for the answer.
3. **Scaffold `$MEMOLABS_ROOT/<domain>/<name>/`:**
   - `git init`
   - `README.md` (name, one-line purpose, stack)
   - local `CLAUDE.md` and `AGENTS.md` — short, pointing to `~/memolabs/AGENTS.md` for the project rules and stating
     the project's stack + any project-specific rules
   - `.gitignore` appropriate to the stack
4. **Register in the registry:** add one row to `$MEMOLABS_ROOT/PROJECTS.md` (table « Projets appartenant à Memo
   Labs »): `| <name> | <domain>/<name> | repo | active | <nature> | <stack> | - |`, Path relative to the root.
   Check with `projects-lint` (clean) and `proj path <name>` (prints the new folder).
5. **Register in the Vault** (`~/Vault`):
   - Create `1-Projects/<name>.md` with frontmatter `type: project, status: active, created/updated:
     today`, plus optional `repo, stack: [...], language, url`. Follow `4-Tools/frontmatter-spec.md`.
   - Add a bullet to `~/Vault/0-Home/Projects-MOC.md` (and a domain MOC like `AI-MOC`/`Mobile-Apps-MOC` if it fits).
   - Append a row to `~/myprojects.md`.
6. **Commit the Vault**, only the paths you wrote, under the sync lock:
   `/Users/memo/Vault/4-Tools/scripts/vault-commit.sh -m "Add project <name>" 1-Projects/<name>.md 0-Home/Projects-MOC.md`.
   Never `git add -A`: other sessions write in the Vault at the same time.
7. Report the created paths, the registry row and the registered note.

## Notes
- Don't scaffold framework boilerplate unless asked — keep the skeleton minimal; the user can run the
  framework's own init (`create-next-app`, etc.) after.
- English naming throughout. Respect `~/AGENTS.md` golden rules.
