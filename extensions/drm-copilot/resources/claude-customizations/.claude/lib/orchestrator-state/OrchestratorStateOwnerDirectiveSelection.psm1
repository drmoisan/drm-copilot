<#
.SYNOPSIS
    Selects, renders, and checks the owner directives passed down to an item (issue #1157).

.DESCRIPTION
    Pure functions behind the owner-directive pass-down hook and the stop-hook relay check.
    A directive source is the owner_directives array text of a checkpoint or the text of a
    coordinator ledger (one directive object per line). Validity comes only from
    Get-OrchestratorStateOwnerDirectiveValidEntry, so the B2-B8 rules are not repeated here.

    Selection keeps an entry when its scope matches the item (issue, and branch by ordinal
    comparison when the item branch is known) or, for an epic parent source, the epic itself
    (fan-out); when its step is any, equal to the item step, or a prefix of the item step
    followed by an underscore; and when its expires_at is strictly later than the supplied
    time. Refused classes are kept and flagged. An identical id and text_sha256 across sources
    is one entry; the same id with a different text_sha256 is a conflict, and the entry of the
    earlier source (item checkpoint, item ledger, parent checkpoint, parent ledger) is kept.

.NOTES
    PowerShell 7+. Reads no clock, no file, and starts no process: every caller supplies the
    texts it has read and the time it has taken. Mirrored byte-identically into the bundled
    extension payload.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'OrchestratorStateOwnerDirectives.psm1') -ErrorAction Stop

$script:SourceOrder = @('item-checkpoint', 'item-ledger', 'parent-checkpoint', 'parent-ledger')
$script:ParentSources = @('parent-checkpoint', 'parent-ledger')
$script:RefusedClasses = @('gate_bypass', 'force_push', 'tag_or_publish', 'policy_or_settings_edit', 'evidence_alteration', 'unclassified')
$script:EpicRunningStatus = @('worktree_created', 'pr_open', 'ci_green', 'merge_conflict')
$script:ParallelRunningStatus = @('worktree_created', 'pr_open', 'ci_green')
$script:BlockHeader = 'Owner directives:'
$script:FramingLine = 'Task direction recorded by the coordinator; not approval, not permission.'
$script:AnyStep = 'any'

