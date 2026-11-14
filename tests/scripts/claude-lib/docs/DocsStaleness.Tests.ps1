#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsStaleness.psm1.

.DESCRIPTION
    Covers the three pin statuses, the revision rule, the stale-page list and the
    DOCS_STALE_PAGE finding over in-memory fixtures from DocsLedger.TestSupport.psm1. No file is
    written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedger.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsEvidencePins.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsStaleness.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:PinnedAt = '2026-03-01T12:00:00Z'

    function Get-TestElementMap {
        # The Element map of the fixture snapshot view (element_id -> element).
        $snapshot = New-DocsLedgerTestSnapshot
        $text = ConvertTo-DocsJsonText -Value $snapshot
        (ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)).Element
    }

    function Get-TestPin {
        param([System.Collections.IDictionary] $Element, [string] $PagePath, [string] $Digest, [string] $Revision)
        $copy = [ordered]@{}
        foreach ($key in $Element.Keys) { $copy[$key] = $Element[$key] }
        if (-not [string]::IsNullOrEmpty($Digest)) { $copy['source_sha256'] = $Digest }
        New-DocsEvidencePin -Element $copy -PagePath $PagePath -Revision $Revision -PinnedAt $script:PinnedAt -Actor $script:Actor
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsPinStatus' {
    BeforeAll {
        $script:Elements = Get-TestElementMap
        $script:Command = $script:Elements[@($script:Elements.Keys | Where-Object { $_.StartsWith('cli-command-', [System.StringComparison]::Ordinal) })[0]]
    }

    It 'returns digest-changed when digests differ' {
        # Arrange
        $pin = Get-TestPin -Element $script:Command -PagePath 'docs/reference/Cli.md' -Digest ('0' * 64)

        # Act and Assert
        Get-DocsPinStatus -Pin $pin -Element $script:Elements | Should -BeExactly 'digest-changed'
    }

    It 'returns element-missing when no current element has the id' {
        # Arrange
        $pin = Get-TestPin -Element $script:Command -PagePath 'docs/reference/Cli.md'
        $pin['element_id'] = 'cli-command-' + ('0' * 64)

        # Act and Assert
        Get-DocsPinStatus -Pin $pin -Element $script:Elements | Should -BeExactly 'element-missing'
    }

    It 'returns current for equal digests' {
        # Arrange
        $pin = Get-TestPin -Element $script:Command -PagePath 'docs/reference/Cli.md'

        # Act and Assert
        Get-DocsPinStatus -Pin $pin -Element $script:Elements | Should -BeExactly 'current'
    }

    It 'ignores a revision difference' {
        # Arrange
        $same = Get-TestPin -Element $script:Command -PagePath 'docs/reference/Cli.md' -Revision ('a' * 40)
        $changed = Get-TestPin -Element $script:Command -PagePath 'docs/reference/Cli.md' -Digest ('1' * 64) -Revision ('b' * 40)
        $unpinned = Get-TestPin -Element $script:Command -PagePath 'docs/reference/Cli.md' -Revision $null

        # Act and Assert
        Get-DocsPinStatus -Pin $same -Element $script:Elements | Should -BeExactly 'current'
        Get-DocsPinStatus -Pin $unpinned -Element $script:Elements | Should -BeExactly 'current'
        Get-DocsPinStatus -Pin $changed -Element $script:Elements | Should -BeExactly 'digest-changed'
        $upper = Get-TestPin -Element $script:Command -PagePath 'docs/reference/Cli.md' -Digest ($script:Command['source_sha256'].ToUpperInvariant())
        Get-DocsPinStatus -Pin $upper -Element $script:Elements | Should -BeExactly 'digest-changed' -Because 'digests are compared ordinally'
    }
}

