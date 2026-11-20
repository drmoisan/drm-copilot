# Remediation Cycle 1 — Final QA: Python Type-Checking

Timestamp: 2026-08-09T08-57

Task: [P7-T3]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442

Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: **`0 errors, 0 warnings, 0 informations`**.

Acceptance: exit code 0 with 0 errors, 0 warnings. **PASS.**

## Non-Diagnostic Lines (not findings)

- `venv .venv subdirectory not found in venv path ...` — the worktree has no local `.venv`; Poetry
  supplies the interpreter. Pre-existing environment condition, present identically at the Phase 0
  baseline.
- `WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411)` — tool-version notice.
  The pinned version is unchanged by this cycle.

## Relationship to the Deliberate Phase Ordering

This is the SECOND zero-error gate of the cycle, after [P4-T13]. The plan deliberately omits Pyright
from [P3-T8]: after [P3-T1] and [P3-T3] made `current_cohort_members` and `current_cohort` required
keyword-only parameters, the not-yet-migrated Phase 4 test call sites made a zero-error result
impossible until Phase 4 completed the migration. Both gates now report 0 errors, so every one of the
26 test call sites [P3-T8] classified PENDING-PHASE-4 is migrated, and the Phase 6 constant-import
refactor introduced no new type error.

One error surfaced on the first run of the [P4-T13] gate and was fixed there — an invariant-`list`
argument-type error at `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py`
where `list(UNSTARTED_KEYS)` narrowed to `list[Literal[444, 445]]`, corrected by annotating the local
as `unstarted: list[int]`. No error remains.

Baseline comparison: the Phase 0 baseline
(`<FEATURE>/evidence/remediation-baseline/remediation1-baseline-py-typecheck.md`) recorded
`0 errors, 0 warnings, 0 informations`, so there is **no type-check regression**.
