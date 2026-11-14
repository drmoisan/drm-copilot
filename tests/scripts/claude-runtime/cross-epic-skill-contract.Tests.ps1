#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Text contract for the cross-epic dependencies of issue #1162 in the epic skills, agents, and templates.

.DESCRIPTION
    Extracts each named section as the text between its '## ' heading and the next '## ' heading,
    collapses every whitespace run to one space, and asserts each token case-sensitively inside
    that text. A token that is an upper-case identifier (a reason or error code) must occur as a
    whole identifier, with no capital letter or underscore on either side, so PREREQ_UNVERIFIABLE
    is not satisfied by MAIN_PREREQ_UNVERIFIABLE. A missing heading fails the row. Whole-file rows
    cover files that carry the key in appended sentences. The two epic templates must be
    byte-identical. Files are read read-only; no file is written and no process is started.
#>

BeforeDiscovery {
    $sectionHeading = '## Cross-Epic Dependencies (cross_epic_depends_on)'
    $sectionToken = @(
        'cross_epic_depends_on', 'Invoke-EpicCrossReadiness.ps1'
        'EPIC_CROSS_DEPENDENCY_MALFORMED', 'EPIC_CROSS_DEPENDENCY_UNSUPPORTED_FORM', 'EPIC_CROSS_DEPENDENCY_BRANCH_MISMATCH'
        'EPIC_CROSS_DEPENDENCY_SAME_EPIC', 'EPIC_CROSS_DEPENDENCY_DUPLICATE', 'EPIC_CROSS_DEPENDENCY_UNRESOLVED'
        'EPIC_CROSS_DEPENDENCY_MANIFEST_UNREADABLE', 'EPIC_CROSS_DEPENDENCY_CYCLE', 'EPIC_CROSS_DEPENDENCY_EARLY_START_CROSS'
        'PREREQ_UNVERIFIABLE', 'PREREQ_IN_MAIN', 'PREREQ_PR_NOT_FOUND', 'PREREQ_PR_AMBIGUOUS', 'PREREQ_NOT_ANCESTOR'
        'PREREQ_ALREADY_INTEGRATED', 'PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED', 'NO_CROSS_EPIC_EDGE'
        'MAIN_PREREQ_UNVERIFIABLE', 'MAIN_PREREQ_PR_NOT_MERGED', 'MAIN_PREREQ_PR_AMBIGUOUS', 'MAIN_PREREQ_NOT_ANCESTOR'
        'MAIN_PREREQ_RELEASED', 'never receives a worktree', 'git merge --no-ff', 'never a rebase or fast-forward'
        '-Mode main', 'main sync runs first', 're-run immediately before', 'gh pr merge', '-WaitSeconds 540', 'at most 40'
        'external_dependency', 'Upstream context for', 'cross-epic depends on', 'not merged', 'epic-status.md'
        'cross-epic table', 'scripts.dev_tools.validate_orchestration_artifacts', 'epic-orchestrator-state'
        'enforce-epic-merge-gate.ps1', 'does not read', 'cross_epic_main_gate'
    )
    $script:SectionRow = @(
        @{ Path = '.claude/skills/epic-orchestrate/SKILL.md'; Heading = $sectionHeading; Token = $sectionToken }
        @{ Path = '.agents/skills/epic-orchestrate/SKILL.md'; Heading = $sectionHeading; Token = $sectionToken }
        @{ Path = '.claude/skills/epic-orchestrate/SKILL.md'; Heading = '## Epic Integration Branch Lifecycle'; Token = @('Invoke-EpicCrossReadiness.ps1', '-Mode main', 'main sync runs first', 're-run immediately before') }
        @{ Path = '.claude/skills/epic-orchestrate/SKILL.md'; Heading = '## Completion Requirements'; Token = @('cross_epic_main_gate') }
        @{ Path = '.claude/skills/epic-orchestrate/SKILL.md'; Heading = '## Epic-Level Checkpoint'; Token = @('cross_epic_main_gate') }
        @{ Path = '.claude/skills/epic-orchestrate/SKILL.md'; Heading = '## Epic Dependency Manifest'; Token = @('cross_epic_depends_on') }
        @{ Path = '.agents/skills/epic-orchestrate/SKILL.md'; Heading = '## Manifest Contract'; Token = @('cross_epic_depends_on') }
        @{ Path = '.claude/agents/epic-orchestrator.md'; Heading = '## Wave Scheduling'; Token = @('Invoke-EpicCrossReadiness.ps1', 'never receives a worktree', 'git merge --no-ff', 'never a rebase or fast-forward') }
        @{ Path = '.claude/agents/epic-orchestrator.md'; Heading = '## Completion Requirements'; Token = @('-Mode main', 're-run immediately before', 'cross_epic_main_gate') }
    )
    $script:FileRow = @(
        @{ Path = '.claude/skills/epic-plan/SKILL.md'; Token = @('cross_epic_depends_on', 'Upstream context for', 'not merged') }
        @{ Path = '.agents/skills/epic-plan/SKILL.md'; Token = @('cross_epic_depends_on', 'Upstream context for', 'not merged') }
        @{ Path = '.claude/skills/epic-run/SKILL.md'; Token = @('cross_epic_depends_on') }
        @{ Path = '.agents/skills/epic-run/SKILL.md'; Token = @('cross_epic_depends_on') }
        @{ Path = '.claude/agents/epic-planner.md'; Token = @('cross_epic_depends_on') }
        @{ Path = '.codex/agents/epic-planner.toml'; Token = @('cross_epic_depends_on') }
        @{ Path = '.codex/agents/epic-orchestrator.toml'; Token = @('Invoke-EpicCrossReadiness.ps1', 'git merge --no-ff', '-Mode main', '-WaitSeconds 540') }
    )
}

