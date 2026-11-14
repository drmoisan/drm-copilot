#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the stage G less-evidence reduction of issue #1097 (ledger entry 0009).

.DESCRIPTION
    Each `LEC-` row reads one mirrored skill, agent, or template copy in place, collapses its
    whitespace, and asserts tokens with an ordinal Contains. The rows pin the one final-QC static
    artifact per language, the CI cross-check section, the Python repo-wide total read from CI,
    the reduced section 9 of the policy-audit template, and the baseline, comparison, and
    check-off text that the reduction keeps. The suite reads tracked files only and writes nothing.
#>

BeforeDiscovery {
    $resources = 'extensions/drm-copilot/resources'
    $claudeBundle = "$resources/claude-customizations"
    $agentsBundle = "$resources/codex-and-agents-customizations"
    $githubBundle = "$resources/customizations"
    $templateBundle = "$resources/templates/policy_audit"

    $contract = @(
        @{ Id = 'CONTRACT-CLAUDE'; Path = '.claude/skills/atomic-plan-contract/SKILL.md' }
        @{ Id = 'CONTRACT-AGENTS'; Path = '.agents/skills/atomic-plan-contract/SKILL.md' }
        @{ Id = 'CONTRACT-GITHUB'; Path = '.github/skills/atomic-plan-contract/SKILL.md' }
        @{ Id = 'CONTRACT-CLAUDE-BUNDLE'; Path = "$claudeBundle/.claude/skills/atomic-plan-contract/SKILL.md" }
        @{ Id = 'CONTRACT-AGENTS-BUNDLE'; Path = "$agentsBundle/.agents/skills/atomic-plan-contract/SKILL.md" }
        @{ Id = 'CONTRACT-GITHUB-BUNDLE'; Path = "$githubBundle/.github/skills/atomic-plan-contract/SKILL.md" }
    )
    $planner = @(
        @{ Id = 'PLANNER-CLAUDE'; Path = '.claude/agents/atomic-planner.md' }
        @{ Id = 'PLANNER-CODEX'; Path = '.codex/agents/atomic-planner.toml' }
    )
    $executor = @(
        @{ Id = 'EXECUTOR-CLAUDE'; Path = '.claude/agents/atomic-executor.md' }
        @{ Id = 'EXECUTOR-CODEX'; Path = '.codex/agents/atomic-executor.toml' }
    )
    $workflowFull = @(
        @{ Id = 'WORKFLOW-CLAUDE'; Path = '.claude/skills/feature-review-workflow/SKILL.md' }
        @{ Id = 'WORKFLOW-AGENTS'; Path = '.agents/skills/feature-review-workflow/SKILL.md' }
        @{ Id = 'WORKFLOW-CLAUDE-BUNDLE'; Path = "$claudeBundle/.claude/skills/feature-review-workflow/SKILL.md" }
        @{ Id = 'WORKFLOW-AGENTS-BUNDLE'; Path = "$agentsBundle/.agents/skills/feature-review-workflow/SKILL.md" }
    )
    $workflowGithub = @(
        @{ Id = 'WORKFLOW-GITHUB'; Path = '.github/skills/feature-review-workflow/SKILL.md' }
        @{ Id = 'WORKFLOW-GITHUB-BUNDLE'; Path = "$githubBundle/.github/skills/feature-review-workflow/SKILL.md" }
    )
    $featureReview = @(
        @{ Id = 'REVIEWER-CLAUDE'; Path = '.claude/agents/feature-review.md' }
        @{ Id = 'REVIEWER-CODEX'; Path = '.codex/agents/feature-review.toml' }
        @{ Id = 'REVIEWER-CLAUDE-BUNDLE'; Path = "$claudeBundle/.claude/agents/feature-review.md" }
        @{ Id = 'REVIEWER-CODEX-BUNDLE'; Path = "$agentsBundle/.codex/agents/feature-review.toml" }
    )
    $template = @(
        @{ Id = 'TEMPLATE'; Path = 'docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md' }
        @{ Id = 'TEMPLATE-BUNDLE'; Path = "$templateBundle/policy-audit.yyyy-MM-ddTHH-mm.md" }
    )
    $auditAgents = @(
        @{ Id = 'AUDIT-AGENTS'; Path = 'docs/features/templates/policy_audit/AGENTS.md' }
        @{ Id = 'AUDIT-AGENTS-BUNDLE'; Path = "$templateBundle/AGENTS.md" }
    )
    $orchestrate = @(
        @{ Id = 'ORCHESTRATE-CLAUDE'; Path = '.claude/skills/orchestrate/SKILL.md' }
        @{ Id = 'ORCHESTRATE-AGENTS'; Path = '.agents/skills/orchestrate/SKILL.md' }
        @{ Id = 'ORCHESTRATE-CLAUDE-BUNDLE'; Path = "$claudeBundle/.claude/skills/orchestrate/SKILL.md" }
        @{ Id = 'ORCHESTRATE-AGENTS-BUNDLE'; Path = "$agentsBundle/.agents/skills/orchestrate/SKILL.md" }
    )

    function Get-LecRow {
        <#
        .SYNOPSIS
            Returns copies of the given rows, each with the given tokens.
        .PARAMETER Row
            The Id and Path rows.
        .PARAMETER Token
            The tokens each row must hold.
        .OUTPUTS
            [hashtable] One row per input row.
        #>
        [CmdletBinding()]
        [OutputType([hashtable])]
        param(
            [Parameter(Mandatory = $true)][hashtable[]] $Row,
            [Parameter(Mandatory = $true)][string[]] $Token
        )

        foreach ($item in $Row) { @{ Id = $item.Id; Path = $item.Path; Token = $Token } }
    }

    $script:StaticArtifactRow = @(Get-LecRow -Row ($contract + $planner + $executor) -Token @('one final-QC static artifact per language'))
    $script:CrossCheckRow = @(Get-LecRow -Row ($template + $auditAgents + $workflowFull + $workflowGithub + $featureReview) -Token @('## CI Cross-check'))
    $script:CrossCheckSectionRow = @(Get-LecRow -Row $orchestrate -Token @('## CI Cross-check', 'gh pr checks', 'REMEDIATION_REQUIRED', 'autonomous', 'REVIEW_GATE_NOT_PASSED'))
    $script:PythonTotalRow = @(Get-LecRow -Row ($workflowFull + $featureReview + $template) -Token @('Enforce Python coverage thresholds'))
    $script:ScopeListingRow = @(Get-LecRow -Row $template -Token @('## 9. Summary of Changes'))
    $script:BaselineHeldRow = @(
        Get-LecRow -Row $contract -Token @('Phase 0 baseline', 'no per-file or repo-wide coverage drop')
        Get-LecRow -Row $template -Token @('Baseline Coverage Documented', 'No Coverage Regression', 'If any required baseline artifact')
        Get-LecRow -Row $auditAgents -Token @('Fill in baseline coverage metrics')
        Get-LecRow -Row ($workflowFull + $workflowGithub + $featureReview) -Token @('regression on changed lines', 'Phase 0 baseline')
        Get-LecRow -Row $planner -Token @('one parallel test-suite baseline run per gate')
        Get-LecRow -Row $executor -Token @('no per-file or repo-wide coverage drop')
    )
    $script:KeptRow = @(
        Get-LecRow -Row $contract -Token @('preflight-fixes.<timestamp>.md', 'self-review.<timestamp>.md')
        Get-LecRow -Row ($workflowFull + $workflowGithub) -Token @('acceptance-criteria-tracking', 'Check off passing criteria')
    )
}

