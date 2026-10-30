# P3-T1 provider probe interface correction

Timestamp: 2026-10-18 11:19:45 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-provider-probes.py`

EXIT_CODE: 1

## Output Summary

The first three provider probes did not reach their assertions: the specialist added the required `Directory.identity()` interface while the verifier was preparing the memory adapter, and that adapter had not yet implemented it. All three cases raised `AttributeError`; this is a probe-fixture failure and is not evidence of a production regression. Source bytes remained stable during the run at SHA-256 `69f2b59123d7651fc3d3634a67786488b22f4f78b9c0a65f4683870f78e4f831`.

The raw result is retained in [structured evidence](p3t1-executor-provider-interface.2026-10-18T11-19.json). The corrective action is to implement the accepted handle-identity seam in the memory adapter and exercise the actual native staging implementation through mocked OS operations. No production file was changed by the verifier. The prior provider review findings remain pending corrected behavioral proof.
