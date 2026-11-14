<#
.SYNOPSIS
    Owner-directive relay check of the orchestrator stop hook (issue #1157).

.DESCRIPTION
    Dot-sourced by validate-orchestrator-output.ps1 under the guarded single-statement pattern and
    called from Get-OrchestratorOutputBlockDecision after the issue #1139 owner-directive check.
    Holds functions only; the entry hook imports OrchestratorStateOwnerDirectives.psm1,
    OrchestratorStateOwnerDirectiveSelection.psm1, HookTargetWorktree.psm1, and the worktree
    resolution modules these functions call.

    The check activates only when the checkpoint under validation has owner_directives, its
    worktree has a non-empty ledger (artifacts/orchestration/owner-directives.jsonl), or, for a
    linked item checkpoint (artifact type orchestrator-state, route_id neither epic nor parallel,
    recording epic_context.integration_branch or parallel_slug), the resolved parent checkpoint has
    owner_directives or the parent worktree has a non-empty ledger. A linked item checkpoint calls
    the parent seam once to decide activation; an unresolved parent or a seam failure activates
    nothing. Without activation the check reads no clock and returns $null.

    An epic or parallel parent checks each running child through Get-OwnerDirectiveRunningChildGap;
    an item checkpoint must hold every entry selected for it from its ledger and its parent. A gap
    blocks with OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING:, and a ledger line that
    fails B2-B8 blocks with OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_LEDGER_INVALID:; both are
    repairable. The clock is read once, after at least one candidate entry exists.

.NOTES
    PowerShell 7+. File reads go through Get-CheckpointFileContent, the stop hook's file seam,
    which the stop-hook suites already mock. The clock, the parent resolver, the child resolver,
    and the item-branch reader are functions that tests mock. Mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/.
#>

function Get-OrchestratorOutputOwnerPassDownClock {
    <#
    .SYNOPSIS
        Clock seam: the current UTC time, read once per check.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param()

    return [DateTime]::UtcNow
}

function Get-OrchestratorOutputOwnerPassDownSourceText {
    <#
    .SYNOPSIS
        The text of a ledger, parent checkpoint, or child checkpoint, or $null when the source is absent.
    .DESCRIPTION
        Reads through Get-CheckpointFileContent, the stop hook's file seam. A thrown read, a $null
        result, Exists false, and blank content are absent. Content ordinally equal to the
        checkpoint under validation is also absent: a source file is never the checkpoint itself.
    .PARAMETER Path
        The absolute path.
    .PARAMETER CheckpointText
        The text of the checkpoint under validation.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Path, [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $CheckpointText)

    try { $file = Get-CheckpointFileContent -Path $Path } catch { return $null }
    if ($null -eq $file -or -not $file.Exists) { return $null }
    $content = [string] $file.Content
    if ([string]::IsNullOrWhiteSpace($content)) { return $null }
    if ([string]::Equals($content, $CheckpointText, [System.StringComparison]::Ordinal)) { return $null }
    return $content
}

function Get-OrchestratorOutputOwnerPassDownValue {
    <#
    .SYNOPSIS
        A named property of a parsed object, or $null; safe under StrictMode.
    .PARAMETER InputObject
        The parsed object, or $null.
    .PARAMETER Name
        The property name (ordinal).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()] [object] $InputObject, [Parameter(Mandatory = $true)] [string] $Name)

    if ($null -eq $InputObject -or $InputObject -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    $property = @($InputObject.PSObject.Properties | Where-Object { $_.Name -ceq $Name })
    if ($property.Count -eq 0) { return $null }
    return $property[0].Value
}

function ConvertFrom-OrchestratorOutputOwnerPassDownJson {
    <#
    .SYNOPSIS
        Parse JSON text into an object, or $null for blank, unparseable, or non-object text.
    .PARAMETER Text
        The JSON text.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()] [AllowEmptyString()] [string] $Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    try { $parsed = ConvertFrom-Json -InputObject $Text -NoEnumerate -ErrorAction Stop } catch { return $null }
    if ($parsed -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    return $parsed
}

