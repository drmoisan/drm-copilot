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

Describe 'ConvertFrom-EpicProgressStateText and ConvertTo-EpicProgressStateJson' {
    It 'reads a legacy sample array' {
        # The issue #1080 tool wrote a bare JSON array of samples with no baseline.
        $state = ConvertFrom-EpicProgressStateText -Text '[{"ts":1000,"done":3},{"ts":1600,"done":5}]'

        $state.Samples.Count | Should -Be 2
        ($state.Samples.ts -join ',') | Should -Be '1000,1600'
        ($state.Samples.done -join ',') | Should -Be '3,5'
        $state.StartUnixSeconds | Should -BeNullOrEmpty
        $state.BaselineDone | Should -BeNullOrEmpty
        $state.BaselineWeeklyPct | Should -BeNullOrEmpty
    }

    It 'reads a version-1 document' {
        $text = '{"version":1,"startUnixSeconds":1767603600,"baselineDone":7,"baselineWeeklyPct":12.5,"samples":[{"ts":1767614400,"done":9}]}'

        $state = ConvertFrom-EpicProgressStateText -Text $text

        $state.StartUnixSeconds | Should -Be 1767603600
        $state.BaselineDone | Should -Be 7
        $state.BaselineWeeklyPct | Should -Be 12.5
        $state.Samples.Count | Should -Be 1
        $state.Samples[0].ts | Should -Be 1767614400
        $state.Samples[0].done | Should -Be 9
    }

    It 'treats blank text as empty state' {
        foreach ($text in @('', '   ', $null)) {
            $state = ConvertFrom-EpicProgressStateText -Text $text

            $state.Samples.Count | Should -Be 0
            $state.StartUnixSeconds | Should -BeNullOrEmpty
            $state.BaselineDone | Should -BeNullOrEmpty
        }
    }

    It 'treats unparseable text as empty state' {
        foreach ($text in @('not json {', '42', '"text"')) {
            $state = ConvertFrom-EpicProgressStateText -Text $text

            $state.Samples.Count | Should -Be 0 -Because "'$text' is not a state document"
            $state.StartUnixSeconds | Should -BeNullOrEmpty
        }
    }

    It 'treats an unknown version as empty state' {
        $state = ConvertFrom-EpicProgressStateText -Text '{"version":2,"startUnixSeconds":1767603600,"baselineDone":7,"samples":[{"ts":1000,"done":1}]}'

        $state.Samples.Count | Should -Be 0
        $state.StartUnixSeconds | Should -BeNullOrEmpty
        $state.BaselineDone | Should -BeNullOrEmpty
        $state.BaselineWeeklyPct | Should -BeNullOrEmpty
    }

    It 'treats missing fields as absent' {
        $state = ConvertFrom-EpicProgressStateText -Text '{"version":1,"baselineDone":null,"baselineWeeklyPct":"n/a"}'

        $state.StartUnixSeconds | Should -BeNullOrEmpty
        $state.BaselineDone | Should -BeNullOrEmpty
        $state.BaselineWeeklyPct | Should -BeNullOrEmpty
        $state.Samples.Count | Should -Be 0
    }

    It 'round-trips integer epoch seconds' {
        $samples = @([pscustomobject]@{ ts = 1767610800; done = 2 }, [pscustomobject]@{ ts = 1767614400; done = 3 })

        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds 1767603600 -BaselineDone 1 -BaselineWeeklyPct 0 -Sample $samples
        $state = ConvertFrom-EpicProgressStateText -Text $json
        $raw = ConvertFrom-Json -InputObject $json

        $raw.version | Should -Be 1
        $raw.startUnixSeconds | Should -BeOfType [long]
        $raw.samples[0].ts | Should -BeOfType [long]
        $json | Should -Not -Match '"ts":\s*"'
        $state.StartUnixSeconds | Should -Be 1767603600
        $state.BaselineDone | Should -Be 1
        $state.BaselineWeeklyPct | Should -Be 0
        ($state.Samples.ts -join ',') | Should -Be '1767610800,1767614400'
        ($state.Samples.done -join ',') | Should -Be '2,3'
    }

    It 'writes a single sample as an array and skips samples without ts' {
        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds 1 -BaselineDone 0 -BaselineWeeklyPct 0 -Sample @([pscustomobject]@{ done = 1 }, [pscustomobject]@{ ts = 5; done = 2 })

        $json | Should -Match '"samples":\s*\['
        (ConvertFrom-EpicProgressStateText -Text $json).Samples.Count | Should -Be 1
    }
}

