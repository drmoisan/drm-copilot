#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsReceipt.psm1.

.DESCRIPTION
    Covers the timestamp text, the writer version, artifact pins, the receipt identifier (with
    its identity property), receipt counts, receipt construction validated against the composed
    runtime schema, and every reason of Get-DocsReceiptGateDecision. Assertions use codes,
    booleans and identifiers, never Test-Json message text. No file is written.
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
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

    function Get-TestView {
        $snapshot = New-DocsLedgerTestSnapshot
        $text = ConvertTo-DocsJsonText -Value $snapshot
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)
    }

    function Get-TestPinList {
        @(
            (Get-DocsArtifactPin -ArtifactKind 'surface-inventory-snapshot' -Path 'estate/surface-inventory-snapshot.json' -Bytes $script:Utf8.GetBytes('snapshot'))
            (Get-DocsArtifactPin -ArtifactKind 'docs-profile' -Path 'docs/documentation-estate/docs-profile.json' -Bytes $script:Utf8.GetBytes('profile'))
            (Get-DocsArtifactPin -ArtifactKind 'docs-coverage-ledger' -Path 'estate/docs-coverage-ledger.json' -Bytes $script:Utf8.GetBytes('ledger'))
        )
    }

    function New-TestReceipt {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Mode = 'docs-complete', [string] $ValidationResult = 'pass', [string] $Revision = $script:Revision, [object[]] $Finding = @(), [object[]] $InputPin = (Get-TestPinList), [string] $IssuedAt = '2026-03-01T12:00:00Z')
        $count = Measure-DocsReceiptCount -Mode $Mode -SnapshotView (Get-TestView) -Ledger (New-DocsLedgerTestLedger -SnapshotSha256 ('a' * 64))
        New-DocsValidationReceipt -Mode $Mode -Repository 'fixture-repo' -Revision $Revision -InputPin $InputPin -Count $count -Finding $Finding -IssuedAt $IssuedAt -ValidationResult $ValidationResult
    }

    function Get-TestReceiptFindingCount {
        param([object] $Receipt)
        (Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText (ConvertTo-DocsJsonText -Value $Receipt) -ComposedSchemaSet $script:Composed).Count
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-DocsTimestampText and Get-DocsWriterVersion' {
    It 'formats the invariant UTC timestamp and throws for a non-Utc Kind' {
        # Arrange
        $utc = [datetime]::new(2026, 3, 1, 12, 5, 9, [System.DateTimeKind]::Utc)
        $local = [datetime]::new(2026, 3, 1, 12, 5, 9, [System.DateTimeKind]::Local)
        $unspecified = [datetime]::new(2026, 3, 1, 12, 5, 9, [System.DateTimeKind]::Unspecified)

        # Act and Assert
        ConvertTo-DocsTimestampText -UtcNow $utc | Should -BeExactly '2026-03-01T12:05:09Z'
        ConvertTo-DocsTimestampText -UtcNow $utc.AddMilliseconds(999) | Should -BeExactly '2026-03-01T12:05:09Z' -Because 'the text has second precision'
        { ConvertTo-DocsTimestampText -UtcNow $local } | Should -Throw -ExpectedMessage 'DOCS_CLOCK_NOT_UTC*'
        { ConvertTo-DocsTimestampText -UtcNow $unspecified } | Should -Throw -ExpectedMessage 'DOCS_CLOCK_NOT_UTC*'
    }

    It 'returns writer version 1.0.0' {
        Get-DocsWriterVersion | Should -BeExactly '1.0.0'
    }
}

Describe 'Get-DocsArtifactPin and receipt inputs' {
    It 'pins raw bytes with Get-DocsBytesSha256Hex and pins nothing for absent bytes' {
        # Arrange
        $bytes = [byte[]]@(0xEF, 0xBB, 0xBF, 0x7B, 0x7D, 0x0A)

        # Act
        $pin = Get-DocsArtifactPin -ArtifactKind 'docs-coverage-ledger' -Path 'estate/docs-coverage-ledger.json' -Bytes $bytes
        $absent = Get-DocsArtifactPin -ArtifactKind 'docs-coverage-ledger' -Path 'estate/docs-coverage-ledger.json' -Bytes $null

        # Assert
        @($pin.Keys) | Should -Be @('artifact_kind', 'path', 'sha256')
        $pin['sha256'] | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes $bytes)
        $pin['sha256'] | Should -Not -BeExactly (Get-DocsSha256Hex -Text ('{}' + "`n")) -Because 'the raw bytes including the BOM are pinned'
        $null -eq $absent | Should -BeTrue
        (Get-DocsArtifactPin -ArtifactKind 'docs-profile' -Path 'p.json' -Bytes ([byte[]]@()))['sha256'] | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes ([byte[]]@()))
    }

    It 'sorts inputs by artifact_kind then path' {
        # Arrange
        $pins = Get-TestPinList
        $pins += @((Get-DocsArtifactPin -ArtifactKind 'docs-coverage-ledger' -Path 'alt/ledger.json' -Bytes $script:Utf8.GetBytes('x')), $null)

        # Act
        $receipt = New-TestReceipt -InputPin $pins

        # Assert
        @($receipt['inputs'] | ForEach-Object { $_['artifact_kind'] + ' ' + $_['path'] }) | Should -Be @(
            'docs-coverage-ledger alt/ledger.json',
            'docs-coverage-ledger estate/docs-coverage-ledger.json',
            'docs-profile docs/documentation-estate/docs-profile.json',
            'surface-inventory-snapshot estate/surface-inventory-snapshot.json'
        )
        $receipt['inputs'].Count | Should -Be 4 -Because 'the null pin of an absent artifact is not listed'
    }
}

