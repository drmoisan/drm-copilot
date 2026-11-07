#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for scripts/dev-tools/ProcessReductionChain.psm1 (issue #1097).

.DESCRIPTION
    Fixtures are in-memory strings built here, and no test creates a file. The read-seam
    test mocks the ledger reader and the filesystem cmdlets inside InModuleScope, so the
    mocks hold under a PoshQC-hosted run.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/dev-tools/ProcessReductionChain.psm1') -Force

    $script:Fence = '`' * 4

    function Get-TestPatchSection {
        param([string] $Path, [int] $Start, [string[]] $Before = @(), [string[]] $Removed = @(), [string[]] $Added = @(), [string[]] $After = @())
        $old = $Before.Count + $Removed.Count + $After.Count
        $new = $Before.Count + $Added.Count + $After.Count
        $lines = @("diff --git a/$Path b/$Path", "--- a/$Path", "+++ b/$Path", "@@ -$Start,$old +$Start,$new @@")
        $lines += @($Before | ForEach-Object { " $_" })
        $lines += @($Removed | ForEach-Object { "-$_" })
        $lines += @($Added | ForEach-Object { "+$_" })
        $lines += @($After | ForEach-Object { " $_" })
        $lines -join "`n"
    }

    function Get-TestHunk {
        param([string[]] $Current, [string[]] $Prior, [int] $Start = 1)
        [pscustomobject]@{ Path = 'docs/a.md'; Kind = 'modify'; Current = $Current; Prior = $Prior; Start = $Start }
    }
}

AfterAll {
    Remove-Module ProcessReductionChain -ErrorAction SilentlyContinue
}

Describe 'Get-ProcessReductionPatchHunk' {
    It 'PRC-HUNK-PARSES-SECTIONS reads two hunks, a spaced path, a create, a delete, and the no-newline marker' {
        # Arrange
        $spaced = 'docs/my file.md'
        $patch = @(
            (Get-TestPatchSection -Path 'docs/a.md' -Start 2 -Before @('one') -Removed @('two') -Added @('TWO') -After @('three')),
            '@@ -10,2 +10,3 @@',
            ' ten',
            '+ten and a half',
            ' eleven',
            "diff --git a/$spaced b/$spaced",
            "--- a/$spaced`t",
            "+++ b/$spaced`t",
            '@@ -1 +1 @@',
            '-old last',
            '\ No newline at end of file',
            '+new last',
            '\ No newline at end of file',
            'diff --git a/docs/new.md b/docs/new.md',
            'new file mode 100644',
            'index 000000000..1111111',
            '--- /dev/null',
            '+++ b/docs/new.md',
            '@@ -0,0 +1,2 @@',
            '+created one',
            '+created two',
            'diff --git a/docs/old.md b/docs/old.md',
            'deleted file mode 100644',
            '--- a/docs/old.md',
            '+++ /dev/null',
            '@@ -1 +0,0 @@',
            '-removed line'
        ) -join "`n"

        # Act
        $hunks = @(Get-ProcessReductionPatchHunk -PatchText $patch)

        # Assert
        $hunks.Count | Should -Be 5
        $hunks[0].Path | Should -BeExactly 'docs/a.md'
        $hunks[0].Kind | Should -BeExactly 'modify'
        $hunks[0].Start | Should -Be 2
        $hunks[0].Current | Should -Be @('one', 'TWO', 'three')
        $hunks[0].Prior | Should -Be @('one', 'two', 'three')
        $hunks[1].Start | Should -Be 10
        $hunks[1].Current | Should -Be @('ten', 'ten and a half', 'eleven')
        $hunks[1].Prior | Should -Be @('ten', 'eleven')
        $hunks[2].Path | Should -BeExactly $spaced -Because 'the tab git appends to a spaced name is removed'
        $hunks[2].Current | Should -Be @('new last')
        $hunks[2].Prior | Should -Be @('old last')
        $hunks[3].Kind | Should -BeExactly 'create'
        $hunks[3].Path | Should -BeExactly 'docs/new.md'
        $hunks[3].Prior.Count | Should -Be 0
        $hunks[4].Kind | Should -BeExactly 'delete'
        $hunks[4].Path | Should -BeExactly 'docs/old.md'
        $hunks[4].Prior | Should -Be @('removed line')
    }

    It 'PRC-HUNK-REJECTS-UNSUPPORTED throws naming the section for a <Case>' -ForEach @(
        @{ Case = 'binary section'; Line = 'GIT binary patch'; Pattern = '*diff --git a/img.png b/img.png*binary*' },
        @{ Case = 'quoted path'; Line = '--- "a/img\tname.png"'; Pattern = '*diff --git a/img.png b/img.png*quoted*' },
        @{ Case = 'malformed hunk line'; Line = "--- a/img.png`n+++ b/img.png`n@@ -1 +1 @@`n?odd"; Pattern = '*malformed hunk line*' },
        @{ Case = 'hunk before its headers'; Line = '@@ -1 +1 @@'; Pattern = '*before its --- and +++ lines*' }
    ) {
        $patch = "diff --git a/img.png b/img.png`n$Line"

        { Get-ProcessReductionPatchHunk -PatchText $patch } | Should -Throw -ExpectedMessage $Pattern
    }
}

Describe 'Invoke-ProcessReductionHunkRevert' {
    It 'PRC-HUNK-REVERT-RESTORES-PREIMAGE replaces the Current lines with the Prior lines' {
        $hunk = Get-TestHunk -Current @('one', 'TWO', 'three') -Prior @('one', 'two', 'three') -Start 2

        $result = Invoke-ProcessReductionHunkRevert -Text "zero`r`none`r`nTWO`r`nthree`r`nfour`r`n" -Hunk $hunk

        $result | Should -BeExactly "zero`none`ntwo`nthree`nfour`n"
    }

    It 'PRC-HUNK-REVERT-LINE-ALIGNED does not match Current inside a longer line' {
        $hunk = Get-TestHunk -Current @('beta') -Prior @('gamma')

        { Invoke-ProcessReductionHunkRevert -Text "alphabeta`nbeta-rule`n" -Hunk $hunk } | Should -Throw -ExpectedMessage '*was not found*'
    }

    It 'PRC-HUNK-REVERT-NEAREST-OCCURRENCE replaces the occurrence nearest the recorded start' {
        $hunk = Get-TestHunk -Current @('same') -Prior @('restored') -Start 5

        $result = Invoke-ProcessReductionHunkRevert -Text "same`na`nb`nc`nsame`nd" -Hunk $hunk

        $result | Should -BeExactly "same`na`nb`nc`nrestored`nd"
    }

    It 'PRC-HUNK-REVERT-NEAREST-OCCURRENCE throws when two occurrences are equally near' {
        $hunk = Get-TestHunk -Current @('same') -Prior @('restored') -Start 3

        { Invoke-ProcessReductionHunkRevert -Text "same`na`nb`nc`nsame" -Hunk $hunk } | Should -Throw -ExpectedMessage '*twice at the same distance*'
    }

    It 'PRC-HUNK-REVERT-THROWS-WHEN-ABSENT throws for <Case>' -ForEach @(
        @{ Case = 'Current text that is absent'; Current = @('missing'); Pattern = '*was not found*' },
        @{ Case = 'a hunk with no Current lines'; Current = @(); Pattern = '*has no Current lines*' }
    ) {
        $hunk = Get-TestHunk -Current $Current -Prior @('old')

        { Invoke-ProcessReductionHunkRevert -Text "present`n" -Hunk $hunk } | Should -Throw -ExpectedMessage $Pattern
    }
}
