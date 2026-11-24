# Feature Audit: Epic Child CI Opt-Out (#1233)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1233-epic-child-ci-opt-out/`
**Base Branch:** `main`
**Head Branch:** `feature/epic-child-ci-opt-out-1233`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/epic-child-ci-opt-out-1233` (commit `0fc83af8b03b74deed2615238faa8c203df942dd`; no pull request yet)
- **Merge base:** `23458fade99f40e81b95ce86ed90805258479782`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 13:43:40 UTC for head `0fc83af8b`) and `git diff 23458fade..0fc83af8b` (136 files, 7931 insertions, 48 deletions)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1233-epic-child-ci-opt-out/evidence/**`, with `evidence/qa-gates/self-review.2026-11-24T13-11.md` as the executor self-review
  - Additional evidence: reviewer re-parse of `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`; reviewer root Jest coverage run (`evidence/qa-gates/review-jest-root.2026-11-24T14-19.md`); reviewer git blob comparison of all mirrors; `validate_evidence_locations.py --root .` (exit 0); `check_quality_tiers` (exit 0); reviewer cross-runtime probe of the completion validators
- **Feature folder used:** `.dev/active/1233-epic-child-ci-opt-out/`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative; the early-draft list in `issue.md` is not an AC source.
- **Scope note:** Full branch diff against `main`; the caller did not narrow scope. The reviewer did not run a full Pester or pytest suite (owner directive: full suites only at the baseline and final QC gates); results come from the executor's final gates and post-sync targeted runs, reviewer artifact parses, and targeted probes.

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
| 1 | S1 opt-out allow | PASS | Allow rows in `enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1:243` and `enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1:231`; helper returns `$null` detail after L3 | inspection; `final-qc-pester.2026-11-24T13-00.md`; `post-sync-check.2026-11-24T13-36.md` | None. |
| 2 | S2 default unchanged | PASS | Default rows (`:315` Claude, `:307` Codex) assert zero seam calls and the pre-change deny text; existing `ChildCi` suites unchanged on the branch | `git diff --stat` of both existing suites (empty) | None. |
| 3 | S3 base fallback | PASS | `Get-EpicMergeGateChildLocalQcResult` returns `Applies = $false` when the base differs or is `main`; predicate requires the integration-branch pattern; base and pattern fallback rows in both suites | inspection | None. |
| 4 | S4 stage denies | PASS | Deny rows `:257` and `:261` per stage; `OPT-ENTRY-DENY-NO-FALL-THROUGH`; prefix passed through by `Get-EpicMergeGateChildCiDecision` | inspection | None. |
| 5 | S5 `-GitRoot` | PASS | Claude gate line 392 passes `-GitRoot $childRoot` (covered); `CLAUDE-OPT-GITROOT-ITEM`, `OPT-COUNT-GITROOT-DEFAULT`, `OPT-COUNT-GITROOT-EXPLICIT` rows | reviewer parse of `artifacts/pester/powershell-coverage.xml` | None. |
| 6 | S6 completion hooks | PASS | `Test-CompletionChildCiIntegrationOnly` and `Get-CompletionLocalQcGateMissing` (ordinal name checks); extended rows in both completion suites and the helper suite | inspection; final Pester gate | None. |
| 7 | S7 three validators | PARTIAL | Corpus passes in all three runtimes, but a reviewer probe with case-variant keys (`Conclusion`, `Head_Sha`, `Remediation_Loop`) returned 3 Python errors and 0 PowerShell errors | reviewer probe of `validate_completion_gate_evidence` and `Get-OrchestratorStateCompletionCiGateError` | Code review F1; unchecked in `spec.md`. |
| 8 | S8 identical strings | PASS | The five strings are identical text in the three implementations, and each suite asserts the same `expected_errors` from the shared corpus | inspection of the three implementations | The emission gap is tracked under S7, not here. |
| 9 | S9 Python and TypeScript scope | PASS | Python diff confined to `validate_orchestrator_state.py`, no new `.py` file, both protected lines unchanged; `orchestrator-state-child-ci.ts` 146/146 lines and 28/28 branches with its own threshold entry | `git diff --diff-filter=A --name-only` (no `.py`); reviewer root Jest run | None. |
| 10 | S10 orchestrate skills | PASS | S9 paragraph, schema paragraph, and PR Creation Gate condition 6 note in `.claude/skills/orchestrate/SKILL.md` and the Codex counterpart; `child-ci-opt-out-skill-contract.Tests.ps1` | `git diff` of both skills | None. |
| 11 | S11 epic skills and template | PASS | Manifest key, validation, checkpoint copy, kickoff line, integration `CI` statements; template comment; contract suite and `early-start-skill-contract.Tests.ps1` passed in the final gate | `git diff` of the skills and template | None. |
| 12 | S12 rule section | PASS | Section added through the harness source; generated rule identical to its bundle copy | generator `-Check` (post-sync record); blob comparison | None. |
| 13 | S13 brief in four locations | PASS | Four copies identical (generated and bundle blob comparison) | `git rev-parse HEAD:<path>` per copy | None. |
| 14 | S14 frozen-surface re-baseline | PASS | Digest moved with the `# RE-BASELINED by issue #1233` paragraph | `git diff` of `parallel_orchestrator_surface_expectations.py` | None. |
| 15 | S15 mirrors | PASS | Helper blob `48be97927` and completion-helper blob `2573b573a` in four locations each; all 21 changed bundle copies equal their sources | `git hash-object` per copy | None. |
| 16 | S16 generators | PASS | `Invoke-HarnessGeneration.ps1 -Check` no drift after the main sync; Codex generator `--check` exit 0 | `post-sync-check.2026-11-24T13-36.md`; `scope-check.2026-11-24T13-10.md` | None. |
| 17 | S17 ledger | PASS | `0014-epic-child-ci-opt-out.md` with `## Prior Text`, revert blocks, disclosures; README row `0014`; ledger suites passed post-sync | `post-sync-check.2026-11-24T13-36.md` | The F1 fix must update the module's revert block. |
| 18 | S18 size and protected files | PASS | Largest covered file 689 logical lines; `ci.yml`, both review guards, the launch contract, and `.claude/lib/docs` not in the diff | reviewer logical line count; `git diff --stat` (empty) | None. |
| 19 | S19 toolchain and PR `CI` | UNVERIFIED | Local final QC loop clean; no pull request exists, so the pull request's own `CI` run has not happened | `final-qc-*` evidence | Pending CI; checked off by the item orchestrator at S9. |
| 20 | U1 kickoff | PASS | See S11; `early-start-skill-contract.Tests.ps1` passed | see row 11 | None. |
| 21 | U2 allow | PASS | See S1 | see row 1 | None. |
| 22 | U3 denies | PASS | See S4 | see row 4 | None. |
| 23 | U4 fallback | PASS | See S3 | see row 3 | None. |
| 24 | U5 S9 procedure | PASS | See S10 | see row 10 | None. |
| 25 | U6 completion hooks | PASS | See S6 | see row 6 | None. |
| 26 | U7 three validators | PARTIAL | See S7 | see row 7 | Code review F1; unchecked in `user-story.md`. |
| 27 | U8 integration PR | PASS | Branch 2 of both gates unchanged in the diff; skill text states integration `CI` | `git diff` of both gates | None. |
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

