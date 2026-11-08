<#
.SYNOPSIS
    Pure eligibility rules for the review/verdict commit status (issue #1097, decision D16).

.DESCRIPTION
    Decides whether the orchestrator may post the commit status review/verdict, state success, on
    a pull-request head, and builds the gh api arguments that post it. The entry point
    Invoke-ReviewVerdictStatus.ps1 owns every process and file read. Each decision evaluates its
    rules in order over a Fact table; when the next rule needs a missing fact it returns
    REVIEW_VERDICT_FACT_REQUIRED with a Request naming the fact and its gh or git arguments, so
    no later process runs once a rule refuses. Every decision returns Eligible, Code, Detail,
    Description, and Request. The status records a passing review and does not prove one.
    Every function is pure: no filesystem, subprocess, network, or clock access.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:FactRequiredCode = 'REVIEW_VERDICT_FACT_REQUIRED'
$script:ObjectIdPattern = '^(?:[0-9a-f]{40}|[0-9a-f]{64})\z'
$script:MaximumDescriptionLength = 140
$script:StatusContext = 'review/verdict'
$script:FeatureRoot = 'docs/features/'
$script:PotentialRoot = 'docs/features/potential/'
$script:PotentialTemplate = 'docs/features/potential/template.md'
$script:ActiveFolderPattern = '^docs/features/active/([^/]+)/.'
$script:IntegrationBranchPattern = '^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration\z'
$script:PromotionBranchPattern = '^(?:feature|bug)/[a-z0-9][a-z0-9-]*-([0-9]+)\z'
$script:RecordsBranch = 'documentationandmemories'
$script:RecordsBranchPattern = '^documentationandmemories\z'
$script:BaseBranch = 'main'
$script:MainRef = 'origin/main'

function ConvertTo-ReviewVerdictDecision {
    <#
    .SYNOPSIS
        Build one decision record; Request names the fact still needed, or is null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([bool] $Eligible, [string] $Code, [string] $Detail = '', [string] $Description = '', [AllowNull()][object] $Request = $null)

    return [pscustomobject]@{ Eligible = $Eligible; Code = $Code; Detail = $Detail; Description = $Description; Request = $Request }
}

function Get-ReviewVerdictFactRequest {
    <#
    .SYNOPSIS
        Return the decision that asks the entry point for one fact from one gh or git process.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Name, [ValidateSet('gh', 'git')][string] $Tool, [string[]] $Arguments)

    $request = [pscustomobject]@{ Name = $Name; Tool = $Tool; Arguments = $Arguments }
    return ConvertTo-ReviewVerdictDecision -Eligible $false -Code $script:FactRequiredCode -Detail $Name -Request $request
}

function Get-ReviewVerdictMember {
    <#
    .SYNOPSIS
        Return the value of one key of a dictionary, or null when the value is not a dictionary
        or does not hold the key.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][object] $Value, [string] $Name)

    if ($Value -isnot [System.Collections.IDictionary]) { return $null }
    if (-not $Value.Contains($Name)) { return $null }
    return $Value[$Name]
}

function Test-ReviewVerdictObjectId {
    <#
    .SYNOPSIS
        Return true for a lowercase 40 or 64 character object id string.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][object] $Value)

    return ($Value -is [string]) -and ($Value -cmatch $script:ObjectIdPattern)
}

function ConvertFrom-ReviewVerdictNulList {
    <#
    .SYNOPSIS
        Split the NUL-terminated output of a git -z listing into its entries; an empty text is
        an empty listing, and a text that does not end with NUL throws.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [System.Object[]])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    if ([string]::IsNullOrEmpty($Text)) { return , [string[]]@() }
    if (-not $Text.EndsWith([string][char]0, [System.StringComparison]::Ordinal)) {
        throw 'The git listing is not NUL-terminated.'
    }
    $entry = $Text.Substring(0, $Text.Length - 1).Split([char]0)
    return , [string[]]$entry
}

function Test-ReviewVerdictFeatureFolder {
    <#
    .SYNOPSIS
        Return true for a feature folder under docs/features/ with no blank, dot, or dot-dot
        segment, no backslash, and no trailing slash.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][object] $FeatureFolder)

    if ($FeatureFolder -isnot [string]) { return $false }
    if (-not $FeatureFolder.StartsWith($script:FeatureRoot, [System.StringComparison]::Ordinal)) { return $false }
    if ($FeatureFolder.Contains([string][char]92) -or $FeatureFolder.EndsWith('/', [System.StringComparison]::Ordinal)) { return $false }
    foreach ($segment in $FeatureFolder.Split('/')) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -ceq '.' -or $segment -ceq '..') { return $false }
    }
    return $true
}

