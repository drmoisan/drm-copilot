<#
.SYNOPSIS
    Planner allow branch of the Codex epic worktree-removal gate (issue #1161).

.DESCRIPTION
    Dot-sourced by enforce-epic-worktree-removal-gate.ps1.
    Get-CodexPlannerWorktreeRemovalDecision collects the facts for one removal target and hands
    them to the pure decision in hook-planner-worktree-removal.ps1. The gate body reads the
    repository-root epic-planner checkpoint and passes its text, together with a reader for
    the target's orchestrator checkpoint, so this file reads no file itself. Its only seam is
    Invoke-CodexPlannerWorktreeGitExe. Git runs only after the planner text holds a candidate
    record, and the target is examined only after a record names it. On Codex only the
    repository-root planner and epic checkpoints are consulted.

    The branch is a policy-level control, not a security control.

.NOTES
    PowerShell 7+. Target, root, and recorded-path comparisons use the gate's
    Get-NormalizedCodexWorktreePath, so they follow the gate's existing path semantics.
    Mirrored byte-identically under extensions/drm-copilot/resources/.
#>

try { . (Join-Path $PSScriptRoot 'hook-planner-worktree-removal.ps1') } catch { Add-HookDependencyFailure -Name 'hook-planner-worktree-removal.ps1' -ErrorRecord $_ }

function Invoke-CodexPlannerWorktreeGitExe {
    <#
    .SYNOPSIS
        Run git with the given arguments (seam).
    .PARAMETER GitArgs
        The git arguments, including -C <directory>.
    .OUTPUTS
        PSCustomObject with ExitCode (-1 when git cannot start) and Output (the stdout lines).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string[]] $GitArgs)

    try {
        $output = @(& git @GitArgs 2>$null)
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = [string[]] $output }
    } catch {
        return [pscustomobject]@{ ExitCode = -1; Output = [string[]] @() }
    }
}

