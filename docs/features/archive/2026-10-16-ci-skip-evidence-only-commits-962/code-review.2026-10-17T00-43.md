# Code Review: CI change-scope skip for evidence-only commits (#962)

---

**Review Date:** 2026-10-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`
**Feature Folder Selection Rule:** the only active feature folder whose suffix matches the branch issue number 962
**Base Branch:** `origin/main` @ `b8fcd77905a51284cfbca54226a2da2a7916a836` (merge base identical)
**Head Branch:** `bug/ci-skip-evidence-only-commits-962` @ `0f98da84e5474e9c09892b33c2fb2995b763457c`
**Review Type:** Initial review

---

## Executive Summary

The branch implements research Candidate B: a `Change scope` job in `ci.yml` decides whether the heavy CI steps run, and the six reusable workflows that produce the 11 required contexts keep their jobs running under their full-run names while every step is gated on a new `run-heavy` input. A `CI full run` marker job lets later decisions recognize a run in which the heavy steps actually ran. The decision logic is PowerShell 7, split into a pure module (`scripts/ci/CiChangeScope.psm1`, 345 lines) and a thin I/O entry script (`scripts/ci/Invoke-CiChangeScope.ps1`, 271 lines) with injectable `gh`, `git`, writer, and environment seams. The D14 follow-ups make the security scan blocking, make bats discovery recursive, and add an 85% bash line-coverage gate.

Evidence reviewed: the full branch diff, `artifacts/pr_context.summary.txt`, the feature `evidence/` tree, `artifacts/pester/pester-junit.xml` (236 tests, 0 failures), and `artifacts/pester/powershell-coverage.xml` (re-parsed: 93.08% and 88.64% line coverage on the two new files). The implementation is consistent with the spec, fails closed on every error path inspected, and introduces no new trust boundary.

**What changed:**
- `.github/workflows/ci.yml`: new `changes` (read-only `actions`/`contents` permissions, partial clone, `continue-on-error` decision step, all event fields passed through `env:`) and `full-run-marker` jobs; six required callers gain `needs: changes`, `if: ${{ !cancelled() }}`, and `run-heavy: ${{ needs.changes.outputs.code != 'false' }}`; `root-typescript-tests` and `npm-audit-gate` skip at job level on `code == 'false'`; `docs-validation` and the `on:` block are unchanged.
- Six reusable workflows: `run-heavy` input under `workflow_call` and `workflow_dispatch` (default `true`), `if: ${{ inputs.run-heavy }}` on every step of each required job, combined conditions on the cache-miss and 3.13-only steps, job-level gates on the non-required `_poshqc.yml` jobs, and the `poshqc` aggregator keeping `if: always()`.
- `_security-scan.yml`: new `Install the Poetry export plugin` step, `shell: bash` on the scan step, `continue-on-error: true` removed.
- `scripts/bash/shell_qc_lib.sh`: `--recursive` in both bats invocations; `check_coverage_threshold` called after the coverage summary.

**Top 3 risks:**
1. The design rests on GitHub Actions behaviour that only a real PR run can show: a job whose steps are all skipped reporting `success` under its matrix-expanded name, and the check-run names matching ruleset 15241672 (AC-33). If either assumption fails, a docs-only commit would leave required contexts unsatisfied. The PR would then block rather than merge untested code, so the failure mode is safe.
2. The security scan is now blocking. `safety check` is a deprecated command in Safety 3.x, and the first full run may report findings or fail on the export pipeline; AC-36 defines the remediation path.
3. The new bash coverage gate passes silently when the merged `cov.xml` is absent (CR-1), so a kcov merge failure would not fail `shell-coverage`.

**PR readiness recommendation:** **Conditional Go** — no code defect requires a change; readiness depends on a green CI run of the branch head (policy-audit findings B-1 to B-4) and on the S9-owned CI-dependent criteria.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/bash/shell_qc_lib.sh` | `check_coverage_threshold`, lines 311-341; call site line 429 | CR-1: `check_coverage_threshold` returns 0 and prints nothing when `cov.xml` is absent or unparseable. `_shell-coverage.yml` uploads `artifacts/pester/kcov/**` with `if-no-files-found: error`, which other kcov output files can satisfy, so a run whose merge produced no `cov.xml` passes the new 85% gate. | In a follow-up, fail `run_test_coverage` when kcov ran successfully but `cov.xml` is absent, or narrow the upload path to `artifacts/pester/kcov/cov.xml`. Keep the stub-kcov tests working by passing a fixture report. | A coverage gate that passes when the report is absent cannot detect the failure it exists to catch. The behaviour is specified and tested (bats test `prints nothing and passes when cov.xml is missing`), so it is a design gap, not a defect against the spec. | Diff of `shell_qc_lib.sh`; `tests/fixtures/shell_qc/stub-bin/kcov` (writes no coverage files); `.github/workflows/_shell-coverage.yml` lines 74-80. |
| Minor | `.github/workflows/_security-scan.yml` | `Check for security vulnerabilities` step | CR-2: The scan now fails the required `security-scan / Security Scanning` context on any finding. `safety check` is the deprecated Safety 3.x command, and `pip install safety` is unpinned, so a Safety release can change the command's behaviour without a repository change. | Record the first full-run result under AC-36. In a follow-up, pin the Safety version or move to the supported scan command. | A required check that depends on an unpinned tool can turn red on a commit that changes nothing. | Diff of `_security-scan.yml`; spec AC-36 remediation rule. |
| Minor | `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiChangeScope.Tests.ps1` | entry script lines 157-158; module lines 62, 81, 86, 169, 217, 226, 273, 282, 286 | CR-3: Several fail-closed branches have no test: an unparseable job-list payload mapped to `JOB_LIST_FAILED`, invalid `exclude_prefixes`, empty `extensions`, non-object JSON at the top level, a NUL list with an empty entry, and blank or `jobs`-less payloads. The spec's test strategy lists malformed JSON for the job list. | Add one row per branch; each is a one-line fixture change in the existing scenario helper. | `.claude/rules/general-unit-test.md` requires negative-flow coverage. Every untested branch fails closed (any unmapped throw reaches the `UNEXPECTED_ERROR` envelope), so the gap cannot produce an unsafe skip. Per-file coverage stays above 85%. | `ci="0"` line entries for the `scripts/ci` package in `artifacts/pester/powershell-coverage.xml`. |
| Info | `scripts/ci/Invoke-CiChangeScope.ps1` | `Find-CiChangeScopeBase`, line 132 | The run list reads one page of 50 successful runs. On a branch with more than 50 successful docs-only runs since its last full run, the decision returns `NO_FULL_GREEN_RUN` and runs in full. | None required; the behaviour is documented in the README section and fails closed. | Bounded API cost (spec performance constraint). | Source line 132; `.github/workflows/README.md` change-scope section. |
| Info | `scripts/ci/Invoke-CiChangeScope.ps1` | `Invoke-CiChangeScopeNative`, lines 38-40 | NUL preservation through PowerShell native-output capture is not unit-tested; the function is the process boundary. If NULs were altered, `ConvertFrom-CiNulPathList` would return `Valid = $false` and the decision would be `DIFF_FAILED` (full run). | Confirm through AC-33 on the PR. | The failure mode loses the optimization but cannot skip CI. | Source lines 38-40 and 160-171 of the module. |
| Info | `.github/workflows/ci.yml` | `changes` job | The decision script runs from the PR head, so a same-repository author could change it to emit `code=false`. The same author can already edit `ci.yml` and every reusable workflow, and such a change is a non-allowlisted path visible in review. Fork PRs are excluded by the fork gate and receive no token write scope. | None. | No new trust boundary relative to the existing `pull_request` workflow model. | `ci.yml` diff; `Test-CiChangeScopeEventEligible`. |
| Info | `.github/workflows/ci.yml` | `changes` job `env:` block | All event-derived values (`HEAD_REF`, `HEAD_REPO`, `HEAD_SHA`, `EVENT_NAME`) reach the script through `env:` rather than `${{ }}` interpolation into `run:`, and the run-list query escapes the branch name with `[uri]::EscapeDataString`. | None. | Prevents expression injection from branch names. | `ci.yml` lines 32-41; script line 132. |
| Info | `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | adjusted assertions | Three pre-existing assertions were narrowed to admit the exact new lines (five event-field lines, the run-heavy gate on the poshqc gate step, the run-heavy gate on the Python threshold step). Each adjustment is exact-match, so any other change still fails. | None. | Consistent with spec D6; recorded in `evidence/other/workflow-suite-adjustment.2026-10-17T00-12.md`. | Diffs of the three files. |

No Blocker or Major findings in the code. The open review obligations are the CI-dependent policy findings B-1 to B-4 in `policy-audit.2026-10-17T00-43.md`.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The only Python change is one assertion in `test_threshold_step_runs_on_every_matrix_leg`: it now requires the step's `if` value to equal `${{ inputs.run-heavy }}` exactly, which preserves the original intent (no per-leg condition) and fails on any other condition.

#### Typing and API notes

- No new public Python API surface was added. The new module constant `RUN_HEAVY_GATE` is a plain `str`.

#### Error handling and logging

- Not applicable to the test-only change. The assertion carries a diagnostic message naming the found value.

### PowerShell implementation audit

#### What changed well

- Clear pure/I-O split: the module performs no `gh`, `git`, file, or network call, which `AC-17` and the structure evidence confirm.
- `New-CiChangeScopeDecision` refuses `code=false` without a `DOCS_ONLY_SINCE_` reason, so no decision path other than the final docs-only return can produce a skip.
- Catch blocks in `Find-CiChangeScopeBase` re-throw any error outside their own `CI_RUN_LIST_INVALID:` or `CI_JOB_LIST_INVALID:` prefix, so unexpected errors reach the single fail-closed envelope rather than being misreported.
- The green base requires both the run conclusion `success` and the marker job conclusion `success`, so a docs-only run (marker skipped) can never become the base for a later skip.
- Path checks reject backslashes, a leading `/`, and `..` segments before any prefix comparison, and prefixes compare ordinally.

#### API and safety notes

- All functions are advanced functions with `[OutputType()]`; `Set-StrictMode -Version Latest` in both files; payload fields are read through `PSObject.Properties` so absent fields exclude a run rather than throw under strict mode.
- Two analyzer suppressions are justified: the spec fixes the name `Select-CiGreenBaseCandidates`, and `New-CiChangeScopeDecision` is an in-memory factory with no state change.
- The dot-source guard (`$MyInvocation.InvocationName -ne '.'`) keeps the entry point from running in tests, and the entry point ends with `exit 0`; the workflow step adds its own `exit 0` and `continue-on-error: true`, consistent with `.claude/rules/ci-workflows.md`.

#### Error handling and logging

- Every decision writes `code=<value>` to `GITHUB_OUTPUT`, logs `code=<value> reason=<REASON>`, and writes a summary line with the base SHA. An unexpected exception produces a `::warning::` annotation naming the exception message and `code=true reason=UNEXPECTED_ERROR`.
- Callers compare the output with `!= 'false'`, so an absent output (failed decision step) also yields a full run.

---

## Test Quality Audit

The four new Pester suites (146 tests) and the adjusted suites pass in a single invocation (255 passed, 0 failed). The regression suite `CiChangeScopeWorkflow.Tests.ps1` was shown to fail against the pre-change workflows and pass after the edits (AC-23). Bats tests run only in CI.

### Reviewed test and QA artifacts

- `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` — 30 rows driving the entry script through in-memory fakes; asserts reason codes, invoker call counts, the diff argument set, and the published texts. Gap: CR-3.
- `tests/scripts/ci/CiChangeScope.Tests.ps1` — 54 rows for the pure functions, including case-sensitivity, upper-case extension, and traversal rejections.
- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` — 23 rows asserting the committed allowlist contract.
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` — 39 rows asserting the AC-18 to AC-21 and AC-36 workflow invariants from the committed YAML.
- `tests/shell/test_shell_qc_commands.bats` — 8 new tests (recursive discovery, six threshold cases); not executed locally.
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/expect-fail-new-suites.2026-10-16T23-42.md` — fail-before record for the new suites.
- `artifacts/pester/powershell-coverage.xml` — per-file line coverage, re-parsed by this review.

