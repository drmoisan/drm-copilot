#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity and documentation contracts of the release merge leg (issue #1234).

.DESCRIPTION
    Reads repository files only, located from $PSScriptRoot with forward-slash relative paths, so
    the suite runs on a case-sensitive file system; no hook is loaded. The rows cover byte identity
    of the leg and of the pure predicate file across both hook trees and both bundles, each merge
    gate against its bundle copy, the core.json listings, the absence of the allowance file, the
    release suffix placement in each gate copy, the function set and excluded tokens of the leg, and
    the release merge text of the generated rule, the brief copies, and the pr-author skill. No row
    writes a file or starts a process.
#>

BeforeAll {
    # The suite names the merge gates by file only and loads no hook; the baseline seam mocks keep
    # the epic-state isolation guard satisfied for the read seams those names bring into scope.
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChildOrchestratorCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicOrchestratorCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelOrchestratorCheckpointContent' -Surface 'Codex' }
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:ClaudeBundle = 'extensions/drm-copilot/resources/claude-customizations'
    $script:CodexBundle = 'extensions/drm-copilot/resources/codex-and-agents-customizations'

    function Get-ReleaseMergeParityText {
        # Read one repository file as text.
        param([Parameter(Mandatory)] [string] $RelativePath)
        return [string](Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot $RelativePath))
    }

    function Get-ReleaseMergeParityHash {
        # Hash one repository file.
        param([Parameter(Mandatory)] [string] $RelativePath)
        return (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Algorithm SHA256).Hash
    }
}

AfterAll {
    Remove-Item -LiteralPath 'Function:\Get-ReleaseMergeParityText' -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath 'Function:\Get-ReleaseMergeParityHash' -ErrorAction SilentlyContinue
}

