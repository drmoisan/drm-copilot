Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function global:Get-DrmCopilotNormalizedPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
}

function global:Test-DrmCopilotPathWithinRepo {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    if ($RelativePath -eq ".") {
        return $true
    }

    return -not (
        $RelativePath -eq ".." -or
        $RelativePath.StartsWith("..\", [System.StringComparison]::Ordinal) -or
        $RelativePath.StartsWith("../", [System.StringComparison]::Ordinal)
    )
}

function global:Get-DrmCopilotPromptPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootPath,

        [Parameter(Mandatory = $true)]
        [string]$LocationPath
    )

    $normalizedRepoRoot = Get-DrmCopilotNormalizedPath -Path $RepoRootPath
    $normalizedLocation = Get-DrmCopilotNormalizedPath -Path $LocationPath

    if ($normalizedLocation -eq $normalizedRepoRoot) {
        return "\"
    }

    $relativePath = [System.IO.Path]::GetRelativePath($normalizedRepoRoot, $normalizedLocation)
    if (-not (Test-DrmCopilotPathWithinRepo -RelativePath $relativePath)) {
        return $normalizedLocation
    }

    return "\" + $relativePath.Replace('/', '\')
}

function global:Get-DrmCopilotPromptText {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootPath,

        [Parameter(Mandatory = $true)]
        [string]$LocationPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$PromptName = "drm-copilot"
    )

    $promptPath = Get-DrmCopilotPromptPath -RepoRootPath $RepoRootPath -LocationPath $LocationPath
    return "($PromptName):$promptPath"
}

function global:Set-DrmCopilotPrompt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$PromptName = "drm-copilot",

        [Parameter()]
        [scriptblock]$GetLocationPath = { (Get-Location).Path }
    )

    $resolvedRepoRoot = Get-DrmCopilotNormalizedPath -Path $RepoRootPath
    $resolvedPromptName = $PromptName
    $resolvedGetLocationPath = $GetLocationPath.GetNewClosure()

    $promptScript = {
        $locationPath = & $resolvedGetLocationPath
        $promptText = Get-DrmCopilotPromptText `
            -RepoRootPath $resolvedRepoRoot `
            -LocationPath $locationPath `
            -PromptName $resolvedPromptName
        return "$promptText> "
    }.GetNewClosure()

    Set-Item -Path Function:\global:prompt -Value $promptScript
}

function global:Resolve-DrmCopilotActivationScriptPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootPath,

        [Parameter()]
        [string]$VirtualEnvironmentPath = (Join-Path -Path $RepoRootPath -ChildPath ".venv")
    )

    $activationScriptPath = Join-Path -Path $VirtualEnvironmentPath -ChildPath "Scripts\Activate.ps1"
    if (-not (Test-Path -LiteralPath $activationScriptPath)) {
        throw "Virtual environment activation script not found at $activationScriptPath"
    }

    return [System.IO.Path]::GetFullPath($activationScriptPath)
}

function global:Start-DrmCopilotPromptSession {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootPath,

        [Parameter()]
        [string]$VirtualEnvironmentPath = (Join-Path -Path $RepoRootPath -ChildPath ".venv"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$PromptName = "drm-copilot",

        [Parameter()]
        [scriptblock]$ActivateEnvironment = {
            param(
                [string]$ActivationScriptPath,
                [string]$ResolvedPromptName
            )

            & $ActivationScriptPath -Prompt $ResolvedPromptName
        },

        [Parameter()]
        [scriptblock]$GetLocationPath = { (Get-Location).Path },

        [Parameter()]
        [scriptblock]$ResolveActivationScriptPath = {
            param([string]$RepoRootPath, [string]$VirtualEnvironmentPath)
            Resolve-DrmCopilotActivationScriptPath `
                -RepoRootPath $RepoRootPath `
                -VirtualEnvironmentPath $VirtualEnvironmentPath
        }
    )

    $activationScriptPath = & $ResolveActivationScriptPath $RepoRootPath $VirtualEnvironmentPath

    & $ActivateEnvironment $activationScriptPath $PromptName
    Set-DrmCopilotPrompt -RepoRootPath $RepoRootPath -PromptName $PromptName -GetLocationPath $GetLocationPath
}
