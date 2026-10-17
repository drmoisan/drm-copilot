# Remediation Inputs (Issue #931), related follow-up cycle

**Entry timestamp:** 2026-10-16T02-11
**Feature folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Head at entry:** `bug/release-flow-waits-on-required-checks-only-931` @ `f73457642c3e47a29f64c6e08b63a529a1570716`
**Origin:** operator rule for this run: related non-blocking findings are fixed inside the item through a remediation cycle before DONE. The source finding is the Minor code-review finding recorded under "Related findings that do not block the merge" in `remediation-inputs.2026-10-16T02-01.md` (reviewer verdict `AWAITING_CI`, 0 autonomous findings). That reviewer verdict opens no cycle; this cycle is opened by the orchestrator for the related Minor finding only.
**Work mode:** `minor-audit`; AC source is `issue.md` `## Acceptance Criteria`.

## Findings

### F1 - Missing tests for two defensive branches of `Get-CheckSetVerdict`

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the branches exist in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (`Get-CheckSetVerdict`, the `$null -eq $check` guard and the `[string]::IsNullOrWhiteSpace([string]$property.Value)` guard, script lines 213 and 214) and no test in `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` drives them; adding tests resolves the finding with no production change.

**Expected state.** `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` (first `Describe`, `Get-CheckSetVerdict`) gains exactly two tests, each calling the real helper with no mocks:

1. `reports unknown for a null check element`: a check set whose only element is `$null`; asserts `Verdict` equal to `unknown` and `Detail` equal to `(missing)`.
2. `reports unknown for a blank bucket value`: a check set whose only element has a `bucket` property holding a whitespace-only string; asserts `Verdict` equal to `unknown` and `Detail` equal to `(missing)`.

Implementation hazard for the planner: `-Checks` is `[Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]]`. Confirm how PowerShell binds an array containing a `$null` element before fixing the exact call form (for example `@($null)` passed through `-Checks`), and choose a form that reaches line 213. If no call form reaches the `$null` branch through the parameter binder, record that fact in the plan and cover only the blank-bucket branch plus an explicit statement of the unreachable branch; do not edit production code to make it reachable.

## Constraints

- Edit only `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`. The file stays at or under 500 lines (currently below that), uses no temporary file, and keeps the existing Arrange, Act, Assert layout.
- Do not edit `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; it is at 499 of 500 lines.
- Do not edit `issue.md` acceptance criteria; AC6 stays unchecked until the PR CI run.
- Evidence goes under `<FEATURE>/evidence/` using the canonical kinds; PowerShell verification is Option A (the PoshQC MCP tools plus CI).

## Out of scope for this cycle (recorded decisions)

- CR Minor "script at 499 of 500 lines": the file is within the limit, nothing in this cycle edits it, and extracting the helpers would be a production refactor with no defect behind it. Not actioned.
- CR Info on `[OutputType([hashtable])]` and Phase A treating an auth or network failure as "not yet registered": unrelated to the files and behavior this item changes. Not actioned; reported as unrelated follow-ups.
- Blocking findings R1 (AC6 CI record) and R2 (Python coverage report) from the reviewer's inputs file are `awaiting_ci` and clear only on the PR CI run at S9.
