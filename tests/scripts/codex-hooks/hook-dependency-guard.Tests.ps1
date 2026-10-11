#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit tests for the Codex copy of the shared hook dependency guard helper (issue #786).

.DESCRIPTION
    Dot-sources .codex/hooks/hook-dependency-guard.ps1 and exercises failure recording, the failure test, the reason text, the
    PreToolUse deny shape, the SubagentStop result, the null decision, record preservation across a
    second dot-source, and the absence of output-stream writes. Every test resets the helper's
    script-scope state in finally. No test creates, renames, moves, or deletes a file.
#>

Describe 'hook-dependency-guard.ps1 helper (Codex)' {
    BeforeAll {
        $script:HelperPath = Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path '.codex/hooks/hook-dependency-guard.ps1'
        . (Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path '.codex/hooks/hook-dependency-guard.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')

        function Get-SampleErrorRecord {
            # An ErrorRecord whose exception message spans two lines.
            param([string] $Message = "first line of the failure`nsecond line of the failure")
            return [System.Management.Automation.ErrorRecord]::new([System.IO.FileNotFoundException]::new($Message), 'SampleLoadFailure', [System.Management.Automation.ErrorCategory]::ObjectNotFound, $null)
        }

        function Initialize-HookDependencyState {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }
    }

    BeforeEach {
        Initialize-HookDependencyState
    }

    It 'H1: records a dependency failure by name' {
        try {
            # Act
            Add-HookDependencyFailure -Name 'Sample.psm1' -ErrorRecord (Get-SampleErrorRecord)
            # Assert
            $script:HookDependencyFailures.Count | Should -Be 1
            $script:HookDependencyFailures[0].Name | Should -Be 'Sample.psm1'
            $script:HookDependencyFailures[0].Message | Should -Be 'first line of the failure'
        }
        finally { Initialize-HookDependencyState }
    }

    It 'H2: reports no failure before any record' {
        try { Test-HookDependencyFailure | Should -BeFalse }
        finally { Initialize-HookDependencyState }
    }

    It 'H3: reports a failure after a record' {
        try {
            Add-HookDependencyFailure -Name 'Sample.psm1'
            Test-HookDependencyFailure | Should -BeTrue
            $script:HookDependencyFailures[0].Message | Should -Be 'no error record'
        }
        finally { Initialize-HookDependencyState }
    }

    It 'H4: builds the reason from the prefix, the dependency name, and the first exception line' {
        try {
            Add-HookDependencyFailure -Name 'First.psm1' -ErrorRecord (Get-SampleErrorRecord)
            Add-HookDependencyFailure -Name 'Second.psm1' -ErrorRecord (Get-SampleErrorRecord -Message 'other')
            Get-HookDependencyFailureReason -ReasonPrefix 'SAMPLE_BLOCKED:' |
                Should -Be "SAMPLE_BLOCKED: the dependency 'First.psm1' failed to load (first line of the failure); the gate fails closed."
        }
        finally { Initialize-HookDependencyState }
    }

    It 'H5: returns the PreToolUse deny decision in the hookSpecificOutput shape' {
        try {
            Add-HookDependencyFailure -Name 'Sample.psm1' -ErrorRecord (Get-SampleErrorRecord)
            $decision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'SAMPLE_BLOCKED:'
            ($decision | ConvertTo-Json -Compress -Depth 5) |
                Should -Be '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"SAMPLE_BLOCKED: the dependency ''Sample.psm1'' failed to load (first line of the failure); the gate fails closed."}}'
        }
        finally { Initialize-HookDependencyState }
    }

    It 'H6: returns a SubagentStop result carrying exit code 2 and the reason' {
        try {
            Add-HookDependencyFailure -Name 'Sample.psm1' -ErrorRecord (Get-SampleErrorRecord)
            $result = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'SAMPLE_BLOCKED:'
            $result.ExitCode | Should -Be 2
            $result.Reason | Should -Be "SAMPLE_BLOCKED: the dependency 'Sample.psm1' failed to load (first line of the failure); the gate fails closed."
        }
        finally { Initialize-HookDependencyState }
    }

    It 'H7: returns null from the decision builder when nothing failed' {
        try {
            Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'SAMPLE_BLOCKED:' | Should -BeNullOrEmpty
            Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'SAMPLE_BLOCKED:' | Should -BeNullOrEmpty
        }
        finally { Initialize-HookDependencyState }
    }

    It 'H8: keeps earlier records when the helper is dot-sourced again' {
        try {
            Add-HookDependencyFailure -Name 'Earlier.psm1'
            . $script:HelperPath
            $script:HookDependencyFailures.Count | Should -Be 1
            $script:HookDependencyFailures[0].Name | Should -Be 'Earlier.psm1'
        }
        finally { Initialize-HookDependencyState }
    }

    It 'H9: writes nothing to any output stream when recording a failure' {
        $priorOut = [System.Console]::Out
        $consoleWriter = [System.IO.StringWriter]::new()
        try {
            [System.Console]::SetOut($consoleWriter)
            $streams = @(& { Add-HookDependencyFailure -Name 'Sample.psm1' -ErrorRecord (Get-SampleErrorRecord); $null = Test-HookDependencyFailure } *>&1)
        }
        finally {
            [System.Console]::SetOut($priorOut)
            Initialize-HookDependencyState
        }
        $streams | Should -BeNullOrEmpty
        $consoleWriter.ToString() | Should -BeNullOrEmpty
    }

    It 'H10: contains no Import-Module and no dot-source' {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HelperPath, [ref]$tokens, [ref]$parseErrors)
        @($parseErrors) | Should -BeNullOrEmpty
        @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and ($n.GetCommandName() -eq 'Import-Module' -or $n.InvocationOperator -eq 'Dot') }, $true)) | Should -BeNullOrEmpty
    }

    It 'H12: stays within 500 lines' {
        @(Get-Content -LiteralPath $script:HelperPath).Count | Should -BeLessOrEqual 500
    }
}
