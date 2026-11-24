<#
.SYNOPSIS
    Release merge leg of the epic merge gates (issue #1234).

.DESCRIPTION
    Dot-sourced, guarded, by .claude/hooks/enforce-epic-merge-gate.ps1 and
    .codex/hooks/enforce-epic-merge-gate.ps1; the two copies are byte-identical. Each gate calls
    Get-EpicMergeGateReleaseDecision in its explicit-number block after the docs-only branch declines
    and before the final deny, so the leg can only turn that deny into an allow, and appends its
    Suffix as the last term of the deny text. The leg admits a checkpoint-free
    gh pr merge <N> --merge (or --squash, or --rebase) --match-head-commit <sha> of a release pull
    request when the destination repository commits .claude/release-commit-allowance.json beneath
    the root R: the session root on Claude and the repository root on Codex.

    Evaluation order (the first failure decides and exactly one code is reported):
       1 PrNumber null or not positive, or R blank: decline with an empty suffix and no I/O;
       2 the allowance file is absent: decline with an empty suffix and no gh call;
         RELEASE_MERGE_CONFIG_INVALID       - read failure, parse failure, or a directory entry;
       3 RELEASE_MERGE_CHECKPOINT_PRESENT   - NoRecordingTarget is false;
       4 RELEASE_MERGE_COMMAND_NOT_MODELLED - Get-DocsOnlyMergeShapeViolation fails, or --admin;
       5 RELEASE_MERGE_MATCH_HEAD_MISSING   - --match-head-commit absent or not a lowercase
                                              40- or 64-character object id;
       6 RELEASE_MERGE_PR_UNRESOLVED        - one bounded gh pr view fails or returns an invalid
                                              field;
       7 RELEASE_MERGE_PR_NOT_OPEN          - state is not exactly OPEN;
       8 RELEASE_MERGE_CROSS_REPOSITORY     - isCrossRepository is true;
       9 RELEASE_MERGE_HEAD_MISMATCH        - headRefOid differs from --match-head-commit;
      10 RELEASE_MERGE_FILES_TRUNCATED      - changedFiles above 100 or unequal to the files count;
      11 RELEASE_MERGE_CHANGE_NOT_MODELLED  - a changeType outside ADDED, MODIFIED, CHANGED, and
                                              DELETED, or a blank path;
      12 RELEASE_MERGE_BRANCH_NOT_MATCHED, RELEASE_MERGE_EMPTY_DIFF, or
         RELEASE_MERGE_PATH_NOT_ALLOWED     - Get-ReleasePullRequestPathDecision on the head branch;
      13 RELEASE_MERGE_CI_UNREADABLE        - the run list for the head cannot be read;
      14 RELEASE_MERGE_CI_MISSING           - no run of the workflow named CI exists on the head;
      15 RELEASE_MERGE_CI_EVENT_NOT_ALLOWED - the newest CI run is not a pull_request run;
      16 RELEASE_MERGE_CI_NOT_GREEN         - the newest CI run is not completed with success.
    A failure at steps 2 to 16 returns the suffix ' (release merge not applied: <CODE>: <detail>)'.

.NOTES
    PowerShell 7+. Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors under
    extensions/drm-copilot/resources/. Never throws: an unexpected error declines with an empty
    Suffix and a Write-Debug record carrying EPIC_MERGE_GATE_RELEASE_LEG_ERROR, so the deny stands.
    Process calls: none for steps 1 to 5, one gh pr view for steps 6 to 12, and one gh run list for
    steps 13 to 16, each through the bounded Invoke-DocsOnlyGhExe; the leg never fetches and runs no
    git command. Call-time dependencies loaded by the gates: Get-DocsOnlyMergeShapeViolation and
    Invoke-DocsOnlyGhExe (hook-docs-only-diff.ps1), Test-CommandLineFlag and Get-CommandLineFlagValue
    (hook-command-invocation.ps1), and Get-EpicMergeGateChildCiRunList, Select-EpicMergeGateChildCiRun,
    Test-EpicMergeGateChildCiObjectId, and Get-EpicMergeGateChildCiProperty
    (enforce-epic-merge-gate-child-ci.ps1). The workflow name CI is a stated assumption shared with
    issue #1130. This hook file starts no interpreter process.

    A policy-level control, not a security control: whoever can commit the allowance file decides
    which paths may be merged without an orchestration checkpoint, and a successful CI run on the
    exact head is the remaining safeguard.
#>

try { . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-release.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-release.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-release-pull-request-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-release-pull-request-context.ps1' -ErrorRecord $_ }

function Get-EpicMergeGateReleaseNotAppliedResult {
    <#
    .SYNOPSIS
        Return a declined leg result whose Suffix names the code and the detail.
    .PARAMETER Code
        The RELEASE_MERGE_* code.
    .PARAMETER Detail
        The detail of the failure.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Allowed and Suffix.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)][string] $Code, [Parameter(Mandatory)][AllowEmptyString()][string] $Detail)

    return [ordered]@{ Allowed = $false; Suffix = " (release merge not applied: ${Code}: $Detail)" }
}

