<#
.SYNOPSIS
    Epic-child CI verification for the epic merge gates (issue #1130).

.DESCRIPTION
    Dot-sourced by .claude/hooks/enforce-epic-merge-gate.ps1 and .codex/hooks/enforce-epic-merge-gate.ps1;
    the two copies are byte-identical. The child branch of each gate allows an epic-child merge only when
    its existing checkpoint predicates hold and Get-EpicMergeGateChildCiDecision returns Verified. The
    decision evaluates six stages in order, cheapest first, and the first failure denies:

      1. PR number: the command's explicit number, else the JSON-integer pr_gate.pr_number; when both
         are present they must match; when neither is present, deny.
      2. ci_gate.conclusion equals "success" and ci_gate.head_sha is a lowercase 40- or 64-character
         object id.
      3. One bounded gh pr view <PR> --json headRefOid; the live head must equal ci_gate.head_sha.
      4. One bounded gh run list --commit <head> --limit 100; the runs are filtered to workflowName "CI"
         and headSha equal to the head, and the newest by createdAt is selected. No match denies.
      5. The selected run's event is pull_request or workflow_dispatch, its status is completed, and its
         conclusion is success. A push-event run is not accepted.
      6. For workflow_dispatch, the run's databaseId equals ci_gate.dispatch_run_id.

    Every failure returns Verified = $false with a Reason that begins
    "EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: ". A failed, timed-out, or unparseable gh
    result denies. The file dot-sources nothing: the bounded gh wrapper comes from hook-docs-only-diff.ps1,
    which both gates load, and it is called only inside the two seams below. The helper never throws
    and invokes no Python. The required workflow name CI is a stated assumption. A push after the
    live-head lookup can change the head; like the rest of the gate this is a policy-level control.

    Child CI opt-out (issue #1233): when the checkpoint records epic_mode as the JSON boolean true,
    child_ci as the exact string integration_only, and an epic_context.integration_branch that matches
    ^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$, stages B, R, L1, L2, and L3 run after stage 1 in
    place of stages 2 to 6:

      B.  One bounded gh pr view <PR> --json headRefOid,baseRefName (Get-EpicMergeGateChildCiLivePullRequest).
          A failed lookup denies. A live base that is not exactly the recorded integration branch, or that
          is main, does not apply the opt-out: stages 2 to 6 run unchanged, and stage 3 reuses the head
          read here, so no second gh pr view is made.
      R.  review_mode is exactly concurrent. The review guard runs before this helper under that key, so
          reaching stage R proves a PASS review at a current head.
      L1. local_qc_gate is an object whose conclusion is exactly success, whose head_sha is a lowercase
          object id, and whose evidence_path is a clean relative path under
          <feature-folder>/evidence/qa-gates/ that ends in .md.
      L2. local_qc_gate.head_sha equals the head_sha of the last remediation_loop.review_outcomes entry.
      L3. One bounded git cat-file -p <live head>:<evidence_path> at GitRoot: the file exists, its first
          EXIT_CODE: line has value 0, and it holds a Timestamp: line and the line Head: <head_sha>.

    Every opt-out failure returns a Reason that begins
    "EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: " and does not fall through. Without the
    predicate the helper is unchanged and the opt-out seam is never called. child_ci is self-declared by
    the item checkpoint; the live base, the concurrent review, and the evidence file bound it.
    The opt-out reads its keys by ordinal name, as the validators and the completion hooks do.
#>

$script:EpicMergeGateChildCiReasonPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: '
$script:EpicMergeGateChildLocalQcReasonPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: '
$script:EpicMergeGateChildCiIntegrationBranchPattern = '\Aepic/[A-Za-z0-9][A-Za-z0-9._-]*-integration\z'

function Test-EpicMergeGateChildCiObjectId {
    <#
    .SYNOPSIS
        Report whether a value is a lowercase 40- or 64-character hexadecimal object id.
    .PARAMETER Value
        The candidate value, of any type.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [string] -and $Value -cmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$')
}

function Test-EpicMergeGateChildCiPositiveInteger {
    <#
    .SYNOPSIS
        Report whether a parsed JSON value is an integer greater than zero; a digit string fails.
    .PARAMETER Value
        The candidate value, of any type.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return (($Value -is [int] -or $Value -is [long]) -and $Value -gt 0)
}

function Get-EpicMergeGateChildCiProperty {
    <#
    .SYNOPSIS
        Read a named property off a parsed JSON object, or $null when the value is not an object or lacks it.
    .PARAMETER InputObject
        The parsed value.
    .PARAMETER Name
        The property name.
    .OUTPUTS
        System.Object
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param([AllowNull()] $InputObject, [Parameter(Mandatory)][string] $Name)

    if ($InputObject -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return , $property.Value
}

function Get-EpicMergeGateChildCiPrNumber {
    <#
    .SYNOPSIS
        Resolve the pull-request number for stage 1, or a failure detail.
    .DESCRIPTION
        A present pr_gate.pr_number must be a positive JSON integer. The command's explicit number wins
        when present and must equal a recorded number; otherwise the recorded number is used.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .PARAMETER CommandPrNumber
        The explicit PR number of the command, or $null for a bare command.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with PrNumber and Detail.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] $Checkpoint, [AllowNull()][Nullable[int]] $CommandPrNumber)

    $prGate = Get-EpicMergeGateChildCiProperty -InputObject $Checkpoint -Name 'pr_gate'
    $recorded = $null
    if ($null -ne $prGate) {
        $recordedValue = Get-EpicMergeGateChildCiProperty -InputObject $prGate -Name 'pr_number'
        if ($null -ne $recordedValue) {
            if (-not (Test-EpicMergeGateChildCiPositiveInteger -Value $recordedValue)) {
                return [ordered]@{ PrNumber = $null; Detail = 'pr_gate.pr_number is not a positive JSON integer.' }
            }
            $recorded = [int]$recordedValue
        }
    }
    if ($null -ne $CommandPrNumber) {
        if ($null -ne $recorded -and $recorded -ne $CommandPrNumber) {
            return [ordered]@{ PrNumber = $null; Detail = "the command names pull request $CommandPrNumber but pr_gate.pr_number records $recorded." }
        }
        return [ordered]@{ PrNumber = [int]$CommandPrNumber; Detail = $null }
    }
    if ($null -eq $recorded) {
        return [ordered]@{ PrNumber = $null; Detail = 'the command names no pull request and the checkpoint records no pr_gate.pr_number.' }
    }
    return [ordered]@{ PrNumber = $recorded; Detail = $null }
}

function Get-EpicMergeGateChildCiLiveHeadSha {
    <#
    .SYNOPSIS
        Return the live head commit of a pull request, or $null on any failure (the live-head seam).
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGhExe call, gh pr view <PR> --json headRefOid. A non-zero exit,
        output that does not parse to a JSON object, and a malformed head all return $null.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][int] $PrNumber, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'headRefOid')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
    } catch {
        # Unreadable gh output is a lookup failure; the decision fails closed on $null.
        return $null
    }
    $head = Get-EpicMergeGateChildCiProperty -InputObject $pr -Name 'headRefOid'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $head)) { return $null }
    return [string]$head
}

