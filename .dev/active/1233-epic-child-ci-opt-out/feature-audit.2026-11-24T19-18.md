# Feature Audit: Epic Child CI Opt-Out (#1233)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1233-epic-child-ci-opt-out/`
**Base Branch:** `main`
**Head Branch:** `feature/epic-child-ci-opt-out-1233`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 2

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/epic-child-ci-opt-out-1233` (commit `9ad75122a69296f69938e5fb64d80a35ede5eb38`, pushed; no pull request yet)
- **Merge base:** `11b2c598652eb6cf6c3a3ccb1e7ea4340dda57d2` (equal to `origin/main`; the main sync `4fadc01eb` moved it from `c030729de`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 19:11:36 UTC for head `9ad75122a`) and `git diff 11b2c5986..9ad75122a` (200 files, 11246 insertions, 48 deletions)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1233-epic-child-ci-opt-out/evidence/**`, with `evidence/qa-gates/self-review.2026-11-24T19-04.md` as the cycle-2 executor self-review
  - Additional evidence: reviewer three-runtime probe (16 variants); mutant check of the `null` clause over the 25-fixture corpus; ledger revert-block replay; git blob comparison of the rule copies; merge-neutrality numstat comparison; reviewer targeted Jest (42 tests) and pytest (35 tests) runs; `validate_evidence_locations.py --root .` (exit 0)
- **Feature folder used:** `.dev/active/1233-epic-child-ci-opt-out/`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative. The checkboxes under `## Definition of Done` and `## Seeded Test Conditions (from potential)` in `spec.md` are not acceptance criteria and are not counted.
- **Scope note:** Full branch diff against `main`; the caller did not narrow scope. No full suite was run by the reviewer.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1233-epic-child-ci-opt-out/spec.md` — primary (19 criteria, S1 to S19)
- `.dev/active/1233-epic-child-ci-opt-out/user-story.md` — secondary (10 criteria, U1 to U10)

### From spec.md

1. S1: opt-out allow on Claude and Codex without a child `CI` run.
2. S2: default, `per_child`, case variant, non-string, and non-boolean `epic_mode` behave as today; new seam never called.
3. S3: main base, other base, missing or malformed integration branch fall back to per-child CI.
4. S4: every stage B, R, L1, L2, L3 failure denies with the local-QC prefix and does not fall through.
5. S5: Claude passes `-GitRoot` as the item worktree; default is `GhRoot`.
6. S6: completion-consistency hooks accept the opted-out DONE only with a valid `local_qc_gate`; default deny text unchanged.
7. S7: the three validators accept the opted-out checkpoint, emit each listed string for its failing condition in order, and report `ci_gate` errors without the opt-out.
8. S8: validator error strings byte-identical across the three runtimes.
9. S9: Python change confined and inline; TypeScript module meets its own threshold.
10. S10: orchestrate skills state the S9 opt-out procedure and schema and PR-gate additions.
11. S11: epic-orchestrate, epic-run, epic-plan skills and the template state the key, validation, copy, kickoff line, and integration `CI`.
12. S12: generated rule contains section `epic-child-ci-opt-out-issue-1233` with the disclosure.
13. S13: execution-environment brief identical in four locations with the four updates.
14. S14: frozen-surface digest re-baselined with the `# RE-BASELINED by issue #1233` paragraph.
15. S15: Claude and Codex helper copies identical; bundle copies match.
16. S16: generator `-Check` and Codex generator `--check` pass.
17. S17: ledger entry and README row with prior text, revert steps, signals, and disclosures.
18. S18: no file above the hard limit; protected files unchanged.
19. S19: toolchain loop passes and the pull request's own `CI` run is green.

### From user-story.md

