<#
.SYNOPSIS
    Behavioral tests for blast-radius path-token and contract extraction.

.DESCRIPTION
    Mirrors the classification half of the pytest suite in
    tests/scripts/dev_tools/test_blast_radius_extraction.py: path-token
    acceptance by known top-level segment and by the extension fallback rule,
    glob classification, the rejected-token cases, whole-plan aggregation, and
    contract-identifier extraction from spec interface sections. Each It targets
    a single behavior with Arrange-Act-Assert structure. The tests invoke no
    external process and create no temporary files.

    This file is the authorized sibling of BlastRadiusExtraction.Tests.ps1 under
    the 500-line file limit; both cover task P4-T5 of the issue #447 plan.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusExtraction.psm1").Path
    Import-Module $modulePath -Force
}

Describe 'Get-PathTokenKind' {
    Context 'Known top-level segments' {
        It 'accepts a token under the known segment <_>' -ForEach @(
            'scripts/', 'tests/', 'docs/', 'config/', 'schemas/', 'packages/',
            'extensions/', '.claude/', '.codex/', '.github/', '.agents/', 'artifacts/'
        ) {
            # Arrange: a directory-shaped token under the segment, with no
            # extension so only the known-segment rule can accept it.
            $token = "${_}thing"

            # Act: classify the token.
            $kind = Get-PathTokenKind -Token $token

            # Assert: a known segment is accepted without a recognized extension.
            $kind | Should -Be 'concrete'
        }
    }

    Context 'Extension fallback rule' {
        It 'accepts a token outside the known segments when its extension is recognized' {
            # Arrange: a path whose leading segment is not a known top-level folder.
            $token = 'src/app/main.ts'

            # Act: classify the token.
            $kind = Get-PathTokenKind -Token $token

            # Assert: the extension rule admits it.
            $kind | Should -Be 'concrete'
        }

        It 'rejects a token outside the known segments with an unrecognized extension' {
            # Arrange: a path-shaped token with an unknown extension.
            $token = 'weird/thing.unknownext'

            # Act: classify the token.
            $kind = Get-PathTokenKind -Token $token

            # Assert: failing both shape rules drops the token.
            $kind | Should -BeNullOrEmpty
        }

        It 'matches a recognized extension case insensitively' {
            # Arrange: an upper-case extension.
            $token = 'src/app/Main.TS'

            # Act: classify the token.
            $kind = Get-PathTokenKind -Token $token

            # Assert: the extension is lower-cased before lookup.
            $kind | Should -Be 'concrete'
        }
    }

    Context 'Glob classification' {
        It 'records a wildcard token as a glob' {
            # Arrange: a recursive glob under a known segment.
            $token = 'docs/features/**'

            # Act: classify the token.
            $kind = Get-PathTokenKind -Token $token

            # Assert: a wildcard token cannot take part in equality checks.
            $kind | Should -Be 'glob'
        }

        It 'records a single-star glob outside the known segments as a glob' {
            # Arrange: a wildcard token accepted by the extension rule.
            $token = 'src/*.ts'

            # Act: classify the token.
            $kind = Get-PathTokenKind -Token $token

            # Assert: acceptance and glob classification are independent rules.
            $kind | Should -Be 'glob'
        }
    }

    Context 'Rejected tokens' {
        It 'rejects a token with no separator' {
            # Arrange / Act: a bare identifier, which is a contract name.
            $kind = Get-PathTokenKind -Token 'derive_blast_radius'

            # Assert: a path reference must name a separator.
            $kind | Should -BeNullOrEmpty
        }

        It 'rejects an absolute path' {
            # Arrange / Act: a leading separator marks an absolute path.
            $kind = Get-PathTokenKind -Token '/etc/hosts.txt'

            # Assert: radius entries must be repository relative.
            $kind | Should -BeNullOrEmpty
        }

        It 'rejects a URL because its leading segment carries a scheme colon' {
            # Arrange / Act: a URL contains separators but is not a repo path.
            $kind = Get-PathTokenKind -Token 'https://example.com/docs/x.md'

            # Assert: a colon in the leading segment disqualifies the token.
            $kind | Should -BeNullOrEmpty
        }

        It 'rejects a Windows drive path because its leading segment carries a colon' {
            # Arrange / Act: a drive-qualified path.
            $kind = Get-PathTokenKind -Token 'C:/repo/docs/x.md'

            # Assert: the same colon rule covers drive letters.
            $kind | Should -BeNullOrEmpty
        }
    }
}

