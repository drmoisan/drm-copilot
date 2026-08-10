<#
.SYNOPSIS
    Behavioral tests for the fail-closed blast-radius contention relation.

.DESCRIPTION
    Mirrors the contention coverage of
    tests/scripts/dev_tools/test_compute_blast_radius.py and the invariant matrix
    of tests/scripts/dev_tools/test_blast_radius_invariants.py: each of the four
    disjuncts in isolation, glob-versus-concrete overlap, the undecidable
    glob-versus-glob fail-closed case, empty-radius cases, multi-reason results
    in the fixed kind order, and the symmetry, monotonicity, self-conflict, and
    determinism invariants. Each It targets a single behavior with
    Arrange-Act-Assert structure. The tests invoke no external process and create
    no temporary files.

    This file is the authorized sibling of BlastRadius.Validation.Tests.ps1 under
    the 500-line file limit; both cover task P4-T6.
#>

BeforeAll {
    # Resolve the facade four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    Import-Module $modulePath -Force

    # The relation reads no truth-table key today, so a minimal mapping suffices;
    # it is still validated because the signature is frozen for consumers.
    $script:TestConfig = @{ version = 1; over_breadth_fraction = 0.25 }

    # Build a radius record from the levels a test cares about, defaulting the
    # rest, so each It states only the values under test.
    function Get-TestRadius {
        param(
            [string[]] $Paths = @(),
            [string[]] $Modules = @(),
            [string[]] $SharedSurfaces = @(),
            [string[]] $Contracts = @()
        )

        return @{
            paths           = $Paths
            modules         = $Modules
            shared_surfaces = $SharedSurfaces
            contracts       = $Contracts
            source          = 'declared'
            computed_at     = '2026-08-07T12-00'
        }
    }
}

