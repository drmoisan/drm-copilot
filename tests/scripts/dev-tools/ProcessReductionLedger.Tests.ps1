#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for scripts/dev-tools/ProcessReductionLedger.psm1 (issue #1097).

.DESCRIPTION
    Fixtures are in-memory strings built here, so CRLF inputs survive the eol=lf rule of
    .gitattributes and no test creates a file. Tests that read the committed ledger or
    the skill copies are read-only.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/dev-tools/ProcessReductionLedger.psm1') -Force

    $script:Fence = '`' * 4
    $script:EntryName = '0001-sample-entry.md'

    function Get-TestEntrySection {
        [ordered]@{
            'Summary'             = "reduction: 0001`nMerge commit: pending (PR #12)`n`nDrops a sample task."
            'Reason and Evidence' = 'The task repeated a rule.'
            'Files Changed'       = '- docs/a.md'
            'Prior Text'          = "### Revert Block: docs/a.md`n`n$($script:Fence)Current`nnew text`n$($script:Fence)`n`n$($script:Fence)Prior`nold text`n$($script:Fence)"
            'Revert Steps'        = "1. Apply the blocks`n2. Re-copy mirrors and bundles`n3. Regenerate Codex variants`n4. Restore pinned hashes`n5. Restore contract-test literals`n6. Run the contract tests"
            'Revert Signals'      = '- More remediation cycles.'
        }
    }

    function ConvertTo-TestEntryText {
        param([System.Collections.Specialized.OrderedDictionary] $Section)
        @($Section.GetEnumerator() | ForEach-Object { "## $($_.Key)`n`n$($_.Value)`n" }) -join "`n"
    }
}

AfterAll {
    Remove-Module ProcessReductionLedger -ErrorAction SilentlyContinue
}

Describe 'Get-ProcessReductionSection' {
    It 'PRL-SECTION-FOUND returns the body between two level-two headings' {
        $text = "# Title`n`n## One`n`nfirst body`n`n## Two`n`nsecond body`n"

        Get-ProcessReductionSection -Text $text -Heading 'One' | Should -BeExactly 'first body'
    }

    It 'PRL-SECTION-ABSENT returns null for a heading that is not present' {
        $result = Get-ProcessReductionSection -Text "## One`n`nbody`n" -Heading 'Two'

        $result | Should -BeNullOrEmpty
        $null -eq $result | Should -BeTrue
    }

    It 'PRL-SECTION-IGNORES-FENCED-HEADING keeps a heading inside a fence in the body' {
        $text = "## One`n`n$($script:Fence)text`n## Not a heading`n$($script:Fence)`n`nafter the fence`n`n## Two`n"

        $result = Get-ProcessReductionSection -Text $text -Heading 'One'

        $result | Should -BeLike '*## Not a heading*'
        $result | Should -BeLike '*after the fence'
    }
}

Describe 'Get-ProcessReductionRevertBlock' {
    It 'PRL-BLOCK-PARSES-VERBATIM-MARKDOWN keeps an inner fence and heading in a longer fence' {
        $inner = '`' * 3
        $verbatim = "$inner`n## Inner heading`n$inner"
        $text = "### Revert Block: docs/a.md`n`n$($script:Fence)Current`n$verbatim`n$($script:Fence)`n`n$($script:Fence)Prior`nold text`n$($script:Fence)`n"

        $blocks = @(Get-ProcessReductionRevertBlock -Text $text)

        $blocks.Count | Should -Be 1
        $blocks[0].Path | Should -BeExactly 'docs/a.md'
        $blocks[0].Current | Should -BeExactly $verbatim
        $blocks[0].Prior | Should -BeExactly 'old text'
    }

    It 'PRL-BLOCK-MISSING-FENCE gives null for an absent fence and empty text for an empty fence' {
        $text = "### Revert Block: docs/a.md`n`n$($script:Fence)Current`n$($script:Fence)`n"

        $blocks = @(Get-ProcessReductionRevertBlock -Text $text)

        $null -eq $blocks[0].Prior | Should -BeTrue
        $null -eq $blocks[0].Current | Should -BeFalse
        $blocks[0].Current.Length | Should -Be 0
    }
}