Describe 'cross-epic skill contract (issue #1162)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path

        function Get-CrossEpicFileText {
            # The text of one repository file with CRLF normalized to LF.
            param([string] $RelativePath)
            return ((Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -replace "`r`n", "`n")
        }

        function Get-CrossEpicCollapsedText {
            # The text with every whitespace run collapsed to one space.
            param([string] $Text)
            return (($Text -replace '\s+', ' ').Trim())
        }

        function Get-CrossEpicSection {
            # The body between a '## ' heading line and the next '## ' heading, or $null when the heading is absent.
            param([string] $Text, [string] $Heading)
            $start = ("`n" + $Text).IndexOf("`n$Heading`n", [System.StringComparison]::Ordinal)
            if ($start -lt 0) { return $null }
            $bodyStart = $start + $Heading.Length + 1
            $end = $Text.IndexOf("`n## ", $bodyStart, [System.StringComparison]::Ordinal)
            if ($end -lt 0) { return $Text.Substring($bodyStart) }
            return $Text.Substring($bodyStart, $end - $bodyStart)
        }

        function Get-CrossEpicMissingToken {
            # The tokens absent from the text: identifiers match whole, other tokens match as ordinal substrings.
            param([string] $Text, [string[]] $Token)
            foreach ($item in $Token) {
                if ($item -cmatch '^[A-Z][A-Z0-9_]*$') {
                    if ($Text -cnotmatch ('(?<![A-Z_])' + [regex]::Escape($item) + '(?![A-Z_])')) { $item }
                } elseif (-not $Text.Contains($item, [System.StringComparison]::Ordinal)) {
                    $item
                }
            }
        }
    }

    It 'CES-SECTION-TOKENS <Heading> of <Path>' -ForEach $script:SectionRow {
        $section = Get-CrossEpicSection -Text (Get-CrossEpicFileText -RelativePath $Path) -Heading $Heading

        $section | Should -Not -BeNullOrEmpty -Because "$Path must contain the heading $Heading"
        @(Get-CrossEpicMissingToken -Text (Get-CrossEpicCollapsedText -Text $section) -Token $Token) | Should -BeNullOrEmpty -Because "$Heading of $Path must state every token"
    }

    It 'CES-FILE-TOKENS <Path>' -ForEach $script:FileRow {
        $text = Get-CrossEpicCollapsedText -Text (Get-CrossEpicFileText -RelativePath $Path)

        @(Get-CrossEpicMissingToken -Text $text -Token $Token) | Should -BeNullOrEmpty -Because "$Path must state every token"
    }

    It 'CES-TEMPLATES-BYTE-IDENTICAL' {
        $source = Join-Path $script:RepoRoot 'docs/features/templates/epic/epic.md'
        $bundle = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/feature-templates/epic/epic.md'

        (Get-FileHash -LiteralPath $bundle -Algorithm SHA256).Hash | Should -BeExactly (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
        (Get-CrossEpicFileText -RelativePath 'docs/features/templates/epic/epic.md').Contains('cross_epic_depends_on') | Should -BeTrue
    }

    It 'CES-IDENTIFIER-MATCH-IS-WHOLE' {
        # The whole-identifier rule: a longer code that contains the token does not satisfy it.
        @(Get-CrossEpicMissingToken -Text 'only MAIN_PREREQ_UNVERIFIABLE here' -Token @('PREREQ_UNVERIFIABLE')) | Should -Be @('PREREQ_UNVERIFIABLE')
        @(Get-CrossEpicMissingToken -Text 'reason `PREREQ_UNVERIFIABLE`.' -Token @('PREREQ_UNVERIFIABLE')).Count | Should -Be 0
    }

    It 'CES-MISSING-HEADING-FAILS' {
        Get-CrossEpicSection -Text "# T`n## Other`ntext`n" -Heading '## Cross-Epic Dependencies (cross_epic_depends_on)' | Should -BeNullOrEmpty
        Get-CrossEpicSection -Text "## A`none`n## B`ntwo`n" -Heading '## A' | Should -BeExactly 'one'
    }
}
