#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsLedgerRules.psm1 (the DocsLedger suite family).

.DESCRIPTION
    Covers the disposition companion table and every ledger rule of Get-DocsLedgerFinding over
    in-memory fixtures from DocsLedger.TestSupport.psm1: missing dispositions, companion fields,
    duplicates, orphans, kind and analysis-method differences, the snapshot reference and the
    precision-limit accounting. Assertions use codes, pointers, severities and identifiers,
    never Test-Json message text. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedger.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedgerRules.psm1') -Force -ErrorAction Stop
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

Describe 'Ledger rules' {
    BeforeAll {
        $script:LedgerPath = 'estate/docs-coverage-ledger.json'

        function Get-TestEntrySet {
            # Complete, consistent entries for the fixture view: one documented entry per element and the precision-limit entry.
            param([hashtable] $View)
            $entries = @(foreach ($id in @($View.Element.Keys | Sort-Object)) { New-DocsLedgerEntry -Element $View.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = 'docs/reference/Cli.md'; anchor = $null }) -Actor $script:Actor })
            $entries + @(foreach ($id in @($View.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $View.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        }

        function Get-TestRuleFinding {
            param([hashtable] $View, [object[]] $Entry, [string] $Code, [string] $Sha256)
            $digest = if ([string]::IsNullOrEmpty($Sha256)) { $View.Sha256 } else { $Sha256 }
            $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $digest -Entry $Entry
            Get-TestFinding -Finding (Get-DocsLedgerFinding -Ledger $ledger -SnapshotView $View -ArtifactPath $script:LedgerPath) -Code $Code
        }

        function Get-TestElementId {
            param([hashtable] $View, [string] $Kind)
            @($View.Element.Values | Where-Object { $_['kind'] -ceq $Kind })[0]['element_id']
        }
    }

    It 'reports no finding for a complete and consistent ledger' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry (Get-TestEntrySet -View $view)

        # Act
        $findings = Get-DocsLedgerFinding -Ledger $ledger -SnapshotView $view -ArtifactPath $script:LedgerPath

        # Assert
        $findings.Count | Should -Be 0
        Get-TestLedgerFindingCount -Document $ledger | Should -Be 0
    }

    It 'reports DOCS_LEDGER_MISSING_DISPOSITION naming kind, declaration and element id' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $routeId = Get-TestElementId -View $view -Kind 'http-route'
        $entries = @(Get-TestEntrySet -View $view | Where-Object { $_['element_id'] -cne $routeId })

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_MISSING_DISPOSITION'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['severity'] | Should -BeExactly 'error'
        $findings[0]['message'] | Should -Match 'http-route'
        $findings[0]['message'].Contains('GET /Items/{id}', [System.StringComparison]::Ordinal) | Should -BeTrue
        $findings[0]['message'].Contains($routeId, [System.StringComparison]::Ordinal) | Should -BeTrue
        $findings[0]['related_ids'] | Should -Be @($routeId)
        $findings[0]['related_paths'] | Should -Be @('src/app/Routes.ps1')
        $findings[0]['artifact_path'] | Should -BeExactly $script:LedgerPath
    }

    It 'reports DOCS_LEDGER_RATIONALE_REQUIRED for excluded without rationale' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $entries = @(Get-TestEntrySet -View $view)
        $entries[1] = New-DocsLedgerEntry -Element $view.Element[$entries[1]['element_id']] -Disposition 'excluded' -Actor $script:Actor

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_RATIONALE_REQUIRED'
        $direct = Get-DocsLedgerEntryCompanionFinding -Entry $entries[1] -Pointer '/entries/1'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/entries/1/rationale'
        $findings[0]['related_ids'] | Should -Be @($entries[1]['element_id'])
        @($direct | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_LEDGER_RATIONALE_REQUIRED')
    }

    It 'reports DOCS_LEDGER_OWNER_REQUIRED and DOCS_LEDGER_TARGET_REQUIRED for deferred without owner or target' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $entries = @(Get-TestEntrySet -View $view)
        $entries[2] = New-DocsLedgerEntry -Element $view.Element[$entries[2]['element_id']] -Disposition 'deferred' -Actor $script:Actor
        $entries[3] = New-DocsLedgerEntry -Element $view.Element[$entries[3]['element_id']] -Disposition 'deferred' -Owner 'docs-team' -Actor $script:Actor

        # Act
        $owner = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_OWNER_REQUIRED'
        $target = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_TARGET_REQUIRED'

        # Assert
        @($owner | ForEach-Object { $_['pointer'] }) | Should -Be @('/entries/2/owner')
        @($target | ForEach-Object { $_['pointer'] }) | Should -Be @('/entries/2/target', '/entries/3/target')
    }

    It 'reports DOCS_LEDGER_BINDING_REQUIRED for documented without binding' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $entries = @(Get-TestEntrySet -View $view)
        $entries[0] = New-DocsLedgerEntry -Element $view.Element[$entries[0]['element_id']] -Disposition 'documented' -Actor $script:Actor

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_BINDING_REQUIRED'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/entries/0/page_bindings'
    }

    It 'reports DOCS_LEDGER_DUPLICATE_ENTRY' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $entries = @(Get-TestEntrySet -View $view)
        $entries = $entries + @($entries[4])

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_DUPLICATE_ENTRY'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly "/entries/$($entries.Count - 1)/element_id"
        $findings[0]['related_ids'] | Should -Be @($entries[4]['element_id'])
    }

    It 'reports DOCS_LEDGER_ORPHAN_ENTRY for an unmarked unknown id' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $stranger = New-DocsSurfaceElement -Kind 'config-key' -Path 'config/Other.json' -Declaration 'tool.other.Key' -Name 'Key' -AnalyzerId 'fixture-scanner' -AnalysisMethod 'scanner' -SourceText "k`n" -LineRange @(1, 1)
        $entries = @(Get-TestEntrySet -View $view) + @((New-DocsLedgerEntry -Element $stranger -Disposition 'excluded' -Rationale 'Not part of the surface.' -Actor $script:Actor))

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_ORPHAN_ENTRY'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly "/entries/$($entries.Count - 1)/element_id"
        $findings[0]['related_ids'] | Should -Be @($stranger['element_id'])
    }

    It 'reports DOCS_LEDGER_KIND_MISMATCH' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $entries = @(Get-TestEntrySet -View $view)
        $entries[3]['kind'] = $(if ($entries[3]['kind'] -ceq 'config-key') { 'http-route' } else { 'config-key' })

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_KIND_MISMATCH'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/entries/3/kind'
        $findings[0]['severity'] | Should -BeExactly 'error'
    }

    It 'reports DOCS_LEDGER_SNAPSHOT_REF as a warning' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry (Get-TestEntrySet -View $view) -Code 'DOCS_LEDGER_SNAPSHOT_REF' -Sha256 ('e' * 64)

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['severity'] | Should -BeExactly 'warning'
        $findings[0]['pointer'] | Should -BeExactly '/snapshot_ref/sha256'
    }

    It 'reports DOCS_LEDGER_ANALYSIS_METHOD_CHANGED as a warning' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $entries = @(Get-TestEntrySet -View $view)
        $entries[5]['analysis_method'] = $(if ($entries[5]['analysis_method'] -ceq 'native') { 'scanner' } else { 'native' })

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_ANALYSIS_METHOD_CHANGED'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['severity'] | Should -BeExactly 'warning'
        $findings[0]['pointer'] | Should -BeExactly '/entries/5/analysis_method'
    }

    It 'reports DOCS_LEDGER_LIMIT_UNRECORDED naming analyzer, code, path, diagnostic id and element id' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $limitId = @($view.PrecisionLimit.Keys)[0]
        $limit = $view.PrecisionLimit[$limitId]
        $entries = @(Get-TestEntrySet -View $view | Where-Object { $_['element_id'] -cne $limitId })

        # Act
        $findings = Get-TestRuleFinding -View $view -Entry $entries -Code 'DOCS_LEDGER_LIMIT_UNRECORDED'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['severity'] | Should -BeExactly 'error'
        foreach ($token in @('fixture-scanner', 'DOCS_SCANNER_DYNAMIC_COMMAND', 'src/app/Dynamic.ps1', $limit.DiagnosticId, $limitId)) {
            $findings[0]['message'].Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the message names $token"
        }
        $findings[0]['related_ids'] | Should -Be @(@($limit.DiagnosticId, $limitId) | Sort-Object)
        $findings[0]['related_paths'] | Should -Be @('src/app/Dynamic.ps1')
    }

    It 'reports DOCS_LEDGER_LIMIT_MISMATCH for a non-deferred, non-scanner, unmarked or differing limit entry' {
        # Arrange
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $limitId = @($view.PrecisionLimit.Keys)[0]
        $base = @(Get-TestEntrySet -View $view | Where-Object { $_['element_id'] -cne $limitId })
        $good = New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$limitId] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor
        $notDeferred = New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$limitId] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor
        $notDeferred['disposition'] = 'excluded'
        $notDeferred['rationale'] = 'Recorded wrongly.'
        $notScanner = New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$limitId] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor
        $notScanner['analysis_method'] = 'native'
        $unmarked = New-DocsLedgerTestEntry -Element @{ element_id = $limitId; kind = 'cli-command'; analysis_method = 'scanner' } -Disposition 'deferred' -Owner 'docs-team' -Target 'Next release'
        $differing = New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$limitId] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor
        $differing['extensions']['docs.precision-limit']['code'] = 'DOCS_OTHER_CODE'
        $index = $base.Count

        # Act
        $none = Get-TestRuleFinding -View $view -Entry ($base + @($good)) -Code 'DOCS_LEDGER_LIMIT_MISMATCH'
        $first = Get-TestRuleFinding -View $view -Entry ($base + @($notDeferred)) -Code 'DOCS_LEDGER_LIMIT_MISMATCH'
        $second = Get-TestRuleFinding -View $view -Entry ($base + @($notScanner)) -Code 'DOCS_LEDGER_LIMIT_MISMATCH'
        $third = Get-TestRuleFinding -View $view -Entry ($base + @($unmarked)) -Code 'DOCS_LEDGER_LIMIT_MISMATCH'
        $fourth = Get-TestRuleFinding -View $view -Entry ($base + @($differing)) -Code 'DOCS_LEDGER_LIMIT_MISMATCH'

        # Assert
        $none.Count | Should -Be 0
        @($first | ForEach-Object { $_['pointer'] }) | Should -Be @("/entries/$index/disposition")
        @($second | ForEach-Object { $_['pointer'] }) | Should -Be @("/entries/$index/analysis_method")
        @($third | ForEach-Object { $_['pointer'] }) | Should -Be @("/entries/$index/extensions")
        @($fourth | ForEach-Object { $_['pointer'] }) | Should -Be @("/entries/$index/extensions/docs.precision-limit/code")
        (Get-TestRuleFinding -View $view -Entry ($base + @($unmarked)) -Code 'DOCS_LEDGER_LIMIT_UNRECORDED').Count | Should -Be 0
    }

    It 'reports DOCS_LEDGER_LIMIT_RESOLVED as a warning' {
        # Arrange
        $marked = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $limitId = @($marked.PrecisionLimit.Keys)[0]
        $entries = @(Get-TestEntrySet -View $marked)
        $resolved = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot -Diagnostic @())

        # Act
        $findings = Get-TestRuleFinding -View $resolved -Entry $entries -Code 'DOCS_LEDGER_LIMIT_RESOLVED'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['severity'] | Should -BeExactly 'warning'
        $findings[0]['pointer'] | Should -BeExactly "/entries/$($entries.Count - 1)"
        $findings[0]['related_ids'] | Should -Be @($limitId)
    }
}
