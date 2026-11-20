# Review Pester Gate at the Reviewed Head (feature-review)

Timestamp: 2026-11-14T21-51
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launched from the item worktree root by a scratch launcher; Invoke-PoshQCParallelTest with coverage, 8 shard workers, integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary:
- Reason: the validate-feature-review-coverage Stop hook reported the executor's coverage report (written 2026-11-14T21:17:06Z) as older than the newest commit touching PowerShell files, the origin/main merge aae55c065 (2026-11-14T21:24:48Z). This run refreshes the report at the reviewed head.
- Head: aae55c0652c1110385f4220ce2c7672f80320954; working tree clean apart from the untracked review artifacts.
- Run window 2026-11-14T21:39:46Z to 2026-11-14T21:51:34Z; workers=8; wall-clock=689.56s; exit code=0.
- Counts (merged artifacts/pester/pester-junit.xml): tests=26852, failures=0, errors=0.
- Coverage (artifacts/pester/powershell-coverage.xml, written 2026-11-14T21:51:34Z): repo-wide 44274/46114 = 96.01% lines; .claude/hooks/invoke-pretooluse-dispatch.ps1 42/42 = 100.00%; .codex/hooks/invoke-pretooluse-dispatch.ps1 40/40 = 100.00%.
- The test and instrumented-line counts are higher than the executor's final gate (26585 tests, 45535 lines) because the head merge of origin/main added suites and production files; the branch's own figures are unchanged.
