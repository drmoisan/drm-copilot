# Feature Audit: CI change-scope skip for evidence-only commits (#962)

---

**Audit Date:** 2026-10-17
**Feature Folder:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`
**Base Branch:** `origin/main`
**Head Branch:** `bug/ci-skip-evidence-only-commits-962`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `b8fcd77905a51284cfbca54226a2da2a7916a836`)
- **Head branch/commit:** `bug/ci-skip-evidence-only-commits-962` (commit `0f98da84e5474e9c09892b33c2fb2995b763457c`; the remote branch head is the same commit)
- **Merge base:** `b8fcd77905a51284cfbca54226a2da2a7916a836`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-17 00:35:18 UTC for head `0f98da84`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/**` (75 files)
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, and direct inspection of the branch diff by this review
- **Feature folder used:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the sole acceptance-criteria source and no `user-story.md` applies. `spec.md` line 9 states the same.
- **Scope note:** The audit covers the full branch diff against the merge base. No PR exists and no CI run exists for the branch (`gh pr list` and `gh run list` both returned `[]`), so every CI-dependent criterion is evaluated as pending CI.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` — only source (`## Acceptance Criteria`, lines 318-454)

### Acceptance criteria

The lead sentence of each criterion is copied from `spec.md`; sub-bullets are in the source at the cited lines.

