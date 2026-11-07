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
        @{ Check = 'LIGHT-ROUTE'; Section = 'MCP Surfaces Run the Installed Extension'; Required = @('invariant 8') }
        @{ Check = 'LIGHT-CONTRACT-TEST'; Section = 'Contract Tests That Pin Mirrored Files'; Required = @('light-remediation-skill-contract.Tests.ps1') }
    )
    # The two planner agents and their bundles restate the G13 guideline.
    $script:PlannerAgent = @(
        @{ Id = 'CLAUDE-PLANNER'; Path = '.claude/agents/atomic-planner.md' }
        @{ Id = 'CLAUDE-PLANNER-BUNDLE'; Path = "$resources/claude-customizations/.claude/agents/atomic-planner.md" }
        @{ Id = 'COPILOT-PLANNER'; Path = '.github/agents/atomic_planning.agent.md' }
        @{ Id = 'COPILOT-PLANNER-BUNDLE'; Path = "$resources/customizations/.github/agents/atomic_planning.agent.md" }
    )
    $script:ModeSurface = @(
        @{ Id = 'HANDOFF-CLAUDE'; Path = '.claude/skills/remediation-handoff-atomic-planner/SKILL.md' }
        @{ Id = 'HANDOFF-AGENTS'; Path = '.agents/skills/remediation-handoff-atomic-planner/SKILL.md' }
        @{ Id = 'HANDOFF-GITHUB'; Path = '.github/skills/remediation-handoff-atomic-planner/SKILL.md' }
        @{ Id = 'COPILOT-ORCH'; Path = '.github/agents/orchestrator.agent.md' }
    )
    $script:BriefRow = @(foreach ($check in $briefCheck) {
            foreach ($copy in $briefCopy) {
                @{ Check = $check.Check; Section = $check.Section; Required = $check.Required; Copy = $copy.Copy; Path = $copy.Path }
            }
        })

    # Every policy-read surface outside the contract, including the Copilot review prompt,
    # whose phase0-instructions-read.md bullet the owner ruled outside the baseline hold.
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
        @{ Id = 'REVIEW-PROMPT'; Path = '.github/prompts/review-feature.prompt.md'; Forbidden = $surfaceForbidden }
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
            Returns one section of a repository file with whitespace runs collapsed.
        .PARAMETER RelativePath
            The repository-relative path of the file.
        .PARAMETER Heading
            The section heading text, without the leading hashes.
        .PARAMETER Level
            The heading level; the section ends at the next heading of this level or higher.
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
                [string] $Heading,

                [ValidateRange(1, 6)]
                [int] $Level = 2
            )

            $path = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
            $text = [System.IO.File]::ReadAllText($path).Replace("`r`n", "`n")
            $start = $text.IndexOf("`n$('#' * $Level) $Heading`n", [System.StringComparison]::Ordinal)
            if ($start -lt 0) {
                return ''
            }
            $next = [regex]::Match($text.Substring($start + 1), "\n#{1,$Level} ")
            $end = if ($next.Success) { $start + 1 + $next.Index } else { $text.Length }
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

    It 'PCW-SIZE-GUIDELINE-<Copy> states the lowered guideline and its cutoff in the size bullet' -ForEach $script:ContractCopy {
        # Arrange
        $text = Get-PcwSurfaceText -RelativePath $Path
        $guideline = $text.IndexOf('**Size guideline.**', [System.StringComparison]::Ordinal)
        $target = $text.IndexOf('**Task target.**', [System.StringComparison]::Ordinal)

        # Act
        $bullet = if ($guideline -ge 0 -and $target -gt $guideline) { $text.Substring($guideline, $target - $guideline) } else { '' }

        # Assert
        $bullet | Should -Not -BeNullOrEmpty -Because "$Path must keep the size guideline bullet before the task target"
        $bullet.Contains('20 canonical tasks and 250 physical lines') | Should -BeTrue -Because "$Path must state the lowered guideline"
        $bullet.Contains('PLAN_GUIDELINE_CUTOFF') | Should -BeTrue -Because "$Path must name the cutoff that keeps older plans on the legacy pair"
        $text.Contains('40 tasks or 400 lines') | Should -BeFalse -Because "$Path must not state the superseded guideline"
    }

    It 'PCW-SIZE-AGENT-<Id> states the lowered guideline with its cutoff' -ForEach $script:PlannerAgent {
        # Arrange / Act
        $text = Get-PcwSurfaceText -RelativePath $Path

        # Assert
        $text.Contains('PLAN_GUIDELINE_CUTOFF') | Should -BeTrue -Because "$Path must name the cutoff"
        $text.Contains('40 tasks or 400 lines') | Should -BeFalse -Because "$Path must not state the superseded guideline"
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

    It 'PCW-LIGHT-WORDING-<Copy> names the light cycle in the single-pass preflight section' -ForEach $script:ContractCopy {
        # Arrange
        $sectionText = Get-PcwSectionText -RelativePath $Path -Heading 'Single-Pass Preflight' -Level 3

        # Act
        $named = $sectionText.Contains('`Remediation-Mode: light`')

        # Assert
        $sectionText | Should -Not -BeNullOrEmpty -Because "$Path must keep the single-pass preflight section"
        $named | Should -BeTrue -Because "$Path must state how a light cycle relates to preflight"
    }

    It 'PCW-MODE-LIGHT-<Id> names the third remediation mode' -ForEach $script:ModeSurface {
        # Arrange
        $text = Get-PcwSurfaceText -RelativePath $Path

        # Act
        $named = $text.Contains('`Remediation-Mode: light`')

        # Assert
        $named | Should -BeTrue -Because "$Path must name the light mode that the orchestrate skill defines"
    }
}
