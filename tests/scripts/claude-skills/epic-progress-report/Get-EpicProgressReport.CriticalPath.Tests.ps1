# Integration tests for the issue #1153 wiring of Invoke-EpicProgressReport in
# .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1: the Full golden from
# fixture checkpoints and a fixture epic.md (AC-55), the pause spans of -ResetBaseline and of a
# closed gap (AC-19, AC-44, E11), the conditional epic.md read (E5), the merged-ledger rate source,
# the routing-config cap, the first run after a version-2 migration (E12), -WaveOverheadHours
# (E10), and the scripts/dev-tools forwarder (AC-54). The script is dot-sourced, so the entry
# block is skipped; every I/O seam is mocked over in-memory fixtures, no test starts git, gh, or
# cswap, reads or writes a file, or reads the clock. The mock bodies read the per-test fixture
# hashtable $fixture by its plain, dynamically scoped name, because in the forwarder case they run
# while the canonical script is the current script scope (as the forwarder tests document).

BeforeAll {
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1'
    $script:forwarderPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../scripts/dev-tools/Get-EpicProgressReport.ps1'
    . $script:scriptPath -EpicFolder 'example-epic' -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc))

    $script:integration = 'origin/epic/example-epic-integration'
    $script:checkpointPath = '/fixture-repo/artifacts/orchestration/epic-orchestrator-state.json'
    $script:statePath = '/fixture-temp/epic-progress-example-epic.json'
    $script:routingPath = Join-Path -Path '/fixture-repo' -ChildPath 'config/orchestration-routing.json'
    # 2026-01-05T12:00:00Z.
    $script:nowUnix = 1767614400
    $script:kickoff = @(
        'Epic issue: #42'
        '| Issue | Title | Wave | Band | Plan |'
        '|---|---|---|---|---|'
        '| 101 | Alpha | 1 | small | docs/p1/plan.md |'
        '| 102 | Beta | 1 | small | docs/p2/plan.md |'
        '| 103 | Gamma | 2 | small | docs/p3/plan.md |'
        '| 104 | Delta | 2 | small | docs/p4/plan.md |'
    )
    # epic.md lists #103 -> #101 and a #101 -> #104 edge that the #101 checkpoint key overrides.
    $script:manifest = @(
        '---', 'epic: example-epic', 'features:'
        '  - issue_num: 101', '    feature_folder: 2026-01-01-alpha-101', '    depends_on: [104]'
        '  - issue_num: 103', '    feature_folder: 2026-01-01-gamma-103', '    depends_on: [101]'
        '---', '# Example epic'
    ) -join "`n"

    function Get-TestCheckpoint {
        # The epic checkpoint: cap 2, #101 and #102 with explicit empty lists, #104 on #101 and on the
        # #102 folder hint, and #103 with no key unless -AllKeyed gives it [101].
        param([string] $MergeStatus104 = 'not_started', [string] $CapText = '"max_parallel_features":2,', [switch] $AllKeyed)
        $row103 = '{"issue_num":103,"merge_status":"not_started"}'
        if ($AllKeyed) { $row103 = '{"issue_num":103,"merge_status":"not_started","depends_on":[101]}' }
        '{' + $CapText + '"features":[{"issue_num":101,"merge_status":"not_started","depends_on":[]},' +
        '{"issue_num":102,"merge_status":"not_started","feature_folder":"docs/features/active/2026-01-01-beta-102","depends_on":[]},' +
        $row103 + ',{"issue_num":104,"merge_status":"' + $MergeStatus104 + '","depends_on":[101,"2026-01-01-beta-102"]}]}'
    }

    function Get-TestStateText {
        # A stored state document of the given version.
        param([int] $Version = 3, [string] $Samples = '', [string] $Items = '{}', [string] $Durations = '{}', [string] $Pauses = '[]', [long] $Start = 1767603600)
        "{`"version`":$Version,`"unit`":`"steps`",`"startUnixSeconds`":$Start,`"baselineDone`":0,`"baselineDoneTasks`":0,`"baselineWeeklyPct`":0,`"samples`":[$Samples],`"durations`":$Durations,`"items`":$Items,`"pauses`":$Pauses}"
    }

    function Get-TestAnchor {
        # The #101 plan.md anchor with the given checked tasks and last tick.
        param([string] $Checked = '', [long] $LastTick, [string] $BlockedSince = 'null')
        "{`"101`":{`"plans`":{`"plan.md`":{`"checked`":[$Checked],`"lastTickUnixSeconds`":$LastTick}},`"blockedSinceUnixSeconds`":$BlockedSince}}"
    }

    function Get-TestRun {
        param([hashtable] $Extra = @{})
        $arguments = @{ EpicFolder = 'example-epic'; StartUtc = [datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc); RepositoryRoot = '/fixture-repo'; CheckpointPath = $script:checkpointPath; StatePath = $script:statePath }
        foreach ($key in $Extra.Keys) { $arguments[$key] = $Extra[$key] }
        if ($arguments.ContainsKey('NoStart')) { $arguments.Remove('NoStart'); $arguments.Remove('StartUtc') }
        @(Invoke-EpicProgressReport @arguments)
    }

    function Get-TestWritten {
        # The last state document written by the run.
        ConvertFrom-Json -InputObject $fixture.Writes[$fixture.Writes.Count - 1].Content
    }

    function Get-TestExecutionSecond {
        # The written ledger seconds of the #101 execution samples, in key order.
        $written = Get-TestWritten
        @(@($written.durations.execution) | Where-Object { $_.key -like '101|exec|*' } | Sort-Object -Property key | ForEach-Object { [double] $_.seconds })
    }
}

