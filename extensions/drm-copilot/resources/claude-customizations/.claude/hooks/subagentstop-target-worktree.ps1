<#
.SYNOPSIS
    Target-worktree resolution and artifact-path conversion for SubagentStop hooks (issue #1105).

.DESCRIPTION
    Dot-sourced by the SubagentStop artifact hooks and the feature-review coverage hook under the
    guarded single-statement pattern. A subagent that works in an item worktree advertises artifact
    paths relative to that worktree, while the hook process runs in the session root. This helper
    resolves the item worktree once and converts each advertised value, so a hook probes only the
    item copy of an artifact and never falls back to the main checkout.

    Resolution reuses Resolve-HookTargetWorktree (HookTargetWorktree.psm1) and adds no resolver of
    its own: an absolute advertised path decides through the FilePath source; otherwise the
    delegation prompt, read from the transcript named by agent_transcript_path, decides through its
    identity; with neither, the session root applies. The identity is reduced to the shapes the
    model-routing gate admits: the first branch label, read by Find-WorktreeResolutionBranchSignal
    (WorktreeTargetResolution.psm1), and the canonical issue lines, read by
    Find-WorktreeItemIssueSignal (WorktreeItemResolution.psm1). An identity with no branch label is
    placed through the worktree checkpoints by Get-WorktreeItemCheckpointIssue, as at the gate.

    The transcript readers Get-TranscriptPathFromEnvelope, Read-TranscriptHead, and
    Get-TranscriptFirstUserText, with their property reader Get-JsonPropertyValue, moved here from
    validate-executor-output.ps1 with unchanged names, parameters, and bodies.

.NOTES
    PowerShell 7+. Holds no script-scope state, invokes no Python, and dot-sources no other hook.
    Imports HookTargetWorktree.psm1, WorktreeTargetResolution.psm1, and WorktreeItemResolution.psm1
    under the guarded single-statement pattern. The file reads are Read-TranscriptHead and the
    default CheckpointIssueReader; the worktree list, the transcript reader, and the checkpoint
    issue reader are injectable script-block parameters, so tests supply in-memory content.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>

try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/HookTargetWorktree.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/AgentTargetWorktree.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'AgentTargetWorktree.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeTargetResolution.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeTargetResolution.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeItemResolution.psm1' -ErrorRecord $_ }

function Get-JsonPropertyValue {
    # Returns a named property of a parsed JSON object, or $null; safe under StrictMode.
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()] [object] $Object, [Parameter(Mandatory = $true)] [string] $Name)

    if ($null -eq $Object -or -not ($Object -is [System.Management.Automation.PSCustomObject])) {
        return $null
    }
    $property = @($Object.PSObject.Properties | Where-Object { $_.Name -ceq $Name })
    if ($property.Count -eq 0) {
        return $null
    }
    return $property[0].Value
}

function Get-TranscriptPathFromEnvelope {
    # Returns agent_transcript_path from the SubagentStop envelope with a leading ~ expanded, or $null.
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [object] $Envelope)

    $path = Get-JsonPropertyValue -Object $Envelope -Name 'agent_transcript_path'
    if (-not ($path -is [string]) -or [string]::IsNullOrWhiteSpace($path)) {
        return $null
    }
    if ($path.StartsWith('~')) {
        $path = $HOME + $path.Substring(1)
    }
    return $path
}

function Get-TranscriptFirstUserText {
    # Returns the text of the first `user` entry of transcript JSONL lines, or $null when none parses.
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()] [string[]] $Lines = @())

    foreach ($line in $Lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        try {
            $entry = ConvertFrom-Json -InputObject $line -ErrorAction Stop
        }
        catch {
            continue
        }
        if ((Get-JsonPropertyValue -Object $entry -Name 'type') -ne 'user') {
            continue
        }
        $container = Get-JsonPropertyValue -Object $entry -Name 'message'
        if ($null -eq $container) {
            $container = $entry
        }
        $content = Get-JsonPropertyValue -Object $container -Name 'content'
        if ($content -is [string]) {
            return $content
        }
        $textBlocks = @(@($content) | Where-Object { (Get-JsonPropertyValue -Object $_ -Name 'type') -eq 'text' })
        $texts = @($textBlocks | ForEach-Object { [string](Get-JsonPropertyValue -Object $_ -Name 'text') })
        if ($texts.Count -gt 0) {
            return ($texts -join "`n")
        }
    }
    return $null
}