function Test-ReviewVerdictRecordsOnlyPath {
    <#
    .SYNOPSIS
        Return true when a listed path lies under the feature folder, the records-only rule of D4.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([string] $Path, [string] $FeatureFolder)

    $prefix = "$FeatureFolder/"
    return $Path.Length -gt $prefix.Length -and $Path.StartsWith($prefix, [System.StringComparison]::Ordinal)
}

function Get-ReviewVerdictStatusArgument {
    <#
    .SYNOPSIS
        Return the gh arguments that post review/verdict, state success, on one head; throws on
        a head that is not an object id and on a blank description or one above 140 characters.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [System.Object[]])]
    param([string] $Head, [string] $Description)

    if (-not (Test-ReviewVerdictObjectId -Value $Head)) { throw "The status head '$Head' is not an object id." }
    if ([string]::IsNullOrWhiteSpace($Description)) { throw 'The status description is blank.' }
    if ($Description.Length -gt $script:MaximumDescriptionLength) {
        throw "The status description has $($Description.Length) characters; the limit is $($script:MaximumDescriptionLength)."
    }
    return , [string[]]@('api', '--method', 'POST', "repos/{owner}/{repo}/statuses/$Head",
        '-f', 'state=success', '-f', "context=$($script:StatusContext)", '-f', "description=$Description")
}

function Get-ReviewVerdictFactOutput {
    <#
    .SYNOPSIS
        Return the trimmed Output of a gathered fact, or throw a code-carrying failure when the
        fact's process exited non-zero.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([hashtable] $Fact, [string] $Name)

    $record = $Fact[$Name]
    if ([int]$record.ExitCode -ne 0) { throw "$Name exited $($record.ExitCode)" }
    return ([string]$record.Output)
}

function Get-ReviewVerdictPullRequest {
    <#
    .SYNOPSIS
        Parse the gh pr view fact into headRefOid, headRefName, baseRefName, and state; null when
        absent, and a throw when gh failed or printed no head object id.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([hashtable] $Fact)

    if (-not $Fact.ContainsKey('PullRequest')) { return $null }
    $parsed = ConvertFrom-Json -InputObject (Get-ReviewVerdictFactOutput -Fact $Fact -Name 'PullRequest') -AsHashtable
    $result = @{}
    foreach ($name in @('headRefOid', 'headRefName', 'baseRefName', 'state')) {
        $value = Get-ReviewVerdictMember -Value $parsed -Name $name
        $result[$name] = if ($value -is [string]) { $value } else { '' }
    }
    if (-not (Test-ReviewVerdictObjectId -Value $result.headRefOid)) { throw 'gh pr view printed no head object id' }
    return $result
}

function Get-ReviewVerdictPullRequestRequest {
    <#
    .SYNOPSIS
        Return the fact request for gh pr view of one pull request.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([int] $PrNumber)

    return Get-ReviewVerdictFactRequest -Name 'PullRequest' -Tool 'gh' -Arguments @('pr', 'view', "$PrNumber", '--json', 'headRefOid,headRefName,baseRefName,state')
}

