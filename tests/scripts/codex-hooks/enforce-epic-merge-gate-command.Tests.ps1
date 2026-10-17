#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    In-process tests for the Codex copy of the merge-gate selector helper (issue #952).
.DESCRIPTION
    Calls ConvertFrom-EpicMergeGateSelector and Get-EpicMergeGateSelectorPrNumber of
    .codex/hooks/enforce-epic-merge-gate-command.ps1 directly. The Codex gate is loaded with
    the resolved-path form of the Claude merge-gate suites, and the helper file is then
    dot-sourced from its resolved path, so every function under test is defined by the Codex
    helper file (issue #952 remediation R1). The CR-4 row pins that a non-numeric
    --merge=<value> does not end the selector scan.

    Coverage attribution note (issue #952 R1). These rows execute, in-process, every
    Codex helper line that full-run CI coverage reports as uncovered, and each named
    assertion can pass only through those lines. Lines 67-68: the two pull-URL converter
    rows return 5. Line 72: the feature-branch and 99999999999 converter rows return no
    number. Lines 165 and 166: 'gh pr merge -- 5' returns 5 and 'gh pr merge --merge --'
    returns no number. Lines 171-172: 'gh pr merge --merge=5' returns 5. Line 179:
    'gh pr merge --merge' returns no number. Lines 182-186: 'gh api -X PUT
    repos/o/r/pulls/5/merge' returns 5. Line 189: 'gh api repos/o/r/pulls/5' and
    'git status' return no number. The likely cause is the issue #936 mechanism: Pester
    5.x breakpoint coverage binds each line breakpoint to the first compiled instance of
    the helper code, created earlier in the run by the codex CN-09 rows of
    tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1; this suite later
    runs a recompiled instance whose hits are not credited. The issue #936 research and
    this issue's evidence/regression-testing/codex-helper-coverage-diagnosis.*.md record
    the details.

    Determinism: every case calls a pure string function with literal fixtures. No disk I/O,
    no child process, no temporary file, and no clock read.
#>

Describe 'Codex enforce-epic-merge-gate-command selector reader (issue #952)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        $script:HelperUnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-epic-merge-gate-command.ps1").Path
        . $script:HelperUnderTest
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'ConvertFrom-EpicMergeGateSelector' {
        It 'converts <Selector> to <Label>' -ForEach @(
            @{ Selector = '5'; Expected = 5; Label = '5' }
            @{ Selector = 'https://github.com/o/r/pull/5'; Expected = 5; Label = '5' }
            @{ Selector = 'https://github.com/o/r/pull/5/?tab=checks'; Expected = 5; Label = '5' }
            @{ Selector = 'feature-branch'; Expected = $null; Label = 'no number' }
            @{ Selector = '99999999999'; Expected = $null; Label = 'no number' }
        ) {
            # Act: the converter is a pure string function and reads nothing from disk.
            $number = ConvertFrom-EpicMergeGateSelector -Selector $Selector

            # Assert: digits and a pull URL yield the number; a branch name or an
            # out-of-range digit run yields no number.
            $number | Should -Be $Expected -Because "the selector $Selector resolves to $Label"
        }
    }

    Context 'Get-EpicMergeGateSelectorPrNumber' {
        It 'returns <Label> for <Command>' -ForEach @(
            @{ Command = 'gh pr merge -- 5'; Expected = 5; Label = '5' }
            @{ Command = 'gh pr merge --merge --'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge --merge=5'; Expected = 5; Label = '5' }
            @{ Command = 'gh pr merge --merge=true 5'; Expected = 5; Label = '5' }
            @{ Command = 'gh pr merge --merge'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge feature-branch --merge'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh api -X PUT repos/o/r/pulls/5/merge'; Expected = 5; Label = '5' }
            @{ Command = 'gh api repos/o/r/pulls/5'; Expected = $null; Label = 'no number' }
            @{ Command = 'git status'; Expected = $null; Label = 'no number' }
        ) {
            # Act: the reader is a pure string function and reads nothing from disk.
            $prNumber = Get-EpicMergeGateSelectorPrNumber -CommandText $Command

            # Assert: a bare '--' passes the next token as the selector, a branch name or a
            # REST path without /merge carries no number, and a non-numeric --merge=<value>
            # does not end the scan (issue #952 R1 and CR-4).
            $prNumber | Should -Be $Expected -Because "the selector of $Command resolves to $Label"
        }
    }
}
