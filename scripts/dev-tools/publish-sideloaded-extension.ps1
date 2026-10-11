<#
.SYNOPSIS
Packages the VS Code extension into a VSIX and installs it locally (side-loaded).

.DESCRIPTION
This script is intended for development workflows where you want to install the
extension into your local VS Code without publishing to the Marketplace.

It performs, in order:
- (Optional) npm ci
- (Optional) npm run compile
- npx vsce package (writes a VSIX)
- (Optional) code --install-extension <vsix> --force

All state-changing actions are gated behind ShouldProcess so you can use -WhatIf.

.NOTES
- Requires Node.js + npm.
- Requires VS Code CLI "code" (or "code-insiders") on PATH for installation.
- Uses "npx vsce" so you do not need a global vsce install.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,

    [Parameter()]
    [AllowEmptyString()]
    [string]$CodeCommand = "",

    [Parameter()]
    [switch]$UseInsiders,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$VsixOutputDir = (Join-Path $RepoRoot "artifacts\vsix"),

    [Parameter()]
    [switch]$SkipNpmCi,

    [Parameter()]
    [switch]$SkipCompile,

    [Parameter()]
    [switch]$SkipInstall,

    [Parameter()]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'SideloadedExtensionPublish.psm1')

$invokeParameters = @{
    RepoRoot      = $RepoRoot
    UseInsiders   = $UseInsiders
    VsixOutputDir = $VsixOutputDir
    SkipNpmCi     = $SkipNpmCi
    SkipCompile   = $SkipCompile
    SkipInstall   = $SkipInstall
    Force         = $Force
}
if ($PSBoundParameters.ContainsKey('CodeCommand')) {
    $invokeParameters['CodeCommand'] = $CodeCommand
}
if ($PSBoundParameters.ContainsKey('WhatIf')) {
    $invokeParameters['WhatIf'] = $PSBoundParameters['WhatIf']
}
if ($PSBoundParameters.ContainsKey('Confirm')) {
    $invokeParameters['Confirm'] = $PSBoundParameters['Confirm']
}
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $invokeParameters['Verbose'] = $PSBoundParameters['Verbose']
}
if ($PSBoundParameters.ContainsKey('WarningAction')) {
    $invokeParameters['WarningAction'] = $PSBoundParameters['WarningAction']
}

Invoke-SideloadedExtensionPublish @invokeParameters
