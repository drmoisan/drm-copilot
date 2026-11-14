#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsLedger.psm1.

.DESCRIPTION
    One property per pure function, generated with a seeded [System.Random] over the seeds of
    DocsLedger.TestSupport.psm1 (each -Because message states the seed) or by exhaustive
    enumeration of a small domain. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedger.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Actor = @{ kind = 'agent'; id = 'fixture-agent' }
    $script:Words = @('Alpha', 'beta', 'Gamma', 'delta', 'EPSILON', 'zeta', 'Eta', 'theta')

    function Get-TestRandomIdentifier {
        param([System.Random] $Random)
        $letters = 'abcdefghijklmnopqrstuvwxyz'
        $digits = 'abcdefghijklmnopqrstuvwxyz0123456789'
        $text = $letters[$Random.Next($letters.Length)]
        for ($index = 0; $index -lt 3 + $Random.Next(6); $index++) { $text += $digits[$Random.Next($digits.Length)] }
        $text
    }

    function Get-TestRandomHex {
        param([System.Random] $Random, [int] $Length = 64)
        $hex = '0123456789abcdef'
        $text = ''
        for ($index = 0; $index -lt $Length; $index++) { $text += $hex[$Random.Next(16)] }
        $text
    }

    function Get-TestRandomText {
        param([System.Random] $Random)
        @(1..(1 + $Random.Next(3)) | ForEach-Object { $script:Words[$Random.Next($script:Words.Count)] }) -join ' '
    }

    function Get-TestView {
        param([object] $Snapshot)
        $text = ConvertTo-DocsJsonText -Value $Snapshot
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)
    }

    function Get-TestLedgerFindingCount {
        param([object] $Document)
        (Test-DocsArtifactText -ArtifactKind 'docs-coverage-ledger' -JsonText (ConvertTo-DocsJsonText -Value $Document) -ComposedSchemaSet $script:Composed).Count
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsLedger properties (P1-T2)' {
    It 'property ConvertTo-DocsSnapshotView: element map and findings invariant under element and diagnostic permutation' {
        # Arrange: a snapshot with three precision limits, one invalid marker and one tampered element.
        $elements = @(foreach ($kind in Get-DocsElementKind) { New-DocsLedgerTestElement -Kind $kind })
        $elements[4]['element_id'] = 'public-symbol-' + ('f' * 64)
        $diagnostics = @(
            (New-DocsLedgerTestPrecisionLimitDiagnostic)
            (New-DocsLedgerTestPrecisionLimitDiagnostic -Code 'DOCS_SCANNER_DYNAMIC_ROUTE' -Path 'src/app/Routes.ps1' -ElementKind 'http-route')
            (New-DocsLedgerTestPrecisionLimitDiagnostic -Code 'DOCS_SCANNER_DYNAMIC_KEY' -Path 'config/Dynamic.json' -ElementKind 'config-key')
            (New-DocsLedgerTestPrecisionLimitDiagnostic -Code 'DOCS_SCANNER_BAD' -ElementKind 'widget')
        )
        $baseline = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot -Element $elements -Diagnostic $diagnostics)
        $baselineCodes = @($baseline.Findings | ForEach-Object { $_['code'] + '|' + (@($_['related_ids']) -join ',') } | Sort-Object)

        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Act
            $shuffled = New-DocsLedgerTestSnapshot -Element (Get-DocsLedgerTestShuffle -Item $elements -Seed $seed) -Diagnostic (Get-DocsLedgerTestShuffle -Item $diagnostics -Seed ($seed + 1))
            $view = Get-TestView -Snapshot $shuffled

            # Assert: the maps and the finding codes with their related ids do not depend on input order (pointers do).
            @($view.Element.Keys | Sort-Object) | Should -Be @($baseline.Element.Keys | Sort-Object) -Because "seed=$seed keeps the element map"
            @($view.PrecisionLimit.Keys | Sort-Object) | Should -Be @($baseline.PrecisionLimit.Keys | Sort-Object) -Because "seed=$seed keeps the precision-limit map"
            @($view.Findings | ForEach-Object { $_['code'] + '|' + (@($_['related_ids']) -join ',') } | Sort-Object) | Should -Be $baselineCodes -Because "seed=$seed keeps the findings"
            $view.Element.Count | Should -Be 5 -Because "seed=$seed drops the tampered element"
            $view.PrecisionLimit.Count | Should -Be 3 -Because "seed=$seed keeps three valid limits"
        }
    }

    It 'property Test-DocsPrecisionLimitDiagnostic: true exactly when all three marker rules hold (exhaustive)' {
        # Arrange
        $analyzers = @(@{ id = 'fixture-scanner'; analysis_method = 'scanner' }, @{ id = 'fixture-native'; analysis_method = 'native' })
        $markerCases = @{ valid = [ordered]@{ element_kind = 'cli-command' }; badKind = [ordered]@{ element_kind = 'widget' }; nonObject = 'cli-command'; absent = $null }
        $pathCases = @{ relative = 'src/app/Dynamic.ps1'; null = $null }
        $analyzerCases = @('fixture-scanner', 'fixture-native', 'unknown-analyzer')
        $checked = 0

        foreach ($markerCase in @($markerCases.Keys | Sort-Object)) {
            foreach ($pathCase in @($pathCases.Keys | Sort-Object)) {
                foreach ($analyzerId in $analyzerCases) {
                    # Act
                    $diagnostic = New-DocsDiagnostic -Code 'DOCS_SCANNER_LIMIT' -Path $pathCases[$pathCase] -Message 'm' -AnalyzerId $analyzerId -Severity 'warning'
                    if ($markerCase -ne 'absent') { $diagnostic['extensions']['docs.precision-limit'] = $markerCases[$markerCase] }
                    $expected = ($markerCase -eq 'valid') -and ($pathCase -eq 'relative') -and ($analyzerId -eq 'fixture-scanner')

                    # Assert
                    Test-DocsPrecisionLimitDiagnostic -Diagnostic $diagnostic -Analyzer $analyzers | Should -Be $expected -Because "marker=$markerCase path=$pathCase analyzer=$analyzerId"
                    $checked++
                }
            }
        }
        $checked | Should -Be 24
    }

    It 'property Get-DocsPrecisionLimitElementId: equals Get-DocsElementId over kind, path and diagnostic id and passes Test-DocsElementId' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 20; $round++) {
                $kinds = Get-DocsElementKind
                $kind = $kinds[$random.Next($kinds.Count)]
                $path = (Get-TestRandomIdentifier -Random $random) + '/' + (Get-TestRandomText -Random $random).Replace(' ', '_') + '.ps1'
                $diagnosticId = 'diagnostic-' + (Get-TestRandomHex -Random $random)

                # Act
                $derived = Get-DocsPrecisionLimitElementId -ElementKind $kind -Path $path -DiagnosticId $diagnosticId

                # Assert
                $derived | Should -BeExactly (Get-DocsElementId -Kind $kind -Path $path -Declaration $diagnosticId) -Because "seed=$seed round=$round"
                Test-DocsElementId -ElementId $derived | Should -BeTrue -Because "seed=$seed round=$round"
                $derived.StartsWith($kind + '-', [System.StringComparison]::Ordinal) | Should -BeTrue -Because "seed=$seed round=$round"
            }
        }
    }

    It 'property New-DocsLedgerEntry: bindings ordinal-sorted; output invariant under binding permutation' {
        $element = New-DocsLedgerTestElement -Kind 'public-symbol'
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange: mixed-case page paths and null or text anchors.
            $random = [System.Random]::new($seed)
            $bindings = @(for ($index = 0; $index -lt 2 + $random.Next(6); $index++) {
                    $anchor = if ($random.Next(2) -eq 0) { $null } else { Get-TestRandomText -Random $random }
                    @{ page_path = 'docs/' + (Get-TestRandomText -Random $random).Replace(' ', '-') + '.md'; anchor = $anchor }
                })

            # Act
            $entry = New-DocsLedgerEntry -Element $element -Disposition 'documented' -PageBinding $bindings -Actor $script:Actor
            $permuted = New-DocsLedgerEntry -Element $element -Disposition 'documented' -PageBinding (Get-DocsLedgerTestShuffle -Item $bindings -Seed $seed) -Actor $script:Actor

            # Assert
            (ConvertTo-DocsCanonicalJson -Value $permuted) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $entry) -Because "seed=$seed"
            $keys = @($entry['page_bindings'] | ForEach-Object { $_['page_path'] + [string][char]0 + $(if ($null -eq $_['anchor']) { '' } else { [string][char]1 + $_['anchor'] }) })
            [string[]] $sorted = @($keys)
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $keys | Should -Be $sorted -Because "seed=$seed sorts by page_path then anchor with null first"
            Get-TestLedgerFindingCount -Document (New-DocsLedgerTestLedger -SnapshotSha256 ('0' * 64) -Entry @($entry)) | Should -Be 0 -Because "seed=$seed"
        }
    }

    It 'property New-DocsPrecisionLimitEntry: entry validates for seeded owners, targets and rationales' {
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $limit = $view.PrecisionLimit[@($view.PrecisionLimit.Keys)[0]]
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 10; $round++) {
                $owner = Get-TestRandomIdentifier -Random $random
                $target = Get-TestRandomText -Random $random
                $rationale = if ($random.Next(2) -eq 0) { $null } else { Get-TestRandomText -Random $random }

                # Act
                $entry = New-DocsPrecisionLimitEntry -Limit $limit -Owner $owner -Target $target -Rationale $rationale -Actor $script:Actor

                # Assert
                Get-TestLedgerFindingCount -Document (New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry @($entry)) | Should -Be 0 -Because "seed=$seed round=$round"
                $entry['owner'] | Should -BeExactly $owner -Because "seed=$seed round=$round"
                $entry['target'] | Should -BeExactly $target -Because "seed=$seed round=$round"
            }
        }
    }

    It 'property New-DocsLedgerDocument: id depends only on the repository id' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 10; $round++) {
                $repository = Get-TestRandomIdentifier -Random $random
                $pinA = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/' + (Get-TestRandomIdentifier -Random $random) + '.json'; sha256 = (Get-TestRandomHex -Random $random) }
                $pinB = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/' + (Get-TestRandomIdentifier -Random $random) + '.json'; sha256 = (Get-TestRandomHex -Random $random) }

                # Act
                $first = New-DocsLedgerDocument -RepositoryId $repository -SnapshotPin $pinA
                $second = New-DocsLedgerDocument -RepositoryId $repository -SnapshotPin $pinB
                $other = New-DocsLedgerDocument -RepositoryId ($repository + 'x') -SnapshotPin $pinA

                # Assert
                $first['id'] | Should -BeExactly $second['id'] -Because "seed=$seed round=$round"
                $first['id'] | Should -Not -BeExactly $other['id'] -Because "seed=$seed round=$round"
                Get-TestLedgerFindingCount -Document $first | Should -Be 0 -Because "seed=$seed round=$round"
            }
        }
    }
}

