# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1 (issues #1080, #1093).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies fixed in-memory input and asserts the returned data.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath
}

Describe 'Select-EpicProgressSample' {
    It 'adds the first sample' {
        $result = Select-EpicProgressSample -Sample @() -NowUnixSeconds 1000 -Done 5 -SampleCap 14

        $result.Changed | Should -BeTrue
        $result.Sample.Count | Should -Be 1
        $result.Sample[0].ts | Should -Be 1000
        $result.Sample[0].done | Should -Be 5
    }

    It 'adds a sample 90 seconds after the last' {
        $existing = @([pscustomobject]@{ ts = 1000; done = 5 })

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 1090 -Done 6 -SampleCap 14

        $result.Changed | Should -BeTrue
        ($result.Sample.ts -join ',') | Should -Be '1000,1090'
    }

    It 'does not add a sample 89 seconds after the last' {
        $existing = @([pscustomobject]@{ ts = 1000; done = 5 })

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 1089 -Done 6 -SampleCap 14

        $result.Changed | Should -BeFalse
        $result.Sample.Count | Should -Be 1
        $result.Sample[0].ts | Should -Be 1000
    }

    It 'drops samples without a timestamp when adding' {
        $existing = @(
            [pscustomobject]@{ done = 1 }
            [pscustomobject]@{ ts = 900; done = 2 }
            [pscustomobject]@{ done = 3 }
        )

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 950 -Done 4 -SampleCap 14

        $result.Changed | Should -BeTrue
        ($result.Sample.ts -join ',') | Should -Be '900,950'
    }

    It 'keeps only the last SampleCap samples' {
        $existing = @(0, 100, 200, 300, 400 | ForEach-Object { [pscustomobject]@{ ts = $_; done = 1 } })

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 1000 -Done 2 -SampleCap 3

        $result.Sample.Count | Should -Be 3
        ($result.Sample.ts -join ',') | Should -Be '300,400,1000'
    }
}

Describe 'Resolve-EpicProgressSetting' {
    BeforeAll {
        $script:fixtureRoot = '/fixture-repo'
    }

    It 'defaults the integration branch from the epic folder' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -CurrentLocation $script:fixtureRoot

        $setting.IntegrationBranch | Should -Be 'origin/epic/example-epic-integration'
    }

    It 'defaults the kickoff path from the epic folder' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -CurrentLocation $script:fixtureRoot

        $setting.KickoffPath | Should -Be 'docs/features/epics/example-epic/epic-kickoff.md'
    }

    It 'defaults the checkpoint path under the repository root' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -CurrentLocation $script:fixtureRoot

        $expected = Join-Path -Path $script:fixtureRoot -ChildPath 'artifacts' -AdditionalChildPath 'orchestration', 'epic-orchestrator-state.json'
        $setting.RepositoryRoot | Should -Be $script:fixtureRoot
        $setting.CheckpointPath | Should -Be $expected
    }

    It 'defaults the state path under .claude/state of the repository root' {
        # Issue #1093 (DEC-3): the state survives a container stop wherever the checkout persists.
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -CurrentLocation $script:fixtureRoot

        $expected = Join-Path -Path $script:fixtureRoot -ChildPath '.claude' -AdditionalChildPath 'state', 'epic-progress-example-epic.json'
        $setting.StatePath | Should -Be $expected
    }

    It 'keeps explicit values over defaults' {
        $setting = Resolve-EpicProgressSetting -EpicFolder 'example-epic' -EpicIssue '42' -IntegrationBranch 'origin/other' -KickoffPath 'docs/other/kickoff.md' -RepositoryRoot '/other-repo' -CheckpointPath '/other-repo/state.json' -StatePath '/other-temp/samples.json' -CurrentLocation $script:fixtureRoot

        $setting.EpicIssue | Should -Be '42'
        $setting.IntegrationBranch | Should -Be 'origin/other'
        $setting.KickoffPath | Should -Be 'docs/other/kickoff.md'
        $setting.RepositoryRoot | Should -Be '/other-repo'
        $setting.CheckpointPath | Should -Be '/other-repo/state.json'
        $setting.StatePath | Should -Be '/other-temp/samples.json'
    }
}
