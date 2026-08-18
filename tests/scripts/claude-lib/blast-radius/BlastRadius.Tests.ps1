<#
.SYNOPSIS
    Behavioral tests for blast-radius derivation on the PowerShell facade.

.DESCRIPTION
    Mirrors the derivation half of the pytest suite in
    tests/scripts/dev_tools/test_compute_blast_radius.py: the exported key set,
    plan and spec path extraction, the feature-folder append and its
    already-qualified guard, module resolution, shared-surface expansion,
    contract extraction, the zero-extractable-paths case, the observed-source
    entry point, and the fail-fast guards. Each It targets a single behavior with
    Arrange-Act-Assert structure. The tests invoke no external process and create
    no temporary files.

    Sibling files cover extraction (BlastRadiusExtraction.Tests.ps1), pattern
    comparison (BlastRadiusGlob.Tests.ps1), truth-table resolution
    (BlastRadiusConfig.Tests.ps1), validation (BlastRadius.Validation.Tests.ps1),
    and contention (BlastRadius.Conflict.Tests.ps1); the split satisfies the
    500-line file limit for task P4-T5.
#>

BeforeAll {
    # Resolve the facade four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    Import-Module $modulePath -Force

    # A minimal truth table exercising both shared-surface sources and two
    # modules, kept independent of the committed configuration.
    $script:TestConfig = @{
        version               = 1
        shared_surfaces       = @('poetry.lock', 'config/orchestration-routing.json')
        shared_surface_globs  = @('scripts/dev_tools/validate_*.py')
        modules               = @{
            'alpha' = @('scripts/**')
            'beta'  = @('docs/**')
        }
        over_breadth_fraction = 0.25
    }

    # The frozen serialized key set every radius must carry.
    $script:RadiusKey = @('paths', 'modules', 'shared_surfaces', 'contracts', 'source', 'computed_at')
}

Describe 'Get-BlastRadius record shape' {
    Context 'Key set and source vocabulary' {
        It 'returns exactly the six documented keys' {
            # Arrange / Act: derive a radius from a trivial plan.
            $radius = Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt '2026-08-07T12-00'

            # Assert: downstream features depend on these strings verbatim.
            @($radius.Keys | Sort-Object) | Should -Be @($script:RadiusKey | Sort-Object)
        }

        It 'records the derived source by default' {
            # Arrange / Act: derive without naming a source.
            $radius = Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt '2026-08-07T12-00'

            # Assert: derivation seeds cohorts provisionally as derived.
            $radius['source'] | Should -Be 'derived'
        }

        It 'records the declared source when a planner adopts the result' {
            # Arrange / Act: derive with the authoritative source.
            $radius = Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -Source 'declared' -ComputedAt '2026-08-07T12-00'

            # Assert: declared is the source the scheduler treats as authoritative.
            $radius['source'] | Should -Be 'declared'
        }

        It 'records the caller-supplied timestamp verbatim' {
            # Arrange / Act: derive with a fixed timestamp.
            $radius = Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt '2026-08-07T12-00'

            # Assert: the library never reads the clock, so the value round-trips.
            $radius['computed_at'] | Should -Be '2026-08-07T12-00'
        }

        It 'throws for a source outside the frozen vocabulary' {
            # Arrange / Act / Assert: an unknown source is malformed input.
            { Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder 'f' `
                    -Config $script:TestConfig -Source 'guessed' -ComputedAt 't' } |
                Should -Throw '*source must be one of*'
        }

        It 'throws for a blank timestamp' {
            # Arrange / Act / Assert: a blank timestamp would break ordering.
            { Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder 'f' `
                    -Config $script:TestConfig -ComputedAt '' } |
                Should -Throw '*computed_at must not be empty*'
        }

        It 'throws for a blank feature folder' {
            # Arrange / Act / Assert: every radius must carry its feature folder.
            { Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder '  ' `
                    -Config $script:TestConfig -ComputedAt 't' } |
                Should -Throw '*feature_folder must not be empty*'
        }

        It 'throws for a truth table that is not a mapping' {
            # Arrange / Act / Assert: a malformed truth table fails fast.
            { Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder 'f' `
                    -Config 'not-a-mapping' -ComputedAt 't' } |
                Should -Throw '*must be a mapping*'
        }
    }
}

