#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the shared pure feature-folder resolver (issue #565).

.DESCRIPTION
    Dot-sources the resolver under test and exercises every public function with literal
    inputs: candidate extraction (S01-S09), basename normalization (B01), the union-index
    record lookup (R01-R08), target selection (T01-T12, O01), work-mode parsing (M01), and
    the plan prerequisite map (P01). H01 hashes the two committed copies of the resolver to
    prove the Claude and Codex copies are byte-identical. No case writes a file.
#>

Describe 'feature-folder-resolution.ps1 (Codex surface)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/feature-folder-resolution.ps1").Path
        . $script:UnderTest

        function ConvertTo-RecordList {
            param([string] $Json)
            return @($Json | ConvertFrom-Json)
        }

        function Get-CandidateText {
            param([AllowNull()][string] $Text)
            return (@(Find-FeatureFolderCandidate -Text $Text) -join '|')
        }

        $script:IssueRecords = ConvertTo-RecordList -Json ('[{"issue_num":301,"feature_folder":"docs/features/active/child-301"},' +
            '{"issue_num":302,"feature_folder":"child-302"},{"feature_folder":"no-issue-303"},' +
            '{"issue_num":401,"feature_folder":"active/child-401"},{"issue_num":501,"feature_folder":"docs/features/active/child-501"}]')
        $script:DependencyRecords = ConvertTo-RecordList -Json ('[{"issue_num":100,"feature_folder":"dep-100","depends_on":[]},' +
            '{"issue_num":101,"feature_folder":"target-101","depends_on":[100]}]')
        $script:PairRecords = ConvertTo-RecordList -Json ('[{"issue_num":301,"feature_folder":"a","depends_on":[]},' +
            '{"issue_num":302,"feature_folder":"docs/features/active/b","depends_on":[]},{"issue_num":303,"feature_folder":"c","depends_on":[]}]')
    }

    Context 'Find-FeatureFolderCandidate (R1)' {
        It 'S01: truncates a research artifact path to its feature folder' {
            Get-CandidateText -Text 'read docs/features/active/alpha/research/notes.md first' | Should -BeExactly 'alpha'
        }

        It 'S02: truncates an evidence artifact path with a kind segment to its feature folder' {
            Get-CandidateText -Text 'see docs/features/active/alpha/evidence/baseline/run.md' | Should -BeExactly 'alpha'
        }

        It 'S03: removes repeated citations while preserving first-occurrence order' {
            Get-CandidateText -Text 'docs/features/active/a/spec.md docs/features/active/b docs/features/active/a/plan.md' | Should -BeExactly 'a|b'
        }

        It 'S04: accepts a backslash-separated token' {
            Get-CandidateText -Text 'docs\features\active\alpha\spec.md' | Should -BeExactly 'alpha'
        }

        It 'S05: reads the folder from an absolute-prefixed token (<Label>)' -ForEach @(
            @{ Label = 'drive letter'; Text = 'C:\repo\docs\features\active\x\spec.md' }
            @{ Label = 'rooted'; Text = '/repo/docs/features/active/x/spec.md' }
        ) {
            Get-CandidateText -Text $Text | Should -BeExactly 'x'
        }

        It 'S06: trims a trailing sentence character (<Char>) from the folder segment' -ForEach @(
            @{ Char = '.' }
            @{ Char = ',' }
            @{ Char = ';' }
            @{ Char = ':' }
        ) {
            Get-CandidateText -Text ("Target docs/features/active/x$Char next") | Should -BeExactly 'x'
        }

        It 'S07: yields no candidate for a bare docs/features/active/ token' {
            @(Find-FeatureFolderCandidate -Text 'see docs/features/active/ for the work').Count | Should -Be 0
        }

        It 'S08: yields no candidate for a docs/features/active/. token' {
            @(Find-FeatureFolderCandidate -Text 'see docs/features/active/. for the work').Count | Should -Be 0
        }

        It 'S09: yields no candidate for <Label> text' -ForEach @(
            @{ Label = 'null'; Text = $null }
            @{ Label = 'empty'; Text = '' }
        ) {
            @(Find-FeatureFolderCandidate -Text $Text).Count | Should -Be 0
        }
    }

    Context 'ConvertTo-FeatureFolderBasename (R2)' {
        It 'B01: normalizes <Value> to <Expected>' -ForEach @(
            @{ Value = 'docs/features/active/b'; Expected = 'b' }
            @{ Value = 'active/b'; Expected = 'b' }
            @{ Value = 'completed/b'; Expected = 'b' }
            @{ Value = 'b/'; Expected = 'b' }
            @{ Value = 'docs\features\active\b\'; Expected = 'b' }
            @{ Value = 'docs/features/active'; Expected = $null }
            @{ Value = '.'; Expected = $null }
            @{ Value = ''; Expected = $null }
        ) {
            ConvertTo-FeatureFolderBasename -Value $Value | Should -Be $Expected
        }
    }

    Context 'Find-FeatureFolderRecord (union index)' {
        It 'R01: matches an integer reference against issue_num' {
            (Find-FeatureFolderRecord -Records $script:IssueRecords -Reference 301).feature_folder | Should -Be 'docs/features/active/child-301'
        }

        It 'R02: matches a numeric-string reference against issue_num' {
            (Find-FeatureFolderRecord -Records $script:IssueRecords -Reference '302').feature_folder | Should -Be 'child-302'
        }

        It 'R03: matches a bare folder basename' {
            (Find-FeatureFolderRecord -Records $script:IssueRecords -Reference 'child-302').issue_num | Should -Be 302
        }

        It 'R04: matches a record value recorded with an active/ prefix' {
            (Find-FeatureFolderRecord -Records $script:IssueRecords -Reference 'child-401').issue_num | Should -Be 401
        }

        It 'R05: matches a record value recorded with a docs/features/active/ prefix' {
            (Find-FeatureFolderRecord -Records $script:IssueRecords -Reference 'docs/features/active/child-501').issue_num | Should -Be 501
        }

        It 'R06: returns $null when no record matches' {
            Find-FeatureFolderRecord -Records $script:IssueRecords -Reference 'missing-999' | Should -BeNullOrEmpty
        }

        It 'R07: returns $null when several records match' {
            $records = ConvertTo-RecordList -Json '[{"issue_num":1,"feature_folder":"active/dup"},{"issue_num":2,"feature_folder":"completed/dup"}]'
            Find-FeatureFolderRecord -Records $records -Reference 'dup' | Should -BeNullOrEmpty
        }

        It 'R08: returns $null for a null reference, null records, or a reference with no folder segment' {
            Find-FeatureFolderRecord -Records $script:IssueRecords -Reference $null | Should -BeNullOrEmpty
            Find-FeatureFolderRecord -Records $null -Reference 'child-302' | Should -BeNullOrEmpty
            Find-FeatureFolderRecord -Records @($null, $script:IssueRecords[1]) -Reference ' ' | Should -BeNullOrEmpty
            (Find-FeatureFolderRecord -Records @($null, $script:IssueRecords[1]) -Reference 'child-302').issue_num | Should -Be 302
        }
    }

    Context 'Select-FeatureFolderTarget (R2-R6)' {
        It 'T01: resolves one matched candidate with its record' {
            $result = Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @('a')
            $result.Status | Should -Be 'Resolved'
            $result.Record.issue_num | Should -Be 301
            $result.Basename | Should -BeExactly 'a'
            $result.Detail | Should -BeExactly "resolved target feature folder 'a'"
        }

        It 'T02: resolves one unmatched candidate with a null record' {
            $result = Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @('unmatched')
            $result.Status | Should -Be 'Resolved'
            $result.Record | Should -BeNullOrEmpty
            $result.Basename | Should -BeExactly 'unmatched'
        }

        It 'T03: reports NoTarget for zero candidates' {
            $result = Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @()
            $result.Status | Should -Be 'NoTarget'
            $result.Detail | Should -BeExactly 'no target feature folder is cited'
            (Select-FeatureFolderTarget -Records $null -Candidate $null).Status | Should -Be 'NoTarget'
        }

        It 'T04: reports Ambiguous for two non-dependency candidates' {
            $result = Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @('a', 'b')
            $result.Status | Should -Be 'Ambiguous'
            $result.Detail | Should -BeExactly 'ambiguous target feature folder; remaining candidates: a, b'
        }

        It 'T05: prunes a cited dependency with -DependencyAware' {
            $result = Select-FeatureFolderTarget -Records $script:DependencyRecords -Candidate @('dep-100', 'target-101') -DependencyAware
            $result.Status | Should -Be 'Resolved'
            $result.Basename | Should -BeExactly 'target-101'
            ($result.Remaining -join '|') | Should -BeExactly 'target-101'
        }

        It 'T06: prunes a transitive dependency (A depends on B depends on C; A and C cited)' {
            $records = ConvertTo-RecordList -Json ('[{"issue_num":1,"feature_folder":"a","depends_on":["b"]},' +
                '{"issue_num":2,"feature_folder":"b","depends_on":[3]},{"issue_num":3,"feature_folder":"c","depends_on":[]}]')
            $result = Select-FeatureFolderTarget -Records $records -Candidate @('c', 'a') -DependencyAware
            $result.Status | Should -Be 'Resolved'
            $result.Basename | Should -BeExactly 'a'
        }

        It 'T07: prunes neither candidate of a dependency cycle' {
            $records = ConvertTo-RecordList -Json ('[{"issue_num":1,"feature_folder":"a","depends_on":[2]},' +
                '{"issue_num":2,"feature_folder":"b","depends_on":[1]}]')
            (Select-FeatureFolderTarget -Records $records -Candidate @('a', 'b') -DependencyAware).Status | Should -Be 'Ambiguous'
        }

        It 'T08: resolves two remaining candidates through -DeclaredIssueNumber' {
            $result = Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @('a', 'b') -DeclaredIssueNumber 302
            $result.Status | Should -Be 'Resolved'
            $result.Basename | Should -BeExactly 'b'
        }

        It 'T09: does not let -DeclaredIssueNumber select a record outside the cited set' {
            (Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @('a', 'b') -DeclaredIssueNumber 303).Status | Should -Be 'Ambiguous'
        }

        It 'T10: resolves zero candidates through -FallbackIssueNumber' {
            $result = Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @() -FallbackIssueNumber 302
            $result.Status | Should -Be 'Resolved'
            $result.Basename | Should -BeExactly 'b'
            $result.Record.issue_num | Should -Be 302
        }

        It 'T11: reports NoTarget when -FallbackIssueNumber names no record' {
            (Select-FeatureFolderTarget -Records $script:PairRecords -Candidate @() -FallbackIssueNumber 999).Status | Should -Be 'NoTarget'
            $noFolder = ConvertTo-RecordList -Json '[{"issue_num":7}]'
            $result = Select-FeatureFolderTarget -Records $noFolder -Candidate @() -FallbackIssueNumber 7
            $result.Status | Should -Be 'Resolved'
            $result.Basename | Should -BeNullOrEmpty
        }

        It 'T12: does not prune a cited dependency without -DependencyAware' {
            (Select-FeatureFolderTarget -Records $script:DependencyRecords -Candidate @('dep-100', 'target-101')).Status | Should -Be 'Ambiguous'
        }

        It 'O01: reports Ambiguous for both orders and either longer slug (<Label>)' -ForEach @(
            @{ Label = 'short first'; First = 'aa'; Second = 'bbbbbbbbbbbbbbbbbbbb' }
            @{ Label = 'long first'; First = 'bbbbbbbbbbbbbbbbbbbb'; Second = 'aa' }
            @{ Label = 'long second slug first'; First = 'aaaaaaaaaaaaaaaaaaaa'; Second = 'bb' }
            @{ Label = 'short second slug first'; First = 'bb'; Second = 'aaaaaaaaaaaaaaaaaaaa' }
        ) {
            $records = ConvertTo-RecordList -Json ('[{"issue_num":1,"feature_folder":"' + $First + '","depends_on":[]},' +
                '{"issue_num":2,"feature_folder":"' + $Second + '","depends_on":[]}]')
            $result = Select-FeatureFolderTarget -Records $records -Candidate @($First, $Second) -DependencyAware
            $result.Status | Should -Be 'Ambiguous'
            $result.Remaining | Should -Contain $First
            $result.Remaining | Should -Contain $Second
        }
    }

    Context 'Resolve-FeatureFolderWorkMode and Get-FeatureFolderPlanPrerequisite' {
        It 'M01: resolves <Label> to the expected mode' -ForEach @(
            @{ Label = 'minor-audit'; Content = "# Issue`n- Work Mode: minor-audit`n"; Unresolved = $null; Expected = 'minor-audit' }
            @{ Label = 'full-bug'; Content = "- Work Mode: full-bug`r`n## Summary"; Unresolved = $null; Expected = 'full-bug' }
            @{ Label = 'full-feature'; Content = '- Work Mode: full-feature'; Unresolved = $null; Expected = 'full-feature' }
            @{ Label = 'legacy full'; Content = '- Work Mode: full'; Unresolved = $null; Expected = 'full-feature' }
            @{ Label = 'a missing marker'; Content = "# Issue`nNo marker here."; Unresolved = $null; Expected = 'full-feature' }
            @{ Label = 'empty content'; Content = ''; Unresolved = $null; Expected = 'full-feature' }
            @{ Label = 'a malformed marker'; Content = '- Work Mode full-bug'; Unresolved = $null; Expected = 'full-feature' }
            @{ Label = 'an unrecognized marker'; Content = '- Work Mode: quick'; Unresolved = $null; Expected = 'full-feature' }
            @{ Label = 'a missing marker with an empty -UnresolvedMode'; Content = '# no marker'; Unresolved = ''; Expected = '' }
            @{ Label = 'null content with an empty -UnresolvedMode'; Content = $null; Unresolved = ''; Expected = '' }
        ) {
            $arguments = @{ IssueContent = $Content }
            if ($null -ne $Unresolved) {
                $arguments['UnresolvedMode'] = $Unresolved
            }
            Resolve-FeatureFolderWorkMode @arguments | Should -BeExactly $Expected
        }

        It 'P01: maps <Mode> to <Expected>' -ForEach @(
            @{ Mode = 'minor-audit'; Expected = 'issue.md' }
            @{ Mode = 'full-bug'; Expected = 'issue.md|spec.md' }
            @{ Mode = 'full-feature'; Expected = 'issue.md|spec.md|user-story.md' }
            @{ Mode = 'unknown'; Expected = 'issue.md|spec.md|user-story.md' }
        ) {
            (@(Get-FeatureFolderPlanPrerequisite -WorkMode $Mode) -join '|') | Should -BeExactly $Expected
        }
    }

    Context 'Claude and Codex copies' {
        It 'H01: the Claude and Codex copies of the resolver have equal SHA256 hashes' {
            $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
            $claudeCopy = Join-Path $repoRoot '.claude/hooks/feature-folder-resolution.ps1'
            $codexCopy = Join-Path $repoRoot '.codex/hooks/feature-folder-resolution.ps1'
            (Get-FileHash -Algorithm SHA256 -LiteralPath $codexCopy).Hash |
                Should -Be (Get-FileHash -Algorithm SHA256 -LiteralPath $claudeCopy).Hash -Because 'the shared resolver must be byte-identical on both surfaces'
        }
    }
}
