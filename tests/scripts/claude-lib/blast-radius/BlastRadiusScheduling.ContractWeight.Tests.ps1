<#
.SYNOPSIS
    Pester tests for the contract cost weight (issue #1013, spec D-7).

.DESCRIPTION
    Mirrors tests/scripts/dev_tools/test_blast_radius_contract_weight.py against
    .claude/lib/blast-radius/BlastRadiusScheduling.psm1: the reader cases of
    conflict_tolerance.weights.contract, the contract cost term (zero, one, and
    two shared identifiers, a repeated identifier counted once, a letter-case
    difference that shares nothing, a same-file pair, weight independence for a
    pair sharing nothing, and a contract-only pair that stays a hard edge), the
    tolerance-0 strict identity with the contract term, and a parity row that
    pins $script:WeightName to WEIGHT_NAMES in the Python source.

    Every configuration is built in memory; no temporary file is created and no
    external process is started. The module scope is read without mutation.
#>

BeforeAll {
    # The facade is imported first and the scheduling module second, because the
    # facade re-imports its siblings with -Force.
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/blast-radius/BlastRadius.psm1') -Force
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/blast-radius/BlastRadiusScheduling.psm1') -Force
    $script:ConflictRelation = ${function:Test-BlastRadiusConflict}
    $script:PythonSchedulingPath = Join-Path $script:RepoRoot 'scripts/dev_tools/_blast_radius_scheduling.py'
    $script:WeightsLabel = 'config["conflict_tolerance"]["weights"]'
    $script:ContractLabel = 'config["conflict_tolerance"]["weights"]["contract"]'

    # The committed weights with an optional contract override; a $null value
    # removes the contract name.
    function Get-TestWeight {
        param([object] $Contract = 8, [switch] $OmitContract, [hashtable] $Extra = @{})
        $weight = @{ same_file = 8; possible_overlap = 2; append_only = 1; module = 2 }
        if (-not $OmitContract) { $weight['contract'] = $Contract }
        foreach ($key in $Extra.Keys) { $weight[$key] = $Extra[$key] }
        return $weight
    }

    function Get-TestConfig {
        param([long] $TolerancePercent = 100, [hashtable] $Weight = (Get-TestWeight))
        return @{
            version               = 1
            shared_surfaces       = @()
            shared_surface_globs  = @()
            mergeable_paths       = @()
            conflict_tolerance    = @{
                tolerance_percent = $TolerancePercent
                weights           = $Weight
                band_durations    = @{ C1 = 1; C2 = 2; C3 = 4; C4 = 8 }
                default_band      = 'C1'
                append_only_paths = @('**/CHANGELOG.md')
            }
            modules               = @{}
            over_breadth_fraction = 0.25
        }
    }

    function Get-TestRadius {
        param([string[]] $Paths = @(), [string[]] $Modules = @(), [string[]] $SharedSurfaces = @(), [string[]] $Contracts = @())
        return @{
            paths = $Paths; modules = $Modules; shared_surfaces = $SharedSurfaces; contracts = $Contracts
            source = 'declared'; computed_at = '2026-10-30T00-00'
        }
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

    function Get-PairCost {
        param([hashtable] $RadiusA, [hashtable] $RadiusB, [hashtable] $Config)
        $tolerance = Get-ConfigConflictTolerance -Config $Config
        return Get-BlastRadiusPairCost -RadiusA $RadiusA -RadiusB $RadiusB -Config $Config -Tolerance $tolerance
    }

    # The invariant item set: paths, modules, a shared surface, and zero, one,
    # and two shared contract identifiers.
    function Get-InvariantItem {
        param([object[]] $Band)
        $radius = @(
            (Get-TestRadius -Paths 'src/app.py' -Modules 'core' -Contracts 'ParseLedger'),
            (Get-TestRadius -Paths 'src/app.py' -Contracts 'FormatInvoice', 'ParseLedger'),
            (Get-TestRadius -Paths 'src/**' -Modules 'core' -Contracts 'FormatInvoice', 'ParseLedger'),
            (Get-TestRadius -Paths 'CHANGELOG.md' -SharedSurfaces 'poetry.lock'),
            (Get-TestRadius -Modules 'core' -SharedSurfaces 'poetry.lock' -Contracts 'FormatInvoice'),
            (Get-TestRadius -Paths 'docs/guide.md', 'CHANGELOG.md' -Modules 'docs')
        )
        $item = for ($index = 0; $index -lt $radius.Count; $index++) {
            @{ key = $index + 1; radius = $radius[$index]; band = $Band[$index] }
        }
        return @($item)
    }

    function Get-SharedContractCount {
        param([hashtable] $RadiusA, [hashtable] $RadiusB)
        $set = [System.Collections.Generic.HashSet[string]]::new([string[]]@($RadiusA['contracts']), [StringComparer]::Ordinal)
        $set.IntersectWith([string[]]@($RadiusB['contracts']))
        return $set.Count
    }

    function Format-PairSet {
        param([object[]] $Record)
        return (@($Record | ForEach-Object { '{0}-{1}' -f $_['a'], $_['b'] }) -join ',')
    }

    $script:InvariantBand = @(
        , @($null, $null, $null, $null, $null, $null)
        , @('C4', 'C4', 'C4', 'C4', 'C4', 'C4')
        , @('C1', 'C2', 'C3', 'C4', 'C2', 'C1')
    )
    $script:InvariantTolerance = @(0, 1, 50, 100, 400, 1000000)
}

Describe 'BlastRadiusScheduling contract weight (issue #1013)' {
    Context 'contract weight reader' {
        It 'accepts a contract weight of <Value>' -ForEach @(
            @{ Value = 1 }, @{ Value = 8 }, @{ Value = 1000 }
        ) {
            $tolerance = Get-ConfigConflictTolerance -Config (Get-TestConfig -Weight (Get-TestWeight -Contract $Value))
            $tolerance['weights']['contract'] | Should -Be $Value
        }

        It 'rejects a missing contract name naming the weights label' {
            $config = Get-TestConfig -Weight (Get-TestWeight -OmitContract)
            $message = Get-ThrownMessage { Get-ConfigConflictTolerance -Config $config }
            $message | Should -Not -BeNullOrEmpty
            $message.Contains($script:WeightsLabel) | Should -BeTrue -Because $message
        }

        It 'rejects an unknown extra weight name naming the weights label' {
            $config = Get-TestConfig -Weight (Get-TestWeight -Extra @{ surface = 4 })
            $message = Get-ThrownMessage { Get-ConfigConflictTolerance -Config $config }
            $message | Should -Not -BeNullOrEmpty
            $message.Contains($script:WeightsLabel) | Should -BeTrue -Because $message
        }

        It 'rejects the <Label> contract weight naming the contract label' -ForEach @(
            @{ Label = 'boolean'; Value = $true },
            @{ Label = 'float'; Value = 8.0 },
            @{ Label = 'string'; Value = '8' },
            @{ Label = 'zero'; Value = 0 },
            @{ Label = 'negative'; Value = -1 }
        ) {
            $config = Get-TestConfig -Weight (Get-TestWeight -Contract $Value)
            $message = Get-ThrownMessage { Get-ConfigConflictTolerance -Config $config }
            $message | Should -Not -BeNullOrEmpty
            $message.Contains($script:ContractLabel) | Should -BeTrue -Because $message
        }

        It 'carries contract 1 in the absent-key strict hashtable' {
            $config = Get-TestConfig
            $config.Remove('conflict_tolerance')
            (Get-ConfigConflictTolerance -Config $config)['weights']['contract'] | Should -Be 1
        }

        It 'pins $script:WeightName to WEIGHT_NAMES in the Python source' {
            # The Python double quote is matched with \x22 so this file holds no
            # double-quoted Python fragment.
            $pythonText = Get-Content -LiteralPath $script:PythonSchedulingPath -Raw
            $body = [regex]::Match($pythonText, '(?s)WEIGHT_NAMES: tuple\[str, \.\.\.\] = tuple\(\s*\x22([^\x22]*)\x22\.split\(\)').Groups[1].Value
            [string[]] $pythonName = @($body -split '\s+' | Where-Object { $_.Length -gt 0 })
            $schedulingModule = (Get-Command -Name Get-ConfigConflictTolerance).ScriptBlock.Module
            [string[]] $powerShellName = @(& $schedulingModule { [string[]] @($script:WeightName) })

            $pythonName.Count | Should -Be 5
            ($powerShellName -join ' ') | Should -BeExactly ($pythonName -join ' ')
        }
    }

    Context 'contract cost term' {
        It 'costs <Expected> for disjoint paths sharing <Label>' -ForEach @(
            @{ Label = 'no identifier'; Shared = @(); Expected = 0 },
            @{ Label = 'one identifier'; Shared = @('ParseLedger'); Expected = 8 },
            @{ Label = 'two identifiers'; Shared = @('FormatInvoice', 'ParseLedger'); Expected = 16 }
        ) {
            $a = Get-TestRadius -Paths 'src/a.py' -Contracts (@($Shared) + 'LeftOnly')
            $b = Get-TestRadius -Paths 'src/b.py' -Contracts (@($Shared) + 'RightOnly')
            Get-PairCost -RadiusA $a -RadiusB $b -Config (Get-TestConfig) | Should -Be $Expected
        }

        It 'counts a repeated identifier once' {
            $a = Get-TestRadius -Paths 'src/a.py' -Contracts 'ParseLedger', 'ParseLedger'
            $b = Get-TestRadius -Paths 'src/b.py' -Contracts 'ParseLedger'
            Get-PairCost -RadiusA $a -RadiusB $b -Config (Get-TestConfig) | Should -Be 8
        }

        It 'shares nothing for identifiers that differ only in letter case' {
            $config = Get-TestConfig
            $a = Get-TestRadius -Paths 'src/a.py' -Contracts 'ParseLedger'
            $b = Get-TestRadius -Paths 'src/b.py' -Contracts 'parseledger'
            $kind = @((Test-BlastRadiusConflict -RadiusA $a -RadiusB $b -Config $config)['reasons'] | ForEach-Object { $_['kind'] })
            Get-PairCost -RadiusA $a -RadiusB $b -Config $config | Should -Be 0
            $kind | Should -Not -Contain 'contract_dependency'
        }

        It 'costs a same-file pair sharing one identifier both terms' {
            $a = Get-TestRadius -Paths 'src/x.py' -Contracts 'ParseLedger'
            $b = Get-TestRadius -Paths 'src/x.py' -Contracts 'ParseLedger'
            Get-PairCost -RadiusA $a -RadiusB $b -Config (Get-TestConfig) | Should -Be 16
        }

        It 'costs a pair sharing no identifier the same under contract 1 and 1000 (<Label>)' -ForEach @(
            @{ Label = 'same file'; A = @{ Paths = @('src/x.py') }; B = @{ Paths = @('src/x.py') } },
            @{ Label = 'glob and module'; A = @{ Paths = @('src/**'); Modules = @('core') }; B = @{ Paths = @('src/a.py'); Modules = @('core') } },
            @{ Label = 'append-only'; A = @{ Paths = @('CHANGELOG.md') }; B = @{ Paths = @('CHANGELOG.md') } },
            @{ Label = 'distinct contracts'; A = @{ Contracts = @('ParseLedger') }; B = @{ Contracts = @('FormatInvoice') } },
            @{ Label = 'shared surface'; A = @{ SharedSurfaces = @('poetry.lock') }; B = @{ SharedSurfaces = @('poetry.lock') } }
        ) {
            $a = Get-TestRadius @A
            $b = Get-TestRadius @B
            $low = Get-PairCost -RadiusA $a -RadiusB $b -Config (Get-TestConfig -Weight (Get-TestWeight -Contract 1))
            $high = Get-PairCost -RadiusA $a -RadiusB $b -Config (Get-TestConfig -Weight (Get-TestWeight -Contract 1000))
            $high | Should -Be $low
        }

        It 'keeps a contract-only pair a hard edge with cost 8 at tolerance 1000000' {
            $a = Get-TestRadius -Paths 'src/a.py' -Contracts 'ParseLedger'
            $b = Get-TestRadius -Paths 'src/b.py' -Contracts 'ParseLedger'
            $decision = Get-BlastRadiusPairDecision -RadiusA $a -RadiusB $b -Config (Get-TestConfig -TolerancePercent 1000000) -Relation $script:ConflictRelation
            $decision['hard'] | Should -BeTrue
            $decision['edge'] | Should -BeTrue
            $decision['cost'] | Should -Be 8
        }
    }

    Context 'Tolerance-0 strict identity with the contract term' {
        It 'keeps the tolerance-0 edges equal to detection for contract <Weight>' -ForEach @(
            @{ Weight = 1 }, @{ Weight = 8 }, @{ Weight = 1000 }
        ) {
            $config = Get-TestConfig -TolerancePercent 0 -Weight (Get-TestWeight -Contract $Weight)
            foreach ($band in $script:InvariantBand) {
                $item = Get-InvariantItem -Band $band
                $detected = for ($i = 0; $i -lt $item.Count; $i++) {
                    for ($j = $i + 1; $j -lt $item.Count; $j++) {
                        if ((Test-BlastRadiusConflict -RadiusA $item[$i]['radius'] -RadiusB $item[$j]['radius'] -Config $config)['conflict']) {
                            @{ a = $item[$i]['key']; b = $item[$j]['key'] }
                        }
                    }
                }
                $result = Get-BlastRadiusConflictEdge -Item $item -Config $config -Relation $script:ConflictRelation
                Format-PairSet -Record $result['edges'] | Should -BeExactly (Format-PairSet -Record @($detected))
                @($result['tolerated_overlaps']).Count | Should -Be 0
            }
        }

        It 'keeps the pair sets equal across contract weights at tolerance <Tolerance>' -ForEach @(
            @{ Tolerance = 0 }, @{ Tolerance = 1 }, @{ Tolerance = 50 }, @{ Tolerance = 100 }, @{ Tolerance = 400 }, @{ Tolerance = 1000000 }
        ) {
            foreach ($band in $script:InvariantBand) {
                $item = Get-InvariantItem -Band $band
                $radius = @{}
                foreach ($entry in $item) { $radius[[long]$entry['key']] = $entry['radius'] }
                $result = @{}
                foreach ($weight in @(1, 8, 1000)) {
                    $config = Get-TestConfig -TolerancePercent $Tolerance -Weight (Get-TestWeight -Contract $weight)
                    $result[$weight] = Get-BlastRadiusConflictEdge -Item $item -Config $config -Relation $script:ConflictRelation
                }

                foreach ($weight in @(8, 1000)) {
                    Format-PairSet -Record $result[$weight]['edges'] | Should -BeExactly (Format-PairSet -Record $result[1]['edges'])
                    Format-PairSet -Record $result[$weight]['tolerated_overlaps'] | Should -BeExactly (Format-PairSet -Record $result[1]['tolerated_overlaps'])
                    $baseCost = @{}
                    foreach ($edge in $result[1]['edges']) { $baseCost['{0}-{1}' -f $edge['a'], $edge['b']] = [long]$edge['cost'] }
                    foreach ($edge in $result[$weight]['edges']) {
                        $shared = Get-SharedContractCount -RadiusA $radius[[long]$edge['a']] -RadiusB $radius[[long]$edge['b']]
                        $difference = [long]$edge['cost'] - $baseCost['{0}-{1}' -f $edge['a'], $edge['b']]
                        $difference | Should -Be (($weight - 1) * $shared) -Because ('edge {0}-{1}' -f $edge['a'], $edge['b'])
                    }
                }
            }
        }
    }
}