Describe 'Invoke-EpicProgressReport critical-path wiring (issue #1153)' {
    BeforeEach {
        $fixture = @{
            Now      = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)
            Git      = [System.Collections.Generic.List[string]]::new()
            Reads    = [System.Collections.Generic.List[string]]::new()
            Probes   = [System.Collections.Generic.List[string]]::new()
            Writes   = [System.Collections.Generic.List[object]]::new()
            Worktree = @()
            Manifest = $script:manifest
            Kickoff  = $script:kickoff
            Files    = @{ $script:checkpointPath = (Get-TestCheckpoint) }
            Plans    = @{
                'docs/p1/plan.md' = "### Phase 0 - Setup`n- [ ] [P0-T1] a.`n- [ ] [P0-T2] b."
                'docs/p2/plan.md' = "### Phase 0 - Setup`n- [ ] [P0-T1] a.`n- [ ] [P0-T2] b.`n- [ ] [P0-T3] c.`n- [ ] [P0-T4] d."
                'docs/p3/plan.md' = "### Phase 0 - Setup`n- [ ] [P0-T1] a."
                'docs/p4/plan.md' = "### Phase 0 - Setup`n- [ ] [P0-T1] a.`n- [ ] [P0-T2] b.`n- [ ] [P0-T3] c."
            }
        }
        Mock Invoke-GitExe {
            param([string[]] $GitArgs)
            $fixture.Git.Add(($GitArgs -join ' '))
            if ($GitArgs[0] -eq 'worktree') { return $fixture.Worktree }
            if ($GitArgs[0] -eq 'show') {
                $objectPath = $GitArgs[1].Substring($GitArgs[1].IndexOf(':') + 1)
                if ($objectPath -like '*/epic-kickoff.md') { return $fixture.Kickoff }
                if ($objectPath -like '*/epic.md') { return ($fixture.Manifest -split "`n") }
                return ($fixture.Plans[$objectPath] -split "`n")
            }
        }
        Mock Invoke-GhExe { param([string[]] $GhArgs) $null = $GhArgs }
        Mock Invoke-CswapExe { param([string[]] $CswapArgs) $null = $CswapArgs }
        Mock Test-EpicProgressCommand { param([string] $Name) $null = $Name; return $false }
        Mock Test-EpicProgressPath { param([string] $Path) $fixture.Probes.Add($Path); return $fixture.Files.ContainsKey($Path) }
        Mock Read-EpicProgressFile { param([string] $Path) $fixture.Reads.Add($Path); return $fixture.Files[$Path] }
        Mock Write-EpicProgressState { param([string] $Path, [string] $Content) $fixture.Writes.Add([pscustomobject]@{ Path = $Path; Content = $Content }) }
        Mock Get-EpicProgressUtcNow { return $fixture.Now }
        Mock Get-EpicProgressLastExitCode { return 0 }
    }

    It 'prints the Full golden from checkpoints with max_parallel_features and depends_on and a fixture epic.md (AC-55)' {
        # Four prepared plans (research, spec, plan done) with 2, 4, 1 and 3 open tasks: each has
        # preflight 10 + tasks x 5 + review 14 + pr 3 + ci 17 + merge 5 = 49 + 5n min left, so
        # #101 59, #102 69, #103 54, #104 64 min. Steps 10 + 12 + 9 + 11 + 1 integration-pr = 43,
        # 12 done (27.9%); tasks 0 of 10. No feature qualifies, so each rate is the 12 tasks / hr
        # default. Dependencies: checkpoint keys for #101, #102, #104 (#104 on #101 and on the #102
        # folder hint) and the epic.md list for #103 (on #101): source checkpoint+manifest. Cap 2
        # from the checkpoint. Longest paths: #102 69 + 64 = 133, #101 59 + 64 = 123, #103 54,
        # #104 64. t = 0: #102 and #101 start. t = 59: #101 ends and #103 starts (to 113). t = 69:
        # #102 ends and #104 starts (to 133). Finish 133 min (2 h 13 min); chain #102 -> #104.
        # Tail: no sync row and integration-pr remaining, so a predicted main-sync (60) and
        # integration-pr (45): 105 min. Headline 238 min (3 h 58 min); serial sum 59 + 69 + 54 + 64
        # + 105 = 351 min (5 h 51 min). Per-type sum: preflight 40 + execution 50 + review 56 + pr 12
        # + ci 68 + merge 20 + integration-pr 45 = 291 min (4 h 51 min).
        $lines = Get-TestRun

        $defaultLines = @('research 13', 'spec 6', 'plan 11', 'preflight 10', 'execution 5', 'review 14', 'pr 3', 'ci 17', 'merge 5', 'integration-pr 45' | ForEach-Object {
                $type, $minutes = $_ -split ' '
                "$($type): no measured duration; default $minutes min"
            })
        $expected = @(
            '**TL;DR:** Epic #42 is at 0 of 10 tasks, 12 of 43 steps (27.9%). None of the 4 features is done yet. No feature is running.'
            '**Elapsed:** 3 h 00 min; critical path about 3 h 58 min left (#102 -> #104 -> tail, cap 2). **Weekly** quota is at n/a.'
            '**Now:** no step is in progress. 10 of 10 types use defaults.'
            '**Velocity:** sequential 12 tasks / hr per feature (default, median of 0, SD n/a); aggregate n/a tasks / hr average, n/a recent, SD n/a over 0 intervals (aggregate, informational).'
            '**Estimated time remaining:** range n/a (fewer than 2 qualifying features and fewer than 3 intervals); serial sum 5 h 51 min (upper bound, no parallelism).'
            ''
            '## Epic #42 example-epic: status at 12:00 UTC, Jan 5'
            ''
            '**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 12 of 43 steps complete, **27.9%**.'
            ''
            '| State | Features |'
            '|---|---|'
            '| Completed | None yet |'
            '| Blocked | None |'
            '| Pending, wave 1 | #101 (10), #102 (12) |'
            '| Pending, wave 2 | #103 (9), #104 (11) |'
            ''
            '| Wave | Children | Steps | Done |'
            '|---|---|---|---|'
            '| 1 | 2 | 22 | 6 |'
            '| 2 | 2 | 20 | 6 |'
            '| Epic | 0 | 1 | 0 |'
            '| **Total** | **4** | **43** | **12** |'
            ''
            '| Feature | State | Tasks | Rate | Source | Remaining | Start | Finish |'
            '|---|---|---|---|---|---|---|---|'
            '| #101 | Pending | 0 of 2 | 12 tasks / hr | default | 0 h 59 min | 0 h 00 min | 0 h 59 min |'
            '| #102 | Pending | 0 of 4 | 12 tasks / hr | default | 1 h 09 min | 0 h 00 min | 1 h 09 min |'
            '| #103 | Pending | 0 of 1 | 12 tasks / hr | default | 0 h 54 min | 0 h 59 min | 1 h 53 min |'
            '| #104 | Pending | 0 of 3 | 12 tasks / hr | default | 1 h 04 min | 1 h 09 min | 2 h 13 min |'
            ''
            '**Critical path:** #102 -> #104 -> tail. Headline 3 h 58 min: features finish in 2 h 13 min, then the tail of 1 h 45 min (main-sync 1 h 00 min, integration-pr 0 h 45 min), main-sync predicted.'
            '**Schedule inputs:** dependency source checkpoint+manifest; cap 2 (checkpoint).'
            '**Serial sum:** 5 h 51 min (upper bound, no parallelism). **Range:** n/a (fewer than 2 qualifying features and fewer than 3 intervals).'
            ''
            '| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |'
            '|---|---|---|---|---|---|---|---|'
            '| research | 4 | 0 | 0 | 0 | 0 h 13 min (default) | 0 | 0 h 00 min |'
            '| spec | 4 | 0 | 0 | 0 | 0 h 06 min (default) | 0 | 0 h 00 min |'
            '| plan | 4 | 0 | 0 | 0 | 0 h 11 min (default) | 0 | 0 h 00 min |'
            '| preflight | 0 | 0 | 4 | 0 | 0 h 10 min (default) | 0 | 0 h 40 min |'
            '| execution | 0 | 0 | 10 | 0 | 0 h 05 min (default) | 0 | 0 h 50 min |'
            '| review | 0 | 0 | 4 | 0 | 0 h 14 min (default) | 0 | 0 h 56 min |'
            '| pr | 0 | 0 | 4 | 0 | 0 h 03 min (default) | 0 | 0 h 12 min |'
            '| ci | 0 | 0 | 4 | 0 | 0 h 17 min (default) | 0 | 1 h 08 min |'
            '| merge | 0 | 0 | 4 | 0 | 0 h 05 min (default) | 0 | 0 h 20 min |'
            '| integration-pr | 0 | 0 | 1 | 0 | 0 h 45 min (default) | 0 | 0 h 45 min |'
            '| **Total** | **12** | **0** | **31** | **0** | | **0** | **4 h 51 min** |'
            ''
            $defaultLines
            '**Unmapped and composite stage time:** none.'
            "**Weekly quota (active account):** n/a used, n/a points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
        )
        ($lines -join "`n") | Should -Be ($expected -join "`n")
        $fixture.Git | Should -Contain "show $($script:integration):docs/features/epics/example-epic/epic.md"
    }

    It 'reads no epic.md when every kickoff feature carries a checkpoint depends_on key (E5)' {
        $fixture.Files[$script:checkpointPath] = Get-TestCheckpoint -AllKeyed

        $lines = Get-TestRun

        @($fixture.Git | Where-Object { $_ -like '*epic.md' }).Count | Should -Be 0
        $lines | Should -Contain '**Schedule inputs:** dependency source checkpoint; cap 2 (checkpoint).'
    }

    It 'prints the built-in cap source with no routing config and the config source with one (AC-31)' {
        $fixture.Files[$script:checkpointPath] = Get-TestCheckpoint -CapText ''
        $absent = Get-TestRun
        $fixture.Files[$script:routingPath] = '{"codex_topology_policy":{"parallelism":{"default_max_parallel_features":3}}}'
        $present = Get-TestRun

        # Epic mode probes the routing config (the positive control for the item-mode case).
        $fixture.Probes | Should -Contain $script:routingPath
        $absent | Should -Contain '**Schedule inputs:** dependency source checkpoint+manifest; cap 4 (built-in).'
        $absent[1] | Should -BeLike '*, cap 4). *'
        $present | Should -Contain '**Schedule inputs:** dependency source checkpoint+manifest; cap 3 (config).'
    }

    Context 'pause spans (AC-19, AC-44, E11)' {
        It 'appends the reset span from the newest stored sample and keeps the ledger and anchors (AC-19)' {
            $durations = '{"review":[{"key":"9|review|1","type":"review","seconds":780,"source":"stage_timing","approx":false,"recorded":1767600000}]}'
            $samples = '{"ts":' + ($script:nowUnix - 1200) + ',"done":12},{"ts":' + ($script:nowUnix - 600) + ',"done":12}'
            $fixture.Files[$script:statePath] = Get-TestStateText -Samples $samples -Durations $durations -Items (Get-TestAnchor -LastTick 1767610000)

            $null = Get-TestRun -Extra @{ ResetBaseline = $true; Mode = 'TLDR' }

            $written = Get-TestWritten
            @($written.pauses).Count | Should -Be 1
            $written.pauses[0].startUnixSeconds | Should -Be ($script:nowUnix - 600)
            $written.pauses[0].endUnixSeconds | Should -Be $script:nowUnix
            $written.durations.review[0].seconds | Should -Be 780
            $written.items.'101'.plans.'plan.md'.lastTickUnixSeconds | Should -Be 1767610000
        }

        It 'appends no reset span when no sample is stored (AC-19)' {
            $fixture.Files[$script:statePath] = Get-TestStateText -Items (Get-TestAnchor -LastTick 1767610000)

            $null = Get-TestRun -Extra @{ ResetBaseline = $true; Mode = 'TLDR' }

            @((Get-TestWritten).pauses).Count | Should -Be 0
        }

        It 'keeps the stored span, appends the reset span, replaces the samples and restarts the blocked span (AC-44)' {
            # #104 stays blocked (merge status blocked_conflict_loop_limit); its stored span started at 10:00.
            $fixture.Files[$script:checkpointPath] = Get-TestCheckpoint -MergeStatus104 'blocked_conflict_loop_limit'
            $items = '{"104":{"plans":{},"blockedSinceUnixSeconds":1767607200}}'
            $samples = '{"ts":' + ($script:nowUnix - 3000) + ',"done":12,"tasks":0,"features":{}},{"ts":' + ($script:nowUnix - 2400) + ',"done":12,"tasks":0,"features":{}}'
            $fixture.Files[$script:statePath] = Get-TestStateText -Samples $samples -Items $items -Pauses '[{"startUnixSeconds":1767600000,"endUnixSeconds":1767603600}]'

            $null = Get-TestRun -Extra @{ ResetBaseline = $true; Mode = 'TLDR' }

            $written = Get-TestWritten
            (@($written.pauses | ForEach-Object { "$($_.startUnixSeconds)-$($_.endUnixSeconds)" }) -join ',') | Should -Be "1767600000-1767603600,$($script:nowUnix - 2400)-$($script:nowUnix)"
            @($written.samples).Count | Should -Be 1
            $written.samples[0].ts | Should -Be $script:nowUnix
            $written.items.'104'.blockedSinceUnixSeconds | Should -Be $script:nowUnix
        }

        It 'excludes a gap closed this run from the tick batch and appends one span (US-06)' {
            # #101 P0-T1 is checked this run; its anchor is at now - 5000 and the newest sample at
            # now - 4000, so the 4000 s gap (above 3600) is a span and the task took 5000 - 4000 = 1000 s.
            $fixture.Plans['docs/p1/plan.md'] = "### Phase 0 - Setup`n- [x] [P0-T1] a.`n- [ ] [P0-T2] b."
            $fixture.Files[$script:statePath] = Get-TestStateText -Samples ('{"ts":' + ($script:nowUnix - 4000) + ',"done":12,"tasks":0,"features":{}}') -Items (Get-TestAnchor -LastTick ($script:nowUnix - 5000))

            $null = Get-TestRun -Extra @{ Mode = 'TLDR' }

            Get-TestExecutionSecond | Should -Be @(1000)
            $written = Get-TestWritten
            @($written.pauses).Count | Should -Be 1
            "$($written.pauses[0].startUnixSeconds)-$($written.pauses[0].endUnixSeconds)" | Should -Be "$($script:nowUnix - 4000)-$($script:nowUnix)"

            # A second run 1200 s later closes no gap above 3600 s, so no further span is appended.
            $fixture.Files[$script:statePath] = $fixture.Writes[0].Content
            $fixture.Now = $fixture.Now.AddSeconds(1200)
            $null = Get-TestRun -Extra @{ Mode = 'TLDR' }

            @((Get-TestWritten).pauses).Count | Should -Be 1
        }

        It 'keeps the full interval and appends no span for a gap of 3000 s (US-06)' {
            $fixture.Plans['docs/p1/plan.md'] = "### Phase 0 - Setup`n- [x] [P0-T1] a.`n- [ ] [P0-T2] b."
            $fixture.Files[$script:statePath] = Get-TestStateText -Samples ('{"ts":' + ($script:nowUnix - 3000) + ',"done":12,"tasks":0,"features":{}}') -Items (Get-TestAnchor -LastTick ($script:nowUnix - 5000))

            $null = Get-TestRun -Extra @{ Mode = 'TLDR' }

            Get-TestExecutionSecond | Should -Be @(5000)
            @((Get-TestWritten).pauses).Count | Should -Be 0
        }

        It 'excludes the reset span from the tick batch under -ResetBaseline (US-06)' {
            # The reset span runs from the newest sample (now - 3000) to now: 5000 - 3000 = 2000 s.
            $fixture.Plans['docs/p1/plan.md'] = "### Phase 0 - Setup`n- [x] [P0-T1] a.`n- [ ] [P0-T2] b."
            $fixture.Files[$script:statePath] = Get-TestStateText -Samples ('{"ts":' + ($script:nowUnix - 3000) + ',"done":12,"tasks":0,"features":{}}') -Items (Get-TestAnchor -LastTick ($script:nowUnix - 5000))

            $null = Get-TestRun -Extra @{ Mode = 'TLDR'; ResetBaseline = $true }

            Get-TestExecutionSecond | Should -Be @(2000)
        }

        It 'drops a stored span ending before the start, the samples, and the anchor and prints the same velocity line (CR4)' {
            # Start 09:00 (1767603600); the samples at now - 2400 and now - 1200 form one 1200 s
            # interval, the anchor is at now - 2400, and the span 1767590000-1767600000 ends before all of them.
            $fixture.Plans['docs/p1/plan.md'] = "### Phase 0 - Setup`n- [x] [P0-T1] a.`n- [ ] [P0-T2] b."
            $samples = '{"ts":' + ($script:nowUnix - 2400) + ',"done":12,"tasks":1,"features":{}},{"ts":' + ($script:nowUnix - 1200) + ',"done":12,"tasks":1,"features":{}}'
            $items = Get-TestAnchor -Checked '"P0-T1"' -LastTick ($script:nowUnix - 2400)
            $fixture.Files[$script:statePath] = Get-TestStateText -Samples $samples -Items $items -Pauses '[{"startUnixSeconds":1767590000,"endUnixSeconds":1767600000}]'
            $withSpan = Get-TestRun -Extra @{ Mode = 'TLDR' }
            $writtenWithSpan = Get-TestWritten
            $fixture.Files[$script:statePath] = Get-TestStateText -Samples $samples -Items $items
            $withoutSpan = Get-TestRun -Extra @{ Mode = 'TLDR' }

            @($writtenWithSpan.pauses).Count | Should -Be 0
            $withSpan[3] | Should -BeLike '**Velocity:** *'
            $withSpan[3] | Should -Not -BeLike '*aggregate n/a tasks / hr average*' -Because 'the stored samples form an interval, so the compared average is finite'
            $withSpan[3] | Should -Be $withoutSpan[3]
        }
    }

    It 'reads the per-feature rate from the ledger merged this run (E3)' {
        # Four stored #101 execution samples of 300 s; P0-T5 is checked this run 600 s after the
        # anchor, so #101 reaches 5 tasks in 1800 s (10 tasks / hr) and qualifies with source own.
        # The same fixture with P0-T5 already in the anchor has 4 tasks and keeps the default.
        # Remaining at 10 tasks / hr: one task 6 + review 14 + pr 3 + ci 17 + merge 5 = 45 min.
        $fixture.Plans['docs/p1/plan.md'] = (@('### Phase 0 - Setup') + @(1..5 | ForEach-Object { "- [x] [P0-T$_] t." }) + @('- [ ] [P0-T6] t.')) -join "`n"
        $stored = @(1..4 | ForEach-Object { '{"key":"101|exec|plan.md|P0-T' + $_ + '","type":"execution","seconds":300,"source":"tick","approx":false,"recorded":1767600000}' }) -join ','
        $durations = '{"execution":[' + $stored + ']}'
        $fixture.Files[$script:statePath] = Get-TestStateText -Durations $durations -Items (Get-TestAnchor -Checked '"P0-T1","P0-T2","P0-T3","P0-T4"' -LastTick ($script:nowUnix - 600))
        $newSample = Get-TestRun
        $fixture.Files[$script:statePath] = Get-TestStateText -Durations $durations -Items (Get-TestAnchor -Checked '"P0-T1","P0-T2","P0-T3","P0-T4","P0-T5"' -LastTick ($script:nowUnix - 600))
        $noSample = Get-TestRun

        @($newSample | Where-Object { $_ -like '| #101 |*' }) | Should -Be @('| #101 | Running | 5 of 6 | 10 tasks / hr | own | 0 h 45 min | 0 h 00 min | 0 h 45 min |')
        @($noSample | Where-Object { $_ -like '| #101 |*' })[0] | Should -BeLike '| #101 | Running | 5 of 6 | 12 tasks / hr | default |*'
    }

    It 'prints the aggregate over 0 intervals and writes the current task baseline on the first run after a version-2 migration (E12)' {
        # Three version-2 samples carry no task count, so they form no interval; #101 has 1 done task.
        $fixture.Plans['docs/p1/plan.md'] = "### Phase 0 - Setup`n- [x] [P0-T1] a.`n- [ ] [P0-T2] b."
        $samples = @(1800, 1200, 600 | ForEach-Object { '{"ts":' + ($script:nowUnix - $_) + ',"done":12}' }) -join ','
        $fixture.Files[$script:statePath] = (Get-TestStateText -Version 2 -Samples $samples).Replace(',"baselineDoneTasks":0', '')

        $lines = Get-TestRun -Extra @{ Mode = 'TLDR' }

        $lines[3] | Should -BeLike '*; aggregate n/a tasks / hr average, n/a recent, SD n/a over 0 intervals (aggregate, informational).'
        $written = Get-TestWritten
        $written.version | Should -Be 3
        $written.baselineDoneTasks | Should -Be 1
        @($written.samples).Count | Should -Be 4
        $written.samples[3].tasks | Should -Be 1
    }

    It 'prints identical lines with and without -WaveOverheadHours (E10)' {
        $without = Get-TestRun
        $with = Get-TestRun -Extra @{ WaveOverheadHours = 3 }

        ($with -join "`n") | Should -Be ($without -join "`n")
        @($with | Where-Object { $_ -like '*wave-parallel*' }).Count | Should -Be 0
    }

    It 'reads no routing config in item mode (E5)' {
        $worktree = '/fixture-repo-wt/item'
        $fixture.Worktree = @("worktree $worktree", 'branch refs/heads/feature/item')
        $fixture.Files[(Join-Path -Path $worktree -ChildPath 'artifacts/orchestration/orchestrator-state.json')] = '{"issue-num":"1118","plan-path":"docs/x/plan.md"}'
        $fixture.Files[(Join-Path -Path $worktree -ChildPath 'docs/x/plan.md')] = "### Phase 0 - Setup`n- [ ] [P0-T1] a."

        $lines = @(Invoke-EpicProgressReport -Issue 1118 -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)) -RepositoryRoot '/fixture-repo' -Mode TLDR)

        $lines.Count | Should -Be 5
        $lines[1] | Should -BeLike '*; critical path about * left (#1118). *'
        $fixture.Probes.Count | Should -BeGreaterThan 0
        @(@($fixture.Probes) + @($fixture.Reads) | Where-Object { $_ -like '*orchestration-routing.json' }).Count | Should -Be 0
        @($fixture.Git | Where-Object { $_ -like '*epic.md' }).Count | Should -Be 0
    }

    Context 'scripts/dev-tools forwarder (AC-54)' {
        BeforeEach {
            $script:savedExitCode = $global:LASTEXITCODE
        }

        AfterEach {
            $global:LASTEXITCODE = $script:savedExitCode
        }

        It 'prints the five TL;DR lines and the Full report through the forwarder' {
            # Run in process with the seams mocked; -RepositoryRoot is this existing test folder, so
            # the entry block's Push-Location succeeds, and every path the run probes is a fixture path.
            $lines = @(& $script:forwarderPath -EpicFolder 'example-epic' -StartUtc '2026-01-05T09:00:00Z' -RepositoryRoot $PSScriptRoot -CheckpointPath $script:checkpointPath -StatePath $script:statePath)

            $prefixes = @('**TL;DR:**', '**Elapsed:**', '**Now:**', '**Velocity:**', '**Estimated time remaining:**')
            for ($index = 0; $index -lt 5; $index++) {
                $lines[$index].StartsWith($prefixes[$index]) | Should -BeTrue -Because "line $index starts with $($prefixes[$index])"
            }
            $lines[6] | Should -BeLike '## Epic #42 example-epic: status at *'
            $lines | Should -Contain '| Feature | State | Tasks | Rate | Source | Remaining | Start | Finish |'
            $LASTEXITCODE | Should -Be 0
            $fixture.Writes.Count | Should -Be 1
        }
    }
}

