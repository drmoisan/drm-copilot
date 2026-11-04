<#
.SYNOPSIS
    Print the TL;DR block and the hourly progress report of an epic.

.DESCRIPTION
    Reads the epic kickoff and the feature plans from the integration branch (or from a
    feature worktree when one holds the plan), the epic orchestrator checkpoint, the pull
    request state of each feature branch, and the weekly quota of the active cswap
    account, then prints the task progress, the per-feature state, the average and
    recent velocity, the sample standard deviation, the estimated time remaining, and the
    weekly quota.

    The pure logic lives in Get-EpicProgressReport.Logic.ps1, which this script
    dot-sources. Every I/O call goes through a wrapper function in this script. When gh
    or cswap is not installed, or prints no parseable output, the report still prints:
    the pull-request state is empty and the quota is n/a.

    A check-in sample (Unix time and done count) is kept in the state file at -StatePath
    when the previous sample is at least 90 seconds old; the recent velocity and its
    standard deviation are computed from those samples.

    The entry-point block at the bottom is skipped when the file is dot-sourced.

.PARAMETER EpicFolder
    Mandatory. The epic folder name under docs/features/epics/. It is also the epic name
    printed in the status heading.

.PARAMETER StartUtc
    Mandatory. The instant from which elapsed time and average velocity are measured;
    converted to UTC.

.PARAMETER EpicIssue
    The epic issue number printed in the report. Default: the number on the first
    'Epic issue: #<n>' line of the kickoff file. The script stops with an error when
    neither this parameter nor the kickoff yields a number.

.PARAMETER IntegrationBranch
    The branch that holds the kickoff and the plans. Default:
    origin/epic/<EpicFolder>-integration.

.PARAMETER KickoffPath
    The repository-relative path of the kickoff file on the integration branch. Default:
    docs/features/epics/<EpicFolder>/epic-kickoff.md.

.PARAMETER RepositoryRoot
    The repository root in which git runs. Default: the current location.

.PARAMETER CheckpointPath
    The epic orchestrator checkpoint. Default:
    artifacts/orchestration/epic-orchestrator-state.json under the repository root.

.PARAMETER StatePath
    The state file that keeps the check-in samples. Default:
    epic-progress-<EpicFolder>.json under the system temporary directory, never inside the
    repository.

.PARAMETER BaselineDone
    The number of tasks already complete at -StartUtc. Default: 0.

.PARAMETER BaselineWeeklyPct
    The weekly quota percentage at -StartUtc. Default: 0.

.PARAMETER WaveOverheadHours
    The review and CI hours added per open wave in the wave-parallel estimate.
    Default: 1.25.

.PARAMETER SampleCap
    The maximum number of check-in samples kept in the state file. Default: 14.

.PARAMETER Mode
    TLDR prints the four-line TL;DR block only; Full prints the TL;DR block followed by
    the full report. Default: Full.

.EXAMPLE
    pwsh -NoProfile -File scripts/dev-tools/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -Mode TLDR

    Prints the TL;DR block for the epic in docs/features/epics/example-epic/, measuring
    from 09:00 UTC with no baseline tasks.

.EXAMPLE
    pwsh -NoProfile -File scripts/dev-tools/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -BaselineDone 40 -EpicIssue 12

    Prints the full report for epic issue 12, counting 40 tasks as complete at the start.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $EpicFolder,

    [Parameter(Mandatory = $true)]
    [datetime] $StartUtc,

    [string] $EpicIssue = '',

    [string] $IntegrationBranch = '',

    [string] $KickoffPath = '',

    [string] $RepositoryRoot = '',

    [string] $CheckpointPath = '',

    [string] $StatePath = '',

    [int] $BaselineDone = 0,

    [double] $BaselineWeeklyPct = 0,

    [double] $WaveOverheadHours = 1.25,

    [ValidateRange(1, 100000)]
    [int] $SampleCap = 14,

    [ValidateSet('TLDR', 'Full')]
    [string] $Mode = 'Full'
)

. (Join-Path -Path $PSScriptRoot -ChildPath 'Get-EpicProgressReport.Logic.ps1')

