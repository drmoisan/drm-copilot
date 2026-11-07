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
