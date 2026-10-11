#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Discovery guard for the epic-state isolation of the hook suites on both surfaces (issue #737).

.DESCRIPTION
    Computes the suite population by directory enumeration of the two hook-suite directories
    (Claude and Codex), so no suite list is written here. For each discovered suite the guard
    computes the loaded-source closure from string literals, takes a census of the read seams in
    that closure, and requires the suite to comply with each seam by form F1 (a direct null Mock in
    the outermost BeforeAll, or the Register-EpicStateBaselineMock helper form), form F2 (seam under
    test with synthetic-path literals), or form F3 (a cwd-derived resolver pinned to a synthetic
    root). Process-spawning suites are reported and never fail the guard. Fixture rows prove each
    rule over in-memory text.

    This file loads no hook, creates no file, reads no gitignored state, and runs no git command.
    It reads only committed files located from $PSScriptRoot.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')
    $discoveryRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:SurfaceRow = @(foreach ($surface in 'claude-hooks', 'codex-hooks') { @{ Surface = $surface } })
    $script:SuiteRow = @(foreach ($row in $script:SurfaceRow) {
            foreach ($suite in @(Get-EpicStateDiscoveredSuite -RepoRoot $discoveryRoot -Surface $row.Surface)) { @{ Path = $suite; Surface = $row.Surface } }
        })
    # Probe rows exist only for suites that comply by form F1 or the helper form for a named seam (PI-2).
    $script:ProbeRow = @(foreach ($row in $script:SuiteRow) {
            if (@(Get-EpicStateProbeSeam -RepoRoot $discoveryRoot -RelativePath $row.Path).Count -gt 0) { @{ Path = $row.Path } }
        })
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path

    function Get-FixtureReader {
        # A reader over an in-memory file table (repository-relative path to text); no file is read.
        param([Parameter(Mandatory)] [hashtable] $File)
        $table = $File
        return {
            param([string] $RelativePath)
            if ($table.ContainsKey($RelativePath)) { return $table[$RelativePath] }
            return $null
        }.GetNewClosure()
    }

    function Get-FixtureCompliance {
        # Compliance findings for one in-memory suite and the hook files it loads.
        param([Parameter(Mandatory)] [string] $SuiteText, [hashtable] $Hook = @{})
        $files = @{ 'tests/scripts/fixture/Sample.Tests.ps1' = $SuiteText }
        foreach ($key in $Hook.Keys) { $files[$key] = $Hook[$key] }
        $reader = Get-FixtureReader -File $files
        return @(Get-EpicStateSuiteCompliance -RepoRoot '/synthetic-worktrees/fixture' -RelativePath 'tests/scripts/fixture/Sample.Tests.ps1' -ReadSource $reader)
    }

    $script:HookFile = '.claude/hooks/a.ps1'
    $script:HookText = @'
function Get-FixtureCheckpointContent {
    param([string] $Path)
    return (Get-Content -Raw -LiteralPath $Path)
}
'@
    $script:ProbeHookText = @'
function Get-EpicScopeCheckpointText {
    param([string] $Path)
    return (Get-Content -Raw -LiteralPath $Path)
}
'@ -replace "`r`n", "`n"
    $script:LoadHookSuite = @'
BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/a.ps1')
}
Describe 'fixture' { It 'does not call the seam' { $true | Should -BeTrue } }
'@
    # Normalize line endings so the fixture edits below match on every checkout.
    $script:HookText = $script:HookText -replace "`r`n", "`n"
    $script:LoadHookSuite = $script:LoadHookSuite -replace "`r`n", "`n"

    function Get-HardCodedSuiteLiteral {
        # Parse one committed file and return the string literals that end in .Tests.ps1 and name a hooks directory.
        param([Parameter(Mandatory)] [string] $Path)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $tokens, [ref] $errors)
        $isLiteral = {
            param($node)
            $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
            $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
        }
        foreach ($node in $ast.FindAll($isLiteral, $true)) {
            $value = [string]$node.Value
            if ($value.EndsWith('.Tests.ps1', [System.StringComparison]::Ordinal) -and $value.Contains('hooks')) { $value }
        }
    }
}

