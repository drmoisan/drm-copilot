<#
.SYNOPSIS
    Behavioral tests for the blast-radius guards and truth-table resolution.

.DESCRIPTION
    Mirrors the pytest coverage of require_text, require_str_tuple,
    require_mapping, config_string_list, config_modules,
    config_over_breadth_fraction, resolve_modules, and resolve_shared_surfaces.
    Each It targets a single behavior with Arrange-Act-Assert structure. The
    tests read the committed config/blast-radius.json read-only, invoke no
    external process, and create no temporary files.

    This file is an authorized sibling of BlastRadius.Tests.ps1 under the
    500-line file limit; it covers the truth-table half of task P4-T5.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusConfig.psm1").Path
    Import-Module $modulePath -Force

    # A minimal truth table exercising both shared-surface sources and a two-glob
    # module, kept independent of the committed configuration.
    $script:TestConfig = @{
        version               = 1
        shared_surfaces       = @('poetry.lock', 'quality-tiers.yml')
        shared_surface_globs  = @('scripts/dev_tools/validate_*.py')
        modules               = @{
            'alpha' = @('scripts/**')
            'beta'  = @('tests/**', 'docs/**')
        }
        over_breadth_fraction = 0.25
    }
}

Describe 'Get-RequiredText' {
    Context 'Accepted values' {
        It 'returns a non-blank string unchanged' {
            # Arrange / Act: guard a normal value.
            $value = Get-RequiredText -Value 'derived' -FieldName 'source'

            # Assert: the guard returns its input so call sites can chain.
            $value | Should -Be 'derived'
        }

        It 'accepts a blank string when empty values are allowed' {
            # Arrange / Act: guard an empty document body.
            $value = Get-RequiredText -Value '' -FieldName 'plan_text' -AllowEmpty

            # Assert: plan and spec text may legitimately be empty.
            $value | Should -Be ''
        }
    }

    Context 'Rejected values' {
        It 'throws for a non-string value' {
            # Arrange / Act / Assert: a numeric value violates the contract.
            { Get-RequiredText -Value 42 -FieldName 'source' } | Should -Throw '*must be a string*'
        }

        It 'throws for a null value' {
            # Arrange / Act / Assert: a missing value violates the contract.
            { Get-RequiredText -Value $null -FieldName 'source' } | Should -Throw '*must be a string*'
        }

        It 'throws for a whitespace-only value when empty values are not allowed' {
            # Arrange / Act / Assert: blank is rejected rather than normalized away.
            { Get-RequiredText -Value '   ' -FieldName 'computed_at' } | Should -Throw '*must not be empty*'
        }
    }
}

Describe 'Get-RequiredStringList' {
    Context 'Accepted collections' {
        It 'deduplicates and ordinally sorts the entries' {
            # Arrange: an unsorted collection with a duplicate.
            $value = @('b', 'a', 'b')

            # Act: guard and normalize the collection.
            $entries = @(Get-RequiredStringList -Value $value -FieldName 'paths')

            # Assert: normalization matches the Python tuple(sorted(set(...))) step.
            $entries | Should -Be @('a', 'b')
        }

        It 'accepts an empty collection' {
            # Arrange / Act: guard an empty collection.
            $entries = @(Get-RequiredStringList -Value @() -FieldName 'contracts')

            # Assert: an empty radius level is valid.
            $entries.Count | Should -Be 0
        }
    }

    Context 'Rejected collections' {
        It 'throws for a bare string' {
            # Arrange / Act / Assert: the Python reference rejects a bare string so
            # it cannot silently split into characters; the port agrees.
            { Get-RequiredStringList -Value 'a/b.py' -FieldName 'paths' } |
                Should -Throw '*must be a list or tuple*'
        }

        It 'throws for a null value' {
            # Arrange / Act / Assert: a missing collection violates the contract.
            { Get-RequiredStringList -Value $null -FieldName 'paths' } |
                Should -Throw '*must be a list or tuple*'
        }

        It 'throws when an entry is not a string' {
            # Arrange / Act / Assert: every entry is validated before sorting.
            { Get-RequiredStringList -Value @('a', 7) -FieldName 'paths' } |
                Should -Throw '*must be a string*'
        }

        It 'throws when an entry is blank' {
            # Arrange / Act / Assert: a blank entry would silently widen a radius.
            { Get-RequiredStringList -Value @('a', '  ') -FieldName 'paths' } |
                Should -Throw '*must not be empty*'
        }
    }
}

