# Feature Audit: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Audit Date:** 2026-11-03
**Feature Folder:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
**Base Branch:** `main`
**Head Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review (fresh start)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
- **Head branch/commit:** `feature/parallel-add-and-plan-resume-prepared-items-1047` (commit `793096c827d8729d87dc5f053afefa652e29ee32`)
- **Merge base:** `01706c697f3ad4a53b4a771d99d851afc7417ea9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-03 18:43:12 UTC for head `793096c8`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/**` (49 committed records)
  - Additional evidence: `evidence/regression-testing/review-linux-reruns.2026-11-03T18-43.md` (review re-runs: 242/242 Pester, 23/23 bats parity on Linux at HEAD)
- **Feature folder used:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`.
- **Scope note:** The full branch diff against the merge base was audited (91 files). The branch merged `origin/main` twice after the QA loop; the merged changes touch only the cleanup-merged-worktrees skill and scripts (issue 1027), their bats suites and fixtures, and the devcontainer, none of which overlap the branch's files. The interrupted partial review artifacts removed in `a86154da3` were not consulted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/spec.md` - primary source (21 criteria)
- `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/user-story.md` - secondary source (11 criteria)

### From spec.md

1. Language: the helper is implemented as the three named PowerShell files; no added `.py`, no `.py` outside `tests/`, no `.ts`; verified by merge-base name-only and name-status diffs recorded under `evidence/qa-gates/`.
2. Stage record: `assess` returns `preparation_status` from `none|research|spec|plan|cleared`; the checkpoint records it; the rule declares the values and the `prepared`/`cleared` correspondence.
3. Preparation receipt: the prompt instructs the receipt write; `assess` selects the greatest receipt; a hash mismatch downgrades to `plan`.
4. Stage inference: rows of `## Data & State`; `cleared` only from committed `PREFLIGHT: ALL CLEAR` evidence at or after the plan's last commit.
5. Resume at first incomplete stage: unchanged kickoff line plus the resume line on the pushed branch; no separate preparation mechanism.
6. Fresh skip: `cleared` with no overlap returns `fresh` and `admit_prepared`; no child, preflight, or revision.
7. Stale path and fully-prepared definition: stale `cleared`/`plan` resumes at preflight with findings; a never-cleared plan always preflights; only `cleared` yields `admit_prepared`.
8. Premise falsified and supersession: removed cited path yields `premise_falsified`; non-ancestor base yields `stale`; supersession by new timestamped files.
9. Plan hash: recorded on the item, the scheduling record, and the `## Integrity` table; kickoff element 4 carries `plan-hash` and the verify-first instruction; element count unchanged.
10. Closed-run guard: `guard-run` rejection matrix, success for an open run, `/parallel-add` `## Prerequisites` wiring, no `PARALLEL_MUTATION_REJECTED` signal.
11. Shared intake and seeding: both commands call `assess`; seeding from `cleared`+`fresh` items without children; validators accept the result.
12. Complexity band precedence: `--band`, then planner checkpoint, then fresh assessment; `band_source` recorded.
13. Precedence input: `--after` recorded as `precedence[]`, never `depends_on`; rejections; `order-cohorts` lift; `defer_and_recolor` for an active unmerged predecessor.
14. Precedence rejection and barrier: `test-cohorts` `precedence_violated`; parity step and recolor run it; barrier rule with `withdrawn` releasing and `blocked` holding; rule documents the Layer 2 gap; passing on the Linux hook-suite job.
15. Durable edges: `record` content; commit at seeding and after each admission; re-seed reuse only on a matching `plan_hash`.
16. Turn gap: `## Per-Item Merge to Main (Merge-on-Green)` keeps `pr_open`, polls CI, and re-delegates to S9; no `##` heading added.
17. Declared fields and permissions: amended sentences; `Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)` in both agents and settings.
18. Mirrors: byte-equal bundle copies and `pack-manifests/core.json` entries.
19. Unit and CLI tests with coverage: seam mocks, no temporary files, each new PowerShell file at or above the line threshold; convention and file-size suites pass.
20. Test-order independence: seeded shuffle, concurrent shards, and `pytest -n auto --strict-markers` with no failures.
21. Gate intent unchanged: closed runs refuse; preflight strictness and the single-pass limit unchanged; bash entry points and Python authorities not edited.

### From user-story.md

