# Preflight Fixes - Remediation Plan Cycle 1 (issue 1047)

Timestamp: 2026-11-03T19-17
Plan: docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/remediation-plan.2026-11-03T18-43.md
Directive: PREFLIGHT VALIDATION ONLY (single pass; no task executed, no box checked)

## Fixes

1. [P4-T3] | diff assertion against a file the branch adds (validator-blind) | The acceptance cited the merge-base diff of `spec.md` in [P6-T14]. `spec.md` is an added (`A`) file relative to the merge base, and [P6-T14] records name listings only, so that diff cannot show one added row. The acceptance now diffs `<FEATURE>/spec.md` anchored to the branch head ref recorded in [P0-T2] (worded without a bare command span, which the first revalidation reported under G8) and records the result in `<FEATURE>/evidence/other/spec-diff.<timestamp>.md`. The asserted outcome (one added `reuse-edges` row, no `## Acceptance Criteria` line changed) is unchanged.
2. [P6-T10] | citation correction | "the consumer of the branch's changed pin module" implied a single consumer; `tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py` also imports the pin module. The text now reads "the test module that imports the branch's changed pin module directly". The run and its acceptance are unchanged.
3. `## Pre-Mortem` File size bullet | file-size headroom note (validator-blind) | `Invoke-ParallelAdmission.Tests.ps1` is 534 logical lines and Phases 2 to 4 add about twenty Its to it, which puts the [P4-T4] limit of 700 at risk. The bullet now states the starting size and directs table-driven `-ForEach` Its where cases share a shape. The [P4-T4] acceptance is unchanged.

## Validation

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`) and the branch-current Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan` were run before and after the fixes.
