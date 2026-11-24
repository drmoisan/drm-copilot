#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity and documentation contracts of the release pull-request legs (issue #1231).

.DESCRIPTION
    Reads repository files only, located from $PSScriptRoot with forward-slash relative paths, so
    the suite runs on a case-sensitive file system; no hook is loaded. The rows cover byte identity
    of the four new and four edited hook files with their claude-customizations bundle copies, the
    core.json listing of the new files, the ReleasePullRequest prefix of the pure predicate file,
    the absence of a JSON parser, a wildcard matcher, and Python invocation text in the new files,
    the receipt suffix placement in both Claude gate copies, and the leg tokens in the generated
    rule, brief, skill, and agent. No row writes a file or starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:BundleRoot = 'extensions/drm-copilot/resources/claude-customizations'

    function Get-ReleasePullRequestParityText {
        # Read one repository file as text.
        param([Parameter(Mandatory)] [string] $RelativePath)
        return [string](Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot $RelativePath))
    }

    function Get-ReleasePullRequestParityHash {
        # Hash one repository file.
        param([Parameter(Mandatory)] [string] $RelativePath)
        return (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Algorithm SHA256).Hash
    }
}

AfterAll {
    Remove-Item -LiteralPath 'Function:\Get-ReleasePullRequestParityText' -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath 'Function:\Get-ReleasePullRequestParityHash' -ErrorAction SilentlyContinue
}