1. AC-1: Event gate. For each `EVENT_NAME` of `merge_group`, `push` and `workflow_dispatch`, `Invoke-CiChangeScope.ps1` writes `code=true` with reason `EVENT_NOT_PULL_REQUEST`, and the injected `-GhInvoker` and `-GitInvoker` are each invoked zero times. (line 320)
2. AC-2: Fork gate. For a `pull_request` event whose `HEAD_REPO` differs from `REPOSITORY`, the entry script writes `code=true` with reason `FORK_PULL_REQUEST`, and neither invoker is called. (line 321)
3. AC-3: Run-list failure. Non-zero exit or invalid JSON gives `code=true` with reason `RUN_LIST_FAILED`. (line 322)
4. AC-4: Job-list failure. A failed jobs call gives `code=true` with reason `JOB_LIST_FAILED`. (line 323)
5. AC-5: Candidate selection by `Select-CiGreenBaseCandidates`. (line 324)
6. AC-6: Full-run marker (`Test-CiFullRunMarker`, `NO_FULL_GREEN_RUN`, older-candidate selection). (line 325)
7. AC-7: Ancestry (`BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR`, `ANCESTRY_CHECK_FAILED`). (lines 326-331)
8. AC-8: Diff invocation argument set and `DIFF_FAILED`. (line 332)
9. AC-9: Empty diff gives `EMPTY_DIFF`. (line 333)
10. AC-10: Mixed diff gives `NON_ALLOWLISTED_PATH: <first non-allowlisted path>`. (line 334)
11. AC-11: Docs-only diff writes `code=false`, logs `DOCS_ONLY_SINCE_<base sha>`, and writes the summary. (lines 335-340)
12. AC-12: Allowlist positive cases. (line 341)
13. AC-13: Allowlist negative cases. (lines 342-352)
14. AC-14: Invalid config. (lines 353-357)
15. AC-15: Committed config. (lines 358-364)
16. AC-16: Unexpected exception gives `UNEXPECTED_ERROR`, a warning, and exit 0. (line 365)
17. AC-17: Structure. (lines 366-372)
18. AC-18: `ci.yml` decision jobs. (lines 373-379)
19. AC-19: `ci.yml` callers. (lines 380-383)
20. AC-20: Reusable-workflow gating. (lines 384-387)
21. AC-21: `_poshqc.yml` gating in the shape present on the branch head. (lines 388-391)
22. AC-22: Unchanged surfaces. (lines 392-403)
23. AC-23: Regression test fails first. (line 404)
24. AC-24: Workflow README (D9). (lines 405-412)
25. AC-25: actionlint. (line 413)
26. AC-26: PowerShell toolchain. (lines 414-417)
27. AC-27: Coverage (D8). (line 418)
28. AC-28: CI-gate tooling unchanged and verified (D4). (lines 419-421)
29. AC-29: Tier classification. (line 422)
30. AC-30: Dependency composition (D5). (lines 423-427)
31. AC-31: Evidence location. (line 428)
32. AC-32 (CI-AC-1): First implementation push runs full CI. (lines 429-435)
33. AC-33 (CI-AC-2): Docs-only evidence commit skips heavy steps. (lines 436-444)
34. AC-34 (CI-AC-3): Code change after a skip runs full CI. (lines 445-450)
35. AC-35 (D14-a): Workflow README counts. (line 451)
36. AC-36 (D14-b): Security scan is blocking. (line 452)
37. AC-37 (D14-c): Recursive bats discovery. (line 453)
38. AC-38 (D14-d): Bash coverage threshold. (line 454)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Event gate | PASS | `It 'writes code=true EVENT_NOT_PULL_REQUEST for <EventName> without calling either invoker (AC-1)'` (three rows); pure-function rows in `CiChangeScope.Tests.ps1`; junit 0 failures | `sh SCRATCH/tools/run-cr.sh cr-pester-list` (executor); junit inspection | Source line 185-188 gate runs before any invoker call. |
| 2 | AC-2 Fork gate | PASS | `It 'writes code=true FORK_PULL_REQUEST for a fork pull request without calling either invoker (AC-2)'` | as row 1 | |
| 3 | AC-3 Run-list failure | PASS | Two named rows (non-zero exit; invalid JSON) | as row 1 | |
| 4 | AC-4 Job-list failure | PASS | `It 'writes code=true JOB_LIST_FAILED when a jobs call fails (AC-4)'` | as row 1 | The unparseable-jobs-JSON branch (lines 157-158) is untested; not required by AC-4 (code-review CR-3). |
| 5 | AC-5 Candidate selection | PASS | Pure rows for current-run exclusion, foreign head repository, unsorted input; entry row `never uses the current run as the base (AC-5)` | as row 1 | |
| 6 | AC-6 Full-run marker | PASS | Pure marker rows; entry rows for skipped marker, empty run list, older qualifying run | as row 1 | |
| 7 | AC-7 Ancestry | PASS | Three named rows (`cat-file` fails; merge-base exit 1; exit 128) | as row 1 | |
| 8 | AC-8 Diff invocation | PASS | Argument-set row plus two failure rows; source line 221 passes all six flags and both SHAs | as row 1; diff inspection | |
| 9 | AC-9 Empty diff | PASS | Pure row and entry row `writes code=true EMPTY_DIFF for an empty diff (AC-9)` | as row 1 | |
| 10 | AC-10 Mixed diff | PASS | Entry row `writes code=true NON_ALLOWLISTED_PATH for a mixed diff (AC-10)` | as row 1 | |
| 11 | AC-11 Docs-only diff | PASS | Entry row capturing Output, Log, and Summary through `-OutputWriter`; default-writer rows for `GITHUB_OUTPUT` and `GITHUB_STEP_SUMMARY` | as row 1 | |
| 12 | AC-12 Allowlist positives | PASS | Pure rows per include prefix, per extension, and `RUN.MD` | as row 1 | |
| 13 | AC-13 Allowlist negatives | PASS | Pure rows for each listed negative | as row 1 | |
| 14 | AC-14 Invalid config | PASS | Parser throw rows for the four named forms; entry row `writes code=true UNEXPECTED_ERROR and a warning for an invalid config (AC-14)` | as row 1 | |
| 15 | AC-15 Committed config | PASS | `config/ci-docs-only-paths.json` matches D3 exactly (diff inspection); `CiDocsOnlyPathsConfig.Tests.ps1` 23 tests, 0 failures in junit | junit inspection; `git diff b8fcd779..HEAD -- config/` | |
| 16 | AC-16 Unexpected exception | PASS | Entry rows for a throwing invoker and a blank `HEAD_SHA`; Warning prefix row | as row 1 | |
| 17 | AC-17 Structure | PASS | Module has no `gh`/`git`/file/network call (inspection); seams and dot-source guard present; test files at the listed paths; hygiene grep returned no match; largest file 411 lines | `wc -l`; grep scan; `evidence/qa-gates/final-structure.2026-10-17T00-21.md` | |
| 18 | AC-18 `ci.yml` decision jobs | PASS | `ci.yml` diff shows `changes` (`Change scope`, permissions, outputs, checkout options, `id: scope`, `continue-on-error: true`) and `full-run-marker` with the exact `if:` | diff inspection; `CiChangeScopeWorkflow.Tests.ps1` 39 tests, 0 failures | |
| 19 | AC-19 `ci.yml` callers | PASS | Six callers carry `needs`, `if: ${{ !cancelled() }}`, `run-heavy`; two non-required callers gate on `code != 'false'`; `docs-validation` unchanged | as row 18 | |
| 20 | AC-20 Reusable-workflow gating | PASS | `run-heavy` declared under both triggers in six files; every step gated; combined conditions on the cache-miss, 3.13-only, and kcov cache-miss steps | as row 18 | |
| 21 | AC-21 `_poshqc.yml` gating | PASS | Sharded shape on the head: `poshqc-static`, `poshqc-shard`, `poshqc-linux-hooks` gated at job level; `poshqc` keeps `if: always()` and every step, including `Require the static and shard jobs to succeed`, is gated | as row 18 | |
| 22 | AC-22 Unchanged surfaces | PASS | `git diff --name-status b8fcd779..HEAD` lists none of the seven paths; the `ci.yml` diff starts inside `jobs:`, so the `on:` block is unchanged; the two existing workflow suites changed only in recorded assertions | `git diff --name-status b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD` | Base is the merge base, which equals `origin/main`. |
| 23 | AC-23 Regression test fails first | PASS | `evidence/regression-testing/expect-fail-new-suites.2026-10-16T23-42.md` (fail before) and `p4-workflow-suite-pass.2026-10-17T00-12.md` (pass after) | evidence inspection | |
| 24 | AC-24 Workflow README | PASS | Appended `## Change-Scope Decision (Issue #962)` section with reason codes, allowlist, fail-closed rules, `run-heavy`, and the 11-row table; Triggers section not in the diff | `git diff b8fcd779..HEAD -- .github/workflows/README.md` | |
| 25 | AC-25 actionlint | PASS | `evidence/qa-gates/final-actionlint.2026-10-17T00-15.md`: 0 findings for seven files | executor `cr-actionlint` | |
| 26 | AC-26 PowerShell toolchain | PASS | Format drift 0; PSSA-TOTAL 0; 255 passed, 0 failed in one pass | `final-format`, `final-pssa`, `final-pester-list` (2026-10-17T00-15) | |
| 27 | AC-27 Coverage (D8) | PASS | `CiChangeScope.psm1` 121/130 = 93.08%; `Invoke-CiChangeScope.ps1` 78/88 = 88.64%; re-parsed by this review | `awk` over `artifacts/pester/powershell-coverage.xml`; `final-coverage-files.2026-10-17T00-19.md` | Per-file only; the repo-wide figure is policy-audit finding B-2. |
| 28 | AC-28 CI-gate tooling unchanged | PASS | `Invoke-CiGateParser.Tests.ps1` 35 tests, 0 failures in junit; parser, mirror, and both skill files absent from the diff; the two named tests are listed in `final-pester-list.2026-10-17T00-15.md` | junit inspection; `git diff --name-status` | |
| 29 | AC-29 Tier classification | PASS | `quality-tiers.yml` entry `scripts/ci`, `T4`, rationale; `final-quality-tiers.2026-10-17T00-19.md` exit 0 | diff inspection | |
| 30 | AC-30 Dependency composition | PASS | `evidence/other/dependency-state.2026-10-16T23-21.md` and `2026-10-17T00-09.md`; merge commits `e07e235d5`, `4e82b3a3c`, `32350256b`; `evidence/other/reintegration.2026-10-17T00-09.md`; `origin/main` is an ancestor of HEAD | `git log --merges --oneline b8fcd779..HEAD`; `git merge-base --is-ancestor origin/main HEAD` (exit 0) | Absence of a force push is supported by the evidence and the linear merge history; it cannot be proven from the local repository alone. |
| 31 | AC-31 Evidence location | PASS | All evidence under `evidence/<kind>/`; validator exit 0 | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | |
| 32 | AC-32 First implementation push runs full CI | UNVERIFIED | No PR and no CI run exist for the branch | `gh run list --repo drmoisan/drm-copilot --branch bug/ci-skip-evidence-only-commits-962` returned `[]` | Pending CI; owned by the orchestrator at S9 per `acceptance-criteria-tracking`. |
| 33 | AC-33 Docs-only evidence commit skips heavy steps | UNVERIFIED | Requires a PR run on a docs-only commit after a full green run | as row 32 | Pending CI; S9-owned. Requires `pull_request` events, so a `workflow_dispatch` run cannot satisfy it. |
| 34 | AC-34 Code change after a skip runs full CI | UNVERIFIED | Requires a PR run after the AC-33 run | as row 32 | Pending CI; S9-owned. |
| 35 | AC-35 Workflow README counts | PASS | README diff: "nine reusable per-stage workflows", `_npm-audit-gate.yml` dispatch row, "The seven jobs it extracted from"; no other pre-existing line changed; `ci.yml` composes nine reusable workflows | `git diff b8fcd779..HEAD -- .github/workflows/README.md`; `final-readme.2026-10-17T00-21.md` | |
| 36 | AC-36 Security scan is blocking | UNVERIFIED | Static part verified: export-plugin step directly before the scan step, `shell: bash`, no `continue-on-error`, both gated; the AC-36 Pester row passes. The first full PR run's safety result does not exist yet | diff inspection; junit | Pending CI; S9-owned. Code-review CR-2 notes the unpinned deprecated `safety check` command. |
| 37 | AC-37 Recursive bats discovery | UNVERIFIED | Static part verified: `--recursive` in both invocations; the two named bats tests exist. The tests have not run, and the CI test-count comparison does not exist yet | diff inspection; `p5-shell-static.2026-10-17T00-00.md` | Pending CI; S9-owned. |
| 38 | AC-38 Bash coverage threshold | UNVERIFIED | Static part verified: `check_coverage_threshold` defined, called after the summary, default 85; six named bats tests exist; all shell files at most 432 lines. The CI log line does not exist yet | diff inspection; `wc -l` | Pending CI; S9-owned. Code-review CR-1 notes the silent pass on an absent report. |

