#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Table-driven tests for the pure functions of EpicCrossDependency.psm1 (issue #1162).

.DESCRIPTION
    Covers manifest parsing, the nine manifest validation codes, the prerequisite PR match
    of D3 as amended by D11, every row and the aggregation of the Feature hold and
    Integration-to-main hold tables, and that the pure functions call no adapter seam.
    All inputs are in-memory manifest text and PR JSON; no file is created.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    Import-Module -Name (Join-Path $script:RepoRoot '.claude/lib/epic-wave/EpicCrossDependency.psm1') -Force -ErrorAction Stop

    # Build epic.md text from a slug and feature item lines (each already indented).
    $script:ManifestText = {
        param([string] $Epic, [string[]] $FeatureLine)
        (@('---', "epic: $Epic", "integration_branch: epic/$Epic-integration", 'features:') + $FeatureLine + @('---', '', '# body')) -join "`n"
    }
    $script:ProviderEdge = '[{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }]'
    $script:Consumer = {
        param($CrossValue)
        $lines = @('  - issue_num: 1201', '    feature_folder: 2026-11-10-consumer-1201', '    depends_on: []')
        if ($null -ne $CrossValue) { $lines += "    cross_epic_depends_on: $CrossValue" }
        ConvertFrom-EpicCrossDependencyManifest -Text (& $script:ManifestText 'consumer' $lines)
    }
    $script:Provider = ConvertFrom-EpicCrossDependencyManifest -Text (& $script:ManifestText 'provider-epic' @(
            '  - issue_num: 1188', '    feature_folder: 2026-11-01-provider-1188', '    depends_on: []'))

    # One merged PR record of the feature snapshot.
    $script:Pr = {
        param([int] $Number, [string] $Head, [string[]] $Path = @())
        @{ number = $Number; headRefName = $Head; mergeCommit = @{ oid = "sha$Number" }; files = @($Path | ForEach-Object { @{ path = $_ } }) }
    }
    $script:Snapshot = { param([object[]] $Pr) ConvertTo-Json -InputObject @($Pr) -Depth 5 -Compress }

    # Edge evidence with the defaults of a merged, not yet integrated prerequisite.
    $script:Evidence = {
        param([hashtable] $Override = @{})
        $value = @{
            Epic = 'provider-epic'; IntegrationBranch = 'epic/provider-epic-integration'; IssueNum = '1188'; AdapterError = $false
            Match = [pscustomobject]@{ Status = 'match'; Number = 7; MergeCommitSha = 'abc'; MatchCount = 1 }
            OtherBranchPresent = $true; OtherAncestorExit = 0; MainAncestorExit = $null; OwnAncestorExit = 1
        }
        foreach ($key in $Override.Keys) { $value[$key] = $Override[$key] }
        $value
    }
}

