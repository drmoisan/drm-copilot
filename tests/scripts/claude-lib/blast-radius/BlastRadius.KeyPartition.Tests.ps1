<#
.SYNOPSIS
    Cross-copy key-partition tests for the committed blast-radius truth table.

.DESCRIPTION
    Split out of BlastRadius.TruthTable.Tests.ps1 (issue #500, cycle 3): that file
    reached 496 of the 500-line limit after the CR-1/CR-2 non-vacuity-floor
    repair, crossing the 480-line split trigger. Three of the four moved cases
    (Class 1 byte-equality of the runtime-describing keys, the directional
    separator-free invariant, and the top-level key-set exhaustiveness gate)
    moved unchanged; the fourth, originally named
    'requires the shared-surface lists compared by the directional invariant to
    be non-empty', was renamed to
    'requires a populated shared-surface list and module map in both copies' and
    rewritten as the cycle-3 CR-1/CR-2 repair. A fifth case, closing the CR-3
    key-consumption residual, was added in cycle 4. The tests read the two
    committed configurations read-only, invoke no external process, and create
    no temporary files.
#>

BeforeAll {
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root. Mirrors the file-level BeforeAll of
    # BlastRadius.TruthTable.Tests.ps1, whose Describe this file received.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:ConfigPath = Join-Path $script:RepoRoot 'config/blast-radius.json'

    # Class 1 key names (issue #500, cycle 3 CR-3). Read by the 'declares equal
    # values for the runtime-describing keys in both copies' case.
    $script:ClassOneKeys = @('version', 'over_breadth_fraction', 'mandate_reads')

    # Class 2 key-to-consumer-file registry (issue #500, cycle 4 R1). Both keys
    # are indexed by name in BlastRadius.TruthTable.Tests.ps1, not in this
    # file, so the registry maps each key to the file that actually consumes
    # it -- closing the CR-3 residual, in which a key added to a bare
    # membership tuple passed silently with no consuming assertion.
    $script:ClassTwoKeyConsumerFile = @{
        'shared_surfaces'      = 'BlastRadius.TruthTable.Tests.ps1'
        'shared_surface_globs' = 'BlastRadius.TruthTable.Tests.ps1'
    }

    # Class 3 key-to-consumer-file registry, same rationale.
    $script:ClassThreeKeyConsumerFile = @{
        'modules' = 'BlastRadius.TruthTable.Tests.ps1'
    }

    # Class 2 and Class 3 key names, derived from the registries above so the
    # exhaustiveness case's declared-key-set computation is unaffected.
    $script:ClassTwoKeys = @($script:ClassTwoKeyConsumerFile.Keys)
    $script:ClassThreeKeys = @($script:ClassThreeKeyConsumerFile.Keys)
}

Describe 'Committed blast-radius truth table cross-copy key partition' {
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

    Context 'Cross-copy key partition' {
        It 'declares equal values for the runtime-describing keys in both copies' {
            # Arrange: Class 1 of the three-class key partition (issue #500).
            # version, over_breadth_fraction, and mandate_reads describe the
            # runtime rather than any repository's directory layout, so the two
            # committed copies must agree exactly. This closes the drift
            # structurally: an addition to one copy's mandate_reads cannot land
            # without the same addition to the other. Mirrors
            # test_class_one_keys_are_equal_across_both_committed_copies in
            # tests/scripts/dev_tools/test_blast_radius_config_parity.py.

            # Act: accumulate the keys whose serialized values differ, so the
            # failure lists every disagreeing key rather than the first.
            $offending = [System.Collections.Generic.List[string]]::new()
            foreach ($key in $script:ClassOneKeys) {
                $committed = ConvertTo-Json -InputObject $script:CommittedConfig[$key] -Depth 10 -Compress
                $bundled = ConvertTo-Json -InputObject $script:BundledConfig[$key] -Depth 10 -Compress
                if ($committed -cne $bundled) {
                    $offending.Add($key)
                }
            }

            # Assert
            $offending.ToArray() | Should -BeNullOrEmpty
        }

        It 'requires every separator-free self-hosted shared surface to reach the bundled copy' {
            # Arrange: directional invariant closing the residual Class 2 gap
            # (issue #500 remediation). Portable-set equality and the
            # bundled <= self_hosted subset relation together do not observe
            # the self-hosted copy gaining a portable separator-free surface
            # that never reaches the bundle. Select the separator-free entries
            # from each committed copy, since only a separator-free entry is
            # accepted by the root-token extractor. Mirrors
            # test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle
            # in tests/scripts/dev_tools/test_blast_radius_config_parity.py.
            $selfHostedSeparatorFree = @(
                $script:CommittedConfig['shared_surfaces'] |
                    Where-Object { -not $_.Contains('/') }
            )
            $bundledSeparatorFree = @(
                $script:BundledConfig['shared_surfaces'] |
                    Where-Object { -not $_.Contains('/') }
            )

            # Act: accumulate every self-hosted separator-free entry absent
            # from the bundled separator-free set, so the failure names all
            # missing entries rather than the first.
            $missing = [System.Collections.Generic.List[string]]::new()
            foreach ($entry in $selfHostedSeparatorFree) {
                if ($bundledSeparatorFree -cnotcontains $entry) {
                    $missing.Add($entry)
                }
            }

            # Assert: no self-hosted separator-free entry may be missing from
            # the bundled separator-free set.
            $missing.ToArray() | Should -BeNullOrEmpty
        }

        It 'requires every top-level key in both copies to be classified and shared' {
            # Arrange: exhaustiveness check closing the key-set gap the three
            # declared classes leave open by construction (issue #500
            # remediation, R8). Mirrors
            # test_every_top_level_key_is_classified_and_shared_by_both_copies
            # in tests/scripts/dev_tools/test_blast_radius_config_parity.py.
            $declaredTopLevelKey = $script:ClassOneKeys + $script:ClassTwoKeys + $script:ClassThreeKeys

            # Act: accumulate every key present in one copy's key set but
            # absent from the other, so the failure names all missing keys
            # rather than the first.
            $missingKey = [System.Collections.Generic.List[string]]::new()
            foreach ($key in @($script:CommittedConfig.Keys)) {
                if ($script:BundledConfig.Keys -cnotcontains $key) {
                    $missingKey.Add($key)
                }
            }
            foreach ($key in @($script:BundledConfig.Keys)) {
                if ($script:CommittedConfig.Keys -cnotcontains $key) {
                    $missingKey.Add($key)
                }
            }

            # Act: accumulate every key present in either copy but absent from
            # the declared key set, so an unclassified key is named.
            $unclassifiedKey = [System.Collections.Generic.List[string]]::new()
            $unionKey = @($script:CommittedConfig.Keys) + @($script:BundledConfig.Keys) |
                Select-Object -Unique
            foreach ($key in $unionKey) {
                if ($declaredTopLevelKey -cnotcontains $key) {
                    $unclassifiedKey.Add($key)
                }
            }

            # Assert: neither copy may be missing a key the other declares,
            # and neither copy may declare a key outside the declared set.
            $missingKey.ToArray() | Should -BeNullOrEmpty
            $unclassifiedKey.ToArray() | Should -BeNullOrEmpty
        }

        It 'requires a populated shared-surface list and module map in both copies' {
            # Arrange: non-vacuity floor guarding the directional invariant and
            # the module-map assertions (issue #500 remediation, cycle 3 CR-1
            # repair, extended by CR-2). The prior form measured emptiness with
            # `@($config[$key]).Count -gt 0` alone, which cannot fail for an
            # ABSENT key: `@($null).Count` is `1` in PowerShell (the scalar
            # `$null` wraps to a one-element array containing `$null`), so the
            # old floor passed on exactly the two states it was meant to
            # reject. This case discriminates four states in an order that
            # never reaches that ambiguous idiom for the absent-key or
            # null-value states, so it correctly rejects both:
            #   1. Key absent from the hashtable (ContainsKey false).
            #   2. Key present but its value is $null.
            #   3. Key present, non-null, but empty (zero entries/zero keys).
            #   4. Key present, non-null, non-empty -- the only passing state.
            # Extends the prior shared_surfaces-only floor to also guard the
            # bundled and self-hosted `modules` map (CR-2), which previously
            # had no non-vacuity floor on the Pester side at all.
            $combination = @(
                @{ Label = 'self-hosted shared_surfaces'; Config = $script:CommittedConfig; Key = 'shared_surfaces' }
                @{ Label = 'bundled shared_surfaces'; Config = $script:BundledConfig; Key = 'shared_surfaces' }
                @{ Label = 'self-hosted modules'; Config = $script:CommittedConfig; Key = 'modules' }
                @{ Label = 'bundled modules'; Config = $script:BundledConfig; Key = 'modules' }
            )

            # Act: accumulate every offending combination so one run names all
            # of them rather than just the first.
            $offending = [System.Collections.Generic.List[string]]::new()
            foreach ($item in $combination) {
                $label = $item.Label
                $config = $item.Config
                $key = $item.Key

                if (-not $config.ContainsKey($key)) {
                    # State 1: key absent. Checked first so the ambiguous
                    # @($null).Count idiom below is never reached for this
                    # state.
                    $offending.Add("${label}: ${key} key absent")
                    continue
                }

                if ($null -eq $config[$key]) {
                    # State 2: key present but null. Checked before the count
                    # measurement for the same reason as state 1.
                    $offending.Add("${label}: ${key} is null")
                    continue
                }

                # States 1 and 2 are excluded by this point, so wrapping in
                # @() to measure a count is safe here and cannot misclassify
                # an absent or null value as populated.
                if ($key -eq 'modules') {
                    $count = @($config[$key].Keys).Count
                } else {
                    $count = @($config[$key]).Count
                }

                if ($count -eq 0) {
                    # State 3: key present, non-null, but empty.
                    $offending.Add("${label}: ${key} is empty")
                }
                # State 4 (populated) adds nothing to $offending.
            }

            # Assert: no combination may be absent, null, or empty.
            $offending.ToArray() | Should -BeNullOrEmpty
        }

        It 'requires every Class 2 and Class 3 key to be indexed by name in its registered consumer file' {
            # Arrange: closes the CR-3 residual (issue #500 remediation, cycle
            # 4 R1). Membership in $script:ClassTwoKeys / $script:ClassThreeKeys
            # proves only that a key was added to the registry, not that any
            # assertion actually reads it. Read each distinct consumer file
            # named in the two registries once, and check every (key, file)
            # pair for the literal indexer substring the consuming assertion
            # uses to read it.
            $registries = @($script:ClassTwoKeyConsumerFile, $script:ClassThreeKeyConsumerFile)
            $consumerFileNames = $registries.Values | Select-Object -Unique
            $fileText = @{}
            foreach ($fileName in $consumerFileNames) {
                $fileText[$fileName] = Get-Content -Raw -Path (Join-Path $PSScriptRoot $fileName)
            }

            # Act: accumulate every (key, file) pair whose consumer file never
            # indexes the key by name, so the failure names every unresolved
            # pair rather than the first.
            $unresolved = [System.Collections.Generic.List[string]]::new()
            foreach ($registry in $registries) {
                foreach ($key in $registry.Keys) {
                    $fileName = $registry[$key]
                    if (-not $fileText[$fileName].Contains("['$key']")) {
                        $unresolved.Add("${key} -> ${fileName}")
                    }
                }
            }

            # Assert: every registered key must be indexed by name in its
            # registered consumer file.
            $unresolved.ToArray() | Should -BeNullOrEmpty
        }
    }
}