Describe 'DocsLedger properties (P1-T4)' {
    BeforeAll {
        function Get-TestRandomEntrySet {
            # Seeded entries over the fixture elements: a random subset in random order with random dispositions.
            param([hashtable] $View, [System.Random] $Random)
            $ids = Get-DocsLedgerTestShuffle -Item @($View.Element.Keys | Sort-Object) -Seed $Random.Next()
            $count = $Random.Next($ids.Count + 1)
            @(for ($index = 0; $index -lt $count; $index++) {
                    switch ($Random.Next(3)) {
                        0 { New-DocsLedgerEntry -Element $View.Element[$ids[$index]] -Disposition 'documented' -PageBinding @(@{ page_path = 'docs/a.md'; anchor = $null }) -Actor $script:Actor }
                        1 { New-DocsLedgerEntry -Element $View.Element[$ids[$index]] -Disposition 'excluded' -Rationale 'Internal.' -Actor $script:Actor }
                        default { New-DocsLedgerEntry -Element $View.Element[$ids[$index]] -Disposition 'deferred' -Owner 'docs-team' -Target 'Soon' -Actor $script:Actor }
                    }
                })
        }
    }

    It 'property Merge-DocsLedgerEntry: sorted, one entry per id, input unchanged' {
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 8; $round++) {
                $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry (Get-TestRandomEntrySet -View $view -Random $random)
                $before = ConvertTo-DocsCanonicalJson -Value $ledger
                $id = @($view.Element.Keys | Sort-Object)[$random.Next($view.Element.Count)]
                $entry = New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'excluded' -Rationale 'Merged.' -Actor $script:Actor

                # Act
                $merged = Merge-DocsLedgerEntry -Ledger $ledger -Entry $entry

                # Assert
                $ids = @($merged['entries'] | ForEach-Object { $_['element_id'] })
                [string[]] $sorted = @($ids)
                [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
                $ids | Should -Be $sorted -Because "seed=$seed round=$round sorts by element_id"
                @($ids | Sort-Object -Unique).Count | Should -Be $ids.Count -Because "seed=$seed round=$round keeps one entry per id"
                $ids | Should -Contain $id -Because "seed=$seed round=$round"
                @($merged['entries'] | Where-Object { $_['element_id'] -ceq $id })[0]['rationale'] | Should -BeExactly 'Merged.' -Because "seed=$seed round=$round"
                (ConvertTo-DocsCanonicalJson -Value $ledger) | Should -BeExactly $before -Because "seed=$seed round=$round leaves the input unchanged"
            }
        }
    }

    It 'property Get-DocsLedgerWithoutEntry: removes exactly the named id; inverse of a merge of a new id' {
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 8; $round++) {
                $entries = @(Get-TestRandomEntrySet -View $view -Random $random)
                $present = @($entries | ForEach-Object { $_['element_id'] })
                $absent = @($view.Element.Keys | Where-Object { $present -cnotcontains $_ })
                if ($absent.Count -eq 0) { continue }
                $base = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
                $sortedBase = Get-DocsLedgerWithoutEntry -Ledger $base -ElementId ('cli-command-' + ('0' * 64))
                $newId = $absent[$random.Next($absent.Count)]
                $newEntry = New-DocsLedgerEntry -Element $view.Element[$newId] -Disposition 'documented' -PageBinding @(@{ page_path = 'docs/b.md'; anchor = 'x' }) -Actor $script:Actor

                # Act
                $roundTrip = Get-DocsLedgerWithoutEntry -Ledger (Merge-DocsLedgerEntry -Ledger $base -Entry $newEntry) -ElementId $newId
                $removedOne = if ($present.Count -gt 0) { Get-DocsLedgerWithoutEntry -Ledger $base -ElementId $present[0] } else { $null }

                # Assert
                (ConvertTo-DocsCanonicalJson -Value $roundTrip) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $sortedBase) -Because "seed=$seed round=$round"
                if ($null -ne $removedOne) {
                    @($removedOne['entries'] | ForEach-Object { $_['element_id'] }) | Should -Not -Contain $present[0] -Because "seed=$seed round=$round"
                    @($removedOne['entries']).Count | Should -Be ($present.Count - 1) -Because "seed=$seed round=$round"
                }
            }
        }
    }

    It 'property Merge-DocsLedgerSnapshotRef: idempotent; element-entry analysis_method equals its element' {
        $view = Get-TestView -Snapshot (New-DocsLedgerTestSnapshot)
        $limit = New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[@($view.PrecisionLimit.Keys)[0]] -Owner 'docs-team' -Target 'Soon' -Actor $script:Actor
        $pin = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/surface-inventory-snapshot.json'; sha256 = $view.Sha256 }
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 8; $round++) {
                $elementEntries = @(Get-TestRandomEntrySet -View $view -Random $random)
                foreach ($entry in $elementEntries) { if ($random.Next(2) -eq 0) { $entry['analysis_method'] = @('native', 'scanner')[$random.Next(2)] } }
                $ledger = New-DocsLedgerTestLedger -SnapshotSha256 ('3' * 64) -Entry ($elementEntries + @($limit))

                # Act
                $once = Merge-DocsLedgerSnapshotRef -Ledger $ledger -SnapshotPin $pin -SnapshotView $view
                $twice = Merge-DocsLedgerSnapshotRef -Ledger $once -SnapshotPin $pin -SnapshotView $view

                # Assert
                (ConvertTo-DocsCanonicalJson -Value $twice) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $once) -Because "seed=$seed round=$round is idempotent"
                $once['snapshot_ref']['sha256'] | Should -BeExactly $view.Sha256 -Because "seed=$seed round=$round"
                foreach ($entry in $once['entries']) {
                    if ($view.Element.ContainsKey($entry['element_id'])) { $entry['analysis_method'] | Should -BeExactly $view.Element[$entry['element_id']]['analysis_method'] -Because "seed=$seed round=$round" }
                    else { $entry['analysis_method'] | Should -BeExactly 'scanner' -Because "seed=$seed round=$round keeps the precision-limit entry" }
                }
            }
        }
    }
}
