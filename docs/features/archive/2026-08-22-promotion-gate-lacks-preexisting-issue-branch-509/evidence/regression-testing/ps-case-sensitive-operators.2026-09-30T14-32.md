# PowerShell Case-Sensitive Operator Check — P5-T10

Timestamp: 2026-09-30T14-32
Task: P5-T10
Working directory: worktree root

## Step 1 — positive control

Command: grep -c -E -e "-c(eq|ne|contains|notcontains|match)" .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
EXIT_CODE: 0
Output Summary: `11` (at least 1; the case-sensitive operators are present and the path resolves).

## Step 2 — rejected operators

Command: grep -n -i -E -e "[[:space:]]-(eq|ne|ieq|ine|contains|notcontains|icontains|match|notmatch|imatch|like|notlike|in|notin)[[:space:]]" .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
EXIT_CODE: 1
Output Summary: no output; no rejected operator appears anywhere in the module, including comments and comment-based help.

Behavioral proof: the `rejects the case-variant tool name Potential_To_Issue` block in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` and the `case-variant-tool-name` corpus case, both run in P5-T11.

Result: PASS
