# Baseline — PowerShell Pester (Coverage-Enabled)

Timestamp: 2026-07-04T09-41

Command: `mcp__drm-copilot__run_poshqc_test` targeting `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` and `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`, using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

EXIT_CODE: 0

## Output Summary

Test results (from `artifacts/pester/pester-junit.xml`, run recorded at 07/04/2026 09:41:59):

- `enforce-completion-consistency.Tests.ps1`: 49 tests, 0 failures, 0 errors.
- `enforce-completion-consistency-codex.Tests.ps1`: 2 tests, 0 failures, 0 errors.
- Total: 51 tests, 0 failures, 0 errors. All tests passed, including both `It` blocks in `Describe 'bundled Codex enforce-completion-consistency.ps1'`.

Numeric coverage headline (line/branch): NOT OBTAINABLE for the in-scope hook files under this run.

The `CodeCoverage.Path` list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is a fixed, curated list of files (`.claude/hooks/validate-bash.ps1`, `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-pr-author-skill.ps1`, `scripts/powershell/Publish-DrmCopilotExtension.ps1`, `scripts/dev-tools/Invoke-FullRelease.ps1`, `scripts/dev-tools/Invoke-MarketplacePublish.ps1`, `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `validate-orchestrator-output.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`). This list does not include `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, or `.codex/hooks/enforce-completion-helpers.ps1`. Consequently, `artifacts/pester/powershell-coverage.xml` (JaCoCo format) contains no entries for any of these four files, and no line/branch percentage specific to them can be derived from this coverage run.

The generated `artifacts/pester/powershell-coverage.xml` reports, for the 15 files that are in the configured `Path` list: `LINE missed="1073" covered="0"`, `METHOD missed="102" covered="0"`, `INSTRUCTION missed="1513" covered="0"` — i.e. 0% coverage for that unrelated file set, because none of those 15 files are exercised by the two hook test files run here. This aggregate figure does not describe coverage of the files in scope for this fix and is not used as the baseline coverage figure for this feature.

This gap in `pester.runsettings.psd1`'s `CodeCoverage.Path` scoping is pre-existing and out of scope for this plan (the plan's change budget names only `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, the two bundled-resource equivalents, and the new test file; it does not authorize editing `pester.runsettings.psd1`). This finding is recorded here rather than acted upon, consistent with the instruction not to expand scope beyond the plan's named files.
