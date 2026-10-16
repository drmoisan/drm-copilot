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

Describe 'issue #935 F-3 hook-reference detector' {
    It 'F-3 detects <Form>' -ForEach @(
        @{ Form = 'RootVariable bare'; Name = 'gate.ps1'; Kind = 'RootVariable'; Root = '.claude/hooks'; Source = @'
$HookRoot = Join-Path $RepoRoot '.claude/hooks'
Describe 'fixture' {
    BeforeAll { . (Join-Path $HookRoot 'gate.ps1') }
}
'@ }
        @{ Form = 'RootVariable expandable'; Name = 'gate.ps1'; Kind = 'RootVariable'; Root = '.codex/hooks'; Source = @'
Describe 'fixture <Name>' -ForEach @(@{ Name = 'codex'; HookRoot = '.codex/hooks' }) {
    BeforeAll { . (Join-Path $script:RepoRoot "$HookRoot/gate.ps1") }
}
'@ }
        @{ Form = 'two-level binding'; Name = 'gate.ps1'; Kind = 'RootVariable'; Root = '.claude/hooks'; Source = @'
$script:HookDirectory = Join-Path $RepoRoot '.claude/hooks'
$script:HookPath = Join-Path $script:HookDirectory 'gate.ps1'
Describe 'fixture' {
    BeforeAll { . $script:HookPath }
}
'@ }
        @{ Form = 'Segment'; Name = 'gate.ps1'; Kind = 'Segment'; Root = '.claude/hooks'; Source = @'
Describe 'fixture' {
    It 'runs the hook' { & (Join-Path $RepoRoot '.claude' 'hooks' 'gate.ps1') }
}
'@ }
        @{ Form = 'Dynamic spawn'; Name = '*'; Kind = 'Dynamic'; Root = '.codex/hooks'; Source = @'
$HookRoot = '.codex/hooks'
Describe 'fixture' {
    It 'spawns every hook' {
        foreach ($hookName in $script:HookNames) {
            $info = [System.Diagnostics.ProcessStartInfo]::new()
            $info.ArgumentList.Add((Join-Path $HookRoot $hookName))
        }
    }
}
'@ }
    ) {
        # Arrange
        $ast = ConvertTo-HookReferenceFixtureAst -Source $Source

        # Act
        $references = @(Get-EpicStateIsolationHookReference -Ast $ast)

        # Assert
        $match = @($references | Where-Object { $_.Name -eq $Name -and $_.Form -eq $Kind -and $_.Root -eq $Root })
        $match.Count | Should -Be 1 -Because "the $Form fixture loads $Name from $Root; got: $(@($references | ForEach-Object { "$($_.Form):$($_.Name):$($_.Root)" }) -join ', ')"
    }

    It 'F-3 ignores a Join-Path used only by <Reader>' -ForEach @(
        @{ Reader = 'Get-FileHash'; Source = @'
$HookRoot = '.claude/hooks'
Describe 'fixture' {
    It 'hashes the hook' { (Get-FileHash -LiteralPath (Join-Path $HookRoot 'gate.ps1')).Hash | Should -Not -BeNullOrEmpty }
}
'@ }
        @{ Reader = 'Get-Content'; Source = @'
$HookRoot = '.claude/hooks'
Describe 'fixture' {
    It 'reads the hook' { Get-Content -Raw -LiteralPath (Join-Path $HookRoot 'gate.ps1') | Should -Not -BeNullOrEmpty }
}
'@ }
        @{ Reader = 'ParseFile'; Source = @'
$HookRoot = '.claude/hooks'
Describe 'fixture' {
    It 'parses the hook' { [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $HookRoot 'gate.ps1'), [ref] $null, [ref] $null) | Should -Not -BeNullOrEmpty }
}
'@ }
    ) {
        # Arrange
        $ast = ConvertTo-HookReferenceFixtureAst -Source $Source

        # Act
        $references = @(Get-EpicStateIsolationHookReference -Ast $ast)

        # Assert
        $references.Count | Should -Be 0 -Because "a Join-Path read by $Reader does not load the hook"
    }

    It 'F-3 process-spawning report includes a variable-built hook path' {
        # Arrange: a process start description whose arguments are built from a .codex/hooks root.
        $suite = @'
$HookRoot = Join-Path $RepoRoot '.codex/hooks'
Describe 'fixture' {
    It 'spawns the hooks' {
        $info = [System.Diagnostics.ProcessStartInfo]::new()
        $info.ArgumentList.Add((Join-Path $HookRoot 'gate.ps1'))
        $info.ArgumentList.Add((Join-Path $HookRoot $script:HookName))
    }
}
'@

        # Act
        $launched = @(Get-EpicStateProcessSpawningHook -SuiteText $suite)

        # Assert
        $launched | Should -Contain 'gate.ps1' -Because 'a literal leaf over a hooks root is reported by name'
        $launched | Should -Contain '*(.codex/hooks)' -Because 'a non-literal leaf is reported as a dynamic load of its root'
    }

    It 'F-3 closure stays literal-seeded' {
        # Arrange: the reader holds the hook, and the suite reaches it only through a root variable.
        $table = @{ '.claude/hooks/gate.ps1' = "function Get-FixtureCheckpointText {`n    param([string] `$Path)`n    return (Get-Content -Raw -LiteralPath `$Path)`n}`n" }
        $reader = { param([string] $RelativePath) if ($table.ContainsKey($RelativePath)) { $table[$RelativePath] } else { $null } }.GetNewClosure()
        $suite = @'
$HookRoot = '.claude/hooks'
Describe 'fixture' {
    BeforeAll { . (Join-Path $HookRoot 'gate.ps1') }
}
'@

        # Act
        $closure = @(Get-EpicStateLoadedSourceClosure -SuiteText $suite -ReadSource $reader)

        # Assert
        $closure.Count | Should -Be 0 -Because 'variable-built loads are reported, not added to the closure'
    }
}

Describe 'issue #935 CR-N3 load-position parameters' {
    # The process-start cmdlet name is composed at run time from __SPAWN__, so it never appears as one token here.
    It 'CR-N3 does not report the separate-token value of <Parameter>' -ForEach @(
        @{ Parameter = 'Import-Module -Prefix'; Source = @'
$HookRoot = '.claude/hooks'
$Prefix = Join-Path $HookRoot 'gate.ps1'
Describe 'fixture' {
    BeforeAll { Import-Module -Prefix $Prefix ./Fixture.psm1 }
}
'@ }
        @{ Parameter = 'process-start -WorkingDirectory'; Source = @'
$HookRoot = '.codex/hooks'
Describe 'fixture' {
    It 'starts a shell' { __SPAWN__ -WorkingDirectory (Join-Path $HookRoot 'gate.ps1') -FilePath fixture-shell }
}
'@ }
    ) {
        # Arrange
        $ast = ConvertTo-HookReferenceFixtureAst -Source $Source.Replace('__SPAWN__', 'Start' + '-' + 'Process')

        # Act
        $references = @(Get-EpicStateIsolationHookReference -Ast $ast)

        # Assert
        $references.Count | Should -Be 0 -Because "the value of $Parameter is not a load position; got: $(@($references | ForEach-Object { "$($_.Form):$($_.Name):$($_.Root)" }) -join ', ')"
    }

    It 'CR-N3 binds Join-Path positionals after the separate-token value of -Credential' {
        # Arrange
        $Source = @'
$HookRoot = '.claude/hooks'
Describe 'fixture' {
    BeforeAll { . (Join-Path -Credential $FixtureCredential $HookRoot 'gate.ps1') }
}
'@
        $ast = ConvertTo-HookReferenceFixtureAst -Source $Source

        # Act
        $references = @(Get-EpicStateIsolationHookReference -Ast $ast)

        # Assert
        $match = @($references | Where-Object { $_.Name -eq 'gate.ps1' -and $_.Form -eq 'RootVariable' -and $_.Root -eq '.claude/hooks' })
        $references.Count | Should -Be 1 -Because "the -Credential value is skipped, so Path is `$HookRoot and ChildPath is 'gate.ps1'"
        $match.Count | Should -Be 1 -Because 'the record names gate.ps1 as a RootVariable load from .claude/hooks'
    }

    It 'CR-N3 still reports a positional load after the switch <Switch>' -ForEach @(
        @{ Switch = 'Import-Module -Force'; Root = '.claude/hooks'; Source = @'
$HookRoot = '.claude/hooks'
Describe 'fixture' {
    BeforeAll { Import-Module -Force (Join-Path $HookRoot 'gate.ps1') }
}
'@ }
        @{ Switch = 'process-start -NoNewWindow'; Root = '.codex/hooks'; Source = @'
$HookRoot = '.codex/hooks'
Describe 'fixture' {
    It 'starts the hook' { __SPAWN__ -NoNewWindow (Join-Path $HookRoot 'gate.ps1') }
}
'@ }
    ) {
        # Arrange
        $ast = ConvertTo-HookReferenceFixtureAst -Source $Source.Replace('__SPAWN__', 'Start' + '-' + 'Process')

        # Act
        $references = @(Get-EpicStateIsolationHookReference -Ast $ast)

        # Assert
        $match = @($references | Where-Object { $_.Name -eq 'gate.ps1' -and $_.Form -eq 'RootVariable' -and $_.Root -eq $Root })
        $references.Count | Should -Be 1 -Because "a switch takes no value, so the positional after $Switch is still a load"
        $match.Count | Should -Be 1 -Because "the record names gate.ps1 as a RootVariable load from $Root"
    }
}

Describe 'issue #935 CR-R1 separate-value edge cases' {
    # Direct rows for Test-EpicStateIsolationSeparateValue over in-memory command ASTs (issue #935, CR-R1).
    It 'CR-R1 separate value: <Case>' -ForEach @(
        @{ Case = 'value parameter as the last element'; Source = 'Import-Module ./Fixture.psm1 -Prefix'; Index = 2; Expected = $false }
        @{ Case = 'value parameter followed by another parameter'; Source = 'Import-Module -Prefix -Force ./Fixture.psm1'; Index = 1; Expected = $false }
        @{ Case = 'value parameter with an attached argument'; Source = 'Import-Module -Prefix:Pre ./Fixture.psm1'; Index = 1; Expected = $false }
        @{ Case = 'abbreviated parameter name'; Source = 'Import-Module -Pref Pre ./Fixture.psm1'; Index = 1; Expected = $false }
        @{ Case = 'element that is not a parameter'; Source = 'Import-Module ./Fixture.psm1 -Force'; Index = 1; Expected = $false }
        @{ Case = 'value parameter followed by its value'; Source = 'Import-Module -Prefix Pre ./Fixture.psm1'; Index = 1; Expected = $true }
        @{ Case = 'common parameter -ErrorAction followed by its value'; Source = 'Import-Module -ErrorAction Stop ./Fixture.psm1'; Index = 1; Expected = $true }
        @{ Case = 'common parameter -OutVariable followed by its value'; Source = 'Import-Module -OutVariable loaded ./Fixture.psm1'; Index = 1; Expected = $true }
    ) {
        # Arrange
        $isCommand = { param($node) $node -is [System.Management.Automation.Language.CommandAst] }
        $command = (ConvertTo-HookReferenceFixtureAst -Source $Source).Find($isCommand, $true)
        $elements = @($command.CommandElements)

        # Act
        $result = Test-EpicStateIsolationSeparateValue -Element $elements -Index $Index

        # Assert
        $result | Should -Be $Expected -Because "element $Index of '$Source' ($Case)"
    }
}
