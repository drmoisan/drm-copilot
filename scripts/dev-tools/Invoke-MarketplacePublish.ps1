<#
.SYNOPSIS
    Task wrapper that gates Marketplace publish behind an explicit confirmation.

.DESCRIPTION
    Invoked by the VS Code task "Publish: Marketplace VSIX (patch + tag)".
    Exits non-zero unless -ConfirmToken equals 'yes'. On confirmation, forwards
    to scripts/powershell/Publish-DrmCopilotExtension.ps1 with -Publish,
    -VersionBump patch, and -Tag.

    The wrapper exists so the task can use pwsh -File (no nested-quoting
    issues) instead of an inline -Command string. Internal logic is exposed
    as named functions to support Pester unit testing per repo policy.

.PARAMETER ConfirmToken
    Must be the literal string 'yes' for the publish to proceed. Any other
    value causes the wrapper to write an error and exit with code 2. Named
    -ConfirmToken (rather than -Confirm) to avoid collision with the
    PowerShell common parameter -Confirm.

.EXAMPLE
    pwsh ./scripts/dev-tools/Invoke-MarketplacePublish.ps1 -ConfirmToken yes
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConfirmToken
)

function Write-StderrLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    [Console]::Error.WriteLine($Message)
}

function Invoke-PublishScript {
    <#
    .SYNOPSIS
        Wrapper seam for invoking the underlying publish script. Exists so
        tests can mock the external call without executing the real publish.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )
    & $ScriptPath -Publish -VersionBump patch -Tag
    return $LASTEXITCODE
}

function Invoke-MarketplacePublishGuarded {
    <#
    .SYNOPSIS
        Validates the confirmation token and delegates to the publish script.
    .OUTPUTS
        Integer exit code: 0 on success, 1 on missing script, 2 on missing
        confirmation, or the publish script's own exit code on failure.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfirmToken,
        [Parameter(Mandatory = $true)]
        [string]$RepoRoot
    )

    if ($ConfirmToken -cne 'yes') {
        Write-StderrLine -Message "Marketplace publish not confirmed (got '$ConfirmToken'). Re-run the task and select 'yes' to proceed."
        return 2
    }

    $publishScript = Join-Path -Path $RepoRoot -ChildPath 'scripts/powershell/Publish-DrmCopilotExtension.ps1'
    if (-not (Test-Path -LiteralPath $publishScript)) {
        Write-StderrLine -Message "Publish script not found at '$publishScript'."
        return 1
    }

    return (Invoke-PublishScript -ScriptPath $publishScript)
}

# Entry point: skipped when the script is dot-sourced for testing.
if ($MyInvocation.InvocationName -ne '.') {
    $resolvedRepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $exitCode = Invoke-MarketplacePublishGuarded -ConfirmToken $ConfirmToken -RepoRoot $resolvedRepoRoot
    exit $exitCode
}
