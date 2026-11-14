# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1 and the
# critical chain of Get-EpicProgressReport.CriticalPath.ps1 (issue #1153).
# The Logic hub is dot-sourced, which dot-sources both files; every function under test is
# pure, so each test supplies fixed in-memory input and asserts the returned data. Durations are in
# seconds (3600 per hour), and golden values are derived by hand in the comments.

BeforeAll {
    $script:scriptFolder = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts'
    . (Join-Path -Path $script:scriptFolder -ChildPath 'Get-EpicProgressReport.Logic.ps1')

    function Get-TestFeature {
        # One kickoff feature for the graph builder.
        param([string] $Issue, [int] $Wave, [string] $Folder = '', [bool] $Merged = $false)
        [pscustomobject]@{ Issue = $Issue; Wave = $Wave; Folder = $Folder; Merged = $Merged }
    }

    function Get-TestRow {
        # One checkpoint or manifest row; omit -DependsOn to leave out the depends_on key.
        param([object] $Issue, [string] $Folder = '', [object[]] $DependsOn, [switch] $NoKey)
        $row = [ordered]@{ issue_num = $Issue; feature_folder = $Folder }
        if (-not $NoKey) { $row['depends_on'] = [object[]] @($DependsOn) }
        [pscustomobject] $row
    }

    function ConvertTo-TestEdgeText {
        # The dependencies as 'issue:dep,dep' entries in ascending issue order, joined by '; '.
        param([hashtable] $DependsOn)
        (@($DependsOn.Keys | Sort-Object { [int] $_ } | ForEach-Object { "$($_):$(@($DependsOn[$_]) -join ',')" }) -join '; ')
    }

    # Three features in two waves with folder names, used by the source rules.
    $script:three = @(
        Get-TestFeature -Issue '101' -Wave 1 -Folder 'f-a'
        Get-TestFeature -Issue '102' -Wave 1 -Folder 'f-b'
        Get-TestFeature -Issue '103' -Wave 2 -Folder 'f-c'
    )
    # Five features in waves 1, 2, and 3 for the waves-edge case.
    $script:five = @(
        Get-TestFeature -Issue '101' -Wave 1
        Get-TestFeature -Issue '102' -Wave 1
        Get-TestFeature -Issue '103' -Wave 2
        Get-TestFeature -Issue '104' -Wave 2
        Get-TestFeature -Issue '105' -Wave 3
    )
    $script:fiveWaveEdges = '101:; 102:; 103:101,102; 104:101,102; 105:103,104'
}

Describe 'Resolve-EpicProgressParallelCap (AC-31)' {
    It 'uses a checkpoint value of <Value>' -ForEach @(@{ Value = 1 }, @{ Value = 8 }) {
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue ([long] $Value) -ConfigValue 3

        $cap.Cap | Should -Be $Value
        $cap.Source | Should -Be 'checkpoint'
    }

    It 'falls back to the config value for checkpoint value <Label>' -ForEach @(
        @{ Label = '0'; Value = 0 }
        @{ Label = '9'; Value = 9 }
        @{ Label = '2.5'; Value = 2.5 }
        @{ Label = 'text 4'; Value = '4' }
        @{ Label = 'missing'; Value = $null }
    ) {
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue $Value -ConfigValue 3

        $cap.Cap | Should -Be 3
        $cap.Source | Should -Be 'config'
    }

    It 'uses the built-in 4 when the config value is <Label>' -ForEach @(
        @{ Label = 'missing'; Value = $null }
        @{ Label = 'invalid'; Value = 0 }
        @{ Label = 'text'; Value = 'four' }
    ) {
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue $null -ConfigValue $Value

        $cap.Cap | Should -Be 4
        $cap.Source | Should -Be 'built-in'
    }
}

