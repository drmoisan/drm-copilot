#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsValidation.psm1.

.DESCRIPTION
    Exhaustive enumeration over the four modes for Get-DocsValidationMode and
    Get-DocsValidationInputKind; seeded [System.Random] generation with the seeds of
    DocsLedger.TestSupport.psm1 (each -Because message states the seed) for the stale-page
    severity rule of Get-DocsCompletionGateFinding and the mode layering of
    Invoke-DocsValidation. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsValidation') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:IssuedAt = '2026-03-01T12:00:00Z'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:PagePath = 'docs/reference/Cli.md'
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

    function Get-TestByte {
        param([object] $Document)
        , $script:Utf8.GetBytes((ConvertTo-DocsJsonText -Value $Document -Indented))
    }

    function Get-TestView {
        param([object] $Snapshot)
        $bytes = Get-TestByte -Document $Snapshot
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $script:Utf8.GetString($bytes)).Value -SnapshotSha256 (Get-DocsBytesSha256Hex -Bytes $bytes)
    }

    function Get-TestCompleteSet {
        # A consistent ledger, matrix and pin collection over the snapshot view (see DocsValidation.Tests.ps1).
        param([hashtable] $View)
        $ids = @($View.Element.Keys | Sort-Object)
        $entries = @(foreach ($id in $ids) { New-DocsLedgerEntry -Element $View.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:PagePath; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($View.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $View.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $View.Sha256 -Entry $entries
        $pins = @(foreach ($id in $ids) { New-DocsEvidencePin -Element $View.Element[$id] -PagePath $script:PagePath -Revision $View.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $View.Element[$pin['element_id']] -PagePath $script:PagePath -Dimension $dimension
            })
        @{ Ledger = $ledger; Matrix = (New-DocsLedgerTestMatrix -SnapshotSha256 $View.Sha256 -LedgerSha256 (Get-DocsBytesSha256Hex -Bytes (Get-TestByte -Document $ledger)) -Row $rows); PinSet = (New-DocsLedgerTestPinSet -Pin $pins) }
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsValidation properties' {
    It 'property Get-DocsValidationMode: four modes in layering order' {
        $first = Get-DocsValidationMode
        $first | Should -Be @('profile', 'ledger', 'matrix', 'docs-complete')
        foreach ($round in 1..5) { Get-DocsValidationMode | Should -Be $first -Because "call $round" }
        $first[0] = 'changed'
        (Get-DocsValidationMode)[0] | Should -BeExactly 'profile' -Because 'a returned copy does not alter the module state'
    }

    It 'property Get-DocsValidationInputKind: each mode needs a superset of the previous mode''s inputs' {
        # Arrange
        $modes = Get-DocsValidationMode
        $previous = [string[]]@()
        $checked = 0

        # Act and Assert
        foreach ($mode in $modes) {
            $kinds = Get-DocsValidationInputKind -Mode $mode
            $kinds[0] | Should -BeExactly 'docs-profile' -Because "$mode reads the profile first"
            foreach ($kind in $previous) { $kinds | Should -Contain $kind -Because "$mode includes the inputs of the previous mode" }
            $kinds.Count | Should -BeGreaterOrEqual $previous.Count -Because "$mode"
            @($kinds | Sort-Object -Unique).Count | Should -Be $kinds.Count -Because "$mode lists each input once"
            $previous = $kinds
            $checked++
        }
        $checked | Should -Be 4
        (Get-DocsValidationInputKind -Mode 'profile') | Should -Be @('docs-profile')
        (Get-DocsValidationInputKind -Mode 'ledger') | Should -Be @('docs-profile', 'surface-inventory-snapshot', 'docs-coverage-ledger')
        (Get-DocsValidationInputKind -Mode 'matrix') | Should -Be (Get-DocsValidationInputKind -Mode 'docs-complete') -Because 'docs-complete reads the same inputs as matrix'
        (Get-DocsValidationInputKind -Mode 'docs-complete') | Should -Contain 'page-path-set'
        { Get-DocsValidationInputKind -Mode 'other' } | Should -Throw -ExpectedMessage 'DOCS_VALIDATION_INPUT_INVALID*'
    }

    It 'property Get-DocsCompletionGateFinding: DOCS_STALE_PAGE is an error exactly when the stale count exceeds max_stale_pages' {
        # Arrange
        $snapshot = New-DocsLedgerTestSnapshot
        $view = Get-TestView -Snapshot $snapshot
        $ids = @($view.Element.Keys | Sort-Object)
        $set = Get-TestCompleteSet -View $view
        foreach ($seed in Get-DocsLedgerTestSeed) {
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 8; $round++) {
                $staleCount = $random.Next(5)
                $maxStale = $random.Next(5)
                $stalePages = @(for ($index = 0; $index -lt $staleCount; $index++) {
                        [ordered]@{ page_path = "docs/guides/Page$index.md"; pins = [object[]]@([ordered]@{ pin_id = 'pin-' + ([string] $index * 64); element_id = $ids[$index % $ids.Count]; status = 'digest-changed' }) }
                    })
                $gate = [ordered]@{ required_dispositions_complete = $true; allow_deferred = $true; max_stale_pages = [long] $maxStale; required_parity_dimensions = [string[]]@() }

                # Act
                $findings = Get-DocsCompletionGateFinding -Gate $gate -SnapshotView $view -Ledger $set.Ledger -Matrix $set.Matrix -StalePage $stalePages -PagePath @($script:PagePath) -SnapshotRevision $view.Revision -PinSet $set.PinSet

                # Assert
                $stale = @($findings | Where-Object { $_['code'] -ceq 'DOCS_STALE_PAGE' })
                $stale.Count | Should -Be $staleCount -Because "seed=$seed round $round one finding per stale page"
                $expected = if ($staleCount -gt $maxStale) { 'error' } else { 'warning' }
                foreach ($finding in $stale) { $finding['severity'] | Should -BeExactly $expected -Because "seed=$seed round $round stale=$staleCount max=$maxStale" }
                @($findings | Where-Object { $_['code'] -cne 'DOCS_STALE_PAGE' }).Count | Should -Be 0 -Because "seed=$seed round $round the complete fixture raises no other gate finding"
            }
        }
    }

    It 'property Invoke-DocsValidation: finding codes of each mode include those of the previous mode; every receipt validates' {
        $modes = Get-DocsValidationMode
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange: seeded defects over the complete fixture.
            $random = [System.Random]::new($seed)
            $snapshot = if ($random.Next(3) -eq 0) { New-DocsLedgerTestSnapshot -NoRevision } else { New-DocsLedgerTestSnapshot }
            $view = Get-TestView -Snapshot $snapshot
            $set = Get-TestCompleteSet -View $view
            if ($random.Next(2) -eq 0) { $set.Ledger['entries'] = [object[]]@($set.Ledger['entries'] | Select-Object -Skip 1) }
            if ($random.Next(2) -eq 0) { $set.PinSet['pins'][$random.Next($set.PinSet['pins'].Count)]['source_sha256'] = '0' * 64 }
            if ($random.Next(2) -eq 0) { $set.Matrix['rows'] = [object[]]@($set.Matrix['rows'] | Select-Object -Skip 1) }
            if ($random.Next(2) -eq 0) { $set.Matrix['rows'][0]['dimensions']['exists']['state'] = 'fail'; $set.Matrix['rows'][0]['dimensions']['exists']['rationale'] = 'The page is missing.' }
            $document = New-DocsLedgerTestProfile -AllowDeferred ($random.Next(2) -eq 0) -MaxStalePages $random.Next(2)
            if ($random.Next(3) -eq 0) { $document['documentation_roots'][0]['audience_ids'] = @('maintainers', 'operators') }
            $artifact = [ordered]@{
                'docs-profile'               = @{ Path = $script:ProfilePath; Bytes = (Get-TestByte -Document $document) }
                'surface-inventory-snapshot' = @{ Path = 'estate/surface-inventory-snapshot.json'; Bytes = (Get-TestByte -Document $snapshot) }
                'docs-coverage-ledger'       = @{ Path = 'estate/docs-coverage-ledger.json'; Bytes = (Get-TestByte -Document $set.Ledger) }
                'docs-parity-matrix'         = @{ Path = 'estate/docs-parity-matrix.json'; Bytes = (Get-TestByte -Document $set.Matrix) }
                'docs-evidence-pin'          = @{ Path = 'estate/docs-evidence-pins.json'; Bytes = (Get-TestByte -Document $set.PinSet) }
            }
            $previousCodes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)

            foreach ($mode in $modes) {
                # Act
                $result = Invoke-DocsValidation -Mode $mode -Revision $script:Revision -IssuedAt $script:IssuedAt -ProfileText ($script:Utf8.GetString($artifact['docs-profile'].Bytes)) -ProfilePath $script:ProfilePath -Artifact $artifact -PagePath @($script:PagePath) -ComposedSchemaSet $script:Composed

                # Assert
                $codes = [System.Collections.Generic.HashSet[string]]::new([string[]]@($result.Findings | ForEach-Object { [string] $_['code'] }), [System.StringComparer]::Ordinal)
                foreach ($code in $previousCodes) { $codes.Contains($code) | Should -BeTrue -Because "seed=$seed mode $mode includes $code of the previous mode" }
                $previousCodes = $codes
                if ($null -ne $result.Receipt) {
                    (Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText (ConvertTo-DocsJsonText -Value $result.Receipt) -ComposedSchemaSet $script:Composed).Count | Should -Be 0 -Because "seed=$seed mode $mode receipt validates"
                    $result.Receipt['mode'] | Should -BeExactly $mode -Because "seed=$seed"
                    $result.Ok | Should -Be ($result.Receipt['validation_result'] -ceq 'pass') -Because "seed=$seed mode $mode"
                    $kinds = Get-DocsValidationInputKind -Mode $mode
                    $result.Receipt['inputs'].Count | Should -Be @($kinds | Where-Object { $_ -cne 'page-path-set' }).Count -Because "seed=$seed mode $mode pins every artifact read"
                } else {
                    $result.Ok | Should -BeFalse -Because "seed=$seed mode $mode a null receipt means the profile did not load"
                }
            }
        }
    }
}
