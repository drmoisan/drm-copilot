# Pester tests for scripts/dev-tools/StageTiming.psm1 (issue #1097, stage B).
# Evidence texts are built in memory; only the two STR-READ- cases read the committed fixtures
# under tests/fixtures/dev-tools/stage-timing, through Read-StageTimingEvidence. No test writes a file.

BeforeAll {
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/StageTiming.psm1') -Force
    $script:fixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../fixtures/dev-tools/stage-timing'
    $script:wallClockLabel = 'Figures are wall-clock time and include queueing; they are not agent time.'
    $script:mergeLabel = 'The merge stage is not captured.'
    $script:issueNumReason = 'issue-num is missing, blank, or not a string or a positive integer'

    function Get-TestClosedEntryJson {
        # One closed entry that starts at 01:00:00Z on 2026-01-02 plus the offset and lasts Seconds.
        param([string] $Stage, [int] $Attempt, [double] $Seconds, [double] $StartOffsetSeconds = 0)
        $base = [DateTime]::new(2026, 1, 2, 1, 0, 0, [DateTimeKind]::Utc).AddSeconds($StartOffsetSeconds)
        $format = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        $culture = [System.Globalization.CultureInfo]::InvariantCulture
        $startText = $base.ToString($format, $culture)
        $endText = $base.AddSeconds($Seconds).ToString($format, $culture)
        '{{"stage":"{0}","attempt":{1},"started_at":"{2}","ended_at":"{3}"}}' -f $Stage, $Attempt, $startText, $endText
    }

    function Get-TestRawEntryJson {
        # One entry with caller-supplied raw JSON for the start and end values.
        param([string] $Stage, [int] $Attempt, [string] $StartJson, [string] $EndJson)
        '{{"stage":"{0}","attempt":{1},"started_at":{2},"ended_at":{3}}}' -f $Stage, $Attempt, $StartJson, $EndJson
    }

    function Get-TestEvidenceItem {
        param([string] $Name, [string] $Issue, [string[]] $EntryJson)
        [pscustomobject]@{
            Name = $Name
            Text = '{"issue-num":"' + $Issue + '","stage_timing":[' + ($EntryJson -join ',') + ']}'
        }
    }

    function Get-TestTextItem {
        param([string] $Name, [string] $Text)
        [pscustomobject]@{ Name = $Name; Text = $Text }
    }
}

AfterAll {
    Remove-Module -Name StageTiming -Force -ErrorAction SilentlyContinue
}

