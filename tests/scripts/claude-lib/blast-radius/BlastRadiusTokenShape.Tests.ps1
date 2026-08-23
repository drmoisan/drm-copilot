<#
.SYNOPSIS
    Behavioral tests for the blast-radius token-shape predicates (issue #502).

.DESCRIPTION
    Mirrors the pytest suites
    tests/scripts/dev_tools/test_blast_radius_token_shapes.py and the marker half
    of tests/scripts/dev_tools/test_blast_radius_extraction_rules.py. Covers, for
    each of the five placeholder and interpolation markers, BOTH halves of the
    paired assertion: that Test-PlaceholderMarker reports the token as
    marker-bearing, and that Get-PathTokenKind returns no classification for it.
    Also covers the filename-position case, the marker-free real-path
    discrimination control, the three degenerate inputs that must not throw, the
    relocated Test-MultipleFeatureFolderSpan cases, and a module-export
    assertion for the re-exported span function. Each It targets a single
    behavior with Arrange-Act-Assert structure. The tests invoke no external
    process and create no temporary files.

    SINGLE-QUOTE CONSTRAINT. Every probe string in this file is single-quoted
    or built by character concatenation, and every marker case asserts its
    probe's literal content BEFORE classifying it. A double-quoted PowerShell
    string expands the subexpression form and the delimited-variable form before
    the classifier ever sees them, so a double-quoted probe silently classifies a
    DIFFERENT token than the one written. That substitution is invisible in the
    test output: the case still reports a classification, just for text the
    author never intended, which reproduces the original mis-measurement of this
    defect while appearing to measure it. The content assertion is what makes
    the substitution detectable rather than merely unlikely. This file contains
    no double-quoted string at all, so the constraint is checkable by a plain
    search rather than by reading each occurrence to decide whether it is a
    probe.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius. Resolve-Path
    # normalizes the separators so Pester's code-coverage breakpoints bind to the
    # same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path

    # BlastRadiusExtraction.psm1 is the only import. Both predicates under test
    # are reachable through it: Test-MultipleFeatureFolderSpan and
    # Test-PlaceholderMarker are re-exported from the leaf module it imports,
    # which is the behavior the module-export assertion below pins.
    $script:ExtractionPath = (Resolve-Path (Join-Path $script:RepoRoot '.claude/lib/blast-radius/BlastRadiusExtraction.psm1')).Path
    Import-Module $script:ExtractionPath -Force
}

