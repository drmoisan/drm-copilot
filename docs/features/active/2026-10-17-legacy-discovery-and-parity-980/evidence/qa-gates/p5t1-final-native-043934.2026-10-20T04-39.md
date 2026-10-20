# P5-T1 final native

Timestamp: 2026-10-20T04-39
Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\issue-980-p5t1-final-native.py SCRATCH\issue-980-p5t1-final-043934-native-result.raw.json`
EXIT_CODE: 1
Output Summary: Stage 7; elapsed 21.048 seconds; completed nodes 0; timeout=False.

```text
PASS actual loader retains profile, scope, inventory, ledger and checksummed evidence
PASS materialized complete no-scope graph is structurally valid
PASS confirmed no-scope reports justified discovery completion
PASS empty denominators retain null ratios and explicit zero runtime obligations
PASS producer and authoritative public projection agree exactly
PASS JSON and Markdown render the same detached fields
PASS identical captured input renders deterministically
PASS generation and validation preserve the immutable capture
Traceback (most recent call last):
  File "SCRATCH\issue-980-p5t1-final-native.py", line 182, in <module>
    check("previous JSON and Markdown outputs do not alter semantic identity or counts",
    ~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          report_input_digest(previous) == report_input_digest(snapshot)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          and previous_report.document == report.document and previous.sha256 != snapshot.sha256)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "SCRATCH\issue-980-p5t1-final-native.py", line 35, in check
    raise AssertionError(name)
AssertionError: previous JSON and Markdown outputs do not alter semantic identity or counts

```
