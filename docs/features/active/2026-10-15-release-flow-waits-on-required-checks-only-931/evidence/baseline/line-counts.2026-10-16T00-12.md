# Line-Count Baseline (Issue #931)

Timestamp: 2026-10-16T00-12
Command: wc -l scripts/dev-tools/Invoke-FullReleaseFlow.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
EXIT_CODE: 0
Output Summary: 401, 426, 141, 266 lines; all four match the plan-time reads. No deviation.

Output (paths shown relative to `<worktree>`):

```
  401 scripts/dev-tools/Invoke-FullReleaseFlow.ps1
  426 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
  141 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
  266 tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
 1234 total
```

| File | Plan-time | Observed | Match |
|---|---|---|---|
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 | 401 | 401 | yes |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | 426 | 426 | yes |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | 141 | 141 | yes |
| tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py | 266 | 266 | yes |
