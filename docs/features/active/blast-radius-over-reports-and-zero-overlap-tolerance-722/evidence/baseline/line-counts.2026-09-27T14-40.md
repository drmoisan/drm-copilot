# Pre-change Line Counts (P0-T13)

Timestamp: 2026-09-27T14-40
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 scripts/dev_tools/compute_blast_radius.py scripts/dev_tools/_blast_radius_validation.py scripts/dev_tools/parallel_drift_detection.py .claude/lib/blast-radius/BlastRadius.psm1 .claude/lib/blast-radius/BlastRadiusValidation.psm1 extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
EXIT_CODE: 0
Output Summary: Exit 0; one LineCount line per file (eleven lines). Every printed value equals the planning-time value (421, 464, 499, 438, 374, 380, 472, 149, 237, 257, 271). The printed values are the baseline.

## Printed output

```text
scripts/dev_tools/compute_blast_radius.py LineCount=421
scripts/dev_tools/_blast_radius_validation.py LineCount=464
scripts/dev_tools/parallel_drift_detection.py LineCount=499
.claude/lib/blast-radius/BlastRadius.psm1 LineCount=438
.claude/lib/blast-radius/BlastRadiusValidation.psm1 LineCount=374
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts LineCount=380
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts LineCount=472
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts LineCount=149
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts LineCount=237
tests/scripts/dev_tools/blast_radius_parity_test_support.py LineCount=257
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 LineCount=271
```

## Comparison with planning-time values

| File | Planning | Printed | Equal |
| --- | --- | --- | --- |
| compute_blast_radius.py | 421 | 421 | yes |
| _blast_radius_validation.py | 464 | 464 | yes |
| parallel_drift_detection.py | 499 | 499 | yes |
| BlastRadius.psm1 | 438 | 438 | yes |
| BlastRadiusValidation.psm1 | 374 | 374 | yes |
| claude-blast-radius-derive-core.ts | 380 | 380 | yes |
| blast-radius-derive.test.ts | 472 | 472 | yes |
| blast-radius-derive-mergeable.test.ts | 149 | 149 | yes |
| config-carriage.test-helpers.ts | 237 | 237 | yes |
| blast_radius_parity_test_support.py | 257 | 257 | yes |
| BlastRadius.KeyPartition.Tests.ps1 | 271 | 271 | yes |
