#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Re-entry policy rows R-1 to R-5 for the validate-required-artifact-output.ps1 SubagentStop hook (issue #903).

.DESCRIPTION
    R-1 drives the entry tail twice through the & route, because the missing-argument path is in the
    tail; stdin and stderr are replaced through [Console]::SetIn and [Console]::SetError and restored in
    finally. R-2 to R-5 call Invoke-RequiredArtifactOutputValidation twice with -InputText: once with
    stop_hook_active absent and once with "stop_hook_active": true. R-AST parses the hook and asserts
    that the pure entry reads StopHookActive from the Read-SubagentStopEnvelope result. No row creates,
    renames, moves, or deletes a file, reads a clock, or sleeps.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-required-artifact-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-envelope.ps1')
}

Describe 'validate-required-artifact-output.ps1 re-entry policy' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-required-artifact-output.ps1'))
        $script:Spec = 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact'

        function Invoke-HookTail {
            # Runs the hook entry tail with stdin, stderr, and CLAUDE_HOOK_INPUT replaced for one call; all are restored in finally.
            param(
                [AllowEmptyString()] [string] $StdinText,
                [AllowNull()] [string] $LegacyInput,
                [hashtable] $HookParameter = @{}
            )
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $priorLegacy = $env:CLAUDE_HOOK_INPUT
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            $exitCode = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($StdinText))
                [System.Console]::SetError($errorWriter)
                $env:CLAUDE_HOOK_INPUT = $LegacyInput
                $global:LASTEXITCODE = 0
                try { $null = & $script:Hook @HookParameter } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
                $env:CLAUDE_HOOK_INPUT = $priorLegacy
                $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
                $script:HookDependencyGuardLoadFailed = $false
            }
            return [pscustomobject]@{ Thrown = $thrown; ExitCode = $exitCode; Stderr = $errorWriter.ToString() }
        }

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
    }

    It 'R-1 missing -AgentName blocks once through the inline tail' {
        # Arrange
        Mock Import-Module { }
        $arguments = @{ RequiredArtifact = @($script:Spec) }

        # Act
        $first = Invoke-HookTail -StdinText (ConvertTo-ReentryInputText -Text 'x') -HookParameter $arguments
        $second = Invoke-HookTail -StdinText (ConvertTo-ReentryInputText -Text 'x' -Active) -HookParameter $arguments

        # Assert
        $first.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($first.Thrown))"
        $first.ExitCode | Should -Be 2
        $first.Stderr.Contains('AgentName and at least one RequiredArtifact spec are required') | Should -BeTrue -Because $first.Stderr
        $first.Stderr.Contains('to the operator and halt.') | Should -BeTrue -Because $first.Stderr
        $second.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($second.Thrown))"
        $second.ExitCode | Should -Be 0
        $second.Stderr | Should -BeNullOrEmpty
    }

    It 'R-2 invalid envelope blocks once' {
        $first = Invoke-RequiredArtifactOutputValidation -InputText '{}' -AgentName 'prd-feature' -RequiredArtifact $script:Spec
        $second = Invoke-RequiredArtifactOutputValidation -InputText '{"stop_hook_active":true}' -AgentName 'prd-feature' -RequiredArtifact $script:Spec
        Assert-ReentryRow -First $first -Second $second -Token 'payload anomaly' -Behavior BlockOnce
    }

    It 'R-3 empty assistant text blocks always' {
        $first = Invoke-RequiredArtifactOutputValidation -InputText (ConvertTo-ReentryInputText -Text '') -AgentName 'prd-feature' -RequiredArtifact $script:Spec
        $second = Invoke-RequiredArtifactOutputValidation -InputText (ConvertTo-ReentryInputText -Text '' -Active) -AgentName 'prd-feature' -RequiredArtifact $script:Spec
        Assert-ReentryRow -First $first -Second $second -Token 'agent output is empty' -Behavior BlockAlways
    }

    It 'R-4 malformed artifact spec blocks once' {
        $first = Invoke-RequiredArtifactOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'x') -AgentName 'prd-feature' -RequiredArtifact 'no-pipes'
        $second = Invoke-RequiredArtifactOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'x' -Active) -AgentName 'prd-feature' -RequiredArtifact 'no-pipes'
        Assert-ReentryRow -First $first -Second $second -Token 'Expected format: token|regex|description' -Behavior BlockOnce
    }

    It 'R-5 missing artifact token blocks always' {
        $first = Invoke-RequiredArtifactOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'No artifact path reported.') -AgentName 'prd-feature' -RequiredArtifact $script:Spec
        $second = Invoke-RequiredArtifactOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'No artifact path reported.' -Active) -AgentName 'prd-feature' -RequiredArtifact $script:Spec
        Assert-ReentryRow -First $first -Second $second -Token 'missing spec-path' -Behavior BlockAlways
    }

    It 'R-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:Hook, [ref]$null, [ref]$null)
        $function = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-RequiredArtifactOutputValidation' }, $true))[0]

        # Act
        $assignments = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and @($node.Right.FindAll({ param($inner) $inner -is [System.Management.Automation.Language.CommandAst] -and $inner.GetCommandName() -eq 'Read-SubagentStopEnvelope' }, $true)).Count -gt 0 }, $true))
        $variableName = if ($assignments.Count -gt 0) { $assignments[0].Left.VariablePath.UserPath } else { $null }
        $reads = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.MemberExpressionAst] -and $node.Expression -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.Expression.VariablePath.UserPath -eq $variableName -and $node.Member.Extent.Text -eq 'StopHookActive' }, $true))

        # Assert
        $assignments.Count | Should -BeGreaterThan 0 -Because 'the pure entry assigns the Read-SubagentStopEnvelope result'
        $reads.Count | Should -BeGreaterThan 0 -Because 'the re-entry decision reads StopHookActive from that result'
    }
}
