#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Index, read-seam, and committed-ledger tests for ProcessReductionLedger.psm1 (issue #1097).

.DESCRIPTION
    Fixtures are in-memory strings, and no test creates a file. The committed-ledger tests
    read docs/engineering/process-reductions/ read-only. The read-seam test mocks the
    filesystem cmdlets inside InModuleScope, so the mocks hold under a PoshQC-hosted run.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/dev-tools/ProcessReductionLedger.psm1') -Force

    function Get-TestIndexText {
        param([string[]] $Row = @())
        $header = "## Index`n`n| ID | Title | Date | Issue | Status |`n| --- | --- | --- | --- | --- |"
        (@($header) + $Row) -join "`n"
    }

    function Get-TestIndexRow {
        param([string] $Label, [string] $File)
        "| [$Label]($File) | Title | 2026-11-06 | #1097 | Active |"
    }
}

AfterAll {
    Remove-Module ProcessReductionLedger -ErrorAction SilentlyContinue
}

Describe 'Test-ProcessReductionIndex' {
    It 'PRL-INDEX-EMPTY-AGREES accepts an empty table and no entries' {
        $result = Test-ProcessReductionIndex -IndexText (Get-TestIndexText) -EntryName @()

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.RowCount | Should -Be 0
    }

    It 'PRL-INDEX-AGREES accepts one row and its entry file' {
        $text = Get-TestIndexText -Row (Get-TestIndexRow -Label '0001' -File '0001-a.md')

        $result = Test-ProcessReductionIndex -IndexText $text -EntryName @('0001-a.md')

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.RowCount | Should -Be 1
    }

    It 'PRL-INDEX-ROW-WITHOUT-FILE rejects a row with no entry file' {
        $text = Get-TestIndexText -Row (Get-TestIndexRow -Label '0001' -File '0001-a.md')

        $result = Test-ProcessReductionIndex -IndexText $text -EntryName @()

        $result.IsValid | Should -BeFalse
        $result.Errors -join "`n" | Should -BeLike '*has no entry file*'
    }

    It 'PRL-INDEX-FILE-WITHOUT-ROW rejects an entry file with no row' {
        $result = Test-ProcessReductionIndex -IndexText (Get-TestIndexText) -EntryName @('0001-a.md')

        $result.IsValid | Should -BeFalse
        $result.Errors -join "`n" | Should -BeLike '*has no index row*'
    }

    It 'PRL-INDEX-MISSING-TABLE rejects a README with no section or no exact header row' {
        $noSection = Test-ProcessReductionIndex -IndexText "# Title`n" -EntryName @()
        $noTable = Test-ProcessReductionIndex -IndexText "## Index`n`nNo table.`n" -EntryName @()
        $otherHeader = Test-ProcessReductionIndex -IndexText "## Index`n`n| ID | Name |`n| --- | --- |`n" -EntryName @()

        $noSection.IsValid | Should -BeFalse
        $noTable.IsValid | Should -BeFalse
        $otherHeader.IsValid | Should -BeFalse
    }

    It 'PRL-INDEX-MALFORMED-ROW rejects a row that does not have five cells and a link' {
        $result = Test-ProcessReductionIndex -IndexText (Get-TestIndexText -Row '| 0001 | Title |') -EntryName @()

        $result.Errors -join "`n" | Should -BeLike '*is malformed*'
    }

    It 'PRL-INDEX-BAD-ENTRY-NAME rejects an entry file outside the name format' {
        $result = Test-ProcessReductionIndex -IndexText (Get-TestIndexText) -EntryName @('Sample.md')

        $result.Errors -join "`n" | Should -BeLike "*'Sample.md' is not NNNN*"
    }

    It 'PRL-INDEX-LABEL-MISMATCH rejects a link label that differs from the file number' {
        $text = Get-TestIndexText -Row (Get-TestIndexRow -Label '0002' -File '0001-a.md')

        $result = Test-ProcessReductionIndex -IndexText $text -EntryName @('0001-a.md')

        $result.Errors -join "`n" | Should -BeLike '*differs from the number*'
    }

    It 'PRL-INDEX-REPEATED-NUMBER rejects two rows with one number' {
        $rows = @((Get-TestIndexRow -Label '0001' -File '0001-a.md'), (Get-TestIndexRow -Label '0001' -File '0001-b.md'))

        $result = Test-ProcessReductionIndex -IndexText (Get-TestIndexText -Row $rows) -EntryName @('0001-a.md', '0001-b.md')

        $result.Errors -join "`n" | Should -BeLike "*'0001' is repeated*"
    }
}