Describe 'Less-evidence contract (issue #1097, entry 0009)' {
    BeforeAll {
        # Walk up from this file so the suite does not depend on the working directory.
        $script:LecRepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))

        function Get-LecText {
            <#
            .SYNOPSIS
                Returns the text of a repository file with whitespace runs collapsed to one space.
            .PARAMETER RelativePath
                The repository-relative path of the file.
            .OUTPUTS
                [string] The collapsed file text.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory = $true)][string] $RelativePath)

            $path = Join-Path -Path $script:LecRepoRoot -ChildPath $RelativePath
            return ([System.IO.File]::ReadAllText($path) -replace '\s+', ' ')
        }

        function Get-LecSection {
            <#
            .SYNOPSIS
                Returns the collapsed text of one level-two section of a repository file.
            .PARAMETER RelativePath
                The repository-relative path of the file.
            .PARAMETER Heading
                The exact level-two heading line that opens the section.
            .OUTPUTS
                [string] The collapsed section text, or an empty string when the heading is absent.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory = $true)][string] $RelativePath,
                [Parameter(Mandatory = $true)][string] $Heading
            )

            $path = Join-Path -Path $script:LecRepoRoot -ChildPath $RelativePath
            $lines = [System.IO.File]::ReadAllText($path).Replace("`r`n", "`n").Split("`n")
            $start = [array]::IndexOf($lines, $Heading)
            if ($start -lt 0) { return '' }
            $end = $lines.Count
            for ($index = $start + 1; $index -lt $lines.Count; $index++) {
                if ($lines[$index].StartsWith('## ')) { $end = $index; break }
            }
            return (($lines[$start..($end - 1)] -join ' ') -replace '\s+', ' ')
        }

        function Get-LecMissingToken {
            <#
            .SYNOPSIS
                Returns the tokens that a text does not hold, compared ordinally.
            .PARAMETER Content
                The text to search.
            .PARAMETER Token
                The tokens to look for.
            .OUTPUTS
                [System.Object[]] The absent tokens.
            #>
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Content,
                [Parameter(Mandatory = $true)][string[]] $Token
            )

            return @($Token | Where-Object { -not $Content.Contains($_, [System.StringComparison]::Ordinal) })
        }
    }

    It 'LEC-STATIC-ARTIFACT-<Id> states one final-QC static artifact per language' -ForEach $script:StaticArtifactRow {
        # Act
        $missing = @(Get-LecMissingToken -Content (Get-LecText -RelativePath $Path) -Token $Token)

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must state the static artifact"
    }

    It 'LEC-CROSS-CHECK-<Id> names the CI Cross-check section' -ForEach $script:CrossCheckRow {
        # Act
        $missing = @(Get-LecMissingToken -Content (Get-LecText -RelativePath $Path) -Token $Token)

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must name the CI Cross-check section"
    }

    It 'LEC-CROSS-CHECK-<Id> states the join comparison inside the concurrent-review section' -ForEach $script:CrossCheckSectionRow {
        # Act
        $section = Get-LecSection -RelativePath $Path -Heading '## Concurrent Review and CI (review_mode)'
        $missing = @(Get-LecMissingToken -Content $section -Token $Token)

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Path must hold the concurrent-review section"
        $missing | Should -BeNullOrEmpty -Because "$Path must state the cross-check at the join"
    }

    It 'LEC-PYTHON-TOTAL-<Id> reads the Python repo-wide total from the CI threshold step' -ForEach $script:PythonTotalRow {
        # Act
        $missing = @(Get-LecMissingToken -Content (Get-LecText -RelativePath $Path) -Token $Token)

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must name the CI threshold step"
    }

    It 'LEC-SCOPE-LISTING-<Id> keeps the section 9 heading and drops both listing subsections' -ForEach $script:ScopeListingRow {
        # Arrange
        $text = Get-LecText -RelativePath $Path

        # Act
        $missing = @(Get-LecMissingToken -Content $text -Token $Token)
        $removed = @(@('### Commits in This PR/Branch', '### Files Modified') | Where-Object { $text.Contains($_, [System.StringComparison]::Ordinal) })

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must keep the required section 9 heading"
        $removed | Should -BeNullOrEmpty -Because "$Path must not list commits or files in section 9"
    }

    It 'LEC-BASELINE-HELD-<Id> keeps the baseline and comparison text' -ForEach $script:BaselineHeldRow {
        # Act
        $missing = @(Get-LecMissingToken -Content (Get-LecText -RelativePath $Path) -Token $Token)

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must keep its baseline text under decision D13"
    }

    It 'LEC-KEPT-<Id> keeps the preflight, self-review, and check-off text' -ForEach $script:KeptRow {
        # Act
        $missing = @(Get-LecMissingToken -Content (Get-LecText -RelativePath $Path) -Token $Token)

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must keep the evidence the reduction does not touch"
    }

    It 'LEC-HELPER-REPORTS-ABSENT-TOKEN finds an absent token in in-memory text' {
        # Act
        $missing = @(Get-LecMissingToken -Content 'one final-QC static artifact per language' -Token @('one final-QC static artifact per language', '## CI Cross-check'))

        # Assert
        $missing | Should -Be @('## CI Cross-check')
    }
}
