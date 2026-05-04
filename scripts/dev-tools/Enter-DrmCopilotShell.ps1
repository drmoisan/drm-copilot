#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepoRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath "..\..")),

    [Parameter()]
    [string]$VirtualEnvironmentPath = (Join-Path -Path ([System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath "..\.."))) -ChildPath ".venv"),

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$PromptName = "drm-copilot"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path -Path $PSScriptRoot -ChildPath "DrmCopilotPromptSupport.ps1")

Start-DrmCopilotPromptSession `
    -RepoRootPath $RepoRootPath `
    -VirtualEnvironmentPath $VirtualEnvironmentPath `
    -PromptName $PromptName
