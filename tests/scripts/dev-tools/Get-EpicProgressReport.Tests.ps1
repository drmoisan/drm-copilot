# Pester 5 tests for scripts/dev-tools/Get-EpicProgressReport.ps1 (issue #1080).
# The script is dot-sourced with its two mandatory parameters bound, so the entry-point
# block is skipped. Every I/O seam is either exercised without side effects (absent
# command, absent path, a read of the script itself, a -WhatIf write) or mocked with a
# matching parameter signature; no test starts git, gh, or cswap, writes a file, or reads
# the clock.

BeforeAll {
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/Get-EpicProgressReport.ps1'
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/Get-EpicProgressReport.Logic.ps1'
    . $script:scriptPath -EpicFolder 'example-epic' -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc))
}

Describe 'Resolve-EpicProgressSetting' {
    BeforeAll {
        $script:fixtureRoot = '/fixture-repo'
        $script:fixtureTemp = '/fixture-temp'
    }

    It 'defaults the integration branch from the epic folder' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -TempRoot $script:fixtureTemp -CurrentLocation $script:fixtureRoot

        $setting.IntegrationBranch | Should -Be 'origin/epic/example-epic-integration'
    }

    It 'defaults the kickoff path from the epic folder' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -TempRoot $script:fixtureTemp -CurrentLocation $script:fixtureRoot

        $setting.KickoffPath | Should -Be 'docs/features/epics/example-epic/epic-kickoff.md'
    }

    It 'defaults the checkpoint path under the repository root' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -TempRoot $script:fixtureTemp -CurrentLocation $script:fixtureRoot

        $expected = Join-Path -Path $script:fixtureRoot -ChildPath 'artifacts' -AdditionalChildPath 'orchestration', 'epic-orchestrator-state.json'
        $setting.RepositoryRoot | Should -Be $script:fixtureRoot
        $setting.CheckpointPath | Should -Be $expected
    }

    It 'defaults the state path under the temporary root and outside the repository' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -TempRoot $script:fixtureTemp -CurrentLocation $script:fixtureRoot

        $setting.StatePath | Should -Be (Join-Path -Path $script:fixtureTemp -ChildPath 'epic-progress-example-epic.json')
        $setting.StatePath.StartsWith($script:fixtureRoot, [System.StringComparison]::Ordinal) | Should -BeFalse
    }

    It 'keeps explicit values over defaults' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -EpicIssue '42' -IntegrationBranch 'origin/other' -KickoffPath 'docs/other/kickoff.md' -RepositoryRoot '/other-repo' -CheckpointPath '/other-repo/state.json' -StatePath '/other-temp/samples.json' -TempRoot $script:fixtureTemp -CurrentLocation $script:fixtureRoot

        $setting.EpicIssue | Should -Be '42'
        $setting.IntegrationBranch | Should -Be 'origin/other'
        $setting.KickoffPath | Should -Be 'docs/other/kickoff.md'
        $setting.RepositoryRoot | Should -Be '/other-repo'
        $setting.CheckpointPath | Should -Be '/other-repo/state.json'
        $setting.StatePath | Should -Be '/other-temp/samples.json'
    }
}

Describe 'I/O seams without side effects' {
    It 'returns false for an absent command name' {
        Test-EpicProgressCommand -Name 'epic-progress-absent-command-1080' | Should -BeFalse
    }

    It 'returns false for an absent path' {
        Test-EpicProgressPath -Path (Join-Path -Path $PSScriptRoot -ChildPath 'absent-epic-progress-fixture.json') | Should -BeFalse
        Test-EpicProgressPath -Path '' | Should -BeFalse
    }

    It 'reads the raw text of an existing file' {
        $text = Read-EpicProgressFile -Path $script:scriptPath

        Test-EpicProgressPath -Path $script:scriptPath | Should -BeTrue
        $text | Should -BeOfType [string]
        $text | Should -Match 'function Resolve-EpicProgressSetting'
    }

    It 'writes nothing when the state write runs with WhatIf' {
        $target = Join-Path -Path $PSScriptRoot -ChildPath 'absent-epic-progress-state.json'

        Write-EpicProgressState -Path $target -Content '[]' -WhatIf

        Test-Path -LiteralPath $target | Should -BeFalse
    }
}
