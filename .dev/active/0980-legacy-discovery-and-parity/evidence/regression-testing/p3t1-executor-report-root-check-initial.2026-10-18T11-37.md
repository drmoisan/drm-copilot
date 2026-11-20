# P3-T1 prerequisite verifier line-ending correction

Timestamp: 2026-10-18T11-37
Command: poetry run python SCRATCH/issue-980-verify-p3t1-report-root.py
EXIT_CODE: 1
Output Summary: The verifier normalized CRLF through read_text before reconstructing the accepted raw-byte SHA256. The narrow-delta assertion failed; this did not identify a production defect.

Read-only inspection confirmed 179 CR and 179 LF bytes in the current production file. The operational verifier now decodes read_bytes without newline translation before reversing the three authorized replacements. No repository source, test, gate result, plan, or acceptance criterion changed.

```text
Traceback (most recent call last):
  File "SCRATCH/issue-980-verify-p3t1-report-root.py", line 55, in <module>
    assert hashlib.sha256(restored.encode()).hexdigest() == prior[production]["sha256"], "Production delta exceeds the three authorized textual replacements"
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: Production delta exceeds the three authorized textual replacements
```
