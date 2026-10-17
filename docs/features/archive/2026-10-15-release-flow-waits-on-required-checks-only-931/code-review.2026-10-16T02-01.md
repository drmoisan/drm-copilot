# Code Review: Release flow waits on every check (#931)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Feature Folder Selection Rule:** the only active feature folder whose suffix matches the branch issue number (931)
**Base Branch:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/release-flow-waits-on-required-checks-only-931` @ `f73457642c3e47a29f64c6e08b63a529a1570716`
**Review Type:** Initial review

---

## Executive Summary

The branch changes the guarded release flow so that `Wait-ForPullRequestChecks` polls every check on the pull request head rather than only branch-protection-required checks. It also makes success a positive assertion. The change touches one production PowerShell script (+120/-24 lines), three Pester suites (one new), and one Python contract test. The review covered the full diff against `main`, the PR-context summary and appendix, the plan and its 40 evidence artifacts, the local Pester JUnit and JaCoCo reports, the main-branch CI coverage artifact, and reviewer reruns of the Python gates.

Implementation quality is good. The new logic is split into two pure helpers with a narrow contract, both unguarded `ConvertFrom-Json` sites were replaced with a non-throwing parser, and a failed or unparsable completion re-poll is now counted against the bounded budget instead of being read as green. Every new branch has a named test, and the local suite reports 0 failures.

**What changed:**
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` lines 162-194 add `ConvertFrom-CheckPollOutput`, which joins output, rejects blank text, parses with `-ErrorAction Stop` under a typed `catch [System.ArgumentException]`, and rejects non-object elements.
- Lines 196-235 add `Get-CheckSetVerdict`, with the precedence empty, fail, unknown, pending, pass and case-sensitive bucket comparison.
- Line 301 drops `--required`.
- Lines 315-355 drive Phase B from the verdict, with new stderr messages and a re-poll path that sets `$checks = @()` on a non-zero exit or a parse failure.
- The help text, script header, and suppression justification were reworded.
- Tests: 17 direct helper tests (new file) and 13 new loop tests, plus string updates in the existing suites. The Python pin asserts no `--required` flag, no "required check" wording, and the presence of three all-checks fragments.

**Top 3 risks:**
1. Results of record are pending: per-test outcomes and per-file coverage on the PR head come from PR CI, which has not run because no PR exists yet.
2. Behavioral widening: release PRs now also wait on path-filtered, non-required workflows that a version bump triggers (for example `publish-extension.yml` PR validation and `npm-audit-gate.yml`). Any of them failing now blocks the merge. This is the intended #931 behavior, but it is a change operators will observe.
3. The production script is at 499 of 500 permitted lines, so the next functional edit must first extract code.