Describe 'Get-RequiredMapping' {
    Context 'Accepted shapes' {
        It 'returns a hashtable unchanged' {
            # Arrange: a hashtable truth table.
            $value = @{ version = 1 }

            # Act: guard the mapping.
            $mapping = Get-RequiredMapping -Value $value -FieldName 'config'

            # Assert: the guard reads the mapping and does not copy or mutate it.
            $mapping['version'] | Should -Be 1
        }

        It 'converts a PSCustomObject such as ConvertFrom-Json output' {
            # Arrange: the shape ConvertFrom-Json yields without -AsHashtable.
            $value = [PSCustomObject]@{ version = 1 }

            # Act: guard the mapping.
            $mapping = Get-RequiredMapping -Value $value -FieldName 'config'

            # Assert: the properties become keys so JSON callers need no ceremony.
            $mapping['version'] | Should -Be 1
        }

        It 'converts an ordered dictionary' {
            # Arrange: an ordered dictionary, which is an IDictionary but not a
            # hashtable.
            $value = [ordered]@{ version = 1 }

            # Act: guard the mapping.
            $mapping = Get-RequiredMapping -Value $value -FieldName 'config'

            # Assert: every dictionary shape is accepted.
            $mapping['version'] | Should -Be 1
        }
    }

    Context 'Rejected shapes' {
        It 'throws for a string' {
            # Arrange / Act / Assert: a string is not a mapping.
            { Get-RequiredMapping -Value 'config' -FieldName 'config' } |
                Should -Throw '*must be a mapping*'
        }

        It 'throws for a null value' {
            # Arrange / Act / Assert: a missing truth table violates the contract.
            { Get-RequiredMapping -Value $null -FieldName 'config' } |
                Should -Throw '*must be a mapping*'
        }
    }
}

Describe 'Get-ConfigStringList' {
    Context 'Reading optional list entries' {
        It 'returns the sorted entries of a present key' {
            # Arrange / Act: read the shared-surface list.
            $entries = @(Get-ConfigStringList -Config $script:TestConfig -Key 'shared_surfaces')

            # Assert: entries are normalized like every other collection.
            $entries | Should -Be @('poetry.lock', 'quality-tiers.yml')
        }

        It 'returns an empty collection for an absent key' {
            # Arrange / Act: read a key the minimal truth table omits.
            $entries = @(Get-ConfigStringList -Config @{ version = 1 } -Key 'shared_surfaces')

            # Assert: an absent key keeps a minimal configuration usable.
            $entries.Count | Should -Be 0
        }

        It 'returns an empty collection for a null value' {
            # Arrange / Act: read a key whose value is explicitly null.
            $entries = @(Get-ConfigStringList -Config @{ shared_surfaces = $null } -Key 'shared_surfaces')

            # Assert: a null value is treated exactly like an absent key.
            $entries.Count | Should -Be 0
        }
    }
}

Describe 'Get-ConfigRootSurface' {
    Context 'Reading the separator-free subset' {
        It 'returns exactly the separator-free entries in ordinal sort order' {
            # Arrange: a truth table mixing separator-bearing and separator-free
            # surfaces, supplied out of order so the sort is observable.
            $config = @{
                shared_surfaces = @(
                    'quality-tiers.yml',
                    'config/orchestration-routing.json',
                    'poetry.lock',
                    'scripts/dev_tools/compute_blast_radius.py',
                    'package-lock.json'
                )
            }

            # Act: read the root-surface set.
            $rootSurface = @(Get-ConfigRootSurface -Config $config)

            # Assert: only the three separator-free entries survive, ordinally
            # sorted, so a bare inline-code token can match one exactly.
            $rootSurface | Should -Be @('package-lock.json', 'poetry.lock', 'quality-tiers.yml')
        }

        It 'returns an empty collection for a config with no shared_surfaces' {
            # Arrange / Act: a minimal truth table with no shared_surfaces key.
            $rootSurface = @(Get-ConfigRootSurface -Config @{ version = 1 })

            # Assert: an empty set reproduces pre-change behavior exactly.
            $rootSurface.Count | Should -Be 0
        }

        It 'returns an empty collection when every surface carries a separator' {
            # Arrange / Act: every entry is already reachable by path shape.
            $rootSurface = @(Get-ConfigRootSurface -Config @{
                    shared_surfaces = @('config/orchestration-routing.json', 'docs/ci.research.md')
                })

            # Assert: a separator-bearing surface is never a root surface.
            $rootSurface.Count | Should -Be 0
        }
    }
}

