# P6-T1 final static

Timestamp: 2026-10-21T05-52

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t1_final_nio1_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t1-final-candidate-released.2026-10-21T05-51.json`

EXIT_CODE: 1

Output Summary: FAIL; 0.209 seconds; 0 passed nodes; timeout=False.

```text

Traceback (most recent call last):
  File "SCRATCH\p6t1_final_nio1_static.py", line 162, in <module>
    main()
    ~~~~^^
  File "SCRATCH\p6t1_final_nio1_static.py", line 127, in main
    assert not any(name.endswith((".read_bytes", ".read_text", ".glob", ".rglob"))
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                   and relative not in manifest["reviewed_native_io_paths"] for name in calls), relative
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py
```
