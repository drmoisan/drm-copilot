# Matrix Bootstrap (P3-T1)

Timestamp: 2026-11-16T02-29
Command: pwsh -NoProfile -File SCRATCH/issue-1025-matrix-bootstrap.ps1 (imports the three scripts/harness modules, Get-HarnessInventory, New-HarnessParityMatrixSkeleton, plan `## Matrix Bootstrap Rules` first match wins, consumers rule, writes config/harness-parity-matrix.json, then Get-HarnessParityMatrixViolation against the live inventory)
EXIT_CODE: 0
Output Summary: 655 entries written; Unmatched 0; Violations 0; Approved 0; codex:skill shared 65 equals skill-survey.md rows with Claude and Codex both yes (65).

Per kind: agent 213, handoff 20, hook-registration 95, instructions 3, mcp-server 2, path-scoped-rule 38, permission 4, prompt 33, setting 5, skill 210, skill-frontmatter-field 10, skill-metadata-file 2, subagent-frontmatter-field 20
Per disposition: dropped 43, generated 318, native 228, shared 66
pending-source count: 173
Ids carrying ~: 14
Duplicate-group base ids:
- `claude:hook-registration:SubagentStop/atomic-planner/validate-planner-output`
- `claude:hook-registration:SubagentStop/epic-orchestrator/validate-orchestrator-output`
- `claude:hook-registration:SubagentStop/feature-review/validate-feature-review-coverage`
- `claude:hook-registration:SubagentStop/orchestrator/validate-orchestrator-output`
- `claude:hook-registration:SubagentStop/parallel-orchestrator/validate-orchestrator-output`
- `claude:hook-registration:SubagentStop/pr-author/validate-pr-author-output`
- `claude:hook-registration:SubagentStop/prd-feature/validate-prd-feature-output`
Entries whose source_path is a dispatch registry: 57
Unmatched: 0
Violations: 0
Approved: 0
codex:skill shared: 65
skill-survey.md rows with Claude and Codex both yes: 65
