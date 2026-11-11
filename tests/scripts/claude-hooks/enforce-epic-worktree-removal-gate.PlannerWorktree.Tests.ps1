#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Planner allow branch of the Claude epic worktree-removal gate (issue #1161).

.DESCRIPTION
    Drives Invoke-EpicWorktreeRemovalGateDecision with the planner adapter seams
    Get-PlannerWorktreeCheckpointText and Invoke-PlannerWorktreeGitExe mocked in memory, the
    epic and parallel checkpoint seams returning no matching record, and the run target fixed
    to the session-root fallback. No row reads or writes a file or starts git; roots are
    synthetic forward-slash paths without a drive letter.
#>

Describe 'enforce-epic-worktree-removal-gate.ps1 planner branch' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-epic-worktree-removal-gate.ps1')
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-worktree-removal-gate-planner.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent', 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex'
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1') -ErrorAction Stop
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
        # No main checkout root is modelled, so no row reads the real repository (issue #995).
        Mock Get-WorktreeRunMainCheckoutRoot { $null }
        Mock Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution { $null }
        Mock Resolve-EpicWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }

        $script:Target = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha'
        $script:Planner = '{"integration_branch":"epic/alpha","planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"prepared","feature_folder":"f"}]}'
        $script:Unlocked = @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'branch refs/heads/feature/alpha-1', '')
        $script:Locked = @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'branch refs/heads/feature/alpha-1', 'locked claude agent agent-alpha (pid 4242)', '')
        $source = 'EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for ''$worktreePath'' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == ""parallel"" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal.'
        $script:Diagnostics = " Diagnostics: epic run SessionRoot (checkpoint '/synthetic-worktrees/default-session/artifacts/orchestration/epic-orchestrator-state.json'), no matching features[] record; parallel run SessionRoot (checkpoint '/synthetic-worktrees/default-session/artifacts/orchestration/parallel-orchestrator-state.json'), no matching items[] record."
        $script:DenySource = $source.Replace('""', '"')

        function Set-GatePlannerScenario {
            # Install the planner text, porcelain listing, and git results of one row.
            param([string] $Planner = $script:Planner, [string[]] $Listing = $script:Unlocked, [hashtable] $Git = @{})
            $script:PlannerText = $Planner
            $script:GitResult = @{
                worktree = @{ ExitCode = 0; Output = $Listing }; status = @{ ExitCode = 0; Output = @() }; 'rev-parse' = @{ ExitCode = 0; Output = @('abc1234') }
                integration = @{ ExitCode = 0; Output = @() }; branch = @{ ExitCode = 1; Output = @() }
            }
            foreach ($key in $Git.Keys) { $script:GitResult[$key] = $Git[$key] }
        }

        function Invoke-EpicPlannerRow {
            # Run the gate for one command and return the decision.
            param([string] $Command = "git worktree remove $($script:Target)")
            return Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
        }
    }
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'sentinel: under the baseline helper an unrecorded deny reads the planner seam once and reaches no live root or git' {
        Mock Get-EpicWorktreeGateCheckpointContent { '{"features":[]}' }
        Mock Get-EpicWorktreeGateParallelCheckpointContent { '{"route_id":"parallel","items":[]}' }
        Mock Get-WorktreeItemLiveRoot { throw 'live roots must not be enumerated' }
        Mock Invoke-PlannerWorktreeGitExe { throw 'git must not run' }
        $target = '/synthetic-worktrees/unrecorded'
        $decision = Invoke-EpicPlannerRow -Command "git worktree remove $target"
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly ($script:DenySource.Replace('$worktreePath', $target) + $script:Diagnostics)
        Should -Invoke Get-PlannerWorktreeCheckpointText -Times 1 -Exactly
        Should -Invoke Get-WorktreeItemLiveRoot -Times 0 -Exactly
        Should -Invoke Invoke-PlannerWorktreeGitExe -Times 0 -Exactly
    }

    Context 'planner rows' {
        BeforeEach {
            Set-GatePlannerScenario
            Mock Get-EpicWorktreeGateCheckpointContent { '{"features":[]}' }
            Mock Get-EpicWorktreeGateParallelCheckpointContent { '{"route_id":"parallel","items":[]}' }
            Mock Get-PlannerWorktreeCheckpointText {
                if ($RelativePath -ceq 'artifacts/orchestration/epic-planner-state.json' -and $script:PlannerText) { [pscustomobject]@{ Root = '/synthetic-worktrees/session'; Text = $script:PlannerText } }
            }
            Mock Invoke-PlannerWorktreeGitExe {
                param([string[]] $GitArgs)
                $key = $GitArgs[2]
                if ($key -eq 'merge-base') { $key = if ($GitArgs[-1] -like 'refs/remotes/origin/epic/*') { 'integration' } else { 'branch' } }
                [pscustomobject]$script:GitResult[$key]
            }
        }

        It 'allows a <Status> record whose HEAD is on the <Ref> ref (AC-5)' -ForEach @(
            @{ Status = 'prepared'; Ref = 'integration'; Git = @{} }
            @{ Status = 'fanned_in'; Ref = 'integration'; Git = @{} }
            @{ Status = 'prepared'; Ref = 'branch'; Git = @{ integration = @{ ExitCode = 1; Output = @() }; branch = @{ ExitCode = 0; Output = @() } } }
            @{ Status = 'fanned_in'; Ref = 'branch'; Git = @{ integration = @{ ExitCode = 1; Output = @() }; branch = @{ ExitCode = 0; Output = @() } } }
        ) {
            Set-GatePlannerScenario -Planner $script:Planner.Replace('"prepared"', """$Status""") -Git $Git
            (Invoke-EpicPlannerRow).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
        It 'denies a dirty target <Name> (AC-9)' -ForEach @(@{ Name = 'without --force'; Flag = '' }, @{ Name = 'with --force'; Flag = '--force ' }) {
            Set-GatePlannerScenario -Git @{ status = @{ ExitCode = 0; Output = @('?? scratch.txt') } }
            $reason = (Invoke-EpicPlannerRow -Command "git worktree remove $Flag$($script:Target)").hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike "* Planner worktree: PLANNER_WORKTREE_DIRTY: branch 'feature/alpha-1' has uncommitted or untracked changes."
        }
        It 'denies an unrecorded target with the byte-identical pre-change text (AC-10)' {
            $target = '/synthetic-worktrees/unrecorded'
            $decision = Invoke-EpicPlannerRow -Command "git worktree remove $target"
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly ($script:DenySource.Replace('$worktreePath', $target) + $script:Diagnostics)
        }
        It 'refuses <Code> and appends the sentence after the diagnostics clause' -ForEach @(
            @{ Code = 'NOT_ELIGIBLE'; Planner = '{"planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"removed"}]}'; Listing = $null; Git = @{} }
            @{ Code = 'DIRTY'; Planner = $null; Listing = $null; Git = @{ status = @{ ExitCode = 0; Output = @(' M a.txt') } } }
            @{ Code = 'NOT_PUSHED'; Planner = $null; Listing = $null; Git = @{ integration = @{ ExitCode = 1; Output = @() } } }
            @{ Code = 'IN_USE'; Planner = $null; Listing = 'locked'; Git = @{} }
            @{ Code = 'AMBIGUOUS'; Planner = $null; Listing = 'twice'; Git = @{} }
            @{ Code = 'GIT_FAILED'; Planner = $null; Listing = $null; Git = @{ 'rev-parse' = @{ ExitCode = 128; Output = @() } } }
        ) {
            $listing = switch ($Listing) { 'locked' { $script:Locked } 'twice' { $script:Unlocked + @('worktree /synthetic-worktrees/copy', 'branch refs/heads/feature/alpha-1', '') } default { $script:Unlocked } }
            $planner = if ($Planner) { $Planner } else { $script:Planner }
            Set-GatePlannerScenario -Planner $planner -Listing $listing -Git $Git
            $reason = (Invoke-EpicPlannerRow).hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike ([WildcardPattern]::Escape($script:DenySource.Replace('$worktreePath', $script:Target) + $script:Diagnostics) + " Planner worktree: PLANNER_WORKTREE_$($Code): *.")
            ([regex]::Matches($reason, 'EPIC_WORKTREE_REMOVAL_BLOCKED')).Count | Should -Be 1
        }
        It 'denies a locked target as U3 <Name> (AC-13)' -ForEach @(@{ Name = 'without --force'; Flag = '' }, @{ Name = 'with --force'; Flag = '--force ' }) {
            Set-GatePlannerScenario -Listing $script:Locked
            $reason = (Invoke-EpicPlannerRow -Command "git worktree remove $Flag$($script:Target)").hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike '* Planner worktree: PLANNER_WORKTREE_IN_USE: U3 *'
        }
        It 'still allows through the manifest branch after a planner refusal (AC-20)' {
            Set-GatePlannerScenario -Git @{ status = @{ ExitCode = 0; Output = @(' M a.txt') } }
            Mock Test-CleanupWorktreeManifestAuthorizesRemoval { $true }
            (Invoke-EpicPlannerRow).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-PlannerWorktreeGitExe -Times 2 -Exactly
        }
    }
}