Describe 'Get-DocsReceiptId' {
    It 'property Get-DocsReceiptId: unchanged when only issued_at, counts or findings differ; changed when any identity member differs' {
        $warning = New-DocsFinding -Code 'DOCS_STALE_PAGE' -Severity 'warning' -Message 'A page is stale.' -NextAction 'Re-pin it.'
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $revision = -join @(for ($index = 0; $index -lt 40; $index++) { '0123456789abcdef'[$random.Next(16)] })
            $mode = @('profile', 'ledger', 'matrix', 'docs-complete')[$random.Next(4)]
            $result = @('pass', 'fail')[$random.Next(2)]
            $pins = @(Get-TestPinList | Select-Object -First (1 + $random.Next(3)))
            $base = New-TestReceipt -Mode $mode -ValidationResult $result -Revision $revision -InputPin $pins -Finding $(if ($result -ceq 'fail') { @((New-DocsFinding -Code 'DOCS_INPUT_UNREADABLE' -Severity 'error' -Message 'Absent.' -NextAction 'Create it.')) } else { @() })

            # Act
            $laterIssue = New-TestReceipt -Mode $mode -ValidationResult $result -Revision $revision -InputPin $pins -Finding $base['findings'] -IssuedAt '2027-01-01T00:00:00Z'
            $moreFindings = New-TestReceipt -Mode $mode -ValidationResult $result -Revision $revision -InputPin $pins -Finding (@($base['findings']) + @($warning))
            $otherCounts = Get-DocsReceiptId -Mode $mode -Repository 'fixture-repo' -Revision $revision -InputPin $pins -ValidationResult $result
            $shuffledPins = Get-DocsReceiptId -Mode $mode -Repository 'fixture-repo' -Revision $revision -InputPin (Get-DocsLedgerTestShuffle -Item $pins -Seed $seed) -ValidationResult $result
            $otherMode = Get-DocsReceiptId -Mode $(if ($mode -ceq 'ledger') { 'matrix' } else { 'ledger' }) -Repository 'fixture-repo' -Revision $revision -InputPin $pins -ValidationResult $result
            $otherRepository = Get-DocsReceiptId -Mode $mode -Repository 'other-repo' -Revision $revision -InputPin $pins -ValidationResult $result
            $otherRevision = Get-DocsReceiptId -Mode $mode -Repository 'fixture-repo' -Revision ('f' * 40) -InputPin $pins -ValidationResult $result
            $otherInputs = Get-DocsReceiptId -Mode $mode -Repository 'fixture-repo' -Revision $revision -InputPin (@($pins) + @((Get-DocsArtifactPin -ArtifactKind 'docs-parity-matrix' -Path 'm.json' -Bytes $script:Utf8.GetBytes('m')))) -ValidationResult $result
            $otherResult = Get-DocsReceiptId -Mode $mode -Repository 'fixture-repo' -Revision $revision -InputPin $pins -ValidationResult $(if ($result -ceq 'pass') { 'fail' } else { 'pass' })

            # Assert
            $laterIssue['id'] | Should -BeExactly $base['id'] -Because "seed=$seed issued_at is excluded"
            $moreFindings['id'] | Should -BeExactly $base['id'] -Because "seed=$seed findings are excluded"
            $otherCounts | Should -BeExactly $base['id'] -Because "seed=$seed counts are excluded"
            $shuffledPins | Should -BeExactly $base['id'] -Because "seed=$seed inputs are sorted before hashing"
            $otherMode | Should -Not -BeExactly $base['id'] -Because "seed=$seed mode is an identity member"
            $otherRepository | Should -Not -BeExactly $base['id'] -Because "seed=$seed repository is an identity member"
            $otherRevision | Should -Not -BeExactly $base['id'] -Because "seed=$seed revision is an identity member"
            $otherInputs | Should -Not -BeExactly $base['id'] -Because "seed=$seed inputs are an identity member"
            $otherResult | Should -Not -BeExactly $base['id'] -Because "seed=$seed validation_result is an identity member"
            $base['id'] | Should -BeExactly (Get-DocsStableId -Prefix 'docs-validation-receipt' -Value ([ordered]@{ inputs = $base['inputs']; mode = $mode; repository = 'fixture-repo'; revision = $revision; validation_result = $result })) -Because "seed=$seed"
        }
    }
}

