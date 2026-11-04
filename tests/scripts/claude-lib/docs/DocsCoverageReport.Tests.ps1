#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsCoverageReport.psm1 (the DocsLedgerCommands suite family).

.DESCRIPTION
    Covers Get-DocsCoverageReport sections over in-memory fixtures from
    DocsLedger.TestSupport.psm1 (totals with by_analysis_method, undocumented, deferred,
    precision limits with recorded, stale pages, parity) and the lines of
    ConvertTo-DocsCoverageReportLine. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsLedger', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsCoverageReport') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:PinnedAt = '2026-03-01T12:00:00Z'
    $script:Page = 'docs/reference/Cli.md'

    function Get-TestView {
        $text = ConvertTo-DocsJsonText -Value (New-DocsLedgerTestSnapshot)
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsCoverageReport' {
    BeforeAll {
        $script:View = Get-TestView
        $script:Ids = @($script:View.Element.Keys | Sort-Object)
        $script:LimitId = @($script:View.PrecisionLimit.Keys)[0]
    }

    It 'builds totals with by_analysis_method, undocumented, deferred, stale_pages and parity' {
        # Arrange: documented 0 and 1 (pinned, one stale), excluded 2, deferred 3; 4 and 5 undocumented; limit recorded.
        $elements = @($script:Ids | ForEach-Object { $script:View.Element[$_] })
        $entries = @(
            (New-DocsLedgerEntry -Element $elements[0] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor)
            (New-DocsLedgerEntry -Element $elements[1] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor)
            (New-DocsLedgerEntry -Element $elements[2] -Disposition 'excluded' -Rationale 'Internal.' -Actor $script:Actor)
            (New-DocsLedgerEntry -Element $elements[3] -Disposition 'deferred' -Owner 'docs-team' -Target 'Later' -Actor $script:Actor)
            (New-DocsPrecisionLimitEntry -Limit $script:View.PrecisionLimit[$script:LimitId] -Owner 'scanner-team' -Target 'Native analyzer' -Actor $script:Actor)
        )
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $script:View.Sha256 -Entry $entries
        $pins = @(
            (New-DocsEvidencePin -Element $elements[0] -PagePath $script:Page -Revision $script:View.Revision -PinnedAt $script:PinnedAt -Actor $script:Actor)
            (New-DocsEvidencePin -Element $elements[1] -PagePath $script:Page -Revision $script:View.Revision -PinnedAt $script:PinnedAt -Actor $script:Actor)
        )
        $pins[1]['source_sha256'] = '0' * 64
        $rows = @(
            (New-DocsLedgerTestRow -Element $elements[0] -Dimension @{ exists = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }; accurate = [ordered]@{ state = 'fail'; rationale = 'Old.'; evidence_pin_ids = [string[]]@($pins[0]['pin_id']) } })
            (New-DocsLedgerTestRow -Element $elements[1] -Dimension @{ exists = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() } })
        )
        $matrix = New-DocsLedgerTestMatrix -SnapshotSha256 $script:View.Sha256 -LedgerSha256 ('a' * 64) -Row $rows

        # Act
        $report = Get-DocsCoverageReport -SnapshotView $script:View -Ledger $ledger -Matrix $matrix -PinSet (New-DocsLedgerTestPinSet -Pin $pins)

        # Assert
        @($report.Keys) | Should -Be @('totals', 'undocumented', 'deferred', 'precision_limits', 'stale_pages', 'parity')
        $report['totals']['elements_total'] | Should -Be 6
        $report['totals']['undocumented'] | Should -Be 2
        $report['totals']['by_disposition']['documented'] | Should -Be 2
        $report['totals']['by_disposition']['excluded'] | Should -Be 1
        $report['totals']['by_disposition']['deferred'] | Should -Be 1 -Because 'the precision-limit entry is excluded from the counts'
        $report['totals']['stale_pages'] | Should -Be 1
        $nativeCount = @($elements[0..3] | Where-Object { $_['analysis_method'] -ceq 'native' }).Count
        $report['totals']['by_analysis_method']['native'] | Should -Be $nativeCount
        $report['totals']['by_analysis_method']['scanner'] | Should -Be (4 - $nativeCount)
        @($report['undocumented'] | ForEach-Object { $_['element_id'] }) | Should -Be @($script:Ids[4], $script:Ids[5])
        @($report['undocumented'][0].Keys) | Should -Be @('element_id', 'kind', 'declaration', 'path')
        $report['undocumented'][0]['declaration'] | Should -BeExactly $elements[4]['declaration']
        $report['deferred'].Count | Should -Be 1
        $report['deferred'][0]['element_id'] | Should -BeExactly $script:Ids[3]
        $report['deferred'][0]['owner'] | Should -BeExactly 'docs-team'
        $report['deferred'][0]['target'] | Should -BeExactly 'Later'
        $report['precision_limits'].Count | Should -Be 1
        $report['precision_limits'][0]['recorded'] | Should -BeTrue
        $report['precision_limits'][0]['owner'] | Should -BeExactly 'scanner-team'
        $report['precision_limits'][0]['element_id'] | Should -BeExactly $script:LimitId
        $report['precision_limits'][0]['diagnostic_id'] | Should -BeExactly $script:View.PrecisionLimit[$script:LimitId]['DiagnosticId']
        $report['stale_pages'].Count | Should -Be 1
        $report['stale_pages'][0]['page_path'] | Should -BeExactly $script:Page
        $report['stale_pages'][0]['pins'][0]['status'] | Should -BeExactly 'digest-changed'
        @($report['parity'].Keys) | Should -Be @(Get-DocsParityDimension)
        $report['parity']['exists']['pass'] | Should -Be 2
        $report['parity']['exists']['score_basis_points'] | Should -Be 10000
        $report['parity']['accurate']['fail'] | Should -Be 1
        $report['parity']['accurate']['not_assessed'] | Should -Be 1
        $report['parity']['accurate']['score_basis_points'] | Should -Be 0
        $null -eq $report['parity']['diataxis_mode']['score_basis_points'] | Should -BeFalse -Because 'two not-assessed rows give a zero score, not a null one'
        $report['parity']['diataxis_mode']['score_basis_points'] | Should -Be 0
    }

    It 'marks an unrecorded precision limit recorded false and lists every element as undocumented over empty documents' {
        # Arrange
        $ledger = New-DocsLedgerDocument -RepositoryId 'fixture-repo' -SnapshotPin @{ path = 'estate/surface-inventory-snapshot.json'; sha256 = $script:View.Sha256 }
        $matrix = New-DocsParityMatrixDocument -RepositoryId 'fixture-repo' -SnapshotPin @{ path = 'estate/surface-inventory-snapshot.json'; sha256 = $script:View.Sha256 } -LedgerPin @{ path = 'estate/docs-coverage-ledger.json'; sha256 = 'a' * 64 }

        # Act
        $report = Get-DocsCoverageReport -SnapshotView $script:View -Ledger $ledger -Matrix $matrix -PinSet (New-DocsPinCollectionDocument -RepositoryId 'fixture-repo')

        # Assert
        @($report['undocumented'] | ForEach-Object { $_['element_id'] }) | Should -Be $script:Ids
        $report['totals']['undocumented'] | Should -Be 6
        $report['totals']['by_analysis_method']['native'] | Should -Be 0
        $report['deferred'].Count | Should -Be 0
        $report['precision_limits'].Count | Should -Be 1
        $report['precision_limits'][0]['recorded'] | Should -BeFalse
        $null -eq $report['precision_limits'][0]['owner'] | Should -BeTrue
        $null -eq $report['precision_limits'][0]['target'] | Should -BeTrue
        $report['precision_limits'][0]['analyzer_id'] | Should -BeExactly 'fixture-scanner'
        $report['precision_limits'][0]['code'] | Should -BeExactly 'DOCS_SCANNER_DYNAMIC_COMMAND'
        $report['precision_limits'][0]['path'] | Should -BeExactly 'src/app/Dynamic.ps1'
        $report['stale_pages'].Count | Should -Be 0
        $null -eq $report['parity']['exists']['score_basis_points'] | Should -BeTrue -Because 'no row gives a zero denominator'
    }
}

