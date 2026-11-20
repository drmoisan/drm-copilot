# Final pytest Gate, First Run (P6-T6): Failed on the Branch

Timestamp: 2026-11-10T01-05
Command: sh SCRATCH/issue-1164-pytest-gate.sh issue-1164-cov-final.json (env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-final.json -p no:cacheprovider --junitxml=SCRATCH/issue-1164-cov-final.json.junit.xml --cov)
EXIT_CODE: 1
Output Summary:
- Run started 2026-11-10T00-59 (UTC); summary line "2 failed, 16653 passed, 6 skipped in 187.63s (0:03:07)".
- Failing tests (2), both failures on the branch:
  - tests/scripts/dev_tools/test_parallel_drift_detection_cli.py::test_main_dispatches_the_cli_inputs_into_the_pure_detection_function: its stub for detect_escaped_paths takes two positional arguments, and the drift CLI call site edited in P2-T5 (scripts/dev_tools/parallel_drift_detection_cli.py, in the merge-base diff) now passes read_paths=, so main returned 1.
  - tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_parent_write_target_has_a_persona_write_grant: the P5-T3 sentence added to .claude/skills/parallel-orchestrate/SKILL.md (in the merge-base diff) placed the path token /parallel-add immediately after the write verb "recorded", which the parser reads as a parent write target.
- Fixes: the stub gains the keyword-only read_paths parameter; the parallel-orchestrate sentence is reworded so the path token is not in a write-destination position (mirror copied). The QA loop restarts from formatting.
