<#
.SYNOPSIS
    Cross-language parity assertions over the committed blast-radius corpus.

.DESCRIPTION
    Iterates every tests/fixtures/blast_radius/*.json file and asserts that the
    PowerShell mirror reproduces each fixture's expected block exactly: the
    derived radius, the sorted findings list, and the contention result. The same
    corpus is asserted by tests/scripts/dev_tools/test_blast_radius_parity.py, so
    the fixtures are the single artifact that pins the two implementations
    together; neither suite may relax an expectation without the other observing
    the change. This follows the ModelRouting.Parity.Tests.ps1 discipline: the
    assertions are file-read-only, create no temporary file, and start no
    external process, so parity is asserted against a shared artifact rather than
    by cross-process execution.

    Fixture shape. A derivation or validation fixture carries input with
    plan_text, spec_text, feature_folder, config, tracked_file_count and
    computed_at, plus the optional source (the confidence source passed to
    derivation, defaulting to derived) and the optional radius (a hand-authored
    declared radius to validate instead of the derived one, which is how a V1 or
    V2 failure can be expressed at all, since a derived radius always passes V1
    and V2 against its own plan). A conflict fixture carries input with radius_a,
    radius_b and config. The two kinds are told apart by the presence of
    radius_a.

    The suite additionally pins the committed config/blast-radius.json to the
    same shape constraints the Python config test asserts, so the two
    implementations and the truth table cannot drift.
#>

# Discovery-time corpus enumeration. Pester executes the file body during
# discovery, so the case list must be built here for -ForEach to generate one It
# per fixture. The kind of each fixture is read here as well because the two
# kinds drive separate Describe blocks; the fixture body itself is re-read inside
# each It so the assertions run against a freshly parsed record.
$fixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius").Path
$fixtureCase = @(
    Get-ChildItem -Path $fixtureDirectory -Filter '*.json' -File |
        Sort-Object -Property Name |
            ForEach-Object {
                $parsed = Get-Content -Path $_.FullName -Raw | ConvertFrom-Json -AsHashtable
                @{
                    FixtureName = $_.BaseName
                    FixturePath = $_.FullName
                    IsConflict  = $parsed['input'].ContainsKey('radius_a')
                }
            }
)
$derivationCase = @($fixtureCase | Where-Object { -not $_['IsConflict'] })
$conflictCase = @($fixtureCase | Where-Object { $_['IsConflict'] })

# Floor on corpus size, matching MINIMUM_FIXTURE_COUNT in the Python parity
# suite. An empty or partially matched glob would make every case below disappear
# and the suite would pass vacuously, so the count is asserted twice: against
# this floor and against the files on disk.
$minimumFixtureCount = 26

BeforeAll {
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius. Resolve-Path
    # normalizes the separators so Pester's code-coverage breakpoints bind to the
    # same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    $validationPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusValidation.psm1").Path
    Import-Module $facadePath -Force
    Import-Module $validationPath -Force

    $script:FixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius").Path
    $script:ConfigPath = Join-Path $script:RepoRoot 'config/blast-radius.json'

    # Read one committed corpus file. The corpus is read-only for this suite.
    function Get-FixtureContent {
        [CmdletBinding()]
        [OutputType([hashtable])]
        param(
            [Parameter(Mandatory = $true)]
            [string] $Path
        )

        return (Get-Content -Path $Path -Raw | ConvertFrom-Json -AsHashtable)
    }

    # Derive the radius a derivation or validation fixture describes, passing the
    # confidence source only when the fixture names one so the default is
    # exercised by every other fixture.
    function Get-FixtureRadius {
        [CmdletBinding()]
        [OutputType([hashtable])]
        param(
            [Parameter(Mandatory = $true)]
            [hashtable] $FixtureInput
        )

        $argument = @{
            PlanText      = [string]$FixtureInput['plan_text']
            SpecText      = [string]$FixtureInput['spec_text']
            FeatureFolder = [string]$FixtureInput['feature_folder']
            Config        = $FixtureInput['config']
            ComputedAt    = [string]$FixtureInput['computed_at']
        }
        if ($FixtureInput.ContainsKey('source')) {
            $argument['Source'] = [string]$FixtureInput['source']
        }

        return Get-BlastRadius @argument
    }

    # Select the radius a validation fixture applies rules V1 to V3 against. A
    # fixture that names an explicit radius is exercising a hand-authored or
    # stale declared radius, which is the only way a V1 or V2 failure can arise.
    function Get-ValidationTargetRadius {
        [CmdletBinding()]
        [OutputType([hashtable])]
        param(
            [Parameter(Mandatory = $true)]
            [hashtable] $FixtureInput
        )

        if ($FixtureInput.ContainsKey('radius')) {
            return $FixtureInput['radius']
        }

        return (Get-FixtureRadius -FixtureInput $FixtureInput)
    }

    # Render a radius as one comparable string. Comparing a single string rather
    # than six collections keeps the empty-collection cases unambiguous and makes
    # a failure message show the whole record at once.
    function Get-RadiusSignature {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [hashtable] $Radius
        )

        $part = @(
            'paths=' + (@($Radius['paths']) -join ',')
            'modules=' + (@($Radius['modules']) -join ',')
            'shared_surfaces=' + (@($Radius['shared_surfaces']) -join ',')
            'contracts=' + (@($Radius['contracts']) -join ',')
            'source=' + [string]$Radius['source']
            'computed_at=' + [string]$Radius['computed_at']
        )

        return ($part -join ' ; ')
    }

    # Render a finding list as one comparable string. Order is preserved, so the
    # documented sort by rule then subject is pinned along with the contents.
    function Get-FindingSignature {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [object[]] $Finding
        )

        $line = [System.Collections.Generic.List[string]]::new()
        foreach ($record in $Finding) {
            $line.Add(@(
                    [string]$record['rule'], [string]$record['severity'],
                    [string]$record['subject'], [string]$record['message']
                ) -join '|')
        }

        return ($line.ToArray() -join ' ;; ')
    }

    # Render a contention reason list as one comparable string, so the fixed kind
    # order path_overlap, module_overlap, shared_surface_overlap,
    # contract_dependency is pinned along with the reported details.
    function Get-ReasonSignature {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [object[]] $Reason
        )

        $line = [System.Collections.Generic.List[string]]::new()
        foreach ($record in $Reason) {
            $line.Add(@([string]$record['kind'], [string]$record['detail']) -join '|')
        }

        return ($line.ToArray() -join ' ;; ')
    }
}

Describe 'Blast-radius fixture corpus discovery' {
    Context 'Non-vacuous iteration' {
        It 'discovers at least <MinimumCount> fixture files' -ForEach @(
            @{ DiscoveredCount = $fixtureCase.Count; MinimumCount = $minimumFixtureCount }
        ) {
            # Arrange / Act: the corpus is enumerated at discovery time.
            # Assert: a short corpus would silently drop scenarios the parity
            # claim depends on, and an empty one would make the suite vacuous.
            $DiscoveredCount | Should -BeGreaterOrEqual $MinimumCount
        }

        It 'discovers exactly the number of JSON files in the corpus directory' -ForEach @(
            @{ DiscoveredCount = $fixtureCase.Count }
        ) {
            # Arrange: enumerate the directory again without the discovery
            # filter, so a pattern that silently skipped files would be caught
            # rather than reproduced.
            $onDisk = @(
                Get-ChildItem -Path $script:FixtureDirectory -File |
                    Where-Object { $_.Extension -eq '.json' }
            )

            # Assert: the two counts must agree, otherwise the Python suite and
            # this one could iterate different subsets of the same directory.
            $DiscoveredCount | Should -Be $onDisk.Count
        }

        It 'covers both the derivation and the conflict fixture kind' -ForEach @(
            @{ DerivationCount = $derivationCase.Count; ConflictCount = $conflictCase.Count }
        ) {
            # Arrange / Act: the two case lists are partitioned at discovery.
            # Assert: an all-derivation or all-conflict corpus would leave one of
            # the two parametrized Describe blocks with zero cases.
            $DerivationCount | Should -BeGreaterThan 0
            $ConflictCount | Should -BeGreaterThan 0
        }
    }
}

Describe 'Blast-radius derivation and validation parity' {
    Context 'Derived radius' {
        It 'reproduces the expected radius for <FixtureName>' -ForEach $derivationCase {
            # Arrange: the fixture's input and its spec-derived expectation.
            $fixture = Get-FixtureContent -Path $FixturePath
            $expected = Get-RadiusSignature -Radius $fixture['expected']['radius']

            # Act: derive the radius from the plan, spec, feature folder, config.
            $actual = Get-RadiusSignature -Radius (Get-FixtureRadius -FixtureInput $fixture['input'])

            # Assert: the record matches key for key and element for element,
            # which is the same comparison the Python suite performs.
            $actual | Should -BeExactly $expected
        }
    }

    Context 'Validation findings' {
        It 'reproduces the expected findings for <FixtureName>' -ForEach $derivationCase {
            # Arrange: the radius under validation, its plan, truth table, count.
            $fixture = Get-FixtureContent -Path $FixturePath
            $fixtureInput = $fixture['input']
            $expected = Get-FindingSignature -Finding @($fixture['expected']['findings'])
            $radius = Get-ValidationTargetRadius -FixtureInput $fixtureInput

            # Act: apply rules V1, V2, and V3.
            $finding = @(Test-BlastRadius -Radius $radius `
                    -PlanText ([string]$fixtureInput['plan_text']) `
                    -Config $fixtureInput['config'] `
                    -TrackedFileCount ([int]$fixtureInput['tracked_file_count']))

            # Assert: contents and the documented sort by rule then subject.
            (Get-FindingSignature -Finding $finding) | Should -BeExactly $expected
        }
    }
}

Describe 'Blast-radius contention parity' {
    Context 'Conflict verdict' {
        It 'reproduces the expected verdict for <FixtureName>' -ForEach $conflictCase {
            # Arrange: the two radii and the truth table.
            $fixture = Get-FixtureContent -Path $FixturePath
            $fixtureInput = $fixture['input']

            # Act: evaluate the four disjuncts.
            $result = Test-BlastRadiusConflict -RadiusA $fixtureInput['radius_a'] `
                -RadiusB $fixtureInput['radius_b'] -Config $fixtureInput['config']

            # Assert: the boolean verdict matches the fixture.
            $result['conflict'] | Should -Be $fixture['expected']['conflict']
        }
    }

    Context 'Conflict reasons' {
        It 'reproduces the expected reasons for <FixtureName>' -ForEach $conflictCase {
            # Arrange: the two radii, the truth table, and the ordered expectation.
            $fixture = Get-FixtureContent -Path $FixturePath
            $fixtureInput = $fixture['input']
            $expected = Get-ReasonSignature -Reason @($fixture['expected']['reasons'])

            # Act: evaluate the four disjuncts.
            $result = Test-BlastRadiusConflict -RadiusA $fixtureInput['radius_a'] `
                -RadiusB $fixtureInput['radius_b'] -Config $fixtureInput['config']

            # Assert: both the reported details and the fixed kind order.
            (Get-ReasonSignature -Reason @($result['reasons'])) | Should -BeExactly $expected
        }
    }
}

Describe 'Committed blast-radius truth table shape' {
    BeforeAll {
        # Read the authoritative truth table as the pinning source, mirroring the
        # constraints tests/scripts/dev_tools/test_blast_radius_config.py asserts.
        $script:CommittedConfig = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json -AsHashtable

        # The bundled copy the Claude push-down surface publishes into a
        # destination repository. It is a separate committed artifact that can
        # drift from the repo-root copy, so the negative pin below reads both.
        $script:BundledConfigPath = Join-Path $script:RepoRoot `
            'extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json'
        $script:BundledConfig = Get-Content -Path $script:BundledConfigPath -Raw | ConvertFrom-Json -AsHashtable
    }

    Context 'Schema version' {
        It 'declares version 1' {
            # Act / Assert: a version change is a cross-language contract change.
            $script:CommittedConfig['version'] | Should -Be 1
        }
    }

    Context 'Module map' {
        It 'populates the module map' {
            # Assert: an empty map would make the per-module check vacuous.
            @($script:CommittedConfig['modules'].Keys).Count | Should -BeGreaterThan 0
        }

        It 'maps every module to a non-empty glob list' {
            # Arrange: collect modules whose glob list is empty.
            $moduleMap = $script:CommittedConfig['modules']
            $empty = @($moduleMap.Keys | Where-Object { @($moduleMap[$_]).Count -eq 0 })

            # Assert: a module with no globs can never resolve a path, so the
            # module would be unreachable and module overlap silently narrower.
            $empty | Should -BeNullOrEmpty
        }
    }

    Context 'Over-breadth fraction' {
        It 'declares an over-breadth fraction within (0, 1]' {
            # Arrange / Act: read the V3 threshold.
            $fraction = [double]$script:CommittedConfig['over_breadth_fraction']

            # Assert: zero or a negative value would make every radius
            # over-broad, and a value above 1 would make V3 unreachable.
            $fraction | Should -BeGreaterThan 0
            $fraction | Should -BeLessOrEqual 1
        }
    }

    Context 'Shared surfaces' {
        It 'populates the shared-surface truth table and its membership globs' {
            # Assert: either list being empty would make the checks below vacuous.
            @($script:CommittedConfig['shared_surfaces']).Count | Should -BeGreaterThan 0
            @($script:CommittedConfig['shared_surface_globs']).Count | Should -BeGreaterThan 0
        }

        It 'lists every shared surface as a repo-relative path' {
            # Arrange: an absolute, drive-qualified, or parent-relative entry
            # could never equal a repository-relative path from a diff or a plan,
            # so the surface would never be recognized as touched.
            $offending = @(
                $script:CommittedConfig['shared_surfaces'] | Where-Object {
                    $_.StartsWith('/') -or $_.Contains(':') -or ($_ -split '/') -contains '..'
                }
            )

            # Assert: no entry may violate the repo-relative constraint.
            $offending | Should -BeNullOrEmpty
        }

        It 'gives every shared-surface membership glob a wildcard' {
            # Arrange: a wildcard-free pattern belongs in the literal
            # shared_surfaces list; leaving it here would hide it from V2.
            $offending = @(
                $script:CommittedConfig['shared_surface_globs'] |
                    Where-Object { -not $_.Contains('*') }
            )

            # Assert: every membership glob must carry a wildcard.
            $offending | Should -BeNullOrEmpty
        }

        It 'gives every separator-free shared surface no wildcard' {
            # Arrange: Get-ConfigRootSurface admits a separator-free entry as a
            # concrete path token (issue #452). A wildcard-bearing entry would
            # classify as a glob instead, so the configured root surface would
            # never be recognized as concrete and V2 could not enumerate it.
            # Mirrors test_every_separator_free_shared_surface_is_wildcard_free
            # in tests/scripts/dev_tools/test_blast_radius_config.py.
            $offending = @(
                $script:CommittedConfig['shared_surfaces'] |
                    Where-Object { -not $_.Contains('/') } |
                        Where-Object { $_.Contains('*') -or $_.Contains('?') }
            )

            # Assert: no separator-free surface may carry either wildcard.
            $offending | Should -BeNullOrEmpty
        }
    }

    Context 'Location-bucket modules' {
        It 'declares no location-bucket module in either committed copy' {
            # Arrange: a bucket keyed on where a file lives rather than on which
            # subsystem owns it attaches to nearly every work item, so it makes
            # every pair of items contend at the module level (issue #472).
            # Mirrors test_no_committed_copy_declares_a_location_bucket_module in
            # tests/scripts/dev_tools/test_blast_radius_config.py.
            $bucketName = @('docs', 'tests')
            $bucketGlob = @('docs/**', 'tests/**')

            # Act: walk both committed copies and record every module name and
            # every glob that matches a location bucket. Comparison is ordinal,
            # matching the case-sensitive semantics of the Python reference.
            $offendingName = [System.Collections.Generic.List[string]]::new()
            $offendingGlob = [System.Collections.Generic.List[string]]::new()
            foreach ($config in @($script:CommittedConfig, $script:BundledConfig)) {
                $moduleMap = $config['modules']
                foreach ($name in @($moduleMap.Keys)) {
                    if ($bucketName -ccontains $name) {
                        $offendingName.Add($name)
                    }
                    foreach ($glob in @($moduleMap[$name])) {
                        if ($bucketGlob -ccontains $glob) {
                            $offendingGlob.Add($glob)
                        }
                    }
                }
            }

            # Assert: neither the bucket name nor its glob may appear anywhere.
            $offendingName.ToArray() | Should -BeNullOrEmpty
            $offendingGlob.ToArray() | Should -BeNullOrEmpty
        }
    }

    Context 'Disjoint work items' {
        It 'reports no contention between two items with disjoint paths' {
            # Arrange: two work items with distinct feature folders and disjoint
            # production paths, derived through the mirror against the committed
            # map. Mirrors
            # test_disjoint_items_do_not_contend_through_the_committed_map in
            # tests/scripts/dev_tools/test_blast_radius_config.py.
            $benchmarkRadius = Get-BlastRadius -SpecText '' `
                -PlanText '- [ ] [P1-T1] Edit `scripts/benchmarks/run.py` and `tests/benchmarks/test_run.py`.' `
                -FeatureFolder '2026-08-15-example-benchmark-item' `
                -Config $script:CommittedConfig -ComputedAt '2026-08-15T09-48'
            $extensionRadius = Get-BlastRadius -SpecText '' `
                -PlanText '- [ ] [P1-T1] Edit `extensions/drm-copilot/src/lib/foo.ts`.' `
                -FeatureFolder '2026-08-15-example-extension-item' `
                -Config $script:CommittedConfig -ComputedAt '2026-08-15T09-48'

            # Act: ask the contention relation whether the items may run together.
            $result = Test-BlastRadiusConflict -RadiusA $benchmarkRadius `
                -RadiusB $extensionRadius -Config $script:CommittedConfig

            # Assert: no disjunct may fire. The reason signature is asserted empty
            # as well, so a failure names the level that forced the contention.
            $result['conflict'] | Should -BeFalse
            (Get-ReasonSignature -Reason @($result['reasons'])) | Should -BeNullOrEmpty
        }
    }
}
