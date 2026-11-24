# Feature Audit: Epic Child CI Opt-Out (#1233)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1233-epic-child-ci-opt-out/`
**Base Branch:** `main`
**Head Branch:** `feature/epic-child-ci-opt-out-1233`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/epic-child-ci-opt-out-1233` (commit `502309bcd2de1b549fec6c154c3eee33dd9e402e`; no pull request yet)
- **Merge base:** `c030729de4703f961ff27489d4890919f6e0587e` (the main sync `71fe3e9a5` moved it from `23458fade`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 17:38:51 UTC for head `502309bcd`) and `git diff c030729de..502309bcd` (170 files, 9902 insertions, 46 deletions)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1233-epic-child-ci-opt-out/evidence/**`, with `evidence/qa-gates/self-review.2026-11-24T17-25.md` as the cycle-1 executor self-review
  - Additional evidence: reviewer targeted Pester run (216 tests, 0 failures); reviewer three-runtime validator probe (nine variants); git blob comparison of all mirrors; merge-neutrality numstat comparison; `validate_evidence_locations.py --root .` (exit 0); `check_quality_tiers` (exit 0)
- **Feature folder used:** `.dev/active/1233-epic-child-ci-opt-out/`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative.
- **Scope note:** Full branch diff against `main`; the caller did not narrow scope. No full suite was run by the reviewer; results come from the executor's final and cycle-1 gates, the post-renumber targeted run, the reviewer's targeted run, and probes.

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
| 1 | S1 opt-out allow | PASS | Allow rows in both opt-out suites; reviewer targeted run 216 tests, 0 failures | launcher `pester -TestPath` (reviewer) | None. |
| 2 | S2 default unchanged | PASS | Default rows plus the new `OPT-ORD-PREDICATE-*` and `CLAUDE-OPT-ORD-PREDICATE-*` rows (case-variant `Child_CI` and `Epic_Mode` keys take the pre-change path with zero seam calls) | reviewer run; fail-before record | Case-variant keys now agree with the completion hooks and validators. |
| 3 | S3 base fallback | PASS | Base and pattern fallback rows, plus `OPT-ORD-FALLBACK-*` rows for case-variant `Epic_Context` and `Integration_Branch` | reviewer run | None. |
| 4 | S4 stage denies | PASS | Deny rows per stage, plus `OPT-ORD-L1-*` and `OPT-ORD-L2-*` rows for case-variant record keys | reviewer run; `fail-before-merge-gate-ordinal.2026-11-24T15-56.md` | None. |
| 5 | S5 `-GitRoot` | PASS | Unchanged since the initial review; `CLAUDE-OPT-GITROOT-ITEM` and `OPT-COUNT-GITROOT-*` rows pass | reviewer run | None. |
| 6 | S6 completion hooks | PASS | `enforce-completion-helpers.OrdinalKeys.Tests.ps1` pins the ordinal reads; `Get-CompletionLocalQcGateMissing` treats `null` as missing | reviewer run (`OrdinalKeys` and helper suites) | None. |
| 7 | S7 three validators | PARTIAL | Corpus (23 fixtures) passes in all three runtimes and F1 is closed, but a reviewer probe shows TypeScript returning no error for `null` `evidence_path` and `verified_at`, where Python and PowerShell report the missing-fields string | reviewer probe of `validateCompletionGateEvidence`, `validate_completion_gate_evidence`, `Get-OrchestratorStateCompletionCiGateError` | Code review F2; reverted to unchecked in `spec.md`. |
| 8 | S8 identical strings | PASS | The five strings are identical text in the three implementations, and each suite asserts the same `expected_errors` from the shared corpus | inspection; R1 selections | The emission gap is tracked under S7. |
| 9 | S9 Python and TypeScript scope | PASS | No `.py` added; no Python or TypeScript production change in cycle 1; module 146/146 lines and 28/28 branches | `r1-contract-check.2026-11-24T17-22.md` | None. |
| 10 | S10 orchestrate skills | PASS | Unchanged since the initial review; main-sync hunks identical (merge neutrality) | numstat comparison | None. |
| 11 | S11 epic skills and template | PASS | Unchanged since the initial review; contract suite passed post-renumber | `post-sync-renumber-check.2026-11-24T17-38.md` | None. |
| 12 | S12 rule section | PASS | Section present; names ledger `0015`; generated rule and bundle copy identical to the source output | generator `-Check` no drift | None. |
| 13 | S13 brief in four locations | PASS | Four copies identical after the main sync | `post-sync-renumber-check.2026-11-24T17-38.md` (cmp) | None. |
| 14 | S14 frozen-surface re-baseline | PASS | Digest and paragraph unchanged since the initial review | `git diff` of `parallel_orchestrator_surface_expectations.py` | None. |
| 15 | S15 mirrors | PASS | Helper blob `551012393` and completion-helper blob `2573b573a` in four locations each; every changed bundle copy equals its source | `git rev-parse HEAD:<path>` per copy | None. |
| 16 | S16 generators | PASS | `-Check` no drift and Codex `--check` exit 0 (R1); `-Check` no drift post-renumber | `r1-contract-check.2026-11-24T17-22.md`; `post-sync-renumber-check.2026-11-24T17-38.md` | None. |
| 17 | S17 ledger | PASS | Entry `0015-epic-child-ci-opt-out.md` with `reduction: 0015`, README row `0015`, revert blocks current; chain and ledger suites pass on the committed tree | `post-sync-renumber-check.2026-11-24T17-38.md` | The F2 fix updates the entry if it edits a recorded region. |
| 18 | S18 size and protected files | PASS | Largest covered file 689 logical lines; `ci.yml`, both review guards, and `.claude/lib/docs` not in the diff | reviewer logical line count | None. |
| 19 | S19 toolchain and PR `CI` | UNVERIFIED | Local loops clean; no pull request exists, so the pull request's own `CI` run has not happened | `gh run list` returns no run for the branch | Pending CI; checked off by the item orchestrator at S9. |
| 20 | U1 kickoff | PASS | See S11 | see row 11 | None. |
| 21 | U2 allow | PASS | See S1 | see row 1 | None. |
| 22 | U3 denies | PASS | See S4 | see row 4 | None. |
| 23 | U4 fallback | PASS | See S3 | see row 3 | None. |
| 24 | U5 S9 procedure | PASS | See S10 | see row 10 | None. |
| 25 | U6 completion hooks | PASS | See S6 | see row 6 | None. |
| 26 | U7 three validators | PARTIAL | See S7 | see row 7 | Code review F2; reverted to unchecked in `user-story.md`. |
| 27 | U8 integration PR | PASS | Branch 2 of both gates unchanged | `git diff` of both gates | None. |
| 28 | U9 default epics | PASS | See S2 and S6 | see rows 2, 6 | None. |
| 29 | U10 ledger | PASS | See S17 | see row 17 | None. |

