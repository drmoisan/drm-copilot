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
            '.claude/hooks/validate-bash.ps1'
            '.claude/hooks/check-python-test-purity.ps1'
            '.claude/hooks/check-powershell-test-purity.ps1'
            '.claude/hooks/enforce-python-batch-budget.ps1'
            '.claude/hooks/enforce-powershell-batch-budget.ps1'
        )
        ExcludedPath          = @(
            '.claude/hooks/validate-feature-review-coverage.ps1' # Feature-review wrapper around repository evidence; not deterministic in normal unit-test execution.
            'scripts/dev-tools/bootstrap-host.ps1' # Host bootstrap entrypoint for external setup; not deterministic in normal unit-test execution.
            'scripts/dev-tools/bootstrap-host.helpers.ps1' # Bootstrap helper for host setup; not deterministic in normal unit-test execution.
            'scripts/dev-tools/format-powershell.ps1' # Thin formatter wrapper around external tooling; not deterministic in normal unit-test execution.
            'scripts/dev-tools/load-openai-key.ps1' # Local secret-loading wrapper; not deterministic in normal unit-test execution.
            'scripts/dev-tools/publish-sideloaded-extension.ps1' # VS Code extension publication wrapper; not deterministic in normal unit-test execution.
            'scripts/dev-tools/run-actionlint.ps1' # External actionlint wrapper; not deterministic in normal unit-test execution.
            'scripts/dev-tools/run-pester.ps1' # Pester CLI wrapper; not deterministic in normal unit-test execution.
            'scripts/dev-tools/run-poshqc-suite.ps1' # PoshQC CLI wrapper; not deterministic in normal unit-test execution.
            'scripts/dev-tools/run-psscriptanalyzer.ps1' # PSScriptAnalyzer CLI wrapper; not deterministic in normal unit-test execution.
            'scripts/dev-tools/verify-host.ps1' # Host verification wrapper for local tools; not deterministic in normal unit-test execution.
            'scripts/dev-tools/vscode-cli.helpers.ps1' # VS Code CLI helper around external processes; not deterministic in normal unit-test execution.
            'scripts/powershell/PoshQC/PoshQC.Analyzer.psm1' # Analyzer orchestration module over external tooling; not deterministic in normal unit-test execution.
            'scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1' # File-discovery module coupled to workspace traversal; not deterministic in normal unit-test execution.
            'scripts/powershell/PoshQC/PoshQC.Testing.psm1' # Pester orchestration module over external tooling; not deterministic in normal unit-test execution.
        )
        # Optional: don't fail the run on coverage percentage
        CoveragePercentTarget = 0
    }
}









