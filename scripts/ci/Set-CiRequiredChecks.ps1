<#
.SYNOPSIS
Create the CI Required Gate ruleset on the default branch of this repository (opt-in, issue #1050).

.DESCRIPTION
The drm-copilot push-down delivers this command with the destination CI files and never runs it.
The default run is a dry run: it reads the required context from the data file beside this script
(ci-required-checks.json), prints the ruleset body it would create, and makes no change. With -Apply
it creates one new ruleset on the default branch through one `gh api --method POST
repos/<owner>/<repo>/rulesets` call. It never edits or deletes an existing ruleset: when a ruleset
with the same name exists, it reports that and makes no change. -WhatIf makes no change.

.PARAMETER Apply
Create the ruleset. Without it the command prints the planned body only.

.PARAMETER DataFilePath
Path of the CI data file. Defaults to ci-required-checks.json beside this script.

.PARAMETER Repository
Repository in owner/name form. Defaults to the repository that `gh repo view` reports.

.PARAMETER RulesetName
Name of the ruleset to create.

.EXAMPLE
pwsh -NoProfile -File .github/drm-copilot/Set-CiRequiredChecks.ps1

.EXAMPLE
pwsh -NoProfile -File .github/drm-copilot/Set-CiRequiredChecks.ps1 -Apply
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch] $Apply,
    [string] $DataFilePath = (Join-Path -Path $PSScriptRoot -ChildPath 'ci-required-checks.json'),
    [string] $Repository = '',
    [string] $RulesetName = 'drm-copilot CI Required Gate'
)

function Invoke-GhExe {
    <#
    .SYNOPSIS
    Run gh with the given arguments and optional standard input; return the exit code and output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $GhArgs,

        [string] $InputText = ''
    )

    if ($InputText -ne '') {
        $output = $InputText | & gh @GhArgs 2>&1
    } else {
        $output = & gh @GhArgs 2>&1
    }
    return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = (@($output) -join "`n") }
}

function Get-CiRequiredChecksDataText {
    <#
    .SYNOPSIS
    Read the CI data file text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "CI data file not found: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
}

function New-CiRequiredChecksRulesetBody {
    <#
    .SYNOPSIS
    Build the ruleset body (JSON text) that requires the contexts named by the CI data file.
    #>
    # The name is fixed by the issue #1050 plan; the function builds text in memory and changes no state.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the name is fixed by the issue #1050 plan.')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $DataText,

        [Parameter(Mandatory = $true)]
        [string] $RulesetName
    )

    try {
        $data = $DataText | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "CI data file is malformed: $($_.Exception.Message)"
    }
    if ($null -eq $data -or $data -isnot [pscustomobject] -or $null -eq $data.PSObject.Properties['required_contexts']) {
        throw 'CI data file is malformed: required_contexts is missing.'
    }
    $contexts = @($data.required_contexts)
    if ($contexts.Count -eq 0 -or @($contexts | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
        throw 'CI data file is malformed: required_contexts must be a non-empty list of names.'
    }

    $body = [ordered]@{
        name        = $RulesetName
        target      = 'branch'
        enforcement = 'active'
        conditions  = [ordered]@{
            ref_name = [ordered]@{ include = @('~DEFAULT_BRANCH'); exclude = @() }
        }
        rules       = @(
            [ordered]@{
                type       = 'required_status_checks'
                parameters = [ordered]@{
                    strict_required_status_checks_policy = $false
                    required_status_checks               = @($contexts | ForEach-Object { [ordered]@{ context = $_ } })
                }
            }
        )
    }
    return ConvertTo-Json -InputObject $body -Depth 10
}

function Invoke-SetCiRequiredChecks {
    <#
    .SYNOPSIS
    Print the planned ruleset and, with -Apply, create it unless a ruleset of the same name exists.
    #>
    # The plural noun matches the command name Set-CiRequiredChecks fixed by the issue #1050 spec.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The name is fixed by the issue #1050 plan and mirrors the command Set-CiRequiredChecks.')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [switch] $Apply,
        [Parameter(Mandatory = $true)]
        [string] $DataFilePath,
        [string] $Repository = '',
        [string] $RulesetName = 'drm-copilot CI Required Gate'
    )

    $body = New-CiRequiredChecksRulesetBody -DataText (Get-CiRequiredChecksDataText -Path $DataFilePath) -RulesetName $RulesetName
    Write-Output "Planned ruleset '$RulesetName':"
    Write-Output $body
    if (-not $Apply) {
        Write-Output 'Dry run: no ruleset was created. Re-run with -Apply to create it.'
        return
    }

    $repo = $Repository
    if ([string]::IsNullOrWhiteSpace($repo)) {
        $view = Invoke-GhExe -GhArgs @('repo', 'view', '--json', 'nameWithOwner', '--jq', '.nameWithOwner')
        if ($view.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($view.Output)) {
            throw "Could not resolve the repository with gh repo view: $($view.Output)"
        }
        $repo = $view.Output.Trim()
    }

    $list = Invoke-GhExe -GhArgs @('api', "repos/$repo/rulesets")
    if ($list.ExitCode -ne 0) {
        throw "Could not list the rulesets of ${repo}: $($list.Output)"
    }
    $existing = @(($list.Output | ConvertFrom-Json -ErrorAction Stop) | Where-Object { $_.name -ceq $RulesetName })
    if ($existing.Count -gt 0) {
        Write-Output "Ruleset '$RulesetName' already exists in $repo (id $($existing[0].id)); no change was made."
        return
    }

    if ($PSCmdlet.ShouldProcess("repos/$repo/rulesets", "Create ruleset '$RulesetName'")) {
        $created = Invoke-GhExe -GhArgs @('api', '--method', 'POST', "repos/$repo/rulesets", '--input', '-') -InputText $body
        if ($created.ExitCode -ne 0) {
            throw "Creating the ruleset failed: $($created.Output)"
        }
        Write-Output "Created ruleset '$RulesetName' in $repo."
    }
}

# Dot-sourcing (the unit tests) defines the functions only; a direct run executes the command.
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-SetCiRequiredChecks -Apply:$Apply -DataFilePath $DataFilePath -Repository $Repository -RulesetName $RulesetName
}