Describe 'Get-BlastRadius path derivation' {
    Context 'The feature-folder append' {
        It 'appends the feature-folder glob for a bare folder name' {
            # Arrange / Act: derive from an empty plan and spec.
            $radius = Get-BlastRadius -PlanText '' -SpecText '' `
                -FeatureFolder '2026-08-07-parallel-blast-radius-447' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: a zero-path plan still yields the feature folder, because
            # every work item writes its own documents and evidence.
            @($radius['paths']) | Should -Be @('docs/features/active/2026-08-07-parallel-blast-radius-447/**')
        }

        It 'uses an already-qualified folder path as is' {
            # Arrange / Act: pass a path the caller already holds.
            $radius = Get-BlastRadius -PlanText '' -SpecText '' `
                -FeatureFolder 'docs/features/active/f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: the guard prevents a doubled docs/features/active prefix.
            @($radius['paths']) | Should -Be @('docs/features/active/f/**')
        }

        It 'trims surrounding whitespace and separators from the folder' {
            # Arrange / Act: pass a folder with stray separators.
            $radius = Get-BlastRadius -PlanText '' -SpecText '' -FeatureFolder ' /f/ ' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: trimming keeps the glob well formed.
            @($radius['paths']) | Should -Be @('docs/features/active/f/**')
        }
    }

    Context 'Plan and spec contributions' {
        It 'collects paths cited in plan task bodies' {
            # Arrange: a plan citing one path in a task body.
            $plan = '- [ ] [P1-T1] Touch `scripts/dev_tools/a.py`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: task bodies are the primary path signal.
            @($radius['paths']) | Should -Contain 'scripts/dev_tools/a.py'
        }

        It 'collects paths cited in the spec' {
            # Arrange: a spec citing a path in inline code.
            $spec = 'The module lives at `scripts/dev_tools/b.py`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText '' -SpecText $spec -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: the spec contributes the paths it cites.
            @($radius['paths']) | Should -Contain 'scripts/dev_tools/b.py'
        }

        It 'returns the union deduplicated and ordinally sorted' {
            # Arrange: a plan and spec citing an overlapping path set.
            $plan = '- [ ] [P1-T1] Touch `scripts/b.py` and `docs/a.md`.'
            $spec = 'Also `scripts/b.py`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText $plan -SpecText $spec -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: the shared citation collapses and the order is ordinal.
            @($radius['paths']) | Should -Be @(
                'docs/a.md', 'docs/features/active/f/**', 'scripts/b.py')
        }

        It 'derives the same radius from a CRLF plan as from its LF equivalent' {
            # Arrange: the same plan text in both line-ending styles.
            $lfPlan = "### Phase 1 — Work`n- [ ] [P1-T1] Touch ``scripts/a.py``."
            $crlfPlan = $lfPlan.Replace("`n", "`r`n")

            # Act: derive from each.
            $lfRadius = Get-BlastRadius -PlanText $lfPlan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'
            $crlfRadius = Get-BlastRadius -PlanText $crlfPlan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: line-ending style cannot change a radius.
            @($crlfRadius['paths']) | Should -Be @($lfRadius['paths'])
        }
    }
}