AfterAll {
    Remove-Module -Name EpicCrossDependency -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-EpicCrossDependencyManifest' {
    It 'parses the epic, the integration branch, and one inline edge' {
        $manifest = & $script:Consumer $script:ProviderEdge

        $manifest.Epic | Should -BeExactly 'consumer'
        $manifest.IntegrationBranch | Should -BeExactly 'epic/consumer-integration'
        $manifest.HasCrossEdge | Should -BeTrue
        $edge = $manifest.Features[0].CrossEdges[0]
        "$($edge.Epic)|$($edge.IntegrationBranch)|$($edge.IssueNum)" | Should -BeExactly 'provider-epic|epic/provider-epic-integration|1188'
    }

    It 'reports no cross-epic edge for <Name>' -ForEach @(
        @{ Name = 'an absent key'; Value = $null }
        @{ Name = 'an empty sequence'; Value = '[]' }
    ) {
        (& $script:Consumer $Value).HasCrossEdge | Should -BeFalse
    }

    It 'returns null for <Name>' -ForEach @(
        @{ Name = 'text without frontmatter'; Text = "epic: a`nfeatures:" }
        @{ Name = 'unclosed frontmatter'; Text = "---`nepic: a`nfeatures:" }
        @{ Name = 'empty text'; Text = '' }
    ) {
        ConvertFrom-EpicCrossDependencyManifest -Text $Text | Should -BeNullOrEmpty
    }

    It 'reads quoted scalars, block lists, scalar early_start_on, and ignores comments' {
        $text = & $script:ManifestText 'consumer' @('  # comment', "  - issue_num: '1201'", '    feature_folder: "folder-1201"', '    depends_on:', '      - 1200', '      - 1199', '    early_start_on: 1200')
        $feature = (ConvertFrom-EpicCrossDependencyManifest -Text $text).Features[0]

        "$($feature.IssueNum)|$($feature.FeatureFolder)|$($feature.DependsOn -join ',')|$($feature.EarlyStartOn -join ',')|$($feature.CrossForm)" | Should -BeExactly '1201|folder-1201|1200,1199|1200|absent'
    }

    It 'classifies a block-style value as block' {
        $text = & $script:ManifestText 'consumer' @('  - issue_num: 1201', '    cross_epic_depends_on:', '      - epic: provider-epic', '        issue_num: 1188')
        (ConvertFrom-EpicCrossDependencyManifest -Text $text).Features[0].CrossForm | Should -BeExactly 'block'
    }

    It 'classifies <Name> as malformed' -ForEach @(
        @{ Name = 'a missing key'; Value = '[{ epic: p, issue_num: 1 }]' }
        @{ Name = 'an extra key'; Value = '[{ epic: p, integration_branch: epic/p-integration, issue_num: 1, x: 2 }]' }
        @{ Name = 'a repeated key'; Value = '[{ epic: p, epic: p, issue_num: 1 }]' }
        @{ Name = 'an epic with a slash'; Value = '[{ epic: a/b, integration_branch: epic/a/b-integration, issue_num: 1 }]' }
        @{ Name = 'a dot-segment epic'; Value = '[{ epic: .., integration_branch: epic/..-integration, issue_num: 1 }]' }
        @{ Name = 'a zero issue_num'; Value = '[{ epic: p, integration_branch: epic/p-integration, issue_num: 0 }]' }
        @{ Name = 'a text issue_num'; Value = '[{ epic: p, integration_branch: epic/p-integration, issue_num: one }]' }
        @{ Name = 'a blank integration_branch'; Value = "[{ epic: p, integration_branch: '', issue_num: 1 }]" }
        @{ Name = 'a scalar value'; Value = 'provider-epic#1188' }
        @{ Name = 'a sequence of scalars'; Value = '[provider-epic]' }
        @{ Name = 'a nested mapping'; Value = '[{ epic: { a: b }, integration_branch: x, issue_num: 1 }]' }
        @{ Name = 'a pair without a colon'; Value = '[{ epic }]' }
        @{ Name = 'an empty inline value without a block'; Value = '' }
    ) {
        (& $script:Consumer $Value).Features[0].CrossForm | Should -BeExactly 'malformed'
    }

    It 'parses two edges in one sequence' {
        $value = '[{ epic: a, integration_branch: epic/a-integration, issue_num: 1 }, { epic: "b", integration_branch: epic/b-integration, issue_num: 2 }]'
        @((& $script:Consumer $value).Features[0].CrossEdges | ForEach-Object { "$($_.Epic)#$($_.IssueNum)" }) -join ',' | Should -BeExactly 'a#1,b#2'
    }
}

