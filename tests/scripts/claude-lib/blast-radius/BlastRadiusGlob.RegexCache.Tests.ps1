<#
.SYNOPSIS
    Behavioral tests for the glob regex cache and the single-scan prefix path.

.DESCRIPTION
    Covers the script-scoped regex cache and the non-exported Get-GlobRegex
    helper added to BlastRadiusGlob.psm1 by issue #776, the agreement of
    Test-GlobMatch between an uncached and a cached call, and the IndexOfAny fast
    path of Get-LiteralPrefix. Each It targets a single behavior with
    Arrange-Act-Assert structure. Every cache test removes the pattern it uses
    before acting, so the tests do not depend on execution order. The tests
    invoke no external process and create no temporary files.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius. Resolve-Path
    # normalizes the separators so Pester's code-coverage breakpoints bind to the
    # same on-disk path the run settings name.
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusGlob.psm1").Path
    Import-Module $modulePath -Force
}

Describe 'Glob regex cache (issue #776)' {
    It 'returns the same compiled regex instance for a repeated pattern' {
        InModuleScope BlastRadiusGlob {
            # Arrange: start from an uncached pattern.
            [void]$script:GlobRegexCache.Remove('scripts/**/*.ps1')

            # Act: request the regex twice.
            $first = Get-GlobRegex -Pattern 'scripts/**/*.ps1'
            $second = Get-GlobRegex -Pattern 'scripts/**/*.ps1'

            # Assert: the second call returns the cached instance itself.
            [object]::ReferenceEquals($first, $second) | Should -BeTrue
        }
    }

    It 'adds one cache entry for a new pattern and none for a repeat' {
        InModuleScope BlastRadiusGlob {
            # Arrange: remove the pattern so the first request is a miss.
            [void]$script:GlobRegexCache.Remove('docs/*.md')
            $before = $script:GlobRegexCache.Count

            # Act: one miss followed by one hit.
            $null = Get-GlobRegex -Pattern 'docs/*.md'
            $afterMiss = $script:GlobRegexCache.Count
            $null = Get-GlobRegex -Pattern 'docs/*.md'
            $afterHit = $script:GlobRegexCache.Count

            # Assert: the miss adds exactly one entry and the hit adds none.
            $afterMiss | Should -Be ($before + 1)
            $afterHit | Should -Be $afterMiss
        }
    }

    It 'keys the cache ordinally so patterns differing by case stay distinct' {
        InModuleScope BlastRadiusGlob {
            # Arrange: remove both case variants.
            [void]$script:GlobRegexCache.Remove('A/*.py')
            [void]$script:GlobRegexCache.Remove('a/*.py')

            # Act: cache both variants and match the upper-case one against a
            # lower-case candidate.
            $null = Get-GlobRegex -Pattern 'A/*.py'
            $null = Get-GlobRegex -Pattern 'a/*.py'
            $matched = Test-GlobMatch -Pattern 'A/*.py' -Candidate 'a/x.py'

            # Assert: two distinct keys, and the case-sensitive match fails.
            $script:GlobRegexCache.ContainsKey('A/*.py') | Should -BeTrue
            $script:GlobRegexCache.ContainsKey('a/*.py') | Should -BeTrue
            $matched | Should -BeFalse
        }
    }

    It 'anchors the cached regex as a whole-string match' {
        InModuleScope BlastRadiusGlob {
            # Arrange: a single-segment wildcard pattern.
            $pattern = 'scripts/*'

            # Act: read the text of the cached regex.
            $text = (Get-GlobRegex -Pattern $pattern).ToString()

            # Assert: \A and \z anchor the translation, reproducing re.fullmatch.
            $text | Should -BeExactly '\A(?:scripts/[^/]*)\z'
        }
    }
}

Describe 'Test-GlobMatch cached and uncached agreement (issue #776)' {
    It 'returns <Expected> for <Pattern> against <Candidate> on the first and the repeated call' -ForEach @(
        @{ Pattern = 'scripts/**'; Candidate = 'scripts/dev_tools/a.py'; Expected = $true }
        @{ Pattern = 'scripts/*'; Candidate = 'scripts/dev_tools/a.py'; Expected = $false }
        @{ Pattern = 'a/?.py'; Candidate = 'a/x.py'; Expected = $true }
        @{ Pattern = 'a/[ab].py'; Candidate = 'a/a.py'; Expected = $false }
        @{ Pattern = 'a//*'; Candidate = 'a//'; Expected = $true }
    ) {
        $parameter = @{ Pattern = $Pattern; Candidate = $Candidate; Expected = $Expected }
        InModuleScope BlastRadiusGlob -Parameters $parameter {
            param($Pattern, $Candidate, $Expected)

            # Arrange: remove the pattern so the first call is uncached.
            [void]$script:GlobRegexCache.Remove($Pattern)
            $script:GlobRegexCache.ContainsKey($Pattern) | Should -BeFalse

            # Act: an uncached call followed by a cached call.
            $first = Test-GlobMatch -Pattern $Pattern -Candidate $Candidate
            $second = Test-GlobMatch -Pattern $Pattern -Candidate $Candidate

            # Assert: both calls agree with the expected verdict.
            $first | Should -Be $Expected
            $second | Should -Be $Expected
        }
    }
}

Describe 'Get-LiteralPrefix single-scan fast path (issue #776)' {
    It 'returns an empty prefix when the entry starts with <_>' -ForEach @('*', '?') {
        # Arrange: an entry whose first character is a wildcard.
        $entry = "${_}/tail.py"

        # Act: compute the literal prefix.
        $prefix = Get-LiteralPrefix -Entry $entry

        # Assert: a wildcard at index 0 leaves no literal prefix.
        $prefix | Should -BeExactly ''
    }

    It 'returns an empty prefix for an empty entry' {
        # Arrange: the empty entry.
        $entry = ''

        # Act: compute the literal prefix.
        $prefix = Get-LiteralPrefix -Entry $entry

        # Assert: the wildcard-free fallback returns the empty entry itself.
        $prefix | Should -BeExactly ''
    }
}
