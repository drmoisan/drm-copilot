# P5-T3 final static

Timestamp: 2026-10-20T09-39
Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\final_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p5t3-final-candidate-preparation.2026-10-20T09-39.json`
EXIT_CODE: 1
Output Summary: Stage 4; 1.016 seconds; 0 completed nodes; timeout=False; changed bindings=0.

```text
Traceback (most recent call last):
  File "SCRATCH\final_static.py", line 95, in <module>
    main()
    ~~~~^^
  File "SCRATCH\final_static.py", line 61, in main
    assert ast.get_docstring(node), (relative, node.name)
           ~~~~~~~~~~~~~~~~~^^^^^^
AssertionError: ('tests/scripts/dev_tools/discovery/test_io.py', 'fake_read_text')

```
