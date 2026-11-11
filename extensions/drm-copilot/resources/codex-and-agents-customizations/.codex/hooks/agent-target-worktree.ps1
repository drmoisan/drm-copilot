<#
.SYNOPSIS
    Codex twin of the AgentTargetWorktree resolver functions (issue #1163).

.DESCRIPTION
    Source: .claude/lib/worktree-resolution/AgentTargetWorktree.psm1. This file carries the two
    functions of that module with byte-identical function text, because Codex hooks cannot import
    .claude/lib in a consumer repository. tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1
    holds the function names and each function's text equal to the module and runs the shared
    resolver rows against this file.

    The only statement outside the function definitions is the guarded dot-source of
    hook-target-worktree.ps1, which supplies Resolve-HookTargetWorktree and its helpers. It is
    dot-sourced by .codex/hooks/enforce-completion-consistency.ps1 and
    .codex/hooks/enforce-file-size-limit.ps1. Edit the module first, then copy the changed
    function text here.

.NOTES
    Compatible with PowerShell 7+. Mirrored byte-identically under
    extensions/drm-copilot/resources/codex-and-agents-customizations/.
#>

try { . (Join-Path $PSScriptRoot 'hook-target-worktree.ps1') } catch { Add-HookDependencyFailure -Name 'hook-target-worktree.ps1' -ErrorRecord $_ }

function ConvertTo-AgentTargetLiveWorktreeListText {
    <#
    .SYNOPSIS
        Drop prunable records from `git worktree list --porcelain` text and re-render the rest.
    .DESCRIPTION
        Pure. Parses the text with ConvertFrom-HookTargetWorktreePorcelain, keeps every
        record that is not prunable, and renders one porcelain stanza per kept record
        (worktree line, then a branch line or a detached line). Returns an object with Text
        (the re-rendered porcelain) and Dropped (the prunable records, in input order).
    .PARAMETER Text
        The porcelain text.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Text
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $dropped = [System.Collections.Generic.List[object]]::new()
    foreach ($record in @(ConvertFrom-HookTargetWorktreePorcelain -Text $Text)) {
        if ($record.Prunable) {
            $dropped.Add($record)
            continue
        }
        $lines.Add("worktree $($record.Root)")
        $lines.Add($(if ($null -ne $record.Branch) { "branch refs/heads/$($record.Branch)" } else { 'detached' }))
        $lines.Add('')
    }
    return [pscustomobject]@{
        Text    = ($lines -join "`n")
        Dropped = $dropped.ToArray()
    }
}

function Resolve-AgentTargetWorktree {
    <#
    .SYNOPSIS
        Resolve the registered worktree an agent's hook call acts on, over live registrations only.
    .DESCRIPTION
        Pure apart from the default WorktreeListInvoker body. The first present source
        decides, in the order: absolute file path, command operand path or branch, the
        delegation branch: label (cross-checked with the canonical issue line), the
        canonical issue line alone, the agent working directory, and the session root. The
        first four are decided by Resolve-HookTargetWorktree, called with a wrapped invoker
        that removes prunable registrations; the agent working directory resolves to its
        enclosing live registered worktree. A branch registered only at a prunable root
        returns TARGET_WORKTREE_NOT_DERIVABLE with a detail naming that root and the remedy
        git worktree repair. Under Policy FailClosedOnIdentity an unresolved result keeps a
        null WorktreeRoot; under SessionFallback it carries the session root. The result
        carries WorktreeRoot, Source, Ambiguous, ReasonCode, Detail, Candidates, Unresolved,
        and StaleRegistration (the dropped prunable roots).
    .PARAMETER SessionRoot
        The absolute session root; the fallback root.
    .PARAMETER FilePath
        File-tool target paths.
    .PARAMETER CommandOperandPath
        Command operand paths parsed by the caller.
    .PARAMETER CommandBranch
        A command branch operand parsed by the caller.
    .PARAMETER DelegationPrompt
        Agent delegation prompt text; its branch: label and canonical issue line are read.
    .PARAMETER AgentWorkingDirectory
        The agent's working directory (for example a SubagentStop payload cwd).
    .PARAMETER Policy
        SessionFallback (default) or FailClosedOnIdentity.
    .PARAMETER WorktreeListInvoker
        { param($SessionRoot) <porcelain text> }; the default runs git worktree list --porcelain.
    .PARAMETER CheckpointIssueReader
        Optional { param($WorktreeRoot) <issue number or $null> } used only for an issue identity.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $SessionRoot,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $FilePath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $CommandOperandPath,
        [AllowNull()] [AllowEmptyString()] [string] $CommandBranch,
        [AllowNull()] [AllowEmptyString()] [string] $DelegationPrompt,
        [AllowNull()] [AllowEmptyString()] [string] $AgentWorkingDirectory,
        [ValidateSet('SessionFallback', 'FailClosedOnIdentity')] [string] $Policy = 'SessionFallback',
        [scriptblock] $WorktreeListInvoker = { param($SessionRoot) $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null; if ($LASTEXITCODE -ne 0) { return '' }; return ($porcelain -join "`n") },
        [scriptblock] $CheckpointIssueReader
    )

    $notDerivableCode = 'TARGET_WORKTREE_NOT_DERIVABLE'
    $ignoreCase = [System.StringComparison]::OrdinalIgnoreCase
    $absolutePattern = '^(/|[A-Za-z]:/)'
    $branchPattern = '(?i)\bbranch:\s*(?<name>[A-Za-z0-9][A-Za-z0-9._/-]*)'
    $issuePattern = 'Canonical issue number for this feature is #?(?<number>\d+)'
    $session = ConvertTo-HookTargetWorktreeNormalizedPath -Path $SessionRoot

    # The wrapped invoker removes prunable records and keeps them for the result; the filter
    # is captured as a script block, so the closure needs no command lookup of its own.
    $dropped = [System.Collections.Generic.List[object]]::new()
    $filter = ${function:ConvertTo-AgentTargetLiveWorktreeListText}
    $userInvoker = $WorktreeListInvoker
    $liveInvoker = {
        param($Root)
        $live = & $filter -Text (@(& $userInvoker $Root) -join "`n")
        foreach ($record in @($live.Dropped)) { $dropped.Add($record) }
        return $live.Text
    }.GetNewClosure()

    $hasPath = @(@($FilePath) + @($CommandOperandPath) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -gt 0
    $hasIdentity = -not [string]::IsNullOrWhiteSpace($DelegationPrompt) -and ($DelegationPrompt -match $branchPattern -or $DelegationPrompt -match $issuePattern)
    $useWorkingDirectory = -not $hasPath -and [string]::IsNullOrWhiteSpace($CommandBranch) -and -not $hasIdentity -and -not [string]::IsNullOrWhiteSpace($AgentWorkingDirectory)

    if ($useWorkingDirectory) {
        # Agent working directory source: its enclosing live registered worktree, listed only
        # when the directory is absolute and differs from the session root.
        $directory = ConvertTo-HookTargetWorktreeNormalizedPath -Path $AgentWorkingDirectory
        $root = $session
        $source = 'SessionRoot'
        $detail = "the agent working directory '$directory' is the session root"
        if ($directory -notmatch $absolutePattern) {
            $detail = "the agent working directory '$directory' is relative, so the session root applies"
        } elseif (-not [string]::Equals($directory, $session, $ignoreCase)) {
            $roots = @()
            try {
                $roots = @(ConvertFrom-HookTargetWorktreePorcelain -Text (& $liveInvoker $SessionRoot) | ForEach-Object { $_.Root })
            } catch {
                $roots = @()
            }
            $enclosing = Get-HookTargetWorktreeEnclosingRoot -Path $directory -Roots $roots
            if ($null -eq $enclosing) {
                $detail = "the agent working directory '$directory' is inside no live registered worktree, so the session root applies"
            } elseif (-not [string]::Equals($enclosing, $session, $ignoreCase)) {
                $root = $enclosing
                $source = 'AgentWorkingDirectory'
                $detail = "the agent working directory '$directory' lies in the worktree '$enclosing'"
            } else {
                $detail = "the agent working directory '$directory' lies in the session worktree"
            }
        }
        $result = [pscustomobject]@{ WorktreeRoot = $root; Source = $source; Ambiguous = $false; ReasonCode = $null; Detail = $detail; Candidates = [string[]] @() }
    } else {
        $arguments = @{ SessionRoot = $SessionRoot; WorktreeListInvoker = $liveInvoker }
        foreach ($name in @('FilePath', 'CommandOperandPath', 'CommandBranch', 'DelegationPrompt', 'CheckpointIssueReader')) {
            if ($PSBoundParameters.ContainsKey($name)) { $arguments[$name] = $PSBoundParameters[$name] }
        }
        $result = Resolve-HookTargetWorktree @arguments
    }

    # A branch registered only at a prunable root names that root and the repair remedy.
    $detailText = [string] $result.Detail
    if ($result.ReasonCode -eq $notDerivableCode) {
        $branches = if (-not [string]::IsNullOrWhiteSpace($CommandBranch)) { @($CommandBranch.Trim()) } else {
            @([regex]::Matches([string] $DelegationPrompt, $branchPattern) | ForEach-Object { $_.Groups['name'].Value.TrimEnd('.', '/') })
        }
        $stale = @($dropped | Where-Object { $record = $_; $null -ne $record.Branch -and @($branches | Where-Object { [string]::Equals($_, $record.Branch, $ignoreCase) }).Count -gt 0 } | ForEach-Object { $_.Root })
        if ($stale.Count -gt 0) {
            $detailText = "branch '$($branches[0])' is registered only at the stale root '$($stale[0])'; run git worktree repair to register the worktree at its current path"
        }
    }

    $unresolved = $null -ne $result.ReasonCode
    $worktreeRoot = $result.WorktreeRoot
    if ($unresolved) { $worktreeRoot = $(if ($Policy -eq 'SessionFallback') { $session } else { $null }) }
    return [pscustomobject]@{
        WorktreeRoot      = $worktreeRoot
        Source            = $result.Source
        Ambiguous         = [bool] $result.Ambiguous
        ReasonCode        = $result.ReasonCode
        Detail            = $detailText
        Candidates        = [string[]] @($result.Candidates)
        Unresolved        = $unresolved
        StaleRegistration = [string[]] @($dropped | ForEach-Object { $_.Root })
    }
}
