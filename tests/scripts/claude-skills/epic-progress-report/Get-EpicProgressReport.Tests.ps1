# Pester 5 tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 (issue #1080).
# The script is dot-sourced with its two mandatory parameters bound, so the entry-point
# block is skipped. Every I/O seam is either exercised without side effects (absent
# command, absent path, a read of the script itself, a -WhatIf write) or mocked with a
# matching parameter signature; no test starts git, gh, or cswap, writes a file, or reads
# the clock.
# Issue #1093 added the -PairSamples write case for a run within 90 seconds of the last sample.
# Issue #1118 replaced the task goldens with hand-derived step goldens and the stored states
# with version-2 documents; item mode and parameter sets are in Get-EpicProgressReport.ItemMode.Tests.ps1.

BeforeAll {
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1'
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:scriptPath -EpicFolder 'example-epic' -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc))
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
        $text | Should -Match 'function Invoke-EpicProgressReport'
    }

    It 'writes nothing when the state write runs with WhatIf' {
        $target = Join-Path -Path $PSScriptRoot -ChildPath 'absent-epic-progress-state.json'

        Write-EpicProgressState -Path $target -Content '[]' -WhatIf

        Test-Path -LiteralPath $target | Should -BeFalse
    }

    Context 'state write without WhatIf (file cmdlets mocked)' {
        BeforeEach {
            # New-Item and Set-Content are mocked, so nothing is written; the directory test is
            # mocked only for container checks so each case controls whether the folder exists.
            $script:stateTarget = Join-Path -Path $PSScriptRoot -ChildPath 'absent-epic-progress-state-folder/epic-progress-example-epic.json'
            $script:stateFolder = Split-Path -Path $script:stateTarget -Parent
            $script:folderExists = $false
            Mock Test-Path { return $folderExists } -ParameterFilter { $PathType -eq 'Container' }
            Mock New-Item { }
            Mock Set-Content { }
        }

        It 'creates the missing state directory before writing the state' {
            Write-EpicProgressState -Path $script:stateTarget -Content '{"version":1}'

            Should -Invoke New-Item -Times 1 -Exactly -ParameterFilter { $ItemType -eq 'Directory' -and $Path -eq $script:stateFolder }
            Should -Invoke Set-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq $script:stateTarget -and $Value -eq '{"version":1}' }
            [System.IO.Directory]::Exists($script:stateFolder) | Should -BeFalse
        }

        It 'writes the state without creating an existing directory' {
            $script:folderExists = $true

            Write-EpicProgressState -Path $script:stateTarget -Content '{"version":1}'

            Should -Invoke New-Item -Times 0 -Exactly
            Should -Invoke Set-Content -Times 1 -Exactly
        }
    }

    It 'returns the last native exit code' {
        # Reads $LASTEXITCODE without assigning it, so no global state changes.
        Get-EpicProgressLastExitCode | Should -Be $LASTEXITCODE
    }
}

