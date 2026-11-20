# Preflight Fixes (single-pass preflight, #964 validation step O1)

Timestamp: 2026-10-17T02-53
Plan: docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/plan.md
Requirements source: docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/spec.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/plan.md
EXIT_CODE: 0
Output Summary: plan validation passed before and after the in-place fixes below. Six trivial defects fixed in place; two substantive defects returned to the planner (P3-T1, P3-T2). No task added, removed, or reordered.

## Fix 1 — [P0-T1] | policy-read citation correction

- Defect: the policy list omitted `.claude/rules/python-suppressions.md`, which `policy-compliance-order` lists for Python and which applies to the Python test module in scope, and `.claude/rules/ci-workflows.md`, whose `paths:` scope is `.github/workflows/**` and which governs the `pwsh` step the plan adds to `ci.yml`.
- Change: both files added to the read list; the acceptance count changed from eight to ten files.

## Fix 2 — [P1-T4] | validator-blind class: tracked-only tool against a created file

- Defect: `scripts/dev_tools/check_quality_tiers.py` discovers projects from `git ls-files -z`. The `scripts/ci/` files created by [P1-T2] and [P1-T3] are untracked when [P1-T4] runs, so the new `scripts/ci` entry would be reported as QT007 (`entry 'scripts/ci' is not a discovered project`) and the checker would exit non-zero. Same mechanism as `git grep` against a file the plan creates.
- Change: the task text now stages `scripts/ci/` with `git add scripts/ci` before the checker runs. The asserted outcome (checker exits 0) is unchanged.

## Fix 3 — [P2-T1] | literal formatting of a test name

- Defect: spec AC-36 requires a Pester test tagged `(AC-36)`; the plan's naming convention produces `[AC-36]` only.
- Change: each `[AC-36]` testcase name also carries the literal `(AC-36)`.

## Fix 4 — Design Decisions Derived From the Current Tree, item 2, third bullet | citation correction

- Defect: the justification for narrowing `test_threshold_step_runs_on_every_matrix_leg` cited AC-26, which covers only Pester suites. The criterion that conflicts with AC-20 is AC-32, which requires every heavy job, including the `quality-checks7` Pytest legs that run this module, to succeed.
- Change: AC-26 replaced by AC-32 with that reason.

## Fix 5 — [P4-T1] | observation that cannot fail (write-mode formatter)

- Defect: at [P4-T1] every in-scope PowerShell file is already modified or untracked, so a formatter rewrite leaves its porcelain status code unchanged; the before-and-after porcelain comparison could not detect a change.
- Change: the observation is now the SHA-256 hash of every in-scope file before and after the run. The asserted outcome (the run changed no file) is unchanged.

## Fix 6 — [P4-T6] | observation that cannot fail (write-mode formatter)

- Defect: same mechanism as Fix 5 for the shell format step; `scripts/bash/shell_qc_lib.sh` and `scripts/bash/shell-qc.sh` are already modified at this point.
- Change: the observation is now the SHA-256 hash of every shell file the format step covers, before and after the run.