Describe 'Invoke-ProcessReductionRevert' {
    BeforeAll {
        function Get-TestBlock {
            param([AllowNull()][object] $Current, [AllowNull()][object] $Prior)
            [pscustomobject]@{ Path = 'docs/a.md'; Current = $Current; Prior = $Prior }
        }
    }

    It 'PRL-REVERT-RESTORES-PRIOR replaces Current with Prior' {
        Invoke-ProcessReductionRevert -Text 'before new after' -Block (Get-TestBlock -Current 'new' -Prior 'old') | Should -BeExactly 'before old after'
    }

    It 'PRL-REVERT-CRLF-LIVE-TEXT matches an LF block against CRLF live text' {
        $block = Get-TestBlock -Current "one`ntwo" -Prior "uno`ndos"

        Invoke-ProcessReductionRevert -Text "one`r`ntwo`r`nthree" -Block $block | Should -BeExactly "uno`ndos`nthree"
    }

    It 'PRL-REVERT-CRLF-BLOCK matches a CRLF block against LF live text' {
        $block = Get-TestBlock -Current "one`r`ntwo" -Prior "uno`r`ndos"

        Invoke-ProcessReductionRevert -Text "one`ntwo`nthree" -Block $block | Should -BeExactly "uno`ndos`nthree"
    }

    It 'PRL-REVERT-LONE-CR treats a lone CR as a line ending' {
        $block = Get-TestBlock -Current "one`ntwo" -Prior 'both'

        Invoke-ProcessReductionRevert -Text "one`rtwo`rthree" -Block $block | Should -BeExactly "both`nthree"
    }

    It 'PRL-REVERT-THROWS-WHEN-CURRENT-ABSENT throws for null Current and for text not found' {
        { Invoke-ProcessReductionRevert -Text 'live' -Block (Get-TestBlock -Current $null -Prior 'old') } | Should -Throw '*no Current text*'
        { Invoke-ProcessReductionRevert -Text 'live' -Block (Get-TestBlock -Current 'gone' -Prior 'old') } | Should -Throw '*was not found*'
    }

    It 'PRL-REVERT-THROWS-WHEN-CURRENT-EMPTY throws for an empty Current' {
        { Invoke-ProcessReductionRevert -Text 'live' -Block (Get-TestBlock -Current '' -Prior 'old') } | Should -Throw '*no Current text*'
    }

    It 'PRL-REVERT-THROWS-WHEN-CURRENT-REPEATS throws when Current occurs twice' {
        { Invoke-ProcessReductionRevert -Text 'new and new' -Block (Get-TestBlock -Current 'new' -Prior 'old') } | Should -Throw '*more than once*'
    }

    It 'PRL-REVERT-THROWS-WHEN-PRIOR-ABSENT throws for a null Prior' {
        { Invoke-ProcessReductionRevert -Text 'new' -Block (Get-TestBlock -Current 'new' -Prior $null) } | Should -Throw '*no Prior text*'
    }
}

