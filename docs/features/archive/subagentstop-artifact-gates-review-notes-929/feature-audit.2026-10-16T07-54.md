# Feature Audit: SubagentStop artifact-gate review notes (#929)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/subagentstop-artifact-gates-review-notes-929`
**Base Branch:** `origin/main`
**Head Branch:** `bug/subagentstop-artifact-gates-review-notes-929`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1 (feature-vs-base)
**Prior review:** `feature-audit.2026-10-16T05-25.md` (REMEDIATION_REQUIRED, FA-1 blocking)

**Total blocking findings: 0.**

---

## Scope and Baseline

- **Base branch:** `origin/main` (merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`; `origin/main` is now `a880c46b9`, see FA-5)
- **Head branch/commit:** `bug/subagentstop-artifact-gates-review-notes-929` (commit `09f319079`, pushed)
- **Merge base:** `5bc97774b8322e57abb94dfac3cd0a000a136c5b`
- **Evidence sources:**
  - Direct diff: `git diff origin/main...HEAD` (123 files; outside the feature folder: 2 production hook copies, 9 test-tree PowerShell files, 1 E3 spec) and the cycle 1 diff `git diff 8d9bad34c..HEAD` (26 files; one test file outside the feature folder)
  - Feature documents: `issue.md`, `spec.md`, `plan.2026-10-15T15-44.md`, `remediation-inputs.2026-10-16T05-25.md`, `remediation-plan.2026-10-16T05-25.md` (47 checked, 0 unchecked)
  - Feature evidence: item evidence reviewed in r1, plus cycle 1 evidence under `evidence/remediation-baseline/`, `evidence/regression-testing/rc1-*`, `evidence/qa-gates/rc1-*`, and `evidence/qa-gates/coverage-repo-wide.2026-10-16T07-38.md`
  - Reviewer reruns at `09f319079`: `git grep` (AC-09, on HEAD and on the trial-merge tree with `origin/main`), `git diff --name-only` (AC-13), `cmp` (mirror parity), `wc -l` (AC-24), spec checkbox count, AC-12 pytest (20 passed), `validate_evidence_locations.py` (exit 0), `git merge-tree --write-tree HEAD origin/main` (clean)
  - PR context artifacts: no PR exists yet; the diff above is the authoritative scope.
- **Feature folder used:** `docs/features/active/subagentstop-artifact-gates-review-notes-929`
- **Requirements source:** `spec.md` `## Acceptance Criteria` only (work mode `full-bug`)
- **Work mode resolution note:** `issue.md` line 9 states `- Work Mode: full-bug`. `user-story.md` is absent, which is correct for `full-bug`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md` — only source (`## Acceptance Criteria`, AC-01 to AC-27, checkbox format, lines 205-249)

### Acceptance criteria

AC-01 to AC-27 as written in `spec.md` lines 205-249. The evaluation table uses the AC number and a short label.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| AC-01 | prd-feature R3 reject and accept rows | PASS | `validate-prd-feature-output.Tests.ps1` rows; `r3-prd-feature.2026-10-16T01-13.md`; full run 0 failed | Diff read; full-run JUnit | Unchanged since r1 |
| AC-02 | task-researcher R3 reject and accept rows | PASS | `validate-task-researcher-output.Coverage.Tests.ps1` R3 Describe; `rc1-final-suite-coverage.2026-10-16T07-49.md` lists all R3 rows Passed | Suite run evidence | |
| AC-03 | NB-2 characterization rows with Risk 5a comments | PASS | Commented rows in both accept tables | Diff read | Unchanged since r1 |
| AC-04 | R3 pattern unchanged; NB-2 decision recorded | PASS | prd-feature hook absent from the branch diff; spec.md decision table | `git diff --name-only` | |
| AC-05 | Four R4 trim-only tests | PASS | `validate-discovery-artifact-gate.Tests.ps1` R4 Context; `r4-discovery.2026-10-16T01-16.md` | Diff read | |
| AC-06 | R4 gate lone-backtick case with `-Times 0` | PASS | Same Context, last `It` | Diff read | |
| AC-07 | Helper exists, `AgentType` default, no suppression | PASS | `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1:12-35` | File read | |
| AC-08 | Seven suites dot-source the helper and pass | PASS | Fragment present in each converted suite; the F2 file now has 2 (one per Describe that uses the helper); full run 0 failed | Grep count; full-run evidence | |
| AC-09 | No old builder name or justification under `tests` | PASS | Reviewer `git grep -n New-SubagentStopEnvelopeJson HEAD -- tests`: no output; same on trial-merge tree `e8da4595c` | `git grep` | The NB-11 literal noted in r1 is gone (F2) |
| AC-10 | NB-4 committed last; #928 check recorded | PASS | `93a06a8cb` and `e0e3d7613` follow every other implementation commit except the cycle 1 F2 commit `bb386ed6b`, which is a review-driven remediation of the NB-4 conversion itself | `git log` | See note below the table |
| AC-11 | No `$agentOutput`; `$assistantMessage` at former sites | PASS | Lines 244, 248, 265 | File read | Production file unchanged in cycle 1 |
| AC-12 | Two pytest contract modules pass | PASS | Reviewer rerun at `09f319079`: 20 passed | `poetry run pytest ...` | |
| AC-13 | Only the two NB-5 production paths changed | PASS | `git diff --name-only origin/main...HEAD -- .claude .codex extensions scripts .github` lists exactly the two paths | Reviewer rerun | |
| AC-14 | E3 AC-20 clarification line; checkbox unchanged | PASS | E3 spec diff | Diff read | |
| AC-15 | E3 AC-11 clarification line; this spec records both | PASS | E3 spec diff; spec.md | Diff read | |
| AC-16 | Dispatch-once test | PASS | `validate-discovery-artifact-gate.Dispatch.Tests.ps1:33-48` | File read | |
| AC-17 | First-failure short-circuit test | PASS | `validate-discovery-artifact-gate.Dispatch.Tests.ps1:50-65` | File read | |
| AC-18 | Baseline and final LINE counters recorded verbatim | PASS | `coverage-counters-baseline.2026-10-16T01-06.md`; `coverage-counters-final.2026-10-16T05-12.md`; full-run per-file counter in `coverage-repo-wide.2026-10-16T07-38.md` | File read | |
| AC-19 | NB-11 in-process test | PASS | `validate-task-researcher-output.Coverage.Tests.ps1:329-351`; passed in `rc1-final-suite-coverage.2026-10-16T07-49.md` | Suite run evidence | Envelope now helper-built |
| AC-20 | Dependency-decision statements first; completeness suite passes | PASS | Hook lines 238-239; full run 0 failed | File read | |
| AC-21 | Format and analyze clean | PASS | `rc1-final-format.2026-10-16T07-39.md`; `rc1-final-analyze.2026-10-16T07-40.md` (`TOTAL_FINDINGS=0`); item `final-*` evidence | File read | |
| AC-22 | PoshQC test no failures | PASS | Full run 10405 passed, 0 failed (`coverage-repo-wide.2026-10-16T07-38.md`); `rc1-final-poshqc-test-mcp.2026-10-16T07-49.md` | File read | |
| AC-23 | Final missed not greater than baseline missed | PASS | 2 vs 2 (scoped final run and full run) | Evidence read | |
| AC-24 | No touched file over 500 lines | PASS | Maximum 420; F2 file 351 | `wc -l` | |
| AC-25 | No `[expect-fail]` task; characterization statement | PASS | Plan count 0 (r1); remediation plan adds no `[expect-fail]` task | Evidence read | |
| AC-26 | CI `poshqc / PowerShell QC` success on PR head | UNVERIFIED (pending CI, non-blocking) | No PR exists yet | Not runnable before CI runs on the PR head | CI-dependent; checked off at S9 by the item's orchestrator run |
| AC-27 | CI `poshqc / PowerShell hook suites (Linux)` success on PR head | UNVERIFIED (pending CI, non-blocking) | No PR exists yet | Not runnable before CI runs on the PR head | CI-dependent; also confirms the case-sensitive helper path on Linux |

AC-10 note: the criterion sequences NB-4 after the other implementation notes within the planned work so that concurrent #928 call sites could be converted. The cycle 1 commit `bb386ed6b` converts one more envelope construction to the NB-4 helper, which keeps the NB-4 conversion as the final implementation step in substance. The reviewer evaluates AC-10 as still satisfied.

---

## Findings Outside the AC Table

| ID | Severity | Description | Remediability | Related |
|---|---|---|---|---|
| FA-1 (= PA-1 / CR-2) | Resolved | r1 blocking: repo-wide PowerShell line coverage not evidenced. Now 90.44% (16384/18115) from a full run on `bb386ed6b`; no PowerShell file changed afterward. | autonomous | Related |
| FA-2 (= PA-4 / CR-1) | Resolved | r1 Minor: NB-11 inline envelope literal. Replaced by the shared helper; envelope text identical. | autonomous | Related |
| FA-3 (= PA-2) | Pending CI (non-blocking) | AC-26 awaits CI on the PR head. | awaiting_ci | Related |
| FA-4 (= PA-3) | Pending CI (non-blocking) | AC-27 awaits CI on the PR head. | awaiting_ci | Related |
| FA-5 (= PA-7 / CR-5) | Minor (non-blocking) | Branch is behind `origin/main` (`a880c46b9`) by PRs #948 and #950; no path overlap, trial merge clean, AC-09 holds on the merged tree. Update the branch before the PR is opened. | autonomous | Related |
| FA-6 (= PA-6) | Resolved (reviewer) | The on-disk coverage XML had been overwritten by a later scoped run (51.99%); the reviewer regenerated it with a full run at `09f319079` and obtained 16384/18115 = 90.44%, identical to the executor's full run. | autonomous | Related |
| FA-7 (= PA-8 / CR-6) | Observation (non-blocking) | Non-uniform `Claude-Session` trailers; no policy makes trailers a merge requirement. | human_decision_required | Related |

No finding is unrelated to this item.

---

## Summary

Remediation cycle 1 resolved the r1 blocking finding (F1, repo-wide PowerShell coverage now evidenced at 90.44%) and the routed non-blocking finding (F2, NB-11 envelope built with the shared helper). The full item change set was re-reviewed; no new defect was found in production or test code.

AC-01 to AC-25: PASS. AC-26 and AC-27: pending PR CI (non-blocking).

Blocking: none. Non-blocking: FA-3 and FA-4 (pending CI), FA-5 (update branch with `origin/main` before PR), FA-7 (observation). FA-6 resolved by the reviewer's full run at the final head.

**Overall verdict:** PASS. Blocking findings: 0.

---

## Acceptance Criteria Check-off

- AC-01 to AC-25 were already checked off in `spec.md` (lines 205-247); the reviewer evaluated each as PASS and made no change to `spec.md`.
- AC-26 and AC-27 remain unchecked (`spec.md` lines 248-249); they are CI-dependent and are owned by the item's orchestrator run at S9.
- No AC item was newly checked off by this review.

### Acceptance Criteria Status
- Source: `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`
- Total AC items: 27
- Checked off (delivered): 25
- Remaining (unchecked): 2
- Items remaining: AC-26 (CI-dependent): CI job `poshqc / PowerShell QC` concludes `success` on the PR head SHA; AC-27 (CI-dependent): CI job `poshqc / PowerShell hook suites (Linux)` concludes `success` on the PR head SHA.
