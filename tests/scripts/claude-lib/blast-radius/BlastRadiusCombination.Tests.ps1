<#
.SYNOPSIS
    Pester tests for issue combination and its threshold (issue #1013, D-5, D-6).

.DESCRIPTION
    Mirrors tests/scripts/dev_tools/test_blast_radius_combination.py and
    tests/scripts/dev_tools/test_blast_radius_combination_threshold.py against
    .claude/lib/blast-radius/BlastRadiusCombination.psm1 and the
    combination_threshold_percent read of Get-ConfigConflictTolerance. Every case
    of the four committed combination fixtures (including the contract-only
    pair) is asserted to the fixture's hand-derived values; the reader accept,
    default, and reject cases match the Python cases; and a parity row pins the
    PowerShell default to COMBINATION_THRESHOLD_DEFAULT in the Python source.
    The tests read only committed files, create no temporary file, and start no
    external process. The module scope is read without mutation.
#>

# Discovery-time corpus enumeration: one generated It per fixture case.
$combinationDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius/combination").Path
$combinationCase = @(
    foreach ($stem in @('combination-threshold-boundary', 'combination-candidate-classes', 'combination-component-chain', 'combination-contract-only')) {
        $fixture = Get-Content -LiteralPath (Join-Path $combinationDirectory "$stem.json") -Raw | ConvertFrom-Json -AsHashtable
        for ($index = 0; $index -lt @($fixture['cases']).Count; $index++) {
            @{ FixtureName = $stem; CaseName = $fixture['cases'][$index]['name']; CaseIndex = $index; FixturePath = (Join-Path $combinationDirectory "$stem.json") }
        }
    }
)

BeforeAll {
    # The facade is imported first, then the combination module, then the
    # scheduling module (for the reader). Each import re-imports its siblings
    # with -Force, so the scheduling module is imported last to keep its
    # exports resolvable in this scope.
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $libraryRoot = Join-Path $script:RepoRoot '.claude/lib/blast-radius'
    Import-Module (Join-Path $libraryRoot 'BlastRadius.psm1') -Force
    Import-Module (Join-Path $libraryRoot 'BlastRadiusCombination.psm1') -Force
    Import-Module (Join-Path $libraryRoot 'BlastRadiusScheduling.psm1') -Force
    $script:ConflictRelation = ${function:Test-BlastRadiusConflict}
    $script:PythonSchedulingPath = Join-Path $script:RepoRoot 'scripts/dev_tools/_blast_radius_scheduling.py'
    $script:ThresholdLabel = 'config["conflict_tolerance"]["combination_threshold_percent"]'
    $script:ChainPath = Join-Path $script:RepoRoot 'tests/fixtures/blast_radius/combination/combination-component-chain.json'

    # Read one fixture case and apply its tolerance override or key removal.
    function Read-CombinationCase {
        param([string] $Path, [int] $Index)
        $fixture = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable
        $case = $fixture['cases'][$Index]
        $config = $fixture['config']
        if ($case.ContainsKey('conflict_tolerance_absent') -and $case['conflict_tolerance_absent']) {
            $config.Remove('conflict_tolerance')
        } elseif ($case.ContainsKey('tolerance_percent')) {
            $config['conflict_tolerance']['tolerance_percent'] = $case['tolerance_percent']
        }
        return @{ config = $config; case = $case }
    }

    function Format-CombinationPair {
        param([object[]] $Pair)
        return (@($Pair | ForEach-Object { '{0}-{1}|{2}|{3}' -f $_['a'], $_['b'], $_['cost'], $_['benefit'] }) -join ';')
    }
    function Format-Combination {
        param([object[]] $Combination)
        return (@($Combination | ForEach-Object {
                    '{0}|{1}|{2}|{3}' -f (@($_['members']) -join ','), $_['primary'], (Format-CombinationPair -Pair @($_['pairs'])), $_['estimated_savings']
                }) -join ' / ')
    }

    # A valid conflict_tolerance member with the five weight names.
    function Get-ToleranceMember {
        param([hashtable] $Extra = @{})
        $member = @{
            tolerance_percent = 100
            weights           = @{ same_file = 8; possible_overlap = 2; append_only = 1; module = 2; contract = 8 }
            band_durations    = @{ C1 = 1; C2 = 2; C3 = 4; C4 = 8 }
            default_band      = 'C1'
            append_only_paths = @('**/CHANGELOG.md')
        }
        foreach ($key in $Extra.Keys) { $member[$key] = $Extra[$key] }
        return @{ version = 1; mergeable_paths = @(); conflict_tolerance = $member }
    }

    # Return the message of the error a script block throws, or $null.
    function Get-ThrownMessage {
        param([scriptblock] $Action)
        try {
            & $Action | Out-Null
        } catch {
            return $_.Exception.Message
        }
        return $null
    }
}

Describe 'BlastRadiusCombination (issue #1013)' {
    Context 'Get-BlastRadiusCombination fixtures' {
        It 'reproduces the qualifying pairs and combinations for <FixtureName> case <CaseName>' -ForEach $combinationCase {
            $data = Read-CombinationCase -Path $FixturePath -Index $CaseIndex

            $result = Get-BlastRadiusCombination -Item @($data['case']['items']) -Config $data['config'] -Relation $script:ConflictRelation

            Format-CombinationPair -Pair $result['pairs'] | Should -BeExactly (Format-CombinationPair -Pair @($data['case']['expected_pairs']))
            Format-Combination -Combination $result['combinations'] | Should -BeExactly (Format-Combination -Combination @($data['case']['expected_combinations']))
        }

        It 'returns nothing at tolerance 0 and with the key absent' {
            foreach ($mode in @('zero', 'absent')) {
                $data = Read-CombinationCase -Path $script:ChainPath -Index 0
                if ($mode -eq 'zero') { $data['config']['conflict_tolerance']['tolerance_percent'] = 0 } else { $data['config'].Remove('conflict_tolerance') }

                $result = Get-BlastRadiusCombination -Item @($data['case']['items']) -Config $data['config'] -Relation $script:ConflictRelation

                @($result['pairs']).Count | Should -Be 0 -Because $mode
                @($result['combinations']).Count | Should -Be 0 -Because $mode
            }
        }

        It 'rejects repeated item keys' {
            $data = Read-CombinationCase -Path $script:ChainPath -Index 0
            $item = @($data['case']['items'])
            $repeated = @($item[0], $item[0])
            { Get-BlastRadiusCombination -Item $repeated -Config $data['config'] -Relation $script:ConflictRelation } | Should -Throw
        }

        It 'requires the relation' {
            $data = Read-CombinationCase -Path $script:ChainPath -Index 0
            { Get-BlastRadiusCombination -Item @($data['case']['items']) -Config $data['config'] } | Should -Throw
        }

        It 'leaves the item records and the config unchanged' {
            $data = Read-CombinationCase -Path $script:ChainPath -Index 0
            $before = ConvertTo-Json -InputObject $data -Depth 20 -Compress

            [void](Get-BlastRadiusCombination -Item @($data['case']['items']) -Config $data['config'] -Relation $script:ConflictRelation)

            ConvertTo-Json -InputObject $data -Depth 20 -Compress | Should -BeExactly $before
        }
    }

    Context 'combination_threshold_percent reader' {
        It 'reads <Value> verbatim' -ForEach @(@{ Value = 0 }, @{ Value = 250 }) {
            $tolerance = Get-ConfigConflictTolerance -Config (Get-ToleranceMember -Extra @{ combination_threshold_percent = $Value })
            $tolerance['combination_threshold_percent'] | Should -Be $Value
        }

        It 'defaults an absent member to 400' {
            (Get-ConfigConflictTolerance -Config (Get-ToleranceMember))['combination_threshold_percent'] | Should -Be 400
        }

        It 'carries the default in the absent-key strict hashtable' {
            (Get-ConfigConflictTolerance -Config @{ version = 1 })['combination_threshold_percent'] | Should -Be 400
        }

        It 'rejects the <Label> value naming the member label' -ForEach @(
            @{ Label = 'negative'; Value = -1 },
            @{ Label = 'float'; Value = 2.5 },
            @{ Label = 'string'; Value = '400' },
            @{ Label = 'true'; Value = $true },
            @{ Label = 'false'; Value = $false }
        ) {
            $config = Get-ToleranceMember -Extra @{ combination_threshold_percent = $Value }
            $message = Get-ThrownMessage { Get-ConfigConflictTolerance -Config $config }
            $message | Should -Not -BeNullOrEmpty
            $message.Contains($script:ThresholdLabel) | Should -BeTrue -Because $message
        }

        It 'still rejects an unknown sibling name' {
            $config = Get-ToleranceMember -Extra @{ combination_threshold_percent = 400; combination_cap = 1 }
            $message = Get-ThrownMessage { Get-ConfigConflictTolerance -Config $config }
            $message | Should -Not -BeNullOrEmpty
            $message.Contains('combination_cap') | Should -BeTrue -Because $message
        }

        It 'pins $script:CombinationThresholdDefault to COMBINATION_THRESHOLD_DEFAULT in the Python source' {
            $pythonText = Get-Content -LiteralPath $script:PythonSchedulingPath -Raw
            $match = [regex]::Match($pythonText, '(?m)^COMBINATION_THRESHOLD_DEFAULT = (\d+)\s*$')
            $schedulingModule = (Get-Command -Name Get-ConfigConflictTolerance).ScriptBlock.Module
            $powerShellDefault = & $schedulingModule { $script:CombinationThresholdDefault }

            $match.Success | Should -BeTrue
            [long]$powerShellDefault | Should -Be ([long]$match.Groups[1].Value)
        }
    }
}
