# Writer Reference Classification ([P2-T4])

Timestamp: 2026-11-19T16-55
Plan: plan-h3-sync-writer-retirement.md
Command: git grep -c -F -e 'sync-agents-from-instructions' -- . ':!docs/features/' ; git grep -c -F -e 'syncAgentsFromInstructions' -- . ':!docs/features/' (repeat of the P0-T1 search, at the head after P2-T1)
EXIT_CODE: 0
Output Summary: 8 files hold a WRITER-TOKENS hit (6 for `sync-agents-from-instructions`, 2 for `syncAgentsFromInstructions`, both research files in both lists); every hit is classified `historical` or `example`; 0 unclassified; 0 hits in a file Phase 1 edited (P0-T1 baseline: 23 files).

## Hits (file | token | count | class | reason)

- docs/research/20260321-bundle-sync-agents-implementation-research.md | sync-agents-from-instructions | 15 | historical | dated research record under `docs/research/`
- docs/research/20260321-bundle-sync-agents-implementation-research.md | syncAgentsFromInstructions | 4 | historical | dated research record under `docs/research/`
- docs/research/20260412-codex-github-skills-agents-migration-implementation-research.md | sync-agents-from-instructions | 3 | historical | dated research record under `docs/research/`
- docs/research/20260412-codex-github-skills-agents-migration-implementation-research.md | syncAgentsFromInstructions | 2 | historical | dated research record under `docs/research/`
- .github/agents/atomic_planning.agent.md | sync-agents-from-instructions | 4 | example | illustrative plan text (sample task lines such as replacing `Write-Host` calls in the script); names no live command
- .github/agents/powershell-atomic-planning.agent.md | sync-agents-from-instructions | 4 | example | illustrative plan text, same sample tasks
- extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md | sync-agents-from-instructions | 4 | example | bundle copy of the illustrative agent text
- extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md | sync-agents-from-instructions | 4 | example | bundle copy of the illustrative agent text

## Removed since P0-T1

- Phase 1 edits or deletions: `.vscode/tasks.json`, `config/poshqc-shard-weights.json`, the three deleted writer files, `reference-rewrites.ts` and its test, `repo-automation-command-registration-admin.ts`, `package.json`, the three extension suites, `push_down_copilot_customizations_rewrites.py` and its test, `README.md`, `extensions/drm-copilot/README.md`.
- `scripts/harness-generation/HarnessInstructions.psm1`: reworded before P2-T1 (`writer-reference-resolution-h3.2026-11-19T16-43.md`); no hit remains.

SearchScope: tracked files of the worktree excluding `docs/features/`.
SearchPatterns: the two WRITER-TOKENS, fixed-string.
SearchResult: the eight files above.
