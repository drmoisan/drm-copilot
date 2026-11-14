#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsParity.psm1.

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
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsEvidencePins.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsParity.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:States = @('pass', 'fail', 'not-assessed', 'not-applicable')
    $script:Pages = @('docs/reference/Cli.md', 'docs/reference/cli.md', 'docs/guides/Start.md', 'docs/Index.md')
    $script:SnapshotPin = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/surface-inventory-snapshot.json'; sha256 = ('a' * 64) }
    $script:LedgerPin = @{ artifact_kind = 'docs-coverage-ledger'; path = 'estate/docs-coverage-ledger.json'; sha256 = ('b' * 64) }
    $script:Elements = @(foreach ($kind in Get-DocsElementKind) { New-DocsLedgerTestElement -Kind $kind })

    function Get-TestRandomHex {
        param([System.Random] $Random)
        $hex = '0123456789abcdef'
        $text = ''
        for ($index = 0; $index -lt 64; $index++) { $text += $hex[$Random.Next(16)] }
        $text
    }

    function Get-TestMatrixFindingCount {
        param([object] $Document)
        (Test-DocsArtifactText -ArtifactKind 'docs-parity-matrix' -JsonText (ConvertTo-DocsJsonText -Value $Document) -ComposedSchemaSet $script:Composed).Count
    }

    function Get-TestRandomMatrix {
        # A matrix over random element and page pairs with random dimension states and rationales where required.
        param([System.Random] $Random)
        $matrix = New-DocsParityMatrixDocument -RepositoryId 'fixture-repo' -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin
        for ($round = 0; $round -lt 1 + $Random.Next(6); $round++) {
            $element = $script:Elements[$Random.Next($script:Elements.Count)]
            $page = $script:Pages[$Random.Next($script:Pages.Count)]
            foreach ($name in Get-DocsParityDimension) {
                $state = $script:States[$Random.Next(4)]
                $rationale = if ($state -in 'fail', 'not-applicable') { 'Because.' } else { $null }
                $matrix = Merge-DocsParityDimension -Matrix $matrix -ElementId $element['element_id'] -Kind $element['kind'] -PagePath $page -Dimension $name -State $state -Rationale $rationale
            }
        }
        $matrix
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsParity properties (P2-T3)' {
    It 'property Get-DocsParityDimension: five dimensions in contract order on every call' {
        for ($round = 0; $round -lt 5; $round++) {
            @(Get-DocsParityDimension) | Should -Be @('exists', 'accurate', 'example_present', 'owner_assigned', 'diataxis_mode') -Because "call $round"
        }
    }

    It 'property Test-DocsPathOrGlobMatch: agrees with the enumerated table; a letter-case change of a literal character never matches' {
        # Arrange: the enumerated semantics of each glob element.
        $table = @(
            @{ Glob = 'docs/Guide.md'; Match = @('docs/Guide.md', 'docs/Guide.md/sub'); NoMatch = @('docs/Guide.mdx', 'docs/guide.md') }
            @{ Glob = 'docs/*.md'; Match = @('docs/A.md', 'docs/nested/B.md'); NoMatch = @('docs/A.txt', 'Docs/A.md') }
            @{ Glob = 'docs/?.md'; Match = @('docs/A.md'); NoMatch = @('docs/AB.md', 'docs/a.md/x') }
            @{ Glob = 'docs/[AB].md'; Match = @('docs/A.md', 'docs/B.md'); NoMatch = @('docs/C.md', 'docs/a.md') }
            @{ Glob = 'docs/[!AB].md'; Match = @('docs/C.md', 'docs/a.md'); NoMatch = @('docs/A.md', 'docs/B.md') }
        )
        foreach ($case in $table) {
            foreach ($path in $case.Match) { Test-DocsPathOrGlobMatch -Path $path -PathOrGlob $case.Glob | Should -BeTrue -Because "'$path' matches '$($case.Glob)'" }
            foreach ($path in $case.NoMatch) { Test-DocsPathOrGlobMatch -Path $path -PathOrGlob $case.Glob | Should -BeFalse -Because "'$path' does not match '$($case.Glob)'" }
        }

        # Seeded: flipping the case of one letter of a literal path makes the exact match fail.
        foreach ($seed in Get-DocsLedgerTestSeed) {
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 10; $round++) {
                $letters = @('a'..'z') + @('A'..'Z')
                $name = -join @(1..(3 + $random.Next(5)) | ForEach-Object { $letters[$random.Next($letters.Count)] })
                $path = "docs/$name.md"
                $position = 5 + $random.Next($name.Length)
                $flipped = $path.Substring(0, $position) + $(if ([char]::IsUpper($path[$position])) { [char]::ToLowerInvariant($path[$position]) } else { [char]::ToUpperInvariant($path[$position]) }) + $path.Substring($position + 1)
                Test-DocsPathOrGlobMatch -Path $path -PathOrGlob $path | Should -BeTrue -Because "seed=$seed round=$round"
                Test-DocsPathOrGlobMatch -Path $flipped -PathOrGlob $path | Should -BeFalse -Because "seed=$seed round=$round flipped '$flipped' against '$path'"
                Test-DocsPathOrGlobMatch -Path $flipped -PathOrGlob 'docs/*' | Should -BeTrue -Because "seed=$seed round=$round"
            }
        }
    }

    It 'property Get-DocsPageOwner: first match wins; appending non-matching entries keeps the owner' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 10; $round++) {
                $page = $script:Pages[$random.Next($script:Pages.Count)]
                $owners = @(for ($index = 0; $index -lt 1 + $random.Next(4); $index++) { @{ path_or_glob = @('docs', 'docs/**', 'docs/reference/**', 'other', 'docs/[!r]*')[$random.Next(5)]; owner = "owner-$index" } })
                $expected = $null
                foreach ($entry in $owners) { if ($null -eq $expected -and (Test-DocsPathOrGlobMatch -Path $page -PathOrGlob $entry.path_or_glob)) { $expected = $entry.owner } }
                $appended = $owners + @(@{ path_or_glob = 'elsewhere/**'; owner = 'nobody' }, @{ path_or_glob = 'README.md'; owner = 'nobody' })

                # Act and Assert
                (Get-DocsPageOwner -PagePath $page -PageOwner $owners) | Should -Be $expected -Because "seed=$seed round=$round"
                (Get-DocsPageOwner -PagePath $page -PageOwner $appended) | Should -Be $expected -Because "seed=$seed round=$round keeps the owner after appending non-matching entries"
            }
        }
    }

    It 'property New-DocsParityRow: every dimension not-assessed; row validates' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 6; $round++) {
                $element = $script:Elements[$random.Next($script:Elements.Count)]
                $page = $script:Pages[$random.Next($script:Pages.Count)]

                # Act
                $row = New-DocsParityRow -ElementId $element['element_id'] -Kind $element['kind'] -PagePath $page
                $matrix = New-DocsParityMatrixDocument -RepositoryId 'fixture-repo' -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin
                $matrix['rows'] = [object[]]@($row)

                # Assert
                foreach ($name in Get-DocsParityDimension) { $row['dimensions'][$name]['state'] | Should -BeExactly 'not-assessed' -Because "seed=$seed round=$round" }
                Get-TestMatrixFindingCount -Document $matrix | Should -Be 0 -Because "seed=$seed round=$round"
            }
        }
    }

    It 'property New-DocsParityMatrixDocument: id depends only on the repository id' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 8; $round++) {
                $repository = 'repo' + $random.Next(1000)
                $pinA = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/a.json'; sha256 = (Get-TestRandomHex -Random $random) }
                $pinB = @{ artifact_kind = 'docs-coverage-ledger'; path = 'estate/b.json'; sha256 = (Get-TestRandomHex -Random $random) }

                # Act
                $first = New-DocsParityMatrixDocument -RepositoryId $repository -SnapshotPin $pinA -LedgerPin $pinB
                $second = New-DocsParityMatrixDocument -RepositoryId $repository -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin
                $other = New-DocsParityMatrixDocument -RepositoryId ($repository + 'x') -SnapshotPin $pinA -LedgerPin $pinB

                # Assert
                $first['id'] | Should -BeExactly $second['id'] -Because "seed=$seed round=$round"
                $first['id'] | Should -Not -BeExactly $other['id'] -Because "seed=$seed round=$round"
                Get-TestMatrixFindingCount -Document $first | Should -Be 0 -Because "seed=$seed round=$round"
            }
        }
    }

    It 'property Get-DocsScoreBasisPoint: equals the integer floor formula or null for a zero denominator' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 30; $round++) {
                $pass = $random.Next(50)
                $fail = $random.Next(50)
                $notAssessed = $random.Next(50)
                $denominator = $pass + $fail + $notAssessed

                # Act
                $score = Get-DocsScoreBasisPoint -Pass $pass -Fail $fail -NotAssessed $notAssessed

                # Assert
                if ($denominator -eq 0) { $score | Should -BeNullOrEmpty -Because "seed=$seed round=$round" }
                else {
                    $score | Should -Be ([long] [math]::Floor(10000.0 * $pass / $denominator)) -Because "seed=$seed round=$round"
                    $score | Should -BeGreaterOrEqual 0 -Because "seed=$seed round=$round"
                    $score | Should -BeLessOrEqual 10000 -Because "seed=$seed round=$round"
                }
            }
        }
    }

    It 'property Measure-DocsParityScore: per-dimension counts sum to the row count' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 6; $round++) {
                $matrix = Get-TestRandomMatrix -Random $random

                # Act
                $score = Measure-DocsParityScore -Matrix $matrix

                # Assert
                foreach ($name in Get-DocsParityDimension) {
                    ($score[$name]['pass'] + $score[$name]['fail'] + $score[$name]['not_assessed'] + $score[$name]['not_applicable']) | Should -Be @($matrix['rows']).Count -Because "seed=$seed round=$round dimension=$name"
                    $score[$name]['score_basis_points'] | Should -Be (Get-DocsScoreBasisPoint -Pass $score[$name]['pass'] -Fail $score[$name]['fail'] -NotAssessed $score[$name]['not_assessed']) -Because "seed=$seed round=$round dimension=$name"
                }
            }
        }
    }
}

