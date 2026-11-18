#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision rows for the Codex SubagentStop envelope twin .codex/hooks/subagentstop-envelope.ps1 (issue #1030).

.DESCRIPTION
    Dot-sources the Codex twin and runs the decision rows of
    tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 against it through -InputText: the six
    anomaly codes, the leading-BOM strip, the StopHookActive, AgentType and HookEventName fields of a Codex
    payload, and the unknown anomaly code. Every input is an inline string; no test creates a file, reads
    stdin, or starts a process.
#>
Set-StrictMode -Version Latest

Describe 'Codex subagentstop-envelope twin' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..')).Path
        $script:HelperPath = Join-Path $script:RepoRoot '.codex/hooks/subagentstop-envelope.ps1'
        . $script:HelperPath
    }

    It 'loads the envelope functions from the Codex file' {
        ((Get-Command -Name Read-SubagentStopEnvelope -CommandType Function).ScriptBlock.File -replace '\\', '/') | Should -BeLike '*/.codex/hooks/subagentstop-envelope.ps1'
    }

    Context 'anomaly codes' {
        It 'classifies <Name> as <Anomaly>' -ForEach @(
            @{ Name = 'an empty payload'; InputText = ''; Anomaly = 'EmptyPayload'; EnvelopeIsNull = $true }
            @{ Name = 'a whitespace payload'; InputText = "  `t`r`n  "; Anomaly = 'EmptyPayload'; EnvelopeIsNull = $true }
            @{ Name = 'a non-JSON payload'; InputText = '{not-json'; Anomaly = 'UnparseableJson'; EnvelopeIsNull = $true }
            @{ Name = 'an array root'; InputText = '[{"last_assistant_message":"x"}]'; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true }
            @{ Name = 'a JSON null root'; InputText = 'null'; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true }
            @{ Name = 'a payload without last_assistant_message'; InputText = '{"hook_event_name":"SubagentStop","agent_type":"pr-author"}'; Anomaly = 'MissingAssistantMessage'; EnvelopeIsNull = $false }
            @{ Name = 'a null last_assistant_message'; InputText = '{"last_assistant_message":null}'; Anomaly = 'NullAssistantMessage'; EnvelopeIsNull = $false }
            @{ Name = 'a numeric last_assistant_message'; InputText = '{"last_assistant_message":5}'; Anomaly = 'NonStringAssistantMessage'; EnvelopeIsNull = $false }
        ) {
            $result = Read-SubagentStopEnvelope -InputText $InputText
            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -BeExactly $Anomaly
            if ($EnvelopeIsNull) { $result.Envelope | Should -BeNullOrEmpty } else { $result.Envelope | Should -Not -BeNullOrEmpty }
            $result.AssistantText | Should -BeExactly ''
        }

        It 'returns a non-empty clause for <Code>' -ForEach @(
            @{ Code = 'EmptyPayload' }
            @{ Code = 'UnparseableJson' }
            @{ Code = 'NonObjectEnvelope' }
            @{ Code = 'MissingAssistantMessage' }
            @{ Code = 'NullAssistantMessage' }
            @{ Code = 'NonStringAssistantMessage' }
        ) {
            Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Code | Should -Not -BeNullOrEmpty
        }

        It 'throws ArgumentException for the unknown anomaly code <Code>' -ForEach @(
            @{ Code = 'NotACode' }
            @{ Code = 'emptypayload' }
            @{ Code = '' }
        ) {
            { Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Code } | Should -Throw -ExceptionType ([System.ArgumentException])
        }
    }

    Context 'Codex payload fields' {
        It 'returns every field of a valid Codex SubagentStop payload' {
            $result = Read-SubagentStopEnvelope -InputText '{"session_id":"s-1030","turn_id":"t-1","hook_event_name":"SubagentStop","agent_type":"pr-author","stop_hook_active":true,"last_assistant_message":"Created PR #1030"}'
            $result.IsValid | Should -BeTrue
            $result.Anomaly | Should -BeNullOrEmpty
            $result.AssistantText | Should -BeExactly 'Created PR #1030'
            $result.StopHookActive | Should -BeTrue
            $result.AgentType | Should -BeExactly 'pr-author'
            $result.HookEventName | Should -BeExactly 'SubagentStop'
        }

        It 'sets StopHookActive to <Expected> when stop_hook_active is <Name>' -ForEach @(
            @{ Name = 'false'; InputText = '{"stop_hook_active":false,"last_assistant_message":"m"}'; Expected = $false }
            @{ Name = 'absent'; InputText = '{"last_assistant_message":"m"}'; Expected = $false }
            @{ Name = 'the string true'; InputText = '{"stop_hook_active":"true","last_assistant_message":"m"}'; Expected = $false }
        ) {
            (Read-SubagentStopEnvelope -InputText $InputText).StopHookActive | Should -Be $Expected
        }

        It 'leaves AgentType and HookEventName empty when they are not strings' {
            $result = Read-SubagentStopEnvelope -InputText '{"agent_type":5,"hook_event_name":5,"last_assistant_message":"m"}'
            $result.AgentType | Should -BeExactly ''
            $result.HookEventName | Should -BeExactly ''
        }

        It 'strips one leading BOM before parsing' {
            $result = Read-SubagentStopEnvelope -InputText ("$([char]0xFEFF)" + '{"last_assistant_message":"bom"}')
            $result.IsValid | Should -BeTrue
            $result.AssistantText | Should -BeExactly 'bom'
        }

        It 'treats a BOM-only payload as EmptyPayload' {
            (Read-SubagentStopEnvelope -InputText "$([char]0xFEFF)").Anomaly | Should -BeExactly 'EmptyPayload'
        }
    }
}
