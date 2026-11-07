Set-StrictMode -Version Latest

# Contract guard for issue #1097: the planning contract, its mirrored copies, and the
# surfaces that restate it carry the planning-side wording of the process-reduction
# work. Each `PCW-` row reads one file in place with whitespace runs collapsed; the
# suite writes nothing.

BeforeDiscovery {
    $resources = 'extensions/drm-copilot/resources'
    $script:ContractCopy = @(
        @{ Copy = 'CLAUDE'; Path = '.claude/skills/atomic-plan-contract/SKILL.md' }
        @{ Copy = 'AGENTS'; Path = '.agents/skills/atomic-plan-contract/SKILL.md' }
        @{ Copy = 'GITHUB'; Path = '.github/skills/atomic-plan-contract/SKILL.md' }
        @{ Copy = 'CLAUDE-BUNDLE'; Path = "$resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md" }
        @{ Copy = 'AGENTS-BUNDLE'; Path = "$resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md" }
        @{ Copy = 'GITHUB-BUNDLE'; Path = "$resources/customizations/.github/skills/atomic-plan-contract/SKILL.md" }
    )

    $briefCopy = @(
        @{ Copy = 'CLAUDE'; Path = '.claude/skills/execution-environment/SKILL.md' }
        @{ Copy = 'AGENTS'; Path = '.agents/skills/execution-environment/SKILL.md' }
        @{ Copy = 'GITHUB'; Path = '.github/skills/execution-environment/SKILL.md' }
        @{ Copy = 'CLAUDE-BUNDLE'; Path = "$resources/claude-customizations/.claude/skills/execution-environment/SKILL.md" }
        @{ Copy = 'AGENTS-BUNDLE'; Path = "$resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md" }
        @{ Copy = 'GITHUB-BUNDLE'; Path = "$resources/customizations/.github/skills/execution-environment/SKILL.md" }
    )
    # Deferred brief facts of stages C and D; each is read from its own section only.
    $briefCheck = @(
        @{ Check = 'MERGE-GUARD'; Section = 'Hook Execution Context'; Required = @('enforce-epic-merge-gate-review.ps1', 'REVIEW_GATE_NOT_PASSED') }
        @{ Check = 'MERGE-TEXT'; Section = 'Command-Text Restrictions'; Required = @('REVIEW_GATE_HEAD_UNRESOLVED', 'git commit -F') }
        @{ Check = 'JOIN'; Section = 'CI Shape and Required Checks'; Required = @('review_mode', 'merge_status: ci_green') }
        @{ Check = 'CHECKPOINT-ROUTE'; Section = 'MCP Surfaces Run the Installed Extension'; Required = @('--require-complete') }
        @{ Check = 'CONCURRENT-CONTRACT-TEST'; Section = 'Contract Tests That Pin Mirrored Files'; Required = @('concurrent-review-skill-contract.Tests.ps1') }
    )
    $script:BriefRow = @(foreach ($check in $briefCheck) {
            foreach ($copy in $briefCopy) {
                @{ Check = $check.Check; Section = $check.Section; Required = $check.Required; Copy = $copy.Copy; Path = $copy.Path }
            }
        })

    # Every policy-read surface outside the contract; the Copilot review prompt is held
    # by the coordinator and is deliberately absent.
    $surfaceForbidden = @(
        'repo-policy reading', 'phase0-instructions-read', 'captures policy reads',
        'Phase 0 tasks that cover', 'Mandatory Policy & Research', 'Compliance & Context'
    )
    $script:PolicyReadSurface = @(
        @{ Id = 'HANDOFF-CLAUDE'; Path = '.claude/skills/remediation-handoff-atomic-planner/SKILL.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-EXEC'; Path = '.github/agents/atomic_executor.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-CS-EXEC'; Path = '.github/agents/csharp-atomic-executor.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-PS-EXEC'; Path = '.github/agents/powershell-atomic-executor.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-PY-EXEC'; Path = '.github/agents/python-atomic-executor.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-ORCH'; Path = '.github/agents/orchestrator.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-CS-ORCH'; Path = '.github/agents/csharp-orchestrator.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-PS-ORCH'; Path = '.github/agents/powershell-orchestrator.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-PY-ORCH'; Path = '.github/agents/python-orchestrator.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-PLANNING'; Path = '.github/agents/atomic_planning.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-CS-PLANNING'; Path = '.github/agents/csharp-atomic-planning.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-PS-PLANNING'; Path = '.github/agents/powershell-atomic-planning.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'COPILOT-PY-PLANNING'; Path = '.github/agents/python-atomic-planning.agent.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'HARD-LOCK-PROMPT'; Path = '.github/prompts/execute-hard-lock.prompt.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'HARD-LOCK-CODEX'; Path = '.github/codex/execute-hard-lock.prompt.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'PLAN-TEMPLATE'; Path = 'docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md'; Forbidden = $surfaceForbidden }
        @{ Id = 'ARCHITECTURE-DOC'; Path = 'docs/engineering/claude-code-architecture.md'; Forbidden = $surfaceForbidden + @('Phase 0 policy reads') }
    )
}

