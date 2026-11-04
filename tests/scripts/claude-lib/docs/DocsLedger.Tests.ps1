#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsLedger.psm1.

.DESCRIPTION
    Covers the snapshot view (element rebuild, precision-limit marker rules), the entry and
    document constructors, the ledger rules and the ledger operations over in-memory fixtures
    from DocsLedger.TestSupport.psm1. Built documents are validated against the committed runtime
    schemas through Test-DocsArtifactText; assertions use codes, pointers and identifiers, never
    Test-Json message text. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedger.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }

    function Get-TestView {
        # Round-trips the snapshot through JSON so the view sees ordinal hashtables, as in production.
        param([object] $Snapshot)
        $text = ConvertTo-DocsJsonText -Value $Snapshot
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text) -ArtifactPath 'estate/surface-inventory-snapshot.json'
    }

    function Get-TestFinding {
        param([object[]] $Finding, [string] $Code)
        , @($Finding | Where-Object { $_['code'] -ceq $Code })
    }

    function Get-TestLedgerFindingCount {
        param([object] $Document)
        (Test-DocsArtifactText -ArtifactKind 'docs-coverage-ledger' -JsonText (ConvertTo-DocsJsonText -Value $Document) -ComposedSchemaSet $script:Composed).Count
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-DocsSnapshotView' {
    It 'rebuilds every element keyed by element_id' {
        # Arrange
        $snapshot = New-DocsLedgerTestSnapshot

        # Act
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $view.Findings.Count | Should -Be 0
        $view.Element.Count | Should -Be 6
        foreach ($key in $view.Element.Keys) { $view.Element[$key]['element_id'] | Should -BeExactly $key }
        $view.Repository | Should -BeExactly 'fixture-repo'
        $view.Revision | Should -BeExactly $snapshot['revision']
        $view.Sha256 | Should -Match '^[0-9a-f]{64}$'
        $view.PrecisionLimit.Count | Should -Be 1
    }

    It 'reports DOCS_SNAPSHOT_ELEMENT_INVALID at the element pointer for a tampered element id' {
        # Arrange
        $snapshot = New-DocsLedgerTestSnapshot
        $snapshot['elements'][2]['element_id'] = 'http-route-' + ('0' * 64)

        # Act
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $findings = Get-TestFinding -Finding $view.Findings -Code 'DOCS_SNAPSHOT_ELEMENT_INVALID'
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/elements/2'
        $findings[0]['severity'] | Should -BeExactly 'error'
        $findings[0]['artifact_path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        $view.Element.Count | Should -Be 5
    }

    It 'reports DOCS_SNAPSHOT_LIMIT_INVALID for an unknown marker element_kind' {
        # Arrange
        $snapshot = New-DocsLedgerTestSnapshot -Diagnostic @((New-DocsLedgerTestPrecisionLimitDiagnostic -ElementKind 'widget'))

        # Act
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $findings = Get-TestFinding -Finding $view.Findings -Code 'DOCS_SNAPSHOT_LIMIT_INVALID'
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/diagnostics/0/extensions/docs.precision-limit/element_kind'
        $view.PrecisionLimit.Count | Should -Be 0
    }

    It 'reports DOCS_SNAPSHOT_LIMIT_INVALID for a marked diagnostic with null path' {
        # Arrange
        $snapshot = New-DocsLedgerTestSnapshot -Diagnostic @((New-DocsLedgerTestPrecisionLimitDiagnostic -Path $null))

        # Act
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $findings = Get-TestFinding -Finding $view.Findings -Code 'DOCS_SNAPSHOT_LIMIT_INVALID'
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/diagnostics/0/path'
        $view.PrecisionLimit.Count | Should -Be 0
    }

    It 'reports DOCS_SNAPSHOT_LIMIT_INVALID for a marked diagnostic from a native analyzer' {
        # Arrange
        $snapshot = New-DocsLedgerTestSnapshot -Diagnostic @((New-DocsLedgerTestPrecisionLimitDiagnostic -AnalyzerId 'fixture-native'))

        # Act
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $findings = Get-TestFinding -Finding $view.Findings -Code 'DOCS_SNAPSHOT_LIMIT_INVALID'
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/diagnostics/0/analyzer_id'
        $view.PrecisionLimit.Count | Should -Be 0
    }

    It 'reports DOCS_SNAPSHOT_LIMIT_INVALID when the precision-limit id equals an element id' {
        # Arrange
        $diagnostic = New-DocsLedgerTestPrecisionLimitDiagnostic
        $colliding = New-DocsSurfaceElement -Kind 'cli-command' -Path $diagnostic['path'] -Declaration $diagnostic['id'] -Name 'dynamic' -AnalyzerId 'fixture-scanner' -AnalysisMethod 'scanner' -SourceText "x`n" -LineRange @(1, 1)
        $elements = @(foreach ($kind in Get-DocsElementKind) { New-DocsLedgerTestElement -Kind $kind }) + @($colliding)
        $snapshot = New-DocsLedgerTestSnapshot -Element $elements -Diagnostic @($diagnostic)

        # Act
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $findings = Get-TestFinding -Finding $view.Findings -Code 'DOCS_SNAPSHOT_LIMIT_INVALID'
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/diagnostics/0/id'
        $findings[0]['related_ids'] | Should -Contain $colliding['element_id']
        $view.PrecisionLimit.Count | Should -Be 0
        $view.Element.Count | Should -Be 7
    }

    It 'ignores diagnostics without the marker' {
        # Arrange
        $plain = New-DocsDiagnostic -Code 'DOCS_SCANNER_NOTICE' -Path $null -Message 'An unrelated notice.' -AnalyzerId 'fixture-scanner' -Severity 'information'
        $marked = New-DocsLedgerTestPrecisionLimitDiagnostic
        $snapshot = New-DocsLedgerTestSnapshot -Diagnostic @($plain, $marked)

        # Act
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $view.Findings.Count | Should -Be 0
        $view.PrecisionLimit.Count | Should -Be 1
        Test-DocsPrecisionLimitDiagnostic -Diagnostic $plain -Analyzer $snapshot['analyzers'] | Should -BeFalse
        Test-DocsPrecisionLimitDiagnostic -Diagnostic $marked -Analyzer $snapshot['analyzers'] | Should -BeTrue
    }

    It 'derives the precision-limit id with Get-DocsElementId over kind, path and diagnostic id' {
        # Arrange
        $diagnostic = New-DocsLedgerTestPrecisionLimitDiagnostic
        $snapshot = New-DocsLedgerTestSnapshot -Diagnostic @($diagnostic)
        $expected = Get-DocsElementId -Kind 'cli-command' -Path $diagnostic['path'] -Declaration $diagnostic['id']

        # Act
        $derived = Get-DocsPrecisionLimitElementId -ElementKind 'cli-command' -Path $diagnostic['path'] -DiagnosticId $diagnostic['id']
        $view = Get-TestView -Snapshot $snapshot

        # Assert
        $derived | Should -BeExactly $expected
        Test-DocsElementId -ElementId $derived | Should -BeTrue
        @($view.PrecisionLimit.Keys) | Should -Be @($expected)
        $record = $view.PrecisionLimit[$expected]
        $record.DiagnosticId | Should -BeExactly $diagnostic['id']
        $record.AnalyzerId | Should -BeExactly 'fixture-scanner'
        $record.Code | Should -BeExactly 'DOCS_SCANNER_DYNAMIC_COMMAND'
        $record.Path | Should -BeExactly 'src/app/Dynamic.ps1'
        $record.ElementKind | Should -BeExactly 'cli-command'
        $record.ElementId | Should -BeExactly $expected
    }
}

Describe 'Entry and document constructors' {
    It 'copies element_id, kind and analysis_method and sorts bindings with a null anchor first' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'http-route'
        $bindings = @(
            @{ page_path = 'docs/b.md'; anchor = 'zeta' }
            @{ page_path = 'docs/a.md'; anchor = 'xi' }
            @{ page_path = 'docs/a.md'; anchor = $null }
            @{ page_path = 'docs/B.md' }
            @{ page_path = 'docs/b.md'; anchor = $null }
        )

        # Act
        $entry = New-DocsLedgerEntry -Element $element -Disposition 'documented' -PageBinding $bindings -Actor $script:Actor

        # Assert
        $entry['element_id'] | Should -BeExactly $element['element_id']
        $entry['kind'] | Should -BeExactly 'http-route'
        $entry['analysis_method'] | Should -BeExactly 'scanner'
        @($entry['page_bindings'] | ForEach-Object { $_['page_path'] + '#' + $_['anchor'] }) | Should -Be @('docs/B.md#', 'docs/a.md#', 'docs/a.md#xi', 'docs/b.md#', 'docs/b.md#zeta')
        $entry['page_bindings'][0]['anchor'] | Should -BeNullOrEmpty
        $entry['rationale'] | Should -BeNullOrEmpty
        $entry['updated_by']['id'] | Should -BeExactly 'fixture-tool'
        @($entry.Keys) | Should -Be @('element_id', 'kind', 'analysis_method', 'disposition', 'page_bindings', 'rationale', 'owner', 'target', 'updated_by', 'extensions')
        Get-TestLedgerFindingCount -Document (New-DocsLedgerTestLedger -SnapshotSha256 ('a' * 64) -Entry @($entry)) | Should -Be 0
        { New-DocsLedgerEntry -Element $element -Disposition 'pending' -Actor $script:Actor } | Should -Throw -ExpectedMessage '*DOCS_LEDGER_INPUT_INVALID*'
    }

    It 'builds a deferred scanner precision-limit entry with the marker' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $limit = $view.PrecisionLimit[@($view.PrecisionLimit.Keys)[0]]

        # Act
        $entry = New-DocsPrecisionLimitEntry -Limit $limit -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor

        # Assert
        $entry['element_id'] | Should -BeExactly $limit.ElementId
        $entry['kind'] | Should -BeExactly 'cli-command'
        $entry['analysis_method'] | Should -BeExactly 'scanner'
        $entry['disposition'] | Should -BeExactly 'deferred'
        @($entry['page_bindings']).Count | Should -Be 0
        $entry['owner'] | Should -BeExactly 'docs-team'
        $entry['target'] | Should -BeExactly 'Next release'
        $entry['rationale'] | Should -BeNullOrEmpty
        $entry['extensions']['docs.precision-limit']['analyzer_id'] | Should -BeExactly 'fixture-scanner'
        $entry['extensions']['docs.precision-limit']['code'] | Should -BeExactly 'DOCS_SCANNER_DYNAMIC_COMMAND'
        $entry['extensions']['docs.precision-limit']['diagnostic_id'] | Should -BeExactly $limit.DiagnosticId
        Get-TestLedgerFindingCount -Document (New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry @($entry)) | Should -Be 0
    }

    It 'builds an empty ledger whose id depends on the repository id' {
        # Arrange
        $pinA = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/a.json'; sha256 = ('a' * 64) }
        $pinB = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/b.json'; sha256 = ('b' * 64) }

        # Act
        $first = New-DocsLedgerDocument -RepositoryId 'fixture-repo' -SnapshotPin $pinA
        $second = New-DocsLedgerDocument -RepositoryId 'fixture-repo' -SnapshotPin $pinB
        $other = New-DocsLedgerDocument -RepositoryId 'other-repo' -SnapshotPin $pinA

        # Assert
        $first['id'] | Should -BeExactly $second['id']
        $first['id'] | Should -Not -BeExactly $other['id']
        $first['id'] | Should -BeExactly (Get-DocsStableId -Prefix 'docs-coverage-ledger' -Value @{ repository = 'fixture-repo' })
        $first['snapshot_ref']['sha256'] | Should -BeExactly ('a' * 64)
        $first['snapshot_ref']['artifact_kind'] | Should -BeExactly 'surface-inventory-snapshot'
        @($first['entries']).Count | Should -Be 0
        Get-TestLedgerFindingCount -Document $first | Should -Be 0
    }
}

