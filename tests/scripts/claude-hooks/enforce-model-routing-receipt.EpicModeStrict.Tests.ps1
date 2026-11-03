#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Strict epic_mode rows for Get-ModelRoutingAuthorAssertedReason (issue #1001).

.DESCRIPTION
    The author-asserted autoclose line is waived only when the per-feature checkpoint records
    epic_mode as the JSON boolean true. A string such as "true", or a number such as 1, does not
    waive it, so a prompt without the line returns the AUTHOR_ASSERTED_AUTOCLOSE_MISSING reason.
    Each checkpoint is built with ConvertFrom-Json from an in-memory string. No row creates a file,
    runs a process, or reads a checkpoint from disk.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    Mock Get-ModelRoutingCheckpoint { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    $script:PromptWithoutLine = "Open the pull request for the item.`nCanonical issue number for this feature is 1001.`nbranch: bug/merge-gate-epic-mode-string-false-1001"
}

Describe 'enforce-model-routing-receipt.ps1 - Get-ModelRoutingAuthorAssertedReason strict epic_mode (issue #1001)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'issue-num 1001 recorded and no author-asserted line in the prompt' {
        It 'returns <Outcome> when epic_mode is <Label>' -ForEach @(
            @{ Label = 'JSON true'; Fragment = ',"epic_mode":true'; Outcome = 'null' }
            @{ Label = 'JSON false'; Fragment = ',"epic_mode":false'; Outcome = 'AUTHOR_ASSERTED_AUTOCLOSE_MISSING' }
            @{ Label = 'JSON null'; Fragment = ',"epic_mode":null'; Outcome = 'AUTHOR_ASSERTED_AUTOCLOSE_MISSING' }
            @{ Label = 'absent'; Fragment = ''; Outcome = 'AUTHOR_ASSERTED_AUTOCLOSE_MISSING' }
            @{ Label = 'string false'; Fragment = ',"epic_mode":"false"'; Outcome = 'AUTHOR_ASSERTED_AUTOCLOSE_MISSING' }
            @{ Label = 'string true'; Fragment = ',"epic_mode":"true"'; Outcome = 'AUTHOR_ASSERTED_AUTOCLOSE_MISSING' }
            @{ Label = 'integer 1'; Fragment = ',"epic_mode":1'; Outcome = 'AUTHOR_ASSERTED_AUTOCLOSE_MISSING' }
            @{ Label = 'integer 0'; Fragment = ',"epic_mode":0'; Outcome = 'AUTHOR_ASSERTED_AUTOCLOSE_MISSING' }
        ) {
            # Arrange
            $checkpoint = ('{"issue-num":"1001"' + $Fragment + '}') | ConvertFrom-Json

            # Act
            $result = Get-ModelRoutingAuthorAssertedReason -Checkpoint $checkpoint -PromptText $script:PromptWithoutLine

            # Assert
            if ($Outcome -eq 'null') {
                $result | Should -BeNullOrEmpty -Because "epic_mode is $Label"
            } else {
                $result | Should -Match $Outcome -Because "epic_mode is $Label"
            }
        }
    }
}
