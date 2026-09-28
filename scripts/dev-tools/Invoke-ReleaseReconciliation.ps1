<#
.SYNOPSIS
    Reconcile the set of pushed mcp-server release tags against the set of
    versions actually published to the npm registry.

.DESCRIPTION
    Layer C of the missed-npm-publish defence (issue #526). Layers A and B only
    look at a release while someone is running it. This layer is retroactive: it
    surfaces a tag whose version was never published even though nobody ran a
    release to look for it, including a gap that predates the defence.

    The comparison itself is the pure function Get-UnpublishedTagVersion, which
    is a set difference over two string collections and performs no external
    call. Keeping it in a script rather than inline in workflow YAML is what
    makes it unit-testable offline with no network, no process, and no clock.

    Collecting the two sets is the caller's job. The scheduled workflow
    .github/workflows/verify-published-releases.yml gathers them and passes them
    in, so this file contains no registry or git access of its own.

    The entry-point block at the bottom is skipped when the file is dot-sourced.

.PARAMETER TagVersionList
    Version strings taken from the pushed release tags, with the tag prefix
    already stripped, for example '1.1.0'.

.PARAMETER PublishedVersionList
    Version strings the registry reports as published for the package.

.EXAMPLE
    pwsh ./scripts/dev-tools/Invoke-ReleaseReconciliation.ps1 -TagVersionList 1.1.0,1.1.1 -PublishedVersionList 1.1.0
#>

[CmdletBinding()]
param(
    [string[]]$TagVersionList = @(),
    [string[]]$PublishedVersionList = @()
)

Set-StrictMode -Version Latest

function Get-UnpublishedTagVersion {
    <#
    .SYNOPSIS
        Return the versions present in the tag set and absent from the published set.

    .DESCRIPTION
        A pure set difference. It makes no external call, reads no file, and
        consults no clock, so it is fully unit-testable offline. Blank entries
        are ignored, surrounding whitespace is trimmed before comparison,
        comparison is case-insensitive, duplicates in the tag set collapse to a
        single result entry, and the tag set's ordering is preserved so the
        output is deterministic.

    .PARAMETER TagVersion
        Version strings taken from the pushed release tags.

    .PARAMETER PublishedVersion
        Version strings the registry reports as published.

    .OUTPUTS
        [string[]]. Empty when every tag version is published.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$TagVersion,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$PublishedVersion
    )

    $published = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    if ($null -ne $PublishedVersion) {
        foreach ($candidate in $PublishedVersion) {
            if (-not [string]::IsNullOrWhiteSpace($candidate)) {
                $null = $published.Add($candidate.Trim())
            }
        }
    }

    $unpublished = [System.Collections.Generic.List[string]]::new()
    $alreadyReported = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    if ($null -ne $TagVersion) {
        foreach ($candidate in $TagVersion) {
            if ([string]::IsNullOrWhiteSpace($candidate)) {
                continue
            }

            $normalized = $candidate.Trim()
            if ($published.Contains($normalized)) {
                continue
            }

            if ($alreadyReported.Add($normalized)) {
                $unpublished.Add($normalized)
            }
        }
    }

    # Emitted as a plain collection, so a caller wrapping the call in @() receives an
    # array of the divergent versions and an empty array when there is no divergence.
    return ([string[]]$unpublished.ToArray())
}

function Get-ReconciliationReport {
    <#
    .SYNOPSIS
        Turn the two version sets into the reported message and the process exit code.

    .DESCRIPTION
        Pure, like Get-UnpublishedTagVersion. It exists so that the entry-point block
        below is nothing but wiring: policy in .claude/rules/general-code-change.md
        requires all logic to live in host-neutral testable code with only the
        thinnest possible wiring left in the host-bound entry point.

    .PARAMETER TagVersion
        Version strings taken from the pushed release tags.

    .PARAMETER PublishedVersion
        Version strings the registry reports as published.

    .OUTPUTS
        [pscustomobject] with UnpublishedVersion, Message, and ExitCode.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$TagVersion,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$PublishedVersion
    )

    $divergence = @(Get-UnpublishedTagVersion -TagVersion $TagVersion -PublishedVersion $PublishedVersion)
    $isDivergent = $divergence.Count -gt 0
    $reported = if ($isDivergent) { $divergence -join ', ' } else { 'none' }

    return [pscustomobject]@{
        UnpublishedVersion = $divergence
        Message            = "UNPUBLISHED_TAG_VERSIONS: $reported"
        ExitCode           = [int]$isDivergent
    }
}

# Entry point: skipped when the script is dot-sourced for testing or for reuse by a
# sibling release script. Wiring only; every decision above is a pure function.
if ($MyInvocation.InvocationName -ne '.') {
    $report = Get-ReconciliationReport -TagVersion $TagVersionList -PublishedVersion $PublishedVersionList
    Write-Output $report.Message
    exit $report.ExitCode
}
