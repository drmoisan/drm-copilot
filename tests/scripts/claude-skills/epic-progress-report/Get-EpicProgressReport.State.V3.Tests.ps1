# Pester tests for the version-3 state document of
# .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1 (issue #1153, decision E12).
# The Logic hub is dot-sourced, which dot-sources the State file; every function under test is pure,
# so each test supplies fixed in-memory JSON text or records and asserts the returned data.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath

    # 2026-01-05T12:00:00Z; the stored start 1767600000 is 2026-01-05T08:00:00Z.
    $script:now = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)
    $script:v2Text = '{"version":2,"unit":"steps","startUnixSeconds":1767600000,"baselineDone":4,"baselineWeeklyPct":10,' +
    '"samples":[{"ts":1767610000,"done":5},{"ts":1767611200,"done":7}],' +
    '"durations":{"review":[{"key":"12|review|1","type":"review","seconds":780,"source":"stage_timing","approx":false,"recorded":1767611200}]},' +
    '"items":{"12":{"plans":{"plan.md":{"checked":["P0-T1"],"lastTickUnixSeconds":1767611200}},"blockedSinceUnixSeconds":null}}}'

    function Get-TestV3Json {
        # A version-3 document written by the writer: two samples with task counts, one pause span, a ledger, and an anchor.
        $samples = @(
            [pscustomobject]@{ ts = 1767610000; done = 5; tasks = 20; features = @{ '12' = 8; '13' = 12 } }
            [pscustomobject]@{ ts = 1767611200; done = 7; tasks = 23; features = @{ '12' = 10; '13' = 13 } }
        )
        $duration = @{ execution = @(Get-EpicProgressDurationSample -Key '12|exec|plan.md|P1-T1' -Type 'execution' -Seconds 300 -Source 'tick' -Recorded 1767611200) }
        $item = @{ '12' = [pscustomobject]@{ Plans = @{ 'plan.md' = [pscustomobject]@{ Checked = [string[]] @('P1-T1'); LastTickUnixSeconds = 1767611200 } }; BlockedSinceUnixSeconds = $null } }
        $pauses = @([pscustomobject]@{ startUnixSeconds = 1767603000; endUnixSeconds = 1767607000 })
        ConvertTo-EpicProgressStateJson -StartUnixSeconds 1767600000 -BaselineDone 4 -BaselineWeeklyPct 10 -Sample $samples -Duration $duration -Item $item -BaselineDoneTasks 15 -PauseSpan $pauses
    }
}

Describe 'ConvertTo-EpicProgressStateJson version 3 (AC-41)' {
    It 'writes version 3 with the task baseline, task samples, and pauses' {
        $raw = ConvertFrom-Json -InputObject (Get-TestV3Json)

        $raw.version | Should -Be 3
        $raw.startUnixSeconds | Should -Be 1767600000
        $raw.baselineDone | Should -Be 4
        $raw.baselineWeeklyPct | Should -Be 10
        $raw.baselineDoneTasks | Should -Be 15
        $raw.samples.Count | Should -Be 2
        $raw.samples[1].ts | Should -Be 1767611200
        $raw.samples[1].done | Should -Be 7
        $raw.samples[1].tasks | Should -Be 23
        $raw.samples[1].features.'12' | Should -Be 10
        $raw.samples[1].features.'13' | Should -Be 13
        $raw.durations.execution[0].key | Should -Be '12|exec|plan.md|P1-T1'
        $raw.items.'12'.plans.'plan.md'.lastTickUnixSeconds | Should -Be 1767611200
        $raw.pauses.Count | Should -Be 1
        $raw.pauses[0].startUnixSeconds | Should -Be 1767603000
        $raw.pauses[0].endUnixSeconds | Should -Be 1767607000
    }

    It 'writes the features of a sample given as an object, sorted by issue' {
        # A features value that is an object (not a hashtable) is written property by property, sorted by name.
        $sample = [pscustomobject]@{ ts = 5; done = 2; tasks = 7; features = [pscustomobject]@{ '77' = 3; '12' = 4 } }

        $written = ConvertFrom-Json -InputObject (ConvertTo-EpicProgressStateJson -StartUnixSeconds 1 -BaselineDone 0 -BaselineWeeklyPct 0 -Sample @($sample))

        @($written.samples[0].features.PSObject.Properties.Name) | Should -Be @('12', '77')
        $written.samples[0].features.'12' | Should -Be 4
        $written.samples[0].features.'77' | Should -Be 3
    }

    It 'writes no tasks or features on a sample that carries none' {
        $json = ConvertTo-EpicProgressStateJson -StartUnixSeconds 1 -BaselineDone 0 -BaselineWeeklyPct 0 -Sample @([pscustomobject]@{ ts = 5; done = 2 })
        $raw = ConvertFrom-Json -InputObject $json

        $raw.samples[0].PSObject.Properties.Name | Should -Not -Contain 'tasks'
        $raw.samples[0].PSObject.Properties.Name | Should -Not -Contain 'features'
        $raw.baselineDoneTasks | Should -BeNullOrEmpty
    }
}