20. U1: kickoff carries `child_ci`, the separate prompt line, and the unchanged kickoff literal; invalid value rejected.
21. U2: opted-out child merge allowed on Claude and Codex without `CI`.
22. U3: failing checks deny with the local-QC prefix naming the stage.
23. U4: non-integration or malformed bases fall back to per-child CI.
24. U5: S9 procedure issues no dispatch, writes and commits the evidence, records the keys.
25. U6: completion hooks accept only with a valid `local_qc_gate`; default text unchanged.
26. U7: three validators accept, report identical strings per failing condition, and report `ci_gate` errors without the opt-out.
27. U8: integration pull request still requires green `CI`; branch 2 unchanged.
28. U9: epics without the key behave as today.
29. U10: ledger entry records prior text, revert steps, residual run, and disclosure.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 opt-out allow | PASS | Unchanged since cycle 1; merge-gate suites in the cycle-1 reviewer run and no gate change since | numstat comparison | None. |
| 2 | S2 default unchanged | PASS | Unchanged since cycle 1 | numstat comparison | None. |
| 3 | S3 base fallback | PASS | Unchanged since cycle 1 | numstat comparison | None. |
| 4 | S4 stage denies | PASS | Unchanged since cycle 1 | numstat comparison | None. |
| 5 | S5 `-GitRoot` | PASS | Unchanged since cycle 1 | numstat comparison | None. |
| 6 | S6 completion hooks | PASS | Unchanged since cycle 1; helper treats `null` as missing | numstat comparison | None. |
| 7 | S7 three validators | PASS | Corpus of 25 fixtures passes in the three runtimes (RC2 selections: Jest 801, Pester 917, pytest 226; reviewer Jest 42, pytest 35); reviewer probe of 16 variants identical across runtimes; null-clause mutant fails exactly the two new fixtures | reviewer probe; reviewer launcher runs; `fail-before-f2.2026-11-24T18-39.md` | F2 closed; checked off by the executor in `3abe730f4`. |
| 8 | S8 identical strings | PASS | Shared corpus `expected_errors` asserted by the three suites; probe outputs identical | reviewer probe | None. |
| 9 | S9 Python and TypeScript scope | PASS | No `.py` added; no Python change in cycle 2; new module 146/146 lines and 28/28 branches | `rc2-contract-check.2026-11-24T19-03.md`; `rc2-final-jest-selection.2026-11-24T18-58.md` | None. |
| 10 | S10 orchestrate skills | PASS | Unchanged since cycle 1; main-sync hunks identical | numstat comparison | None. |
| 11 | S11 epic skills and template | PASS | Unchanged since cycle 1; contract suite passes post-sync | `post-sync-check.2026-11-24T19-10.md` | None. |
| 12 | S12 rule section | PASS | Section present with the disclosure and the new known-limitation paragraph; generated rule and bundle copy share blob `7405bfaed` | `git rev-parse HEAD:<path>`; generator `-Check` | None. |
| 13 | S13 brief in four locations | PASS | Four copies identical after the main sync | `post-sync-check.2026-11-24T19-10.md` (cmp) | None. |
| 14 | S14 frozen-surface re-baseline | PASS | Unchanged since cycle 1 | numstat comparison | None. |
| 15 | S15 mirrors | PASS | No helper change in cycle 2; cycle-1 blob comparison stands | numstat comparison | None. |
| 16 | S16 generators | PASS | `-Check` no drift and Codex `--check` exit 0 (RC2); `-Check` no drift post-sync | `rc2-contract-check.2026-11-24T19-03.md`; `post-sync-check.2026-11-24T19-10.md` | None. |
| 17 | S17 ledger | PASS | Entry `0015` lists the cycle-2 files and blocks; reviewer replay restores the merge-base bytes; chain and ledger suites pass on the committed tree | reviewer replay; `post-sync-check.2026-11-24T19-10.md` | Merge-commit line back-filled at the records stage. |
| 18 | S18 size and protected files | PASS | Largest covered file 689 logical lines; `ci.yml`, both review guards, and `.claude/lib/docs` not in the diff | reviewer logical line count | None. |
| 19 | S19 toolchain and PR `CI` | PENDING-CI | Local loops clean; no pull request exists, so the pull request's own `CI` run has not happened | `gh run list` returns no run for the branch | Checked off by the item orchestrator at S9. |
| 20 | U1 kickoff | PASS | See S11 | see row 11 | None. |
| 21 | U2 allow | PASS | See S1 | see row 1 | None. |
| 22 | U3 denies | PASS | See S4 | see row 4 | None. |
| 23 | U4 fallback | PASS | See S3 | see row 3 | None. |
| 24 | U5 S9 procedure | PASS | See S10 | see row 10 | None. |
| 25 | U6 completion hooks | PASS | See S6 | see row 6 | None. |
| 26 | U7 three validators | PASS | See S7 | see row 7 | F2 closed; checked off by the executor in `3abe730f4`. |
| 27 | U8 integration PR | PASS | Branch 2 of both gates unchanged | numstat comparison | None. |
| 28 | U9 default epics | PASS | See S2 and S6 | see rows 2, 6 | None. |
| 29 | U10 ledger | PASS | See S17 | see row 17 | None. |

---

## Summary

**Overall Feature Readiness:** PASS (one criterion pending CI)

**Criteria summary:**
- **PASS:** 28 criteria
- **PARTIAL:** 0 criteria
- **PENDING-CI:** 1 criterion
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None blocking. S19 is pending the pull request's own `CI` run, which cannot exist before the pull request is opened.

**Recommended follow-up verification steps:**

1. At S9, confirm the pull request's `CI` run is green at the final head and check off S19.
2. At the records stage, back-fill the merge commit in ledger `0015`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `.dev/active/1233-epic-child-ci-opt-out/spec.md`, `.dev/active/1233-epic-child-ci-opt-out/user-story.md`
- Total AC items: 29
- Checked off (delivered): 28
- Remaining (unchecked): 1
- Items remaining: S19 (toolchain loop and the pull request's own `CI` run)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1233-epic-child-ci-opt-out/spec.md` | 19 | 18 | 1 | S19 left unchecked (pending CI, orchestrator-owned at S9) |
| `.dev/active/1233-epic-child-ci-opt-out/user-story.md` | 10 | 10 | 0 | None |

Source-file changes made by this review: none. Every criterion evaluated as PASS was already checked; the executor checked S7 and U7 in `3abe730f4`, and this review confirms them.
