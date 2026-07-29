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

## Enabled plugins (15 — core, always on)
mgrep@Mixedbread-Grep · superpowers@claude-plugins-official · claude-mem@thedotmack ·
context7@claude-plugins-official · github@claude-plugins-official · commit-commands@claude-plugins-official ·
code-review@claude-plugins-official · code-simplifier@claude-plugins-official ·
typescript-lsp@claude-plugins-official · claude-md-management@claude-plugins-official ·
plugin-dev@claude-plugins-official · obsidian@obsidian-skills · frontend-design@claude-plugins-official ·
memo@memo-marketplace · caveman@caveman

## Disabled plugins (23 — on-demand, re-enable via `/plugin` when needed)
vercel · linear · sentry · semgrep · ralph-loop · security-guidance · agent-sdk-dev · feature-dev ·
pr-review-toolkit · chrome-devtools-mcp · playwright (all @claude-plugins-official) ·
ui-ux-pro-max@ui-ux-pro-max-skill · claude-seo@agricidaniel-seo ·
context-mode@context-mode (2026-07-03: recurring ~100-tok injection on every Read/Bash/Grep/mcp call
≈ 10k tok/100 calls + 14 hook bindings — cost outweighed savings) ·
threejs-webgl / gsap-scrolltrigger / react-three-fiber / core-3d-animation / extended-3d-scroll /
animation-components / authoring-motion / meta-skills (all @claude-design-skillstack; 2026-07-03:
~11k tok combined, 3 of them 100% duplicated inside core-3d-animation — re-enable only core-3d-animation
for 3D work)

## Config audit 2026-07-03 (measured)
Full read-only audit then slim-down. System-prompt frontmatter: **99,982B (~25k tok) → 36,655B (~9.2k tok)**.
- **Global skills: 37 of 73 archived** to `~/.claude/skills-archive/` (moved, never deleted): 12 overlapping
  design-taste skills (kept impeccable, imagegen-frontend-web, brandkit, logo-generator, aceternity-ui,
  design-inspiration, responsive-design), 2 orphans (llm-agnostics: no SKILL.md; open-gstack-browser:
  name collision with connect-chrome), 23 dormant gstack wrappers (autoplan, benchmark*, plan-*-review,
  retro, office-hours, canary, browse=duplicate of gstack, design-consultation/html/review/shotgun,
  setup/sync-gbrain, skillify, pair-agent, devex-review, document-release, landing-report).
  ⚠️ `~/.claude/skills/gstack/` is the full gstack source repo and the symlink target of the ~20
  remaining wrappers — never move it.
- **Permissions purged** in `settings.local.json` (49 → 36 allow entries): removed `rm:*`, `ssh:*`,
  `chmod:*`, 7 dead shell-loop fragments, 3 one-shot fossils.
- **Removed** the `context-mode-cache-heal.mjs` SessionStart hook from `settings.json` (orphaned once
  context-mode disabled). Backups: `~/.claude/backups-audit-2026-07-03/`.

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

## opencode (canonical global config — audit 2026-07-04)
Templates in `setup/opencode/` (installed by `bootstrap.sh` step 7):
- **`~/.config/opencode/opencode.json`** — global MCP: `context7` + `shadcn` enabled; `playwright` +
  `draw-things` present but `"enabled": false` (flip on demand). Everything else per-project.
- **`~/.config/opencode/AGENTS.md`** — global rules (home map, Vault, sensitive zones, English names,
  jj, small-context discipline for free models).
- ⚠️ **`~/.opencode/opencode.json` (legacy path) is MERGED into the global config** — keep it
  schema-only, or its MCP entries silently pile onto every session (bootstrap neutralizes it).
- Audit findings 2026-07-04: 17 MCP servers globally enabled across the two files (~14 local processes
  spawned per session, hundreds of tool schemas — deadly for free models' 32–64k context windows);
  4 pointed at a deleted `~/projects/echo/echotravel/.opencode/` (crashed every start); `stitch` was
  corrupted by the two-file merge and carried a **plaintext Google API key** (rotate it); `dcp.jsonc` +
  `config.json` were orphans; 1.39 GB stale logs purged from `~/.local/share/opencode/log`.
  Backups: `~/.config/opencode/backups-audit-2026-07-04/`.
- Project MCP (storybook, antd, booking…) belongs in each repo's `opencode.json`, never global.
- Secrets in opencode config: use `{env:VAR}` substitution, never literal keys.

## LLM fallback (when out of Claude tokens)
Keep the same harness/skills/knowledge, swap the model. See `setup/llm-fallback/`.
- **claude-code-router** (`ccr code`) routes Claude Code to OpenRouter (DeepSeek/Qwen/Gemini, cheap) or
  **Ollama** (local). Config template at `setup/llm-fallback/config.json.template` → `~/.claude-code-router/config.json`.
- Key in Keychain (`OpenRouter API Key`), exported from `~/.zshrc`. `ccr model ollama,qwen2.5-coder:7b` = fully local.
- Local model: **`qwen2.5-coder:7b`** (16GB sweet spot; `qwen3-coder:14b` stretch).
- **`~/GEMINI.md`** mirrors `~/AGENTS.md` for Gemini CLI; **opencode** (model-agnostic) reads AGENTS.md; the Vault is the shared cross-LLM memory.

## Global skills (`~/.claude/skills/`)
Reproducible global skills live in `setup/global-skills/` and are installed by `bootstrap.sh`.
- _(paperclip removed 2026-07-29 — Paperclip app fully deleted; it duplicated stasis/jobs/GitHub/Vault
  and carried no live work. Venture task state now lives in GitHub issues + Vault notes.)_

## Statusline fix
`setup/statusline-command.sh` uses locale-independent integer truncation (`${pct%%.*}`) so `printf` never
breaks under FR locale, plus the ccusage cost segment with graceful fallback.
