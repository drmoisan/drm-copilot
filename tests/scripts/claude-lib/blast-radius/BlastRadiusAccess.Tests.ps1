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

Describe 'Access-aware path pair weight' {
    BeforeAll {
        $script:Tolerance = Get-ConfigConflictTolerance -Config (Get-AccessTestConfig -Weight @{ separable = 15 })
        $script:ToleranceWithoutSeparable = Get-ConfigConflictTolerance -Config (Get-AccessTestConfig)
    }

    It 'weighs a read-only entry on side A at 0' {
        Get-BlastRadiusAccessPathPairWeight -EntryA 'src/app.py' -EntryB 'src/app.py' -Tolerance $script:Tolerance -AccessA @{ read_paths = @('src/app.py') } |
            Should -Be 0
    }

    It 'weighs a read-only entry on side B at 0' {
        Get-BlastRadiusAccessPathPairWeight -EntryA 'src/**' -EntryB 'src/app.py' -Tolerance $script:Tolerance -AccessB @{ read_paths = @('src/app.py') } |
            Should -Be 0
    }

    It 'keeps append-only ahead of separable' {
        $both = @{ separable_paths = @('CHANGELOG.md') }
        Get-BlastRadiusAccessPathPairWeight -EntryA 'CHANGELOG.md' -EntryB 'CHANGELOG.md' -Tolerance $script:Tolerance -AccessA $both -AccessB $both |
            Should -Be 10
    }

    It 'weighs a both-side separable entry at the separable weight' {
        $both = @{ separable_paths = @('src/app.py') }
        Get-BlastRadiusAccessPathPairWeight -EntryA 'src/app.py' -EntryB 'src/app.py' -Tolerance $script:Tolerance -AccessA $both -AccessB $both |
            Should -Be 15
    }

    It 'falls through to same_file for a one-side separable entry' {
        Get-BlastRadiusAccessPathPairWeight -EntryA 'src/app.py' -EntryB 'src/app.py' -Tolerance $script:Tolerance -AccessA @{ separable_paths = @('src/app.py') } -AccessB @{ separable_paths = @() } |
            Should -Be 90
    }

    It 'falls through when the separable weight is absent' {
        $both = @{ separable_paths = @('src/app.py') }
        Get-BlastRadiusAccessPathPairWeight -EntryA 'src/app.py' -EntryB 'src/app.py' -Tolerance $script:ToleranceWithoutSeparable -AccessA $both -AccessB $both |
            Should -Be 90
    }

    It 'weighs a glob overlap as possible_overlap' {
        Get-BlastRadiusAccessPathPairWeight -EntryA 'src/**' -EntryB 'src/app.py' -Tolerance $script:Tolerance |
            Should -Be 20
    }

    It 'matches the legacy weight without access lists' {
        # The former Get-PathPairWeight rows: append-only first, then same file, then possible overlap.
        $legacy = @(
            @{ A = 'CHANGELOG.md'; B = 'CHANGELOG.md'; Weight = 10 },
            @{ A = 'docs'; B = 'docs/CHANGELOG.md'; Weight = 10 },
            @{ A = 'src/app.py'; B = 'src/app.py'; Weight = 90 },
            @{ A = 'scripts/dev_tools'; B = 'scripts/dev_tools/x.py'; Weight = 20 },
            @{ A = 'src/**'; B = 'src/app.py'; Weight = 20 }
        )
        foreach ($row in $legacy) {
            Get-BlastRadiusAccessPathPairWeight -EntryA $row.A -EntryB $row.B -Tolerance $script:Tolerance | Should -Be $row.Weight -Because "$($row.A) with $($row.B) and no access lists"
            Get-BlastRadiusAccessPathPairWeight -EntryA $row.A -EntryB $row.B -Tolerance $script:Tolerance -AccessA @{} -AccessB @{} | Should -Be $row.Weight -Because "$($row.A) with $($row.B) and empty access lists"
        }
    }
}

Describe 'Read-only path derivation' {
    It 'derives a path named only by Read and Run tasks' {
        $plan = @(
            '### Phase 0 - Baselines',
            '- [ ] [P0-T1] Read `docs/rule.md` before the baseline.',
            '- [ ] [P6-T5] Run the gate; the record cites `docs/rule.md`.',
            '- [ ] [P1-T1] Update `src/app.py`.'
        ) -join "`n"

        Get-BlastRadiusReadOnlyPath -PlanText $plan -RadiusPath @('docs/rule.md', 'src/app.py') | Should -Be @('docs/rule.md')
    }

    It 'rejects a path named by an Update task' {
        $plan = @(
            '- [ ] [P0-T1] Read `src/app.py`.',
            '- [ ] [P1-T1] Update the parser.',
            '  - Design: the parser lives in `src/app.py`.'
        ) -join "`n"

        @(Get-BlastRadiusReadOnlyPath -PlanText $plan -RadiusPath @('src/app.py')).Count | Should -Be 0
    }

    It 'rejects a path whose read title carries a write verb' {
        $plan = '- [ ] [P2-T1] Run the formatter and fix `src/app.ps1`.'

        @(Get-BlastRadiusReadOnlyPath -PlanText $plan -RadiusPath @('src/app.ps1')).Count | Should -Be 0
    }

    It 'rejects a path whose read title carries the write form <Form>' -ForEach @(
        @{ Form = 'writes' }, @{ Form = 'updates' }, @{ Form = 'adds' }, @{ Form = 'fixes' }, @{ Form = 'copies' },
        @{ Form = 'added' }, @{ Form = 'fixed' }, @{ Form = 'copied' }, @{ Form = 'updated' }, @{ Form = 'adding' },
        @{ Form = 'updating' }, @{ Form = 'Regenerate' }, @{ Form = 'regenerates' }, @{ Form = 'Overwrite' }, @{ Form = 'overwriting' },
        @{ Form = 'wrote' }, @{ Form = 'written' }, @{ Form = 'rewrote' }, @{ Form = 'rewritten' }, @{ Form = 'overwrote' },
        @{ Form = 'overwritten' }
    ) {
        $plan = "- [ ] [P2-T1] Run the generator that $Form ``docs/out.json``."

        @(Get-BlastRadiusReadOnlyPath -PlanText $plan -RadiusPath @('docs/out.json')).Count | Should -Be 0 -Because "'$Form' marks a write"
    }

    It 'keeps a read path whose title word only begins like a write verb' {
        $plan = '- [ ] [P0-T1] Review the address table in `docs/rule.md`.'

        Get-BlastRadiusReadOnlyPath -PlanText $plan -RadiusPath @('docs/rule.md') | Should -Be @('docs/rule.md')
    }

    It 'never derives a created path' {
        $plan = @(
            '- [ ] [P1-T1] Create `src/new.ps1` with the helper.',
            '- [ ] [P6-T5] Verify `src/new.ps1` in the gate.'
        ) -join "`n"

        @(Get-BlastRadiusReadOnlyPath -PlanText $plan -RadiusPath @('src/new.ps1')).Count | Should -Be 0
    }

    It 'returns nothing for empty plan text' {
        @(Get-BlastRadiusReadOnlyPath -PlanText '' -RadiusPath @('docs/rule.md')).Count | Should -Be 0
    }
}
