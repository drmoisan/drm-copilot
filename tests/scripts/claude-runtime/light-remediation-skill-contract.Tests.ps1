#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the light-remediation text of the review and orchestration surfaces (issue #1097).

.DESCRIPTION
    The light remediation path lives in prose: the review contract that writes Remediation-Path and
    Finding-Scope, and the orchestrator contract that acts on them. Prose can be deleted without any
    other test noticing, so these rows assert each statement in every copy, bundles included. Text
    is read with whitespace collapsed, so a reflow cannot break an assertion, except for the
    counted-token rule, which is a per-line rule and reads raw lines. Assertions use
    String.Contains, because a backtick is an escape character inside a wildcard pattern.

    Reads committed text only. No test creates a file, starts a process, or reads a clock.
#>

BeforeDiscovery {
    $resources = 'extensions/drm-copilot/resources'
    $script:ReviewCopy = @(
        @{ Copy = '.claude/skills/feature-review-workflow/SKILL.md' }
        @{ Copy = '.agents/skills/feature-review-workflow/SKILL.md' }
        @{ Copy = '.github/skills/feature-review-workflow/SKILL.md' }
        @{ Copy = "$resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md" }
        @{ Copy = "$resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md" }
        @{ Copy = "$resources/customizations/.github/skills/feature-review-workflow/SKILL.md" }
        @{ Copy = '.claude/agents/feature-review.md' }
        @{ Copy = "$resources/claude-customizations/.claude/agents/feature-review.md" }
        @{ Copy = '.agents/skills/feature-review/SKILL.md' }
        @{ Copy = "$resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md" }
    )
    $script:ClaudeOrchestrateCopy = @(
        @{ Copy = '.claude/skills/orchestrate/SKILL.md' }
        @{ Copy = "$resources/claude-customizations/.claude/skills/orchestrate/SKILL.md" }
    )
    $script:AgentsOrchestrateCopy = @(
        @{ Copy = '.agents/skills/orchestrate/SKILL.md' }
        @{ Copy = "$resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md" }
    )
    $script:OrchestrateCopy = $script:ClaudeOrchestrateCopy + $script:AgentsOrchestrateCopy
    $script:AgentCopy = @(
        @{ Copy = '.claude/agents/orchestrator.md' }
        @{ Copy = "$resources/claude-customizations/.claude/agents/orchestrator.md" }
    )
    $script:ExecutorCopy = @(
        @{ Copy = '.claude/agents/atomic-executor.md' }
        @{ Copy = "$resources/claude-customizations/.claude/agents/atomic-executor.md" }
        @{ Copy = '.codex/agents/atomic-executor.toml' }
        @{ Copy = "$resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml" }
    )
    $script:RuleCopy = @(
        @{ Copy = '.claude/rules/orchestrator-state.md' }
        @{ Copy = "$resources/claude-customizations/.claude/rules/orchestrator-state.md" }
        @{ Copy = '.agents/skills/orchestrator-state/SKILL.md' }
        @{ Copy = "$resources/codex-and-agents-customizations/.agents/skills/orchestrator-state/SKILL.md" }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    # The loop heading carries an en dash, composed here so this file stays ASCII.
    $script:LoopHeading = '## Remediation Loop (R1' + [char]0x2013 + 'R5)'

    function Get-LightRemediationText {
        <#
        .SYNOPSIS
            Return a file, or one section of it, with whitespace collapsed.
        .PARAMETER Copy
            The repository-relative file.
        .PARAMETER Heading
            The exact heading line of the section; the whole file when omitted.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory)][string] $Copy,
            [string] $Heading = ''
        )

        $lines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $Copy))
        if ($Heading) {
            $start = [array]::IndexOf($lines, $Heading)
            if ($start -lt 0) { return '' }
            $depth = ($Heading -split ' ')[0].Length
            $collected = [System.Collections.Generic.List[string]]::new()
            # Walk forward until a heading of equal or shallower depth ends the section.
            for ($index = $start + 1; $index -lt $lines.Count; $index++) {
                if ($lines[$index] -match '^(#{1,6})\s' -and $Matches[1].Length -le $depth) { break }
                $collected.Add($lines[$index])
            }
            $lines = $collected.ToArray()
        }
        return (($lines -join ' ') -replace '\s+', ' ').Trim()
    }

    function Assert-LightRemediationToken {
        <#
        .SYNOPSIS
            Assert that every token occurs in the text.
        .PARAMETER Text
            The collapsed text.
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

Describe 'review contract for the light remediation path (issue #1097)' {
    It 'LRS-REVIEW-STATES-PATH-AND-SCOPE-LINES (<Copy>)' -ForEach $script:ReviewCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy) -Token '`Remediation-Path: light`', '`Remediation-Path: full`', '`Finding-Scope: contained`', '`Finding-Scope: design`'
    }

    It 'LRS-REVIEW-STATES-THRESHOLD (<Copy>)' -ForEach $script:ReviewCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy) -Token 'at most 3'
    }

    It 'LRS-REVIEW-STATES-LIGHT-FIX-TASKS (<Copy>)' -ForEach $script:ReviewCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy) -Token '## Light Fix Tasks'
    }

    It 'LRS-REVIEW-LINES-CARRY-NO-COUNTED-TOKEN (<Copy>)' -ForEach $script:ReviewCopy {
        # Arrange: the orchestrator counts lines holding these tokens, so a new line must hold none.
        $lines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $Copy))

        # Act
        $prefixed = @($lines | Where-Object { $_.Contains('Remediation-Path:') -or $_.Contains('Finding-Scope:') })
        $offending = @($prefixed | Where-Object { $_.Contains('BLOCKING') -or $_.Contains('Severity: Blocking') })

        # Assert
        $prefixed.Count | Should -BeGreaterThan 0
        $offending | Should -BeNullOrEmpty
    }
}

