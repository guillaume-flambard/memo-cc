# LLM fallback — use any model with the same skills/knowledge

Goal: when Claude tokens run out, keep **the exact same Claude Code setup** (skills, subagents, MCP,
hooks, AGENTS.md, Vault, memory) but swap the **model** underneath — or fall back to a fully local model.

## Strategy (highest fidelity first)
1. **claude-code-router (CCR)** — keep Claude Code, route the model. `config.json.template` here →
   `~/.claude-code-router/config.json`. Providers: **OpenRouter** (cheap cloud: DeepSeek/Qwen/Gemini)
   + **Ollama** (local, free, offline).
2. **opencode** (already installed) — model-agnostic harness, reads `~/AGENTS.md`, any provider incl. Ollama.
3. **Gemini CLI / Codex** — read `~/GEMINI.md` / `~/AGENTS.md`; the Vault is the shared cross-LLM memory.

## Setup
```bash
# 1. install router + copy config
npm install -g @musistudio/claude-code-router
mkdir -p ~/.claude-code-router && cp config.json.template ~/.claude-code-router/config.json && chmod 600 ~/.claude-code-router/config.json

# 2. OpenRouter key -> macOS Keychain (get one at openrouter.ai), exported from ~/.zshrc
security add-generic-password -a "$USER" -s "OpenRouter API Key" -w "sk-or-..." -U

# 3. local model (Apple Silicon 16GB sweet spot)
ollama pull qwen2.5-coder:7b     # ~5GB; qwen3-coder:14b (~9GB) is the stretch

# 4. run Claude Code through the router
ccr code                          # instead of `claude`
ccr ui                            # web UI to edit providers/models/routing
ccr model ollama,qwen2.5-coder:7b # force fully-local (offline / no key)
```

## Routing (in config.json)
- `default` → `deepseek/deepseek-chat` (cheap, strong) · `think` → `deepseek/deepseek-r1`
- `longContext` (>60k) → `google/gemini-2.0-flash-001` · `background` → local `qwen2.5-coder:7b`
- Edit model IDs via `ccr ui` if OpenRouter renames them.

## Honest expectations (tested 2026-06-29)
- **Cheap cloud (DeepSeek/Qwen/Gemini)** ≈ closest to Claude efficiency, pennies per task. **Use this for real `ccr code` sessions** — fast, handles Claude Code's large context.
- **Local 16GB** = free/offline/private but **slow with the full Claude Code harness** (the big system prompt overwhelms a 7B; `ccr code`→local timed out >2min). For local, prefer **`opencode`** (lighter harness) or use local only for background/simple/offline tasks.
- Routing plumbing verified: CCR → local model returns correctly on direct requests.
- Secrets stay in the **Keychain**, never plaintext (same policy as the rest of the setup).