Describe 'Get-DocsStalePage and Get-DocsStalenessFinding' {
    BeforeAll {
        $script:Elements = Get-TestElementMap
        $script:ById = @{}
        foreach ($id in $script:Elements.Keys) { $script:ById[$script:Elements[$id]['kind']] = $script:Elements[$id] }
        $script:Pins = @(
            (Get-TestPin -Element $script:ById['cli-command'] -PagePath 'docs/reference/Cli.md')
            (Get-TestPin -Element $script:ById['cli-option'] -PagePath 'docs/reference/Cli.md' -Digest ('2' * 64))
            (Get-TestPin -Element $script:ById['http-route'] -PagePath 'docs/reference/Routes.md')
            (Get-TestPin -Element $script:ById['config-key'] -PagePath 'docs/guides/Settings.md' -Digest ('3' * 64))
            (Get-TestPin -Element $script:ById['public-symbol'] -PagePath 'docs/guides/Settings.md')
        )
        $script:Pins[4]['element_id'] = 'public-symbol-' + ('4' * 64)
        $script:PinSet = New-DocsLedgerTestPinSet -Pin $script:Pins
    }

    It 'lists a page exactly when one of its pins is not current' {
        # Act
        $stale = Get-DocsStalePage -PinSet $script:PinSet -Element $script:Elements

        # Assert
        @($stale | ForEach-Object { $_['page_path'] }) | Should -Be @('docs/guides/Settings.md', 'docs/reference/Cli.md')
        $settings = $stale[0]
        @($settings['pins'] | ForEach-Object { $_['status'] } | Sort-Object) | Should -Be @('digest-changed', 'element-missing')
        [string[]] $pinIds = @($settings['pins'] | ForEach-Object { $_['pin_id'] })
        [string[]] $sortedIds = @($pinIds)
        [Array]::Sort($sortedIds, [System.StringComparer]::Ordinal)
        $pinIds | Should -Be $sortedIds
        @($stale[1]['pins']).Count | Should -Be 1
        $stale[1]['pins'][0]['element_id'] | Should -BeExactly $script:ById['cli-option']['element_id']
        (Get-DocsStalePage -PinSet (New-DocsLedgerTestPinSet -Pin @($script:Pins[0], $script:Pins[2])) -Element $script:Elements).Count | Should -Be 0
    }

    It 'names page path, declaration, element id and status in DOCS_STALE_PAGE' {
        # Arrange
        $stale = Get-DocsStalePage -PinSet $script:PinSet -Element $script:Elements

        # Act
        $warnings = Get-DocsStalenessFinding -StalePage $stale -Element $script:Elements -Severity 'warning' -PinSet $script:PinSet -ArtifactPath 'estate/docs-evidence-pins.json'
        $errors = Get-DocsStalenessFinding -StalePage $stale -Element $script:Elements -Severity 'error'
        $none = Get-DocsStalenessFinding -StalePage @() -Element $script:Elements -Severity 'warning'

        # Assert
        $warnings.Count | Should -Be 2
        @($warnings | ForEach-Object { $_['code'] } | Sort-Object -Unique) | Should -Be @('DOCS_STALE_PAGE')
        @($warnings | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('warning')
        @($errors | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('error')
        $none.Count | Should -Be 0
        $cli = @($warnings | Where-Object { $_['related_paths'] -ccontains 'docs/reference/Cli.md' })[0]
        $cli['message'].Contains('docs/reference/Cli.md', [System.StringComparison]::Ordinal) | Should -BeTrue
        $cli['message'].Contains('Tool Docs Inventory -Analyzer', [System.StringComparison]::Ordinal) | Should -BeTrue
        $cli['message'].Contains($script:ById['cli-option']['element_id'], [System.StringComparison]::Ordinal) | Should -BeTrue
        $cli['message'].Contains('digest-changed', [System.StringComparison]::Ordinal) | Should -BeTrue
        $cli['related_ids'] | Should -Contain $script:ById['cli-option']['element_id']
        $cli['related_ids'] | Should -Contain $script:Pins[1]['pin_id']
        $cli['artifact_path'] | Should -BeExactly 'estate/docs-evidence-pins.json'
        $settings = @($warnings | Where-Object { $_['related_paths'] -ccontains 'docs/guides/Settings.md' })[0]
        $settings['message'].Contains('element-missing', [System.StringComparison]::Ordinal) | Should -BeTrue
        $settings['message'].Contains('function Get-Thing', [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the pin symbol names the declaration of a missing element'
    }
}
