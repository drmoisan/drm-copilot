<#
.SYNOPSIS
    Behavioral tests for the blast-radius read-by-mandate exclusion helpers.

.DESCRIPTION
    Mirrors the pytest coverage of matches_mandate_read and
    exclude_mandate_reads in
    scripts/dev_tools/_blast_radius_normalization.py. Each It targets a single
    behavior with Arrange-Act-Assert structure. Every configuration is an
    in-memory literal, no external process is started, and no temporary file is
    created.

    Get-ContractIdentifier and Resolve-BlastRadiusModule also live in
    BlastRadiusNormalization.psm1 after the issue #489 relocation, but their
    Describes stay in the two files that already covered them
    (BlastRadiusExtraction.Path.Tests.ps1 and BlastRadiusConfig.Tests.ps1)
    beside the sibling behaviors they belong with.

    The end-to-end exclusion Describe at the bottom of this file covers the same
    rule applied through the facade: Get-BlastRadius drops the citations during
    the harvest and Test-BlastRadius drops them from its plan-side extraction, so
    a derived radius still validates clean against its own plan. It lives here
    rather than in BlastRadius.Validation.Tests.ps1 because that file measured
    444 lines and could not take it inside the 500-line limit.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    # The facade is imported FIRST and deliberately so. Import-Module -Force
    # removes a module before re-importing it, and the facade force-imports the
    # normalization module, so the reverse order would strip Test-MandateRead and
    # Get-NonMandateReadEntry out of scope.
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    Import-Module $facadePath -Force

    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusNormalization.psm1").Path
    Import-Module $modulePath -Force

    # The ratified mandate-read membership, repeated here as a literal so a
    # change to the committed truth table cannot silently change what these
    # tests exercise.
    $script:MandateRead = @(
        '.claude/rules/**',
        '.claude/skills/atomic-plan-contract/SKILL.md',
        '.claude/skills/evidence-and-timestamp-conventions/SKILL.md',
        '.github/instructions/**',
        'artifacts/**',
        'quality-tiers.yml'
    )
}

