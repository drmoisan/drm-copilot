#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity and behavior tests for the Codex file-size policy twin .codex/hooks/file-size-policy.ps1 (issue #990).

.DESCRIPTION
    The twin is dot-sourced and driven with the shared rows of
    tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Cases.ps1, the same rows the
    Claude module suites use. A parity row parses the twin and
    .claude/lib/file-size-policy/FileSizePolicy.psm1 (parse only, no import) and asserts
    that both define the same set of function names with text-identical definitions.

    Paths are built with Join-Path and forward slashes so the suite holds on the
    case-sensitive Linux hook job. No row creates a file or starts a process.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-lib/file-size-policy/FileSizePolicy.Cases.ps1')
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:TwinPath = Join-Path $script:RepoRoot '.codex/hooks/file-size-policy.ps1'
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/file-size-policy/FileSizePolicy.psm1'
    . $script:TwinPath

    function Get-FileSizeFunctionDefinition {
        param([Parameter(Mandatory)][string] $Path)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
        $errors | Should -BeNullOrEmpty -Because "$Path must parse"
        $definition = [ordered]@{}
        foreach ($function in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            $definition[$function.Name] = $function.Extent.Text.Replace("`r`n", "`n")
        }
        return $definition
    }
}

Describe 'Codex file-size policy twin parity' {
    It 'defines the same function names as the Claude module' {
        # Arrange / Act
        $twin = Get-FileSizeFunctionDefinition -Path $script:TwinPath
        $module = Get-FileSizeFunctionDefinition -Path $script:ModulePath

        # Assert
        @($twin.Keys | Sort-Object) | Should -Be @($module.Keys | Sort-Object)
        $twin.Count | Should -BeGreaterThan 0
    }

    It 'keeps every function definition text-identical to the Claude module' {
        # Arrange
        $twin = Get-FileSizeFunctionDefinition -Path $script:TwinPath
        $module = Get-FileSizeFunctionDefinition -Path $script:ModulePath

        # Act: the names whose definition text differs.
        $different = @($module.Keys | Where-Object { $twin[$_] -cne $module[$_] })

        # Assert: a drifted twin applies a different policy on the Codex surface.
        $different | Should -BeNullOrEmpty
    }

    It 'reads no legacy Claude environment variable' {
        Get-Content -Raw -LiteralPath $script:TwinPath | Should -Not -Match '\$env:CLAUDE_'
    }
}

Describe 'Codex file-size policy twin behavior' {
    It 'returns the 500, 700, and 800 limits' {
        $limit = Get-FileSizePolicyLimit
        @($limit.Guidance, $limit.Advisory, $limit.HardLimit) | Should -Be @(500, 700, 800)
    }

    It 'counts <Name> as <Expected> lines' -ForEach $script:FileSizeLineCountCases {
        Get-FileSizeLogicalLineCount -Content $Content | Should -Be $Expected
    }

    It 'classifies <LineCount> lines as <Expected>' -ForEach $script:FileSizeTierCases {
        Get-FileSizeTier -LineCount $LineCount | Should -Be $Expected
    }

    It 'rejects a negative line count' {
        { Get-FileSizeTier -LineCount -5 } | Should -Throw '*must be non-negative*'
    }

    It 'reports <Path> as covered = <Expected>' -ForEach $script:FileSizeCoveredPathCases {
        Test-FileSizeCoveredPath -RelativePath $Path | Should -Be $Expected
    }

    It 'excludes a file under the <Segment> directory' -ForEach $script:FileSizeExcludedSegmentCases {
        Test-FileSizeCoveredPath -RelativePath "lib/$Segment/tool.ps1" | Should -BeFalse
    }

    It 'converts <Name>' -ForEach $script:FileSizeRelativePathCases {
        ConvertTo-FileSizeRelativePath -Path $Path -RepositoryRoot $Root | Should -Be $Expected
    }

    It 'evaluates the ratchet row: <Name>' -ForEach $script:FileSizeBaselineCases {
        $violation = Compare-FileSizeBaselineEntry -Path 'scripts/large.py' -CurrentSize $Current -BaselineSize $Baseline
        if ($null -eq $ExpectedRule) { $violation | Should -BeNullOrEmpty } else { $violation.Rule | Should -Be $ExpectedRule }
    }

    It 'resolves <Name>' -ForEach $script:FileSizeEditCases {
        $result = Resolve-FileSizeEditContent -Content $Content -OldString $Old -NewString $New -ReplaceAll $ReplaceAll
        $result.Failure | Should -Be $Failure
        if ($null -eq $Failure) { $result.Content | Should -BeExactly $Expected }
    }

    It 'decides: <Name>' -ForEach $script:FileSizeHookDecisionCases {
        $decision = Get-FileSizeHookDecision -RelativePath $Path -ResultLineCount $Result -PreEditLineCount $PreEdit
        $decision.Allowed | Should -Be $Allowed
        if (-not $Allowed) { $decision.Reason | Should -Match '^FILE_SIZE_LIMIT_BLOCKED:' }
    }
}
