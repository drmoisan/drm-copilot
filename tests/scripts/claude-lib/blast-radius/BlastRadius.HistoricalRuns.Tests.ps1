<#
.SYNOPSIS
    Pinned historical parallel runs for the PowerShell scheduling layer (issue #722).

.DESCRIPTION
    Mirrors the BEFORE tests of tests/scripts/dev_tools/test_blast_radius_historical_runs.py.
    Each committed fixture under tests/fixtures/blast_radius/historical-runs
    carries one historical run's recorded radii, per-item complexity bands, the
    pre-change truth table, and the pinned BEFORE edges. These tests re-derive
    the edges with the unchanged relation Test-BlastRadiusConflict and assert
    that strict scheduling (the conflict_tolerance key absent, or set to
    tolerance 0) through Get-BlastRadiusConflictEdge reproduces the pinned edge
    set with no tolerated overlap. The AFTER test normalizes every recorded
    radius with the fixture's AFTER truth table through
    Get-NormalizedDeclaredRadius, schedules the run with that table, and asserts
    the pinned AFTER edges (with hard, cost, and benefit) and tolerated overlaps.

    Cohort partitions are asserted by the Python module only, because the
    PowerShell library has no cohort-coloring function; this file asserts the
    edge sets that feed the coloring. Every value is read from the committed
    fixtures; no test reads a remote ref or a generated build directory, creates
    a temporary file, or starts an external process.
#>

# Discovery-time run list. Each generated It carries its run name in the It name.
$historicalDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius/historical-runs").Path
$runCase = @(
    'epic-655-followups', 'backlog-2026-09-26', 'followups-2026-09-27' | ForEach-Object {
        @{ Run = $_; RunPath = (Join-Path $historicalDirectory "$_.json") }
    }
)

BeforeAll {
    # Resolve the facade four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    Import-Module $facadePath -Force

    # The second strict configuration: tolerance 0 with the committed weights.
    function Get-ZeroToleranceMember {
        return @{
            tolerance_percent = 0
            weights           = @{ same_file = 8; possible_overlap = 2; append_only = 1; module = 2 }
            band_durations    = @{ C1 = 1; C2 = 2; C3 = 4; C4 = 8 }
            default_band      = 'C1'
            append_only_paths = @('**/CHANGELOG.md')
        }
    }

    # -DateKind String keeps computed_at a string. The recorded radii carry real
    # ISO-8601 instants, which ConvertFrom-Json otherwise materializes as
    # [datetime]; the radius contract requires a string.
    function Read-HistoricalRun {
        param([string] $Path)
        return (Get-Content -Path $Path -Raw | ConvertFrom-Json -AsHashtable -DateKind String)
    }

    # The pinned BEFORE edges in their one-line form a-b|reason, fixture order.
    function Get-PinnedEdge {
        param([hashtable] $Before)
        return @($Before['edges'] | ForEach-Object { '{0}-{1}|{2}' -f $_['a'], $_['b'], $_['reason'] })
    }
}

Describe 'Blast-radius historical runs' {
    foreach ($case in $runCase) {
        It "reproduces the pinned BEFORE edges for $($case['Run'])" -ForEach @($case) {
            # Arrange: the recorded radii keyed by issue number, and the
            # pre-change truth table.
            $fixture = Read-HistoricalRun -Path $RunPath
            $before = $fixture['before']
            $radius = @{}
            foreach ($entry in $fixture['items']) { $radius[[int]$entry['issue_num']] = $entry['radius'] }
            $key = @($radius.Keys | Sort-Object)

            # Act: evaluate every unordered pair once, in ascending key order.
            $derived = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $key.Count; $i++) {
                for ($j = $i + 1; $j -lt $key.Count; $j++) {
                    $result = Test-BlastRadiusConflict -RadiusA $radius[$key[$i]] -RadiusB $radius[$key[$j]] -Config $before['config']
                    if ($result['conflict']) {
                        $derived.Add(('{0}-{1}|{2}' -f $key[$i], $key[$j], $result['reasons'][0]['kind']))
                    }
                }
            }

            # Assert
            @($derived.ToArray()) | Should -Be (Get-PinnedEdge -Before $before) -Because $Run
            $derived.Count | Should -Be $before['edge_count'] -Because $Run
        }

        It "matches detection at tolerance 0 for $($case['Run'])" -ForEach @($case) {
            # Arrange: the absent-key and tolerance-0 configurations, and one
            # scheduling item per recorded radius carrying its recorded band.
            $fixture = Read-HistoricalRun -Path $RunPath
            $before = $fixture['before']
            $absent = $before['config'].Clone()
            $absent.Remove('conflict_tolerance')
            $zero = $absent.Clone()
            $zero['conflict_tolerance'] = Get-ZeroToleranceMember
            $item = @($fixture['items'] | ForEach-Object {
                    @{ key = [int]$_['issue_num']; radius = $_['radius']; band = $_['complexity_band'] }
                })

            foreach ($config in @($absent, $zero)) {
                # Act
                $result = Get-BlastRadiusConflictEdge -Item $item -Config $config

                # Assert: the pinned edges with their reasons, and no tolerated pair.
                @($result['edges'] | ForEach-Object { '{0}-{1}|{2}' -f $_['a'], $_['b'], $_['reason'] }) |
                    Should -Be (Get-PinnedEdge -Before $before) -Because $Run
                @($result['tolerated_overlaps']).Count | Should -Be 0 -Because $Run
            }
        }

        It "reproduces the pinned AFTER edges and tolerated overlaps for $($case['Run'])" -ForEach @($case) {
            # Arrange: the AFTER truth table, and one scheduling item per recorded
            # radius, normalized with that table and carrying its recorded band.
            $fixture = Read-HistoricalRun -Path $RunPath
            $after = $fixture['after']
            $item = @($fixture['items'] | ForEach-Object {
                    $normalized = Get-NormalizedDeclaredRadius -Radius $_['radius'] -Config $after['config']
                    @{ key = [int]$_['issue_num']; radius = $normalized; band = $_['complexity_band'] }
                })

            # Act
            $result = Get-BlastRadiusConflictEdge -Item $item -Config $after['config']

            # Assert: the edges with their tolerated extra fields, then the
            # tolerated overlaps with their full reason lists, in pinned order.
            $edgeFormat = '{0}-{1}|{2}|{3}|{4}|{5}'
            @($result['edges'] | ForEach-Object { $edgeFormat -f $_['a'], $_['b'], $_['reason'], $_['hard'], $_['cost'], $_['benefit'] }) |
                Should -Be @($after['edges'] | ForEach-Object { $edgeFormat -f $_['a'], $_['b'], $_['reason'], $_['hard'], $_['cost'], $_['benefit'] }) -Because $Run
            @($result['edges']).Count | Should -Be $after['edge_count'] -Because $Run
            $toleratedFormat = '{0}-{1}|{2}|{3}|{4}'
            @($result['tolerated_overlaps'] | ForEach-Object { $toleratedFormat -f $_['a'], $_['b'], (@($_['reasons']) -join ','), $_['cost'], $_['benefit'] }) |
                Should -Be @($after['tolerated_overlaps'] | ForEach-Object { $toleratedFormat -f $_['a'], $_['b'], (@($_['reasons']) -join ','), $_['cost'], $_['benefit'] }) -Because $Run
        }
    }
}