Describe 'Get-EpicProgressDependencyGraph sources (AC-32, E5)' {
    It 'uses a checkpoint key over a manifest list for the same feature' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(101)) -ManifestRow @(Get-TestRow -Issue 103 -DependsOn @(102))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:; 103:101'
        $graph.Source | Should -Be 'checkpoint'
        $graph.Message | Should -BeNullOrEmpty
    }

    It 'reports checkpoint+manifest when the keys come from both sources' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(101)) -ManifestRow @(Get-TestRow -Issue 102 -DependsOn @(101))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:101; 103:101'
        $graph.Source | Should -Be 'checkpoint+manifest'
    }

    It 'uses a manifest key present for one feature only, not the waves' {
        # Waves would give 103 the edges 101 and 102; the manifest gives 103 only 102.
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -NoKey) -ManifestRow @(Get-TestRow -Issue 103 -DependsOn @(102))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:; 103:102'
        $graph.Source | Should -Be 'manifest'
    }

    It 'gives no edge for an explicit empty list and the waves for a missing key everywhere' {
        $empty = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @())
        $missing = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -NoKey) -ManifestRow @(Get-TestRow -Issue 102 -NoKey)

        ConvertTo-TestEdgeText -DependsOn $empty.DependsOn | Should -Be '101:; 102:; 103:'
        $empty.Source | Should -Be 'checkpoint'
        ConvertTo-TestEdgeText -DependsOn $missing.DependsOn | Should -Be '101:; 102:; 103:101,102'
        $missing.Source | Should -Be 'waves'
    }

    It 'resolves a reference by issue number and by feature-folder hint' {
        # 103 names 101 by number; 102 names f-a through a lifecycle path; a row matched by folder names 'f-b'.
        $rows = @(
            Get-TestRow -Issue 103 -DependsOn @(101)
            Get-TestRow -Issue 102 -DependsOn @('docs/features/active/f-a')
            Get-TestRow -Issue $null -Folder 'completed/f-a' -DependsOn @()
        )

        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow $rows

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:101; 103:101'
        $graph.Message | Should -BeNullOrEmpty
    }

    It 'reports an unresolved reference that matches neither an issue nor a folder' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @('f-zzz'))

        $graph.Message | Should -BeLike "unresolved dependency reference: #103 depends on 'f-zzz'*"
    }

    It 'gives no edge for a reference to a merged feature' {
        $features = @(
            Get-TestFeature -Issue '101' -Wave 1 -Folder 'f-a' -Merged $true
            Get-TestFeature -Issue '103' -Wave 2 -Folder 'f-c'
        )

        $graph = Get-EpicProgressDependencyGraph -Feature $features -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(101))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 103:'
        $graph.Source | Should -Be 'checkpoint'
    }
}

Describe 'Get-EpicProgressDependencyGraph waves fallback (E5)' {
    It 'links each feature to every feature of the next lower wave only' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:five

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be $script:fiveWaveEdges
        $graph.Source | Should -Be 'waves'
        $graph.Message | Should -BeNullOrEmpty
    }

    It 'links to the nearest lower wave when a wave number is skipped' {
        # Waves 1 and 3 only: each wave-3 feature depends on every wave-1 feature.
        $features = @(
            Get-TestFeature -Issue '101' -Wave 1
            Get-TestFeature -Issue '102' -Wave 1
            Get-TestFeature -Issue '105' -Wave 3
            Get-TestFeature -Issue '106' -Wave 3
        )

        $graph = Get-EpicProgressDependencyGraph -Feature $features

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:; 105:101,102; 106:101,102'
        $graph.Source | Should -Be 'waves'
    }
}

