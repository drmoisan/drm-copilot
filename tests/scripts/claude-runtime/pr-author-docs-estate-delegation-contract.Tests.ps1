#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    The checkpoint-free docs-estate delegation-prompt contract in the four pr-author skill copies
    (issue #1169).

.DESCRIPTION
    Each row reads one committed copy, takes the text of the section
    '## Checkpoint-Free Docs-Estate Delegation (issue #1169)' up to the next level-two heading,
    collapses whitespace runs to one space, and checks ordinal tokens. A copy that carries
    '## Coordinator-Session Topology (issue #1011)' places the section after that heading; the
    .agents copies, which carry no such heading, place it after every other section. No row writes
    a file or starts a process.
#>

BeforeDiscovery {
    $script:PrAuthorCopyRows = @(
        @{ Path = '.claude/skills/pr-author/SKILL.md' }
        @{ Path = '.agents/skills/pr-author/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-author/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-author/SKILL.md' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:Heading = '## Checkpoint-Free Docs-Estate Delegation (issue #1169)'
    $script:Anchor = '## Coordinator-Session Topology (issue #1011)'

    function Read-PrAuthorDocsEstateText {
        param([Parameter(Mandatory)] [string] $RelativePath)
        return ((Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -replace "`r`n", "`n")
    }
}

AfterAll {
    Remove-Item -LiteralPath 'function:Read-PrAuthorDocsEstateText' -ErrorAction SilentlyContinue
}

Describe 'pr-author docs-estate delegation contract (issue #1169)' {
    It 'places the docs-estate section after the coordinator topology section, or last when that section is absent, in <Path>' -ForEach $script:PrAuthorCopyRows {
        # Arrange
        $lines = @((Read-PrAuthorDocsEstateText -RelativePath $Path) -split "`n")

        # Act
        $section = [array]::IndexOf([string[]]$lines, $script:Heading)
        $anchor = [array]::IndexOf([string[]]$lines, $script:Anchor)
        $levelTwo = @(for ($index = 0; $index -lt $lines.Count; $index++) { if ($lines[$index] -cmatch '^## ') { $index } })

        # Assert
        $section | Should -BeGreaterThan -1
        if ($anchor -ge 0) { $section | Should -BeGreaterThan $anchor } else { $section | Should -Be $levelTwo[-1] -Because 'without the coordinator section the docs-estate section is the last section' }
    }

    It 'states the delegation-prompt contract and its preconditions in <Path>' -ForEach $script:PrAuthorCopyRows {
        # Arrange
        $text = Read-PrAuthorDocsEstateText -RelativePath $Path
        $match = [regex]::Match($text, '(?ms)^' + [regex]::Escape($script:Heading) + '[ \t]*\n(?<body>.*?)(?=^## |\z)')
        $section = $match.Groups['body'].Value -replace '\s+', ' '
        $tokens = @('`branch: <branch>`', '`base: <base>`', 'Canonical issue number for this feature is <N>.', 'Author-asserted autoclose issues: #<N>', 'gh pr create --head <branch> --base <base>', 'docs/documentation-estate/docs-profile.json', 'docs path set', 'receipt revision rule', 'exactly once')

        # Assert
        $match.Success | Should -BeTrue
        foreach ($token in $tokens) { $section.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the section states '$token'" }
    }

    It 'writes the gh pr create form inside a fenced block in <Path>' -ForEach $script:PrAuthorCopyRows {
        # Arrange
        $text = Read-PrAuthorDocsEstateText -RelativePath $Path
        $match = [regex]::Match($text, '(?ms)^' + [regex]::Escape($script:Heading) + '[ \t]*\n(?<body>.*?)(?=^## |\z)')

        # Act
        $fenced = [regex]::IsMatch($match.Groups['body'].Value, '(?ms)^```text\ngh pr create --head <branch> --base <base>\n```')
        $inline = [regex]::IsMatch($match.Groups['body'].Value, '`gh pr create --head <branch> --base <base>`')

        # Assert
        $fenced | Should -BeTrue
        $inline | Should -BeFalse -Because 'an inline span with <base> would fail the pr-author command allowlist row AL-34'
    }
}
