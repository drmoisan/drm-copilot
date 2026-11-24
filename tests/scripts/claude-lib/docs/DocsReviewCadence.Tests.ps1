#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit and property tests for .claude/lib/docs/DocsReviewCadence.psm1 (issue #1220).

.DESCRIPTION
    Covers the review date parser, the reference date of the command instant, the family
    interval lookup, the effective due date, the page front-matter reader, the overdue findings
    and their severity. Every family and legacy-exclusion case passes in-memory arrays directly
    to the pure functions and never loads a profile; page text is supplied through an in-memory
    ReadText scriptblock. An AST test checks that the review cadence module and the changed docs
    lib modules read no wall clock. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsReviewCadence.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Runbook = 'docs/operations/runbook.md'

    function Get-TestFamily {
        # One in-memory documentation family record.
        param([string] $Directory, [object] $Interval, [switch] $NoInterval)
        $family = [ordered]@{ id = 'family'; directory = $Directory; diataxis_mode = 'how-to'; template = 'runbook'; audience = @('operators'); required = $true }
        if (-not $NoInterval) { $family['review_interval_days'] = $Interval }
        $family
    }

    function Get-TestFrontMatter {
        # A front-matter table with the given date fields.
        param([string] $LastReviewed, [string] $ReviewDue)
        $table = @{ owner = 'team-docs' }
        if ($PSBoundParameters.ContainsKey('LastReviewed')) { $table['last_reviewed'] = $LastReviewed }
        if ($PSBoundParameters.ContainsKey('ReviewDue')) { $table['review_due'] = $ReviewDue }
        $table
    }

    function Get-TestPageMap {
        # An ordinal page-path map built from alternating path and front-matter values.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Page paths are case-sensitive; an ordinal-comparer hashtable is required.')]
        param([object[]] $Pair)
        $map = [hashtable]::new([System.StringComparer]::Ordinal)
        for ($index = 0; $index -lt $Pair.Count; $index += 2) { $map[[string] $Pair[$index]] = $Pair[$index + 1] }
        $map
    }

    function Get-TestUtcDate {
        # The UTC-kind date of a yyyy-MM-dd text.
        param([string] $Text)
        [datetime]::SpecifyKind([datetime]::ParseExact($Text, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture), [System.DateTimeKind]::Utc)
    }
}

