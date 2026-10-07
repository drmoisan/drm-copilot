<#
.SYNOPSIS
    Stand-in for a pushed-down drm-copilot hook in the PoshQC consumer fixture.

.DESCRIPTION
    Reproduces the issue #623 item 1 layout: a consumer repository that received
    drm-copilot hooks under .claude/hooks through push-down. The fixture's tests
    never execute this file. A PoshQC coverage run over the fixture must not
    measure it as part of the consumer's coverage population.
#>

function Test-StandInHookPayload {
    <#
    .SYNOPSIS
        Returns true; exists only so the stand-in file contains a function.

    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    return $true
}