function Get-EpicMergeGateChildCiRunList {
    <#
    .SYNOPSIS
        Return the workflow runs recorded for a commit as an array, or $null on any failure (the run-list seam).
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGhExe call, gh run list --commit <head> --limit 100 with the JSON
        fields databaseId, event, status, conclusion, headSha, workflowName, and createdAt. A non-zero
        exit, unparseable output, and output that is not a JSON array return $null.
    .PARAMETER HeadSha
        The commit whose runs are listed.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Object[] or $null
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][string] $HeadSha, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('run', 'list', '--commit', $HeadSha, '--limit', '100', '--json', 'databaseId,event,status,conclusion,headSha,workflowName,createdAt')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $runs = ConvertFrom-Json -InputObject ([string]$lookup.Output) -NoEnumerate -ErrorAction Stop
    } catch {
        # Unreadable gh output is a lookup failure; the decision fails closed on $null.
        return $null
    }
    if ($runs -isnot [System.Array]) { return $null }
    return , $runs
}

function Select-EpicMergeGateChildCiRun {
    <#
    .SYNOPSIS
        Select the newest run of the workflow named CI on the given head, or $null when none qualifies.
    .DESCRIPTION
        Considers only object entries whose workflowName is exactly CI and whose headSha equals the head.
        The newest is chosen by createdAt, then by databaseId. A matching entry whose createdAt cannot be
        read makes the selection fail, because its order relative to the others is unknown.
    .PARAMETER Runs
        The parsed run list.
    .PARAMETER HeadSha
        The verified head commit.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Runs, [Parameter(Mandatory)][string] $HeadSha)

    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($run in @($Runs)) {
        if ([string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'workflowName') -cne 'CI') { continue }
        if ([string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'headSha') -cne $HeadSha) { continue }
        $created = Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'createdAt'
        $stamp = [DateTimeOffset]::MinValue
        if ($created -is [DateTime]) {
            $stamp = [DateTimeOffset]::new($created.ToUniversalTime())
        } elseif (-not ($created -is [string] -and [DateTimeOffset]::TryParse($created, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal, [ref] $stamp))) {
            return $null
        }
        $id = Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'databaseId'
        $candidates.Add([pscustomobject]@{ Stamp = $stamp; Id = $(if (Test-EpicMergeGateChildCiPositiveInteger -Value $id) { [long]$id } else { [long]0 }); Run = $run })
    }
    if ($candidates.Count -eq 0) { return $null }
    $newest = $candidates | Sort-Object -Property @{ Expression = 'Stamp'; Descending = $true }, @{ Expression = 'Id'; Descending = $true } | Select-Object -First 1
    return $newest.Run
}

