# P6-T1 final coverage-proof

Timestamp: 2026-10-21T11-43

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t1_final_nio1_coverage.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t1-final-capture-comment-candidate.2026-10-21T10-32.json SCRATCH\p6t1-final-103256-coverage.json SCRATCH\p6t1-final-103256-coverage-result.json`

EXIT_CODE: 1

Output Summary: FAIL; 1.411 seconds; 0 passed nodes; timeout=False.

```text

Traceback (most recent call last):
  File "SCRATCH\p6t1_final_nio1_coverage.py", line 234, in <module>
    main()
    ~~~~^^
  File "SCRATCH\p6t1_final_nio1_coverage.py", line 197, in main
    assert not unit_lines or len(effective) / len(unit_lines) >= .9, (path, name, "raw AST line floor")
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: ('packages/discovery-runtime/src/drm_copilot_discovery/operations.py', 'OperationContext.read', 'raw AST line floor')
```
