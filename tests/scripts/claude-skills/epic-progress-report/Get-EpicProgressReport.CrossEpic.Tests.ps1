# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1 (issue #1162).
# The entry script is dot-sourced with its mandatory parameters bound, so the entry-point
# block is skipped. Inputs are in-memory rows and texts; Read-EpicProgressText is mocked with
# a matching parameter signature, so no test starts git or reads a file.

BeforeAll {
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1'
    . $script:scriptPath -EpicFolder 'example-epic' -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc))
    $script:defaults = Resolve-EpicProgressStepDefault
    $script:edgeRecord = {
        param([string] $Status = '')
        [pscustomobject]@{ Issue = '1201'; Epic = 'provider-epic'; IntegrationBranch = 'epic/provider-epic-integration'; IssueNum = '1188'; Status = $Status; Node = 'provider-epic#1188' }
    }
}

Describe 'Get-EpicProgressCrossEpicEdge' {
    It 'reads edges and statuses from checkpoint rows' {
        $row = '{"issue_num":1201,"cross_epic_depends_on":[{"epic":"provider-epic","integration_branch":"epic/provider-epic-integration","issue_num":1188,"status":"integrated"},{"epic":"other","issue_num":7}]}' | ConvertFrom-Json

        $edges = @(Get-EpicProgressCrossEpicEdge -CheckpointRow @($row))

        (@($edges | ForEach-Object { "$($_.Issue)>$($_.Node):$($_.Status):$($_.IntegrationBranch)" }) -join ',') | Should -BeExactly '1201>provider-epic#1188:integrated:epic/provider-epic-integration,1201>other#7::'
    }

    It 'reads edges from the raw single-line manifest value when no checkpoint row carries the key' {
        $manifest = [pscustomobject]@{ issue_num = '1202'; cross_epic_depends_on = '[{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }, { epic: "b", issue_num: 2 }]' }
        $checkpoint = '{"issue_num":1202,"merge_status":"not_started"}' | ConvertFrom-Json

        $edges = @(Get-EpicProgressCrossEpicEdge -CheckpointRow @($checkpoint) -ManifestRow @($manifest))

        (@($edges | ForEach-Object { "$($_.Issue)>$($_.Node):$($_.Status)" }) -join ',') | Should -BeExactly '1202>provider-epic#1188:,1202>b#2:'
    }

    It 'prefers the checkpoint row over the manifest value for the same feature' {
        $checkpoint = '{"issue_num":1201,"cross_epic_depends_on":[{"epic":"a","issue_num":1,"status":"held"}]}' | ConvertFrom-Json
        $manifest = [pscustomobject]@{ issue_num = '1201'; cross_epic_depends_on = '[{ epic: z, issue_num: 9 }]' }

        @(Get-EpicProgressCrossEpicEdge -CheckpointRow @($checkpoint) -ManifestRow @($manifest)).Node | Should -BeExactly 'a#1'
    }

    It 'skips <Name>' -ForEach @(
        @{ Name = 'rows without the key'; Checkpoint = '{"issue_num":1201}'; Raw = $null }
        @{ Name = 'entries without an epic or a positive issue number'; Checkpoint = '{"issue_num":1201,"cross_epic_depends_on":[{"issue_num":1},{"epic":"a","issue_num":0},"x",null]}'; Raw = $null }
        @{ Name = 'manifest mappings without an issue number'; Checkpoint = $null; Raw = '[{ epic: a }]' }
        @{ Name = 'an empty manifest value'; Checkpoint = $null; Raw = '[]' }
    ) {
        $checkpoint = @()
        if ($Checkpoint) { $checkpoint = @($Checkpoint | ConvertFrom-Json) }
        $manifest = @()
        if ($Raw) { $manifest = @([pscustomobject]@{ issue_num = '1201'; cross_epic_depends_on = $Raw }) }

        @(Get-EpicProgressCrossEpicEdge -CheckpointRow $checkpoint -ManifestRow $manifest).Count | Should -Be 0
    }
}

