# Canonical Claude Code config — Guillaume's "general truth"

The standard, reproducible setup applied across all of Guillaume's machines. Run `setup/bootstrap.sh`
to bring a machine to this state. Rationale (token cost re-paid every turn, tool-overload degrades
accuracy) is in the Vault: `03-Technologies/Claude-Code-Setup.md` + `AI-Tooling-Inventory.md`.

## Principles
- **MCP servers: 3–6 active max.** Global MCP = `shadcn` only. Niche servers live **per-project** in each repo's `.mcp.json`, never global.
- **Plugins: keep a lean core enabled; everything else on-demand** via `/plugin`.
- **CLAUDE.md < 200 lines.** Push project/business context to project-scoped or `@import` files.
- **Secrets never in plaintext config** — store in macOS Keychain, reference via `${VAR}` exported from `~/.zshrc`.
- **Measure**: `ccusage` (installed + wired to statusline) + `/context`.

## Enabled plugins (14 — core, always on)
mgrep@Mixedbread-Grep · superpowers@claude-plugins-official · claude-mem@thedotmack ·
context7@claude-plugins-official · github@claude-plugins-official · commit-commands@claude-plugins-official ·
code-review@claude-plugins-official · code-simplifier@claude-plugins-official ·
typescript-lsp@claude-plugins-official · claude-md-management@claude-plugins-official ·
plugin-dev@claude-plugins-official · obsidian@obsidian-skills · frontend-design@claude-plugins-official ·
memo@memo-marketplace

## Disabled plugins (13 — on-demand, re-enable via `/plugin` when needed)
vercel · linear · sentry · semgrep · ralph-loop · security-guidance · agent-sdk-dev · feature-dev ·
pr-review-toolkit · chrome-devtools-mcp · playwright (all @claude-plugins-official) ·
ui-ux-pro-max@ui-ux-pro-max-skill · claude-seo@agricidaniel-seo

## Global MCP servers (`~/.claude.json` → mcpServers)
Keep: `shadcn`. Remove from global: `gbrain` (~150 tools), `stitch`. (gbrain on-demand; niche MCP per-project.)

## Efficiency tooling
- **rtk** (Rust Token Killer) hook on Bash — ~60% savings. **mgrep** for all search.
- **ccusage** installed globally + integrated into `setup/statusline-command.sh` (shows live `💰 session/today/block | 🔥 burn`).
- **claude-mem** kept; prune logs periodically (`~/.claude-mem/logs`).
- **Serena** — enable per-project only for heavy code work (adds ~25 tools).

## Security
- 2FA recovery codes, LINE bot token → **macOS Keychain** (entries: `LINE Channel Access Token`, `LINE Destination User ID`, `2FA Recovery - *`).
- `~/.claude/mcp_servers.json` references `${LINE_CHANNEL_ACCESS_TOKEN}` / `${LINE_DESTINATION_USER_ID}`; chmod 600; exports from Keychain in `~/.zshrc`.

## Manual steps (not scriptable here)
- **Cowork bundles** (account-provided, per-session mount): disable via `/plugin` the irrelevant ones —
  bio-research, legal, finance, human-resources, sales, operations, customer-support, enterprise-search,
  auth0, marketing, small-business, product-management. Keep: engineering, data, design, prisma, qdrant,
  pdf-viewer, productivity, figma, canva, cowork-plugin-management.
- After bootstrap: **fully quit & relaunch Claude Code**, then check `/context`.

## LLM fallback (when out of Claude tokens)
Keep the same harness/skills/knowledge, swap the model. See `setup/llm-fallback/`.
- **claude-code-router** (`ccr code`) routes Claude Code to OpenRouter (DeepSeek/Qwen/Gemini, cheap) or
  **Ollama** (local). Config template at `setup/llm-fallback/config.json.template` → `~/.claude-code-router/config.json`.
- Key in Keychain (`OpenRouter API Key`), exported from `~/.zshrc`. `ccr model ollama,qwen2.5-coder:7b` = fully local.
- Local model: **`qwen2.5-coder:7b`** (16GB sweet spot; `qwen3-coder:14b` stretch).
- **`~/GEMINI.md`** mirrors `~/AGENTS.md` for Gemini CLI; **opencode** (model-agnostic) reads AGENTS.md; the Vault is the shared cross-LLM memory.

## Statusline fix
`setup/statusline-command.sh` uses locale-independent integer truncation (`${pct%%.*}`) so `printf` never
breaks under FR locale, plus the ccusage cost segment with graceful fallback.
