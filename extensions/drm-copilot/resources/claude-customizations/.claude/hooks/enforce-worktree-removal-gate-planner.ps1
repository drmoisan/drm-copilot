<#
.SYNOPSIS
    Planner allow branch of the Claude worktree-removal gates (issue #1161).

.DESCRIPTION
    Dot-sourced by enforce-epic-worktree-removal-gate.ps1 and
    enforce-parallel-worktree-removal-gate.ps1. Get-PlannerWorktreeRemovalTargetDecision
    collects the facts for one removal target and hands them to the pure decision in
    hook-planner-worktree-removal.ps1. All I/O goes through two seams:
    Get-PlannerWorktreeCheckpointText (file text beneath every live root) and
    Invoke-PlannerWorktreeGitExe (git). Git runs only after an epic-planner checkpoint
    holds a candidate record, and the target is examined only after a record names it.
    The adapter never writes a checkpoint and never reads the working directory: the
    gate passes its session root.

    The branch is a policy-level control, not a security control.

.NOTES
    PowerShell 7+. Path comparisons use Test-WorktreeRunPathEqual and
    Test-WorktreeRunRecordedPathMatchesTarget from WorktreeRunRecordPath.psm1, which both
    gates import. Mirrored byte-identically under extensions/drm-copilot/resources/.
#>

try { . (Join-Path $PSScriptRoot 'hook-planner-worktree-removal.ps1') } catch { Add-HookDependencyFailure -Name 'hook-planner-worktree-removal.ps1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeItemResolution.psm1' -ErrorRecord $_ }

function Get-PlannerWorktreeCheckpointText {
    <#
    .SYNOPSIS
        Read one repository-relative file beneath every live worktree root (seam).
    .PARAMETER SessionRoot
        The session root the gate derived, used only to find the repository.
    .PARAMETER RelativePath
        The repository-relative file to read.
    .OUTPUTS
        PSCustomObject with Root and Text, one per live root that holds the file.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $SessionRoot, [Parameter(Mandatory)][string] $RelativePath)

    # The live-root seam returns its roots as one array object; the assignment unwraps it.
    $roots = Get-WorktreeItemLiveRoot -SessionRoot $SessionRoot
    # Read the file beneath each live root; a root without the file contributes nothing.
    foreach ($root in @($roots)) {
        if ([string]::IsNullOrWhiteSpace($root)) { continue }
        $text = Get-WorktreeRunCheckpointText -Path ((($root -replace '\\', '/').TrimEnd('/')) + '/' + $RelativePath)
        if ($null -ne $text) { [pscustomobject]@{ Root = $root; Text = $text } }
    }
}

