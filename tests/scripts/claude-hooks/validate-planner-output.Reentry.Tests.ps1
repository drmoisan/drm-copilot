#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Re-entry policy rows P-1 to P-7 for the validate-planner-output.ps1 SubagentStop hook (issue #903).

.DESCRIPTION
    Each row calls Invoke-PlannerOutputValidation twice with -InputText: once with stop_hook_active
    absent and once with "stop_hook_active": true. A block-always row blocks both times; a
    block-once row blocks the first time with report-and-halt wording and allows the second. P-AST
    parses the hook and asserts that the pure entry reads StopHookActive from the
    Read-SubagentStopEnvelope result. Plan reads go through a mocked Get-PlanFileContent. No row
    creates, renames, moves, or deletes a file, reads a clock, or sleeps.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-envelope.ps1')
}

Describe 'validate-planner-output.ps1 re-entry policy' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1'))
        $script:PlanText = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: ALL CLEAR"
        # Issue #964: the structurally valid plan fixture carries a valid Pre-Mortem section.
        $script:PreMortemFixture = @('## Pre-Mortem', '- Review checklists: walked.', '- Coverage: measured.', '- Mirror parity: copied.', '- File size: measured.', '- Test isolation: shuffled.', '- CI-only behavior: checked.', '- Evidence: recorded.', '## Phases')

        function ConvertTo-ReentryInputText {
            # Builds the envelope text for one call; -Active adds stop_hook_active true.
            param([AllowEmptyString()] [string] $Text, [switch] $Active)
            $envelope = [ordered]@{ last_assistant_message = $Text }
            if ($Active) { $envelope['stop_hook_active'] = $true }
            return ($envelope | ConvertTo-Json -Compress)
        }

        function Assert-ReentryRow {
            # Asserts the first call blocks with the token and the second call follows the row behavior.
            param($First, $Second, [string] $Token, [ValidateSet('BlockOnce', 'BlockAlways')] [string] $Behavior)
            $First.Ok | Should -BeFalse -Because 'the first stop must block'
            ([string]$First.Message).Contains($Token) | Should -BeTrue -Because $First.Message
            if ($Behavior -eq 'BlockOnce') {
                ([string]$First.Message).Contains('to the operator and halt.') | Should -BeTrue -Because $First.Message
                $Second.Ok | Should -BeTrue -Because ([string]$Second.Message)
            }
            else {
                $Second.Ok | Should -BeFalse -Because 'a repairable condition blocks on every stop'
                ([string]$Second.Message).Contains($Token) | Should -BeTrue -Because $Second.Message
            }
        }

        function Set-ReentryPlan {
            # Serves one plan read result for one row.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
            param([string[]] $Lines = @(), [bool] $Exists = $true)
            $planLines = $Lines
            $planExists = $Exists
            Mock Get-PlanFileContent { @{ Exists = $planExists; Lines = $planLines } }.GetNewClosure()
        }
    }

    It 'P-1 invalid envelope blocks once' {
        $first = Invoke-PlannerOutputValidation -InputText '{}'
        $second = Invoke-PlannerOutputValidation -InputText '{"stop_hook_active":true}'
        Assert-ReentryRow -First $first -Second $second -Token 'payload anomaly' -Behavior BlockOnce
    }

    It 'P-2 empty assistant text blocks always' {
        $first = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text '')
        $second = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text '' -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'agent output is empty' -Behavior BlockAlways
    }

    It 'P-3 missing preflight signal blocks always' {
        $first = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'plan-path: docs/features/active/foo/plan.md')
        $second = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'plan-path: docs/features/active/foo/plan.md' -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'agent output must include' -Behavior BlockAlways
    }

    It 'P-4 missing plan-path blocks always' {
        $first = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'PREFLIGHT: ALL CLEAR')
        $second = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'PREFLIGHT: ALL CLEAR' -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'does not advertise a plan-path' -Behavior BlockAlways
    }

    It 'P-5 missing plan file blocks always' {
        Set-ReentryPlan -Exists $false
        $first = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText)
        $second = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'no file exists' -Behavior BlockAlways
    }

    It 'P-6 plan structure violations block always' {
        Set-ReentryPlan -Lines @('no phases')
        $first = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText)
        $second = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'violates the atomic plan contract' -Behavior BlockAlways
    }

    It 'P-7 planner internal review violations block always' {
        Set-ReentryPlan -Lines (@($script:PreMortemFixture) + @(
                "### Phase 0 `u{2014} Baseline",
                '- [ ] [P0-T1] Read AGENTS.md and .agents/skills/powershell/SKILL.md and record docs/features/active/foo/evidence/baseline/phase0-instructions-read.md',
                '- [ ] [P0-T2] Capture baseline with pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/baseline/pester.md',
                "### Phase 1 `u{2014} Implement",
                '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1',
                "### Phase 2 `u{2014} Final QA",
                '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
            ))
        $first = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText)
        $second = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'planner internal review must contain exactly one' -Behavior BlockAlways
    }

    It 'P-8 a missing Pre-Mortem section blocks always (issue #964)' {
        Set-ReentryPlan -Lines @(
            "### Phase 0 `u{2014} Baseline",
            '- [ ] [P0-T1] Read policy files and capture baseline for docs/features/active/foo/issue.md',
            "### Phase 1 `u{2014} QA",
            '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
        )
        $first = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText)
        $second = Invoke-PlannerOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanText -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'Pre-Mortem' -Behavior BlockAlways
    }

    It 'P-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:Hook, [ref]$null, [ref]$null)
        $function = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-PlannerOutputValidation' }, $true))[0]

        # Act
        $assignments = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and @($node.Right.FindAll({ param($inner) $inner -is [System.Management.Automation.Language.CommandAst] -and $inner.GetCommandName() -eq 'Read-SubagentStopEnvelope' }, $true)).Count -gt 0 }, $true))
        $variableName = if ($assignments.Count -gt 0) { $assignments[0].Left.VariablePath.UserPath } else { $null }
        $reads = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.MemberExpressionAst] -and $node.Expression -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.Expression.VariablePath.UserPath -eq $variableName -and $node.Member.Extent.Text -eq 'StopHookActive' }, $true))

        # Assert
        $assignments.Count | Should -BeGreaterThan 0 -Because 'the pure entry assigns the Read-SubagentStopEnvelope result'
        $reads.Count | Should -BeGreaterThan 0 -Because 'the re-entry decision reads StopHookActive from that result'
    }
}