function Get-ReviewVerdictReviewDecision {
    <#
    .SYNOPSIS
        Decide mode Review: a feature pull request whose last review outcome is PASS.
    .DESCRIPTION
        Rules in order: the last review_outcomes entry has verdict PASS; its head_sha is an object
        id; pr_gate.pr_number equals PrNumber and the pull request is OPEN; the feature folder is
        valid; ReviewArtifact is <feature-folder>/policy-audit.<yyyy-MM-ddTHH-mm>.md and is present
        in the live head. The live head then posts when it equals the reviewed head, or when the
        reviewed head is its ancestor and every path changed since lies under the feature folder.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][object] $Checkpoint, [int] $PrNumber, [string] $ReviewArtifact, [hashtable] $Fact = @{})

    $list = Get-ReviewVerdictMember -Value (Get-ReviewVerdictMember -Value $Checkpoint -Name 'remediation_loop') -Name 'review_outcomes'
    $outcome = @()
    if ($null -ne $list) { $outcome = @($list) }
    $last = if ($outcome.Count -gt 0) { $outcome[$outcome.Count - 1] } else { $null }
    $verdict = Get-ReviewVerdictMember -Value $last -Name 'verdict'
    if (-not ($verdict -is [string] -and $verdict -ceq 'PASS')) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_PASS' -Detail "last review outcome verdict is '$verdict'"
    }
    $reviewed = Get-ReviewVerdictMember -Value $last -Name 'head_sha'
    if (-not (Test-ReviewVerdictObjectId -Value $reviewed)) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_HEAD_ABSENT' -Detail 'the PASS outcome records no head_sha object id'
    }
    $recorded = Get-ReviewVerdictMember -Value (Get-ReviewVerdictMember -Value $Checkpoint -Name 'pr_gate') -Name 'pr_number'
    if (-not ($recorded -is [long] -or $recorded -is [int]) -or [long]$recorded -ne $PrNumber) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_PR_MISMATCH' -Detail "pr_gate.pr_number is '$recorded', not $PrNumber"
    }
    if (-not $Fact.ContainsKey('PullRequest')) { return Get-ReviewVerdictPullRequestRequest -PrNumber $PrNumber }
    $pullRequest = Get-ReviewVerdictPullRequest -Fact $Fact
    if ($pullRequest.state -cne 'OPEN') {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_PR_MISMATCH' -Detail "pull request $PrNumber is '$($pullRequest.state)', not OPEN"
    }
    $folder = Get-ReviewVerdictMember -Value $Checkpoint -Name 'feature-folder'
    if (-not (Test-ReviewVerdictFeatureFolder -FeatureFolder $folder)) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_FEATURE_FOLDER_INVALID' -Detail "feature-folder '$folder' is not a folder under docs/features/"
    }
    $artifactPattern = '^' + [regex]::Escape($folder) + '/policy-audit\.[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}\.md\z'
    if ($ReviewArtifact -cnotmatch $artifactPattern) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_ARTIFACT_INVALID' -Detail "'$ReviewArtifact' is not $folder/policy-audit.<yyyy-MM-ddTHH-mm>.md"
    }
    $live = $pullRequest.headRefOid
    if (-not $Fact.ContainsKey('ArtifactCommitted')) {
        return Get-ReviewVerdictFactRequest -Name 'ArtifactCommitted' -Tool 'git' -Arguments @('cat-file', '-e', "$($live):$ReviewArtifact")
    }
    if ([int]$Fact.ArtifactCommitted.ExitCode -ne 0) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_ARTIFACT_NOT_COMMITTED' -Detail "$ReviewArtifact is not in the live head $live"
    }
    $description = "feature-review PASS: $($ReviewArtifact.Substring($ReviewArtifact.LastIndexOf('/') + 1))"
    if ($live -ceq $reviewed) { return ConvertTo-ReviewVerdictDecision -Eligible $true -Code 'REVIEW_VERDICT_ELIGIBLE' -Detail $live -Description $description }
    if (-not $Fact.ContainsKey('Ancestry')) {
        return Get-ReviewVerdictFactRequest -Name 'Ancestry' -Tool 'git' -Arguments @('merge-base', '--is-ancestor', $reviewed, $live)
    }
    $ancestry = [int]$Fact.Ancestry.ExitCode
    if ($ancestry -eq 1) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_HEAD_NOT_CURRENT' -Detail "the reviewed head $reviewed is not an ancestor of the live head $live"
    }
    if ($ancestry -ne 0) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail "git merge-base --is-ancestor exited $ancestry" }
    if (-not $Fact.ContainsKey('Listing')) {
        return Get-ReviewVerdictFactRequest -Name 'Listing' -Tool 'git' -Arguments @('diff', '--name-only', '-z', '--no-renames', $reviewed, $live)
    }
    try { $path = ConvertFrom-ReviewVerdictNulList -Text (Get-ReviewVerdictFactOutput -Fact $Fact -Name 'Listing') }
    catch { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail $_.Exception.Message }
    foreach ($entry in $path) {
        if (-not (Test-ReviewVerdictRecordsOnlyPath -Path $entry -FeatureFolder $folder)) {
            return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_RECORDS_ONLY' -Detail "'$entry' changed after the review and lies outside $folder/"
        }
    }
    return ConvertTo-ReviewVerdictDecision -Eligible $true -Code 'REVIEW_VERDICT_ELIGIBLE' -Detail $live -Description $description
}