function Get-EpicMergeGateChildCiOrdinalProperty {
    <#
    .SYNOPSIS
        Read a named property off a parsed JSON object by ordinal name, or $null when absent (issue #1233).
    .DESCRIPTION
        Same contract as Get-EpicMergeGateChildCiProperty, except that a property matches only when its
        name equals Name ordinally (-ceq), as a Python dict and a TypeScript property lookup do.
    .PARAMETER InputObject
        The parsed value.
    .PARAMETER Name
        The property name, compared ordinally.
    .OUTPUTS
        System.Object
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param([AllowNull()] $InputObject, [Parameter(Mandatory)][string] $Name)

    if ($InputObject -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Name -ceq $Name) { return , $property.Value }
    }
    return $null
}

function Get-EpicMergeGateChildLocalQcReviewedHead {
    <#
    .SYNOPSIS
        Return the head_sha of the last remediation_loop.review_outcomes entry, read by ordinal names (pure).
    .DESCRIPTION
        A missing loop, a value that is not a list, an empty list, and a last entry that is not an object
        all return $null; only the final list element counts.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param([AllowNull()] $Checkpoint)

    $loop = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'remediation_loop'
    $outcomes = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $loop -Name 'review_outcomes'
    if ($outcomes -isnot [System.Array] -or $outcomes.Count -eq 0) { return $null }
    $head = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $outcomes[$outcomes.Count - 1] -Name 'head_sha'
    return , $head
}

function Test-EpicMergeGateChildCiOptOut {
    <#
    .SYNOPSIS
        Report whether the child-CI opt-out predicate of issue #1233 holds for a parsed checkpoint (pure).
    .DESCRIPTION
        True only when epic_mode is the JSON boolean true, child_ci is the exact string integration_only
        (ordinal), and epic_context.integration_branch is a string matching the integration-branch pattern.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Checkpoint)

    $epicMode = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'epic_mode'
    if (-not ($epicMode -is [bool] -and $epicMode)) { return $false }
    $childCi = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'child_ci'
    if (-not ($childCi -is [string] -and $childCi -ceq 'integration_only')) { return $false }
    $context = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'epic_context'
    $branch = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $context -Name 'integration_branch'
    return ($branch -is [string] -and $branch -cmatch $script:EpicMergeGateChildCiIntegrationBranchPattern)
}

function Get-EpicMergeGateChildCiLivePullRequest {
    <#
    .SYNOPSIS
        Return the live head and base of a pull request, or $null on any failure (the opt-out seam).
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGhExe call, gh pr view <PR> --json headRefOid,baseRefName. A
        non-zero exit, output that does not parse to a JSON object, a malformed head, and an absent or
        blank base all return $null.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with HeadSha and BaseRef, or $null
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)][int] $PrNumber, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'headRefOid,baseRefName')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
    } catch {
        # Unreadable gh output is a lookup failure; the opt-out fails closed on $null.
        return $null
    }
    $head = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $pr -Name 'headRefOid'
    $base = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $pr -Name 'baseRefName'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $head)) { return $null }
    if (-not ($base -is [string]) -or [string]::IsNullOrWhiteSpace($base)) { return $null }
    return [ordered]@{ HeadSha = [string]$head; BaseRef = [string]$base }
}

