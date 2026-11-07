# Pester 5 tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 (issue #1080).
# The script is dot-sourced with its two mandatory parameters bound, so the entry-point
# block is skipped. Every I/O seam is either exercised without side effects (absent
# command, absent path, a read of the script itself, a -WhatIf write) or mocked with a
# matching parameter signature; no test starts git, gh, or cswap, writes a file, or reads
# the clock.

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

        $script:expectedTldr = @(
            '**TL;DR:** Epic #42 is at 3 of 10 tasks (30%). 1 of 3 features are done. #12345 is running (1 of 5).'
            '**Elapsed:** 3 h 00 min, with about 10 hours left on the wave-parallel estimate. **Weekly** quota is at 42.5%.'
            '**Avg Velocity:** 1 tasks / hr. **Recent Velocity:** n/a tasks / hr since last check-in. (SD of recent velocity: n/a, from 0 intervals)'
            '**Estimated time remaining:** 09:30 hrs (range needs 3 or more check-in intervals)'
        )
        $script:expectedFull = @(
            ''
            '## Epic #42 example-epic: status at 12:00 UTC, Jan 5'
            ''
            '**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 3 of 10 tasks complete, **30%**.'
            ''
            '| State | Features |'
            '|---|---|'
            '| Completed | #12 |'
            '| Running | #12345 (wave 2, large): 1 of 5 tasks (20%). Now at: Phase 1 - Build. PR #8 OPEN. |'
            '| Pending, wave 3 | #77 (3) |'
            ''
            '| Wave | Children | Tasks | Done |'
            '|---|---|---|---|'
            '| 1 | 1 | 2 | 2 |'
            '| 2 | 1 | 5 | 1 |'
            '| 3 | 1 | 3 | 0 |'
            '| **Total** | **3** | **10** | **3** |'
            ''
            "**Velocity:** 1 tasks per hour (one child's pace). **Remaining:** 7 tasks."
            '- Straight line, no parallelism: about 7 h 00 min (upper bound).'
            '- Wave-parallel (longest chain 7 tasks plus about 1.25 h per open wave for review and CI): about **9 h 30 min**.'
            "**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
        )

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
        $lines | Should -Contain '| Running | #12345 (wave 2, large): 1 of 5 tasks (20%). Now at: Phase 1 - Build. PR #8 OPEN. |'
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
        $lines | Should -Contain '| Running | #12345 (wave 2, large): 1 of 5 tasks (20%). Now at: Phase 1 - Build. |'
        $lines | Should -Contain '| Completed | #12 |'
    }

    It 'leaves the PR state empty when gh output is unparseable' {
        $script:ghOutput = @{ 'feature/alpha' = 'gh: authentication required'; 'feature/beta' = 'gh: authentication required' }

        $lines = Get-TestReportLine

        $lines | Should -Contain '| Running | #12345 (wave 2, large): 1 of 5 tasks (20%). Now at: Phase 1 - Build. |'
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
        @($written.samples).Count | Should -Be 1
        $written.samples[0].ts | Should -Be $script:fixedNowUnix
        $written.samples[0].done | Should -Be 3
        # 1767603600 is the fixture start, 2026-01-05T09:00:00Z.
        $written.startUnixSeconds | Should -Be 1767603600
        $written.baselineDone | Should -Be 0
    }

    It 'does not write the state file within 90 seconds of the last sample' {
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $script:fileText[$script:statePath] = "[{`"ts`":$($script:fixedNowUnix - 50),`"done`":3}]"

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
        $script:fileText[$script:statePath] = "{`"version`":1,`"startUnixSeconds`":1767600000,`"baselineDone`":1,`"baselineWeeklyPct`":12.5,`"samples`":[{`"ts`":$($script:fixedNowUnix - 600),`"done`":2},{`"ts`":$($script:fixedNowUnix - 30),`"done`":3}]}"
        $arguments = $script:reportParameter.Clone()
        $arguments.Remove('StartUtc')
        $arguments['ResetBaseline'] = $true

        $null = Invoke-EpicProgressReport @arguments

        $script:stateWrites.Count | Should -Be 1
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        @($written.samples).Count | Should -Be 1
        $written.samples[0].ts | Should -Be $script:fixedNowUnix
        $written.samples[0].done | Should -Be 3
        $written.startUnixSeconds | Should -Be $script:fixedNowUnix
        $written.baselineDone | Should -Be 3
        $written.baselineWeeklyPct | Should -Be 12.5
    }

    It 'rewrites the stored samples in pairs with -PairSamples' {
        # The sample rule adds now to the four stored samples; pairing keeps now, now - 600 and now - 1200.
        $script:existingPaths = @($script:checkpointPath, $script:livePlanPath, $script:statePath)
        $stored = @(1200, 900, 600, 300 | ForEach-Object { "{`"ts`":$($script:fixedNowUnix - $_),`"done`":2}" }) -join ','
        $script:fileText[$script:statePath] = "{`"version`":1,`"startUnixSeconds`":1767603600,`"baselineDone`":0,`"baselineWeeklyPct`":0,`"samples`":[$stored]}"

        $null = Get-TestReportLine -Extra @{ PairSamples = $true; Mode = 'TLDR' }

        $script:stateWrites.Count | Should -Be 1
        $written = ConvertFrom-Json -InputObject $script:stateWrites[0].Content
        (@($written.samples.ts) -join ',') | Should -Be "$($script:fixedNowUnix - 1200),$($script:fixedNowUnix - 600),$($script:fixedNowUnix)"
    }

    It 'throws before any I/O when -ResetBaseline and -PairSamples are combined' {
        { Get-TestReportLine -Extra @{ ResetBaseline = $true; PairSamples = $true } } | Should -Throw -ExpectedMessage '*-ResetBaseline*-PairSamples*'

        Should -Invoke Read-EpicProgressFile -Times 0 -Exactly
        Should -Invoke Test-EpicProgressPath -Times 0 -Exactly
        Should -Invoke Invoke-GitExe -Times 0 -Exactly
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

        foreach ($path in $script:productionPaths) {
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
