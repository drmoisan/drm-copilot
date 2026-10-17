# Feature Audit: CI change-scope skip for evidence-only commits (#962)

---

**Audit Date:** 2026-10-17
**Feature Folder:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`
**Base Branch:** `origin/main`
**Head Branch:** `bug/ci-skip-evidence-only-commits-962`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1 (supersedes `feature-audit.2026-10-17T00-43.md`)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `b8fcd77905a51284cfbca54226a2da2a7916a836`; `git ls-remote` shows `main` unchanged)
- **Head branch/commit:** `bug/ci-skip-evidence-only-commits-962` (commit `8be7c95da5af05f6a9464a776469a380b400c0e2`; the remote branch head is the same commit)
- **Merge base:** `b8fcd77905a51284cfbca54226a2da2a7916a836`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-17 02:05:18 UTC for head `8be7c95da`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/**` (108 files)
  - CI: run 38992247041 (`workflow_dispatch`, head `8be7c95da`, 23 of 23 jobs `success`), job logs and the downloaded `poshqc-test-results` and `shell-coverage` artifacts; base-commit run 38982032960 for baseline coverage
- **Feature folder used:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the sole acceptance-criteria source; no `user-story.md` applies.
- **Scope note:** The audit covers the full branch diff against the merge base. No PR exists yet. AC-32 to AC-34 require `pull_request` runs and cannot be verified by a `workflow_dispatch` run. AC-36 to AC-38 name the first full PR run as their verification run. All six are CI-dependent criteria owned by the item's orchestrator at S9 and are evaluated as pending CI; supporting evidence from run 38992247041 is recorded below.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` — only source (`## Acceptance Criteria`, lines 318-454)

### Acceptance criteria

The lead sentence of each criterion is copied from `spec.md`; sub-bullets are in the source at the cited lines.