function Test-EpicMergeGateChildCiEvidencePath {
    <#
    .SYNOPSIS
        Report whether an evidence path is a clean relative .md path under <feature-folder>/evidence/qa-gates/ (pure).
    .PARAMETER Path
        The candidate local_qc_gate.evidence_path value, of any type.
    .PARAMETER FeatureFolder
        The validated feature-folder value.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Path, [Parameter(Mandatory)][string] $FeatureFolder)

    if ($Path -isnot [string] -or $Path.Length -eq 0) { return $false }
    if ($Path.IndexOf([char]92) -ge 0) { return $false }
    foreach ($segment in $Path.Split('/')) {
        if ($segment.Length -eq 0 -or $segment -ceq '.' -or $segment -ceq '..') { return $false }
    }
    if (-not $Path.StartsWith("$FeatureFolder/evidence/qa-gates/", [System.StringComparison]::Ordinal)) { return $false }
    return $Path.EndsWith('.md', [System.StringComparison]::Ordinal)
}

function Get-EpicMergeGateChildLocalQcEvidenceDetail {
    <#
    .SYNOPSIS
        Stage L3: read the evidence file at the live head and return a failure detail, or $null when it passes.
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGitExe call, git cat-file -p <head>:<path>, at GitRoot. The file
        must exist, its first EXIT_CODE: line must have value 0, and it must hold a Timestamp: line and the
        line Head: <head_sha>, compared ordinally.
    .PARAMETER LiveHead
        The live head commit of the pull request.
    .PARAMETER EvidencePath
        The validated local_qc_gate.evidence_path.
    .PARAMETER RecordedHead
        The validated local_qc_gate.head_sha.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $LiveHead,
        [Parameter(Mandatory)][string] $EvidencePath,
        [Parameter(Mandatory)][string] $RecordedHead,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $read = Invoke-DocsOnlyGitExe -WorktreeRoot $GitRoot -GitArgs @('cat-file', '-p', "${LiveHead}:$EvidencePath")
    if ($null -eq $read -or $read.ExitCode -ne 0) { return "stage L3 (evidence): $EvidencePath could not be read at the live head $LiveHead." }
    $lines = @(([string]$read.Output) -split "`n" | ForEach-Object { $_.TrimEnd("`r") })
    $exitLine = @($lines | Where-Object { $_.StartsWith('EXIT_CODE:', [System.StringComparison]::Ordinal) } | Select-Object -First 1)
    if ($exitLine.Count -eq 0) { return "stage L3 (evidence): $EvidencePath has no EXIT_CODE: line." }
    if ($exitLine[0].Substring('EXIT_CODE:'.Length).Trim() -cne '0') { return "stage L3 (evidence): the first EXIT_CODE: line of $EvidencePath is not 0." }
    if (@($lines | Where-Object { $_.StartsWith('Timestamp:', [System.StringComparison]::Ordinal) }).Count -eq 0) {
        return "stage L3 (evidence): $EvidencePath has no Timestamp: line."
    }
    if (@($lines | Where-Object { $_.TrimEnd() -ceq "Head: $RecordedHead" }).Count -eq 0) {
        return "stage L3 (evidence): $EvidencePath has no line Head: $RecordedHead."
    }
    return $null
}

function ConvertTo-EpicMergeGateChildLocalQcResult {
    <#
    .SYNOPSIS
        Build an applied opt-out result with a detail and the live head (pure).
    .PARAMETER Detail
        The failure detail, or $null when every stage passed.
    .PARAMETER LiveHead
        The live head read by stage B, or $null when stage B failed.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Applies, Detail, and LiveHead.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()][AllowEmptyString()][string] $Detail, [AllowNull()][AllowEmptyString()][string] $LiveHead)

    $detailValue = if ([string]::IsNullOrEmpty($Detail)) { $null } else { $Detail }
    $headValue = if ([string]::IsNullOrEmpty($LiveHead)) { $null } else { $LiveHead }
    return [ordered]@{ Applies = $true; Detail = $detailValue; LiveHead = $headValue }
}