---

## Summary

**Overall Feature Readiness:** BLOCKED (awaiting CI)

**Criteria summary:**
- **PASS:** 32 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 6 criteria (AC-32, AC-33, AC-34, AC-36, AC-37, AC-38; all CI-dependent and S9-owned)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. No CI run exists against the branch head, so the six CI-dependent criteria cannot be evaluated and the policy-audit `awaiting_ci` findings B-1 to B-4 remain open.
2. AC-33 depends on GitHub Actions behaviour (all-steps-skipped jobs reporting `success` under matrix-expanded names; check-run names matching ruleset 15241672) that the spec marks unverified until the PR runs.
3. AC-36 may enter its remediation path if the first blocking safety scan reports findings.

**Recommended follow-up verification steps:**

1. Dispatch `ci.yml` on the branch head (`gh workflow run ci.yml --repo drmoisan/drm-copilot --ref bug/ci-skip-evidence-only-commits-962`) or open the PR, and re-run the review once the run concludes, to close B-1 to B-4.
2. At S9, execute `spec.md` `## Proof Procedure` P0 to P3 on the PR and record the outputs under `evidence/regression-testing/`, then check off AC-32 to AC-34 and AC-36 to AC-38 as each is verified.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md`
- Total AC items: 38
- Checked off (delivered): 32
- Remaining (unchecked): 6
- Items remaining: AC-32 (CI-AC-1) First implementation push runs full CI; AC-33 (CI-AC-2) Docs-only evidence commit skips heavy steps; AC-34 (CI-AC-3) Code change after a skip runs full CI; AC-36 (D14-b) Security scan is blocking; AC-37 (D14-c) Recursive bats discovery; AC-38 (D14-d) Bash coverage threshold.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` | 38 | 32 | 6 | Checkbox-backed; the six unchecked items are CI-dependent and owned by the orchestrator at S9 |

No source-file checkbox change was made by this review. Every criterion evaluated PASS (AC-1 to AC-31 and AC-35) was already checked in `spec.md` by the executor, and the review's evaluation agrees with each of those check-offs. The six UNVERIFIED criteria remain unchecked.
