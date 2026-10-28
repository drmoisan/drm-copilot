#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Static contract rows for the pr-author issue-link prose (issue #989, PC-01 to PC-07).

.DESCRIPTION
    Pins the prose that carries the issue #989 contract:

      - the orchestrate skill and the orchestrator agent require the line
        'Author-asserted autoclose issues: #<issue-num>' in every Agent(pr-author) delegation
        prompt, with its two omission conditions (PC-01, PC-02);
      - the pr-author skill accepts that line as a source for '- Closes #NNN' even when the PR
        context lists no verified autoclose issues (PC-03, PC-04);
      - the pr-author skill and agent require the closing-reference verification command after
        every create or edit (PC-05) and state the gh pr edit target forms (PC-06);
      - the pr-author agent frontmatter grants the gh pr view tool entry (PC-07).

.NOTES
    Sections are read with a test-local copy of the Get-SkillSection helper from
    checkpoint-hygiene-skill-contract.Tests.ps1: each section runs from its heading to the next
    heading of the same or a shallower level, with whitespace runs collapsed so a reflow cannot
    break an assertion. Tokens are asserted with String.Contains, because a backtick or bracket
    is a wildcard metacharacter under -BeLike.

    Reads committed text only. No test creates a file, spawns a process, reads a wall clock, or
    touches the network.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:OrchestrateSkill = Join-Path $script:RepoRoot '.claude/skills/orchestrate/SKILL.md'
    $script:OrchestratorAgent = Join-Path $script:RepoRoot '.claude/agents/orchestrator.md'
    $script:PrAuthorSkill = Join-Path $script:RepoRoot '.claude/skills/pr-author/SKILL.md'
    $script:PrAuthorAgent = Join-Path $script:RepoRoot '.claude/agents/pr-author.md'
    $script:HeadHeading = '## Required `--head` on `gh pr create` (issue #687)'
    $script:DelegationLine = 'Author-asserted autoclose issues: #<issue-num>'
    $script:ViewForm = 'gh pr view <N> --json closingIssuesReferences,body'

    # Return one section of a Markdown file, from its heading to the next heading of the
    # same or a shallower level, with all runs of whitespace collapsed to single spaces.
    function Get-SkillSection {
        param(
            [Parameter(Mandatory)] [string] $Path,
            [Parameter(Mandatory)] [string] $Heading
        )
        $lines = @(Get-Content -LiteralPath $Path)
        $start = [array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { return '' }
        $depth = ($Heading -split ' ')[0].Length
        $collected = [System.Collections.Generic.List[string]]::new()
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            if ($line -match '^(#{1,6})\s') {
                if ($Matches[1].Length -le $depth) { break }
            }
            $collected.Add($line)
        }
        return (($collected -join ' ') -replace '\s+', ' ').Trim()
    }
}

Describe 'pr-author issue-link prose contract (issue #989)' {
    It 'PC-01 the orchestrate skill requires the author-asserted line and names both omission conditions' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:OrchestrateSkill -Heading '## PR Authoring (pr-author Handoff)'

        # Assert
        $section | Should -Not -BeNullOrEmpty
        $section.Contains($script:DelegationLine) | Should -BeTrue -Because 'the delegation prompt must carry the line'
        $section.Contains('issue-num') | Should -BeTrue -Because 'the number comes from the checkpoint issue-num'
        $section.Contains('epic_mode') | Should -BeTrue -Because 'an epic child is the second omission condition'
    }

    It 'PC-02 the orchestrator agent states the author-asserted line in its PR delegation section' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:OrchestratorAgent -Heading '## PR Creation Delegation'

        # Assert
        $section | Should -Not -BeNullOrEmpty
        $section.Contains($script:DelegationLine) | Should -BeTrue
    }

    It 'PC-03 the pr-author skill accepts the delegation prompt as a Closes source' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:PrAuthorSkill -Heading '## Issue/PR Reference Rules'

        # Assert
        $section | Should -Not -BeNullOrEmpty
        $section.Contains('delegation prompt') | Should -BeTrue
        $section.Contains('no verified autoclose issues') | Should -BeTrue
        $section.Contains('sourced only from') | Should -BeFalse -Because 'the PR-context lists are no longer the only sources'
    }

    It 'PC-04 the pr-author body structure no longer limits Closes to verified lists' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:PrAuthorSkill -Heading '## PR Body Structure'

        # Assert
        $section | Should -Not -BeNullOrEmpty
        $section.Contains('only from verified autoclose lists') | Should -BeFalse
    }

    It 'PC-05 the pr-author <Name> requires the closing-reference verification after every create or edit' -ForEach @(
        @{ Name = 'skill'; Key = 'PrAuthorSkill' }
        @{ Name = 'agent'; Key = 'PrAuthorAgent' }
    ) {
        # Arrange / Act
        $path = Get-Variable -Name $Key -Scope Script -ValueOnly
        $section = Get-SkillSection -Path $path -Heading '## Closing-Reference Verification'

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Name carries the section"
        $section.Contains($script:ViewForm) | Should -BeTrue
        $section.Contains('after every') | Should -BeTrue
    }

    It 'PC-06 the pr-author <Name> states the gh pr edit target forms in the --head section' -ForEach @(
        @{ Name = 'skill'; Key = 'PrAuthorSkill' }
        @{ Name = 'agent'; Key = 'PrAuthorAgent' }
    ) {
        # Arrange / Act
        $path = Get-Variable -Name $Key -Scope Script -ValueOnly
        $section = Get-SkillSection -Path $path -Heading $script:HeadHeading

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Name carries the section"
        $section.Contains('--head is not valid for gh pr edit') | Should -BeTrue
        $section.Contains('# branch: <branch>') | Should -BeTrue
    }

    It 'PC-07 the pr-author agent frontmatter grants the gh pr view tool entry' {
        # Arrange: the frontmatter is the text between the first two '---' lines.
        $lines = @(Get-Content -LiteralPath $script:PrAuthorAgent)
        $end = [Array]::IndexOf($lines, '---', 1)
        $frontmatter = @($lines[1..($end - 1)])
        $start = [Array]::IndexOf($frontmatter, 'tools:')
        $entries = [System.Collections.Generic.List[string]]::new()
        for ($index = $start + 1; $index -lt $frontmatter.Count -and $frontmatter[$index].StartsWith('  - '); $index++) {
            $entries.Add($frontmatter[$index].Substring(4))
        }

        # Act / Assert
        $start | Should -BeGreaterThan -1
        $entries | Should -Contain '"Bash(gh pr view *)"'
    }
}
