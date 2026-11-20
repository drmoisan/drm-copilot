# Epic Manifest Check [P3-T5]

Timestamp: 2026-11-20T15-11
Command: sed rewrite of the ten `feature_folder` values in `.dev/epics/shared-agent-harness-layer/epic.md` to their `RENAME_MAP` basenames; sh SCRATCH/issue-1016-tc-p3t5.sh (YAML front-matter parse with a directory test per value; launcher pytest -n auto over test_epic_kickoff_contract.py, test_epic_planner_readiness.py, test_epic_cross_dependency_validation.py)
EXIT_CODE: 0
Output Summary: Ten `feature_folder` values changed; each names an existing directory under `.dev/active`; the front matter parses (10 features); test_epic_kickoff_contract.py and the two related epic suites pass (64 passed, 0 failed).

`RENAME_MAP` source: the `renames` entries of `FRESH_DRY_RUN` (`dev-docs-migration-dry-run.2026-11-20T13-31.json`).

| issue_num | Old value | New value | Directory |
| --- | --- | --- | --- |
| 1025 | `2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025` | `1025-harness-survey-gold-standard-contracts-parity-matrix` | `.dev/active` |
| 1035 (child 2) | `2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035` | `1035-dev-docs-root-resolver-and-feature-folder-name-parser` | `.dev/active` |
| 1028 | `2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028` | `1028-shared-source-generators-skills-rules-mcp-agents` | `.dev/active` |
| 1029 | `2026-10-30-push-down-consolidation-and-ecosystem-packs-1029` | `1029-push-down-consolidation-and-ecosystem-packs` | `.dev/active` |
| 1030 | `2026-10-30-hook-parity-across-claude-codex-copilot-1030` | `1030-hook-parity-across-claude-codex-copilot` | `.dev/active` |
| 1032 | `2026-10-30-retire-github-skills-and-thin-copilot-layer-1032` | `1032-retire-github-skills-and-thin-copilot-layer` | `.dev/active` |
| 1049 | `2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049` | `1049-pushed-down-vendored-code-coverage-carve-out` | `.dev/active` |
| 1050 | `2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050` | `1050-push-down-ci-workflows-per-ecosystem-pack` | `.dev/active` |
| 1051 | `2026-10-31-push-down-integration-mcp-tools-and-skill-1051` | `1051-push-down-integration-mcp-tools-and-skill` | `.dev/active` |
| 1016 | `2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016` | `1016-move-development-docs-to-dev-root-and-reserve-docs-for-production` | `.dev/active` |

No other line of the manifest changed (git diff: 10 insertions, 10 deletions).
