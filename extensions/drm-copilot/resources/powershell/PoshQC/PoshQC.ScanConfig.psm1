<#
.SYNOPSIS
Resolves the persisted PoshQC test scan-folder configuration.
.DESCRIPTION
Reads and validates the repo-local scan configuration file (default
'config/poshqc-scan.json') and returns the validated, workspace-relative
folder list from 'test.scanFolders'. Returns an empty array when the file is
absent or when 'test.scanFolders' is absent or empty, so that an absent
configuration preserves the settings 'Run.Path' defaults downstream.

Validation is fail-fast and names the configuration file: malformed JSON, a
'version' value other than 1, blank entries, absolute-path entries, and
entries containing '..' segments are errors. Config-sourced folders that do
not exist are skipped with a logged warning; if a non-empty configuration
lists only folders that do not exist, the function fails fast with a clear
error. This function never weakens Resolve-PoshQCScanFolder; the throw-on-missing
behavior for explicitly supplied folders is unaffected because it is not used
on this path.
.PARAMETER Root
Workspace root the relative configuration path and folder entries resolve against.
.PARAMETER ConfigRelativePath
Workspace-relative path to the configuration file. Defaults to
'config/poshqc-scan.json'.
.PARAMETER TestPathExists
Injectable existence-check seam (config file and folder existence). Defaults to Test-Path.
.PARAMETER ReadContent
Injectable read seam returning the raw file text. Defaults to Get-Content -Raw.
.PARAMETER Logger
Injectable warning seam for skip-with-warning messages. Defaults to Write-Warning.
#>
function Get-PoshQCScanConfigFolder {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Root,
        [string] $ConfigRelativePath = 'config/poshqc-scan.json',
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path $Path },
        [scriptblock] $ReadContent = { param([string] $Path) Get-Content -Path $Path -Raw },
        [scriptblock] $Logger = { param([string] $Message) Write-Warning $Message }
    )

    $ErrorActionPreference = 'Stop'

    # Resolve the configuration path against the workspace root unless it is already absolute.
    $configPath = if ([IO.Path]::IsPathRooted($ConfigRelativePath)) {
        $ConfigRelativePath
    } else {
        Join-Path -Path $Root -ChildPath $ConfigRelativePath
    }

    # Absent configuration file means defaults apply (empty result, no error).
    if (-not (& $TestPathExists $configPath)) {
        return @()
    }

    $raw = & $ReadContent $configPath
    # Absent or whitespace-only content is treated the same as an absent file.
    if ([string]::IsNullOrWhiteSpace([string] $raw)) {
        return @()
    }

    try {
        $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "Invalid JSON in scan configuration '$ConfigRelativePath': $($_.Exception.Message)"
    }

    # StrictMode-safe property access: read properties through PSObject so a
    # missing property yields $null rather than a strict-mode failure.
    $versionProperty = $parsed.PSObject.Properties['version']
    if (-not $versionProperty -or $versionProperty.Value -ne 1) {
        throw "Scan configuration '$ConfigRelativePath' must declare 'version' equal to 1."
    }

    # Absent 'test' section, or absent/empty 'test.scanFolders', means defaults apply.
    $testProperty = $parsed.PSObject.Properties['test']
    if (-not $testProperty -or $null -eq $testProperty.Value) {
        return @()
    }
    $scanFoldersProperty = $testProperty.Value.PSObject.Properties['scanFolders']
    if (-not $scanFoldersProperty -or $null -eq $scanFoldersProperty.Value) {
        return @()
    }
    $scanFolders = @($scanFoldersProperty.Value)
    if ($scanFolders.Count -eq 0) {
        return @()
    }

    # Validate every entry; each failure is fail-fast and names the configuration file.
    $validated = foreach ($folder in $scanFolders) {
        $folderText = [string] $folder
        if ([string]::IsNullOrWhiteSpace($folderText)) {
            throw "Scan configuration '$ConfigRelativePath' contains a blank 'test.scanFolders' entry."
        }
        if ([IO.Path]::IsPathRooted($folderText)) {
            throw "Scan configuration '$ConfigRelativePath' entry '$folderText' must be a workspace-relative path, not an absolute path."
        }
        # Reject parent-directory traversal in any path segment.
        $segments = $folderText -split '[\\/]+'
        if ($segments -contains '..') {
            throw "Scan configuration '$ConfigRelativePath' entry '$folderText' must not contain '..' segments."
        }
        $folderText
    }
    $validated = @($validated)

    # Filter out config-sourced folders that do not exist, skipping each with a warning.
    $existing = foreach ($folder in $validated) {
        $candidate = Join-Path -Path $Root -ChildPath $folder
        if (& $TestPathExists $candidate) {
            $folder
        } else {
            & $Logger "Scan configuration '$ConfigRelativePath' folder '$folder' does not exist under root '$Root'; skipping."
        }
    }
    $existing = @($existing)

    # A non-empty configuration whose folders were all filtered out is a hard error.
    if ($existing.Count -eq 0) {
        throw "Scan configuration '$ConfigRelativePath' lists only folders that do not exist under root '$Root'."
    }

    return @($existing)
}