function Get-CodexPlannerWorktreeRemovalDecision {
    <#
    .SYNOPSIS
        Decide the planner branch for one removal target on the Codex surface.
    .DESCRIPTION
        Returns NoRecord before any seam or reader call when the planner text is empty or holds
        no candidate record. Otherwise it lists the worktrees once with -C <WorkingDirectory>,
        matches each candidate's branch to the live root that has it checked out (and its
        optional path to the target), and, when a record names the target, collects U1 to U5
        and runs the target git checks the pure decision asks for.
    .PARAMETER Target
        The removal target, absolute or relative to the working directory.
    .PARAMETER WorkingDirectory
        The payload working directory (U1 and the listing directory).
    .PARAMETER EpicCheckpoint
        The parsed repository-root epic checkpoint the gate already read (U5), or $null.
    .PARAMETER PlannerCheckpointText
        The repository-root epic-planner checkpoint text, or '' when absent.
    .PARAMETER TargetCheckpointReader
        Script block that returns the text of the file path it is given, or $null when the file
        is absent (U4). $null reads every file as absent.
    .PARAMETER RepositoryRoot
        The root that holds the planner checkpoint (U1). Defaults to the repository that
        contains this file.
    .OUTPUTS
        PSCustomObject with Outcome (Allow, Refuse, or NoRecord), Code, Detail, and Suffix.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Target,
        [Parameter(Mandatory)][string] $WorkingDirectory,
        [AllowNull()] $EpicCheckpoint,
        [AllowNull()][AllowEmptyString()][string] $PlannerCheckpointText = '',
        [AllowNull()][scriptblock] $TargetCheckpointReader = $null,
        [AllowNull()][AllowEmptyString()][string] $RepositoryRoot = ''
    )

    $candidates = @(Get-PlannerWorktreeCandidateRecord -Text $PlannerCheckpointText)
    if ($candidates.Count -eq 0) { return Complete-PlannerWorktreeDecision -Decision (Get-PlannerWorktreeOutcome -Outcome NoRecord) }

    $listing = Invoke-CodexPlannerWorktreeGitExe -GitArgs @('-C', $WorkingDirectory, 'worktree', 'list', '--porcelain')
    $facts = @{ Branch = (@($candidates | ForEach-Object { $_.Branch }) -join "', '"); ListingExitCode = $listing.ExitCode; MatchCount = 0 }
    if ($listing.ExitCode -ne 0) { return Complete-PlannerWorktreeDecision -Decision (Get-PlannerWorktreeRemovalDecision -Facts $facts) }

    $targetPath = Get-NormalizedCodexWorktreePath -Path $Target -WorkingDirectory $WorkingDirectory
    $stanzas = @(ConvertFrom-PlannerWorktreePorcelain -Text $listing.Output | ForEach-Object {
            [pscustomobject]@{ Root = (Get-NormalizedCodexWorktreePath -Path $_.Root -WorkingDirectory $WorkingDirectory); Branch = $_.Branch; Locked = $_.Locked; IsMain = $_.IsMain }
        })
    $mainRoot = [string] (@($stanzas | Where-Object { $_.IsMain }) | ForEach-Object { $_.Root } | Select-Object -First 1)
    # A record names the target when its branch is checked out at the target and its optional path agrees.
    $matched = @(foreach ($candidate in $candidates) {
            $roots = @($stanzas | Where-Object { $null -ne $_.Branch -and $_.Branch -ceq $candidate.Branch })
            $atTarget = @($roots | Where-Object { Test-PlannerWorktreePathEqual -Left $_.Root -Right $targetPath })
            if ($atTarget.Count -gt 0 -and (Test-PlannerWorktreeRecordPathMatch -Record $candidate.Record -TargetPath $targetPath -MainRoot $mainRoot)) {
                [pscustomobject]@{ Candidate = $candidate; RootCount = $roots.Count; Stanza = $atTarget[0] }
            }
        })
    if ($matched.Count -eq 0) { return Complete-PlannerWorktreeDecision -Decision (Get-PlannerWorktreeOutcome -Outcome NoRecord) }

    $match = $matched[0]
    if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) { $RepositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }
    $workingRoot = Get-NormalizedCodexWorktreePath -Path $WorkingDirectory -WorkingDirectory $WorkingDirectory
    $facts.Branch = $match.Candidate.Branch
    $facts.MatchCount = $matched.Count
    $facts.BranchRootCount = $match.RootCount
    $facts.Record = $match.Candidate.Record
    $facts.IntegrationBranch = $match.Candidate.IntegrationBranch
    $facts.U1 = (Test-PlannerWorktreePathEncloses -Outer $targetPath -Inner $workingRoot) -or (Test-PlannerWorktreePathEqual -Left $targetPath -Right (Get-NormalizedCodexWorktreePath -Path $RepositoryRoot -WorkingDirectory $WorkingDirectory))
    $facts.U2 = Test-PlannerWorktreePathEqual -Left $targetPath -Right $mainRoot
    $facts.U3 = [bool] $match.Stanza.Locked
    $facts.U4 = $false
    $facts.U5 = $false
    # The in-use reads run only after a record names the target and only while no earlier condition holds.
    if ($facts.MatchCount -eq 1 -and $facts.BranchRootCount -eq 1 -and -not ($facts.U1 -or $facts.U2 -or $facts.U3)) {
        if ($null -ne $TargetCheckpointReader) {
            $text = & $TargetCheckpointReader ($targetPath + '/artifacts/orchestration/orchestrator-state.json')
            $facts.U4 = Test-PlannerWorktreeTargetCheckpointInUse -Text $text
        }
        $epic = Get-PlannerWorktreeEpicRecordFact -Checkpoint $EpicCheckpoint -Branch $facts.Branch
        $recorded = @($epic.WorktreePath | Where-Object { (Get-NormalizedCodexWorktreePath -Path $_ -WorkingDirectory $WorkingDirectory) -eq $targetPath })
        $facts.U5 = $epic.BranchNamed -or $recorded.Count -gt 0
    }
    return Complete-PlannerWorktreeDecision -Decision (Invoke-CodexPlannerWorktreeTargetGitCheck -Facts $facts -WorktreePath $targetPath)
}

function Invoke-CodexPlannerWorktreeTargetGitCheck {
    <#
    .SYNOPSIS
        Run the pure decision, collecting each git fact it reports as Pending, until it settles.
    .PARAMETER Facts
        The facts hashtable; this function adds the git facts to it.
    .PARAMETER WorktreePath
        The removal target, passed to git as -C.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][hashtable] $Facts, [Parameter(Mandatory)][string] $WorktreePath)

    # Each pass either settles the decision or collects exactly one more git fact.
    while ($true) {
        $decision = Get-PlannerWorktreeRemovalDecision -Facts $Facts
        if ($decision.Outcome -ne 'Pending') { return $decision }
        $result = Invoke-CodexPlannerWorktreeGitExe -GitArgs (Get-PlannerWorktreeGitFactArgument -Pending $decision.Pending -WorktreePath $WorktreePath -Facts $Facts)
        Add-PlannerWorktreeGitFact -Pending $decision.Pending -Result $result -Facts $Facts
    }
}
