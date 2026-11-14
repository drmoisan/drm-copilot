<#
.SYNOPSIS
    Pester tests for .claude/lib/regeneration/RegenerationClassifier.psm1 (issue #1156).

.DESCRIPTION
    Exercises the first-match decision table, declared-pattern matching, and the
    changed-path intersection with in-memory values only. The suite registers no
    Mock and creates no file. It imports only RegenerationClassifier.psm1, so the
    glob cases fail when the module's own BlastRadiusGlob.psm1 import is removed.
#>

BeforeAll {
    $script:ModulePath = Join-Path $PSScriptRoot '../../../../.claude/lib/regeneration/RegenerationClassifier.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop

    $script:Config = [ordered]@{ command = @('gen'); paths = @('gen/**', 'docs/*.json') }
}

AfterAll {
    Remove-Module -Name RegenerationClassifier -Force -ErrorAction SilentlyContinue
}

Describe 'Get-RegenerationPathDecision' {
    It 'returns regenerate with all_match when every path matches' {
        $result = Get-RegenerationPathDecision -ChangedPath @('gen/a.json', 'docs/x.json') -MergeBaseCount 1 -Config $script:Config -ConfigError @()
        $result.Decision | Should -BeExactly 'regenerate'
        $result.Reason | Should -BeExactly 'all_match'
        @($result.UnmatchedPath).Count | Should -Be 0
    }

    It 'returns unmatched_path with the unmatched paths ordinal-sorted' {
        $result = Get-RegenerationPathDecision -ChangedPath @('src/b.ps1', 'gen/a.json', 'Src/a.ps1', 'docs/sub/y.json') -MergeBaseCount 1 -Config $script:Config -ConfigError @()
        $result.Decision | Should -BeExactly 'remediation_loop'
        $result.Reason | Should -BeExactly 'unmatched_path'
        $result.UnmatchedPath | Should -Be @('Src/a.ps1', 'docs/sub/y.json', 'src/b.ps1')
    }

    It 'returns no_config with an empty UnmatchedPath when the config is null' {
        $result = Get-RegenerationPathDecision -ChangedPath @('src/x.ps1') -MergeBaseCount 1 -Config $null -ConfigError @()
        $result.Decision | Should -BeExactly 'remediation_loop'
        $result.Reason | Should -BeExactly 'no_config'
        @($result.UnmatchedPath).Count | Should -Be 0
    }

    It 'returns config_invalid with an empty UnmatchedPath when config errors exist' {
        $result = Get-RegenerationPathDecision -ChangedPath @('src/x.ps1') -MergeBaseCount 1 -Config $script:Config -ConfigError @('version: must be the JSON integer 1')
        $result.Reason | Should -BeExactly 'config_invalid'
        @($result.UnmatchedPath).Count | Should -Be 0
    }

    It 'returns multiple_merge_bases with an empty UnmatchedPath for a merge-base count of <Count>' -ForEach @(
        @{ Count = 0 }
        @{ Count = 2 }
    ) {
        $result = Get-RegenerationPathDecision -ChangedPath @('src/x.ps1') -MergeBaseCount $Count -Config $script:Config -ConfigError @()
        $result.Decision | Should -BeExactly 'remediation_loop'
        $result.Reason | Should -BeExactly 'multiple_merge_bases'
        @($result.UnmatchedPath).Count | Should -Be 0
    }

    It 'returns empty_set with an empty UnmatchedPath for an empty changed set' {
        $result = Get-RegenerationPathDecision -ChangedPath @() -MergeBaseCount 1 -Config $script:Config -ConfigError @()
        $result.Reason | Should -BeExactly 'empty_set'
        @($result.UnmatchedPath).Count | Should -Be 0
    }

    It 'returns no_config before empty_set when both hold (first match wins)' {
        $result = Get-RegenerationPathDecision -ChangedPath @() -MergeBaseCount 1 -Config $null -ConfigError @()
        $result.Reason | Should -BeExactly 'no_config'
    }

    It 'returns config_invalid before multiple_merge_bases when both hold' {
        $result = Get-RegenerationPathDecision -ChangedPath @('src/x.ps1') -MergeBaseCount 2 -Config $script:Config -ConfigError @('e')
        $result.Reason | Should -BeExactly 'config_invalid'
    }
}

Describe 'Test-RegenerationPathMatch' {
    It 'matches a root-level path against a pattern beginning with a double-star segment' {
        Test-RegenerationPathMatch -Path 'lock.json' -Pattern @('**/lock.json') | Should -BeTrue
    }

    It 'matches a nested path against a pattern beginning with a double-star segment' {
        Test-RegenerationPathMatch -Path 'a/b/lock.json' -Pattern @('**/lock.json') | Should -BeTrue
    }

    It 'does not let a single star cross a slash' {
        Test-RegenerationPathMatch -Path 'gen/sub/a.json' -Pattern @('gen/*.json') | Should -BeFalse
        Test-RegenerationPathMatch -Path 'gen/a.json' -Pattern @('gen/*.json') | Should -BeTrue
    }

    It 'does not let a question mark cross a slash' {
        Test-RegenerationPathMatch -Path 'a/b' -Pattern @('a?b') | Should -BeFalse
        Test-RegenerationPathMatch -Path 'axb' -Pattern @('a?b') | Should -BeTrue
    }

    It 'lets a double star cross two slashes' {
        Test-RegenerationPathMatch -Path 'gen/x/y/z.json' -Pattern @('gen/**') | Should -BeTrue
    }

    It 'does not match a case variant' {
        Test-RegenerationPathMatch -Path 'Gen/a.json' -Pattern @('gen/**') | Should -BeFalse
    }

    It 'never matches a candidate holding a backslash' {
        Test-RegenerationPathMatch -Path 'gen\a.json' -Pattern @('gen**', '**') | Should -BeFalse
    }

    It 'returns false for an empty pattern list' {
        Test-RegenerationPathMatch -Path 'gen/a.json' -Pattern @() | Should -BeFalse
    }
}

Describe 'Get-RegenerationChangedPath' {
    It 'returns an empty result for disjoint listings' {
        $result = Get-RegenerationChangedPath -OursListing "a`0b`0" -TheirsListing "c`0d`0"
        @($result).Count | Should -Be 0
    }

    It 'returns the ordinal-sorted de-duplicated intersection of overlapping listings' {
        $result = Get-RegenerationChangedPath -OursListing "z.json`0B.json`0a.json`0z.json" -TheirsListing "a.json`0z.json`0B.json`0q.json"
        $result | Should -Be @('B.json', 'a.json', 'z.json')
    }

    It 'drops empty entries produced by trailing and doubled NUL terminators' {
        $result = Get-RegenerationChangedPath -OursListing "a`0`0b`0" -TheirsListing "b`0a`0`0"
        $result | Should -Be @('a', 'b')
    }

    It 'returns an empty result for empty listings' {
        (Get-RegenerationChangedPath -OursListing '' -TheirsListing '').Count | Should -Be 0
    }
}
