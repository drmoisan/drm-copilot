<#
.SYNOPSIS
    Validates numeric acceptance criteria produced by the prd-feature worker.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ArtifactPathFromOutput {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string] $Output, [Parameter(Mandatory = $true)][string] $Label)

    $match = [regex]::Match($Output, "(?im)^\s*$([regex]::Escape($Label))\s*:\s*(?<path>\S+)")
    if ($match.Success) { return $match.Groups['path'].Value }
    return $null
}

function Test-NumericDerivationEvidence {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Content)

    $section = [regex]::Match($Content, '(?ims)^##\s+Numeric\s+Derivation\s+Evidence\s*$.*?(?=^##\s|\z)')
    if (-not $section.Success) { return @{ Ok = $false; Message = 'prd-feature hook: numeric criterion requires ## Numeric Derivation Evidence.' } }
    foreach ($label in @('Family', 'Inclusion Rules', 'Exclusion Rules', 'Member Set', 'Primary Count', 'Cross-check Count')) {
        if (-not [regex]::IsMatch($section.Value, "(?im)^\s*[-*]?\s*$([regex]::Escape($label))\s*:\s*\S")) {
            return @{ Ok = $false; Message = "prd-feature hook: numeric derivation evidence is missing $label." }
        }
    }
    $primary = [regex]::Match($section.Value, '(?im)^\s*[-*]?\s*Primary Count\s*:\s*(?<count>\d+)\s*$')
    $crossCheck = [regex]::Match($section.Value, '(?im)^\s*[-*]?\s*Cross-check Count\s*:\s*(?<count>\d+)\s*$')
    if ($primary.Groups['count'].Value -ne $crossCheck.Groups['count'].Value) {
        return @{ Ok = $false; Message = 'prd-feature hook: numeric derivation primary and independent cross-check counts disagree.' }
    }
    return @{ Ok = $true; Message = $null }
}

function Test-SpecNumericCriterion {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $SpecContent)

    $section = [regex]::Match($SpecContent, '(?ims)^##\s+Acceptance\s+Criteria\s*$.*?(?=^##\s|\z)')
    return $section.Success -and [regex]::IsMatch($section.Value, '(?m)^\s*[-*]\s*\[.\].*\b\d+\b')
}

function Invoke-PrdFeatureOutputValidation {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([string] $RawPayload)

    if ([string]::IsNullOrWhiteSpace($RawPayload)) { return @{ Ok = $false; Message = 'prd-feature hook: CLAUDE_HOOK_INPUT is empty.' } }
    try { $payload = $RawPayload | ConvertFrom-Json -ErrorAction Stop } catch { return @{ Ok = $false; Message = "prd-feature hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" } }
    $output = if ($null -ne $payload.PSObject.Properties['output']) { $payload.output } else { $null }
    if ([string]::IsNullOrWhiteSpace($output)) { return @{ Ok = $false; Message = 'prd-feature hook: agent output is empty.' } }
    $specPath = Get-ArtifactPathFromOutput -Output $output -Label 'spec-path'
    if ([string]::IsNullOrWhiteSpace($specPath) -or -not (Test-Path -LiteralPath $specPath -PathType Leaf)) { return @{ Ok = $false; Message = 'prd-feature hook: spec-path is required and must exist.' } }
    $specContent = Get-Content -LiteralPath $specPath -Raw -ErrorAction Stop
    if (-not (Test-SpecNumericCriterion -SpecContent $specContent)) { return @{ Ok = $true; Message = $null } }
    $researchPath = Get-ArtifactPathFromOutput -Output $output -Label 'research-path'
    if ([string]::IsNullOrWhiteSpace($researchPath) -or -not (Test-Path -LiteralPath $researchPath -PathType Leaf)) { return @{ Ok = $false; Message = 'prd-feature hook: numeric acceptance criterion requires an existing research-path.' } }
    return Test-NumericDerivationEvidence -Content (Get-Content -LiteralPath $researchPath -Raw -ErrorAction Stop)
}

if ($MyInvocation.InvocationName -eq '.') { return }
$result = Invoke-PrdFeatureOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
if (-not $result.Ok) { Write-Error $result.Message; exit 1 }
exit 0
