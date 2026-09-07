# Baseline — edit-target line counts (issue #643, task [P0-T3])

- Timestamp: 2026-09-07T15:10Z
- Command: `wc -l` over the sixteen paths of plan constraint C2 plus `scripts/dev_tools/compute_blast_radius.py`, `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, and `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, run from the worktree root
- EXIT_CODE: 0

## Output Summary

Every count below is the observed value on the current tree. The 500-line ceiling of
`.claude/rules/general-code-change.md` applies to all nineteen paths (all are production code,
test code, or reusable script files; none is Markdown or a raw text fixture). Headroom is
`500 - count`.

### Constraint C2 table paths

| File | Observed lines | Headroom to 500 | C2 table value | Reconciliation |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` | 500 | 0 | 500 | matches |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 499 | 1 | 499 | matches |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 495 | 5 | 495 | matches |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py` | 486 | 14 | 486 | matches |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 482 | 18 | 482 | matches |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 473 | 27 | 473 | matches |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 472 | 28 | 472 | matches |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 468 | 32 | 468 | matches |
| `scripts/dev_tools/_blast_radius_validation.py` | 464 | 36 | 464 | matches |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | 461 | 39 | 461 | matches |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | 435 | 65 | 435 | matches |
| `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py` | 420 | 80 | 420 | matches |
| `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts` | 417 | 83 | 417 | matches |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 325 | 175 | 325 | matches |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | 268 | 232 | 268 | matches |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 241 | 259 | 241 | matches |

All sixteen observed counts equal their C2 table values. No authoritative-value substitution was
required, and every task-text bound stated in C2 applies unchanged.

### Additional paths named by [P0-T3]

| File | Observed lines | Headroom to 500 | C2 table value | Reconciliation |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/compute_blast_radius.py` | 419 | 81 | not in C2 table | recorded as the authoritative value; the [P1-T7] bound of at most 430 applies |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | 249 | 251 | not in C2 table | recorded as the authoritative value; the [P1-T3] bound of at most 260 applies |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 228 | 272 | not in C2 table | recorded as the authoritative value |

### Verbatim `wc -l` output

```text
   500 tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1
   499 tests/scripts/dev_tools/test_blast_radius_config_parity.py
   495 .claude/lib/blast-radius/BlastRadius.psm1
   486 tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py
   482 extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts
   473 .claude/lib/blast-radius/BlastRadiusConfig.psm1
   472 extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts
   468 extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
   464 scripts/dev_tools/_blast_radius_validation.py
   461 extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts
   435 tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
   420 tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py
   417 extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts
   325 tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
   268 tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
   241 scripts/dev_tools/_blast_radius_conflicts.py
   419 scripts/dev_tools/compute_blast_radius.py
   249 tests/scripts/dev_tools/blast_radius_parity_test_support.py
   228 extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts
  7802 total
```