**PR readiness recommendation:** **Conditional Go**. The branch is ready to open as a PR. Merge depends on PR CI success and on the AC6 S9 coverage comparison recorded in `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (awaiting_ci) | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | AC6 CI clause | The PoshQC result of record and the per-file coverage no-regression comparison for the PR head do not exist yet; no PR or branch CI run exists. | Open the PR. When CI concludes `success`, run S9 steps 1-6 from `ac-verification.2026-10-16T01-51.md`: per-file percentage of at least 94.26%, 19 ChecksWait and 17 CheckClassification passes. Then check off AC6. | AC6 names CI results as its verification basis. | `gh pr list --head bug/release-flow-waits-on-required-checks-only-931` returned `[]`; `gh run list --branch ...` returned `[]`. Local supplementary figure: 95.62% (153/160), 0 failures. |
| Major (awaiting_ci) | `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | coverage report | No Python post-change coverage report exists on the branch for a language with a changed file; `artifacts/python/lcov.info` is absent. | Record the PR CI `Enforce Python coverage thresholds` step result and the pytest `TOTAL` line from `quality-checks7 / Code Quality & Tests (3.13)`. | The reviewer coverage rule requires a post-change artifact for every language with changed files. The change is test-only, so the measured value is expected to equal the baseline of 93.72%. | `_quality-checks.yml` lines 79-92; main run 38730332356 job 116406243603 `TOTAL 17638 1108 6368 504 92%`. |
| Minor | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | whole file (499 lines) | The file is 1 line under the 500-line limit. | Before the next functional edit, extract `ConvertFrom-CheckPollOutput` and `Get-CheckSetVerdict` (and possibly the process seams) into a dot-sourced helper file or module with mirrored tests. | Leaves no room for maintenance edits without a size-limit breach. | `wc -l` = 499; `evidence/qa-gates/line-counts-final.2026-10-16T01-51.md`. |
| Minor | `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` | `Get-CheckSetVerdict` Describe | Two contract inputs have no dedicated test: a `$null` element in `-Checks` (script line 213, `$null -eq $check` alternative), and a blank or whitespace `bucket` value (line 214, `IsNullOrWhiteSpace` alternative). Both should yield `unknown` with `Detail` `(missing)`. | Add two `It` blocks: `reports unknown for a null check element` and `reports unknown for a blank bucket value`, each asserting `Verdict` and `Detail`. | Plan Decision 2 specifies these inputs explicitly. Line coverage cannot show the gap because each alternative shares a line with a tested path, and Pester has no branch metric. The behavior is related to this item. | Inspection of lines 211-221 against the 10 verdict test titles. |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | line 184 | The typed catch handles only `System.ArgumentException`. Local JUnit confirms that `reports failure for text that is not JSON` and `returns failure without throwing on unparsable check output` pass on PowerShell 7. Other exception types propagate, which is consistent with fail-fast. | No change. Confirm the same two tests in the PR CI `pester-junit.xml`. | The plan listed the exception type as a residual unknown, and the local run now resolves it. | `artifacts/pester/pester-junit.xml`: CheckClassification 17/17, ChecksWait 19/19, 0 failures. |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | line 301 | Removing `--required` makes non-required, path-filtered workflows gating for release merges. A workflow that registers after the first non-empty all-pass read can be missed (accepted parity race with S9 #899). | No change in this item. Monitor the first release run. | Intended by #931. The race is pre-existing and recorded in plan Notes. | `.github/workflows/publish-extension.yml` and `npm-audit-gate.yml` `pull_request` path filters; plan `## Notes`. |
| Info | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | lines 68-100, 303-313 | Pre-existing and unrelated: `Invoke-GitExe`/`Invoke-GhExe` declare `[OutputType([hashtable])]` but return `[pscustomobject]`, and Phase A treats an auth or network failure as "not yet registered". | File separately, as the plan records. | Outside #931 scope. | Plan `## Notes` (a) and (b). |
| Info | `docs/research/2026-07-09-active-features-delivery-status-audit.md` | line 31 | A dated 2026-07-09 audit quotes the old "required checks to register and complete" help text. | No edit. It is a historical snapshot, and the disposition is recorded. | AC5 targets current descriptions of the release flow. Rewriting dated records would misstate history. | `evidence/qa-gates/reference-search.2026-10-16T01-51.md`. |

No Blocker findings. The two Major findings are classified `awaiting_ci` and need no branch change.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The pin reuses the module's existing helpers (`read_repo_text`, `collapse_whitespace`, `missing_fragments`) and the existing `REQUIRED_FLAG` constant, so whitespace reflow in the script cannot break it.
- The fail-before/pass-after pair is genuine: `1 failed` with the message `... carries the --required flag`, then `1 passed`.

#### Typing and API notes

- No new public Python API surface was added. The constants are module-level tuples and a `Path`, and the test is annotated `-> None`. Pyright reports 0 errors.

#### Error handling and logging

- Not applicable; the change is assertion-only.

### PowerShell implementation audit

#### What changed well

- Success requires at least one check, with every bucket `pass` or `skipping`. An empty set, an unknown bucket, an absent bucket, a parse failure, and a failed re-poll can never produce 0.
- Bucket comparison is case-sensitive (`-ccontains`, `-cnotin`, `-ceq`), so `PASS` is reported as unrecognized rather than accepted. A test pins this.
- Both previous `ConvertFrom-Json` call sites, which could throw on malformed text, now route through one non-throwing parser.
- Interpolation uses `${PrNumber}: ${value}` to avoid a scope-qualified variable parse.

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType([pscustomobject])]`, `Mandatory` parameters with `AllowEmptyCollection`/`AllowNull`/`AllowEmptyString` where the contract allows them. The verbs are approved.
- Property access through `PSObject.Properties['bucket']` is strict-mode safe.
- The `Wait-ForPullRequestChecks` signature, defaults, and timeout messages are unchanged, so the caller `Invoke-FullReleaseFlowGuarded` needs no change.

#### Error handling and logging

- Each non-success path writes one specific stderr line: parse failure, failed check, unrecognized bucket with its value, and timeouts. No broad catch is used.

---

## Test Quality Audit

Evidence reviewed: the reviewer reran the Python gates on the changed module (Black, Ruff, Pyright, pytest: 35 passed). The local Pester JUnit and JaCoCo reports were produced after the implementation commit `3fdbc47ca`. The main-branch CI `poshqc-test-results` artifact (run 38730332356) supplies the baseline. CI-of-record results for the PR head are pending.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`: 17 direct, mock-free tests of both helpers, covering pass, pending, fail, cancel, precedence, unknown and case, absent property, empty set, parse success, multi-line output, blank output, invalid JSON, and null and scalar elements. Gap: CR Minor above.
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: 13 new loop tests with a response-index mock. They assert return codes, the exact `gh` argument list, the absence of `--required`, stderr text, and `gh`/sleep call counts.
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`: four argument strings and one message updated. The end-to-end guarded-flow tests still assert the full `gh` call sequence.
- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`: a text pin preventing regression to `--required` or required-only wording.
- `evidence/regression-testing/release-flow-pin-fail-before.2026-10-16T01-29.md` and `release-flow-pin-pass-after.2026-10-16T01-42.md`: a genuine fail-before/pass-after pair.
- `evidence/regression-testing/fail-before-exception.2026-10-16T01-42.md`: an absence-of-test proof for the Pester additions, because the MCP tools return status only.
- `artifacts/pester/pester-junit.xml`: 654 tests, 0 failures, 0 errors, 2 disabled. The release-flow suites passed 62/62.
- `artifacts/pester/powershell-coverage.xml`: script 153/160 lines (95.62%). The uncovered lines 81, 82, 98, 99, 118, 119, and 141 are the mocked process seams and are unchanged from baseline.

