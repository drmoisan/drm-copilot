<#
    Test-support helpers for the Codex preimplementation-gate command-exemption suites.

    The three functions below moved unchanged from the BeforeAll block of
    enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
    (issue #935, I-3). Each consuming suite dot-sources this file after the hook and
    the Baseline helper. The functions read no file and start no process.
#>

function ConvertTo-CodexExemptionToolInput {
    <#
        Builds the MAPPED tool_input JSON the Codex decision seam consumes. The
        command text is carried verbatim so a fixture can exercise quoting,
        chaining, and redirection exactly as the shell would present it.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

    return (@{ command = $Command } | ConvertTo-Json -Compress -Depth 5)
}

function ConvertTo-CodexNotReadyCheckpointRaw {
    <#
        An explicitly NOT-ready checkpoint: route id empty and lifecycle
        readiness false, so `Test-OrchestrationReady` returns false and any
        allow decision must come from the command-branch exemption alone.
    #>
    param()

    return @{
        'issue-num'      = ''
        'feature-folder' = ''
        route_id         = ''
        lifecycle_ready  = $false
    } | ConvertTo-Json -Compress
}

function Get-CodexExemptionDecisionForCommand {
    <#
        Single act step for every case in this file: classify one command text
        against a not-ready checkpoint and return the decision object.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

    return Invoke-OrchestrationPreimplementationGateDecision `
        -ToolInputRaw (ConvertTo-CodexExemptionToolInput -Command $Command) `
        -CheckpointRaw (ConvertTo-CodexNotReadyCheckpointRaw)
}
