# Pester tests for the Item parameter set of .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 (issue #1118).
# The script is dot-sourced with -EpicFolder and a fixed -StartUtc, so the entry-point block is
# skipped. Every I/O seam is mocked with a matching parameter signature over in-memory fixtures:
# no test starts git, gh, or cswap, reads or writes a file, or reads the clock.

BeforeAll {
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1'
    . $script:scriptPath -EpicFolder 'example-epic' -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc))
}

Describe 'Invoke-EpicProgressReport in item mode' {
    BeforeAll {
        $script:worktree = '/fixture-repo-wt/item'
        $script:checkpointPath = Join-Path -Path $script:worktree -ChildPath 'artifacts/orchestration/orchestrator-state.json'
        $script:planPath = Join-Path -Path $script:worktree -ChildPath 'docs/features/active/x/plan.md'
        $script:specPath = Join-Path -Path $script:worktree -ChildPath 'docs/features/active/x/spec.md'
        # Research 09:00-09:10, spec 09:10-09:15, planning 09:15-09:25, preflight 09:25-09:35,
        # execution 09:35-10:35 (four tasks, all checked), and an open review since 11:50.
        $script:stageTiming = '{"stage":"research","attempt":1,"started_at":"2026-01-05T09:00:00Z","ended_at":"2026-01-05T09:10:00Z"},' +
        '{"stage":"spec","attempt":1,"started_at":"2026-01-05T09:10:00Z","ended_at":"2026-01-05T09:15:00Z"},' +
        '{"stage":"planning","attempt":1,"started_at":"2026-01-05T09:15:00Z","ended_at":"2026-01-05T09:25:00Z"},' +
        '{"stage":"preflight","attempt":1,"started_at":"2026-01-05T09:25:00Z","ended_at":"2026-01-05T09:35:00Z"},' +
        '{"stage":"execution","attempt":1,"started_at":"2026-01-05T09:35:00Z","ended_at":"2026-01-05T10:35:00Z"}'
        $script:openReview = '{"stage":"review","attempt":1,"started_at":"2026-01-05T11:50:00Z","ended_at":null}'
        $script:itemCheckpoint = '{"issue-num":"1118","feature-folder":"docs/features/active/x","plan-path":"docs/features/active/x/plan.md","next_step":"S7_feature_review","stage_timing":[' + $script:stageTiming + ',' + $script:openReview + ']}'
        $script:startUtc = [datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)
        # 2026-01-05T12:00:00Z.
        $script:noon = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)

        function Get-TestItemLine {
            param([hashtable] $Extra = @{})
            $arguments = @{ Issue = 1118; StartUtc = $script:startUtc; RepositoryRoot = '/fixture-repo' }
            foreach ($key in $Extra.Keys) { $arguments[$key] = $Extra[$key] }
            @(Invoke-EpicProgressReport @arguments)
        }
    }

    BeforeEach {
        $script:gitCalls = [System.Collections.Generic.List[string]]::new()
        $script:readPaths = [System.Collections.Generic.List[string]]::new()
        $script:stateWrites = [System.Collections.Generic.List[object]]::new()
        $script:now = $script:noon
        $script:fileText = @{
            $script:checkpointPath = $script:itemCheckpoint
            $script:planPath       = "### Phase 0 - Setup`n- [x] [P0-T1] a.`n- [x] [P0-T2] b.`n- [x] [P1-T1] c.`n- [x] [P1-T2] d."
            $script:specPath       = '# spec'
        }
        Mock Invoke-GitExe {
            param([string[]] $GitArgs)
            $script:gitCalls.Add(($GitArgs -join ' '))
            if ($GitArgs[0] -eq 'worktree') { return @('worktree /fixture-repo', 'branch refs/heads/main', '', "worktree $($script:worktree)", 'branch refs/heads/feature/item') }
        }
        Mock Invoke-GhExe { param([string[]] $GhArgs) $null = $GhArgs }
        Mock Invoke-CswapExe { param([string[]] $CswapArgs) $null = $CswapArgs }
        Mock Test-EpicProgressCommand { param([string] $Name) $null = $Name; return $false }
        Mock Test-EpicProgressPath { param([string] $Path) return $script:fileText.ContainsKey($Path) }
        Mock Read-EpicProgressFile { param([string] $Path) $script:readPaths.Add($Path); return $script:fileText[$Path] }
        Mock Write-EpicProgressState { param([string] $Path, [string] $Content) $script:stateWrites.Add([pscustomobject]@{ Path = $Path; Content = $Content }) }
        Mock Get-EpicProgressUtcNow { return $script:now }
        Mock Get-EpicProgressLastExitCode { return 0 }
    }

    It 'reports one item in item mode without reading a kickoff or epic checkpoint' {
        $lines = Get-TestItemLine -Extra @{ Mode = 'TLDR' }

        ($script:gitCalls -join "`n") | Should -Be 'worktree list --porcelain'
        @($script:readPaths | Where-Object { $_ -like '*epic-orchestrator-state.json' -or $_ -like '*epic-kickoff.md' }).Count | Should -Be 0
        $lines[0] | Should -BeLike '**TL;DR:** Item #1118 is at *'
        $lines.Count | Should -Be 4
    }

    It 'includes no epic-level step in item mode' {
        $lines = Get-TestItemLine

        @($lines | Where-Object { $_ -like '| integration-pr |*' -or $_ -like '| main-sync |*' -or $_ -like '| Epic |*' }).Count | Should -Be 0
        $lines | Should -Contain '## Item #1118: status at 12:00 UTC, Jan 5'
    }

    It 'uses the item state path by default' {
        $null = Get-TestItemLine -Extra @{ Mode = 'TLDR' }

        $script:stateWrites.Count | Should -Be 1
        $script:stateWrites[0].Path | Should -Be (Join-Path -Path '/fixture-repo' -ChildPath '.claude' -AdditionalChildPath 'state', 'progress-item-1118.json')
        (ConvertFrom-Json -InputObject $script:stateWrites[0].Content).version | Should -Be 2
    }

    It 'places -EpicFolder and -Issue in different parameter sets' {
        foreach ($command in @((Get-Command -Name $script:scriptPath), (Get-Command -Name 'Invoke-EpicProgressReport'))) {
            (@($command.Parameters['EpicFolder'].ParameterSets.Keys) -join ',') | Should -Be 'Epic'
            (@($command.Parameters['Issue'].ParameterSets.Keys) -join ',') | Should -Be 'Item'
            $command.Parameters['EpicFolder'].ParameterSets['Epic'].IsMandatory | Should -BeTrue
            $command.Parameters['Issue'].ParameterSets['Item'].IsMandatory | Should -BeTrue
        }
    }

    It 'rejects -EpicFolder combined with -Issue' {
        { Invoke-EpicProgressReport -EpicFolder 'example-epic' -Issue 1118 -StartUtc $script:startUtc } | Should -Throw -ExpectedMessage '*Parameter set cannot be resolved*'

        Should -Invoke Test-EpicProgressPath -Times 0 -Exactly
        Should -Invoke Invoke-GitExe -Times 0 -Exactly
    }

    It 'prints the four TL;DR lines in item mode' {
        # 12 steps: research, spec, plan, preflight, four tasks (all done), review (in progress),
        # pr, ci, and merge: 8 of 12 (66.7%). Medians from the closed stages; review, pr, ci, and
        # merge use defaults (4 of 9 types). Remaining: review 14 - 10 elapsed = 4 min, pr 3,
        # ci 17, merge 5: 29 min (0.48 h), and the item's wave-parallel figure is the same sum.
        $lines = Get-TestItemLine -Extra @{ Mode = 'TLDR' }

        $expected = @(
            '**TL;DR:** Item #1118 is at 8 of 12 steps (66.7%). #1118 is not done yet. #1118 is running (8 of 12 steps).'
            '**Elapsed:** 3 h 00 min, with about 0.5 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at n/a.'
            '**Now:** #1118 review (0 h 10 min of median 0 h 14 min). 4 of 9 types use defaults.'
            '**Estimated time remaining:** 0 h 29 min by type (sum); 0 h 29 min wave-parallel.'
        )
        ($lines -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'counts review and ci steps from an item checkpoint' {
        # Review closed 10:40-10:55 (15 min), pr 10:55-11:00, ci attempt 1 closed 11:00-11:20
        # (20 min), and ci attempt 2 open since 11:40: two ci steps, the second credited
        # max(0, 20 - 20) = 0 min.
        $ci = '{"stage":"review","attempt":1,"started_at":"2026-01-05T10:40:00Z","ended_at":"2026-01-05T10:55:00Z"},' +
        '{"stage":"pr","attempt":1,"started_at":"2026-01-05T10:55:00Z","ended_at":"2026-01-05T11:00:00Z"},' +
        '{"stage":"ci","attempt":1,"started_at":"2026-01-05T11:00:00Z","ended_at":"2026-01-05T11:20:00Z"},' +
        '{"stage":"ci","attempt":2,"started_at":"2026-01-05T11:40:00Z","ended_at":null}'
        $script:fileText[$script:checkpointPath] = '{"issue-num":"1118","plan-path":"docs/features/active/x/plan.md","stage_timing":[' + $script:stageTiming + ',' + $ci + ']}'

        $lines = Get-TestItemLine

        $lines | Should -Contain '| review | 1 | 0 | 0 | 0 | 0 h 15 min | 1 | 0 h 00 min |'
        $lines | Should -Contain '| ci | 1 | 1 | 0 | 0 | 0 h 20 min | 1 | 0 h 00 min |'
        $lines[2] | Should -Be '**Now:** #1118 ci (0 h 20 min of median 0 h 20 min). 1 of 9 types use defaults.'
    }

    It 'shows an in-progress review on the Now line' {
        $lines = Get-TestItemLine -Extra @{ Mode = 'TLDR' }

        $lines[2] | Should -BeLike '**Now:** #1118 review (0 h 10 min of median 0 h 14 min).*'
    }

    It 'reports a lower remaining estimate on a later run with no new checked task' {
        # At 12:05 the review has run 15 min, over its 14-min median: no credit, 25 min remain.
        $first = Get-TestItemLine -Extra @{ Mode = 'TLDR' }
        $script:now = $script:noon.AddMinutes(5)
        $second = Get-TestItemLine -Extra @{ Mode = 'TLDR' }

        $first[3] | Should -Be '**Estimated time remaining:** 0 h 29 min by type (sum); 0 h 29 min wave-parallel.'
        $second[3] | Should -Be '**Estimated time remaining:** 0 h 25 min by type (sum); 0 h 25 min wave-parallel.'
        $second[2] | Should -BeLike '**Now:** #1118 review (0 h 15 min of median 0 h 14 min, over median).*'
    }

    It 'does not report a stalled item as blocked on a later run' {
        # The second run, an hour later, sees the same four checked tasks (a zero tick rate).
        $first = Get-TestItemLine
        $script:now = $script:noon.AddHours(1)
        $second = Get-TestItemLine

        foreach ($lines in @(, $first) + @(, $second)) {
            ($lines -join "`n") | Should -Not -Match 'is blocked'
            $lines | Should -Contain '| Blocked | None |'
            @($lines | Where-Object { $_ -like '| **Total** | **8** | **1** | **3** | **0** |*' }).Count | Should -Be 1
        }
    }

    It 'binds the -EpicFolder TLDR and Full invocation shapes' {
        # '-EpicFolder documentation-estate-tooling -Mode TLDR' and '-EpicFolder <folder>' (Full)
        # bind to the default Epic set: every parameter they name is in it, and -EpicFolder is in no other set.
        $command = Get-Command -Name $script:scriptPath
        $epicSet = @($command.ParameterSets | Where-Object { $_.Name -eq 'Epic' })[0]
        $itemSet = @($command.ParameterSets | Where-Object { $_.Name -eq 'Item' })[0]

        $epicSet.IsDefault | Should -BeTrue
        @($epicSet.Parameters.Name) | Should -Contain 'EpicFolder'
        @($epicSet.Parameters.Name) | Should -Contain 'Mode'
        @($itemSet.Parameters.Name) | Should -Not -Contain 'EpicFolder'
        (@($epicSet.Parameters | Where-Object { $_.IsMandatory } | ForEach-Object { $_.Name }) -join ',') | Should -Be 'EpicFolder'
    }

    It 'keeps the name, type, default, mandatory status and validation of every existing parameter' {
        $expected = @(
            'EpicFolder|System.String||True|[ValidateNotNullOrEmpty()]'
            'StartUtc|System.DateTime||False|'
            "EpicIssue|System.String|''|False|"
            "IntegrationBranch|System.String|''|False|"
            "KickoffPath|System.String|''|False|"
            "RepositoryRoot|System.String|''|False|"
            "CheckpointPath|System.String|''|False|"
            "StatePath|System.String|''|False|"
            'BaselineDone|System.Int32|0|False|'
            'BaselineWeeklyPct|System.Double|0|False|'
            'WaveOverheadHours|System.Double|1.25|False|'
            'SampleCap|System.Int32|14|False|[ValidateRange(1, 100000)]'
            "Mode|System.String|'Full'|False|[ValidateSet('TLDR', 'Full')]"
            'ResetBaseline|System.Management.Automation.SwitchParameter||False|'
            'PairSamples|System.Management.Automation.SwitchParameter||False|'
        )
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $script:scriptPath).ProviderPath, [ref] $tokens, [ref] $parseErrors)

        $actual = @($ast.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -notin @('Issue', 'StepDefaultMinutes') } | ForEach-Object {
                $parameterAttribute = @($_.Attributes | Where-Object { $_.TypeName.Name -eq 'Parameter' })
                $mandatory = [bool] @($parameterAttribute.NamedArguments | Where-Object { $_.ArgumentName -eq 'Mandatory' }).Count
                $default = ''
                if ($null -ne $_.DefaultValue) { $default = $_.DefaultValue.Extent.Text }
                $validation = (@($_.Attributes | Where-Object { $_.TypeName.Name -like 'Validate*' } | ForEach-Object { $_.Extent.Text }) -join '')
                "$($_.Name.VariablePath.UserPath)|$($_.StaticType.FullName)|$default|$mandatory|$validation"
            })

        $parseErrors.Count | Should -Be 0
        $actual.Count | Should -Be 15
        ($actual -join "`n") | Should -Be ($expected -join "`n")
    }
}
