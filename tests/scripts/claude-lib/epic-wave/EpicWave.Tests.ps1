#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the epic wave module and its command entry (issue #1129).

.DESCRIPTION
    Covers the three distinct manifest errors of Get-EpicWaveNumber, the exit codes of
    Invoke-EpicWaveCommand with an in-memory reader, and the Invoke-EpicWave.ps1 entry
    script invoked in-process against committed fixtures. No temporary file is created.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/epic-wave/EpicWave.psm1'
    $script:CliPath = Join-Path $script:RepoRoot '.claude/lib/epic-wave/Invoke-EpicWave.ps1'
    $script:FixtureRoot = Join-Path $script:RepoRoot 'tests/fixtures/epic_wave'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name EpicWave -Force -ErrorAction SilentlyContinue
}

Describe 'Get-EpicWaveNumber errors' {
    It 'rejects a self-loop with the self-loop prefix and the feature name' {
        { Get-EpicWaveNumber -Manifest @{ solo = @('solo') } } | Should -Throw -ExpectedMessage "EPIC_WAVE_SELF_LOOP:*'solo'*"
    }

    It 'rejects a cycle with the cycle prefix' {
        { Get-EpicWaveNumber -Manifest @{ a = @('b'); b = @('a') } } | Should -Throw -ExpectedMessage 'EPIC_WAVE_CYCLE:*'
    }

    It 'rejects an unresolved reference naming the feature and the missing dependency' {
        { Get-EpicWaveNumber -Manifest @{ a = @('ghost') } } | Should -Throw -ExpectedMessage "EPIC_WAVE_UNRESOLVED_REFERENCE:*'a'*'ghost'*"
    }

    It 'keeps the three messages distinct' {
        $messages = foreach ($manifest in @(@{ a = @('a') }, @{ a = @('b'); b = @('a') }, @{ a = @('c') })) {
            try { Get-EpicWaveNumber -Manifest $manifest } catch { ($_.Exception.Message -split ':')[0] }
        }
        @($messages | Select-Object -Unique).Count | Should -Be 3
    }

    It 'treats feature names as case-sensitive' {
        $manifest = [System.Collections.Generic.Dictionary[string, string[]]]::new([StringComparer]::Ordinal)
        $manifest['A'] = [string[]] @()
        $manifest['a'] = [string[]] @('A')

        $result = Get-EpicWaveNumber -Manifest $manifest

        $result['A'] | Should -Be 0
        $result['a'] | Should -Be 1
    }

    It 'treats a null dependency list as no dependencies' {
        (Get-EpicWaveNumber -Manifest @{ a = $null })['a'] | Should -Be 0
    }
}

Describe 'Invoke-EpicWaveCommand' {
    It 'returns exit code 0 and the compressed wave map on success' {
        $result = Invoke-EpicWaveCommand -ManifestPath 'm.json' -ReadManifestText { '{"b":["a"],"a":[]}' }

        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -BeExactly '{"a":0,"b":1}'
        $result.Stderr | Should -BeExactly ''
    }

    It 'returns exit code 0 for manifest keys that differ only by case' {
        $result = Invoke-EpicWaveCommand -ManifestPath 'm.json' -ReadManifestText { '{"a":[],"A":["a"]}' }

        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -BeExactly '{"A":1,"a":0}'
        $result.Stderr | Should -BeExactly ''
    }

    It 'returns exit code 0 and an empty object for an empty manifest' {
        $result = Invoke-EpicWaveCommand -ManifestPath 'm.json' -ReadManifestText { '{}' }

        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -BeExactly '{}'
    }

    It 'returns exit code 1 with the <Prefix> message for <Name>' -ForEach @(
        @{ Name = 'a self-loop'; Text = '{"a":["a"]}'; Prefix = 'EPIC_WAVE_SELF_LOOP:' }
        @{ Name = 'a cycle'; Text = '{"a":["b"],"b":["a"]}'; Prefix = 'EPIC_WAVE_CYCLE:' }
        @{ Name = 'an unresolved reference'; Text = '{"a":["z"]}'; Prefix = 'EPIC_WAVE_UNRESOLVED_REFERENCE:' }
    ) {
        $reader = { param($Path) $null = $Path; $Text }.GetNewClosure()

        $result = Invoke-EpicWaveCommand -ManifestPath 'm.json' -ReadManifestText $reader

        $result.ExitCode | Should -Be 1
        $result.Stderr | Should -BeLike "$Prefix*"
        $result.Stdout | Should -BeExactly ''
    }

    It 'returns exit code 2 for <Name>' -ForEach @(
        @{ Name = 'an invalid JSON document'; Text = '{not json' }
        @{ Name = 'an empty document'; Text = '' }
        @{ Name = 'a JSON array root'; Text = '["a"]' }
        @{ Name = 'a JSON string root'; Text = '"a"' }
        @{ Name = 'a non-array value'; Text = '{"a":"b"}' }
        @{ Name = 'a non-string dependency'; Text = '{"a":[1]}' }
    ) {
        $reader = { param($Path) $null = $Path; $Text }.GetNewClosure()

        $result = Invoke-EpicWaveCommand -ManifestPath 'm.json' -ReadManifestText $reader

        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -BeLike 'EPIC_WAVE_USAGE:*'
    }

    It 'returns exit code 2 for an empty manifest path' {
        (Invoke-EpicWaveCommand -ManifestPath '').ExitCode | Should -Be 2
    }

    It 'returns exit code 2 when the reader throws' {
        $result = Invoke-EpicWaveCommand -ManifestPath 'm.json' -ReadManifestText { throw 'cannot read' }

        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -BeLike '*cannot read*'
    }

    It 'propagates an unexpected computation failure' {
        InModuleScope EpicWave {
            Mock Get-EpicWaveNumber { throw 'unexpected failure' }

            { Invoke-EpicWaveCommand -ManifestPath 'm.json' -ReadManifestText { '{"a":[]}' } } | Should -Throw -ExpectedMessage 'unexpected failure'
        }
    }
}

Describe 'Invoke-EpicWave.ps1 entry script' {
    It 'exits 0 and writes the wave map for a valid manifest' {
        $output = & $script:CliPath -ManifestPath (Join-Path $script:FixtureRoot 'cli-valid-manifest.json')

        $LASTEXITCODE | Should -Be 0
        $output | Should -BeExactly '{"a":0,"b":1,"c":2}'
    }

    It 'exits 0 and writes both case-variant keys' {
        $output = & $script:CliPath -ManifestPath (Join-Path $script:FixtureRoot 'cli-case-variant-manifest.json')

        $LASTEXITCODE | Should -Be 0
        $output | Should -BeExactly '{"A":1,"a":0}'
    }

    It 'exits 1 for a cyclic manifest' {
        $null = & $script:CliPath -ManifestPath (Join-Path $script:FixtureRoot 'cli-cycle-manifest.json') 2>&1

        $LASTEXITCODE | Should -Be 1
    }

    It 'exits 2 for a manifest that is not an object' {
        $null = & $script:CliPath -ManifestPath (Join-Path $script:FixtureRoot 'cli-not-an-object.json') 2>&1

        $LASTEXITCODE | Should -Be 2
    }

    It 'exits 2 for a missing file' {
        $null = & $script:CliPath -ManifestPath (Join-Path $script:FixtureRoot 'does-not-exist.json') 2>&1

        $LASTEXITCODE | Should -Be 2
    }

    It 'exits 2 when no manifest path is given' {
        $null = & $script:CliPath 2>&1

        $LASTEXITCODE | Should -Be 2
    }
}