function Read-TranscriptHead {
    # File seam: returns the first 50 lines of the transcript at Path, or $null when no file exists.
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return [string[]]@(Get-Content -LiteralPath $Path -TotalCount 50 -ErrorAction Stop)
}

function Test-SubagentStopSessionRoot {
    <#
    .SYNOPSIS
        Returns $true when a resolved root is $null, blank, or the session root.
    .DESCRIPTION
        Both values are normalized to forward slashes without a trailing slash and compared with
        OrdinalIgnoreCase, the comparison Resolve-HookTargetWorktree uses.
    .PARAMETER WorktreeRoot
        The resolved worktree root, or $null.
    .PARAMETER SessionRoot
        The hook's session root.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $WorktreeRoot,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    $root = ConvertTo-HookTargetWorktreeNormalizedPath -Path $WorktreeRoot
    if ([string]::IsNullOrEmpty($root)) { return $true }
    return [string]::Equals($root, (ConvertTo-HookTargetWorktreeNormalizedPath -Path $SessionRoot), [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-SubagentStopIdentityPrompt {
    <#
    .SYNOPSIS
        Reduces a delegation prompt to the identity the model-routing gate reads, or $null.
    .DESCRIPTION
        Pure. Returns $null when the prompt carries no branch signal and no canonical issue line.
        Otherwise returns text holding 'branch: <first branch>' when a branch is present, followed
        by one canonical issue line per distinct issue number. Later branch labels, such as a
        'base branch: main' line, are dropped, because the gate reads only the first.
    .PARAMETER Prompt
        The delegation prompt text, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [AllowEmptyString()] [string] $Prompt)

    $branch = Find-WorktreeResolutionBranchSignal -Text $Prompt
    # Assigned before wrapping, because the reader returns its array as one object.
    $issueSignal = Find-WorktreeItemIssueSignal -Text $Prompt
    $issues = @($issueSignal)
    $hasBranch = -not [string]::IsNullOrWhiteSpace($branch)
    if (-not $hasBranch -and $issues.Count -eq 0) { return $null }
    $lines = [System.Collections.Generic.List[string]]::new()
    if ($hasBranch) { $lines.Add("branch: $branch") }
    foreach ($number in $issues) { $lines.Add("Canonical issue number for this feature is $number.") }
    return ($lines -join "`n")
}

function Resolve-SubagentStopTargetWorktree {
    <#
    .SYNOPSIS
        Resolves the worktree that produced a subagent's advertised artifacts.
    .DESCRIPTION
        When any advertised path is absolute, Resolve-HookTargetWorktree decides from the absolute
        paths (source FilePath). Otherwise the first user entry of the transcript named by the
        envelope's agent_transcript_path is read and reduced by Get-SubagentStopIdentityPrompt; a
        reduced identity decides (source DelegationPrompt; the resolver reports it as
        DelegationIdentity). An identity without a branch label is passed with
        CheckpointIssueReader, so an issue-line-only prompt is placed through the worktree
        checkpoints; a branch-bearing identity reads no checkpoint. With no identity, the envelope
        cwd decides through its enclosing live registered worktree (source AgentWorkingDirectory,
        issue #1163); otherwise the session root applies (source SessionRoot). Resolution runs
        through Resolve-AgentTargetWorktree with Policy FailClosedOnIdentity, so prunable
        registrations never match.
        Returns WorktreeRoot, Source, ReasonCode, Detail, Unresolved, and StaleRegistration. A
        TARGET_WORKTREE_NOT_DERIVABLE or TARGET_WORKTREE_AMBIGUOUS result carries a $null
        WorktreeRoot; a caller that passes it to Resolve-SubagentStopArtifactLocation -Target
        blocks without a probe. No exception escapes: a resolver failure yields the session root.
    .PARAMETER Envelope
        The parsed SubagentStop envelope, or $null.
    .PARAMETER AdvertisedPath
        The artifact paths the subagent advertised.
    .PARAMETER SessionRoot
        The hook's session root, (Get-Location).Path in production.
    .PARAMETER ReadTranscriptHead
        { param($Path) <JSONL lines or $null> }; defaults to Read-TranscriptHead.
    .PARAMETER WorktreeListInvoker
        Optional { param($SessionRoot) <porcelain text> } passed to Resolve-HookTargetWorktree.
    .PARAMETER CheckpointIssueReader
        { param($WorktreeRoot) <issue number or $null> } passed to Resolve-HookTargetWorktree for an
        identity without a branch label; defaults to Get-WorktreeItemCheckpointIssue.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [object] $Envelope,
        [AllowNull()] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $AdvertisedPath,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [scriptblock] $ReadTranscriptHead = ${function:Read-TranscriptHead},
        [scriptblock] $WorktreeListInvoker,
        [scriptblock] $CheckpointIssueReader = { param($WorktreeRoot) Get-WorktreeItemCheckpointIssue -WorktreeRoot $WorktreeRoot }
    )

    try {
        $resolverArguments = @{ SessionRoot = $SessionRoot; Policy = 'FailClosedOnIdentity' }
        $workingDirectory = Get-JsonPropertyValue -Object $Envelope -Name 'cwd'
        if ($workingDirectory -is [string] -and -not [string]::IsNullOrWhiteSpace($workingDirectory)) { $resolverArguments['AgentWorkingDirectory'] = $workingDirectory }
        if ($null -ne $WorktreeListInvoker) { $resolverArguments['WorktreeListInvoker'] = $WorktreeListInvoker }
        $absolute = @($AdvertisedPath | Where-Object { (ConvertTo-HookTargetWorktreeNormalizedPath -Path $_) -match '^(/|[A-Za-z]:/)' })
        if ($absolute.Count -gt 0) {
            $resolverArguments['FilePath'] = [string[]]$absolute
        }
        else {
            $prompt = $null
            $transcriptPath = Get-TranscriptPathFromEnvelope -Envelope $Envelope
            if ($null -ne $transcriptPath) {
                $head = $null
                try { $head = & $ReadTranscriptHead $transcriptPath } catch { $head = $null }
                if ($null -ne $head) { $prompt = Get-TranscriptFirstUserText -Lines ([string[]]@($head)) }
            }
            $identity = Get-SubagentStopIdentityPrompt -Prompt $prompt
            if ($null -ne $identity) {
                $resolverArguments['DelegationPrompt'] = $identity
                # Only an identity with no branch label is placed through the worktree checkpoints.
                if ($null -eq (Find-WorktreeResolutionBranchSignal -Text $identity)) { $resolverArguments['CheckpointIssueReader'] = $CheckpointIssueReader }
            }
        }
        $result = Resolve-AgentTargetWorktree @resolverArguments
        $source = if ($result.Source -eq 'DelegationIdentity') { 'DelegationPrompt' } else { [string]$result.Source }
        return [pscustomobject]@{ WorktreeRoot = $result.WorktreeRoot; Source = $source; ReasonCode = $result.ReasonCode; Detail = [string]$result.Detail; Unresolved = [bool]$result.Unresolved; StaleRegistration = [string[]]@($result.StaleRegistration) }
    }
    catch {
        $reason = ([string]$_.Exception.Message -split "`r?`n")[0]
        return [pscustomobject]@{ WorktreeRoot = $SessionRoot; Source = 'SessionRoot'; ReasonCode = $null; Detail = "target worktree resolution failed: $reason; the session root applies" }
    }
}

function Resolve-SubagentStopArtifactPath {
    <#
    .SYNOPSIS
        Converts one advertised artifact value against a resolved worktree root.
    .DESCRIPTION
        With a $null root or the session root, the value is returned unchanged. With an item root,
        an absolute value inside the root becomes its repository-relative form, a relative value is
        joined beneath the root with forward slashes, and an absolute value outside the root is
        returned unchanged for the unchanged shape rules to reject.
    .PARAMETER Path
        The advertised value.
    .PARAMETER WorktreeRoot
        The resolved worktree root, or $null.
    .PARAMETER SessionRoot
        The hook's session root.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [AllowNull()] [AllowEmptyString()] [string] $WorktreeRoot,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    if (Test-SubagentStopSessionRoot -WorktreeRoot $WorktreeRoot -SessionRoot $SessionRoot) { return $Path }
    $normalized = ConvertTo-HookTargetWorktreeNormalizedPath -Path $Path
    if ($normalized -match '^(/|[A-Za-z]:/)') {
        $relative = Get-HookTargetWorktreeRelativePath -Path $normalized -WorktreeRoot $WorktreeRoot
        if ([string]::IsNullOrEmpty($relative)) { return $Path }
        return $relative
    }
    $relativeValue = $normalized -replace '^(\./)+', ''
    return ((ConvertTo-HookTargetWorktreeNormalizedPath -Path $WorktreeRoot) + '/' + $relativeValue)
}

function Resolve-SubagentStopArtifactLocation {
    <#
    .SYNOPSIS
        Returns the shape-rule value and the probe path of one advertised artifact value.
    .DESCRIPTION
        RelativePath is the value the unchanged shape rules read: an absolute value inside the item
        root becomes repository-relative, and every other value is unchanged. ProbePath is the
        location the hook reads: RelativePath joined beneath the item root, or the unchanged value
        for the session root and for an absolute value outside the root. Beneath an item root, a
        relative RelativePath with a '..' segment is rejected before any join: Rejected is $true,
        ProbePath is $null, and RejectionDetail names the segment, so the caller blocks without a
        probe. A Target that carries a reason code is rejected the same way before any conversion,
        and RejectionDetail names the code and the target's Detail (issue #1163). Otherwise
        Rejected is $false and RejectionDetail is $null.
    .PARAMETER Path
        The advertised value.
    .PARAMETER WorktreeRoot
        The resolved worktree root, or $null.
    .PARAMETER SessionRoot
        The hook's session root.
    .PARAMETER Target
        Optional Resolve-SubagentStopTargetWorktree result; $null keeps the result of the other inputs.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [AllowNull()] [AllowEmptyString()] [string] $WorktreeRoot,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [AllowNull()] [object] $Target = $null
    )

    # An unresolved present identity never probes any root (issue #1163, D4).
    $reasonCode = if ($null -ne $Target -and $null -ne $Target.PSObject.Properties['ReasonCode']) { [string]$Target.ReasonCode } else { '' }
    if (-not [string]::IsNullOrWhiteSpace($reasonCode)) {
        $detail = "target worktree resolution returned $reasonCode ($([string]$Target.Detail)); no root was probed"
        return @{ RelativePath = $Path; ProbePath = $null; Rejected = $true; RejectionDetail = $detail }
    }
    $relativePath = $Path
    if ((ConvertTo-HookTargetWorktreeNormalizedPath -Path $Path) -match '^(/|[A-Za-z]:/)') {
        $relativePath = Resolve-SubagentStopArtifactPath -Path $Path -WorktreeRoot $WorktreeRoot -SessionRoot $SessionRoot
    }
    if (-not (Test-SubagentStopSessionRoot -WorktreeRoot $WorktreeRoot -SessionRoot $SessionRoot)) {
        $normalized = ConvertTo-HookTargetWorktreeNormalizedPath -Path $relativePath
        if ($normalized -notmatch '^(/|[A-Za-z]:/)' -and @($normalized -split '/') -contains '..') {
            $detail = "the value contains a '..' segment, which could leave the item worktree '$(ConvertTo-HookTargetWorktreeNormalizedPath -Path $WorktreeRoot)'"
            return @{ RelativePath = $relativePath; ProbePath = $null; Rejected = $true; RejectionDetail = $detail }
        }
    }
    $probePath = Resolve-SubagentStopArtifactPath -Path $relativePath -WorktreeRoot $WorktreeRoot -SessionRoot $SessionRoot
    return @{ RelativePath = $relativePath; ProbePath = $probePath; Rejected = $false; RejectionDetail = $null }
}

function Get-SubagentStopTargetNote {
    <#
    .SYNOPSIS
        Returns the text a hook appends to a "no file exists" block, or an empty string.
    .DESCRIPTION
        A not-derivable or ambiguous resolution names its reason code and states that the session
        root was probed. An item root names the probed location and the resolver source. The
        session-root case returns an empty string, so existing block messages are unchanged.
    .PARAMETER Target
        The Resolve-SubagentStopTargetWorktree result, or $null.
    .PARAMETER ProbePath
        The location the hook probed.
    .PARAMETER SessionRoot
        The hook's session root.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [object] $Target,
        [AllowNull()] [AllowEmptyString()] [string] $ProbePath,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    if ($null -eq $Target) { return '' }
    if ($null -ne $Target.ReasonCode) {
        return " Target worktree resolution returned $($Target.ReasonCode) ($($Target.Detail)); the session root was probed."
    }
    if (Test-SubagentStopSessionRoot -WorktreeRoot $Target.WorktreeRoot -SessionRoot $SessionRoot) { return '' }
    return " Probed location: '$ProbePath' (item worktree resolved by $($Target.Source))."
}
