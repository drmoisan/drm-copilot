# P6-T1 final static

Timestamp: 2026-10-21T06-03

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t1_final_nio1_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t1-final-candidate-static-qualified.2026-10-21T06-02.json`

EXIT_CODE: 1

Output Summary: FAIL; 0.412 seconds; 0 passed nodes; timeout=False.

```text

Traceback (most recent call last):
  File "SCRATCH\p6t1_final_nio1_static.py", line 207, in <module>
    main()
    ~~~~^^
  File "SCRATCH\p6t1_final_nio1_static.py", line 197, in main
    old = definitions(ast.parse(previous))[source_name]
          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^
KeyError: 'run_local_git.expire'
```