Describe 'Get-EpicCrossDependencyManifestError' {
    It 'returns no error for a valid manifest whose prerequisite resolves' {
        @(Get-EpicCrossDependencyManifestError -Manifest (& $script:Consumer $script:ProviderEdge) -OtherManifest @{ 'provider-epic' = $script:Provider }).Count | Should -Be 0
    }

    It 'returns no error for a manifest without the key' {
        @(Get-EpicCrossDependencyManifestError -Manifest (& $script:Consumer $null) -OtherManifest @{}).Count | Should -Be 0
    }

    It 'returns <Code> for <Name>' -ForEach @(
        @{ Name = 'a malformed value'; Code = 'EPIC_CROSS_DEPENDENCY_MALFORMED'; Value = '[{ epic: p }]' }
        @{ Name = 'a wrong integration branch'; Code = 'EPIC_CROSS_DEPENDENCY_BRANCH_MISMATCH'; Value = '[{ epic: provider-epic, integration_branch: epic/other-integration, issue_num: 1188 }]' }
        @{ Name = 'its own epic'; Code = 'EPIC_CROSS_DEPENDENCY_SAME_EPIC'; Value = '[{ epic: consumer, integration_branch: epic/consumer-integration, issue_num: 1201 }]' }
        @{ Name = 'a repeated pair'; Code = 'EPIC_CROSS_DEPENDENCY_DUPLICATE'; Value = '[{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }, { epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }]' }
        @{ Name = 'an issue the other manifest lacks'; Code = 'EPIC_CROSS_DEPENDENCY_UNRESOLVED'; Value = '[{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 9999 }]' }
    ) {
        $errors = @(Get-EpicCrossDependencyManifestError -Manifest (& $script:Consumer $Value) -OtherManifest @{ 'provider-epic' = $script:Provider })

        $errors.Count | Should -Be 1
        $errors[0] | Should -BeLike "$($Code):*"
    }

    It 'returns UNSUPPORTED_FORM for a block-style value' {
        $text = & $script:ManifestText 'consumer' @('  - issue_num: 1201', '    cross_epic_depends_on:', '      - epic: provider-epic')
        $errors = @(Get-EpicCrossDependencyManifestError -Manifest (ConvertFrom-EpicCrossDependencyManifest -Text $text))

        ($errors -join '|') | Should -BeExactly 'EPIC_CROSS_DEPENDENCY_UNSUPPORTED_FORM: feature 1201 gives cross_epic_depends_on in block style; write it on one line as an inline flow sequence of flow mappings.'
    }

    It 'returns MANIFEST_UNREADABLE when the other manifest is absent' {
        $errors = @(Get-EpicCrossDependencyManifestError -Manifest (& $script:Consumer $script:ProviderEdge) -OtherManifest @{ 'provider-epic' = $null })

        ($errors -join '|') | Should -BeExactly 'EPIC_CROSS_DEPENDENCY_MANIFEST_UNREADABLE: feature 1201 names epic provider-epic, whose manifest is absent on epic/provider-epic-integration and on main.'
    }

    It 'returns MANIFEST_UNREADABLE when the other epic is missing from the supplied map' {
        @(Get-EpicCrossDependencyManifestError -Manifest (& $script:Consumer $script:ProviderEdge) -OtherManifest @{})[0] | Should -BeLike 'EPIC_CROSS_DEPENDENCY_MANIFEST_UNREADABLE:*'
    }

    It 'skips the referenced-manifest rules when no other manifest map is supplied' {
        $manifest = & $script:Consumer '[{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 9999 }]'
        @(Get-EpicCrossDependencyManifestError -Manifest $manifest).Count | Should -Be 0
    }

    It 'returns EARLY_START_CROSS when early_start_on names only a cross-epic issue' {
        $text = & $script:ManifestText 'consumer' @('  - issue_num: 1201', '    depends_on: []', "    cross_epic_depends_on: $($script:ProviderEdge)", '    early_start_on: 1188')
        $errors = @(Get-EpicCrossDependencyManifestError -Manifest (ConvertFrom-EpicCrossDependencyManifest -Text $text))

        ($errors -join '|') | Should -BeExactly 'EPIC_CROSS_DEPENDENCY_EARLY_START_CROSS: feature 1201 gives early_start_on 1188, which names a cross-epic dependency; early start applies only inside the epic.'
    }

    It 'accepts early_start_on that names an issue of the epic itself' {
        $text = & $script:ManifestText 'consumer' @('  - issue_num: 1188', '    depends_on: []', '  - issue_num: 1201', '    depends_on: [1188]', "    cross_epic_depends_on: $($script:ProviderEdge)", '    early_start_on: 1188')
        @(Get-EpicCrossDependencyManifestError -Manifest (ConvertFrom-EpicCrossDependencyManifest -Text $text)).Count | Should -Be 0
    }

    It 'returns CYCLE for a one-hop cycle through a depends_on edge' {
        $consumer = ConvertFrom-EpicCrossDependencyManifest -Text (& $script:ManifestText 'consumer' @(
                '  - issue_num: 1201', '    depends_on: []', "    cross_epic_depends_on: $($script:ProviderEdge)",
                '  - issue_num: 1202', '    depends_on: [1201]'))
        $provider = ConvertFrom-EpicCrossDependencyManifest -Text (& $script:ManifestText 'provider-epic' @(
                '  - issue_num: 1188', '    depends_on: []', '    cross_epic_depends_on: [{ epic: consumer, integration_branch: epic/consumer-integration, issue_num: 1202 }]'))

        $errors = @(Get-EpicCrossDependencyManifestError -Manifest $consumer -OtherManifest @{ 'provider-epic' = $provider })

        $errors.Count | Should -Be 1
        $errors[0] | Should -BeLike 'EPIC_CROSS_DEPENDENCY_CYCLE: the features of this manifest and the manifests it references form a cycle through *'
    }

    It 'reports no cycle when the other manifest points at an unrelated feature' {
        $provider = ConvertFrom-EpicCrossDependencyManifest -Text (& $script:ManifestText 'provider-epic' @(
                '  - issue_num: 1188', '    depends_on: [1187]', '  - issue_num: 1187', '    depends_on: []'))
        @(Get-EpicCrossDependencyManifestError -Manifest (& $script:Consumer $script:ProviderEdge) -OtherManifest @{ 'provider-epic' = $provider }).Count | Should -Be 0
    }
}