Describe 'discovery guard (both hook surfaces)' {
    It 'AC-2 non-vacuity <Surface> yields at least one suite' -ForEach $script:SurfaceRow {
        # Arrange and act: enumerate the surface directory.
        $suites = @(Get-EpicStateDiscoveredSuite -RepoRoot $script:RepoRoot -Surface $Surface)

        # Assert: a surface that yields nothing would make every per-suite row vacuous.
        $suites.Count | Should -BeGreaterThan 0 -Because "the $Surface directory must hold at least one suite"
    }

    It 'AC-4 <Path> complies with the baseline isolation form for every closure seam' -ForEach $script:SuiteRow {
        # Arrange and act: compute the closure, the seam census, and the compliance findings.
        $findings = @(Get-EpicStateSuiteCompliance -RepoRoot $script:RepoRoot -RelativePath $Path)

        # Assert: no finding; the message names the suite, the seam, and the violated rule.
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-6 <Path> calls the interception probe from inside an It' -ForEach $script:ProbeRow {
        # Arrange and act: parse the suite and look for a probe call inside an It.
        $findings = @(Get-EpicStateProbeFinding -RepoRoot $script:RepoRoot -RelativePath $Path)

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-6 suite lacking a probe call yields a finding' {
        # Arrange and act: the suite complies for the epic-scope seam by a direct null Mock and calls no probe.
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Mock Get-EpicScopeCheckpointText { `$null }`n}`nDescribe")
        $reader = Get-FixtureReader -File @{ 'tests/scripts/fixture/Sample.Tests.ps1' = $suite; $script:HookFile = $script:ProbeHookText }
        $findings = @(Get-EpicStateProbeFinding -RepoRoot '/synthetic-worktrees/fixture' -RelativePath 'tests/scripts/fixture/Sample.Tests.ps1' -ReadSource $reader)

        # Assert
        $findings.Count | Should -Be 1
        $findings[0] | Should -BeLike '*never calls Invoke-EpicStateInterceptionProbe*'
    }

    It 'AC-6 suite with a probe call yields none' {
        # Arrange and act: the same suite with a probe call inside an It.
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Mock Get-EpicScopeCheckpointText { `$null }`n}`nDescribe") +
        "Describe 'probe' { It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' } }`n"
        $reader = Get-FixtureReader -File @{ 'tests/scripts/fixture/Sample.Tests.ps1' = $suite; $script:HookFile = $script:ProbeHookText }
        $findings = @(Get-EpicStateProbeFinding -RepoRoot '/synthetic-worktrees/fixture' -RelativePath 'tests/scripts/fixture/Sample.Tests.ps1' -ReadSource $reader)

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-5 process-spawning report <Surface>' -ForEach $script:SurfaceRow {
        # Arrange and act: collect the report line of every process-spawning suite on the surface.
        $collect = {
            foreach ($suite in @(Get-EpicStateDiscoveredSuite -RepoRoot $script:RepoRoot -Surface $Surface)) {
                Get-EpicStateProcessSpawningReport -RepoRoot $script:RepoRoot -RelativePath $suite
            }
        }
        { $script:ReportLine = @(& $collect) } | Should -Not -Throw

        # Assert: the row reports each launched hook and never fails on an entry; the lines go to the information stream.
        foreach ($line in $script:ReportLine) { Write-Information $line -InformationAction Continue }
    }

    It 'AC-2 no hard-coded suite list in N2' {
        # Arrange and act: parse this file.
        $literals = @(Get-HardCodedSuiteLiteral -Path (Join-Path $PSScriptRoot 'enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1'))

        # Assert
        $literals.Count | Should -Be 0 -Because ('suites are discovered by enumeration; found: ' + ($literals -join '; '))
    }

    It 'AC-2 no hard-coded suite list or decision D9 note in the legacy guard' {
        # Arrange and act: parse the legacy guard and flatten its text (line breaks and comment markers become one space).
        $legacyPath = Join-Path $PSScriptRoot 'enforce-gate-suites.EpicStateIsolation.Tests.ps1'
        $literals = @(Get-HardCodedSuiteLiteral -Path $legacyPath)
        $flat = [regex]::Replace((Get-Content -Raw -LiteralPath $legacyPath), '\s*\r?\n\s*(#\s*)?', ' ')

        # Assert
        $literals.Count | Should -Be 0 -Because ('the fixed list belongs to the discovery guard; found: ' + ($literals -join '; '))
        $flat.Contains('decision D9') | Should -BeFalse -Because 'the known-limit note is obsolete once suites are discovered'
    }

    It 'AC-3 closure-only variable-driven load is detected' {
        # Arrange: the suite names only a.ps1; a.ps1 loads b.psm1 through a variable assigned from a string literal.
        $hook = "`$modulePath = Join-Path `$PSScriptRoot '../lib/fixture/b.psm1'`nImport-Module `$modulePath`n"
        $module = "function Get-FixtureCheckpointText {`n    param([string] `$Path)`n    return [System.IO.File]::ReadAllText(`$Path)`n}`n"
        $reader = Get-FixtureReader -File @{ $script:HookFile = $hook; '.claude/lib/fixture/b.psm1' = $module }

        # Act
        $closure = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource $reader)
        $census = @(Get-EpicStateSeamCensus -ClosureFile $closure)

        # Assert: the module reached only through the variable is in the closure and its seam is counted.
        @($closure | ForEach-Object { $_.Path }) | Should -Contain '.claude/lib/fixture/b.psm1'
        @($census | Where-Object { $_.Name -eq 'Get-FixtureCheckpointText' }).Count | Should -Be 1
    }

    It 'AC-3 suite whose rows never reach the seam is still flagged' {
        # Arrange and act: the closure holds a seam and no row calls it.
        $findings = Get-FixtureCompliance -SuiteText $script:LoadHookSuite -Hook @{ $script:HookFile = $script:HookText }

        # Assert
        $findings.Count | Should -BeGreaterThan 0 -Because 'a closure that holds a seam needs the baseline mock whether or not a row reaches it'
        ($findings -join '; ') | Should -BeLike '*seam Get-FixtureCheckpointContent*'
    }

    It 'AC-5 process-spawning fixture is reported and does not fail' {
        # Arrange: the suite builds a process start description and names a hook script; the hook holds no seam.
        $suite = "BeforeAll {`n    `$startInfo = [System.Diagnostics.ProcessStartInfo]::new()`n    `$startInfo.ArgumentList.Add((Join-Path `$PSScriptRoot '../../../.claude/hooks/x.ps1'))`n}`n"
        $files = @{ 'tests/scripts/fixture/Sample.Tests.ps1' = $suite; '.claude/hooks/x.ps1' = "function Get-Thing { return 1 }`n" }
        $reader = Get-FixtureReader -File $files

        # Act
        $report = @(Get-EpicStateProcessSpawningReport -RepoRoot '/synthetic-worktrees/fixture' -RelativePath 'tests/scripts/fixture/Sample.Tests.ps1' -ReadSource $reader)
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ '.claude/hooks/x.ps1' = $files['.claude/hooks/x.ps1'] }

        # Assert: one report line names the hook, and the compliance function raises no finding.
        $report.Count | Should -Be 1
        $report[0] | Should -BeLike '*launches x.ps1*'
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-2 missing suite yields a finding' {
        # Arrange and act: the reader holds no file.
        $reader = Get-FixtureReader -File @{}
        $findings = @(Get-EpicStateSuiteCompliance -RepoRoot '/synthetic-worktrees/fixture' -RelativePath 'tests/scripts/fixture/Missing.Tests.ps1' -ReadSource $reader)

        # Assert
        $findings.Count | Should -Be 1
        $findings[0] | Should -BeLike '*Missing.Tests.ps1*not found*'
    }

    It 'AC-2 unparseable suite yields a finding' {
        # Arrange and act: the suite text does not parse.
        $reader = Get-FixtureReader -File @{ 'tests/scripts/fixture/Broken.Tests.ps1' = 'Describe ( {' }
        $findings = @(Get-EpicStateSuiteCompliance -RepoRoot '/synthetic-worktrees/fixture' -RelativePath 'tests/scripts/fixture/Broken.Tests.ps1' -ReadSource $reader)

        # Assert
        $findings.Count | Should -Be 1
        $findings[0] | Should -BeLike '*Broken.Tests.ps1: parse error:*'
    }

    It 'AC-4 helper form satisfies the requirement' {
        # Arrange: a Register-EpicStateBaselineMock statement after the hook dot-source names the seam.
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Register-EpicStateBaselineMock -Seam 'Get-FixtureCheckpointContent' -Surface 'Claude'`n}`nDescribe")

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $script:HookText }

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-4 helper form naming the wrong seam is a finding' {
        # Arrange: the helper statement names a seam that the closure does not require.
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Register-EpicStateBaselineMock -Seam 'Get-SomethingElse' -Surface 'Claude'`n}`nDescribe")

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $script:HookText }

        # Assert
        $findings.Count | Should -BeGreaterThan 0 -Because 'the required seam is not named by any statement'
    }

    It 'AC-4 script-scope seam needs no import' {
        # Arrange: a direct null Mock of the script-scope seam after the dot-source, with no Import-Module.
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Mock Get-FixtureCheckpointContent { `$null }`n}`nDescribe")

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $script:HookText }

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-4 form F2 fixture complies' {
        # Arrange: the seam is under test, every call passes a synthetic path, and Test-Path and Get-Content are mocked on it.
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Mock Test-Path -ParameterFilter { `$LiteralPath -like '/synthetic-worktrees/*' } { `$true }`n    Mock Get-Content -ParameterFilter { `$LiteralPath -like '/synthetic-worktrees/*' } { '{}' }`n}`nDescribe") +
        "Describe 'seam under test' { It 'reads a synthetic path' { Get-FixtureCheckpointContent -Path '/synthetic-worktrees/item/state.json' | Should -Be '{}' } }`n"

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $script:HookText }

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-4 form F3 fixture complies' {
        # Arrange: a cwd-derived resolver seam that the outermost BeforeAll pins to a synthetic root.
        $hook = "function Get-FixtureCheckpointResolver {`n    `$base = (Get-Location).Path`n    return (Get-Content -Raw -LiteralPath (Join-Path `$base 'artifacts/orchestration/state.json'))`n}`n"
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Mock Get-FixtureCheckpointResolver { '/synthetic-worktrees/default-session' }`n}`nDescribe")

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $hook }

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-4 helper form with a -ForEach-bound -Seam variable satisfies the requirement' {
        # Arrange: the Seam array comes from the -ForEach entry, as in the AttributionTrailer shape.
        $suite = "Describe 'fixture' -ForEach @(`n    @{ GateRelativePath = '.claude/hooks/a.ps1'; Surface = 'Claude'; Seam = @('Get-FixtureCheckpointContent') }`n) {`n    BeforeAll {`n        . (Join-Path `$PSScriptRoot `$GateRelativePath)`n        Register-EpicStateBaselineMock -Seam `$Seam -Surface `$Surface`n    }`n}`n"

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $script:HookText }

        # Assert
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-4 helper form with an unresolvable -Seam variable is a finding' {
        # Arrange: the same text with no Seam entry and no assignment to the variable.
        $suite = "Describe 'fixture' -ForEach @(`n    @{ GateRelativePath = '.claude/hooks/a.ps1'; Surface = 'Claude' }`n) {`n    BeforeAll {`n        . (Join-Path `$PSScriptRoot `$GateRelativePath)`n        Register-EpicStateBaselineMock -Seam `$Seam -Surface `$Surface`n    }`n}`n"

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $script:HookText }

        # Assert
        $findings.Count | Should -BeGreaterThan 0 -Because 'a variable that resolves to no constant contributes no seam'
    }

    It 'AC-4 helper form with ExtraSeam entries adds a seam and an empty entry adds none' {
        # Arrange: two -ForEach entries and two register statements; one hook seam comes from Seam, the other only from the first ExtraSeam.
        $hook = $script:HookText + "function Get-OtherCheckpointContent {`n    param([string] `$Path)`n    return (Get-Content -Raw -LiteralPath `$Path)`n}`n"
        $suite = "Describe 'fixture' -ForEach @(`n    @{ GateRelativePath = '.claude/hooks/a.ps1'; Surface = 'Claude'; Seam = @('Get-FixtureCheckpointContent'); ExtraSeam = @('Get-OtherCheckpointContent') }`n    @{ GateRelativePath = '.claude/hooks/a.ps1'; Surface = 'Claude'; Seam = @('Get-FixtureCheckpointContent'); ExtraSeam = @() }`n) {`n    BeforeAll {`n        . (Join-Path `$PSScriptRoot `$GateRelativePath)`n        Register-EpicStateBaselineMock -Seam `$Seam -Surface `$Surface`n        Register-EpicStateBaselineMock -Seam `$ExtraSeam -Surface `$Surface`n    }`n}`n"

        # Act
        $findings = Get-FixtureCompliance -SuiteText $suite -Hook @{ $script:HookFile = $hook }

        # Assert: the extra name satisfies its requirement and the empty array literal adds no finding.
        $findings.Count | Should -Be 0 -Because ($findings -join '; ')
    }
}