Describe 'Get-ConfigModuleEntry' {
    Context 'Reading the module map' {
        It 'returns name and glob pairs ordered by module name' {
            # Arrange / Act: read the two-module test truth table.
            $pairs = @(Get-ConfigModuleEntry -Config $script:TestConfig)

            # Assert: ordering by name makes resolution deterministic.
            @($pairs | ForEach-Object { $_['name'] }) | Should -Be @('alpha', 'beta')
        }

        It 'carries every glob of a multi-glob module' {
            # Arrange / Act: read the module map.
            $pairs = @(Get-ConfigModuleEntry -Config $script:TestConfig)
            $beta = $pairs | Where-Object { $_['name'] -eq 'beta' }

            # Assert: both globs survive, sorted ordinally.
            @($beta['globs']) | Should -Be @('docs/**', 'tests/**')
        }

        It 'returns an empty collection when the module map is absent' {
            # Arrange / Act: read a truth table with no module map.
            $pairs = @(Get-ConfigModuleEntry -Config @{ version = 1 })

            # Assert: an absent map resolves no module rather than failing.
            $pairs.Count | Should -Be 0
        }

        It 'throws when a module maps to something other than a string list' {
            # Arrange: a malformed module entry.
            $config = @{ modules = @{ 'alpha' = 'scripts/**' } }

            # Act / Assert: a malformed truth table fails at the offending module.
            { Get-ConfigModuleEntry -Config $config } | Should -Throw '*must be a list or tuple*'
        }
    }
}

Describe 'Get-ConfigOverBreadthFraction' {
    Context 'Accepted thresholds' {
        It 'reads a fractional threshold' {
            # Arrange / Act: read the test truth table's threshold.
            $fraction = Get-ConfigOverBreadthFraction -Config $script:TestConfig

            # Assert: the value is returned as a double for the V3 comparison.
            $fraction | Should -Be 0.25
        }

        It 'accepts the inclusive upper bound of one' {
            # Arrange / Act: read a threshold at the top of the allowed range.
            $fraction = Get-ConfigOverBreadthFraction -Config @{ over_breadth_fraction = 1 }

            # Assert: the range is (0, 1], so one is valid.
            $fraction | Should -Be 1
        }
    }

    Context 'Rejected thresholds' {
        It 'throws when the key is absent' {
            # Arrange / Act / Assert: V3 cannot run without a threshold.
            { Get-ConfigOverBreadthFraction -Config @{ version = 1 } } |
                Should -Throw '*must be a number*'
        }

        It 'throws for a boolean, which Python would treat as an integer' {
            # Arrange / Act / Assert: booleans are rejected explicitly.
            { Get-ConfigOverBreadthFraction -Config @{ over_breadth_fraction = $true } } |
                Should -Throw '*must be a number*'
        }

        It 'throws for a non-numeric value' {
            # Arrange / Act / Assert: a string threshold violates the contract.
            { Get-ConfigOverBreadthFraction -Config @{ over_breadth_fraction = '0.25' } } |
                Should -Throw '*must be a number*'
        }

        It 'throws for a value outside the (0, 1] range' -ForEach @(0, 1.5, -0.5) {
            # Arrange / Act / Assert: a threshold outside the range is malformed.
            { Get-ConfigOverBreadthFraction -Config @{ over_breadth_fraction = $_ } } |
                Should -Throw
        }
    }
}

