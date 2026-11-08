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
        Return the Output of a gathered fact untrimmed, or throw a code-carrying failure when the
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
        in the live head; no policy-audit.<yyyy-MM-ddTHH-mm>.md listed in the feature folder at the
        live head sorts after it (REVIEW_VERDICT_ARTIFACT_NOT_LATEST). The live head then posts when it equals the reviewed head, or when the
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
    if (-not $Fact.ContainsKey('AuditListing')) {
        return Get-ReviewVerdictFactRequest -Name 'AuditListing' -Tool 'git' -Arguments @('ls-tree', '--name-only', $live, '--', "$folder/")
    }
    if ([int]$Fact.AuditListing.ExitCode -ne 0) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail "git ls-tree exited $($Fact.AuditListing.ExitCode)"
    }
    foreach ($listed in ([string]$Fact.AuditListing.Output).Split("`n")) {
        if ($listed -cmatch $artifactPattern -and [string]::CompareOrdinal($listed, $ReviewArtifact) -gt 0) {
            return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_ARTIFACT_NOT_LATEST' -Detail "$listed is newer than $ReviewArtifact"
        }
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

function Get-ReviewVerdictBranchDecision {
    <#
    .SYNOPSIS
        Gather the pull request and check its head ref and its main base; return null when both
        match, otherwise the decision to return.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([int] $PrNumber, [hashtable] $Fact, [string] $Pattern, [string] $Expected)

    if (-not $Fact.ContainsKey('PullRequest')) { return Get-ReviewVerdictPullRequestRequest -PrNumber $PrNumber }
    $pullRequest = Get-ReviewVerdictPullRequest -Fact $Fact
    if ($pullRequest.headRefName -cnotmatch $Pattern -or $pullRequest.baseRefName -cne $script:BaseBranch) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_BRANCH_MISMATCH' -Detail "head '$($pullRequest.headRefName)' into '$($pullRequest.baseRefName)' is not $Expected into main"
    }
    return $null
}

function Get-ReviewVerdictListingFact {
    <#
    .SYNOPSIS
        Return the parsed NUL listing of a gathered git fact as Entry, or a decision when git failed.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Fact, [string] $Name)

    try { $entry = ConvertFrom-ReviewVerdictNulList -Text (Get-ReviewVerdictFactOutput -Fact $Fact -Name $Name) }
    catch { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail $_.Exception.Message }
    return [pscustomobject]@{ Entry = $entry }
}

function Get-ReviewVerdictMergeBaseFact {
    <#
    .SYNOPSIS
        Return the object id of a gathered git merge-base fact as Base, or a decision when git failed.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Fact, [string] $Name)

    $record = $Fact[$Name]
    $value = ([string]$record.Output).Trim()
    if ([int]$record.ExitCode -ne 0 -or -not (Test-ReviewVerdictObjectId -Value $value)) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail "git merge-base for $Name exited $($record.ExitCode)"
    }
    return [pscustomobject]@{ Base = $value }
}

function Test-ReviewVerdictIsDecision {
    <# .SYNOPSIS Return true when a helper result is a decision record rather than a gathered value. #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([object] $Value)

    return $Value.PSObject.Properties.Name -contains 'Code'
}

