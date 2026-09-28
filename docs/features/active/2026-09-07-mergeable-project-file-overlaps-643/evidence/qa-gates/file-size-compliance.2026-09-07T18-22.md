# Phase 8 — file-size compliance over the change set

Timestamp: 2026-09-07T18-22

Command: `git diff c3ffb080 --name-only`; `git status --porcelain --untracked-files=all`; `wc -l` over every listed path whose extension is `.py`, `.ps1`, `.psm1`, `.psd1`, `.ts`, `.cjs`, or `.json` and that does not lie under `tests/fixtures/`

EXIT_CODE: 0

## Output Summary

Forty paths met the extension and non-fixture filter. Every count is at or under the 500-line
ceiling of `.claude/rules/general-code-change.md`; the largest is 490
(`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`).

## Per-path counts, ascending

```text
    36 extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
    50 config/blast-radius.json
    59 tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py
    81 tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1
   118 tests/scripts/dev_tools/test_parallel_mergeable_cohort.py
   149 extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts
   160 scripts/dev_tools/_blast_radius_mergeable.py
   173 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
   183 extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts
   194 tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1
   200 extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts
   212 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1
   226 .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1
   226 extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1
   232 tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
   237 extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts
   257 scripts/dev_tools/_blast_radius_conflicts.py
   257 tests/scripts/dev_tools/blast_radius_parity_test_support.py
   260 .claude/lib/blast-radius/BlastRadiusConflict.psm1
   260 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusConflict.psm1
   263 tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1
   268 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
   271 tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
   274 extensions/drm-copilot/jest.config.cjs
   318 .claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1
   318 extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1
   349 tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
   355 .claude/lib/project-file-merge/ProjectFileMerge.psm1
   355 extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMerge.psm1
   380 extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
   401 tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py
   421 scripts/dev_tools/compute_blast_radius.py
   438 .claude/lib/blast-radius/BlastRadius.psm1
   438 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1
   453 extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts
   459 tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py
   461 extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts
   472 extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts
   486 extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts
   490 tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
 11240 total
```

## Constraint C2 table — plan-time count beside final count

| File | Plan-time | Final | Stated bound | Met |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` | 500 | 500 | not edited | yes |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 499 | 499 | not edited | yes |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 495 | 438 | at or under 450 | yes |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py` | 486 | 486 | not edited | yes |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 482 | 486 | net change at most +4 | yes (+4) |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 473 | 473 | not edited | yes |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 472 | 472 | net 0 | yes |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 468 | 380 | at or under 420 | yes |
| `scripts/dev_tools/_blast_radius_validation.py` | 464 | 464 | not edited | yes |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | 461 | 461 | net change at most +2 | yes (0) |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | 435 | 490 | at or under 490 | yes |
| `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py` | 420 | 459 | one test added | yes |
| `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts` | 417 | 453 | one describe, two it blocks | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 325 | 349 | one It block added | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | 268 | 271 | one array element added | yes |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 241 | 257 | filter and docstring edit | yes |

The five files marked "not edited" carry their plan-time counts unchanged, which is the direct
observation that the C2 relocations and splits held: no case was added to a file already at or near
the ceiling.
