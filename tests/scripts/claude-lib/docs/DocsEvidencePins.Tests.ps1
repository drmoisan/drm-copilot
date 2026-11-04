#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsEvidencePins.psm1.

.DESCRIPTION
    Covers the pin identifier derivation, pin construction with an opaque digest, the
    DOCS_PIN_INCONSISTENT rules (tampered identity, wrong pin_id, duplicate pin_id) and the pin
    operations, over in-memory fixtures from DocsLedger.TestSupport.psm1. Built pins and
    collections are validated against the committed runtime schema through Test-DocsArtifactText.
    No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsEvidencePins.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Actor = @{ kind = 'agent'; id = 'fixture-agent' }
    $script:PinnedAt = '2026-03-01T12:00:00Z'
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'

    function Get-TestPinFindingCount {
        param([object] $Document)
        (Test-DocsArtifactText -ArtifactKind 'docs-evidence-pin' -JsonText (ConvertTo-DocsJsonText -Value $Document) -ComposedSchemaSet $script:Composed).Count
    }

    function Get-TestInconsistency {
        param([object] $PinSet)
        , @((Get-DocsPinFinding -PinSet $PinSet -ArtifactPath 'estate/docs-evidence-pins.json') | Where-Object { $_['code'] -ceq 'DOCS_PIN_INCONSISTENT' })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Pin identity and construction' {
    It 'derives pin_id with Get-DocsStableId over element_id, page_path and symbol' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'cli-command'
        $expected = Get-DocsStableId -Prefix 'pin' -Value ([ordered]@{ element_id = $element['element_id']; page_path = 'docs/reference/Cli.md'; symbol = $element['declaration'] })

        # Act
        $derived = Get-DocsPinId -ElementId $element['element_id'] -PagePath 'docs/reference/Cli.md' -Symbol $element['declaration']
        $pin = New-DocsEvidencePin -Element $element -PagePath 'docs/reference/Cli.md' -PinnedAt $script:PinnedAt -Actor $script:Actor

        # Assert
        $derived | Should -BeExactly $expected
        $pin['pin_id'] | Should -BeExactly $expected
        $derived | Should -Not -BeExactly (Get-DocsPinId -ElementId $element['element_id'] -PagePath 'docs/reference/cli.md' -Symbol $element['declaration'])
        $derived | Should -Match '^pin-[0-9a-f]{64}$'
    }

    It 'copies source_sha256 as an opaque value and allows a null revision' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'public-symbol'
        $element['source_sha256'] = 'f' * 64

        # Act
        $pin = New-DocsEvidencePin -Element $element -PagePath 'docs/reference/Module.md' -Claim 'Describes Get-Thing.' -Revision $null -PinnedAt $script:PinnedAt -Actor $script:Actor
        $pinned = New-DocsEvidencePin -Element $element -PagePath 'docs/guides/Module.md' -Revision $script:Revision -PinnedAt $script:PinnedAt -Actor $script:Actor

        # Assert
        $pin['source_sha256'] | Should -BeExactly ('f' * 64)
        $pin['element_kind'] | Should -BeExactly 'public-symbol'
        $pin['symbol'] | Should -BeExactly 'function Get-Thing'
        $pin['source_path'] | Should -BeExactly 'src/app/Module.psm1'
        $pin['revision'] | Should -BeNullOrEmpty
        $pin['claim'] | Should -BeExactly 'Describes Get-Thing.'
        $pin['pinned_by']['id'] | Should -BeExactly 'fixture-agent'
        $pinned['revision'] | Should -BeExactly $script:Revision
        $pinned['claim'] | Should -BeNullOrEmpty
        @($pin.Keys) | Should -Be @('pin_id', 'element_id', 'element_kind', 'page_path', 'symbol', 'source_path', 'source_sha256', 'revision', 'claim', 'pinned_at', 'pinned_by')
        Get-TestPinFindingCount -Document (New-DocsLedgerTestPinSet -Pin @($pin, $pinned)) | Should -Be 0
        (Get-TestInconsistency -PinSet (New-DocsLedgerTestPinSet -Pin @($pin, $pinned))).Count | Should -Be 0
    }

    It 'builds an empty collection whose id depends on the repository id' {
        # Act
        $first = New-DocsPinCollectionDocument -RepositoryId 'fixture-repo'
        $second = New-DocsPinCollectionDocument -RepositoryId 'fixture-repo'
        $other = New-DocsPinCollectionDocument -RepositoryId 'other-repo'

        # Assert
        $first['id'] | Should -BeExactly $second['id']
        $first['id'] | Should -Not -BeExactly $other['id']
        @($first['pins']).Count | Should -Be 0
        Get-TestPinFindingCount -Document $first | Should -Be 0
    }
}

