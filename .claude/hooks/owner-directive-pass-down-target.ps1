<#
.SYNOPSIS
    Item and parent resolution, directive-source reads, and the clock seam of the owner-directive
    pass-down hook (issue #1157).

.DESCRIPTION
    Dot-sourced by enforce-owner-directive-pass-down.ps1 under the guarded single-statement
    pattern. Holds functions only; the entry file imports the modules these functions call
    (HookTargetWorktree.psm1, WorktreeItemResolution.psm1, WorktreeRunResolution.psm1, and
    OrchestratorStateOwnerDirectiveSelection.psm1) and dot-sources subagentstop-target-worktree.ps1
    for the transcript readers.

    The item root is the registered worktree enclosing the payload cwd when that worktree holds
    artifacts/orchestration/orchestrator-state.json; otherwise the worktree named by the delegation
    prompt read from the subagent transcript; otherwise there is no root and the hook is inert.
    The parent is the epic worktree named by epic_context.integration_branch or the parallel
    worktree named by parallel_slug. The four directive sources are the item checkpoint, the item
    ledger, the parent checkpoint, and the parent ledger.

    The file also holds the deny factory New-OwnerDirectivePassDownDeny and the ledger guard
    Get-OwnerDirectivePassDownLedgerDecision, which the entry file calls for a ledger write
    (OrchestratorStateOwnerDirectiveDecision.psm1 supplies the append-only check).

.NOTES
    PowerShell 7+. Every file read, the worktree listing, the resolvers, and the clock are
    injectable script-block parameters with defaults, so tests supply in-memory content and a
    fixed time. Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>


function Get-OwnerDirectiveClock {
    <#
    .SYNOPSIS
        Clock seam: the current UTC time. Tests inject a fixed value instead.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param()

    return [DateTime]::UtcNow
}

function Read-OwnerDirectiveFileText {
    <#
    .SYNOPSIS
        File seam: the text of a file, or $null when it does not exist or cannot be read.
    .PARAMETER Path
        The absolute path.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    if (-not [System.IO.File]::Exists($Path)) { return $null }
    try { return [System.IO.File]::ReadAllText($Path) } catch { return $null }
}

function Test-OwnerDirectiveFileExist {
    <#
    .SYNOPSIS
        File seam: whether a file exists.
    .PARAMETER Path
        The absolute path.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    return [System.IO.File]::Exists($Path)
}

function Get-OwnerDirectivePropertyValue {
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

function ConvertFrom-OwnerDirectiveJsonObject {
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

function Get-OwnerDirectiveSubagentTranscriptPath {
    <#
    .SYNOPSIS
        The transcript path of a subagent, derived from the payload transcript_path.
    .DESCRIPTION
        Returns transcript_path itself when its file name is agent-<agent_id>.jsonl; otherwise,
        for a root session transcript ending in .jsonl, the subagents/agent-<agent_id>.jsonl path
        beside it; otherwise $null. A leading ~ is expanded.
    .PARAMETER TranscriptPath
        The payload transcript_path.
    .PARAMETER AgentId
        The payload agent_id.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $TranscriptPath,
        [AllowNull()] [AllowEmptyString()] [string] $AgentId
    )

    if ([string]::IsNullOrWhiteSpace($TranscriptPath) -or [string]::IsNullOrWhiteSpace($AgentId)) { return $null }
    $path = $TranscriptPath.Replace('\', '/')
    if ($path.StartsWith('~')) { $path = $HOME.Replace('\', '/') + $path.Substring(1) }
    $leaf = $path.Substring($path.LastIndexOf('/') + 1)
    $expected = 'agent-' + $AgentId + '.jsonl'
    if ([string]::Equals($leaf, $expected, [System.StringComparison]::Ordinal)) { return $path }
    if (-not $path.EndsWith('.jsonl', [System.StringComparison]::Ordinal)) { return $null }
    return ($path.Substring(0, $path.Length - 6) + '/subagents/' + $expected)
}

function Resolve-OwnerDirectiveItemRoot {
    <#
    .SYNOPSIS
        Resolve the item worktree root of a running worker, or $null.
    .DESCRIPTION
        The registered worktree enclosing the payload cwd decides when it holds the item
        checkpoint. Otherwise the delegation prompt read from the subagent transcript decides
        through its branch: label and canonical issue line. Otherwise the result is $null.
        Returns an object with Root and Source (Cwd or Transcript).
    .PARAMETER Cwd
        The payload cwd.
    .PARAMETER TranscriptPath
        The payload transcript_path.
    .PARAMETER AgentId
        The payload agent_id.
    .PARAMETER SessionRoot
        The hook process location.
    .PARAMETER ReadText
        { param($Path) <text or $null> }.
    .PARAMETER ReadTranscriptHead
        { param($Path) <JSONL lines or $null> }.
    .PARAMETER WorktreeListInvoker
        { param($SessionRoot) <porcelain text> }.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Cwd,
        [AllowNull()] [AllowEmptyString()] [string] $TranscriptPath,
        [AllowNull()] [AllowEmptyString()] [string] $AgentId,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [scriptblock] $ReadText = { param($Path) Read-OwnerDirectiveFileText -Path $Path },
        [scriptblock] $ReadTranscriptHead = { param($Path) Read-TranscriptHead -Path $Path },
        [scriptblock] $WorktreeListInvoker = { param($SessionRoot) $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null; if ($LASTEXITCODE -ne 0) { return '' }; return ($porcelain -join "`n") }
    )

    if (-not [string]::IsNullOrWhiteSpace($Cwd)) {
        $byCwd = Resolve-HookTargetWorktree -SessionRoot $SessionRoot -FilePath @($Cwd) -WorktreeListInvoker $WorktreeListInvoker
        if ($null -ne $byCwd.WorktreeRoot -and $null -ne (& $ReadText (Join-Path $byCwd.WorktreeRoot 'artifacts/orchestration/orchestrator-state.json'))) {
            return [pscustomobject]@{ Root = [string] $byCwd.WorktreeRoot; Source = 'Cwd' }
        }
    }
    $transcript = Get-OwnerDirectiveSubagentTranscriptPath -TranscriptPath $TranscriptPath -AgentId $AgentId
    if ($null -eq $transcript) { return $null }
    $head = $null
    try { $head = & $ReadTranscriptHead $transcript } catch { $head = $null }
    if ($null -eq $head) { return $null }
    $identity = Get-SubagentStopIdentityPrompt -Prompt (Get-TranscriptFirstUserText -Lines ([string[]] @($head)))
    if ($null -eq $identity) { return $null }
    $resolverArguments = @{ SessionRoot = $SessionRoot; DelegationPrompt = $identity; WorktreeListInvoker = $WorktreeListInvoker }
    $resolverArguments['CheckpointIssueReader'] = {
        param($WorktreeRoot)
        $parsed = ConvertFrom-OwnerDirectiveJsonObject -Text (& $ReadText (Join-Path $WorktreeRoot 'artifacts/orchestration/orchestrator-state.json'))
        $value = Get-OwnerDirectivePropertyValue -InputObject $parsed -Name 'issue-num'
        if ($null -eq $value) { return $null }
        return (ConvertTo-WorktreeItemIssueNumber -Value $value)
    }
    $byPrompt = Resolve-HookTargetWorktree @resolverArguments
    if ($null -eq $byPrompt.WorktreeRoot -or $null -ne $byPrompt.ReasonCode) { return $null }
    return [pscustomobject]@{ Root = [string] $byPrompt.WorktreeRoot; Source = 'Transcript' }
}

function Resolve-OwnerDirectiveParentRoot {
    <#
    .SYNOPSIS
        Resolve the epic or parallel parent of an item checkpoint, or $null.
    .DESCRIPTION
        epic_context.integration_branch resolves through the epic resolver and parallel_slug
        through the parallel resolver. Returns Kind, Root, IntegrationBranch, and ParallelSlug for
        a resolved parent; $null when the checkpoint links to no parent, the resolver does not
        resolve, or it throws.
    .PARAMETER Checkpoint
        The parsed item checkpoint, or $null.
    .PARAMETER SessionRoot
        The hook process location.
    .PARAMETER EpicResolver
        { param($IntegrationBranch, $SessionRoot) <target result> }.
    .PARAMETER ParallelResolver
        { param($ParallelSlug, $SessionRoot) <target result> }.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [object] $Checkpoint,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [scriptblock] $EpicResolver = { param($IntegrationBranch, $SessionRoot) Resolve-WorktreeEpicTarget -IntegrationBranch $IntegrationBranch -SessionRoot $SessionRoot },
        [scriptblock] $ParallelResolver = { param($ParallelSlug, $SessionRoot) Resolve-WorktreeParallelTarget -ParallelSlug $ParallelSlug -SessionRoot $SessionRoot }
    )

    $epicContext = Get-OwnerDirectivePropertyValue -InputObject $Checkpoint -Name 'epic_context'
    $integrationBranch = [string] (Get-OwnerDirectivePropertyValue -InputObject $epicContext -Name 'integration_branch')
    $parallelSlug = [string] (Get-OwnerDirectivePropertyValue -InputObject $Checkpoint -Name 'parallel_slug')
    try {
        if (-not [string]::IsNullOrWhiteSpace($integrationBranch)) {
            $kind = 'epic'
            $result = & $EpicResolver $integrationBranch $SessionRoot
        }
        elseif (-not [string]::IsNullOrWhiteSpace($parallelSlug)) {
            $kind = 'parallel'
            $result = & $ParallelResolver $parallelSlug $SessionRoot
        }
        else { return $null }
    }
    catch { return $null }
    if ($null -eq $result -or [string] $result.Status -notin @('SessionRoot', 'OtherWorktree') -or [string]::IsNullOrWhiteSpace([string] $result.WorktreeRoot)) { return $null }
    return [pscustomobject]@{ Kind = $kind; Root = [string] $result.WorktreeRoot; IntegrationBranch = $integrationBranch; ParallelSlug = $parallelSlug }
}

function Get-OwnerDirectiveItemBranch {
    <#
    .SYNOPSIS
        The branch checked out in the item root, or $null when detached, unlisted, or unknown.
    .PARAMETER ItemRoot
        The item worktree root.
    .PARAMETER SessionRoot
        The hook process location.
    .PARAMETER WorktreeListInvoker
        { param($SessionRoot) <porcelain text> }.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $ItemRoot,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [scriptblock] $WorktreeListInvoker = { param($SessionRoot) $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null; if ($LASTEXITCODE -ne 0) { return '' }; return ($porcelain -join "`n") }
    )

    try { $records = @(ConvertFrom-HookTargetWorktreePorcelain -Text (@(& $WorktreeListInvoker $SessionRoot) -join "`n")) } catch { return $null }
    $root = ConvertTo-HookTargetWorktreeNormalizedPath -Path $ItemRoot
    foreach ($record in $records) {
        if ([string]::Equals([string] $record.Root, $root, [System.StringComparison]::OrdinalIgnoreCase)) { return $record.Branch }
    }
    return $null
}

function Get-OwnerDirectiveSourceSet {
    <#
    .SYNOPSIS
        Read the four directive sources of an item.
    .DESCRIPTION
        Returns descriptors with Name, Text, and IsEpicParent for the item checkpoint (its
        owner_directives array text), the item ledger, and, when a parent is given, the parent
        checkpoint and the parent ledger. An absent file contributes a $null Text.
    .PARAMETER ItemRoot
        The item worktree root.
    .PARAMETER ItemCheckpointText
        The item checkpoint text already read, or $null.
    .PARAMETER Parent
        The Resolve-OwnerDirectiveParentRoot result, or $null.
    .PARAMETER ReadText
        { param($Path) <text or $null> }.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [string] $ItemRoot,
        [AllowNull()] [AllowEmptyString()] [string] $ItemCheckpointText,
        [AllowNull()] [object] $Parent,
        [scriptblock] $ReadText = { param($Path) Read-OwnerDirectiveFileText -Path $Path }
    )

    $sources = [System.Collections.Generic.List[object]]::new()
    $sources.Add([pscustomobject]@{ Name = 'item-checkpoint'; Text = (Get-OwnerDirectiveCheckpointBlockText -CheckpointText $ItemCheckpointText); IsEpicParent = $false })
    $sources.Add([pscustomobject]@{ Name = 'item-ledger'; Text = (& $ReadText (Join-Path $ItemRoot 'artifacts/orchestration/owner-directives.jsonl')); IsEpicParent = $false })
    if ($null -ne $Parent) {
        $relative = if ($Parent.Kind -eq 'epic') { 'artifacts/orchestration/epic-orchestrator-state.json' } else { 'artifacts/orchestration/parallel-orchestrator-state.json' }
        $isEpic = ($Parent.Kind -eq 'epic')
        $sources.Add([pscustomobject]@{ Name = 'parent-checkpoint'; Text = (Get-OwnerDirectiveCheckpointBlockText -CheckpointText (& $ReadText (Join-Path $Parent.Root $relative))); IsEpicParent = $isEpic })
        $sources.Add([pscustomobject]@{ Name = 'parent-ledger'; Text = (& $ReadText (Join-Path $Parent.Root 'artifacts/orchestration/owner-directives.jsonl')); IsEpicParent = $isEpic })
    }
    return $sources.ToArray()
}

function Get-OwnerDirectiveParentIssue {
    <#
    .SYNOPSIS
        The epic_issue_num of an epic parent checkpoint, or $null.
    .PARAMETER Parent
        The Resolve-OwnerDirectiveParentRoot result, or $null.
    .PARAMETER ReadText
        { param($Path) <text or $null> }.
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [AllowNull()] [object] $Parent,
        [scriptblock] $ReadText = { param($Path) Read-OwnerDirectiveFileText -Path $Path }
    )

    if ($null -eq $Parent -or $Parent.Kind -ne 'epic') { return $null }
    $parsed = ConvertFrom-OwnerDirectiveJsonObject -Text (& $ReadText (Join-Path $Parent.Root 'artifacts/orchestration/epic-orchestrator-state.json'))
    $number = ConvertTo-WorktreeItemIssueNumber -Value (Get-OwnerDirectivePropertyValue -InputObject $parsed -Name 'epic_issue_num')
    if ($null -eq $number) { return $null }
    return [long] $number
}