function Resolve-OrchestratorOutputOwnerPassDownParent {
    <#
    .SYNOPSIS
        Parent seam: resolve the epic or parallel parent of a linked item checkpoint.
    .DESCRIPTION
        Returns Kind, Status, WorktreeRoot, IntegrationBranch, and ParallelSlug. The epic parent
        resolves through Resolve-WorktreeEpicTarget and the parallel parent through
        Resolve-WorktreeParallelTarget (one worktree-listing read).
    .PARAMETER Checkpoint
        The parsed item checkpoint.
    .PARAMETER SessionRoot
        The hook process location.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [object] $Checkpoint, [Parameter(Mandatory = $true)] [string] $SessionRoot)

    $branch = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'epic_context') -Name 'integration_branch')
    $slug = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'parallel_slug')
    if (-not [string]::IsNullOrWhiteSpace($branch)) {
        $result = Resolve-WorktreeEpicTarget -IntegrationBranch $branch -SessionRoot $SessionRoot
        return [pscustomobject]@{ Kind = 'epic'; Status = [string] $result.Status; WorktreeRoot = $result.WorktreeRoot; IntegrationBranch = $branch; ParallelSlug = $null }
    }
    $result = Resolve-WorktreeParallelTarget -ParallelSlug $slug -SessionRoot $SessionRoot
    return [pscustomobject]@{ Kind = 'parallel'; Status = [string] $result.Status; WorktreeRoot = $result.WorktreeRoot; IntegrationBranch = $null; ParallelSlug = $slug }
}

function Resolve-OrchestratorOutputOwnerPassDownChild {
    <#
    .SYNOPSIS
        Child seam: the worktree root whose item checkpoint records an issue, or $null.
    .PARAMETER Issue
        The child issue number.
    .PARAMETER SessionRoot
        The hook process location.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $Issue, [Parameter(Mandatory = $true)] [string] $SessionRoot)

    $result = Resolve-HookTargetWorktree -SessionRoot $SessionRoot -DelegationPrompt ("Canonical issue number for this feature is $Issue.") -CheckpointIssueReader { param($WorktreeRoot) Get-WorktreeItemCheckpointIssue -WorktreeRoot $WorktreeRoot }
    $status = if ($null -ne $result.ReasonCode) { [string] $result.ReasonCode } else { 'Resolved' }
    return [pscustomobject]@{ Status = $status; WorktreeRoot = $result.WorktreeRoot }
}

function Get-OrchestratorOutputOwnerPassDownItemBranch {
    <#
    .SYNOPSIS
        Item-branch seam: the branch checked out in a worktree root, or $null.
    .PARAMETER WorktreeRoot
        The item worktree root.
    .PARAMETER SessionRoot
        The hook process location.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $WorktreeRoot, [Parameter(Mandatory = $true)] [string] $SessionRoot)

    try {
        $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null
        if ($LASTEXITCODE -ne 0) { return $null }
        $root = ConvertTo-HookTargetWorktreeNormalizedPath -Path $WorktreeRoot
        foreach ($record in @(ConvertFrom-HookTargetWorktreePorcelain -Text ($porcelain -join "`n"))) {
            if ([string]::Equals([string] $record.Root, $root, [System.StringComparison]::OrdinalIgnoreCase)) { return $record.Branch }
        }
    }
    catch { return $null }
    return $null
}

function Test-OrchestratorOutputOwnerPassDownSource {
    <#
    .SYNOPSIS
        Whether a checkpoint has a top-level owner_directives key or a ledger text has content.
    .PARAMETER CheckpointText
        The checkpoint text, or $null.
    .PARAMETER LedgerText
        The ledger text, or $null.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [AllowEmptyString()] [string] $CheckpointText, [AllowNull()] [AllowEmptyString()] [string] $LedgerText)

    if (-not [string]::IsNullOrWhiteSpace($LedgerText)) { return $true }
    return ($null -ne (Get-OwnerDirectiveCheckpointBlockText -CheckpointText $CheckpointText))
}

function New-OrchestratorOutputOwnerPassDownBlock {
    <#
    .SYNOPSIS
        The repairable block decision for a sub-code and detail list.
    .PARAMETER Code
        OWNER_DIRECTIVE_RELAY_MISSING or OWNER_DIRECTIVE_LEDGER_INVALID.
    .PARAMETER Detail
        The detail strings.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Code, [Parameter(Mandatory = $true)] [string[]] $Detail)

    return @{ Ok = $false; Repairable = $true; Message = ('OWNER_DIRECTIVE_BLOCKED: {0}: {1}' -f $Code, ($Detail -join '; ')) }
}

function Get-OrchestratorOutputOwnerPassDownLedgerError {
    <#
    .SYNOPSIS
        The ledger validity errors of a selection, or the empty array.
    .PARAMETER Selection
        The Select-OwnerDirectivePassDown result.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [object] $Selection)

    return [string[]] @($Selection.Errors | Where-Object { $_ -like '*-ledger: *' })
}

