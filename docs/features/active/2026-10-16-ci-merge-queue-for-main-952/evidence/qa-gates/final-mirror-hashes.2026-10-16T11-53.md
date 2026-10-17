# Final Mirror Hashes (P8-T9, AC-20, D10(a), D10(b))

Timestamp: 2026-10-16T11-53
Command: git hash-object over the 20 P0-T5 paths followed by .claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1
EXIT_CODE: 0
Output Summary: 26 hashes; PAIRS_EQUAL=13/13; HELPER_RUNTIMES_EQUAL=true; all ten P0-T6 pairs differ from their P0-T6 hashes

| # | Pair | Source hash | Mirror hash | Equal | P0-T6 hash | Changed since P0-T6 |
|---|---|---|---|---|---|---|
| 1 | .claude/hooks/enforce-epic-merge-gate.ps1 | a7250a43d70088f5c1d3c73588363f875368b036 | a7250a43d70088f5c1d3c73588363f875368b036 | yes | 19f7c5e2384713176e3fce61014c5cd937cf9f81 | yes |
| 2 | .codex/hooks/enforce-epic-merge-gate.ps1 | d14b90abe54b3500a464be50e4a659c14f20c1e4 | d14b90abe54b3500a464be50e4a659c14f20c1e4 | yes | 807a776677f0364878a400f07bd7d9cd24a91694 | yes |
| 3 | .claude/skills/parallel-orchestrate/SKILL.md | 92b4f9ceefb534a387cbeccc46ee25b87a5a834b | 92b4f9ceefb534a387cbeccc46ee25b87a5a834b | yes | ef8b82ac082859c1eb76c78a038a300773859950 | yes |
| 4 | .claude/agents/parallel-orchestrator.md | 563c0467331aaae99c26af4ec990aec6fa156a5d | 563c0467331aaae99c26af4ec990aec6fa156a5d | yes | 3dc1722fb81c8e9a0c76f998f3b23c9252014e20 | yes |
| 5 | .claude/skills/orchestrate/SKILL.md | d557a13190289b45993553c97795148feb0abae0 | d557a13190289b45993553c97795148feb0abae0 | yes | 1225177772f7d9bc7df8a25b0a3163d5471c0ab0 | yes |
| 6 | .claude/skills/epic-orchestrate/SKILL.md | 55280cad8670b942d67f6b64381791f7e9773725 | 55280cad8670b942d67f6b64381791f7e9773725 | yes | 1e4c374032e597caf61d3253fabb07b8da6675fc | yes |
| 7 | .claude/agents/epic-orchestrator.md | 7db699a0c0493be7d043d09216e37f4021906660 | 7db699a0c0493be7d043d09216e37f4021906660 | yes | b91cf900cc9b2b1257c18cec8078440fcff4957c | yes |
| 8 | .agents/skills/epic-orchestrate/SKILL.md | 23f7b4931d865b92d51ef52a1bde698f90652ac3 | 23f7b4931d865b92d51ef52a1bde698f90652ac3 | yes | c708d88dd34c984267f19e656c86d2ec1e2ef686 | yes |
| 9 | .codex/agents/epic-orchestrator.toml | 34416553d2f236e9c3308cd8876f00bfea9b13be | 34416553d2f236e9c3308cd8876f00bfea9b13be | yes | 7ea809e0809690d39140b4958fd731ea77491d27 | yes |
| 10 | .claude/skills/cleanup-merged-worktrees/SKILL.md | 151d69f2952efc95526d903d4a7645d7826ec4e6 | 151d69f2952efc95526d903d4a7645d7826ec4e6 | yes | a8aa539d1e927bab564a080d8a53be79d31378d4 | yes |
| 11 | .claude/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd | yes | NEW | n/a |
| 12 | .codex/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd | yes | NEW | n/a |
| 13 | .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 | f343b7a7d172a27d53bf415446371b0309c9b3df | f343b7a7d172a27d53bf415446371b0309c9b3df | yes | NEW | n/a |

Mirror paths, in pair order: extensions/drm-copilot/resources/claude-customizations/<source> for `.claude/` sources, and extensions/drm-copilot/resources/codex-and-agents-customizations/<source> for `.codex/` and `.agents/` sources.

PAIRS_EQUAL=13/13
HELPER_RUNTIMES_EQUAL=true (the `.claude` and `.codex` helper hashes are both d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd)