1. AC-1: Event gate. (line 320)
2. AC-2: Fork gate. (line 321)
3. AC-3: Run-list failure. (line 322)
4. AC-4: Job-list failure. (line 323)
5. AC-5: Candidate selection. (line 324)
6. AC-6: Full-run marker. (line 325)
7. AC-7: Ancestry. (lines 326-331)
8. AC-8: Diff invocation. (line 332)
9. AC-9: Empty diff. (line 333)
10. AC-10: Mixed diff. (line 334)
11. AC-11: Docs-only diff. (lines 335-340)
12. AC-12: Allowlist positive cases. (line 341)
13. AC-13: Allowlist negative cases. (lines 342-352)
14. AC-14: Invalid config. (lines 353-357)
15. AC-15: Committed config. (lines 358-364)
16. AC-16: Unexpected exception. (line 365)
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
36. AC-36 (D14-b): Security scan runs with a working export. (line 452; text amended by remediation decision RPD-3)
37. AC-37 (D14-c): Recursive bats discovery. (line 453)
38. AC-38 (D14-d): Bash coverage threshold. (line 454)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Event gate | PASS | Three named rows `(AC-1)` and pure-function rows; CI Pester shards 0 failures; run 38992247041 logged `code=true reason=EVENT_NOT_PULL_REQUEST` for `workflow_dispatch` | junit inspection; `gh run view --job 117276956540 --log` | Runtime behaviour matches the unit tests. |
| 2 | AC-2 Fork gate | PASS | Named row `(AC-2)` | junit inspection | |
| 3 | AC-3 Run-list failure | PASS | Two named rows | junit inspection | |
| 4 | AC-4 Job-list failure | PASS | Named row `(AC-4)` | junit inspection | Unparseable-jobs branch untested (code-review CR-3); not required by AC-4. |
| 5 | AC-5 Candidate selection | PASS | Pure rows and entry row `(AC-5)` | junit inspection | |
| 6 | AC-6 Full-run marker | PASS | Pure marker rows; entry rows | junit inspection | |
| 7 | AC-7 Ancestry | PASS | Three named rows | junit inspection | |
| 8 | AC-8 Diff invocation | PASS | Argument-set row and two failure rows | junit inspection; diff inspection | |
| 9 | AC-9 Empty diff | PASS | Pure and entry rows | junit inspection | |
| 10 | AC-10 Mixed diff | PASS | Entry row `(AC-10)` | junit inspection | |
| 11 | AC-11 Docs-only diff | PASS | Entry row capturing Output, Log, and Summary; default-writer rows | junit inspection | |
| 12 | AC-12 Allowlist positives | PASS | Pure rows per prefix, extension, and `RUN.MD` | junit inspection | |
| 13 | AC-13 Allowlist negatives | PASS | Pure rows for each listed negative | junit inspection | |
| 14 | AC-14 Invalid config | PASS | Parser throw rows; entry row `(AC-14)` | junit inspection | |
| 15 | AC-15 Committed config | PASS | `config/ci-docs-only-paths.json` matches D3; 23 contract tests | `git diff b8fcd779..HEAD -- config/`; junit | |
| 16 | AC-16 Unexpected exception | PASS | Entry rows for a throwing invoker and blank `HEAD_SHA` | junit inspection | |
| 17 | AC-17 Structure | PASS | Module has no I/O; seams and dot-source guard; test locations; largest file 411 lines | `wc -l`; `evidence/qa-gates/final-structure.2026-10-17T00-21.md` | |
| 18 | AC-18 `ci.yml` decision jobs | PASS | `ci.yml` diff; `CiChangeScopeWorkflow.Tests.ps1` 39 rows pass locally and in CI; `Change scope` and `CI full run` jobs `success` in run 38992247041 | diff inspection; `rem1-pester-workflows.2026-10-17T01-37.md` | |
| 19 | AC-19 `ci.yml` callers | PASS | As row 18 | as row 18 | |
| 20 | AC-20 Reusable-workflow gating | PASS | As row 18; every heavy job ran and passed under `run-heavy: true` | as row 18 | |
| 21 | AC-21 `_poshqc.yml` gating | PASS | Sharded shape gated; aggregator `poshqc / PowerShell QC` `success` | as row 18 | |
| 22 | AC-22 Unchanged surfaces | PASS | `git diff --name-status b8fcd779..HEAD` lists none of the protected paths; the remediation touched only `_security-scan.yml`, `README.md`, and the W18 test file | `git diff --name-only 0f98da84e..HEAD` | |
| 23 | AC-23 Regression test fails first | PASS | `expect-fail-new-suites.2026-10-16T23-42.md` and `p4-workflow-suite-pass.2026-10-17T00-12.md` | evidence inspection | The W18 replacement has its own fail-before (`rem1-w18-expect-fail.2026-10-17T01-33.md`) and pass-after (`rem1-w18-pass.2026-10-17T01-34.md`). |
| 24 | AC-24 Workflow README | PASS | Appended change-scope section unchanged; `rem1-readme.2026-10-17T01-39.md` (`README-PREFIX-IDENTICAL: True`, `README-TOKENS-MISSING: 0`) | evidence inspection | |
| 25 | AC-25 actionlint | PASS | `final-actionlint.2026-10-17T00-15.md` and `rem1-actionlint.2026-10-17T01-37.md`: 0 findings | evidence inspection | |
| 26 | AC-26 PowerShell toolchain | PASS | Format drift 0; PSSA-TOTAL 0; Pester 0 failures (local and CI) | evidence inspection; CI shards | |
| 27 | AC-27 Coverage (D8) | PASS | `CiChangeScope.psm1` 121/130 = 93.08%; `Invoke-CiChangeScope.ps1` 78/88 = 88.64%, identical in the CI merged XML | `awk` over the CI `powershell-coverage.xml` | Repo-wide PowerShell 92.15% (policy audit). |
| 28 | AC-28 CI-gate tooling unchanged | PASS | Parser, mirror, and skill files absent from the diff; `Invoke-CiGateParser.Tests.ps1` passes | `git diff --name-status`; junit | |
| 29 | AC-29 Tier classification | PASS | `scripts/ci` T4 entry; `final-quality-tiers.2026-10-17T00-19.md` exit 0 | diff inspection | |
| 30 | AC-30 Dependency composition | PASS | Dependency-state and reintegration evidence; `origin/main` is an ancestor of HEAD; remediation push was fast-forward (`commit-remediation-1.2026-10-17T01-40.md`) | `git ls-remote`; evidence inspection | |
| 31 | AC-31 Evidence location | PASS | All 108 evidence files under `evidence/<kind>/`; validator exit 0 | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | |
| 32 | AC-32 First implementation push runs full CI | UNVERIFIED | No PR exists, so no `pull_request` run exists. Supporting: run 38992247041 (`workflow_dispatch`) concluded `success` with `CI full run` and every heavy job `success` | `gh run view 38992247041 --json jobs` | Pending CI; S9-owned. The criterion requires the PR run and a `NO_FULL_GREEN_RUN` or `NON_ALLOWLISTED_PATH` reason, which a `workflow_dispatch` run cannot produce. |
| 33 | AC-33 Docs-only evidence commit skips heavy steps | UNVERIFIED | Requires a PR run on a docs-only commit after a full green PR run | none possible before the PR | Pending CI; S9-owned. |
| 34 | AC-34 Code change after a skip runs full CI | UNVERIFIED | Requires a PR run after the AC-33 run | none possible before the PR | Pending CI; S9-owned. |
| 35 | AC-35 Workflow README counts | PASS | README diff; `final-readme.2026-10-17T00-21.md`; `rem1-readme.2026-10-17T01-39.md` confirms the remediation did not change the counted lines | evidence inspection | |
| 36 | AC-36 Security scan runs with a working export | UNVERIFIED | Static part verified: export-plugin step directly before the scan step, `shell: bash`, `continue-on-error: true` as the only such line in the job (W18 passes in CI). Supporting runtime evidence from run 38992247041: `poetry-plugin-export (1.10.1)` installed, `Found and scanned 78 packages`, `101 vulnerabilities reported`, job `success`. The 101 findings are recorded in `evidence/other/security-scan-findings.2026-10-17T01-18.md` | `gh run view --job 117277015648 --log` | Pending CI; S9-owned. The criterion names a full PR run after the remediation cycle; the dispatch run shows the condition is expected to hold. |
| 37 | AC-37 Recursive bats discovery | UNVERIFIED | Supporting: in job 117277015644, `ok 712 test passes --recursive to bats for each test directory`, `ok 713 test --coverage passes --recursive to bats under kcov`; plan `1..733`, equal to the 733 `@test` lines under `tests/shell/` at the head | `gh run view --job 117277015644 --log`; `grep -c '^@test'` over `tests/shell/**/*.bats` | Pending CI; S9-owned (named verification run is the PR run). |
| 38 | AC-38 Bash coverage threshold | UNVERIFIED | Supporting: six named threshold tests `ok 714` to `ok 719`; log line `Bash coverage 95.2% meets the minimum line coverage of 85%.`; shell files 432, 106, 265 lines | as row 37; `wc -l` | Pending CI; S9-owned (named verification run is the first full PR run). |

