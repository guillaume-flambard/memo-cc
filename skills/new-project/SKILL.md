---
name: new-project
description: "Use when Guillaume wants to start a new code project. Scaffolds ~/projects/<name>/ with his conventions (local AGENTS.md/CLAUDE.md, README, git), ASKS for the stack each time, then registers it in the Vault (01-Projects + Projects-MOC) and ~/myprojects.md. Trigger: /new-project <name>."
---

# new-project — scaffold and register a new project

Create a new project under `~/projects/` and wire it into the knowledge base so it's discoverable.

## Checklist (do in order)

1. **Name.** Take `<name>` (kebab-case, English). If `~/projects/<name>/` already exists, STOP (no overwrite).
2. **Ask the stack — every time (no default).** One compact question covering: language/framework,
   DB/backend, payments if relevant (e.g. Next.js + Tailwind + Supabase + Stripe). Wait for the answer.
3. **Scaffold `~/projects/<name>/`:**
   - `git init`
   - `README.md` (name, one-line purpose, stack)
   - local `CLAUDE.md` and `AGENTS.md` — short, pointing to `~/AGENTS.md` for the home map and stating
     the project's stack + any project-specific rules
   - `.gitignore` appropriate to the stack
4. **Register in the Vault** (`~/Vault`):
   - Create `01-Projects/<name>.md` with frontmatter `type: project, status: active, created/updated:
     today`, plus optional `repo, stack: [...], language, url`. Follow `99-System/frontmatter-spec.md`.
   - Add a bullet to `~/Vault/00-Dashboard/Projects-MOC.md` (and a domain MOC like `AI-MOC`/`Mobile-Apps-MOC` if it fits).
   - Append a row to `~/myprojects.md`.
5. **Commit the Vault:** `git -C ~/Vault add -A && git -C ~/Vault commit -m "Add project <name>" && git -C ~/Vault push`.
6. Report the created paths and the registered note.

## Notes
- Don't scaffold framework boilerplate unless asked — keep the skeleton minimal; the user can run the
  framework's own init (`create-next-app`, etc.) after.
- English naming throughout. Respect `~/AGENTS.md` golden rules.
