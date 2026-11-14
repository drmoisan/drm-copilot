#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsSurfaceDelta.psm1 (issue #1034).

.DESCRIPTION
    Drives Compare-DocsSurfaceSnapshot, Get-DocsLedgerChange and Get-DocsSurfaceDeltaFinding with
    in-memory ordinal hashtables only: additions with and without a ledger change, changes with
    and without a ledger or pin change, line_range-only and analysis_method-only differences, a
    $null base, a removed element whose entry is retained, the precondition findings, and a
    seeded shuffle of element and ledger order. No file, clock or process is used.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurfaceDelta.psm1') -Force -ErrorAction Stop

    $script:IdA = 'cli-command-' + ('a' * 64)
    $script:IdB = 'cli-option-' + ('b' * 64)
    $script:IdC = 'config-key-' + ('c' * 64)

    function Get-TestElement {
        param([string] $Id, [string] $Kind = 'cli-command', [string] $Path = 'src/cli.py', [string] $Sha = ('1' * 64), [int] $Start = 1, [string] $Method = 'native')
        $element = @{}
        $element['element_id'] = $Id; $element['kind'] = $Kind; $element['path'] = $Path; $element['source_sha256'] = $Sha
        $element['analysis_method'] = $Method; $element['line_range'] = @{ start = $Start; end = $Start }
        return $element
    }

    function Get-TestSnapshot {
        param([object[]] $Element = @())
        $snapshot = @{}
        $snapshot['elements'] = [object[]] $Element
        return $snapshot
    }

    function Get-TestLedger {
        param([string[]] $Id = @(), [string] $Disposition = 'documented')
        $ledger = @{}
        $ledger['entries'] = [object[]]@(foreach ($item in $Id) { $entry = @{}; $entry['element_id'] = $item; $entry['disposition'] = $Disposition; $entry })
        return $ledger
    }

    function Get-TestPinSet {
        param([string[]] $Id = @(), [string] $Sha = ('9' * 64))
        $pins = @{}
        $pins['pins'] = [object[]]@(foreach ($item in $Id) { $pin = @{}; $pin['element_id'] = $item; $pin['source_sha256'] = $Sha; $pin })
        return $pins
    }

    function Get-TestCode {
        param([object[]] $Finding)
        return [string[]]@($Finding | ForEach-Object { [string] $_['code'] })
    }
}

AfterAll {
    Remove-Module -Name DocsSurfaceDelta, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Compare-DocsSurfaceSnapshot' {
    It 'reports added, changed and removed identifiers sorted ordinally' {
        # Arrange
        $base = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdB), (Get-TestElement -Id $script:IdC))
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdC -Sha ('2' * 64)), (Get-TestElement -Id $script:IdA))

        # Act
        $delta = Compare-DocsSurfaceSnapshot -BaseSnapshot $base -HeadSnapshot $head

        # Assert
        $delta['added'] | Should -Be @($script:IdA)
        $delta['changed'] | Should -Be @($script:IdC)
        $delta['removed'] | Should -Be @($script:IdB)
    }

    It 'treats a line_range-only or analysis_method-only difference as no change' {
        # Arrange
        $base = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA -Start 1 -Method 'native'))
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA -Start 40 -Method 'scanner'))

        # Act
        $delta = Compare-DocsSurfaceSnapshot -BaseSnapshot $base -HeadSnapshot $head

        # Assert
        @($delta['added']).Count + @($delta['changed']).Count + @($delta['removed']).Count | Should -Be 0
    }

    It 'treats a $null base as empty so every head element is added' {
        # Arrange
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdB), (Get-TestElement -Id $script:IdA))

        # Act
        $delta = Compare-DocsSurfaceSnapshot -BaseSnapshot $null -HeadSnapshot $head

        # Assert
        $delta['added'] | Should -Be @($script:IdA, $script:IdB)
        @($delta['removed']).Count | Should -Be 0
    }
}