function Get-EpicMergeGateChildLocalQcResult {
    <#
    .SYNOPSIS
        Evaluate opt-out stages B, R, L1, L2, and L3 (issue #1233).
    .DESCRIPTION
        Applies is $false only when the live base is not exactly the recorded integration branch or is
        main; LiveHead then carries the head read by stage B, for reuse by stage 3. Otherwise Applies is
        $true and Detail holds the first failure detail, or $null when every stage passes.
    .PARAMETER Checkpoint
        The parsed child checkpoint, for which Test-EpicMergeGateChildCiOptOut holds.
    .PARAMETER PrNumber
        The resolved pull request number.
    .PARAMETER GhRoot
        The directory gh runs in.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Applies, Detail, and LiveHead.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] $Checkpoint,
        [Parameter(Mandatory)][int] $PrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $live = Get-EpicMergeGateChildCiLivePullRequest -PrNumber $PrNumber -WorktreeRoot $GhRoot
    if ($null -eq $live) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail "stage B (base): the live head and base of pull request $PrNumber could not be resolved." -LiveHead $null
    }
    $integration = [string](Get-EpicMergeGateChildCiOrdinalProperty -InputObject (Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'epic_context') -Name 'integration_branch')
    if ($live.BaseRef -cne $integration -or $live.BaseRef -ceq 'main') {
        return [ordered]@{ Applies = $false; Detail = $null; LiveHead = $live.HeadSha }
    }

    if (-not (Test-EpicMergeGateReviewModeConcurrent -Checkpoint $Checkpoint)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage R (review): child_ci integration_only requires review_mode "concurrent".' -LiveHead $live.HeadSha
    }

    $gate = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'local_qc_gate'
    if ($gate -isnot [System.Management.Automation.PSCustomObject]) { return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): the checkpoint records no local_qc_gate object.' -LiveHead $live.HeadSha }
    $conclusion = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $gate -Name 'conclusion'
    if (-not ($conclusion -is [string] -and $conclusion -ceq 'success')) { return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): local_qc_gate.conclusion is not "success".' -LiveHead $live.HeadSha }
    $recordedHead = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $gate -Name 'head_sha'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $recordedHead)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): local_qc_gate.head_sha is not a lowercase 40- or 64-character object id.' -LiveHead $live.HeadSha
    }
    $featureFolder = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'feature-folder'
    if (-not (Test-EpicMergeGateReviewFeatureFolder -Value $featureFolder)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): the checkpoint feature-folder is absent or not a clean development-docs path.' -LiveHead $live.HeadSha
    }
    $evidencePath = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $gate -Name 'evidence_path'
    if (-not (Test-EpicMergeGateChildCiEvidencePath -Path $evidencePath -FeatureFolder ([string]$featureFolder))) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail "stage L1 (record): local_qc_gate.evidence_path is not a clean relative path under $featureFolder/evidence/qa-gates/ that ends in .md." -LiveHead $live.HeadSha
    }

    $reviewedHead = Get-EpicMergeGateChildLocalQcReviewedHead -Checkpoint $Checkpoint
    if (-not ($reviewedHead -is [string] -and $reviewedHead -ceq $recordedHead)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail "stage L2 (binding): local_qc_gate.head_sha $recordedHead differs from the head_sha of the last review_outcomes entry." -LiveHead $live.HeadSha
    }

    $evidenceDetail = Get-EpicMergeGateChildLocalQcEvidenceDetail -LiveHead $live.HeadSha -EvidencePath ([string]$evidencePath) -RecordedHead ([string]$recordedHead) -GitRoot $GitRoot
    return ConvertTo-EpicMergeGateChildLocalQcResult -Detail $evidenceDetail -LiveHead $live.HeadSha
}

function Get-EpicMergeGateChildCiDecision {
    <#
    .SYNOPSIS
        Verify a green CI run on the live head of an epic child's pull request (stages 1 to 6).
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .PARAMETER CommandPrNumber
        The explicit PR number of the command, or $null for a bare command.
    .PARAMETER GhRoot
        The directory gh runs in: the session root on Claude, the repository root on Codex.
    .PARAMETER GitRoot
        The directory git runs in for opt-out stage L3: the item worktree on Claude. Omitted or empty, it
        defaults to GhRoot.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Verified and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $gitDirectory = if ([string]::IsNullOrEmpty($GitRoot)) { $GhRoot } else { $GitRoot }
    try {
        $detail = Get-EpicMergeGateChildCiFailureDetail -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber -GhRoot $GhRoot -GitRoot $gitDirectory
    } catch {
        # The helper never throws: an unexpected error denies with its message (fail closed).
        $detail = 'verification failed with an error: ' + $_.Exception.Message
    }
    if ($null -eq $detail) { return [ordered]@{ Verified = $true; Reason = '' } }
    # An opt-out failure already carries its own prefix; every other detail takes the CI prefix.
    if ($detail.StartsWith($script:EpicMergeGateChildLocalQcReasonPrefix, [System.StringComparison]::Ordinal)) {
        return [ordered]@{ Verified = $false; Reason = $detail }
    }
    return [ordered]@{ Verified = $false; Reason = $script:EpicMergeGateChildCiReasonPrefix + $detail }
}

