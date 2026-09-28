# Final Line Counts (P18-T1)

Timestamp: 2026-09-27T18-14
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <the 64 files written by this plan outside the feature folder>
EXIT_CODE: 0
Output Summary: PASS. Script line-counts (A4) exited 0 and printed one LineCount line for each of the 64 files written by this plan outside the feature folder (the FINAL_BASE-anchored name diff, git diff --name-only beae3f021674e64fa6662097fe48a332d8da62b8, excluding the feature folder). Every production and test file is at most 500 lines; the largest are _blast_radius_scheduling.py 495, test_blast_radius_write_intent.py 495, BlastRadius.Tests.ps1 492, and BlastRadiusScheduling.psm1 490 (and its mirror). The drift module parallel_drift_detection.py is 460 lines, at most its P0-T13 value of 499. The only files above 500 lines are Markdown documentation (the parallel-orchestration rule file and the parallel-plan skill, 624 and 619, with their mirrors) and two JSON historical-run fixtures (710 and 1467), which the 500-line policy exempts as documentation and test data respectively (the plan's batch-budget section records that JSON fixtures follow the verification-integrity fixture precedent). The feature-folder files are Markdown documentation.

## Production and test code files

| File | Kind | LineCount | <= 500 |
| --- | --- | --- | --- |
| scripts/dev_tools/_blast_radius_scheduling.py | Python production | 495 | yes |
| scripts/dev_tools/_blast_radius_validation.py | Python production | 468 | yes |
| scripts/dev_tools/_blast_radius_write_intent.py | Python production | 421 | yes |
| scripts/dev_tools/_parallel_drift_scheduling.py | Python production | 143 | yes |
| scripts/dev_tools/compute_blast_radius.py | Python production | 473 | yes |
| scripts/dev_tools/parallel_drift_detection.py | Python production (drift module; P0-T13 value 499) | 460 | yes |
| .claude/lib/blast-radius/BlastRadius.psm1 (and mirror) | PowerShell production | 475 | yes |
| .claude/lib/blast-radius/BlastRadiusScheduling.psm1 (and mirror) | PowerShell production | 490 | yes |
| .claude/lib/blast-radius/BlastRadiusValidation.psm1 (and mirror) | PowerShell production | 377 | yes |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 (and mirror) | PowerShell production | 446 | yes |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (and mirror) | PowerShell settings | 330 | yes |
| extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts | TypeScript production | 394 | yes |
| extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts | TypeScript test | 156 | yes |
| extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts | TypeScript test | 171 | yes |
| extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts | TypeScript test | 484 | yes |
| extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts | TypeScript test helper | 254 | yes |
| extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts | TypeScript test | 193 | yes |
| tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | Pester test | 140 | yes |
| tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | Pester test | 291 | yes |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | Pester test | 492 | yes |
| tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | Pester test | 359 | yes |
| tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | Pester test | 323 | yes |
| tests/scripts/dev_tools/blast_radius_parity_test_support.py | Python test support | 277 | yes |
| tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py | Python test | 153 | yes |
| tests/scripts/dev_tools/test_blast_radius_historical_runs.py | Python test | 266 | yes |
| tests/scripts/dev_tools/test_blast_radius_mandate_reads.py | Python test | 232 | yes |
| tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py | Python test | 408 | yes |
| tests/scripts/dev_tools/test_blast_radius_scheduling.py | Python test | 428 | yes |
| tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py | Python test | 197 | yes |
| tests/scripts/dev_tools/test_blast_radius_write_intent.py | Python test | 495 | yes |
| tests/scripts/dev_tools/test_parallel_drift_scheduling.py | Python test | 255 | yes |
| tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py | Python test | 99 | yes |

## A4 output (verbatim)

```text
.claude/agents/parallel-planner.md LineCount=221
.claude/lib/blast-radius/BlastRadius.psm1 LineCount=475
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=490
.claude/lib/blast-radius/BlastRadiusValidation.psm1 LineCount=377
.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 LineCount=446
.claude/rules/parallel-orchestration.md LineCount=624
.claude/skills/parallel-add/SKILL.md LineCount=180
.claude/skills/parallel-plan/SKILL.md LineCount=619
config/blast-radius.json LineCount=81
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md LineCount=221
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 LineCount=475
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=490
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusValidation.psm1 LineCount=377
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 LineCount=446
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md LineCount=624
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md LineCount=180
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md LineCount=619
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json LineCount=49
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json LineCount=187
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=330
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts LineCount=394
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts LineCount=156
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts LineCount=171
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts LineCount=484
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts LineCount=254
extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts LineCount=193
scripts/dev_tools/_blast_radius_scheduling.py LineCount=495
scripts/dev_tools/_blast_radius_validation.py LineCount=468
scripts/dev_tools/_blast_radius_write_intent.py LineCount=421
scripts/dev_tools/_parallel_drift_scheduling.py LineCount=143
scripts/dev_tools/compute_blast_radius.py LineCount=473
scripts/dev_tools/parallel_drift_detection.py LineCount=460
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=330
tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json LineCount=710
tests/fixtures/blast_radius/historical-runs/epic-655-followups.json LineCount=499
tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json LineCount=1467
tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json LineCount=87
tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json LineCount=75
tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json LineCount=69
tests/fixtures/blast_radius/scheduling/scheduling-absent-key-strict.json LineCount=85
tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json LineCount=97
tests/fixtures/blast_radius/write-intent/write-intent-command-span.json LineCount=39
tests/fixtures/blast_radius/write-intent/write-intent-flag-absent-matches-current.json LineCount=63
tests/fixtures/blast_radius/write-intent/write-intent-glob-mention.json LineCount=39
tests/fixtures/blast_radius/write-intent/write-intent-placeholder-stem.json LineCount=39
tests/fixtures/blast_radius/write-intent/write-intent-read-task.json LineCount=39
tests/fixtures/blast_radius/write-intent/write-intent-root-anchoring.json LineCount=58
tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json LineCount=93
tests/fixtures/blast_radius/write-intent/write-intent-spec-contracts-only.json LineCount=39
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 LineCount=140
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 LineCount=291
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 LineCount=492
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 LineCount=359
tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 LineCount=323
tests/scripts/dev_tools/blast_radius_parity_test_support.py LineCount=277
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py LineCount=153
tests/scripts/dev_tools/test_blast_radius_historical_runs.py LineCount=266
tests/scripts/dev_tools/test_blast_radius_mandate_reads.py LineCount=232
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py LineCount=408
tests/scripts/dev_tools/test_blast_radius_scheduling.py LineCount=428
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py LineCount=197
tests/scripts/dev_tools/test_blast_radius_write_intent.py LineCount=495
tests/scripts/dev_tools/test_parallel_drift_scheduling.py LineCount=255
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py LineCount=99
(exit 0)
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
