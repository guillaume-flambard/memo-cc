#!/usr/bin/env bash
# Bootstrap Guillaume's canonical Claude Code config on this machine.
# Idempotent. Backs up everything it touches. See CANONICAL-CONFIG.md for rationale.
#   Usage: bash bootstrap.sh [--check]
#     --check : dry-run, report what WOULD change, modify nothing.
set -uo pipefail

CHECK=0; [ "${1:-}" = "--check" ] && CHECK=1
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$HOME/.claude/settings.json"
CLAUDEJSON="$HOME/.claude.json"
STATUSLINE="$HOME/.claude/statusline-command.sh"
STAMP="$(date +%Y%m%d-%H%M%S)"
say(){ printf '%s\n' "$*"; }
do_backup(){ [ "$CHECK" = 1 ] && { say "  [check] would back up $1"; return; }; cp "$1" "$1.bak-bootstrap-$STAMP" 2>/dev/null && say "  backed up $1"; }

ENABLE=(
  mgrep@Mixedbread-Grep superpowers@claude-plugins-official claude-mem@thedotmack
  context7@claude-plugins-official github@claude-plugins-official commit-commands@claude-plugins-official
  code-review@claude-plugins-official code-simplifier@claude-plugins-official
  typescript-lsp@claude-plugins-official claude-md-management@claude-plugins-official
  plugin-dev@claude-plugins-official obsidian@obsidian-skills frontend-design@claude-plugins-official
  memo@memo-marketplace caveman@caveman
)
DISABLE=(
  vercel@claude-plugins-official linear@claude-plugins-official sentry@claude-plugins-official
  semgrep@claude-plugins-official ralph-loop@claude-plugins-official security-guidance@claude-plugins-official
  agent-sdk-dev@claude-plugins-official feature-dev@claude-plugins-official pr-review-toolkit@claude-plugins-official
  chrome-devtools-mcp@claude-plugins-official playwright@claude-plugins-official
  ui-ux-pro-max@ui-ux-pro-max-skill claude-seo@agricidaniel-seo
  context-mode@context-mode
  threejs-webgl@claude-design-skillstack gsap-scrolltrigger@claude-design-skillstack
  react-three-fiber@claude-design-skillstack core-3d-animation@claude-design-skillstack
  extended-3d-scroll@claude-design-skillstack animation-components@claude-design-skillstack
  authoring-motion@claude-design-skillstack meta-skills@claude-design-skillstack
)

say "== 1. Plugins (enabledPlugins in settings.json) =="
if [ -f "$SETTINGS" ]; then
  do_backup "$SETTINGS"
  ENABLE="${ENABLE[*]}" DISABLE="${DISABLE[*]}" CHECK="$CHECK" SETTINGS="$SETTINGS" python3 - <<'PY'
import json,os
p=os.environ["SETTINGS"]; check=os.environ["CHECK"]=="1"
d=json.load(open(p)); ep=d.get("enabledPlugins",{})
for k in os.environ["ENABLE"].split():
    if ep.get(k)is not True: print(f"  enable  {k}"); ep[k]=True
for k in os.environ["DISABLE"].split():
    if ep.get(k)is not False: print(f"  disable {k}"); ep[k]=False
d["enabledPlugins"]=ep
if not check: json.dump(d,open(p,"w"),indent=2); print("  -> settings.json written")
else: print("  [check] settings.json not written")
PY
else
  say "  ! $SETTINGS not found — skipping (install Claude Code first)"
fi

say "== 2. Global MCP (remove gbrain/stitch from ~/.claude.json; keep shadcn) =="
if [ -f "$CLAUDEJSON" ]; then
  CHECK="$CHECK" CLAUDEJSON="$CLAUDEJSON" python3 - <<'PY'
import json,os,shutil,datetime
p=os.environ["CLAUDEJSON"]; check=os.environ["CHECK"]=="1"
d=json.load(open(p)); ms=d.get("mcpServers",{}); removed=[k for k in("gbrain","stitch") if k in ms]
if removed and not check:
    shutil.copy(p,p+".bak-bootstrap-"+datetime.datetime.now().strftime("%Y%m%d-%H%M%S"))
    for k in removed: ms.pop(k)
    d["mcpServers"]=ms; json.dump(d,open(p,"w"),indent=2)
