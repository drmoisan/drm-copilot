# Feature Audit — Issue #452 v2 Regression Cycle

- Timestamp: 2026-09-27T16-03
- Branch: `bug/blast-radius-under-reporting-regression-452`
- Head: `f7b1acadf21bf9f510f294be2c8cde668eb1498a`

## Scope and Baseline

- **Baseline.** `origin/main` at merge-base `beae3f021674e64fa6662097fe48a332d8da62b8`. This matches the spec's stated baseline "main at beae3f02". The `CI` workflow on main at that commit concluded `success` (`gh run list --branch main`).
- **Diff.** `git diff --name-status origin/main...HEAD` lists 61 added files and no modified or deleted file:
  - 58 files under `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/`: the spec, the plan, the research, and 55 evidence files;
  - `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`;
  - `tests/scripts/dev_tools/test_blast_radius_regression_452.py`;
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`.
- **Work mode.** `full-bug`, per the `v2/spec.md` marker. The v1 `issue.md` in the feature root is read-only background for this cycle. The v2 spec states that it is the sole acceptance-criteria source.
- **Acceptance-criteria source.** `v2/spec.md` `## Acceptance Criteria` (22 checkbox items). There is no `user-story.md`, by design.
- **Executed plan.** `v2/plan.2026-09-27T12-15.md` (revision 10).
- **Pre-PR state.** No pull request exists. AC-21 and AC-22 depend on the pull request and are recorded as pending.

## Acceptance Criteria Inventory

AC numbers follow the order of the checkbox items in `v2/spec.md` "Acceptance Criteria".

