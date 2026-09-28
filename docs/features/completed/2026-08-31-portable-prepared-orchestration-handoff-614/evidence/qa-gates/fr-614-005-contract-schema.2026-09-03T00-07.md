# Contract and Schema Compatibility — P3-T14

Timestamp: 2026-09-06T00-00
Task: [P3-T14]
Working directory: repository root

Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_schema.py tests/scripts/dev_tools/test_orchestration_handoff_versions.py tests/scripts/dev_tools/test_validate_orchestrator_state.py`
EXIT_CODE: 0

```
tests\scripts\dev_tools\test_orchestration_handoff_schema.py .........   [ 28%]
tests\scripts\dev_tools\test_orchestration_handoff_versions.py .......   [ 50%]
tests\scripts\dev_tools\test_validate_orchestrator_state.py ............ [ 87%]
....                                                                     [100%]

============================= 32 passed in 0.17s ==============================
```

Passed: 32
Failed: 0
Skipped: 0

This equals the 32-case baseline recorded in
`evidence/remediation-baseline/contract-schema.2026-09-03T00-07.md`.

## Failure-order and schema stability

`HANDOFF_FAILURE_PRECEDENCE` in
`extensions/drm-copilot/src/lib/validate/orchestration-handoff-validation.ts`
is unchanged by this remediation: `git status --porcelain=v1
--untracked-files=all` does not list that file, so the sixteen-code order is
byte-identical to the reviewed head. The remediation adds no failure code and
reorders none; it changes only which values the existing codes are decided
against.

`config/orchestration-handoff.schema.json`,
`config/orchestration-handoff-registry.json`, and their published copies under
`extensions/drm-copilot/resources/config/` are likewise absent from the
porcelain span, so the provider-neutral envelope schema and the legacy
compatibility surface are unmodified.

Output Summary: Pytest exited 0 with all 32 baseline contract and schema
compatibility cases passing. The sixteen-code failure order is unchanged and no
provider-neutral schema or legacy compatibility regression was introduced.
