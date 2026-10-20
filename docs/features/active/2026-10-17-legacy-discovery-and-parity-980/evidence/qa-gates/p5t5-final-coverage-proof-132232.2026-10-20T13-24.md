# P5-T5 final coverage-proof

Timestamp: 2026-10-20T13-24
Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p5t5_final_coverage.py SCRATCH\candidate-released.json SCRATCH\p5t5-final-132232-combined-coverage.json SCRATCH\p5t5-final-132232-coverage-result.json`
EXIT_CODE: 1
Output Summary: Stage 6; 1.016 seconds; 0 completed nodes; timeout=False; changed bindings=0.

```text
Traceback (most recent call last):
  File "SCRATCH\p5t5_final_coverage.py", line 210, in <module>
    main()
    ~~~~^^
  File "SCRATCH\p5t5_final_coverage.py", line 179, in main
    assert len(named_lines & proof_lines) / len(named_lines) >= .9, (path, name, "named line floor")
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: ('packages/discovery-runtime/src/drm_copilot_discovery/gherkin.py', '_trace', 'named line floor')

```
