#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1.

.DESCRIPTION
    Covers the recording in-memory context (call order, read-after-write, injected failures),
    the fixture documents against the committed runtime schemas, the fixture profile through
    ConvertFrom-DocsProfileText, and the seeded shuffle. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

    function Get-TestArtifactFindingCount {
        param([string] $Kind, [object] $Document)
        (Test-DocsArtifactText -ArtifactKind $Kind -JsonText (ConvertTo-DocsJsonText -Value $Document) -ComposedSchemaSet $script:Composed).Count
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'New-DocsLedgerTestContext' {
    It 'records every context call in order' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/a.json' = '{}'; 'docs/one.md' = 'one' }

        # Act
        [void](& $test.Context.TestFile 'estate/a.json')
        [void](& $test.Context.ReadBytes 'estate/a.json')
        [void](& $test.Context.ReadText 'estate/a.json')
        $listed = & $test.Context.ListFile 'docs'
        & $test.Context.WriteText 'docs/two.md' 'two' 'create'

        # Assert
        @($test.CallLog | ForEach-Object { $_.Member }) | Should -Be @('TestFile', 'ReadBytes', 'ReadText', 'ListFile', 'WriteText')
        @($test.CallLog | ForEach-Object { $_.RelativePath }) | Should -Be @('estate/a.json', 'estate/a.json', 'estate/a.json', 'docs', 'docs/two.md')
        $test.CallLog[4].Mode | Should -BeExactly 'create'
        $listed | Should -Be @('docs/one.md')
        (& $test.Context.UtcNow).Kind | Should -Be ([System.DateTimeKind]::Utc)
        @($test.Context.PSObject.Properties | ForEach-Object { $_.Name }) | Should -Be @('RepositoryRoot', 'ReadText', 'ReadBytes', 'TestFile', 'ListFile', 'WriteText', 'UtcNow', 'InvokeProcess')
    }

    It 'returns written text on a later ReadBytes' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'docs/old.md' = 'old' }

        # Act
        & $test.Context.WriteText 'docs/new.md' 'hello' 'create'
        & $test.Context.WriteText 'docs/old.md' 'replaced' 'overwrite'
        $newBytes = & $test.Context.ReadBytes 'docs/new.md'
        $oldText = & $test.Context.ReadText 'docs/old.md'

        # Assert
        $script:Utf8.GetString($newBytes) | Should -BeExactly 'hello'
        $oldText | Should -BeExactly 'replaced'
        & $test.Context.TestFile 'docs/new.md' | Should -BeTrue
        $test.WriteLog.Count | Should -Be 2
        $test.WriteLog[0].Mode | Should -BeExactly 'create'
        $test.WriteLog[1].Mode | Should -BeExactly 'overwrite'
    }

    It 'raises the injected read and write failures' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/bad.json' = '{}'; 'docs/kept.md' = 'kept' } -ReadBytesFailure @{ 'estate/bad.json' = 'injected read failure' } -WriteTextFailure @{ 'docs/blocked.md' = 'injected write failure' }

        # Act and Assert
        { & $test.Context.ReadBytes 'estate/bad.json' } | Should -Throw -ExpectedMessage '*injected read failure*'
        { & $test.Context.ReadText 'estate/bad.json' } | Should -Throw -ExpectedMessage '*injected read failure*'
        { & $test.Context.WriteText 'docs/blocked.md' 'x' 'create' } | Should -Throw -ExpectedMessage '*injected write failure*'
        { & $test.Context.ReadBytes 'estate/absent.json' } | Should -Throw -ExceptionType ([System.Management.Automation.ItemNotFoundException])
        { & $test.Context.WriteText 'docs/kept.md' 'x' 'create' } | Should -Throw -ExpectedMessage '*already exists*'
        { & $test.Context.InvokeProcess 'tool' @() '' 1 } | Should -Throw
        $test.WriteLog.Count | Should -Be 0
        $script:Utf8.GetString((& $test.Context.ReadBytes 'docs/kept.md')) | Should -BeExactly 'kept'
    }

    It 'uses the supplied clock and keeps a fresh file map per context' {
        # Arrange
        $clock = [datetime]::new(2030, 6, 7, 8, 9, 10, [System.DateTimeKind]::Utc)
        $first = New-DocsLedgerTestContext -UtcNow $clock
        $second = New-DocsLedgerTestContext

        # Act
        & $first.Context.WriteText 'docs/only-first.md' 'x' 'create'

        # Assert
        (& $first.Context.UtcNow) | Should -Be $clock
        & $second.Context.TestFile 'docs/only-first.md' | Should -BeFalse
        $second.CallLog.Count | Should -Be 1
    }
}

