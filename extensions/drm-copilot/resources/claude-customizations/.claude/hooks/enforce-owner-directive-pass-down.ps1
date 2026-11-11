<#
.SYNOPSIS
    PreToolUse hook that passes recorded owner directives down to delegated agents (issue #1157).

.DESCRIPTION
    Registered on the matcher Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|mcp__.*. The hook
    reads four directive sources for an item: the item checkpoint owner_directives, the item
    ledger artifacts/orchestration/owner-directives.jsonl, the parent (epic or parallel) checkpoint,
    and the parent ledger. It acts in three ways and is inert for every other call:

      - Ledger guard. A Write, Edit, MultiEdit, or NotebookEdit of a ledger is denied with
        OWNER_DIRECTIVE_LEDGER_WRITE_DENIED when the caller is a subagent, the tool is not Write,
        an existing line changes or disappears, or an appended line fails B2-B8.
      - Acknowledgement mode. A call by an agent of the acknowledgement set is denied with
        OWNER_DIRECTIVE_DECISION_REQUIRED, the rendered block as the reason, while a selected
        directive has no decision file under the agent's id. A Write of a pending decision file
        holding one valid decision line is not denied; an invalid line, a second write, an Edit,
        and a write under another agent id are denied with OWNER_DIRECTIVE_DECISION_INVALID.
      - Relay mode. An Agent or Task delegation to a relay target is denied with
        OWNER_DIRECTIVE_RELAY_REQUIRED when a selected directive is missing from the item
        checkpoint or its rendered lines are missing from the prompt. A child orchestrator launch
        by an epic or parallel coordinator applies the prompt check only.

    Every deny is the hookSpecificOutput deny JSON at exit 0, prefixed OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:.
    An allow writes nothing. With no directive source the hook emits nothing, so behavior equals
    the behavior before this hook. A call that is none of the three returns before any file,
    worktree, or clock read.

.NOTES
    PowerShell 7+. Invokes no Python. Selection, rendering, and decision rules live in
    OrchestratorStateOwnerDirectiveSelection.psm1 and OrchestratorStateOwnerDirectiveDecision.psm1;
    resolution and reads live in owner-directive-pass-down-target.ps1. A policy-level control, not
    a security control. Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/HookTargetWorktree.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeItemResolution.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeRunResolution.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeRunResolution.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorStateOwnerDirectives.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorStateOwnerDirectiveSelection.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorStateOwnerDirectiveDecision.psm1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'subagentstop-target-worktree.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-target-worktree.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'owner-directive-pass-down-target.ps1') } catch { Add-HookDependencyFailure -Name 'owner-directive-pass-down-target.ps1' -ErrorRecord $_ }

function Get-OwnerDirectivePassDownRoleSet {
    <#
    .SYNOPSIS
        The acknowledgement set, the relay targets, and the written-file tools.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $acknowledgement = @('atomic-executor', 'atomic-planner', 'feature-review', 'task-researcher', 'prd-feature', 'python-typed-engineer', 'powershell-typed-engineer')
    return @{
        Acknowledgement = $acknowledgement
        Relay           = $acknowledgement + @('csharp-typed-engineer', 'typescript-engineer', 'orchestrator')
        FileTool        = @('Write', 'Edit', 'MultiEdit', 'NotebookEdit')
        DelegationTool  = @('Agent', 'Task')
    }
}

function Test-OwnerDirectivePassDownMember {
    <#
    .SYNOPSIS
        Whether a value equals a member of a set under ordinal comparison.
    .PARAMETER Value
        The value.
    .PARAMETER Set
        The set.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [AllowEmptyString()] [string] $Value, [Parameter(Mandatory = $true)] [string[]] $Set)

    foreach ($member in $Set) { if ([string]::Equals($Value, $member, [System.StringComparison]::Ordinal)) { return $true } }
    return $false
}

function Test-OwnerDirectiveSourcePresent {
    <#
    .SYNOPSIS
        Whether any directive source holds text.
    .PARAMETER Sources
        Source descriptors.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Sources)

    return (@($Sources | Where-Object { $null -ne $_ -and -not [string]::IsNullOrWhiteSpace([string] $_.Text) }).Count -gt 0)
}

