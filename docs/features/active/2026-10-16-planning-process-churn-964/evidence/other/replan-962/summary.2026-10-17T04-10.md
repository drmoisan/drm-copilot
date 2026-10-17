# O1 — #962 Re-Plan Under the Single-Pass, Design-Level Contract (AC-33)

Timestamp: 2026-10-17T04-10
Owner: orchestrator (O1; the executor has no Agent tool)
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <attempt plan path>
EXIT_CODE: 0
Output Summary: Two re-plans of the #962 spec, each under 40 tasks and validator-clean; both first preflights returned PREFLIGHT: REVISIONS REQUIRED (attempt 1: 2 substantive defects; attempt 2: 1 substantive defect of a different class). AC-33's "first preflight PREFLIGHT: ALL CLEAR" condition is not met; every other AC-33 condition is met.

## Source

- Source ref: `origin/bug/ci-skip-evidence-only-commits-962` (#962 had not merged; its PR #966 was open).
- Snapshot: `spec.md` in this folder, taken with `git show`. #962's own feature folder was not modified.
- Original #962 plan measured on that ref: `plan.2026-10-16T10-27.md`, 1754 physical lines, 99 canonical task lines, six preflight rounds (per the #964 spec and research).

## Results

| Measure | Original #962 plan | Attempt 1 (`plan.md`) | Attempt 2 (`attempt-2/plan.md`) |
|---|---|---|---|
| Physical lines | 1754 | 139 | 291 |
| Canonical tasks | 99 | 38 | 38 |
| G11 findings (line-number citation) | n/a (pre-rule) | 0 | 0 |
| G12 findings (commit SHA citation) | n/a (pre-rule) | 0 | 0 |
| G13 (40 tasks / 400 lines) | n/a (pre-rule) | within guideline | within guideline |
| Branch-current Python validator | n/a | exit 0 (before and after fixes) | exit 0 (before and after fixes) |
| Preflight rounds | 6 | 1 | 1 |
| First preflight signal | n/a | PREFLIGHT: REVISIONS REQUIRED | PREFLIGHT: REVISIONS REQUIRED |
| PREFLIGHT-FIX count (in place) | n/a | 6 | 8 |
| PREFLIGHT-DEFECT count (substantive) | n/a | 2 | 1 |
| Fix record | n/a | `preflight-fixes.2026-10-17T02-53.md` | `attempt-2/preflight-fixes.2026-10-17T04-02.md` |

Both re-plans are smaller than the original in lines (92% and 83% smaller) and in tasks (62% smaller). Each preflight reviewed the whole plan in one pass and returned one signal.

## Substantive Defects and Contract Response

- Attempt 1, P3-T1 and P3-T2: the plan changed the observable behavior of an existing shell function (`run_test`/`run_test_coverage` argv) and an existing test stub (kcov stub output) without naming the existing bats tests that assert that behavior. Response (the one proportionate correction the spec permits): the design-level contract and the execution-environment brief's `## Preflight Defect Classes the Validator Cannot See` now require a task that changes existing behavior to name the asserting tests and their disposition (commit `b35fe1de1`, evidence `qa-gates/contract-correction.2026-10-17T03-37.md`). Attempt 2 was authored from a cold start under the corrected contract; its preflight found the remaining gaps in that class only as trivial in-place disposition additions.
- Attempt 2, P3-T2/P3-T8 and `## Pre-Mortem` (Mirror parity): the plan adds two `ci.yml` jobs but has no task to update the execution-environment brief's job list, which the brief's own maintenance rule requires in the same change. This class is created by the brief this item introduces. Response: the contract's Pre-Mortem `Mirror parity` label and the brief's validator-blind defect classes now name the brief-maintenance obligation (this commit (fix(964): require brief updates and record the #962 re-plan)). A third attempt was not run: the spec permits one proportionate correction and the operator ruling forbids open-ended iteration.

## AC-33 Status

- Met: `spec.md` and this summary exist; source ref, original and re-plan line and task counts recorded; no G11 or G12 finding; G13 within guideline; passing Python CLI validation; re-plan smaller than the original in both lines and tasks; #962's folder unmodified.
- Not met: "a first preflight of `PREFLIGHT: ALL CLEAR` (in-place fixes permitted)". Both attempts returned REVISIONS REQUIRED. AC-33 therefore remains unchecked in `spec.md`.
