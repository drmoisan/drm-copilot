#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Corpus parity lane for the epic wave computation (issue #1129).

.DESCRIPTION
    Runs every case of tests/fixtures/epic_wave/wave-computation-cases.json through
    Get-EpicWaveNumber. The Python reference lane tests/scripts/dev_tools/test_epic_wave_corpus_parity.py
    reads the same corpus, so the two implementations stay in agreement. Files are read
    with Get-Content only; no temporary file is created.
#>

BeforeDiscovery {
    # The corpus is read at discovery time so one It is generated per case.
    $corpusPath = Join-Path $PSScriptRoot '../../../fixtures/epic_wave/wave-computation-cases.json'
    $corpus = Get-Content -Raw -LiteralPath $corpusPath | ConvertFrom-Json -AsHashtable
    $errorPrefix = @{
        cycle      = 'EPIC_WAVE_CYCLE:'
        self_loop  = 'EPIC_WAVE_SELF_LOOP:'
        unresolved = 'EPIC_WAVE_UNRESOLVED_REFERENCE:'
    }
    $script:Cases = @(foreach ($case in $corpus.cases) {
            $expectedErrorKey = if ($case.ContainsKey('expected_error')) { $case.expected_error } else { $null }
            @{
                Name           = $case.name
                Manifest       = $case.manifest
                ExpectedWaves  = if ($case.ContainsKey('expected_waves')) { $case.expected_waves } else { $null }
                ExpectedPrefix = if ($null -ne $expectedErrorKey) { $errorPrefix[$expectedErrorKey] } else { $null }
            }
        })
}

BeforeAll {
    $script:ModulePath = (Resolve-Path (Join-Path $PSScriptRoot '../../../../.claude/lib/epic-wave/EpicWave.psm1')).Path
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name EpicWave -Force -ErrorAction SilentlyContinue
}

Describe 'EpicWave corpus parity' {
    It 'loads at least the nine corpus cases' -ForEach @(@{ Count = $script:Cases.Count }) {
        $Count | Should -BeGreaterOrEqual 9
    }

    It 'matches the reference for <Name>' -ForEach $script:Cases {
        if ($null -ne $ExpectedPrefix) {
            # Arrange / Act / Assert: an error case must throw its stable message prefix.
            { Get-EpicWaveNumber -Manifest $Manifest } | Should -Throw -ExpectedMessage "$ExpectedPrefix*"
            return
        }

        # Act
        $result = Get-EpicWaveNumber -Manifest $Manifest

        # Assert: same feature set, same wave per feature, ordinal-sorted key order.
        $expectedKeys = [string[]] @($ExpectedWaves.Keys)
        [Array]::Sort($expectedKeys, [StringComparer]::Ordinal)
        ($result.Keys -join ',') | Should -BeExactly ($expectedKeys -join ',')
        foreach ($key in $expectedKeys) {
            $result[$key] | Should -Be $ExpectedWaves[$key]
        }
    }
}
