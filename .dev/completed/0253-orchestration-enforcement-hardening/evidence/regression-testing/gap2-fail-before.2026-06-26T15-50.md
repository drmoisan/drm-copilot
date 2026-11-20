# Gap 2 Fail-Before — Sentinel Rejection (Issue #253, P4-T1)

- Timestamp: 2026-06-26T15-50
- Command: `Invoke-Pester` over `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` filtered to `*Sentinel*` (Context "Sentinel issue-num and feature-folder rejection (Gap 2)")
- EXIT_CODE: 0 (Pester run completed; the two target tests FAILED as expected for a fail-before)
- Output Summary: 2 failed, 0 passed for the two new sentinel `It` blocks. Pester output:
  - `[-] blocks a completion-asserting checkpoint whose issue-num is the sentinel "n/a"`
  - `[-] blocks a completion-asserting checkpoint whose feature-folder is the sentinel "n/a"`
  - `Tests Passed: 0, Failed: 2`

## Interpretation

Before the Gap-2 change, `Get-MissingCompletionEvidence` uses `if (-not $issueNum)` / `if (-not $featureFolder)` (lines 161-171), which only treat empty/whitespace as missing. A sentinel value such as `n/a` is a non-empty truthy string, so it passes the presence check and a completion-asserting checkpoint with `issue-num = "n/a"` (or `feature-folder = "n/a"`) plus full `ci_gate` evidence is ALLOWED. The two new `It` blocks assert that such checkpoints are BLOCKED; they fail before the change, confirming the gap.

## Pass-After

P4-T2 introduces `Test-IsValidIssueNum` and `Test-IsValidFeatureFolder` (in `.claude/hooks/enforce-completion-helpers.ps1`) and replaces the truthiness checks with calls to these helpers, after which the two `It` blocks pass.
