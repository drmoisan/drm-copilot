# Baseline Token Counts (issue #928)

Timestamp: 2026-10-16T01-33
Command: grep -c -F "validator error:" <nine validator files>
EXIT_CODE: 0

Second command: grep -c -F "validation blocks with exit 2 and a reason" <nine validator files> (EXIT_CODE 1: no file matched)

Output Summary: The eight AC1 validators have 0 for both tokens; validate-feature-review-coverage.ps1 has 2 (lines 186 and 203) and 0.

| File | "validator error:" | "validation blocks with exit 2 and a reason" |
| --- | --- | --- |
| .claude/hooks/validate-discovery-artifact-gate.ps1 | 0 | 0 |
| .claude/hooks/validate-executor-output.ps1 | 0 | 0 |
| .claude/hooks/validate-feature-review-coverage.ps1 | 2 | 0 |
| .claude/hooks/validate-orchestrator-output.ps1 | 0 | 0 |
| .claude/hooks/validate-planner-output.ps1 | 0 | 0 |
| .claude/hooks/validate-pr-author-output.ps1 | 0 | 0 |
| .claude/hooks/validate-prd-feature-output.ps1 | 0 | 0 |
| .claude/hooks/validate-required-artifact-output.ps1 | 0 | 0 |
| .claude/hooks/validate-task-researcher-output.ps1 | 0 | 0 |
