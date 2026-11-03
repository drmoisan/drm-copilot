<#
.SYNOPSIS
    Fixture analyzer for DocsAnalyzerRegistry.Tests.ps1, loaded through the -ImportModule seam.

.DESCRIPTION
    Invoke-DocsAnalyzerFixture is pure: it returns one element built with New-DocsSurfaceElement
    from the first captured input, with the kind, analysis method, declaration, name, analyzer
    identifier and line range taken from -Selection. It reads and writes nothing.

.NOTES
    Issue #1020. Test fixture only; never shipped.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../../.claude/lib/docs/DocsSurface.psm1') -ErrorAction Stop

function Invoke-DocsAnalyzerFixture {
    <#
    .SYNOPSIS
        Returns @{ Elements = @(<one element>); Diagnostics = @() } for the first captured input.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Selection
    )

    $first = $CapturedInput[0]
    $element = New-DocsSurfaceElement `
        -Kind $Selection['Kind'] `
        -Path $first['path'] `
        -Declaration $Selection['Declaration'] `
        -Name $Selection['Name'] `
        -AnalyzerId $Selection['AnalyzerId'] `
        -AnalysisMethod $Selection['AnalysisMethod'] `
        -SourceText $first['text'] `
        -LineRange $Selection['LineRange']
    return @{ Elements = @($element); Diagnostics = @() }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerFixture
