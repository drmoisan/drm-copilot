# P5-T3 final native

Timestamp: 2026-10-20T09-44
Command: `WORKSPACE\.venv\Scripts\python.exe -u NATIVE_SCRATCH\issue-980-p5t3-native-composition.py NATIVE_SCRATCH\issue-980-p5t3-native-fixture.2026-10-20T08-50.json NATIVE_SCRATCH\issue-980-p5t3-native-result.json --release NATIVE_SCRATCH\issue-980-p5t3-native-release.json`
EXIT_CODE: 1
Output Summary: Stage 5; 7.029 seconds; 0 completed nodes; timeout=False; changed bindings=0.

```text
PASS accepted-fixture-byte-identity
PASS checkout-identity
PASS captured-byte-identity
PASS semantic-input-identity
PASS actual-core-structural-pass
Traceback (most recent call last):
  File "NATIVE_SCRATCH\issue-980-p5t3-native-composition.py", line 297, in <module>
    main()
    ~~~~^^
  File "NATIVE_SCRATCH\issue-980-p5t3-native-composition.py", line 173, in main
    check("completion-output-absence", all(snapshot.file(path) is None for path in outputs))
                                       ~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "NATIVE_SCRATCH\issue-980-p5t3-native-composition.py", line 173, in <genexpr>
    check("completion-output-absence", all(snapshot.file(path) is None for path in outputs))
                                           ~~~~~~~~~~~~~^^^^^^
  File "WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py", line 270, in file
    raise KeyError(path)
KeyError: 'docs/migration/discovery/reports/completion-report.json'

```