function Get-ReviewVerdictMainSyncDecision {
    <#
    .SYNOPSIS
        Decide mode MainSync: a merge of main into an epic integration branch.
    .DESCRIPTION
        The head ref matches epic/<name>-integration and the base is main. The live head has
        exactly two parents, R then M; R carries a review/verdict status with state success; M is
        an ancestor of origin/main. With B the merge base of R and M, diff(B,R) and diff(B,M) are
        disjoint, diff(R,H) is a subset of diff(B,M), and diff(M,H) is a subset of diff(B,R).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([int] $PrNumber, [hashtable] $Fact = @{})

    $branch = Get-ReviewVerdictBranchDecision -PrNumber $PrNumber -Fact $Fact -Pattern $script:IntegrationBranchPattern -Expected 'epic/<name>-integration'
    if ($null -ne $branch) { return $branch }
    $head = (Get-ReviewVerdictPullRequest -Fact $Fact).headRefOid
    if (-not $Fact.ContainsKey('Parents')) { return Get-ReviewVerdictFactRequest -Name 'Parents' -Tool 'git' -Arguments @('log', '-1', '--format=%P', $head) }
    if ([int]$Fact.Parents.ExitCode -ne 0) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail "git log exited $($Fact.Parents.ExitCode)" }
    $parent = @(([string]$Fact.Parents.Output).Trim().Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries))
    if ($parent.Count -ne 2) {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_MAIN_SYNC' -Detail "the head $head has $($parent.Count) parents, not 2"
    }
    $reviewed = $parent[0]; $main = $parent[1]
    if (-not $Fact.ContainsKey('ParentStatus')) {
        return Get-ReviewVerdictFactRequest -Name 'ParentStatus' -Tool 'gh' -Arguments @('api', "repos/{owner}/{repo}/commits/$reviewed/statuses")
    }
    $state = ''
    if ([int]$Fact.ParentStatus.ExitCode -eq 0) {
        $status = @(ConvertFrom-Json -InputObject ([string]$Fact.ParentStatus.Output) -AsHashtable -NoEnumerate)
        if ($status.Count -eq 1 -and $status[0] -is [array]) { $status = @($status[0]) }
        $newest = @($status | Where-Object { (Get-ReviewVerdictMember -Value $_ -Name 'context') -ceq $script:StatusContext })
        if ($newest.Count -gt 0) { $state = [string](Get-ReviewVerdictMember -Value $newest[0] -Name 'state') }
    }
    if ($state -cne 'success') {
        return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_PARENT_UNVERIFIED' -Detail "the first parent $reviewed has no successful review/verdict status"
    }
    if (-not $Fact.ContainsKey('MainAncestry')) { return Get-ReviewVerdictFactRequest -Name 'MainAncestry' -Tool 'git' -Arguments @('merge-base', '--is-ancestor', $main, $script:MainRef) }
    $ancestry = [int]$Fact.MainAncestry.ExitCode
    if ($ancestry -eq 1) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_MAIN_SYNC' -Detail "the second parent $main is not an ancestor of origin/main" }
    if ($ancestry -ne 0) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail "git merge-base --is-ancestor exited $ancestry" }
    if (-not $Fact.ContainsKey('MergeBase')) { return Get-ReviewVerdictFactRequest -Name 'MergeBase' -Tool 'git' -Arguments @('merge-base', $reviewed, $main) }
    $base = Get-ReviewVerdictMergeBaseFact -Fact $Fact -Name 'MergeBase'
    if (Test-ReviewVerdictIsDecision -Value $base) { return $base }
    $set = @{}
    foreach ($pair in @(@('BranchSet', $base.Base, $reviewed), @('MainSet', $base.Base, $main), @('ReviewedToHead', $reviewed, $head), @('MainToHead', $main, $head))) {
        if (-not $Fact.ContainsKey($pair[0])) {
            return Get-ReviewVerdictFactRequest -Name $pair[0] -Tool 'git' -Arguments @('diff', '--name-only', '-z', '--no-renames', $pair[1], $pair[2])
        }
        $listing = Get-ReviewVerdictListingFact -Fact $Fact -Name $pair[0]
        if (Test-ReviewVerdictIsDecision -Value $listing) { return $listing }
        $set[$pair[0]] = [System.Collections.Generic.HashSet[string]]::new([string[]]$listing.Entry, [System.StringComparer]::Ordinal)
    }
    foreach ($path in $set.BranchSet) {
        if ($set.MainSet.Contains($path)) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_MAIN_SYNC' -Detail "'$path' changed on both the branch and main" }
    }
    foreach ($check in @(@('ReviewedToHead', 'MainSet', 'main'), @('MainToHead', 'BranchSet', 'the reviewed head'))) {
        foreach ($path in $set[$check[0]]) {
            if (-not $set[$check[1]].Contains($path)) {
                return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_MAIN_SYNC' -Detail "'$path' differs from $($check[2]) in the merge"
            }
        }
    }
    return ConvertTo-ReviewVerdictDecision -Eligible $true -Code 'REVIEW_VERDICT_ELIGIBLE' -Detail $head -Description 'main sync: no change beyond main and the reviewed head'
}

function Get-ReviewVerdictBaseListing {
    <#
    .SYNOPSIS
        Gather the merge base of origin/main and the head, then one listing from it; return Base
        and Entry, or the decision to return.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([hashtable] $Fact, [string] $Head, [string] $Name, [string] $ListFlag)

    if (-not $Fact.ContainsKey('MergeBase')) { return Get-ReviewVerdictFactRequest -Name 'MergeBase' -Tool 'git' -Arguments @('merge-base', $script:MainRef, $Head) }
    $base = Get-ReviewVerdictMergeBaseFact -Fact $Fact -Name 'MergeBase'
    if (Test-ReviewVerdictIsDecision -Value $base) { return $base }
    if (-not $Fact.ContainsKey($Name)) { return Get-ReviewVerdictFactRequest -Name $Name -Tool 'git' -Arguments @('diff', $ListFlag, '-z', '--no-renames', $base.Base, $Head) }
    $listing = Get-ReviewVerdictListingFact -Fact $Fact -Name $Name
    if (Test-ReviewVerdictIsDecision -Value $listing) { return $listing }
    return [pscustomobject]@{ Base = $base.Base; Entry = $listing.Entry }
}

