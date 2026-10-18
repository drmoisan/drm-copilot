# P2-T7 expanded probe fixture correction

Timestamp: 2026-10-18 09:48:22 UTC
Started: 2026-10-18 09:47:42 UTC
Command: `poetry run python SCRATCH/issue-980-probe-p2t7.py`
EXIT_CODE: 1

Output summary: 33 semantic cases completed; 33 matched expectations before the next fixture failed authoritative schema validation. The unassigned coverage-row variant incorrectly omitted required nullable supporting_rationale. It will retain that key with null. This was an operational fixture error, not a production defect or task success. All completed consolidated correction cases passed; no final source binding is claimed.

```text
Traceback (most recent call last):
  File "SCRATCH\issue-980-probe-p2t7.py", line 146, in <module>
    run('zero-feature scope cannot conceal an undispositioned component', incomplete, acceptance_ok=False, ready_count=0)
    ~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "SCRATCH\issue-980-probe-p2t7.py", line 45, in run
    snapshot, index = graph(documents + support['evidence_set'](), profile=current_profile or support['PROFILE'], **(graph_options or {}))
                      ~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "SCRATCH\issue-980-p2t7-probe-support.py", line 110, in graph
    assert checked.ok, [(finding.code, finding.pointer, finding.message) for finding in checked.findings]
           ^^^^^^^^^^
AssertionError: [('SCHEMA_INVALID', '/components/0', "'supporting_rationale' is a required property")]
```
