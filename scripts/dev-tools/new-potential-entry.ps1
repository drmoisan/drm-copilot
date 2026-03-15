# Creates a dated potential feature file from the template and opens it plus backlog.md.
param(
    [string] $ShortName,
    [string] $TemplateRoot
)

. (Join-Path -Path $PSScriptRoot -ChildPath 'vscode-cli.helpers.ps1')

function Test-ValidShortName {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [AllowEmptyString()]
        [string] $CandidateName
    )

    $shortPattern = '^[a-z0-9]+(-[a-z0-9]+)*$'
    if ($CandidateName -cmatch $shortPattern) {
        return $true
    }

    return $false
}

function Get-AuthorName {
    [CmdletBinding()]
    param(
        [scriptblock] $GetGitConfig = { param([string]$Key) git config $Key 2>$null },
        [scriptblock] $GetEnvironmentVariable = { param([string]$Name) [Environment]::GetEnvironmentVariable($Name) }
    )

    $author = & $GetGitConfig 'user.name'
    if (-not $author -or [string]::IsNullOrWhiteSpace($author)) {
        $author = & $GetEnvironmentVariable 'USERNAME'
    }
    if (-not $author) { $author = 'Unknown' }
    return $author
}

function Convert-TemplateContent {
    <#
    .SYNOPSIS
    Replaces placeholders in template content with actual values.

    .DESCRIPTION
    This is a pure string transformation function that does not modify system state.
    It replaces frontmatter and body placeholders in the provided content.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string] $Content,
        [Parameter(Mandatory = $true)]
        [string] $ShortName,
        [Parameter(Mandatory = $true)]
        [string] $Date,
        [Parameter(Mandatory = $true)]
        [string] $Author,
        [string] $LastUpdated,
        [string] $Status,
        [string] $StatusColor,
        [string] $Issue,
        [string] $Parent,
        [string] $Version
    )
    $updatedContent = $Content -replace '<feature-name>', $ShortName
    $updatedContent = $updatedContent -replace '- Author: name', "- Author: $Author"
    if ($Author) {
        $updatedContent = $updatedContent -replace '<name>', $Author
    }
    if ($LastUpdated) {
        $updatedContent = $updatedContent -replace '<yyyy-MM-ddTHH-mm>', $LastUpdated
    }
    $updatedContent = $updatedContent -replace '- Date captured: YYYY-MM-DD', "- Date captured: $Date"
    if ($Status) {
        $updatedContent = $updatedContent -replace '<status>', $Status
    }
    if ($StatusColor) {
        $updatedContent = $updatedContent -replace '<color>', $StatusColor
    }
    if ($Issue) {
        $updatedContent = $updatedContent -replace '<issue>', $Issue
    }
    if ($Parent) {
        $updatedContent = $updatedContent -replace '<parent-id>', $Parent
    }
    if ($Version) {
        $updatedContent = $updatedContent -replace '<version_number>', $Version
    }
    return $updatedContent
}

function Invoke-VSCodeOpen {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Files,
        [scriptblock] $GetCommand = { param([string]$Name) Get-Command $Name -ErrorAction SilentlyContinue },
        # DI seam: receives ($Exe, $CmdArgs); default invokes directly to support --reuse-window.
        [scriptblock] $InvokeCommand = { param([string]$Exe, [string[]]$CmdArgs) & $Exe @CmdArgs }
    )

    # Detect Insiders using multiple signals; TERM_PROGRAM_VERSION alone is
    # unreliable when VS Code spawns external processes (e.g., extension host or task runners).
    $isInsidersSession = $env:TERM_PROGRAM_VERSION -match 'insider' -or
        (-not [string]::IsNullOrEmpty($env:VSCODE_IPC_HOOK_CLI) -and $env:VSCODE_IPC_HOOK_CLI -match 'insider') -or
        ($null -ne (Get-Process -Name '*insiders*' -ErrorAction SilentlyContinue | Select-Object -First 1))

    $hasMatchingCommand = {
        param(
            $CommandInfo,
            [string] $ExpectedName
        )

        return $CommandInfo -and $CommandInfo.Name -eq $ExpectedName
    }

    if ($isInsidersSession) {
        $codeInsidersCmd = & $GetCommand 'code-insiders'
        if (& $hasMatchingCommand $codeInsidersCmd 'code-insiders') {
            & $InvokeCommand 'code-insiders' (@('--reuse-window') + $Files)
            return $true
        }
    }

    $codeCmd = & $GetCommand 'code'
    if (& $hasMatchingCommand $codeCmd 'code') {
        & $InvokeCommand 'code' (@('--reuse-window') + $Files)
        return $true
    }


    return $false
}

# Main script logic
if ([string]::IsNullOrWhiteSpace($ShortName)) {
    Write-Error 'Aborted: no name provided. (Pass -ShortName or use the VS Code task prompt.)'
    exit 1
}

if (-not (Test-ValidShortName -CandidateName $ShortName)) {
    Write-Error "Aborted: '$ShortName' is invalid. Use kebab-case letters/numbers only (e.g., notes-feature)."
    exit 1
}

$workspace = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$today = Get-Date -Format 'yyyy-MM-dd'
$lastUpdated = Get-Date -Format 'yyyy-MM-ddTHH-mm'
$target = Join-Path $workspace "docs/features/potential/$today-$ShortName.md"
if ($TemplateRoot -and (Test-Path (Join-Path $TemplateRoot 'potential/template.md'))) {
    $template = Join-Path $TemplateRoot 'potential/template.md'
} else {
    $template = Join-Path $workspace 'docs/features/potential/template.md'
}
if (-not (Test-Path $template)) {
    Write-Error "Template not found: $template"
    exit 1
}
$backlog = Join-Path $workspace 'docs/features/backlog.md'

$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}
Copy-Item $template $target -Force
Write-Output "Created: $target"

# Populate placeholders in the new file
$author = Get-AuthorName
$status = 'Draft'
$statusColor = 'lightgrey'
$issue = 'TBD'
$parent = 'none'
$version = '0.1'
$content = Get-Content -Raw -Path $target
$content = Convert-TemplateContent -Content $content -ShortName $ShortName -Date $today -Author $author -LastUpdated $lastUpdated -Status $status -StatusColor $statusColor -Issue $issue -Parent $parent -Version $version
Set-Content -Path $target -Value $content -Encoding UTF8

$opened = Invoke-VSCodeOpen -Files @($target, $backlog)
if (-not $opened) {
    Write-Warning "VS Code CLI command not found (expected 'code' or 'code-insiders'). Open files manually:"
    Write-Output "  $target"
    Write-Output "  $backlog"
}