Describe 'Version-2 migration (AC-42)' {
    It 'keeps the baselines, ledger, anchors, and samples and starts pauses empty' {
        $state = ConvertFrom-EpicProgressStateText -Text $script:v2Text

        $state.MigratedFrom | Should -Be '2'
        $state.StartUnixSeconds | Should -Be 1767600000
        $state.BaselineWeeklyPct | Should -Be 10
        $state.BaselineDone | Should -Be 4
        $state.Durations['review'][0].seconds | Should -Be 780
        $state.Items['12'].Plans['plan.md'].Checked | Should -Be @('P0-T1')
        $state.Pauses.Count | Should -Be 0
        $state.BaselineDoneTasks | Should -BeNullOrEmpty
        $state.Samples.Count | Should -Be 2
        @($state.Samples | ForEach-Object { $_.ts }) | Should -Be @(1767610000, 1767611200)
        @($state.Samples | ForEach-Object { $_.done }) | Should -Be @(5, 7)
        @($state.Samples | Where-Object { $_.PSObject.Properties.Name -contains 'tasks' }).Count | Should -Be 0
    }

    It 'does not reset the step baseline for version 2 but still resets it for version 1' {
        $fromTwo = Resolve-EpicProgressBaseline -State (ConvertFrom-EpicProgressStateText -Text $script:v2Text) -NowUtc $script:now
        $fromOne = Resolve-EpicProgressBaseline -State (ConvertFrom-EpicProgressStateText -Text '{"version":1,"startUnixSeconds":1767600000,"baselineDone":7}') -NowUtc $script:now

        $fromTwo.UseCurrentDone | Should -BeFalse
        $fromTwo.BaselineDone | Should -Be 4
        $fromOne.UseCurrentDone | Should -BeTrue
    }

    It 'sets UseCurrentDoneTasks for a version-2 document' {
        $resolved = Resolve-EpicProgressBaseline -State (ConvertFrom-EpicProgressStateText -Text $script:v2Text) -NowUtc $script:now

        $resolved.UseCurrentDoneTasks | Should -BeTrue
        $resolved.BaselineDoneTasks | Should -BeNullOrEmpty
    }

    It 'keeps a stored task baseline for version 3 and resets it with -ResetBaseline' {
        $state = ConvertFrom-EpicProgressStateText -Text (Get-TestV3Json)

        $kept = Resolve-EpicProgressBaseline -State $state -NowUtc $script:now
        $reset = Resolve-EpicProgressBaseline -State $state -ResetBaseline -NowUtc $script:now

        $kept.UseCurrentDoneTasks | Should -BeFalse
        $kept.BaselineDoneTasks | Should -Be 15
        $reset.UseCurrentDoneTasks | Should -BeTrue
        $reset.BaselineDoneTasks | Should -BeNullOrEmpty
    }
}

Describe 'Version-3 reading and older versions (AC-43)' {
    It 'round-trips a version-3 document unchanged' {
        $first = Get-TestV3Json
        $state = ConvertFrom-EpicProgressStateText -Text $first

        $second = ConvertTo-EpicProgressStateJson -StartUnixSeconds $state.StartUnixSeconds -BaselineDone $state.BaselineDone -BaselineWeeklyPct $state.BaselineWeeklyPct -Sample $state.Samples -Duration $state.Durations -Item $state.Items -BaselineDoneTasks $state.BaselineDoneTasks -PauseSpan $state.Pauses

        $state.MigratedFrom | Should -BeNullOrEmpty
        $state.BaselineDoneTasks | Should -Be 15
        $state.Samples[0].tasks | Should -Be 20
        $state.Samples[0].features['13'] | Should -Be 12
        $state.Pauses[0].endUnixSeconds | Should -Be 1767607000
        $second | Should -BeExactly $first
    }

    It 'migrates a version-1 document and the legacy array as before' {
        $one = ConvertFrom-EpicProgressStateText -Text '{"version":1,"startUnixSeconds":1767600000,"baselineDone":7,"baselineWeeklyPct":12.5,"samples":[{"ts":1767610000,"done":9}]}'
        $legacy = ConvertFrom-EpicProgressStateText -Text '[{"ts":1000,"done":3}]'

        $one.MigratedFrom | Should -Be '1'
        $one.StartUnixSeconds | Should -Be 1767600000
        $one.BaselineWeeklyPct | Should -Be 12.5
        $one.Samples.Count | Should -Be 0
        $legacy.MigratedFrom | Should -Be 'legacy'
        $legacy.Samples.Count | Should -Be 0
    }

    It 'reads version 4, blank text, and unparseable text as empty state' {
        foreach ($text in @('{"version":4,"startUnixSeconds":1767600000,"baselineDoneTasks":3,"pauses":[{"startUnixSeconds":1,"endUnixSeconds":2}]}', '', 'not json {')) {
            $state = ConvertFrom-EpicProgressStateText -Text $text

            $state.StartUnixSeconds | Should -BeNullOrEmpty -Because "'$text' is not a readable state document"
            $state.BaselineDoneTasks | Should -BeNullOrEmpty
            $state.Pauses.Count | Should -Be 0
            $state.Samples.Count | Should -Be 0
            $state.MigratedFrom | Should -BeNullOrEmpty
        }
    }
}

Describe 'Merge-EpicProgressSamplePair on version-3 samples (AC-44)' {
    It 'keeps the tasks and features values of each kept sample' {
        $samples = @(0..3 | ForEach-Object { [pscustomobject]@{ ts = 1200 * $_; done = $_; tasks = 10 * $_; features = @{ '12' = 5 * $_ } } })

        $paired = @(Merge-EpicProgressSamplePair -Sample $samples)

        # Indices 1 and 3 are kept.
        $paired.Count | Should -Be 2
        @($paired | ForEach-Object { $_.tasks }) | Should -Be @(10, 30)
        @($paired | ForEach-Object { $_.features['12'] }) | Should -Be @(5, 15)
    }
}