Describe 'Get-DocsLedgerChange' {
    It 'reports an absent-to-present ledger entry as a ledger change' {
        # Act
        $change = Get-DocsLedgerChange -BaseLedger (Get-TestLedger) -HeadLedger (Get-TestLedger -Id $script:IdA) -BasePins $null -HeadPins $null -ElementId $script:IdA

        # Assert
        $change.LedgerChanged | Should -BeTrue
        $change.PinChanged | Should -BeFalse
    }

    It 'reports a changed entry and, separately, a changed pin' {
        # Act
        $ledger = Get-DocsLedgerChange -BaseLedger (Get-TestLedger -Id $script:IdA) -HeadLedger (Get-TestLedger -Id $script:IdA -Disposition 'excluded') -ElementId $script:IdA
        $pin = Get-DocsLedgerChange -BaseLedger (Get-TestLedger -Id $script:IdA) -HeadLedger (Get-TestLedger -Id $script:IdA) -BasePins (Get-TestPinSet -Id $script:IdA) -HeadPins (Get-TestPinSet -Id $script:IdA -Sha ('8' * 64)) -ElementId $script:IdA

        # Assert
        $ledger.LedgerChanged | Should -BeTrue
        $pin.LedgerChanged | Should -BeFalse
        $pin.PinChanged | Should -BeTrue
    }
}

