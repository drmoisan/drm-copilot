@{
    Run          = @{
        Path = @('scripts', 'tests/powershell', 'tests/scripts')
        Exit = $true
    }
    Should       = @{
        ErrorAction = 'Stop'
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
    TestResult   = @{
        Enabled      = $true
        OutputFormat = 'JUnitXml'
        OutputPath   = 'artifacts/pester/pester-junit.xml'
    }
    CodeCoverage = @{
        Enabled               = $true
        # Use Pester's CoverageGutters format so VS Code Coverage Gutters
        # can map file paths correctly.
        OutputFormat          = 'CoverageGutters'
        OutputPath            = 'artifacts/pester/powershell-coverage.xml'
        Path                  = @(
            # Scope coverage to hook files with deterministic Pester coverage in this branch.
            # Broader script/module globs include bootstrap and one-shot automation paths that
            # are validated by their own suites but not meaningfully covered by this hook batch.
            '.claude/hooks/validate-bash.ps1'
            '.claude/hooks/check-python-test-purity.ps1'
            '.claude/hooks/check-powershell-test-purity.ps1'
            '.claude/hooks/enforce-python-batch-budget.ps1'
            '.claude/hooks/enforce-powershell-batch-budget.ps1'
            # Issue #272 hardened this PreToolUse hook with a new orchestrator-state preflight
            # check; measured here so the change produces real per-file coverage evidence.
            '.claude/hooks/enforce-pr-author-skill.ps1'
            # Issue #214 added/changed these four release scripts and provided dedicated
            # Pester suites; they are measured here to produce real per-file changed-line
            # coverage rather than relying on behavioral-only evidence.
            'scripts/powershell/Publish-DrmCopilotExtension.ps1'
            'scripts/dev-tools/Invoke-FullRelease.ps1'
            'scripts/dev-tools/Invoke-MarketplacePublish.ps1'
            'scripts/dev-tools/Invoke-ReleaseTagPush.ps1'
            # Issue #275 remediation cycle 1 (fix #3): measure the epic-orchestrate hook set and
            # its dot-sourced sibling module so no production hook is excluded from coverage.
            '.claude/hooks/enforce-epic-merge-gate.ps1'
            '.claude/hooks/enforce-epic-wave-barrier.ps1'
            '.claude/hooks/enforce-epic-worktree-removal-gate.ps1'
            '.claude/hooks/enforce-pr-author-skill.ps1'
            '.claude/hooks/validate-orchestrator-output.ps1'
            '.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1'
            # Issue #301 remediation cycle 1 (fix #1): measure the completion-consistency
            # hook set (Claude and Codex variants) so their Pester coverage is captured.
            '.claude/hooks/enforce-completion-consistency.ps1'
            '.claude/hooks/enforce-completion-helpers.ps1'
            '.codex/hooks/enforce-completion-consistency.ps1'
            '.codex/hooks/enforce-completion-helpers.ps1'
            # Issue #298 fixed ConvertTo-CommandResult's handling of an empty array Output
            # parameter in this script; measured here so the change produces real per-file
            # coverage evidence going forward.
            'scripts/dev-tools/Invoke-FullReleaseFlow.ps1'
            # Issue #305 added this PreToolUse model-routing-receipt deterrent hook; measured
            # here so the new production hook is not excluded from coverage.
            '.claude/hooks/enforce-model-routing-receipt.ps1'
            # Issue #312 added the .claude-resident PowerShell model-routing library so the
            # push-down bundle no longer cites missing scripts/dev_tools references; measured
            # here so the new production module is not excluded from coverage.
            '.claude/lib/model-routing/ModelRouting.psm1'
            # The portable orchestrator-state modules make the pushed-down enforcement hooks
            # work in consumer repos without scripts/dev_tools; measured here so the new
            # production modules are not excluded from coverage.
            '.claude/lib/orchestrator-state/OrchestratorState.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1'
            # Issue #328 added this dev-tools worktree launcher script; measured here so the
            # changed production file is in the coverage denominator (R1). The test suite
            # dot-sources the file (guarded body) so line attribution is valid.
            'scripts/dev-tools/new-claude-worktree-session.ps1'
            # Issue #334 added this SessionStart hook that persists the current session id;
            # measured here so the new production hook is not excluded from coverage. The
            # test suite dot-sources the file (guarded body) so line attribution is valid.
            '.claude/hooks/persist-session-id.ps1'
            # Issue #344 remediation cycle 1 (R2): measure the new production ScanConfig module
            # so it is not excluded from coverage; PoshQC.psm1 sub-module loading was refactored
            # to AST-based scriptblocks (Parser::ParseFile(...).GetScriptBlock()) so Pester
            # coverage breakpoints bind to the on-disk source file.
            'scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1'
            # Issue #357 remediation cycle 1 (fix #1): measure the atomic-planner SubagentStop
            # hook so its Pester coverage is captured in the canonical artifact.
            '.claude/hooks/validate-planner-output.ps1'
            # Issue #366 added the discovery-artifact completion-gate hooks (PreToolUse and
            # SubagentStop); measured here so the new production hooks are not excluded from
            # coverage.
            '.claude/hooks/enforce-discovery-artifact-gate.ps1'
            '.claude/hooks/validate-discovery-artifact-gate.ps1'
            # Issue #392 changed the Invoke-PoshQCTest default seams ($EnsureModule -Global
            # import and the global-session-state $InvokePester trampoline) so the bundled
            # entry path hosts the Pester run in the global session state; measured here so
            # the fix produces real per-file changed-line coverage evidence.
            'scripts/powershell/PoshQC/PoshQC.Testing.psm1'
            # Issue #415 remediation cycle 1 (R1): the PreToolUse hook transport fix added the
            # shared payload-parsing module and rewired seven Codex hooks to consume it. Those
            # production files were absent from this list, so the changed surface was outside
            # the coverage denominator. Measured here so the changed production surface is not
            # excluded from coverage.
            '.codex/hooks/codex-pretooluse-file-mapping.ps1'
            '.codex/hooks/check-python-test-purity.ps1'
            '.codex/hooks/check-powershell-test-purity.ps1'
            '.codex/hooks/enforce-python-batch-budget.ps1'
            '.codex/hooks/enforce-powershell-batch-budget.ps1'
            '.codex/hooks/enforce-evidence-locations.ps1'
            '.codex/hooks/enforce-checkpoint-monotonic.ps1'
            '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
            # Issue #415 remediation cycle 2 (R-COV): the detached-HEAD null-guard fix changed
            # these two Codex PreToolUse hooks. Both were absent from this list, so the changed
            # production surface was outside the coverage denominator. Measured here so the
            # changed production surface is not excluded from coverage.
            '.codex/hooks/enforce-epic-child-worktree-binding.ps1'
            '.codex/hooks/enforce-epic-planning-only.ps1'
        )
        # Optional: don't fail the run on coverage percentage
        CoveragePercentTarget = 0
    }
}








