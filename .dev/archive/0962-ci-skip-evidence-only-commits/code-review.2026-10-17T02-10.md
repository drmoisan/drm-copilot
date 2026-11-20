# Code Review: CI change-scope skip for evidence-only commits (#962)

---

**Review Date:** 2026-10-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`
**Feature Folder Selection Rule:** the only active feature folder whose suffix matches the branch issue number 962
**Base Branch:** `origin/main` @ `b8fcd77905a51284cfbca54226a2da2a7916a836` (merge base identical; `origin/main` has not moved)
**Head Branch:** `bug/ci-skip-evidence-only-commits-962` @ `8be7c95da5af05f6a9464a776469a380b400c0e2`
**Review Type:** Re-review after remediation cycle 1 (supersedes `code-review.2026-10-17T00-43.md`)

---

## Executive Summary

The branch implements research Candidate B: a `Change scope` job in `ci.yml` decides whether the heavy CI steps run, and the six reusable workflows that produce the 11 required contexts keep their jobs running under their full-run names while every step is gated on a new `run-heavy` input. A `CI full run` marker job lets later decisions recognize a run in which the heavy steps ran. The decision logic is PowerShell 7, split into a pure module (`scripts/ci/CiChangeScope.psm1`, 345 lines) and a thin I/O entry script (`scripts/ci/Invoke-CiChangeScope.ps1`, 271 lines) with injectable seams.

Since the prior review, remediation cycle 1 (commit `d91d8e274`) changed three files outside the feature folder: `.github/workflows/_security-scan.yml` gained `continue-on-error: true` on the step `Check for security vulnerabilities`; Pester row W18 in `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` now asserts that this line exists, that it is the only `continue-on-error` line in the job, and that it belongs to the scan step; and the `### Security scan` subsection of `.github/workflows/README.md` describes the non-blocking scan and the 101 pre-existing findings. The cause was the first full CI run (38988542731), in which the now non-vacuous scan reported 101 findings in 14 locked packages and failed the required `security-scan / Security Scanning` context.

Evidence reviewed: the full branch diff, the remediation diff, `artifacts/pr_context.summary.txt` (generated for head `8be7c95da`), the feature `evidence/` tree, and CI run 38992247041 on the head (23 of 23 jobs `success`; logs and the `poshqc-test-results` and `shell-coverage` artifacts parsed by this review).

**What changed:**
- `.github/workflows/ci.yml`: new `changes` and `full-run-marker` jobs; six required callers gain `needs: changes`, `if: ${{ !cancelled() }}`, and `run-heavy`; `root-typescript-tests` and `npm-audit-gate` skip at job level on `code == 'false'`; the `on:` block is unchanged.
- Six reusable workflows: `run-heavy` input and step gating; the `poshqc` aggregator keeps `if: always()`.
- `_security-scan.yml`: new `Install the Poetry export plugin` step, `shell: bash` on the scan step, `continue-on-error: true` kept on the scan step only.
- `scripts/bash/shell_qc_lib.sh`: `--recursive` in both bats invocations; `check_coverage_threshold` after the coverage summary.