function Get-EpicMergeGateReleasePullRequest {
    <#
    .SYNOPSIS
        Return the parsed gh pr view result of a pull request, or $null on any failure (the gh seam).
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGhExe call, gh pr view <N> --json with the fields headRefName,
        baseRefName, headRefOid, state, isCrossRepository, changedFiles, and files. A non-zero exit and
        unparseable output return $null; any parsed value, including an array, is returned unchanged.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param([Parameter(Mandatory)][int] $PrNumber, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $pullRequest = ConvertFrom-Json -InputObject ([string]$lookup.Output) -NoEnumerate -ErrorAction Stop
    } catch {
        # Unreadable gh output is a lookup failure; the decision fails closed on $null.
        return $null
    }
    return , $pullRequest
}

function Get-EpicMergeGateReleasePullRequestViolation {
    <#
    .SYNOPSIS
        Return the step 6 failure detail of a parsed pull request, or $null when every field is valid.
    .PARAMETER PullRequest
        The value Get-EpicMergeGateReleasePullRequest returned.
    .PARAMETER PrNumber
        The pull request number, for the detail text.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] $PullRequest, [Parameter(Mandatory)][int] $PrNumber)

    if ($PullRequest -isnot [System.Management.Automation.PSCustomObject]) { return "gh pr view $PrNumber did not return a readable pull request object" }
    if (-not (Test-EpicMergeGateChildCiObjectId -Value (Get-EpicMergeGateChildCiProperty -InputObject $PullRequest -Name 'headRefOid'))) {
        return "the headRefOid of pull request $PrNumber is not a full lowercase object id"
    }
    foreach ($name in 'headRefName', 'baseRefName') {
        $value = Get-EpicMergeGateChildCiProperty -InputObject $PullRequest -Name $name
        if ($value -isnot [string] -or $value -cnotmatch '^[A-Za-z0-9][A-Za-z0-9._/-]*$' -or $value.Contains('..')) {
            return "the $name of pull request $PrNumber is not a conservative branch name"
        }
    }
    if ((Get-EpicMergeGateChildCiProperty -InputObject $PullRequest -Name 'isCrossRepository') -isnot [bool]) {
        return "the isCrossRepository field of pull request $PrNumber is not a JSON boolean"
    }
    $changedFiles = Get-EpicMergeGateChildCiProperty -InputObject $PullRequest -Name 'changedFiles'
    if (-not ($changedFiles -is [int] -or $changedFiles -is [long])) {
        return "the changedFiles field of pull request $PrNumber is not a JSON integer"
    }
    if ((Get-EpicMergeGateChildCiProperty -InputObject $PullRequest -Name 'files') -isnot [System.Array]) {
        return "the files field of pull request $PrNumber is not a JSON array"
    }
    return $null
}

