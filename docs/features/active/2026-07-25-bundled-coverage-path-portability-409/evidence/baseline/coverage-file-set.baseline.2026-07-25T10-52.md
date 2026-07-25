# Baseline — Coverage Per-File Entry Set (AC 4 invariance baseline, issue #409)

Timestamp: 2026-07-25T10-52

Command:
1. Direct repo-root module run (the coverage-XML producer):
   `pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest"`
   (run from the repository root; `-Root` omitted so it defaults to the absolute `$PWD.ProviderPath`)
2. Copy and entry-set extraction:
   `pwsh -NoLogo -NoProfile -Command "Copy-Item artifacts/pester/powershell-coverage.xml docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/powershell-coverage.baseline.xml -Force; $x = [xml](Get-Content -Raw docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/powershell-coverage.baseline.xml); $entries = @($x.report.package | ForEach-Object { $pkg = $_.name; @($_.sourcefile) | ForEach-Object { \"$pkg/$($_.name)\" } }) | Sort-Object -Unique; 'COUNT=' + $entries.Count; $entries -join [Environment]::NewLine"`

EXIT_CODE: 0 (direct run: 0; copy/extraction: 0)

Output Summary:
- Harness provenance: this coverage XML was produced by the **direct repo-root module run**, not by the MCP tool. Rationale: the configured MCP server is `npx -y @danmoisan/drm-copilot-mcp` (`.mcp.json`), whose npx-cached 1.0.18 bundle carries its own copy of `PoshQC.Testing.psm1` that will not change when this branch edits the repository. Sourcing both the baseline and the post-change XML from the direct module run keeps the AC-4 comparison a comparison of the code change rather than of two harnesses.
- Direct run result: 1341 passed, 0 failed, 9 skipped, 0 inconclusive, 0 not-run, completed in 34.82 s.
- Replayed coverage headline: `Covered 89.64% / 0%. 3,253 analyzed Commands in 31 Files.`
- Report-level line coverage: 90.19% (JaCoCo `LINE` counter: covered 2143, missed 233).
- Changed-module baseline (`scripts/powershell/PoshQC/PoshQC.Testing.psm1`): LINE 100.00% (covered 195, missed 0); INSTRUCTION 98.50% (covered 263, missed 4).
- **Prune messages in the run log: 0.** The pre-fix module contains no pruning code, so no prune line can be emitted. This is the pre-change reference point for the AC-4 zero-prune assertion.
- **Distinct per-file entry count: 31.** Extracted as `<package name>/<sourcefile name>` pairs from the JaCoCo report, sorted unique. Note: Pester 5.6.1 emits JaCoCo format (`<sourcefile name=...>` inside `<package name=...>`), not Cobertura `filename` attributes; the entry set is therefore keyed on the JaCoCo `sourcefile` identity as the plan permits.
- Baseline XML preserved at `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/powershell-coverage.baseline.xml`.

## Baseline per-file entry set (31 entries, sorted)

```
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/check-powershell-test-purity.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/check-python-test-purity.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-completion-consistency.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-completion-helpers.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-discovery-artifact-gate.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-epic-merge-gate.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-epic-wave-barrier.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-model-routing-receipt.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-powershell-batch-budget.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-pr-author-skill.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/enforce-python-batch-budget.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/persist-session-id.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/validate-bash.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/validate-discovery-artifact-gate.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/validate-orchestrator-output.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/hooks/validate-planner-output.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/lib/model-routing/ModelRouting.psm1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/lib/orchestrator-state/OrchestratorState.psm1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.codex/hooks/enforce-completion-consistency.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/.codex/hooks/enforce-completion-helpers.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/dev-tools/Invoke-FullRelease.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/dev-tools/Invoke-FullReleaseFlow.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/dev-tools/Invoke-MarketplacePublish.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/dev-tools/Invoke-ReleaseTagPush.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/dev-tools/new-claude-worktree-session.ps1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/powershell/PoshQC/PoshQC.Testing.psm1
C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/scripts/powershell/Publish-DrmCopilotExtension.ps1
```
