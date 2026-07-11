<#
.SYNOPSIS
Formats PowerShell files using PSScriptAnalyzer.
.DESCRIPTION
Applies PSScriptAnalyzer formatting rules from repo settings to all PowerShell files under Root.
.PARAMETER Root
Root directory to search for PowerShell files. Defaults to current location.
.PARAMETER SettingsPath
Path to PSScriptAnalyzer settings file.
.PARAMETER ExcludeDirs
Directory names to exclude from processing.
.PARAMETER ScanFolders
Optional workspace-relative or workspace-contained folders to scan instead of the entire root.
#>
function Invoke-PoshQCFormat {
    [CmdletBinding()]
    param(
        [string] $Root,
        [string[]] $ScanFolders,
        [string] $SettingsPath = $script:PssaSettings,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [scriptblock] $EnsureModule = {
            param([string] $Name, [string] $ErrorMessage)
            if (-not (Get-Module -ListAvailable -Name $Name)) { throw $ErrorMessage }
            Import-Module $Name -ErrorAction Stop
        },
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path $Path },
        [scriptblock] $GetFileList = { param([string] $RootPath, [string[]] $ScanFoldersPath, [string[]] $Excluded) Get-PoshQCFileList -Root $RootPath -ScanFolders $ScanFoldersPath -ExcludeDirs $Excluded },
        [scriptblock] $ReadFile = { param([string] $Path) Get-Content -Raw -Path $Path },
        [scriptblock] $WriteFile = { param([string] $Path, [string] $Content) Set-Content -Path $Path -Value $Content -Encoding UTF8 -NoNewline },
        [scriptblock] $FormatContent = { param([string] $Content, [string] $Settings) Invoke-Formatter -ScriptDefinition $Content -Settings $Settings },
        [scriptblock] $Logger = {
            param([string] $Message)
            Write-Information $Message -InformationAction Continue
        }
    )

    $ErrorActionPreference = 'Stop'

    if (-not $Root) {
        $Root = $PWD.ProviderPath
    }

    & $EnsureModule 'PSScriptAnalyzer' "PSScriptAnalyzer is not installed. Run Install-PoshQCTool (alias Install-PoshQCTools) first."

    if (-not (& $TestPathExists $SettingsPath)) {
        throw "Settings not found: $SettingsPath"
    }

    $files = @(& $GetFileList $Root $ScanFolders $ExcludeDirs)
    if (-not $files) {
        & $Logger "No PowerShell files found under $Root"
        return
    }

    foreach ($file in $files) {
        $original = & $ReadFile $file.FullName
        $normalized = $original -replace "`r?`n", "`n"
        $formatted = & $FormatContent $normalized $SettingsPath
        if ($formatted -ne $normalized) {
            & $WriteFile $file.FullName $formatted
            & $Logger "Formatted: $($file.FullName)"
        } else {
            & $Logger "Already formatted: $($file.FullName)"
        }
    }
}

<#
.SYNOPSIS
Runs PSScriptAnalyzer static analysis on PowerShell files.
.DESCRIPTION
Analyzes all PowerShell files under Root using repo PSScriptAnalyzer settings and reports issues.
.PARAMETER Root
Root directory to search for PowerShell files. Defaults to current location.
.PARAMETER SettingsPath
Path to PSScriptAnalyzer settings file.
.PARAMETER ExcludeDirs
Directory names to exclude from analysis.
.PARAMETER ScanFolders
Optional workspace-relative or workspace-contained folders to scan instead of the entire root.
#>
function Invoke-PoshQCAnalyze {
    [CmdletBinding()]
    param(
        [string] $Root,
        [string[]] $ScanFolders,
        [string] $SettingsPath = $script:PssaSettings,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [int] $NullReferenceRetryCount = 4,
        [int] $NullReferenceInitialDelayMilliseconds = 200,
        [scriptblock] $EnsureModule = {
            param([string] $Name, [string] $ErrorMessage)
            if (-not (Get-Module -ListAvailable -Name $Name)) { throw $ErrorMessage }
            Import-Module $Name -ErrorAction Stop
        },
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path $Path },
        [scriptblock] $GetFileList = { param([string] $RootPath, [string[]] $ScanFoldersPath, [string[]] $Excluded) Get-PoshQCFileList -Root $RootPath -ScanFolders $ScanFoldersPath -ExcludeDirs $Excluded },
        [scriptblock] $AnalyzeFile = {
            param([string] $Path, [string] $Settings)
            Invoke-ScriptAnalyzer -Path $Path -Settings $Settings -Severity Error, Warning, Information -ErrorAction Stop
        },
        [scriptblock] $ReloadAnalyzerModule = {
            # Retry path: ScriptAnalyzer has intermittent engine-level NullReferenceExceptions.
            # Re-importing the module can reset internal state without masking legitimate findings.
            try {
                Remove-Module -Name PSScriptAnalyzer -Force -ErrorAction SilentlyContinue
            } catch {
                # Best-effort reset; if removal fails we still attempt re-import.
                Write-Verbose "Remove-Module PSScriptAnalyzer failed during retry reset: $($_.Exception.Message)"
            }
            Import-Module -Name PSScriptAnalyzer -Force -ErrorAction Stop
        },
        [scriptblock] $Logger = {
            param([string] $Message)
            Write-Information $Message -InformationAction Continue
        }
    )

    $ErrorActionPreference = 'Stop'

    if (-not $Root) {
        $Root = $PWD.ProviderPath
    }

    & $EnsureModule 'PSScriptAnalyzer' "PSScriptAnalyzer is not installed. Run Install-PoshQCTool (alias Install-PoshQCTools) first."

    if (-not (& $TestPathExists $SettingsPath)) {
        throw "Settings not found: $SettingsPath"
    }

    $files = @(& $GetFileList $Root $ScanFolders $ExcludeDirs | Where-Object { $_.Extension -in '.ps1', '.psm1' })
    if (-not $files) {
        & $Logger "No PowerShell files found under $Root"
        return
    }

    $results = @()
    foreach ($file in $files) {
        try {
            $attempts = 0
            $maxAttempts = 1 + [math]::Max(0, $NullReferenceRetryCount)
            $delayMs = [math]::Max(0, $NullReferenceInitialDelayMilliseconds)

            while ($attempts -lt $maxAttempts) {
                $attempts++
                try {
                    $results += & $AnalyzeFile $file.FullName $SettingsPath
                    break
                } catch {
                    $errorType = $_.Exception.GetType().FullName
                    $errorMessage = $_.Exception.Message

                    if ($errorType -ne 'System.NullReferenceException') {
                        throw
                    }

                    if ($attempts -ge $maxAttempts) {
                        throw
                    }

                    $pssaVersion = (Get-Module -Name PSScriptAnalyzer | Select-Object -First 1).Version
                    & $Logger "Transient ScriptAnalyzer engine error (NullReferenceException) on $($file.FullName); retrying ($attempts/$maxAttempts). PSScriptAnalyzer=$pssaVersion PS=$($PSVersionTable.PSVersion)"

                    if ($delayMs -gt 0) {
                        Start-Sleep -Milliseconds $delayMs
                        $delayMs = [math]::Min($delayMs * 2, 5000)
                    }

                    # Best-effort reset between retries.
                    & $ReloadAnalyzerModule
                }
            }
        } catch {
            $errorType = $_.Exception.GetType().FullName
            $errorMessage = $_.Exception.Message
            throw "Invoke-ScriptAnalyzer failed for $($file.FullName) ($errorType): $errorMessage"
        }
    }

    if ($results.Count -gt 0) {
        $results | Format-Table -AutoSize
        throw "PSScriptAnalyzer reported $($results.Count) issue(s)."
    }
    & $Logger "PSScriptAnalyzer passed: no findings under $Root"
}