Describe 'Get-BlastRadius module and surface resolution' {
    Context 'Modules' {
        It 'resolves the modules the derived paths belong to' {
            # Arrange: a plan touching both configured modules.
            $plan = '- [ ] [P1-T1] Touch `scripts/a.py` and `docs/b.md`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: both modules join, ordinally sorted.
            @($radius['modules']) | Should -Be @('alpha', 'beta')
        }

        It 'resolves no module for a path matching no glob' {
            # Arrange: a plan touching a path outside every configured module glob.
            $plan = '- [ ] [P1-T1] Touch `schemas/x.json`.'

            # Act: derive the radius, using a folder outside every module glob.
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' `
                -FeatureFolder 'docs/features/active/f' -Config @{
                modules               = @{ 'alpha' = @('scripts/**') }
                over_breadth_fraction = 0.25
            } -ComputedAt 't'

            # Assert: path-matching-no-module is a supported outcome.
            @($radius['modules']).Count | Should -Be 0
        }
    }

    Context 'Shared surfaces' {
        It 'expands a surface named in the literal truth-table list' {
            # Arrange: a plan touching a literal shared surface.
            $plan = '- [ ] [P1-T1] Touch `config/orchestration-routing.json`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: literal list membership expands the surfaces level.
            @($radius['shared_surfaces']) | Should -Be @('config/orchestration-routing.json')
        }

        It 'reaches a configured separator-free repository-root surface from plan text' {
            # Arrange: a plan citing a repository-root shared surface that carries
            # no path separator.
            $plan = '- [ ] [P1-T1] Touch `poetry.lock`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: issue #452 amends this behaviour. Token classification admits a
            # separator-free token that is an exact ordinal member of the configured
            # shared_surfaces list, so a root-level file cited in plan text now reaches
            # the surfaces level. This mirrors the Python reference exactly. The prior
            # assertion of an unreachable surface encoded the Gap 1 defect as intended
            # behaviour; it is one of the two authorized assertion inversions.
            @($radius['shared_surfaces']).Count | Should -Be 1
            @($radius['shared_surfaces'])[0] | Should -Be 'poetry.lock'
        }

        It 'expands a surface matched only by a shared-surface glob' {
            # Arrange: a plan touching a validator module absent from the list.
            $plan = '- [ ] [P1-T1] Touch `scripts/dev_tools/validate_x.py`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: a glob hit counts on its own, the fail-closed direction.
            @($radius['shared_surfaces']) | Should -Be @('scripts/dev_tools/validate_x.py')
        }

        It 'never expands a glob path into a shared surface' {
            # Arrange: a plan citing only a wildcard path.
            $plan = '- [ ] [P1-T1] Touch `scripts/**`.'

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: only concrete entries can be enumerated as surfaces.
            @($radius['shared_surfaces']).Count | Should -Be 0
        }
    }

    Context 'Contracts' {
        It 'extracts contract identifiers from spec interface sections' {
            # Arrange: a spec with one qualifying and one ordinary section.
            $spec = "## Public API`n`n``SymbolOne```n`n## Rationale`n`n``Ignored``"

            # Act: derive the radius.
            $radius = Get-BlastRadius -PlanText '' -SpecText $spec -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: only the qualifying section contributes contracts.
            @($radius['contracts']) | Should -Be @('SymbolOne')
        }

        It 'leaves contracts empty when the spec has no interface section' {
            # Arrange / Act: derive from a spec with no qualifying heading.
            $radius = Get-BlastRadius -PlanText '' -SpecText '## Rationale' -FeatureFolder 'f' `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: an empty contracts level is the common case.
            @($radius['contracts']).Count | Should -Be 0
        }
    }
}

Describe 'Get-BlastRadiusFromObservedPaths' {
    Context 'Observed-source radii' {
        It 'records the observed source' {
            # Arrange / Act: build from a diff path list.
            $radius = Get-BlastRadiusFromObservedPaths -ObservedPaths @('scripts/a.py') `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: drift detection is the only producer of this source.
            $radius['source'] | Should -Be 'observed'
        }

        It 'takes the supplied paths verbatim, deduplicated and sorted' {
            # Arrange: an unsorted diff listing with a duplicate.
            $observed = @('scripts/b.py', 'scripts/a.py', 'scripts/b.py')

            # Act: build the radius.
            $radius = Get-BlastRadiusFromObservedPaths -ObservedPaths $observed `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: diff paths are not re-classified by the plan heuristic.
            @($radius['paths']) | Should -Be @('scripts/a.py', 'scripts/b.py')
        }

        It 'resolves modules and shared surfaces by the derivation rules' {
            # Arrange: a diff touching a module path and a shared surface.
            $observed = @('scripts/a.py', 'poetry.lock')

            # Act: build the radius.
            $radius = Get-BlastRadiusFromObservedPaths -ObservedPaths $observed `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: resolution is identical to derivation for the same paths.
            @($radius['modules']) | Should -Be @('alpha')
            @($radius['shared_surfaces']) | Should -Be @('poetry.lock')
        }

        It 'leaves contracts empty because a diff carries no interface text' {
            # Arrange / Act: build from a diff listing.
            $radius = Get-BlastRadiusFromObservedPaths -ObservedPaths @('scripts/a.py') `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: the contracts level cannot be observed from a diff.
            @($radius['contracts']).Count | Should -Be 0
        }

        It 'accepts an empty observed path list' {
            # Arrange / Act: a diff that touched nothing.
            $radius = Get-BlastRadiusFromObservedPaths -ObservedPaths @() `
                -Config $script:TestConfig -ComputedAt 't'

            # Assert: an empty observed radius is well formed.
            @($radius['paths']).Count | Should -Be 0
        }

        It 'throws for a bare string rather than a collection' {
            # Arrange / Act / Assert: the Python reference rejects a bare string,
            # so the port agrees about which inputs are malformed.
            { Get-BlastRadiusFromObservedPaths -ObservedPaths 'scripts/a.py' `
                    -Config $script:TestConfig -ComputedAt 't' } |
                Should -Throw '*must be a list or tuple*'
        }
    }
}

Describe 'Get-NormalizedDeclaredRadius' {
    Context 'Re-filtering a recorded radius (issue #489)' {
        BeforeAll {
            # A truth table carrying the ratified mandate-read list and one
            # module, kept independent of the committed configuration.
            $script:NormalizerConfig = @{
                version               = 1
                shared_surfaces       = @('config/blast-radius.json', 'quality-tiers.yml')
                shared_surface_globs  = @()
                mandate_reads         = @(
                    '.claude/rules/**',
                    '.claude/skills/atomic-plan-contract/SKILL.md',
                    '.claude/skills/evidence-and-timestamp-conventions/SKILL.md',
                    '.github/instructions/**',
                    'artifacts/**',
                    'quality-tiers.yml'
                )
                modules               = @{ config = @('config/**') }
                over_breadth_fraction = 0.25
            }
        }

        It 'does not mutate its input' {
            # Arrange: a recorded radius carrying one entry of each rejected class.
            $radius = @{
                paths           = @('config/blast-radius.json', 'scripts/dev_tools', 'quality-tiers.yml')
                modules         = @('config')
                shared_surfaces = @('config/blast-radius.json', 'quality-tiers.yml')
                contracts       = @('Get-NormalizedDeclaredRadius', '->')
                source          = 'declared'
                computed_at     = '2026-08-18T10-00'
            }
            $before = ($radius['paths'] -join ',') + '|' + ($radius['contracts'] -join ',')

            # Act
            [void](Get-NormalizedDeclaredRadius -Radius $radius -Config $script:NormalizerConfig)

            # Assert: the supplied hashtable is unchanged.
            (($radius['paths'] -join ',') + '|' + ($radius['contracts'] -join ',')) |
                Should -Be $before
        }

        It 'drops every rejected entry class and re-resolves the levels' {
            # Arrange: directory tokens, corpus globs, mandate reads, notation.
            $radius = @{
                paths           = @(
                    '.claude/rules/**', 'artifacts/pr_context.summary.txt',
                    'config/blast-radius.json', 'docs/features/**/plan*.md',
                    'quality-tiers.yml', 'scripts/dev_tools'
                )
                modules         = @('config', 'python-dev-tools')
                shared_surfaces = @('config/blast-radius.json', 'quality-tiers.yml')
                contracts       = @('Get-NormalizedDeclaredRadius', '->', '{')
                source          = 'declared'
                computed_at     = '2026-08-18T10-00'
            }

            # Act
            $result = Get-NormalizedDeclaredRadius -Radius $radius -Config $script:NormalizerConfig

            # Assert
            $result['paths'] | Should -Be @('config/blast-radius.json')
            $result['modules'] | Should -Be @('config')
            $result['shared_surfaces'] | Should -Be @('config/blast-radius.json')
            $result['contracts'] | Should -Be @('Get-NormalizedDeclaredRadius')
            $result['source'] | Should -Be 'declared'
            $result['computed_at'] | Should -Be '2026-08-18T10-00'
        }

        It 'throws for a radius whose source is observed' {
            # Arrange: an observed radius records a diff listing, not a harvest.
            $radius = @{
                paths           = @('config/blast-radius.json')
                modules         = @('config')
                shared_surfaces = @('config/blast-radius.json')
                contracts       = @()
                source          = 'observed'
                computed_at     = '2026-08-18T10-00'
            }

            # Act / Assert
            { Get-NormalizedDeclaredRadius -Radius $radius -Config $script:NormalizerConfig } |
                Should -Throw '*observed*'
        }
    }
}

Describe 'Exported facade surface' {
    Context 'Spec PowerShell surface' {
        It 'exports <_>' -ForEach @(
            'Get-PlanPaths', 'Get-BlastRadius', 'Get-BlastRadiusFromObservedPaths',
            'Get-NormalizedDeclaredRadius', 'Test-BlastRadius', 'Test-BlastRadiusConflict'
        ) {
            # Arrange: the module's exported command table.
            $exported = (Get-Module BlastRadius).ExportedFunctions.Keys

            # Act / Assert: the six spec-fixed names are all exported.
            # Get-NormalizedDeclaredRadius joined the contract with issue #489.
            $exported | Should -Contain $_
        }

        It 'exports no function beyond the six spec-fixed names' {
            # Arrange: the module's exported command table.
            $exported = @((Get-Module BlastRadius).ExportedFunctions.Keys)

            # Assert: the facade surface is exactly the documented contract.
            $exported.Count | Should -Be 6
        }
    }
}
