# Feature Audit: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Audit Date:** 2026-11-03
**Feature Folder:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
**Base Branch:** `main`
**Head Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047`
**Work Mode:** `full-feature`
**Audit Type:** Remediation re-audit after cycle 1

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
- **Head branch/commit:** `feature/parallel-add-and-plan-resume-prepared-items-1047` (commit `49c54e3de3a725c6a17d8b8fceca7d0ab768dce5`)
- **Merge base:** `01706c697f3ad4a53b4a771d99d851afc7417ea9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-03 21:04:00 UTC for head `49c54e3d`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Canonical coverage artifacts parsed by this review: `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`
  - Feature evidence: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/**`, including the cycle 1 records under `evidence/remediation-baseline/`, `evidence/qa-gates/` (`*.2026-11-03T19-*` to `*T20-59`), and `evidence/regression-testing/`
  - Review re-runs at HEAD on Linux: touched Pester suites 282/282, `FileSizePolicy.RepoGate.Tests.ps1` 5/5, PSScriptAnalyzer 0 findings, formatter 0 differences
- **Feature folder used:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`.
- **Scope note:** The full branch diff against the merge base was audited (146 files). Cycle 1 (`c878af760..49c54e3de`) added the `reuse-edges` subcommand, the `ParallelAdmissionJson.psm1` module, git stderr surfacing, side-effect wording, their tests and mirrors, and the cycle evidence.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/spec.md` - primary source (21 criteria under `## Acceptance Criteria`)
- `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/user-story.md` - secondary source (11 criteria)

The `## Definition of Done` checklist in `spec.md` is outside the `## Acceptance Criteria` section and is not counted.

### From spec.md

1. Language: helper in PowerShell under `.claude/lib/parallel-admission/`; no added `.py`, no `.py` outside `tests/`, no `.ts`.
2. Stage record values and rule declaration.
3. Preparation receipt instruction, selection, and downgrade.
4. Stage inference rows.
5. Resume at first incomplete stage.
6. Fresh skip.
7. Stale path and fully-prepared definition.
8. Premise falsified and supersession.
9. Plan hash recording and kickoff verification.
10. Closed-run guard.
11. Shared intake and seeding.
12. Complexity band precedence.
13. Precedence input.
14. Precedence rejection and barrier, passing on the Linux hook-suite CI job.
15. Durable edges and re-seed reuse on a matching `plan_hash`.
16. Turn gap.
17. Declared fields and permissions.
18. Mirrors.
19. Unit and CLI tests with coverage.
20. Test-order independence.
21. Gate intent unchanged.

### From user-story.md

1. Admission without repeating a completed stage.
2. Fresh `cleared` item admitted without child, preflight, or revision.
3. Stale and falsified handling.
4. Receipt with plan hash and base commit.
5. Closed-run rejection.
6. Seeding from prepared items.
7. Band precedence.
8. `--after` honored and violations rejected.
9. Durable edges read by a re-seed.
10. Turn gap.
11. Language, mirrors, and contract tests.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | Language | PASS | Merge-base diff: the only `.py` path is `M tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; no `A` `.py`; no `.ts`. `evidence/qa-gates/scope-diff.2026-11-03T20-58.md`. | `git diff --name-status --no-renames 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD` | Previously checked. Cycle 1 added a fourth PowerShell file in the same folder (`ParallelAdmissionJson.psm1`); the criterion's verified condition holds. Spec wording drift recorded as a Minor code-review finding. |
| S2 | Stage record | PASS | `ParallelAdmission.Tests.ps1` 56/56 at HEAD. | `Invoke-Pester` (review re-run) | Previously checked. |
| S3 | Preparation receipt | PASS | Receipt cases pass; skill text unchanged in cycle 1. | `Invoke-Pester`; pytest (executor) | Previously checked. |
| S4 | Stage inference | PASS | Inference cases pass at HEAD. | `Invoke-Pester` (review re-run) | Previously checked. |
| S5 | Resume at first incomplete stage | PASS | `next_action` cases; skill text unchanged in cycle 1. | `Invoke-Pester` (review re-run) | Previously checked. |
| S6 | Fresh skip | PASS | Staleness and integration seed cases pass. | `Invoke-Pester` (review re-run) | Previously checked. |
| S7 | Stale path and fully-prepared definition | PASS | Decision cases pass; `.claude/skills/orchestrate/` not in the diff. | `Invoke-Pester`; `git diff --name-only` | Previously checked. |
| S8 | Premise falsified and supersession | PASS | Removed-path and non-ancestor cases pass. | `Invoke-Pester` (review re-run) | Previously checked. |
| S9 | Plan hash | PASS | Hash cases; `kickoff-plan-hash-verification` pin in the passing pytest suite (16063 passed). | pytest (executor) | Previously checked. |
| S10 | Closed-run guard | PASS | Guard matrix and closed-run integration case pass at HEAD. | `Invoke-Pester` (review re-run) | Previously checked. |
| S11 | Shared intake and seeding | PASS | Seed integration scenario passes; validator evidence unchanged. | `Invoke-Pester`; validators (executor) | Previously checked. |
| S12 | Complexity band precedence | PASS | Band-source cases pass. | `Invoke-Pester` (review re-run) | Previously checked. |
| S13 | Precedence input | PASS | `ParallelAdmissionPrecedence.Tests.ps1` 51/51 at HEAD. | `Invoke-Pester` (review re-run) | Previously checked. |
| S14 | Precedence rejection and barrier | UNVERIFIED | Behavior verified locally: precedence suite 51/51 and hook suite 62/62 on Linux at HEAD. The criterion names the CI job `poshqc / PowerShell hook suites (Linux)`, which has not run because no PR exists. | `Invoke-Pester` (review re-run); CI pending | Pending CI. CI-dependent criterion; the item orchestrator checks it off at S9. Not a blocking finding. |
| S15 | Durable edges | PASS | The re-seed reuse rule is now applied in code through `reuse-edges` (M1): CLI cases for reuse on a matching hash and record read by ref with no fetch, integration `reuse-edges` scenario, skill step 7 and rule updated. Review probe of the CLI returned `record_missing` for an absent record. | `Invoke-Pester` (review re-run); review CLI probe | Previously checked; strengthened in cycle 1. |
| S16 | Turn gap | PASS | Obligation pin in the passing pytest suite. | pytest (executor) | Previously checked. |
| S17 | Declared fields and permissions | PASS | The existing permission rule ends in `*` and covers `reuse-edges`; `.claude/settings.json` and agents byte-equal to their bundle copies. | `cmp -s` (review) | Previously checked. |
| S18 | Mirrors | PASS | 12 of 12 primary and bundle pairs byte-equal (review `cmp`), including `ParallelAdmissionJson.psm1`; `pack-manifests/core.json` lists the new module; `ParallelAdmission.Manifest.Tests.ps1` 5/5. | `cmp -s <primary> <bundle>` | Previously checked. |
| S19 | Unit and CLI tests with coverage | PASS | Read from `artifacts/pester/powershell-coverage.xml` by this review: `ParallelAdmission.psm1` 100.00%, `ParallelAdmissionPrecedence.psm1` 100.00%, `ParallelAdmissionJson.psm1` 100.00%, `Invoke-ParallelAdmission.ps1` 96.44%; recorded in `evidence/qa-gates/pester-coverage.2026-11-03T20-57.md`. No temporary files in the suites. `ClaudeLibModuleConvention.Tests.ps1` 6/6 and `FileSizePolicy.RepoGate.Tests.ps1` 5/5 at HEAD. | Coverage parse; `Invoke-Pester` (review re-run) | Previously checked; now verified from the canonical artifact. The JUnit file of the full-tree run is truncated on this host (export failed on a 0x1B character in a failure message of an unrelated suite); the review's own Pester run supplies the pass counts. |
| S20 | Test-order independence | PASS | `pester-shuffle.2026-11-03T20-30.md` (seeds 11, 23, 47; 214 tests each; 0 failures), `python-reversed.2026-11-03T20-31.md`, `pytest-n-auto.2026-11-03T20-40.md`. The concurrent-shard runs show failures only in pre-existing host suites outside the diff, none in a touched suite. | Evidence inspection | Previously checked. |
| S21 | Gate intent unchanged | PASS | No path under `.claude/lib/bash/`, `.claude/skills/orchestrate/`, or the Python authorities in the diff; cycle 1 changed no bash file. | `git diff --name-only` | Previously checked. |
| U1 | Admission without repeating a stage | PASS | Same evidence as S2, S5. | `Invoke-Pester` | Previously checked. |
| U2 | Fresh admission | PASS | Same evidence as S6. | `Invoke-Pester` | Previously checked. |
| U3 | Stale and falsified handling | PASS | Same evidence as S7, S8. | `Invoke-Pester` | Previously checked. |
| U4 | Receipt and execution hash check | PASS | Same evidence as S3, S9. | `Invoke-Pester`; pytest | Previously checked. |
| U5 | Closed-run rejection | PASS | Same evidence as S10. | `Invoke-Pester` | Previously checked. |
| U6 | Seeding from prepared items | PASS | Same evidence as S11. | validators (executor) | Previously checked. |
| U7 | Band precedence | PASS | Same evidence as S12. | `Invoke-Pester` | Previously checked. |
| U8 | Precedence honored and rejected | PASS | Precedence suite 51/51 and hook suite 62/62 at HEAD; the criterion names the Pester suites only. | `Invoke-Pester` (review re-run) | Previously checked. |
| U9 | Durable edges | PASS | Same evidence as S15. | `Invoke-Pester` | Previously checked. |
| U10 | Turn gap | PASS | Same evidence as S16. | pytest (executor) | Previously checked. |
| U11 | Language, mirrors, contract tests | PASS | Same evidence as S1 and S18; contract modules pass in the full pytest run (16063 passed). | `git diff --name-status`; `cmp`; pytest (executor) | Previously checked. |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 31 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria (S14, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None blocking. S14 depends on the CI job `poshqc / PowerShell hook suites (Linux)`, which runs only after the PR exists; the item orchestrator owns its check-off at S9.

**Recommended follow-up verification steps:**

1. After the PR opens, confirm the `poshqc / PowerShell hook suites (Linux)` job and the `windows-latest` PoshQC shards are green, then check off S14 at S9.
2. Consider the two Minor code-review findings (leading-dash check on ref options; spec mention of `ParallelAdmissionJson.psm1`) for in-item fixing at the orchestrator's discretion; neither blocks the PR.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkbox items and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

Newly checked off by this review: none. All 31 criteria evaluated as PASS were already checked in the source files (four of them by the previous review at `c878af760`). S14 remains unchecked as a CI-dependent criterion.

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
