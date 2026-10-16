#Requires -Version 7.0
<#
.SYNOPSIS
    Shared SubagentStop envelope builder for the artifact-gate validator suites (issue #929, review note NB-4).

.DESCRIPTION
    Suites dot-source this file from a BeforeAll block with
    . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')
    It defines one function, holds no state, and writes no file.
#>

function ConvertTo-SubagentStopEnvelopeJson {
    <#
    .SYNOPSIS
        Returns compressed SubagentStop envelope JSON text.
    .DESCRIPTION
        Keys, in order: session_id ('e3-905'), hook_event_name ('SubagentStop'), agent_type,
        stop_hook_active, then last_assistant_message unless -OmitAssistantMessage is set, then
        output only when -OutputField is bound.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyString()] [string] $AssistantMessage = '',
        [switch] $OmitAssistantMessage,
        [string] $OutputField,
        [switch] $StopHookActive,
        [string] $AgentType = 'general-purpose'
    )

    $envelope = [ordered]@{ session_id = 'e3-905'; hook_event_name = 'SubagentStop'; agent_type = $AgentType; stop_hook_active = [bool]$StopHookActive }
    if (-not $OmitAssistantMessage) { $envelope['last_assistant_message'] = $AssistantMessage }
    if ($PSBoundParameters.ContainsKey('OutputField')) { $envelope['output'] = $OutputField }
    return ($envelope | ConvertTo-Json -Compress)
}
