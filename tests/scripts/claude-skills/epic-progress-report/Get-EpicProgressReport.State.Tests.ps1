# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1 (issues #1080, #1093, #1118).
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
        # The issue #1080 tool wrote a bare JSON array of task-count samples with no baseline;
        # issue #1118 discards those samples and marks the state migrated.
        $state = ConvertFrom-EpicProgressStateText -Text '[{"ts":1000,"done":3},{"ts":1600,"done":5}]'

        $state.Samples.Count | Should -Be 0
        $state.Migrated | Should -BeTrue
        $state.StartUnixSeconds | Should -BeNullOrEmpty
        $state.BaselineDone | Should -BeNullOrEmpty
        $state.BaselineWeeklyPct | Should -BeNullOrEmpty
    }

    It 'reads a version-1 document' {
        # The start and the weekly baseline are kept; the task-count samples and baseline are discarded.
        $text = '{"version":1,"startUnixSeconds":1767603600,"baselineDone":7,"baselineWeeklyPct":12.5,"samples":[{"ts":1767614400,"done":9}]}'

        $state = ConvertFrom-EpicProgressStateText -Text $text

        $state.StartUnixSeconds | Should -Be 1767603600
        $state.BaselineWeeklyPct | Should -Be 12.5
        $state.BaselineDone | Should -BeNullOrEmpty
        $state.Samples.Count | Should -Be 0
        $state.Migrated | Should -BeTrue
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
        $state = ConvertFrom-EpicProgressStateText -Text '{"version":3,"startUnixSeconds":1767603600,"baselineDone":7,"samples":[{"ts":1000,"done":1}]}'

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

        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds 1767603600 -BaselineDone 1 -BaselineWeeklyPct 0 -Sample $samples -Duration @{} -Item @{}
        $state = ConvertFrom-EpicProgressStateText -Text $json
        $raw = ConvertFrom-Json -InputObject $json

        $raw.version | Should -Be 2
        $raw.unit | Should -Be 'steps'
        $raw.startUnixSeconds | Should -BeOfType [long]
        $raw.samples[0].ts | Should -BeOfType [long]
        $json | Should -Not -Match '"ts":\s*"'
        $state.StartUnixSeconds | Should -Be 1767603600
        $state.BaselineDone | Should -Be 1
        $state.BaselineWeeklyPct | Should -Be 0
        $state.Migrated | Should -BeFalse
        ($state.Samples.ts -join ',') | Should -Be '1767610800,1767614400'
        ($state.Samples.done -join ',') | Should -Be '2,3'
    }

    It 'writes a single sample as an array and skips samples without ts' {
        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds 1 -BaselineDone 0 -BaselineWeeklyPct 0 -Sample @([pscustomobject]@{ done = 1 }, [pscustomobject]@{ ts = 5; done = 2 }) -Duration @{} -Item @{}

        $json | Should -Match '"samples":\s*\['
        (ConvertFrom-EpicProgressStateText -Text $json).Samples.Count | Should -Be 1
    }

    It 'reads a version-2 document with durations and items' {
        $text = '{"version":2,"unit":"steps","startUnixSeconds":1767603600,"baselineDone":4,"baselineWeeklyPct":10,' +
        '"samples":[{"ts":1767614400,"done":12}],' +
        '"durations":{"review":[{"key":"12|review|1","type":"review","seconds":780,"source":"stage_timing","approx":false,"recorded":1767614400}]},' +
        '"items":{"12":{"plans":{"plan.md":{"checked":["P0-T1","P1-T2"],"lastTickUnixSeconds":1767614400}},"blockedSinceUnixSeconds":1767610000},' +
        '"77":{"plans":{"plan.md":{"checked":[],"lastTickUnixSeconds":1767600000}},"blockedSinceUnixSeconds":null}}}'

        $state = ConvertFrom-EpicProgressStateText -Text $text

        $state.Migrated | Should -BeFalse
        $state.BaselineDone | Should -Be 4
        $state.Samples[0].done | Should -Be 12
        $state.Durations['review'].Count | Should -Be 1
        $state.Durations['review'][0].seconds | Should -Be 780
        ($state.Items['12'].Plans['plan.md'].Checked -join ',') | Should -Be 'P0-T1,P1-T2'
        $state.Items['12'].Plans['plan.md'].LastTickUnixSeconds | Should -Be 1767614400
        $state.Items['12'].BlockedSinceUnixSeconds | Should -Be 1767610000
        $state.Items['77'].Plans['plan.md'].Checked.Count | Should -Be 0
        $state.Items['77'].BlockedSinceUnixSeconds | Should -BeNullOrEmpty
    }

    It 'migrates a version-1 document to the current step count' {
        # The migrated state resolves its baseline to the current done count, and the next write is version 2.
        $state = ConvertFrom-EpicProgressStateText -Text '{"version":1,"startUnixSeconds":1767603600,"baselineDone":7,"baselineWeeklyPct":12.5,"samples":[{"ts":1767614400,"done":9}]}'
        $baseline = Resolve-EpicProgressBaseline -State $state -NowUtc ([datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc))

        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds $state.StartUnixSeconds -BaselineDone 21 -BaselineWeeklyPct $baseline.BaselineWeeklyPct -Sample @() -Duration $state.Durations -Item $state.Items
        $raw = ConvertFrom-Json -InputObject $json

        $baseline.UseCurrentDone | Should -BeTrue
        $baseline.BaselineWeeklyPct | Should -Be 12.5
        $state.Durations.Count | Should -Be 0
        $state.Items.Count | Should -Be 0
        $raw.version | Should -Be 2
        $raw.unit | Should -Be 'steps'
        $raw.startUnixSeconds | Should -Be 1767603600
        $raw.baselineDone | Should -Be 21
    }

    It 'migrates the legacy sample array' {
        $state = ConvertFrom-EpicProgressStateText -Text '[{"ts":1000,"done":3}]'
        $baseline = Resolve-EpicProgressBaseline -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)) -StartUtcPassed -State $state -NowUtc ([datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc))

        $state.Migrated | Should -BeTrue
        $state.Samples.Count | Should -Be 0
        $state.Durations.Count | Should -Be 0
        $baseline.UseCurrentDone | Should -BeTrue
    }

    It 'treats version 3 as empty state' {
        $state = ConvertFrom-EpicProgressStateText -Text '{"version":3,"durations":{"review":[{"key":"k","seconds":1}]},"items":{"12":{}}}'

        $state.Migrated | Should -BeFalse
        $state.Durations.Count | Should -Be 0
        $state.Items.Count | Should -Be 0
        $state.Samples.Count | Should -Be 0
    }

    It 'writes version 2 with unit steps' {
        $item = @{ '12' = [pscustomobject]@{ Plans = @{ 'plan.md' = [pscustomobject]@{ Checked = [string[]] @('P0-T1'); LastTickUnixSeconds = 1767614400 } }; BlockedSinceUnixSeconds = $null } }

        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds 1767603600 -BaselineDone 0 -BaselineWeeklyPct 0 -Sample @() -Duration @{} -Item $item
        $raw = ConvertFrom-Json -InputObject $json

        $raw.version | Should -Be 2
        $raw.unit | Should -Be 'steps'
        $json | Should -Match '"checked":\s*\[\s*"P0-T1"\s*\]'
        $raw.items.'12'.plans.'plan.md'.lastTickUnixSeconds | Should -Be 1767614400
        $raw.items.'12'.blockedSinceUnixSeconds | Should -BeNullOrEmpty
    }

    It 'writes durations beyond the sample cap' {
        # Twenty review samples are written although the default check-in cap is 14.
        $duration = @{ review = @(1..20 | ForEach-Object { Get-EpicProgressDurationSample -Key "12|review|$_" -Type 'review' -Seconds (60 * $_) -Source 'stage_timing' -Recorded $_ }) }

        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds 1 -BaselineDone 0 -BaselineWeeklyPct 0 -Sample @() -Duration $duration
        $state = ConvertFrom-EpicProgressStateText -Text $json

        $state.Durations['review'].Count | Should -Be 20
        $state.Durations['review'][19].key | Should -Be '12|review|20'
        $state.Durations['review'][19].seconds | Should -Be 1200
    }
}