Describe 'Measure-DocsReceiptCount and New-DocsValidationReceipt' {
    It 'counts zeros where the mode reads no input and excludes precision-limit entries' {
        # Arrange
        $view = Get-TestView
        $elements = @($view.Element.Keys | Sort-Object | ForEach-Object { $view.Element[$_] })
        $entries = @(
            (New-DocsLedgerTestEntry -Element $elements[0])
            (New-DocsLedgerTestEntry -Element $elements[1] -Disposition 'excluded' -Rationale 'Internal.')
            (New-DocsLedgerTestEntry -Element $elements[2] -Disposition 'deferred' -Owner 'docs-team' -Target 'Later')
            (New-DocsLedgerTestEntry -Element $elements[2] -Disposition 'documented')
            (New-DocsLedgerTestEntry -Element @{ element_id = 'cli-command-' + ('0' * 64); kind = 'cli-command'; analysis_method = 'native' })
        )
        $limit = $view.PrecisionLimit[@($view.PrecisionLimit.Keys)[0]]
        $entries += @((New-DocsPrecisionLimitEntry -Limit $limit -Owner 'docs-team' -Target 'Later' -Actor $script:Actor))
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries

        # Act
        $profileCount = Measure-DocsReceiptCount -Mode 'profile' -SnapshotView $view -Ledger $ledger -StalePageCount 3
        $ledgerCount = Measure-DocsReceiptCount -Mode 'ledger' -SnapshotView $view -Ledger $ledger -StalePageCount 3
        $matrixCount = Measure-DocsReceiptCount -Mode 'matrix' -SnapshotView $view -Ledger $ledger -StalePageCount 3
        $nullCount = Measure-DocsReceiptCount -Mode 'docs-complete' -SnapshotView $null -Ledger $null

        # Assert
        $profileCount['elements_total'] | Should -Be 0
        $profileCount['undocumented'] | Should -Be 0
        $profileCount['stale_pages'] | Should -Be 0
        @($profileCount['by_disposition'].Values | ForEach-Object { [long] $_ } | Sort-Object -Unique) | Should -Be @(0)
        @($profileCount['by_kind'].Keys) | Should -Be @(Get-DocsElementKind)
        $ledgerCount['elements_total'] | Should -Be 6
        $ledgerCount['undocumented'] | Should -Be 3
        $ledgerCount['stale_pages'] | Should -Be 0 -Because 'ledger mode reads no pin collection'
        $ledgerCount['by_disposition']['documented'] | Should -Be 1
        $ledgerCount['by_disposition']['excluded'] | Should -Be 1
        $ledgerCount['by_disposition']['deferred'] | Should -Be 1 -Because 'the precision-limit entry and the orphan entry are excluded and a duplicate id counts once'
        @($ledgerCount['by_kind'].Values | ForEach-Object { [long] $_ } | Sort-Object -Unique) | Should -Be @(1)
        $matrixCount['stale_pages'] | Should -Be 3
        $nullCount['elements_total'] | Should -Be 0
        { Measure-DocsReceiptCount -Mode 'other' -SnapshotView $view -Ledger $ledger } | Should -Throw -ExpectedMessage 'DOCS_RECEIPT_INPUT_INVALID*'
    }

    It 'builds pass and fail receipts that produce no finding from Test-DocsArtifactText' {
        # Arrange
        $errorFinding = New-DocsFinding -Code 'DOCS_LEDGER_MISSING_DISPOSITION' -Severity 'error' -Message 'Missing.' -NextAction 'Record it.' -ArtifactPath 'estate/docs-coverage-ledger.json' -Pointer '/entries'
        $warning = New-DocsFinding -Code 'DOCS_STALE_PAGE' -Severity 'warning' -Message 'Stale.' -NextAction 'Re-pin.'

        # Act
        $pass = New-TestReceipt -ValidationResult 'pass' -Finding @($warning)
        $fail = New-TestReceipt -ValidationResult 'fail' -Finding @($errorFinding, $warning)
        $profilePass = New-TestReceipt -Mode 'profile' -InputPin @((Get-TestPinList)[1])

        # Assert
        foreach ($receipt in @($pass, $fail, $profilePass)) { Get-TestReceiptFindingCount -Receipt $receipt | Should -Be 0 }
        $pass['validation_result'] | Should -BeExactly 'pass'
        $fail['validation_result'] | Should -BeExactly 'fail'
        $pass['writer']['tool'] | Should -BeExactly 'drm-copilot-docs'
        $pass['writer']['version'] | Should -BeExactly '1.0.0'
        $pass['issued_at'] | Should -BeExactly '2026-03-01T12:00:00Z'
        $pass['revision'] | Should -BeExactly $script:Revision
        $pass['repository'] | Should -BeExactly 'fixture-repo'
        $pass['id'] | Should -Match '^docs-validation-receipt-[0-9a-f]{64}$'
        @($pass['extensions'].Keys).Count | Should -Be 0
        $fail['findings'].Count | Should -Be 2
        { New-TestReceipt -Mode 'other' } | Should -Throw -ExpectedMessage 'DOCS_RECEIPT_INPUT_INVALID*'
    }
}

