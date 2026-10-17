#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Memo rows for the epic-state isolation discovery helpers (issue #935, PERF).

.DESCRIPTION
    Rows that prove the census, closure-node, reader and parse memos of
    EpicStateIsolation.Discovery.Helpers.ps1 and the -Seam path of Get-EpicStateProbeFinding.
    Describe 'issue #935 PERF memo' moved here from
    enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 to keep that suite under the
    500-line limit; its row names are unchanged, and the rows added by the cycle R4 full-diff
    review (CR-G3, TEST-3) follow them.

    This file uses in-memory fixtures only: it loads no hook, creates no file, reads no
    gitignored state, and runs no process or git command.
#>

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

    # The fixtures of the Discovery suite; line endings are normalized so the edits below match on every checkout.
    $script:HookFile = '.claude/hooks/a.ps1'
    $script:HookText = @'
function Get-FixtureCheckpointContent {
    param([string] $Path)
    return (Get-Content -Raw -LiteralPath $Path)
}
'@ -replace "`r`n", "`n"
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
'@ -replace "`r`n", "`n"
}

Describe 'issue #935 PERF memo' {
    It 'PERF census memo returns the cached records for a repeated file' {
        # Arrange: one closure file that defines one seam.
        $file = [pscustomobject]@{ Path = '.claude/hooks/perf-a.ps1'; Text = $script:HookText }

        # Act: take the census of the same path and text twice.
        $first = @(Get-EpicStateSeamCensus -ClosureFile @($file))
        $second = @(Get-EpicStateSeamCensus -ClosureFile @($file))

        # Assert: the second call returns the memoized record objects.
        $second.Count | Should -Be 1
        $second[0].Name | Should -Be 'Get-FixtureCheckpointContent'
        [object]::ReferenceEquals($first[0], $second[0]) | Should -BeTrue -Because 'a repeated path and text is served from the census memo'
    }

    It 'PERF census memo recomputes for changed text' {
        # Arrange: the same path with a second text that renames the seam.
        $before = [pscustomobject]@{ Path = '.claude/hooks/perf-b.ps1'; Text = $script:HookText }
        $after = [pscustomobject]@{ Path = '.claude/hooks/perf-b.ps1'; Text = $script:HookText.Replace('Get-FixtureCheckpointContent', 'Get-RenamedCheckpointContent') }

        # Act
        $first = @(Get-EpicStateSeamCensus -ClosureFile @($before))
        $second = @(Get-EpicStateSeamCensus -ClosureFile @($after))

        # Assert: the changed text is a different memo key and is censused afresh.
        $second.Count | Should -Be 1
        $second[0].Name | Should -Be 'Get-RenamedCheckpointContent'
        [object]::ReferenceEquals($first[0], $second[0]) | Should -BeFalse -Because 'a changed text must not be served from the memo'
    }

    It 'PERF census memo keys by path as well as text' {
        # Arrange and act: the same text as a hook file and as a library module.
        $hookCensus = @(Get-EpicStateSeamCensus -ClosureFile @([pscustomobject]@{ Path = '.claude/hooks/perf-c.ps1'; Text = $script:HookText }))
        $moduleCensus = @(Get-EpicStateSeamCensus -ClosureFile @([pscustomobject]@{ Path = '.claude/lib/perf/perf-c.psm1'; Text = $script:HookText }))

        # Assert: each path gets its own class and defining file.
        $hookCensus[0].Class | Should -Be 'HookLocalContentSeam'
        $moduleCensus[0].Class | Should -Be 'ModuleTextSeam'
        $moduleCensus[0].DefiningFile | Should -Be '.claude/lib/perf/perf-c.psm1'
    }

    It 'PERF closure memo reads each file once for a repeated closure' {
        # Arrange: a counting reader over a hook that imports a library module.
        $count = @{ Value = 0 }
        $table = @{ $script:HookFile = "Import-Module (Join-Path `$PSScriptRoot '../lib/fixture/b.psm1')`n"; '.claude/lib/fixture/b.psm1' = "function Get-Thing { return 1 }`n" }
        $reader = { param([string] $RelativePath) $count.Value++; if ($table.ContainsKey($RelativePath)) { $table[$RelativePath] } else { $null } }.GetNewClosure()

        # Act: walk the closure twice with the same reader.
        $first = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource $reader)
        $readsAfterFirst = $count.Value
        $second = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource $reader)

        # Assert: the second walk reads no file and returns the same files in the same order.
        $readsAfterFirst | Should -Be 3 -Because 'the first walk reads .claude/hooks/a.ps1, .codex/hooks/a.ps1 and .claude/lib/fixture/b.psm1 once each'
        $count.Value | Should -Be $readsAfterFirst -Because 'a repeated closure with the same reader is served from the closure-node memo'
        (@($first | ForEach-Object { $_.Path }) -join ',') | Should -Be '.claude/hooks/a.ps1,.claude/lib/fixture/b.psm1'
        (@($second | ForEach-Object { $_.Path }) -join ',') | Should -Be '.claude/hooks/a.ps1,.claude/lib/fixture/b.psm1'
    }

    It 'PERF closure memo recomputes for a reader with changed text' {
        # Arrange: two readers over the same paths; in the second, the hook imports another module.
        $tableA = @{ $script:HookFile = "Import-Module (Join-Path `$PSScriptRoot '../lib/fixture/b.psm1')`n"; '.claude/lib/fixture/b.psm1' = "function Get-Thing { return 1 }`n"; '.claude/lib/fixture/c.psm1' = "function Get-Other { return 2 }`n" }
        $tableB = @{} + $tableA
        $tableB[$script:HookFile] = "Import-Module (Join-Path `$PSScriptRoot '../lib/fixture/c.psm1')`n"

        # Act
        $first = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource (Get-FixtureReader -File $tableA))
        $second = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource (Get-FixtureReader -File $tableB))

        # Assert: the reader with the changed hook text is walked afresh.
        (@($first | ForEach-Object { $_.Path }) -join ',') | Should -Be '.claude/hooks/a.ps1,.claude/lib/fixture/b.psm1'
        (@($second | ForEach-Object { $_.Path }) -join ',') | Should -Be '.claude/hooks/a.ps1,.claude/lib/fixture/c.psm1'
    }

    It 'PERF memo starts empty when the helper is dot-sourced' {
        # Arrange: populate every memo of this suite.
        $null = @(Get-EpicStateSeamCensus -ClosureFile @([pscustomobject]@{ Path = '.claude/hooks/perf-d.ps1'; Text = $script:HookText }))
        $null = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource (Get-FixtureReader -File @{ $script:HookFile = $script:HookText }))
        $null = Get-EpicStateSourceReader -RepoRoot $script:RepoRoot
        $populated = $script:EpicStateCensusCache.Count -gt 0 -and $script:EpicStateClosureNodeCache.Count -gt 0 -and $script:EpicStateReaderCache.Count -gt 0 -and $script:EpicStateParseCache.Count -gt 0

        # Act: dot-source the helper, as each suite does in BeforeDiscovery or BeforeAll.
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')

        # Assert: every memo is replaced by an empty one, so a separate suite starts empty.
        $populated | Should -BeTrue
        $script:EpicStateCensusCache.Count | Should -Be 0
        $script:EpicStateClosureNodeCache.Count | Should -Be 0
        $script:EpicStateReaderCache.Count | Should -Be 0
        $script:EpicStateParseCache.Count | Should -Be 0
    }

    It 'PERF parse memo keeps texts that differ only in letter case apart' {
        # Arrange: two texts for one path that differ only in the letter case of the seam name.
        $upperText = $script:HookText.Replace('Get-FixtureCheckpointContent', 'GET-FIXTURECHECKPOINTCONTENT')

        # Act: take the census of the original text, then of the upper-case text.
        $lower = @(Get-EpicStateSeamCensus -ClosureFile @([pscustomobject]@{ Path = '.claude/hooks/perf-e.ps1'; Text = $script:HookText }))
        $upper = @(Get-EpicStateSeamCensus -ClosureFile @([pscustomobject]@{ Path = '.claude/hooks/perf-e.ps1'; Text = $upperText }))

        # Assert: the ordinal parse memo parses the upper-case text on its own, so its census reports the upper-case name.
        $lower[0].Name | Should -BeExactly 'Get-FixtureCheckpointContent'
        $upper[0].Name | Should -BeExactly 'GET-FIXTURECHECKPOINTCONTENT' -Because 'a text that differs only in letter case must not be served from the parse memo'
    }

    It 'PERF reader memo returns one reader per repository root' {
        # Arrange and act: two readers for this repository root and one for another root; no file is read.
        $first = Get-EpicStateSourceReader -RepoRoot $script:RepoRoot
        $second = Get-EpicStateSourceReader -RepoRoot $script:RepoRoot
        $other = Get-EpicStateSourceReader -RepoRoot '/synthetic-worktrees/other'

        # Assert: a repeated root is served from the reader memo, and another root gets its own reader.
        [object]::ReferenceEquals($first, $second) | Should -BeTrue -Because 'a repeated repository root is served from the reader memo'
        [object]::ReferenceEquals($first, $other) | Should -BeFalse -Because 'each repository root has its own reader'
    }

    It 'PERF closure memo keys by library directory' {
        # Arrange: one reader over a hook that imports a module by its leaf name only.
        $reader = Get-FixtureReader -File @{ $script:HookFile = "Import-Module 'b.psm1'`n"; '.claude/lib/fixture/b.psm1' = "function Get-Thing { return 1 }`n" }

        # Act: walk the closure with no library directory, then with the same reader and one library directory.
        $withoutLibrary = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource $reader -LibraryDirectory @())
        $withLibrary = @(Get-EpicStateLoadedSourceClosure -SuiteText $script:LoadHookSuite -ReadSource $reader -LibraryDirectory @('.claude/lib/fixture'))

        # Assert: the library directories are part of the successor memo key.
        (@($withoutLibrary | ForEach-Object { $_.Path }) -join ',') | Should -Be '.claude/hooks/a.ps1'
        (@($withLibrary | ForEach-Object { $_.Path }) -join ',') | Should -Be '.claude/hooks/a.ps1,.claude/lib/fixture/b.psm1' -Because 'another library directory list is another successor memo key'
    }

    It 'PERF probe finding with supplied seams' {
        # Arrange: the suite and reader of the Discovery row 'AC-6 suite lacking a probe call yields a finding'.
        $suite = $script:LoadHookSuite.Replace("`n}`nDescribe", "`n    Mock Get-EpicScopeCheckpointText { `$null }`n}`nDescribe")
        $reader = Get-FixtureReader -File @{ 'tests/scripts/fixture/Sample.Tests.ps1' = $suite; $script:HookFile = $script:ProbeHookText }
        $target = @{ RepoRoot = '/synthetic-worktrees/fixture'; RelativePath = 'tests/scripts/fixture/Sample.Tests.ps1' }

        # Act: scan for the seams, supply them, supply none, and supply them with a reader that lacks the suite.
        $scanned = @(Get-EpicStateProbeFinding @target -ReadSource $reader)
        $supplied = @(Get-EpicStateProbeFinding @target -ReadSource $reader -Seam @('Get-EpicScopeCheckpointText'))
        $none = @(Get-EpicStateProbeFinding @target -ReadSource $reader -Seam @())
        $missing = @(Get-EpicStateProbeFinding @target -ReadSource (Get-FixtureReader -File @{}) -Seam @('Get-EpicScopeCheckpointText'))

        # Assert: supplied seams give the scanned finding, no seams give none, and a missing suite gives a named finding.
        $scanned.Count | Should -Be 1
        $supplied | Should -BeExactly $scanned[0] -Because 'a supplied seam list gives the same finding as the scan'
        $none.Count | Should -Be 0 -Because 'an empty seam list leaves no probe requirement'
        $missing | Should -BeExactly 'tests/scripts/fixture/Sample.Tests.ps1: suite file not found' -Because 'a missing suite gives a named finding, not a binding error'
    }
}
