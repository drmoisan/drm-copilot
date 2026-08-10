<#
.SYNOPSIS
    Behavioral tests for the blast-radius glob and overlap primitives.

.DESCRIPTION
    Mirrors the pytest coverage of _glob_to_regex_text, matches_glob,
    is_path_subsumed, is_glob_entry, concrete_entries, _literal_prefix, and
    _entries_overlap. Each It targets a single behavior with Arrange-Act-Assert
    structure. The tests invoke no external process and create no temporary
    files.

    This file is an authorized sibling of BlastRadius.Tests.ps1 under the
    500-line file limit; it covers the pattern-comparison half of task P4-T5.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusGlob.psm1").Path
    Import-Module $modulePath -Force
}

Describe 'Test-GlobEntry' {
    Context 'Wildcard detection' {
        It 'reports true for an entry carrying <_>' -ForEach @('*', '?') {
            # Arrange: an entry carrying the given wildcard character.
            $entry = "scripts/a${_}b.py"

            # Act: classify the entry.
            $isGlob = Test-GlobEntry -Entry $entry

            # Assert: both wildcard characters make an entry a pattern.
            $isGlob | Should -BeTrue
        }

        It 'reports false for a wildcard-free entry' {
            # Arrange: a concrete path.
            $entry = 'scripts/dev_tools/a.py'

            # Act: classify the entry.
            $isGlob = Test-GlobEntry -Entry $entry

            # Assert: a concrete path is not a pattern.
            $isGlob | Should -BeFalse
        }

        It 'reports false for an empty entry' {
            # Arrange / Act: the degenerate empty entry.
            $isGlob = Test-GlobEntry -Entry ''

            # Assert: an empty entry carries no wildcard.
            $isGlob | Should -BeFalse
        }
    }
}

Describe 'Get-ConcreteEntry' {
    Context 'Filtering' {
        It 'keeps only the wildcard-free entries and preserves their order' {
            # Arrange: a mixed collection already in ordinal order.
            $entry = @('a/1.py', 'b/**', 'c/2.py', 'd/*.md')

            # Act: select the concrete entries.
            $concrete = @(Get-ConcreteEntry -Entry $entry)

            # Assert: only equality-comparable entries survive, in input order.
            $concrete | Should -Be @('a/1.py', 'c/2.py')
        }

        It 'returns nothing when every entry is a glob' {
            # Arrange: an all-glob collection.
            $entry = @('a/**', 'b/*.py')

            # Act: select the concrete entries.
            $concrete = @(Get-ConcreteEntry -Entry $entry)

            # Assert: a radius of pure globs has no concrete coverage.
            $concrete.Count | Should -Be 0
        }

        It 'accepts an empty collection' {
            # Arrange / Act: filter nothing.
            $concrete = @(Get-ConcreteEntry -Entry @())

            # Assert: an empty input yields an empty result.
            $concrete.Count | Should -Be 0
        }
    }
}

