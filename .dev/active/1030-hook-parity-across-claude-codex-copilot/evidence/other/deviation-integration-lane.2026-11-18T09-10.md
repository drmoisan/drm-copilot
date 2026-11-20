# Non-Blocking Deviation — Integration Lane ([P1-T3])

Timestamp: 2026-11-18T09-10
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath ... tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 ...`
EXIT_CODE: 2
Output Summary: the launcher refused the selection with `TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence (test-execution policy).` The [P1-T3] text names `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` among the suites that must pass; its file name carries the integration-lane suffix, so local gates exclude it and CI provides its evidence (`poshqc / PowerShell hook suites (Linux)` and `poshqc / PowerShell QC`). The remaining [P1-T3] suites ran and passed locally. Decision (autonomous mode, recommended option): exclude the file from local task checks and phase gates and rely on CI for it, because the launcher policy forbids a local integration-lane run and that rule is not bypassed.