Describe 'Test-ProcessReductionEntry' {
    It 'PRL-ENTRY-COMPLETE accepts a complete entry' {
        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section (Get-TestEntrySection))

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.Errors.Count | Should -Be 0
        $null -eq $result.PatchPath | Should -BeTrue
    }

    It 'PRL-ENTRY-MISSING-SECTION rejects an entry without <Title>' -ForEach @(
        @{ Title = 'Summary' }, @{ Title = 'Reason and Evidence' }, @{ Title = 'Files Changed' },
        @{ Title = 'Prior Text' }, @{ Title = 'Revert Steps' }, @{ Title = 'Revert Signals' }
    ) {
        $section = Get-TestEntrySection
        $section.Remove($Title)

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeFalse
        $result.Errors -join "`n" | Should -BeLike "*'## $Title'*"
    }

    It 'PRL-ENTRY-EMPTY-SECTION rejects an entry with an empty <Title>' -ForEach @(
        @{ Title = 'Summary' }, @{ Title = 'Reason and Evidence' }, @{ Title = 'Files Changed' },
        @{ Title = 'Prior Text' }, @{ Title = 'Revert Steps' }, @{ Title = 'Revert Signals' }
    ) {
        $section = Get-TestEntrySection
        $section[$Title] = ''

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeFalse
        $result.Errors -join "`n" | Should -BeLike "*'## $Title' is empty*"
    }

    It 'PRL-ENTRY-NO-PRIOR-TEXT rejects an entry with neither Prior Text nor Stored Patch' {
        $section = Get-TestEntrySection
        $section.Remove('Prior Text')

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.Errors -join "`n" | Should -BeLike "*needs '## Prior Text' or '## Stored Patch'*"
    }

    It 'PRL-ENTRY-PRIOR-TEXT-WITHOUT-BLOCK rejects Prior Text that holds no revert block' {
        $section = Get-TestEntrySection
        $section['Prior Text'] = 'Only prose.'

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeFalse
        $result.Errors -join "`n" | Should -BeLike '*at least one revert block*'
    }

    It 'PRL-ENTRY-BLOCK-WITHOUT-PRIOR rejects a revert block with no Prior fence' {
        $section = Get-TestEntrySection
        $section['Prior Text'] = "### Revert Block: docs/a.md`n`n$($script:Fence)Current`nnew text`n$($script:Fence)"

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeFalse
        $result.Errors -join "`n" | Should -BeLike '*needs a Prior fence*'
    }

    It 'PRL-ENTRY-EMPTY-PRIOR-ACCEPTED accepts an empty Prior fence' {
        $section = Get-TestEntrySection
        $section['Prior Text'] = "### Revert Block: docs/a.md`n`n$($script:Fence)Current`nnew text`n$($script:Fence)`n`n$($script:Fence)Prior`n$($script:Fence)"

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
    }

    It 'PRL-ENTRY-STORED-PATCH-ACCEPTED accepts a Stored Patch naming the entry stem and returns its path' {
        $section = Get-TestEntrySection
        $section.Remove('Prior Text')
        $section['Stored Patch'] = 'Apply patches/0001-sample-entry.patch in reverse.'

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.PatchPath | Should -BeExactly 'patches/0001-sample-entry.patch'
    }

    It 'PRL-ENTRY-STORED-PATCH-WRONG-NAME rejects a Stored Patch naming another stem' {
        $section = Get-TestEntrySection
        $section.Remove('Prior Text')
        $section['Stored Patch'] = 'Apply patches/0002-other-entry.patch in reverse.'

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeFalse
        $null -eq $result.PatchPath | Should -BeTrue
    }

    It 'PRL-ENTRY-TOKEN-MISMATCH rejects a reduction token that differs from the file number' {
        $section = Get-TestEntrySection
        $section['Summary'] = "reduction: 0002`nMerge commit: pending (PR #12)"

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.Errors -join "`n" | Should -BeLike "*'reduction: 0001'*"
    }

    It 'PRL-ENTRY-MERGE-PENDING-ACCEPTED accepts the exact pending form' {
        $section = Get-TestEntrySection
        $section['Summary'] = "reduction: 0001`nMerge commit: pending (PR #1097)"

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
    }

    It 'PRL-ENTRY-MERGE-RESOLVED-ACCEPTED accepts a commit identifier of <Length> characters' -ForEach @(
        @{ Length = 7 }, @{ Length = 40 }
    ) {
        $section = Get-TestEntrySection
        $section['Summary'] = "reduction: 0001`nMerge commit: $('a' * $Length)"

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
    }

    It 'PRL-ENTRY-MERGE-MALFORMED-REJECTED rejects the summary line [<Line>]' -ForEach @(
        @{ Line = 'Merge commit: pending' }, @{ Line = 'Merge commit: Pending (PR #12)' },
        @{ Line = 'Merge commit: pending (PR 12)' }, @{ Line = 'Merge commit: pending (#12)' },
        @{ Line = 'Merge commit: pending (PR #N)' }, @{ Line = 'Merge commit: pending (PR #12) later' },
        @{ Line = 'an absent merge line' }
    ) {
        $section = Get-TestEntrySection
        $section['Summary'] = "reduction: 0001`n$Line"

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.IsValid | Should -BeFalse
        $result.Errors -join "`n" | Should -BeLike '*Merge commit*'
    }

    It 'PRL-ENTRY-REVERT-STEP-MISSING rejects Revert Steps without a label' {
        $section = Get-TestEntrySection
        $section['Revert Steps'] = $section['Revert Steps'].Replace('Restore pinned hashes', 'Other step')

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $result.Errors -join "`n" | Should -BeLike "*must name 'Restore pinned hashes'*"
    }

    It 'PRL-ENTRY-REVERT-STEP-ORDER rejects labels out of order and ignores label case' {
        $section = Get-TestEntrySection
        $steps = $section['Revert Steps']
        $section['Revert Steps'] = $steps.ToUpperInvariant()
        $upperResult = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)
        $section['Revert Steps'] = $steps.Replace('Apply the blocks', 'SWAP').Replace('Run the contract tests', 'Apply the blocks').Replace('SWAP', 'Run the contract tests')

        $result = Test-ProcessReductionEntry -Name $script:EntryName -Text (ConvertTo-TestEntryText -Section $section)

        $upperResult.IsValid | Should -BeTrue -Because ($upperResult.Errors -join '; ')
        $result.Errors -join "`n" | Should -BeLike '*out of order*'
    }
}
