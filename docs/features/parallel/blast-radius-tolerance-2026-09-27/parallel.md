---
parallel: "blast-radius-tolerance-2026-09-27"
mode: "closed"
max_concurrency: 4
created_at: "2026-09-27T14:50:00Z"
items:
  - issue_num: 452
    feature_folder: "docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/**"
        - "docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md"
        - "docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md"
        - "tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json"
        - "tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1"
        - "tests/scripts/dev_tools/test_blast_radius_regression_452.py"
      modules: []
      shared_surfaces: []
      contracts:
        - "Get-BlastRadius"
        - "contract_dependency"
        - "derive_blast_radius"
        - "module_overlap"
        - "path_overlap"
        - "shared_surface_overlap"
      source: "declared"
      computed_at: "2026-09-27T14-20"
  - issue_num: 722
    feature_folder: "docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/agents/parallel-planner.md"
        - ".claude/lib/blast-radius/BlastRadius.psm1"
        - ".claude/lib/blast-radius/BlastRadiusScheduling.psm1"
        - ".claude/lib/blast-radius/BlastRadiusValidation.psm1"
        - ".claude/lib/blast-radius/BlastRadiusWriteIntent.psm1"
        - ".claude/rules/parallel-orchestration.md"
        - ".claude/skills/parallel-add/SKILL.md"
        - ".claude/skills/parallel-plan/SKILL.md"
        - "config/blast-radius.json"
        - "docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/**"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusValidation.psm1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md"
        - "extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json"
        - "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
        - "extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1"
        - "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts"
        - "extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts"
        - "extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts"
        - "scripts/dev_tools/_blast_radius_scheduling.py"
        - "scripts/dev_tools/_blast_radius_validation.py"
        - "scripts/dev_tools/_blast_radius_write_intent.py"
        - "scripts/dev_tools/_parallel_drift_scheduling.py"
        - "scripts/dev_tools/compute_blast_radius.py"
        - "scripts/dev_tools/parallel_drift_detection.py"
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
        - "tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json"
        - "tests/fixtures/blast_radius/historical-runs/epic-655-followups.json"
        - "tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json"
        - "tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json"
        - "tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json"
        - "tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json"
        - "tests/fixtures/blast_radius/scheduling/scheduling-absent-key-strict.json"
        - "tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-command-span.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-flag-absent-matches-current.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-glob-mention.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-placeholder-stem.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-read-task.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-root-anchoring.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json"
        - "tests/fixtures/blast_radius/write-intent/write-intent-spec-contracts-only.json"
        - "tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1"
        - "tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1"
        - "tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1"
        - "tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1"
        - "tests/scripts/dev_tools/blast_radius_parity_test_support.py"
        - "tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py"
        - "tests/scripts/dev_tools/test_blast_radius_historical_runs.py"
        - "tests/scripts/dev_tools/test_blast_radius_mandate_reads.py"
        - "tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py"
        - "tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py"
        - "tests/scripts/dev_tools/test_blast_radius_scheduling.py"
        - "tests/scripts/dev_tools/test_blast_radius_write_intent.py"
        - "tests/scripts/dev_tools/test_parallel_drift_scheduling.py"
        - "tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py"
      modules:
        - "config"
        - "poshqc"
      shared_surfaces:
        - "config/blast-radius.json"
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
      contracts: []
      source: "declared"
      computed_at: "2026-09-27T14-40"
expected_conflict_components:
  - name: blast-radius-lane
    members:
      - 452
      - 722
---

# Parallel Run: blast-radius-tolerance-2026-09-27

Two blast-radius items: #722 (write-intent extraction and a configurable integration-cost conflict tolerance) and #452 (bidirectional regression corpus for the under-reporting cases). Items are scheduled by computed blast-radius contention; there is no integration branch, and each item opens its own pull request against main.

The `expected_conflict_components` entry records the operator expectation that the two items contend. It is an advisory assertion only and does not feed cohort computation. The derived conflict graph has no edge between them, so they share cohort 0; both plans are written to be merge-order independent.
