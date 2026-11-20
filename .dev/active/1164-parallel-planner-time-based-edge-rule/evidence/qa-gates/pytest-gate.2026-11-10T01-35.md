# Final pytest Gate, After the Corpus Addition (P6-T6)

Timestamp: 2026-11-10T01-35
Command: sh SCRATCH/issue-1164-pytest-gate.sh issue-1164-cov-final4.json (env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-final4.json -p no:cacheprovider --junitxml=SCRATCH/issue-1164-cov-final4.json.junit.xml --cov)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T01-30 (UTC) after the corpus case reject-overlap-reasons-not-a-list.json was added; summary line "16659 passed, 6 skipped in 249.72s (0:04:09)"; 0 failed. This run supersedes pytest-gate.2026-11-10T01-28.md.
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13% (baseline 97.11%); branch 12758 / 13514 = 94.41% (baseline 94.38%).
- Per-file (JSON report), against the Phase 0 baseline: _blast_radius_scheduling.py 100.00% / 100.00% (171/171, 40/40); _parallel_drift_scheduling.py 100.00% / 100.00% (47/47, 18/18); parallel_drift_detection.py 100.00% / 100.00% (80/80, 26/26); _parallel_state_records.py 100.00% / 100.00% (191/191, 96/96); parallel_manifest_contract.py 100.00% / 100.00% (168/168, 82/82); validate_parallel_planner_state.py 100.00% / 100.00% (117/117, 46/46); validate_parallel_orchestrator_state.py 97.78% / 94.12% (88/90, 32/34; baseline 97.73% / 94.12%); parallel_drift_detection_cli.py 100.00% / 100.00% (75/75, 10/10). No file is below its baseline figure.
- Named tests and contract suites (same list as the previous record): NAMED_NOT_ALL_PASSED 0; test_parallel_state_scheduling_parity.py now has 22 cases (floor plus 21 corpus files).
