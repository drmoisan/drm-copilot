# P2-T9 preliminary independent mode/output probes

Timestamp: 2026-10-18 10:32:24 UTC

Command: `poetry run python SCRATCH/issue-980-probe-p2t9.py`

EXIT_CODE: 1

## Output Summary

- 36 of 38 cases passed. Two cases failed in fixture construction because the probe used `configuration_sha256` instead of the declared `scan_configuration_sha256`; neither case reached the production gate assertion.
- Production changed during the run as the specialist completed its approved same-component split. This is preliminary semantic evidence, not final byte-bound acceptance.
- Passing cases include the complete fixture in four modes, honest draft structural success versus discovery/parity/planning failure, explicit no-prerequisite planning, missing profile and malformed unreferenced input rejection, gate controls, output identity/precondition/role checks, selected versus unselected ledger changes, retained warning findings, and passing/failing reviewer reports captured with their output manifests.
- A valid failing reviewer output has `output_valid=true` and `validation_result=fail`; forged pass/findings/counts were rejected. Final binding and additional role/carry-forward cases remain.
- Corrective action: correct only the inventory fixture field, retain this result, and run the bounded report and remaining role cases. No production change was made by the verifier.

Structured results: [probe results](p2t9-executor-probes-initial.2026-10-18T10-32.json).