Describe 'Test-GlobMatch' {
    Context 'The supported fnmatch subset' {
        It 'matches a recursive ** across directory separators' {
            # Arrange: a recursive glob and a deeply nested candidate.
            $pattern = 'scripts/**'

            # Act: test the candidate.
            $matched = Test-GlobMatch -Pattern $pattern -Candidate 'scripts/dev_tools/a.py'

            # Assert: only ** may cross a separator.
            $matched | Should -BeTrue
        }

        It 'stops a single * at a directory separator' {
            # Arrange: a single-star glob and a nested candidate.
            $pattern = 'scripts/*'

            # Act: test the candidate.
            $matched = Test-GlobMatch -Pattern $pattern -Candidate 'scripts/dev_tools/a.py'

            # Assert: a single star matches within one path component only.
            $matched | Should -BeFalse
        }

        It 'matches a single * within one path component' {
            # Arrange: a single-star glob and a same-level candidate.
            $pattern = 'scripts/dev_tools/validate_*.py'

            # Act: test the candidate.
            $matched = Test-GlobMatch -Pattern $pattern `
                -Candidate 'scripts/dev_tools/validate_orchestration_artifacts.py'

            # Assert: the shared-surface globs rely on this behavior.
            $matched | Should -BeTrue
        }

        It 'matches exactly one non-separator character for ?' {
            # Arrange: a single-character wildcard.
            $pattern = 'a/?.py'

            # Act / Assert: one character matches and two do not.
            (Test-GlobMatch -Pattern $pattern -Candidate 'a/x.py') | Should -BeTrue
            (Test-GlobMatch -Pattern $pattern -Candidate 'a/xy.py') | Should -BeFalse
        }

        It 'treats a bracket as a literal rather than a character class' {
            # Arrange: a pattern containing brackets, which fnmatch would read as
            # a class but this deliberate subset reads literally.
            $pattern = 'a/[ab].py'

            # Act / Assert: only the literal bracket text matches.
            (Test-GlobMatch -Pattern $pattern -Candidate 'a/[ab].py') | Should -BeTrue
            (Test-GlobMatch -Pattern $pattern -Candidate 'a/a.py') | Should -BeFalse
        }

        It 'treats a dot as a literal rather than a regex wildcard' {
            # Arrange: a pattern whose dot must not match an arbitrary character.
            $pattern = 'a/b.py'

            # Act: test a candidate differing only in that position.
            $matched = Test-GlobMatch -Pattern $pattern -Candidate 'a/bxpy'

            # Assert: every non-wildcard character is escaped to a literal.
            $matched | Should -BeFalse
        }

        It 'requires the whole candidate to match the whole pattern' {
            # Arrange: a pattern that is a strict prefix of the candidate.
            $pattern = 'scripts/a'

            # Act: test the longer candidate.
            $matched = Test-GlobMatch -Pattern $pattern -Candidate 'scripts/abc'

            # Assert: matching is anchored at both ends, like re.fullmatch.
            $matched | Should -BeFalse
        }

        It 'matches an exact wildcard-free pattern' {
            # Arrange: a pattern with no wildcard at all.
            $pattern = 'config/blast-radius.json'

            # Act: test the identical candidate.
            $matched = Test-GlobMatch -Pattern $pattern -Candidate 'config/blast-radius.json'

            # Assert: a literal pattern behaves as an equality test.
            $matched | Should -BeTrue
        }
    }
}

Describe 'Test-PathSubsumed' {
    Context 'The three coverage rules' {
        It 'covers a path by an exact entry' {
            # Arrange: a covering collection naming the path exactly.
            $covering = @('scripts/dev_tools/a.py')

            # Act: test coverage.
            $subsumed = Test-PathSubsumed -Path 'scripts/dev_tools/a.py' -CoveringPath $covering

            # Assert: exact match is the first coverage rule.
            $subsumed | Should -BeTrue
        }

        It 'covers a path by a listed directory prefix' {
            # Arrange: a wildcard-free directory entry.
            $covering = @('scripts/dev_tools')

            # Act: test coverage of a file beneath it.
            $subsumed = Test-PathSubsumed -Path 'scripts/dev_tools/a.py' -CoveringPath $covering

            # Assert: a wildcard-free entry covers everything beneath it.
            $subsumed | Should -BeTrue
        }

        It 'covers a path by a listed directory prefix written with a trailing slash' {
            # Arrange: the same directory entry with a trailing separator.
            $covering = @('scripts/dev_tools/')

            # Act: test coverage of a file beneath it.
            $subsumed = Test-PathSubsumed -Path 'scripts/dev_tools/a.py' -CoveringPath $covering

            # Assert: trailing separators are trimmed before the prefix test.
            $subsumed | Should -BeTrue
        }

        It 'covers a path by a glob entry' {
            # Arrange: a recursive glob entry.
            $covering = @('scripts/**')

            # Act: test coverage.
            $subsumed = Test-PathSubsumed -Path 'scripts/dev_tools/a.py' -CoveringPath $covering

            # Assert: glob match is the third coverage rule.
            $subsumed | Should -BeTrue
        }

        It 'does not cover a path by a directory-name prefix that is not a full component' {
            # Arrange: an entry that is a string prefix but not a path component.
            $covering = @('scripts/dev')

            # Act: test coverage.
            $subsumed = Test-PathSubsumed -Path 'scripts/dev_tools/a.py' -CoveringPath $covering

            # Assert: the separator is appended before the prefix test, so a
            # partial component name never covers.
            $subsumed | Should -BeFalse
        }

        It 'does not cover an unrelated path' {
            # Arrange: a covering collection naming a different tree.
            $covering = @('tests/**', 'docs/a.md')

            # Act: test coverage.
            $subsumed = Test-PathSubsumed -Path 'scripts/a.py' -CoveringPath $covering

            # Assert: none of the three rules applies.
            $subsumed | Should -BeFalse
        }

        It 'covers nothing when the collection is empty' {
            # Arrange / Act: an empty covering collection.
            $subsumed = Test-PathSubsumed -Path 'scripts/a.py' -CoveringPath @()

            # Assert: an empty radius subsumes no plan path.
            $subsumed | Should -BeFalse
        }
    }
}

Describe 'Get-LiteralPrefix' {
    Context 'Prefix extraction' {
        It 'returns the text before the first wildcard' {
            # Arrange: a glob whose wildcard appears mid-string.
            $entry = 'scripts/dev_tools/validate_*.py'

            # Act: read the literal prefix.
            $prefix = Get-LiteralPrefix -Entry $entry

            # Assert: the prefix stops at the earliest wildcard.
            $prefix | Should -Be 'scripts/dev_tools/validate_'
        }

        It 'stops at a question mark when it precedes an asterisk' {
            # Arrange: a glob whose earliest wildcard is a question mark.
            $entry = 'a/?b/*.py'

            # Act: read the literal prefix.
            $prefix = Get-LiteralPrefix -Entry $entry

            # Assert: the earliest wildcard of any kind terminates the prefix.
            $prefix | Should -Be 'a/'
        }

        It 'returns the whole entry when it carries no wildcard' {
            # Arrange: a concrete entry, the defensive fallback branch that the
            # overlap relation itself never reaches.
            $entry = 'scripts/dev_tools/a.py'

            # Act: read the literal prefix.
            $prefix = Get-LiteralPrefix -Entry $entry

            # Assert: a wildcard-free entry is entirely literal.
            $prefix | Should -Be 'scripts/dev_tools/a.py'
        }
    }
}

Describe 'Test-EntryOverlap' {
    Context 'Concrete against concrete' {
        It 'reports overlap only for equal entries' {
            # Arrange / Act / Assert: equality is the only concrete-pair rule.
            (Test-EntryOverlap -EntryA 'a/1.py' -EntryB 'a/1.py') | Should -BeTrue
            (Test-EntryOverlap -EntryA 'a/1.py' -EntryB 'a/2.py') | Should -BeFalse
        }

        It 'treats a directory entry as overlapping a file beneath it' {
            # Arrange / Act: two wildcard-free entries in a prefix relationship.
            $overlap = Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/a.py'

            # Assert: issue #452 amends this behaviour. The contention relation now
            # honours the same anchored listed-directory rule that Test-PathSubsumed
            # already applied, so a plan citing a directory contends with a plan
            # citing a file inside it. The prior assertion of disjointness encoded
            # the Gap 2 defect as intended behaviour; it is one of the two
            # authorized assertion inversions.
            $overlap | Should -BeTrue
        }
    }

    Context 'Glob against concrete' {
        It 'reports overlap when the glob matches the concrete entry' {
            # Arrange / Act: a recursive glob over a nested file.
            $overlap = Test-EntryOverlap -EntryA 'scripts/**' -EntryB 'scripts/dev_tools/a.py'

            # Assert: the mixed pair is a plain pattern match.
            $overlap | Should -BeTrue
        }

        It 'reports overlap with the arguments swapped' {
            # Arrange / Act: the same pair in the opposite order.
            $overlap = Test-EntryOverlap -EntryA 'scripts/dev_tools/a.py' -EntryB 'scripts/**'

            # Assert: the relation is symmetric.
            $overlap | Should -BeTrue
        }

        It 'reports no overlap when the glob does not match' {
            # Arrange / Act: a glob over a different tree.
            $overlap = Test-EntryOverlap -EntryA 'tests/**' -EntryB 'scripts/a.py'

            # Assert: a decidable mixed pair is decided exactly.
            $overlap | Should -BeFalse
        }
    }

    Context 'Glob against glob, decided conservatively' {
        It 'reports overlap for an undecidable pair whose literal prefixes agree' {
            # Arrange / Act: two globs that a full containment test could not
            # separate in general.
            $overlap = Test-EntryOverlap -EntryA 'scripts/*/a.py' -EntryB 'scripts/dev_tools/*.py'

            # Assert: a pair that cannot be proven disjoint counts as overlapping,
            # which is the fail-closed direction.
            $overlap | Should -BeTrue
        }

        It 'reports no overlap when the literal prefixes diverge' {
            # Arrange / Act: two globs rooted in different trees.
            $overlap = Test-EntryOverlap -EntryA 'scripts/*.py' -EntryB 'tests/*.py'

            # Assert: divergent prefixes are a sound disjointness proof.
            $overlap | Should -BeFalse
        }

        It 'reports overlap when one literal prefix is a prefix of the other' {
            # Arrange / Act: a broad glob against a narrower one beneath it.
            $overlap = Test-EntryOverlap -EntryA 'scripts/**' -EntryB 'scripts/dev_tools/*.py'

            # Assert: prefix containment cannot prove disjointness.
            $overlap | Should -BeTrue
        }
    }

    Context 'Directory containment, added by issue #452' {
        # Each case mirrors a Python case in
        # tests/scripts/dev_tools/test_blast_radius_conflicts.py one for one, so a
        # divergence between the two implementations fails a test in both languages.
        It 'reports overlap for <EntryA> against <EntryB>' -TestCases @(
            @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/dev_tools/a.py' }
            @{ EntryA = 'scripts/dev_tools/'; EntryB = 'scripts/dev_tools/a.py' }
            @{ EntryA = 'docs'; EntryB = 'docs/features/active/x/spec.md' }
            @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/dev_tools/**' }
            @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/dev_tools/*.py' }
            @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/*/a.py' }
        ) {
            param([string]$EntryA, [string]$EntryB)

            # Arrange / Act / Assert: a listed directory contends with anything
            # beneath it, in both argument orders.
            (Test-EntryOverlap -EntryA $EntryA -EntryB $EntryB) | Should -BeTrue
            (Test-EntryOverlap -EntryA $EntryB -EntryB $EntryA) | Should -BeTrue
        }

        It 'reports no overlap for <EntryA> against <EntryB>' -TestCases @(
            @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/dev_toolsX/a.py' }
            @{ EntryA = 'scripts/dev_tools/a.py'; EntryB = 'scripts/dev_tools/b.py' }
            @{ EntryA = 'docs/features/active/alpha'; EntryB = 'docs/features/active/beta/**' }
            @{ EntryA = 'scripts/a.py'; EntryB = 'tests/**' }
        ) {
            param([string]$EntryA, [string]$EntryB)

            # Arrange / Act / Assert: widening the relation must not reach a sibling
            # prefix, two peer files, or a pair whose roots diverge.
            (Test-EntryOverlap -EntryA $EntryA -EntryB $EntryB) | Should -BeFalse
            (Test-EntryOverlap -EntryA $EntryB -EntryB $EntryA) | Should -BeFalse
        }
    }

    Context 'Monotonicity, the fail-closed invariant' {
        # Every pair the pre-change baseline recorded as overlapping. Widening the
        # relation must never drop one, because reporting LESS contention is a
        # regression rather than a fix. The pair set matches
        # PREVIOUSLY_OVERLAPPING_ENTRY_PAIRS in the Python suite one for one.
        It 'still reports overlap for <EntryA> against <EntryB>' -TestCases @(
            @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/**' }
            @{ EntryA = 'scripts/dev_tools/**'; EntryB = 'scripts/dev_tools/compute_blast_radius.py' }
            @{ EntryA = 'shared.py'; EntryB = 'shared.py' }
            @{ EntryA = 'scripts/*/alpha.py'; EntryB = 'scripts/*/beta.py' }
        ) {
            param([string]$EntryA, [string]$EntryB)

            # Arrange / Act / Assert: a prior overlap must survive the widening.
            (Test-EntryOverlap -EntryA $EntryA -EntryB $EntryB) | Should -BeTrue
        }
    }
}

Describe 'Get-OrdinalSmallestEntry' {
    Context 'Ordinal minimum' {
        It 'returns the ordinally smallest entry rather than the culture smallest' {
            # Arrange: entries whose ordinal and culture minima differ, because
            # ordinal places every upper-case letter before every lower-case one.
            $entry = @('b', 'A', 'a')

            # Act: take the minimum.
            $smallest = Get-OrdinalSmallestEntry -Entry $entry

            # Assert: the result matches Python's min() over the same set.
            $smallest | Should -Be 'A'
        }

        It 'returns null for an empty collection' {
            # Arrange / Act: an empty candidate set.
            $smallest = Get-OrdinalSmallestEntry -Entry @()

            # Assert: an empty intersection contributes no reason detail.
            $smallest | Should -BeNullOrEmpty
        }
    }
}