function Invoke-PlannerWorktreeGitExe {
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

function Get-PlannerWorktreeRemovalTargetDecision {
    <#
    .SYNOPSIS
        Decide the planner branch for one removal target on the Claude surface.
    .DESCRIPTION
        Reads the epic-planner checkpoint beneath every live root and returns NoRecord
        before any git call when no candidate record exists. Otherwise it lists the
        worktrees once, matches each candidate's branch to the live root that has it
        checked out (and its optional path to the target), and, when a record names the
        target, collects U1 to U5 and runs the target git checks the pure decision asks for.
    .PARAMETER WorktreePath
        The removal target.
    .PARAMETER SessionRoot
        The session root the gate derived.
    .OUTPUTS
        PSCustomObject with Outcome (Allow, Refuse, or NoRecord), Code, Detail, and Suffix
        (the text the gate appends to its final deny; '' unless refused).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $WorktreePath, [Parameter(Mandatory)][AllowEmptyString()][string] $SessionRoot)

    $candidates = @(foreach ($read in @(Get-PlannerWorktreeCheckpointText -SessionRoot $SessionRoot -RelativePath 'artifacts/orchestration/epic-planner-state.json')) {
            foreach ($candidate in @(Get-PlannerWorktreeCandidateRecord -Text $read.Text)) { [pscustomobject]@{ Root = $read.Root; Candidate = $candidate } }
        })
    if ($candidates.Count -eq 0) { return Complete-PlannerWorktreeDecision -Decision (Get-PlannerWorktreeOutcome -Outcome NoRecord) }

    $listing = Invoke-PlannerWorktreeGitExe -GitArgs @('-C', $SessionRoot, 'worktree', 'list', '--porcelain')
    $facts = @{ Branch = (@($candidates | ForEach-Object { $_.Candidate.Branch }) -join "', '"); ListingExitCode = $listing.ExitCode; MatchCount = 0 }
    if ($listing.ExitCode -ne 0) { return Complete-PlannerWorktreeDecision -Decision (Get-PlannerWorktreeRemovalDecision -Facts $facts) }

    $stanzas = @(ConvertFrom-PlannerWorktreePorcelain -Text $listing.Output)
    $mainRoot = [string] (@($stanzas | Where-Object { $_.IsMain }) | ForEach-Object { $_.Root } | Select-Object -First 1)
    # A record names the target when its branch is checked out at the target and its optional path agrees.
    $matched = @(foreach ($entry in $candidates) {
            $roots = @($stanzas | Where-Object { $null -ne $_.Branch -and $_.Branch -ceq $entry.Candidate.Branch })
            $atTarget = @($roots | Where-Object { Test-WorktreeRunPathEqual -Left $_.Root -Right $WorktreePath })
            $record = $entry.Candidate.Record
            $pathAgrees = (@($record.PSObject.Properties.Name) -cnotcontains 'path') -or ((Test-PlannerWorktreeRelativePathSafe -Path $record.path) -and (Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $record.path -TargetPath $WorktreePath -BaseRoot @($mainRoot)))
            if ($atTarget.Count -gt 0 -and $pathAgrees) { [pscustomobject]@{ Entry = $entry; RootCount = $roots.Count; Stanza = $atTarget[0] } }
        })
    if ($matched.Count -eq 0) { return Complete-PlannerWorktreeDecision -Decision (Get-PlannerWorktreeOutcome -Outcome NoRecord) }

    $match = $matched[0]
    $facts.Branch = $match.Entry.Candidate.Branch
    $facts.MatchCount = $matched.Count
    $facts.BranchRootCount = $match.RootCount
    $facts.Record = $match.Entry.Candidate.Record
    $facts.IntegrationBranch = $match.Entry.Candidate.IntegrationBranch
    $facts.U1 = (Test-PlannerWorktreePathEnclosure -Outer $WorktreePath -Inner $SessionRoot) -or (Test-WorktreeRunPathEqual -Left $WorktreePath -Right $match.Entry.Root)
    $facts.U2 = Test-WorktreeRunPathEqual -Left $WorktreePath -Right $mainRoot
    $facts.U3 = [bool] $match.Stanza.Locked
    $facts.U4 = $false
    $facts.U5 = $false
    # The in-use reads run only after a record names the target and only while no earlier condition holds.
    if ($facts.MatchCount -eq 1 -and $facts.BranchRootCount -eq 1 -and -not ($facts.U1 -or $facts.U2 -or $facts.U3)) {
        foreach ($read in @(Get-PlannerWorktreeCheckpointText -SessionRoot $SessionRoot -RelativePath 'artifacts/orchestration/orchestrator-state.json')) {
            if (Test-WorktreeRunPathEqual -Left $read.Root -Right $WorktreePath) { $facts.U4 = Test-PlannerWorktreeTargetCheckpointInUse -Text $read.Text }
        }
        foreach ($read in @(Get-PlannerWorktreeCheckpointText -SessionRoot $SessionRoot -RelativePath 'artifacts/orchestration/epic-orchestrator-state.json')) {
            $epic = Get-PlannerWorktreeEpicRecordFact -Checkpoint (ConvertFrom-PlannerWorktreeJson -Text $read.Text) -Branch $facts.Branch
            $baseRoot = @(@($mainRoot, $read.Root) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            if ($epic.BranchNamed -or @($epic.WorktreePath | Where-Object { Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $_ -TargetPath $WorktreePath -BaseRoot $baseRoot }).Count -gt 0) { $facts.U5 = $true }
        }
    }
    return Complete-PlannerWorktreeDecision -Decision (Invoke-PlannerWorktreeTargetGitCheck -Facts $facts -WorktreePath $WorktreePath)
}

function Invoke-PlannerWorktreeTargetGitCheck {
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
        $result = Invoke-PlannerWorktreeGitExe -GitArgs (Get-PlannerWorktreeGitFactArgument -Pending $decision.Pending -WorktreePath $WorktreePath -Facts $Facts)
        Add-PlannerWorktreeGitFact -Pending $decision.Pending -Result $result -Facts $Facts
    }
}