function Get-EpicMergeGateReleaseChangedPath {
    <#
    .SYNOPSIS
        Return the changed paths of the files array for step 11, or the failure detail.
    .PARAMETER File
        The files array of the pull request.
    .PARAMETER PrNumber
        The pull request number, for the detail text.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Path and Detail.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $File, [Parameter(Mandatory)][int] $PrNumber)

    $paths = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in @($File)) {
        $changeType = [string](Get-EpicMergeGateChildCiProperty -InputObject $entry -Name 'changeType')
        if (@('ADDED', 'MODIFIED', 'CHANGED', 'DELETED') -cnotcontains $changeType) {
            return [ordered]@{ Path = $null; Detail = "a changed file of pull request $PrNumber has the change type '$changeType'; only ADDED, MODIFIED, CHANGED, and DELETED are modelled" }
        }
        $path = Get-EpicMergeGateChildCiProperty -InputObject $entry -Name 'path'
        if ($path -isnot [string] -or [string]::IsNullOrWhiteSpace($path)) {
            return [ordered]@{ Path = $null; Detail = "a changed file of pull request $PrNumber has a blank path" }
        }
        $paths.Add($path)
    }
    return [ordered]@{ Path = $paths.ToArray(); Detail = $null }
}

function Get-EpicMergeGateReleaseCiFailure {
    <#
    .SYNOPSIS
        Evaluate steps 13 to 16 for the head commit and return the failing code and detail, or $null.
    .PARAMETER HeadSha
        The verified live head commit.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Code and Detail, or $null.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)][string] $HeadSha, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $runs = Get-EpicMergeGateChildCiRunList -HeadSha $HeadSha -WorktreeRoot $WorktreeRoot
    if ($null -eq $runs) { return [ordered]@{ Code = 'RELEASE_MERGE_CI_UNREADABLE'; Detail = "the workflow runs for $HeadSha could not be listed" } }
    $run = Select-EpicMergeGateChildCiRun -Runs $runs -HeadSha $HeadSha
    if ($null -eq $run) { return [ordered]@{ Code = 'RELEASE_MERGE_CI_MISSING'; Detail = "no run of the workflow named CI exists on $HeadSha" } }
    $runEvent = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'event')
    if ($runEvent -cne 'pull_request') {
        return [ordered]@{ Code = 'RELEASE_MERGE_CI_EVENT_NOT_ALLOWED'; Detail = "the newest CI run on $HeadSha has event '$runEvent'; only pull_request is accepted" }
    }
    $status = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'status')
    $conclusion = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'conclusion')
    if ($status -cne 'completed' -or $conclusion -cne 'success') {
        return [ordered]@{ Code = 'RELEASE_MERGE_CI_NOT_GREEN'; Detail = "the newest CI run on $HeadSha has status '$status' and conclusion '$conclusion'" }
    }
    return $null
}

