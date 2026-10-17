# Final Scope Check AC-14 and #936 Exclusion (issue #953, P6-T15)

Timestamp: 2026-10-16T08-56
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $names = @(git diff --name-only origin/main...HEAD); $porc = @(git status --porcelain | ForEach-Object { $_.Substring(3) }); ...count paths starting with ".claude/rules/" or ".github/instructions/" and paths equal to the two #936-owned test files in each listing...' (script SCRATCH/issue-953-p6-t15.sh, run with sh)
EXIT_CODE: 0
Output Summary: Both git listings exited 0 (48 diff entries, 14 porcelain entries). Neither listing contains a path starting with .claude/rules/ or .github/instructions/, and neither contains tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 or tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1. All eight counts are 0.

DIFF_CLAUDE_RULES: 0
DIFF_GITHUB_INSTRUCTIONS: 0
DIFF_936_FAILCLOSED: 0
DIFF_936_DECISION: 0
STATUS_CLAUDE_RULES: 0
STATUS_GITHUB_INSTRUCTIONS: 0
STATUS_936_FAILCLOSED: 0
STATUS_936_DECISION: 0