Describe 'Resolve-BlastRadiusModule' {
    Context 'Module resolution' {
        It 'resolves a path to the module whose glob covers it' {
            # Arrange / Act: a script path against the test truth table.
            $modules = @(Resolve-BlastRadiusModule -PathEntry @('scripts/dev_tools/a.py') -Config $script:TestConfig)

            # Assert: only the matching module joins the radius.
            $modules | Should -Be @('alpha')
        }

        It 'resolves a module through any one of its globs' {
            # Arrange / Act: a docs path matching beta's second glob.
            $modules = @(Resolve-BlastRadiusModule -PathEntry @('docs/x.md') -Config $script:TestConfig)

            # Assert: a module joins as soon as one of its globs covers one entry.
            $modules | Should -Be @('beta')
        }

        It 'returns the matched modules deduplicated and ordinally sorted' {
            # Arrange: paths matching both modules, listed out of order.
            $paths = @('tests/a.py', 'scripts/b.py', 'docs/c.md')

            # Act: resolve the modules.
            $modules = @(Resolve-BlastRadiusModule -PathEntry $paths -Config $script:TestConfig)

            # Assert: beta matches twice but appears once.
            $modules | Should -Be @('alpha', 'beta')
        }

        It 'resolves no module for a path matching no glob' {
            # Arrange / Act: a repository-root file outside every module glob.
            $modules = @(Resolve-BlastRadiusModule -PathEntry @('poetry.lock') -Config $script:TestConfig)

            # Assert: path-matching-no-module is a supported outcome.
            $modules.Count | Should -Be 0
        }

        It 'resolves no module for an empty path collection' {
            # Arrange / Act: an empty radius.
            $modules = @(Resolve-BlastRadiusModule -PathEntry @() -Config $script:TestConfig)

            # Assert: nothing touched means no module touched.
            $modules.Count | Should -Be 0
        }
    }
}

Describe 'Resolve-BlastRadiusSharedSurface' {
    Context 'Surface membership' {
        It 'selects a path named in the literal shared-surface list' {
            # Arrange / Act: a literal surface among ordinary paths.
            $surfaces = @(Resolve-BlastRadiusSharedSurface `
                    -ConcretePath @('poetry.lock', 'scripts/a.py') -Config $script:TestConfig)

            # Assert: literal list membership is the first source.
            $surfaces | Should -Be @('poetry.lock')
        }

        It 'selects a path matched only by a shared-surface glob' {
            # Arrange / Act: a validator module absent from the literal list.
            $surfaces = @(Resolve-BlastRadiusSharedSurface `
                    -ConcretePath @('scripts/dev_tools/validate_orchestration_artifacts.py') `
                    -Config $script:TestConfig)

            # Assert: a glob hit counts on its own, the fail-closed direction.
            $surfaces.Count | Should -Be 1
        }

        It 'returns the surfaces deduplicated and ordinally sorted' {
            # Arrange: both surfaces listed out of order with a duplicate.
            $paths = @('quality-tiers.yml', 'poetry.lock', 'poetry.lock')

            # Act: resolve the touched surfaces.
            $surfaces = @(Resolve-BlastRadiusSharedSurface -ConcretePath $paths -Config $script:TestConfig)

            # Assert: normalization matches every other collection.
            $surfaces | Should -Be @('poetry.lock', 'quality-tiers.yml')
        }

        It 'selects nothing when no path is a shared surface' {
            # Arrange / Act: ordinary implementation paths only.
            $surfaces = @(Resolve-BlastRadiusSharedSurface `
                    -ConcretePath @('scripts/a.py', 'tests/b.py') -Config $script:TestConfig)

            # Assert: an untouched surface set is the common case.
            $surfaces.Count | Should -Be 0
        }
    }
}

Describe 'Committed truth table' {
    Context 'config/blast-radius.json shape' {
        It 'resolves the repository module map without error' {
            # Arrange: the committed truth table, read read-only.
            $config = Get-Content -Path (Join-Path $script:RepoRoot 'config/blast-radius.json') -Raw |
                ConvertFrom-Json -AsHashtable

            # Act: read every module pair.
            $pairs = @(Get-ConfigModuleEntry -Config $config)

            # Assert: the committed map carries the twelve spec modules.
            $pairs.Count | Should -Be 12
        }

        It 'exposes the committed over-breadth fraction' {
            # Arrange: the committed truth table.
            $config = Get-Content -Path (Join-Path $script:RepoRoot 'config/blast-radius.json') -Raw |
                ConvertFrom-Json -AsHashtable

            # Act: read the V3 threshold.
            $fraction = Get-ConfigOverBreadthFraction -Config $config

            # Assert: the pinned value matches the spec Configuration section.
            $fraction | Should -Be 0.25
        }
    }
}