<#
.SYNOPSIS
Applies PSScriptAnalyzer autofixes, then reruns analysis.
.DESCRIPTION
Uses the repo PSScriptAnalyzer settings to apply `-Fix` to each discovered PowerShell file, then invokes
the standard analysis pass and fails if findings remain.
.PARAMETER Root
Root directory to search for PowerShell files. Defaults to current location.
.PARAMETER ScanFolders
Optional workspace-relative or workspace-contained folders to scan instead of the entire root.
.PARAMETER SettingsPath
Path to PSScriptAnalyzer settings file.
.PARAMETER ExcludeDirs
Directory names to exclude from analysis.
#>
function Invoke-PoshQCAnalyzeAutofix {
    [CmdletBinding()]
    param(
        [string] $Root,
        [string[]] $ScanFolders,
        [string] $SettingsPath = $script:PssaSettings,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [scriptblock] $EnsureModule = {
            param([string] $Name, [string] $ErrorMessage)
            if (-not (Get-Module -ListAvailable -Name $Name)) { throw $ErrorMessage }
            Import-Module $Name -ErrorAction Stop
        },
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path $Path },
        [scriptblock] $GetFileList = { param([string] $RootPath, [string[]] $ScanFoldersPath, [string[]] $Excluded) Get-PoshQCFileList -Root $RootPath -ScanFolders $ScanFoldersPath -ExcludeDirs $Excluded },
        [scriptblock] $FixFile = {
            param([string] $Path, [string] $Settings)
            Invoke-ScriptAnalyzer -Path $Path -Settings $Settings -Severity Error, Warning, Information -Fix -ErrorAction Stop | Out-Null
        },
        [scriptblock] $InvokeAnalyze = {
            param([string] $RootPath, [string[]] $ScanFoldersPath, [string] $AnalyzeSettingsPath, [string[]] $Excluded)
            Invoke-PoshQCAnalyze -Root $RootPath -ScanFolders $ScanFoldersPath -SettingsPath $AnalyzeSettingsPath -ExcludeDirs $Excluded
        },
        [scriptblock] $Logger = {
            param([string] $Message)
            Write-Information $Message -InformationAction Continue
        }
    )

    $ErrorActionPreference = 'Stop'

    if (-not $Root) {
        $Root = $PWD.ProviderPath
    }

    & $EnsureModule 'PSScriptAnalyzer' "PSScriptAnalyzer is not installed. Run Install-PoshQCTool (alias Install-PoshQCTools) first."

    if (-not (& $TestPathExists $SettingsPath)) {
        throw "Settings not found: $SettingsPath"
    }

    $files = @(& $GetFileList $Root $ScanFolders $ExcludeDirs | Where-Object { $_.Extension -in '.ps1', '.psm1' })
    if (-not $files) {
        & $Logger "No PowerShell files found under $Root"
    } else {
        foreach ($file in $files) {
            & $FixFile $file.FullName $SettingsPath
            & $Logger "Autofixed: $($file.FullName)"
        }
    }

    & $InvokeAnalyze $Root $ScanFolders $SettingsPath $ExcludeDirs
}
