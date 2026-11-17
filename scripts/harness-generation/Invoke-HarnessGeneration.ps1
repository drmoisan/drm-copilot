<#
.SYNOPSIS
    Generates the shared harness surfaces from their sources, or checks them for drift (issue #1028).

.DESCRIPTION
    Runs Invoke-HarnessGeneration from HarnessGeneration.psm1 for one surface or for all surfaces
    (instructions, mcp, skills, rules, agents) against the repository root. With -Check no file is written,
    and the script prints one line per drifted, missing or extra generated file. Without -Check every target
    is written in its rendered form. 'instructions' is check-only, so it is rejected without -Check.

    Exit codes: 0 when no finding remains, 1 on any finding or a malformed source, 2 when the arguments
    are rejected. The entry point runs only when the script is executed; when it is dot-sourced (tests),
    the guard at the end of the file skips it.

.PARAMETER Surface
    skills, rules, mcp, agents, instructions or all.

.PARAMETER Check
    Report drift without writing.

.PARAMETER Root
    Repository root (default: two folders above this script).
#>
[CmdletBinding()]
param(
    [ValidateSet('skills', 'rules', 'mcp', 'agents', 'instructions', 'all')][string] $Surface = 'all',
    [switch] $Check,
    [string] $Root = (Join-Path -Path $PSScriptRoot -ChildPath '../..')
)
Set-StrictMode -Version Latest
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HarnessGeneration.psm1') -Force

function Invoke-HarnessGenerationEntry {
    <#
    .SYNOPSIS
        Runs the generation with the default seams, prints the report and returns the process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('skills', 'rules', 'mcp', 'agents', 'instructions', 'all')][string] $Surface,
        [switch] $Check,
        [Parameter(Mandatory = $true)][string] $Root,
        [System.Collections.IDictionary] $Providers = @{},
        [scriptblock] $WriteFile,
        [scriptblock] $ReadFile,
        [scriptblock] $ListFiles,
        [scriptblock] $TestReparse,
        [scriptblock] $OutputWriter = { param([string] $Line) Write-Information -MessageData $Line -InformationAction Continue }
    )
    if ($Surface -eq 'instructions' -and -not $Check) {
        & $OutputWriter "ERROR: surface 'instructions' is check-only; run it with -Check."
        return 2
    }
    try {
        $context = New-HarnessGenerationContext -Root ([System.IO.Path]::GetFullPath($Root)) -ReadFile $ReadFile -ListFiles $ListFiles -TestReparse $TestReparse
        $result = Invoke-HarnessGeneration -Surface $Surface -Context $context -Check:$Check -Providers $Providers -WriteFile $WriteFile
    }
    catch {
        & $OutputWriter "ERROR: $($_.Exception.Message)"
        return 1
    }
    foreach ($line in @($result.Report)) { & $OutputWriter $line }
    return [int]$result.ExitCode
}

if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-HarnessGenerationEntry -Surface $Surface -Check:$Check -Root $Root)
}