print(f"  {'[check] would remove' if check else 'removed'}: {removed or 'nothing'} | remaining: {list(ms.keys())}")
PY
else
  say "  ! $CLAUDEJSON not found — skipping"
fi

say "== 3. ccusage (token analytics) =="
if command -v ccusage >/dev/null 2>&1; then say "  already installed ($(ccusage --version 2>/dev/null))"
elif [ "$CHECK" = 1 ]; then say "  [check] would: npm install -g ccusage"
else npm install -g ccusage >/dev/null 2>&1 && say "  installed ccusage" || say "  ! ccusage install failed (run: npm i -g ccusage)"; fi

say "== 4. Statusline (canonical, with ccusage + FR-locale fix) =="
if [ -f "$STATUSLINE" ] && cmp -s "$HERE/statusline-command.sh" "$STATUSLINE"; then
  say "  already canonical"
elif [ "$CHECK" = 1 ]; then say "  [check] would install $HERE/statusline-command.sh -> $STATUSLINE"
else
  [ -f "$STATUSLINE" ] && do_backup "$STATUSLINE"
  cp "$HERE/statusline-command.sh" "$STATUSLINE" && chmod +x "$STATUSLINE" && say "  installed canonical statusline"
fi

say "== 5. LLM fallback (claude-code-router + Ollama + GEMINI.md) =="
CCRCFG="$HOME/.claude-code-router/config.json"
GEM="$HOME/GEMINI.md"
if command -v ccr >/dev/null 2>&1; then say "  ccr already installed ($(ccr -v 2>/dev/null))"
elif [ "$CHECK" = 1 ]; then say "  [check] would: npm install -g @musistudio/claude-code-router"
else npm install -g @musistudio/claude-code-router >/dev/null 2>&1 && say "  installed claude-code-router" || say "  ! ccr install failed"; fi
if [ -f "$CCRCFG" ]; then say "  CCR config present (not overwriting)"
elif [ "$CHECK" = 1 ]; then say "  [check] would install CCR config from template"
else mkdir -p "$(dirname "$CCRCFG")" && cp "$HERE/llm-fallback/config.json.template" "$CCRCFG" && chmod 600 "$CCRCFG" && say "  installed CCR config (set OPENROUTER_API_KEY in Keychain)"; fi
if [ -f "$GEM" ] && cmp -s "$HERE/GEMINI.md" "$GEM"; then say "  GEMINI.md already canonical"
elif [ "$CHECK" = 1 ]; then say "  [check] would install ~/GEMINI.md"
else [ -f "$GEM" ] && do_backup "$GEM"; cp "$HERE/GEMINI.md" "$GEM" && say "  installed ~/GEMINI.md"; fi
say "  (local model: run 'ollama pull qwen2.5-coder:7b' — ~5GB, not auto-pulled)"

say "== 6. Global skills (install setup/global-skills/* into ~/.claude/skills) =="
if [ -d "$HERE/global-skills" ]; then
  for sk in "$HERE"/global-skills/*/; do
    [ -d "$sk" ] || continue
    name="$(basename "$sk")"; dest="$HOME/.claude/skills/$name"
    if [ -f "$dest/SKILL.md" ] && cmp -s "$sk/SKILL.md" "$dest/SKILL.md"; then say "  $name already current"
    elif [ "$CHECK" = 1 ]; then say "  [check] would install global skill: $name"
    else mkdir -p "$dest" && cp -R "$sk"* "$dest/" && say "  installed global skill: $name"; fi
  done
else say "  (no global-skills dir)"; fi

say ""
say "== Manual steps (not scriptable) =="
say "  - /plugin : disable Cowork bundles (bio-research, legal, finance, hr, sales, operations,"
say "    customer-support, enterprise-search, auth0, marketing, small-business, product-management)."
say "  - Secrets (LINE token, 2FA codes) -> macOS Keychain; config references \${VAR}. See CANONICAL-CONFIG.md."
say "  - Register memo marketplace if missing:  /plugin marketplace add guillaume-flambard/memo-cc"
say "  - Fully quit & relaunch Claude Code, then run /context to verify."
say ""
[ "$CHECK" = 1 ] && say "DRY RUN — nothing changed." || say "Done. Restart Claude Code to apply."
