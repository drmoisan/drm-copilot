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
        )
        # Optional: don't fail the run on coverage percentage
        CoveragePercentTarget = 0
    }
}









