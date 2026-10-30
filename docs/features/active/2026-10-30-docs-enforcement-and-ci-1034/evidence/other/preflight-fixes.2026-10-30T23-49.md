# Preflight Fixes

Timestamp: 2026-10-30T23-49
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/plan.2026-10-30T18-40.md
Round: 1 (single-pass preflight, preparation mode; no task executed, no checkbox changed)

## Fix 1

- Task: [P0-T5]
- Defect class: validator-blind unsatisfiable condition whose correction keeps the assertion's meaning (baseline population narrower than the consuming gate).
- Before: the baseline Pester run covered `tests/scripts/claude-lib/docs`, `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime` only, while [P6-T3] and the fresh single-process run of [P6-T4] run over `tests/scripts` and exempt only "the baseline failures of [P0-T5]". A pre-existing failure in any other folder under `tests/scripts` could not be exempted, so those gates could fail for reasons unrelated to this plan.
- After: the baseline run covers `tests/scripts`, the same population as [P6-T3] and [P6-T4]. The recorded fields (pass and fail counts, pre-existing failures by name, line coverage of `Invoke-DocsCommand.ps1` and `DocsProfileCommands.psm1`) are unchanged.

## Fix 2

- Task: [P6-T1]
- Defect class: write-mode command observed by a signal that cannot fail (G7 class, not detected by the validator for this wording).
- Before: the formatter result was judged by comparing `git status --porcelain` before and after. A rewrite of a file that is already modified (` M`) or untracked (`??`) leaves the porcelain listing unchanged, so the condition passed whether or not the formatter changed a file.
- After: the task records the SHA-256 of each formatted file before and after the run, and the acceptance requires every pair to be identical. The meaning of the condition (the formatter changed nothing) is unchanged.
