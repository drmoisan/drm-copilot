<#
.SYNOPSIS
    Behavioral tests for blast-radius record normalization and rules V1-V3.

.DESCRIPTION
    Mirrors the validation half of the pytest suites in
    tests/scripts/dev_tools/test_compute_blast_radius.py and
    tests/scripts/dev_tools/test_blast_radius_invariants.py: the record key-set
    and construction invariants, V1 coverage, V2 shared-surface enumeration
    including the glob-only failure, the V3 boundary at and just over the
    configured fraction, finding ordering, and V1 self-consistency. Each It
    targets a single behavior with Arrange-Act-Assert structure. The tests invoke
    no external process and create no temporary files.

    Contention is covered by the authorized sibling
    BlastRadius.Conflict.Tests.ps1; the split satisfies the 500-line file limit
    for task P4-T6.
#>

BeforeAll {
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    $validationPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusValidation.psm1").Path
    Import-Module $facadePath -Force
    Import-Module $validationPath -Force

    # A minimal truth table naming one literal shared surface, one surface glob,
    # and one module, kept independent of the committed configuration.
    $script:TestConfig = @{
        version               = 1
        shared_surfaces       = @('config/orchestration-routing.json')
        shared_surface_globs  = @('scripts/dev_tools/validate_*.py')
        modules               = @{ 'alpha' = @('scripts/**') }
        over_breadth_fraction = 0.25
    }

    # Build a radius record from the levels a test cares about, defaulting the
    # rest, so each It states only the values under test.
    function Get-TestRadius {
        param(
            [string[]] $Paths = @(),
            [string[]] $Modules = @(),
            [string[]] $SharedSurfaces = @(),
            [string[]] $Contracts = @(),
            [string] $Source = 'declared'
        )

        return @{
            paths           = $Paths
            modules         = $Modules
            shared_surfaces = $SharedSurfaces
            contracts       = $Contracts
            source          = $Source
            computed_at     = '2026-08-07T12-00'
        }
    }
}