Describe 'release pull-request parity and documentation contracts (#1231)' {
    It 'keeps .claude/hooks/<Leaf> byte-identical to its claude-customizations bundle copy (#1231)' -ForEach @(
        @{ Leaf = 'hook-release-pull-request-context.ps1' }
        @{ Leaf = 'enforce-pr-author-skill.release.ps1' }
        @{ Leaf = 'enforce-model-routing-receipt-release.ps1' }
        @{ Leaf = 'enforce-orchestration-preimplementation-gate-release-receipt.ps1' }
        @{ Leaf = 'enforce-pr-author-skill.cleanup.ps1' }
        @{ Leaf = 'enforce-pr-author-skill.ps1' }
        @{ Leaf = 'enforce-model-routing-receipt.ps1' }
        @{ Leaf = 'enforce-orchestration-preimplementation-gate.ps1' }
    ) {
        # Act
        $source = Get-ReleasePullRequestParityHash -RelativePath ".claude/hooks/$Leaf"
        $bundle = Get-ReleasePullRequestParityHash -RelativePath "$($script:BundleRoot)/.claude/hooks/$Leaf"

        # Assert
        $bundle | Should -Be $source -Because "the bundle copy of $Leaf equals .claude/hooks/$Leaf"
    }

    It 'lists each new hook file in the core pack manifest (#1231)' {
        # Arrange
        $manifest = Get-ReleasePullRequestParityText -RelativePath "$($script:BundleRoot)/pack-manifests/core.json" | ConvertFrom-Json
        $expected = @(
            '.claude/hooks/hook-release-pull-request-context.ps1'
            '.claude/hooks/enforce-pr-author-skill.release.ps1'
            '.claude/hooks/enforce-model-routing-receipt-release.ps1'
            '.claude/hooks/enforce-orchestration-preimplementation-gate-release-receipt.ps1'
        )

        # Act
        $missing = @($expected | Where-Object { @($manifest.paths) -cnotcontains $_ })

        # Assert
        $missing | Should -BeNullOrEmpty -Because 'core.json lists every new hook file'
    }

    It 'uses the ReleasePullRequest prefix for every script-scope name and function of the pure predicate file (#1231)' {
        # Arrange
        $text = Get-ReleasePullRequestParityText -RelativePath '.claude/hooks/hook-release-pull-request-context.ps1'
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref] $tokens, [ref] $errors)

        # Act
        $scriptNames = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.IsScript }, $true) | ForEach-Object { $_.VariablePath.UserPath -replace '^script:', '' })
        $badNames = @($scriptNames | Where-Object { -not $_.StartsWith('ReleasePullRequest', [System.StringComparison]::Ordinal) })
        $functions = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name })
        $badFunctions = @($functions | Where-Object { -not $_.Contains('ReleasePullRequest') })

        # Assert
        $errors | Should -BeNullOrEmpty
        $badNames | Should -BeNullOrEmpty -Because 'script-scope names use the ReleasePullRequest prefix'
        $functions.Count | Should -Be 2
        $badFunctions | Should -BeNullOrEmpty -Because 'the pure file defines only ReleasePullRequest functions'
    }

    It 'keeps <Token> out of the new file <Leaf> (AC-12, AC-13) (#1231)' -ForEach @(
        foreach ($leaf in 'hook-release-pull-request-context.ps1', 'enforce-pr-author-skill.release.ps1', 'enforce-model-routing-receipt-release.ps1', 'enforce-orchestration-preimplementation-gate-release-receipt.ps1') {
            foreach ($token in 'ConvertFrom-Json', 'WildcardPattern', 'python', 'poetry') { @{ Leaf = $leaf; Token = $token } }
        }
    ) {
        # Act
        $text = Get-ReleasePullRequestParityText -RelativePath ".claude/hooks/$Leaf"

        # Assert
        $text.IndexOf($Token, [System.StringComparison]::OrdinalIgnoreCase) | Should -Be -1 -Because "$Leaf does not contain $Token"
    }

    It 'places the receipt suffix immediately before the release suffix in the gate copy under <Root> (AC-09) (#1231)' -ForEach @(
        @{ Root = '.claude/hooks' }
        @{ Root = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks' }
    ) {
        # Arrange
        $text = Get-ReleasePullRequestParityText -RelativePath "$Root/enforce-orchestration-preimplementation-gate.ps1"
        $denyLine = @($text -split "`r?`n" | Where-Object { $_.Contains("'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require") })

        # Act
        $receiptCall = $text.IndexOf('Get-OrchestrationReleaseReceiptResult -', [System.StringComparison]::Ordinal)

        # Assert
        $denyLine.Count | Should -Be 1
        $denyLine[0].TrimEnd().EndsWith('+ $receipt.DenySuffix + $release.DenySuffix)', [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the receipt suffix immediately precedes the release suffix'
        $receiptCall | Should -BeGreaterThan $text.LastIndexOf('Get-OrchestrationParallelRecordsResult -', [System.StringComparison]::Ordinal)
        $receiptCall | Should -BeLessThan $text.IndexOf('Get-OrchestrationReleaseAllowanceResult -', [System.StringComparison]::Ordinal)
    }

    It 'states the release pull-request legs in <Path> (AC-17, AC-18) (#1231)' -ForEach @(
        @{ Path = '.claude/rules/orchestrator-state.md'; Tokens = @('RELEASE_EXEMPTION_', 'RELEASE_DELEGATION_', 'RELEASE_RECEIPT_', 'policy-level control', 'destination-owned') }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md'; Tokens = @('RELEASE_EXEMPTION_', 'RELEASE_DELEGATION_', 'RELEASE_RECEIPT_', 'policy-level control', 'destination-owned') }
        @{ Path = '.claude/skills/execution-environment/SKILL.md'; Tokens = @('Release pull-request legs (#1231)', 'RELEASE_EXEMPTION_', 'RELEASE_DELEGATION_', 'RELEASE_RECEIPT_', 'release-pull-request.Parity.Tests.ps1') }
        @{ Path = '.agents/skills/execution-environment/SKILL.md'; Tokens = @('Release pull-request legs (#1231)', 'RELEASE_EXEMPTION_', 'RELEASE_DELEGATION_', 'RELEASE_RECEIPT_', 'release-pull-request.Parity.Tests.ps1') }
        @{ Path = '.claude/skills/pr-author/SKILL.md'; Tokens = @('## Checkpoint-Free Release Delegation (issue #1231)', 'RELEASE_EXEMPTION_', 'RELEASE_DELEGATION_', 'RELEASE_RECEIPT_') }
        @{ Path = '.agents/skills/pr-author/SKILL.md'; Tokens = @('## Checkpoint-Free Release Delegation (issue #1231)', 'RELEASE_EXEMPTION_', 'RELEASE_DELEGATION_', 'RELEASE_RECEIPT_') }
        @{ Path = '.claude/agents/pr-author.md'; Tokens = @('RELEASE_EXEMPTION_', 'issue #1231') }
    ) {
        # Act
        $text = Get-ReleasePullRequestParityText -RelativePath $Path
        $missing = @($Tokens | Where-Object { -not $text.Contains($_) })

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path names every release pull-request token"
    }
}
