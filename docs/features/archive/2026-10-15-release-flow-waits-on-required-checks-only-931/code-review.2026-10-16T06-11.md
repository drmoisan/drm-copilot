# Code Review: Release flow waits on every check (#931)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Feature Folder Selection Rule:** the only active feature folder whose suffix matches the canonical issue number (931)
**Base Branch:** `main` (merge base `ba53ff5694a42e975d5d1db99b2b6ef505143e66`; `origin/main` at `5bc97774b8322e57abb94dfac3cd0a000a136c5b`)
**Head Branch:** `bug/release-flow-waits-on-required-checks-only-931` (local alias `issue-931-cycle2`) @ `85179c841f4efee523776c550defa30b0cf10f12`, PR #948
**Review Type:** Re-review at remediation cycle 2 exit (full branch diff)

---

## Executive Summary

The branch changes the guarded release flow so that `Wait-ForPullRequestChecks` polls every check on the pull request head (`gh pr checks <n> --json bucket`) instead of only required checks, and returns 0 only when at least one check is reported and every bucket is `pass` or `skipping`. Remediation cycle 2 addressed four related findings recorded in `remediation-inputs.2026-10-16T04-02.md`:

- F1: `Invoke-GitExe` and `Invoke-GhExe` now declare `[OutputType([pscustomobject])]`, and `.OUTPUTS` names the `ConvertTo-CommandResult` object.
- F2: Phase A retries a non-zero poll only when the output contains the gh text `no checks reported`; any other non-zero poll writes `Could not query the checks for PR #<n> (gh exit code <c>).` and returns 1 before any sleep.
- F3: `ConvertFrom-CheckPollOutput`, `Get-CheckSetVerdict`, and the new `Test-UnregisteredCheckPollOutput` moved to `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` (116 lines), dot-sourced through `$PSScriptRoot`. The script dropped from 499 to 435 lines.
- F4: the unreachable `$null -eq $check` alternative was removed from `Get-CheckSetVerdict`.

The reviewer re-derived each claim from the code and from CI run 38857583261 on the head (17 of 17 checks `pass`, confirmed with `gh pr checks 948` and `gh run view 38857583261`). `git diff 0eddcff3e HEAD` shows the two moved helpers are byte-identical to their cycle 1 form apart from the F4 line. The PR CI `poshqc-test-results` artifact, downloaded by the reviewer, reports `Invoke-FullReleaseFlow.ps1` at 131/138 lines (94.93%; the 7 missed lines are the unchanged process seams 86, 87, 103, 104, 123, 124, 146) and the helper file at 30/30 lines (100%).

**What changed (full branch):**
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: `--required` dropped (line 233); Phase A fail-fast guard (lines 237-241); Phase B driven by the verdict helper (lines 251-290); help text and output-type declarations updated.
- `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` (new): three pure helpers.
- Tests: `Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` (22 tests, renamed from the CheckClassification suite plus 4 new), `ChecksWait` (23 tests, 4 new in cycle 2), `Invoke-FullReleaseFlow.Tests.ps1` (OutputType test), and the Python text pin.

**Top 3 risks:**
1. Behavioral widening: release PRs now wait on non-required, path-filtered workflows. This is the intended #931 behavior.
2. F2 trade-off: a transient network error on a Phase A poll now ends the flow at once instead of being retried. This is the behavior the F2 finding requested.
3. Phase B tolerates failed re-polls as an empty set, so a persistent gh failure after Phase A surfaces as a completion timeout rather than a gh-failure message (Info finding below; fail-closed).

**PR readiness recommendation:** **Go**. No Blocker or Major finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | lines 280-289 | Phase B treats a non-zero re-poll as an empty set and consumes an attempt. A persistent gh failure after a successful Phase A therefore ends with `did not complete within the timeout` after up to 120 x 10 s, without naming the gh failure. | Optional: when the completion timeout is reached and the last poll failed, include its exit code in the stderr message. | Not a defect: the result is fail-closed (returns 1), the tolerance for transient errors during a long wait is deliberate, and the help text documents it ("a re-poll that fails or cannot be parsed consumes an attempt and counts as an empty set"). F2 targeted the first-poll case, where a gh failure indicates a configuration problem. | Script lines 214-290; tests `continues after a non-zero completion poll`, `times out when completion polls keep failing` (CI JUnit, ChecksWait 23/23). |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` | lines 14-18, 48-52 | `ConvertFrom-CheckPollOutput` and `Get-CheckSetVerdict` carry `.SYNOPSIS` only, while `Test-UnregisteredCheckPollOutput` also carries `.DESCRIPTION` and `.OUTPUTS`. | Optional: add `.OUTPUTS` to the two moved helpers at the next edit. | Help depth is uneven; PSScriptAnalyzer does not require these sections and the moved text is unchanged from the reviewed cycle 1 form. | File inspection. |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | line 233 | Removing `--required` makes non-required workflows gate release merges. A workflow that registers after the first non-empty all-pass read can be missed (pre-existing parity race with the S9 rule from #899). | No change. | Intended by #931. | Plan `## Notes`. |