Describe 'Get-DocsPinFinding' {
    It 'reports DOCS_PIN_INCONSISTENT for a tampered identity' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'http-route'
        $pin = New-DocsEvidencePin -Element $element -PagePath 'docs/reference/Routes.md' -PinnedAt $script:PinnedAt -Actor $script:Actor
        $pin['symbol'] = 'GET /items/{id}'
        $pin['pin_id'] = Get-DocsPinId -ElementId $pin['element_id'] -PagePath $pin['page_path'] -Symbol $pin['symbol']

        # Act
        $findings = Get-TestInconsistency -PinSet (New-DocsLedgerTestPinSet -Pin @($pin))

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/pins/0/element_id'
        $findings[0]['severity'] | Should -BeExactly 'error'
        $findings[0]['related_ids'] | Should -Contain $pin['element_id']
        $findings[0]['related_paths'] | Should -Be @('docs/reference/Routes.md')
    }

    It 'reports DOCS_PIN_INCONSISTENT for a wrong pin_id' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'config-key'
        $pin = New-DocsEvidencePin -Element $element -PagePath 'docs/reference/Settings.md' -PinnedAt $script:PinnedAt -Actor $script:Actor
        $pin['pin_id'] = 'pin-' + ('0' * 64)

        # Act
        $findings = Get-TestInconsistency -PinSet (New-DocsLedgerTestPinSet -Pin @($pin))

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/pins/0/pin_id'
    }

    It 'reports DOCS_PIN_INCONSISTENT for a duplicate pin_id' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'cli-option'
        $pin = New-DocsEvidencePin -Element $element -PagePath 'docs/reference/Cli.md' -PinnedAt $script:PinnedAt -Actor $script:Actor

        # Act
        $findings = Get-TestInconsistency -PinSet (New-DocsLedgerTestPinSet -Pin @($pin, $pin))

        # Assert
        $findings.Count | Should -Be 1
        $findings[0]['pointer'] | Should -BeExactly '/pins/1/pin_id'
        $findings[0]['related_ids'] | Should -Contain $pin['pin_id']
    }
}

Describe 'Pin operations' {
    It 'replaces a pin with the same pin_id' {
        # Arrange
        $command = New-DocsLedgerTestElement -Kind 'cli-command'
        $option = New-DocsLedgerTestElement -Kind 'cli-option'
        $first = New-DocsEvidencePin -Element $command -PagePath 'docs/reference/Cli.md' -PinnedAt $script:PinnedAt -Actor $script:Actor
        $second = New-DocsEvidencePin -Element $option -PagePath 'docs/reference/Cli.md' -PinnedAt $script:PinnedAt -Actor $script:Actor
        $pinSet = New-DocsLedgerTestPinSet -Pin @($second, $first)
        $before = ConvertTo-DocsCanonicalJson -Value $pinSet
        $replacement = New-DocsEvidencePin -Element $command -PagePath 'docs/reference/Cli.md' -Claim 'Updated claim.' -Revision $script:Revision -PinnedAt '2026-03-02T00:00:00Z' -Actor $script:Actor

        # Act
        $merged = Merge-DocsEvidencePin -PinSet $pinSet -Pin $replacement
        $merged['pins'][0]['claim'] = 'tampered'

        # Assert
        @($merged['pins']).Count | Should -Be 2
        $ids = @((Merge-DocsEvidencePin -PinSet $pinSet -Pin $replacement)['pins'] | ForEach-Object { $_['pin_id'] })
        [string[]] $sorted = @($ids)
        [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
        $ids | Should -Be $sorted
        @((Merge-DocsEvidencePin -PinSet $pinSet -Pin $replacement)['pins'] | Where-Object { $_['pin_id'] -ceq $first['pin_id'] })[0]['claim'] | Should -BeExactly 'Updated claim.'
        (ConvertTo-DocsCanonicalJson -Value $pinSet) | Should -BeExactly $before
        Get-TestPinFindingCount -Document (Merge-DocsEvidencePin -PinSet $pinSet -Pin $replacement) | Should -Be 0
    }

    It 'removes the pins of one element and page' {
        # Arrange
        $command = New-DocsLedgerTestElement -Kind 'cli-command'
        $option = New-DocsLedgerTestElement -Kind 'cli-option'
        $pins = @(
            (New-DocsEvidencePin -Element $command -PagePath 'docs/reference/Cli.md' -PinnedAt $script:PinnedAt -Actor $script:Actor)
            (New-DocsEvidencePin -Element $command -PagePath 'docs/guides/Start.md' -PinnedAt $script:PinnedAt -Actor $script:Actor)
            (New-DocsEvidencePin -Element $option -PagePath 'docs/reference/Cli.md' -PinnedAt $script:PinnedAt -Actor $script:Actor)
        )
        $pinSet = New-DocsLedgerTestPinSet -Pin $pins
        $before = ConvertTo-DocsCanonicalJson -Value $pinSet

        # Act
        $withoutPage = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId $command['element_id'] -PagePath 'docs/reference/Cli.md'
        $withoutElement = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId $command['element_id']
        $withoutUnknown = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId ('cli-command-' + ('0' * 64))

        # Assert
        @($withoutPage['pins'] | ForEach-Object { $_['pin_id'] } | Sort-Object) | Should -Be @(@($pins[1]['pin_id'], $pins[2]['pin_id']) | Sort-Object)
        @($withoutElement['pins'] | ForEach-Object { $_['pin_id'] }) | Should -Be @($pins[2]['pin_id'])
        @($withoutUnknown['pins']).Count | Should -Be 3
        (ConvertTo-DocsCanonicalJson -Value $pinSet) | Should -BeExactly $before
    }
}
