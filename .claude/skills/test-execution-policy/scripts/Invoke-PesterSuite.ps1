<#
.SYNOPSIS
    The pester suite of the test-execution launcher (issue #1158, spec D26): imports PoshQC and runs
    Invoke-PoshQCParallelTest with the launcher's words bound as parameters.

.DESCRIPTION
    Runs only through the launcher (Invoke-TestSuite.ps1 or run-test-suite.sh), which holds the machine
    test-suite lock; the enforce-test-execution-policy hook denies a direct run. The script has no param
    block and no CmdletBinding, so every word arrives unchanged in $args. A word equal (ordinal,
    case-insensitive) to '-' plus a declared parameter name of Invoke-PoshQCParallelTest starts a key;
    every other word, including a suffix such as '-integration.test.ts', is a value of the current key;
    a key with no value is $true; a value before any key stops the script with exit 1. The script adds
    -Root . when no Root is given, never adds -WorkerCount, and exits with the result's ExitCode.

    The script-file entry runs only when the script is not dot-sourced; it reads the optional hashtable
    variable PesterSuiteSeams from the caller's scope and splats it onto Invoke-PesterSuite.
#>

function ConvertTo-PesterSuiteParameter {
    <#
    .SYNOPSIS
        Convert the launcher's words into the Invoke-PoshQCParallelTest parameter hashtable.
    .PARAMETER ArgumentList
        The words after the script path.
    .PARAMETER ParameterName
        The declared parameter names of Invoke-PoshQCParallelTest.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowEmptyCollection()][AllowEmptyString()][string[]] $ArgumentList = @(),
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $ParameterName
    )

    $table = @{}
    $values = @{}
    $currentKey = $null
    foreach ($word in $ArgumentList) {
        $key = $null
        if ($word.Length -gt 1 -and $word.StartsWith('-')) {
            $candidate = $word.Substring(1)
            $key = @($ParameterName | Where-Object { [string]::Equals($_, $candidate, [System.StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1)
        }
        if ($null -ne $key -and $key.Count -gt 0) {
            $currentKey = [string]$key[0]
            if (-not $values.ContainsKey($currentKey)) { $values[$currentKey] = [System.Collections.Generic.List[string]]::new() }
            continue
        }
        if ($null -eq $currentKey) { throw "Invoke-PesterSuite: unexpected argument '$word' before any parameter name." }
        $values[$currentKey].Add($word)
    }
    foreach ($name in $values.Keys) {
        $list = $values[$name]
        $table[$name] = switch ($list.Count) {
            0 { $true }
            1 { $list[0] }
            default { [string[]]$list.ToArray() }
        }
    }
    return $table
}

function Invoke-PesterSuite {
    <#
    .SYNOPSIS
        Import PoshQC and run Invoke-PoshQCParallelTest with the converted parameters; return its ExitCode.
    .PARAMETER ArgumentList
        The words after the script path.
    .PARAMETER RepositoryRoot
        The repository root; defaults to the current location.
    .PARAMETER ImportModule
        Seam that imports the PoshQC manifest path.
    .PARAMETER GetParameterName
        Seam that returns the declared parameter names of Invoke-PoshQCParallelTest.
    .PARAMETER InvokeParallelTest
        Seam that runs Invoke-PoshQCParallelTest with a parameter hashtable and returns its result.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowEmptyCollection()][AllowEmptyString()][string[]] $ArgumentList = @(),
        [string] $RepositoryRoot = (Get-Location).ProviderPath,
        [scriptblock] $ImportModule = { param([string] $Path) Import-Module -Name $Path -Force },
        [scriptblock] $GetParameterName = {
            $common = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            @((Get-Command -Name Invoke-PoshQCParallelTest).Parameters.Keys | Where-Object { $common -notcontains $_ })
        },
        [scriptblock] $InvokeParallelTest = { param([hashtable] $Parameter) Invoke-PoshQCParallelTest @Parameter }
    )

    & $ImportModule (Join-Path $RepositoryRoot 'scripts/powershell/PoshQC/PoshQC.psd1')
    $parameters = ConvertTo-PesterSuiteParameter -ArgumentList $ArgumentList -ParameterName ([string[]]@(& $GetParameterName))
    if (-not $parameters.ContainsKey('Root')) { $parameters['Root'] = '.' }
    $result = & $InvokeParallelTest $parameters
    return [int]$result.ExitCode
}

if ($MyInvocation.InvocationName -ne '.') {
    $pesterSuiteSeamTable = Get-Variable -Name PesterSuiteSeams -ValueOnly -ErrorAction Ignore
    if ($pesterSuiteSeamTable -isnot [hashtable]) { $pesterSuiteSeamTable = @{} }
    try {
        $pesterSuiteExitCode = Invoke-PesterSuite -ArgumentList $args @pesterSuiteSeamTable
    } catch {
        [Console]::Error.WriteLine($_.Exception.Message)
        exit 1
    }
    exit $pesterSuiteExitCode
}
