<#
.SYNOPSIS
    Pester regression tests for generic spreadsheet contract tokens (issue #1006).

.DESCRIPTION
    A default spreadsheet sheet-tab name such as Sheet1 names no exported symbol,
    schema, or CLI identifier, yet the contract harvest recorded it as a contract,
    so two unrelated work items whose specs mentioned a worksheet received a hard
    contract_dependency edge. quality-tiers.yml produced a second false hard edge
    as a shared surface. These tests mirror
    tests/scripts/dev_tools/test_blast_radius_generic_contracts.py: the
    Test-GenericContractToken predicate, the three PowerShell contract-filtering
    sites, the parity pin of the stem constant against the Python source, the
    module exports, and the end-to-end issue scenario under both committed truth
    tables.

    Every configuration is a committed truth table read as text; no temporary
    file is created and no external process is started. Non-ASCII probes are
    built from character codes so this file holds ASCII text only.
#>

BeforeAll {
    # Resolve the repository root four levels up: blast-radius -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path

    # The facade is imported FIRST, in the order BlastRadiusNormalization.Tests.ps1
    # uses: Import-Module -Force removes a module before re-importing it, and the
    # facade force-imports its siblings. Get-ContractIdentifier is not exported
    # by the facade, so the normalization module is imported directly, and the
    # token-shape module is imported directly so the predicate is reachable even
    # before the extraction module re-exports it.
    Import-Module (Resolve-Path (Join-Path $script:RepoRoot '.claude/lib/blast-radius/BlastRadius.psm1')).Path -Force
    Import-Module (Resolve-Path (Join-Path $script:RepoRoot '.claude/lib/blast-radius/BlastRadiusNormalization.psm1')).Path -Force
    Import-Module (Resolve-Path (Join-Path $script:RepoRoot '.claude/lib/blast-radius/BlastRadiusTokenShape.psm1')).Path -Force

    $script:PythonTokenShapePath = Join-Path $script:RepoRoot 'scripts/dev_tools/_blast_radius_token_shapes.py'
    $script:ComputedAt = '2026-10-30T11-05'
    $script:TierMap = 'quality-tiers.yml'

    # A spec whose interface section names a default worksheet and one genuine
    # contract identifier. Only the genuine identifier is a contract.
    $script:SpecWithSheetAndContract = @(
        '# Example spec',
        '## Interface',
        '- Reads worksheet `Sheet1` and exports `ParseLedger`.'
    ) -join [Environment]::NewLine

    # The issue scenario: a spec naming only the worksheet, and a plan writing
    # one ordinary file that is not a shared surface in either committed table.
    $script:ScenarioSpec = @(
        '# Scenario spec',
        '## Interface',
        '- The importer reads worksheet `Sheet1`.'
    ) -join [Environment]::NewLine
    $script:ScenarioPlan = @(
        '### Phase 1 - Implementation',
        '- [ ] [P1-T1] Edit `src/issue_1006_ordinary_module.py`.'
    ) -join [Environment]::NewLine

    function Read-CommittedTable {
        param([string] $RelativePath)
        # Each call parses a fresh copy, so a test that edits its copy cannot
        # leak the edit into another test.
        return Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw | ConvertFrom-Json -AsHashtable
    }

    function New-ScenarioRadius {
        param([string] $FeatureFolder, [hashtable] $Config)
        # Derive and normalize the way the planner records a declared radius,
        # then append the tier map after normalization (the planner append
        # obligation) and re-resolve shared surfaces from the extended paths.
        $derived = Get-BlastRadius -PlanText $script:ScenarioPlan -SpecText $script:ScenarioSpec `
            -FeatureFolder $FeatureFolder -Config $Config -Source 'declared' -ComputedAt $script:ComputedAt
        $normalized = Get-NormalizedDeclaredRadius -Radius $derived -Config $Config
        $paths = [string[]]@(@($normalized['paths']) + $script:TierMap)
        $resolved = Get-BlastRadiusFromObservedPaths -ObservedPaths $paths -Config $Config -ComputedAt $script:ComputedAt
        return @{
            paths           = $paths
            modules         = @($normalized['modules'])
            shared_surfaces = @($resolved['shared_surfaces'])
            contracts       = @($normalized['contracts'])
            source          = $normalized['source']
            computed_at     = $normalized['computed_at']
        }
    }

    function New-ScenarioItem {
        param([hashtable] $Config)
        return @(
            @{ key = 41; radius = (New-ScenarioRadius -FeatureFolder '2026-10-30-item-41' -Config $Config) },
            @{ key = 42; radius = (New-ScenarioRadius -FeatureFolder '2026-10-30-item-42' -Config $Config) }
        )
    }
}

Describe 'Generic contract-token rejection (issue #1006)' {
    Context 'Test-GenericContractToken' {
        It 'recognizes <Token> as a generic token' -ForEach @(
            @{ Token = 'Sheet1' },
            @{ Token = 'sheet12' },
            @{ Token = 'CHART3' }
        ) {
            Test-GenericContractToken -Token $Token | Should -BeTrue
        }

        It 'rejects <Label>' -ForEach @(
            @{ Label = 'a bare stem'; Token = 'Sheet' },
            @{ Label = 'a trailing letter'; Token = 'Sheet1a' },
            @{ Label = 'a prefixed stem'; Token = 'MySheet1' },
            @{ Label = 'a member access'; Token = 'Sheet1.Range' },
            @{ Label = 'the empty string'; Token = '' },
            @{ Label = 'a full-width digit'; Token = 'Sheet' + [char]0xFF11 },
            @{ Label = 'a trailing Kelvin sign'; Token = 'Sheet1' + [char]0x212A },
            @{ Label = 'a long-s look-alike'; Token = [string][char]0x017F + 'heet1' },
            @{ Label = 'a workbook name'; Token = 'Book1' },
            @{ Label = 'a table name'; Token = 'Table1' }
        ) {
            Test-GenericContractToken -Token $Token | Should -BeFalse
        }

        It 'pins GenericContractStem to GENERIC_CONTRACT_STEMS in the Python source' {
            # Arrange: read the quoted segments between GENERIC_CONTRACT_STEMS and
            # its .split() call. The Python double quote is matched with \x22 so
            # this file holds no double-quoted string.
            $pythonText = Get-Content -LiteralPath $script:PythonTokenShapePath -Raw
            $body = [regex]::Match($pythonText, '(?s)GENERIC_CONTRACT_STEMS: tuple\[str, \.\.\.\] = tuple\((.*?)\.split\(\)').Groups[1].Value
            $joined = (@([regex]::Matches($body, '\x22([^\x22]*)\x22') | ForEach-Object { $_.Groups[1].Value }) -join '')
            [string[]] $pythonStem = @($joined -split '\s+' | Where-Object { $_.Length -gt 0 })
            # The defining module is read from the function's own script block,
            # so the comparison reads the module's script scope without editing it.
            $tokenShapeModule = (Get-Command -Name Test-GenericContractToken).ScriptBlock.Module
            [string[]] $powerShellStem = @(& $tokenShapeModule { [string[]] @($script:GenericContractStem) })

            # Assert: declaration order is part of the contract, so no sort.
            $pythonStem.Count | Should -Be 2
            ($powerShellStem -join ' ') | Should -BeExactly ($pythonStem -join ' ')
        }

        It 'exports Test-GenericContractToken from <ModuleName>' -ForEach @(
            @{ ModuleName = 'BlastRadiusTokenShape' },
            @{ ModuleName = 'BlastRadiusExtraction' }
        ) {
            # Arrange: every loaded instance of the module, nested or not.
            $loaded = @(Get-Module -All -Name $ModuleName)

            # Assert
            $loaded.Count | Should -BeGreaterThan 0
            foreach ($module in $loaded) {
                $module.ExportedFunctions.Keys | Should -Contain 'Test-GenericContractToken'
            }
        }
    }

    Context 'Contract-filtering sites' {
        It 'drops Sheet1 and keeps ParseLedger in Get-ContractIdentifier' {
            @(Get-ContractIdentifier -SpecText $script:SpecWithSheetAndContract) | Should -Be @('ParseLedger')
        }

        It 'drops Sheet1 and keeps ParseLedger in Get-WriteIntentSpecContract' {
            @(Get-WriteIntentSpecContract -SpecText $script:SpecWithSheetAndContract) | Should -Be @('ParseLedger')
        }

        It 'drops a recorded Sheet1 contract and keeps ParseLedger in Get-NormalizedDeclaredRadius' {
            # Arrange: a declared radius recorded by the pre-change extractor.
            $recorded = @{
                paths           = @('docs/features/active/2026-10-30-recorded-item/**')
                modules         = @()
                shared_surfaces = @()
                contracts       = @('ParseLedger', 'Sheet1')
                source          = 'declared'
                computed_at     = $script:ComputedAt
            }
            $config = Read-CommittedTable -RelativePath 'config/blast-radius.json'

            # Act
            $normalized = Get-NormalizedDeclaredRadius -Radius $recorded -Config $config

            # Assert
            @($normalized['contracts']) | Should -Be @('ParseLedger')
        }
    }

    Context 'Issue 1006 scenario' {
        It 'reports no hard edge for the issue 1006 scenario under <Label>' -ForEach @(
            @{ Label = 'the self-hosted table'; RelativePath = 'config/blast-radius.json' },
            @{ Label = 'the bundled table'; RelativePath = 'extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json' }
        ) {
            # Arrange
            $config = Read-CommittedTable -RelativePath $RelativePath
            $items = New-ScenarioItem -Config $config
            $radius = @{}
            foreach ($item in $items) { $radius[[long]$item['key']] = $item['radius'] }

            # Act
            $result = Get-BlastRadiusConflictEdge -Item $items -Config $config -Relation ${function:Test-BlastRadiusConflict}

            # Assert: name the reason kinds the relation reports for every hard
            # edge, because an edge record keeps only the first kind.
            $hardReason = @(foreach ($edge in @($result['edges'])) {
                    if ($edge['hard']) {
                        $kinds = @((Test-BlastRadiusConflict -RadiusA $radius[[long]$edge['a']] -RadiusB $radius[[long]$edge['b']] -Config $config)['reasons'] |
                                ForEach-Object { $_['kind'] })
                        '{0}~{1}: {2}' -f $edge['a'], $edge['b'], ($kinds -join ',')
                    }
                })
            $hardReason | Should -BeNullOrEmpty
        }

        It 'keeps every detected conflict as an edge at tolerance zero under <Label>' -ForEach @(
            @{ Label = 'the self-hosted table'; RelativePath = 'config/blast-radius.json' },
            @{ Label = 'the bundled table'; RelativePath = 'extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json' }
        ) {
            # Arrange: a fresh copy of the committed table with only the
            # tolerance set to zero.
            $config = Read-CommittedTable -RelativePath $RelativePath
            $config['conflict_tolerance']['tolerance_percent'] = 0
            $items = @(New-ScenarioItem -Config $config)

            # Act
            $result = Get-BlastRadiusConflictEdge -Item $items -Config $config -Relation ${function:Test-BlastRadiusConflict}

            # Assert: every pair the relation reports is an edge, and nothing else.
            $edgePair = @(@($result['edges']) | ForEach-Object { '{0}~{1}' -f $_['a'], $_['b'] })
            $detectedPair = @(for ($first = 0; $first -lt $items.Count; $first++) {
                    for ($second = $first + 1; $second -lt $items.Count; $second++) {
                        $verdict = Test-BlastRadiusConflict -RadiusA $items[$first]['radius'] -RadiusB $items[$second]['radius'] -Config $config
                        if ($verdict['conflict']) { '{0}~{1}' -f $items[$first]['key'], $items[$second]['key'] }
                    }
                })
            $detectedPair.Count | Should -BeGreaterThan 0
            ($edgePair -join ' ') | Should -BeExactly ($detectedPair -join ' ')
        }
    }
}
