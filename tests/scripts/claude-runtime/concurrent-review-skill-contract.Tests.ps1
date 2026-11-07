#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the concurrent-review text of the skills, rule, and agent (issue #1097).

.DESCRIPTION
    The run sequence of review_mode concurrent lives in prose, and prose can be deleted without any
    other test noticing, so these rows assert each statement in every copy. They read the text with
    whitespace collapsed, so a reflow cannot break an assertion, and extract the owning section by
    heading, so a statement placed under the wrong heading fails. Assertions use String.Contains,
    because a backtick is an escape character inside a wildcard pattern.

    Reads committed text only. No test creates a file, starts a process, or reads a clock.
#>

BeforeDiscovery {
    $script:OrchestrateCopy = @(
        @{ Copy = '.claude/skills/orchestrate/SKILL.md' }
        @{ Copy = '.agents/skills/orchestrate/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md' }
    )
    $script:ParallelCopy = @(
        @{ Copy = '.claude/skills/parallel-orchestrate/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md' }
    )
    $script:RuleCopy = @(
        @{ Copy = '.claude/rules/orchestrator-state.md' }
        @{ Copy = 'extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md' }
    )
    $script:AgentsStateCopy = @(
        @{ Copy = '.agents/skills/orchestrator-state/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-state/SKILL.md' }
    )
    $script:AgentCopy = @(
        @{ Copy = '.claude/agents/orchestrator.md' }
        @{ Copy = 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:SectionHeading = '## Concurrent Review and CI (review_mode)'

    function Get-ConcurrentReviewSection {
        <#
        .SYNOPSIS
            Return one section of a Markdown file with whitespace collapsed.
        .PARAMETER Copy
            The repository-relative file.
        .PARAMETER Heading
            The exact heading line.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory)][string] $Copy,
            [Parameter(Mandatory)][string] $Heading
        )

        $lines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $Copy))
        $start = [array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { return '' }
        $depth = ($Heading -split ' ')[0].Length
        $collected = [System.Collections.Generic.List[string]]::new()
        # Walk forward until a heading of equal or shallower depth ends the section.
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -match '^(#{1,6})\s' -and $Matches[1].Length -le $depth) { break }
            $collected.Add($lines[$index])
        }
        return (($collected -join ' ') -replace '\s+', ' ').Trim()
    }

    function Assert-ConcurrentReviewToken {
        <#
        .SYNOPSIS
            Assert that every token occurs in the text.
        .PARAMETER Text
            The collapsed section text.
        .PARAMETER Token
            The expected tokens.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
            [Parameter(Mandatory)][string[]] $Token
        )

        $Text | Should -Not -BeNullOrEmpty
        foreach ($item in $Token) {
            $Text.Contains($item) | Should -BeTrue -Because "the text must state: $item"
        }
    }
}

Describe 'orchestrate skill concurrent review section (issue #1097)' {
    It 'CRS-SKILL-DEFAULTS-NEW-RUNS-TO-CONCURRENT (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'The first checkpoint write of a new run records `review_mode: "concurrent"`', 'enforce-epic-merge-gate-review.ps1', 'Without that file the run stays sequential'
    }

    It 'CRS-SKILL-KEEPS-RESUME-SEQUENTIAL (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'A run that resumes a checkpoint without the key stays sequential', 'the key is never added on resume'
    }

    It 'CRS-SKILL-STATES-SEQUENCE-AND-JOIN (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'open the pull request', 'delegation and CI together; join; merge', 'the last `review_outcomes[]` entry has verdict `PASS` at a current head', '`ci_gate.conclusion` is `success` at the live head', 'A parallel child still never merges itself'
    }

    It 'CRS-SKILL-REQUIRES-CI-FULL-RUN (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'a `CI full run` check with conclusion `success`', 'a docs-only head reports success without the heavy suites'
    }

    It 'CRS-SKILL-STATES-STALE-RULE (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'Any code push after a `PASS`, including a CI fix or a merge of `origin/main`, is a stale head', 'requires a new review', 'Commits inside `feature-folder`'
    }

    It 'CRS-SKILL-NAMES-DENY-CODES (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'REVIEW_GATE_NOT_PASSED', 'REVIEW_GATE_HEAD_STALE', 'REVIEW_GATE_HEAD_UNRESOLVED'
    }

    It 'CRS-SKILL-COMMITS-ENTRY-NUMBER-BEFORE-HEAD-READ (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'open the pull request; a run with a ledger entry commits the entry''s pull-request number next, before reading `head_sha`'
    }

    It 'CRS-SKILL-STATES-OWN-CALL-MERGE (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token 'The merge is issued as its own Bash call', 'any other form is denied with `REVIEW_GATE_HEAD_UNRESOLVED`'
    }

    It 'CRS-SKILL-KEEPS-COMPLETED-STEPS-CANONICAL (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token '`completed_steps` stays in canonical order', 'insert `S7_feature_review` before the existing `S8_create_pr` entry'
    }

    It 'CRS-SKILL-HOLDS-STEP8-UNTIL-JOIN (<Copy>)' -ForEach $script:OrchestrateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading $script:SectionHeading
        Assert-ConcurrentReviewToken -Text $section -Token '`step8_status` is `in_progress` at pull-request creation', 'it stays `in_progress` until the join'
    }

    It 'CRS-SKILL-SEQUENTIAL-SECTIONS-INTACT (<Copy>)' -ForEach $script:OrchestrateCopy {
        # Arrange
        $lines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $Copy))
        $sectionIndex = [array]::IndexOf($lines, $script:SectionHeading)
        $gateIndex = [array]::IndexOf($lines, '## PR Creation Gate')

        # Act
        $gate = Get-ConcurrentReviewSection -Copy $Copy -Heading '## PR Creation Gate'

        # Assert
        $sectionIndex | Should -BeGreaterThan -1
        $sectionIndex | Should -BeLessThan $gateIndex
        Assert-ConcurrentReviewToken -Text $gate -Token '1. `blocking_findings_resolved: true`'
    }
}

