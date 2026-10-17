#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the manifest branch of the enforce-epic-worktree-removal-gate.ps1
    PreToolUse hook.

.DESCRIPTION
    The manifest-branch Describe moved here unchanged from
    enforce-epic-worktree-removal-gate.Tests.ps1 (issue #935, I-3), which had reached
    the 500-line limit. The determinism rule stated in that file applies here: every
    checkpoint fixture is a literal JSON string injected through a mocked read seam,
    every deny-expecting test mocks both checkpoint seams, and no test reads live
    orchestration state or writes a temporary file.
#>
# Sanctioned-removal manifest branch (issue #635). A separate Describe so the
# manifest module import and its two seam mocks do not alter the fixture set the
# pre-existing Describe in enforce-epic-worktree-removal-gate.Tests.ps1 pins. Both
# checkpoint seams are mocked on every test here, as the suite rule requires of any
# test that can reach a deny.
Describe 'enforce-epic-worktree-removal-gate.ps1 manifest branch' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        # Issue #935 (I-3): after the split this Describe no longer shares the seam-under-test
        # rows of the original file, so both hook-local checkpoint seams get a baseline mock here.
        # The BeforeEach mocks below still supply each test's fixture.
        Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent', 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex'
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1").Path -Force
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
        Mock Resolve-EpicWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
    }
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        # Neither checkpoint fixture records the removal target, so both existing
        # positive predicates are false and condition 10 does not exclude the target.
        Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { '{"features":[]}' }
        Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { '{"route_id":"parallel","items":[]}' }
        # Literal JSON through the module read seam and a constructed UTC value
        # through its clock seam: no temporary file, no wall-clock read.
        Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith {
            '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-09-07T03:40:00Z","run_id":"cleanup-2026-09-07T03-40-00Z-a47a5e33","removals":[{"worktree_path":"/repo/worktrees/cleanup-target","branch":"drm-copilot-wt-2026-08-14T09-02","branch_state":"HAS_UNIQUE_RESIDUALS","removal_disposition":"SAFE_TO_DELETE","verdict":"ALREADY_SOLVED_ELSEWHERE","evidence":"Unique residual commit 3f9a1c2 is already fixed on main under issue #612."}],"preserved_files":[]}'
        }
        Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest' -MockWith {
            [datetime]::new(2026, 9, 7, 4, 0, 0, [System.DateTimeKind]::Utc)
        }
    }

    It 'allows removal when a fresh manifest record authorizes the target' {
        $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/cleanup-target"}}'
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    # Condition 10. The manifest record here satisfies conditions 1 through 9, so a
    # deny can only come from the checkpoint-presence exclusion. A merge_status outside
    # the allow-set makes the point sharper: the existing branch does not authorize the
    # removal either, and the gate must still refuse rather than fall through to the
    # manifest.
    It 'denies a manifest-covered removal whose target an epic checkpoint records' {
        Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { '{"features":[{"worktree_path":"/repo/worktrees/cleanup-target","merge_status":"in_progress"}]}' }
        $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/cleanup-target"}}'
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_WORKTREE_REMOVAL_BLOCKED*'
    }

    # The literal below is the pre-change SOURCE text of the reason string, and the
    # returned reason is its EXPANSION, so the two substitutions the double-quoted
    # string performs at run time are applied before comparing: $worktreePath becomes
    # the supplied target and each doubled quote becomes one quote character.
    It 'emits the unchanged epic block reason' {
        $target = '/repo/worktrees/not-authorized'
        $source = 'EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for ''$worktreePath'' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == ""parallel"" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal.'
        $expected = $source.Replace('$worktreePath', $target).Replace('""', '"')
        $expected += " Diagnostics: epic run SessionRoot (checkpoint '/synthetic-worktrees/default-session/artifacts/orchestration/epic-orchestrator-state.json'), no matching features[] record; parallel run SessionRoot (checkpoint '/synthetic-worktrees/default-session/artifacts/orchestration/parallel-orchestrator-state.json'), no matching items[] record."
        $json = "{""tool_input"":{""command"":""git worktree remove $target""}}"
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $expected
    }

    # The manifest introduces removal_disposition as a distinct key with a distinct
    # value set; the merge_status allow-set must not be widened to carry that traffic.
    It 'keeps the merge_status allow-set unchanged' {
        $script:AllowedMergeStatuses | Should -HaveCount 2
        $script:AllowedMergeStatuses[0] | Should -BeExactly 'merged'
        $script:AllowedMergeStatuses[1] | Should -BeExactly 'worktree_removed'
    }
}