Describe 'Get-EpicCrossDependencyPrerequisitePr' {
    It 'matches a PR by <Name>' -ForEach @(
        @{ Name = 'the file rule alone (active)'; Head = 'feature/unrelated-branch'; Path = @('docs/features/active/2026-11-01-provider-1188/spec.md') }
        @{ Name = 'the file rule alone (completed)'; Head = 'feature/unrelated-branch'; Path = @('docs/features/completed/2026-11-01-provider-1188/plan.md') }
        @{ Name = 'the token rule with a trailing issue'; Head = 'feature/provider-thing-1188'; Path = @('src/a.ts') }
        @{ Name = 'the token rule with a retry token'; Head = 'feature/provider-thing-1188-r2'; Path = @() }
        @{ Name = 'the token rule after an exec token'; Head = 'exec-1188-provider'; Path = @() }
    ) {
        $result = Get-EpicCrossDependencyPrerequisitePr -SnapshotJson (& $script:Snapshot @((& $script:Pr 41 $Head $Path))) -IssueNum '1188' -FeatureFolder '2026-11-01-provider-1188'

        "$($result.Status)|$($result.Number)|$($result.MergeCommitSha)" | Should -BeExactly 'match|41|sha41'
    }

    It 'counts a PR matching both rules once' {
        $snapshot = & $script:Snapshot @((& $script:Pr 41 'feature/provider-1188' @('docs/features/active/2026-11-01-provider-1188/spec.md')))
        (Get-EpicCrossDependencyPrerequisitePr -SnapshotJson $snapshot -IssueNum '1188' -FeatureFolder '2026-11-01-provider-1188').MatchCount | Should -Be 1
    }

    It 'returns PREREQ_PR_AMBIGUOUS for two distinct matching PRs' {
        $snapshot = & $script:Snapshot @((& $script:Pr 41 'feature/a-1188'), (& $script:Pr 42 'feature/b-1188-r2'))
        $result = Get-EpicCrossDependencyPrerequisitePr -SnapshotJson $snapshot -IssueNum '1188' -FeatureFolder 'f'

        "$($result.Status)|$($result.MatchCount)" | Should -BeExactly 'PREREQ_PR_AMBIGUOUS|2'
    }

    It 'does not match an issue number inside a longer token or a different folder' {
        $snapshot = & $script:Snapshot @((& $script:Pr 41 'feature/thing-11880' @('docs/features/active/2026-11-01-provider-11880/spec.md', 'docs/features/active/2026-11-01-provider-1188x/a.md')))
        (Get-EpicCrossDependencyPrerequisitePr -SnapshotJson $snapshot -IssueNum '1188' -FeatureFolder '2026-11-01-provider-1188').Status | Should -BeExactly 'PREREQ_PR_NOT_FOUND'
    }

    It 'never matches a main-sync PR (AC2.2)' {
        $sync = & $script:Pr 50 'chore/epic-1188-main-sync-2' @('docs/features/active/2026-11-01-provider-1188/spec.md')

        $alone = Get-EpicCrossDependencyPrerequisitePr -SnapshotJson (& $script:Snapshot @($sync)) -IssueNum '1188' -FeatureFolder '2026-11-01-provider-1188'
        $withChild = Get-EpicCrossDependencyPrerequisitePr -SnapshotJson (& $script:Snapshot @($sync, (& $script:Pr 51 'feature/provider-1188'))) -IssueNum '1188' -FeatureFolder '2026-11-01-provider-1188'

        $alone.Status | Should -BeExactly 'PREREQ_PR_NOT_FOUND'
        "$($withChild.Status)|$($withChild.Number)" | Should -BeExactly 'match|51'
    }

    It 'returns PREREQ_PR_NOT_FOUND for an empty snapshot' {
        (Get-EpicCrossDependencyPrerequisitePr -SnapshotJson '[]' -IssueNum '1188' -FeatureFolder 'f').Status | Should -BeExactly 'PREREQ_PR_NOT_FOUND'
    }

    It 'returns PREREQ_SNAPSHOT_INVALID for <Name>' -ForEach @(
        @{ Name = 'text that is not JSON'; Json = '{not json' }
        @{ Name = 'a JSON object root'; Json = '{"number":1}' }
        @{ Name = 'a non-object element'; Json = '[1]' }
        @{ Name = 'a missing number'; Json = '[{"headRefName":"a","mergeCommit":{"oid":"x"},"files":[]}]' }
        @{ Name = 'a null mergeCommit'; Json = '[{"number":1,"headRefName":"a","mergeCommit":null,"files":[]}]' }
        @{ Name = 'a missing headRefName'; Json = '[{"number":1,"mergeCommit":{"oid":"x"},"files":[]}]' }
        @{ Name = 'a missing files list'; Json = '[{"number":1,"headRefName":"a","mergeCommit":{"oid":"x"}}]' }
        @{ Name = 'a file without a path'; Json = '[{"number":1,"headRefName":"a","mergeCommit":{"oid":"x"},"files":[{"additions":1}]}]' }
        @{ Name = 'empty text'; Json = '' }
    ) {
        (Get-EpicCrossDependencyPrerequisitePr -SnapshotJson $Json -IssueNum '1188' -FeatureFolder 'f').Status | Should -BeExactly 'PREREQ_SNAPSHOT_INVALID'
    }

    It 'matches by token only when the feature folder is blank' {
        $snapshot = & $script:Snapshot @((& $script:Pr 41 'feature/x' @('docs/features/active/f/a.md')), (& $script:Pr 42 'feature/x-1188'))
        (Get-EpicCrossDependencyPrerequisitePr -SnapshotJson $snapshot -IssueNum '1188' -FeatureFolder '').Number | Should -Be 42
    }
}

