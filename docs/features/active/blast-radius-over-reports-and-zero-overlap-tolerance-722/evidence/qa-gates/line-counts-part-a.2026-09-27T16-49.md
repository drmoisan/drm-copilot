# Line Counts, Part A (P7-T5)

Timestamp: 2026-09-27T16-49
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <the 27 Python, PowerShell, and TypeScript files written in Phases 1 through 5, listed below>
EXIT_CODE: 0
Output Summary: PASS. Script A4 exited 0 and printed one LineCount line per file (27 lines). Every value is at most 500 (maximum 495, scripts/dev_tools/_blast_radius_scheduling.py). The drift-detection module scripts/dev_tools/parallel_drift_detection.py is 460 lines, at most its P0-T13 value of 499. tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 (edited by P5-T12) is 490 lines.

## File set derivation

The file set is the output of `git diff --name-only beae3f021674e64fa6662097fe48a332d8da62b8 -- "*.py" "*.ps1" "*.psm1" "*.psd1" "*.ts"`
at the Phase 6 commit: every Python, PowerShell, and TypeScript file changed on this branch since
BASE_SHA. Phase 6 wrote Markdown only, so this is exactly the Phases 1-5 set; it includes the P5-T12
file and the bundled mirrors. The working tree had no uncommitted change to any of these files.

## Printed output

```text
.claude/lib/blast-radius/BlastRadius.psm1 LineCount=448
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=490
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 LineCount=448
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=490
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=327
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts LineCount=386
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts LineCount=152
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts LineCount=119
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts LineCount=480
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts LineCount=249
extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts LineCount=193
scripts/dev_tools/_blast_radius_scheduling.py LineCount=495
scripts/dev_tools/_parallel_drift_scheduling.py LineCount=143
scripts/dev_tools/compute_blast_radius.py LineCount=451
scripts/dev_tools/parallel_drift_detection.py LineCount=460
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=327
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 LineCount=113
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 LineCount=273
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 LineCount=490
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 LineCount=359
tests/scripts/dev_tools/blast_radius_parity_test_support.py LineCount=261
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py LineCount=79
tests/scripts/dev_tools/test_blast_radius_historical_runs.py LineCount=179
tests/scripts/dev_tools/test_blast_radius_scheduling.py LineCount=428
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py LineCount=197
tests/scripts/dev_tools/test_parallel_drift_scheduling.py LineCount=255
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py LineCount=99
```

## Drift module check

| File | P0-T13 value | Current value | Did not grow |
| --- | --- | --- | --- |
| scripts/dev_tools/parallel_drift_detection.py | 499 | 460 | yes |

SCRATCH denotes the executor session scratchpad directory (outside the repository).
