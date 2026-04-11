function ConvertTo-PoshQCPath {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Path
    }

    if ($Path -match '^[A-Za-z]:[\\/]+$') {
        return $Path.Substring(0, 3)
    }

    return $Path -replace '[\\/]+$', ''
}

<#
.SYNOPSIS
Enumerates PowerShell files in a given root directory.
.DESCRIPTION
Returns all PowerShell (.ps1/.psm1/.psd1) files recursively, excluding specified directories.
.PARAMETER ScanFolders
Optional workspace-relative or workspace-contained folders to scan instead of the entire root.
#>
function Get-PoshQCFileList {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Root,
        [string[]] $ScanFolders,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [scriptblock] $ResolvePath = { param([string] $Path) Resolve-Path -Path $Path -ErrorAction Stop },
        [scriptblock] $EnumerateFiles = { param([string] $Path) Get-ChildItem -Path $Path -Recurse },
        [scriptblock] $ShouldExclude = {
            param($File, [string[]] $ExcludedDirs)
            $parts = $File.FullName -split '[\\/]+' | Where-Object { $_ -ne '' }
            foreach ($dir in $ExcludedDirs) {
                if ($parts -contains $dir) { return $true }
            }
            return $false
        },
        [scriptblock] $IsAllowedExtension = {
            param($File)
            $File.Extension -in '.ps1', '.psm1', '.psd1'
        },
        [scriptblock] $ResolveScanFolders = {
            param([string] $ResolvedRoot, [string[]] $Folders, [scriptblock] $ResolvePathFn)
            Resolve-PoshQCScanFolder -Root $ResolvedRoot -ScanFolders $Folders -ResolvePath $ResolvePathFn
        }
    )

    try {
        $resolvedRoot = & $ResolvePath $Root
        if ($resolvedRoot -isnot [string]) {
            $resolvedRoot = $resolvedRoot.Path
        }
    } catch {
        throw "Failed to resolve root path '$Root': $($_.Exception.Message)"
    }

    $scanRoots = if ($ScanFolders -and $ScanFolders.Count -gt 0) {
        @(& $ResolveScanFolders $resolvedRoot $ScanFolders $ResolvePath)
    } else {
        @($resolvedRoot)
    }

    $files = foreach ($scanRoot in $scanRoots) {
        @(& $EnumerateFiles $scanRoot)
    }
    if (-not $files) { return @() }

    $result = foreach ($file in $files) {
        if (-not (& $IsAllowedExtension $file)) { continue }
        if (& $ShouldExclude $file $ExcludeDirs) { continue }
        $file
    }

    return @($result | Sort-Object -Property FullName -Stable)
}

<#
.SYNOPSIS
Resolves workspace-relative scan folders and validates they stay inside Root.
.DESCRIPTION
Returns absolute scan-folder paths rooted under Root. Absolute inputs are accepted only when they still resolve inside Root.
#>
function Resolve-PoshQCScanFolder {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Root,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]] $ScanFolders,
        [scriptblock] $ResolvePath = { param([string] $Path) (Resolve-Path -Path $Path -ErrorAction Stop).Path }
    )

    # Use $null check instead of -not to avoid treating @('') as empty.
    if ($null -eq $ScanFolders -or $ScanFolders.Count -eq 0) {
        return @()
    }

    try {
        $resolvedRoot = & $ResolvePath $Root
        if ($resolvedRoot -isnot [string]) {
            $resolvedRoot = $resolvedRoot.Path
        }
    } catch {
        throw "Failed to resolve root path '$Root': $($_.Exception.Message)"
    }

    $normalizedRoot = (ConvertTo-PoshQCPath $resolvedRoot) -replace '\\', '/'
    $resolvedFolders = foreach ($folder in $ScanFolders) {
        if ([string]::IsNullOrWhiteSpace($folder)) {
            throw "Scan folder values must not be blank."
        }

        $candidate = if ([IO.Path]::IsPathRooted($folder)) { $folder } else { Join-Path -Path $resolvedRoot -ChildPath $folder }

        try {
            $resolvedFolder = & $ResolvePath $candidate
            if ($resolvedFolder -isnot [string]) {
                $resolvedFolder = $resolvedFolder.Path
            }
        } catch {
            throw "Failed to resolve scan folder '$folder': $($_.Exception.Message)"
        }

        $normalizedFolder = (ConvertTo-PoshQCPath $resolvedFolder) -replace '\\', '/'
        if (($normalizedFolder -ne $normalizedRoot) -and (-not $normalizedFolder.StartsWith("$normalizedRoot/"))) {
            throw "Scan folder '$folder' must resolve inside root '$Root'."
        }

        $resolvedFolder
    }

    return @($resolvedFolders | Sort-Object -Unique)
}