1. F1: the PowerShell completion validator reads the new `local_qc_gate` field keys and the review-loop keys case-insensitively, so it accepts a case-variant checkpoint that the Python (and, by inspection, TypeScript) validator rejects (S7, U7).
2. S19 is pending the pull request's own `CI` run, which cannot exist before the pull request is opened.

**Recommended follow-up verification steps:**

1. After the F1 fix, run the three corpus suites (`OrchestratorStateChildCi.Tests.ps1`, `test_validate_orchestrator_state_completion.py`, `orchestrator-state-child-ci.test.ts`) and the ledger suites, then re-check S7 and U7.
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
| `.dev/active/1233-epic-child-ci-opt-out/spec.md` | 19 | 17 | 2 | S7 reverted from checked to unchecked by this review (PARTIAL); S19 left unchecked (pending CI) |
| `.dev/active/1233-epic-child-ci-opt-out/user-story.md` | 10 | 9 | 1 | U7 reverted from checked to unchecked by this review (PARTIAL) |

Source-file changes made by this review: the executor had checked S7 and U7; both were reverted to `- [ ]` because the reviewer probe shows a PARTIAL result. Every criterion evaluated as PASS was already checked. The spec's Definition of Done and Seeded Test Conditions checklists are not acceptance criteria and were left unchanged.
