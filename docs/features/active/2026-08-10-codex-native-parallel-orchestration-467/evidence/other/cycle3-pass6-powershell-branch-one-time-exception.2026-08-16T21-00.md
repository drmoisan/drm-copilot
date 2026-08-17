# Issue #467 PowerShell Branch-Coverage One-Time Exception Receipt

Timestamp: 2026-08-16T21-00

Command: `Get-Content docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/runbooks/powershell-branch-coverage-one-time-exception.runbook.md | Select-String '^## (Cue|Prerequisites|Step-by-step Instructions|Verification|Source and Citation)$'`

EXIT_CODE: 0

## Authorization

- Authorization date: 2026-08-16
- Exact user instruction: `Please enable a one-time exception for the branch requirement and continue`
- Response: `exception`
- Canonical issue: `467`
- Delivery branch: `feature/codex-native-parallel-orchestration-467`
- Scope: one-time exception for the PowerShell branch-coverage requirement only, exclusively for issue #467 and this delivery.

## Preserved Raw Measurement

- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`
- `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE`
- Source-attributable covered outcomes: `0`
- Source-attributable missed outcomes: `0`
- Source-attributable denominator: `0`
- Measured 75% branch threshold result: `NOT ESTABLISHED`
- Synthetic branch percentage calculated: `NO`

## Authorized Compliance Disposition

`COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED`

The exception changes only the compliance disposition for the unavailable raw PowerShell branch measurement. It does not constitute a measured branch PASS, permanent policy change, threshold change, reusable waiver, synthetic metric, or exception for any other gate.

## Retained Gates

- PowerShell tests: 2,456 total, 2,447 passed, 9 disabled, zero failures/errors.
- PowerShell line coverage: 4,040/4,260 = 94.835681%.
- PowerShell formatting, analysis, and owner coverage.
- All non-PowerShell language gates and required type checks.
- Acceptance criteria unrelated to the raw PowerShell branch measurement.
- Full feature-vs-base review, hosted CI, and checkpoint validation.
- Known historical MCP `commit-steward` checkpoint-validator incompatibility remains an independent blocker and is not waived.

## Expiry and Non-Reuse

The exception expires when issue #467's current delivery is merged, closed, abandoned, replaced, or moved to another issue or branch. It must not be copied or reused for another issue, feature, pull request, coverage type, threshold, or delivery. Withdrawal or scope drift restores `POWERSHELL_BRANCH_POLICY_UNRESOLVED` as a blocking disposition while preserving the authorization history and raw evidence.

## Runbook

- Path: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/runbooks/powershell-branch-coverage-one-time-exception.runbook.md`
- SHA-256: `1C0761047A7EB4FF8C084A6762DC832004FBD1AB2469B84D0E8158DF9E5B2C7F`
- Required section order verified: `Cue`, `Prerequisites`, `Step-by-step Instructions`, `Verification`, `Source and Citation`.
- Current external sources and capture date verified: 2026-08-16.

## Sources

- https://github.com/drmoisan/drm-copilot/issues/467 — captured 2026-08-16.
- https://pester.dev/docs/usage/code-coverage — captured 2026-08-16.