Describe 'Cross-epic external nodes on the critical path (issue #1162)' {
    BeforeAll {
        $script:crossDefaults = Resolve-EpicProgressStepDefault
        $script:crossNow = 1767614400
    }

    It 'lengthens the chain of a dependent by a pending external prerequisite' {
        $nodes = @(
            [pscustomobject]@{ Issue = 'provider-epic#1188'; State = 'pending'; DurationSeconds = 7200; DependsOn = [string[]] @(); External = $true }
            [pscustomobject]@{ Issue = '1201'; State = 'pending'; DurationSeconds = 3600; DependsOn = [string[]] @('provider-epic#1188') }
        )

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 1 -TailSeconds 600

        $schedule.HeadlineSeconds | Should -Be (7200 + 3600 + 600)
        Get-EpicProgressCriticalChain -Schedule $schedule | Should -BeExactly 'provider-epic#1188 -> #1201 -> tail'
    }

    It 're-prices an external node at the side rates like an equal local node' {
        # The local twin has 3 remaining execution tasks and a merge step whose default (300 s)
        # equals the external node's OtherSeconds, so both price identically at every rate.
        $external = [pscustomobject]@{ Issue = 'p#7'; NodeState = 'pending'; Step = @(); Rate = 8.0; DependsOn = [string[]] @(); External = $true; ExecutionTasks = 3; OtherSeconds = 300.0 }
        $steps = @(1..3 | ForEach-Object { Get-EpicProgressStepRecord -Issue '7' -Type 'execution' -Ordinal $_ }) + @(Get-EpicProgressStepRecord -Issue '7' -Type 'merge')
        $local = [pscustomobject]@{ Issue = '7'; NodeState = 'pending'; Step = $steps; Rate = 8.0; DependsOn = [string[]] @() }
        $pooled = [pscustomobject]@{ Count = 2; StandardDeviation = 1.0 }

        $externalRange = Get-EpicProgressScheduleRange -Feature @($external) -Pooled $pooled -Ledger @{} -Default $script:crossDefaults -NowUnixSeconds $script:crossNow
        $localRange = Get-EpicProgressScheduleRange -Feature @($local) -Pooled $pooled -Ledger @{} -Default $script:crossDefaults -NowUnixSeconds $script:crossNow

        "$($externalRange.FastSeconds)|$($externalRange.SlowSeconds)" | Should -BeExactly "$($localRange.FastSeconds)|$($localRange.SlowSeconds)"
    }

    It 'adds external nodes to the report schedule without a feature row or a step' {
        $feature = [pscustomobject]@{ Issue = '1201'; Wave = 1; Folder = 'f'; State = 'Pending'; Blocked = $false; Step = @(Get-EpicProgressStepRecord -Issue '1201' -Type 'merge'); TasksDone = 0; TasksTotal = 0 }
        $edge = [pscustomobject]@{ Issue = '1201'; Epic = 'p'; IntegrationBranch = 'epic/p-integration'; IssueNum = '7'; Status = 'held'; Node = 'p#7' }
        $node = New-EpicProgressExternalNode -Edge $edge -Default $script:crossDefaults -NowUnixSeconds $script:crossNow

        $path = Get-EpicProgressCriticalPathReport -Feature @($feature) -Ledger @{} -Default $script:crossDefaults -NowUnixSeconds $script:crossNow -ExternalNode @($node) -CrossEdge @($edge)

        @($path.Feature).Count | Should -Be 1
        $path.Chain | Should -BeExactly 'p#7 -> #1201 -> tail'
        "$($path.CrossEpic[0].Issue)|$($path.CrossEpic[0].Node)|$($path.CrossEpic[0].State)|$($path.CrossEpic[0].Label)" | Should -BeExactly '1201|p#7|pending|external (default)'
        $path.SerialSumSeconds | Should -BeLessThan $path.HeadlineSeconds
    }
}
