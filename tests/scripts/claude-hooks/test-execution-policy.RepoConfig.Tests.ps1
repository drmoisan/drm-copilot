#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Contract tests for the committed config/test-execution-policy.json and the pytest lane
    markers in pyproject.toml (issue #1158).

.DESCRIPTION
    Reads only committed repository files. The policy helper validates the configuration,
    and the lane classifier confirms that the repository's integration-named test files are
    integration-lane names under the committed suffixes.
#>

Describe 'committed test-execution policy configuration (issue #1158)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/test-execution-policy.ps1')
        $script:ConfigPath = Join-Path $script:RepoRoot 'config/test-execution-policy.json'
        $script:ConfigText = Get-Content -LiteralPath $script:ConfigPath -Raw
        $script:Policy = Get-TestExecutionPolicy -ReadText { $script:ConfigText }
    }

    It 'validates with no error' {
        # Arrange
        $document = ConvertFrom-Json -InputObject $script:ConfigText -AsHashtable

        # Act
        $errors = @(Test-TestExecutionPolicyDocument -Document $document)

        # Assert
        $errors.Count | Should -Be 0 -Because ($errors -join '; ')
    }

    It 'writes the version line exactly once' {
        # Act
        $lines = @(Get-Content -LiteralPath $script:ConfigPath | Where-Object { $_.Trim() -ceq '"version": 1,' })

        # Assert
        $lines.Count | Should -Be 1
    }

    It 'defines the jest-extension and bats suites' {
        # Act
        $jest = $script:Policy['suites']['jest-extension']
        $bats = $script:Policy['suites']['bats']

        # Assert
        $jest['workingDirectory'] | Should -BeExactly 'extensions/drm-copilot'
        ($jest['command'] -join ' ') | Should -BeExactly 'node run-jest.cjs'
        $jest['runner'] | Should -BeExactly 'jest'
        ($bats['command'] -join ' ') | Should -BeExactly 'bash scripts/bash/shell-qc.sh test'
        $bats['runner'] | Should -BeExactly 'bats'
    }

    It 'classifies <Name> as an integration-lane name' -ForEach @(
        @{ Name = 'extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts'; Runner = 'jest' }
        @{ Name = 'tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1'; Runner = 'pester' }
        @{ Name = 'tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1'; Runner = 'pester' }
        @{ Name = 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1'; Runner = 'pester' }
        @{ Name = 'tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1'; Runner = 'pester' }
    ) {
        # Act
        $lane = Get-TestExecutionLaneSelection -Policy $script:Policy -Runner $Runner -ArgumentList @($Name)

        # Assert
        $lane | Should -Be 'integration'
    }

    It 'registers the integration and golden markers in pyproject.toml' {
        # Arrange
        $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot 'pyproject.toml') -Raw
        $section = [regex]::Match($text, '(?ms)^\[tool\.pytest\.ini_options\]\s*$(.*?)(?=^\[)').Groups[1].Value
        $markers = [regex]::Match($section, '(?ms)^markers\s*=\s*\[(.*?)\]').Groups[1].Value
        $entries = @([regex]::Matches($markers, '"([^"]*)"') | ForEach-Object { $_.Groups[1].Value })

        # Act / Assert
        @($entries | Where-Object { $_.StartsWith('integration:') }).Count | Should -Be 1
        @($entries | Where-Object { $_.StartsWith('golden:') }).Count | Should -Be 1
    }
}