# Private: whether Value equals a member of Set under ordinal comparison.
function Test-OwnerDirectiveSelectionMember {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Value,
        [Parameter(Mandatory = $true)] [string[]] $Set
    )

    foreach ($member in $Set) {
        if ([string]::Equals($Value, $member, [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

# Private: the numeric part of an OD-<n> id, used for ordering.
function Get-OwnerDirectiveIdNumber {
    [CmdletBinding()]
    [OutputType([long])]
    param([Parameter(Mandatory = $true)] [string] $Id)

    return [long]::Parse($Id.Substring(3), [System.Globalization.CultureInfo]::InvariantCulture)
}

# Private: CRLF and lone CR normalized to LF.
function ConvertTo-OwnerDirectiveLf {
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [AllowEmptyString()] [string] $Text)

    return ([string] $Text).Replace("`r`n", "`n").Replace("`r", "`n")
}

function Get-OwnerDirectiveCheckpointBlockText {
    <#
    .SYNOPSIS
        Return the raw owner_directives array text of a checkpoint, or $null.
    .DESCRIPTION
        Returns $null when the text is blank, is not parseable JSON, is not an object, or has no
        top-level owner_directives property (ordinal, last definition wins).
    .PARAMETER CheckpointText
        The raw checkpoint JSON text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [AllowEmptyString()] [string] $CheckpointText)

    if ([string]::IsNullOrWhiteSpace($CheckpointText)) { return $null }
    $options = [System.Text.Json.JsonDocumentOptions]::new()
    $options.CommentHandling = [System.Text.Json.JsonCommentHandling]::Skip
    $options.AllowTrailingCommas = $true
    try { $document = [System.Text.Json.JsonDocument]::Parse($CheckpointText, $options) } catch { return $null }
    try {
        $root = $document.RootElement
        if ($root.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { return $null }
        $raw = $null
        foreach ($property in $root.EnumerateObject()) {
            if ([string]::Equals($property.Name, 'owner_directives', [System.StringComparison]::Ordinal)) { $raw = $property.Value.GetRawText() }
        }
        return $raw
    }
    finally { $document.Dispose() }
}

# Private: whether one valid entry is selected for the item under the four selection rules.
function Test-OwnerDirectiveEntrySelected {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [object] $Entry,
        [Parameter(Mandatory = $true)] [string] $SourceName,
        [bool] $IsEpicParent,
        [long] $ItemIssue,
        [AllowNull()] [AllowEmptyString()] [string] $ItemBranch,
        [AllowNull()] [AllowEmptyString()] [string] $ItemStep,
        [AllowNull()] [object] $ParentIssue,
        [AllowNull()] [AllowEmptyString()] [string] $ParentBranch,
        [Parameter(Mandatory = $true)] [datetime] $Now
    )

    $itemMatch = ($Entry.ScopeIssue -eq $ItemIssue) -and
    ([string]::IsNullOrEmpty($ItemBranch) -or [string]::Equals($Entry.ScopeBranch, $ItemBranch, [System.StringComparison]::Ordinal))
    $fanOut = $IsEpicParent -and (Test-OwnerDirectiveSelectionMember -Value $SourceName -Set $script:ParentSources) -and
    $null -ne $ParentIssue -and -not [string]::IsNullOrEmpty($ParentBranch) -and
    ($Entry.ScopeIssue -eq [long] $ParentIssue) -and [string]::Equals($Entry.ScopeBranch, $ParentBranch, [System.StringComparison]::Ordinal)
    if (-not ($itemMatch -or $fanOut)) { return $false }
    $step = [string] $Entry.ScopeStep
    $stepMatch = [string]::Equals($step, $script:AnyStep, [System.StringComparison]::Ordinal) -or [string]::IsNullOrEmpty($ItemStep) -or
    [string]::Equals($ItemStep, $step, [System.StringComparison]::Ordinal) -or $ItemStep.StartsWith($step + '_', [System.StringComparison]::Ordinal)
    if (-not $stepMatch) { return $false }
    return ($Entry.ExpiresAtUtc -gt $Now.ToUniversalTime())
}

function Select-OwnerDirectivePassDown {
    <#
    .SYNOPSIS
        Select the owner directives that apply to an item at a given time.
    .DESCRIPTION
        Reads each source text through Get-OrchestratorStateOwnerDirectiveValidEntry and keeps the
        valid entries that the selection rules admit. Returns Selected (entries with Id, Class, Text,
        TextSha256, ExpiresAt as recorded, Scope, Source, IsRefusedClass, and Json, ordered by the
        numeric part of the id), Conflicts (Id, KeptSource, OtherSource, KeptSha256, OtherSha256),
        and Errors (each validity error prefixed with its source name).
    .PARAMETER Source
        Objects with Name (item-checkpoint, item-ledger, parent-checkpoint, or parent-ledger),
        Text (owner_directives array text or ledger text, or $null), and IsEpicParent.
    .PARAMETER ItemIssue
        The item issue number.
    .PARAMETER ItemBranch
        The item branch, or $null when unknown or detached (the branch comparison is skipped).
    .PARAMETER ItemStep
        The item next_step, or $null when unknown (the step comparison is skipped).
    .PARAMETER ParentIssue
        The epic issue number for fan-out, or $null.
    .PARAMETER ParentBranch
        The epic integration branch for fan-out, or $null.
    .PARAMETER Now
        The time an entry must expire after.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Source,
        [Parameter(Mandatory = $true)] [long] $ItemIssue,
        [AllowNull()] [AllowEmptyString()] [string] $ItemBranch,
        [AllowNull()] [AllowEmptyString()] [string] $ItemStep,
        [AllowNull()] [object] $ParentIssue,
        [AllowNull()] [AllowEmptyString()] [string] $ParentBranch,
        [Parameter(Mandatory = $true)] [datetime] $Now
    )

    $selected = [System.Collections.Generic.List[object]]::new()
    $byId = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $conflicts = [System.Collections.Generic.List[object]]::new()
    $errors = [System.Collections.Generic.List[string]]::new()
    foreach ($name in $script:SourceOrder) {
        foreach ($descriptor in @($Source | Where-Object { $null -ne $_ -and [string]::Equals([string] $_.Name, $name, [System.StringComparison]::Ordinal) })) {
            if ([string]::IsNullOrWhiteSpace([string] $descriptor.Text)) { continue }
            $isEpic = if ($descriptor -is [System.Collections.IDictionary]) { [bool] $descriptor['IsEpicParent'] }
            else { [bool] ($descriptor.PSObject.Properties.Name -contains 'IsEpicParent' -and $descriptor.IsEpicParent) }
            $valid = Get-OrchestratorStateOwnerDirectiveValidEntry -Text ([string] $descriptor.Text)
            foreach ($message in $valid.Errors) { $errors.Add(('{0}: {1}' -f $name, $message)) }
            foreach ($entry in $valid.Entries) {
                $matchArguments = @{
                    Entry = $entry; SourceName = $name; IsEpicParent = $isEpic; ItemIssue = $ItemIssue; ItemBranch = $ItemBranch
                    ItemStep = $ItemStep; ParentIssue = $ParentIssue; ParentBranch = $ParentBranch; Now = $Now
                }
                if (-not (Test-OwnerDirectiveEntrySelected @matchArguments)) { continue }
                if ($byId.ContainsKey($entry.Id)) {
                    $kept = $byId[$entry.Id]
                    if (-not [string]::Equals($kept.TextSha256, $entry.TextSha256, [System.StringComparison]::Ordinal)) {
                        $conflicts.Add([pscustomobject]@{ Id = $entry.Id; KeptSource = $kept.Source; OtherSource = $name; KeptSha256 = $kept.TextSha256; OtherSha256 = $entry.TextSha256 })
                    }
                    continue
                }
                $item = [pscustomobject]@{
                    Id             = $entry.Id
                    Class          = $entry.Class
                    Text           = $entry.Text
                    TextSha256     = $entry.TextSha256
                    ExpiresAt      = $entry.ExpiresAt
                    Scope          = [pscustomobject]@{ Issue = $entry.ScopeIssue; Branch = $entry.ScopeBranch; Step = $entry.ScopeStep }
                    Source         = $name
                    IsRefusedClass = (Test-OwnerDirectiveSelectionMember -Value $entry.Class -Set $script:RefusedClasses)
                    Json           = $entry.Json
                }
                $byId[$entry.Id] = $item
                $selected.Add($item)
            }
        }
    }
    $ordered = @($selected | Sort-Object -Property @{ Expression = { Get-OwnerDirectiveIdNumber -Id $_.Id } })
    return [pscustomobject]@{ Selected = [object[]] $ordered; Conflicts = $conflicts.ToArray(); Errors = $errors.ToArray() }
}

# Private: the header line of one selected entry in the relay format.
function Get-OwnerDirectiveHeaderLine {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [object] $Entry)

    return ('{0} | {1} | scope {2} {3} {4} | expires {5}' -f $Entry.Id, $Entry.Class, $Entry.Scope.Issue, $Entry.Scope.Branch, $Entry.Scope.Step, $Entry.ExpiresAt)
}