AfterAll {
    foreach ($name in 'Get-TestFamily', 'Get-TestFrontMatter', 'Get-TestPageMap', 'Get-TestUtcDate') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'DocsReviewCadence', 'DocsPageFrontMatter', 'DocsPageMetadata', 'DocsPageMarkdown', 'DocsSchema', 'DocsSchemaWalk', 'DocsFinding', 'DocsJson', 'DocsLedger.TestSupport', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-DocsReviewDate' {
    It 'returns a UTC-kind date for 2026-04-10' {
        # Act
        $date = ConvertFrom-DocsReviewDate -Value '2026-04-10'

        # Assert
        $date | Should -BeOfType [datetime]
        $date.Kind | Should -Be ([System.DateTimeKind]::Utc)
        $date | Should -Be (Get-TestUtcDate -Text '2026-04-10')
    }

    It 'returns $null for <Value>' -ForEach @(
        @{ Value = '2026-02-30' }
        @{ Value = '2026/04/10' }
        @{ Value = '' }
        @{ Value = '2026-04-10x' }
    ) {
        # Act / Assert
        ConvertFrom-DocsReviewDate -Value $Value | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsReviewReferenceDate' {
    It 'returns the UTC date 2026-04-11 for 2026-04-11T23:59:59Z' {
        # Act
        $date = Get-DocsReviewReferenceDate -IssuedAt '2026-04-11T23:59:59Z'

        # Assert
        $date | Should -Be (Get-TestUtcDate -Text '2026-04-11')
        $date.Kind | Should -Be ([System.DateTimeKind]::Utc)
    }

    It 'throws DOCS_REVIEW_CLOCK_INVALID for <IssuedAt>' -ForEach @(
        @{ IssuedAt = '2026-04-11' }
        @{ IssuedAt = '2026-04-11T23:59:59+01:00' }
        @{ IssuedAt = '2026-02-30T08:00:00Z' }
        @{ IssuedAt = '' }
    ) {
        # Act / Assert
        { Get-DocsReviewReferenceDate -IssuedAt $IssuedAt } | Should -Throw -ExpectedMessage '*DOCS_REVIEW_CLOCK_INVALID*'
    }
}

Describe 'Get-DocsReviewIntervalDays' {
    It 'selects the longest covering directory at a / boundary' {
        # Arrange
        $family = @((Get-TestFamily -Directory 'docs' -Interval 30L), (Get-TestFamily -Directory 'docs/operations/' -Interval 90L), (Get-TestFamily -Directory 'docs/ops' -Interval 7L))

        # Act / Assert
        Get-DocsReviewIntervalDays -PagePath $script:Runbook -Family $family | Should -Be 90
        Get-DocsReviewIntervalDays -PagePath 'docs/guide.md' -Family $family | Should -Be 30
    }

    It 'does not match docs/ops against docs/operations/runbook.md' {
        # Act / Assert
        Get-DocsReviewIntervalDays -PagePath $script:Runbook -Family @((Get-TestFamily -Directory 'docs/ops' -Interval 7L)) | Should -BeNullOrEmpty
    }

    It 'compares directories ordinally and case-sensitively' {
        # Act / Assert
        Get-DocsReviewIntervalDays -PagePath $script:Runbook -Family @((Get-TestFamily -Directory 'docs/Operations' -Interval 90L)) | Should -BeNullOrEmpty
    }

    It 'accepts an Int32 interval' {
        # Act / Assert
        Get-DocsReviewIntervalDays -PagePath $script:Runbook -Family @((Get-TestFamily -Directory 'docs/operations' -Interval 14)) | Should -Be 14
    }

    It 'returns $null for <Case>' -ForEach @(
        @{ Case = 'an empty family list'; Family = @() }
        @{ Case = 'a $null family list'; Family = $null }
        @{ Case = 'an entry that is not a table'; Family = @('docs/operations') }
        @{ Case = 'a directory that is not a string'; Family = @([ordered]@{ directory = 5; review_interval_days = 90L }) }
    ) {
        # Act / Assert
        Get-DocsReviewIntervalDays -PagePath $script:Runbook -Family $Family | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsPageReviewDue' {
    It 'returns the explicit review_due with Source review_due even when a matching family defines an interval' {
        # Arrange
        $frontMatter = Get-TestFrontMatter -LastReviewed '2026-01-10' -ReviewDue '2026-02-01'

        # Act
        $due = Get-DocsPageReviewDue -FrontMatter $frontMatter -PagePath $script:Runbook -Family @((Get-TestFamily -Directory 'docs/operations' -Interval 90L))

        # Assert
        $due.Source | Should -BeExactly 'review_due'
        $due.DueDate | Should -Be (Get-TestUtcDate -Text '2026-02-01')
    }

    It 'derives 2026-04-10 with Source interval for docs/operations/runbook.md, last_reviewed 2026-01-10 and interval 90' {
        # Act
        $due = Get-DocsPageReviewDue -FrontMatter (Get-TestFrontMatter -LastReviewed '2026-01-10') -PagePath $script:Runbook -Family @((Get-TestFamily -Directory 'docs/operations' -Interval 90L))

        # Assert
        $due.Source | Should -BeExactly 'interval'
        $due.DueDate | Should -Be (Get-TestUtcDate -Text '2026-04-10')
        $due.DueDate.Kind | Should -Be ([System.DateTimeKind]::Utc)
    }

    It 'returns a $null due date for <Case>' -ForEach @(
        @{ Case = 'an empty family list'; Family = @(); LastReviewed = '2026-01-10' }
        @{ Case = 'no covering family'; Family = @(@{ directory = 'docs/security'; review_interval_days = 90L }); LastReviewed = '2026-01-10' }
        @{ Case = 'an absent interval'; Family = @(@{ directory = 'docs/operations' }); LastReviewed = '2026-01-10' }
        @{ Case = 'a non-integer interval'; Family = @(@{ directory = 'docs/operations'; review_interval_days = 90.5 }); LastReviewed = '2026-01-10' }
        @{ Case = 'a string interval'; Family = @(@{ directory = 'docs/operations'; review_interval_days = '90' }); LastReviewed = '2026-01-10' }
        @{ Case = 'a zero interval'; Family = @(@{ directory = 'docs/operations'; review_interval_days = 0L }); LastReviewed = '2026-01-10' }
        @{ Case = 'a negative interval'; Family = @(@{ directory = 'docs/operations'; review_interval_days = -5L }); LastReviewed = '2026-01-10' }
        @{ Case = 'an invalid last_reviewed'; Family = @(@{ directory = 'docs/operations'; review_interval_days = 90L }); LastReviewed = '2026-02-30' }
    ) {
        # Act
        $due = Get-DocsPageReviewDue -FrontMatter (Get-TestFrontMatter -LastReviewed $LastReviewed) -PagePath $script:Runbook -Family $Family

        # Assert
        $due.DueDate | Should -BeNullOrEmpty
        $due.Source | Should -BeNullOrEmpty
    }

    It 'returns a $null due date for an invalid explicit review_due instead of the family interval' {
        # Act
        $due = Get-DocsPageReviewDue -FrontMatter (Get-TestFrontMatter -LastReviewed '2026-01-10' -ReviewDue '2026/04/10') -PagePath $script:Runbook -Family @((Get-TestFamily -Directory 'docs/operations' -Interval 90L))

        # Assert
        $due.DueDate | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsReviewPageFrontMatter' {
    It 'keeps only .md pages whose front matter parses, and reads each once' {
        # Arrange
        $files = @{
            'docs/a.md'      = "---`nowner: `"team-docs`"`nlast_reviewed: `"2026-01-10`"`n---`n# A`n"
            'docs/b.md'      = "# No front matter`n"
            'docs/c.md'      = "---`nowner: [`n---`n"
            'docs/notes.txt' = "---`nowner: `"team-docs`"`n---`n"
        }
        $test = New-DocsLedgerTestContext -File $files

        # Act
        $result = Get-DocsReviewPageFrontMatter -PagePath @('docs/a.md', 'docs/b.md', 'docs/c.md', 'docs/notes.txt', 'docs/a.md', '') -ReadText $test.Context.ReadText

        # Assert
        @($result.Keys) | Should -Be @('docs/a.md')
        $result['docs/a.md']['last_reviewed'] | Should -BeExactly '2026-01-10'
        @($test.CallLog | Where-Object { $_.Member -ceq 'ReadText' } | ForEach-Object { $_.RelativePath }) | Should -Be @('docs/a.md', 'docs/b.md', 'docs/c.md')
    }

    It 'returns an empty table for a $null page list' {
        # Act
        $result = Get-DocsReviewPageFrontMatter -PagePath $null -ReadText { throw 'not read' }

        # Assert
        $result.Count | Should -Be 0
    }

    It 'propagates a read failure' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{} -ReadBytesFailure @{ 'docs/a.md' = 'disk error' }

        # Act / Assert
        { Get-DocsReviewPageFrontMatter -PagePath @('docs/a.md') -ReadText $test.Context.ReadText } | Should -Throw -ExpectedMessage '*disk error*'
    }
}

Describe 'Get-DocsReviewOverdueFinding' {
    BeforeAll {
        $script:Family = @((Get-TestFamily -Directory 'docs/operations' -Interval 90L))
        $script:Explicit = Get-TestPageMap -Pair @('docs/guide/page.md', (Get-TestFrontMatter -LastReviewed '2026-01-10' -ReviewDue '2026-04-10'))
        $script:Derived = Get-TestPageMap -Pair @($script:Runbook, (Get-TestFrontMatter -LastReviewed '2026-01-10'))
    }

    It 'emits exactly one DOCS_REVIEW_OVERDUE at reference date 2026-04-11 for a page due 2026-04-10' {
        # Act
        $findings = Get-DocsReviewOverdueFinding -PageFrontMatter $script:Explicit -Family @() -LegacyExclusion @() -ReferenceDate (Get-TestUtcDate -Text '2026-04-11') -Severity 'warning'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['code'] | Should -BeExactly 'DOCS_REVIEW_OVERDUE'
        $findings[0]['severity'] | Should -BeExactly 'warning'
        $findings[0]['artifact_path'] | Should -BeExactly 'docs/guide/page.md'
        $findings[0]['pointer'] | Should -BeExactly '/review_due'
        $findings[0]['next_action'] | Should -BeExactly 'Review the page, then update last_reviewed and review_due.'
        $findings[0]['message'] | Should -BeLike '*2026-04-10*'
        $findings[0]['message'] | Should -BeLike '*source review_due*'
        $findings[0]['message'] | Should -BeLike '*2026-04-11*'
    }

    It 'emits no finding at reference date 2026-04-10, the due date' {
        # Act
        $findings = Get-DocsReviewOverdueFinding -PageFrontMatter $script:Explicit -ReferenceDate (Get-TestUtcDate -Text '2026-04-10')

        # Assert
        $findings.Count | Should -Be 0
    }

    It 'points a derived due date at /last_reviewed and names source interval' {
        # Act
        $findings = Get-DocsReviewOverdueFinding -PageFrontMatter $script:Derived -Family $script:Family -ReferenceDate (Get-TestUtcDate -Text '2026-04-11') -Severity 'error'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/last_reviewed'
        $findings[0]['severity'] | Should -BeExactly 'error'
        $findings[0]['message'] | Should -BeLike '*source interval*'
    }

    It 'emits no finding for <Case>' -ForEach @(
        @{ Case = 'an empty family list'; Family = @() }
        @{ Case = 'no covering family'; Family = @(@{ directory = 'docs/security'; review_interval_days = 90L }) }
        @{ Case = 'an absent interval'; Family = @(@{ directory = 'docs/operations' }) }
        @{ Case = 'a non-integer interval'; Family = @(@{ directory = 'docs/operations'; review_interval_days = 'ninety' }) }
        @{ Case = 'an interval below 1'; Family = @(@{ directory = 'docs/operations'; review_interval_days = 0L }) }
    ) {
        # Act
        $findings = Get-DocsReviewOverdueFinding -PageFrontMatter $script:Derived -Family $Family -ReferenceDate (Get-TestUtcDate -Text '2027-01-01')

        # Assert
        $findings.Count | Should -Be 0
    }

    It 'skips a page listed in the legacy exclusions' {
        # Act
        $findings = Get-DocsReviewOverdueFinding -PageFrontMatter $script:Derived -Family $script:Family -LegacyExclusion @($script:Runbook) -ReferenceDate (Get-TestUtcDate -Text '2027-01-01')

        # Assert
        $findings.Count | Should -Be 0
    }

    It 'skips a page whose review_due is not later than last_reviewed' {
        # Arrange
        $pages = Get-TestPageMap -Pair @('docs/a.md', (Get-TestFrontMatter -LastReviewed '2026-01-10' -ReviewDue '2026-01-10'))

        # Act
        $findings = Get-DocsReviewOverdueFinding -PageFrontMatter $pages -ReferenceDate (Get-TestUtcDate -Text '2027-01-01')

        # Assert
        $findings.Count | Should -Be 0
    }

    It 'returns no finding for a $null page map and orders findings by page path' {
        # Arrange
        $due = Get-TestFrontMatter -LastReviewed '2026-01-10' -ReviewDue '2026-02-01'
        $pages = Get-TestPageMap -Pair @('docs/b.md', $due, 'docs/B.md', $due, 'docs/a.md', $due, 'docs/x.md', 'not a table')

        # Act
        $none = Get-DocsReviewOverdueFinding -PageFrontMatter $null -ReferenceDate (Get-TestUtcDate -Text '2027-01-01')
        $findings = Get-DocsReviewOverdueFinding -PageFrontMatter $pages -ReferenceDate (Get-TestUtcDate -Text '2027-01-01')

        # Assert
        $none.Count | Should -Be 0
        @($findings | ForEach-Object { $_['artifact_path'] }) | Should -Be @('docs/B.md', 'docs/a.md', 'docs/b.md')
    }
}

Describe 'Get-DocsReviewOverdueSeverity' {
    It 'returns <Expected> for <Case>' -ForEach @(
        @{ Case = 'block_overdue_review true'; Gate = @{ block_overdue_review = $true }; Expected = 'error' }
        @{ Case = 'block_overdue_review false'; Gate = @{ block_overdue_review = $false }; Expected = 'warning' }
        @{ Case = 'an absent key'; Gate = @{ allow_deferred = $true }; Expected = 'warning' }
        @{ Case = 'a string true'; Gate = @{ block_overdue_review = 'true' }; Expected = 'warning' }
        @{ Case = 'the number 1'; Gate = @{ block_overdue_review = 1L }; Expected = 'warning' }
        @{ Case = 'a $null gate'; Gate = $null; Expected = 'warning' }
    ) {
        # Act / Assert
        Get-DocsReviewOverdueSeverity -Gate $Gate | Should -BeExactly $Expected
    }
}

Describe 'DocsReviewCadence properties' {
    It 'property Get-DocsPageReviewDue: the derived due date is last_reviewed plus the interval (seed <_>)' -ForEach @(11, 1023, 65537) {
        # Arrange
        $seed = $_
        $random = [System.Random]::new($seed)

        for ($round = 0; $round -lt 50; $round++) {
            $start = [datetime]::new(2000, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc).AddDays($random.Next(0, 10000))
            $interval = [long] $random.Next(1, 1000)
            $lastReviewed = $start.ToString('yyyy-MM-dd', [cultureinfo]::InvariantCulture)

            # Act
            $due = Get-DocsPageReviewDue -FrontMatter (Get-TestFrontMatter -LastReviewed $lastReviewed) -PagePath $script:Runbook -Family @((Get-TestFamily -Directory 'docs/operations' -Interval $interval))

            # Assert
            $due.Source | Should -BeExactly 'interval' -Because "seed $seed round $round"
            $due.DueDate | Should -Be $start.AddDays($interval) -Because "seed $seed round $round last_reviewed $lastReviewed interval $interval"
        }
    }
}

Describe 'Wall-clock reads' {
    It 'finds no Get-Date command and no static Now or UtcNow member in <Module>' -ForEach @(
        @{ Module = 'DocsReviewCadence' }
        @{ Module = 'DocsPageMetadata' }
        @{ Module = 'DocsPageFrontMatter' }
        @{ Module = 'DocsValidation' }
        @{ Module = 'DocsValidateCommands' }
        @{ Module = 'DocsReferenceFrontMatter' }
    ) {
        # Arrange
        $path = Join-Path -Path $script:LibraryRoot -ChildPath "docs/$Module.psm1"
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $path).Path, [ref] $null, [ref] $null)

        # Act
        $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ieq 'Get-Date' }, $true))
        $members = @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.MemberExpressionAst] -and $node.Static -and
                    $node.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
                    @('datetime', 'System.DateTime', 'DateTimeOffset', 'System.DateTimeOffset') -icontains $node.Expression.TypeName.FullName -and
                    $node.Member -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
                    @('Now', 'UtcNow') -icontains $node.Member.Value
                }, $true))

        # Assert
        $commands.Count | Should -Be 0
        $members.Count | Should -Be 0
    }
}