| AC | Summary | Checkbox state before review |
|---|---|---|
| AC-1 | Corpus exists, parses, conforms to the shapes, and carries exactly the Case List ids, uniquely | [x] |
| AC-2 | Pairing rules hold; verified in both consumers | [x] |
| AC-3 | Both directions per gap; verdict matches direction; verified in both consumers | [x] |
| AC-4 | quality-tiers.yml pinned as the mandate-read doctrine pin and as a conflicting declared radius | [x] |
| AC-5 | Plan-line intent rule (Edit/Create; Read for the doctrine pin); verified in both consumers | [x] |
| AC-6 | Phase 0 Python execution evidence for every case | [x] |
| AC-7 | Phase 0 PowerShell execution evidence for every case, with the three-way comparison | [x] |
| AC-8 | Conditional production correction resolved and recorded | [x] |
| AC-9 | Python consumer passes, loading relative to `__file__` | [x] |
| AC-10 | Python mutation demonstration recorded | [x] |
| AC-11 | Pester consumer passes through the PoshQC MCP test tool with the repository runsettings | [x] |
| AC-12 | Pester mutation demonstration recorded | [x] |
| AC-13 | Bundled-configuration parity asserted in both consumers | [x] |
| AC-14 | Merge-order independence (no cohort, drift, or mutation-protocol calls) | [x] |
| AC-15 | Conditional tolerance branch resolved and recorded | [x] |
| AC-16 | Loading constraints verified by text search and recorded | [x] |
| AC-17 | Non-goals untouched | [x] |
| AC-18 | Non-Markdown, non-JSON files at or under 500 lines, recorded | [x] |
| AC-19 | Full Python toolchain in a single pass, with the coverage thresholds | [x] |
| AC-20 | Full PowerShell toolchain in a single pass, 0 findings, line coverage >= 85% | [x] |
| AC-21 | All required CI checks green on the PR head | [ ] |
| AC-22 | PR body contains `Fixes #452` | [ ] |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence and reviewer verification |
|---|---|---|
| AC-1 | PASS | The reviewer ran the Python consumer: `test_corpus_top_level_shape_matches_the_contract`, `test_every_case_matches_the_case_shape_contract`, and `test_corpus_case_ids_are_unique_and_equal_the_spec_case_list` passed. The reviewer's own load of the corpus listed 17 cases matching the spec Case List field by field. |
| AC-2 | PASS | The pairing test passed in both consumers (reviewer runs: Python 25 passed; Pester 25 passed). The Python test additionally requires that the set of non-reciprocated controls equals the set of doctrine pins (`{g1-plan-quality-tiers-mandate-read}`). |
| AC-3 | PASS | `test_every_expected_verdict_matches_its_direction` and `test_each_gap_has_a_must_conflict_and_a_must_not_conflict_case` passed, and the Pester equivalents passed (reviewer runs). |
| AC-4 | PASS | The per-case tests for `g1-plan-quality-tiers-mandate-read` (expected no conflict) and `g1-radius-quality-tiers` (expected `path_overlap` and `shared_surface_overlap`) passed in both consumers (reviewer runs). |
| AC-5 | PASS | The plan-line intent test passed in both consumers. The reviewer's corpus dump shows four `Edit` plan cases and one `Read` doctrine-pin case, each one line of the form `- [ ] [P1-T1] <Verb> \`<path>\`.`. |
| AC-6 | PASS | `v2/evidence/baseline/phase0-python-runtime-verdicts.2026-09-27T14-56.md`: `poetry run python <scratchpad>/phase0_python_verdicts.py`, EXIT_CODE 0, 17 CASE lines (reviewer count). |
| AC-7 | PASS | `v2/evidence/baseline/phase0-powershell-runtime-verdicts.2026-09-27T14-58.md` (17 CASE lines, EXIT_CODE 0, run through an `sh` wrapper against the root modules) and `v2/evidence/baseline/phase0-three-way-comparison.2026-09-27T14-59.md` (17 COMPARE lines, all AGREE, BRANCH=AGREE). |
| AC-8 | PASS | `v2/evidence/regression-testing/phase1-correction-resolution.2026-09-27T15-03.md` records `CORRECTION_BRANCH: NO-CORRECTION-REQUIRED`. The reviewer confirmed that `git diff --name-only origin/main...HEAD -- .claude scripts extensions config pyproject.toml .github` returns no output. |
| AC-9 | PASS | Reviewer run: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py` gave 25 passed and 1 skipped. The skip is the pre-authorized tolerance test. `REPO_ROOT = Path(__file__).resolve().parents[3]`. |
| AC-10 | PASS | `v2/evidence/regression-testing/phase3-python-mutation-demonstration.2026-09-27T15-18.md`: four flips (one must-conflict and one must-not-conflict case per gap), each raising an AssertionError that names the case. Porcelain is empty and the anchored diff exits 0. The reviewer repeated the procedure on four different cases, and each flip was detected with the case named. |
| AC-11 | PASS | `v2/evidence/regression-testing/phase4-pester-consumer-run.2026-09-27T15-28.md` and `v2/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md` record the MCP test call plus the self-hosted PoshQC run with the repository runsettings: 26 matched, 25 PASS, 1 SKIP, 0 FAIL. The reviewer's `Invoke-Pester` run gave 25 passed, 1 skipped, 0 failed. The corpus is loaded from `$PSScriptRoot`, and `$caseList` is built outside `BeforeAll`. |
| AC-12 | PASS | `v2/evidence/regression-testing/phase4-pester-mutation-demonstration.2026-09-27T15-30.md`: the control gives `FailedCount=0`; each of the four flips gives `FailedCount=2` with the flipped case named. The corpus is unchanged afterwards. |
| AC-13 | PASS | `test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset` and the Pester `Bundled configuration parity` test passed (reviewer runs). Both compute the subsets at test time from the two committed configurations. |
| AC-14 | PASS | A reviewer grep for `compute_cohorts`, `pcoh_`, `drift`, and `mutation_protocol` over both consumers returned no match. Every verdict assertion is on the `conflicts` or `Test-BlastRadiusConflict` result. |
| AC-15 | PASS | `v2/evidence/baseline/phase0-tolerance-detection.2026-09-27T14-54.md` records `TOLERANCE_BRANCH: NOT FOUND` with a positive control. Both consumers take the pre-authorized skip with a reason naming #722 (reviewer runs show the skip reason). `v2/evidence/regression-testing/phase5-tolerance-branch.2026-09-27T15-32.md` records the detection-level verdicts for all eight must-conflict cases. |
| AC-16 | PASS | `v2/evidence/qa-gates/final-loading-constraints.2026-09-27T15-55.md` records 0 forbidden constructs per file, with positive controls. The reviewer's independent grep returned no match (exit 1). |
| AC-17 | PASS | The diff contains only added files under `v2/` and three new paths. No v1 document, existing fixture, existing test, configuration, cohort or scheduling code, or TypeScript file is changed. Recorded in `v2/evidence/qa-gates/final-non-goals-scope-diff.2026-09-27T15-54.md`. |
| AC-18 | PASS | `v2/evidence/qa-gates/final-line-counts.2026-09-27T15-55.md`: 487 and 290 lines. Reviewer `wc -l` agrees. |
| AC-19 | PASS | Local black, ruff, and pyright are clean (evidence and reviewer runs). Repository-wide coverage is 92.97% line and 85.68% branch, with no exclusion or suppression added (`v2/evidence/qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md`, `v2/evidence/qa-gates/final-python-no-new-suppression.2026-09-27T15-41.md`). The only failure in the repository-wide pytest run is the issue #510 test, excused under the plan's revision 9 allowance. The reviewer reproduced that failure, confirmed the path is `.gitignore:68` hook state, and confirmed the branch changes no tracked `.claude` path. The verdict relies on that allowance for the local run. AC-21 is the unexcused CI confirmation. |
| AC-20 | PASS | Format: hash unchanged across three runs. Analyze: `PSSA_FINDINGS=0` (evidence, confirmed by a reviewer run with the repository settings). Test: 5488 total, 0 failed. Repository-wide line coverage 96.04% (reviewer parse of `artifacts/pester/powershell-coverage.xml`). |
| AC-21 | PENDING (UNVERIFIED) | No pull request exists yet. The CI result on the PR head cannot be observed before the PR is opened. Plan task P9-T5 owns this check. Not scored as FAIL and not blocking for this pre-PR review. |
| AC-22 | PENDING (UNVERIFIED) | No pull request exists yet, so there is no PR body to inspect. Plan task P9-T4 owns this. Not scored as FAIL and not blocking for this pre-PR review. |

## Summary

- 20 of 22 acceptance criteria are PASS. The reviewer verified each against evidence, and re-executed checks where execution was possible.
- 2 criteria (AC-21, AC-22) are pending because the pull request does not yet exist.
- No criterion is FAIL or PARTIAL.
- **Baseline comparison.** Relative to `beae3f02`, the branch adds regression coverage only. Production behaviour of the Python authority and the PowerShell port is unchanged, and both runtimes produce the corpus verdicts for all 17 cases.
- **Issue #452 gaps.** Gap 1 (separator-free root surfaces reachable from plan text) and gap 2 (a listed directory contends with a glob beneath it) are pinned in both directions and in both runtimes.
- **Feature drift.** None observed beyond the spec scope.
- **Blocking finding count:** 0.
- **Remediation inputs:** not required and not written.

## Acceptance Criteria Check-off

The reviewer evaluated AC-1 through AC-20 as PASS. All 20 were already checked `[x]` in `v2/spec.md` when the review started, so this review made no new check-off edit to `v2/spec.md`. AC-21 and AC-22 remain unchecked, as instructed and as required by the check-off protocol for criteria that are not yet verified.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md`
- Total AC items: 22
- Checked off (delivered): 20
- Remaining (unchecked): 2
- Items remaining:
  - AC-21: "All required CI checks are green on the pull request head commit, including the pytest job and the windows-latest Pester job."
  - AC-22: "The pull request body contains the literal text `Fixes #452`."

## Overall Feature-Audit Verdict

PASS for the pre-PR scope. Blocking finding count: 0. AC-21 and AC-22 are to be verified after the pull request is opened (plan tasks P9-T4 and P9-T5). The issue #510 test must pass unexcused in the "Code Quality & Tests" CI job for AC-21 to be checked off.