---

## Summary

**Overall Feature Readiness:** PARTIAL

**Criteria summary:**
- **PASS:** 26 criteria
- **PARTIAL:** 2 criteria
- **UNVERIFIED:** 1 criterion
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F2: the TypeScript completion validator treats a JSON `null` local-QC field as present, so it accepts an opted-out checkpoint that the Python and PowerShell validators reject (S7, U7).
2. S19 is pending the pull request's own `CI` run, which cannot exist before the pull request is opened.

**Recommended follow-up verification steps:**

1. After the F2 fix, run the three corpus suites with the new null-field fixtures, the TypeScript completion tests, and the ledger suites if a recorded region moves; then re-check S7 and U7.
2. At S9, confirm the pull request's `CI` run is green at the final head and check off S19.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `.dev/active/1233-epic-child-ci-opt-out/spec.md`, `.dev/active/1233-epic-child-ci-opt-out/user-story.md`
- Total AC items: 29
- Checked off (delivered): 26
- Remaining (unchecked): 3
- Items remaining: S7 (three validators accept and emit each string for its failing condition), S19 (toolchain loop and the pull request's own `CI` run), U7 (three validators accept and report identical strings per failing condition)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1233-epic-child-ci-opt-out/spec.md` | 19 | 17 | 2 | S7 reverted from checked to unchecked by this review (PARTIAL, F2); S19 left unchecked (pending CI) |
| `.dev/active/1233-epic-child-ci-opt-out/user-story.md` | 10 | 9 | 1 | U7 reverted from checked to unchecked by this review (PARTIAL, F2) |

Source-file changes made by this review: the executor checked S7 and U7 in `a1608a009`; both were reverted to `- [ ]` because the reviewer probe shows a PARTIAL result. Every criterion evaluated as PASS was already checked. The changes are uncommitted in the item worktree for the orchestrator to commit with the review records.
