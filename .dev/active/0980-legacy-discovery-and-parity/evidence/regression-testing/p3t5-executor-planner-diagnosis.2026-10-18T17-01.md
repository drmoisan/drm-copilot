# P3-T5 generated-link diagnosis

Timestamp: 2026-10-18T17:01:07Z
Command: `poetry run python SCRATCH/issue-980-p3t5-planner-diagnosis.py`
EXIT_CODE: 1
Output Summary: Reproduced the single real runtime-evidence planning failure with original findings and stable source SHA-256.

The command isolates the already-failing positive; it adds no broader review or production changes. The common schema at schemas/discovery/v2/common.schema.json lines 28–44 rejects a path-only reference. The worker received this bounded correction and must retain a successful actual planner regression.

[Raw diagnosis](p3t5-executor-planner-diagnosis.2026-10-18T17-01.json).

```text
{
  "source_before": "553b8afe4a86c6b5b1f23003b5fb421683abace78cdbbad0e5dbead371cbd6a5",
  "ok": false,
  "error": "MUTATION_INVALID: Prospective graph is invalid",
  "findings": [
    {
      "code": "SCHEMA_INVALID",
      "path": "docs/migration/discovery/feature-contracts/feature.json",
      "pointer": "/runtime_evidence_refs/0",
      "message": "'repository' is a dependency of 'path'"
    },
    {
      "code": "SCHEMA_INVALID",
      "path": "docs/migration/discovery/feature-contracts/feature.json",
      "pointer": "/runtime_evidence_refs/0",
      "message": "'revision' is a dependency of 'path'"
    },
    {
      "code": "SCHEMA_INVALID",
      "path": "docs/migration/discovery/feature-contracts/feature.json",
      "pointer": "/runtime_evidence_refs/0",
      "message": "'sha256' is a dependency of 'path'"
    }
  ],
  "source_after": "553b8afe4a86c6b5b1f23003b5fb421683abace78cdbbad0e5dbead371cbd6a5"
}
```
