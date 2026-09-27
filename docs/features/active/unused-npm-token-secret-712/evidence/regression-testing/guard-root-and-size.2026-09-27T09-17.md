# Guard Module Root Derivation and Size (P1-T10)

Timestamp: 2026-09-27T09-17
Command: grep -c -F "Path(__file__).resolve().parents[3]" tests/scripts/dev_tools/test_workflow_npm_token_guard.py
EXIT_CODE: 0
Output Summary: 1 (the repository root is derived from the test file's own location, exactly once)

Command 2: grep -c "" tests/scripts/dev_tools/test_workflow_npm_token_guard.py
EXIT_CODE 2: 0
Output Summary 2: 263 (line count; within the 500-line limit)