1. Admission without repeating a completed stage; checkpoint records `preparation_status`.
2. Fresh `cleared` item admitted with no child, no preflight, no revision.
3. Changed cited files go through the unchanged single-pass preflight; redo only on a falsified premise; supersession by new files.
4. Receipt with plan hash and base commit; execution child stops on a hash mismatch.
5. `/parallel-add` against a closed run fails with `PARALLEL_ADMISSION_REJECTED: run_closed` from the helper.
6. `/parallel-plan` seeds from prepared items without children; validators accept.
7. Band from `--band`, then the planner checkpoint, then a fresh assessment.
8. `--after` honored by the cohort table; a violating table rejected by the helper and the cohort barrier hook; verified by Pester precedence and hook suites.
9. Conflict edges stored in a committed `parallel-scheduling.json` that a re-seed reads.
10. Parent keeps `pr_open` while the CI gate is pending and re-delegates to that gate.
11. PowerShell helper, no new or production Python, no TypeScript; mirrors and bundles byte-equal; push-down, pack-manifest, dependency-closure, and parallel contract tests pass.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | Language | PASS | Review diff shows exactly one `.py` path, `M tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; no `A` `.py`; no `.ts`. Recorded under `evidence/qa-gates/scope-diff.2026-11-03T14-20.md`. | `git diff --name-status --no-renames 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD` | Re-verified after both main merges; newly checked off. |
| S2 | Stage record | PASS | `ParallelAdmission.Tests.ps1` (56 pass); rule section `## Prepared-Item Admission (issue #1047)`; validators exit 0 on the seed fixtures (`integration-seed.2026-11-03T13-39.md`). | `Invoke-Pester` (review re-run) | Previously checked. |
| S3 | Preparation receipt | PASS | `Select-ParallelAdmissionReceipt` and `Resolve-ParallelAdmissionStage` cases; receipt line in `parallel-plan/SKILL.md` separate from the kickoff line; `test_parallel_issue_adoption_skill_contracts.py` in the passing full suite. | `poetry run pytest -n auto -q -p no:cacheprovider` (executor) | Previously checked. |
| S4 | Stage inference | PASS | Inference Describe cases including placeholder spec, placeholder plan, and stale preflight evidence. | `Invoke-Pester` (review re-run) | Previously checked. |
| S5 | Resume at first incomplete stage | PASS | `next_action` cases; resume line in skill; `integration-half-prepared.2026-11-03T13-39.md`. | `Invoke-Pester` (review re-run) | Previously checked. |
| S6 | Fresh skip | PASS | Staleness cases with and without overlap; seed scenario `admit_prepared` for 1101 and 1102. | `Invoke-Pester` (review re-run) | Previously checked. |
| S7 | Stale path and fully-prepared definition | PASS | `Get-ParallelAdmissionDecision` cases; skill text references the unchanged `## Delegation Model` of `.claude/skills/orchestrate/SKILL.md`, which is not in the diff. | `Invoke-Pester`; `git diff --name-only ... -- .claude/skills/orchestrate` (empty) | Previously checked. |
| S8 | Premise falsified and supersession | PASS | Removed-path and non-ancestor cases; supersession sentence in the preparation-resume paragraph. | `Invoke-Pester` (review re-run) | Previously checked. |
| S9 | Plan hash | PASS | Hash-recording cases; `kickoff-plan-hash-verification` obligation pinned in `parallel_orchestrator_surface_expectations.py` line 225. | `poetry run pytest -n auto` (executor) | Previously checked. |
| S10 | Closed-run guard | PASS | Guard matrix; `integration-closed-run.2026-11-03T13-39.md`; `test_parallel_mutation_rejection_signal_contracts.py` in the passing suite. | `Invoke-Pester`; pytest (executor) | Previously checked. |
| S11 | Shared intake and seeding | PASS | Both skills call `assess`; three validators exit 0 (`integration-seed.2026-11-03T13-39.md`). | `bash .claude/lib/bash/validate-parallel-manifest.sh ...`; `validate_orchestration_artifacts` (executor) | Previously checked. |
| S12 | Complexity band precedence | PASS | `Resolve-ParallelAdmissionBand` cases for each source. | `Invoke-Pester` (review re-run) | Previously checked. |
| S13 | Precedence input | PASS | `ParallelAdmissionPrecedence.Tests.ps1` (51 pass); planner surface contracts in the passing suite. | `Invoke-Pester` (review re-run) | Previously checked. |
| S14 | Precedence rejection and barrier | UNVERIFIED | Behavior verified locally: precedence suite 51/51 and hook suite 62/62 on Linux at HEAD (`review-linux-reruns.2026-11-03T18-43.md`); the rule documents the Layer 2 gap. The criterion names the CI job `poshqc / PowerShell hook suites (Linux)`, which has not run (no PR exists). | `Invoke-Pester` (review re-run); CI pending | Pending CI. CI-dependent criterion; the item orchestrator checks it off at S9. Not a blocking finding. |
| S15 | Durable edges | PASS | Record content and reuse cases; seed scenario reads the record by ref through the mocked git seam. | `Invoke-Pester` (review re-run) | Previously checked. The reuse rule is applied from skill prose; see code-review Minor finding. |
| S16 | Turn gap | PASS | `merge-on-green-turn-gap-redelegation` obligation pinned; the only added `##` heading is in the rule file, not in `parallel-orchestrate/SKILL.md`. | `git diff ... -- .claude/skills .claude/rules` heading scan | Previously checked. |
| S17 | Declared fields and permissions | PASS | Permission line present in both agents and `.claude/settings.json`; amended sentences in the agent and skill diffs. | Diff inspection; pytest (executor) | Previously checked. |
| S18 | Mirrors | PASS | 11 of 11 primary/bundle pairs byte-equal; three `pack-manifests/core.json` entries; `ParallelAdmission.Manifest.Tests.ps1` 5/5. | `cmp -s <primary> <bundle>` | Previously checked. |
| S19 | Unit and CLI tests with coverage | PASS | Per-file figures recorded in `evidence/qa-gates/pester-coverage.2026-11-03T13-52.md` (100.00%, 100.00%, 96.15%), with junit counts; no temporary files in the suites. | Evidence inspection | Previously checked. The criterion is satisfied by the recorded evidence it names; the policy audit separately records the absence of the canonical coverage artifact as a review-contract FAIL. |
| S20 | Test-order independence | PASS | `pester-shuffle.2026-11-03T13-54.md`, `pester-parallel-shards.2026-11-03T14-00.md`, `pytest-n-auto.2026-11-03T13-53.md`, `pytest-strict-markers-nauto.2026-11-03T18-42.md`. | Evidence inspection | Previously checked. |
| S21 | Gate intent unchanged | PASS | Six `tests/shell/*_parity.bats` suites pass unchanged on Linux at HEAD (23/23); `test_parallel_mutation_run_bash_parity.py` in the passing full suite; no path under `.claude/lib/bash/` or `.claude/skills/orchestrate/` in the diff. | `bats tests/shell/parallel_*_parity.bats` (review re-run) | Newly checked off. |
| U1 | Admission without repeating a stage | PASS | Same evidence as S2, S5. | `Invoke-Pester` | Previously checked. |
| U2 | Fresh admission | PASS | Same evidence as S6. | `Invoke-Pester` | Previously checked. |
| U3 | Stale and falsified handling | PASS | Same evidence as S7, S8. | `Invoke-Pester` | Previously checked. |
| U4 | Receipt and execution hash check | PASS | Same evidence as S3, S9. | `Invoke-Pester`; pytest | Previously checked. |
| U5 | Closed-run rejection | PASS | Same evidence as S10. | `Invoke-Pester` | Previously checked. |
| U6 | Seeding from prepared items | PASS | Same evidence as S11. | validators (executor) | Previously checked. |
| U7 | Band precedence | PASS | Same evidence as S12. | `Invoke-Pester` | Previously checked. |
| U8 | Precedence honored and rejected | PASS | Precedence suite 51/51 and hook suite 62/62 at HEAD on Linux; the criterion names the Pester suites only, not a CI job. | `Invoke-Pester` (review re-run) | Newly checked off. |
| U9 | Durable edges | PASS | Same evidence as S15. | `Invoke-Pester` | Previously checked. |
| U10 | Turn gap | PASS | Same evidence as S16. | pytest (executor) | Previously checked. |
| U11 | Language, mirrors, contract tests | PASS | Same evidence as S1 and S18; push-down, pack-manifest, dependency-closure, and parallel contract modules pass in the post-merge full suite (16063 passed). | `git diff --name-status`; `cmp`; pytest (executor) | Newly checked off. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 31 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria (S14, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. The policy audit records two blocking findings: the canonical coverage artifacts `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info` are absent from the item worktree.
2. S14 depends on the CI job `poshqc / PowerShell hook suites (Linux)`, which runs only after the PR exists; it is pending CI and owned by the item orchestrator at S9.

**Recommended follow-up verification steps:**

1. Regenerate both coverage artifacts at the branch head in the item worktree and re-run the feature review.
2. After the PR opens, confirm the `poshqc / PowerShell hook suites (Linux)` job is green and check off S14 at S9.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

Newly checked off by this review:
- `spec.md`: "Language: the helper is implemented as ..." (S1)
- `spec.md`: "Gate intent unchanged: ..." (S21)
- `user-story.md`: "An `--after` precedence input is honored by the cohort table ..." (U8)
- `user-story.md`: "The helper is PowerShell with no new Python ..." (U11)

### AC Status Summary

- Source: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/spec.md`, `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/user-story.md`
- Total AC items: 32
- Checked off (delivered): 31
- Remaining (unchecked): 1
- Items remaining: `spec.md` "Precedence rejection and barrier: ... passing on the Linux hook-suite job." (pending CI)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 21 | 20 | 1 | Checkbox-backed; S14 pending CI |
| `user-story.md` | 11 | 11 | 0 | Checkbox-backed |