Describe 'New-EpicProgressExternalNode' {
    It 'names the node by epic slug, #, and issue and maps <Status> to <State>' -ForEach @(
        @{ Status = 'integrated'; State = 'done' }
        @{ Status = 'in_main'; State = 'done' }
        @{ Status = 'held'; State = 'pending' }
        @{ Status = 'released'; State = 'pending' }
        @{ Status = ''; State = 'pending' }
    ) {
        $node = New-EpicProgressExternalNode -Edge (& $script:edgeRecord $Status) -Default $script:defaults -NowUnixSeconds 0

        "$($node.Issue)|$($node.NodeState)|$($node.External)" | Should -BeExactly "provider-epic#1188|$State|True"
        $node.NodeState | Should -Not -Be 'blocked'
    }

    It 'prices an unreadable plan at the per-type defaults with zero execution tasks' {
        $node = New-EpicProgressExternalNode -Edge (& $script:edgeRecord) -PlanText '' -Default $script:defaults -NowUnixSeconds 0

        # research 13 + spec 6 + plan 11 + preflight 10 + review 14 + pr 3 + ci 17 + merge 5 = 79 min.
        "$($node.Label)|$($node.ExecutionTasks)|$($node.OtherSeconds)" | Should -BeExactly 'external (default)|0|4740'
    }

    It 'prices a prepared plan by its unchecked tasks and the remaining step medians' {
        $plan = "### Phase 1`n- [x] [P1-T1] a.`n- [ ] [P1-T2] b.`n- [ ] [P1-T3] c."
        $node = New-EpicProgressExternalNode -Edge (& $script:edgeRecord) -PlanText $plan -Ledger $null -Default $script:defaults -NowUnixSeconds 0

        # Without ledger samples: preflight 10 + review 14 + pr 3 + ci 17 + merge 5 = 49 min.
        "$($node.Label)|$($node.ExecutionTasks)|$($node.OtherSeconds)" | Should -BeExactly 'external|2|2940'
    }

    It 'carries no step records' {
        $node = New-EpicProgressExternalNode -Edge (& $script:edgeRecord) -Default $script:defaults -NowUnixSeconds 0

        $node.PSObject.Properties.Name | Should -Not -Contain 'Step'
    }
}

Describe 'Get-EpicProgressExternalSecond' {
    It 'returns <Expected> seconds for <Name>' -ForEach @(
        @{ Name = 'a done node'; State = 'done'; Tasks = 3; Rate = 12.0; Expected = 0.0 }
        @{ Name = 'a node without execution tasks'; State = 'pending'; Tasks = 0; Rate = 0.0; Expected = 100.0 }
        @{ Name = 'three tasks at 12 per hour'; State = 'pending'; Tasks = 3; Rate = 12.0; Expected = 1000.0 }
        @{ Name = 'tasks at a zero rate'; State = 'pending'; Tasks = 1; Rate = 0.0; Expected = [double]::PositiveInfinity }
    ) {
        $node = [pscustomobject]@{ NodeState = $State; ExecutionTasks = $Tasks; OtherSeconds = 100.0 }

        Get-EpicProgressExternalSecond -Node $node -Rate $Rate | Should -Be $Expected
    }
}

Describe 'Read-EpicProgressCrossEpicPlanText' {
    BeforeEach {
        $script:texts = @{}
        Mock Read-EpicProgressText { param([string] $RelativePath, [string] $WorktreePath, [string] $IntegrationBranch) $null = $WorktreePath; return [string] $script:texts["$IntegrationBranch|$RelativePath"] }
    }

    It 'reads the plan named by the other epic kickoff row on origin of its integration branch' {
        $script:texts['origin/epic/provider-epic-integration|docs/features/epics/provider-epic/epic-kickoff.md'] = "| Issue | Title | Wave | Band | Plan |`n|---|---|---|---|---|`n| 1188 | P | 0 | small | docs/p/plan.md |"
        $script:texts['origin/epic/provider-epic-integration|docs/p/plan.md'] = 'PLAN TEXT'

        Read-EpicProgressCrossEpicPlanText -Edge (& $script:edgeRecord) | Should -BeExactly 'PLAN TEXT'
    }

    It 'returns an empty text for <Name>' -ForEach @(
        @{ Name = 'a missing kickoff'; Kickoff = '' }
        @{ Name = 'a kickoff without the prerequisite row'; Kickoff = "| Issue | Title | Wave | Band | Plan |`n|---|---|---|---|---|`n| 7 | P | 0 | small | docs/p/plan.md |" }
        @{ Name = 'a kickoff table that does not parse'; Kickoff = 'no table here' }
    ) {
        $script:texts['origin/epic/provider-epic-integration|docs/features/epics/provider-epic/epic-kickoff.md'] = $Kickoff

        Read-EpicProgressCrossEpicPlanText -Edge (& $script:edgeRecord) | Should -BeExactly ''
    }

    It 'derives the integration branch from the epic slug when the edge has none' {
        $edge = [pscustomobject]@{ Issue = '1201'; Epic = 'b'; IntegrationBranch = ''; IssueNum = '2'; Status = ''; Node = 'b#2' }
        $script:texts['origin/epic/b-integration|docs/features/epics/b/epic-kickoff.md'] = "| Issue | Title | Wave | Band | Plan |`n|---|---|---|---|---|`n| 2 | B | 0 | small | docs/b/plan.md |"
        $script:texts['origin/epic/b-integration|docs/b/plan.md'] = 'B PLAN'

        Read-EpicProgressCrossEpicPlanText -Edge $edge | Should -BeExactly 'B PLAN'
    }
}