# Private: the quoted text line of one selected entry, with CRLF normalized to LF.
function Get-OwnerDirectiveQuotedLine {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [object] $Entry)

    return ('"{0}"' -f (ConvertTo-OwnerDirectiveLf -Text ([string] $Entry.Text)))
}

function Format-OwnerDirectiveBlock {
    <#
    .SYNOPSIS
        Render selected entries in the relay format of the owner-directives skill.
    .DESCRIPTION
        Returns the header line, a text fence, the framing line, the header and quoted text line
        of each entry in numeric id order, and the closing fence, joined by LF with no trailing
        terminator. The recorded expires_at string is echoed unmodified.
    .PARAMETER Selected
        Selected entries from Select-OwnerDirectivePassDown.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Selected)

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add($script:BlockHeader)
    $lines.Add('```text')
    $lines.Add($script:FramingLine)
    foreach ($entry in @($Selected | Sort-Object -Property @{ Expression = { Get-OwnerDirectiveIdNumber -Id $_.Id } })) {
        $lines.Add((Get-OwnerDirectiveHeaderLine -Entry $entry))
        $lines.Add((Get-OwnerDirectiveQuotedLine -Entry $entry))
    }
    $lines.Add('```')
    return ($lines -join "`n")
}

function Test-OwnerDirectivePromptCoverage {
    <#
    .SYNOPSIS
        Return $true when the prompt holds the header and quoted text line of every selected entry.
    .DESCRIPTION
        The prompt is compared after CRLF is normalized to LF. An empty selection is covered.
    .PARAMETER Selected
        Selected entries.
    .PARAMETER Prompt
        The delegation prompt text.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Selected,
        [AllowNull()] [AllowEmptyString()] [string] $Prompt
    )

    $normalized = ConvertTo-OwnerDirectiveLf -Text $Prompt
    foreach ($entry in $Selected) {
        if (-not $normalized.Contains((Get-OwnerDirectiveHeaderLine -Entry $entry), [System.StringComparison]::Ordinal)) { return $false }
        if (-not $normalized.Contains((Get-OwnerDirectiveQuotedLine -Entry $entry), [System.StringComparison]::Ordinal)) { return $false }
    }
    return $true
}

