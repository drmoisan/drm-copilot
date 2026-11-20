# Remediation Inputs — Issue #1066, Cycle 1

- Timestamp: 2026-11-04T01-03
- Source: execution-time finding (scope-change rule); the executor stopped BLOCKED at plan task P2-T4 of `plan.2026-11-03T17-43.md`.
- Branch: `bug/test-path-leak-run-actionlint` (head a45d7c0de at cycle entry)
- AC source: `spec.md` `## Acceptance Criteria` (AC3 and the tasks still unchecked).
- Remediation-Mode: proportionate
- Review-Verdict: REMEDIATION_REQUIRED

The fix stays within the files already in the branch diff (`tests/scripts/dev-tools/run-actionlint.Tests.ps1`, `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1`) and the feature folder. No spec acceptance criterion, public interface, or production file changes.

## Finding F1 — run-actionlint.Tests.ps1 still leaves global state changed after the DD1 fix

- Severity: Blocking
- Remediability: autonomous
- Evidence: `evidence/regression-testing/global-state-pass-after.2026-11-04T01-00.md`. After the DD1 fix, `SCRATCH/issue-1066-global-state.ps1` over TARGET (and over GUARD, which runs TARGET nested) exits 1. The difference is three added global functions:
  - `Import-ScriptFunction`: defined with `function global:` in `tests/scripts/powershell/Support/TestHelpers.ps1`, which TARGET dot-sources.
  - `Compress-Archive` and `Expand-Archive`: from the `Microsoft.PowerShell.Archive` module, auto-loaded when TARGET mocks `Expand-Archive`.
- Violated: spec AC3 ("no other environment variable, location, alias, or global state remains altered after the file runs") and plan task P2-T4. The coordinator's objective also requires fixing every unrestored process-global mutation in this test file.
- Required change: TARGET restores this state at Describe level, in `BeforeAll`/`AfterAll` or an equivalent.
  - Remove the global `Import-ScriptFunction` only when it did not exist before the file ran.
  - Remove `Microsoft.PowerShell.Archive` only when it was not loaded before the file ran.
  - The restore must call none of the commands mocked inside Contexts, per the DD1 preflight constraint.
  - Show that no other suite that dot-sources `TestHelpers.ps1` or uses the Archive module depends on the state TARGET left behind. Find such suites by searching the test tree. A suite that does depend on it is a victim, and the repository rule requires fixing both sides; name it.

## Finding F2 — The guard's LASTEXITCODE testcase cannot fail

- Severity: Blocking
- Remediability: autonomous
- Evidence: the executor handback. On this host the nested Pester harness leaves `$global:LASTEXITCODE` at 0 for both the empty control container and pre-fix TARGET. So `run-actionlint.Tests.ps1 leaves global LASTEXITCODE as the nested harness leaves it` passes both before and after the fix, and proves nothing about the DD1 LASTEXITCODE restore.
- Required change: either make the LASTEXITCODE assertion able to fail against the unrestored code and show that it fails before the restore (fail-before evidence), or remove the testcase and verify the DD1 LASTEXITCODE restore some other way that can fail. Record the choice. Do not keep a testcase that cannot fail.

## Carried-forward plan work (not findings)

These tasks of the approved plan were not executed and remain required: P2-T4 (re-run after F1), Phase 3 (P3-T1 to P3-T6), and Phase 4 (P4-T1 to P4-T10), with the same acceptance conditions. Exception: totals and testcase counts change by the number of GUARD testcases if F2 changes that number. The remediation plan reuses the existing scratch tooling and baselines (Phase 0 sets A, B, VS, PL_min, PC, Base_S, Base_P).