No Blocker, Major, or Minor findings. All three Info items are non-blocking.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The pin `test_release_flow_waits_on_every_check_without_required_wording` reuses the module helpers and the `REQUIRED_FLAG` constant; it still reads `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, which retains the help text and the `--json bucket` arguments after the extraction.

#### Typing and API notes

- No new public Python API. Reviewer reruns at the head: `black --check` "1 file would be left unchanged.", `ruff check` "All checks passed!", pytest 35 passed.

#### Error handling and logging

- Not applicable; the change is assertion-only.

### PowerShell implementation audit

#### What changed well

- Extraction preserves behavior: `git diff 0eddcff3e HEAD -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` removes the two helpers, and the helper file reproduces them unchanged except the F4 line (`$property = $check.PSObject.Properties['bucket']`).
- F4 removal is safe. `-Checks` is a `Mandatory` `[object[]]` parameter without `[AllowNull()]`, so the binder rejects a `$null` element, and the only caller passes either `@()` or `ConvertFrom-CheckPollOutput` output, which rejects any non-`PSCustomObject` element (`reports failure for a null element`).
- F2 rule is grounded in observation: `evidence/baseline/cycle2-gh-observation.2026-10-16T05-12.md` records gh 2.87.3 exiting 1 with `no checks reported on the 'chore/gitignore' branch` for a PR with no checks, and exit 0 with a JSON array for a pending set. `Invoke-GhExe` merges stderr (`2>&1`), and `[string]` conversion of the resulting `ErrorRecord` yields the message text, so the substring test sees the gh text. With `--required` removed, the alternative text `no required checks reported` can no longer occur.
- F1: the declared type now matches the returned object, and a test compares both wrappers' `OutputType` with that of `ConvertTo-CommandResult`.
- The dot-source uses `Join-Path -Path $PSScriptRoot`, which resolves both when the script runs as an entry point and when a Pester suite dot-sources it.

#### API and safety notes

- The `Wait-ForPullRequestChecks` signature and defaults (24 x 5 s registration, 120 x 10 s completion) are unchanged.
- Bucket comparison remains case-sensitive (`-ccontains`, `-cnotin`, `-ceq`).

#### Error handling and logging

- Every non-success path writes one specific stderr line and returns 1. The only `catch` is typed (`System.ArgumentException`).

---

## Test Quality Audit

Evidence reviewed: CI run 38857583261 artifact `poshqc-test-results` (`pester-junit.xml`: 10417 tests, 0 errors, 0 failures; `powershell-coverage.xml`), job `quality-checks7 / Code Quality & Tests (3.13)` log, and reviewer reruns of the Python module.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1`: 22 tests, 22 passed in CI. It dot-sources only the helper file, so the helpers are tested without the script. New `Test-UnregisteredCheckPollOutput` tests cover the plain string, the `ErrorRecord` form produced by `2>&1`, an HTTP 401 text, and empty output.
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: 23 tests, 23 passed. The F2 test is data-driven over three failure texts (HTTP 401 exit 1, `gh auth login` exit 4, connection error exit 1) and asserts return 1, the stderr text, exactly one `Invoke-GhExe` call, and zero `Invoke-Sleep` calls. The retry test feeds the no-checks text as an `ErrorRecord` twice and asserts 2 sleeps and 3 polls before success. These assertions would fail if the guard were removed or inverted.
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`: 17 tests, 17 passed, including the OutputType test for both wrappers.
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`: 11 tests, 11 passed (unchanged suite).
- The JUnit contains no testsuite named `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`; the rename left no orphan.

### Quality assessment prompts

- **Determinism:** `gh`, sleep, and stderr are mocked; inputs are literals.
- **Isolation:** helper tests call one function each without mocks.
- **Speed:** all waits are mocked.
- **Diagnostics:** literal `Should -Be` and `-Match` expectations name the failing field.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: no tokens or credentials. |
| No unsafe subprocess or command construction | PASS | `gh` arguments are a literal array passed to the `Invoke-GhExe` splat. |
| Input validation at boundaries | PASS | gh output is treated as untrusted; blank, malformed, non-object, unknown, blank-bucket, and case-variant values are rejected. |
| Error handling remains explicit | PASS | Typed catch; explicit `return 1` with a message on each failure path, including the new gh-failure path. |
| Configuration / path handling is safe | PASS | The helper path is built with `Join-Path` from `$PSScriptRoot`; no user input reaches it. |
| Fail-closed success verdict | PASS | `return 0` is reachable only from `Verdict -ceq 'pass'`, which requires a non-empty set of `pass`/`skipping` buckets. |

---

## Research Log

- gh behavior for zero checks and for pending sets under `--json` was taken from the recorded live observation (`evidence/baseline/cycle2-gh-observation.2026-10-16T05-12.md`, gh 2.87.3) and the existing research note `research/2026-10-15-release-flow-all-checks-research.md`. The reviewer did not re-run gh against a check-less PR.
- CI claims were re-verified directly: `gh run view 38857583261 --json status,conclusion,headSha` returned `completed`, `success`, head `85179c841f4efee523776c550defa30b0cf10f12`; `gh pr checks 948` listed 17 checks, all `pass`.

---

## Verdict

F1 to F4 hold in the code and in the tests, and the extraction changed no behavior beyond the intended F4 removal. Both production PowerShell files are under the 500-line limit, the helper file is inside Pester coverage at 100%, and the script's line coverage (94.93%) does not regress from the 94.26% Phase 0 baseline. There are no Blocker, Major, or Minor findings; the three Info items are optional and non-blocking.