function Get-OrchestratorOutputOwnerPassDownParentDecision {
    <#
    .SYNOPSIS
        The relay check of an epic or parallel parent checkpoint.
    .PARAMETER Kind
        epic or parallel.
    .PARAMETER Checkpoint
        The parsed parent checkpoint.
    .PARAMETER CheckpointText
        The parent checkpoint text.
    .PARAMETER LedgerText
        The parent ledger text, or $null.
    .PARAMETER SessionRoot
        The hook process location.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [object] $Checkpoint,
        [Parameter(Mandatory = $true)] [string] $CheckpointText,
        [AllowNull()] [AllowEmptyString()] [string] $LedgerText,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    $now = Get-OrchestratorOutputOwnerPassDownClock
    $isEpic = ($Kind -eq 'epic')
    $sources = @(
        [pscustomobject]@{ Name = 'parent-checkpoint'; Text = (Get-OwnerDirectiveCheckpointBlockText -CheckpointText $CheckpointText); IsEpicParent = $isEpic }
        [pscustomobject]@{ Name = 'parent-ledger'; Text = $LedgerText; IsEpicParent = $isEpic }
    )
    $integrationBranch = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'integration_branch')
    $parallelSlug = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'parallel_slug')
    $parentIssue = $null
    $parentBranch = $null
    if ($isEpic) {
        $parentIssue = ConvertTo-WorktreeItemIssueNumber -Value (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'epic_issue_num')
        $parentBranch = $integrationBranch
    }
    $ledgerErrors = @(Get-OrchestratorOutputOwnerPassDownLedgerError -Selection (Select-OwnerDirectivePassDown -Source $sources -ItemIssue 0 -Now $now))
    if ($ledgerErrors.Count -gt 0) { return (New-OrchestratorOutputOwnerPassDownBlock -Code 'OWNER_DIRECTIVE_LEDGER_INVALID' -Detail $ledgerErrors) }
    $childKey = if ($isEpic) { 'features' } else { 'items' }
    $details = [System.Collections.Generic.List[string]]::new()
    foreach ($child in @(Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name $childKey)) {
        $issue = ConvertTo-WorktreeItemIssueNumber -Value (Get-OrchestratorOutputOwnerPassDownValue -InputObject $child -Name 'issue_num')
        if ($null -eq $issue) { continue }
        $probe = [pscustomobject]@{
            Issue = [long] $issue; Branch = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $child -Name 'branch_name')
            MergeStatus = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $child -Name 'merge_status'); Resolution = 'NotResolved'; CheckpointEntry = @(); LinksBack = $false
        }
        $gapArguments = @{ ParentKind = $Kind; ParentEntry = $sources; ParentIssue = $parentIssue; ParentBranch = $parentBranch; Now = $now }
        if (@(Get-OwnerDirectiveRunningChildGap -Child $probe @gapArguments).Count -eq 0) { continue }
        $resolved = $null
        try { $resolved = Resolve-OrchestratorOutputOwnerPassDownChild -Issue $issue -SessionRoot $SessionRoot } catch { $resolved = $null }
        if ($null -eq $resolved -or [string] $resolved.Status -cne 'Resolved' -or [string]::IsNullOrWhiteSpace([string] $resolved.WorktreeRoot)) {
            $probe.Resolution = if ($null -eq $resolved) { 'NoTarget' } else { [string] $resolved.Status }
        }
        else {
            $childText = Get-OrchestratorOutputOwnerPassDownSourceText -Path (Join-Path ([string] $resolved.WorktreeRoot) 'artifacts/orchestration/orchestrator-state.json') -CheckpointText $CheckpointText
            $childCheckpoint = ConvertFrom-OrchestratorOutputOwnerPassDownJson -Text $childText
            if ($null -eq $childCheckpoint) { $probe.Resolution = 'Unreadable' }
            else {
                $probe.Resolution = 'Resolved'
                $blockText = Get-OwnerDirectiveCheckpointBlockText -CheckpointText $childText
                if ($null -ne $blockText) { $probe.CheckpointEntry = @((Get-OrchestratorStateOwnerDirectiveValidEntry -Text $blockText).Entries) }
                $childBranch = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject (Get-OrchestratorOutputOwnerPassDownValue -InputObject $childCheckpoint -Name 'epic_context') -Name 'integration_branch')
                $childSlug = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $childCheckpoint -Name 'parallel_slug')
                $probe.LinksBack = if ($isEpic) { -not [string]::IsNullOrEmpty($childBranch) -and $childBranch -ceq $integrationBranch } else { -not [string]::IsNullOrEmpty($childSlug) -and $childSlug -ceq $parallelSlug }
            }
        }
        foreach ($gap in @(Get-OwnerDirectiveRunningChildGap -Child $probe @gapArguments)) { $details.Add($gap.Detail) }
    }
    if ($details.Count -gt 0) { return (New-OrchestratorOutputOwnerPassDownBlock -Code 'OWNER_DIRECTIVE_RELAY_MISSING' -Detail $details.ToArray()) }
    return $null
}