Describe 'Get-EpicCrossDependencyFeatureDecision rows' {
    It 'row <Row>: <Name> gives <Decision> with <Reason>' -ForEach @(
        @{ Row = 1; Name = 'an adapter error'; Override = @{ AdapterError = $true }; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Row = 1; Name = 'no match record'; Override = @{ Match = $null }; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Row = 1; Name = 'an invalid snapshot'; Override = @{ Match = [pscustomobject]@{ Status = 'PREREQ_SNAPSHOT_INVALID' } }; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Row = 1; Name = 'an ancestry exit of 128'; Override = @{ OtherAncestorExit = 128 }; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Row = 2; Name = 'an absent branch whose commit is in main'; Override = @{ OtherBranchPresent = $false; OtherAncestorExit = $null; OwnAncestorExit = $null; MainAncestorExit = 0 }; Decision = 'release'; Reason = 'PREREQ_IN_MAIN' }
        @{ Row = 3; Name = 'no matching merged PR'; Override = @{ Match = [pscustomobject]@{ Status = 'PREREQ_PR_NOT_FOUND' }; OtherAncestorExit = $null }; Decision = 'hold'; Reason = 'PREREQ_PR_NOT_FOUND' }
        @{ Row = 4; Name = 'two matching PRs'; Override = @{ Match = [pscustomobject]@{ Status = 'PREREQ_PR_AMBIGUOUS' }; OtherAncestorExit = $null }; Decision = 'hold'; Reason = 'PREREQ_PR_AMBIGUOUS' }
        @{ Row = 5; Name = 'a commit missing from the other branch'; Override = @{ OtherAncestorExit = 1; OwnAncestorExit = $null }; Decision = 'hold'; Reason = 'PREREQ_NOT_ANCESTOR' }
        @{ Row = 5; Name = 'an absent branch whose commit is not in main'; Override = @{ OtherBranchPresent = $false; OtherAncestorExit = $null; OwnAncestorExit = $null; MainAncestorExit = 1 }; Decision = 'hold'; Reason = 'PREREQ_NOT_ANCESTOR' }
        @{ Row = 6; Name = 'a commit already in the own branch'; Override = @{ OwnAncestorExit = 0 }; Decision = 'release'; Reason = 'PREREQ_ALREADY_INTEGRATED' }
        @{ Row = 7; Name = 'a merged prerequisite not yet integrated'; Override = @{}; Decision = 'merge_required'; Reason = 'PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED' }
    ) {
        $result = Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence @(& $script:Evidence $Override) -EvaluatedAt 'T'

        "$($result.Decision)|$($result.Reason)" | Should -BeExactly "$Decision|$Reason"
        $result.Edges[0].Reason | Should -BeExactly $Reason
    }

    It 'applies the first matching row: <Name>' -ForEach @(
        @{ Name = 'an adapter error outranks a release in main'; Override = @{ AdapterError = $true; OtherBranchPresent = $false; MainAncestorExit = 0 }; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'a bad own-branch exit outranks integration'; Override = @{ OwnAncestorExit = 2 }; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'release in main outranks not-ancestor for an absent branch'; Override = @{ OtherBranchPresent = $false; OtherAncestorExit = $null; MainAncestorExit = 0 }; Reason = 'PREREQ_IN_MAIN' }
        @{ Name = 'not found outranks an ancestry result'; Override = @{ Match = [pscustomobject]@{ Status = 'PREREQ_PR_NOT_FOUND' }; OtherAncestorExit = 1 }; Reason = 'PREREQ_PR_NOT_FOUND' }
        @{ Name = 'not-ancestor outranks an own-branch ancestor'; Override = @{ OtherAncestorExit = 1; OwnAncestorExit = 0 }; Reason = 'PREREQ_NOT_ANCESTOR' }
    ) {
        (Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence @(& $script:Evidence $Override)).Reason | Should -BeExactly $Reason
    }

    It 'records the matched PR number, merge commit, and evaluation time on each edge' {
        $edge = (Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence @(& $script:Evidence) -EvaluatedAt '2026-11-10T00:00:00Z').Edges[0]

        "$($edge.Epic)|$($edge.IssueNum)|$($edge.PrNumber)|$($edge.MergeCommitSha)|$($edge.EvaluatedAt)" | Should -BeExactly 'provider-epic|1188|7|abc|2026-11-10T00:00:00Z'
    }

    It 'records no PR evidence for an unmatched edge' {
        $edge = (Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence @(& $script:Evidence @{ Match = [pscustomobject]@{ Status = 'PREREQ_PR_NOT_FOUND' } })).Edges[0]

        $edge.PrNumber | Should -BeNullOrEmpty
        $edge.MergeCommitSha | Should -BeExactly ''
    }
}

