# Code Review: Release flow waits on every check (#931)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Feature Folder Selection Rule:** the only active feature folder whose suffix matches the branch issue number (931)
**Base Branch:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/release-flow-waits-on-required-checks-only-931` @ `a0ddc4d570edd2421ca079e1e8579695444c4e3a`
**Review Type:** Re-review at remediation cycle 1 exit (full branch diff)

---

## Executive Summary

The branch changes the guarded release flow so that `Wait-ForPullRequestChecks` polls every check on the pull request head rather than only branch-protection-required checks, and makes success a positive assertion. The full diff touches one production PowerShell script, three Pester suites (one new), and one Python contract test. This re-review covered the full diff against `main`, the refreshed PR-context summary and appendix (generated 2026-10-16 03:11 UTC for head `a0ddc4d5`), the plan, the cycle 1 remediation plan and its 24 `cycle1-` evidence files, the local Pester JUnit and JaCoCo reports written after the cycle 1 test commit, and reviewer reruns of the Python gates.

Cycle 1 added one test (`reports unknown for a blank bucket value`) and changed no production code. It also recorded that the `$null` element guard in `Get-CheckSetVerdict` cannot be reached through the parameter binder. The reviewer checked that claim against PowerShell binding rules and the caller: a `Mandatory` `[object[]]` parameter without `[AllowNull()]` rejects any collection with a `$null` element, and the only caller passes output that `ConvertFrom-CheckPollOutput` has already filtered to `PSCustomObject` elements. The prior Minor test-gap finding is therefore resolved.

**What changed (full branch):**
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` lines 162-194 add `ConvertFrom-CheckPollOutput` (non-throwing parse, typed catch, rejects non-object elements).
- Lines 196-235 add `Get-CheckSetVerdict` (precedence empty, fail, unknown, pending, pass; case-sensitive comparison).
- Line 301 drops `--required`. Lines 315-355 drive Phase B from the verdict.
- Tests: 18 direct helper tests (new file), 13 new loop tests, string updates in the existing suites, and a Python text pin.

**Top 3 risks:**
1. Results of record are pending: per-test outcomes and per-file coverage on the PR head come from PR CI, which has not run because no PR exists yet.
2. Behavioral widening: release PRs now also wait on path-filtered, non-required workflows. This is the intended #931 behavior and will be visible to operators.
3. The production script is at 499 of 500 permitted lines, so the next functional edit must first extract code.

**PR readiness recommendation:** **Conditional Go**. The branch is ready to open as a PR. Merge depends on PR CI success and on the AC6 S9 coverage comparison.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (awaiting_ci) | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | AC6 CI clause | The PoshQC result of record and the per-file coverage no-regression comparison for the PR head do not exist yet; no PR or branch CI run exists. | Open the PR. When CI concludes `success`, run S9 steps 1-6 from `ac-verification.2026-10-16T01-51.md` with 18 CheckClassification tests expected (per `cycle1-verification.2026-10-16T03-08.md`), 19 ChecksWait, and a per-file percentage of at least 94.26%. Then check off AC6. | AC6 names CI results as its verification basis. | Reviewer at 03:14 UTC: `gh pr list --head ... --state all` returned `[]`; `gh run list --branch ...` returned no runs. Local supplementary figure: 95.63% (153/160), 655 tests, 0 failures. |
| Major (awaiting_ci) | `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | coverage report | No Python post-change coverage report exists on the branch for a language with a changed file; `artifacts/python/lcov.info` is absent. | Record the PR CI `Enforce Python coverage thresholds` step result and the pytest `TOTAL` line from `quality-checks7 / Code Quality & Tests (3.13)`. | The reviewer coverage rule requires a post-change artifact for every language with changed files. The change is test-only, so the measured value is expected to equal the 93.72% baseline. | `_quality-checks.yml` lines 79-92; main run 38730332356 job 116406243603. |
| Minor | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | whole file (499 lines) | The file is 1 line under the 500-line limit. | Before the next functional edit, extract `ConvertFrom-CheckPollOutput` and `Get-CheckSetVerdict` into a dot-sourced helper file with mirrored tests. | Leaves no room for maintenance edits without a size-limit breach. Within the limit today, so not blocking. | Reviewer `wc -l` = 499. |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | line 213 | The `$null -eq $check` alternative is unreachable defensive code: the binder rejects `$null` elements in `-Checks`, and the caller filters them earlier. Prior Minor finding (null element and blank bucket tests) is resolved: the blank-bucket test was added and passes; the null alternative cannot be driven. | No change in this item. At the planned helper extraction, either remove the guard or add `[AllowNull()]` to `-Checks` and a test, so the code and the contract agree. | Dead branches mislead readers about accepted inputs. Changing it now would edit a 499-line file for no behavioral gain. | `evidence/baseline/cycle1-binder-probe.2026-10-16T02-49.md` (6 forms rejected on PowerShell 7.6.6); script lines 187-191; JUnit `reports unknown for a blank bucket value` Passed. |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | line 301 | Removing `--required` makes non-required, path-filtered workflows gating for release merges. A workflow that registers after the first non-empty all-pass read can be missed (accepted parity race with S9 #899). | No change in this item. Monitor the first release run. | Intended by #931; the race is pre-existing. | Plan `## Notes`. |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | lines 68-100, 303-313 | Pre-existing and unrelated: `Invoke-GitExe`/`Invoke-GhExe` declare `[OutputType([hashtable])]` but return `[pscustomobject]`, and Phase A treats an auth or network failure as "not yet registered". | File separately. | Outside #931 scope. | Plan `## Notes` (a) and (b); `remediation-inputs.2026-10-16T02-11.md` out-of-scope list. |

