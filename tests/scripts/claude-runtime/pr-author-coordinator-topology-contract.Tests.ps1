#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Static contract rows for the pr-author coordinator-session topology (issue #1011, CT-01 to CT-07).

.DESCRIPTION
    Pins the prose that lets a pr-author running outside the item worktree author a pull request:

      - the pr-author agent and skill carry a Coordinator-Session Topology section (CT-01) that
        names the worktree discovery and its stop rule (CT-02), the absolute body and receipt
        writes, the absolute checksum, and the absolute --body-file with --head (CT-03), the
        repo-relative receipt fields and the existing-summary requirement (CT-04), and delegation
        without worktree isolation (CT-05);
      - both documents keep the item-rooted relative procedure outside that section (CT-06);
      - the orchestrate skill's PR Authoring section names the coordinator-session handoff (CT-07).

.NOTES
    Sections run from their heading to the next heading of the same or a shallower level, with
    every whitespace run collapsed to one space so a reflow cannot break an assertion. Tokens are
    asserted with String.Contains, because a backtick or bracket is a wildcard metacharacter under
    -BeLike.

    Reads committed text only. No test creates a file, spawns a process, reads a wall clock, or
    touches the network, and no hook is dot-sourced.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:PrAuthorAgent = Join-Path $script:RepoRoot '.claude/agents/pr-author.md'
    $script:PrAuthorSkill = Join-Path $script:RepoRoot '.claude/skills/pr-author/SKILL.md'
    $script:OrchestrateSkill = Join-Path $script:RepoRoot '.claude/skills/orchestrate/SKILL.md'
    $script:TopologyHeading = '## Coordinator-Session Topology (issue #1011)'

    # Split a Markdown file into the named section and the remaining text, each with all runs of
    # whitespace collapsed to single spaces. The section runs from its heading to the next heading
    # of the same or a shallower level; a missing heading yields an empty section.
    function Get-TopologyDocumentPart {
        param(
            [Parameter(Mandatory)] [string] $Path,
            [Parameter(Mandatory)] [string] $Heading
        )
        $lines = @(Get-Content -LiteralPath $Path)
        $start = [array]::IndexOf($lines, $Heading)
        $depth = ($Heading -split ' ')[0].Length
        $section = [System.Collections.Generic.List[string]]::new()
        $rest = [System.Collections.Generic.List[string]]::new()
        $inSection = $false
        for ($index = 0; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            if ($index -eq $start) {
                $inSection = $true
                continue
            }
            if ($inSection -and $line -match '^(#{1,6})\s' -and $Matches[1].Length -le $depth) {
                $inSection = $false
            }
            if ($inSection) { $section.Add($line) } else { $rest.Add($line) }
        }
        return [pscustomobject]@{
            Section = (($section -join ' ') -replace '\s+', ' ').Trim()
            Rest    = (($rest -join ' ') -replace '\s+', ' ').Trim()
        }
    }
}

Describe 'pr-author coordinator-session topology prose contract (issue #1011)' {
    BeforeDiscovery {
        $script:Documents = @(
            @{ Name = 'agent'; Key = 'PrAuthorAgent' }
            @{ Name = 'skill'; Key = 'PrAuthorSkill' }
        )
    }

    It 'CT-01 the <Name> has a Coordinator-Session Topology section' -ForEach $script:Documents {
        # Arrange / Act
        $part = Get-TopologyDocumentPart -Path (Get-Variable -Name $Key -Scope Script -ValueOnly) -Heading $script:TopologyHeading

        # Assert
        $part.Section | Should -Not -BeNullOrEmpty -Because "the $Name must carry '$($script:TopologyHeading)'"
    }

    It 'CT-02 the <Name> section names the worktree discovery and its stop rule' -ForEach $script:Documents {
        # Arrange / Act
        $section = (Get-TopologyDocumentPart -Path (Get-Variable -Name $Key -Scope Script -ValueOnly) -Heading $script:TopologyHeading).Section

        # Assert
        foreach ($token in @('git worktree list --porcelain', 'branch refs/heads/<branch>', 'zero or more than one')) {
            $section.Contains($token) | Should -BeTrue -Because "the $Name section must name '$token'"
        }
    }

    It 'CT-03 the <Name> section names the absolute write, checksum, and create forms' -ForEach $script:Documents {
        # Arrange / Act
        $section = (Get-TopologyDocumentPart -Path (Get-Variable -Name $Key -Scope Script -ValueOnly) -Heading $script:TopologyHeading).Section

        # Assert
        foreach ($token in @(
                '<item worktree>/artifacts/pr_body_<N>.md'
                '<item worktree>/artifacts/pr_body_<N>.receipt.json'
                'sha256sum <item worktree>/artifacts/pr_body_<N>.md'
                'gh pr create --head <branch> --body-file <item worktree>/artifacts/pr_body_<N>.md'
            )) {
            $section.Contains($token) | Should -BeTrue -Because "the $Name section must name '$token'"
        }
    }

    It 'CT-04 the <Name> section keeps receipt paths repo-relative and requires the existing summary' -ForEach $script:Documents {
        # Arrange / Act
        $section = (Get-TopologyDocumentPart -Path (Get-Variable -Name $Key -Scope Script -ValueOnly) -Heading $script:TopologyHeading).Section

        # Assert
        foreach ($token in @('repo-relative', 'pr_body_path', 'context_summary_path', '<item worktree>/artifacts/pr_context.summary.txt', 'created_at')) {
            $section.Contains($token) | Should -BeTrue -Because "the $Name section must name '$token'"
        }
    }

    It 'CT-05 the <Name> section requires delegation without worktree isolation' -ForEach $script:Documents {
        # Arrange / Act
        $section = (Get-TopologyDocumentPart -Path (Get-Variable -Name $Key -Scope Script -ValueOnly) -Heading $script:TopologyHeading).Section

        # Assert
        $section.Contains('without worktree isolation') | Should -BeTrue -Because "the $Name section must require a non-isolated delegation"
    }

    It 'CT-06 the <Name> keeps the item-rooted relative procedure' -ForEach $script:Documents {
        # Arrange / Act
        $rest = (Get-TopologyDocumentPart -Path (Get-Variable -Name $Key -Scope Script -ValueOnly) -Heading $script:TopologyHeading).Rest

        # Assert
        foreach ($token in @('sha256sum artifacts/pr_body_<N>.md', 'gh pr create --head <branch> --body-file artifacts/pr_body_<N>.md')) {
            $rest.Contains($token) | Should -BeTrue -Because "the $Name must keep '$token' outside the coordinator-session section"
        }
    }

    It 'CT-07 the orchestrate PR Authoring section names the coordinator-session handoff' {
        # Arrange / Act
        $section = (Get-TopologyDocumentPart -Path $script:OrchestrateSkill -Heading '## PR Authoring (pr-author Handoff)').Section

        # Assert
        $section | Should -Not -BeNullOrEmpty
        foreach ($token in @('workspace_root', 'target_ref', 'branch: <branch>', 'derives the item worktree root itself', 'without worktree isolation')) {
            $section.Contains($token) | Should -BeTrue -Because "the PR Authoring section must name '$token'"
        }
    }
}