Describe 'Get-EpicCrossDependencyFeatureDecision aggregation' {
    It 'releases with NO_CROSS_EPIC_EDGE when the feature has no edge' {
        $result = Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence @()

        "$($result.Issue)|$($result.Decision)|$($result.Reason)|$($result.Edges.Count)" | Should -BeExactly '1201|release|NO_CROSS_EPIC_EDGE|0'
    }

    It 'holds when any edge holds, with the first held reason' {
        $evidence = @((& $script:Evidence @{ OwnAncestorExit = 0 }), (& $script:Evidence @{ AdapterError = $true }), (& $script:Evidence @{ OtherAncestorExit = 1 }))
        $result = Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence $evidence

        "$($result.Decision)|$($result.Reason)|$($result.MergeBranches.Count)" | Should -BeExactly 'hold|PREREQ_UNVERIFIABLE|0'
    }

    It 'lists the distinct integration branches to merge when no edge holds' {
        $evidence = @(
            (& $script:Evidence @{ OwnAncestorExit = 0 })
            (& $script:Evidence @{ IssueNum = '1189' })
            (& $script:Evidence @{ IssueNum = '1190' })
            (& $script:Evidence @{ Epic = 'other'; IntegrationBranch = 'epic/other-integration'; IssueNum = '7' })
        )
        $result = Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence $evidence

        $result.Decision | Should -BeExactly 'merge_required'
        $result.Reason | Should -BeExactly 'PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED'
        $result.MergeBranches -join ',' | Should -BeExactly 'epic/provider-epic-integration,epic/other-integration'
    }

    It 'releases when every edge releases, with the first edge reason' {
        $evidence = @((& $script:Evidence @{ OtherBranchPresent = $false; OtherAncestorExit = $null; MainAncestorExit = 0 }), (& $script:Evidence @{ OwnAncestorExit = 0 }))
        $result = Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence $evidence

        "$($result.Decision)|$($result.Reason)" | Should -BeExactly 'release|PREREQ_IN_MAIN'
    }
}

