<#
.SYNOPSIS
    Pester tests for the precedence gate of issue #1164.

.DESCRIPTION
    Covers Test-ParallelPrecedenceJustified in
    .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 (spec
    B6.3, B6.4): a "cost" ordering must name a returned edge, a "correctness"
    ordering needs a non-empty reason, and a legacy entry without kind is not
    tested. Every scheduling result is built in memory; no file is read or
    created.
#>

BeforeAll {
    $script:GatePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1").Path
    $script:SchedulingPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusScheduling.psm1").Path
    # The gate is imported first: it re-imports the scheduling module with
    # -Force, which would otherwise remove this scope's scheduling import.
    Import-Module $script:GatePath -Force
    Import-Module $script:SchedulingPath -Force

    # The recalibrated committed minutes.
    $script:Tolerance = Get-ConfigConflictTolerance -Config @{
        conflict_tolerance = @{
            tolerance_percent = 100
            weights           = @{ same_file = 90; possible_overlap = 20; append_only = 10; module = 10; separable = 15; contract = 90 }
            band_durations    = @{ C1 = 30; C2 = 45; C3 = 90; C4 = 180 }
            default_band      = 'C1'
            append_only_paths = @('**/CHANGELOG.md')
        }
    }

    # A scheduling result for items 1 (C2), 2 (C2), 3 (C3), 4 (C3), and 5 (C4)
    # with one precedence entry; Override replaces any member.
    function Get-GateEntry {
        param([hashtable] $Precedence, [hashtable] $Override = @{})
        $entry = @{
            edges              = @(
                @{ a = 1; b = 2; reason = 'path_overlap'; hard = $false; cost = 90; benefit = 45 },
                @{ a = 2; b = 5; reason = 'contract_dependency'; hard = $true; cost = 90; benefit = 45 }
            )
            tolerated_overlaps = @(@{ a = 3; b = 4; reasons = @('path_overlap'); cost = 90; benefit = 90 })
            items              = @(
                @{ issue_num = 1; complexity_band = 'C2' }, @{ issue_num = 2; complexity_band = 'C2' },
                @{ issue_num = 3; complexity_band = 'C3' }, @{ issue_num = 4; complexity_band = 'C3' },
                @{ issue_num = 5; complexity_band = 'C4' }
            )
            precedence         = @($Precedence)
        }
        foreach ($name in $Override.Keys) { $entry[$name] = $Override[$name] }
        return $entry
    }
}

Describe 'Test-ParallelPrecedenceJustified' {
    It 'accepts a cost entry on a cost edge' {
        $entry = Get-GateEntry -Precedence @{ before = 1; after = 2; source = 'operator'; kind = 'cost' }

        Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance | Should -Be 1
    }

    It 'accepts a cost entry on a hard edge' {
        $entry = Get-GateEntry -Precedence @{ before = 5; after = 2; source = 'planner'; kind = 'cost' }

        Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance | Should -Be 1
    }

    It 'rejects a cost entry on a tolerated overlap with its estimates' {
        $entry = Get-GateEntry -Precedence @{ before = 3; after = 4; source = 'operator'; kind = 'cost' } -Override @{
            tolerated_overlaps = @(@{ a = 3; b = 4; reasons = @('path_overlap'); cost = 10; benefit = 90 })
        }

        { Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance } |
            Should -Throw -ExpectedMessage 'precedence_not_justified: --after 4:3 fails the parallel scheduling rule (merge time 10 min does not exceed parallel gain 90 min); add --reason "<text>" to record a correctness ordering'
    }

    It 'rejects a tie at 90 against 90' {
        $entry = Get-GateEntry -Precedence @{ before = 3; after = 4; source = 'operator'; kind = 'cost' }

        { Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance } |
            Should -Throw -ExpectedMessage '*--after 4:3 fails the parallel scheduling rule (merge time 90 min does not exceed parallel gain 90 min)*'
    }

    It 'rejects a cost entry on a non-conflicting pair with merge time 0 and the gain' {
        $entry = Get-GateEntry -Precedence @{ before = 1; after = 3; source = 'operator'; kind = 'cost' }

        # Items 1 (C2) and 3 (C3) do not conflict: merge time 0, gain min(45, 90) = 45.
        { Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance } |
            Should -Throw -ExpectedMessage '*--after 3:1 fails the parallel scheduling rule (merge time 0 min does not exceed parallel gain 45 min)*'
    }

    It 'accepts a correctness entry with a reason' {
        $entry = Get-GateEntry -Precedence @{ before = 3; after = 4; source = 'operator'; kind = 'correctness'; reason = 'item 4 consumes the schema item 3 adds' }

        Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance | Should -Be 0
    }

    It 'rejects a correctness entry with an empty reason' {
        $entry = Get-GateEntry -Precedence @{ before = 3; after = 4; source = 'operator'; kind = 'correctness'; reason = '' }

        { Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance } |
            Should -Throw -ExpectedMessage 'precedence_not_justified: --after 4:3 is marked as a correctness ordering with an empty reason'
    }

    It 'rejects a correctness entry with a whitespace reason' {
        $entry = Get-GateEntry -Precedence @{ before = 3; after = 4; source = 'operator'; kind = 'correctness'; reason = "  `t" }

        { Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance } |
            Should -Throw -ExpectedMessage '*is marked as a correctness ordering with an empty reason'
    }

    It 'skips a legacy entry without kind' {
        $entry = Get-GateEntry -Precedence @{ before = 1; after = 3; source = 'operator'; recorded_at = '2026-11-03T10-00' }

        Test-ParallelPrecedenceJustified -Entry $entry -Tolerance $script:Tolerance | Should -Be 0
    }
}
