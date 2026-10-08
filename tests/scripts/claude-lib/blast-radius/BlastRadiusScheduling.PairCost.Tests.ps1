<#
.SYNOPSIS
    Characterization tests pinning Get-BlastRadiusPairCost values (issue #776).

.DESCRIPTION
    Issue #776 replaced the nested Test-EntryOverlap loop inside
    Get-BlastRadiusPairCost with one loop over Get-OverlappingPathPair. These rows
    were pinned against the unchanged nested-loop implementation, so a passing run
    shows the rewrite keeps every cost identical: same_file, possible_overlap for a
    glob and for a listed directory, append_only precedence, the module term, the
    mergeable zero, and a sum over several pairs. Each It follows
    Arrange-Act-Assert. The tests invoke no external process and create no
    temporary files.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusScheduling.psm1").Path -Force

    # One truth table for every row: strict tolerance, the committed weights and
    # band durations, and the mergeable and append-only classes the rows exercise.
    function Get-PairCostTestConfig {
        return @{
            version               = 1
            over_breadth_fraction = 0.25
            mergeable_paths       = @('**/*.csproj')
            conflict_tolerance    = @{
                tolerance_percent = 0
                weights           = @{ same_file = 8; possible_overlap = 2; append_only = 1; module = 2 }
                band_durations    = @{ C1 = 1; C2 = 2; C3 = 4; C4 = 8 }
                default_band      = 'C1'
                append_only_paths = @('**/CHANGELOG.md')
            }
        }
    }

    # A declared radius record whose surface and contract levels are empty.
    function Get-PairCostTestRadius {
        param([string[]] $Paths = @(), [string[]] $Modules = @())
        return @{
            paths           = $Paths
            modules         = $Modules
            shared_surfaces = @()
            contracts       = @()
            source          = 'declared'
            computed_at     = '2026-09-29T20-15'
        }
    }
}

Describe 'Get-BlastRadiusPairCost equivalence (issue #776)' {
    It 'returns <Expected> for <Name>' -ForEach @(
        @{ Name = 'one shared concrete file'; PathsA = @('src/a.py', 'src/b.py'); PathsB = @('src/a.py'); ModulesA = @(); ModulesB = @(); Expected = 8 }
        @{ Name = 'a glob over a concrete file'; PathsA = @('src/**'); PathsB = @('docs/x.md', 'src/a.py'); ModulesA = @(); ModulesB = @(); Expected = 2 }
        @{ Name = 'a root append-only file named by both'; PathsA = @('CHANGELOG.md'); PathsB = @('CHANGELOG.md'); ModulesA = @(); ModulesB = @(); Expected = 1 }
        @{ Name = 'shared modules only'; PathsA = @('a/x.py'); PathsB = @('b/y.py'); ModulesA = @('m1', 'm2'); ModulesB = @('m2'); Expected = 2 }
        @{ Name = 'a mergeable project file named by both'; PathsA = @('p/x.csproj'); PathsB = @('p/x.csproj'); ModulesA = @(); ModulesB = @(); Expected = 0 }
        @{ Name = 'a listed directory over a file beneath it'; PathsA = @('scripts/dev_tools'); PathsB = @('scripts/dev_tools/a.py'); ModulesA = @(); ModulesB = @(); Expected = 2 }
        @{ Name = 'mixed pairs summed'; PathsA = @('a/1.py', 'a/**'); PathsB = @('a/1.py', 'a/2.py'); ModulesA = @(); ModulesB = @(); Expected = 12 }
    ) {
        # Arrange: two radius records and the shared config and tolerance.
        $config = Get-PairCostTestConfig
        $tolerance = Get-ConfigConflictTolerance -Config $config
        $radiusA = Get-PairCostTestRadius -Paths $PathsA -Modules $ModulesA
        $radiusB = Get-PairCostTestRadius -Paths $PathsB -Modules $ModulesB

        # Act: compute the integer integration cost of the pair.
        $cost = Get-BlastRadiusPairCost -RadiusA $radiusA -RadiusB $radiusB -Config $config -Tolerance $tolerance

        # Assert: the cost equals the value pinned against the nested-loop code.
        $cost | Should -Be $Expected -Because "the pinned cost for '$Name' is $Expected"
    }
}