Describe 'Fixture documents' {
    It 'fixture snapshot produces no finding from Test-DocsArtifactText' {
        # Arrange
        $snapshot = New-DocsLedgerTestSnapshot
        $unpinned = New-DocsLedgerTestSnapshot -NoRevision

        # Assert
        Get-TestArtifactFindingCount -Kind 'surface-inventory-snapshot' -Document $snapshot | Should -Be 0
        Get-TestArtifactFindingCount -Kind 'surface-inventory-snapshot' -Document $unpinned | Should -Be 0
        @($snapshot['elements']).Count | Should -Be 6
        @($snapshot['elements'] | ForEach-Object { $_['kind'] }) | Should -Be @(Get-DocsElementKind)
        @($snapshot['elements'] | ForEach-Object { $_['analysis_method'] } | Sort-Object -Unique) | Should -Be @('native', 'scanner')
        $snapshot['diagnostics'][0]['extensions']['docs.precision-limit']['element_kind'] | Should -BeExactly 'cli-command'
        $unpinned['revision'] | Should -BeNullOrEmpty
    }

    It 'fixture profile loads without an error finding' {
        # Arrange
        $fixtureProfile = New-DocsLedgerTestProfile -AllowDeferred $false -MaxStalePages 2

        # Act
        $result = ConvertFrom-DocsProfileText -Text (ConvertTo-DocsJsonText -Value $fixtureProfile) -ArtifactPath 'docs-profile.json' -ComposedSchemaSet $script:Composed

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
        $result.Profile['completion_gates']['docs_complete']['allow_deferred'] | Should -BeFalse
        $result.Profile['completion_gates']['docs_complete']['max_stale_pages'] | Should -Be 2
        $result.Profile['page_owners'][0]['owner'] | Should -BeExactly 'docs-team'
    }

    It 'fixture ledger, matrix and pin collection produce no finding from Test-DocsArtifactText' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'cli-command'
        $digest = Get-DocsSha256Hex -Text 'snapshot'
        $pin = New-DocsLedgerTestPin -Element $element
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $digest -Entry @(
            (New-DocsLedgerTestEntry -Element $element)
            (New-DocsLedgerTestEntry -Element (New-DocsLedgerTestElement -Kind 'http-route') -Disposition 'deferred' -Owner 'docs-team' -Target 'Next release')
        )
        $matrix = New-DocsLedgerTestMatrix -SnapshotSha256 $digest -LedgerSha256 (Get-DocsSha256Hex -Text 'ledger') -Row @(
            (New-DocsLedgerTestRow -Element $element -Dimension @{ exists = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) } })
        )
        $pins = New-DocsLedgerTestPinSet -Pin @($pin)

        # Assert
        Get-TestArtifactFindingCount -Kind 'docs-coverage-ledger' -Document $ledger | Should -Be 0
        Get-TestArtifactFindingCount -Kind 'docs-parity-matrix' -Document $matrix | Should -Be 0
        Get-TestArtifactFindingCount -Kind 'docs-evidence-pin' -Document $pins | Should -Be 0
        $pin['pin_id'] | Should -BeExactly (Get-DocsStableId -Prefix 'pin' -Value ([ordered]@{ element_id = $element['element_id']; page_path = 'docs/reference/Cli.md'; symbol = $element['declaration'] }))
    }
}

Describe 'Get-DocsLedgerTestShuffle' {
    It 'shuffle is a permutation and deterministic per seed' {
        # Arrange
        $items = @(1..20 | ForEach-Object { "item-$_" })
        $changed = 0

        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Act
            $first = Get-DocsLedgerTestShuffle -Item $items -Seed $seed
            $second = Get-DocsLedgerTestShuffle -Item $items -Seed $seed

            # Assert
            @($first | Sort-Object) | Should -Be @($items | Sort-Object) -Because "seed=$seed yields a permutation"
            $first | Should -Be $second -Because "seed=$seed is deterministic"
            if ((@($first) -join ',') -cne ($items -join ',')) { $changed++ }
        }
        $changed | Should -BeGreaterThan 0
        (Get-DocsLedgerTestShuffle -Item @() -Seed 11).Count | Should -Be 0
        @(Get-DocsLedgerTestSeed) | Should -Be @(11, 1023, 65537)
    }
}