Describe 'Get-EpicCrossDependencyMainGateDecision' {
    BeforeAll {
        $script:MainEvidence = {
            param([hashtable] $Override = @{})
            $value = @{ Epic = 'provider-epic'; IntegrationBranch = 'epic/provider-epic-integration'; AdapterError = $false; SnapshotJson = '[{"number":90,"mergeCommit":{"oid":"m90"}}]'; AncestorExit = 0 }
            foreach ($key in $Override.Keys) { $value[$key] = $Override[$key] }
            $value
        }
    }

    It 'row <Row>: <Name> gives <Reason>' -ForEach @(
        @{ Row = 1; Name = 'an adapter error'; Override = @{ AdapterError = $true }; Reason = 'MAIN_PREREQ_UNVERIFIABLE' }
        @{ Row = 1; Name = 'an invalid snapshot'; Override = @{ SnapshotJson = '[{"number":"x"}]' }; Reason = 'MAIN_PREREQ_UNVERIFIABLE' }
        @{ Row = 1; Name = 'an ancestry exit of 128'; Override = @{ AncestorExit = 128 }; Reason = 'MAIN_PREREQ_UNVERIFIABLE' }
        @{ Row = 2; Name = 'no merged PR into main'; Override = @{ SnapshotJson = '[]'; AncestorExit = $null }; Reason = 'MAIN_PREREQ_PR_NOT_MERGED' }
        @{ Row = 3; Name = 'two merged PRs'; Override = @{ SnapshotJson = '[{"number":1,"mergeCommit":{"oid":"a"}},{"number":2,"mergeCommit":{"oid":"b"}}]' }; Reason = 'MAIN_PREREQ_PR_AMBIGUOUS' }
        @{ Row = 4; Name = 'a merge commit outside origin/main'; Override = @{ AncestorExit = 1 }; Reason = 'MAIN_PREREQ_NOT_ANCESTOR' }
        @{ Row = 5; Name = 'a merged PR in origin/main'; Override = @{}; Reason = 'MAIN_PREREQ_RELEASED' }
    ) {
        $result = Get-EpicCrossDependencyMainGateDecision -Evidence @(& $script:MainEvidence $Override)

        $result.Epics[0].Reason | Should -BeExactly $Reason
        $result.Decision | Should -BeExactly $(if ($Reason -eq 'MAIN_PREREQ_RELEASED') { 'release' } else { 'hold' })
    }

    It 'gives not_applicable without a prerequisite epic' {
        $result = Get-EpicCrossDependencyMainGateDecision -Evidence @()
        "$($result.Decision)|$($result.Reason)|$($result.Epics.Count)" | Should -BeExactly 'not_applicable|NO_CROSS_EPIC_EDGE|0'
    }

    It 'holds when any epic holds, with the first held reason' {
        $evidence = @((& $script:MainEvidence), (& $script:MainEvidence @{ Epic = 'b'; SnapshotJson = '[]' }), (& $script:MainEvidence @{ Epic = 'c'; AncestorExit = 1 }))
        $result = Get-EpicCrossDependencyMainGateDecision -Evidence $evidence

        "$($result.Decision)|$($result.Reason)" | Should -BeExactly 'hold|MAIN_PREREQ_PR_NOT_MERGED'
    }

    It 'releases when every epic released and records the PR evidence' {
        $result = Get-EpicCrossDependencyMainGateDecision -Evidence @((& $script:MainEvidence), (& $script:MainEvidence @{ Epic = 'b' })) -EvaluatedAt 'T1'

        "$($result.Decision)|$($result.Reason)" | Should -BeExactly 'release|MAIN_PREREQ_RELEASED'
        "$($result.Epics[0].PrNumber)|$($result.Epics[0].MergeCommitSha)|$($result.Epics[0].EvaluatedAt)" | Should -BeExactly '90|m90|T1'
    }
}

