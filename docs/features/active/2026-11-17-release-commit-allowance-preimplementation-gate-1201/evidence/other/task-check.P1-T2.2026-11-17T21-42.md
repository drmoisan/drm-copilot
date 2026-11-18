# Task check - P1-T2

Timestamp: 2026-11-17T21-42
Changed files:
- .claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1 (new), byte-identical copies at .codex/hooks and both bundle hook roots (one SHA256 across the four copies; prefix 84639ac0a4161a19); the file holds no artifacts-tree string literal (count 0).
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release.Tests.ps1 (new)
Selection rule: the mirrored test file of the new production file, the suite of the file it dot-sources (hook-release-allowance-context.Tests.ps1), and the discovery guard `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, as the task acceptance names.

Commands:
1. Command: sh SCRATCH/issue-1201-ps-static.sh .claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release.Tests.ps1
   EXIT_CODE: 1
   Output Summary: format drift 0; 1 PSScriptAnalyzer finding (PSReviewUnusedParameter, an unused scriptblock parameter in the directory-entry row of the test). The row now reads the probe's positional argument; the re-run exited 0 with 0 findings. Production file 149 lines.
2. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release.Tests.ps1 tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (first run)
   EXIT_CODE: 1
   Output Summary: 8 failures, all in the AC-3 seam rows of both surfaces: the ParameterFilter compared a forward-slash literal while Join-Path on Windows emits backslashes. The filters now normalize separators and compare the exact path; the static re-check exited 0.
3. Command: the same launcher selection (second run)
   EXIT_CODE: 0
   Output Summary: 970 tests, 970 passed, 0 failed, 0 skipped. Selection-only line coverage (not gate evidence): release sibling 32/32, context file 170/171.
