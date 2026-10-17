# Fail-Before Exception Dossier: CR-8 Python (P2-T8)

Timestamp: 2026-10-16T06-27
Command: ls docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/fail-before-cr8-python.*.md (search for a failing Python CR-8 run)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: No failing Python CR-8 run exists or can exist; the alternative proof is recorded below.
Finding: CR-8 (Python)

WhyFailingRunImpossible: The old `_plan_path` (`scripts/dev_tools/epic_planner_git_integrity.py` lines 167-173) returns `PurePosixPath(value).as_posix()` for every non-blank string. `_relative_path` (`scripts/dev_tools/epic_planner_readiness.py` lines 102-112) returns that same value for every string it accepts and derives no plan for every string it rejects (the readiness caller appends a plan only when one is derived, lines 360-361), so no plan the readiness caller passes can be paired differently before and after the change.

Alternative proof:
- `evidence/regression-testing/rc2-python-authority-before.2026-10-16T06-26.md` (P2-T7): on pre-fix Python, `test_planning_commit_prefix_matches_dot_prefixed_plan_path` and every readiness-path case pass (20 passed), so the dot-prefixed pairing is already correct before the change.
- The P3-T3 pass-after artifact `evidence/regression-testing/pass-after-cr8-cr10-python.<timestamp>.md` records the same twenty node IDs passing after the shared derivation is introduced.

SearchScope: docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/
SearchPatterns: fail-before-cr8-python.*.md
SearchResult: none