function Get-OrchestratorOutputOwnerPassDownItemDecision {
    <#
    .SYNOPSIS
        The relay check of an item checkpoint.
    .PARAMETER Checkpoint
        The parsed item checkpoint.
    .PARAMETER CheckpointText
        The item checkpoint text.
    .PARAMETER LedgerText
        The item ledger text, or $null.
    .PARAMETER WorktreeRoot
        The item worktree root.
    .PARAMETER SessionRoot
        The hook process location.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [object] $Checkpoint,
        [Parameter(Mandatory = $true)] [string] $CheckpointText,
        [AllowNull()] [AllowEmptyString()] [string] $LedgerText,
        [Parameter(Mandatory = $true)] [string] $WorktreeRoot,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    $active = Test-OrchestratorOutputOwnerPassDownSource -CheckpointText $CheckpointText -LedgerText $LedgerText
    $linked = -not [string]::IsNullOrWhiteSpace([string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'epic_context') -Name 'integration_branch')) -or
    -not [string]::IsNullOrWhiteSpace([string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'parallel_slug'))
    $parent = $null
    $parentCheckpointText = $null
    $parentLedgerText = $null
    if ($linked) {
        try { $resolved = Resolve-OrchestratorOutputOwnerPassDownParent -Checkpoint $Checkpoint -SessionRoot $SessionRoot } catch { $resolved = $null }
        if ($null -ne $resolved -and [string] $resolved.Status -in @('SessionRoot', 'OtherWorktree') -and -not [string]::IsNullOrWhiteSpace([string] $resolved.WorktreeRoot)) {
            $parent = $resolved
            $relative = if ($parent.Kind -eq 'epic') { 'artifacts/orchestration/epic-orchestrator-state.json' } else { 'artifacts/orchestration/parallel-orchestrator-state.json' }
            $parentCheckpointText = Get-OrchestratorOutputOwnerPassDownSourceText -Path (Join-Path ([string] $parent.WorktreeRoot) $relative) -CheckpointText $CheckpointText
            $parentLedgerText = Get-OrchestratorOutputOwnerPassDownSourceText -Path (Join-Path ([string] $parent.WorktreeRoot) 'artifacts/orchestration/owner-directives.jsonl') -CheckpointText $CheckpointText
            if (Test-OrchestratorOutputOwnerPassDownSource -CheckpointText $parentCheckpointText -LedgerText $parentLedgerText) { $active = $true }
        }
    }
    if (-not $active) { return $null }
    $issue = ConvertTo-WorktreeItemIssueNumber -Value (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'issue-num')
    if ($null -eq $issue) { return $null }

    $isEpic = ($null -ne $parent -and $parent.Kind -eq 'epic')
    $sources = [System.Collections.Generic.List[object]]::new()
    $sources.Add([pscustomobject]@{ Name = 'item-checkpoint'; Text = (Get-OwnerDirectiveCheckpointBlockText -CheckpointText $CheckpointText); IsEpicParent = $false })
    $sources.Add([pscustomobject]@{ Name = 'item-ledger'; Text = $LedgerText; IsEpicParent = $false })
    $parentIssue = $null
    if ($null -ne $parent) {
        $sources.Add([pscustomobject]@{ Name = 'parent-checkpoint'; Text = (Get-OwnerDirectiveCheckpointBlockText -CheckpointText $parentCheckpointText); IsEpicParent = $isEpic })
        $sources.Add([pscustomobject]@{ Name = 'parent-ledger'; Text = $parentLedgerText; IsEpicParent = $isEpic })
        if ($isEpic) { $parentIssue = ConvertTo-WorktreeItemIssueNumber -Value (Get-OrchestratorOutputOwnerPassDownValue -InputObject (ConvertFrom-OrchestratorOutputOwnerPassDownJson -Text $parentCheckpointText) -Name 'epic_issue_num') }
    }
    $now = Get-OrchestratorOutputOwnerPassDownClock
    $parentBranch = if ($isEpic) { [string] $parent.IntegrationBranch } else { $null }
    $branch = Get-OrchestratorOutputOwnerPassDownItemBranch -WorktreeRoot $WorktreeRoot -SessionRoot $SessionRoot
    $selection = Select-OwnerDirectivePassDown -Source $sources.ToArray() -ItemIssue ([long] $issue) -ItemBranch $branch -ItemStep ([string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $Checkpoint -Name 'next_step')) -ParentIssue $parentIssue -ParentBranch $parentBranch -Now $now
    $ledgerErrors = @(Get-OrchestratorOutputOwnerPassDownLedgerError -Selection $selection)
    if ($ledgerErrors.Count -gt 0) { return (New-OrchestratorOutputOwnerPassDownBlock -Code 'OWNER_DIRECTIVE_LEDGER_INVALID' -Detail $ledgerErrors) }
    $held = @()
    $blockText = $sources[0].Text
    if ($null -ne $blockText) { $held = @((Get-OrchestratorStateOwnerDirectiveValidEntry -Text $blockText).Entries) }
    $details = [System.Collections.Generic.List[string]]::new()
    foreach ($conflict in $selection.Conflicts) { $details.Add(('{0} in {1} has a different text_sha256 than in {2}' -f $conflict.Id, $conflict.OtherSource, $conflict.KeptSource)) }
    foreach ($entry in @(Get-OwnerDirectiveCheckpointGap -Selected @($selection.Selected) -CheckpointEntry $held)) {
        $details.Add(('the item checkpoint owner_directives lacks {0} selected from {1}; append {2}' -f $entry.Id, $entry.Source, $entry.Json))
    }
    if ($details.Count -gt 0) { return (New-OrchestratorOutputOwnerPassDownBlock -Code 'OWNER_DIRECTIVE_RELAY_MISSING' -Detail $details.ToArray()) }
    return $null
}

