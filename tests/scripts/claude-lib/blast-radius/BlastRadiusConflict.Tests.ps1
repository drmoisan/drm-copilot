<#
.SYNOPSIS
    Behavioral tests for the mechanically-mergeable path exclusion (issue #643).

.DESCRIPTION
    Mirrors the coverage of tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py:
    the optional reader and its three rejection cases, the three-step matcher
    including the anchor-stripped step that admits a root-level file, the
    never-mergeable rule for a glob entry, the collection filter, the two overlap
    helpers relocated here from BlastRadius.psm1, and the fail-closed equivalence
    of an absent key with an empty list at the relation level. Each It targets a
    single behavior with Arrange-Act-Assert structure. The tests invoke no
    external process and create no temporary files.
#>

BeforeAll {
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius. Resolve-Path
    # normalizes the separators so Pester's code-coverage breakpoints bind to the
    # same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $conflictPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusConflict.psm1").Path
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    # The facade re-imports its siblings with -Force, which replaces an existing
    # module instance, so it is imported first and the conflict module second;
    # the reverse order leaves the conflict exports unresolvable in this scope.
    Import-Module $facadePath -Force
    Import-Module $conflictPath -Force

    # The five default patterns, in the order the truth table declares them.
    $script:DefaultMergeable = @(
        '**/*.csproj',
        '**/packages.config',
        '**/app.config',
        '**/*.vbproj',
        '**/*.props'
    )

    # Build a radius record from the levels a test cares about, defaulting the
    # rest, so each It states only the values under test.
    function Get-TestRadius {
        param(
            [string[]] $Paths = @()
        )

        return @{
            paths           = $Paths
            modules         = @()
            shared_surfaces = @()
            contracts       = @()
            source          = 'declared'
            computed_at     = '2026-09-07T09-00'
        }
    }
}

Describe 'Get-ConfigMergeablePath' {
    It 'returns the present entries sorted' {
        # Arrange: a truth table declaring the class out of ordinal order.
        $config = @{ version = 1; mergeable_paths = @('**/app.config', '**/*.csproj') }

        # Act.
        $result = @(Get-ConfigMergeablePath -Config $config)

        # Assert: the reader sorts, so the comparison is runtime-independent.
        $result | Should -Be @('**/*.csproj', '**/app.config')
    }

    It 'returns an empty array for an absent key' {
        # Arrange: the minimal mapping every pre-#643 caller passed.
        $config = @{ version = 1; over_breadth_fraction = 0.25 }

        # Act.
        $result = @(Get-ConfigMergeablePath -Config $config)

        # Assert: absent is fail-closed and excludes nothing.
        $result.Count | Should -Be 0
    }

    It 'throws for a non-list value' {
        # Arrange: a scalar where a list is required.
        $config = @{ version = 1; mergeable_paths = '**/*.csproj' }

        # Act / Assert: a malformed truth table is rejected, not coerced.
        { Get-ConfigMergeablePath -Config $config } | Should -Throw
    }

    It 'throws for a blank entry' {
        # Arrange: a whitespace-only entry, which names nothing.
        $config = @{ version = 1; mergeable_paths = @('**/*.csproj', '   ') }

        # Act / Assert.
        { Get-ConfigMergeablePath -Config $config } | Should -Throw
    }
}

Describe 'Test-MergeablePath' {
    It 'matches a concrete csproj against the double-star pattern' {
        # Arrange / Act: a nested project file, the ordinary case.
        $result = Test-MergeablePath -Entry 'QuickFiler.Test/QuickFiler.Test.csproj' `
            -MergeablePath $script:DefaultMergeable

        # Assert: glob containment settles it at step two.
        $result | Should -BeTrue
    }

    It 'matches a root-level packages.config for a double-star prefix' {
        # Arrange / Act: an anchored pattern requires a separator, so only the
        # anchor-stripped third step can admit a repository-root file.
        $result = Test-MergeablePath -Entry 'packages.config' `
            -MergeablePath $script:DefaultMergeable

        # Assert.
        $result | Should -BeTrue
    }

    It 'never treats a glob entry as mergeable' {
        # Arrange / Act: pattern subsumption is not a supported comparison, so a
        # glob that does not equal a configured pattern is left in place.
        $result = Test-MergeablePath -Entry 'Proj/*.csproj' `
            -MergeablePath $script:DefaultMergeable

        # Assert.
        $result | Should -BeFalse
    }

    It 'matches an entry equal to a configured pattern' {
        # Arrange / Act: ordinal equality is the one rule that can settle a glob.
        $result = Test-MergeablePath -Entry '**/*.props' `
            -MergeablePath $script:DefaultMergeable

        # Assert.
        $result | Should -BeTrue
    }
}

Describe 'Get-NonMergeablePathEntry' {
    It 'drops matching entries and sorts the survivors' {
        # Arrange: two project files and two source files, out of ordinal order.
        $entry = @('QuickFiler.Test/B.cs', 'QuickFiler.Test/QuickFiler.Test.csproj',
            'QuickFiler.Test/A.cs', 'packages.config')

        # Act.
        $result = @(Get-NonMergeablePathEntry -Entry $entry -MergeablePath $script:DefaultMergeable)

        # Assert: both mergeable entries are gone and the rest are ordinally sorted.
        $result | Should -Be @('QuickFiler.Test/A.cs', 'QuickFiler.Test/B.cs')
    }

    It 'returns the input content when the mergeable list is empty' {
        # Arrange: the pre-#643 configuration.
        $entry = @('b/2.cs', 'a/1.csproj')

        # Act.
        $result = @(Get-NonMergeablePathEntry -Entry $entry -MergeablePath @())

        # Assert: nothing is excluded; the content is the input, ordinally sorted.
        $result | Should -Be @('a/1.csproj', 'b/2.cs')
    }
}

Describe 'Relocated overlap helpers' {
    It 'Get-SmallestPathOverlap renders the ordinally smallest pair' {
        # Arrange: two collections whose members overlap in more than one pair.
        $pathA = @('src/b.py', 'src/a.py')
        $pathB = @('src/b.py', 'src/a.py')

        # Act.
        $result = Get-SmallestPathOverlap -PathA $pathA -PathB $pathB

        # Assert: the pair is ordered before the minimum is taken, so the detail
        # does not depend on argument order.
        $result | Should -Be 'src/a.py ~ src/a.py'
    }

    It 'Get-SmallestCommonEntry returns the smallest shared element' {
        # Arrange: two collections sharing two elements.
        $left = @('modules/z', 'modules/a', 'modules/m')
        $right = @('modules/m', 'modules/a')

        # Act.
        $result = Get-SmallestCommonEntry -Left $left -Right $right

        # Assert.
        $result | Should -Be 'modules/a'
    }
}

Describe 'Test-BlastRadiusConflict equivalence' {
    It 'returns identical results for an absent key and an empty list' {
        # Arrange: the same .csproj-bearing pair under the two fail-closed
        # configurations the optional key admits.
        $left = Get-TestRadius -Paths @('QuickFiler.Test/QuickFiler.Test.csproj', 'QuickFiler.Test/A.cs')
        $right = Get-TestRadius -Paths @('QuickFiler.Test/QuickFiler.Test.csproj', 'QuickFiler.Test/B.cs')
        $absent = @{ version = 1; over_breadth_fraction = 0.25 }
        $empty = @{ version = 1; over_breadth_fraction = 0.25; mergeable_paths = @() }

        # Act.
        $absentResult = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $absent
        $emptyResult = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right -Config $empty

        # Assert: the verdict and the reason kind/detail sequence agree, so an
        # omitted key reproduces pre-change behavior exactly.
        $absentResult['conflict'] | Should -Be $emptyResult['conflict']
        $absentKind = @($absentResult['reasons'] | ForEach-Object { $_['kind'] })
        $emptyKind = @($emptyResult['reasons'] | ForEach-Object { $_['kind'] })
        $absentKind | Should -Be $emptyKind
        $absentDetail = @($absentResult['reasons'] | ForEach-Object { $_['detail'] })
        $emptyDetail = @($emptyResult['reasons'] | ForEach-Object { $_['detail'] })
        $absentDetail | Should -Be $emptyDetail
    }
}