Describe 'Get-EpicProgressDependencyGraph invalid graphs (AC-33)' {
    It 'reports a <Kind> with a distinct message and falls back to the waves' -ForEach @(
        @{ Kind = 'self-loop'; Rows = @(@{ Issue = 103; DependsOn = @(103) }); Expected = 'dependency self-loop: #103 depends on itself*' }
        @{ Kind = 'unresolved reference'; Rows = @(@{ Issue = 103; DependsOn = @('f-zzz') }); Expected = "unresolved dependency reference: #103 depends on 'f-zzz'*" }
        @{ Kind = 'cycle'; Rows = @(@{ Issue = 101; DependsOn = @(103) }, @{ Issue = 103; DependsOn = @(101) }); Expected = 'dependency cycle: #101 -> #103 -> #101*' }
    ) {
        $rows = @($Rows | ForEach-Object { Get-TestRow -Issue $_.Issue -DependsOn $_.DependsOn })

        { $script:graphResult = Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow $rows } | Should -Not -Throw
        $graph = $script:graphResult

        $graph.Message | Should -BeLike $Expected
        $graph.Message | Should -BeLike '*the schedule falls back to waves'
        $graph.Source | Should -Be 'waves'
        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be $script:fiveWaveEdges
    }

    It 'gives three different messages for the three defects' {
        $messages = @(
            (Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(103))).Message
            (Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @('f-zzz'))).Message
            (Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow @(Get-TestRow -Issue 101 -DependsOn @(103); Get-TestRow -Issue 103 -DependsOn @(101))).Message
        )

        @($messages | Sort-Object -Unique).Count | Should -Be 3
    }
}

Describe 'Velocity and Schedule purity (AC-50, E6, E14)' {
    It 'calls no I/O seam and reads no clock in the Velocity and Schedule files' {
        $forbidden = @('Get-EpicProgressUtcNow', 'Read-EpicProgressFile', 'Test-EpicProgressPath', 'Write-EpicProgressState', 'Invoke-GitExe', 'Invoke-GhExe', 'Invoke-CswapExe', 'Get-Date', 'Import-Module')
        foreach ($name in @('Get-EpicProgressReport.Velocity.ps1', 'Get-EpicProgressReport.Schedule.ps1', 'Get-EpicProgressReport.CriticalPath.ps1')) {
            $path = Join-Path -Path $script:scriptFolder -ChildPath $name
            $tokens = $null
            $parseErrors = $null

            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref] $tokens, [ref] $parseErrors)
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))

            $parseErrors.Count | Should -Be 0 -Because "$name must parse"
            $commands.Count | Should -BeGreaterThan 0 -Because "$name must hold commands to check"
            foreach ($command in $commands) {
                $forbidden | Should -Not -Contain $command.GetCommandName() -Because "$name must stay host-neutral"
                if ($command.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot) {
                    $command.Extent.Text | Should -BeLike '*$PSScriptRoot*' -Because "$name may dot-source only its own folder"
                }
            }
            $ast.UsingStatements.Count | Should -Be 0 -Because "$name must not use a module"
        }
    }
}