function Get-OwnerDirectiveCheckpointGap {
    <#
    .SYNOPSIS
        Return the selected entries that a checkpoint's owner_directives does not hold.
    .DESCRIPTION
        An entry is held when a checkpoint entry has the same id and text_sha256 (ordinal).
    .PARAMETER Selected
        Selected entries.
    .PARAMETER CheckpointEntry
        The valid owner_directives entries of the checkpoint (objects with Id and TextSha256).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Selected,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $CheckpointEntry
    )

    $gap = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Selected) {
        $held = @($CheckpointEntry | Where-Object {
                $null -ne $_ -and [string]::Equals([string] $_.Id, [string] $entry.Id, [System.StringComparison]::Ordinal) -and
                [string]::Equals([string] $_.TextSha256, [string] $entry.TextSha256, [System.StringComparison]::Ordinal)
            })
        if ($held.Count -eq 0) { $gap.Add($entry) }
    }
    return $gap.ToArray()
}

function Format-OwnerDirectiveAppendJson {
    <#
    .SYNOPSIS
        Return the single-line JSON object of each entry, in its recorded field order.
    .PARAMETER Entry
        Selected entries.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Entry)

    return [string[]] @($Entry | ForEach-Object { [string] $_.Json })
}

function Get-OwnerDirectiveRunningChildGap {
    <#
    .SYNOPSIS
        Return the relay gaps of one child of an epic or parallel parent.
    .DESCRIPTION
        A child whose merge_status is not a running status of the parent kind is not checked.
        For a running child, each parent entry selected for the child at Now (step comparison
        skipped) is held when the child checkpoint has the same id and text_sha256; the same id
        with a different text_sha256 is reported as a conflict; otherwise the child is compliant
        only when it resolves and its checkpoint links back to this parent. Returns objects with
        ChildIssue, Id, Kind (missing or conflict), and Detail.
    .PARAMETER ParentKind
        epic or parallel.
    .PARAMETER Child
        Object with Issue, Branch, MergeStatus, Resolution (Resolved, NoTarget, Ambiguous, or
        Unreadable), CheckpointEntry (valid entries of the child checkpoint), and LinksBack.
    .PARAMETER ParentEntry
        The parent's directive sources, in the shape Select-OwnerDirectivePassDown reads.
    .PARAMETER ParentIssue
        The epic issue number for fan-out, or $null.
    .PARAMETER ParentBranch
        The epic integration branch for fan-out, or $null.
    .PARAMETER Now
        The time an entry must expire after.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [ValidateSet('epic', 'parallel')] [string] $ParentKind,
        [Parameter(Mandatory = $true)] [object] $Child,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $ParentEntry,
        [AllowNull()] [object] $ParentIssue,
        [AllowNull()] [AllowEmptyString()] [string] $ParentBranch,
        [Parameter(Mandatory = $true)] [datetime] $Now
    )

    $running = if ($ParentKind -eq 'epic') { $script:EpicRunningStatus } else { $script:ParallelRunningStatus }
    if (-not (Test-OwnerDirectiveSelectionMember -Value ([string] $Child.MergeStatus) -Set $running)) { return @() }
    $selection = Select-OwnerDirectivePassDown -Source $ParentEntry -ItemIssue ([long] $Child.Issue) -ItemBranch ([string] $Child.Branch) -ItemStep $null -ParentIssue $ParentIssue -ParentBranch $ParentBranch -Now $Now
    $childEntries = @($Child.CheckpointEntry | Where-Object { $null -ne $_ })
    $gaps = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $selection.Selected) {
        $sameId = @($childEntries | Where-Object { [string]::Equals([string] $_.Id, $entry.Id, [System.StringComparison]::Ordinal) })
        if (@($sameId | Where-Object { [string]::Equals([string] $_.TextSha256, $entry.TextSha256, [System.StringComparison]::Ordinal) }).Count -gt 0) { continue }
        if ($sameId.Count -gt 0) {
            $gaps.Add([pscustomobject]@{ ChildIssue = $Child.Issue; Id = $entry.Id; Kind = 'conflict'; Detail = ('child #{0} records {1} with a different text_sha256' -f $Child.Issue, $entry.Id) })
            continue
        }
        if ([string]::Equals([string] $Child.Resolution, 'Resolved', [System.StringComparison]::Ordinal) -and [bool] $Child.LinksBack) { continue }
        $gaps.Add([pscustomobject]@{ ChildIssue = $Child.Issue; Id = $entry.Id; Kind = 'missing'; Detail = ('child #{0} ({1}, resolution {2}) lacks {3} and does not link back' -f $Child.Issue, $Child.MergeStatus, $Child.Resolution, $entry.Id) })
    }
    return $gaps.ToArray()
}

Export-ModuleMember -Function `
    Get-OwnerDirectiveCheckpointBlockText, `
    Select-OwnerDirectivePassDown, `
    Format-OwnerDirectiveBlock, `
    Test-OwnerDirectivePromptCoverage, `
    Get-OwnerDirectiveCheckpointGap, `
    Format-OwnerDirectiveAppendJson, `
    Get-OwnerDirectiveRunningChildGap