Describe 'Invoke-EpicProgressReport' {
    BeforeAll {
        $script:integration = 'origin/epic/example-epic-integration'
        $script:checkpointPath = '/fixture-repo/artifacts/orchestration/epic-orchestrator-state.json'
        $script:statePath = '/fixture-temp/epic-progress-example-epic.json'
        $script:livePlanPath = Join-Path -Path '/repo-wt/beta' -ChildPath 'docs/b/plan.md'
        $script:fixedNow = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)
        $script:fixedNowUnix = 1767614400
        $script:reportParameter = @{
            EpicFolder     = 'example-epic'
            StartUtc       = [datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)
            RepositoryRoot = '/fixture-repo'
            CheckpointPath = $script:checkpointPath
            StatePath      = $script:statePath
        }
        $script:kickoffWithMarker = @(
            '# Example epic kickoff'
            'Epic issue: #42'
            ''
            '| Issue | Title | Wave | Band | Plan |'
            '|---|---|---|---|---|'
            '| 12 | Alpha | 1 | small | docs/a/plan.md |'
            '| 12345 | Beta | 2 | large | docs/b/plan.md |'
            '| 77 | Gamma | 3 | medium | docs/c/plan.md |'
        )
        $script:planText = @{
            'docs/a/plan.md' = "### Phase 0 - Setup`n- [x] [P0-T1] Read.`n- [x] [P0-T2] Baseline."
            'docs/b/plan.md' = "### Phase 0 - Setup`n- [ ] [P0-T1] Read.`n- [ ] [P1-T1] a.`n- [ ] [P1-T2] b.`n- [ ] [P1-T3] c.`n- [ ] [P1-T4] d."
            'docs/c/plan.md' = "### Phase 0 - Setup`n- [ ] [P0-T1] Read.`n- [ ] [P0-T2] Baseline.`n- [ ] [P0-T3] Plan."
        }
        $script:livePlan = "### Phase 0 - Setup`n- [x] [P0-T1] Read.`n### Phase 1 - Build`n- [ ] [P1-T1] a.`n- [ ] [P1-T2] b.`n- [ ] [P1-T3] c.`n- [ ] [P1-T4] d."
        $script:checkpointJson = '{"features":[{"issue_num":12,"branch_name":"feature/alpha","merge_status":"merged"},{"issue_num":12345,"branch_name":"feature/beta","merge_status":"in_progress"}]}'

        # Hand-derived step goldens. No item has a checkpoint, so stage_timing is absent:
        # #12 is merged, so all 10 item steps (8 non-execution types plus 2 tasks) are done.
        # #12345 has a prepared plan (research, spec, plan done), a checked task (preflight
        # done, 1 of 5 tasks), and PR #8 (pr done): 6 of 13. #77 has a prepared plan: 3 of 11.
        # The integration-pr epic step remains: 19 of 35 steps (54.3%). No sample exists, so
        # every type uses its default: preflight 1 x 10 + execution 7 x 5 + review 2 x 14 +
        # pr 1 x 3 + ci 2 x 17 + merge 2 x 5 + integration-pr 1 x 45 = 165 min (2.75 h). Wave
        # 2 holds 56 min and wave 3 64 min, plus 45 min of epic steps: also 165 min.
        $script:expectedTldr = @(
            '**TL;DR:** Epic #42 is at 19 of 35 steps (54.3%). 1 of 3 features are done. #12345 is running (6 of 13 steps).'
            '**Elapsed:** 3 h 00 min, with about 2.8 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.'
            '**Now:** no step is in progress. 10 of 10 types use defaults.'
            '**Estimated time remaining:** 2 h 45 min by type (sum); 2 h 45 min wave-parallel.'
        )
        $defaultLines = @(
            'research 13', 'spec 6', 'plan 11', 'preflight 10', 'execution 5', 'review 14', 'pr 3', 'ci 17', 'merge 5', 'integration-pr 45' | ForEach-Object {
                $type, $minutes = $_ -split ' '
                "$($type): no measured duration; default $minutes min"
            })
        $script:expectedFull = @(
            ''
            '## Epic #42 example-epic: status at 12:00 UTC, Jan 5'
            ''
            '**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 19 of 35 steps complete, **54.3%**.'
            ''
            '| State | Features |'
            '|---|---|'
            '| Completed | #12 |'
            '| Running | #12345 (wave 2, large): 6 of 13 steps (46%). Now at: Phase 1 - Build. PR #8 OPEN. |'
            '| Blocked | None |'
            '| Pending, wave 3 | #77 (11) |'
            ''
            '| Wave | Children | Steps | Done |'
            '|---|---|---|---|'
            '| 1 | 1 | 10 | 10 |'
            '| 2 | 1 | 13 | 6 |'
            '| 3 | 1 | 11 | 3 |'
            '| Epic | 0 | 1 | 0 |'
            '| **Total** | **3** | **35** | **19** |'
            ''
            '| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |'
            '|---|---|---|---|---|---|---|---|'
            '| research | 3 | 0 | 0 | 0 | 0 h 13 min (default) | 0 | 0 h 00 min |'
            '| spec | 3 | 0 | 0 | 0 | 0 h 06 min (default) | 0 | 0 h 00 min |'
            '| plan | 3 | 0 | 0 | 0 | 0 h 11 min (default) | 0 | 0 h 00 min |'
            '| preflight | 2 | 0 | 1 | 0 | 0 h 10 min (default) | 0 | 0 h 10 min |'
            '| execution | 3 | 0 | 7 | 0 | 0 h 05 min (default) | 0 | 0 h 35 min |'
            '| review | 1 | 0 | 2 | 0 | 0 h 14 min (default) | 0 | 0 h 28 min |'
            '| pr | 2 | 0 | 1 | 0 | 0 h 03 min (default) | 0 | 0 h 03 min |'
            '| ci | 1 | 0 | 2 | 0 | 0 h 17 min (default) | 0 | 0 h 34 min |'
            '| merge | 1 | 0 | 2 | 0 | 0 h 05 min (default) | 0 | 0 h 10 min |'
            '| integration-pr | 0 | 0 | 1 | 0 | 0 h 45 min (default) | 0 | 0 h 45 min |'
            '| **Total** | **19** | **0** | **16** | **0** | | **0** | **2 h 45 min** |'
            ''
            $defaultLines
            '**Unmapped and composite stage time:** none.'
            "**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
        )
        # A version-2 store whose anchors match the fixture plans: P0-T1 of #12345 is checked, #77 has none.
        $script:anchorItems = '"items":{"12345":{"plans":{"plan.md":{"checked":["P0-T1"],"lastTickUnixSeconds":1767610000}},"blockedSinceUnixSeconds":null},"77":{"plans":{"plan.md":{"checked":[],"lastTickUnixSeconds":1767610000}},"blockedSinceUnixSeconds":null}}'

        function Get-TestStateText {
            # A version-2 state document with the given start, baseline, weekly baseline, sample offsets, and done count.
            param([long] $Start = 1767603600, [int] $BaselineDone = 0, [double] $Weekly = 0, [int[]] $Offset = @(), [int] $Done = 19, [string] $Extra = '')
            $samples = @($Offset | ForEach-Object { "{`"ts`":$($script:fixedNowUnix - $_),`"done`":$Done}" }) -join ','
            $tail = ''
            if ($Extra) { $tail = ",$Extra" }
            "{`"version`":2,`"unit`":`"steps`",`"startUnixSeconds`":$Start,`"baselineDone`":$BaselineDone,`"baselineWeeklyPct`":$Weekly,`"samples`":[$samples]$tail}"
        }

        function Get-TestReportLine {
            param([hashtable] $Extra = @{})
            $arguments = $script:reportParameter.Clone()
            foreach ($key in $Extra.Keys) { $arguments[$key] = $Extra[$key] }
            @(Invoke-EpicProgressReport @arguments)
        }
    }

    BeforeEach {
        # Fresh per-test fixture state; the mocks below read and record through it.
        $script:gitCalls = [System.Collections.Generic.List[string]]::new()
        $script:ghCalls = [System.Collections.Generic.List[string]]::new()
        $script:stateWrites = [System.Collections.Generic.List[object]]::new()
        $script:kickoffLines = $script:kickoffWithMarker
        $script:installed = @('gh', 'cswap')
        $script:ghOutput = @{
            'feature/alpha' = '[{"number":7,"state":"MERGED"}]'
            'feature/beta'  = '[{"number":8,"state":"OPEN"}]'
        }
        $script:cswapOutput = '{"accounts":[{"active":true,"usage":{"sevenDay":{"pct":42.5}}}]}'
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath)
        $script:fileText = @{
            $script:checkpointPath = $script:checkpointJson
            $script:livePlanPath   = $script:livePlan
        }

        Mock Invoke-GitExe {
            param([string[]] $GitArgs)
            $script:gitCalls.Add(($GitArgs -join ' '))
            if ($GitArgs[0] -eq 'worktree') {
                return @('worktree /repo', 'branch refs/heads/main', '', 'worktree /repo-wt/beta', 'branch refs/heads/feature/beta')
            }
            if ($GitArgs[0] -eq 'show') {
                $objectPath = $GitArgs[1].Substring($script:integration.Length + 1)
                if ($objectPath -eq 'docs/features/epics/example-epic/epic-kickoff.md') { return $script:kickoffLines }
                return ($script:planText[$objectPath] -split "`n")
            }
        }
        Mock Invoke-GhExe {
            param([string[]] $GhArgs)
            $script:ghCalls.Add(($GhArgs -join ' '))
            return $script:ghOutput[$GhArgs[3]]
        }
        Mock Invoke-CswapExe { param([string[]] $CswapArgs) $null = $CswapArgs; return $script:cswapOutput }
        Mock Test-EpicProgressCommand { param([string] $Name) return ($script:installed -contains $Name) }
        Mock Test-EpicProgressPath { param([string] $Path) return ($script:existingPaths -contains $Path) }
        Mock Read-EpicProgressFile { param([string] $Path) return $script:fileText[$Path] }
        Mock Write-EpicProgressState {
            param([string] $Path, [string] $Content)
            $script:stateWrites.Add([pscustomobject]@{ Path = $Path; Content = $Content })
        }
        Mock Get-EpicProgressUtcNow { return $script:fixedNow }
        # The fetch exit code comes from the fixture, never from the ambient $LASTEXITCODE.
        $script:fetchExitCode = 0
        Mock Get-EpicProgressLastExitCode { return $script:fetchExitCode }
    }

    It 'warns when git fetch fails' {
        $script:fetchExitCode = 128
        $arguments = $script:reportParameter.Clone()
        $arguments['Mode'] = 'TLDR'

        $lines = @(Invoke-EpicProgressReport @arguments -WarningVariable fetchWarnings -WarningAction SilentlyContinue)

        @($fetchWarnings).Count | Should -Be 1
        "$($fetchWarnings[0])" | Should -BeLike 'git fetch -q origin failed with exit code 128;*'
        ($lines -join "`n") | Should -Be ($script:expectedTldr -join "`n")
    }

    It 'does not warn when git fetch succeeds' {
        $arguments = $script:reportParameter.Clone()
        $arguments['Mode'] = 'TLDR'

        $null = Invoke-EpicProgressReport @arguments -WarningVariable fetchWarnings -WarningAction SilentlyContinue

        @($fetchWarnings).Count | Should -Be 0
    }

    It 'prints the four TL;DR lines in TLDR mode' {
        $lines = Get-TestReportLine -Extra @{ Mode = 'TLDR' }

        ($lines -join "`n") | Should -Be ($script:expectedTldr -join "`n")
    }

    It 'prints the TL;DR block followed by the Full sections in Full mode' {
        $lines = Get-TestReportLine

        $lines.Count | Should -Be ($script:expectedTldr.Count + $script:expectedFull.Count)
        ($lines -join "`n") | Should -Be ((@($script:expectedTldr) + @($script:expectedFull)) -join "`n")
    }

    It 'takes the epic issue from the kickoff when -EpicIssue is absent' {
        $lines = Get-TestReportLine -Extra @{ Mode = 'TLDR' }

        $lines[0] | Should -BeLike '**TL;DR:** Epic #42 is at *'
    }

    It 'uses -EpicIssue over the kickoff marker' {
        $lines = Get-TestReportLine -Extra @{ EpicIssue = '900' }

        $lines[0] | Should -BeLike '**TL;DR:** Epic #900 is at *'
        $lines[5] | Should -Be '## Epic #900 example-epic: status at 12:00 UTC, Jan 5'
    }

    It 'throws when no epic issue can be resolved' {
        $script:kickoffLines = @($script:kickoffWithMarker | Where-Object { $_ -notlike 'Epic issue:*' })

        { Get-TestReportLine } | Should -Throw '*-EpicIssue*'
    }

    It 'reads a live plan from the feature worktree' {
        $lines = Get-TestReportLine

        Should -Invoke Read-EpicProgressFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:livePlanPath }
        $script:gitCalls | Should -Not -Contain "show $($script:integration):docs/b/plan.md"
        $lines | Should -Contain '| Running | #12345 (wave 2, large): 6 of 13 steps (46%). Now at: Phase 1 - Build. PR #8 OPEN. |'
    }

    It 'prints n/a quota when cswap is not installed' {
        $script:installed = @('gh')

        $lines = Get-TestReportLine

        Should -Invoke Invoke-CswapExe -Times 0 -Exactly
        $lines[1] | Should -BeLike '* **Weekly** quota is at n/a.'
        $lines[-1] | Should -BeLike '**Weekly quota (active account):** n/a used, n/a points since the epic started. *'
    }

    It 'prints n/a quota when cswap output is unparseable' {
        $script:cswapOutput = 'error: no account is signed in'

        $lines = Get-TestReportLine

        $lines[1] | Should -BeLike '* **Weekly** quota is at n/a.'
    }

    It 'leaves the PR state empty when gh is not installed' {
        $script:installed = @('cswap')

        $lines = Get-TestReportLine

        Should -Invoke Invoke-GhExe -Times 0 -Exactly
        $lines | Should -Contain '| Running | #12345 (wave 2, large): 5 of 13 steps (38%). Now at: Phase 1 - Build. |'
        $lines | Should -Contain '| Completed | #12 |'
    }

    It 'leaves the PR state empty when gh output is unparseable' {
        $script:ghOutput = @{ 'feature/alpha' = 'gh: authentication required'; 'feature/beta' = 'gh: authentication required' }

        $lines = Get-TestReportLine

        $lines | Should -Contain '| Running | #12345 (wave 2, large): 5 of 13 steps (38%). Now at: Phase 1 - Build. |'
    }

    It 'treats an unparseable state file as empty' {
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = 'not json {'

        $lines = Get-TestReportLine -Extra @{ Mode = 'TLDR' }

        ($lines -join "`n") | Should -Be ($script:expectedTldr -join "`n")
        $script:stateWrites.Count | Should -Be 1
        @((ConvertFrom-Json -InputObject $script:stateWrites[0].Content).samples).Count | Should -Be 1
    }

    It 'passes only fetch, show and worktree list to git' {
        $null = Get-TestReportLine

        $expected = @(
            'fetch -q origin'
            'worktree list --porcelain'
            "show $($script:integration):docs/features/epics/example-epic/epic-kickoff.md"
            "show $($script:integration):docs/a/plan.md"
            "show $($script:integration):docs/c/plan.md"
        )
        ($script:gitCalls -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'passes only pr list to gh' {
        $null = Get-TestReportLine

        $expected = @(
            'pr list --head feature/alpha --state all --json number,state'
            'pr list --head feature/beta --state all --json number,state'
        )
        ($script:ghCalls -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'writes only the state file at -StatePath' {
        $null = Get-TestReportLine

        $script:stateWrites.Count | Should -Be 1
        $script:stateWrites[0].Path | Should -Be $script:statePath
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        $written.version | Should -Be 2
        $written.unit | Should -Be 'steps'
        @($written.samples).Count | Should -Be 1
        $written.samples[0].ts | Should -Be $script:fixedNowUnix
        # 19 done steps (see the golden comment).
        $written.samples[0].done | Should -Be 19
        # 1767603600 is the fixture start, 2026-01-05T09:00:00Z.
        $written.startUnixSeconds | Should -Be 1767603600
        $written.baselineDone | Should -Be 0
    }

    It 'does not write the state file within 90 seconds of the last sample' {
        # A version-2 store whose newest sample is 50 s old and whose anchors match the fixture plans.
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = Get-TestStateText -Offset @(50) -Extra $script:anchorItems

        $null = Get-TestReportLine

        Should -Invoke Write-EpicProgressState -Times 0 -Exactly
        $script:stateWrites.Count | Should -Be 0
    }

    It 'throws before any git call without a passed or stored start' {
        $arguments = $script:reportParameter.Clone()
        $arguments.Remove('StartUtc')

        { Invoke-EpicProgressReport @arguments } | Should -Throw -ExpectedMessage '*-StartUtc*-ResetBaseline*'
        Should -Invoke Invoke-GitExe -Times 0 -Exactly
    }

    It 'uses the stored start when -StartUtc is absent' {
        # 1767603600 is the fixture start, 2026-01-05T09:00:00Z.
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = '{"version":1,"startUnixSeconds":1767603600,"samples":[]}'
        $arguments = $script:reportParameter.Clone()
        $arguments.Remove('StartUtc')
        $arguments['Mode'] = 'TLDR'

        $lines = @(Invoke-EpicProgressReport @arguments)

        ($lines -join "`n") | Should -Be ($script:expectedTldr -join "`n")
    }

    It 'clears stored samples and writes the resolved baseline with -ResetBaseline' {
        # The stored start (08:00 UTC), baseline done, and samples are discarded; the weekly baseline is kept.
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = Get-TestStateText -Start 1767600000 -BaselineDone 1 -Weekly 12.5 -Offset @(600, 30) -Done 18
        $arguments = $script:reportParameter.Clone()
        $arguments.Remove('StartUtc')
        $arguments['ResetBaseline'] = $true

        $null = Invoke-EpicProgressReport @arguments

        $script:stateWrites.Count | Should -Be 1
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        @($written.samples).Count | Should -Be 1
        $written.samples[0].ts | Should -Be $script:fixedNowUnix
        $written.samples[0].done | Should -Be 19
        $written.startUnixSeconds | Should -Be $script:fixedNowUnix
        $written.baselineDone | Should -Be 19
        $written.baselineWeeklyPct | Should -Be 12.5
    }

    It 'keeps the durations ledger and anchors with -ResetBaseline' {
        # Decision D10: the reset clears the samples and the blocked span of #77 and keeps the
        # review duration and the tick anchors.
        $duration = '"durations":{"review":[{"key":"12|review|1","type":"review","seconds":780,"source":"stage_timing","approx":false,"recorded":1767600000}]}'
        $items = $script:anchorItems.Replace('"77":{"plans":{"plan.md":{"checked":[],"lastTickUnixSeconds":1767610000}},"blockedSinceUnixSeconds":null}', '"77":{"plans":{"plan.md":{"checked":[],"lastTickUnixSeconds":1767610000}},"blockedSinceUnixSeconds":1767612000}')
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = Get-TestStateText -Offset @(600) -Extra "$duration,$items"

        $null = Get-TestReportLine -Extra @{ ResetBaseline = $true }

        $script:stateWrites.Count | Should -Be 1
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        @($written.durations.review).Count | Should -Be 1
        $written.durations.review[0].seconds | Should -Be 780
        @($written.items.'12345'.plans.'plan.md'.checked) | Should -Be @('P0-T1')
        $written.items.'12345'.plans.'plan.md'.lastTickUnixSeconds | Should -Be 1767610000
        $written.items.'77'.plans.'plan.md'.lastTickUnixSeconds | Should -Be 1767610000
        $written.items.'77'.blockedSinceUnixSeconds | Should -BeNullOrEmpty
        @($written.samples).Count | Should -Be 1
    }

    It 'rewrites the stored samples in pairs with -PairSamples' {
        # The sample rule adds now to the four stored samples; pairing keeps now, now - 600 and now - 1200.
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = Get-TestStateText -Offset @(1200, 900, 600, 300) -Done 18

        $null = Get-TestReportLine -Extra @{ PairSamples = $true; Mode = 'TLDR' }

        $script:stateWrites.Count | Should -Be 1
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        (@($written.samples.ts) -join ',') | Should -Be "$($script:fixedNowUnix - 1200),$($script:fixedNowUnix - 600),$($script:fixedNowUnix)"
    }

    It 'pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample' {
        # The newest stored sample is 30 seconds old and the anchors match, so only the -PairSamples term of the write condition in Invoke-EpicProgressReport causes the write.
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        # 1767600000 is the stored start, 2026-01-05T08:00:00Z, which differs from the fixture -StartUtc.
        $script:fileText[$script:statePath] = Get-TestStateText -Start 1767600000 -BaselineDone 1 -Weekly 12.5 -Offset @(1230, 930, 630, 330, 30) -Extra $script:anchorItems
        $arguments = $script:reportParameter.Clone()
        $arguments.Remove('StartUtc')
        $arguments['PairSamples'] = $true
        $arguments['Mode'] = 'TLDR'

        $null = Invoke-EpicProgressReport @arguments

        Should -Invoke Write-EpicProgressState -Times 1 -Exactly
        $script:stateWrites.Count | Should -Be 1
        $script:stateWrites[0].Path | Should -Be $script:statePath
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        (@($written.samples.ts) -join ',') | Should -Be "$($script:fixedNowUnix - 1230),$($script:fixedNowUnix - 630),$($script:fixedNowUnix - 30)"
        $written.startUnixSeconds | Should -Be 1767600000
        $written.baselineDone | Should -Be 1
        $written.baselineWeeklyPct | Should -Be 12.5
    }

    It 'throws before any I/O when -ResetBaseline and -PairSamples are combined' {
        { Get-TestReportLine -Extra @{ ResetBaseline = $true; PairSamples = $true } } | Should -Throw -ExpectedMessage '*-ResetBaseline*-PairSamples*'

        Should -Invoke Read-EpicProgressFile -Times 0 -Exactly
        Should -Invoke Test-EpicProgressPath -Times 0 -Exactly
        Should -Invoke Invoke-GitExe -Times 0 -Exactly
    }

    It 'rejects an unknown -StepDefaultMinutes type before any I/O' {
        { Get-TestReportLine -Extra @{ StepDefaultMinutes = @{ deploy = 5 } } } | Should -Throw -ExpectedMessage "*key 'deploy' is not a step type*"

        Should -Invoke Test-EpicProgressPath -Times 0 -Exactly
        Should -Invoke Invoke-GitExe -Times 0 -Exactly
    }

    It 'rejects a non-positive -StepDefaultMinutes value before any I/O' {
        { Get-TestReportLine -Extra @{ StepDefaultMinutes = @{ ci = 0 } } } | Should -Throw -ExpectedMessage "*value for 'ci' must be a number of minutes above 0*"

        Should -Invoke Read-EpicProgressFile -Times 0 -Exactly
        Should -Invoke Invoke-GitExe -Times 0 -Exactly
    }

    It 'prints the Full golden for a legacy four-sample state' {
        # The legacy array (samples at now minus 10800, 7200, 3600, and 60 s with done 0 to 3)
        # counted tasks, so it is migrated: the samples are discarded, the step goldens print,
        # and one version-2 state is written with the current step count as its baseline.
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = "[{`"ts`":$($script:fixedNowUnix - 10800),`"done`":0},{`"ts`":$($script:fixedNowUnix - 7200),`"done`":1},{`"ts`":$($script:fixedNowUnix - 3600),`"done`":2},{`"ts`":$($script:fixedNowUnix - 60),`"done`":3}]"

        $lines = Get-TestReportLine

        $lines.Count | Should -Be ($script:expectedTldr.Count + $script:expectedFull.Count)
        ($lines -join "`n") | Should -Be ((@($script:expectedTldr) + @($script:expectedFull)) -join "`n")
        $script:stateWrites.Count | Should -Be 1
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        $written.version | Should -Be 2
        $written.baselineDone | Should -Be 19
    }
}

Describe 'Get-EpicProgressReport.ps1 repository constraints' {
    BeforeAll {
        # The five canonical files, entry first (issue #1093 split the Logic file into a hub and three files).
        $canonicalFolder = Split-Path -Path $script:scriptPath -Parent
        $script:productionPaths = @(
            (Resolve-Path -LiteralPath $script:scriptPath).ProviderPath
            (Resolve-Path -LiteralPath $script:logicPath).ProviderPath
            (Resolve-Path -LiteralPath (Join-Path -Path $canonicalFolder -ChildPath 'Get-EpicProgressReport.State.ps1')).ProviderPath
            (Resolve-Path -LiteralPath (Join-Path -Path $canonicalFolder -ChildPath 'Get-EpicProgressReport.Metrics.ps1')).ProviderPath
            (Resolve-Path -LiteralPath (Join-Path -Path $canonicalFolder -ChildPath 'Get-EpicProgressReport.Render.ps1')).ProviderPath
        )

        function Get-TestCommandUse {
            # Each command invocation in the five production files with its enclosing function name.
            $uses = [System.Collections.Generic.List[object]]::new()
            foreach ($path in $script:productionPaths) {
                $tokens = $null
                $parseErrors = $null
                $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref] $tokens, [ref] $parseErrors)
                $commands = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)
                foreach ($command in $commands) {
                    $parent = $command.Parent
                    while ($null -ne $parent -and $parent -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) { $parent = $parent.Parent }
                    $functionName = ''
                    if ($null -ne $parent) { $functionName = $parent.Name }
                    $uses.Add([pscustomobject]@{ Name = $command.GetCommandName(); Function = $functionName })
                }
            }
            $uses.ToArray()
        }
    }

    It 'confines file writes to Write-EpicProgressState' {
        $writeCommands = @('Set-Content', 'Add-Content', 'Out-File', 'New-Item', 'Remove-Item', 'Copy-Item', 'Move-Item')
        $uses = @(Get-TestCommandUse)

        $writes = @($uses | Where-Object { $writeCommands -contains $_.Name })

        # Set-Content writes the state file and New-Item creates its missing directory (issue #1093).
        $script:productionPaths.Count | Should -Be 5
        $writes.Count | Should -Be 2
        (@($writes.Name | Sort-Object) -join ',') | Should -Be 'New-Item,Set-Content'
        foreach ($write in $writes) {
            $write.Function | Should -Be 'Write-EpicProgressState' -Because "$($write.Name) may run only in the state writer"
        }
    }

    It 'confines native commands to their wrappers' {
        $wrapperOf = @{ git = 'Invoke-GitExe'; gh = 'Invoke-GhExe'; cswap = 'Invoke-CswapExe' }
        $uses = @(Get-TestCommandUse)

        $native = @($uses | Where-Object { $_.Name -and $wrapperOf.ContainsKey($_.Name) })

        $native.Count | Should -Be 3
        foreach ($use in $native) {
            $use.Function | Should -Be $wrapperOf[$use.Name] -Because "$($use.Name) may run only inside its wrapper"
        }
    }

    It 'contains no recovered hardcoded value' {
        $forbidden = @('documentation-estate-tooling', '1019', '/workspaces', '2026-11-04T13:55')
        # The five canonical files, the scripts/dev-tools forwarder, and the skill text (issue #1093).
        $canonicalFolder = Split-Path -Path $script:scriptPath -Parent
        $scanPaths = @($script:productionPaths) + @(
            (Join-Path -Path $PSScriptRoot -ChildPath '../../../../scripts/dev-tools/Get-EpicProgressReport.ps1')
            (Join-Path -Path (Split-Path -Path $canonicalFolder -Parent) -ChildPath 'SKILL.md')
        )

        $scanPaths.Count | Should -Be 7
        foreach ($path in $scanPaths) {
            Test-Path -LiteralPath $path -PathType Leaf | Should -BeTrue -Because "$path must exist"
            $text = Get-Content -LiteralPath $path -Raw
            foreach ($token in $forbidden) {
                $text.Contains($token) | Should -BeFalse -Because "$path must not contain '$token'"
            }
            # A drive-letter path; the lookbehind keeps a URL scheme such as https:// from matching.
            $text | Should -Not -Match '(?<![A-Za-z])[A-Za-z]:[\\/]'
        }
    }

    It 'documents every parameter in comment-based help' {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:productionPaths[0], [ref] $tokens, [ref] $parseErrors)
        $parameterNames = @($ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })

        $help = Get-Help -Name $script:productionPaths[0] -Full

        $parameterNames.Count | Should -Be 15
        $help.Synopsis | Should -BeLike 'Print the TL;DR block*'
        (($help.description | ForEach-Object { $_.Text }) -join ' ').Trim() | Should -Not -BeNullOrEmpty
        $helpParameters = @($help.parameters.parameter)
        foreach ($name in $parameterNames) {
            $entry = @($helpParameters | Where-Object { $_.name -eq $name }) | Select-Object -First 1
            $entry | Should -Not -BeNullOrEmpty -Because "-$name must be documented"
            (($entry.description | ForEach-Object { $_.Text }) -join ' ').Trim() | Should -Not -BeNullOrEmpty -Because "-$name needs a description"
        }
    }

    It 'carries at least one example' {
        $help = Get-Help -Name $script:productionPaths[0] -Full

        $examples = @($help.examples.example)

        $examples.Count | Should -BeGreaterOrEqual 1
        $examples[0].code | Should -BeLike '*-EpicFolder example-epic*'
    }
}