Describe 'ConvertTo-DocsCoverageReportLine' {
    It 'renders the totals line, one line per listed item and one line per parity dimension' {
        # Arrange
        $view = Get-TestView
        $ids = @($view.Element.Keys | Sort-Object)
        $element = $view.Element[$ids[0]]
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry @((New-DocsLedgerEntry -Element $element -Disposition 'deferred' -Owner 'docs-team' -Target 'Later' -Actor $script:Actor))
        $pin = New-DocsEvidencePin -Element $view.Element[$ids[1]] -PagePath $script:Page -Revision $view.Revision -PinnedAt $script:PinnedAt -Actor $script:Actor
        $pin['source_sha256'] = '1' * 64
        $report = Get-DocsCoverageReport -SnapshotView $view -Ledger $ledger -Matrix (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 ('a' * 64) -Row @()) -PinSet (New-DocsLedgerTestPinSet -Pin @($pin))

        # Act
        $lines = ConvertTo-DocsCoverageReportLine -Report $report

        # Assert
        $lines.Count | Should -Be (1 + 5 + 1 + 1 + 1 + 5)
        $native = if ($element['analysis_method'] -ceq 'native') { 1 } else { 0 }
        $lines[0] | Should -BeExactly "coverage: elements=6 undocumented=5 documented=0 excluded=0 deferred=1 native=$native scanner=$(1 - $native) stale_pages=1 precision_limits=1"
        @($lines | Where-Object { $_.StartsWith('undocumented ', [System.StringComparison]::Ordinal) }).Count | Should -Be 5
        @($lines | Where-Object { $_.StartsWith('deferred ', [System.StringComparison]::Ordinal) }) | Should -Be @("deferred $($ids[0]) owner=docs-team target=Later")
        @($lines | Where-Object { $_.StartsWith('precision-limit ', [System.StringComparison]::Ordinal) })[0] | Should -Match ' fixture-scanner DOCS_SCANNER_DYNAMIC_COMMAND src/app/Dynamic.ps1 recorded=false$'
        @($lines | Where-Object { $_.StartsWith('stale ', [System.StringComparison]::Ordinal) }) | Should -Be @("stale $($script:Page): 1 pin(s)")
        @($lines | Where-Object { $_.StartsWith('parity ', [System.StringComparison]::Ordinal) }).Count | Should -Be 5
        $lines[-1] | Should -BeExactly 'parity diataxis_mode pass=0 fail=0 not_assessed=0 not_applicable=0 score_basis_points=null'
    }
}