Describe 'Test-MandateRead' {
    Context 'Exclusion rules' {
        It 'excludes a concrete path listed verbatim' {
            # Arrange / Act: exact ordinal equality settles a listed file.
            $excluded = Test-MandateRead -Entry 'quality-tiers.yml' -MandateRead $script:MandateRead

            # Assert
            $excluded | Should -BeTrue
        }

        It 'excludes a concrete path inside a configured subtree glob' {
            # Arrange / Act: artifacts/** covers the process-artifact tree.
            $excluded = Test-MandateRead `
                -Entry 'artifacts/pr_context.summary.txt' -MandateRead $script:MandateRead

            # Assert
            $excluded | Should -BeTrue
        }

        It 'excludes a glob entry equal to a configured pattern' {
            # Arrange / Act: exact equality is the only rule that settles a glob.
            $excluded = Test-MandateRead -Entry '.claude/rules/**' -MandateRead $script:MandateRead

            # Assert
            $excluded | Should -BeTrue
        }

        It 'retains a genuine write claim outside the configured patterns' {
            # Arrange / Act: an ordinary production file is not a mandate read.
            $excluded = Test-MandateRead `
                -Entry 'scripts/dev_tools/compute_blast_radius.py' -MandateRead $script:MandateRead

            # Assert
            $excluded | Should -BeFalse
        }

        It 'retains a glob that is not identical to any configured pattern' {
            # Arrange / Act: one glob is never tested for containment in another,
            # because guessing subsumption would silently drop a genuine claim.
            $excluded = Test-MandateRead `
                -Entry '.claude/rules/parallel-*.md' -MandateRead $script:MandateRead

            # Assert
            $excluded | Should -BeFalse
        }

        It 'retains every entry when the mandate-read list is empty' {
            # Arrange / Act: an absent configuration key excludes nothing.
            $excluded = Test-MandateRead -Entry 'quality-tiers.yml' -MandateRead @()

            # Assert
            $excluded | Should -BeFalse
        }
    }
}

Describe 'Get-NonMandateReadEntry' {
    Context 'Collection filtering' {
        It 'drops exact, subtree, and glob-equal citations together' {
            # Arrange: one entry of each excluded class plus one genuine claim.
            $entries = @(
                '.claude/rules/**',
                'artifacts/pr_context.summary.txt',
                'config/blast-radius.json',
                'quality-tiers.yml'
            )

            # Act
            $survivors = @(Get-NonMandateReadEntry -Entry $entries -MandateRead $script:MandateRead)

            # Assert
            $survivors | Should -Be @('config/blast-radius.json')
        }

        It 'passes content through unchanged when the list is empty' {
            # Arrange: entries that would all be excluded under the real list.
            $entries = @('quality-tiers.yml', 'config/blast-radius.json', 'artifacts/report.md')

            # Act
            $survivors = @(Get-NonMandateReadEntry -Entry $entries -MandateRead @())

            # Assert: the same content, ordinally sorted.
            $survivors | Should -Be @(
                'artifacts/report.md', 'config/blast-radius.json', 'quality-tiers.yml')
        }

        It 'accepts an empty entry collection' {
            # Arrange / Act: an empty radius filters to an empty radius.
            $survivors = @(Get-NonMandateReadEntry -Entry @() -MandateRead $script:MandateRead)

            # Assert
            $survivors.Count | Should -Be 0
        }
    }
}

Describe 'Read-by-mandate exclusion through the facade (issue #489)' {
    BeforeAll {
        # A truth table carrying the exclusion list, kept as a literal so a
        # change to config/blast-radius.json cannot change what is exercised.
        $script:MandateConfig = @{
            version               = 1
            shared_surfaces       = @('quality-tiers.yml')
            shared_surface_globs  = @()
            mandate_reads         = @('.claude/rules/**', 'artifacts/**', 'quality-tiers.yml')
            modules               = @{ 'alpha' = @('scripts/**') }
            over_breadth_fraction = 0.25
        }

        # A plan whose only citations outside its own feature folder are mandate
        # reads plus one genuine write claim.
        $script:MandatePlan = @(
            '### Phase 0 - Policy Reads',
            '- [ ] [P0-T1] Read `.claude/rules/python.md` and `quality-tiers.yml`.',
            '- [ ] [P0-T2] Record evidence at `artifacts/pr_context.summary.txt`.',
            '### Phase 1 - Implementation',
            '- [ ] [P1-T1] Edit `scripts/dev_tools/compute_blast_radius.py`.'
        ) -join "`n"

        function Get-MandateRadius {
            param([hashtable] $Config)
            return Get-BlastRadius -PlanText $script:MandatePlan -SpecText '' `
                -FeatureFolder '2026-08-18-mandate-489' -Config $Config `
                -ComputedAt '2026-08-18T10-00'
        }
    }

    Context 'Derivation harvest' {
        It 'excludes mandate-read citations from every level' {
            # Act
            $radius = Get-MandateRadius -Config $script:MandateConfig

            # Assert: the policy rule, the tier map, and the process artifact are
            # all absent, while the genuine write claim survives.
            $radius['paths'] | Should -Not -Contain '.claude/rules/python.md'
            $radius['paths'] | Should -Not -Contain 'quality-tiers.yml'
            $radius['paths'] | Should -Not -Contain 'artifacts/pr_context.summary.txt'
            $radius['paths'] | Should -Contain 'scripts/dev_tools/compute_blast_radius.py'
            $radius['shared_surfaces'] | Should -Not -Contain 'quality-tiers.yml'
        }

        It 'includes the citations when the mandate_reads key is absent' {
            # Arrange: the same table with only the new key removed.
            $config = $script:MandateConfig.Clone()
            $config.Remove('mandate_reads')

            # Act
            $radius = Get-MandateRadius -Config $config

            # Assert: an absent key excludes nothing (fail-closed default).
            $radius['paths'] | Should -Contain '.claude/rules/python.md'
            $radius['paths'] | Should -Contain 'quality-tiers.yml'
            $radius['shared_surfaces'] | Should -Contain 'quality-tiers.yml'
        }
    }

    Context 'Symmetric exclusion' {
        It 'validates a derived radius clean against its own mandate-citing plan' {
            # Arrange
            $radius = Get-MandateRadius -Config $script:MandateConfig

            # Act
            $findings = @(Test-BlastRadius -Radius $radius -PlanText $script:MandatePlan `
                    -Config $script:MandateConfig -TrackedFileCount 5000)

            # Assert: without the matching filter in Test-BlastRadius every plan
            # citing a policy file would produce V1 Blocking findings against its
            # own derived radius.
            $findings.Count | Should -Be 0
        }
    }
}

Describe 'Get-NormalizedDeclaredRadius placeholder stripping (issue #502)' {
    BeforeAll {
        # A minimal truth table sufficient for the normalizer: one module keyed on
        # the configuration tree, one shared surface inside it, and no mandate
        # reads, so the only rule that can drop an entry is the shape guard under
        # test. Every literal is single-quoted, per the constraint recorded in
        # tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1.
        $script:ShapeConfig = @{
            version               = 1
            shared_surfaces       = @('config/blast-radius.json')
            shared_surface_globs  = @()
            modules               = @{ 'config' = @('config/**') }
            over_breadth_fraction = 0.25
        }
        $script:ShapeComputedAt = '2026-08-22T10-00'
    }

    Context 'Retrospective cleaning of an already-recorded radius' {
        It 'strips placeholder entries and preserves the real entries' {
            # Arrange: a recorded radius carrying one placeholder entry shaped
            # like a feature document and one shaped like an interpolated
            # configuration file, plus two real entries that must survive. The
            # interpolation form is single-quoted so the classifier receives the
            # marker rather than an expansion.
            $recorded = @{
                paths           = @(
                    '<FEATURE>/spec.md',
                    'config/blast-radius.json',
                    'config/${environment}.json',
                    'scripts/dev_tools/compute_blast_radius.py'
                )
                modules         = @('config')
                shared_surfaces = @('config/blast-radius.json')
                contracts       = @('Get-NormalizedDeclaredRadius')
                source          = 'declared'
                computed_at     = $script:ShapeComputedAt
            }
            # Assert the probe literals before normalization, so an expansion
            # cannot make this case measure a different radius than it states.
            $recorded['paths'][0] | Should -Be ('<' + 'FEATURE' + '>' + '/spec.md')
            $recorded['paths'][2].Length | Should -Be 26

            # Act
            $result = Get-NormalizedDeclaredRadius -Radius $recorded -Config $script:ShapeConfig

            # Assert: both placeholder entries are gone and both real entries
            # survive. All three dependent levels are asserted, not just paths,
            # because the module and shared-surface levels are re-resolved from
            # the surviving paths; a normalizer that dropped the entry from paths
            # while leaving a stale module behind would still make two unrelated
            # items contend one level up.
            $result['paths'] | Should -Not -Contain '<FEATURE>/spec.md'
            $result['paths'] | Should -Not -Contain 'config/${environment}.json'
            $result['paths'] | Should -Contain 'config/blast-radius.json'
            $result['paths'] | Should -Contain 'scripts/dev_tools/compute_blast_radius.py'
            $result['modules'] | Should -Be @('config')
            $result['shared_surfaces'] | Should -Be @('config/blast-radius.json')
            $result['contracts'] | Should -Be @('Get-NormalizedDeclaredRadius')
            $result['source'] | Should -Be 'declared'
            $result['computed_at'] | Should -Be $script:ShapeComputedAt
        }

        It 'clears a level that only a placeholder entry supplied' {
            # Arrange: the companion above keeps the config module because a real
            # entry also resolves to it, which cannot distinguish re-resolution
            # from passthrough. Here the only entry reaching the module and
            # shared-surface levels is the placeholder, so both levels must come
            # back empty.
            $recorded = @{
                paths           = @(
                    'config/${environment}.json',
                    'scripts/dev_tools/compute_blast_radius.py'
                )
                modules         = @('config')
                shared_surfaces = @('config/blast-radius.json')
                contracts       = @('Get-NormalizedDeclaredRadius')
                source          = 'declared'
                computed_at     = $script:ShapeComputedAt
            }
            $recorded['paths'][0].Length | Should -Be 26

            # Act
            $result = Get-NormalizedDeclaredRadius -Radius $recorded -Config $script:ShapeConfig

            # Assert
            $result['paths'] | Should -Be @('scripts/dev_tools/compute_blast_radius.py')
            @($result['modules']).Count | Should -Be 0
            @($result['shared_surfaces']).Count | Should -Be 0
        }
    }
}
