#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Hook-reference rows for the epic-state isolation guard (issue #935).

.DESCRIPTION
    R1 rows prove that Test-EpicStateIsolationHookReference identifies a hook load written as a
    hooks/<name>.ps1 literal, as an expandable string or Join-Path over a variable bound to a
    hooks root, or as a Join-Path segment list ending in 'hooks', '<name>.ps1'; negative rows
    prove that a variable bound to a non-hooks segment, or not bound at all, is not identified.
    R2 rows prove that a BeforeAll whose dot-sources are all .Helpers.ps1 test-helper loads is
    anchored at the last helper dot-source and yields no 'no dot-source loads the hook' finding,
    while presence and ordering rules still apply. Every fixture hook name is absent from
    .claude/hooks and .codex/hooks.

    This file uses in-memory fixtures only: it loads no hook, creates no file, reads no
    gitignored state, and runs no process or git command.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')

    function ConvertTo-HookReferenceFixtureAst {
        # Parse one in-memory fixture into a script block AST.
        param([Parameter(Mandatory)] [string] $Source)
        $tokens = $null
        $errors = $null
        return [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
    }

    function Get-HookReferenceFixtureDotSource {
        # The first dot-source command of a parsed fixture, in source order.
        param([Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $Ast)
        $isDotSource = {
            param($node)
            $node -is [System.Management.Automation.Language.CommandAst] -and
            $node.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot
        }
        return @($Ast.FindAll($isDotSource, $true) | Sort-Object -Property { $_.Extent.StartOffset })[0]
    }
}

Describe 'issue #935 hook-reference recognizer (R1)' {
    It 'R1 identifies <Case>' -ForEach @(
        @{ Case = 'hooks literal'; Source = @'
Describe 'fixture' {
    BeforeAll { . (Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-x.ps1') }
}
'@ }
        @{ Case = 'expandable slash bound by assignment'; Source = @'
$HookRoot = '.claude/hooks'
Describe 'fixture' {
    BeforeAll { . (Join-Path $script:RepoRoot "$HookRoot/enforce-x.ps1") }
}
'@ }
        @{ Case = 'expandable slash bound by hashtable'; Source = @'
Describe 'fixture <Name>' -ForEach @(@{ Name = 'codex'; HookRoot = '.codex/hooks' }) {
    BeforeAll { . (Join-Path $script:RepoRoot "$HookRoot/enforce-x.ps1") }
}
'@ }
        @{ Case = 'expandable backslash bound by assignment'; Source = @'
$script:HookRoot = '.claude\hooks'
Describe 'fixture' {
    BeforeAll { . (Join-Path $script:RepoRoot "$script:HookRoot\enforce-x.ps1") }
}
'@ }
        @{ Case = 'expandable backslash bound by hashtable'; Source = @'
Describe 'fixture <Name>' -ForEach @(@{ Name = 'claude'; HookRoot = '.claude\hooks\' }) {
    BeforeAll { . (Join-Path $script:RepoRoot "$HookRoot\enforce-x.ps1") }
}
'@ }
        @{ Case = 'Join-Path positional bound by assignment'; Source = @'
$script:HookDirectory = Join-Path $script:RepoRoot '.claude/hooks'
Describe 'fixture' {
    BeforeAll { . (Join-Path $script:HookDirectory 'gate.ps1') }
}
'@ }
        @{ Case = 'Join-Path positional bound by hashtable'; Source = @'
Describe 'fixture <Name>' -ForEach @(@{ Name = 'codex'; HookDirectory = '.codex/hooks' }) {
    BeforeAll { . (Join-Path $HookDirectory 'gate.ps1') }
}
'@ }
        @{ Case = 'Join-Path ChildPath bound by assignment'; Source = @'
$HookDirectory = 'hooks'
Describe 'fixture' {
    BeforeAll { . (Join-Path -Path $HookDirectory -ChildPath 'gate.ps1') }
}
'@ }
        @{ Case = 'Join-Path ChildPath bound by hashtable'; Source = @'
Describe 'fixture <Name>' -ForEach @(@{ Name = 'claude'; HookDirectory = '.claude/hooks/' }) {
    BeforeAll { . (Join-Path -Path $HookDirectory -ChildPath 'gate.ps1') }
}
'@ }
        @{ Case = 'AdditionalChildPath segment list bound by assignment'; Source = @'
$RepoRoot = '/synthetic-worktrees/repo'
Describe 'fixture' {
    BeforeAll { . (Join-Path $RepoRoot '.claude' -AdditionalChildPath 'hooks', 'x.ps1') }
}
'@ }
        @{ Case = 'AdditionalChildPath segment list bound by hashtable'; Source = @'
Describe 'fixture <Surface>' -ForEach @(@{ Surface = '.codex' }) {
    BeforeAll { . (Join-Path $script:RepoRoot $Surface -AdditionalChildPath 'hooks', 'x.ps1') }
}
'@ }
    ) {
        # Arrange
        $ast = ConvertTo-HookReferenceFixtureAst -Source $Source
        $dotSource = Get-HookReferenceFixtureDotSource -Ast $ast

        # Act
        $identified = Test-EpicStateIsolationHookReference -Node $dotSource -SuiteAst $ast

        # Assert
        $identified | Should -BeTrue -Because "the $Case fixture loads a hook script"
    }

    It 'R1 does not identify <Case>' -ForEach @(
        @{ Case = 'variable bound to a non-hooks segment by assignment'; Source = @'
$HookRoot = '.claude/lib'
Describe 'fixture' {
    BeforeAll { . (Join-Path $script:RepoRoot "$HookRoot/enforce-x.ps1") }
}
'@ }
        @{ Case = 'variable bound to a non-hooks segment by hashtable'; Source = @'
Describe 'fixture <Name>' -ForEach @(@{ Name = 'codex'; HookDirectory = '.codex/hooks-archive' }) {
    BeforeAll { . (Join-Path $HookDirectory 'gate.ps1') }
}
'@ }
        @{ Case = 'unbound variable'; Source = @'
Describe 'fixture' {
    BeforeAll { . (Join-Path $HookDirectory 'gate.ps1') }
}
'@ }
    ) {
        # Arrange
        $ast = ConvertTo-HookReferenceFixtureAst -Source $Source
        $dotSource = Get-HookReferenceFixtureDotSource -Ast $ast

        # Act
        $identified = Test-EpicStateIsolationHookReference -Node $dotSource -SuiteAst $ast

        # Assert
        $identified | Should -BeFalse -Because "the $Case fixture names no hooks root"
    }
}

Describe 'issue #935 helper-only BeforeAll (R2)' {
    It 'R2 (a) helper-only block yields no dot-source finding' {
        # Arrange: every dot-source is a .Helpers.ps1 load and every pair follows the last one.
        $ast = ConvertTo-HookReferenceFixtureAst -Source @'
Describe 'fixture' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'Fixture.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'Other.Helpers.ps1')
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'R2 (b) seam mock before the last helper dot-source yields the ordering finding' {
        # Arrange: the epic-scope pair sits between the two helper dot-sources.
        $ast = ConvertTo-HookReferenceFixtureAst -Source @'
Describe 'fixture' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'Fixture.Helpers.ps1')
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        . (Join-Path $PSScriptRoot 'Other.Helpers.ps1')
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@

        # Act
        $text = @(Get-EpicStateIsolationFinding -Ast $ast) -join '; '

        # Assert
        $text | Should -BeLike '*hook dot-source, Import-Module, Mock order violated*' -Because 'the anchor is the last helper dot-source'
        $text | Should -Not -BeLike '*no dot-source loads the hook*' -Because 'a helper-only block yields no F-2 finding'
    }

    It 'R2 (c) helper-only block without the seam mock yields the presence finding' {
        # Arrange: the epic-scope mock is absent.
        $ast = ConvertTo-HookReferenceFixtureAst -Source @'
Describe 'fixture' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'Fixture.Helpers.ps1')
        Import-Module ./EpicScopeResolution.psm1
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@

        # Act
        $text = @(Get-EpicStateIsolationFinding -Ast $ast) -join '; '

        # Assert
        $text | Should -BeLike '*Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll*' -Because 'presence rules still apply to a helper-only block'
    }

    It 'R2 (d) helper plus unidentified non-helper dot-source yields no dot-source loads the hook' {
        # Arrange: Helper.ps1 is neither a .Helpers.ps1 load nor a hook reference.
        $ast = ConvertTo-HookReferenceFixtureAst -Source @'
Describe 'fixture' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'Fixture.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'Helper.ps1')
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@

        # Act
        $text = @(Get-EpicStateIsolationFinding -Ast $ast) -join '; '

        # Assert
        $text | Should -BeLike '*no dot-source loads the hook*' -Because 'a non-helper dot-source that loads no identified hook keeps the F-2 finding'
    }
}
