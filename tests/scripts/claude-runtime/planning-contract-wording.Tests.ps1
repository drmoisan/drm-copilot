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
}
