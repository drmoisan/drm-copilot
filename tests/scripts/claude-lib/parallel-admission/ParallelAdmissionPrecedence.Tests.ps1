<#
.SYNOPSIS
    Unit tests for the precedence and scheduling-record functions of ParallelAdmissionPrecedence.psm1 (issue #1047).

.DESCRIPTION
    Covers .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1. Every
    function under test is pure, so inputs are built in memory: no file is
    created, no process is started, and no clock is read.
#>

BeforeAll {
    # Resolve the repository root four levels up: parallel-admission -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:ModulePath = Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name ParallelAdmissionPrecedence -Force -ErrorAction SilentlyContinue
}

Describe 'Test-ParallelPrecedenceInput' {
    It 'rejects an entry that names an unknown item' {
        $entry = @(@{ before = 101; after = 999 })

        { Test-ParallelPrecedenceInput -Entry $entry -ItemKey @(101, 102) } | Should -Throw 'precedence_unknown_item:*999*'
    }

    It 'rejects an entry whose keys are not integers' {
        { Test-ParallelPrecedenceInput -Entry @(@{ before = 'abc'; after = 102 }) -ItemKey @(101, 102) } | Should -Throw 'precedence_unknown_item:*'
    }

    It 'rejects a self-pair' {
        { Test-ParallelPrecedenceInput -Entry @(@{ before = 101; after = 101 }) -ItemKey @(101, 102) } | Should -Throw 'precedence_cycle:*itself*'
    }

    It 'rejects a two-node cycle' {
        $entry = @(@{ before = 101; after = 102 }, @{ before = 102; after = 101 })

        { Test-ParallelPrecedenceInput -Entry $entry -ItemKey @(101, 102) } | Should -Throw 'precedence_cycle:*101, 102*'
    }

    It 'rejects a three-node cycle' {
        $entry = @(@{ before = 101; after = 102 }, @{ before = 102; after = 103 }, @{ before = 103; after = 101 })

        { Test-ParallelPrecedenceInput -Entry $entry -ItemKey @(101, 102, 103, 104) } | Should -Throw 'precedence_cycle:*101, 102, 103.'
    }

    It 'accepts an acyclic chain' {
        $entry = @(@{ before = 101; after = 102 }, @{ before = '102'; after = 103 })

        Test-ParallelPrecedenceInput -Entry $entry -ItemKey @(101, 102, 103) | Should -BeTrue
    }

    It 'accepts an empty entry list' {
        Test-ParallelPrecedenceInput -Entry @() -ItemKey @(101) | Should -BeTrue
    }
}

Describe 'ConvertTo-ParallelPrecedenceEdge' {
    It 'normalizes pairs to sorted a:b edges with a below b and no duplicates' {
        $entry = @(@{ before = 205; after = 103 }, @{ before = 101; after = 102 }, @{ before = 103; after = 205 }, @{ before = 101; after = 103 })

        $edges = ConvertTo-ParallelPrecedenceEdge -Entry $entry

        $edges | Should -Be @('101:102', '101:103', '103:205')
    }

    It 'returns an empty list for no entries' {
        (ConvertTo-ParallelPrecedenceEdge -Entry @()).Count | Should -Be 0
    }
}

Describe 'Invoke-ParallelPrecedenceLift' {
    BeforeAll {
        # Render a cohort table as one comparable string, for example '101,102|103'.
        function Format-CohortTable {
            param([object[]] $Table)
            return (@($Table | ForEach-Object { @($_) -join ',' }) -join '|')
        }

        # Report any conflict edge whose two ends share a cohort.
        function Get-CohortConflict {
            param([object[]] $Table, [string[]] $Edge)
            $conflict = @()
            foreach ($members in $Table) {
                foreach ($text in $Edge) {
                    $ends = $text -split ':'
                    if (@($members) -contains [long]$ends[0] -and @($members) -contains [long]$ends[1]) { $conflict += $text }
                }
            }
            return $conflict
        }
    }

    It 'leaves an already-satisfied table unchanged' {
        $table = Invoke-ParallelPrecedenceLift -Cohort @(@(101), @(102)) -Precedence @(@{ before = 101; after = 102 })

        Format-CohortTable $table | Should -Be '101|102'
    }

    It 'lifts an after item into the cohort above its before item' {
        $table = Invoke-ParallelPrecedenceLift -Cohort @(@(101, 102), @(103)) -Precedence @(@{ before = 101; after = 102 })

        Format-CohortTable $table | Should -Be '101|102,103'
    }

    It 'lifts past a cohort that holds a conflict neighbor' {
        # Arrange: 102 must follow 101, and 102 conflicts with 103 in cohort 1.
        $table = Invoke-ParallelPrecedenceLift -Cohort @(@(101, 102), @(103)) -Edge @('102:103') -Precedence @(@{ before = 101; after = 102 })

        Format-CohortTable $table | Should -Be '101|103|102'
    }

    It 'lifts an unpinned after item above a pinned before item' {
        $table = Invoke-ParallelPrecedenceLift -Cohort @(@(101), @(102, 103)) -Precedence @(@{ before = 102; after = 101 }) -Pinned @(102)

        Format-CohortTable $table | Should -Be '|102,103|101'
    }

    It 'leaves a pinned after item in place' {
        $table = Invoke-ParallelPrecedenceLift -Cohort @(, @(101, 102)) -Precedence @(@{ before = 101; after = 102 }) -Pinned @(102)

        Format-CohortTable $table | Should -Be '101,102'
    }

    It 'orders a precedence chain into successive cohorts' {
        $entry = @(@{ before = 101; after = 102 }, @{ before = 102; after = 103 })

        $table = Invoke-ParallelPrecedenceLift -Cohort @(, @(101, 102, 103)) -Precedence $entry

        Format-CohortTable $table | Should -Be '101|102|103'
    }

    It 'respects the floor when it moves an item' {
        $table = Invoke-ParallelPrecedenceLift -Cohort @(, @(101, 102)) -Precedence @(@{ before = 101; after = 102 }) -Floor 2

        Format-CohortTable $table | Should -Be '101||102'
    }

    It 'keeps every cohort an independent set' {
        $edge = @('101:104', '102:104', '103:104', '102:105')
        $entry = @(@{ before = 101; after = 102 }, @{ before = 103; after = 105 })

        $table = Invoke-ParallelPrecedenceLift -Cohort @(@(101, 102, 103), @(104, 105)) -Edge $edge -Precedence $entry

        Get-CohortConflict -Table $table -Edge $edge | Should -BeNullOrEmpty
        Format-CohortTable $table | Should -Be '101,103|104,105|102'
    }

    It 'changes nothing on a second application' {
        $edge = @('102:103')
        $entry = @(@{ before = 101; after = 102 })
        $first = Invoke-ParallelPrecedenceLift -Cohort @(@(101, 102), @(103)) -Edge $edge -Precedence $entry

        $second = Invoke-ParallelPrecedenceLift -Cohort $first -Edge $edge -Precedence $entry

        Format-CohortTable $second | Should -Be (Format-CohortTable $first)
    }

    It 'rejects a precedence entry that names an item outside the table' {
        { Invoke-ParallelPrecedenceLift -Cohort @(@(101)) -Precedence @(@{ before = 101; after = 102 }) } | Should -Throw 'precedence_unknown_item:*'
    }

    It 'rejects a malformed conflict edge' {
        { Invoke-ParallelPrecedenceLift -Cohort @(@(101), @(102)) -Edge @('101-102') } | Should -Throw '*is not of the form*'
    }

    It 'rejects a cohort member that is not an item key' {
        { Invoke-ParallelPrecedenceLift -Cohort @(@('x')) } | Should -Throw '*is not an integer item key*'
    }

    It 'rejects an item that appears in two cohorts' {
        { Invoke-ParallelPrecedenceLift -Cohort @(@(101), @(101)) } | Should -Throw '*more than one cohort*'
    }
}

Describe 'ConvertTo-ParallelPrecedenceKey' {
    It 'converts <Value> to <Expected>' -ForEach @(
        @{ Value = 42; Expected = 42 }
        @{ Value = [long]7; Expected = 7 }
        @{ Value = '1101'; Expected = 1101 }
    ) {
        ConvertTo-ParallelPrecedenceKey -Value $Value | Should -Be $Expected
    }

    It 'returns null for the non-key value <Label>' -ForEach @(
        @{ Label = 'boolean'; Value = $true }
        @{ Label = 'mixed string'; Value = '12a' }
        @{ Label = 'double'; Value = 1.5 }
        @{ Label = 'null'; Value = $null }
    ) {
        ConvertTo-ParallelPrecedenceKey -Value $Value | Should -BeNullOrEmpty
    }
}

Describe 'Get-ParallelActivePrecedence' {
    BeforeAll {
        # Build one checkpoint item record.
        function Get-ItemRecord {
            param([long] $Key, [string] $State = 'scheduled', [string] $MergeStatus = 'not_started', [long[]] $Combined = @())
            $record = @{ issue_num = $Key; state = $State; merge_status = $MergeStatus }
            if ($Combined.Count -gt 0) { $record.combined_issue_nums = $Combined }
            return $record
        }
        $script:Entry = @(@{ before = 101; after = 102; source = 'operator'; recorded_at = '2026-11-03T10-00' })
    }

    It 'releases an entry whose predecessor is <MergeStatus> in state <State>' -ForEach @(
        @{ State = 'merged'; MergeStatus = 'merged' }
        @{ State = 'merged'; MergeStatus = 'worktree_removed' }
        @{ State = 'withdrawn'; MergeStatus = 'not_started' }
    ) {
        $items = @((Get-ItemRecord -Key 101 -State $State -MergeStatus $MergeStatus), (Get-ItemRecord -Key 102))

        (Get-ParallelActivePrecedence -Precedence $script:Entry -Item $items).Count | Should -Be 0
    }

    It 'holds an entry whose predecessor is <MergeStatus> in state <State>' -ForEach @(
        @{ State = 'blocked'; MergeStatus = 'blocked_ci_loop_limit' }
        @{ State = 'in_flight'; MergeStatus = 'pr_open' }
        @{ State = 'in_flight'; MergeStatus = 'ci_green' }
    ) {
        $items = @((Get-ItemRecord -Key 101 -State $State -MergeStatus $MergeStatus), (Get-ItemRecord -Key 102))

        $active = Get-ParallelActivePrecedence -Precedence $script:Entry -Item $items

        $active.Count | Should -Be 1
        $active[0].before | Should -Be 101
        $active[0].after | Should -Be 102
    }

    It 'maps member keys to the combined item that carries them' {
        # Arrange: 101 and 103 are combined into 101; 104 must follow member 103.
        $items = @((Get-ItemRecord -Key 101 -Combined @(101, 103)), (Get-ItemRecord -Key 104))
        $entry = @(@{ before = 103; after = 104 }, @{ before = 101; after = 104 })

        $active = Get-ParallelActivePrecedence -Precedence $entry -Item $items

        $active.Count | Should -Be 1
        $active[0].before | Should -Be 101
        $active[0].after | Should -Be 104
    }

    It 'drops a pair inside one combination' {
        $items = @((Get-ItemRecord -Key 101 -Combined @(101, 103)), (Get-ItemRecord -Key 104))

        (Get-ParallelActivePrecedence -Precedence @(@{ before = 101; after = 103 }) -Item $items).Count | Should -Be 0
    }

    It 'rejects an entry that names no item' {
        { Get-ParallelActivePrecedence -Precedence @(@{ before = 101; after = 999 }) -Item @(Get-ItemRecord -Key 101) } | Should -Throw 'precedence_unknown_item:*999*'
    }
}

Describe 'Test-ParallelPrecedenceCohortTable' {
    BeforeAll {
        # Build a checkpoint with a current generation (1), a stale generation (0), and the given table.
        function Get-CohortCheckpoint {
            param([object[]] $Table, [object[]] $Precedence)
            $cohorts = @(@{ index = 0; generation = 0; item_keys = @(102, 101) })
            for ($position = 0; $position -lt $Table.Count; $position++) {
                $cohorts += @{ index = $position; generation = 1; item_keys = @($Table[$position]) }
            }
            $checkpoint = @{
                recolor_generation = 1
                cohorts            = $cohorts
                items              = @(@{ issue_num = 101; state = 'scheduled' }, @{ issue_num = 102; state = 'scheduled' }, @{ issue_num = 103; state = 'scheduled' })
            }
            if ($null -ne $Precedence) { $checkpoint.precedence = $Precedence }
            return $checkpoint
        }
    }

    It 'accepts a table that places each after item in a later cohort' {
        $checkpoint = Get-CohortCheckpoint -Table @(@(101, 103), @(102)) -Precedence @(@{ before = 101; after = 102 })

        $result = Test-ParallelPrecedenceCohortTable -Checkpoint $checkpoint

        $result.Satisfied | Should -BeTrue
        $result.Violation.Count | Should -Be 0
    }

    It 'rejects a table that places an after item in the same cohort as its before item' {
        $checkpoint = Get-CohortCheckpoint -Table @(@(101, 102), @(103)) -Precedence @(@{ before = 101; after = 102 })

        $result = Test-ParallelPrecedenceCohortTable -Checkpoint $checkpoint

        $result.Satisfied | Should -BeFalse
        $result.Violation | Should -Be @('item 102 in cohort 0 must follow item 101 in cohort 0')
    }

    It 'rejects a table that places an after item before its before item' {
        $checkpoint = Get-CohortCheckpoint -Table @(@(102), @(101, 103)) -Precedence @(@{ before = 101; after = 102 })

        (Test-ParallelPrecedenceCohortTable -Checkpoint $checkpoint).Satisfied | Should -BeFalse
    }

    It 'accepts a checkpoint with no precedence key' {
        $checkpoint = Get-CohortCheckpoint -Table @(@(101, 102, 103)) -Precedence $null

        (Test-ParallelPrecedenceCohortTable -Checkpoint $checkpoint).Satisfied | Should -BeTrue
    }

    It 'throws when the checkpoint is not an object' {
        { Test-ParallelPrecedenceCohortTable -Checkpoint 'text' } | Should -Throw '*must be a JSON object*'
    }
}

Describe 'Scheduling record' {
    BeforeAll {
        $script:RecordArguments = @{
            Slug             = 'admission-seed'
            Edge             = @(@{ a = 1102; b = 1103; reason = 'path_overlap'; hard = $false; cost = 2 }, @{ a = 1101; b = 1103; reason = 'contract_dependency' })
            ToleratedOverlap = @(@{ a = 1101; b = 1102; reasons = @('path_overlap'); cost = 1; benefit = 4; observed_resolution = @{ conflicted = $false } })
            Precedence       = @(@{ before = 1101; after = 1102; source = 'operator'; recorded_at = '2026-11-03T10-00'; note = 'x' })
            Item             = @(
                @{ issue_num = 1102; branch_name = 'feature/b-1102'; plan_path = 'docs/features/active/b-1102/plan.2026-11-02T09-00.md'; plan_hash = 'bbbb'; base_commit = 'c2'; preparation_status = 'cleared'; complexity_band = 'C2'; state = 'scheduled' }
                @{ issue_num = 1101; branch_name = 'feature/a-1101'; plan_path = 'docs/features/active/a-1101/plan.2026-11-02T08-00.md'; plan_hash = 'aaaa'; base_commit = 'c1'; preparation_status = 'cleared'; complexity_band = 'C1' }
            )
        }
    }

    It 'carries exactly the six record keys in ordinal order' {
        $record = New-ParallelSchedulingRecord @script:RecordArguments

        @($record.Keys) | Should -Be @('edges', 'items', 'parallel_slug', 'precedence', 'schema_version', 'tolerated_overlaps')
        $record['schema_version'] | Should -Be 1
        $record['parallel_slug'] | Should -Be 'admission-seed'
    }

    It 'projects each item onto the seven item keys, sorted by issue_num' {
        $record = New-ParallelSchedulingRecord @script:RecordArguments

        @($record['items'] | ForEach-Object { $_['issue_num'] }) | Should -Be @(1101, 1102)
        @($record['items'][0].Keys) | Should -Be @('base_commit', 'branch_name', 'complexity_band', 'issue_num', 'plan_hash', 'plan_path', 'preparation_status')
        $record['items'][1]['plan_hash'] | Should -Be 'bbbb'
    }

    It 'projects edges, tolerated overlaps, and precedence onto their declared keys' {
        $record = New-ParallelSchedulingRecord @script:RecordArguments

        @($record['edges'] | ForEach-Object { "$($_['a']):$($_['b']):$($_['reason'])" }) | Should -Be @('1101:1103:contract_dependency', '1102:1103:path_overlap')
        @($record['edges'][0].Keys) | Should -Be @('a', 'b', 'reason')
        @($record['tolerated_overlaps'][0].Keys) | Should -Be @('a', 'b', 'benefit', 'cost', 'reasons')
        @($record['precedence'][0].Keys) | Should -Be @('after', 'before', 'recorded_at', 'source')
    }

    It 'yields the same record whatever the input order' {
        $reversed = $script:RecordArguments.Clone()
        $reversed.Item = @($script:RecordArguments.Item[1], $script:RecordArguments.Item[0])
        $reversed.Edge = @($script:RecordArguments.Edge[1], $script:RecordArguments.Edge[0])

        $first = New-ParallelSchedulingRecord @script:RecordArguments | ConvertTo-Json -Depth 8 -Compress
        $second = New-ParallelSchedulingRecord @reversed | ConvertTo-Json -Depth 8 -Compress

        $second | Should -Be $first
    }

    It 'throws when the slug is blank' {
        { New-ParallelSchedulingRecord -Slug '' } | Should -Throw '*requires -Slug*'
    }

    It 'reuses the recorded edges of an item whose plan hash matches' {
        $record = New-ParallelSchedulingRecord @script:RecordArguments

        $reuse = Get-ParallelSchedulingRecordReuse -Record $record -IssueNum 1102 -CurrentPlanHash 'bbbb'

        $reuse.action | Should -Be 'reuse'
        @($reuse.edges | ForEach-Object { "$($_['a']):$($_['b'])" }) | Should -Be @('1102:1103')
    }

    It 'returns a recompute marker when the plan hash changed' {
        $record = New-ParallelSchedulingRecord @script:RecordArguments

        $reuse = Get-ParallelSchedulingRecordReuse -Record $record -IssueNum 1102 -CurrentPlanHash 'cccc'

        $reuse.action | Should -Be 'recompute'
        $reuse.reason | Should -Be 'plan_hash_changed'
        $reuse.edges.Count | Should -Be 0
    }

    It 'returns a recompute marker for an item the record does not list' {
        $record = New-ParallelSchedulingRecord @script:RecordArguments

        $reuse = Get-ParallelSchedulingRecordReuse -Record $record -IssueNum 4242 -CurrentPlanHash 'aaaa'

        $reuse.action | Should -Be 'recompute'
        $reuse.reason | Should -Be 'unknown_item'
    }
}
