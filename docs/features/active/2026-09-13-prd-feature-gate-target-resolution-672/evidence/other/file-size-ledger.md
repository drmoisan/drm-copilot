# File-Size Ledger

This ledger deliberately carries no timestamp in its filename: `[P1-T6]` and `[P4-T20]` both append to it, and two differently timestamped filenames would be two different files. Each block carries its own `Timestamp:` line.

## Phase 1 block — after the helpers extraction, before the behaviour change

Timestamp: 2026-09-17T11-02

Command: `(Get-Content -LiteralPath '<path>').Count`, run from the worktree root through the scratchpad wrapper `sh runps.sh p1verify.ps1`.

| file | measured lines | cap |
| --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 262 | 500 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 203 | 500 |

Both measured counts are at or under the 500-line cap in `.claude/rules/general-code-change.md`. The research record's projection was roughly 266 for the parent and roughly 211 for the sibling; the binding requirement is the measured 500-line cap, not the projection, and both measurements sit close to it.

## Phase 4 block — after the target-resolution behaviour change

Timestamp: 2026-09-17T11-35

Command: `(Get-Content -LiteralPath '<path>').Count`, run from the worktree root through the scratchpad wrapper `sh runps.sh p4verify.ps1`.

| file | measured lines | cap |
| --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 424 | 500 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 314 | 500 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 384 | 500 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 445 | 500 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 453 | 500 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | 262 | 500 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 203 | 500 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 306 | 500 |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 306 | 500 |

All nine measured counts are at or under 500, covering every production and test file in the change set as `spec.md` line 653 requires. The two bundled hook copies are measured here at their batch-B values (262 and 203); batch E re-mirrors them to the post-change repository copies, and the delivery tests at `[P5-T4]` assert text identity after that.

### Delivered-state remeasurement (final)

Timestamp: 2026-09-17T12-10

The Phase 6 loop added test cases and one decision branch after the Phase 4 block was written, so the same nine files were remeasured in their delivered state with the same command:

| file | measured lines | cap |
| --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 431 | 500 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 314 | 500 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 454 | 500 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 445 | 500 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 453 | 500 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | 431 | 500 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 314 | 500 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 306 | 500 |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 306 | 500 |

All nine delivered counts are at or under 500; the largest is the new companion suite at 454. The two bundled hook copies now match their repository counterparts exactly, which is the batch-E mirroring verified by `[P5-T2]`, `[P5-T3]`, and the delivery tests.

Citation drift recorded rather than hidden: `[P4-T20]` states that both `pester.runsettings.psd1` copies are 293 lines and the bundled hook 448. The runsettings copies measured 302 before this feature's single-entry addition and 306 after it, because F1 (merged as PR #683) added coverage entries; the bundled hook measured 448 before the extraction. The plan's point stands either way — the entries each task adds cannot approach the cap.
