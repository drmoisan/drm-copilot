<#
.SYNOPSIS
    Pure route helpers for the PowerShell batch-budget hook.

.DESCRIPTION
    Defines the functions that read the selected route from orchestrator checkpoint
    text and decide whether that checkpoint selects the uncapped orchestrated large
    path. The file is dot-sourced by enforce-powershell-batch-budget.ps1 and has no
    entry point. None of the functions reads a file or an environment variable; the
    checkpoint text is supplied by the caller.

.NOTES
    Compatible with PowerShell 7+.
#>

function ConvertFrom-PowerShellBatchBudgetCheckpoint {
    <#
    .SYNOPSIS
        Parses orchestrator checkpoint text into a checkpoint object.
    .DESCRIPTION
        Returns the parsed object only when the text is a JSON object. Null or
        whitespace text, text that is not parseable JSON, and JSON whose root is not
        an object all return $null. Performs no file or environment access.
    .PARAMETER CheckpointText
        Raw text of the orchestrator checkpoint file.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $CheckpointText
    )

    if ([string]::IsNullOrWhiteSpace($CheckpointText)) {
        return $null
    }

    try {
        $parsed = ConvertFrom-Json -InputObject $CheckpointText -ErrorAction Stop
    } catch {
        Write-Verbose "Ignoring unparseable orchestrator checkpoint text: $($_.Exception.Message)"
        return $null
    }

    if ($parsed -is [System.Management.Automation.PSCustomObject]) {
        return $parsed
    }

    return $null
}

function Get-PowerShellBatchBudgetSelectedRoute {
    <#
    .SYNOPSIS
        Returns the route selected by an orchestrator checkpoint.
    .DESCRIPTION
        Uses route_id when the checkpoint has that key, otherwise path_selected. The
        value is returned only when it is a non-blank string; every other case,
        including unparseable text, returns an empty string.
    .PARAMETER CheckpointText
        Raw text of the orchestrator checkpoint file.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $CheckpointText
    )

    $checkpoint = ConvertFrom-PowerShellBatchBudgetCheckpoint -CheckpointText $CheckpointText
    if ($null -eq $checkpoint) {
        return ''
    }

    $propertyNames = @($checkpoint.PSObject.Properties.Name)
    $rawRoute = $null
    if ($propertyNames -contains 'route_id') {
        $rawRoute = $checkpoint.route_id
    } elseif ($propertyNames -contains 'path_selected') {
        $rawRoute = $checkpoint.path_selected
    }

    if ($rawRoute -is [string] -and -not [string]::IsNullOrWhiteSpace($rawRoute)) {
        return $rawRoute
    }

    return ''
}

function Test-PowerShellBatchBudgetLargePathRoute {
    <#
    .SYNOPSIS
        Reports whether an orchestrator checkpoint selects the uncapped large path.
    .DESCRIPTION
        Returns $true only when the checkpoint parses to an object, its selected route
        is large, remediation, or preparation (case-sensitive), next_step is not
        complete, and completed_steps does not contain S12_complete. No input causes
        an exception; any failure returns $false.
    .PARAMETER CheckpointText
        Raw text of the orchestrator checkpoint file.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $CheckpointText
    )

    try {
        $checkpoint = ConvertFrom-PowerShellBatchBudgetCheckpoint -CheckpointText $CheckpointText
        if ($null -eq $checkpoint) {
            return $false
        }

        $route = Get-PowerShellBatchBudgetSelectedRoute -CheckpointText $CheckpointText
        if (-not (@('large', 'remediation', 'preparation') -ccontains $route)) {
            return $false
        }

        $propertyNames = @($checkpoint.PSObject.Properties.Name)
        if ($propertyNames -contains 'next_step' -and $checkpoint.next_step -is [string] -and $checkpoint.next_step -ceq 'complete') {
            return $false
        }

        if ($propertyNames -contains 'completed_steps' -and (@($checkpoint.completed_steps) -ccontains 'S12_complete')) {
            return $false
        }

        return $true
    } catch {
        Write-Verbose "Treating the orchestrator checkpoint as direct mode: $($_.Exception.Message)"
        return $false
    }
}