---

## Summary

**Overall Feature Readiness:** READY FOR PR (CI-dependent criteria pending S9)

**Criteria summary:**
- **PASS:** 32 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 6 criteria (AC-32, AC-33, AC-34, AC-36, AC-37, AC-38; all CI-dependent and S9-owned)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-32 to AC-34 need `pull_request` runs on the PR, which S8 creates after this review.
2. AC-33 depends on GitHub Actions behaviour (all-steps-skipped jobs reporting `success` under matrix-expanded names; check-run names matching the ruleset) that only the PR run can show.
3. AC-36 to AC-38 name the first full PR run as their verification run; run 38992247041 shows each condition holding on the same head.

**Recommended follow-up verification steps:**

1. Open the PR and, at S9, execute the `spec.md` `## Proof Procedure` P0 to P3, recording outputs under `evidence/regression-testing/`.
2. Check off AC-32 to AC-34 and AC-36 to AC-38 as each is verified on the PR runs, then re-run the CI green gate on the final head.

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
- Items remaining: AC-32 (CI-AC-1) First implementation push runs full CI; AC-33 (CI-AC-2) Docs-only evidence commit skips heavy steps; AC-34 (CI-AC-3) Code change after a skip runs full CI; AC-36 (D14-b) Security scan runs with a working export; AC-37 (D14-c) Recursive bats discovery; AC-38 (D14-d) Bash coverage threshold.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` | 38 | 32 | 6 | Checkbox-backed; the six unchecked items are CI-dependent and owned by the orchestrator at S9 |

No source-file checkbox change was made by this review. Every criterion evaluated PASS (AC-1 to AC-31 and AC-35) was already checked in `spec.md`, and this review agrees with each check-off. The six UNVERIFIED criteria remain unchecked and are not counted as review findings, because their verification requires the PR that S8 creates after this review.
