# AC16 Retained Python Reference (P6-T4)

Timestamp: 2026-09-29T18-44
Command: git ls-files -- scripts/dev_tools/parallel_drift_detection_cli.py scripts/dev_tools/parallel_mutation_abandon_cli.py scripts/dev_tools/parallel_drift_detection.py scripts/dev_tools/parallel_drift_halt.py scripts/dev_tools/parallel_drift_resolution.py scripts/dev_tools/_parallel_drift_cli_io.py scripts/dev_tools/_parallel_drift_scheduling.py scripts/dev_tools/_parallel_drift_shape.py scripts/dev_tools/_parallel_state_common.py ; poetry run pytest -v tests/scripts/dev_tools/test_parallel_drift_detection_cli.py tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py tests/scripts/dev_tools/test_parallel_mutation_protocol.py
EXIT_CODE: 0
Output Summary:
- CMD-GIT-LS printed all nine paths:
  scripts/dev_tools/_parallel_drift_cli_io.py
  scripts/dev_tools/_parallel_drift_scheduling.py
  scripts/dev_tools/_parallel_drift_shape.py
  scripts/dev_tools/_parallel_state_common.py
  scripts/dev_tools/parallel_drift_detection.py
  scripts/dev_tools/parallel_drift_detection_cli.py
  scripts/dev_tools/parallel_drift_halt.py
  scripts/dev_tools/parallel_drift_resolution.py
  scripts/dev_tools/parallel_mutation_abandon_cli.py
- pytest: `86 passed in 0.28s`, exit 0, no FAILED line.
