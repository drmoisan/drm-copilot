#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsReceipt.psm1.

.DESCRIPTION
    Seeded [System.Random] generation with the seeds of DocsLedger.TestSupport.psm1 (each
    -Because message states the seed) for the timestamp text, artifact pins, receipt counts and
    receipt construction; exhaustive enumeration for the writer version and the gate decision
    precedence. The receipt identity property lives in DocsReceipt.Tests.ps1. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedger.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsReceipt.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:Kinds = @('docs-profile', 'surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin')

    $snapshotText = ConvertTo-DocsJsonText -Value (New-DocsLedgerTestSnapshot)
    $script:View = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $snapshotText).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $snapshotText)
    $script:Elements = @($script:View.Element.Keys | Sort-Object | ForEach-Object { $script:View.Element[$_] })

    function Get-TestRandomByte {
        param([System.Random] $Random)
        $bytes = [byte[]]::new($Random.Next(0, 64))
        $Random.NextBytes($bytes)
        , $bytes
    }

    function Get-TestRandomPin {
        param([System.Random] $Random)
        Get-DocsArtifactPin -ArtifactKind $script:Kinds[$Random.Next($script:Kinds.Count)] -Path ('estate/' + [string][char](97 + $Random.Next(26)) + [string][char](65 + $Random.Next(26)) + '.json') -Bytes (Get-TestRandomByte -Random $Random)
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsReceipt properties' {
    It 'property ConvertTo-DocsTimestampText: seeded UTC instants round-trip at second precision; every non-Utc Kind throws' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 20; $round++) {
                $ticks = [long] $random.Next() * [long] 10000000 + [long] $random.Next(10000000)
                $instant = [datetime]::new([long] 599266080000000000 + $ticks, [System.DateTimeKind]::Utc)
                $truncated = [datetime]::new($instant.Ticks - ($instant.Ticks % 10000000), [System.DateTimeKind]::Utc)

                # Act
                $text = ConvertTo-DocsTimestampText -UtcNow $instant
                $parsed = [datetime]::ParseExact($text, "yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal)

                # Assert
                $parsed | Should -Be $truncated -Because "seed=$seed round $round"
                $text | Should -Match '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' -Because "seed=$seed round $round"
                foreach ($kind in @([System.DateTimeKind]::Local, [System.DateTimeKind]::Unspecified)) {
                    { ConvertTo-DocsTimestampText -UtcNow ([datetime]::new($instant.Ticks, $kind)) } | Should -Throw -ExpectedMessage 'DOCS_CLOCK_NOT_UTC*' -Because "seed=$seed kind $kind"
                }
            }
        }
    }

    It 'property Get-DocsWriterVersion: constant across calls' {
        $first = Get-DocsWriterVersion
        foreach ($round in 1..10) { Get-DocsWriterVersion | Should -BeExactly $first -Because "call $round" }
        $first | Should -BeExactly '1.0.0'
    }

    It 'property Get-DocsArtifactPin: sha256 equals Get-DocsBytesSha256Hex of seeded byte arrays' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 20; $round++) {
                $bytes = Get-TestRandomByte -Random $random
                $kind = $script:Kinds[$random.Next($script:Kinds.Count)]

                # Act
                $pin = Get-DocsArtifactPin -ArtifactKind $kind -Path 'estate/a.json' -Bytes $bytes

                # Assert
                $pin['sha256'] | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes $bytes) -Because "seed=$seed round $round"
                $pin['artifact_kind'] | Should -BeExactly $kind -Because "seed=$seed round $round"
                $null -eq (Get-DocsArtifactPin -ArtifactKind $kind -Path 'estate/a.json' -Bytes $null) | Should -BeTrue -Because "seed=$seed round $round"
            }
        }
    }

    It 'property Measure-DocsReceiptCount: by_disposition sums to entries matching current elements; precision-limit entries excluded' {
        $dispositions = @('documented', 'excluded', 'deferred')
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $entries = [System.Collections.Generic.List[object]]::new()
            $expected = 0
            $covered = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            foreach ($element in $script:Elements) {
                if ($random.Next(2) -eq 0) { continue }
                $entries.Add((New-DocsLedgerTestEntry -Element $element -Disposition $dispositions[$random.Next(3)] -PageBinding @()))
                [void]$covered.Add([string] $element['element_id'])
                $expected++
            }
            $orphanCount = $random.Next(3)
            for ($index = 0; $index -lt $orphanCount; $index++) {
                $entries.Add((New-DocsLedgerTestEntry -Element @{ element_id = 'config-key-' + ([string] $index * 64); kind = 'config-key'; analysis_method = 'scanner' } -Disposition $dispositions[$random.Next(3)] -PageBinding @()))
            }
            foreach ($id in @($script:View.PrecisionLimit.Keys)) {
                if ($random.Next(2) -eq 0) { $entries.Add((New-DocsPrecisionLimitEntry -Limit $script:View.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Later' -Actor $script:Actor)) }
            }
            $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $script:View.Sha256 -Entry (Get-DocsLedgerTestShuffle -Item $entries.ToArray() -Seed $seed)
            $stale = $random.Next(5)

            # Act
            $count = Measure-DocsReceiptCount -Mode 'docs-complete' -SnapshotView $script:View -Ledger $ledger -StalePageCount $stale

            # Assert
            $sum = [long] 0
            foreach ($value in $count['by_disposition'].Values) { $sum += [long] $value }
            $sum | Should -Be $expected -Because "seed=$seed by_disposition sums to the entries matching current elements"
            $count['undocumented'] | Should -Be ($script:Elements.Count - $covered.Count) -Because "seed=$seed"
            $count['elements_total'] | Should -Be $script:Elements.Count -Because "seed=$seed"
            $count['stale_pages'] | Should -Be $stale -Because "seed=$seed"
            $kindSum = [long] 0
            foreach ($value in $count['by_kind'].Values) { $kindSum += [long] $value }
            $kindSum | Should -Be $script:Elements.Count -Because "seed=$seed by_kind sums to the elements"
        }
    }

    It 'property New-DocsValidationReceipt: receipt validates and inputs are sorted for seeded pins' {
        $modes = @('profile', 'ledger', 'matrix', 'docs-complete')
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $pins = @(for ($index = 0; $index -lt 1 + $random.Next(5); $index++) { Get-TestRandomPin -Random $random })
            $mode = $modes[$random.Next(4)]
            $fail = $random.Next(2) -eq 0
            $findings = @(if ($fail) { New-DocsFinding -Code 'DOCS_INPUT_UNREADABLE' -Severity 'error' -Message 'Absent.' -NextAction 'Create it.' } else { New-DocsFinding -Code 'DOCS_STALE_PAGE' -Severity 'warning' -Message 'Stale.' -NextAction 'Re-pin.' })
            $count = Measure-DocsReceiptCount -Mode $mode -SnapshotView $script:View -Ledger (New-DocsLedgerTestLedger -SnapshotSha256 $script:View.Sha256) -StalePageCount $random.Next(3)

            # Act
            $receipt = New-DocsValidationReceipt -Mode $mode -Repository 'fixture-repo' -Revision $script:Revision -InputPin $pins -Count $count -Finding $findings -IssuedAt '2026-03-01T12:00:00Z' -ValidationResult $(if ($fail) { 'fail' } else { 'pass' })

            # Assert
            (Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText (ConvertTo-DocsJsonText -Value $receipt) -ComposedSchemaSet $script:Composed).Count | Should -Be 0 -Because "seed=$seed the receipt validates"
            [string[]] $keys = @($receipt['inputs'] | ForEach-Object { $_['artifact_kind'] + [string][char]0 + $_['path'] })
            [string[]] $sorted = @($keys)
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $keys | Should -Be $sorted -Because "seed=$seed inputs are sorted by artifact_kind then path"
            @($receipt['inputs'] | ForEach-Object { $_['artifact_kind'] + [string][char]0 + $_['path'] } | Sort-Object -Unique).Count | Should -Be $receipt['inputs'].Count -Because "seed=$seed one pin per artifact"
        }
    }

    It 'property Get-DocsReceiptGateDecision: reason follows the fixed precedence over all combinations of the four failure conditions (exhaustive)' {
        # Arrange
        $count = Measure-DocsReceiptCount -Mode 'docs-complete' -SnapshotView $script:View -Ledger (New-DocsLedgerTestLedger -SnapshotSha256 $script:View.Sha256)
        $errorFinding = New-DocsFinding -Code 'DOCS_SNAPSHOT_UNPINNED' -Severity 'error' -Message 'Unpinned.' -NextAction 'Pin it.'
        $checked = 0
        foreach ($invalid in $false, $true) {
            foreach ($wrongMode in $false, $true) {
                foreach ($failed in $false, $true) {
                    foreach ($wrongRevision in $false, $true) {
                        $receipt = New-DocsValidationReceipt -Mode $(if ($wrongMode) { 'ledger' } else { 'docs-complete' }) -Repository 'fixture-repo' -Revision $script:Revision -InputPin @() -Count $count -Finding $(if ($failed) { @($errorFinding) } else { @() }) -IssuedAt '2026-03-01T12:00:00Z' -ValidationResult $(if ($failed) { 'fail' } else { 'pass' })
                        if ($invalid) { $receipt.Remove('writer') }
                        $head = if ($wrongRevision) { 'e' * 40 } else { $script:Revision }
                        $expected = if ($invalid) { 'receipt-invalid' } elseif ($wrongMode) { 'mode-not-docs-complete' } elseif ($failed) { 'result-fail' } elseif ($wrongRevision) { 'revision-mismatch' } else { 'pass' }

                        # Act
                        $decision = Get-DocsReceiptGateDecision -ReceiptText (ConvertTo-DocsJsonText -Value $receipt) -HeadRevision $head -ComposedSchemaSet $script:Composed

                        # Assert
                        $decision.Reason | Should -BeExactly $expected -Because "invalid=$invalid wrongMode=$wrongMode failed=$failed wrongRevision=$wrongRevision"
                        $decision.Allow | Should -Be ($expected -ceq 'pass') -Because "invalid=$invalid wrongMode=$wrongMode failed=$failed wrongRevision=$wrongRevision"
                        $checked++
                    }
                }
            }
        }
        $checked | Should -Be 16
    }
}