Describe 'Pure function isolation' {
    It 'calls no wrapper, clock, or sleep seam' {
        InModuleScope EpicCrossDependency -Parameters @{ Text = (& $script:ManifestText 'consumer' @('  - issue_num: 1201', '    depends_on: []', "    cross_epic_depends_on: $($script:ProviderEdge)")) } {
            param($Text)
            Mock Invoke-EpicCrossGhExe { throw 'gh called' }
            Mock Invoke-EpicCrossGitExe { throw 'git called' }
            Mock Get-EpicCrossUtcNow { throw 'clock called' }
            Mock Wait-EpicCrossInterval { throw 'sleep called' }

            $manifest = ConvertFrom-EpicCrossDependencyManifest -Text $Text
            $null = Get-EpicCrossDependencyManifestError -Manifest $manifest -OtherManifest @{}
            $null = Get-EpicCrossDependencyPrerequisitePr -SnapshotJson '[]' -IssueNum '1188' -FeatureFolder 'f'
            $null = Get-EpicCrossDependencyFeatureDecision -Issue '1201' -Evidence @(@{ AdapterError = $true })
            $null = Get-EpicCrossDependencyMainGateDecision -Evidence @(@{ AdapterError = $true })

            Should -Invoke Invoke-EpicCrossGhExe -Times 0 -Exactly
            Should -Invoke Invoke-EpicCrossGitExe -Times 0 -Exactly
            Should -Invoke Get-EpicCrossUtcNow -Times 0 -Exactly
            Should -Invoke Wait-EpicCrossInterval -Times 0 -Exactly
        }
    }
}