Describe 'parallel skill, rule, and agent concurrent review text (issue #1097)' {
    It 'CRS-PARALLEL-WITHHOLDS-CI-GREEN-WHILE-REVIEW-UNRESOLVED (<Copy>)' -ForEach $script:ParallelCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading '## Per-Item Merge to Main (Merge-on-Green)'
        Assert-ConcurrentReviewToken -Text $section -Token 'When the child checkpoint records `review_mode: "concurrent"`', 'do not record `merge_status: ci_green` and do not run `gh pr merge` until its last `review_outcomes[]` entry is `PASS` at a current head', 'keep `merge_status: pr_open`', 'this step is the backstop when that target does not resolve'
    }

    It 'CRS-RULE-DOCUMENTS-KEY-AND-LIMIT (<Copy>)' -ForEach $script:RuleCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading '## Concurrent-Review Scope and Backward Compatibility'
        Assert-ConcurrentReviewToken -Text $section -Token '`review_mode`', '`head_sha`', 'Only the final `review_outcomes[]` element counts', 'requires a last review_outcomes entry with verdict PASS.', 'requires head_sha on the last review_outcomes entry.', 'REVIEW_GATE_NOT_PASSED', 'REVIEW_GATE_HEAD_STALE', 'REVIEW_GATE_HEAD_UNRESOLVED', 'D10', 'D9', 'policy-level', 'a checkpoint without the key validates exactly as before'
    }

    It 'CRS-RULE-DISCLOSES-UNREAD-MERGE-FORMS (<Copy>)' -ForEach $script:RuleCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading '## Concurrent-Review Scope and Backward Compatibility'
        Assert-ConcurrentReviewToken -Text $section -Token 'a script file performing the merge cannot be read', 'the Claude PowerShell tool', '`shell_command`', 'An already-queued auto-merge fires with no command', '`gh pr merge <PR> --disable-auto`', 'prose containing `pr merge` is denied in any command', 'a failed read sees no key'
    }

    It 'CRS-AGENTS-STATE-SKILL-DOCUMENTS-KEY (<Copy>)' -ForEach $script:AgentsStateCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading '## Concurrent-Review Key (review_mode)'
        Assert-ConcurrentReviewToken -Text $section -Token '`review_mode`', 'the exact string `concurrent`', '`head_sha`', '`## Concurrent Review and CI (review_mode)` in `.agents/skills/orchestrate/SKILL.md`'
    }

    It 'CRS-AGENT-DOCUMENTS-HEAD-SHA (<Copy>)' -ForEach $script:AgentCopy {
        $section = Get-ConcurrentReviewSection -Copy $Copy -Heading '### Remediation Loop Checkpoint Shape'
        Assert-ConcurrentReviewToken -Text $section -Token '`review_mode: "concurrent"`', '`head_sha`', '`## Concurrent Review and CI (review_mode)`'
    }
}