function Get-OwnerDirectivePassDownSelection {
    <#
    .SYNOPSIS
        Select the entries of an item context at a time.
    .PARAMETER Context
        The Get-OwnerDirectiveItemContext result.
    .PARAMETER Now
        The hook clock value.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [object] $Context, [Parameter(Mandatory = $true)] [datetime] $Now)

    $parentBranch = if ($null -ne $Context.Parent -and $Context.Parent.Kind -eq 'epic') { [string] $Context.Parent.IntegrationBranch } else { $null }
    return (Select-OwnerDirectivePassDown -Source $Context.Sources -ItemIssue $Context.Issue -ItemBranch $Context.Branch -ItemStep $Context.Step -ParentIssue $Context.ParentIssue -ParentBranch $parentBranch -Now $Now)
}

function Get-OwnerDirectivePassDownAckDecision {
    <#
    .SYNOPSIS
        The acknowledgement-mode decision for a call by an agent of the acknowledgement set.
    .PARAMETER Payload
        The parsed PreToolUse payload.
    .PARAMETER ToolName
        The tool name.
    .PARAMETER ToolInput
        The tool_input object.
    .PARAMETER Seam
        The seam hashtable of Get-OwnerDirectivePassDownDecision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [object] $Payload,
        [Parameter(Mandatory = $true)] [string] $ToolName,
        [AllowNull()] [object] $ToolInput,
        [Parameter(Mandatory = $true)] [hashtable] $Seam
    )

    $agentId = [string] (Get-ClaudeHookEnvelopeValue -Envelope $Payload -Name 'agent_id')
    if (-not (Test-OwnerDirectiveAgentId -AgentId $agentId)) { return $null }
    $item = Resolve-OwnerDirectiveItemRoot -Cwd ([string] (Get-ClaudeHookEnvelopeValue -Envelope $Payload -Name 'cwd')) -TranscriptPath ([string] (Get-ClaudeHookEnvelopeValue -Envelope $Payload -Name 'transcript_path')) -AgentId $agentId -SessionRoot $Seam.SessionRoot -ReadText $Seam.ReadText -ReadTranscriptHead $Seam.ReadTranscriptHead -WorktreeListInvoker $Seam.WorktreeListInvoker
    if ($null -eq $item) { return $null }
    $context = Get-OwnerDirectiveItemContext -ItemRoot $item.Root -SessionRoot $Seam.SessionRoot -ReadText $Seam.ReadText -WorktreeListInvoker $Seam.WorktreeListInvoker -EpicResolver $Seam.EpicResolver -ParallelResolver $Seam.ParallelResolver
    if ($null -eq $context -or -not (Test-OwnerDirectiveSourcePresent -Sources $context.Sources)) { return $null }
    $Clock = $Seam.Clock
    $now = [datetime] (& $Clock)
    $selected = @((Get-OwnerDirectivePassDownSelection -Context $context -Now $now).Selected)
    if ($selected.Count -eq 0) { return $null }

    $path = ([string] (Get-ClaudeHookEnvelopeValue -Envelope $ToolInput -Name 'file_path') + [string] (Get-ClaudeHookEnvelopeValue -Envelope $ToolInput -Name 'notebook_path')).Replace('\', '/')
    $decisionMatch = [regex]::Match($path, '/artifacts/orchestration/owner-directive-decisions/(?<agent>[^/]+)/(?<id>[^/]+)\.md\z')
    $existing = @(Get-OwnerDirectiveExistingDecisionId -ItemRoot $context.Root -AgentId $agentId -Selected $selected -TestFile $Seam.TestFile)
    if ($decisionMatch.Success) {
        return (Get-OwnerDirectivePassDownDecisionWrite -ToolName $ToolName -AgentId $agentId -Match $decisionMatch -Path $path -Content ([string] (Get-ClaudeHookEnvelopeValue -Envelope $ToolInput -Name 'content')) -Selected $selected -Existing $existing -Now $now -Seam $Seam)
    }
    $pending = @(Get-OwnerDirectivePendingSet -Selected $selected -ExistingDecisionId $existing)
    if ($pending.Count -eq 0) { return $null }
    return (New-OwnerDirectivePassDownDeny -Code 'OWNER_DIRECTIVE_DECISION_REQUIRED' -Detail (Format-OwnerDirectivePassDownAckReason -Pending $pending -ItemRoot $context.Root -AgentId $agentId -Now $now))
}