### Quality assessment prompts

- **Determinism:** `gh`, sleep, and stderr are mocked, and responses are scripted per call index. No clock, randomness, network, or temporary file is used.
- **Isolation:** helper tests call one function each, and loop tests target one scenario each.
- **Speed:** all waits are mocked; the Python module runs in 0.10 s.
- **Diagnostics:** literal `Should -Be`/`-Match` expectations and named call-count assertions identify the failing path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: no tokens, credentials, or URLs with secrets. |
| No unsafe subprocess or command construction | PASS | `gh` arguments are an array passed to the existing `Invoke-GhExe` splat; `$PrNumber` is not string-concatenated into a command line. |
| Input validation at boundaries | PASS | `gh` output is treated as untrusted. Blank, malformed, non-object, unknown, and case-variant values are all rejected. |
| Error handling remains explicit | PASS | Typed catch, explicit `return 1` with a message on every failure path. |
| Configuration / path handling is safe | N/A | No path or configuration handling changed. |
| Fail-closed success verdict | PASS | `return 0` is reachable only from `Verdict -ceq 'pass'`, which requires a non-empty set of `pass`/`skipping` buckets. |

---

## Research Log

No external research was required beyond the in-repository research file `research/2026-10-15-release-flow-all-checks-research.md`. The `gh pr checks --json` exit-code behavior noted there as a residual unknown does not affect the verdict, because success is never inferred from the exit code.

---

## Verdict

The implementation meets the #931 intent, follows the repository's PowerShell and testing conventions, and is fail-closed on every non-success input. There are no Blocker findings. The two Major findings are `awaiting_ci`: both clear when the PR CI run concludes `success` and the S9 procedure records the PowerShell per-file coverage comparison and the Python coverage threshold step. The branch is ready for normal PR flow.

The two Minor items (file-size headroom and two untested contract inputs) are related to this item and are suitable for an in-item fix or a follow-up. They do not block the merge.