function Get-EpicMergeGateReleaseDecision {
    <#
    .SYNOPSIS
        Decide whether a checkpoint-free explicit-number merge is an admitted release merge (issue #1234).
    .DESCRIPTION
        Applies steps 1 to 16 of the file header in order. Returns Allowed and Suffix; the suffix is
        empty for an allow, for steps 1 and 2 (absent file), and for a caught error.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER PrNumber
        The explicit pull request number the gate read, or $null.
    .PARAMETER WorktreeRoot
        The root R: the session root on Claude, the repository root on Codex.
    .PARAMETER NoRecordingTarget
        $true when no checkpoint records the merge (the docs-only branch's eligibility rule).
    .PARAMETER ConfigReader
        Called with R; default Get-OrchestrationGateReleaseAllowanceConfigText.
    .PARAMETER ContainerProbe
        Called with R and an allowed_paths entry; default Test-OrchestrationGateReleaseAllowancePathIsContainer.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Allowed and Suffix.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [AllowNull()][Nullable[int]] $PrNumber,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [bool] $NoRecordingTarget,
        [scriptblock] $ConfigReader = { param([string] $Root) Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $Root },
        [scriptblock] $ContainerProbe = { param([string] $Root, [string] $RelativePath) Test-OrchestrationGateReleaseAllowancePathIsContainer -WorktreeRoot $Root -RelativePath $RelativePath }
    )

    $declined = [ordered]@{ Allowed = $false; Suffix = '' }
    try {
        if ($null -eq $PrNumber -or $PrNumber -le 0 -or [string]::IsNullOrWhiteSpace($WorktreeRoot)) { return $declined }
        $number = [int]$PrNumber
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $WorktreeRoot -ConfigReader $ConfigReader -ContainerProbe $ContainerProbe
        if ($state.State -ceq 'Absent') { return $declined }
        if ($state.State -cne 'Valid') { return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_CONFIG_INVALID' ([string]$state.Detail)) }
        if (-not $NoRecordingTarget) {
            return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_CHECKPOINT_PRESENT' "an orchestrator checkpoint records pull request $number or is present at the root; the release merge leg applies only to a checkpoint-free merge")
        }
        $shape = Get-DocsOnlyMergeShapeViolation -CommandText $CommandText -PrNumber $number
        $shapePrefix = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: '
        if ($shape) {
            $shapeDetail = if ($shape.StartsWith($shapePrefix, [System.StringComparison]::Ordinal)) { $shape.Substring($shapePrefix.Length) } else { $shape }
            return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_COMMAND_NOT_MODELLED' $shapeDetail)
        }
        $subcommandPath = @('pr', 'merge')
        if (Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--admin') {
            return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_COMMAND_NOT_MODELLED' '--admin is not eligible')
        }
        $pinned = $null
        if (Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit') {
            $pinned = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit'
        }
        if (-not (Test-EpicMergeGateChildCiObjectId -Value $pinned)) {
            return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_MATCH_HEAD_MISSING' 'the command must pass --match-head-commit with the full lowercase 40- or 64-character head commit')
        }

        $pullRequest = Get-EpicMergeGateReleasePullRequest -PrNumber $number -WorktreeRoot $WorktreeRoot
        $violation = Get-EpicMergeGateReleasePullRequestViolation -PullRequest $pullRequest -PrNumber $number
        if ($violation) { return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_PR_UNRESOLVED' $violation) }
        $prState = [string]$pullRequest.state
        if ($prState -cne 'OPEN') { return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_PR_NOT_OPEN' "pull request $number has state '$prState'; only OPEN is accepted") }
        if ($pullRequest.isCrossRepository) { return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_CROSS_REPOSITORY' "pull request $number comes from another repository") }
        $head = [string]$pullRequest.headRefOid
        if (-not [string]::Equals($head, $pinned, [System.StringComparison]::Ordinal)) {
            return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_HEAD_MISMATCH' "--match-head-commit does not equal the head commit $head of pull request $number")
        }
        $files = Get-EpicMergeGateChildCiProperty -InputObject $pullRequest -Name 'files'
        $changedFiles = [long]$pullRequest.changedFiles
        if ($changedFiles -gt 100 -or @($files).Count -ne $changedFiles) {
            return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_FILES_TRUNCATED' "pull request $number reports $changedFiles changed files and lists $(@($files).Count); at most 100 fully listed files are accepted")
        }
        $changed = Get-EpicMergeGateReleaseChangedPath -File $files -PrNumber $number
        if ($null -ne $changed.Detail) { return (Get-EpicMergeGateReleaseNotAppliedResult 'RELEASE_MERGE_CHANGE_NOT_MODELLED' $changed.Detail) }

        $pathDecision = Get-ReleasePullRequestPathDecision -Allowances @($state.Allowances) -Branch ([string]$pullRequest.headRefName) -Path $changed.Path
        if (-not $pathDecision.Allowed) {
            $pathCode = switch -CaseSensitive ([string]$pathDecision.Failure) {
                'BranchNotMatched' { 'RELEASE_MERGE_BRANCH_NOT_MATCHED' }
                'EmptyPath' { 'RELEASE_MERGE_EMPTY_DIFF' }
                default { 'RELEASE_MERGE_PATH_NOT_ALLOWED' }
            }
            return (Get-EpicMergeGateReleaseNotAppliedResult $pathCode ([string]$pathDecision.Detail))
        }

        $ciFailure = Get-EpicMergeGateReleaseCiFailure -HeadSha $head -WorktreeRoot $WorktreeRoot
        if ($null -ne $ciFailure) { return (Get-EpicMergeGateReleaseNotAppliedResult $ciFailure.Code $ciFailure.Detail) }
        return [ordered]@{ Allowed = $true; Suffix = '' }
    } catch {
        Write-Debug "EPIC_MERGE_GATE_RELEASE_LEG_ERROR: $($_.Exception.Message)"
        return $declined
    }
}
