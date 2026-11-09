<#
.SYNOPSIS
    Pester tests for the access-aware scheduling additions of issue #1164.

.DESCRIPTION
    Covers the optional separable weight of Get-ConfigConflictTolerance in
    .claude/lib/blast-radius/BlastRadiusScheduling.psm1, and the two exports of
    .claude/lib/blast-radius/BlastRadiusAccess.psm1: the access-aware path-pair
    weight (spec section B2) and the read-only path derivation from plan text
    (spec B5.2). Mirrors tests/scripts/dev_tools/test_blast_radius_access_weights.py.
    Every configuration and plan text is built in memory; no file is read or
    created.
#>

BeforeAll {
    $script:SchedulingPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusScheduling.psm1").Path
    $script:AccessPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusAccess.psm1").Path
    Import-Module $script:SchedulingPath -Force
    Import-Module $script:AccessPath -Force

    # A truth table carrying the recalibrated committed minutes; Weight adds or
    # replaces weight names.
    function Get-AccessTestConfig {
        param([hashtable] $Weight = @{})
        $weights = @{ same_file = 90; possible_overlap = 20; append_only = 10; module = 10; contract = 90 }
        foreach ($name in $Weight.Keys) { $weights[$name] = $Weight[$name] }
        return @{
            version            = 1
            mergeable_paths    = @()
            conflict_tolerance = @{
                tolerance_percent = 100
                weights           = $weights
                band_durations    = @{ C1 = 30; C2 = 45; C3 = 90; C4 = 180 }
                default_band      = 'C1'
                append_only_paths = @('**/CHANGELOG.md')
            }
        }
    }
}

Describe 'Separable weight reader' {
    It 'reads a table without separable' {
        $tolerance = Get-ConfigConflictTolerance -Config (Get-AccessTestConfig)

        $tolerance['weights'].ContainsKey('separable') | Should -BeFalse
        $tolerance['weights']['same_file'] | Should -Be 90
    }

    It 'accepts a separable weight of 15' {
        $tolerance = Get-ConfigConflictTolerance -Config (Get-AccessTestConfig -Weight @{ separable = 15 })

        $tolerance['weights']['separable'] | Should -Be 15
    }

    It 'rejects a separable weight of 0' {
        { Get-ConfigConflictTolerance -Config (Get-AccessTestConfig -Weight @{ separable = 0 }) } |
            Should -Throw -ExpectedMessage '*separable*must be >= 1, got 0.'
    }

    It 'rejects a negative separable weight' {
        { Get-ConfigConflictTolerance -Config (Get-AccessTestConfig -Weight @{ separable = -3 }) } |
            Should -Throw -ExpectedMessage '*separable*must be >= 1, got -3.'
    }

    It 'rejects a boolean separable weight' {
        { Get-ConfigConflictTolerance -Config (Get-AccessTestConfig -Weight @{ separable = $true }) } |
            Should -Throw -ExpectedMessage '*separable*must be an integer, got Boolean.'
    }

    It 'rejects a string separable weight' {
        { Get-ConfigConflictTolerance -Config (Get-AccessTestConfig -Weight @{ separable = '15' }) } |
            Should -Throw -ExpectedMessage '*separable*must be an integer, got String.'
    }
}