function Format-OwnerDirectivePassDownAckReason {
    <#
    .SYNOPSIS
        The reason text of an acknowledgement hold.
    .PARAMETER Pending
        The pending entries.
    .PARAMETER ItemRoot
        The item worktree root.
    .PARAMETER AgentId
        The calling agent id.
    .PARAMETER Now
        The hook clock value.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [object[]] $Pending,
        [Parameter(Mandatory = $true)] [string] $ItemRoot,
        [Parameter(Mandatory = $true)] [string] $AgentId,
        [Parameter(Mandatory = $true)] [datetime] $Now
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('record a decision for each pending owner directive before any other matched tool call; Read, Grep, and Glob stay available.')
    $lines.Add((Format-OwnerDirectiveBlock -Selected $Pending))
    foreach ($entry in @($Pending | Where-Object { $_.IsRefusedClass })) {
        $lines.Add(('Always refused: {0} has class {1}, which accepts only the outcome refused.' -f $entry.Id, $entry.Class))
    }
    foreach ($entry in $Pending) {
        $lines.Add(('Decision file for {0}: {1}' -f $entry.Id, (Get-OwnerDirectiveDecisionPath -ItemRoot $ItemRoot -AgentId $AgentId -Id $entry.Id).Replace('\', '/')))
    }
    $lines.Add('Grammar (one line per file, written once with Write): OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at|-> | <reason of at least 20 characters>')
    $lines.Add(('Hook clock (use as decided_at): {0}' -f $Now.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture)))
    return ($lines -join "`n")
}

function Get-OwnerDirectivePassDownDecisionWrite {
    <#
    .SYNOPSIS
        The decision for a file tool call whose target is a decision file.
    .PARAMETER ToolName
        The tool name.
    .PARAMETER AgentId
        The calling agent id.
    .PARAMETER Match
        The decision-path match with agent and id groups.
    .PARAMETER Path
        The normalized target path.
    .PARAMETER Content
        The Write content.
    .PARAMETER Selected
        The selected entries.
    .PARAMETER Existing
        The ids whose decision files exist for the agent.
    .PARAMETER Now
        The hook clock value.
    .PARAMETER Seam
        The seam hashtable.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $ToolName,
        [Parameter(Mandatory = $true)] [string] $AgentId,
        [Parameter(Mandatory = $true)] [System.Text.RegularExpressions.Match] $Match,
        [Parameter(Mandatory = $true)] [string] $Path,
        [AllowNull()] [AllowEmptyString()] [string] $Content,
        [Parameter(Mandatory = $true)] [object[]] $Selected,
        [AllowEmptyCollection()] [string[]] $Existing,
        [Parameter(Mandatory = $true)] [datetime] $Now,
        [Parameter(Mandatory = $true)] [hashtable] $Seam
    )

    $code = 'OWNER_DIRECTIVE_DECISION_INVALID'
    $id = $Match.Groups['id'].Value
    if ($ToolName -cne 'Write') { return (New-OwnerDirectivePassDownDeny -Code $code -Detail ('decision files are written once with Write; {0} of {1} is not admitted.' -f $ToolName, $Path)) }
    if ($Match.Groups['agent'].Value -cne $AgentId) { return (New-OwnerDirectivePassDownDeny -Code $code -Detail ("the decision file belongs to agent '{0}'; agent '{1}' writes only its own decision files." -f $Match.Groups['agent'].Value, $AgentId)) }
    $TestFile = $Seam.TestFile
    if (@($Existing) -ccontains $id -or (& $TestFile $Path)) { return (New-OwnerDirectivePassDownDeny -Code $code -Detail ('the decision file {0} already exists; decision files are write-once.' -f $Path)) }
    $directive = @($Selected | Where-Object { [string]::Equals([string] $_.Id, $id, [System.StringComparison]::Ordinal) })
    if ($directive.Count -eq 0) { return (New-OwnerDirectivePassDownDeny -Code $code -Detail ('{0} names no pending owner directive.' -f $id)) }
    $body = ([string] $Content).TrimEnd("`r", "`n")
    $line = if ($body.Contains("`n") -or $body.Contains("`r")) { $null } else { $body }
    $errors = @(Test-OwnerDirectiveDecision -Decision (ConvertFrom-OwnerDirectiveDecisionLine -Line $line) -Directive $directive[0] -Now $Now)
    if ($errors.Count -gt 0) { return (New-OwnerDirectivePassDownDeny -Code $code -Detail (('the decision for {0} is invalid: ' -f $id) + ($errors -join ' '))) }
    return $null
}

function Get-OwnerDirectivePassDownCoordinatorDecision {
    <#
    .SYNOPSIS
        The prompt-only relay decision for a child orchestrator launch by an epic or parallel coordinator.
    .DESCRIPTION
        Returns $null when the caller root holds no epic or parallel checkpoint; otherwise an
        object with Decision (the deny, or $null). The caller's own checkpoint and ledger are the
        parent sources, filtered by the prompt's canonical issue line and branch label.
    .PARAMETER CallerRoot
        The caller's worktree root.
    .PARAMETER Prompt
        The delegation prompt.
    .PARAMETER Seam
        The seam hashtable.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $CallerRoot,
        [AllowNull()] [AllowEmptyString()] [string] $Prompt,
        [Parameter(Mandatory = $true)] [hashtable] $Seam
    )

    $ReadText = $Seam.ReadText
    $parent = $null
    foreach ($kind in @('epic', 'parallel')) {
        $relative = if ($kind -eq 'epic') { 'artifacts/orchestration/epic-orchestrator-state.json' } else { 'artifacts/orchestration/parallel-orchestrator-state.json' }
        $parsed = ConvertFrom-OwnerDirectiveJsonObject -Text (& $ReadText (Join-Path $CallerRoot $relative))
        if ([string] (Get-OwnerDirectivePropertyValue -InputObject $parsed -Name 'route_id') -ceq $kind) {
            $parent = [pscustomobject]@{ Kind = $kind; Root = $CallerRoot; IntegrationBranch = [string] (Get-OwnerDirectivePropertyValue -InputObject $parsed -Name 'integration_branch'); ParallelSlug = [string] (Get-OwnerDirectivePropertyValue -InputObject $parsed -Name 'parallel_slug') }
            break
        }
    }
    if ($null -eq $parent) { return $null }
    # Assigned before wrapping, because the reader returns its array as one object.
    $issueSignal = Find-WorktreeItemIssueSignal -Text $Prompt
    $issues = @($issueSignal)
    if ($issues.Count -ne 1) { return [pscustomobject]@{ Decision = $null } }
    $sources = @(Get-OwnerDirectiveSourceSet -ItemRoot $CallerRoot -ItemCheckpointText $null -Parent $parent -ReadText $Seam.ReadText | Where-Object { $_.Name -like 'parent-*' })
    if (-not (Test-OwnerDirectiveSourcePresent -Sources $sources)) { return [pscustomobject]@{ Decision = $null } }
    $Clock = $Seam.Clock
    $now = [datetime] (& $Clock)
    $parentBranch = if ($parent.Kind -eq 'epic') { $parent.IntegrationBranch } else { $null }
    $selection = Select-OwnerDirectivePassDown -Source $sources -ItemIssue ([long] $issues[0]) -ItemBranch (Find-WorktreeResolutionBranchSignal -Text $Prompt) -ItemStep $null -ParentIssue (Get-OwnerDirectiveParentIssue -Parent $parent -ReadText $Seam.ReadText) -ParentBranch $parentBranch -Now $now
    $selected = @($selection.Selected)
    if ($selected.Count -eq 0 -or (Test-OwnerDirectivePromptCoverage -Selected $selected -Prompt $Prompt)) { return [pscustomobject]@{ Decision = $null } }
    $detail = "paste this block into the child orchestrator prompt; the child records the entries at its first checkpoint write.`n" + (Format-OwnerDirectiveBlock -Selected $selected)
    return [pscustomobject]@{ Decision = (New-OwnerDirectivePassDownDeny -Code 'OWNER_DIRECTIVE_RELAY_REQUIRED' -Detail $detail) }
}

