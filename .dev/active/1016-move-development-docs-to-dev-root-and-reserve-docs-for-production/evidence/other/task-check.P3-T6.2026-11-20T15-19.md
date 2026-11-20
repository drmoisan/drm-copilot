# Task Check [P3-T6]

Timestamp: 2026-11-20T15-19
Command: sh SCRATCH/issue-1016-tc-p3t6.sh; sh SCRATCH/issue-1016-pstc.sh <each edited Pester file>
EXIT_CODE: 0
Output Summary: First run: Ruff E501 on the new loop comment and 1 failed (test_architecture_document_links_the_planning_prerequisite, the moved document keeps its docs/engineering text); both fixed (decision D-P3T6-1 in manual-literal-edits.2026-11-20T15-19.md). Second run: Black "3 files would be left unchanged.", Ruff "All checks passed!", Pyright 0 errors; pytest 90 passed, 0 failed; Pester 27 tests, 0 failures (exit 0); PowerShell format drift 0 and PSSA findings 0 for each edited file.

## Changed files

`tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`.

## Selection and rule

Mirrored-test rule for changed test and test-support files: each edited test file, plus every test file that imports the edited support module (`parallel_orchestrator_surface_expectations.py` is imported by `test_parallel_orchestrator_surface_contracts.py` and `test_parallel_planner_surface_contracts.py`), plus `ProcessReductionChain.Ledger.Tests.ps1` because two edited files are `LEDGER_PINNED`.
