#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pure-function and live-head seam rows for .claude/hooks/enforce-epic-merge-gate-green-ci.ps1 (issue #997).

.DESCRIPTION
    Covers Test-ChildCheckpointGreenCiRecorded (one row per fail-closed case),
    Test-EpicMergeGateGreenCiHeadAgreement, the layer 1b worktree seam, and the body of
    Get-EpicMergeGateLivePrHeadSha through a mocked Invoke-DocsOnlyGhExe. Checkpoints are JSON
    text parsed by ConvertFrom-EpicMergeGateJson, so values carry JSON types. No row starts a
    process, runs git or gh, or writes a file.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'The Invoke-DocsOnlyGhExe mock declares WorkingRoot and GhArgs for mock signature parity with the production seam')]
param()

Describe 'enforce-epic-merge-gate green-CI pure functions (issue #997)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $script:FixtureHead = 'abcdef0123456789abcdef0123456789abcdef01'
        $script:OtherHead = 'fedcba9876543210fedcba9876543210fedcba98'

        function Set-GreenCiFixtureValue {
            <#
            .SYNOPSIS
                Set or remove one dotted-path value in a nested ordered fixture document.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Edits an in-memory test fixture only; it changes no system state.')]
            param(
                [Parameter(Mandatory)][System.Collections.IDictionary] $Document,
                [Parameter(Mandatory)][string] $Path,
                [AllowNull()] $Value,
                [switch] $Remove
            )

            $parts = $Path.Split('.')
            $node = $Document
            # Walk to the parent of the leaf, creating intermediate objects only when setting.
            for ($index = 0; $index -lt $parts.Count - 1; $index++) {
                $part = $parts[$index]
                if ($node[$part] -isnot [System.Collections.IDictionary]) {
                    if ($Remove) { return }
                    $node[$part] = [ordered]@{}
                }
                $node = $node[$part]
            }
            if ($Remove) { $node.Remove($parts[-1]) } else { $node[$parts[-1]] = $Value }
        }

        function New-GreenCiCheckpointJson {
            <#
            .SYNOPSIS
                Return a green standalone checkpoint as JSON text, with named overrides and removals.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds an in-memory JSON string only; it changes no system state.')]
            [CmdletBinding()]
            [OutputType([string])]
            param([hashtable] $Override = @{}, [string[]] $Remove = @())

            $document = [ordered]@{
                step9_status = 'passed'
                ci_gate      = [ordered]@{ conclusion = 'success'; head_sha = $script:FixtureHead }
                pr_gate      = [ordered]@{ pr_number = 42 }
            }
            foreach ($key in $Override.Keys) { Set-GreenCiFixtureValue -Document $document -Path $key -Value $Override[$key] }
            foreach ($key in $Remove) { Set-GreenCiFixtureValue -Document $document -Path $key -Remove }
            return ($document | ConvertTo-Json -Depth 6 -Compress)
        }

        function Get-GreenCiFixture {
            <#
            .SYNOPSIS
                Parse a fixture through the gate's own JSON reader so values carry JSON types.
            #>
            param([hashtable] $Override = @{}, [string[]] $Remove = @())
            return ConvertFrom-EpicMergeGateJson -Raw (New-GreenCiCheckpointJson -Override $Override -Remove $Remove)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'Test-ChildCheckpointGreenCiRecorded allow rows' {
        It 'Test-ChildCheckpointGreenCiRecorded returns true for a green standalone checkpoint' {
            # Arrange
            $checkpoint = Get-GreenCiFixture

            # Act
            $actual = Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42

            # Assert
            $actual | Should -BeTrue
        }

        It 'Test-ChildCheckpointGreenCiRecorded returns true when epic_mode is JSON false' {
            $checkpoint = Get-GreenCiFixture -Override @{ epic_mode = $false }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeTrue
        }

        It 'accepts epic_mode JSON null' {
            $checkpoint = Get-GreenCiFixture -Override @{ epic_mode = $null }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeTrue
        }

        It 'accepts parallel_mode JSON false with a blank parallel_slug' {
            $checkpoint = Get-GreenCiFixture -Override @{ parallel_mode = $false; parallel_slug = ' ' }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeTrue
        }
    }

    Context 'Test-ChildCheckpointGreenCiRecorded fail-closed rows' {
        It 'declines ci_gate case <Case>' -ForEach @(
            @{ Case = 'conclusion pending'; Override = @{ 'ci_gate.conclusion' = 'pending' }; Remove = @() }
            @{ Case = 'conclusion failure'; Override = @{ 'ci_gate.conclusion' = 'failure' }; Remove = @() }
            @{ Case = 'conclusion absent'; Override = @{}; Remove = @('ci_gate.conclusion') }
            @{ Case = 'conclusion Success'; Override = @{ 'ci_gate.conclusion' = 'Success' }; Remove = @() }
            @{ Case = 'conclusion SUCCESS'; Override = @{ 'ci_gate.conclusion' = 'SUCCESS' }; Remove = @() }
            @{ Case = 'ci_gate absent'; Override = @{}; Remove = @('ci_gate') }
            @{ Case = 'ci_gate a string'; Override = @{ ci_gate = 'success' }; Remove = @() }
        ) {
            $checkpoint = Get-GreenCiFixture -Override $Override -Remove $Remove
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'declines step9_status case <Case>' -ForEach @(
            @{ Case = 'absent'; Override = @{}; Remove = @('step9_status') }
            @{ Case = 'pending'; Override = @{ step9_status = 'pending' }; Remove = @() }
            @{ Case = 'failed_remediation_required'; Override = @{ step9_status = 'failed_remediation_required' }; Remove = @() }
            @{ Case = 'blocked_ci_loop_limit'; Override = @{ step9_status = 'blocked_ci_loop_limit' }; Remove = @() }
            @{ Case = 'Passed'; Override = @{ step9_status = 'Passed' }; Remove = @() }
            @{ Case = 'PASSED'; Override = @{ step9_status = 'PASSED' }; Remove = @() }
        ) {
            $checkpoint = Get-GreenCiFixture -Override $Override -Remove $Remove
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'declines pr_gate.pr_number case <Case>' -ForEach @(
            @{ Case = 'absent'; Override = @{}; Remove = @('pr_gate.pr_number') }
            @{ Case = 'JSON null'; Override = @{ 'pr_gate.pr_number' = $null }; Remove = @() }
            @{ Case = 'fractional'; Override = @{ 'pr_gate.pr_number' = 42.5 }; Remove = @() }
            @{ Case = 'non-numeric string'; Override = @{ 'pr_gate.pr_number' = 'forty-two' }; Remove = @() }
            @{ Case = '43 against command 42'; Override = @{ 'pr_gate.pr_number' = 43 }; Remove = @() }
            @{ Case = 'pr_gate absent with a matching authorization record'; Override = @{ standalone_merge_authorizations = @(@{ pr_number = 42 }) }; Remove = @('pr_gate') }
        ) {
            $checkpoint = Get-GreenCiFixture -Override $Override -Remove $Remove
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'declines epic_mode true in the green check' {
            $checkpoint = Get-GreenCiFixture -Override @{ epic_mode = $true }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'declines epic_mode as the string false' {
            $checkpoint = Get-GreenCiFixture -Override @{ epic_mode = 'false' }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'declines epic_mode as the number 1' {
            $checkpoint = Get-GreenCiFixture -Override @{ epic_mode = 1 }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'ci_gate.head_sha case <Case>' -ForEach @(
            @{ Case = 'absent'; Override = @{}; Remove = @('ci_gate.head_sha'); Expected = $false }
            @{ Case = 'blank'; Override = @{ 'ci_gate.head_sha' = '' }; Remove = @(); Expected = $false }
            @{ Case = 'uppercase 40-hex'; Override = @{ 'ci_gate.head_sha' = 'ABCDEF0123456789ABCDEF0123456789ABCDEF01' }; Remove = @(); Expected = $false }
            @{ Case = '39-hex'; Override = @{ 'ci_gate.head_sha' = 'abcdef0123456789abcdef0123456789abcdef0' }; Remove = @(); Expected = $false }
            @{ Case = '41-hex'; Override = @{ 'ci_gate.head_sha' = 'abcdef0123456789abcdef0123456789abcdef012' }; Remove = @(); Expected = $false }
            @{ Case = 'lowercase 64-hex'; Override = @{ 'ci_gate.head_sha' = 'abcdef0123456789abcdef0123456789abcdef010123456789abcdef01234567' }; Remove = @(); Expected = $true }
            @{ Case = 'pr_gate.head_sha differing'; Override = @{ 'pr_gate.head_sha' = 'fedcba9876543210fedcba9876543210fedcba98' }; Remove = @(); Expected = $false }
            @{ Case = 'pr_gate.head_sha JSON null'; Override = @{ 'pr_gate.head_sha' = $null }; Remove = @(); Expected = $true }
        ) {
            $checkpoint = Get-GreenCiFixture -Override $Override -Remove $Remove
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -Be $Expected
        }

        It 'declines parallel_mode true in the green check' {
            $checkpoint = Get-GreenCiFixture -Override @{ parallel_mode = $true }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'declines a non-blank parallel_slug in the green check' {
            $checkpoint = Get-GreenCiFixture -Override @{ parallel_slug = 'cohort-997' }
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber 42 | Should -BeFalse
        }

        It 'declines command PR number case <Case>' -ForEach @(
            @{ Case = 'null'; Number = $null }
            @{ Case = 'zero'; Number = 0 }
        ) {
            $checkpoint = Get-GreenCiFixture
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $checkpoint -CommandPrNumber $Number | Should -BeFalse
        }

        It 'declines a null checkpoint' {
            Test-ChildCheckpointGreenCiRecorded -Checkpoint $null -CommandPrNumber 42 | Should -BeFalse
        }
    }

    Context 'Test-EpicMergeGateGreenCiHeadAgreement' {
        It 'Test-EpicMergeGateGreenCiHeadAgreement returns true for an equal live head and no pin' {
            Test-EpicMergeGateGreenCiHeadAgreement -Checkpoint (Get-GreenCiFixture) -LiveHeadSha $script:FixtureHead -PinnedHeadSha $null | Should -BeTrue
        }

        It 'Test-EpicMergeGateGreenCiHeadAgreement returns false for a differing live head' {
            Test-EpicMergeGateGreenCiHeadAgreement -Checkpoint (Get-GreenCiFixture) -LiveHeadSha $script:OtherHead -PinnedHeadSha $null | Should -BeFalse
        }

        It 'Test-EpicMergeGateGreenCiHeadAgreement returns false for a differing pinned head' {
            Test-EpicMergeGateGreenCiHeadAgreement -Checkpoint (Get-GreenCiFixture) -LiveHeadSha $script:FixtureHead -PinnedHeadSha $script:OtherHead | Should -BeFalse
        }

        It 'Test-EpicMergeGateGreenCiHeadAgreement returns false for an unresolved live head' {
            Test-EpicMergeGateGreenCiHeadAgreement -Checkpoint (Get-GreenCiFixture) -LiveHeadSha $null -PinnedHeadSha $null | Should -BeFalse
        }
    }

    Context 'Get-EpicMergeGateLivePrHeadSha' {
        It 'Get-EpicMergeGateLivePrHeadSha outcome <Case>' -ForEach @(
            @{ Case = 'exit 0 with a valid headRefOid'; Exit = 0; Output = '{"headRefOid":"abcdef0123456789abcdef0123456789abcdef01"}'; Expected = 'abcdef0123456789abcdef0123456789abcdef01' }
            @{ Case = 'exit 1'; Exit = 1; Output = ''; Expected = $null }
            @{ Case = 'exit 124 timeout'; Exit = 124; Output = ''; Expected = $null }
            @{ Case = 'exit -1 missing root'; Exit = -1; Output = ''; Expected = $null }
            @{ Case = 'unparseable JSON'; Exit = 0; Output = 'not json {'; Expected = $null }
            @{ Case = 'malformed headRefOid'; Exit = 0; Output = '{"headRefOid":"ABCDEF"}'; Expected = $null }
        ) {
            # Arrange: the gh seam returns one fixed outcome; gh itself never runs.
            $result = [pscustomobject]@{ ExitCode = $Exit; Output = $Output }
            Mock Invoke-DocsOnlyGhExe -MockWith ({ param([string] $WorkingRoot, [string[]] $GhArgs) $result }.GetNewClosure())

            # Act
            $actual = Get-EpicMergeGateLivePrHeadSha -PrNumber 42 -WorktreeRoot '/synthetic-worktrees/session-997'

            # Assert
            $actual | Should -Be $Expected
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 42 --json headRefOid' }
        }
    }

    Context 'Resolve-EpicMergeGateParallelItemByWorktree' {
        It 'forwards the worktree root to the parallel worktree_path record lookup' {
            # Arrange
            Mock Resolve-WorktreeRunTargetByRecord { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null } }

            # Act
            $actual = Resolve-EpicMergeGateParallelItemByWorktree -WorktreeRoot '/synthetic-worktrees/item-997'

            # Assert
            $actual.Status | Should -Be 'NoTarget'
            Should -Invoke Resolve-WorktreeRunTargetByRecord -Times 1 -Exactly -ParameterFilter { $Kind -eq 'parallel' -and $RecordField -eq 'worktree_path' -and $Value -eq '/synthetic-worktrees/item-997' }
        }
    }
}