Describe 'Get-DocsReceiptGateDecision' {
    BeforeAll {
        $script:PassText = ConvertTo-DocsJsonText -Value (New-TestReceipt)
    }

    It 'returns receipt-invalid for unparsable or schema-invalid text' {
        # Arrange
        $invalid = (ConvertFrom-DocsJsonText -Text $script:PassText).Value
        $invalid.Remove('counts')

        # Act
        $unparsable = Get-DocsReceiptGateDecision -ReceiptText '{"id":' -HeadRevision $script:Revision -ComposedSchemaSet $script:Composed
        $empty = Get-DocsReceiptGateDecision -ReceiptText '' -HeadRevision $script:Revision -ComposedSchemaSet $script:Composed
        $schemaInvalid = Get-DocsReceiptGateDecision -ReceiptText (ConvertTo-DocsJsonText -Value $invalid) -HeadRevision $script:Revision -ComposedSchemaSet $script:Composed

        # Assert
        foreach ($decision in @($unparsable, $empty, $schemaInvalid)) {
            $decision.Allow | Should -BeFalse
            $decision.Reason | Should -BeExactly 'receipt-invalid'
        }
        $null -eq $unparsable.ReceiptId | Should -BeTrue
        $schemaInvalid.ReceiptId | Should -BeExactly $invalid['id'] -Because 'the parsed id is reported when the text parses'
    }

    It 'returns mode-not-docs-complete' {
        # Arrange
        $text = ConvertTo-DocsJsonText -Value (New-TestReceipt -Mode 'matrix')

        # Act
        $decision = Get-DocsReceiptGateDecision -ReceiptText $text -HeadRevision $script:Revision -ComposedSchemaSet $script:Composed

        # Assert
        $decision.Allow | Should -BeFalse
        $decision.Reason | Should -BeExactly 'mode-not-docs-complete'
        $decision.ReceiptId | Should -Match '^docs-validation-receipt-[0-9a-f]{64}$'
    }

    It 'returns result-fail' {
        # Arrange
        $errorFinding = New-DocsFinding -Code 'DOCS_SNAPSHOT_UNPINNED' -Severity 'error' -Message 'Unpinned.' -NextAction 'Pin it.'
        $text = ConvertTo-DocsJsonText -Value (New-TestReceipt -ValidationResult 'fail' -Finding @($errorFinding))

        # Act
        $decision = Get-DocsReceiptGateDecision -ReceiptText $text -HeadRevision $script:Revision -ComposedSchemaSet $script:Composed

        # Assert
        $decision.Allow | Should -BeFalse
        $decision.Reason | Should -BeExactly 'result-fail'
    }

    It 'returns revision-mismatch including a letter-case-only difference' {
        # Act
        $other = Get-DocsReceiptGateDecision -ReceiptText $script:PassText -HeadRevision ('f' * 40) -ComposedSchemaSet $script:Composed
        $upper = Get-DocsReceiptGateDecision -ReceiptText $script:PassText -HeadRevision $script:Revision.ToUpperInvariant() -ComposedSchemaSet $script:Composed

        # Assert
        $other.Allow | Should -BeFalse
        $other.Reason | Should -BeExactly 'revision-mismatch'
        $upper.Allow | Should -BeFalse
        $upper.Reason | Should -BeExactly 'revision-mismatch' -Because 'the comparison is ordinal'
    }

    It 'allows a passing docs-complete receipt pinned to the revision' {
        # Act
        $decision = Get-DocsReceiptGateDecision -ReceiptText $script:PassText -HeadRevision $script:Revision -ComposedSchemaSet $script:Composed

        # Assert
        $decision.Allow | Should -BeTrue
        $decision.Reason | Should -BeExactly 'pass'
        $decision.ReceiptId | Should -BeExactly (ConvertFrom-DocsJsonText -Text $script:PassText).Value['id']
    }
}
