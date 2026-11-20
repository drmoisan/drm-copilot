# Task check - P2-T4

Timestamp: 2026-11-18T00-13
Changed files:
- tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1 (new, 228 lines): AC-22 byte identity and size of both new files across the four hook roots; AC-21 guarded dot-source, single leg call after the last existing leg, `$release.DenySuffix` as the last deny term, and bundle-equals-source for the four gate copies; AC-24 absence from every `pack-manifests/*.json` under extensions/drm-copilot/resources and from the repository `.claude/` and both bundle `.claude/` roots; AC-25 the Python tuple; AC-27 and AC-28 tokens per copy and copy identity; AC-32 no `python` or `poetry` text; the ReleaseAllowance prefix of every script-scope assignment (AST over AssignmentStatementAst targets plus Set-Variable and New-Variable with -Scope Script), with companion rows (`$script:Other = 1`, a typed assignment, and a Set-Variable call each report one violation; a prefixed assignment reports none). Hook paths are built from a variable leaf, as hook-docs-estate-context.Parity.Tests.ps1 does.
Selection rule: the new suite, the discovery guard, and hook-dependency-guard-completeness.Tests.ps1, as the task acceptance names.

Commands:
1. Command: sh SCRATCH/issue-1201-ps-static.sh tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1
   EXIT_CODE: 0
   Output Summary: format drift 0, PSScriptAnalyzer findings 0 (before and after the fix below).
2. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
   EXIT_CODE: 1
   Output Summary: 7 failures, all in the script-scope rows of the new suite: VariablePath.UnqualifiedPath is not a public property, so every collected name was empty. Every discovery-guard row and every dependency-guard row passed. The helper now reads VariablePath.UserPath without the `script:` prefix.
3. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1 tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 (one earlier attempt exited 75 on a busy lock, a queue timeout)
   EXIT_CODE: 0
   Output Summary: 830 tests, 830 passed, 0 failed; every parity row and both companion directions pass.