Describe 'Get-StageTimingSummary totals and medians' {
    It 'STR-TOTAL-SUMS-ATTEMPTS-PER-ISSUE-STAGE' {
        # Two closed attempts of one stage in one issue add up to one total and one attempt count of two.
        $item = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @(
            (Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 600),
            (Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 2 -Seconds 300 -StartOffsetSeconds 3600)
        )

        $summary = Get-StageTimingSummary -Evidence @($item)

        @($summary.Issues).Count | Should -Be 1
        $summary.Issues[0].Issue | Should -Be '9001'
        $summary.Issues[0].Stage | Should -Be 'S5_x'
        $summary.Issues[0].Attempts | Should -Be 2
        $summary.Issues[0].OpenCount | Should -Be 0
        $summary.Issues[0].TotalSeconds | Should -Be 900
    }

    It 'STR-MEDIAN-ACROSS-ISSUES-ODD' {
        # Three issues with totals 100, 300, and 200 give the middle value.
        $items = @(
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 100))),
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-01.json' -Issue '9002' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 300))),
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-02.json' -Issue '9003' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 200)))
        )

        $summary = Get-StageTimingSummary -Evidence $items

        @($summary.Stages).Count | Should -Be 1
        $summary.Stages[0].IssueCount | Should -Be 3
        $summary.Stages[0].MedianSeconds | Should -Be 200
    }

    It 'STR-MEDIAN-ACROSS-ISSUES-EVEN' {
        # Two issues with totals 100 and 400 average to 250.
        $items = @(
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 100))),
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-01.json' -Issue '9002' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 400)))
        )

        $summary = Get-StageTimingSummary -Evidence $items

        $summary.Stages[0].IssueCount | Should -Be 2
        $summary.Stages[0].MedianSeconds | Should -Be 250
    }

    It 'STR-OPEN-ENTRY-COUNTED-NOT-TOTALLED' {
        # An open entry adds to the attempt and open counts but not to the total; an issue that holds
        # only an open entry for a stage does not enter that stage's median.
        $mixed = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @(
            (Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 60),
            (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 2 -StartJson '"2026-01-02T05:00:00Z"' -EndJson 'null')
        )
        $openOnly = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-01.json' -Issue '9002' -EntryJson @(
            (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 1 -StartJson '"2026-01-02T05:00:00Z"' -EndJson 'null')
        )

        $summary = Get-StageTimingSummary -Evidence @($mixed, $openOnly)

        $first = @($summary.Issues | Where-Object { $_.Issue -eq '9001' })[0]
        $first.Attempts | Should -Be 2
        $first.OpenCount | Should -Be 1
        $first.TotalSeconds | Should -Be 60
        $second = @($summary.Issues | Where-Object { $_.Issue -eq '9002' })[0]
        $second.OpenCount | Should -Be 1
        $second.TotalSeconds | Should -Be 0
        $summary.Stages[0].IssueCount | Should -Be 1
        $summary.Stages[0].MedianSeconds | Should -Be 60
    }

    It 'STR-GREATEST-FILE-NAME-WINS-PER-ISSUE' {
        # Two files for one issue: only the file with the greater name counts, whatever the input order.
        $older = Get-TestEvidenceItem -Name 'a/stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 100))
        $newer = Get-TestEvidenceItem -Name 'b/stage-timing.2026-01-03T00-00.json' -Issue '9001' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 200))

        $forward = Get-StageTimingSummary -Evidence @($older, $newer)
        $reverse = Get-StageTimingSummary -Evidence @($newer, $older)

        @($forward.Issues).Count | Should -Be 1
        $forward.Issues[0].TotalSeconds | Should -Be 200
        @($reverse.Issues).Count | Should -Be 1
        $reverse.Issues[0].TotalSeconds | Should -Be 200
    }

    It 'STR-OFFSET-AND-Z-FORMS-GIVE-EQUAL-DURATION' {
        # The same ten minutes written with Z and with a +02:00 offset give equal durations.
        $zulu = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @(
            (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 1 -StartJson '"2026-01-02T01:00:00Z"' -EndJson '"2026-01-02T01:10:00Z"')
        )
        $offset = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-01.json' -Issue '9002' -EntryJson @(
            (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 1 -StartJson '"2026-01-02T03:00:00+02:00"' -EndJson '"2026-01-02T03:10:00+02:00"')
        )

        $summary = Get-StageTimingSummary -Evidence @($zulu, $offset)

        $summary.Issues[0].TotalSeconds | Should -Be 600
        $summary.Issues[1].TotalSeconds | Should -Be 600
    }

    It 'STR-STAGE-ORDER-BY-EARLIEST-START' {
        # S5 starts before S10, so it prints first although ordinal order places S10 first; two stages
        # with an equal earliest start fall back to ordinal order.
        $item = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @(
            (Get-TestClosedEntryJson -Stage 'S10_late' -Attempt 1 -Seconds 60 -StartOffsetSeconds 7200),
            (Get-TestClosedEntryJson -Stage 'S5_early' -Attempt 1 -Seconds 60),
            (Get-TestClosedEntryJson -Stage 'S7_b' -Attempt 1 -Seconds 60 -StartOffsetSeconds 3600),
            (Get-TestClosedEntryJson -Stage 'S7_a' -Attempt 1 -Seconds 60 -StartOffsetSeconds 3600)
        )

        $summary = Get-StageTimingSummary -Evidence @($item)

        (@($summary.Stages | ForEach-Object { $_.Stage }) -join ',') | Should -Be 'S5_early,S7_a,S7_b,S10_late'
        (@($summary.Issues | ForEach-Object { $_.Stage }) -join ',') | Should -Be 'S5_early,S7_a,S7_b,S10_late'
    }

    It 'STR-EMPTY-EVIDENCE-YIELDS-EMPTY-SUMMARY' {
        $summary = Get-StageTimingSummary -Evidence @()

        @($summary.Issues).Count | Should -Be 0
        @($summary.Stages).Count | Should -Be 0
        @($summary.SkippedFiles).Count | Should -Be 0
        @($summary.SkippedEntries).Count | Should -Be 0
    }
}

