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
