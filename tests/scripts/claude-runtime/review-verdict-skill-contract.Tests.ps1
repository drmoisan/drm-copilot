#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the review/verdict text of the orchestrate skills (issue #1097, decision D16).

.DESCRIPTION
    Each RVS- row asserts one statement of `## Review Verdict Status (review/verdict)` in the four
    orchestrate copies: the Claude and Codex skills and their bundle copies. The section is read
    with whitespace collapsed, so a reflow cannot break an assertion, and is extracted by heading,
    so a statement placed under another heading fails. Assertions use String.Contains, because a
    backtick is an escape character inside a wildcard pattern.

    Reads committed text only. No test creates a file, starts a process, or reads a clock.
#>

BeforeDiscovery {
    $script:OrchestrateCopy = @(
        @{ Copy = '.claude/skills/orchestrate/SKILL.md' }
        @{ Copy = '.agents/skills/orchestrate/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:SectionHeading = '## Review Verdict Status (review/verdict)'

    function Get-ReviewVerdictSkillSection {
        <#
        .SYNOPSIS
            Return the review/verdict section of one copy with whitespace collapsed, or an empty string.
        .PARAMETER Copy
            The repository-relative file.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param([Parameter(Mandatory)][string] $Copy)

        $lines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $Copy))
        $start = [array]::IndexOf($lines, $script:SectionHeading)
        if ($start -lt 0) { return '' }
        $collected = [System.Collections.Generic.List[string]]::new()
        # Walk forward until the next level-one or level-two heading ends the section.
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -match '^#{1,2}\s') { break }
            $collected.Add($lines[$index])
        }
        return (($collected -join ' ') -replace '\s+', ' ').Trim()
    }

    function Get-ReviewVerdictMissingToken {
        <#
        .SYNOPSIS
            Return the tokens that do not occur in the section of one copy.
        .PARAMETER Copy
            The repository-relative file.
        .PARAMETER Token
            The expected tokens.
        #>
        [CmdletBinding()]
        [OutputType([string[]], [System.Object[]])]
        param(
            [Parameter(Mandatory)][string] $Copy,
            [Parameter(Mandatory)][string[]] $Token
        )

        $text = Get-ReviewVerdictSkillSection -Copy $Copy
        return @($Token | Where-Object { -not $text.Contains($_, [System.StringComparison]::Ordinal) })
    }
}

Describe 'review/verdict orchestrate skill contract' {
    It 'RVS-POSTS-AFTER-PASS in <Copy>' -ForEach $script:OrchestrateCopy {
        # The status is posted through the statuses API by the entry point, naming the artifact.
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('gh api repos/{owner}/{repo}/statuses/{sha}', 'Invoke-ReviewVerdictStatus.ps1', 'names the review artifact', '`review/verdict`, state `success`')
        $missing | Should -BeNullOrEmpty -Because "$Copy must state when and how the status is posted"
    }

    It 'RVS-NEW-PUSH-NEEDS-NEW-REVIEW in <Copy>' -ForEach $script:OrchestrateCopy {
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('a new push leaves the new head without the status', 'review must pass again')
        $missing | Should -BeNullOrEmpty -Because "$Copy must state that a new head needs a new review"
    }

    It 'RVS-RECORDS-FIRST in <Copy>' -ForEach $script:OrchestrateCopy {
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('REVIEW_VERDICT_ARTIFACT_NOT_COMMITTED', 're-posts on the records-only head', 'REVIEW_VERDICT_NOT_RECORDS_ONLY')
        $missing | Should -BeNullOrEmpty -Because "$Copy must state the records-first rule and the records-only re-post"
    }

    It 'RVS-BEFORE-MERGE in <Copy>' -ForEach $script:OrchestrateCopy {
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('immediately before the merge', 'A refusal means no merge and a new review.')
        $missing | Should -BeNullOrEmpty -Because "$Copy must run the entry point against the live head before merging"
    }

    It 'RVS-NON-FEATURE-RULES in <Copy>' -ForEach $script:OrchestrateCopy {
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('-Mode MainSync', '-Mode RecordsPr', '-Mode PromotionPr', 'keys on the branch pattern and the diff')
        $missing | Should -BeNullOrEmpty -Because "$Copy must name the three non-feature rules"
    }

    It 'RVS-PARALLEL-AND-EPIC in <Copy>' -ForEach $script:OrchestrateCopy {
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('The parallel parent posts nothing', 'PINNED_FROZEN_SURFACE_HASHES', 'Epic children post as orchestrate runs.')
        $missing | Should -BeNullOrEmpty -Because "$Copy must state the parallel and epic behavior"
    }

    It 'RVS-NOT-CI in <Copy>' -ForEach $script:OrchestrateCopy {
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('no CI run, no CI job, no workflow file, no committed verdict file, and no GitHub ruleset change')
        $missing | Should -BeNullOrEmpty -Because "$Copy must state that the status adds no CI surface"
    }

    It 'RVS-STATES-LIMIT in <Copy>' -ForEach $script:OrchestrateCopy {
        $missing = Get-ReviewVerdictMissingToken -Copy $Copy -Token @('Anyone with write access', 'including any agent with', 'It records a passing review and does not prove one.')
        $missing | Should -BeNullOrEmpty -Because "$Copy must state the limit of the status"
    }

    It 'RVS-SECTION-PLACEMENT in <Copy>' -ForEach $script:OrchestrateCopy {
        # The section follows the PR Creation Gate and precedes the Step 6 delegation section.
        $lines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $Copy))
        $gate = [array]::IndexOf($lines, '## PR Creation Gate')
        $section = [array]::IndexOf($lines, $script:SectionHeading)
        $step6 = [array]::IndexOf($lines, ('## Step 6 Delegation ' + [char]0x2014 + ' Prohibited Prompt Language'))
        $gate | Should -BeGreaterOrEqual 0
        $section | Should -BeGreaterThan $gate
        $step6 | Should -BeGreaterThan $section
        @($lines[($gate + 1)..($section - 1)] | Where-Object { $_ -match '^#{1,2}\s' }) | Should -BeNullOrEmpty
    }
}
