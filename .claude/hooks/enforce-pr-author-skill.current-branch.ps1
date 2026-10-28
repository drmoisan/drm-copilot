<#
.SYNOPSIS
    Current-branch target derivation for enforce-pr-author-skill.ps1 (issue #989).

.DESCRIPTION
    Dot-sourced by enforce-pr-author-skill-helpers.ps1. Resolve-PrAuthorWorktreeTarget passes its
    command-text resolution through Resolve-PrAuthorCurrentBranchTarget, which applies one
    fallback: when the command carries no branch signal (--head, --branch, or branch:) and no
    canonical issue line, and resolution returned NoTarget, the branch checked out in the hook
    process's working directory is read and re-resolved through the existing resolver as a
    'branch: <name>' signal. gh pr edit has no --head flag, so this is how an edit run from the
    item worktree names its own target.

    Derivation order: explicit signal in the command, else the current branch, else the
    original NoTarget result. A signal that matches no live worktree does not trigger the
    fallback. A detached HEAD (git prints the literal HEAD), a non-zero git exit, or empty
    output keeps the original NoTarget result and its reason code.

    Get-PrAuthorTargetGuidanceText supplies the remedy sentence that follows the reason code and
    detail in the TARGET_WORKTREE_NOT_DERIVABLE denial.

.NOTES
    PowerShell 7+. Depends, at call time, on Find-WorktreeResolutionBranchSignal,
    Find-WorktreeItemIssueSignal, and Resolve-WorktreeItemTarget from the worktree-resolution
    modules the helpers file imports. It reads no file content. The git executable runs only
    through Invoke-PrAuthorCurrentBranchGitExe, the single executable seam, which never throws.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>
[CmdletBinding()]
param()

function Invoke-PrAuthorCurrentBranchGitExe {
    <#
    .SYNOPSIS
        Run git with the given arguments in the current directory. The single executable seam.
    .DESCRIPTION
        Never throws: an uncaught error ends the hook with exit 1, which PreToolUse treats as
        non-blocking, so a throw here would allow the call. A git that cannot start returns
        ExitCode -1. Standard error is discarded so that it is never read as a branch name.
    .PARAMETER GitArgs
        The git arguments.
    .PARAMETER GitInvoker
        The scriptblock that runs git; a unit test passes a test-local stand-in so that this
        body runs without starting a process.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output (trimmed).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string[]] $GitArgs,
        [ValidateNotNull()][scriptblock] $GitInvoker = { git @args 2>$null }
    )

    try {
        $lines = @(& $GitInvoker @GitArgs 2>$null)
        $code = $LASTEXITCODE
    }
    catch {
        return [pscustomobject]@{ ExitCode = -1; Output = '' }
    }
    return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n").Trim() }
}

function Get-PrAuthorCurrentBranch {
    <#
    .SYNOPSIS
        Return the branch checked out in the current directory, or $null.
    .DESCRIPTION
        Runs git rev-parse --abbrev-ref HEAD through Invoke-PrAuthorCurrentBranchGitExe. Returns
        $null for a non-zero exit, for empty output, for output containing whitespace, and for
        the literal HEAD that git prints on a detached checkout.
    .PARAMETER GitInvoker
        Optional. Forwarded to the git seam; omitted, the seam's default invoker runs git.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [scriptblock] $GitInvoker
    )

    $seamArgs = @{ GitArgs = @('rev-parse', '--abbrev-ref', 'HEAD') }
    if ($null -ne $GitInvoker) { $seamArgs['GitInvoker'] = $GitInvoker }
    $result = Invoke-PrAuthorCurrentBranchGitExe @seamArgs
    $name = [string]$result.Output
    if ($result.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($name) -or $name -match '\s' -or $name -ceq 'HEAD') {
        return $null
    }
    return $name
}

function Resolve-PrAuthorCurrentBranchTarget {
    <#
    .SYNOPSIS
        Apply the current-branch fallback to a command-text resolution result.
    .DESCRIPTION
        Returns Target unchanged unless its Status is NoTarget and the command text carries
        neither a branch signal nor a canonical issue line. In that case the current branch is
        read; a $null branch returns Target unchanged, and any other branch is re-resolved with
        Resolve-WorktreeItemTarget as the text 'branch: <name>', so ambiguity handling and the
        SessionRoot or OtherWorktree labelling stay with the existing resolver.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER Target
        The result Resolve-WorktreeItemTarget returned for the command text.
    .OUTPUTS
        The target result object from Resolve-WorktreeItemTarget.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText,
        [Parameter(Mandatory)][AllowNull()][object] $Target
    )

    if ($null -eq $Target -or $Target.Status -ne 'NoTarget') {
        return $Target
    }
    # Find-WorktreeItemIssueSignal emits its array as one object, so it is assigned before counting.
    $issueSignal = Find-WorktreeItemIssueSignal -Text $CommandText
    if ($null -ne (Find-WorktreeResolutionBranchSignal -Text $CommandText) -or $issueSignal.Count -gt 0) {
        return $Target
    }
    $branch = Get-PrAuthorCurrentBranch
    if ($null -eq $branch) {
        return $Target
    }
    return (Resolve-WorktreeItemTarget -Text "branch: $branch" -SessionRoot (Get-Location).Path)
}

function Get-PrAuthorTargetGuidanceText {
    <#
    .SYNOPSIS
        Return the remedy sentence of the TARGET_WORKTREE_NOT_DERIVABLE denial.
    .DESCRIPTION
        Names the accepted target forms: --head <branch> on gh pr create, and for gh pr edit
        either running the command from the item worktree (the branch is derived) or appending
        the shell comment # branch: <branch>. States that --head is not valid for gh pr edit.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return 'Name the target: for gh pr create, pass --head <branch> (gh pr create --head <branch> ...). For gh pr edit, run the command from the item worktree so the gate derives the branch from its checkout, or append the shell comment # branch: <branch> to the command; --head is not valid for gh pr edit.'
}
