#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsLedgerRules.psm1.

.DESCRIPTION
    The companion table is enumerated exhaustively over every disposition and field-presence
    combination; the ledger rules are checked over every subset of a fixed snapshot and under
    seeded entry permutations (each -Because message states the seed). No file is written.
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

    $script:Actor = @{ kind = 'agent'; id = 'fixture-agent' }

    function Get-TestView {
        param([object] $Snapshot)
        $text = ConvertTo-DocsJsonText -Value $Snapshot
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsLedger properties (P1-T3)' {
    It 'property Get-DocsLedgerEntryCompanionFinding: findings equal the companion table over every disposition and field-presence combination' {
        # Arrange
        $element = New-DocsLedgerTestElement -Kind 'config-key'
        $checked = 0
        foreach ($disposition in 'documented', 'excluded', 'deferred') {
            foreach ($hasBinding in $false, $true) {
                foreach ($hasRationale in $false, $true) {
                    foreach ($hasOwner in $false, $true) {
                        foreach ($hasTarget in $false, $true) {
                            $bindings = if ($hasBinding) { @(@{ page_path = 'docs/a.md'; anchor = $null }) } else { @() }
                            $entry = New-DocsLedgerEntry -Element $element -Disposition $disposition -PageBinding $bindings -Rationale $(if ($hasRationale) { 'Because.' } else { $null }) -Owner $(if ($hasOwner) { 'docs-team' } else { $null }) -Target $(if ($hasTarget) { 'Soon' } else { $null }) -Actor $script:Actor
                            $expected = @()
                            if ($disposition -ceq 'documented' -and -not $hasBinding) { $expected += 'DOCS_LEDGER_BINDING_REQUIRED' }
                            if ($disposition -ceq 'excluded' -and -not $hasRationale) { $expected += 'DOCS_LEDGER_RATIONALE_REQUIRED' }
                            if ($disposition -ceq 'deferred' -and -not $hasOwner) { $expected += 'DOCS_LEDGER_OWNER_REQUIRED' }
                            if ($disposition -ceq 'deferred' -and -not $hasTarget) { $expected += 'DOCS_LEDGER_TARGET_REQUIRED' }

                            # Act
                            $findings = Get-DocsLedgerEntryCompanionFinding -Entry $entry -Pointer '/entries/0'

                            # Assert
                            @($findings | ForEach-Object { $_['code'] } | Sort-Object) | Should -Be @($expected | Sort-Object) -Because "disposition=$disposition binding=$hasBinding rationale=$hasRationale owner=$hasOwner target=$hasTarget"
                            $checked++
                        }
                    }
                }
            }
        }
        $checked | Should -Be 48
    }

    It 'property Get-DocsLedgerFinding: missing-disposition findings name exactly the complement of every entry subset; DOCS_LEDGER_LIMIT_UNRECORDED names exactly the unrecorded limits of every limit subset; findings and canonical output invariant under entry permutation' {
        # Arrange: six elements and three precision limits.
        $diagnostics = @(
            (New-DocsLedgerTestPrecisionLimitDiagnostic)
            (New-DocsLedgerTestPrecisionLimitDiagnostic -Code 'DOCS_SCANNER_DYNAMIC_ROUTE' -Path 'src/app/Routes.ps1' -ElementKind 'http-route')
            (New-DocsLedgerTestPrecisionLimitDiagnostic -Code 'DOCS_SCANNER_DYNAMIC_KEY' -Path 'config/Dynamic.json' -ElementKind 'config-key')
        )
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot -Diagnostic $diagnostics)
        [string[]] $elementIds = @($view.Element.Keys | Sort-Object)
        [string[]] $limitIds = @($view.PrecisionLimit.Keys | Sort-Object)
        $elementEntries = @{}
        foreach ($id in $elementIds) { $elementEntries[$id] = New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = 'docs/a.md'; anchor = $null }) -Actor $script:Actor }
        $limitEntries = @{}
        foreach ($id in $limitIds) { $limitEntries[$id] = New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Soon' -Actor $script:Actor }
        $allLimitEntries = @(foreach ($id in $limitIds) { $limitEntries[$id] })
        $allElementEntries = @(foreach ($id in $elementIds) { $elementEntries[$id] })

        # Act and Assert: every element subset.
        for ($mask = 0; $mask -lt 64; $mask++) {
            $present = @(for ($bit = 0; $bit -lt 6; $bit++) { if (($mask -band (1 -shl $bit)) -ne 0) { $elementIds[$bit] } })
            $entries = @(foreach ($id in $present) { $elementEntries[$id] }) + $allLimitEntries
            $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
            $missing = @((Get-DocsLedgerFinding -Ledger $ledger -SnapshotView $view) | Where-Object { $_['code'] -ceq 'DOCS_LEDGER_MISSING_DISPOSITION' } | ForEach-Object { $_['related_ids'][0] } | Sort-Object)
            $complement = @($elementIds | Where-Object { $present -cnotcontains $_ } | Sort-Object)
            $missing | Should -Be $complement -Because "element subset mask=$mask"
        }

        # Act and Assert: every limit subset.
        for ($mask = 0; $mask -lt 8; $mask++) {
            $present = @(for ($bit = 0; $bit -lt 3; $bit++) { if (($mask -band (1 -shl $bit)) -ne 0) { $limitIds[$bit] } })
            $entries = $allElementEntries + @(foreach ($id in $present) { $limitEntries[$id] })
            $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
            $unrecorded = @((Get-DocsLedgerFinding -Ledger $ledger -SnapshotView $view) | Where-Object { $_['code'] -ceq 'DOCS_LEDGER_LIMIT_UNRECORDED' } | ForEach-Object { @($_['related_ids'] | Where-Object { Test-DocsElementId -ElementId $_ })[0] } | Sort-Object)
            $complement = @($limitIds | Where-Object { $present -cnotcontains $_ } | Sort-Object)
            $unrecorded | Should -Be $complement -Because "limit subset mask=$mask"
        }

        # Act and Assert: permutation invariance over a partial ledger.
        $partial = @($allElementEntries[0], $allElementEntries[2], $allElementEntries[5], $allLimitEntries[1])
        $baseline = ConvertTo-DocsCanonicalJson -Value (Get-DocsLedgerFinding -Ledger (New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $partial) -SnapshotView $view)
        foreach ($seed in Get-DocsLedgerTestSeed) {
            $shuffled = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry (Get-DocsLedgerTestShuffle -Item $partial -Seed $seed)
            (ConvertTo-DocsCanonicalJson -Value (Get-DocsLedgerFinding -Ledger $shuffled -SnapshotView $view)) | Should -BeExactly $baseline -Because "seed=$seed"
        }
    }
}
