# P6-T3 final static

Timestamp: 2026-10-21T17-17

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t1_final_nio1_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t3-final-candidate-released.2026-10-21T17-16.json`

EXIT_CODE: 1

Output Summary: FAIL; 0.211 seconds; 0 passed nodes; timeout=False.

```text

Traceback (most recent call last):
  File "SCRATCH\p6t1_final_nio1_static.py", line 216, in <module>
    main()
    ~~~~^^
  File "SCRATCH\p6t1_final_nio1_static.py", line 171, in main
    assert not any(name.endswith((".write_bytes", ".write_text", ".mkdir", ".unlink"))
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                   and relative not in manifest["reviewed_native_io_paths"]
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                   for name in calls), relative
                   ^^^^^^^^^^^^^^^^^^
AssertionError: tests/scripts/dev_tools/test_generate_acceptance_scenarios.py
```