function Get-OwnerDirectiveExistingDecisionId {
    <#
    .SYNOPSIS
        The ids of the selected entries whose decision file exists for an agent.
    .PARAMETER ItemRoot
        The item worktree root.
    .PARAMETER AgentId
        The deciding agent id.
    .PARAMETER Selected
        Selected entries.
    .PARAMETER TestFile
        { param($Path) <bool> }.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)] [string] $ItemRoot,
        [Parameter(Mandatory = $true)] [string] $AgentId,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Selected,
        [scriptblock] $TestFile = { param($Path) Test-OwnerDirectiveFileExist -Path $Path }
    )

    $found = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $Selected) {
        if (& $TestFile (Get-OwnerDirectiveDecisionPath -ItemRoot $ItemRoot -AgentId $AgentId -Id $entry.Id)) { $found.Add([string] $entry.Id) }
    }
    return $found.ToArray()
}

function Get-OwnerDirectiveItemContext {
    <#
    .SYNOPSIS
        Read an item root into the values the hook decides on, or $null without an issue.
    .DESCRIPTION
        Returns Root, Checkpoint (parsed), CheckpointText, Issue, Step, Branch, Parent,
        ParentIssue, and Sources. The issue comes from the checkpoint issue-num, else from
        FallbackIssue; without either the result is $null.
    .PARAMETER ItemRoot
        The item worktree root.
    .PARAMETER SessionRoot
        The hook process location.
    .PARAMETER FallbackIssue
        The issue named by the delegation prompt, or $null.
    .PARAMETER ReadText
        { param($Path) <text or $null> }.
    .PARAMETER WorktreeListInvoker
        { param($SessionRoot) <porcelain text> }.
    .PARAMETER EpicResolver
        Passed to Resolve-OwnerDirectiveParentRoot.
    .PARAMETER ParallelResolver
        Passed to Resolve-OwnerDirectiveParentRoot.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $ItemRoot,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [AllowNull()] [AllowEmptyString()] [string] $FallbackIssue,
        [scriptblock] $ReadText = { param($Path) Read-OwnerDirectiveFileText -Path $Path },
        [scriptblock] $WorktreeListInvoker = { param($SessionRoot) $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null; if ($LASTEXITCODE -ne 0) { return '' }; return ($porcelain -join "`n") },
        [scriptblock] $EpicResolver = { param($IntegrationBranch, $SessionRoot) Resolve-WorktreeEpicTarget -IntegrationBranch $IntegrationBranch -SessionRoot $SessionRoot },
        [scriptblock] $ParallelResolver = { param($ParallelSlug, $SessionRoot) Resolve-WorktreeParallelTarget -ParallelSlug $ParallelSlug -SessionRoot $SessionRoot }
    )

    $checkpointText = & $ReadText (Join-Path $ItemRoot 'artifacts/orchestration/orchestrator-state.json')
    $checkpoint = ConvertFrom-OwnerDirectiveJsonObject -Text $checkpointText
    $issueValue = Get-OwnerDirectivePropertyValue -InputObject $checkpoint -Name 'issue-num'
    $issue = if ($null -ne $issueValue) { ConvertTo-WorktreeItemIssueNumber -Value $issueValue } else { $null }
    if ($null -eq $issue -and -not [string]::IsNullOrWhiteSpace($FallbackIssue)) { $issue = ConvertTo-WorktreeItemIssueNumber -Value $FallbackIssue }
    if ($null -eq $issue) { return $null }
    $parent = Resolve-OwnerDirectiveParentRoot -Checkpoint $checkpoint -SessionRoot $SessionRoot -EpicResolver $EpicResolver -ParallelResolver $ParallelResolver
    return [pscustomobject]@{
        Root           = $ItemRoot
        Checkpoint     = $checkpoint
        CheckpointText = $checkpointText
        Issue          = [long] $issue
        Step           = [string] (Get-OwnerDirectivePropertyValue -InputObject $checkpoint -Name 'next_step')
        Branch         = (Get-OwnerDirectiveItemBranch -ItemRoot $ItemRoot -SessionRoot $SessionRoot -WorktreeListInvoker $WorktreeListInvoker)
        Parent         = $parent
        ParentIssue    = (Get-OwnerDirectiveParentIssue -Parent $parent -ReadText $ReadText)
        Sources        = (Get-OwnerDirectiveSourceSet -ItemRoot $ItemRoot -ItemCheckpointText $checkpointText -Parent $parent -ReadText $ReadText)
    }
}

