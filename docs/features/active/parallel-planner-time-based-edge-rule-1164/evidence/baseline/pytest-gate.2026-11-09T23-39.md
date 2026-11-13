# pytest Phase 0 Baseline (P0-T5)

Timestamp: 2026-11-09T23-39
Command: sh SCRATCH/issue-1164-pytest-gate.sh issue-1164-cov-baseline.json (env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-baseline.json -p no:cacheprovider --junitxml=SCRATCH/issue-1164-cov-baseline.json.junit.xml --cov)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-09T23-35 (UTC); summary line "16590 passed, 6 skipped in 217.50s (0:03:37)"; 0 failed.
- Repo-wide (JSON report totals): line 34334 / 35355 = 97.11%; branch 12669 / 13424 = 94.38% (terminal TOTAL row 96% combined).
- Per-file (JSON report):
  - scripts/dev_tools/_blast_radius_scheduling.py: line 100.00% (158/158), branch 100.00% (36/36)
  - scripts/dev_tools/_parallel_drift_scheduling.py: line 100.00% (33/33), branch 100.00% (10/10)
  - scripts/dev_tools/parallel_drift_detection.py: line 100.00% (79/79), branch 100.00% (26/26)
  - scripts/dev_tools/_parallel_state_records.py: line 100.00% (88/88), branch 100.00% (50/50)
  - scripts/dev_tools/parallel_manifest_contract.py: line 100.00% (113/113), branch 100.00% (50/50)
  - scripts/dev_tools/validate_parallel_planner_state.py: line 100.00% (115/115), branch 100.00% (46/46)
  - scripts/dev_tools/validate_parallel_orchestrator_state.py: line 97.73% (86/88), branch 94.12% (32/34)
  - Also recorded for comparison (call-site edit expected in P2-T5): scripts/dev_tools/parallel_drift_detection_cli.py: line 100.00% (74/74), branch 100.00% (10/10)
