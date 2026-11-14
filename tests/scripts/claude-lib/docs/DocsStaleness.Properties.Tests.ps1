#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsStaleness.psm1.

.DESCRIPTION
    Get-DocsPinStatus is enumerated exhaustively over presence, digest equality and revision
    equality; Get-DocsStalePage and Get-DocsStalenessFinding are checked over seeded pin sets
    (each -Because message states the seed). No file is written.
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
    $script:Pages = @('docs/reference/Cli.md', 'docs/reference/cli.md', 'docs/guides/Start.md', 'docs/Index.md')

    $snapshotText = ConvertTo-DocsJsonText -Value (New-DocsLedgerTestSnapshot)
    $script:Elements = (ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $snapshotText).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $snapshotText)).Element
    $script:ElementIds = @($script:Elements.Keys | Sort-Object)

    function Get-TestRandomPin {
        # A pin on a random page for a random fixture element; Status selects current, digest-changed or element-missing.
        param([System.Random] $Random, [string] $Status)
        $copy = [ordered]@{}
        $element = $script:Elements[$script:ElementIds[$Random.Next($script:ElementIds.Count)]]
        foreach ($key in $element.Keys) { $copy[$key] = $element[$key] }
        if ($Status -ceq 'digest-changed') { $copy['source_sha256'] = ('0123456789abcdef' * 4).Substring(0, 63) + [string] $Random.Next(10) }
        $pin = New-DocsEvidencePin -Element $copy -PagePath $script:Pages[$Random.Next($script:Pages.Count)] -Revision $(if ($Random.Next(2) -eq 0) { $null } else { 'a' * 40 }) -PinnedAt $script:PinnedAt -Actor $script:Actor
        if ($Status -ceq 'element-missing') { $pin['element_id'] = $copy['kind'] + '-' + ('f' * 64) }
        $pin
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsStaleness properties' {
    It 'property Get-DocsPinStatus: presence by digest by revision product yields the three statuses; revision never matters (exhaustive)' {
        # Arrange
        $element = $script:Elements[$script:ElementIds[0]]
        $checked = 0
        foreach ($present in $true, $false) {
            foreach ($sameDigest in $true, $false) {
                foreach ($sameRevision in $true, $false) {
                    $copy = [ordered]@{}
                    foreach ($key in $element.Keys) { $copy[$key] = $element[$key] }
                    if (-not $sameDigest) { $copy['source_sha256'] = 'e' * 64 }
                    $pin = New-DocsEvidencePin -Element $copy -PagePath 'docs/Index.md' -Revision $(if ($sameRevision) { 'a' * 40 } else { 'b' * 40 }) -PinnedAt $script:PinnedAt -Actor $script:Actor
                    if (-not $present) { $pin['element_id'] = $copy['kind'] + '-' + ('f' * 64) }
                    $expected = if (-not $present) { 'element-missing' } elseif (-not $sameDigest) { 'digest-changed' } else { 'current' }

                    # Act and Assert
                    Get-DocsPinStatus -Pin $pin -Element $script:Elements | Should -BeExactly $expected -Because "present=$present sameDigest=$sameDigest sameRevision=$sameRevision"
                    $checked++
                }
            }
        }
        $checked | Should -Be 8
    }

    It 'property Get-DocsStalePage: page listed exactly when a pin is not current; ordinal and permutation invariant' {
        $statuses = @('current', 'digest-changed', 'element-missing')
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $pins = @(for ($round = 0; $round -lt 10; $round++) { Get-TestRandomPin -Random $random -Status $statuses[$random.Next(3)] })
            $distinct = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
            foreach ($pin in $pins) { $distinct[$pin['pin_id']] = $pin }
            $pins = @($distinct.Values)
            $expectedSet = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
            foreach ($pin in $pins) { if ((Get-DocsPinStatus -Pin $pin -Element $script:Elements) -cne 'current') { [void]$expectedSet.Add([string] $pin['page_path']) } }
            [string[]] $ordinalPages = @($expectedSet)

            # Act
            $stale = Get-DocsStalePage -PinSet (New-DocsLedgerTestPinSet -Pin $pins) -Element $script:Elements
            $baseline = ConvertTo-DocsCanonicalJson -Value $stale
            $shuffled = ConvertTo-DocsCanonicalJson -Value (Get-DocsStalePage -PinSet (New-DocsLedgerTestPinSet -Pin (Get-DocsLedgerTestShuffle -Item $pins -Seed $seed)) -Element $script:Elements)

            # Assert
            @($stale | ForEach-Object { $_['page_path'] }) | Should -Be $ordinalPages -Because "seed=$seed lists exactly the pages with a non-current pin in ordinal order"
            foreach ($record in $stale) {
                foreach ($entry in $record['pins']) { $entry['status'] | Should -Not -BeExactly 'current' -Because "seed=$seed lists only non-current pins" }
            }
            $shuffled | Should -BeExactly $baseline -Because "seed=$seed is permutation invariant"
        }
    }

    It 'property Get-DocsStalenessFinding: one finding per stale page with the requested severity' {
        $statuses = @('current', 'digest-changed', 'element-missing')
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $pins = @(for ($round = 0; $round -lt 10; $round++) { Get-TestRandomPin -Random $random -Status $statuses[$random.Next(3)] })
            $distinct = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
            foreach ($pin in $pins) { $distinct[$pin['pin_id']] = $pin }
            $pinSet = New-DocsLedgerTestPinSet -Pin @($distinct.Values)
            $stale = Get-DocsStalePage -PinSet $pinSet -Element $script:Elements
            $severity = @('warning', 'error')[$random.Next(2)]

            # Act
            $findings = Get-DocsStalenessFinding -StalePage $stale -Element $script:Elements -Severity $severity -PinSet $pinSet

            # Assert
            $findings.Count | Should -Be $stale.Count -Because "seed=$seed"
            @($findings | ForEach-Object { $_['related_paths'][0] } | Sort-Object) | Should -Be @($stale | ForEach-Object { $_['page_path'] } | Sort-Object) -Because "seed=$seed names every stale page once"
            foreach ($finding in $findings) {
                $finding['severity'] | Should -BeExactly $severity -Because "seed=$seed"
                $finding['code'] | Should -BeExactly 'DOCS_STALE_PAGE' -Because "seed=$seed"
            }
        }
    }
}
