<#
.SYNOPSIS
    Pester tests for the aggregate cost cap (issue #1013, spec D-2).

.DESCRIPTION
    Mirrors tests/scripts/dev_tools/test_blast_radius_aggregate.py against
    .claude/lib/blast-radius/BlastRadiusAggregate.psm1 and the post-pass in
    Get-BlastRadiusConflictEdge. Every case of the three committed aggregate
    fixtures is asserted to the fixture's hand-derived values, both through
    Get-AggregateCappedPair directly and through the scheduling entry point,
    plus the tolerance-0 no-op. The tests read only committed fixture files,
    create no temporary file, and start no external process.
#>

# Discovery-time corpus enumeration: one generated It per fixture case.
$aggregateDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius/aggregate").Path
$aggregateCase = @(
    foreach ($stem in @('aggregate-cap-promotes-cheapest-pair', 'aggregate-cap-tie-break', 'aggregate-cap-cascade')) {
        $fixture = Get-Content -LiteralPath (Join-Path $aggregateDirectory "$stem.json") -Raw | ConvertFrom-Json -AsHashtable
        for ($index = 0; $index -lt @($fixture['cases']).Count; $index++) {
            @{ FixtureName = $stem; CaseName = $fixture['cases'][$index]['name']; CaseIndex = $index; FixturePath = (Join-Path $aggregateDirectory "$stem.json") }
        }
    }
)

BeforeAll {
    # The facade is imported first, then the scheduling module (for the reader)
    # and the aggregate module, because the facade re-imports its siblings with
    # -Force.
    $libraryRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius").Path
    Import-Module (Join-Path $libraryRoot 'BlastRadius.psm1') -Force
    Import-Module (Join-Path $libraryRoot 'BlastRadiusScheduling.psm1') -Force
    Import-Module (Join-Path $libraryRoot 'BlastRadiusAggregate.psm1') -Force
    $script:ConflictRelation = ${function:Test-BlastRadiusConflict}
    # Pester reads $aggregateCase only during discovery, so the run phase names
    # the two fixtures its non-generated rows read.
    $fixtureRoot = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius/aggregate").Path
    $script:CascadePath = Join-Path $fixtureRoot 'aggregate-cap-cascade.json'
    $script:CheapestPath = Join-Path $fixtureRoot 'aggregate-cap-promotes-cheapest-pair.json'

    function Read-AggregateCase {
        param([string] $Path, [int] $Index)
        $fixture = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable
        return @{ config = $fixture['config']; case = $fixture['cases'][$Index] }
    }

    # The key-to-band map; an item without a band is left out.
    function Get-CaseBand {
        param([hashtable] $Case)
        $band = @{}
        foreach ($item in $Case['items']) {
            if ($item.ContainsKey('band')) { $band[[long]$item['key']] = $item['band'] }
        }
        return $band
    }

    function Format-Pair {
        param([object[]] $Pair)
        return (@($Pair | ForEach-Object { '{0}-{1}' -f $_['a'], $_['b'] }) -join ',')
    }
    function Format-ExpectedPromoted {
        param([object[]] $Promoted)
        return (@($Promoted | ForEach-Object { '{0}-{1}' -f $_[0], $_[1] }) -join ',')
    }
    function Format-Edge {
        param([object[]] $Edge)
        return (@($Edge | ForEach-Object { '{0}-{1}|{2}|{3}|{4}|{5}' -f $_['a'], $_['b'], $_['reason'], $_['hard'], $_['cost'], $_['benefit'] }) -join ';')
    }
    function Format-Tolerated {
        param([object[]] $Overlap)
        return (@($Overlap | ForEach-Object { '{0}-{1}|{2}|{3}|{4}' -f $_['a'], $_['b'], (@($_['reasons']) -join ','), $_['cost'], $_['benefit'] }) -join ';')
    }
}

Describe 'BlastRadiusAggregate (issue #1013)' {
    Context 'Get-AggregateCappedPair cap selection' {
        It 'promotes the hand-derived pairs for <FixtureName> case <CaseName>' -ForEach $aggregateCase {
            $data = Read-AggregateCase -Path $FixturePath -Index $CaseIndex
            $tolerance = Get-ConfigConflictTolerance -Config $data['config']

            $promoted = @(Get-AggregateCappedPair -ToleratedOverlap @($data['case']['pairwise_tolerated']) -Band (Get-CaseBand -Case $data['case']) -Tolerance $tolerance)

            Format-Pair -Pair $promoted | Should -BeExactly (Format-ExpectedPromoted -Promoted @($data['case']['expected_promoted']))
        }

        It 'promotes nothing from an empty overlap list' {
            $tolerance = Get-ConfigConflictTolerance -Config @{ version = 1 }
            @(Get-AggregateCappedPair -ToleratedOverlap @() -Band @{} -Tolerance $tolerance).Count | Should -Be 0
        }

        It 'does not mutate the overlap records or the band map' {
            $data = Read-AggregateCase -Path $script:CascadePath -Index 0
            $overlap = @($data['case']['pairwise_tolerated'])
            $band = Get-CaseBand -Case $data['case']
            $overlapBefore = ConvertTo-Json -InputObject $overlap -Depth 10 -Compress
            # The band map has integer keys, so it is snapshotted as sorted text.
            $bandBefore = (@($band.Keys | Sort-Object | ForEach-Object { '{0}={1}' -f $_, $band[$_] }) -join ',')

            [void]@(Get-AggregateCappedPair -ToleratedOverlap $overlap -Band $band -Tolerance (Get-ConfigConflictTolerance -Config $data['config']))

            ConvertTo-Json -InputObject $overlap -Depth 10 -Compress | Should -BeExactly $overlapBefore
            (@($band.Keys | Sort-Object | ForEach-Object { '{0}={1}' -f $_, $band[$_] }) -join ',') | Should -BeExactly $bandBefore
        }

        It 'rejects a band outside the configured bands' {
            $tolerance = Get-ConfigConflictTolerance -Config (Read-AggregateCase -Path $script:CheapestPath -Index 0)['config']
            $overlap = @(@{ a = 1; b = 2; cost = 9; benefit = 1 })
            { Get-AggregateCappedPair -ToleratedOverlap $overlap -Band @{ 1 = 'C9' } -Tolerance $tolerance } | Should -Throw
        }
    }

    Context 'Get-BlastRadiusConflictEdge post-pass' {
        It 'reproduces the capped edges and tolerated overlaps for <FixtureName> case <CaseName>' -ForEach $aggregateCase {
            $data = Read-AggregateCase -Path $FixturePath -Index $CaseIndex

            $result = Get-BlastRadiusConflictEdge -Item @($data['case']['items']) -Config $data['config'] -Relation $script:ConflictRelation

            Format-Edge -Edge $result['edges'] | Should -BeExactly (Format-Edge -Edge @($data['case']['expected_edges']))
            Format-Tolerated -Overlap $result['tolerated_overlaps'] | Should -BeExactly (Format-Tolerated -Overlap @($data['case']['expected_tolerated']))
        }

        It 'is a no-op at tolerance 0 for <FixtureName> case <CaseName>' -ForEach $aggregateCase {
            $data = Read-AggregateCase -Path $FixturePath -Index $CaseIndex
            $data['config']['conflict_tolerance']['tolerance_percent'] = 0

            $result = Get-BlastRadiusConflictEdge -Item @($data['case']['items']) -Config $data['config'] -Relation $script:ConflictRelation

            # Every detected conflict (the capped edges plus the tolerated
            # overlaps at the fixture tolerance) is an edge at tolerance 0.
            $detected = @(@($data['case']['expected_edges']) + @($data['case']['expected_tolerated']) |
                    Sort-Object -Property { $_['a'] }, { $_['b'] })
            @($result['tolerated_overlaps']).Count | Should -Be 0
            Format-Pair -Pair $result['edges'] | Should -BeExactly (Format-Pair -Pair $detected)
        }
    }
}