function Test-ReviewVerdictRecordsPrPath {
    <#
    .SYNOPSIS
        Return true for a records path: under docs/features/ except templates/ and the potential
        template, or under .claude/agent-memory/.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([string] $Path)

    $ordinal = [System.StringComparison]::Ordinal
    if ($Path.StartsWith('.claude/agent-memory/', $ordinal)) { return $true }
    return $Path.StartsWith($script:FeatureRoot, $ordinal) -and -not $Path.StartsWith('docs/features/templates/', $ordinal) -and $Path -cne $script:PotentialTemplate
}

function Get-ReviewVerdictRecordsPrDecision {
    <#
    .SYNOPSIS
        Decide mode RecordsPr: the documentationandmemories records pull request into main.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([int] $PrNumber, [hashtable] $Fact = @{})

    $branch = Get-ReviewVerdictBranchDecision -PrNumber $PrNumber -Fact $Fact -Pattern $script:RecordsBranchPattern -Expected $script:RecordsBranch
    if ($null -ne $branch) { return $branch }
    $head = (Get-ReviewVerdictPullRequest -Fact $Fact).headRefOid
    $listing = Get-ReviewVerdictBaseListing -Fact $Fact -Head $head -Name 'Listing' -ListFlag '--name-only'
    if (Test-ReviewVerdictIsDecision -Value $listing) { return $listing }
    if ($listing.Entry.Count -eq 0) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_RECORDS_ONLY' -Detail 'the pull request changes no path' }
    foreach ($path in $listing.Entry) {
        if (-not (Test-ReviewVerdictRecordsPrPath -Path $path)) {
            return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_NOT_RECORDS_ONLY' -Detail "'$path' is not a records path"
        }
    }
    return ConvertTo-ReviewVerdictDecision -Eligible $true -Code 'REVIEW_VERDICT_ELIGIBLE' -Detail $head -Description 'records-only pull request'
}

function Get-ReviewVerdictPromotionPrDecision {
    <#
    .SYNOPSIS
        Decide mode PromotionPr: a promotion-record pull request into main.
    .DESCRIPTION
        Every name-status entry lies under docs/features/potential/ (not template.md) or is an
        added file under exactly one folder docs/features/active/<name>-<branch number>/ that does
        not exist at the merge base.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([int] $PrNumber, [hashtable] $Fact = @{})

    $branch = Get-ReviewVerdictBranchDecision -PrNumber $PrNumber -Fact $Fact -Pattern $script:PromotionBranchPattern -Expected '<feature|bug>/<name>-<number>'
    if ($null -ne $branch) { return $branch }
    $pullRequest = Get-ReviewVerdictPullRequest -Fact $Fact
    $number = ([regex]::Match($pullRequest.headRefName, $script:PromotionBranchPattern)).Groups[1].Value
    $listing = Get-ReviewVerdictBaseListing -Fact $Fact -Head $pullRequest.headRefOid -Name 'NameStatus' -ListFlag '--name-status'
    if (Test-ReviewVerdictIsDecision -Value $listing) { return $listing }
    $code = 'REVIEW_VERDICT_NOT_PROMOTION_RECORD'
    if ($listing.Entry.Count % 2 -ne 0) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code $code -Detail 'the name-status listing is not status and path pairs' }
    $folder = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $listing.Entry.Count; $index += 2) {
        $status = $listing.Entry[$index]; $path = $listing.Entry[$index + 1]
        if ($path.StartsWith($script:PotentialRoot, [System.StringComparison]::Ordinal) -and $path -cne $script:PotentialTemplate) { continue }
        $match = [regex]::Match($path, $script:ActiveFolderPattern)
        $isRecord = $status -ceq 'A' -and $match.Success -and $match.Groups[1].Value.EndsWith("-$number", [System.StringComparison]::Ordinal)
        if (-not $isRecord) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code $code -Detail "'$status $path' is not a potential record or an added file of the promoted folder" }
        [void]$folder.Add("docs/features/active/$($match.Groups[1].Value)")
    }
    if ($folder.Count -ne 1) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code $code -Detail "the pull request adds $($folder.Count) promoted folders, not 1" }
    $promoted = @($folder)[0]
    if (-not $Fact.ContainsKey('FolderTree')) { return Get-ReviewVerdictFactRequest -Name 'FolderTree' -Tool 'git' -Arguments @('ls-tree', '-d', '--name-only', $listing.Base, '--', $promoted) }
    if ([int]$Fact.FolderTree.ExitCode -ne 0) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_GIT_FAILED' -Detail "git ls-tree exited $($Fact.FolderTree.ExitCode)" }
    if (-not [string]::IsNullOrWhiteSpace([string]$Fact.FolderTree.Output)) { return ConvertTo-ReviewVerdictDecision -Eligible $false -Code $code -Detail "$promoted already exists at the merge base" }
    return ConvertTo-ReviewVerdictDecision -Eligible $true -Code 'REVIEW_VERDICT_ELIGIBLE' -Detail $pullRequest.headRefOid -Description 'promotion-record pull request'
}
