<#
.SYNOPSIS
    Production module of the PoshQC consumer fixture (issue #527).

.DESCRIPTION
    Provides a single function used by the fixture's own Pester test. A PoshQC
    acceptance run over this fixture must measure this file in its coverage
    population.
#>

function Get-SampleGreeting {
    <#
    .SYNOPSIS
        Returns a greeting for the supplied name.

    .PARAMETER Name
        The name to greet.

    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    return "Hello, $Name."
}

Export-ModuleMember -Function 'Get-SampleGreeting'
