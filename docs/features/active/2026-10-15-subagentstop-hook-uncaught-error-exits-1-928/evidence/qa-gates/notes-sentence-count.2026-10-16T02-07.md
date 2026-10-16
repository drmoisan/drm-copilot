# .NOTES Sentence Count (issue #928)

Timestamp: 2026-10-16T02-07
Command: grep -c -F "validation blocks with exit 2 and a reason" <nine validator files>
EXIT_CODE: 0

Output Summary: Count 1 for each of the eight AC1 validators and 0 for validate-feature-review-coverage.ps1. PASS. Each sentence sits on the line immediately after the previous last nonblank line of its `.NOTES` section, indented four spaces (line numbers from `grep -n`).

| File | Count | Line |
| --- | --- | --- |
| .claude/hooks/validate-discovery-artifact-gate.ps1 | 1 | 40 |
| .claude/hooks/validate-executor-output.ps1 | 1 | 31 |
| .claude/hooks/validate-feature-review-coverage.ps1 | 0 | n/a |
| .claude/hooks/validate-orchestrator-output.ps1 | 1 | 41 |
| .claude/hooks/validate-planner-output.ps1 | 1 | 33 |
| .claude/hooks/validate-pr-author-output.ps1 | 1 | 30 |
| .claude/hooks/validate-prd-feature-output.ps1 | 1 | 12 |
| .claude/hooks/validate-required-artifact-output.ps1 | 1 | 28 |
| .claude/hooks/validate-task-researcher-output.ps1 | 1 | 23 |
