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
# Raised from 26 by issue #502, which added placeholder-shape fixtures. The two
# floors must stay equal: they guard the same shared corpus, so a divergence
# would let one runtime read a smaller corpus than the other while both suites
# reported a pass.
$minimumFixtureCount = 30

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
Describe 'Verification-integrity regression (issue #489)' {
    BeforeAll {
        # The committed capture of the verification-integrity parallel run. Its
        # three recorded radii are the data the false-conflict defect was found
        # on, so the fix is demonstrated against them rather than against the
        # gitignored working-tree checkpoint.
        $fixturePath = Join-Path $script:RepoRoot (
            'tests/fixtures/blast_radius/verification-integrity/' +
            'verification-integrity-485-486-487.json')
        # -DateKind String keeps computed_at a string. The recorded radii carry
        # real ISO-8601 instants, which ConvertFrom-Json otherwise materializes
        # as [datetime]; the radius contract requires a string.
        $script:Capture = Get-Content -Path $fixturePath -Raw |
            ConvertFrom-Json -AsHashtable -DateKind String
        $script:ItemKey = @('485', '486', '487')
        $script:CommittedTruthTable = Get-Content -Path $script:ConfigPath -Raw |
            ConvertFrom-Json -AsHashtable

        # The one genuine conflict of the recorded run: 486 and 487 both edit the
        # MCP tool surface.
        $script:SurvivingOverlap = 'extensions/drm-copilot/src/mcp-tools.ts'

        # Evaluate the frozen relation over each canonical ascending pair and
        # return the contending pairs as 'a-b' strings.
        function Get-ConflictEdge {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)] [hashtable] $Radius,
                [Parameter(Mandatory = $true)] [hashtable] $Config
            )
            $edge = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $script:ItemKey.Count; $i++) {
                for ($j = $i + 1; $j -lt $script:ItemKey.Count; $j++) {
                    $left = $script:ItemKey[$i]
                    $right = $script:ItemKey[$j]
                    $result = Test-BlastRadiusConflict -RadiusA $Radius[$left] `
                        -RadiusB $Radius[$right] -Config $Config
                    if ($result['conflict']) {
                        $edge.Add("$left-$right")
                    }
                }
            }
            return @($edge.ToArray())
        }
    }

    Context 'Before state' {
        It 'reports contention for all three pairs under the pre-fix config' {
            # Arrange: the raw recorded radii and the pre-fix truth table, both
            # embedded in the fixture so neither input moves when the repository
            # configuration is amended.
            $radius = @{}
            foreach ($key in $script:ItemKey) {
                $radius[$key] = $script:Capture['radii'][$key]
            }

            # Act
            $edges = Get-ConflictEdge -Radius $radius -Config $script:Capture['pre_fix_config']

            # Assert: the complete K3 triangle, which forced fully serial
            # execution of three thematically unrelated items.
            $edges | Should -Be @('485-486', '485-487', '486-487')
        }
    }

    Context 'After state' {
        It 'reports only the genuine 486-487 conflict after normalization' {
            # Arrange: the same recorded radii re-filtered against the committed
            # repository truth table. Reading the shipped config deliberately:
            # the fix is only delivered if the config that actually ships
            # produces this result.
            $radius = @{}
            foreach ($key in $script:ItemKey) {
                $radius[$key] = Get-NormalizedDeclaredRadius `
                    -Radius $script:Capture['radii'][$key] -Config $script:CommittedTruthTable
            }

            # Act
            $edges = Get-ConflictEdge -Radius $radius -Config $script:CommittedTruthTable

            # Assert
            $edges | Should -Be @('486-487')
        }

        It 'cites the shared MCP tool surface as the surviving path overlap' {
            # Arrange
            $left = Get-NormalizedDeclaredRadius -Radius $script:Capture['radii']['486'] `
                -Config $script:CommittedTruthTable
            $right = Get-NormalizedDeclaredRadius -Radius $script:Capture['radii']['487'] `
                -Config $script:CommittedTruthTable

            # Act
            $result = Test-BlastRadiusConflict -RadiusA $left -RadiusB $right `
                -Config $script:CommittedTruthTable
            $detail = @($result['reasons'] | ForEach-Object { $_['detail'] })

            # Assert: the surviving edge is a real path overlap on one file, not
            # a residual artefact of a mandated read. Cohort assertions are
            # Python-side; this port has no cohort computation.
            $result['conflict'] | Should -BeTrue
            $detail | Should -Be @("$script:SurvivingOverlap ~ $script:SurvivingOverlap")
        }
    }
}
