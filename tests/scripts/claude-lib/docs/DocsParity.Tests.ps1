#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsParity.psm1.

.DESCRIPTION
    Covers the path_or_glob table, page-owner selection, the row and matrix constructors, the
    score arithmetic, every matrix finding code and the matrix operations over in-memory fixtures
    from DocsLedger.TestSupport.psm1. Built rows and documents are validated against the committed
    runtime schema through Test-DocsArtifactText. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsEvidencePins.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsParity.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:Page = 'docs/reference/Cli.md'
    $script:Owners = @(@{ path_or_glob = 'docs/reference/**'; owner = 'docs-team' }, @{ path_or_glob = 'docs'; owner = 'maintainer-team' })
    $script:SnapshotPin = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/surface-inventory-snapshot.json'; sha256 = ('a' * 64) }
    $script:LedgerPin = @{ artifact_kind = 'docs-coverage-ledger'; path = 'estate/docs-coverage-ledger.json'; sha256 = ('b' * 64) }

    function Get-TestMatrixFindingCount {
        param([object] $Document)
        (Test-DocsArtifactText -ArtifactKind 'docs-parity-matrix' -JsonText (ConvertTo-DocsJsonText -Value $Document) -ComposedSchemaSet $script:Composed).Count
    }

    function New-TestFixture {
        # One documented element bound to the page, one pin for it, and a consistent matrix row.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param()
        $element = New-DocsLedgerTestElement -Kind 'cli-command'
        $pin = New-DocsEvidencePin -Element $element -PagePath $script:Page -PinnedAt '2026-03-01T12:00:00Z' -Actor $script:Actor
        $entry = New-DocsLedgerTestEntry -Element $element -PageBinding @(@{ page_path = $script:Page; anchor = $null })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 ('a' * 64) -Entry @($entry)
        $pinSet = New-DocsLedgerTestPinSet -Pin @($pin)
        $matrix = New-DocsParityMatrixDocument -RepositoryId 'fixture-repo' -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin
        $matrix = Merge-DocsParityDimension -Matrix $matrix -ElementId $element['element_id'] -Kind 'cli-command' -PagePath $script:Page -Dimension 'exists' -State 'pass' -PinId @($pin['pin_id'])
        $matrix = Merge-DocsParityDimension -Matrix $matrix -ElementId $element['element_id'] -Kind 'cli-command' -PagePath $script:Page -Dimension 'accurate' -State 'pass' -PinId @($pin['pin_id'])
        $matrix = Merge-DocsParityDimension -Matrix $matrix -ElementId $element['element_id'] -Kind 'cli-command' -PagePath $script:Page -Dimension 'owner_assigned' -State 'pass'
        @{ Element = $element; Pin = $pin; Ledger = $ledger; PinSet = $pinSet; Matrix = $matrix }
    }

    function Get-TestMatrixFinding {
        param([hashtable] $Fixture, [string] $Code, [string[]] $PagePath = @($script:Page), [string] $LedgerSha256 = ('b' * 64))
        , @((Get-DocsMatrixFinding -Matrix $Fixture.Matrix -Ledger $Fixture.Ledger -PinSet $Fixture.PinSet -PagePath $PagePath -PageOwner $script:Owners -LedgerSha256 $LedgerSha256 -ArtifactPath 'estate/docs-parity-matrix.json') | Where-Object { $_['code'] -ceq $Code })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Path matching and owners' {
    It 'matches the enumerated path_or_glob table' {
        # Arrange
        $table = @(
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/Cli.md'; Expected = $true }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference'; Expected = $true }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs'; Expected = $true }
            @{ Path = 'docs/reference-notes/Cli.md'; Glob = 'docs/reference'; Expected = $false }
            @{ Path = 'docs/reference/nested/Cli.md'; Glob = 'docs/*.md'; Expected = $true }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/C?i.md'; Expected = $true }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/C?.md'; Expected = $false }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/[ABC]li.md'; Expected = $true }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/[!ABC]li.md'; Expected = $false }
            @{ Path = 'docs/reference/Dli.md'; Glob = 'docs/reference/[!ABC]li.md'; Expected = $true }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/cli.md'; Expected = $false }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'DOCS/**'; Expected = $false }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/**'; Expected = $true }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/Cli.m'; Expected = $false }
            @{ Path = 'docs/reference/Cli.md'; Glob = 'docs/reference/Cli.md*'; Expected = $true }
            @{ Path = 'docs/a.b'; Glob = 'docs/a.b'; Expected = $true }
            @{ Path = 'docs/axb'; Glob = 'docs/a.b'; Expected = $false }
        )

        foreach ($case in $table) {
            # Act and Assert
            Test-DocsPathOrGlobMatch -Path $case.Path -PathOrGlob $case.Glob | Should -Be $case.Expected -Because "glob '$($case.Glob)' against '$($case.Path)'"
        }
        $table.Count | Should -Be 17
    }

    It 'returns the first matching page owner' {
        # Arrange
        $owners = @(@{ path_or_glob = 'docs/reference/**'; owner = 'docs-team' }, @{ path_or_glob = 'docs'; owner = 'maintainer-team' }, @{ path_or_glob = 'docs/reference/Cli.md'; owner = 'cli-team' })

        # Act and Assert
        Get-DocsPageOwner -PagePath 'docs/reference/Cli.md' -PageOwner $owners | Should -BeExactly 'docs-team'
        Get-DocsPageOwner -PagePath 'docs/guides/Start.md' -PageOwner $owners | Should -BeExactly 'maintainer-team'
        Get-DocsPageOwner -PagePath 'README.md' -PageOwner $owners | Should -BeNullOrEmpty
        Get-DocsPageOwner -PagePath 'README.md' -PageOwner @() | Should -BeNullOrEmpty
        Get-DocsPageOwner -PagePath 'docs/reference/Cli.md' -PageOwner ($owners + @(@{ path_or_glob = '**'; owner = 'everyone' })) | Should -BeExactly 'docs-team'
    }
}

Describe 'Rows, documents and scores' {
    It 'creates a row with every dimension not-assessed' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'http-route'

        # Act
        $row = New-DocsParityRow -ElementId $element['element_id'] -Kind 'http-route' -PagePath 'docs/reference/Routes.md'
        $matrix = New-DocsParityMatrixDocument -RepositoryId 'fixture-repo' -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin
        $matrix['rows'] = [object[]]@($row)

        # Assert
        @($row['dimensions'].Keys) | Should -Be @(Get-DocsParityDimension)
        foreach ($name in Get-DocsParityDimension) {
            $row['dimensions'][$name]['state'] | Should -BeExactly 'not-assessed'
            $row['dimensions'][$name]['rationale'] | Should -BeNullOrEmpty
            @($row['dimensions'][$name]['evidence_pin_ids']).Count | Should -Be 0
        }
        @(Get-DocsParityDimension) | Should -Be @('exists', 'accurate', 'example_present', 'owner_assigned', 'diataxis_mode')
        Get-TestMatrixFindingCount -Document $matrix | Should -Be 0
        $matrix['id'] | Should -BeExactly (Get-DocsStableId -Prefix 'docs-parity-matrix' -Value @{ repository = 'fixture-repo' })
        (New-DocsParityMatrixDocument -RepositoryId 'other-repo' -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin)['id'] | Should -Not -BeExactly $matrix['id']
    }

    It 'computes the integer basis-point floor and null for a zero denominator' {
        Get-DocsScoreBasisPoint -Pass 1 -Fail 2 -NotAssessed 0 | Should -Be 3333
        Get-DocsScoreBasisPoint -Pass 2 -Fail 0 -NotAssessed 1 | Should -Be 6666
        Get-DocsScoreBasisPoint -Pass 5 -Fail 0 -NotAssessed 0 | Should -Be 10000
        Get-DocsScoreBasisPoint -Pass 0 -Fail 3 -NotAssessed 0 | Should -Be 0
        (Get-DocsScoreBasisPoint -Pass 0 -Fail 0 -NotAssessed 0) | Should -BeNullOrEmpty
        (Get-DocsScoreBasisPoint -Pass 1 -Fail 2 -NotAssessed 0).GetType().Name | Should -BeExactly 'Int64'
    }

    It 'counts per dimension summing to the row count' {
        # Arrange
        $elements = @(foreach ($kind in Get-DocsElementKind) { New-DocsLedgerTestElement -Kind $kind })
        $states = @('pass', 'fail', 'not-assessed', 'not-applicable', 'pass', 'fail')
        $rows = @(for ($index = 0; $index -lt 6; $index++) {
                $dimension = @{ exists = [ordered]@{ state = $states[$index]; rationale = $(if ($states[$index] -in 'fail', 'not-applicable') { 'Because.' } else { $null }); evidence_pin_ids = [string[]]@() } }
                New-DocsLedgerTestRow -Element $elements[$index] -PagePath "docs/page-$index.md" -Dimension $dimension
            })
        $matrix = New-DocsLedgerTestMatrix -SnapshotSha256 ('a' * 64) -LedgerSha256 ('b' * 64) -Row $rows

        # Act
        $score = Measure-DocsParityScore -Matrix $matrix

        # Assert
        @($score.Keys) | Should -Be @(Get-DocsParityDimension)
        $score['exists']['pass'] | Should -Be 2
        $score['exists']['fail'] | Should -Be 2
        $score['exists']['not_assessed'] | Should -Be 1
        $score['exists']['not_applicable'] | Should -Be 1
        $score['exists']['score_basis_points'] | Should -Be 4000
        $score['accurate']['not_assessed'] | Should -Be 6
        $score['accurate']['score_basis_points'] | Should -Be 0
        foreach ($name in Get-DocsParityDimension) { ($score[$name]['pass'] + $score[$name]['fail'] + $score[$name]['not_assessed'] + $score[$name]['not_applicable']) | Should -Be 6 }
        (Measure-DocsParityScore -Matrix (New-DocsLedgerTestMatrix -SnapshotSha256 ('a' * 64) -LedgerSha256 ('b' * 64) -Row @()))['exists']['score_basis_points'] | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsMatrixFinding' {
    It 'reports no finding for a consistent matrix' {
        # Arrange
        $fixture = New-TestFixture

        # Act
        $findings = Get-DocsMatrixFinding -Matrix $fixture.Matrix -Ledger $fixture.Ledger -PinSet $fixture.PinSet -PagePath @($script:Page) -PageOwner $script:Owners -LedgerSha256 ('b' * 64)

        # Assert
        $findings.Count | Should -Be 0
        Get-TestMatrixFindingCount -Document $fixture.Matrix | Should -Be 0
    }

    It 'reports DOCS_MATRIX_UNBOUND_ROW' {
        # Arrange
        $fixture = New-TestFixture
        $fixture.Ledger['entries'][0]['page_bindings'] = [object[]]@(@{ page_path = 'docs/other.md'; anchor = $null })

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_UNBOUND_ROW'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/rows/0'
        $findings[0]['related_ids'] | Should -Be @($fixture.Element['element_id'])
        $findings[0]['related_paths'] | Should -Be @($script:Page)
    }

    It 'reports DOCS_MATRIX_ROW_MISSING' {
        # Arrange
        $fixture = New-TestFixture
        $fixture.Matrix['rows'] = [object[]]@()

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_ROW_MISSING'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/rows'
        $findings[0]['related_ids'] | Should -Be @($fixture.Element['element_id'])
        $findings[0]['related_paths'] | Should -Be @($script:Page)
    }

    It 'reports DOCS_MATRIX_DUPLICATE_ROW' {
        # Arrange
        $fixture = New-TestFixture
        $fixture.Matrix['rows'] = [object[]]@($fixture.Matrix['rows'][0], $fixture.Matrix['rows'][0])

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_DUPLICATE_ROW'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/rows/1'
    }

    It 'reports DOCS_MATRIX_PIN_UNKNOWN' {
        # Arrange
        $fixture = New-TestFixture
        $foreign = New-DocsEvidencePin -Element (New-DocsLedgerTestElement -Kind 'cli-option') -PagePath $script:Page -PinnedAt '2026-03-01T12:00:00Z' -Actor $script:Actor
        $fixture.PinSet['pins'] = [object[]]@($fixture.Pin, $foreign)
        $fixture.Matrix['rows'][0]['dimensions']['exists']['evidence_pin_ids'] = [string[]]@($fixture.Pin['pin_id'], ('pin-' + ('0' * 64)), $foreign['pin_id'])

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_PIN_UNKNOWN'

        # Assert
        @($findings | ForEach-Object { $_['pointer'] }) | Should -Be @('/rows/0/dimensions/exists/evidence_pin_ids/1', '/rows/0/dimensions/exists/evidence_pin_ids/2')
        $findings[1]['related_ids'] | Should -Contain $foreign['pin_id']
    }

    It 'reports DOCS_MATRIX_ACCURACY_UNPINNED' {
        # Arrange
        $fixture = New-TestFixture
        $fixture.Matrix['rows'][0]['dimensions']['accurate']['evidence_pin_ids'] = [string[]]@()

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_ACCURACY_UNPINNED'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/rows/0/dimensions/accurate'
    }

    It 'reports DOCS_MATRIX_EXISTS_INCONSISTENT' {
        # Arrange
        $fixture = New-TestFixture

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_EXISTS_INCONSISTENT' -PagePath @('docs/reference/cli.md')
        $none = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_EXISTS_INCONSISTENT'

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/rows/0/dimensions/exists'
        $none.Count | Should -Be 0
    }

    It 'reports DOCS_MATRIX_OWNER_INCONSISTENT' {
        # Arrange
        $fixture = New-TestFixture
        $fixture.Matrix['rows'][0]['page_path'] = 'guides/Cli.md'
        $fixture.Ledger['entries'][0]['page_bindings'] = [object[]]@(@{ page_path = 'guides/Cli.md'; anchor = $null })
        $fixture.Matrix['rows'][0]['dimensions']['exists']['evidence_pin_ids'] = [string[]]@()
        $fixture.Matrix['rows'][0]['dimensions']['accurate']['evidence_pin_ids'] = [string[]]@()
        $fixture.Matrix['rows'][0]['dimensions']['accurate']['state'] = 'not-assessed'

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_OWNER_INCONSISTENT' -PagePath @('guides/Cli.md')

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/rows/0/dimensions/owner_assigned'
        $findings[0]['related_paths'] | Should -Be @('guides/Cli.md')
    }

    It 'reports DOCS_MATRIX_LEDGER_REF as a warning' {
        # Arrange
        $fixture = New-TestFixture

        # Act
        $findings = Get-TestMatrixFinding -Fixture $fixture -Code 'DOCS_MATRIX_LEDGER_REF' -LedgerSha256 ('c' * 64)

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['severity'] | Should -BeExactly 'warning'
        $findings[0]['pointer'] | Should -BeExactly '/ledger_ref/sha256'
    }
}

Describe 'Matrix operations' {
    It 'creates an absent row and derives sorted evidence_pin_ids' {
        # Arrange
        $fixture = New-TestFixture
        $option = New-DocsLedgerTestElement -Kind 'cli-option'
        $before = ConvertTo-DocsCanonicalJson -Value $fixture.Matrix
        $pinA = 'pin-' + ('a' * 64)
        $pinB = 'pin-' + ('b' * 64)

        # Act
        $merged = Merge-DocsParityDimension -Matrix $fixture.Matrix -ElementId $option['element_id'] -Kind 'cli-option' -PagePath 'docs/guides/Start.md' -Dimension 'example_present' -State 'fail' -Rationale 'No example.' -PinId @($pinB, $pinA, $pinB)

        # Assert
        @($merged['rows']).Count | Should -Be 2
        $row = @($merged['rows'] | Where-Object { $_['element_id'] -ceq $option['element_id'] })[0]
        $row['kind'] | Should -BeExactly 'cli-option'
        $row['dimensions']['example_present']['state'] | Should -BeExactly 'fail'
        $row['dimensions']['example_present']['rationale'] | Should -BeExactly 'No example.'
        $row['dimensions']['example_present']['evidence_pin_ids'] | Should -Be @($pinA, $pinB)
        $row['dimensions']['exists']['state'] | Should -BeExactly 'not-assessed'
        $commandKey = $fixture.Element['element_id'] + '|' + $script:Page
        $optionKey = $option['element_id'] + '|docs/guides/Start.md'
        @($merged['rows'] | ForEach-Object { $_['element_id'] + '|' + $_['page_path'] }) | Should -Be @(@($commandKey, $optionKey) | Sort-Object)
        (ConvertTo-DocsCanonicalJson -Value $fixture.Matrix) | Should -BeExactly $before
        Get-TestMatrixFindingCount -Document $merged | Should -Be 0
        { Merge-DocsParityDimension -Matrix $fixture.Matrix -ElementId $option['element_id'] -Kind 'cli-option' -PagePath 'docs/x.md' -Dimension 'colour' -State 'pass' } | Should -Throw -ExpectedMessage '*DOCS_PARITY_INPUT_INVALID*'
    }

    It 'removes rows of one element and page' {
        # Arrange
        $fixture = New-TestFixture
        $matrix = Merge-DocsParityDimension -Matrix $fixture.Matrix -ElementId $fixture.Element['element_id'] -Kind 'cli-command' -PagePath 'docs/guides/Start.md' -Dimension 'exists' -State 'pass'
        $matrix = Merge-DocsParityDimension -Matrix $matrix -ElementId (New-DocsLedgerTestElement -Kind 'cli-option')['element_id'] -Kind 'cli-option' -PagePath $script:Page -Dimension 'exists' -State 'pass'

        # Act
        $withoutPage = Get-DocsMatrixWithoutBinding -Matrix $matrix -ElementId $fixture.Element['element_id'] -PagePath $script:Page
        $withoutElement = Get-DocsMatrixWithoutBinding -Matrix $matrix -ElementId $fixture.Element['element_id']

        # Assert
        @($matrix['rows']).Count | Should -Be 3
        @($withoutPage['rows'] | ForEach-Object { $_['page_path'] } | Sort-Object) | Should -Be @('docs/guides/Start.md', $script:Page)
        @($withoutElement['rows']).Count | Should -Be 1
        $withoutElement['rows'][0]['kind'] | Should -BeExactly 'cli-option'
    }

    It 'removes one pin id from every row' {
        # Arrange
        $fixture = New-TestFixture
        $extra = 'pin-' + ('e' * 64)
        $fixture.Matrix['rows'][0]['dimensions']['exists']['evidence_pin_ids'] = [string[]]@($fixture.Pin['pin_id'], $extra)
        $before = ConvertTo-DocsCanonicalJson -Value $fixture.Matrix

        # Act
        $removed = Merge-DocsMatrixPinRemoval -Matrix $fixture.Matrix -PinId $fixture.Pin['pin_id']

        # Assert
        $removed['rows'][0]['dimensions']['exists']['evidence_pin_ids'] | Should -Be @($extra)
        @($removed['rows'][0]['dimensions']['accurate']['evidence_pin_ids']).Count | Should -Be 0
        (ConvertTo-DocsCanonicalJson -Value $fixture.Matrix) | Should -BeExactly $before
    }

    It 'sets snapshot_ref and ledger_ref' {
        # Arrange
        $fixture = New-TestFixture
        $snapshotPin = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/snap.json'; sha256 = ('1' * 64) }
        $ledgerPin = @{ artifact_kind = 'docs-coverage-ledger'; path = 'estate/ledger.json'; sha256 = ('2' * 64) }

        # Act
        $synced = Merge-DocsMatrixRef -Matrix $fixture.Matrix -SnapshotPin $snapshotPin -LedgerPin $ledgerPin

        # Assert
        $synced['snapshot_ref']['sha256'] | Should -BeExactly ('1' * 64)
        $synced['snapshot_ref']['path'] | Should -BeExactly 'estate/snap.json'
        $synced['ledger_ref']['sha256'] | Should -BeExactly ('2' * 64)
        $synced['ledger_ref']['artifact_kind'] | Should -BeExactly 'docs-coverage-ledger'
        $fixture.Matrix['ledger_ref']['sha256'] | Should -BeExactly ('b' * 64)
        Get-TestMatrixFindingCount -Document $synced | Should -Be 0
    }
}
