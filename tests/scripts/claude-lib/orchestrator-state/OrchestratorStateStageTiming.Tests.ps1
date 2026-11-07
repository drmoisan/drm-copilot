#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pins the tolerated, unvalidated stage_timing checkpoint key for the PowerShell validator
    (issue #1097, stage B).

.DESCRIPTION
    The orchestrator main session writes stage_timing into the checkpoint. No validator reads the
    key, so a valid list, JSON null, and a string must leave the plain-mode error list of
    Get-OrchestratorStateUnconditionalError equal to the list for the same checkpoint without the
    key. A control removes a required key, which proves the validator ran. The completion and
    PR-readiness functions of the orchestrator-state modules read a checkpoint path, which the
    no-temporary-file rule excludes for a modified checkpoint, so only the plain mode is driven.

    The base checkpoint is the committed back-compat fixture none.json, read in place; the key is
    added to the parsed object in memory. The suite creates no temporary files.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helpers are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateUnconditional.psm1') -Force
    $script:BasePath = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_blocked_reason_backcompat/none.json").Path

    # Parse a fresh copy of the committed base checkpoint so each case mutates its own object.
    function script:Get-BaseState {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param()
        return [System.IO.File]::ReadAllText($script:BasePath) | ConvertFrom-Json
    }

    # Return the ordered error lines for a state as one newline-joined string, so an empty
    # list and a populated list compare with one assertion.
    function script:Get-ErrorText {
        [CmdletBinding()]
        [OutputType([string])]
        param([Parameter(Mandatory = $true)][psobject] $State)
        $errors = @(Get-OrchestratorStateUnconditionalError -State $State)
        return ($errors -join "`n")
    }
}

Describe 'Orchestrator-state stage_timing tolerated key' {
    It 'OST-PLAIN-IGNORES-STAGE-TIMING' {
        # A valid list, JSON null, and a string each leave the error list unchanged.
        $validList = '[{"stage":"S4_atomic_planning","attempt":1,"started_at":"2026-01-02T01:00:00Z","ended_at":null}]' | ConvertFrom-Json -NoEnumerate
        $values = @($validList, $null, 'not-a-list')
        $expected = Get-ErrorText -State (Get-BaseState)

        foreach ($value in $values) {
            $state = Get-BaseState
            $state.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('stage_timing', $value))

            $observed = Get-ErrorText -State $state

            $observed | Should -Be $expected
            $observed | Should -Not -BeLike '*stage_timing*'
        }
    }

    It 'OST-CONTROL-MISSING-REQUIRED-KEY-REPORTED' {
        # Removing a required key is reported, which proves the validator ran with the key present.
        $state = Get-BaseState
        $state.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('stage_timing', @()))
        $state.PSObject.Properties.Remove('last_updated')

        $observed = Get-ErrorText -State $state

        $observed | Should -BeLike '*Checkpoint missing required key: last_updated*'
        $observed | Should -Not -BeLike '*stage_timing*'
    }
}