Describe 'Placeholder-marker token-shape rejection (issue #502)' {
    Context 'Paired predicate and classifier assertions, one case per marker' {
        # Each row carries the probe, the single marker it is meant to contain,
        # and the probe's exact character length. The two dollar markers are
        # assembled from single characters so no interpolation form appears as a
        # parseable sequence anywhere in this file.
        It 'reports and rejects the marker case <Name>' -ForEach @(
            @{ Name = 'angle-open'; Probe = 'docs/features/active/<feature/plan.md'; Marker = '<'; Length = 37 }
            @{ Name = 'angle-close'; Probe = 'docs/features/active/feature>/plan.md'; Marker = '>'; Length = 37 }
            @{ Name = 'dollar-brace'; Probe = '.claude/state/${session_id}.json'; Marker = '$' + '{'; Length = 32 }
            @{ Name = 'dollar-paren'; Probe = '.claude/state/$(session).json'; Marker = '$' + '('; Length = 29 }
            @{ Name = 'percent'; Probe = '.claude/state/%SESSION%.json'; Marker = '%'; Length = 28 }
        ) {
            # Arrange: assert the probe's literal content before either predicate
            # runs. The ordinal IndexOf proves the intended marker survived, and
            # the exact length proves nothing else was consumed. Without both,
            # an expanded probe would still produce a classification and the case
            # would report a result for text the author never wrote.
            $Probe.IndexOf($Marker, [System.StringComparison]::Ordinal) |
                Should -BeGreaterOrEqual 0
            $Probe.Length | Should -Be $Length

            # Act: run both halves of the pair on the same probe.
            $isMarkerBearing = Test-PlaceholderMarker -Token $Probe
            $kind = Get-PathTokenKind -Token $Probe

            # Assert: the predicate must recognize the shape, and the classifier
            # must decline to record it as a path. Asserting only the classifier
            # would leave the predicate untested; asserting only the predicate
            # would leave the guard unwired.
            $isMarkerBearing | Should -BeTrue
            $kind | Should -BeNullOrEmpty
        }
    }

    Context 'Marker position and discrimination' {
        It 'reads a marker in the filename position' {
            # Arrange: the marker sits inside the final component rather than in
            # a leading segment. An interpolated filename is exactly as
            # unresolvable as an interpolated directory, so scoping the scan to
            # leading segments would admit the shape the guard exists to reject.
            $token = '.claude/state/powershell-batch-budget.<session_id>.json'
            $token.IndexOf('<', [System.StringComparison]::Ordinal) |
                Should -BeGreaterOrEqual 0

            # Act
            $isMarkerBearing = Test-PlaceholderMarker -Token $token
            $kind = Get-PathTokenKind -Token $token

            # Assert
            $isMarkerBearing | Should -BeTrue
            $kind | Should -BeNullOrEmpty
        }

        It 'does not report a marker-free real repository path' {
            # Arrange: the discrimination control. A predicate that reported
            # every token as marker-bearing would satisfy every rejection case
            # above while dropping the entire harvest, so this case is what
            # shows the rejection is selective.
            $token = 'scripts/dev_tools/compute_blast_radius.py'

            # Act
            $isMarkerBearing = Test-PlaceholderMarker -Token $token
            $kind = Get-PathTokenKind -Token $token

            # Assert
            $isMarkerBearing | Should -BeFalse
            $kind | Should -Be 'concrete'
        }
    }

    Context 'Degenerate tokens must not throw' {
        # The predicate runs inside a classifier that is called on every
        # inline-code span in a document, so it must be total. A throw on a
        # degenerate token would abort an entire derivation over one stray span.
        It 'returns a verdict without throwing for the degenerate token <Name>' -ForEach @(
            @{ Name = 'empty-string'; Probe = ''; Expected = $false }
            @{ Name = 'marker-only'; Probe = '<'; Expected = $true }
            @{ Name = 'bare-bracket-pair'; Probe = '<>'; Expected = $true }
        ) {
            # Arrange / Act
            $observed = Test-PlaceholderMarker -Token $Probe

            # Assert
            $observed | Should -Be $Expected
        }
    }
}

Describe 'Test-MultipleFeatureFolderSpan after relocation (issue #489 behavior preserved)' {
    Context 'Cross-corpus documentation globs' {
        It 'reports the cross-corpus glob <_>' -ForEach @(
            'docs/features/**/plan*.md',
            'docs/features/active/*/plan.md',
            'docs/features/**'
        ) {
            # Arrange: a documentation glob whose wildcard occupies or truncates
            # the feature-folder segment.
            $token = $_

            # Act
            $spans = Test-MultipleFeatureFolderSpan -Token $token

            # Assert
            $spans | Should -BeTrue
        }

        It 'retains a glob naming one complete feature folder' {
            # Arrange: every segment up to and including the feature-folder name
            # is a literal, so the claim resolves to exactly one folder.
            $token = 'docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/**'

            # Act
            $spans = Test-MultipleFeatureFolderSpan -Token $token

            # Assert
            $spans | Should -BeFalse
        }

        It 'ignores a token rooted outside the documentation corpus' {
            # Arrange: the span rule is scoped to the documentation corpus and
            # nothing else.
            $token = 'scripts/dev_tools/**'

            # Act
            $spans = Test-MultipleFeatureFolderSpan -Token $token

            # Assert
            $spans | Should -BeFalse
        }
    }

    Context 'Module export surface after relocation' {
        It 'still resolves the relocated span function from the extraction module' {
            # Arrange: the relocation moved Test-MultipleFeatureFolderSpan into
            # the leaf module, and the extraction module re-imports and
            # re-exports it. Every pre-existing call site and test resolves the
            # function through the extraction module, so source compatibility
            # depends on that re-export surviving. Reading the exported-function
            # set is what makes the compatibility claim observable rather than
            # inferred from the fact that a call happened to work.
            $exported = (Get-Module BlastRadiusExtraction).ExportedFunctions.Keys

            # Act / Assert
            $exported | Should -Contain 'Test-MultipleFeatureFolderSpan'
            $exported | Should -Contain 'Test-PlaceholderMarker'
        }
    }
}