Describe 'Ledger operations' {
    BeforeAll {
        function Get-TestOperationLedger {
            # A ledger whose entries are given out of order: the http-route entry before the cli-command entry.
            param([hashtable] $View)
            $ids = @($View.Element.Keys | Sort-Object)
            $entries = @(
                (New-DocsLedgerEntry -Element $View.Element[$ids[2]] -Disposition 'documented' -PageBinding @(@{ page_path = 'docs/a.md'; anchor = $null }) -Actor $script:Actor)
                (New-DocsLedgerEntry -Element $View.Element[$ids[0]] -Disposition 'documented' -PageBinding @(@{ page_path = 'docs/a.md'; anchor = $null }) -Actor $script:Actor)
                (New-DocsPrecisionLimitEntry -Limit $View.PrecisionLimit[@($View.PrecisionLimit.Keys)[0]] -Owner 'docs-team' -Target 'Soon' -Actor $script:Actor)
            )
            New-DocsLedgerTestLedger -SnapshotSha256 ('1' * 64) -Entry $entries
        }
    }

    It 'replaces or inserts by element_id and sorts entries' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $ids = @($view.Element.Keys | Sort-Object)
        $ledger = Get-TestOperationLedger -View $view
        $inserted = New-DocsLedgerEntry -Element $view.Element[$ids[1]] -Disposition 'excluded' -Rationale 'Internal.' -Actor $script:Actor
        $replacement = New-DocsLedgerEntry -Element $view.Element[$ids[2]] -Disposition 'deferred' -Owner 'docs-team' -Target 'Later' -Actor $script:Actor

        # Act
        $withInsert = Merge-DocsLedgerEntry -Ledger $ledger -Entry $inserted
        $withReplace = Merge-DocsLedgerEntry -Ledger $withInsert -Entry $replacement

        # Assert
        $sortedIds = @($withInsert['entries'] | ForEach-Object { $_['element_id'] })
        [string[]] $expected = @($sortedIds)
        [Array]::Sort($expected, [System.StringComparer]::Ordinal)
        $sortedIds | Should -Be $expected
        @($withInsert['entries']).Count | Should -Be 4
        @($withReplace['entries']).Count | Should -Be 4
        @($withReplace['entries'] | Where-Object { $_['element_id'] -ceq $ids[2] })[0]['disposition'] | Should -BeExactly 'deferred'
        $withReplace['id'] | Should -BeExactly $ledger['id']
        Get-TestLedgerFindingCount -Document $withReplace | Should -Be 0
    }

    It 'leaves the input ledger unchanged' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $ids = @($view.Element.Keys | Sort-Object)
        $ledger = Get-TestOperationLedger -View $view
        $before = ConvertTo-DocsCanonicalJson -Value $ledger
        $entry = New-DocsLedgerEntry -Element $view.Element[$ids[3]] -Disposition 'excluded' -Rationale 'Internal.' -Actor $script:Actor
        $pin = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/surface-inventory-snapshot.json'; sha256 = $view.Sha256 }

        # Act
        $merged = Merge-DocsLedgerEntry -Ledger $ledger -Entry $entry
        $without = Get-DocsLedgerWithoutEntry -Ledger $ledger -ElementId $ids[0]
        $synced = Merge-DocsLedgerSnapshotRef -Ledger $ledger -SnapshotPin $pin -SnapshotView $view
        $merged['entries'][0]['disposition'] = 'tampered'
        $without['snapshot_ref']['sha256'] = '2' * 64
        $synced['entries'][0]['analysis_method'] = 'tampered'

        # Assert
        (ConvertTo-DocsCanonicalJson -Value $ledger) | Should -BeExactly $before
        $entry['disposition'] | Should -BeExactly 'excluded'
    }

    It 'removes only the named entry including a precision-limit entry' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $ids = @($view.Element.Keys | Sort-Object)
        $limitId = @($view.PrecisionLimit.Keys)[0]
        $ledger = Get-TestOperationLedger -View $view

        # Act
        $withoutElement = Get-DocsLedgerWithoutEntry -Ledger $ledger -ElementId $ids[0]
        $withoutLimit = Get-DocsLedgerWithoutEntry -Ledger $ledger -ElementId $limitId
        $withoutUnknown = Get-DocsLedgerWithoutEntry -Ledger $ledger -ElementId ('cli-command-' + ('0' * 64))

        # Assert
        @($withoutElement['entries'] | ForEach-Object { $_['element_id'] }) | Should -Be @(@($ids[2], $limitId) | Sort-Object)
        @($withoutLimit['entries'] | ForEach-Object { $_['element_id'] }) | Should -Be @(@($ids[0], $ids[2]) | Sort-Object)
        @($withoutUnknown['entries']).Count | Should -Be 3
        $withoutUnknown['entries'][0]['element_id'] | Should -BeExactly @(@($ids[0], $ids[2], $limitId) | Sort-Object)[0]
    }

    It 'sync sets snapshot_ref and refreshes analysis_method of element entries only' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $ids = @($view.Element.Keys | Sort-Object)
        $limitId = @($view.PrecisionLimit.Keys)[0]
        $ledger = Get-TestOperationLedger -View $view
        foreach ($entry in $ledger['entries']) { $entry['analysis_method'] = 'native' }
        $pin = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/surface-inventory-snapshot.json'; sha256 = $view.Sha256 }

        # Act
        $synced = Merge-DocsLedgerSnapshotRef -Ledger $ledger -SnapshotPin $pin -SnapshotView $view

        # Assert
        $synced['snapshot_ref']['sha256'] | Should -BeExactly $view.Sha256
        $synced['snapshot_ref']['path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        $synced['snapshot_ref']['artifact_kind'] | Should -BeExactly 'surface-inventory-snapshot'
        foreach ($entry in $synced['entries']) {
            if ($entry['element_id'] -ceq $limitId) { $entry['analysis_method'] | Should -BeExactly 'native' -Because 'a precision-limit entry is not refreshed' }
            else { $entry['analysis_method'] | Should -BeExactly $view.Element[$entry['element_id']]['analysis_method'] }
        }
        @($synced['entries'] | ForEach-Object { $_['element_id'] }) | Should -Be @(@($ids[0], $ids[2], $limitId) | Sort-Object)
        $ledger['snapshot_ref']['sha256'] | Should -BeExactly ('1' * 64)
    }
}
