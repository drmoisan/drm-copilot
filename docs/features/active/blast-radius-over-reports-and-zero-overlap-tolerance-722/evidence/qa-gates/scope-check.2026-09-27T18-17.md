# Scope Check (P18-T3)

Timestamp: 2026-09-27T18-17
Command: git diff --name-only beae3f021674e64fa6662097fe48a332d8da62b8 -- . ; git status --porcelain ; poetry run python SCRATCH/p18-scope-check.py <plan> <diff output> <untracked paths>
EXIT_CODE: 0
Output Summary: PASS. The FINAL_BASE-anchored name diff (FINAL_BASE beae3f021674e64fa6662097fe48a332d8da62b8) listed 231 paths (exit 0), and the porcelain status listed the plan (modified) and two untracked P18 artifacts under FEATURE (exit 0), 233 paths in total. A scratch classifier compared each path with the set of backticked paths in the plan and with the FEATURE prefix: 64 paths are backticked in the plan, 169 lie under FEATURE, 0 are out of scope. No path lies under .claude/lib/bash or the .github instructions directory, and the only path under the rules directory is .claude/rules/parallel-orchestration.md (forbidden count 0).

## Porcelain status at the time of the check

```text
 M docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/plan.2026-09-27T12-16.md
?? docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/qa-gates/batch-accounting.2026-09-27T18-16.md
?? docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/qa-gates/final-line-counts.2026-09-27T18-14.md
```

## Paths outside FEATURE (all backticked in the plan)

```text
.claude/agents/parallel-planner.md
.claude/lib/blast-radius/BlastRadius.psm1
.claude/lib/blast-radius/BlastRadiusScheduling.psm1
.claude/lib/blast-radius/BlastRadiusValidation.psm1
.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1
.claude/rules/parallel-orchestration.md
.claude/skills/parallel-add/SKILL.md
.claude/skills/parallel-plan/SKILL.md
config/blast-radius.json
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusValidation.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts
extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts
scripts/dev_tools/_blast_radius_scheduling.py
scripts/dev_tools/_blast_radius_validation.py
scripts/dev_tools/_blast_radius_write_intent.py
scripts/dev_tools/_parallel_drift_scheduling.py
scripts/dev_tools/compute_blast_radius.py
scripts/dev_tools/parallel_drift_detection.py
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json
tests/fixtures/blast_radius/historical-runs/epic-655-followups.json
tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json
tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json
tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json
tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json
tests/fixtures/blast_radius/scheduling/scheduling-absent-key-strict.json
tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json
tests/fixtures/blast_radius/write-intent/write-intent-command-span.json
tests/fixtures/blast_radius/write-intent/write-intent-flag-absent-matches-current.json
tests/fixtures/blast_radius/write-intent/write-intent-glob-mention.json
tests/fixtures/blast_radius/write-intent/write-intent-placeholder-stem.json
tests/fixtures/blast_radius/write-intent/write-intent-read-task.json
tests/fixtures/blast_radius/write-intent/write-intent-root-anchoring.json
tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json
tests/fixtures/blast_radius/write-intent/write-intent-spec-contracts-only.json
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
tests/scripts/dev_tools/blast_radius_parity_test_support.py
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py
tests/scripts/dev_tools/test_blast_radius_historical_runs.py
tests/scripts/dev_tools/test_blast_radius_mandate_reads.py
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py
tests/scripts/dev_tools/test_blast_radius_scheduling.py
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py
tests/scripts/dev_tools/test_blast_radius_write_intent.py
tests/scripts/dev_tools/test_parallel_drift_scheduling.py
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py
```

## Classifier summary

```text
SCOPE-SUMMARY paths=233 out_of_scope=0 forbidden=0
(exit 0)
```

The classifier (SCRATCH/p18-scope-check.py) treats a path as in scope when it equals a backticked
token in the plan or starts with the FEATURE prefix, and as forbidden when it lies under .claude/lib/bash
or .github/instructions, or under .claude/rules other than the parallel-orchestration rule file. The 169
FEATURE paths (plan, spec, issue, research, and evidence files) are not repeated here.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