Describe 'Get-PathFromLine and Get-PlanPaths' {
    Context 'Aggregation across lines' {
        It 'returns accepted tokens deduplicated and ordinally sorted' {
            # Arrange: two lines citing overlapping paths out of order.
            $lines = @('`tests/b.py` `scripts/a.py`', '`scripts/a.py`')

            # Act: collect the accepted tokens.
            $paths = @(Get-PathFromLine -Line $lines)

            # Assert: the duplicate collapses and the order is ordinal.
            $paths | Should -Be @('scripts/a.py', 'tests/b.py')
        }

        It 'returns nothing when no line cites a path' {
            # Arrange: prose-only lines.
            $lines = @('nothing here', 'nor `here`')

            # Act: collect the accepted tokens.
            $paths = @(Get-PathFromLine -Line $lines)

            # Assert: a non-path inline token is not a path reference.
            $paths.Count | Should -Be 0
        }
    }

    Context 'Whole-plan extraction' {
        It 'collects paths from task bodies, phase headings, and prose alike' {
            # Arrange: a plan citing one path in each of the three line categories.
            $plan = "### Phase 1 — Touch ``config/a.json```n" +
            "- [ ] [P1-T1] Touch ``scripts/b.py``.`n" +
            'Guardrail: do not touch `docs/c.md`.'

            # Act: extract the plan paths.
            $paths = @(Get-PlanPaths -PlanText $plan)

            # Assert: all three citations are collected in ordinal order.
            $paths | Should -Be @('config/a.json', 'docs/c.md', 'scripts/b.py')
        }

        It 'returns nothing for an empty plan' {
            # Arrange / Act: an empty plan document.
            $paths = @(Get-PlanPaths -PlanText '')

            # Assert: a plan with no citations yields no paths.
            $paths.Count | Should -Be 0
        }
    }
}

Describe 'Get-ContractIdentifier' {
    Context 'Qualifying sections' {
        It 'collects identifiers from a section whose heading names <_>' -ForEach @(
            'API', 'Interface', 'Contract', 'Surface'
        ) {
            # Arrange: a spec section qualified by the given keyword.
            $spec = "## Public $_ Section`n`n``SymbolOne`` and ``SymbolTwo``."

            # Act: extract the contract identifiers.
            $identifiers = @(Get-ContractIdentifier -SpecText $spec)

            # Assert: both identifiers are collected in ordinal order.
            $identifiers | Should -Be @('SymbolOne', 'SymbolTwo')
        }

        It 'inherits qualification into a nested deeper heading' {
            # Arrange: a nested subsection under a qualifying section.
            $spec = "## Public API`n`n### Detail`n`n``NestedSymbol``"

            # Act: extract the contract identifiers.
            $identifiers = @(Get-ContractIdentifier -SpecText $spec)

            # Assert: markdown sections nest, so the subsection stays qualified.
            $identifiers | Should -Be @('NestedSymbol')
        }

        It 'ends the section at a heading of the same level' {
            # Arrange: a non-qualifying sibling section following a qualifying one.
            $spec = "## Public API`n`n``Inside```n`n## Rationale`n`n``Outside``"

            # Act: extract the contract identifiers.
            $identifiers = @(Get-ContractIdentifier -SpecText $spec)

            # Assert: only the qualifying section contributes.
            $identifiers | Should -Be @('Inside')
        }
    }

    Context 'Exclusions' {
        It 'excludes a path-like token from a qualifying section' {
            # Arrange: a qualifying section citing both a symbol and a path.
            $spec = "## Contract`n`n``SymbolOne`` and ``scripts/dev_tools/x.py``"

            # Act: extract the contract identifiers.
            $identifiers = @(Get-ContractIdentifier -SpecText $spec)

            # Assert: a token with a separator is recorded at the paths level.
            $identifiers | Should -Be @('SymbolOne')
        }

        It 'returns nothing when no heading qualifies' {
            # Arrange: a spec with only non-qualifying headings.
            $spec = "## Rationale`n`n``SymbolOne``"

            # Act: extract the contract identifiers.
            $identifiers = @(Get-ContractIdentifier -SpecText $spec)

            # Assert: identifiers outside a qualifying section are ignored.
            $identifiers.Count | Should -Be 0
        }

        It 'returns nothing for an empty spec' {
            # Arrange / Act: an empty spec document.
            $identifiers = @(Get-ContractIdentifier -SpecText '')

            # Assert: no text means no identifiers.
            $identifiers.Count | Should -Be 0
        }
    }
}

Describe 'Get-OrdinalSortedEntry' {
    Context 'Normalization' {
        It 'sorts entries by ordinal code point rather than culture' {
            # Arrange: entries whose ordinal and culture orders differ, because
            # ordinal places every upper-case letter before every lower-case one.
            $entry = @('b', 'A', 'a', 'B')

            # Act: normalize the collection.
            $sorted = @(Get-OrdinalSortedEntry -Entry $entry)

            # Assert: the result matches Python's sorted() over the same set.
            $sorted | Should -Be @('A', 'B', 'a', 'b')
        }

        It 'removes duplicate entries' {
            # Arrange: a collection with a repeated entry.
            $entry = @('x', 'x', 'y')

            # Act: normalize the collection.
            $sorted = @(Get-OrdinalSortedEntry -Entry $entry)

            # Assert: deduplication mirrors the Python set() step.
            $sorted | Should -Be @('x', 'y')
        }

        It 'accepts an empty collection' {
            # Arrange / Act: normalize nothing.
            $sorted = @(Get-OrdinalSortedEntry -Entry @())

            # Assert: an empty input yields an empty result.
            $sorted.Count | Should -Be 0
        }
    }
}