Describe 'Test-BlastRadiusConflict result shape' {
    Context 'The documented return contract' {
        It 'returns the conflict verdict and a reasons collection' {
            # Arrange: two disjoint radii.
            $left = Get-TestRadius -Paths @('a/1.py')
            $right = Get-TestRadius -Paths @('b/2.py')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: the shape is the frozen contract the cohort barrier reads.
            @($result.Keys | Sort-Object) | Should -Be @('conflict', 'reasons')
            $result['conflict'] | Should -BeFalse
        }

        It 'carries kind and detail on every reason' {
            # Arrange: two radii sharing one concrete path.
            $left = Get-TestRadius -Paths @('a/1.py')
            $right = Get-TestRadius -Paths @('a/1.py')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: reason records are auditable cohort-edge evidence.
            @($result['reasons'][0].Keys | Sort-Object) | Should -Be @('detail', 'kind')
        }

        It 'throws when the truth table is not a mapping' {
            # Arrange / Act / Assert: the frozen signature is still validated.
            { Test-BlastRadiusConflict -RadiusA (Get-TestRadius) -RadiusB (Get-TestRadius) `
                    -Config 'not-a-mapping' } | Should -Throw '*must be a mapping*'
        }
    }
}

Describe 'Test-BlastRadiusConflict disjuncts in isolation' {
    Context 'path_overlap' {
        It 'reports path overlap for two equal concrete entries' {
            # Arrange: two radii naming the same file.
            $left = Get-TestRadius -Paths @('scripts/dev_tools/a.py', 'scripts/dev_tools/b.py')
            $right = Get-TestRadius -Paths @('scripts/dev_tools/b.py', 'scripts/dev_tools/c.py')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: concrete pairs overlap only when equal, and the detail names
            # the overlapping pair.
            $result['conflict'] | Should -BeTrue
            $result['reasons'][0]['kind'] | Should -Be 'path_overlap'
            $result['reasons'][0]['detail'] | Should -Be 'scripts/dev_tools/b.py ~ scripts/dev_tools/b.py'
        }

        It 'reports path overlap for a glob against a concrete entry' {
            # Arrange: a broad glob against a file beneath it.
            $left = Get-TestRadius -Paths @('scripts/**')
            $right = Get-TestRadius -Paths @('scripts/dev_tools/a.py')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: a mixed pair is decided by a plain pattern match.
            $result['conflict'] | Should -BeTrue
            $result['reasons'][0]['kind'] | Should -Be 'path_overlap'
        }

        It 'reports no path overlap for two disjoint concrete entries' {
            # Arrange: two radii in different trees.
            $left = Get-TestRadius -Paths @('scripts/a.py')
            $right = Get-TestRadius -Paths @('tests/b.py')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: disjoint work items may run in the same cohort.
            $result['conflict'] | Should -BeFalse
        }
    }

    Context 'module_overlap, shared_surface_overlap, and contract_dependency' {
        It 'reports module overlap for a shared module' {
            # Arrange: two radii sharing one module and nothing else.
            $left = Get-TestRadius -Modules @('alpha', 'beta')
            $right = Get-TestRadius -Modules @('beta')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: the module level is a plain set intersection.
            $result['reasons'][0]['kind'] | Should -Be 'module_overlap'
            $result['reasons'][0]['detail'] | Should -Be 'beta'
        }

        It 'reports shared-surface overlap for a shared surface' {
            # Arrange: two radii sharing one high-contention artifact.
            $left = Get-TestRadius -SharedSurfaces @('poetry.lock')
            $right = Get-TestRadius -SharedSurfaces @('poetry.lock', 'quality-tiers.yml')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: the surfaces level is a plain set intersection.
            $result['reasons'][0]['kind'] | Should -Be 'shared_surface_overlap'
            $result['reasons'][0]['detail'] | Should -Be 'poetry.lock'
        }

        It 'reports contract dependency for a shared identifier' {
            # Arrange: two radii naming the same exported symbol.
            $left = Get-TestRadius -Contracts @('SymbolOne')
            $right = Get-TestRadius -Contracts @('SymbolOne', 'SymbolTwo')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: v1 scope is identifier equality, which is fail closed.
            $result['reasons'][0]['kind'] | Should -Be 'contract_dependency'
            $result['reasons'][0]['detail'] | Should -Be 'SymbolOne'
        }

        It 'reports the ordinally smallest shared element as the detail' {
            # Arrange: two radii sharing two modules.
            $left = Get-TestRadius -Modules @('zeta', 'alpha')
            $right = Get-TestRadius -Modules @('alpha', 'zeta')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: the smallest element keeps the detail argument-order stable.
            $result['reasons'][0]['detail'] | Should -Be 'alpha'
        }
    }
}

Describe 'Test-BlastRadiusConflict fail-closed behavior' {
    Context 'Undecidable glob pairs' {
        It 'reports overlap for a glob pair that cannot be proven disjoint' {
            # Arrange: two globs whose containment is undecidable in general.
            $left = Get-TestRadius -Paths @('scripts/*/a.py')
            $right = Get-TestRadius -Paths @('scripts/dev_tools/*.py')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: radius under-reporting is the dominant design risk, so an
            # undecidable pair counts as overlapping.
            $result['conflict'] | Should -BeTrue
            $result['reasons'][0]['kind'] | Should -Be 'path_overlap'
        }

        It 'reports no overlap for a glob pair whose literal prefixes diverge' {
            # Arrange: two globs rooted in different trees.
            $left = Get-TestRadius -Paths @('scripts/*.py')
            $right = Get-TestRadius -Paths @('tests/*.py')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: divergent literal prefixes are a sound disjointness proof.
            $result['conflict'] | Should -BeFalse
        }
    }

    Context 'Empty radii' {
        It 'reports no conflict between two empty radii' {
            # Arrange: two radii with every level empty.
            $left = Get-TestRadius
            $right = Get-TestRadius

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: under-reporting via emptiness is V1's problem at plan time,
            # not the relation's.
            $result['conflict'] | Should -BeFalse
            @($result['reasons']).Count | Should -Be 0
        }

        It 'reports no conflict between an empty radius and a non-empty one' {
            # Arrange: one empty radius against a fully populated one.
            $left = Get-TestRadius
            $right = Get-TestRadius -Paths @('a/1.py') -Modules @('alpha') `
                -SharedSurfaces @('poetry.lock') -Contracts @('SymbolOne')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: an empty radius has no overlap at any level.
            $result['conflict'] | Should -BeFalse
        }
    }
}

Describe 'Test-BlastRadiusConflict reason ordering' {
    Context 'The fixed kind order' {
        It 'reports every triggered level in the documented order' {
            # Arrange: two radii that overlap at all four levels.
            $left = Get-TestRadius -Paths @('a/1.py') -Modules @('alpha') `
                -SharedSurfaces @('poetry.lock') -Contracts @('SymbolOne')
            $right = Get-TestRadius -Paths @('a/1.py') -Modules @('alpha') `
                -SharedSurfaces @('poetry.lock') -Contracts @('SymbolOne')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: the downstream parallel schema depends on this exact order.
            @($result['reasons'] | ForEach-Object { $_['kind'] }) | Should -Be @(
                'path_overlap', 'module_overlap', 'shared_surface_overlap', 'contract_dependency')
        }

        It 'omits the levels that did not trigger while keeping the order' {
            # Arrange: two radii overlapping at the module and contract levels only.
            $left = Get-TestRadius -Modules @('alpha') -Contracts @('SymbolOne')
            $right = Get-TestRadius -Modules @('alpha') -Contracts @('SymbolOne')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: filtering the vocabulary preserves the relative order.
            @($result['reasons'] | ForEach-Object { $_['kind'] }) | Should -Be @(
                'module_overlap', 'contract_dependency')
        }

        It 'populates the detail of every reported reason' {
            # Arrange: two radii overlapping at all four levels.
            $left = Get-TestRadius -Paths @('a/1.py') -Modules @('alpha') `
                -SharedSurfaces @('poetry.lock') -Contracts @('SymbolOne')
            $right = Get-TestRadius -Paths @('a/1.py') -Modules @('alpha') `
                -SharedSurfaces @('poetry.lock') -Contracts @('SymbolOne')

            # Act: evaluate the relation.
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: a blank detail would make a cohort decision unauditable.
            @($result['reasons'] | Where-Object { [string]::IsNullOrWhiteSpace($_['detail']) }).Count |
                Should -Be 0
        }
    }
}

Describe 'Contention relation invariants' {
    Context 'Symmetry' {
        It 'returns the same verdict and reason kinds with the arguments swapped' {
            # Arrange: two radii overlapping at three levels.
            $left = Get-TestRadius -Paths @('scripts/**') -Modules @('alpha') `
                -Contracts @('SymbolOne')
            $right = Get-TestRadius -Paths @('scripts/dev_tools/a.py') -Modules @('alpha') `
                -Contracts @('SymbolOne')

            # Act: evaluate the relation in both argument orders.
            $forward = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig
            $reverse = Test-BlastRadiusConflict -RadiusA $right -RadiusB $left -Config $script:TestConfig

            # Assert: the relation is symmetric in verdict and reason multiset.
            $reverse['conflict'] | Should -Be $forward['conflict']
            @($reverse['reasons'] | ForEach-Object { $_['kind'] }) |
                Should -Be @($forward['reasons'] | ForEach-Object { $_['kind'] })
        }

        It 'renders the overlapping path pair identically in both argument orders' {
            # Arrange: two radii whose overlapping pair is not self-equal.
            $left = Get-TestRadius -Paths @('scripts/**')
            $right = Get-TestRadius -Paths @('scripts/dev_tools/a.py')

            # Act: evaluate the relation in both argument orders.
            $forward = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig
            $reverse = Test-BlastRadiusConflict -RadiusA $right -RadiusB $left -Config $script:TestConfig

            # Assert: the pair is ordinally ordered before it is formatted, which
            # is what makes the reported detail observably symmetric.
            $reverse['reasons'][0]['detail'] | Should -Be $forward['reasons'][0]['detail']
        }
    }

    Context 'Monotonicity' {
        It 'never turns a conflict into a non-conflict when a level grows' {
            # Arrange: an already-conflicting pair, then widen one radius.
            $left = Get-TestRadius -Modules @('alpha')
            $right = Get-TestRadius -Modules @('alpha')
            $widened = Get-TestRadius -Modules @('alpha', 'beta') -Paths @('z/9.py')

            # Act: evaluate before and after widening.
            $before = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig
            $after = Test-BlastRadiusConflict -RadiusA $left -RadiusB $widened -Config $script:TestConfig

            # Assert: adding coverage can only add contention, never remove it.
            $before['conflict'] | Should -BeTrue
            $after['conflict'] | Should -BeTrue
        }

        It 'turns a non-conflict into a conflict when the added entry overlaps' {
            # Arrange: a disjoint pair, then add an overlapping path.
            $left = Get-TestRadius -Paths @('scripts/a.py')
            $right = Get-TestRadius -Paths @('tests/b.py')
            $widened = Get-TestRadius -Paths @('tests/b.py', 'scripts/a.py')

            # Act: evaluate before and after widening.
            $before = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig
            $after = Test-BlastRadiusConflict -RadiusA $left -RadiusB $widened -Config $script:TestConfig

            # Assert: the relation responds monotonically to added coverage.
            $before['conflict'] | Should -BeFalse
            $after['conflict'] | Should -BeTrue
        }
    }

    Context 'Self-conflict and determinism' {
        It 'conflicts with itself when the <_> level is non-empty' -ForEach @(
            'paths', 'modules', 'shared_surfaces', 'contracts'
        ) {
            # Arrange: a radius populated at exactly one level.
            $radius = Get-TestRadius
            $radius[$_] = @('shared-entry')

            # Act: evaluate the radius against itself.
            $result = Test-BlastRadiusConflict -RadiusA $radius -RadiusB $radius -Config $script:TestConfig

            # Assert: a work item always contends with itself at any populated
            # level, which is what keeps a cohort from containing duplicates.
            $result['conflict'] | Should -BeTrue
        }

        It 'produces the same result on repeated invocation' {
            # Arrange: one pair of radii.
            $left = Get-TestRadius -Paths @('scripts/**') -Modules @('alpha')
            $right = Get-TestRadius -Paths @('scripts/a.py') -Modules @('alpha')

            # Act: evaluate the relation twice.
            $first = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig
            $second = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $script:TestConfig

            # Assert: the relation is pure, so repeated calls agree exactly.
            @($second['reasons'] | ForEach-Object { $_['detail'] }) |
                Should -Be @($first['reasons'] | ForEach-Object { $_['detail'] })
        }

        It 'produces the same result regardless of input collection order' {
            # Arrange: the same radius serialized two ways.
            $ordered = Get-TestRadius -Modules @('alpha', 'beta')
            $shuffled = Get-TestRadius -Modules @('beta', 'alpha')
            $other = Get-TestRadius -Modules @('beta')

            # Act: evaluate each against the same counterpart.
            $first = Test-BlastRadiusConflict -RadiusA $ordered -RadiusB $other -Config $script:TestConfig
            $second = Test-BlastRadiusConflict -RadiusA $shuffled -RadiusB $other -Config $script:TestConfig

            # Assert: normalization on entry makes the relation order independent.
            $second['reasons'][0]['detail'] | Should -Be $first['reasons'][0]['detail']
        }
    }
}