Describe 'Resolve-EpicProgressItemSetting' {
    It 'defaults the item state path from the issue number' {
        $setting = Resolve-EpicProgressItemSetting -Issue 1118 -CurrentLocation '/fixture-repo'
        $explicit = Resolve-EpicProgressItemSetting -Issue 1118 -RepositoryRoot '/other-repo' -StatePath '/other-temp/item.json' -CurrentLocation '/fixture-repo'

        $setting.StatePath | Should -Be (Join-Path -Path '/fixture-repo' -ChildPath '.claude' -AdditionalChildPath 'state', 'progress-item-1118.json')
        $setting.RepositoryRoot | Should -Be '/fixture-repo'
        $setting.Issue | Should -Be '1118'
        $explicit.StatePath | Should -Be '/other-temp/item.json'
        $explicit.RepositoryRoot | Should -Be '/other-repo'
    }
}

Describe 'Resolve-EpicProgressBaseline after migration' {
    It 'resolves the baseline to the current done count after migration' {
        $now = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)
        $migrated = [pscustomobject]@{ StartUnixSeconds = [long] 1767600000; BaselineDone = $null; BaselineWeeklyPct = 5.0; Samples = [object[]] @(); Migrated = $true }

        $resolved = Resolve-EpicProgressBaseline -State $migrated -NowUtc $now
        $passed = Resolve-EpicProgressBaseline -BaselineDone 3 -BaselineDonePassed -State $migrated -NowUtc $now

        $resolved.UseCurrentDone | Should -BeTrue
        $resolved.BaselineWeeklyPct | Should -Be 5
        $passed.UseCurrentDone | Should -BeFalse
        $passed.BaselineDone | Should -Be 3
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

Describe 'Merge-EpicProgressSamplePair' {
    BeforeAll {
        function Get-TestSampleSet {
            # Samples s0..s(n-1) with ts = 300 * index and done = index, in chronological order.
            param([int] $Count)
            $set = [System.Collections.Generic.List[object]]::new()
            for ($index = 0; $index -lt $Count; $index++) { $set.Add([pscustomobject]@{ ts = 300 * $index; done = $index }) }
            , [object[]] $set.ToArray()
        }
    }

    It 'keeps s13, s11, s9, s7, s5, s3 and s1 of 14 samples' {
        $merged = @(Merge-EpicProgressSamplePair -Sample (Get-TestSampleSet -Count 14))

        $merged.Count | Should -Be 7
        ($merged.done -join ',') | Should -Be '1,3,5,7,9,11,13'
    }

    It 'reduces 13 samples to 7' {
        $merged = @(Merge-EpicProgressSamplePair -Sample (Get-TestSampleSet -Count 13))

        $merged.Count | Should -Be 7
        ($merged.done -join ',') | Should -Be '0,2,4,6,8,10,12'
    }

    It 'reduces 2 samples to 1' {
        $merged = @(Merge-EpicProgressSamplePair -Sample (Get-TestSampleSet -Count 2))

        $merged.Count | Should -Be 1
        $merged[0].done | Should -Be 1
    }

    It 'leaves 1 and 0 samples unchanged' {
        $one = @(Merge-EpicProgressSamplePair -Sample (Get-TestSampleSet -Count 1))
        $none = @(Merge-EpicProgressSamplePair -Sample @())

        $one.Count | Should -Be 1
        $one[0].done | Should -Be 0
        $none.Count | Should -Be 0
    }

    It 'leaves 4 samples after two applications to 14' {
        $once = @(Merge-EpicProgressSamplePair -Sample (Get-TestSampleSet -Count 14))
        $twice = @(Merge-EpicProgressSamplePair -Sample $once)

        $twice.Count | Should -Be 4
        ($twice.done -join ',') | Should -Be '1,5,9,13'
    }

    It 'reproduces the recorded 5-minute to 10-minute example' {
        # The 14 recorded samples of the research (offsets in seconds from a fixed base epoch, done counts).
        $baseEpoch = 1767571200
        $offsets = @(0, 286, 572, 856, 1144, 1428, 1714, 1999, 2282, 2568, 2854, 3139, 3424, 3716)
        $doneCounts = @(131, 132, 140, 141, 142, 144, 145, 145, 147, 154, 155, 156, 158, 158)
        $recorded = [System.Collections.Generic.List[object]]::new()
        for ($index = 0; $index -lt $offsets.Count; $index++) { $recorded.Add([pscustomobject]@{ ts = $baseEpoch + $offsets[$index]; done = $doneCounts[$index] }) }

        [double[]] $before = @(Get-EpicProgressRecentVelocityInterval -Sample $recorded.ToArray())
        [double[]] $after = @(Get-EpicProgressRecentVelocityInterval -Sample @(Merge-EpicProgressSamplePair -Sample $recorded.ToArray()))
        $meanBefore = ($before | Measure-Object -Average).Average
        $meanAfter = ($after | Measure-Object -Average).Average
        $deviationBefore = Get-EpicProgressStandardDeviation -Interval $before
        $deviationAfter = Get-EpicProgressStandardDeviation -Interval $after

        $before.Count | Should -Be 13
        $after.Count | Should -Be 6
        [math]::Abs($meanBefore - 26.1875) | Should -BeLessThan 0.001
        [math]::Abs($deviationBefore - 31.4495) | Should -BeLessThan 0.001
        [math]::Abs($meanAfter - 27.3430) | Should -BeLessThan 0.001
        [math]::Abs($deviationAfter - 23.2316) | Should -BeLessThan 0.001
        Format-EpicProgressNumber -Value $meanBefore -Digits 1 | Should -Be '26.2'
        Format-EpicProgressNumber -Value $deviationBefore -Digits 1 | Should -Be '31.4'
        Format-EpicProgressNumber -Value $meanAfter -Digits 1 | Should -Be '27.3'
        Format-EpicProgressNumber -Value $deviationAfter -Digits 1 | Should -Be '23.2'
    }
}