function Get-OwnerDirectivePassDownRelayDecision {
    <#
    .SYNOPSIS
        The relay-mode decision for a delegation to a relay target.
    .PARAMETER Payload
        The parsed PreToolUse payload.
    .PARAMETER SubagentType
        The target subagent_type.
    .PARAMETER Prompt
        The delegation prompt.
    .PARAMETER Seam
        The seam hashtable.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [object] $Payload,
        [Parameter(Mandatory = $true)] [string] $SubagentType,
        [AllowNull()] [AllowEmptyString()] [string] $Prompt,
        [Parameter(Mandatory = $true)] [hashtable] $Seam
    )

    $ReadText = $Seam.ReadText
    $cwd = [string] (Get-ClaudeHookEnvelopeValue -Envelope $Payload -Name 'cwd')
    $callerRoot = $null
    if (-not [string]::IsNullOrWhiteSpace($cwd)) { $callerRoot = (Resolve-HookTargetWorktree -SessionRoot $Seam.SessionRoot -FilePath @($cwd) -WorktreeListInvoker $Seam.WorktreeListInvoker).WorktreeRoot }
    if ($SubagentType -ceq 'orchestrator' -and -not [string]::IsNullOrWhiteSpace($callerRoot)) {
        $coordinator = Get-OwnerDirectivePassDownCoordinatorDecision -CallerRoot $callerRoot -Prompt $Prompt -Seam $Seam
        if ($null -ne $coordinator) { return $coordinator.Decision }
    }
    $itemRoot = $null
    $identity = Get-SubagentStopIdentityPrompt -Prompt $Prompt
    if ($null -ne $identity) {
        $resolverArguments = @{ SessionRoot = $Seam.SessionRoot; DelegationPrompt = $identity; WorktreeListInvoker = $Seam.WorktreeListInvoker }
        if ($null -eq (Find-WorktreeResolutionBranchSignal -Text $identity)) {
            $resolverArguments['CheckpointIssueReader'] = {
                param($WorktreeRoot)
                $value = Get-OwnerDirectivePropertyValue -InputObject (ConvertFrom-OwnerDirectiveJsonObject -Text (& $ReadText (Join-Path $WorktreeRoot 'artifacts/orchestration/orchestrator-state.json'))) -Name 'issue-num'
                if ($null -eq $value) { return $null }
                return (ConvertTo-WorktreeItemIssueNumber -Value $value)
            }
        }
        $resolved = Resolve-HookTargetWorktree @resolverArguments
        if ($null -eq $resolved.ReasonCode) { $itemRoot = $resolved.WorktreeRoot }
    }
    if ([string]::IsNullOrWhiteSpace($itemRoot)) { $itemRoot = $callerRoot }
    if ([string]::IsNullOrWhiteSpace($itemRoot)) { return $null }
    $promptSignal = Find-WorktreeItemIssueSignal -Text $Prompt
    $promptIssues = @($promptSignal)
    $fallbackIssue = if ($promptIssues.Count -eq 1) { $promptIssues[0] } else { $null }
    $context = Get-OwnerDirectiveItemContext -ItemRoot $itemRoot -SessionRoot $Seam.SessionRoot -FallbackIssue $fallbackIssue -ReadText $Seam.ReadText -WorktreeListInvoker $Seam.WorktreeListInvoker -EpicResolver $Seam.EpicResolver -ParallelResolver $Seam.ParallelResolver
    if ($null -eq $context -or -not (Test-OwnerDirectiveSourcePresent -Sources $context.Sources)) { return $null }
    $Clock = $Seam.Clock
    $now = [datetime] (& $Clock)
    $selected = @((Get-OwnerDirectivePassDownSelection -Context $context -Now $now).Selected)
    if ($selected.Count -eq 0) { return $null }
    $checkpointText = @($context.Sources | Where-Object { $_.Name -ceq 'item-checkpoint' })[0].Text
    $held = if ([string]::IsNullOrWhiteSpace([string] $checkpointText)) { @() } else { @((Get-OrchestratorStateOwnerDirectiveValidEntry -Text $checkpointText).Entries) }
    $gap = @(Get-OwnerDirectiveCheckpointGap -Selected $selected -CheckpointEntry $held)
    $covered = Test-OwnerDirectivePromptCoverage -Selected $selected -Prompt $Prompt
    if ($gap.Count -eq 0 -and $covered) { return $null }
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add(("record each selected owner directive in the item checkpoint owner_directives and paste the block into the {0} prompt before delegating." -f $SubagentType))
    $lines.Add((Format-OwnerDirectiveBlock -Selected $selected))
    if ($gap.Count -gt 0) {
        $lines.Add('JSON entries to append to owner_directives:')
        foreach ($json in (Format-OwnerDirectiveAppendJson -Entry $gap)) { $lines.Add($json) }
    }
    return (New-OwnerDirectivePassDownDeny -Code 'OWNER_DIRECTIVE_RELAY_REQUIRED' -Detail ($lines -join "`n"))
}