function Resolve-EpicProgressSetting {
    <#
    .SYNOPSIS
        Apply the parameter defaults of the report; pure, with the temporary root and the current location passed in.
    .DESCRIPTION
        A blank value takes its default and an explicit value is kept. The kickoff path is a
        git object path with '/' separators; filesystem paths are built with Join-Path.
    .PARAMETER EpicFolder
        The epic folder name.
    .PARAMETER EpicIssue
        The explicit epic issue number, or blank.
    .PARAMETER IntegrationBranch
        The explicit integration branch, or blank.
    .PARAMETER KickoffPath
        The explicit kickoff path, or blank.
    .PARAMETER RepositoryRoot
        The explicit repository root, or blank.
    .PARAMETER CheckpointPath
        The explicit checkpoint path, or blank.
    .PARAMETER StatePath
        The explicit state file path, or blank.
    .PARAMETER TempRoot
        The system temporary directory.
    .PARAMETER CurrentLocation
        The current location.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $EpicFolder,
        [AllowEmptyString()] [string] $EpicIssue = '',
        [AllowEmptyString()] [string] $IntegrationBranch = '',
        [AllowEmptyString()] [string] $KickoffPath = '',
        [AllowEmptyString()] [string] $RepositoryRoot = '',
        [AllowEmptyString()] [string] $CheckpointPath = '',
        [AllowEmptyString()] [string] $StatePath = '',
        [Parameter(Mandatory = $true)] [string] $TempRoot,
        [Parameter(Mandatory = $true)] [string] $CurrentLocation
    )

    $root = $RepositoryRoot
    if ([string]::IsNullOrWhiteSpace($root)) { $root = $CurrentLocation }
    $branch = $IntegrationBranch
    if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "origin/epic/$EpicFolder-integration" }
    $kickoff = $KickoffPath
    if ([string]::IsNullOrWhiteSpace($kickoff)) { $kickoff = "docs/features/epics/$EpicFolder/epic-kickoff.md" }
    $checkpoint = $CheckpointPath
    if ([string]::IsNullOrWhiteSpace($checkpoint)) {
        $checkpoint = Join-Path -Path $root -ChildPath 'artifacts' -AdditionalChildPath 'orchestration', 'epic-orchestrator-state.json'
    }
    $state = $StatePath
    if ([string]::IsNullOrWhiteSpace($state)) { $state = Join-Path -Path $TempRoot -ChildPath "epic-progress-$EpicFolder.json" }

    return [pscustomobject]@{
        EpicIssue         = $EpicIssue
        IntegrationBranch = $branch
        KickoffPath       = $kickoff.Replace('\', '/')
        RepositoryRoot    = $root
        CheckpointPath    = $checkpoint
        StatePath         = $state
    }
}

function Invoke-GitExe {
    <#
    .SYNOPSIS
        Run git with the given arguments and return its standard output lines.
    .PARAMETER GitArgs
        The git arguments.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string[]] $GitArgs)

    & git @GitArgs 2>$null
}

function Invoke-GhExe {
    <#
    .SYNOPSIS
        Run gh with the given arguments and return its standard output lines.
    .PARAMETER GhArgs
        The gh arguments.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string[]] $GhArgs)

    & gh @GhArgs 2>$null
}

function Invoke-CswapExe {
    <#
    .SYNOPSIS
        Run cswap with the given arguments and return its standard output lines.
    .PARAMETER CswapArgs
        The cswap arguments.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string[]] $CswapArgs)

    & cswap @CswapArgs 2>$null
}

function Test-EpicProgressCommand {
    <#
    .SYNOPSIS
        Return whether an application of the given name is installed.
    .PARAMETER Name
        The application name.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [string] $Name)

    return [bool] (Get-Command -Name $Name -CommandType Application -ErrorAction SilentlyContinue)
}

function Test-EpicProgressPath {
    <#
    .SYNOPSIS
        Return whether a file exists at the given path; a blank path returns $false.
    .PARAMETER Path
        The file path.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    return Test-Path -LiteralPath $Path -PathType Leaf
}

function Read-EpicProgressFile {
    <#
    .SYNOPSIS
        Return the raw text of a file.
    .PARAMETER Path
        The file path.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    return Get-Content -LiteralPath $Path -Raw
}

function Write-EpicProgressState {
    <#
    .SYNOPSIS
        Write the state file content as UTF-8; the only file the report writes.
    .PARAMETER Path
        The state file path.
    .PARAMETER Content
        The JSON text to write.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Content
    )

    if ($PSCmdlet.ShouldProcess($Path, 'Write epic progress state')) { Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 }
}

function Get-EpicProgressUtcNow {
    <#
    .SYNOPSIS
        Return the current UTC instant.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param()

    return [datetime]::UtcNow
}