function Get-EpicMergeGateChildCiFailureDetail {
    <#
    .SYNOPSIS
        Evaluate stages 1 to 6 in order and return the first failure detail, or $null when all pass.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .PARAMETER CommandPrNumber
        The explicit PR number of the command, or $null for a bare command.
    .PARAMETER GhRoot
        The directory gh runs in.
    .PARAMETER GitRoot
        The directory git runs in for opt-out stage L3.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $pr = Get-EpicMergeGateChildCiPrNumber -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber
    if ($null -eq $pr.PrNumber) { return 'stage 1 (PR number): ' + $pr.Detail }

    # Child CI opt-out (issue #1233): stages B to L3 replace stages 2 to 6 unless the live base falls back.
    $knownLiveHead = $null
    if (Test-EpicMergeGateChildCiOptOut -Checkpoint $Checkpoint) {
        $localQc = Get-EpicMergeGateChildLocalQcResult -Checkpoint $Checkpoint -PrNumber $pr.PrNumber -GhRoot $GhRoot -GitRoot $GitRoot
        if ($localQc.Applies) {
            if ($null -eq $localQc.Detail) { return $null }
            return $script:EpicMergeGateChildLocalQcReasonPrefix + $localQc.Detail
        }
        $knownLiveHead = $localQc.LiveHead
    }

    $ciGate = Get-EpicMergeGateChildCiProperty -InputObject $Checkpoint -Name 'ci_gate'
    if ($null -eq $ciGate -or [string](Get-EpicMergeGateChildCiProperty -InputObject $ciGate -Name 'conclusion') -cne 'success') {
        return 'stage 2 (ci_gate): the checkpoint records no ci_gate with conclusion "success" for the child head.'
    }
    $head = Get-EpicMergeGateChildCiProperty -InputObject $ciGate -Name 'head_sha'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $head)) {
        return 'stage 2 (ci_gate): ci_gate.head_sha is not a lowercase 40- or 64-character object id.'
    }

    $liveHead = if ($null -ne $knownLiveHead) { $knownLiveHead } else { Get-EpicMergeGateChildCiLiveHeadSha -PrNumber $pr.PrNumber -WorktreeRoot $GhRoot }
    if ($null -eq $liveHead) { return "stage 3 (live head): the live head of pull request $($pr.PrNumber) could not be resolved." }
    if ($liveHead -cne $head) { return "stage 3 (live head): the live head $liveHead differs from ci_gate.head_sha $head." }

    $runs = Get-EpicMergeGateChildCiRunList -HeadSha $head -WorktreeRoot $GhRoot
    if ($null -eq $runs) { return "stage 4 (run list): the workflow runs for $head could not be listed." }
    $run = Select-EpicMergeGateChildCiRun -Runs $runs -HeadSha $head
    if ($null -eq $run) { return "stage 4 (run list): no run of the workflow named CI exists on $head." }

    $runEvent = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'event')
    if (@('pull_request', 'workflow_dispatch') -cnotcontains $runEvent) {
        return "stage 5 (run result): the newest CI run on $head has event '$runEvent'; only pull_request or workflow_dispatch is accepted."
    }
    $status = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'status')
    $conclusion = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'conclusion')
    if ($status -cne 'completed' -or $conclusion -cne 'success') {
        return "stage 5 (run result): the newest CI run on $head has status '$status' and conclusion '$conclusion'."
    }

    if ($runEvent -ceq 'workflow_dispatch') {
        $recordedId = Get-EpicMergeGateChildCiProperty -InputObject $ciGate -Name 'dispatch_run_id'
        $runId = Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'databaseId'
        if (-not (Test-EpicMergeGateChildCiPositiveInteger -Value $recordedId) -or
            -not (Test-EpicMergeGateChildCiPositiveInteger -Value $runId) -or
            [long]$recordedId -ne [long]$runId) {
            return "stage 6 (dispatch run): the workflow_dispatch run $runId is not the run recorded in ci_gate.dispatch_run_id."
        }
    }
    return $null
}
