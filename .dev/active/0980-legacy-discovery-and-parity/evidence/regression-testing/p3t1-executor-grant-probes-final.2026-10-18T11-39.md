# P3-T1 final bounded probe: regressions

Timestamp: 2026-10-18T11-39
Command: poetry run python 'SCRATCH/issue-980-p3t1-initial-probes.py' 'Opaque payload grant cannot create a structured evidence record' 'Directory enumeration order is semantically irrelevant'
EXIT_CODE: 0
Output Summary: Two correction probes passed: opaque payload grants cannot conceal structured identity, and directory enumeration order is normalized.

The source hashes were stable throughout this command. Exact results and hashes are in [p3t1-executor-grant-probes-final.2026-10-18T11-39.json](p3t1-executor-grant-probes-final.2026-10-18T11-39.json). This is bounded task evidence, not final task or feature acceptance.

```text
{"name": "Opaque payload grant cannot create a structured evidence record", "passed": true, "rejected": "MUTATION_IDENTITY", "message": "MUTATION_IDENTITY: Proposed artifact kind/ID differs"}
{"name": "Directory enumeration order is semantically irrelevant", "passed": true, "stable_snapshot": "5e57fe61e126bf065d2bb1ea3a975da7145c99afc87814dab18119bb9ae3c1b2", "shuffled_snapshot": "5e57fe61e126bf065d2bb1ea3a975da7145c99afc87814dab18119bb9ae3c1b2"}
```
