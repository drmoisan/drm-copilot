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
        )
        # Optional: don't fail the run on coverage percentage
        CoveragePercentTarget = 0
    }
}