Describe 'Invoke-EpicProgressListSchedule and Get-EpicProgressCriticalChain (E6)' {
    BeforeAll {
        function Get-TestNode {
            # One schedule node with a duration in hours.
            param([string] $Issue, [double] $Hours, [string] $State = 'pending', [string[]] $DependsOn = @())
            [pscustomobject]@{ Issue = $Issue; State = $State; DurationSeconds = 3600 * $Hours; DependsOn = $DependsOn }
        }

        function Get-TestRowOf {
            # The schedule row of one issue.
            param([object] $Schedule, [string] $Issue)
            @($Schedule.Feature | Where-Object { $_.Issue -eq $Issue })[0]
        }

        $script:diamond = @(
            Get-TestNode -Issue 'A' -Hours 1
            Get-TestNode -Issue 'B' -Hours 2 -DependsOn @('A')
            Get-TestNode -Issue 'C' -Hours 3 -DependsOn @('A')
            Get-TestNode -Issue 'D' -Hours 1 -DependsOn @('B', 'C')
        )
        $script:fourIndependent = @(1..4 | ForEach-Object { Get-TestNode -Issue "20$_" -Hours $_ })
    }

    It 'schedules the serial chain A -> B -> C with a 1-hour tail at 7 h (AC-24)' {
        # 1 + 2 + 3 = 6 h of features, plus the 1 h tail.
        $nodes = @(Get-TestNode -Issue 'A' -Hours 1; Get-TestNode -Issue 'B' -Hours 2 -DependsOn @('A'); Get-TestNode -Issue 'C' -Hours 3 -DependsOn @('B'))

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 4 -TailSeconds 3600

        $schedule.HeadlineSeconds | Should -Be (7 * 3600)
        Get-EpicProgressCriticalChain -Schedule $schedule | Should -Be '#A -> #B -> #C -> tail'
    }

    It 'schedules the diamond at 5 h with cap 4 and 7 h with cap 1 (AC-25)' {
        # Cap 4: A 0-1, B 1-3, C 1-4, D 4-5; D waited for C, which finished last.
        # Cap 1: paths A 5, C 4, B 3, D 1, so A 0-1, C 1-4, B 4-6, D 6-7.
        $wide = Invoke-EpicProgressListSchedule -Node $script:diamond -Cap 4
        $narrow = Invoke-EpicProgressListSchedule -Node $script:diamond -Cap 1

        $wide.HeadlineSeconds | Should -Be (5 * 3600)
        Get-EpicProgressCriticalChain -Schedule $wide | Should -Be '#A -> #C -> #D -> tail'
        $narrow.HeadlineSeconds | Should -Be (7 * 3600)
        (Get-TestRowOf -Schedule $narrow -Issue 'B').StartSeconds | Should -Be (4 * 3600)
    }

    It 'schedules four independent features at 10, 5 and 4 h for caps 1, 2 and 4 (AC-26)' {
        # Cap 2: 4 h and 3 h start at 0; 2 h starts at 3 h and 1 h at 4 h; both end at 5 h.
        (Invoke-EpicProgressListSchedule -Node $script:fourIndependent -Cap 1).HeadlineSeconds | Should -Be (10 * 3600)
        (Invoke-EpicProgressListSchedule -Node $script:fourIndependent -Cap 2).HeadlineSeconds | Should -Be (5 * 3600)
        (Invoke-EpicProgressListSchedule -Node $script:fourIndependent -Cap 4).HeadlineSeconds | Should -Be (4 * 3600)
    }

    It 'schedules three 1-hour features at cap <Cap> in <Hours> h (AC-27)' -ForEach @(
        @{ Cap = 4; Hours = 1 }
        @{ Cap = 3; Hours = 1 }
        @{ Cap = 2; Hours = 2 }
    ) {
        $nodes = @(101..103 | ForEach-Object { Get-TestNode -Issue "$_" -Hours 1 })

        (Invoke-EpicProgressListSchedule -Node $nodes -Cap $Cap).HeadlineSeconds | Should -Be ($Hours * 3600)
    }

    It 'names the feature whose finish freed the slot at cap 2 (AC-27, AC-29)' {
        # 101 and 102 run 0-1 h; 103 starts at 1 h, delayed by 101 (the lower issue of the two finishing at 1 h).
        $nodes = @(101..103 | ForEach-Object { Get-TestNode -Issue "$_" -Hours 1 })

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 2

        (Get-TestRowOf -Schedule $schedule -Issue '101').FinishSeconds | Should -Be 3600
        (Get-TestRowOf -Schedule $schedule -Issue '102').FinishSeconds | Should -Be 3600
        (Get-TestRowOf -Schedule $schedule -Issue '103').StartSeconds | Should -Be 3600
        (Get-TestRowOf -Schedule $schedule -Issue '103').Predecessor | Should -Be '101'
        Get-EpicProgressCriticalChain -Schedule $schedule | Should -Be '#101 -> #103 -> tail'
    }

    It 'keeps running features beyond the cap and starts a ready feature below it (AC-28)' {
        # Three running features of 1, 2 and 3 h at cap 2: at 1 h two still run, so the pending feature starts at 2 h.
        $nodes = @(
            Get-TestNode -Issue '301' -Hours 1 -State 'running'
            Get-TestNode -Issue '302' -Hours 2 -State 'running'
            Get-TestNode -Issue '303' -Hours 3 -State 'running'
            Get-TestNode -Issue '304' -Hours 1
        )

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 2

        @('301', '302', '303' | ForEach-Object { (Get-TestRowOf -Schedule $schedule -Issue $_).StartSeconds }) | Should -Be @(0, 0, 0)
        (Get-TestRowOf -Schedule $schedule -Issue '304').StartSeconds | Should -Be (2 * 3600)
        (Get-TestRowOf -Schedule $schedule -Issue '304').Predecessor | Should -Be '302'
        $schedule.HeadlineSeconds | Should -Be (3 * 3600)
    }

    It 'starts the longest remaining path first and breaks ties by ascending issue number (AC-29)' {
        # Cap 1: 402 and 403 both have a 3 h path and 401 a 1 h path, so the order is 402, 403, 401.
        $nodes = @(Get-TestNode -Issue '403' -Hours 3; Get-TestNode -Issue '401' -Hours 1; Get-TestNode -Issue '402' -Hours 3)

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 1

        (Get-TestRowOf -Schedule $schedule -Issue '402').StartSeconds | Should -Be 0
        (Get-TestRowOf -Schedule $schedule -Issue '403').StartSeconds | Should -Be (3 * 3600)
        (Get-TestRowOf -Schedule $schedule -Issue '401').StartSeconds | Should -Be (6 * 3600)
    }

    It 'finishes done features at 0 without holding a slot and satisfies a dependency on them (AC-30)' {
        $nodes = @(
            Get-TestNode -Issue '501' -Hours 0 -State 'done'
            Get-TestNode -Issue '502' -Hours 0 -State 'done'
            Get-TestNode -Issue '503' -Hours 2 -DependsOn @('501')
        )

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 1

        (Get-TestRowOf -Schedule $schedule -Issue '501').FinishSeconds | Should -Be 0
        (Get-TestRowOf -Schedule $schedule -Issue '503').StartSeconds | Should -Be 0
        $schedule.HeadlineSeconds | Should -Be (2 * 3600)
    }

    It 'satisfies a dependency on an issue that is not a node' {
        $schedule = Invoke-EpicProgressListSchedule -Node @(Get-TestNode -Issue '601' -Hours 1 -DependsOn @('600')) -Cap 1

        (Get-TestRowOf -Schedule $schedule -Issue '601').StartSeconds | Should -Be 0
        (Get-TestRowOf -Schedule $schedule -Issue '601').Predecessor | Should -BeNullOrEmpty
    }

    It 'gives a NaN finish to a node that can never start' {
        $nodes = @(Get-TestNode -Issue '701' -Hours 1 -DependsOn @('702'); Get-TestNode -Issue '702' -Hours 1 -DependsOn @('701'))

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 2

        [double]::IsNaN($schedule.FinishSeconds) | Should -BeTrue
        Format-EpicProgressHour -Hours ($schedule.HeadlineSeconds / 3600) | Should -Be 'n/a'
    }

    It 'equals the serial sum at cap 1 and never exceeds it at any cap (AC-37)' {
        # Serial sums: diamond 1 + 2 + 3 + 1 = 7 h; four independent 1 + 2 + 3 + 4 = 10 h.
        foreach ($case in @(@{ Nodes = $script:diamond; Serial = 7 }, @{ Nodes = $script:fourIndependent; Serial = 10 })) {
            (Invoke-EpicProgressListSchedule -Node $case.Nodes -Cap 1 -TailSeconds 1800).HeadlineSeconds | Should -Be ($case.Serial * 3600 + 1800)
            foreach ($cap in 1..5) {
                (Invoke-EpicProgressListSchedule -Node $case.Nodes -Cap $cap -TailSeconds 1800).HeadlineSeconds | Should -BeLessOrEqual ($case.Serial * 3600 + 1800)
            }
        }
    }

    It 'finishes five equal running features at cap 5 together (US-02)' {
        # Five running features of 1 h each run side by side: 1 h, not the 5 h serial sum.
        $nodes = @(801..805 | ForEach-Object { Get-TestNode -Issue "$_" -Hours 1 -State 'running' })

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 5

        $schedule.HeadlineSeconds | Should -Be 3600
        Get-EpicProgressCriticalChain -Schedule $schedule | Should -Be '#801 -> tail'
        Get-EpicProgressCriticalChain -Schedule $schedule -NoTail | Should -Be '#801'
    }
}