Describe 'DocsParity properties (P2-T4)' {
    It 'property Get-DocsMatrixFinding: findings and canonical output invariant under row permutation' {
        $owners = @(@{ path_or_glob = 'docs/reference/**'; owner = 'docs-team' })
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange: a random matrix whose rows are unbound (no ledger entry) so every row yields index-independent findings.
            $random = [System.Random]::new($seed)
            $matrix = Get-TestRandomMatrix -Random $random
            $ledger = New-DocsLedgerTestLedger -SnapshotSha256 ('a' * 64) -Entry @()
            $pinSet = New-DocsLedgerTestPinSet -Pin @()
            $rows = @($matrix['rows'])
            $shuffledMatrix = Merge-DocsMatrixRef -Matrix $matrix -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin
            $shuffledMatrix['rows'] = [object[]] (Get-DocsLedgerTestShuffle -Item $rows -Seed $seed)

            # Act
            $baseline = Get-DocsMatrixFinding -Matrix $matrix -Ledger $ledger -PinSet $pinSet -PagePath @('docs/reference/Cli.md') -PageOwner $owners -LedgerSha256 ('b' * 64)
            $shuffled = Get-DocsMatrixFinding -Matrix $shuffledMatrix -Ledger $ledger -PinSet $pinSet -PagePath @('docs/reference/Cli.md') -PageOwner $owners -LedgerSha256 ('b' * 64)
            $strip = { param($f) $f['code'] + '|' + (@($f['related_ids']) -join ',') + '|' + (@($f['related_paths']) -join ',') + '|' + [regex]::Replace($f['pointer'], '^/rows/[0-9]+', '') }

            # Assert: Merge-DocsMatrixRef sorts rows, so a shuffled copy re-sorted through it gives the identical canonical output.
            @($shuffled | ForEach-Object { & $strip $_ } | Sort-Object) | Should -Be @($baseline | ForEach-Object { & $strip $_ } | Sort-Object) -Because "seed=$seed keeps the findings apart from their row index"
            (ConvertTo-DocsCanonicalJson -Value (Get-DocsMatrixFinding -Matrix (Merge-DocsMatrixRef -Matrix $shuffledMatrix -SnapshotPin $script:SnapshotPin -LedgerPin $script:LedgerPin) -Ledger $ledger -PinSet $pinSet -PagePath @('docs/reference/Cli.md') -PageOwner $owners -LedgerSha256 ('b' * 64))) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $baseline) -Because "seed=$seed"
            $baseline.Count | Should -BeGreaterThan 0 -Because "seed=$seed"
        }
    }

    It 'property Merge-DocsParityDimension: changes only the named dimension; sorted evidence_pin_ids' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 6; $round++) {
                $matrix = Get-TestRandomMatrix -Random $random
                $row = $matrix['rows'][$random.Next(@($matrix['rows']).Count)]
                $dimension = (Get-DocsParityDimension)[$random.Next(5)]
                $pins = @(for ($index = 0; $index -lt $random.Next(4); $index++) { 'pin-' + (Get-TestRandomHex -Random $random) })
                $before = ConvertTo-DocsCanonicalJson -Value $matrix

                # Act
                $merged = Merge-DocsParityDimension -Matrix $matrix -ElementId $row['element_id'] -Kind $row['kind'] -PagePath $row['page_path'] -Dimension $dimension -State 'pass' -PinId $pins
                $target = @($merged['rows'] | Where-Object { $_['element_id'] -ceq $row['element_id'] -and $_['page_path'] -ceq $row['page_path'] })[0]

                # Assert
                $target['dimensions'][$dimension]['state'] | Should -BeExactly 'pass' -Because "seed=$seed round=$round"
                [string[]] $sorted = @($pins | Sort-Object -Unique)
                [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
                @($target['dimensions'][$dimension]['evidence_pin_ids']) | Should -Be $sorted -Because "seed=$seed round=$round"
                foreach ($name in Get-DocsParityDimension) {
                    if ($name -ceq $dimension) { continue }
                    (ConvertTo-DocsCanonicalJson -Value $target['dimensions'][$name]) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $row['dimensions'][$name]) -Because "seed=$seed round=$round leaves $name unchanged"
                }
                @($merged['rows']).Count | Should -Be @($matrix['rows']).Count -Because "seed=$seed round=$round"
                (ConvertTo-DocsCanonicalJson -Value $matrix) | Should -BeExactly $before -Because "seed=$seed round=$round leaves the input unchanged"
            }
        }
    }

    It 'property Get-DocsMatrixWithoutBinding: removes exactly the rows of the named element and page' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 6; $round++) {
                $matrix = Get-TestRandomMatrix -Random $random
                $row = $matrix['rows'][$random.Next(@($matrix['rows']).Count)]
                $keys = @($matrix['rows'] | ForEach-Object { $_['element_id'] + '|' + $_['page_path'] })

                # Act
                $withoutPage = Get-DocsMatrixWithoutBinding -Matrix $matrix -ElementId $row['element_id'] -PagePath $row['page_path']
                $withoutElement = Get-DocsMatrixWithoutBinding -Matrix $matrix -ElementId $row['element_id']

                # Assert
                @($withoutPage['rows'] | ForEach-Object { $_['element_id'] + '|' + $_['page_path'] }) | Should -Be @($keys | Where-Object { $_ -cne ($row['element_id'] + '|' + $row['page_path']) }) -Because "seed=$seed round=$round"
                @($withoutElement['rows'] | ForEach-Object { $_['element_id'] + '|' + $_['page_path'] }) | Should -Be @($keys | Where-Object { -not $_.StartsWith($row['element_id'] + '|', [System.StringComparison]::Ordinal) }) -Because "seed=$seed round=$round"
            }
        }
    }

    It 'property Merge-DocsMatrixPinRemoval: no row references the removed pin; other ids keep their order' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 6; $round++) {
                $matrix = Get-TestRandomMatrix -Random $random
                $pool = @(for ($index = 0; $index -lt 4; $index++) { 'pin-' + (Get-TestRandomHex -Random $random) })
                foreach ($row in $matrix['rows']) {
                    foreach ($name in Get-DocsParityDimension) { $row['dimensions'][$name]['evidence_pin_ids'] = [string[]]@($pool | Where-Object { $random.Next(2) -eq 0 }) }
                }
                $target = $pool[$random.Next($pool.Count)]

                # Act
                $removed = Merge-DocsMatrixPinRemoval -Matrix $matrix -PinId $target

                # Assert
                for ($index = 0; $index -lt @($matrix['rows']).Count; $index++) {
                    foreach ($name in Get-DocsParityDimension) {
                        $expected = @($matrix['rows'][$index]['dimensions'][$name]['evidence_pin_ids'] | Where-Object { $_ -cne $target })
                        @($removed['rows'][$index]['dimensions'][$name]['evidence_pin_ids']) | Should -Be $expected -Because "seed=$seed round=$round row=$index dimension=$name"
                    }
                }
            }
        }
    }

    It 'property Merge-DocsMatrixRef: idempotent; both refs equal the supplied pins' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 6; $round++) {
                $matrix = Get-TestRandomMatrix -Random $random
                $snapshotPin = @{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/snap.json'; sha256 = (Get-TestRandomHex -Random $random) }
                $ledgerPin = @{ artifact_kind = 'docs-coverage-ledger'; path = 'estate/ledger.json'; sha256 = (Get-TestRandomHex -Random $random) }

                # Act
                $once = Merge-DocsMatrixRef -Matrix $matrix -SnapshotPin $snapshotPin -LedgerPin $ledgerPin
                $twice = Merge-DocsMatrixRef -Matrix $once -SnapshotPin $snapshotPin -LedgerPin $ledgerPin

                # Assert
                (ConvertTo-DocsCanonicalJson -Value $twice) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $once) -Because "seed=$seed round=$round"
                $once['snapshot_ref']['sha256'] | Should -BeExactly $snapshotPin.sha256 -Because "seed=$seed round=$round"
                $once['ledger_ref']['sha256'] | Should -BeExactly $ledgerPin.sha256 -Because "seed=$seed round=$round"
                Get-TestMatrixFindingCount -Document $once | Should -Be 0 -Because "seed=$seed round=$round"
            }
        }
    }
}