Describe 'Read-ProcessReductionLedger' {
    It 'PRL-READ-THROWS-ON-MISSING-FOLDER throws for a folder that does not exist' {
        $missing = Join-Path $script:RepoRoot 'docs/engineering/process-reductions/no-such-folder'

        { Read-ProcessReductionLedger -LedgerPath $missing } | Should -Throw '*does not exist*'
    }

    It 'PRL-READ-THROWS-ON-MISSING-README throws for a folder without README.md' {
        $noReadme = Join-Path $script:RepoRoot 'tests/scripts/dev-tools'

        { Read-ProcessReductionLedger -LedgerPath $noReadme } | Should -Throw '*has no README.md*'
    }

    It 'PRL-READ-COLLECTS-ENTRIES-AND-PATCHES returns entries without the README and the patch names' {
        InModuleScope ProcessReductionLedger {
            Mock Test-Path { $true }
            Mock Get-Content { "text of $(Split-Path -Path $LiteralPath -Leaf)" }
            Mock Get-ChildItem {
                @('README.md', '0002-b.md', '0001-a.md', 'notes.txt') | ForEach-Object {
                    [pscustomobject]@{ Name = $_; Extension = [System.IO.Path]::GetExtension($_); FullName = $_ }
                }
            }
            Mock Get-ChildItem { [pscustomobject]@{ Name = '0001-a.patch' } } -ParameterFilter { $LiteralPath -like '*patches' }

            $ledger = Read-ProcessReductionLedger -LedgerPath 'ledger-root'

            $ledger.IndexText | Should -BeExactly 'text of README.md'
            @($ledger.Entries | ForEach-Object { $_.Name }) | Should -Be @('0001-a.md', '0002-b.md')
            $ledger.Entries[0].Text | Should -BeExactly 'text of 0001-a.md'
            @($ledger.PatchNames) | Should -Be @('0001-a.patch')
        }
    }
}

Describe 'Committed ledger' {
    BeforeAll {
        $script:LedgerPath = Join-Path $script:RepoRoot 'docs/engineering/process-reductions'
    }

    It 'PRL-REAL-LEDGER-AGREES finds the committed README and entries in agreement' {
        $ledger = Read-ProcessReductionLedger -LedgerPath $script:LedgerPath

        $result = Test-ProcessReductionLedger -Ledger $ledger

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.RowCount | Should -Be @($ledger.Entries).Count
    }

    It 'PRL-PARTIAL-REVERT-LINKED links the 0001 partial revert to entry 0006 in the index and both entries' {
        # Arrange
        $readme = Get-Content -Raw -LiteralPath (Join-Path $script:LedgerPath 'README.md')
        $entry0001 = Get-Content -Raw -LiteralPath (Join-Path $script:LedgerPath '0001-parallel-only-test-gates.md')
        $entry0006 = Get-Content -Raw -LiteralPath (Join-Path $script:LedgerPath '0006-test-suite-baseline-restored.md')

        # Act
        $row0001 = @($readme -split "`r?`n" | Where-Object { $_.StartsWith('| [0001](0001-parallel-only-test-gates.md) |') })
        $partialRevert = Get-ProcessReductionSection -Text $entry0001 -Heading 'Partial Revert'
        $summary0006 = Get-ProcessReductionSection -Text $entry0006 -Heading 'Summary'

        # Assert
        $row0001.Count | Should -Be 1 -Because 'the index holds one 0001 row'
        $row0001[0] | Should -Match '\|\s*Partially reverted by 0006\s*\|\s*$' -Because 'the 0001 Status names the partial revert'
        $partialRevert | Should -Match '0006-test-suite-baseline-restored\.md' -Because 'the 0001 Partial Revert section links entry 0006'
        $summary0006 | Should -Match 'entry `0001`' -Because 'the 0006 summary names the entry it partially reverts'
    }

    It 'PRL-README-EXAMPLE-IS-VALID validates the worked example and replays its first block' {
        $readme = Get-Content -Raw -LiteralPath (Join-Path $script:LedgerPath 'README.md')
        $section = Get-ProcessReductionSection -Text $readme -Heading 'Worked Example'
        $outer = [regex]::Match($section, '(?ms)^`{5,}[^\n]*\n(.*)\n`{5,}[ \t]*$')
        $outer.Success | Should -BeTrue
        $entryText = $outer.Groups[1].Value

        $result = Test-ProcessReductionEntry -Name '0000-example-reduction.md' -Text $entryText
        $block = @(Get-ProcessReductionRevertBlock -Text $entryText)[0]
        $reverted = Invoke-ProcessReductionRevert -Text "before`n$($block.Current)`nafter" -Block $block

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $reverted | Should -BeExactly "before`n$($block.Prior)`nafter"
    }
}