function Get-OrchestratorOutputOwnerPassDownDecision {
    <#
    .SYNOPSIS
        The owner-directive relay decision for a checkpoint, or $null when the check allows or is inactive.
    .PARAMETER ArtifactType
        orchestrator-state, epic-orchestrator-state, or parallel-orchestrator-state.
    .PARAMETER CheckpointText
        The checkpoint text the stop hook read.
    .PARAMETER WorktreeRoot
        The worktree root that holds the checkpoint.
    .PARAMETER SessionRoot
        The hook process location; defaults to WorktreeRoot.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $ArtifactType,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $CheckpointText,
        [Parameter(Mandatory = $true)] [string] $WorktreeRoot,
        [string] $SessionRoot
    )

    if ([string]::IsNullOrWhiteSpace($SessionRoot)) { $SessionRoot = $WorktreeRoot }
    $checkpoint = ConvertFrom-OrchestratorOutputOwnerPassDownJson -Text $CheckpointText
    if ($null -eq $checkpoint) { return $null }
    $routeId = [string] (Get-OrchestratorOutputOwnerPassDownValue -InputObject $checkpoint -Name 'route_id')
    $kind = switch ($ArtifactType) {
        'epic-orchestrator-state' { 'epic' }
        'parallel-orchestrator-state' { 'parallel' }
        default { if ($routeId -ceq 'epic' -or $routeId -ceq 'parallel') { $routeId } else { 'item' } }
    }
    $ledgerText = Get-OrchestratorOutputOwnerPassDownSourceText -Path (Join-Path $WorktreeRoot 'artifacts/orchestration/owner-directives.jsonl') -CheckpointText $CheckpointText
    if ($kind -eq 'item') {
        return (Get-OrchestratorOutputOwnerPassDownItemDecision -Checkpoint $checkpoint -CheckpointText $CheckpointText -LedgerText $ledgerText -WorktreeRoot $WorktreeRoot -SessionRoot $SessionRoot)
    }
    if (-not (Test-OrchestratorOutputOwnerPassDownSource -CheckpointText $CheckpointText -LedgerText $ledgerText)) { return $null }
    return (Get-OrchestratorOutputOwnerPassDownParentDecision -Kind $kind -Checkpoint $checkpoint -CheckpointText $CheckpointText -LedgerText $ledgerText -SessionRoot $SessionRoot)
}
