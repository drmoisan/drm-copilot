#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the pr-author gate's worktree target resolution (issue #687).

.DESCRIPTION
    Covers the defect this change exists to remove: the gate validated a call against
    whichever orchestrator checkpoint occupied the session root, so in a parallel or epic
    topology it could return allow on the strength of a sibling item's state.

    The resolution outcome is injected through the Resolve-PrAuthorWorktreeTarget seam. The
    resolver behind it reads real git state, so driving it directly would make these tests
    depend on whichever worktrees exist on the machine running them.

    Issue #1011: TR-01 to TR-09 run the real Resolve-PrAuthorWorktreeTarget body with the shared
    resolver Resolve-HookTargetWorktree, the identity resolver Resolve-WorktreeItemTarget, and the
    current-branch reader Get-PrAuthorCurrentBranch mocked, so no row starts git. Resolver results
    are built in test scope with the six properties of the shared resolver's result.

    Issue #673: both expected reason codes come from the worktree-resolution accessors rather
    than from a literal, and every synthetic root is composed at run time from the path root
    of $PSScriptRoot, so no drive-letter path is written here.
#>

Describe 'enforce-pr-author-skill.ps1 target resolution' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
        Mock Get-PrAuthorCheckpointContent { $null }
        Mock Get-PrAuthorReceiptContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }

        # The accessors resolve through the helpers the hook dot-sources, whose own module
        # import lands in this session state.
        $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
        $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode

        $script:SeamRoot = ([System.IO.Path]::GetPathRoot($PSScriptRoot) + 'f5-seam-root').Replace([string][char]92, '/')
        $script:ItemRoot = "$($script:SeamRoot)/item-701"
        $script:SessionRootPath = "$($script:SeamRoot)/session"
        $script:CheckpointRelative = 'artifacts/orchestration/orchestrator-state.json'
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'the checkpoint is taken from the resolved target, not the session root' {
        It 'validates the sibling worktree checkpoint when --head names another worktree' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $script:ItemRoot; ReasonCode = $null; Detail = 'branch names item-701' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
                $script:capturedPath = $CheckpointPath
                [pscustomobject]@{ HasErrors = $false; ErrorText = '' }
            }
            Mock -CommandName Test-PrAuthorReceiptVerification -MockWith { $null }
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --head feature/item-701 --body-file artifacts/pr_body_701.md'

            $reason | Should -BeNullOrEmpty
            $script:capturedPath | Should -BeLike ("{0}*" -f $script:ItemRoot)
            $script:capturedPath | Should -BeLike ("*{0}" -f $script:CheckpointRelative)
        }

        It 'uses the absolute session-root checkpoint path when the target resolves to the session root' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $script:SessionRootPath; ReasonCode = $null; Detail = 'session root' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
                $script:capturedPath = $CheckpointPath
                [pscustomobject]@{ HasErrors = $false; ErrorText = '' }
            }
            Mock -CommandName Test-PrAuthorReceiptVerification -MockWith { $null }
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --head feature/self --body-file artifacts/pr_body_1.md'

            $reason | Should -BeNullOrEmpty
            $script:capturedPath | Should -BeExactly "$($script:SessionRootPath)/$($script:CheckpointRelative)"
        }
    }

    Context 'an underivable target denies instead of answering from unrelated state' {
        It 'denies with the no-target code when the call names no target' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionNoTargetReasonCode); Detail = 'the call names no feature folder, file path, or branch.' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { throw 'the gate must not consult any checkpoint for an underivable target' }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --title x --body-file artifacts/pr_body_1.md'

            $reason | Should -BeLike ("{0}*" -f (Get-WorktreeResolutionNoTargetReasonCode))
            $reason | Should -BeLike '*--head*'
            Should -Invoke -CommandName Invoke-OrchestratorStatePreflight -Times 0 -Exactly
        }

        It 'denies with the ambiguity code when signals disagree' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionAmbiguityReasonCode); Detail = 'the branch matches two worktrees.' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { throw 'the gate must not consult any checkpoint for an ambiguous target' }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --head feature/shared --body-file artifacts/pr_body_1.md'

            $reason | Should -BeLike ("{0}*" -f (Get-WorktreeResolutionAmbiguityReasonCode))
            Should -Invoke -CommandName Invoke-OrchestratorStatePreflight -Times 0 -Exactly
        }

        It 'never reports success on a sibling checkpoint: the false-approval case of defect 3.2' {
            # The sibling's checkpoint is the only state present and would pass the preflight.
            # Before issue #687 the gate consulted it and allowed; it must now refuse.
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionNoTargetReasonCode); Detail = 'no signal.' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { [pscustomobject]@{ HasErrors = $false; ErrorText = '' } }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --body-file artifacts/pr_body_838.md'

            $reason | Should -Not -BeNullOrEmpty
            $reason | Should -BeLike ("{0}*" -f (Get-WorktreeResolutionNoTargetReasonCode))
        }
    }

    Context 'shared resolver consumption (issue #1011)' {
        BeforeAll {
            Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/HookTargetWorktree.psm1')).Path -ErrorAction Stop
            $script:HeadCommand = 'gh pr create --head feature/item-701 --body-file artifacts/pr_body_701.md'
            $script:FeatureFolderRoot = "$($script:SeamRoot)/docs/features/active/item-701"
            $script:IdentityNoTarget = New-WorktreeResolutionTargetResult -Status NoTarget -SessionRoot $script:SessionRootPath -Detail 'identity resolution found no target.'

            # Build a resolver result with the six RESOLVER_CONTRACT properties.
            function New-HookTargetTestResult {
                param($Root, [string] $Source, [bool] $Ambiguous = $false, $ReasonCode = $null)
                [pscustomobject]@{ WorktreeRoot = $Root; Source = $Source; Ambiguous = $Ambiguous; ReasonCode = $ReasonCode; Detail = 'test resolver result'; Candidates = [string[]] @() }
            }
        }

        BeforeEach {
            Mock -CommandName Resolve-WorktreeItemTarget -MockWith { $script:IdentityNoTarget }
            Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { $null }
        }

        It 'TR-01 invokes Resolve-HookTargetWorktree once for a --head command' {
            $script:HookResult = New-HookTargetTestResult -Root $script:ItemRoot -Source 'CommandOperand'
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { $script:HookResult }

            $null = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly
        }

        It 'TR-02 maps a CommandOperand root equal to the session root to SessionRoot' {
            $result = New-HookTargetTestResult -Root $script:SessionRootPath -Source 'CommandOperand'

            $target = ConvertFrom-PrAuthorHookTargetResult -Result $result -CommandText $script:HeadCommand -SessionRoot $script:SessionRootPath

            $target.Status | Should -Be 'SessionRoot'
            $target.WorktreeRoot | Should -Be $script:SessionRootPath
            $target.Signal | Should -Be 'Branch'
        }

        It 'TR-03 maps a different CommandOperand root to OtherWorktree' {
            $script:HookResult = New-HookTargetTestResult -Root $script:ItemRoot -Source 'CommandOperand'
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { $script:HookResult }

            $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

            $target.Status | Should -Be 'OtherWorktree'
            $target.WorktreeRoot | Should -Be $script:ItemRoot
            $target.ReasonCode | Should -BeNullOrEmpty
            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly
        }

        It 'TR-04 maps an ambiguous result to Ambiguous with the ambiguity code' {
            $script:HookResult = New-HookTargetTestResult -Root $null -Source 'CommandOperand' -Ambiguous $true -ReasonCode $script:AmbiguityCode
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { $script:HookResult }

            $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

            $target.Status | Should -Be 'Ambiguous'
            $target.ReasonCode | Should -Be $script:AmbiguityCode
            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly
        }

        It 'TR-05 maps a not-derivable result to NoTarget with the no-target code after the current-branch fallback' {
            $script:HookResult = New-HookTargetTestResult -Root $null -Source 'CommandOperand' -ReasonCode $script:NoTargetCode
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { $script:HookResult }

            $mapped = ConvertFrom-PrAuthorHookTargetResult -Result $script:HookResult -CommandText $script:HeadCommand -SessionRoot $script:SessionRootPath
            $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

            $mapped | Should -BeNullOrEmpty
            $target.Status | Should -Be 'NoTarget'
            $target.ReasonCode | Should -Be $script:NoTargetCode
            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly
            Should -Invoke -CommandName Get-PrAuthorCurrentBranch -Times 0 -Exactly
        }

        It 'TR-06 does not select a worktree from the <Source> source' -ForEach @(
            @{ Source = 'SessionRoot' }
            @{ Source = 'DelegationIdentity' }
        ) {
            $script:HookResult = New-HookTargetTestResult -Root $script:ItemRoot -Source $Source
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { $script:HookResult }

            $mapped = ConvertFrom-PrAuthorHookTargetResult -Result $script:HookResult -CommandText $script:HeadCommand -SessionRoot $script:SessionRootPath
            $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

            $mapped | Should -BeNullOrEmpty
            $target.Status | Should -Be 'NoTarget'
            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly
        }

        It 'TR-07 does not select a worktree from a path-derived source (issue #673)' {
            $script:HookResult = New-HookTargetTestResult -Root $script:FeatureFolderRoot -Source 'FilePath'
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { $script:HookResult }

            $mapped = ConvertFrom-PrAuthorHookTargetResult -Result $script:HookResult -CommandText $script:HeadCommand -SessionRoot $script:SessionRootPath
            $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

            $mapped | Should -BeNullOrEmpty
            $target.Status | Should -Be 'NoTarget'
            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly
        }

        It 'TR-08 never invokes the shared resolver for a command with no branch signal' {
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { throw 'the shared resolver must not run without a branch signal' }

            $target = Resolve-PrAuthorWorktreeTarget -CommandText 'gh pr create --title x --body-file artifacts/pr_body_1.md'

            $target.Status | Should -Be 'NoTarget'
            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 0 -Exactly
        }

        It 'TR-09 passes the --head branch to the shared resolver only through -CommandBranch' {
            $script:HookResult = New-HookTargetTestResult -Root $script:ItemRoot -Source 'CommandOperand'
            Mock -CommandName Resolve-HookTargetWorktree -MockWith { $script:HookResult }
            $command = "gh pr create --head feature/item-701 --body-file $($script:FeatureFolderRoot)/artifacts/pr_body_701.md"

            $null = Resolve-PrAuthorWorktreeTarget -CommandText $command

            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly
            Should -Invoke -CommandName Resolve-HookTargetWorktree -Times 1 -Exactly -ParameterFilter {
                $CommandBranch -eq 'feature/item-701' -and -not $FilePath -and -not $CommandOperandPath -and [string]::IsNullOrEmpty($DelegationPrompt)
            }
        }
    }
}