Describe 'Get-StageTimingSummary skips what it cannot read' {
    It 'STR-NEGATIVE-DURATION-ENTRY-SKIPPED' {
        # An ended_at before its started_at is skipped with a reason and is not counted as an attempt.
        $item = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @(
            (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 1 -StartJson '"2026-01-02T02:00:00Z"' -EndJson '"2026-01-02T01:00:00Z"'),
            (Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 2 -Seconds 60)
        )

        $summary = Get-StageTimingSummary -Evidence @($item)

        @($summary.SkippedEntries).Count | Should -Be 1
        $summary.SkippedEntries[0].Issue | Should -Be '9001'
        $summary.SkippedEntries[0].Stage | Should -Be 'S5_x'
        $summary.SkippedEntries[0].Reason | Should -BeLike '*before*'
        $summary.Issues[0].Attempts | Should -Be 1
        $summary.Issues[0].TotalSeconds | Should -Be 60
    }

    It 'STR-UNPARSABLE-TIME-ENTRY-SKIPPED' {
        # An unparsable started_at, an unparsable ended_at, a blank stage, a bad attempt, a missing
        # ended_at, and a non-object entry are each skipped with a reason.
        $text = '{"issue-num":"9001","stage_timing":[' + (@(
                (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 1 -StartJson '"yesterday"' -EndJson 'null'),
                (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 2 -StartJson '"2026-01-02T01:00:00Z"' -EndJson '"tomorrow"'),
                (Get-TestRawEntryJson -Stage ' ' -Attempt 3 -StartJson '"2026-01-02T01:00:00Z"' -EndJson 'null'),
                (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 0 -StartJson '"2026-01-02T01:00:00Z"' -EndJson 'null'),
                '{"stage":"S5_x","attempt":5,"started_at":"2026-01-02T01:00:00Z"}',
                '7'
            ) -join ',') + ']}'

        $summary = Get-StageTimingSummary -Evidence @((Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text $text))

        @($summary.SkippedEntries).Count | Should -Be 6
        @($summary.Issues).Count | Should -Be 0
        $reasons = @($summary.SkippedEntries | ForEach-Object { $_.Reason })
        $reasons | Should -Contain 'started_at is not an ISO-8601 time'
        $reasons | Should -Contain 'ended_at is not an ISO-8601 time'
        $reasons | Should -Contain 'stage is missing or blank'
        $reasons | Should -Contain 'attempt is not an integer of 1 or more'
        $reasons | Should -Contain 'ended_at is missing'
        $reasons | Should -Contain 'the entry is not an object'
    }

    It 'STR-MALFORMED-JSON-FILE-SKIPPED' {
        $summary = Get-StageTimingSummary -Evidence @(
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text '{oops'),
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-01.json' -Text '[1,2]'),
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-02.json' -Text 'null')
        )

        @($summary.SkippedFiles).Count | Should -Be 3
        $summary.SkippedFiles[0].Name | Should -Be 'stage-timing.2026-01-02T00-00.json'
        $summary.SkippedFiles[0].Reason | Should -BeLike 'not valid JSON*'
        $summary.SkippedFiles[1].Reason | Should -Be 'the JSON root is not an object'
        $summary.SkippedFiles[2].Reason | Should -Be 'the JSON root is not an object'
        @($summary.Issues).Count | Should -Be 0
    }

    It 'STR-BLANK-ISSUE-FILE-SKIPPED' {
        $summary = Get-StageTimingSummary -Evidence @(
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text '{"issue-num":"  ","stage_timing":[]}'),
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-01.json' -Text '{"stage_timing":[]}')
        )

        @($summary.SkippedFiles).Count | Should -Be 2
        $summary.SkippedFiles[0].Reason | Should -Be $script:issueNumReason
        $summary.SkippedFiles[1].Reason | Should -Be $script:issueNumReason
    }

    It 'STR-INTEGER-ISSUE-NUM-READ-AS-STRING-ISSUE' {
        # An integer issue-num reads as its decimal string, and a string file and an integer file for
        # one issue select as one issue (the greater file name wins).
        $entry = Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 60
        $integerOnly = Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text ('{"issue-num":9001,"stage_timing":[' + $entry + ']}')
        $older = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-01.json' -Issue '9002' -EntryJson @($entry)
        $newer = Get-TestTextItem -Name 'stage-timing.2026-01-02T00-02.json' -Text ('{"issue-num":9002,"stage_timing":[' + $entry + ',' + (Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 2 -Seconds 30 -StartOffsetSeconds 600) + ']}')

        $single = Get-StageTimingSummary -Evidence @($integerOnly)
        $mixed = Get-StageTimingSummary -Evidence @($older, $newer)

        @($single.SkippedFiles).Count | Should -Be 0
        $single.Issues[0].Issue | Should -Be '9001'
        @($mixed.Issues).Count | Should -Be 1
        $mixed.Issues[0].Issue | Should -Be '9002'
        $mixed.Issues[0].Attempts | Should -Be 2
    }

    It 'STR-NON-POSITIVE-OR-FRACTIONAL-ISSUE-NUM-SKIPPED' -ForEach @(
        @{ Json = '0' },
        @{ Json = '-3' },
        @{ Json = '1.5' },
        @{ Json = 'true' }
    ) {
        $summary = Get-StageTimingSummary -Evidence @(
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text ('{"issue-num":' + $Json + ',"stage_timing":[]}'))
        )

        @($summary.SkippedFiles).Count | Should -Be 1
        $summary.SkippedFiles[0].Reason | Should -Be $script:issueNumReason
        @($summary.Issues).Count | Should -Be 0
    }

    It 'STR-MISSING-STARTED-AT-ENTRY-SKIPPED' {
        $text = '{"issue-num":"9001","stage_timing":[{"stage":"S5_x","attempt":1,"ended_at":null}]}'

        $summary = Get-StageTimingSummary -Evidence @((Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text $text))

        @($summary.SkippedEntries).Count | Should -Be 1
        $summary.SkippedEntries[0].Stage | Should -Be 'S5_x'
        $summary.SkippedEntries[0].Reason | Should -Be 'started_at is not an ISO-8601 time'
    }

    It 'STR-MISSING-STAGE-OR-ATTEMPT-ENTRY-SKIPPED' {
        # An entry with no stage key and an entry with no attempt key are each skipped with their reason.
        $text = '{"issue-num":"9001","stage_timing":[' +
        '{"attempt":1,"started_at":"2026-01-02T01:00:00Z","ended_at":null},' +
        '{"stage":"S5_x","started_at":"2026-01-02T01:00:00Z","ended_at":null}]}'

        $summary = Get-StageTimingSummary -Evidence @((Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text $text))

        @($summary.SkippedEntries).Count | Should -Be 2
        $summary.SkippedEntries[0].Reason | Should -Be 'stage is missing or blank'
        $summary.SkippedEntries[1].Reason | Should -Be 'attempt is not an integer of 1 or more'
        @($summary.Issues).Count | Should -Be 0
    }

    It 'STR-STAGE-WITH-ONLY-OPEN-ENTRIES-ABSENT-FROM-MEDIANS' {
        # A stage whose entries are all open is listed under Issues but has no median.
        $item = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @(
            (Get-TestRawEntryJson -Stage 'S5_x' -Attempt 1 -StartJson '"2026-01-02T05:00:00Z"' -EndJson 'null')
        )

        $summary = Get-StageTimingSummary -Evidence @($item)

        @($summary.Issues).Count | Should -Be 1
        $summary.Issues[0].OpenCount | Should -Be $summary.Issues[0].Attempts
        @($summary.Stages).Count | Should -Be 0
    }

    It 'STR-ISSUE-ROWS-ORDER-SHORTER-ID-FIRST' {
        # Issue 99 sorts before issue 100 although ordinal order places 100 first, whatever the input order.
        $short = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '99' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 60))
        $long = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-01.json' -Issue '100' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 60))

        $forward = Get-StageTimingSummary -Evidence @($short, $long)
        $reverse = Get-StageTimingSummary -Evidence @($long, $short)

        (@($forward.Issues | ForEach-Object { $_.Issue }) -join ',') | Should -Be '99,100'
        (@($reverse.Issues | ForEach-Object { $_.Issue }) -join ',') | Should -Be '99,100'
    }

    It 'STR-STAGE-TIMING-NOT-A-LIST-SKIPPED' {
        $summary = Get-StageTimingSummary -Evidence @(
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-00.json' -Text '{"issue-num":"9001","stage_timing":"none"}'),
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-01.json' -Text '{"issue-num":"9002","stage_timing":{"stage":"S5_x"}}'),
            (Get-TestTextItem -Name 'stage-timing.2026-01-02T00-02.json' -Text '{"issue-num":"9003"}')
        )

        @($summary.SkippedFiles).Count | Should -Be 3
        foreach ($skipped in $summary.SkippedFiles) {
            $skipped.Reason | Should -Be 'stage_timing is not a list'
        }
    }
}