Describe 'Get-EpicProgressBlockedClosure (AC-34, E7)' {
    It 'excludes a blocked feature and its transitive dependent and keeps an independent feature' {
        # 902 depends on 901 and 903 on 902; 904 depends on nothing.
        $dependsOn = @{ '901' = @(); '902' = @('901'); '903' = @('902'); '904' = @() }

        $closure = @(Get-EpicProgressBlockedClosure -Blocked @('901') -DependsOn $dependsOn)

        $closure | Should -Be @('901', '902', '903')
        $closure | Should -Not -Contain '904'
        @(Get-EpicProgressBlockedClosure -Blocked @() -DependsOn $dependsOn).Count | Should -Be 0
    }
}

Describe 'Cross-epic external nodes in the schedule (issue #1162)' {
    It 'starts the local node at time 0 under cap 1 while a pending external node runs' {
        # The external node holds no slot, so the cap-1 local node does not wait for it.
        $nodes = @(
            [pscustomobject]@{ Issue = 'provider-epic#1188'; State = 'pending'; DurationSeconds = 7200; DependsOn = [string[]] @(); External = $true }
            [pscustomobject]@{ Issue = '1201'; State = 'pending'; DurationSeconds = 3600; DependsOn = [string[]] @() }
        )

        $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap 1

        $local = @($schedule.Feature | Where-Object Issue -EQ '1201')[0]
        $external = @($schedule.Feature | Where-Object Issue -EQ 'provider-epic#1188')[0]
        "$($local.StartSeconds)|$($external.StartSeconds)" | Should -BeExactly '0|0'
        $schedule.FinishSeconds | Should -Be 7200
    }

    It 'orders <Left> <Relation> <Right>' -ForEach @(
        @{ Left = '0-alpha#12'; Right = '1201'; Relation = 'after'; Sign = 1 }
        @{ Left = '0-alpha#12'; Right = '5'; Relation = 'after'; Sign = 1 }
        @{ Left = '5'; Right = '0-alpha#12'; Relation = 'before'; Sign = -1 }
        @{ Left = 'alpha#3'; Right = '0-alpha#12'; Relation = 'after'; Sign = 1 }
    ) {
        [math]::Sign((Compare-EpicProgressIssue -Left $Left -Right $Right)) | Should -Be $Sign
    }

    It 'returns a blocked local feature without the external node it depends on' {
        $closure = @(Get-EpicProgressBlockedClosure -Blocked @('1201') -DependsOn @{ '1201' = [string[]] @('provider-epic#1188'); '1202' = [string[]] @() })

        ($closure -join ',') | Should -BeExactly '1201'
    }

    It 'gives the same wave edges and dependency graph with a raw cross_epic_depends_on value' {
        $features = @(Get-TestFeature -Issue '101' -Wave 1 -Folder 'f-a'; Get-TestFeature -Issue '102' -Wave 2 -Folder 'f-b')
        $plain = [pscustomobject]@{ issue_num = '102'; feature_folder = 'f-b'; depends_on = [string[]] @('101') }
        $keyed = [pscustomobject]@{ issue_num = '102'; feature_folder = 'f-b'; depends_on = [string[]] @('101'); cross_epic_depends_on = '[{ epic: p, integration_branch: epic/p-integration, issue_num: 7 }]' }

        $plainGraph = Get-EpicProgressDependencyGraph -Feature $features -ManifestRow @($plain)
        $keyedGraph = Get-EpicProgressDependencyGraph -Feature $features -ManifestRow @($keyed)

        (ConvertTo-TestEdgeText -DependsOn $keyedGraph.DependsOn) | Should -BeExactly (ConvertTo-TestEdgeText -DependsOn $plainGraph.DependsOn)
        "$($keyedGraph.Source)|$($keyedGraph.Message)" | Should -BeExactly "$($plainGraph.Source)|$($plainGraph.Message)"
        (ConvertTo-TestEdgeText -DependsOn (Get-EpicProgressWaveEdge -Feature $features)) | Should -BeExactly '101:; 102:101'
    }
}