### Quality assessment prompts

- **Determinism:** no clock, RNG, process, network, or temporary file in the PowerShell suites; a grep for the prohibited constructs returned no match.
- **Isolation:** each row changes one scenario field from a documented standard scenario.
- **Speed:** 236 tests in 2.85 s.
- **Diagnostics:** `-Because` clauses name the rule; reason-code assertions use `-BeExactly`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Only `${{ github.token }}` passed as `GH_TOKEN` to a job with `actions: read`, `contents: read`; `persist-credentials: false` on checkout. |
| No unsafe subprocess or command construction | ✅ PASS | `gh` and `git` are invoked with argument arrays (`& $FileName @ArgumentList`); no string-built command lines; event fields reach the script through `env:`. |
| Input validation at boundaries | ✅ PASS | API payloads, config JSON, and diff output are validated before use; invalid input fails closed. |
| Error handling remains explicit | ✅ PASS | Prefix-scoped catches re-throw unexpected errors to one envelope that emits a warning annotation. |
| Configuration / path handling is safe | ✅ PASS | Allowlist rejects traversal, backslashes, and absolute paths; the allowlist file itself is not allowlisted, and workflow, script, and config paths are outside the include prefixes. |
| Fail-closed CI behaviour | ✅ PASS | Non-`pull_request` events, forks, API errors, a missing or non-ancestor base, diff errors, empty diffs, and non-allowlisted paths all give `code=true`; `merge_group` and `push` to `main` never skip. |

---

## Research Log

No external research was required. The review relied on the repository's research artifact (`research/research.2026-10-16T14-39.md`) for the GitHub Actions skip semantics, which the spec marks as unverified until the CI-dependent criteria AC-32 to AC-34 run on the PR.

---

## Verdict

The code is ready for normal PR flow. No Blocker or Major finding was identified; the three Minor findings (CR-1 silent pass on an absent bash coverage report, CR-2 unpinned deprecated Safety command in a now-blocking step, CR-3 untested fail-closed validation branches) are suitable for follow-up work inside this item's remediation cycle or a separate issue, at the orchestrator's discretion. None of them can cause CI to be skipped unsafely.

Merge readiness depends on CI, not on code changes: the branch needs a green `CI` run against its head (policy-audit findings B-1 to B-4), and the S9 gate must verify the CI-dependent criteria AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38 on the PR.