Describe 'Format-StageTimingReport' {
    It 'STR-FORMAT-STATES-WALL-CLOCK-INCLUDING-QUEUEING' {
        $item = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 60))

        $lines = Format-StageTimingReport -Summary (Get-StageTimingSummary -Evidence @($item))

        $lines[0] | Should -Be $script:wallClockLabel
    }

    It 'STR-FORMAT-STATES-MERGE-STAGE-NOT-CAPTURED' {
        $item = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 60))

        $lines = Format-StageTimingReport -Summary (Get-StageTimingSummary -Evidence @($item))

        $lines[1] | Should -Be $script:mergeLabel
    }

    It 'STR-FORMAT-LABELS-PRESENT-WITHOUT-DATA' {
        $lines = Format-StageTimingReport -Summary (Get-StageTimingSummary -Evidence @())

        $lines | Should -Contain $script:wallClockLabel
        $lines | Should -Contain $script:mergeLabel
        $lines | Should -Contain 'No stage timing evidence was found.'
    }

    It 'STR-FORMAT-LISTS-SKIPPED-FILES-AND-ENTRIES' {
        $item = Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @(
            (Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 60),
            (Get-TestRawEntryJson -Stage 'S6_y' -Attempt 1 -StartJson '"never"' -EndJson 'null')
        )
        $broken = Get-TestTextItem -Name 'stage-timing.2026-01-02T00-01.json' -Text '[1]'

        $lines = Format-StageTimingReport -Summary (Get-StageTimingSummary -Evidence @($item, $broken))

        $lines | Should -Contain 'Skipped files'
        $lines | Should -Contain '  stage-timing.2026-01-02T00-01.json: the JSON root is not an object'
        $lines | Should -Contain 'Skipped entries'
        $lines | Should -Contain "  Issue 9001, stage 'S6_y': started_at is not an ISO-8601 time"
    }

    It 'STR-FORMAT-RENDERS-HOURS-MINUTES-SECONDS' {
        # 3725 seconds is 1:02:05, 600 is 0:10:00, and 90000 is 25:00:00.
        $items = @(
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-00.json' -Issue '9001' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 3725))),
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-01.json' -Issue '9002' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 600))),
            (Get-TestEvidenceItem -Name 'stage-timing.2026-01-02T00-02.json' -Issue '9003' -EntryJson @((Get-TestClosedEntryJson -Stage 'S5_x' -Attempt 1 -Seconds 90000)))
        )

        $lines = Format-StageTimingReport -Summary (Get-StageTimingSummary -Evidence $items)

        $lines | Should -Contain '  Issue 9001, S5_x: 1 attempt(s), 0 open, total 1:02:05'
        $lines | Should -Contain '  Issue 9002, S5_x: 1 attempt(s), 0 open, total 0:10:00'
        $lines | Should -Contain '  Issue 9003, S5_x: 1 attempt(s), 0 open, total 25:00:00'
        $lines | Should -Contain '  S5_x: 3 issue(s), median 1:02:05'
    }
}

Describe 'Read-StageTimingEvidence' {
    It 'STR-READ-RETURNS-NAMED-FILES-IN-ORDER' {
        $evidence = @(Read-StageTimingEvidence -Root $script:fixtureRoot)

        $evidence.Count | Should -Be 2
        $evidence[0].Name | Should -Be 'stage-timing.2026-01-02T03-04.json'
        $evidence[1].Name | Should -Be 'stage-timing.2026-01-03T03-04.json'
        $evidence[0].Text | Should -BeLike '*"issue-num": "9001"*'
        $evidence[1].Text | Should -BeLike '*"issue-num": "9002"*'
    }

    It 'STR-READ-THROWS-ON-MISSING-ROOT' {
        $missing = Join-Path -Path $script:fixtureRoot -ChildPath 'no-such-folder'

        { Read-StageTimingEvidence -Root $missing } | Should -Throw '*not found*'
    }
}
