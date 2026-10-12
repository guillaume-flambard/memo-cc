# Cleanup report, systeme live de Guillaume (2026-09-05)

Mesure read-only via `bootstrap.sh --check` et audits. La partie sure a ete faite dans la session
(voir plus bas). Ce qui reste demande ta supervision : a executer quand tu ne fais pas tourner six
sessions en parallele, une chose a la fois.

## Fait dans la session (sur, deja pousse)
- **Starter-kit exportable** extrait a `~/projects/active/devtools/ai-system-starter` (c'est la
  version propre, lisible-humain, de ton systeme, et l'install de Zied). Audit du squelette : 0/0/0.
- **Vault d'entreprise A-table** cree a `~/Vault-atable` (depot git local, pret a pousser). Audit :
  0/0/0. Voir son `SETUP.md`.
- **Pointeurs-retour** ajoutes aux 3 notes A-table du vault perso vers `~/Vault-atable`, commit via
  `vault-commit.sh` (chemins nommes, verrou pris).

## Drift mesure vs canonical (a decider)

### 1. MCP globaux : 9 actifs, canonical dit shadcn seul
`bootstrap.sh --check` liste en global : `cloudflare-api`, `cloudflare-docs`, `cloudflare-bindings`,
`cloudflare-builds`, `cloudflare-observability`, `codegraph`, `chrome-devtools`, `google-workspace`,
`searxng`. Les cinq `cloudflare-*` sont en plus auth-gated (inutilisables sans OAuth) mais chargent
quand meme leurs schemas d'outils a chaque session. C'est exactement le cout que CANONICAL-CONFIG
veut eviter (surcharge d'outils, precision qui baisse, tokens payes a chaque tour).
- **Recommande** : garder `codegraph`, `google-workspace`, `searxng`, `chrome-devtools` si tu les
  utilises ; sortir les `cloudflare-*` du global vers le(s) repo(s) cloudflare concernes (`.mcp.json`
  par projet). Vise 3 a 6 actifs.
- **Non scriptable ici sans casser** : le retrait se fait a la main dans `~/.claude.json`
  (`mcpServers`) apres avoir verifie quel projet en a besoin.

### 2. PIEGE opencode, ne pas lancer bootstrap etape 7 a l'aveugle
`bootstrap.sh` installerait `setup/opencode/opencode.json` (MCP seul) sur
`~/.config/opencode/opencode.json`. Ton bloc provider `bai` (27 modeles, defaut qwen3.8-flash) vit
dans `~/.config/opencode/opencode.jsonc`. Les deux fichiers coexistent et OpenCode peut les fusionner.
- **Avant tout `bootstrap.sh` reel** : verifie que l'etape opencode ne vide pas ton provider `bai`.
  Le starter, lui, ecrit un `opencode.json` AVEC le bloc `bai` (sans cle en dur) : c'est la version
  a garder comme canonical, pas le `setup/opencode/opencode.json` actuel qui n'a que le MCP.
- **Action** : aligner `setup/opencode/opencode.json` sur celui du starter (ajouter le provider
  `bai`, cle via `opencode auth login`), puis ranger la cle en clair de `opencode.jsonc` ligne 13
  dans le Keychain ou via `opencode auth login`.

### 3. Skills dormants + plugins
Le pattern d'audit 2026-07-03 (archiver vers `skills-archive/`, jamais supprimer) n'a pas ete
re-mesure ici. A refaire en pass dediee avec `/context` avant/apres.

### 4. Schema du vault live : 3 notes generees hors-schema
`0-Home/Pipeline.md` (`bad type 'dashboard'`, `missing created`) et `0-Home/Daily-Brief.md`
(no frontmatter) sont des sorties generees. Soit les exempter dans `vault-audit.py`
(`SCHEMA_EXEMPT_PREFIX`/`FILES`), soit corriger leur generateur (`pipeline.py`). Tache typique du
`vault-librarian`.

## Comment executer la suite, sans collision
Une pass, seul, hors des heures ou d'autres sessions tournent. Pour le vault, `vault-commit.sh`
uniquement. Pour `~/.claude.json` et l'opencode, edite a la main, sauvegarde avant, relance Claude
Code puis `/context` pour mesurer le gain. Deleguer l'audit du vault a l'agent `vault-librarian`.