function New-OwnerDirectivePassDownDeny {
    <#
    .SYNOPSIS
        The PreToolUse deny decision for a sub-code and detail text.
    .PARAMETER Code
        The sub-code, without its trailing colon.
    .PARAMETER Detail
        The reason text after the sub-code.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Detail
    )

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = ('OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: {0}: {1}' -f $Code, $Detail)
        }
    }
}

function Get-OwnerDirectivePassDownLedgerDecision {
    <#
    .SYNOPSIS
        The ledger-guard decision for a file tool call whose target is a ledger.
    .PARAMETER ToolName
        The tool name.
    .PARAMETER AgentType
        The payload agent_type, or $null for the main session.
    .PARAMETER Path
        The target path.
    .PARAMETER Content
        The Write content.
    .PARAMETER ReadText
        { param($Path) <text or $null> }.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $ToolName,
        [AllowNull()] [AllowEmptyString()] [string] $AgentType,
        [Parameter(Mandatory = $true)] [string] $Path,
        [AllowNull()] [AllowEmptyString()] [string] $Content,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadText
    )

    $code = 'OWNER_DIRECTIVE_LEDGER_WRITE_DENIED'
    if (-not [string]::IsNullOrWhiteSpace($AgentType)) {
        return (New-OwnerDirectivePassDownDeny -Code $code -Detail ("the coordinator ledger is written only by the main session; agent type '{0}' may not write it." -f $AgentType))
    }
    if ($ToolName -cne 'Write') {
        return (New-OwnerDirectivePassDownDeny -Code $code -Detail ("the coordinator ledger is append-only and is written only with Write; {0} is not admitted." -f $ToolName))
    }
    $errors = @(Test-OwnerDirectiveLedgerAppend -ExistingText (& $ReadText $Path) -NewText $Content)
    if ($errors.Count -gt 0) {
        return (New-OwnerDirectivePassDownDeny -Code $code -Detail (($errors -join ' ') + ' Keep every existing line unchanged and append only valid directive objects, one per line.'))
    }
    return $null
}
