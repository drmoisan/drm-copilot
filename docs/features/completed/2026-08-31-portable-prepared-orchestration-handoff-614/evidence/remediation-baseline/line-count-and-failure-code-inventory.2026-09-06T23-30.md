# Line-Count and Failure-Code Baseline — Issue #614 Remediation

Timestamp: 2026-09-07T01-20
Cycle: 2026-09-06T23-30
Task: [P0-T3]
EXIT_CODE: 0

## 1. Line counts

Command: `Get-ChildItem -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts, tests/scripts/dev_tools/test_orchestration_handoff_adapters.py, tests/scripts/dev_tools/test_orchestration_handoff_contract.py | ForEach-Object { "$($_.Name) $((Get-Content -LiteralPath $_.FullName).Count)" }`

```
orchestration-handoff-materializer.ts 439
orchestration-handoff-materializer.test.ts 334
orchestration-handoff-materializer-test-support.ts 249
test_orchestration_handoff_adapters.py 451
test_orchestration_handoff_contract.py 100
```

Each of the five counts equals the value the plan states for it: 439, 334, 249, 451, and 100.

## 2. Failure-code inventory of the materializer

Command: `Select-String -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts -Pattern 'HANDOFF_[A-Z_]+' -AllMatches -CaseSensitive | ForEach-Object { $_.Matches.Value } | Group-Object | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }`

```
HANDOFF_DIRTY_WORKTREE 1
HANDOFF_HISTORY_INVALID 1
HANDOFF_PLAN_PATH_INVALID 3
HANDOFF_PROVIDER_ROUTING_UNAVAILABLE 1
HANDOFF_SOURCE_HASH_MISMATCH 3
HANDOFF_UNSUPPORTED_VERSION 1
HANDOFF_VALIDATOR_UNAVAILABLE 10
HANDOFF_WORKSPACE_MISMATCH 1
```

This sorted name-and-count list is the reference against which P3-T4 asserts that the
production correction changes no failure code.

Output Summary: Both commands exited 0. The five recorded line counts are 439, 334, 249,
451, and 100, matching the plan. The failure-code inventory holds eight distinct
`HANDOFF_*` codes with a total of 21 occurrences, of which `HANDOFF_VALIDATOR_UNAVAILABLE`
accounts for 10.
