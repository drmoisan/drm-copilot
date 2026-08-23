<#
.SYNOPSIS
    Shape-pinning tests for the committed blast-radius truth table.

.DESCRIPTION
    Reads config/blast-radius.json and its bundled push-down copy and asserts the
    shape contract the PowerShell mirror and its Python reference both rely on:
    the schema version, the seven ratified subsystem modules, a non-empty glob
    list per module, an over-breadth fraction inside (0, 1], repo-relative shared
    surfaces, wildcard-bearing membership globs, the read-by-mandate exclusion
    list, and the absence of both location-bucket and removed umbrella modules.

    Relocated out of BlastRadius.Parity.Tests.ps1 for issue #489: that file
    measured 464 lines and the amended truth-table content had to grow, so the
    Describe moved here under the 500-line file limit. The Disjoint work items
    Context travelled with it because it consumes the same Describe-level
    BeforeAll. The tests read the two committed configurations read-only, invoke
    no external process, and create no temporary files.
#>

BeforeAll {
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius. Resolve-Path
    # normalizes the separators so Pester's code-coverage breakpoints bind to the
    # same on-disk path the run settings name. $script:RepoRoot and
    # $script:ConfigPath mirror the file-level BeforeAll of
    # BlastRadius.Parity.Tests.ps1, whose Describe this file received.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    Import-Module $facadePath -Force

    $script:ConfigPath = Join-Path $script:RepoRoot 'config/blast-radius.json'

    # Render a contention result's reason kinds as a sorted signature so a
    # failure names the level that forced the contention.
    function Get-ReasonSignature {
        [CmdletBinding()]
        [OutputType([System.Object[]])]
        param(
            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [object[]] $Reason
        )
        return @($Reason | ForEach-Object { $_['kind'] } | Sort-Object)
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

        It 'retains exactly the seven ratified subsystem modules' {
            # Arrange: mcp-server, benchmarks, poshqc, powershell-dev-tools,
            # codex-runtime, config, and schemas are the modules that survived
            # the issue #489 granularity review.
            $expected = @(
                'benchmarks', 'codex-runtime', 'config', 'mcp-server', 'poshqc',
                'powershell-dev-tools', 'schemas'
            )

            # Act
            $actual = @($script:CommittedConfig['modules'].Keys | Sort-Object)

            # Assert
            $actual | Should -Be $expected
        }

        It 'declares no removed umbrella module in either committed copy' {
            # Arrange: an umbrella bucket that essentially every work item writes
            # into is not a coherent unit of contention, so these five were
            # removed (issue #489, extending the #472 rationale).
            #
            # The scope is BOTH committed copies. The bundled base document's
            # module map is never read: a destination's map is derived from the
            # destination's OWN layout by assembleModules, and PAYLOAD_MODULES in
            # extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
            # is the live source of a destination's payload modules. The former
            # comment here exempted the bundled copy on the ground that its map
            # describes the destination repository's subsystems, which was not
            # true, and the exemption let a claude-runtime umbrella survive in
            # the published document (issue #500).
            $removed = @('python-dev-tools', 'vscode-extension', 'claude-runtime',
                'copilot-surface', 'agents-surface')

            # Act: walk both committed copies. Comparison is ordinal, matching
            # the case-sensitive semantics of the Python reference.
            $offending = [System.Collections.Generic.List[string]]::new()
            foreach ($config in @($script:CommittedConfig, $script:BundledConfig)) {
                foreach ($name in @($config['modules'].Keys)) {
                    if ($removed -ccontains $name) {
                        $offending.Add($name)
                    }
                }
            }

            # Assert
            $offending.ToArray() | Should -BeNullOrEmpty
        }

        It 'declares only payload modules in the bundled copy' {
            # Arrange: Class 3 of the three-class key partition (issue #500).
            # The bundled modules key set must be a subset of the payload module
            # names the push-down itself creates in a destination. The
            # authoritative source is PAYLOAD_MODULES in
            # extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts.
            # A subset relation rather than equality is asserted so shrinking the
            # payload set does not require editing this test in lockstep.
            # Mirrors test_class_three_bundled_modules_are_payload_modules_only
            # in tests/scripts/dev_tools/test_blast_radius_config_parity.py.
            $script:PayloadModuleName = @('config')

            # Act: comparison is ordinal, matching the Python reference.
            $offending = @(
                $script:BundledConfig['modules'].Keys |
                    Where-Object { -not ($script:PayloadModuleName -ccontains $_) }
            )

            # Assert
            $offending | Should -BeNullOrEmpty
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

        It 'gives every separator-free bundled shared surface no wildcard' {
            # Arrange: the same constraint applied to the published copy
            # (issue #500). A separator-free entry is the sole gate on whether
            # the extractor accepts a separator-free token at all, so a published
            # table with none of them cannot detect two items rewriting the same
            # root build file. Mirrors
            # test_every_separator_free_bundled_shared_surface_is_wildcard_free
            # in tests/scripts/dev_tools/test_blast_radius_config_parity.py.
            $separatorFree = @(
                $script:BundledConfig['shared_surfaces'] |
                    Where-Object { -not $_.Contains('/') }
            )

            # Act
            $offending = @(
                $separatorFree | Where-Object { $_.Contains('*') -or $_.Contains('?') }
            )

            # Assert: the selection must be non-empty, otherwise the wildcard
            # check would pass vacuously while the fail-open defect remained.
            $separatorFree.Count | Should -BeGreaterThan 0
            $offending | Should -BeNullOrEmpty
        }
    }

    Context 'Read-by-mandate exclusions' {
        It 'declares mandate_reads as a list of non-empty strings' {
            # Arrange: the optional key is absent-tolerant in the readers, but the
            # committed table opted in with issue #489, so its shape is pinned.
            $entries = @($script:CommittedConfig['mandate_reads'])

            # Assert: an empty or blank-bearing list would exclude nothing or
            # throw at read time.
            $entries.Count | Should -BeGreaterThan 0
            @($entries | Where-Object { [string]::IsNullOrWhiteSpace($_) }) |
                Should -BeNullOrEmpty
        }

        It 'lists quality-tiers.yml as both a shared surface and a mandate read' {
            # Assert: the tier map is a genuine shared surface when an item really
            # writes it, and a mandate read when an item merely cites it.
            $script:CommittedConfig['shared_surfaces'] | Should -Contain 'quality-tiers.yml'
            $script:CommittedConfig['mandate_reads'] | Should -Contain 'quality-tiers.yml'
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
