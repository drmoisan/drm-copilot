#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision-level release-commit allowance suite for the Claude preimplementation gate (issue #1201).

.DESCRIPTION
    Drives the rows of enforce-orchestration-preimplementation-gate.ReleaseAllowance.Cases.ps1
    through Invoke-OrchestrationPreimplementationGateDecision of
    .claude/hooks/enforce-orchestration-preimplementation-gate.ps1. No per-feature checkpoint is
    ready, so each classified call reaches the deny tail, where the cleanup, bookkeeping,
    docs-estate, parallel records, and release-commit allowance legs are evaluated.

    Isolation: the issue #737 baseline isolation form. Read-OrchestrationGateCheckpoint returns the
    synthetic root /synthetic-worktrees/release plus the item checkpoint suffix (except for the
    AC-18 row, which reaches the unmocked issue #1188 resolver); the bookkeeping configuration
    disables that leg; Test-OrchestrationDocsEstateCheckpointPresent and
    Get-WorktreeResolutionGitFileText keep the docs-estate leg off the file system; the allowance
    file, the container probe, the HEAD branch, and the staged index are mocked per row. No row
    creates a file, starts a process, or reads a real worktree.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.ReleaseAllowance.Cases.ps1')
}

Describe 'enforce-orchestration-preimplementation-gate.ps1 release-commit allowance leg (issue #1201)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path (Split-Path -Parent $script:UnderTest) 'enforce-orchestration-preimplementation-gate-release.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.ReleaseAllowance.Cases.ps1')
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @() }
        $checkpointPath = $script:ReleaseAllowanceSyntheticRoot + '/artifacts/orchestration/orchestrator-state.json'
        # Pester 6 throws when no filtered mock matches, so the default mock runs the unmocked
        # resolver for the AC-18 row and the filtered mock serves every other row.
        $script:ReleaseAllowanceOriginalRead = (Get-Command -Name Read-OrchestrationGateCheckpoint -CommandType Function).ScriptBlock
        Mock Read-OrchestrationGateCheckpoint { & $script:ReleaseAllowanceOriginalRead @PesterBoundParameters }
        Mock Read-OrchestrationGateCheckpoint -ParameterFilter { $Command -cne 'git -C "$WT" add package.json' } { [pscustomobject]@{ Resolved = $true; Raw = ''; Path = $checkpointPath; DenyReason = $null } }.GetNewClosure()
        Mock Test-OrchestrationDocsEstateCheckpointPresent { $false }

        function Invoke-ReleaseAllowanceRow {
            <#
                Registers the per-row mocks and runs the decision for one row in the envelope
                payload shape of the Claude gate.
            #>
            param([Parameter(Mandatory)][hashtable] $Row)

            $config = if ($Row.ContainsKey('Config')) { $Row.Config } else { $script:ReleaseAllowanceValidConfig }
            if ($Row.ConfigAbsent) { Mock Get-OrchestrationGateReleaseAllowanceConfigText { $null } }
            elseif ($Row.ConfigThrows) { Mock Get-OrchestrationGateReleaseAllowanceConfigText { throw 'synthetic read failure' } }
            else { Mock Get-OrchestrationGateReleaseAllowanceConfigText { $config }.GetNewClosure() }
            $script:ReleaseAllowanceDirectory = [string]$Row.Directory
            if ($Row.ContainerThrows) { Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { throw 'synthetic probe failure' } }
            else { Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $RelativePath -ceq $script:ReleaseAllowanceDirectory } }
            $branch = if ($Row.ContainsKey('Branch')) { $Row.Branch } else { 'release/v1.2.3' }
            Mock Get-EpicScopeWorktreeHeadBranch { $branch }.GetNewClosure()
            $staged = if ($Row.StagedNull) { $null } else {
                [pscustomobject]@{
                    ExitCode = $(if ($Row.ContainsKey('StagedExitCode')) { $Row.StagedExitCode } else { 0 })
                    Output   = $(if ($Row.ContainsKey('StagedOutput')) { $Row.StagedOutput } else { "package.json`0CHANGELOG.md`0" })
                }
            }
            Mock Get-OrchestrationGateStagedIndex { $staged }.GetNewClosure()
            $bookkeeping = if ($Row.ContainsKey('BookkeepingConfig')) { $Row.BookkeepingConfig } else { $script:ReleaseAllowanceDisabledBookkeepingConfig }
            Mock Get-OrchestrationGateBookkeepingConfigText { $bookkeeping }.GetNewClosure()

            if ($Row.Mode -eq 'write') {
                $toolInputRaw = @{ tool_name = 'Write'; tool_input = @{ file_path = $Row.Command; content = 'x' } } | ConvertTo-Json -Compress -Depth 5
            } else {
                $toolInputRaw = @{ tool_name = 'Bash'; tool_input = @{ command = $Row.Command } } | ConvertTo-Json -Compress -Depth 5
            }
            if ($Row.Mode -eq 'raw') {
                $notReady = @{ 'issue-num' = ''; 'feature-folder' = ''; route_id = ''; lifecycle_ready = $false } | ConvertTo-Json -Compress
                return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw -CheckpointRaw $notReady
            }
            return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'decides release-allowance row <Id>' -ForEach $script:ReleaseAllowanceDecisionCase {
        # Arrange and act: the row selects the mocks and the payload.
        $decision = Invoke-ReleaseAllowanceRow -Row $_

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be $_.Expected -Because "row $($_.Id)"
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
        if ($_.Expected -eq 'deny' -and $_.ReasonLike) {
            $reason | Should -Match $_.ReasonLike -Because "row $($_.Id) keeps the resolver deny"
            $reason | Should -Not -Match 'Release allowance not applied' -Because "row $($_.Id) carries no release suffix"
        } elseif ($_.Expected -eq 'deny') {
            $reason | Should -BeExactly ($script:ReleaseAllowanceGenericDenyText + $_.Suffix) -Because "row $($_.Id)"
        }
        if ($_.OneSuffix) { ([regex]::Matches($reason, 'Release allowance not applied:')).Count | Should -Be 1 -Because "row $($_.Id) reports one code" }
        foreach ($entry in @(if ($_.Invoke) { $_.Invoke.GetEnumerator() })) {
            Should -Invoke -CommandName $entry.Key -Times $entry.Value -Exactly -Because "row $($_.Id) calls $($entry.Key) $($entry.Value) times"
        }
    }
}
