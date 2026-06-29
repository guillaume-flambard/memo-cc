---
name: paperclip
description: "Use when working on one of Guillaume's tracked ventures/projects (Echo Travel, Largo IA, …) or whenever project work should be tracked as issues. Drives the self-hosted Paperclip app (local project/issue/agent manager at 127.0.0.1:3100) via the `paperclipai` CLI: ensure it's up, find the company, list/create/update/comment issues, checkout issues for agents. Trigger: 'paperclip', 'track this in paperclip', 'open the project board'."
---

# paperclip — track project work in the self-hosted Paperclip app

Paperclip is Guillaume's local project/issue/agent manager (`paperclipai run`, dashboard at
`http://127.0.0.1:3100`). Companies = his ventures/projects; issues use identifiers like `PC-12`.
Use this skill to keep project work in sync with Paperclip instead of losing it in chat.

## 0. Ensure it's running
- `paperclip status` → if down, `paperclip start` (controller in `~/.local/bin/paperclip`, port 3100).
- `paperclip open` opens the dashboard; `paperclip logs` for the server log.

## 1. Find the company (= project/venture)
- `paperclipai company list` → pick the active one by name. Known IDs (verify, they can change):
  - **Echo Travel** `5473dbed-a886-48ab-969b-3bc327bb5291` (active)
  - **Largo IA** `7efc1c9a-e3d1-4876-adda-e3e122a95cfa` (active)
  - Phangan AI `dab3dd51-…` (archived)
- Add `--json` to any command to parse output reliably.

## 2. Work with issues (the core loop)
- **List:** `paperclipai issue list -C <companyId> [--json]`
- **Get:** `paperclipai issue get PC-12`
- **Create:** `paperclipai issue create -C <companyId> --title "<t>" --description "<d>" --priority <p> --status <s>`
  (optional: `--assignee-agent-id`, `--project-id`, `--goal-id`, `--parent-id`)
- **Update:** `paperclipai issue update <issueId> --status <s> [--title/--description/--priority …]`
- **Comment:** `paperclipai issue comment <issueId> --body "<note>"` *(check `paperclipai issue help comment` for the exact flag)*
- **Agent flow:** `paperclipai issue checkout <issueId>` (assign to an agent) · `release <issueId>` (back to todo)
- When unsure of flags for any subcommand: `paperclipai issue help <subcommand>`.

## 3. Agents (optional)
- `paperclipai agent list -C <companyId>` — the AI agents on a company.
- **One-time auth/integration:** `paperclipai agent local-cli <agentRef>` mints an agent API key,
  installs Paperclip's own Claude/Codex skills, and prints shell exports. Store the key in the **macOS
  Keychain** (entry e.g. `Paperclip Agent Key`), not plaintext — then pass `--api-key "$(security find-generic-password -s 'Paperclip Agent Key' -w)"` or export it.

## How to use it for projects (the habit)
- Starting work on a tracked venture → `company list` → `issue list` to see what's open; pick or `create` an issue for the task.
- During work → `issue update` status (todo→in_progress→done) and `issue comment` with decisions/links.
- Keep durable *knowledge* in the Vault (`/vault-enrich`); keep *task/issue state* in Paperclip. Don't duplicate.

## Notes
- Local, private (`deploymentMode: local_trusted`). Keep API keys in the Keychain (same policy as the rest of the setup).
- PayKit isn't a Paperclip company yet — create one if you want to track the launch sprint there.