No Blocker findings. The two Major findings are classified `awaiting_ci` and need no branch change.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The pin reuses the module's existing helpers and the existing `REQUIRED_FLAG` constant, so whitespace reflow in the script cannot break it.
- The fail-before/pass-after pair is genuine (`evidence/regression-testing/release-flow-pin-fail-before.2026-10-16T01-29.md`, `release-flow-pin-pass-after.2026-10-16T01-42.md`).

#### Typing and API notes

- No new public Python API surface. The test is annotated `-> None`; Pyright reports 0 errors (reviewer run).

#### Error handling and logging

- Not applicable; the change is assertion-only.

### PowerShell implementation audit

#### What changed well

- Success requires at least one check with every bucket `pass` or `skipping`. Empty sets, unknown, absent, or blank buckets, parse failures, and failed re-polls never produce 0.
- Bucket comparison is case-sensitive, and a test pins this.
- Both former `ConvertFrom-Json` call sites route through one non-throwing parser.
- Cycle 1 respected its constraints: only the CheckClassification test file changed (+9 lines, now 160), and the production script is byte-identical to `f73457642` (`git diff f73457642..HEAD -- scripts` is empty).

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType([pscustomobject])]`, `Mandatory` parameters with `AllowEmptyCollection`/`AllowNull`/`AllowEmptyString` where the contract allows them.
- Property access through `PSObject.Properties['bucket']` is strict-mode safe.
- The `Wait-ForPullRequestChecks` signature, defaults, and timeout messages are unchanged.

#### Error handling and logging

- Each non-success path writes one specific stderr line. No broad catch is used.

---

## Test Quality Audit

Evidence reviewed: reviewer reruns of Black, Ruff, Pyright, and pytest on the changed Python module (35 passed); reviewer parse of `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, both written 2026-10-16 03:06 UTC after commit `92ff4d632`; the main-branch CI `poshqc-test-results` artifact (run 38730332356) for the baseline. CI-of-record results for the PR head are pending.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`: 18 direct, mock-free tests (Get-CheckSetVerdict 11, ConvertFrom-CheckPollOutput 7). The new test `reports unknown for a blank bucket value` passes a whitespace-only `bucket` and asserts `Verdict` `unknown` and `Detail` `(missing)`. It follows the file's Arrange/Act/Assert layout.
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: 19 tests, 19 passed locally.
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and `AdditionalFailurePaths`: 26 guarded-flow tests, 26 passed locally.
- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`: text pin, 35 module tests passed.
- `evidence/baseline/cycle1-binder-probe.2026-10-16T02-49.md`: the probe binds a stand-in function with the same parameter attributes rather than `Get-CheckSetVerdict` itself. Combined with the documented PowerShell rule for mandatory collection parameters, the evidence is sufficient for the claim made.
- `evidence/qa-gates/cycle1-local-results-final.2026-10-16T03-06.md`: 654 to 655 tests, coverage 153/160 unchanged. The blank-bucket alternative shares line 214 with the absent-property path, so line coverage could not change.

### Quality assessment prompts

- **Determinism:** `gh`, sleep, and stderr are mocked; the new test uses a literal input.
- **Isolation:** helper tests call one function each.
- **Speed:** all waits are mocked.
- **Diagnostics:** literal `Should -Be` expectations identify the failing field.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: no tokens or credentials. |
| No unsafe subprocess or command construction | PASS | `gh` arguments are an array passed to the existing `Invoke-GhExe` splat. |
| Input validation at boundaries | PASS | `gh` output is treated as untrusted; blank, malformed, non-object, unknown, blank-bucket, and case-variant values are all rejected. |
| Error handling remains explicit | PASS | Typed catch, explicit `return 1` with a message on every failure path. |
| Configuration / path handling is safe | N/A | No path or configuration handling changed. |
| Fail-closed success verdict | PASS | `return 0` is reachable only from `Verdict -ceq 'pass'`, which requires a non-empty set of `pass`/`skipping` buckets. |

---

## Research Log

No external research was required. The PowerShell rule that a `Mandatory` collection parameter rejects `$null` elements unless `[AllowNull()]` is present is consistent with the cycle 1 probe output.

---

## Verdict

The implementation meets the #931 intent and is fail-closed on every non-success input. Cycle 1 resolved the prior test-gap finding within its constraints. There are no Blocker findings and no autonomous findings. The two Major findings are `awaiting_ci` and clear when the PR CI run concludes `success` and the S9 procedure records the PowerShell per-file coverage comparison and the Python coverage threshold step. The remaining Minor (file size) and Info items do not block the merge.