function Get-OwnerDirectivePassDownDecision {
    <#
    .SYNOPSIS
        Parse the PreToolUse payload and return a deny decision, or $null to allow.
    .DESCRIPTION
        Returns the dependency decision first. A call that is neither a ledger write, a call by
        an agent of the acknowledgement set, nor a delegation to a relay target returns $null
        before any file, worktree, or clock read.
    .PARAMETER HookInputRaw
        The raw PreToolUse JSON envelope.
    .PARAMETER SessionRoot
        The hook process location.
    .PARAMETER ReadText
        { param($Path) <text or $null> }.
    .PARAMETER ReadTranscriptHead
        { param($Path) <JSONL lines or $null> }.
    .PARAMETER WorktreeListInvoker
        { param($SessionRoot) <porcelain text> }.
    .PARAMETER EpicResolver
        { param($IntegrationBranch, $SessionRoot) <target result> }.
    .PARAMETER ParallelResolver
        { param($ParallelSlug, $SessionRoot) <target result> }.
    .PARAMETER TestFile
        { param($Path) <bool> }.
    .PARAMETER Clock
        { <UTC datetime> }.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $HookInputRaw,
        [string] $SessionRoot = (Get-Location).Path,
        [scriptblock] $ReadText = { param($Path) Read-OwnerDirectiveFileText -Path $Path },
        [scriptblock] $ReadTranscriptHead = { param($Path) Read-TranscriptHead -Path $Path },
        [scriptblock] $WorktreeListInvoker = { param($SessionRoot) $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null; if ($LASTEXITCODE -ne 0) { return '' }; return ($porcelain -join "`n") },
        [scriptblock] $EpicResolver = { param($IntegrationBranch, $SessionRoot) Resolve-WorktreeEpicTarget -IntegrationBranch $IntegrationBranch -SessionRoot $SessionRoot },
        [scriptblock] $ParallelResolver = { param($ParallelSlug, $SessionRoot) Resolve-WorktreeParallelTarget -ParallelSlug $ParallelSlug -SessionRoot $SessionRoot },
        [scriptblock] $TestFile = { param($Path) Test-OwnerDirectiveFileExist -Path $Path },
        [scriptblock] $Clock = { Get-OwnerDirectiveClock }
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    if ([string]::IsNullOrWhiteSpace($HookInputRaw)) { return $null }
    try { $payload = $HookInputRaw | ConvertFrom-Json -ErrorAction Stop } catch { return $null }
    if ($payload -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    $roles = Get-OwnerDirectivePassDownRoleSet
    $toolName = [string] (Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'tool_name')
    $toolInput = Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'tool_input'
    if ($toolInput -isnot [System.Management.Automation.PSCustomObject]) { $toolInput = [pscustomobject]@{} }
    $agentType = [string] (Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'agent_type')
    $seam = @{
        SessionRoot = $SessionRoot; ReadText = $ReadText; ReadTranscriptHead = $ReadTranscriptHead; WorktreeListInvoker = $WorktreeListInvoker
        EpicResolver = $EpicResolver; ParallelResolver = $ParallelResolver; TestFile = $TestFile; Clock = $Clock
    }

    if (Test-OwnerDirectivePassDownMember -Value $toolName -Set $roles.FileTool) {
        $path = ([string] (Get-ClaudeHookEnvelopeValue -Envelope $toolInput -Name 'file_path') + [string] (Get-ClaudeHookEnvelopeValue -Envelope $toolInput -Name 'notebook_path')).Replace('\', '/')
        if ($path -eq 'artifacts/orchestration/owner-directives.jsonl' -or $path.EndsWith('/artifacts/orchestration/owner-directives.jsonl', [System.StringComparison]::Ordinal)) {
            return (Get-OwnerDirectivePassDownLedgerDecision -ToolName $toolName -AgentType $agentType -Path $path -Content ([string] (Get-ClaudeHookEnvelopeValue -Envelope $toolInput -Name 'content')) -ReadText $ReadText)
        }
    }
    if (Test-OwnerDirectivePassDownMember -Value $agentType -Set $roles.Acknowledgement) {
        return (Get-OwnerDirectivePassDownAckDecision -Payload $payload -ToolName $toolName -ToolInput $toolInput -Seam $seam)
    }
    $subagentType = [string] (Get-ClaudeHookEnvelopeValue -Envelope $toolInput -Name 'subagent_type')
    if ((Test-OwnerDirectivePassDownMember -Value $toolName -Set $roles.DelegationTool) -and (Test-OwnerDirectivePassDownMember -Value $subagentType -Set $roles.Relay)) {
        return (Get-OwnerDirectivePassDownRelayDecision -Payload $payload -SubagentType $subagentType -Prompt ([string] (Get-ClaudeHookEnvelopeValue -Envelope $toolInput -Name 'prompt')) -Seam $seam)
    }
    return $null
}

# Allow dot-sourcing in tests without executing the entry point.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

$decision = Get-OwnerDirectivePassDownDecision -HookInputRaw ([string] (Read-ClaudeHookRawPayload))
if ($null -ne $decision) { $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output }
exit 0
