#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsEvidencePins.psm1.

.DESCRIPTION
    One property per pure function, generated with a seeded [System.Random] over the seeds of
    DocsLedger.TestSupport.psm1; each -Because message states the seed. No file is written.
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
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:PinnedAt = '2026-03-01T12:00:00Z'
    $script:Pages = @('docs/reference/Cli.md', 'docs/reference/cli.md', 'docs/guides/Start.md', 'docs/Index.md')

    function Get-TestRandomText {
        param([System.Random] $Random)
        $words = @('Alpha', 'beta', 'Gamma', 'delta', 'EPSILON', 'zeta')
        @(1..(1 + $Random.Next(3)) | ForEach-Object { $words[$Random.Next($words.Count)] }) -join ' '
    }

    function Get-TestRandomHex {
        param([System.Random] $Random)
        $hex = '0123456789abcdef'
        $text = ''
        for ($index = 0; $index -lt 64; $index++) { $text += $hex[$Random.Next(16)] }
        $text
    }

    function Get-TestRandomPin {
        # A consistent pin for a random fixture element on a random page, optionally with a random digest.
        param([System.Random] $Random)
        $kinds = Get-DocsElementKind
        $element = New-DocsLedgerTestElement -Kind $kinds[$Random.Next($kinds.Count)]
        if ($Random.Next(2) -eq 0) { $element['source_sha256'] = Get-TestRandomHex -Random $Random }
        New-DocsEvidencePin -Element $element -PagePath $script:Pages[$Random.Next($script:Pages.Count)] -Claim $(if ($Random.Next(2) -eq 0) { $null } else { Get-TestRandomText -Random $Random }) -PinnedAt $script:PinnedAt -Actor $script:Actor
    }

    function Get-TestPinFindingCount {
        param([object] $Document)
        (Test-DocsArtifactText -ArtifactKind 'docs-evidence-pin' -JsonText (ConvertTo-DocsJsonText -Value $Document) -ComposedSchemaSet $script:Composed).Count
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsEvidencePins properties' {
    It 'property Get-DocsPinId: injective over seeded triples; stable across calls' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $seen = @{}
            for ($round = 0; $round -lt 25; $round++) {
                $elementId = 'public-symbol-' + (Get-TestRandomHex -Random $random)
                $page = $script:Pages[$random.Next($script:Pages.Count)]
                $symbol = Get-TestRandomText -Random $random
                $key = $elementId + '|' + $page + '|' + $symbol

                # Act
                $first = Get-DocsPinId -ElementId $elementId -PagePath $page -Symbol $symbol
                $second = Get-DocsPinId -ElementId $elementId -PagePath $page -Symbol $symbol

                # Assert
                $first | Should -BeExactly $second -Because "seed=$seed round=$round is stable"
                if ($seen.ContainsKey($key)) { $seen[$key] | Should -BeExactly $first -Because "seed=$seed round=$round" }
                foreach ($otherKey in @($seen.Keys)) { if ($otherKey -cne $key) { $seen[$otherKey] | Should -Not -BeExactly $first -Because "seed=$seed round=$round is injective" } }
                $seen[$key] = $first
            }
        }
    }

    It 'property New-DocsEvidencePin: built pins yield no DOCS_PIN_INCONSISTENT' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $pins = @(for ($round = 0; $round -lt 6; $round++) { Get-TestRandomPin -Random $random })
            $distinct = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
            foreach ($pin in $pins) { $distinct[$pin['pin_id']] = $pin }
            $pinSet = New-DocsLedgerTestPinSet -Pin @($distinct.Values)

            # Act
            $findings = Get-DocsPinFinding -PinSet $pinSet

            # Assert
            $findings.Count | Should -Be 0 -Because "seed=$seed"
            Get-TestPinFindingCount -Document $pinSet | Should -Be 0 -Because "seed=$seed"
        }
    }

    It 'property New-DocsPinCollectionDocument: id depends only on the repository id' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 10; $round++) {
                $repository = 'repo' + $random.Next(1000)

                # Act
                $first = New-DocsPinCollectionDocument -RepositoryId $repository
                $second = New-DocsPinCollectionDocument -RepositoryId $repository
                $other = New-DocsPinCollectionDocument -RepositoryId ($repository + 'x')

                # Assert
                $first['id'] | Should -BeExactly $second['id'] -Because "seed=$seed round=$round"
                $first['id'] | Should -Not -BeExactly $other['id'] -Because "seed=$seed round=$round"
                $first['id'] | Should -BeExactly (Get-DocsStableId -Prefix 'docs-evidence-pin' -Value @{ repository = $repository }) -Because "seed=$seed round=$round"
            }
        }
    }

    It 'property Get-DocsPinFinding: findings and canonical output invariant under pin permutation' {
        # Arrange: a consistent set plus one tampered pin and one wrong pin_id, which produce index-independent codes.
        $random = [System.Random]::new(7)
        $pins = @(for ($round = 0; $round -lt 5; $round++) { Get-TestRandomPin -Random $random })
        $tampered = New-DocsEvidencePin -Element (New-DocsLedgerTestElement -Kind 'http-route') -PagePath 'docs/Tampered.md' -PinnedAt $script:PinnedAt -Actor $script:Actor
        $tampered['element_id'] = 'http-route-' + ('e' * 64)
        $wrong = New-DocsEvidencePin -Element (New-DocsLedgerTestElement -Kind 'config-key') -PagePath 'docs/Wrong.md' -PinnedAt $script:PinnedAt -Actor $script:Actor
        $wrong['pin_id'] = 'pin-' + ('1' * 64)
        $all = $pins + @($tampered, $wrong)
        $baseline = @((Get-DocsPinFinding -PinSet (New-DocsLedgerTestPinSet -Pin $all)) | ForEach-Object { $_['code'] + '|' + (@($_['related_ids']) -join ',') + '|' + $_['pointer'].Substring($_['pointer'].LastIndexOf('/')) } | Sort-Object)
        $baselineCanonical = ConvertTo-DocsCanonicalJson -Value (Get-DocsPinFinding -PinSet (New-DocsLedgerTestPinSet -Pin $pins))

        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Act
            $shuffled = @((Get-DocsPinFinding -PinSet (New-DocsLedgerTestPinSet -Pin (Get-DocsLedgerTestShuffle -Item $all -Seed $seed))) | ForEach-Object { $_['code'] + '|' + (@($_['related_ids']) -join ',') + '|' + $_['pointer'].Substring($_['pointer'].LastIndexOf('/')) } | Sort-Object)
            $consistentCanonical = ConvertTo-DocsCanonicalJson -Value (Get-DocsPinFinding -PinSet (New-DocsLedgerTestPinSet -Pin (Get-DocsLedgerTestShuffle -Item $pins -Seed $seed)))

            # Assert
            $shuffled | Should -Be $baseline -Because "seed=$seed keeps the findings apart from their index"
            $consistentCanonical | Should -BeExactly $baselineCanonical -Because "seed=$seed keeps the canonical output of a consistent set"
        }
        $baseline.Count | Should -BeGreaterThan 0
    }

    It 'property Merge-DocsEvidencePin: re-pinning keeps one pin with the same pin_id' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $pins = @(for ($round = 0; $round -lt 5; $round++) { Get-TestRandomPin -Random $random })
            $pinSet = New-DocsLedgerTestPinSet -Pin $pins
            $target = $pins[$random.Next($pins.Count)]
            $element = New-DocsLedgerTestElement -Kind $target['element_kind']
            $element['source_sha256'] = Get-TestRandomHex -Random $random
            $repin = New-DocsEvidencePin -Element $element -PagePath $target['page_path'] -Claim 'Re-pinned.' -PinnedAt '2026-04-01T00:00:00Z' -Actor $script:Actor

            # Act
            $merged = Merge-DocsEvidencePin -PinSet $pinSet -Pin $repin

            # Assert
            $repin['pin_id'] | Should -BeExactly $target['pin_id'] -Because "seed=$seed derives the same pin_id"
            @($merged['pins'] | Where-Object { $_['pin_id'] -ceq $target['pin_id'] }).Count | Should -Be 1 -Because "seed=$seed"
            @($merged['pins'] | Where-Object { $_['pin_id'] -ceq $target['pin_id'] })[0]['claim'] | Should -BeExactly 'Re-pinned.' -Because "seed=$seed"
            $ids = @($merged['pins'] | ForEach-Object { $_['pin_id'] })
            [string[]] $sorted = @($ids)
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sorted -Because "seed=$seed sorts by pin_id"
            @($ids | Sort-Object -Unique).Count | Should -Be $ids.Count -Because "seed=$seed keeps one pin per id"
        }
    }

    It 'property Get-DocsPinSetWithoutPin: removes exactly the pins of the named element and page' {
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $pins = @(for ($round = 0; $round -lt 8; $round++) { Get-TestRandomPin -Random $random })
            $distinct = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
            foreach ($pin in $pins) { $distinct[$pin['pin_id']] = $pin }
            $pins = @($distinct.Values)
            $pinSet = New-DocsLedgerTestPinSet -Pin $pins
            $target = $pins[$random.Next($pins.Count)]

            # Act
            $withoutPage = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId $target['element_id'] -PagePath $target['page_path']
            $withoutElement = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId $target['element_id']

            # Assert
            $expectedPage = @($pins | Where-Object { -not ($_['element_id'] -ceq $target['element_id'] -and $_['page_path'] -ceq $target['page_path']) } | ForEach-Object { $_['pin_id'] } | Sort-Object)
            $expectedElement = @($pins | Where-Object { $_['element_id'] -cne $target['element_id'] } | ForEach-Object { $_['pin_id'] } | Sort-Object)
            @($withoutPage['pins'] | ForEach-Object { $_['pin_id'] } | Sort-Object) | Should -Be $expectedPage -Because "seed=$seed"
            @($withoutElement['pins'] | ForEach-Object { $_['pin_id'] } | Sort-Object) | Should -Be $expectedElement -Because "seed=$seed"
        }
    }
}
