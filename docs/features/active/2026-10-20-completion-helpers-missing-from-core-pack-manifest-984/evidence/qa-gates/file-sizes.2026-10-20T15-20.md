# QA Gate: Physical Line Counts (Issue #984)

Timestamp: 2026-10-20T15-20
Command: wc -l <each path below>
EXIT_CODE: 0
Output Summary: loop pass 3. every count is at most 500 (largest 496); each of the six converted repository hooks is exactly one line longer than its [P0-T4] count; the Codex completion hook, the FailClosed suite, and the helper file stay within the limit.

| Path | Physical lines | [P0-T4] count | Delta |
|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 489 | 488 | +1 |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 240 | 239 | +1 |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 496 | 495 | +1 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 493 | 492 | +1 |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 351 | 350 | +1 |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 348 | 347 | +1 |
| `.codex/hooks/enforce-completion-consistency.ps1` | 491 | 491 | 0 |
| `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` | 174 | 160 | +14 |
| `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | 461 | 461 | 0 |
| bundle copies of the six converted hooks | equal to their repository copies (489, 240, 496, 493, 351, 348) | n/a | n/a |
| `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1` | 223 | new | n/a |
| `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1` | 179 | new | n/a |
| `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1` | 181 | new | n/a |
| `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1` | 145 | new | n/a |
| `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` | 458 | new | n/a |
| `tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py` | 211 | new | n/a |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | 347 | new | n/a |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | 165 | n/a | n/a |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | 322 | n/a | n/a |
