#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Re-entry policy rows X-1 to X-12 for the validate-executor-output.ps1 SubagentStop hook (issue #903).

.DESCRIPTION
    Each row calls Invoke-ExecutorOutputValidation twice with -InputText: once with
    stop_hook_active absent and once with "stop_hook_active": true. A block-always row blocks both
    times; a block-once row blocks the first time with report-and-halt wording and allows the second.
    X-AST parses the hook and asserts that the pure entry reads StopHookActive from the
    Read-SubagentStopEnvelope result. Plan reads go through a mocked Get-PlanFileContent. No row
    creates, renames, moves, or deletes a file, reads a clock, or sleeps.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-envelope.ps1')
}

Describe 'validate-executor-output.ps1 re-entry policy' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1'))
        $script:PlanPath = 'plan-path: docs/features/active/foo/plan.md'
        $script:Checked = @('### Phase 0 - Baseline', '- [x] [P0-T1] Update scripts/powershell/Foo.ps1')
        $script:Preflight = @('DIRECTIVE: PREFLIGHT VALIDATION ONLY', '### Phase 0 - Baseline', '- [ ] [P0-T1] Read docs/features/active/foo/issue.md')

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

    It 'X-1 invalid envelope blocks once' {
        $first = Invoke-ExecutorOutputValidation -InputText '{}'
        $second = Invoke-ExecutorOutputValidation -InputText '{"stop_hook_active":true}'
        Assert-ReentryRow -First $first -Second $second -Token 'payload anomaly' -Behavior BlockOnce
    }

    It 'X-2 empty assistant text blocks always' {
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text '')
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text '' -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'agent output is empty' -Behavior BlockAlways
    }

    It 'X-3 missing plan-path blocks always' {
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Done.')
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Done.' -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'does not advertise a plan-path' -Behavior BlockAlways
    }

    It 'X-4 missing plan file blocks always' {
        Set-ReentryPlan -Exists $false
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'no file exists' -Behavior BlockAlways
    }

    It 'X-5 non-canonical preflight blocked text blocks always' {
        Set-ReentryPlan -Lines $script:Preflight
        $text = "$($script:PlanPath) BLOCKED during preflight without delta"
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'exact text' -Behavior BlockAlways
    }

    It 'X-6 missing preflight signal blocks always' {
        Set-ReentryPlan -Lines $script:Preflight
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'preflight output must include' -Behavior BlockAlways
    }

    It 'X-7 non-preflight blocked report blocks once' {
        Set-ReentryPlan -Lines $script:Checked
        $text = "$($script:PlanPath) BLOCKED at preflight (before [P0-T1])"
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'blocking is permitted only during preflight' -Behavior BlockOnce
    }

    It 'X-8 plan without task checkboxes blocks once' {
        Set-ReentryPlan -Lines @('### Phase 0 - Baseline')
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'contains no task checkboxes' -Behavior BlockOnce
    }

    It 'X-9 unchecked task blocks always' {
        Set-ReentryPlan -Lines @('### Phase 0 - Baseline', '- [ ] [P0-T1] Update scripts/powershell/Foo.ps1')
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $script:PlanPath -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'unchecked task' -Behavior BlockAlways
    }

    It 'X-10 missing AC Status Summary blocks always' {
        Set-ReentryPlan -Lines $script:Checked
        $text = "$($script:PlanPath) Commands Run: pwsh x PowerShell PASS"
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'AC Status Summary' -Behavior BlockAlways
    }

    It 'X-11 missing command evidence blocks always' {
        Set-ReentryPlan -Lines $script:Checked
        $text = "$($script:PlanPath)`nAC Status Summary`nPowerShell PASS"
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'commands run and pass/fail status' -Behavior BlockAlways
    }

    It 'X-12 missing per-language status line blocks always' {
        Set-ReentryPlan -Lines $script:Checked
        $text = "$($script:PlanPath)`nAC Status Summary`nCommands Run:`nPASS overall"
        $first = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text)
        $second = Invoke-ExecutorOutputValidation -InputText (ConvertTo-ReentryInputText -Text $text -Active)
        Assert-ReentryRow -First $first -Second $second -Token 'missing explicit PASS/FAIL toolchain status lines' -Behavior BlockAlways
    }

    It 'X-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:Hook, [ref]$null, [ref]$null)
        $function = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-ExecutorOutputValidation' }, $true))[0]

        # Act
        $assignments = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and @($node.Right.FindAll({ param($inner) $inner -is [System.Management.Automation.Language.CommandAst] -and $inner.GetCommandName() -eq 'Read-SubagentStopEnvelope' }, $true)).Count -gt 0 }, $true))
        $variableName = if ($assignments.Count -gt 0) { $assignments[0].Left.VariablePath.UserPath } else { $null }
        $reads = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.MemberExpressionAst] -and $node.Expression -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.Expression.VariablePath.UserPath -eq $variableName -and $node.Member.Extent.Text -eq 'StopHookActive' }, $true))

        # Assert
        $assignments.Count | Should -BeGreaterThan 0 -Because 'the pure entry assigns the Read-SubagentStopEnvelope result'
        $reads.Count | Should -BeGreaterThan 0 -Because 'the re-entry decision reads StopHookActive from that result'
    }
}
