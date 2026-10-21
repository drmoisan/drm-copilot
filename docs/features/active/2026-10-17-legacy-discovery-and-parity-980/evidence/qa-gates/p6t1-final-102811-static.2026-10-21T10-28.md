# P6-T1 final static

Timestamp: 2026-10-21T10-28

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t1_final_nio1_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t1-final-capture-candidate-released.2026-10-21T10-28.json`

EXIT_CODE: 1

Output Summary: FAIL; 0.460 seconds; 0 passed nodes; timeout=False.

```text

Traceback (most recent call last):
  File "SCRATCH\p6t1_final_nio1_static.py", line 216, in <module>
    main()
    ~~~~^^
  File "SCRATCH\p6t1_final_nio1_static.py", line 162, in main
    assert exact.get(str(node.lineno)) == hashlib.sha256(ast.dump(node).encode()).hexdigest(), (relative, node.lineno)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: ('tests/discovery_runtime/test_migration_capture.py', 54)
```
