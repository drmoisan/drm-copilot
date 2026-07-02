[CmdletBinding()]
param(
    [string]$SourceRoot = "",
    [string]$WorktreeRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-NormalizedRootPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return $Path.Replace('\', '/').TrimEnd('/')
}

function Get-RelativeCustomizationPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceFolder,

        [Parameter(Mandatory = $true)]
        [string]$SourcePath
    )

    $normalizedSourceFolder = ConvertTo-NormalizedRootPath -Path $SourceFolder
    $normalizedSourcePath = $SourcePath.Replace('\', '/')
    return $normalizedSourcePath.Substring($normalizedSourceFolder.Length).TrimStart('/')
}

function Get-CodexCustomizationCopyPlan {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,

        [Parameter(Mandatory = $true)]
        [string]$WorktreeRoot,

        [scriptblock]$TestPath = {
            param([string]$LiteralPath)
            Test-Path -LiteralPath $LiteralPath -PathType Container
        },

        [scriptblock]$GetChildItem = {
            param([string]$LiteralPath)
            Get-ChildItem -LiteralPath $LiteralPath -File -Recurse
        }
    )

    $normalizedSourceRoot = ConvertTo-NormalizedRootPath -Path $SourceRoot
    $normalizedWorktreeRoot = ConvertTo-NormalizedRootPath -Path $WorktreeRoot
    if ($normalizedSourceRoot.Equals($normalizedWorktreeRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return
    }

    foreach ($customizationFolder in @('.codex', '.agents')) {
        $sourceFolder = "$normalizedSourceRoot/$customizationFolder"
        if (-not (& $TestPath -LiteralPath $sourceFolder)) {
            continue
        }

        foreach ($file in @(& $GetChildItem -LiteralPath $sourceFolder)) {
            $fullNameProperty = $file.PSObject.Properties['FullName']
            if ($null -eq $fullNameProperty) {
                throw "Customization file object is missing FullName."
            }

            $sourcePath = [string]$fullNameProperty.Value
            $relativePath = Get-RelativeCustomizationPath -SourceFolder $sourceFolder -SourcePath $sourcePath
            [pscustomobject]@{
                CustomizationFolder = $customizationFolder
                SourcePath          = $sourcePath.Replace('\', '/')
                DestinationPath     = "$normalizedWorktreeRoot/$customizationFolder/$relativePath"
            }
        }
    }
}

function Invoke-CodexCustomizationCopyPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$CopyOperation,

        [scriptblock]$NewDirectory = {
            param([string]$LiteralPath)
            New-Item -ItemType Directory -Force -Path $LiteralPath | Out-Null
        },

        [scriptblock]$CopyFile = {
            param(
                [string]$SourcePath,
                [string]$DestinationPath
            )
            Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
        }
    )

    foreach ($operation in $CopyOperation) {
        $destinationDirectory = Split-Path -Parent $operation.DestinationPath
        & $NewDirectory -LiteralPath $destinationDirectory
        & $CopyFile -SourcePath $operation.SourcePath -DestinationPath $operation.DestinationPath
    }
}

$effectiveSourceRoot = if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath "../..")).Path
}
else {
    $SourceRoot
}

$effectiveWorktreeRoot = if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) {
    (Get-Location).Path
}
else {
    $WorktreeRoot
}

$copyOperations = @(
    Get-CodexCustomizationCopyPlan -SourceRoot $effectiveSourceRoot -WorktreeRoot $effectiveWorktreeRoot
)
Invoke-CodexCustomizationCopyPlan -CopyOperation $copyOperations