**Top 3 risks:**
1. The skip path depends on GitHub Actions behaviour that only `pull_request` runs can show (all-steps-skipped jobs reporting `success` under matrix-expanded names; check-run names matching the ruleset). AC-33 verifies it at S9. If the assumption fails, required contexts stay unsatisfied and the PR blocks; it does not merge untested code.
2. The security scan is advisory: a new advisory, or an export failure, does not fail the required context. This matches the base branch, where the step already carried `continue-on-error: true` and, without the export plugin, did not scan locked packages. The branch makes the scan read 78 packages (CI log `Found and scanned 78 packages`); the coordinator follow-up to upgrade the 14 affected packages and remove `continue-on-error` is recorded in `remediation-plan.2026-10-17T01-20.md`.
3. The bash coverage gate passes silently when the merged `cov.xml` is absent (CR-1). In run 38992247041 the report was present and the gate printed its pass line.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; CI is green on the head; the CI-dependent criteria are verified at S9 on the PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/bash/shell_qc_lib.sh` | `check_coverage_threshold`, lines 311-341; call site line 429 | CR-1 (carried): `check_coverage_threshold` returns 0 and prints nothing when `cov.xml` is absent or unparseable, and the upload glob `artifacts/pester/kcov/**` can be satisfied by other kcov files, so a run whose merge produced no `cov.xml` passes the 85% gate. | Fail `run_test_coverage` when kcov ran but `cov.xml` is absent, or narrow the upload path to `artifacts/pester/kcov/cov.xml`; keep the stub-kcov tests working with a fixture report. | A gate that passes when its input is missing cannot detect the failure it exists to catch. Specified and tested behaviour, so a design gap rather than a spec defect. | bats `ok 719 check_coverage_threshold prints nothing and passes when cov.xml is missing` (job 117277015644); `_shell-coverage.yml` lines 74-80. |
| Minor | `.github/workflows/_security-scan.yml` | `Check for security vulnerabilities` step | CR-2 (revised): `safety check` is the deprecated Safety 3.x command and `pip install safety` is unpinned (CI installed Safety 3.8.1, whose output recommends the `scan` command). With `continue-on-error: true`, a behaviour change in a later Safety release would not turn the context red, but could make the scan vacuous without notice. | When the coordinator follow-up removes `continue-on-error`, pin Safety and move to the supported command in the same change. | An advisory scan whose tool version floats can stop scanning without any visible signal. | Job 117277015648 log (`Downloading safety-3.8.1-py3-none-any.whl` and the deprecation notice recommending the `scan` command); `remediation-plan.2026-10-17T01-20.md` coordinator follow-up. |
| Minor | `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiChangeScope.Tests.ps1` | entry script lines 157-158; module lines 62, 81, 86, 169, 217, 226, 273, 282, 286 | CR-3 (carried): several fail-closed branches have no test (unparseable job-list payload mapped to `JOB_LIST_FAILED`, invalid `exclude_prefixes`, empty `extensions`, non-object top-level JSON, a NUL list with an empty entry, blank or `jobs`-less payloads). | Add one row per branch through the existing scenario helper. | Negative-flow coverage is required by `.claude/rules/general-unit-test.md`. Every untested branch fails closed, and per-file coverage stays above 85%. | Uncovered `LINE` entries in the CI merged `powershell-coverage.xml` (121/130 and 78/88). |
| Info | `.github/workflows/_security-scan.yml`, `.github/workflows/README.md` | scan step; `### Security scan` | The remediation is scoped as planned: one added line in the workflow, and W18 asserts both the value and the step placement, so `continue-on-error` cannot spread to the export-plugin step or be set to `false` without a test failure. The README names the 101 findings and their evidence file. | None. | Matches RPD-1, RPD-2, and RPD-4; fail-before and pass-after recorded. | `git show d91d8e274`; `evidence/regression-testing/rem1-w18-expect-fail.2026-10-17T01-33.md`, `rem1-w18-pass.2026-10-17T01-34.md`; CI junit test case `...with continue-on-error true after installing the Poetry export plugin (AC-36)` `status="Passed"`. |
| Info | `.github/workflows/_security-scan.yml` | scan step exit status | The scan step ended with `Process completed with exit code 64` (findings) and the job concluded `success` through `continue-on-error`. The step outcome is visible as an annotation but not as a failed context. | None for this item; covered by the coordinator follow-up. | Expected behaviour of PD-18. | Job 117277015648 log (`##[error]Process completed with exit code 64.`); run 38992247041 job list. |
| Info | `scripts/ci/Invoke-CiChangeScope.ps1` | `Find-CiChangeScopeBase`, line 132 | The run list reads one page of 50 successful runs; beyond that the decision returns `NO_FULL_GREEN_RUN` and runs in full. | None. | Bounded API cost; fails closed. | Source line 132; README change-scope section. |
| Info | `scripts/ci/Invoke-CiChangeScope.ps1` | `Invoke-CiChangeScopeNative`, lines 38-40 | NUL preservation through native-output capture is not unit-tested; altered NULs give `DIFF_FAILED` (full run). | Confirm through AC-33 on the PR. | Loses the optimization but cannot skip CI. | Source lines 38-40; module lines 160-171. |
| Info | `.github/workflows/ci.yml` | `changes` job | The decision script runs from the PR head; a same-repository author could alter it, but can already alter every workflow, and such a change is a non-allowlisted path. Event-derived values reach the script through `env:`. | None. | No new trust boundary; prevents expression injection. | `ci.yml` diff; `Test-CiChangeScopeEventEligible`. |

No Blocker or Major finding.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The only Python change is one assertion in `test_threshold_step_runs_on_every_matrix_leg`, requiring the step's `if` value to equal `${{ inputs.run-heavy }}` exactly. The step ran and passed on all four legs of run 38992247041.

#### Typing and API notes

- No new public Python API surface. The new module constant `RUN_HEAVY_GATE` is a plain `str`.

#### Error handling and logging

- Not applicable to the test-only change; the assertion message names the found value.

### PowerShell implementation audit

#### What changed well

- Pure/I-O split: the module performs no `gh`, `git`, file, or network call.
- `New-CiChangeScopeDecision` refuses `code=false` without a `DOCS_ONLY_SINCE_` reason, so only the final docs-only return can produce a skip.
- The green base requires both run conclusion `success` and marker job `success`, so a docs-only run cannot become a base.
- Path checks reject backslashes, a leading `/`, and `..` segments before ordinal prefix comparison.
- The revised W18 row reads the committed YAML through the suite's existing job and step helpers and uses exact-line matches (`-ccontains`, `-BeExactly`).

#### API and safety notes

- Advanced functions with `[OutputType()]`; `Set-StrictMode -Version Latest`; payload fields read through `PSObject.Properties`.
- Two analyzer suppressions are justified (spec-fixed name; in-memory factory).
- The dot-source guard keeps the entry point from running in tests; the workflow step adds `exit 0` and `continue-on-error: true`, consistent with `.claude/rules/ci-workflows.md`.

#### Error handling and logging

- Every decision writes `code=<value>` to `GITHUB_OUTPUT`, logs `code=<value> reason=<REASON>`, and writes a summary line. In run 38992247041 the job logged `code=true reason=EVENT_NOT_PULL_REQUEST`.
- Callers compare the output with `!= 'false'`, so an absent output also yields a full run.

---

## Test Quality Audit

The four new Pester suites and the adjusted suites pass locally and in CI (three shards, 11129 tests, 0 failures). The bats suite ran 733 tests with no failure, including the eight new tests. The W18 replacement was shown to fail against the unchanged workflow and pass after the edit.

### Reviewed test and QA artifacts

- `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` — 30 rows through in-memory fakes. Gap: CR-3.
- `tests/scripts/ci/CiChangeScope.Tests.ps1` — 54 rows for the pure functions.
- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` — 23 rows for the committed allowlist contract.
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` — 39 rows (325 lines) for AC-18 to AC-21 and AC-36.
- `tests/shell/test_shell_qc_commands.bats` — 8 new tests, all `ok` in job 117277015644 (ok 712 to ok 719).
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-w18-expect-fail.2026-10-17T01-33.md` and `rem1-w18-pass.2026-10-17T01-34.md` — fail-before and pass-after for W18.
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-hermetic.2026-10-17T01-39.md` — 325 lines, `HERMETIC-HITS: 0`.

### Quality assessment prompts

- **Determinism:** no clock, RNG, process, network, or temporary file in the PowerShell suites.
- **Isolation:** each row changes one scenario field from a documented standard scenario.
- **Speed:** 236 tests in 2.85 s locally; W18 0.007 s in CI.
- **Diagnostics:** `-Because` clauses name the rule and, for W18, the PD-18 reason.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Only `${{ github.token }}` as `GH_TOKEN` to a job with `actions: read`, `contents: read`; `persist-credentials: false`. |
| No unsafe subprocess or command construction | ✅ PASS | `gh` and `git` invoked with argument arrays; event fields through `env:`. |
| Input validation at boundaries | ✅ PASS | API payloads, config JSON, and diff output validated; invalid input fails closed. |
| Error handling remains explicit | ✅ PASS | Prefix-scoped catches re-throw unexpected errors to one envelope. |
| Configuration / path handling is safe | ✅ PASS | Allowlist rejects traversal, backslashes, and absolute paths; workflow, script, and config paths are outside the include prefixes. |
| Fail-closed CI behaviour | ✅ PASS | Non-`pull_request` events, forks, API errors, missing or non-ancestor base, diff errors, empty diffs, and non-allowlisted paths all give `code=true`. |
| Dependency vulnerability scanning | ✅ PASS (advisory) | The scan reads 78 locked packages and reports 101 pre-existing findings in 14 packages; it is non-blocking by recorded decision PD-18, as the base branch's step already was. |

---

## Research Log

No external research was required. The review used the repository's research artifact (`research/research.2026-10-16T14-39.md`) for the GitHub Actions skip semantics and CI run 38992247041 for runtime behaviour.

---

## Verdict

The code is ready for PR. No Blocker or Major finding was identified. The three Minor findings (CR-1 silent pass on an absent bash coverage report, CR-2 unpinned deprecated Safety command in the advisory scan step, CR-3 untested fail-closed validation branches) are recommendations; none can cause CI to be skipped unsafely. The remediation change is minimal, tested with fail-before and pass-after evidence, and green in CI.

The CI-dependent criteria AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38 remain for the S9 gate on the PR.