Describe 'Get-DocsSurfaceDeltaFinding' {
    It 'reports DOCS_SURFACE_UNLEDGERED_ADDITION naming the element when the ledger is unchanged' {
        # Arrange
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA -Path 'src/tool.py'))

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot (Get-TestSnapshot) -HeadSnapshot $head -BaseLedger (Get-TestLedger) -HeadLedger (Get-TestLedger) -SnapshotPath 'docs/s.json'

        # Assert
        Get-TestCode -Finding $outcome.Findings | Should -Be @('DOCS_SURFACE_UNLEDGERED_ADDITION')
        $finding = @($outcome.Findings)[0]
        $finding['severity'] | Should -BeExactly 'error'
        $finding['message'] | Should -Match ([regex]::Escape($script:IdA))
        $finding['message'] | Should -Match 'cli-command'
        $finding['message'] | Should -Match 'src/tool.py'
    }

    It 'reports no finding for an addition with a head ledger entry' {
        # Arrange
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA))

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot (Get-TestSnapshot) -HeadSnapshot $head -BaseLedger (Get-TestLedger) -HeadLedger (Get-TestLedger -Id $script:IdA)

        # Assert
        @($outcome.Findings).Count | Should -Be 0
        $outcome.Delta['added'] | Should -Be @($script:IdA)
    }

    It 'reports DOCS_SURFACE_UNLEDGERED_CHANGE for a changed digest with no ledger or pin change' {
        # Arrange
        $base = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA))
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA -Sha ('2' * 64)))
        $ledger = Get-TestLedger -Id $script:IdA

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot $base -HeadSnapshot $head -BaseLedger $ledger -HeadLedger $ledger -BasePins (Get-TestPinSet -Id $script:IdA) -HeadPins (Get-TestPinSet -Id $script:IdA)

        # Assert
        Get-TestCode -Finding $outcome.Findings | Should -Be @('DOCS_SURFACE_UNLEDGERED_CHANGE')
    }

    It 'reports no finding for a changed digest whose pin changed' {
        # Arrange
        $base = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA))
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA -Sha ('2' * 64)))
        $ledger = Get-TestLedger -Id $script:IdA

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot $base -HeadSnapshot $head -BaseLedger $ledger -HeadLedger $ledger -BasePins (Get-TestPinSet -Id $script:IdA) -HeadPins (Get-TestPinSet -Id $script:IdA -Sha ('2' * 64))

        # Assert
        @($outcome.Findings).Count | Should -Be 0
    }

    It 'reports nothing for line_range-only and analysis_method-only differences' {
        # Arrange
        $base = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA -Start 3), (Get-TestElement -Id $script:IdB -Method 'native'))
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA -Start 9), (Get-TestElement -Id $script:IdB -Method 'scanner'))

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot $base -HeadSnapshot $head -BaseLedger (Get-TestLedger) -HeadLedger (Get-TestLedger)

        # Assert
        @($outcome.Findings).Count | Should -Be 0
    }

    It 'makes every head element added when the base snapshot is $null' {
        # Arrange
        $head = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA), (Get-TestElement -Id $script:IdB -Kind 'cli-option'))

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot $null -HeadSnapshot $head -BaseLedger $null -HeadLedger $null

        # Assert
        $outcome.Delta['added'] | Should -Be @($script:IdA, $script:IdB)
        Get-TestCode -Finding $outcome.Findings | Should -Be @('DOCS_SURFACE_UNLEDGERED_ADDITION', 'DOCS_SURFACE_UNLEDGERED_ADDITION')
    }

    It 'reports DOCS_SURFACE_REMOVED_ENTRY_RETAINED as a warning for a removed element with an unchanged entry' {
        # Arrange
        $base = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA))
        $ledger = Get-TestLedger -Id $script:IdA

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot $base -HeadSnapshot (Get-TestSnapshot) -BaseLedger $ledger -HeadLedger $ledger

        # Assert
        Get-TestCode -Finding $outcome.Findings | Should -Be @('DOCS_SURFACE_REMOVED_ENTRY_RETAINED')
        @($outcome.Findings)[0]['severity'] | Should -BeExactly 'warning'
    }

    It 'reports no finding for a removed element whose entry was removed from the head ledger' {
        # Arrange
        $base = Get-TestSnapshot -Element @((Get-TestElement -Id $script:IdA))

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot $base -HeadSnapshot (Get-TestSnapshot) -BaseLedger (Get-TestLedger -Id $script:IdA) -HeadLedger (Get-TestLedger)

        # Assert
        @($outcome.Findings).Count | Should -Be 0
    }

    It 'reports <Code> for its precondition' -ForEach @(
        @{ Code = 'DOCS_SURFACE_BASE_UNRESOLVED'; Unresolved = $true; Missing = $false; Stale = @() }
        @{ Code = 'DOCS_SURFACE_SNAPSHOT_MISSING'; Unresolved = $false; Missing = $true; Stale = @() }
        @{ Code = 'DOCS_SURFACE_SNAPSHOT_STALE'; Unresolved = $false; Missing = $false; Stale = @('src/cli.py') }
    ) {
        # Arrange
        $head = if ($Missing) { $null } else { Get-TestSnapshot }

        # Act
        $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot (Get-TestSnapshot) -HeadSnapshot $head -BaseRef 'origin/main' -BaseResolved (-not $Unresolved) -SnapshotPath 'docs/s.json' -StaleInputPath ([string[]] $Stale)

        # Assert
        Get-TestCode -Finding $outcome.Findings | Should -Be @($Code)
        @($outcome.Findings)[0]['severity'] | Should -BeExactly 'error'
    }

    It 'produces identical output for a seeded shuffle of element and ledger order' {
        # Arrange
        $seed = 1034
        $random = [System.Random]::new($seed)
        $ids = @(foreach ($n in 1..8) { 'cli-command-' + ([string] $n * 64) })
        $baseElements = @(foreach ($id in $ids[0..3]) { Get-TestElement -Id $id })
        $headElements = @(foreach ($id in $ids[2..7]) { Get-TestElement -Id $id -Sha $(if ($id -eq $ids[3]) { '2' * 64 } else { '1' * 64 }) })
        $ledgerIds = [string[]]@($ids[5], $ids[6])
        $expected = Get-DocsSurfaceDeltaFinding -BaseSnapshot (Get-TestSnapshot -Element $baseElements) -HeadSnapshot (Get-TestSnapshot -Element $headElements) -BaseLedger (Get-TestLedger) -HeadLedger (Get-TestLedger -Id $ledgerIds)
        $expectedText = ConvertTo-Json -InputObject @{ Findings = @($expected.Findings); Delta = $expected.Delta } -Depth 8 -Compress

        foreach ($iteration in 1..5) {
            # Act
            $shuffledBase = @($baseElements | Sort-Object { $random.Next() })
            $shuffledHead = @($headElements | Sort-Object { $random.Next() })
            $shuffledLedger = [string[]]@($ledgerIds | Sort-Object { $random.Next() })
            $actual = Get-DocsSurfaceDeltaFinding -BaseSnapshot (Get-TestSnapshot -Element $shuffledBase) -HeadSnapshot (Get-TestSnapshot -Element $shuffledHead) -BaseLedger (Get-TestLedger) -HeadLedger (Get-TestLedger -Id $shuffledLedger)
            $actualText = ConvertTo-Json -InputObject @{ Findings = @($actual.Findings); Delta = $actual.Delta } -Depth 8 -Compress

            # Assert
            $actualText | Should -BeExactly $expectedText -Because "seed $seed, iteration $iteration"
        }
    }
}