Describe 'Planning contract wording' {
    BeforeAll {
        # Walk up from this file so the suite does not depend on the working directory.
        $script:RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))

        <#
        .SYNOPSIS
            Returns the text of a repository file with whitespace runs collapsed.
        .PARAMETER RelativePath
            The repository-relative path of the file.
        .OUTPUTS
            [string] The collapsed file text.
        #>
        function Get-PcwSurfaceText {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory = $true)]
                [string] $RelativePath
            )

            $path = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
            return ([System.IO.File]::ReadAllText($path) -replace '\s+', ' ')
        }

        <#
        .SYNOPSIS
            Returns one level-two section of a repository file with whitespace runs collapsed.
        .PARAMETER RelativePath
            The repository-relative path of the file.
        .PARAMETER Heading
            The section heading text, without the leading `## `.
        .OUTPUTS
            [string] The collapsed section text, or an empty string when the heading is absent.
        #>
        function Get-PcwSectionText {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory = $true)]
                [string] $RelativePath,

                [Parameter(Mandatory = $true)]
                [string] $Heading
            )

            $path = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
            $text = [System.IO.File]::ReadAllText($path).Replace("`r`n", "`n")
            $start = $text.IndexOf("`n## $Heading`n", [System.StringComparison]::Ordinal)
            if ($start -lt 0) {
                return ''
            }
            $end = $text.IndexOf("`n## ", $start + 1, [System.StringComparison]::Ordinal)
            if ($end -lt 0) {
                $end = $text.Length
            }
            return ($text.Substring($start, $end - $start) -replace '\s+', ' ')
        }
    }

    It 'PCW-STANDING-RULE-<Copy> states the process-reduction ledger rule' -ForEach $script:ContractCopy {
        # Arrange
        $required = @(
            '`docs/engineering/process-reductions/` exists',
            'adds its ledger entry in the same commit',
            'One-off waivers for a single item are not entries.'
        )

        # Act
        $text = Get-PcwSurfaceText -RelativePath $Path
        $missing = @($required | Where-Object { -not $text.Contains($_) })

        # Assert
        $text.Contains('## Process-Reduction Ledger') | Should -BeTrue -Because "$Path must carry the standing-rule section"
        $missing | Should -BeNullOrEmpty -Because "$Path must state the planning-side ledger rule"
    }

    It 'PCW-TASK-TARGET-<Copy> states the task target after the size guideline' -ForEach $script:ContractCopy {
        # Arrange
        $text = Get-PcwSurfaceText -RelativePath $Path

        # Act
        $guideline = $text.IndexOf('**Size guideline.**', [System.StringComparison]::Ordinal)
        $target = $text.IndexOf('**Task target.**', [System.StringComparison]::Ordinal)
        $range = $text.IndexOf('15 to 20', [System.StringComparison]::Ordinal)

        # Assert
        $guideline | Should -BeGreaterOrEqual 0 -Because "$Path must keep the size guideline bullet"
        $target | Should -BeGreaterThan $guideline -Because "$Path must place the task target after the size guideline"
        $range | Should -BeGreaterThan $target -Because "$Path must state the 15 to 20 task target in that bullet"
    }

    It 'PCW-POLICY-READ-REMOVED-<Copy> carries no routine policy-read requirement' -ForEach $script:ContractCopy {
        # Arrange
        $forbidden = @(
            'policy reading',
            'policy reads in required order',
            'policy-read evidence artifact',
            'tasks to read policy files',
            'phase0-instructions-read.md'
        )

        # Act
        $text = Get-PcwSurfaceText -RelativePath $Path
        $held = @($forbidden | Where-Object { $text.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 })

        # Assert
        $held | Should -BeNullOrEmpty -Because "$Path must not require the routine policy-read task"
        $text.Contains('stays valid') | Should -BeTrue -Because "$Path must state that a plan that keeps the task stays valid"
    }

    It 'PCW-SURFACE-<Id> carries no routine policy-read requirement' -ForEach $script:PolicyReadSurface {
        # Arrange
        $text = Get-PcwSurfaceText -RelativePath $Path

        # Act
        $held = @($Forbidden | Where-Object { $text.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 })

        # Assert
        $held | Should -BeNullOrEmpty -Because "$Path must not require the routine policy-read task or its artifact"
    }

    It 'PCW-BRIEF-<Check>-<Copy> states the deferred fact in its section' -ForEach $script:BriefRow {
        # Arrange
        $sectionText = Get-PcwSectionText -RelativePath $Path -Heading $Section

        # Act
        $missing = @($Required | Where-Object { -not $sectionText.Contains($_) })

        # Assert
        $sectionText | Should -Not -BeNullOrEmpty -Because "$Path must keep the section '$Section'"
        $missing | Should -BeNullOrEmpty -Because "$Path must state the fact in '$Section'"
    }
}
