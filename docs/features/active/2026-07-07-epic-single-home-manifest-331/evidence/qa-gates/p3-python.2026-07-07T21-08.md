# Phase 3 QA Gate — Python (#331)

Timestamp: 2026-07-07T21-08
Toolchain order format -> lint -> type-check -> test. Black reformatted 2 files on
the first pass (validator + test); the loop was restarted and the second pass had
zero reformats.

Command: poetry run black .
EXIT_CODE: 0
Output Summary: "All done!" 231 files left unchanged (clean pass, no reformats).

Command: poetry run ruff check .
EXIT_CODE: 0
Output Summary: "All checks passed!" 0 findings.

Command: poetry run pyright
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations.

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 1309 passed, 0 failed. TOTAL line coverage 84% (unchanged from
baseline; pre-existing untested files). Changed modules:
validate_epic_orchestrator_state.py 95% line, _epic_orchestrator_state_resolution.py
94% line — both above the 85% line / 75% branch gates, no regression on changed
lines. New logic exercised by 11 new validator tests (issue_num keying,
active/completed hint resolution, presence-gated intent positive/negative/absent).

Note (file-size policy): the new resolver + intent validation and the moved
detect_dependency_cycle were placed in the sibling module
scripts/dev_tools/_epic_orchestrator_state_resolution.py (288 lines) to keep
validate_epic_orchestrator_state.py at 450 lines, under the repository 500-line
limit. This follows the documented _orchestrator_state_*.py sibling-delegate
precedent; the resolver remains a single shared helper consumed by every
dependency-aware check in the validator.
