#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsCoverageReport.psm1.

.DESCRIPTION
    Seeded [System.Random] generation with the seeds of DocsLedger.TestSupport.psm1 (each
    -Because message states the seed): the four disposition lists partition the current
    elements, and the text lines count one per listed item plus the fixed lines. No file is
    written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsLedger', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsCoverageReport') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:PinnedAt = '2026-03-01T12:00:00Z'
    $script:Pages = @('docs/reference/Cli.md', 'docs/guides/Start.md', 'docs/Index.md')
    $text = ConvertTo-DocsJsonText -Value (New-DocsLedgerTestSnapshot)
    $script:View = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)
    $script:Ids = @($script:View.Element.Keys | Sort-Object)

    function New-TestRandomReport {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([System.Random] $Random)
        $dispositions = @('documented', 'excluded', 'deferred')
        $entries = [System.Collections.Generic.List[object]]::new()
        $expected = @{ documented = 0; excluded = 0; deferred = 0; undocumented = 0 }
        foreach ($id in $script:Ids) {
            if ($Random.Next(3) -eq 0) { $expected.undocumented++; continue }
            $disposition = $dispositions[$Random.Next(3)]
            $expected[$disposition]++
            $entries.Add((New-DocsLedgerTestEntry -Element $script:View.Element[$id] -Disposition $disposition -Owner 'docs-team' -Target 'Later' -Rationale 'Reason.'))
        }
        if ($Random.Next(2) -eq 0) { $entries.Add((New-DocsPrecisionLimitEntry -Limit $script:View.PrecisionLimit[@($script:View.PrecisionLimit.Keys)[0]] -Owner 'docs-team' -Target 'Later' -Actor $script:Actor)) }
        $pins = [System.Collections.Generic.List[object]]::new()
        $pinCount = $Random.Next(4)
        for ($index = 0; $index -lt $pinCount; $index++) {
            $pin = New-DocsEvidencePin -Element $script:View.Element[$script:Ids[$Random.Next($script:Ids.Count)]] -PagePath $script:Pages[$Random.Next(3)] -Revision $script:View.Revision -PinnedAt $script:PinnedAt -Actor $script:Actor
            if ($Random.Next(2) -eq 0) { $pin['source_sha256'] = '0' * 64 }
            $pins.Add($pin)
        }
        $rows = @(for ($index = 0; $index -lt $Random.Next(3); $index++) { New-DocsLedgerTestRow -Element $script:View.Element[$script:Ids[$index]] -PagePath $script:Pages[$index] })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $script:View.Sha256 -Entry (Get-DocsLedgerTestShuffle -Item $entries.ToArray() -Seed $Random.Next())
        $matrix = New-DocsLedgerTestMatrix -SnapshotSha256 $script:View.Sha256 -LedgerSha256 ('a' * 64) -Row $rows
        @{ Report = (Get-DocsCoverageReport -SnapshotView $script:View -Ledger $ledger -Matrix $matrix -PinSet (New-DocsLedgerTestPinSet -Pin $pins.ToArray())); Expected = $expected }
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsCoverageReport properties' {
    It 'property Get-DocsCoverageReport: undocumented, deferred, excluded and documented partition the current elements' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 5; $round++) {
                $case = New-TestRandomReport -Random $random
                $report = $case.Report
                $counts = $report['totals']['by_disposition']

                # Assert
                $report['undocumented'].Count | Should -Be $case.Expected.undocumented -Because "seed=$seed round $round"
                $report['totals']['undocumented'] | Should -Be $case.Expected.undocumented -Because "seed=$seed round $round"
                $counts['documented'] | Should -Be $case.Expected.documented -Because "seed=$seed round $round"
                $counts['excluded'] | Should -Be $case.Expected.excluded -Because "seed=$seed round $round"
                $counts['deferred'] | Should -Be $case.Expected.deferred -Because "seed=$seed round $round"
                $report['deferred'].Count | Should -Be $case.Expected.deferred -Because "seed=$seed round $round"
                ($report['undocumented'].Count + $counts['documented'] + $counts['excluded'] + $counts['deferred']) | Should -Be $script:Ids.Count -Because "seed=$seed round $round the four lists partition the current elements"
                ($report['totals']['by_analysis_method']['native'] + $report['totals']['by_analysis_method']['scanner']) | Should -Be ($script:Ids.Count - $case.Expected.undocumented) -Because "seed=$seed round $round"
                [string[]] $undocumentedIds = @($report['undocumented'] | ForEach-Object { $_['element_id'] })
                [string[]] $sorted = @($undocumentedIds)
                [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
                $undocumentedIds | Should -Be $sorted -Because "seed=$seed round $round sorted by element_id"
            }
        }
    }

    It 'property ConvertTo-DocsCoverageReportLine: one line per listed item plus the fixed lines for seeded reports' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 5; $round++) {
                $report = (New-TestRandomReport -Random $random).Report
                $listed = $report['undocumented'].Count + $report['deferred'].Count + $report['precision_limits'].Count + $report['stale_pages'].Count

                # Act
                $lines = ConvertTo-DocsCoverageReportLine -Report $report

                # Assert
                $lines.Count | Should -Be (6 + $listed) -Because "seed=$seed round $round one totals line, five parity lines and one line per listed item"
                $lines[0] | Should -Match '^coverage: elements=6 ' -Because "seed=$seed round $round"
                @($lines | Where-Object { $_.StartsWith('parity ', [System.StringComparison]::Ordinal) }).Count | Should -Be 5 -Because "seed=$seed round $round"
            }
        }
    }
}
