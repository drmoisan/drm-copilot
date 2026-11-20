# P0-T7 File-Path Invocation Defect Reproduction

Timestamp: 2026-10-09T02-59
Command: poetry run python -S scripts/dev_tools/validate_orchestration_artifacts.py --help
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Traceback raised at line 16 (`from scripts.dev_tools.epic_planner_readiness import build_epic_readiness_context`).
- Last stderr line: `ModuleNotFoundError: No module named 'scripts'`
- Result: defect reproduced against the unmodified dispatcher (PASS for this task).