Describe 'ConvertTo-NormalizedBlastRadius' {
    Context 'Construction invariants' {
        It 'deduplicates and ordinally sorts every collection' {
            # Arrange: a record whose collections arrive unsorted with duplicates.
            $record = Get-TestRadius -Paths @('b/2.py', 'a/1.py', 'a/1.py') `
                -Modules @('zeta', 'alpha') -Contracts @('Zed', 'Ada')

            # Act: normalize the record.
            $normalized = ConvertTo-NormalizedBlastRadius -Radius $record

            # Assert: normalization reproduces the Python dataclass invariant.
            @($normalized['paths']) | Should -Be @('a/1.py', 'b/2.py')
            @($normalized['modules']) | Should -Be @('alpha', 'zeta')
            @($normalized['contracts']) | Should -Be @('Ada', 'Zed')
        }

        It 'accepts the source <_>' -ForEach @('derived', 'declared', 'observed') {
            # Arrange: a record carrying one of the three confidence sources.
            $record = Get-TestRadius -Source $_

            # Act: normalize the record.
            $normalized = ConvertTo-NormalizedBlastRadius -Radius $record

            # Assert: the frozen vocabulary is exactly these three values.
            $normalized['source'] | Should -Be $_
        }

        It 'throws for a source outside the frozen vocabulary' {
            # Arrange / Act / Assert: an unknown source is malformed input.
            { ConvertTo-NormalizedBlastRadius -Radius (Get-TestRadius -Source 'guessed') } |
                Should -Throw '*source must be one of*'
        }

        It 'throws when a documented key is missing' {
            # Arrange: a record that omits the contracts level.
            $record = Get-TestRadius
            $record.Remove('contracts')

            # Act / Assert: a missing key would silently narrow a radius.
            { ConvertTo-NormalizedBlastRadius -Radius $record } |
                Should -Throw '*missing keys*'
        }

        It 'throws when an unexpected key is present' {
            # Arrange: a record carrying an extra level.
            $record = Get-TestRadius
            $record['extra_level'] = @()

            # Act / Assert: an unexpected key would silently drop data.
            { ConvertTo-NormalizedBlastRadius -Radius $record } |
                Should -Throw '*unexpected keys*'
        }

        It 'throws when a collection level holds a non-string entry' {
            # Arrange: a record whose paths level carries a number.
            $record = Get-TestRadius
            $record['paths'] = @('a/1.py', 7)

            # Act / Assert: every entry is validated at construction.
            { ConvertTo-NormalizedBlastRadius -Radius $record } | Should -Throw '*must be a string*'
        }

        It 'is idempotent over an already-normalized record' {
            # Arrange: normalize once.
            $once = ConvertTo-NormalizedBlastRadius -Radius (Get-TestRadius -Paths @('b/2.py', 'a/1.py'))

            # Act: normalize the result again.
            $twice = ConvertTo-NormalizedBlastRadius -Radius $once

            # Assert: normalization is a no-op on well-formed input, which is what
            # lets Test-BlastRadius normalize defensively on entry.
            @($twice['paths']) | Should -Be @($once['paths'])
        }
    }
}

Describe 'Test-BlastRadius rule V1' {
    Context 'Coverage of plan paths' {
        It 'emits a Blocking finding naming an uncovered plan path' {
            # Arrange: a radius that does not cover the path the plan cites.
            $radius = Get-TestRadius -Paths @('docs/features/active/f/**')
            $plan = '- [ ] [P1-T1] Touch `scripts/dev_tools/uncovered.py`.'

            # Act: validate the radius against its plan.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: V1 reports one Blocking finding per uncovered path.
            $findings.Count | Should -Be 1
            $findings[0]['rule'] | Should -Be 'V1'
            $findings[0]['severity'] | Should -Be 'Blocking'
            $findings[0]['subject'] | Should -Be 'scripts/dev_tools/uncovered.py'
        }

        It 'emits one finding per uncovered path, ordinally ordered' {
            # Arrange: a plan citing two paths the radius does not cover.
            $radius = Get-TestRadius -Paths @('docs/features/active/f/**')
            $plan = '- [ ] [P1-T1] Touch `scripts/b.py` and `scripts/a.py`.'

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: subjects are ordered ordinally within the rule.
            @($findings | ForEach-Object { $_['subject'] }) | Should -Be @('scripts/a.py', 'scripts/b.py')
        }

        It 'accepts an exactly matching radius entry' {
            # Arrange: a radius naming the plan path exactly.
            $radius = Get-TestRadius -Paths @('scripts/a.py')
            $plan = '- [ ] [P1-T1] Touch `scripts/a.py`.'

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: exact coverage produces no finding.
            $findings.Count | Should -Be 0
        }

        It 'accepts a radius that covers the plan path by glob' {
            # Arrange: a radius covering the path with a recursive glob.
            $radius = Get-TestRadius -Paths @('scripts/**')
            $plan = '- [ ] [P1-T1] Touch `scripts/dev_tools/a.py`.'

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: coverage is subsumption, not equality.
            $findings.Count | Should -Be 0
        }

        It 'ignores glob citations in the plan because only concrete paths are checked' {
            # Arrange: a plan citing only a wildcard path.
            $radius = Get-TestRadius -Paths @('docs/features/active/f/**')
            $plan = '- [ ] [P1-T1] Touch `tests/**`.'

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: a glob names no single file, so V1 has nothing to check.
            $findings.Count | Should -Be 0
        }

        It 'passes V1 for a radius derived from the same plan' {
            # Arrange: derive a radius from a plan, then validate against it.
            $plan = "### Phase 1 — Work`n- [ ] [P1-T1] Touch ``scripts/a.py`` and " +
            '`config/orchestration-routing.json`.'
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Act: validate the derived radius against its own plan.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: derivation and V1 share one extraction function, so a
            # derived radius always passes V1 against its own plan.
            $findings.Count | Should -Be 0
        }
    }
}

Describe 'Test-BlastRadius rule V2' {
    Context 'Shared-surface enumeration' {
        It 'emits a Blocking finding for a touched but unenumerated surface' {
            # Arrange: a radius naming the surface as a path but not as a surface.
            $radius = Get-TestRadius -Paths @('config/orchestration-routing.json')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: V2 requires explicit enumeration at the surfaces level.
            $findings.Count | Should -Be 1
            $findings[0]['rule'] | Should -Be 'V2'
            $findings[0]['severity'] | Should -Be 'Blocking'
            $findings[0]['subject'] | Should -Be 'config/orchestration-routing.json'
        }

        It 'accepts a radius that enumerates the touched surface explicitly' {
            # Arrange: a radius naming the surface at both levels.
            $radius = Get-TestRadius -Paths @('config/orchestration-routing.json') `
                -SharedSurfaces @('config/orchestration-routing.json')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: explicit enumeration is what V2 asks for.
            $findings.Count | Should -Be 0
        }

        It 'rejects glob-only coverage of a shared surface' {
            # Arrange: a radius covering the surface only through a wildcard, and
            # a plan that names it concretely.
            $radius = Get-TestRadius -Paths @('config/**')
            $plan = '- [ ] [P1-T1] Touch `config/orchestration-routing.json`.'

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: the touched-surface set unions the radius's concrete paths
            # with the plan's, so glob coverage is deliberately insufficient.
            @($findings | Where-Object { $_['rule'] -eq 'V2' }).Count | Should -Be 1
        }

        It 'catches a surface reached only through a shared-surface glob' {
            # Arrange: a radius touching a validator module absent from the list.
            $radius = Get-TestRadius -Paths @('scripts/dev_tools/validate_x.py')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: glob membership counts, the fail-closed direction.
            $findings[0]['subject'] | Should -Be 'scripts/dev_tools/validate_x.py'
        }

        It 'emits no finding when no shared surface is touched' {
            # Arrange: a radius touching only ordinary implementation paths.
            $radius = Get-TestRadius -Paths @('scripts/a.py', 'tests/b.py')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: an untouched surface set is the common case.
            $findings.Count | Should -Be 0
        }
    }
}

Describe 'Test-BlastRadius rule V3' {
    Context 'The over-breadth boundary' {
        It 'does not trigger when coverage sits exactly at the configured fraction' {
            # Arrange: five concrete paths against twenty tracked files, which is
            # exactly the configured 0.25 fraction.
            $radius = Get-TestRadius -Paths @('a/1.py', 'a/2.py', 'a/3.py', 'a/4.py', 'a/5.py')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 20)

            # Assert: the threshold is applied by multiplication, so the boundary
            # is exact and exactly-at does not trigger.
            $findings.Count | Should -Be 0
        }

        It 'triggers a single Advisory finding just over the configured fraction' {
            # Arrange: one more path than the boundary allows.
            $radius = Get-TestRadius -Paths @(
                'a/1.py', 'a/2.py', 'a/3.py', 'a/4.py', 'a/5.py', 'a/6.py')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 20)

            # Assert: an over-broad radius is safe but serializes the batch, so
            # the rule reports once at Advisory severity.
            $findings.Count | Should -Be 1
            $findings[0]['rule'] | Should -Be 'V3'
            $findings[0]['severity'] | Should -Be 'Advisory'
            $findings[0]['subject'] | Should -Be 'blast_radius.paths'
        }

        It 'counts only concrete entries toward coverage' {
            # Arrange: six entries of which four are globs.
            $radius = Get-TestRadius -Paths @(
                'a/1.py', 'a/2.py', 'b/**', 'c/**', 'd/**', 'e/**')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 20)

            # Assert: a glob names no countable file set, so it is excluded.
            $findings.Count | Should -Be 0
        }

        It 'throws for a non-positive tracked-file count' {
            # Arrange / Act / Assert: the denominator must be positive.
            { Test-BlastRadius -Radius (Get-TestRadius) -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 0 } |
                Should -Throw '*must be a positive integer*'
        }

        It 'throws for a non-integer tracked-file count' {
            # Arrange / Act / Assert: a fractional count is malformed input.
            { Test-BlastRadius -Radius (Get-TestRadius) -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 1.5 } |
                Should -Throw '*must be an integer*'
        }

        It 'throws for a boolean tracked-file count, which Python reads as an integer' {
            # Arrange / Act / Assert: booleans are rejected explicitly.
            { Test-BlastRadius -Radius (Get-TestRadius) -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount $true } |
                Should -Throw '*must be an integer*'
        }
    }
}

Describe 'Test-BlastRadius finding ordering and determinism' {
    Context 'Cross-rule ordering' {
        It 'sorts findings by rule and then by subject' {
            # Arrange: a radius and plan that trigger V1, V2, and V3 together.
            $radius = Get-TestRadius -Paths @(
                'config/orchestration-routing.json', 'a/1.py', 'a/2.py', 'a/3.py', 'a/4.py', 'a/5.py')
            $plan = '- [ ] [P1-T1] Touch `scripts/z.py` and `scripts/a.py`.'

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 20)

            # Assert: rules appear in V1, V2, V3 order with ordinal subjects
            # inside each rule, which the parity corpus depends on.
            @($findings | ForEach-Object { $_['rule'] }) | Should -Be @('V1', 'V1', 'V2', 'V3')
            $findings[0]['subject'] | Should -Be 'scripts/a.py'
            $findings[1]['subject'] | Should -Be 'scripts/z.py'
        }

        It 'produces the same findings regardless of the input collection order' {
            # Arrange: the same radius with its levels serialized two ways.
            $ordered = Get-TestRadius -Paths @('a/1.py', 'b/2.py')
            $shuffled = Get-TestRadius -Paths @('b/2.py', 'a/1.py')
            $plan = '- [ ] [P1-T1] Touch `scripts/uncovered.py`.'

            # Act: validate both.
            $first = @(Test-BlastRadius -Radius $ordered -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)
            $second = @(Test-BlastRadius -Radius $shuffled -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: normalization on entry makes validation order independent.
            @($second | ForEach-Object { $_['subject'] }) |
                Should -Be @($first | ForEach-Object { $_['subject'] })
        }

        It 'produces the same findings on repeated invocation' {
            # Arrange: one radius and plan.
            $radius = Get-TestRadius -Paths @('scripts/**')
            $plan = '- [ ] [P1-T1] Touch `config/orchestration-routing.json`.'

            # Act: validate twice.
            $first = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)
            $second = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: the library is pure, so repeated calls agree exactly.
            @($second | ForEach-Object { $_['message'] }) |
                Should -Be @($first | ForEach-Object { $_['message'] })
        }

        It 'carries the four documented keys on every finding' {
            # Arrange: a radius that triggers V1.
            $radius = Get-TestRadius -Paths @('docs/f/**')
            $plan = '- [ ] [P1-T1] Touch `scripts/a.py`.'

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $plan `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: downstream planner records depend on this key set.
            @($findings[0].Keys | Sort-Object) | Should -Be @('message', 'rule', 'severity', 'subject')
        }

        It 'returns an empty result for a valid radius' {
            # Arrange: a radius that satisfies all three rules.
            $radius = Get-TestRadius -Paths @('scripts/a.py')

            # Act: validate the radius.
            $findings = @(Test-BlastRadius -Radius $radius -PlanText '' `
                    -Config $script:TestConfig -TrackedFileCount 1000)

            # Assert: an empty finding list means the radius is valid.
            $findings.Count | Should -Be 0
        }
    }
}