Describe 'Resolve-EpicProgressBaseline' {
    BeforeAll {
        $script:baseNow = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)
        $script:passedStart = [datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)
        # 1767600000 is 2026-01-05T08:00:00Z.
        $script:storedState = [pscustomobject]@{ StartUnixSeconds = [long] 1767600000; BaselineDone = 11; BaselineWeeklyPct = 30.5; Samples = [object[]] @() }
        $script:emptyState = [pscustomobject]@{ StartUnixSeconds = $null; BaselineDone = $null; BaselineWeeklyPct = $null; Samples = [object[]] @() }
    }

    It 'prefers passed values' {
        $result = Resolve-EpicProgressBaseline -StartUtc $script:passedStart -StartUtcPassed -BaselineDone 4 -BaselineDonePassed -BaselineWeeklyPct 12 -BaselineWeeklyPctPassed -State $script:storedState -NowUtc $script:baseNow

        $result.StartUtc | Should -Be $script:passedStart
        $result.BaselineDone | Should -Be 4
        $result.BaselineWeeklyPct | Should -Be 12
        $result.UseCurrentDone | Should -BeFalse
    }

    It 'uses stored values' {
        $result = Resolve-EpicProgressBaseline -State $script:storedState -NowUtc $script:baseNow

        $result.StartUtc | Should -Be ([datetime]::new(2026, 1, 5, 8, 0, 0, [System.DateTimeKind]::Utc))
        $result.StartUtc.Kind | Should -Be ([System.DateTimeKind]::Utc)
        $result.BaselineDone | Should -Be 11
        $result.BaselineWeeklyPct | Should -Be 30.5
        $result.UseCurrentDone | Should -BeFalse
    }

    It 'resets to now and the current done count' {
        # A stored start and baseline are discarded by the reset.
        $result = Resolve-EpicProgressBaseline -State $script:storedState -ResetBaseline -NowUtc $script:baseNow

        $result.StartUtc | Should -Be $script:baseNow
        $result.UseCurrentDone | Should -BeTrue
    }

    It 'keeps a passed start on reset' {
        $result = Resolve-EpicProgressBaseline -StartUtc $script:passedStart -StartUtcPassed -BaselineDone 6 -BaselineDonePassed -State $script:storedState -ResetBaseline -NowUtc $script:baseNow

        $result.StartUtc | Should -Be $script:passedStart
        $result.BaselineDone | Should -Be 6
        $result.UseCurrentDone | Should -BeFalse
    }

    It 'throws without a start and without reset' {
        { Resolve-EpicProgressBaseline -State $script:emptyState -NowUtc $script:baseNow } | Should -Throw -ExpectedMessage '*-StartUtc*-ResetBaseline*'
    }

    It 'keeps the weekly baseline on reset' {
        $stored = Resolve-EpicProgressBaseline -State $script:storedState -ResetBaseline -NowUtc $script:baseNow
        $empty = Resolve-EpicProgressBaseline -State $script:emptyState -ResetBaseline -NowUtc $script:baseNow
        $passed = Resolve-EpicProgressBaseline -BaselineWeeklyPct 7.5 -BaselineWeeklyPctPassed -State $script:storedState -ResetBaseline -NowUtc $script:baseNow

        $stored.BaselineWeeklyPct | Should -Be 30.5
        $empty.BaselineWeeklyPct | Should -Be 0
        $passed.BaselineWeeklyPct | Should -Be 7.5
    }

    It 'defaults the baseline done count to 0 without a passed or stored value' {
        $result = Resolve-EpicProgressBaseline -StartUtc $script:passedStart -StartUtcPassed -State $script:emptyState -NowUtc $script:baseNow

        $result.BaselineDone | Should -Be 0
        $result.BaselineWeeklyPct | Should -Be 0
        $result.UseCurrentDone | Should -BeFalse
    }
}