Describe 'orchestrator contract for the light remediation path (issue #1097)' {
    It 'LRS-ORCHESTRATE-STATES-THIRD-MODE (<Copy>)' -ForEach $script:OrchestrateCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading $script:LoopHeading) -Token '`Remediation-Mode: light`', '**Light cycle.**', '`remediation_path` as `light` or `full`'
    }

    It 'LRS-ORCHESTRATE-STATES-THRESHOLD (<Copy>)' -ForEach $script:OrchestrateCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading $script:LoopHeading) -Token 'at most 3 blocking findings', '`Finding-Scope: contained`', 'a prior cycle that was not light'
    }

    It 'LRS-ORCHESTRATE-MOVES-ONLY-HEAVIER (<Copy>)' -ForEach $script:OrchestrateCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading $script:LoopHeading) -Token 'only when the reviewer wrote `Remediation-Path: light`', 'heavier mode and never to a lighter one', 'CI-failure and merge-conflict cycles are never light'
    }

    It 'LRS-ORCHESTRATE-STATES-DETECTION (<Copy>)' -ForEach $script:OrchestrateCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading $script:LoopHeading) -Token '`execution_status: "in_progress"`', 'and no `preflight`', 'the route lacks invariant 8'
    }

    It 'LRS-ORCHESTRATE-STATES-FALLBACK-AND-REUSE (<Copy>)' -ForEach $script:OrchestrateCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading $script:LoopHeading) -Token 'R1 and R2 do not run', 'no attempt number is consumed', 'The pre-R4 commit, R4, R5', 'The cycle after a light cycle is full.'
    }

    It 'LRS-CLAUDE-NAMES-PYTHON-CLI-ROUTE (<Copy>)' -ForEach $script:ClaudeOrchestrateCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading $script:LoopHeading) -Token '`scripts.dev_tools.validate_orchestration_artifacts` with its `orchestrator-state` subcommand', 'records no receipt', 'not repaired by editing the cycle'
    }

    It 'LRS-CODEX-STATES-UNAVAILABLE-UNTIL-RELEASE (<Copy>)' -ForEach $script:AgentsOrchestrateCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading $script:LoopHeading) -Token 'The light path is unavailable until an extension release that carries invariant 8 is installed', '`## Hard Enforcement Boundary`'
    }

    It 'LRS-AGENT-RECORDS-PATH-AND-SCOPE (<Copy>)' -ForEach $script:AgentCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading '### Remediation Loop Checkpoint Shape') -Token '`remediation_path`', '`light` or `full`, recorded on every new cycle', '`review_outcomes[].findings[].scope`', 'A light cycle carries no `preflight` key.'
    }

    It 'LRS-EXECUTOR-PERMITS-LIGHT-STOP (<Copy>)' -ForEach $script:ExecutorCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy) -Token 'A light remediation run has no preflight', 'only when a fix task cannot be done at its named location'
    }

    It 'LRS-RULE-STATES-INVARIANT-8 (<Copy>)' -ForEach $script:RuleCopy {
        Assert-LightRemediationToken -Text (Get-LightRemediationText -Copy $Copy -Heading '## Invariants (per remediation cycle)') -Token '**Light remediation (issue #1097).**', 'remediation_path must be light or full.', 'remediation_path is light but the prior cycle is light.', 'does not apply to a cycle whose `remediation_path` is exactly the string `light`'
    }
}