Describe 'release merge parity and documentation contracts (#1234)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'keeps the four copies of <Leaf> byte-identical (AC-29, AC-30) (#1234)' -ForEach @(
        @{ Leaf = 'enforce-epic-merge-gate-release.ps1' }
        @{ Leaf = 'hook-release-pull-request-context.ps1' }
    ) {
        # Arrange
        $paths = @(
            ".claude/hooks/$Leaf"
            ".codex/hooks/$Leaf"
            "$($script:ClaudeBundle)/.claude/hooks/$Leaf"
            "$($script:CodexBundle)/.codex/hooks/$Leaf"
        )

        # Act
        $hashes = @($paths | ForEach-Object { Get-ReleaseMergeParityHash -RelativePath $_ } | Select-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 1 -Because "the four copies of $Leaf are byte-identical"
    }

    It 'keeps the <Tree> merge gate byte-identical to its bundle copy (AC-30) (#1234)' -ForEach @(
        @{ Tree = '.claude/hooks'; Bundle = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks' }
        @{ Tree = '.codex/hooks'; Bundle = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks' }
    ) {
        # Act
        $source = Get-ReleaseMergeParityHash -RelativePath "$Tree/enforce-epic-merge-gate.ps1"
        $bundle = Get-ReleaseMergeParityHash -RelativePath "$Bundle/enforce-epic-merge-gate.ps1"

        # Assert
        $bundle | Should -Be $source
    }

    It 'lists <Path> in the <Pack> core pack manifest (AC-31) (#1234)' -ForEach @(
        @{ Pack = 'claude-customizations'; Path = '.claude/hooks/enforce-epic-merge-gate-release.ps1' }
        @{ Pack = 'codex-and-agents-customizations'; Path = '.codex/hooks/enforce-epic-merge-gate-release.ps1' }
        @{ Pack = 'codex-and-agents-customizations'; Path = '.codex/hooks/hook-release-pull-request-context.ps1' }
    ) {
        # Arrange
        $manifest = Get-ReleaseMergeParityText -RelativePath "extensions/drm-copilot/resources/$Pack/pack-manifests/core.json" | ConvertFrom-Json

        # Act and Assert
        @($manifest.paths) -ccontains $Path | Should -BeTrue -Because "core.json of $Pack lists $Path"
    }

    It 'ships no release-commit allowance file in the repository, the bundles, or a pack manifest (AC-33) (#1234)' {
        # Arrange
        $leaf = '.claude/release-commit-allowance.json'
        $manifests = @(
            "$($script:ClaudeBundle)/pack-manifests"
            "$($script:CodexBundle)/pack-manifests"
        ) | ForEach-Object { Get-ChildItem -LiteralPath (Join-Path $script:RepoRoot $_) -Filter '*.json' -File }

        # Act
        $present = @(@($leaf, "$($script:ClaudeBundle)/$leaf", "$($script:CodexBundle)/$leaf") | Where-Object { Test-Path -LiteralPath (Join-Path $script:RepoRoot $_) })
        $listed = @($manifests | Where-Object { (Get-Content -Raw -LiteralPath $_.FullName).Contains('release-commit-allowance.json') })

        # Assert
        $present | Should -BeNullOrEmpty
        $listed | Should -BeNullOrEmpty
    }

    It 'ends the explicit-number deny with the release suffix in <Path> (AC-23) (#1234)' -ForEach @(
        @{ Path = '.claude/hooks/enforce-epic-merge-gate.ps1'; Ending = '+ $greenCi.Suffix + $release.Suffix)' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1'; Ending = '+ $greenCi.Suffix + $release.Suffix)' }
        @{ Path = '.codex/hooks/enforce-epic-merge-gate.ps1'; Ending = '+ $docsOnlySuffix + $release.Suffix' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1'; Ending = '+ $docsOnlySuffix + $release.Suffix' }
    ) {
        # Arrange
        $text = Get-ReleaseMergeParityText -RelativePath $Path

        # Act
        $denyLines = @($text -split "`r?`n" | Where-Object { $_.Contains("'EPIC_MERGE_GATE_BLOCKED: ' +") -and $_.Contains('$docsOnlySuffix') })

        # Assert
        $denyLines.Count | Should -Be 1
        $denyLines[0].TrimEnd().EndsWith($Ending, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the release suffix is the last deny term in $Path"
    }

    It 'defines only EpicMergeGateRelease functions in the leg (AC-26, AC-27) (#1234)' {
        # Arrange
        $text = Get-ReleaseMergeParityText -RelativePath '.claude/hooks/enforce-epic-merge-gate-release.ps1'
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref] $tokens, [ref] $errors)

        # Act
        $functions = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name })
        $badFunctions = @($functions | Where-Object { ($_ -split '-', 2)[1] -cnotlike 'EpicMergeGateRelease*' })

        # Assert
        $errors | Should -BeNullOrEmpty
        $functions | Should -Contain 'Get-EpicMergeGateReleasePullRequest'
        $functions | Should -Contain 'Get-EpicMergeGateReleaseDecision'
        $badFunctions | Should -BeNullOrEmpty -Because 'the leg defines only functions whose noun begins with EpicMergeGateRelease'
    }

    It 'keeps <Token> out of the leg (AC-26, AC-27, AC-39) (#1234)' -ForEach @(
        @{ Token = 'WildcardPattern' }
        @{ Token = 'schema_version' }
        @{ Token = 'Start' + '-Process' }
        @{ Token = 'ProcessStartInfo' }
        @{ Token = 'python' }
        @{ Token = 'poetry' }
    ) {
        # Act
        $text = Get-ReleaseMergeParityText -RelativePath '.claude/hooks/enforce-epic-merge-gate-release.ps1'

        # Assert
        $text.IndexOf($Token, [System.StringComparison]::OrdinalIgnoreCase) | Should -Be -1 -Because "the leg does not contain $Token"
    }

    It 'states the release merge leg in <Path> (AC-34, AC-35) (#1234)' -ForEach @(
        @{ Path = '.claude/rules/orchestrator-state.md'; Tokens = @('RELEASE_MERGE_', 'Get-EpicMergeGateReleaseDecision', 'policy-level control') }
        @{ Path = '.claude/skills/execution-environment/SKILL.md'; Tokens = @('RELEASE_MERGE_', 'Get-EpicMergeGateReleaseDecision') }
        @{ Path = '.agents/skills/execution-environment/SKILL.md'; Tokens = @('RELEASE_MERGE_', 'Get-EpicMergeGateReleaseDecision') }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md'; Tokens = @('RELEASE_MERGE_', 'Get-EpicMergeGateReleaseDecision') }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md'; Tokens = @('RELEASE_MERGE_', 'Get-EpicMergeGateReleaseDecision') }
        @{ Path = '.claude/skills/pr-author/SKILL.md'; Tokens = @('RELEASE_MERGE_', 'Get-EpicMergeGateReleaseDecision', '## Checkpoint-Free Release Delegation (issue #1231)') }
    ) {
        # Act
        $text = Get-ReleaseMergeParityText -RelativePath $Path
        $missing = @($Tokens | Where-Object { -not $text.Contains($_) })

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path names every release merge token"
    }
}
