#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the review_due checks of the page checker (issue #1220).

.DESCRIPTION
    Runs Test-DocsPageFrontMatter over in-memory front matter: review_due is a known field, its
    format and calendar date are checked, and it must be later than last_reviewed when both are
    calendar dates. One context runs Invoke-DocsCheckCommand over in-memory pages with a context
    whose UtcNow member throws, so the check reads no clock. No file is written.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibraryRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageCheck.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instances that DocsPageCheck imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageFrontMatter.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:PagePath = 'docs/guide.md'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'

    function Invoke-TestFrontMatter {
        # Runs Test-DocsPageFrontMatter over front matter with last_reviewed and, when given, review_due.
        param([AllowNull()] [string] $LastReviewed = '2026-01-10', [AllowNull()] [string] $ReviewDue)
        $frontMatter = @{ owner = 'team-docs'; last_reviewed = $LastReviewed; audience = @('developers'); diataxis_mode = 'explanation'; surface_refs = @() }
        if ($PSBoundParameters.ContainsKey('ReviewDue')) { $frontMatter['review_due'] = $ReviewDue }
        @(Test-DocsPageFrontMatter -FrontMatter $frontMatter -PagePath $script:PagePath -ComposedSchemaSet $script:Composed -RequiredField @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs') -AudienceId @('developers'))
    }

    function Get-TestReviewFinding {
        param([object[]] $Finding)
        , @($Finding | Where-Object { ([string] $_.code).StartsWith('DOCS_PAGE_REVIEW_DUE_', [System.StringComparison]::Ordinal) })
    }
}

AfterAll {
    foreach ($name in 'Invoke-TestFrontMatter', 'Get-TestReviewFinding') { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
    Remove-Module -Name DocsPageCheck, DocsPageOrphans, DocsPageDiataxis, DocsPageLinks, DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsProfile, DocsProfileFamilies, DocsProfileSourceRoot, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Test-DocsPageFrontMatter review_due' {
    It 'accepts last_reviewed 2026-01-10 with review_due 2026-04-10: no DOCS_PAGE_FIELD_UNKNOWN and no review-date finding' {
        # Act
        $findings = Invoke-TestFrontMatter -ReviewDue '2026-04-10'

        # Assert
        @($findings | Where-Object { $_.code -ceq 'DOCS_PAGE_FIELD_UNKNOWN' }).Count | Should -Be 0
        @($findings | Where-Object { $_.code -like 'DOCS_PAGE_LAST_REVIEWED_*' }).Count | Should -Be 0
        (Get-TestReviewFinding -Finding $findings).Count | Should -Be 0
        $findings.Count | Should -Be 0 -Because (@($findings | ForEach-Object { $_.code }) -join ', ')
    }

    It 'reports <Code> at /review_due with severity error for review_due <ReviewDue>' -ForEach @(
        @{ ReviewDue = '2026/04/10'; Code = 'DOCS_PAGE_REVIEW_DUE_INVALID' }
        @{ ReviewDue = '2026-02-30'; Code = 'DOCS_PAGE_REVIEW_DUE_NOT_A_DATE' }
        @{ ReviewDue = '2026-01-10'; Code = 'DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED' }
        @{ ReviewDue = '2026-01-09'; Code = 'DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED' }
    ) {
        # Act
        $review = Get-TestReviewFinding -Finding (Invoke-TestFrontMatter -ReviewDue $ReviewDue)

        # Assert
        @($review | ForEach-Object { $_.code }) | Should -Be @($Code)
        $review[0].severity | Should -BeExactly 'error'
        $review[0].pointer | Should -BeExactly '/review_due'
        $review[0].artifact_path | Should -BeExactly $script:PagePath
        [string]::IsNullOrWhiteSpace($review[0].next_action) | Should -BeFalse
    }

    It 'reports no review-date finding for review_due 2026-01-11' {
        # Act / Assert
        (Get-TestReviewFinding -Finding (Invoke-TestFrontMatter -ReviewDue '2026-01-11')).Count | Should -Be 0
    }

    It 'emits no ordering finding when <Case>' -ForEach @(
        @{ Case = 'last_reviewed is not a calendar date'; LastReviewed = '2026-02-30'; ReviewDue = '2026-01-01'; Expected = @() }
        @{ Case = 'last_reviewed has the wrong format'; LastReviewed = '2026/01/10'; ReviewDue = '2026-01-01'; Expected = @() }
        @{ Case = 'review_due is not a calendar date'; LastReviewed = '2026-03-10'; ReviewDue = '2026-02-30'; Expected = @('DOCS_PAGE_REVIEW_DUE_NOT_A_DATE') }
        @{ Case = 'review_due has the wrong format'; LastReviewed = '2026-03-10'; ReviewDue = '2026/01/01'; Expected = @('DOCS_PAGE_REVIEW_DUE_INVALID') }
    ) {
        # Act
        $review = Get-TestReviewFinding -Finding (Invoke-TestFrontMatter -LastReviewed $LastReviewed -ReviewDue $ReviewDue)

        # Assert
        @($review | ForEach-Object { $_.code }) | Should -Be $Expected
    }
}

Describe 'Invoke-DocsCheckCommand review_due ordering' {
    It 'reports DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED for a page whose review_due equals last_reviewed and reads no clock' {
        # Arrange
        $profileValue = (ConvertFrom-DocsJsonText -Text (Get-Content -LiteralPath (Join-Path -Path $script:RepositoryRoot -ChildPath 'examples/docs/v1/docs-profile.example.json') -Raw)).Value
        $profileValue['audiences'] = @([ordered]@{ id = 'developers'; description = 'People who change the code.' })
        $profileValue['documentation_roots'] = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') })
        $profileValue['diataxis_policy']['modes'] = @('tutorial', 'how-to', 'reference', 'explanation')
        $profileValue['diataxis_policy']['directory_modes'] = @()
        $head = "---`nowner: `"team-docs`"`nlast_reviewed: `"2026-01-10`"`naudience: [`"developers`"]`ndiataxis_mode: `"explanation`"`nsurface_refs: []`n"
        $files = @{
            $script:ProfilePath = (ConvertTo-DocsJsonText -Value $profileValue -Indented)
            'docs/README.md'    = $head + "---`n# Documentation`n- [Guide](guide.md)`n"
            'docs/guide.md'     = $head + "review_due: `"2026-01-10`"`n---`n# Guide`nText.`n"
        }
        $test = New-DocsTestContext -File $files
        $test.Context.UtcNow = { throw 'check must not read the clock' }

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        $review = @($result.Findings | Where-Object { $_.code -ceq 'DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED' })
        $review.Count | Should -Be 1
        $review[0].artifact_path | Should -BeExactly 'docs/guide.md'
        $review[0].pointer | Should -BeExactly '/review_due'
        @($result.Findings | Where-Object { $_.code -cne 'DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED' }).Count | Should -Be 0 -Because (@($result.Findings | ForEach-Object { $_.code }) -join ', ')
    }
}
