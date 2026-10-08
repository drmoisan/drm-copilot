#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Back-compat capture for the orchestrator-state blocked_reason vocabulary (#523).

.DESCRIPTION
    Replays the nine committed checkpoint fixtures in
    tests/fixtures/orchestrator_state_blocked_reason_backcompat (the key absent,
    JSON null, and each pre-existing blocked_reason member) through the PowerShell
    validators in three modes and asserts ordered, case-sensitive equality with the
    powershell section of
    tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json, which
    was captured against the unmodified modules.

    Modes:
      plain                     - Get-OrchestratorStateUnconditionalError on the
                                  loaded checkpoint state.
      require_complete          - Test-OrchestratorStateCompletionReadiness Output,
                                  split into lines (includes the M family).
      require_pr_creation_ready - Test-OrchestratorStatePrCreationReadiness Output,
                                  split into lines.

    The suite reads committed fixtures only; it creates no temporary file and
    starts no external process.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Discovery-time case lists are consumed by -ForEach and helpers inside It blocks')]
param()

# Discovery-time enumeration. Pester executes the file body during discovery, so
# the case list must be built here for -ForEach to generate one It per stem and
# mode.
$backcompatFixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_blocked_reason_backcompat").Path
$backcompatStem = @(
    'absent',
    'null',
    'none',
    'spawn_agent_unavailable',
    'delegation_launch_failed',
    'delegate_no_receipt',
    'delegate_contract_incomplete',
    'validator_failed',
    'user_requested_stop'
)
$backcompatMode = @('plain', 'require_complete', 'require_pr_creation_ready')
$backcompatCase = @(
    foreach ($stem in $backcompatStem) {
        foreach ($mode in $backcompatMode) {
            @{
                Stem        = $stem
                Mode        = $mode
                FixturePath = (Join-Path -Path $backcompatFixtureDirectory -ChildPath "$stem.json")
            }
        }
    }
)

BeforeAll {
    # OrchestratorStateCompletion.psm1 re-imports OrchestratorState.psm1 with
    # -Force, so OrchestratorState.psm1 is imported last.
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCompletion.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateUnconditional.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorState.psm1') -Force

    $script:FixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_blocked_reason_backcompat").Path
    $expectedPath = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json").Path
    $script:ExpectedPowerShell = (Get-Content -LiteralPath $expectedPath -Raw | ConvertFrom-Json -AsHashtable)['powershell']

    # Emit each error line to the pipeline; an empty Output emits nothing, which
    # the caller's @() collects as an empty list.
    function script:ConvertTo-BackcompatErrorLine {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [AllowEmptyString()]
            [string] $Text
        )

        if ([string]::IsNullOrEmpty($Text)) {
            return
        }
        $Text -split "`r?`n"
    }

    # Emit the ordered error lines for one fixture and mode to the pipeline.
    function script:Get-BackcompatActualError {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [string] $Path,

            [Parameter(Mandatory = $true)]
            [string] $Mode
        )

        switch ($Mode) {
            'plain' {
                $state = (Get-OrchestratorStateCheckpoint -CheckpointPath $Path).State
                Get-OrchestratorStateUnconditionalError -State $state
            }
            'require_complete' {
                $output = [string](Test-OrchestratorStateCompletionReadiness -CheckpointPath $Path).Output
                ConvertTo-BackcompatErrorLine -Text $output
            }
            'require_pr_creation_ready' {
                $output = [string](Test-OrchestratorStatePrCreationReadiness -CheckpointPath $Path).Output
                ConvertTo-BackcompatErrorLine -Text $output
            }
            default {
                throw "Unknown back-compat mode: $Mode"
            }
        }
    }
}

Describe 'Orchestrator-state blocked_reason back-compat capture' {
    It 'discovers exactly nine back-compat fixtures' {
        # Arrange / Act
        $names = @(Get-ChildItem -LiteralPath $script:FixtureDirectory -Filter '*.json' -File | ForEach-Object Name)

        # Assert
        $names.Count | Should -Be 9 -Because ($names -join ', ')
    }

    It '<Stem> / <Mode> yields the captured ordered error list' -ForEach $backcompatCase {
        # Arrange
        $expected = [string[]]@($script:ExpectedPowerShell[$Stem][$Mode])

        # Act
        $actual = [string[]]@(Get-BackcompatActualError -Path $FixturePath -Mode $Mode)

        # Assert
        $actual.Count | Should -Be $expected.Count -Because "actual: $($actual -join ' | ')"
        $mismatch = @(
            for ($index = 0; $index -lt $expected.Count; $index++) {
                if (-not ($actual[$index] -ceq $expected[$index])) {
                    "[$index] actual='$($actual[$index])' expected='$($expected[$index])'"
                }
            }
        )
        $mismatch.Count | Should -Be 0 -Because ($mismatch -join '; ')
    }
}
