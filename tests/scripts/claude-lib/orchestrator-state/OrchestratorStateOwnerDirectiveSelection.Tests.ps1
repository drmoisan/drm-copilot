#Requires -Version 7.0

<#
.SYNOPSIS
    Selection, rendering, coverage, and running-child tests for OrchestratorStateOwnerDirectiveSelection.psm1 (issue #1157).

.DESCRIPTION
    Directive entries are built in memory with a computed text_sha256, and every time-dependent
    call receives a fixed -Now. The relay-format example is read from the committed
    owner-directives skill text. No test writes a file, reads a clock, or starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1'
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1') -Force -ErrorAction Stop
    Import-Module $script:ModulePath -Force -ErrorAction Stop
    $script:Now = [datetime]::new(2026, 11, 10, 12, 0, 0, [System.DateTimeKind]::Utc)

    # One directive object as compact JSON text with a matching text_sha256.
    function Get-SelectionTestEntry {
        param(
            [string] $Id = 'OD-1', [string] $Class = 'scheduling', [long] $Issue = 1157, [string] $Branch = 'feature/owner-directive-pass-down-1157',
            [string] $Step = 'S5', [string] $Expires = '2026-11-11T12:00:00Z', [string] $Text = 'Run the features in parallel where the merge cost is lower.',
            [string] $Recorded = '2026-11-01T00:00:00Z'
        )
        $digest = [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.Text.UTF8Encoding]::new($false).GetBytes($Text))).ToLowerInvariant()
        $entry = [ordered]@{
            id = $Id; text = $Text; text_sha256 = $digest; class = $Class; recorded_at = $Recorded; expires_at = $Expires
            scope = [ordered]@{ issue = $Issue; branch = $Branch; step = $Step }; issued_by_session = 'coordinator-session-1157'
        }
        return ($entry | ConvertTo-Json -Compress -Depth 4)
    }

    function Get-SelectionTestSource {
        param([string] $Name = 'item-checkpoint', [string[]] $Entry, [switch] $Ledger, [switch] $Epic)
        $text = if ($Ledger) { $Entry -join "`n" } else { '[' + ($Entry -join ',') + ']' }
        return [pscustomobject]@{ Name = $Name; Text = $text; IsEpicParent = [bool] $Epic }
    }

    function Invoke-SelectionTest {
        param([object[]] $Source, [string] $Branch = 'feature/owner-directive-pass-down-1157', [string] $Step = 'S5', [datetime] $Now = $script:Now, [object] $ParentIssue = 900, [string] $ParentBranch = 'epic/pass-down-integration', [long] $Issue = 1157)
        return (Select-OwnerDirectivePassDown -Source $Source -ItemIssue $Issue -ItemBranch $Branch -ItemStep $Step -ParentIssue $ParentIssue -ParentBranch $ParentBranch -Now $Now)
    }

    function Get-SelectionModuleText {
        return (Get-Content -Raw -LiteralPath $script:ModulePath)
    }
}

Describe 'Select-OwnerDirectivePassDown item match (AC-1)' {
    It 'selects an entry whose issue and branch match the item' {
        $result = Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry))
        @($result.Selected).Count | Should -Be 1
        $result.Selected[0].Source | Should -BeExactly 'item-checkpoint'
        $result.Selected[0].Scope.Issue | Should -Be 1157
    }

    It 'does not select a branch that differs only in letter case' {
        $result = Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry -Branch 'Feature/Owner-Directive-Pass-Down-1157'))
        @($result.Selected).Count | Should -Be 0
    }

    It 'skips the branch comparison when the item branch is null' {
        $result = Select-OwnerDirectivePassDown -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry -Branch 'some/other-branch')) -ItemIssue 1157 -ItemBranch $null -ItemStep 'S5' -Now $script:Now
        @($result.Selected).Count | Should -Be 1
    }

    It 'does not select an entry scoped to another issue' {
        $result = Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry -Issue 1156))
        @($result.Selected).Count | Should -Be 0
    }
}

Describe 'Select-OwnerDirectivePassDown epic fan-out (AC-2)' {
    It 'selects an epic parent entry scoped to the epic issue and integration branch' {
        $entry = Get-SelectionTestEntry -Issue 900 -Branch 'epic/pass-down-integration'
        $result = Invoke-SelectionTest -Source @(Get-SelectionTestSource -Name 'parent-ledger' -Ledger -Epic -Entry $entry)
        @($result.Selected).Count | Should -Be 1
        $result.Selected[0].Source | Should -BeExactly 'parent-ledger'
    }

    It 'does not fan out when <Case>' -ForEach @(
        @{ Case = 'the issue differs'; Issue = 901; Branch = 'epic/pass-down-integration'; Epic = $true; Name = 'parent-checkpoint' }
        @{ Case = 'the branch differs'; Issue = 900; Branch = 'epic/other-integration'; Epic = $true; Name = 'parent-checkpoint' }
        @{ Case = 'the parent source is not an epic source'; Issue = 900; Branch = 'epic/pass-down-integration'; Epic = $false; Name = 'parent-checkpoint' }
        @{ Case = 'the source is an item source'; Issue = 900; Branch = 'epic/pass-down-integration'; Epic = $true; Name = 'item-ledger' }
    ) {
        $source = Get-SelectionTestSource -Name $Name -Ledger -Epic:$Epic -Entry (Get-SelectionTestEntry -Issue $Issue -Branch $Branch)
        @((Invoke-SelectionTest -Source @($source)).Selected).Count | Should -Be 0
    }
}

Describe 'Select-OwnerDirectivePassDown step match (AC-3)' {
    It 'scope.step <ScopeStep> against next_step <ItemStep> selects <Expected>' -ForEach @(
        @{ ScopeStep = 'S5'; ItemStep = 'S5_atomic_execution'; Expected = 1 }
        @{ ScopeStep = 'S5'; ItemStep = 'S5'; Expected = 1 }
        @{ ScopeStep = 'any'; ItemStep = 'R4'; Expected = 1 }
        @{ ScopeStep = 'S5'; ItemStep = 'S51'; Expected = 0 }
        @{ ScopeStep = 'S5'; ItemStep = 'S5x'; Expected = 0 }
        @{ ScopeStep = 'S5'; ItemStep = 'S7'; Expected = 0 }
    ) {
        $result = Invoke-SelectionTest -Step $ItemStep -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry -Step $ScopeStep))
        @($result.Selected).Count | Should -Be $Expected
    }
}

Describe 'Select-OwnerDirectivePassDown expiry boundary (AC-4)' {
    It 'expires_at <Expires> against Now 2026-11-10T12:00:00Z selects <Expected>' -ForEach @(
        @{ Expires = '2026-11-10T12:00:01Z'; Expected = 1 }
        @{ Expires = '2026-11-10T12:00:00Z'; Expected = 0 }
        @{ Expires = '2026-11-10T11:59:59Z'; Expected = 0 }
    ) {
        $result = Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry -Expires $Expires))
        @($result.Selected).Count | Should -Be $Expected
    }
}

Describe 'Select-OwnerDirectivePassDown validity comes only from the B rules (AC-5)' {
    It '<Rule> drops a matching violating entry and keeps the valid sibling' -ForEach @(
        @{ Rule = 'B2'; Bad = { (Get-SelectionTestEntry -Id 'OD-1') -replace '"issued_by_session":"coordinator-session-1157"', '"issued_by_session":""' } }
        @{ Rule = 'B3'; Bad = { Get-SelectionTestEntry -Id 'OD-01' } }
        @{ Rule = 'B5'; Bad = { (Get-SelectionTestEntry -Id 'OD-1') -replace '"text":"Run', '"text":"Do not run' } }
        @{ Rule = 'B6'; Bad = { Get-SelectionTestEntry -Id 'OD-1' -Class 'approval' } }
        @{ Rule = 'B7'; Bad = { Get-SelectionTestEntry -Id 'OD-1' -Recorded '2026-11-12T00:00:00Z' } }
        @{ Rule = 'B8'; Bad = { Get-SelectionTestEntry -Id 'OD-1' -Step '' } }
    ) {
        $source = Get-SelectionTestSource -Name 'item-ledger' -Ledger -Entry @((& $Bad), (Get-SelectionTestEntry -Id 'OD-2'))
        $result = Invoke-SelectionTest -Source @($source)
        @($result.Selected | ForEach-Object Id) | Should -Be @('OD-2')
        @($result.Errors).Count | Should -Be 1
        $result.Errors[0] | Should -BeLike 'item-ledger: Ledger line #1 *'
    }

    It 'B4 keeps the first entry of a duplicated id and drops the second' {
        $source = Get-SelectionTestSource -Name 'item-ledger' -Ledger -Entry @((Get-SelectionTestEntry -Id 'OD-1'), (Get-SelectionTestEntry -Id 'OD-1' -Text 'A different instruction with the same id.'))
        $result = Invoke-SelectionTest -Source @($source)
        @($result.Selected).Count | Should -Be 1
        $result.Selected[0].Text | Should -BeExactly 'Run the features in parallel where the merge cost is lower.'
        $result.Errors[0] | Should -BeExactly 'item-ledger: Ledger line #2 id OD-1 is duplicated.'
    }
}

Describe 'Select-OwnerDirectivePassDown classes (AC-6)' {
    It 'selects refused class <Class> with IsRefusedClass true' -ForEach @(
        @{ Class = 'gate_bypass' }, @{ Class = 'force_push' }, @{ Class = 'tag_or_publish' }
        @{ Class = 'policy_or_settings_edit' }, @{ Class = 'evidence_alteration' }, @{ Class = 'unclassified' }
    ) {
        $result = Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry -Class $Class))
        $result.Selected[0].IsRefusedClass | Should -BeTrue
    }

    It 'selects honorable class <Class> with IsRefusedClass false' -ForEach @(
        @{ Class = 'scheduling' }, @{ Class = 'merge_timing' }, @{ Class = 'extra_planner_revision' }
        @{ Class = 'scope_narrowing' }, @{ Class = 'accept_nonblocking_deviation' }
    ) {
        $result = Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry -Class $Class))
        $result.Selected[0].IsRefusedClass | Should -BeFalse
    }
}

Describe 'Select-OwnerDirectivePassDown id conflicts (AC-7)' {
    It 'collapses the same id and text_sha256 across sources into one entry' {
        $entry = Get-SelectionTestEntry
        $result = Invoke-SelectionTest -Source @((Get-SelectionTestSource -Name 'parent-ledger' -Ledger -Entry $entry), (Get-SelectionTestSource -Entry $entry))
        @($result.Selected).Count | Should -Be 1
        $result.Selected[0].Source | Should -BeExactly 'item-checkpoint'
        @($result.Conflicts).Count | Should -Be 0
    }

    It 'keeps the item-local entry and returns the conflict for the same id with a different text_sha256' {
        $parent = Get-SelectionTestSource -Name 'parent-checkpoint' -Entry (Get-SelectionTestEntry -Text 'The parent text of this directive id.')
        $item = Get-SelectionTestSource -Name 'item-ledger' -Ledger -Entry (Get-SelectionTestEntry)
        $result = Invoke-SelectionTest -Source @($parent, $item)
        @($result.Selected).Count | Should -Be 1
        $result.Selected[0].Source | Should -BeExactly 'item-ledger'
        @($result.Conflicts).Count | Should -Be 1
        $result.Conflicts[0].Id | Should -BeExactly 'OD-1'
        $result.Conflicts[0].KeptSource | Should -BeExactly 'item-ledger'
        $result.Conflicts[0].OtherSource | Should -BeExactly 'parent-checkpoint'
    }
}

Describe 'Format-OwnerDirectiveBlock and prompt coverage (AC-8)' {
    It 'renders the relay-format example of the owner-directives skill byte for byte' {
        $skill = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.claude/skills/owner-directives/SKILL.md')
        $match = [regex]::Match($skill.Replace("`r`n", "`n"), '(?s)\n````text\n(?<block>.*?)\n````\n')
        $match.Success | Should -BeTrue
        $entry = Get-SelectionTestEntry -Id 'OD-1' -Class 'extra_planner_revision' -Issue 1139 -Branch 'feature/owner-directive-relay' -Step 'S5' -Expires '2026-11-09T14:05:00Z' -Text '<verbatim owner text>' -Recorded '2026-11-08T14:05:00Z'
        $selected = (Select-OwnerDirectivePassDown -Source @(Get-SelectionTestSource -Entry $entry) -ItemIssue 1139 -ItemBranch $null -ItemStep 'S5' -Now ([datetime]::new(2026, 11, 9, 0, 0, 0, [System.DateTimeKind]::Utc))).Selected
        Format-OwnerDirectiveBlock -Selected $selected | Should -BeExactly $match.Groups['block'].Value
    }

    It 'orders OD-2 before OD-10, echoes the recorded expires_at, and normalizes CRLF in text' {
        $source = Get-SelectionTestSource -Entry @((Get-SelectionTestEntry -Id 'OD-10' -Expires '2026-11-11T07:00:00-05:00'), (Get-SelectionTestEntry -Id 'OD-2' -Text "Two lines`r`nof owner text."))
        $block = Format-OwnerDirectiveBlock -Selected (Invoke-SelectionTest -Source @($source)).Selected
        $block.IndexOf('OD-2 |') | Should -BeLessThan $block.IndexOf('OD-10 |')
        $block | Should -Match ([regex]::Escape('| expires 2026-11-11T07:00:00-05:00'))
        $block | Should -Not -Match "`r"
        $block | Should -Match ([regex]::Escape("`"Two lines`nof owner text.`""))
    }

    It 'covers a prompt holding every rendered line, after CRLF normalization' {
        $selected = (Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry))).Selected
        $prompt = "Do the work.`r`n" + (Format-OwnerDirectiveBlock -Selected $selected).Replace("`n", "`r`n")
        Test-OwnerDirectivePromptCoverage -Selected $selected -Prompt $prompt | Should -BeTrue
    }

    It 'does not cover a prompt missing the <Missing>' -ForEach @(@{ Missing = 'header line'; Index = 3 }, @{ Missing = 'quoted text line'; Index = 4 }) {
        $selected = (Invoke-SelectionTest -Source @(Get-SelectionTestSource -Entry (Get-SelectionTestEntry))).Selected
        $lines = [System.Collections.Generic.List[string]]::new([string[]] ((Format-OwnerDirectiveBlock -Selected $selected) -split "`n"))
        $lines.RemoveAt($Index)
        Test-OwnerDirectivePromptCoverage -Selected $selected -Prompt ($lines -join "`n") | Should -BeFalse
    }
}

Describe 'Checkpoint gap and append JSON' {
    It 'returns the selected entries the checkpoint lacks by id and text_sha256' {
        $selected = (Invoke-SelectionTest -Source @(Get-SelectionTestSource -Name 'item-ledger' -Ledger -Entry @((Get-SelectionTestEntry -Id 'OD-1'), (Get-SelectionTestEntry -Id 'OD-2')))).Selected
        $held = @([pscustomobject]@{ Id = 'OD-1'; TextSha256 = $selected[0].TextSha256 }, [pscustomobject]@{ Id = 'OD-2'; TextSha256 = 'other' })
        $gap = Get-OwnerDirectiveCheckpointGap -Selected $selected -CheckpointEntry $held
        @($gap | ForEach-Object Id) | Should -Be @('OD-2')
        $json = @(Format-OwnerDirectiveAppendJson -Entry $gap)
        $json.Count | Should -Be 1
        ($json[0] | ConvertFrom-Json).id | Should -BeExactly 'OD-2'
    }

    It 'returns the block text of a checkpoint and $null for one without the key' {
        Get-OwnerDirectiveCheckpointBlockText -CheckpointText '{"owner_directives":[{"id":"OD-1"}]}' | Should -BeExactly '[{"id":"OD-1"}]'
        Get-OwnerDirectiveCheckpointBlockText -CheckpointText '{"objective":"x"}' | Should -BeNullOrEmpty
        Get-OwnerDirectiveCheckpointBlockText -CheckpointText 'not json' | Should -BeNullOrEmpty
    }
}

Describe 'Get-OwnerDirectiveRunningChildGap (pure parts of AC-30 to AC-32)' {
    BeforeAll {
        $script:ParentSource = @(Get-SelectionTestSource -Name 'parent-checkpoint' -Epic -Entry (Get-SelectionTestEntry -Issue 1157 -Branch 'feature/owner-directive-pass-down-1157' -Step 'S5'))
        function Get-ChildTestValue {
            param([string] $Status, [string] $Resolution = 'Resolved', [object[]] $Entry = @(), [bool] $LinksBack = $false)
            return [pscustomobject]@{ Issue = 1157; Branch = 'feature/owner-directive-pass-down-1157'; MergeStatus = $Status; Resolution = $Resolution; CheckpointEntry = $Entry; LinksBack = $LinksBack }
        }
    }

    It '<Kind> child with merge_status <Status> is checked: <Checked>' -ForEach @(
        @{ Kind = 'epic'; Status = 'worktree_created'; Checked = $true }, @{ Kind = 'epic'; Status = 'pr_open'; Checked = $true }
        @{ Kind = 'epic'; Status = 'ci_green'; Checked = $true }, @{ Kind = 'epic'; Status = 'merge_conflict'; Checked = $true }
        @{ Kind = 'epic'; Status = 'not_started'; Checked = $false }, @{ Kind = 'epic'; Status = 'blocked_conflict_loop_limit'; Checked = $false }
        @{ Kind = 'epic'; Status = 'merged'; Checked = $false }, @{ Kind = 'epic'; Status = 'worktree_removed'; Checked = $false }
        @{ Kind = 'parallel'; Status = 'worktree_created'; Checked = $true }, @{ Kind = 'parallel'; Status = 'pr_open'; Checked = $true }
        @{ Kind = 'parallel'; Status = 'ci_green'; Checked = $true }, @{ Kind = 'parallel'; Status = 'not_started'; Checked = $false }
        @{ Kind = 'parallel'; Status = 'merged'; Checked = $false }, @{ Kind = 'parallel'; Status = 'worktree_removed'; Checked = $false }
        @{ Kind = 'parallel'; Status = 'blocked_drift'; Checked = $false }, @{ Kind = 'parallel'; Status = 'blocked_ci_loop_limit'; Checked = $false }
        @{ Kind = 'parallel'; Status = 'merge_conflict'; Checked = $false }
    ) {
        $gaps = Get-OwnerDirectiveRunningChildGap -ParentKind $Kind -Child (Get-ChildTestValue -Status $Status) -ParentEntry $script:ParentSource -Now $script:Now
        (@($gaps).Count -gt 0) | Should -Be $Checked
        if ($Checked) { $gaps[0].Kind | Should -BeExactly 'missing' }
    }

    It 'treats a child holding the same id and text_sha256 as compliant' {
        $held = (Invoke-SelectionTest -Source $script:ParentSource).Selected
        @(Get-OwnerDirectiveRunningChildGap -ParentKind 'epic' -Child (Get-ChildTestValue -Status 'pr_open' -Entry $held) -ParentEntry $script:ParentSource -Now $script:Now).Count | Should -Be 0
    }

    It 'treats a resolved child that links back as compliant without the entry' {
        @(Get-OwnerDirectiveRunningChildGap -ParentKind 'epic' -Child (Get-ChildTestValue -Status 'pr_open' -LinksBack $true) -ParentEntry $script:ParentSource -Now $script:Now).Count | Should -Be 0
    }

    It 'reports a <Resolution> child that lacks the entry even when LinksBack is set' -ForEach @(@{ Resolution = 'NoTarget' }, @{ Resolution = 'Unreadable' }) {
        $gaps = Get-OwnerDirectiveRunningChildGap -ParentKind 'epic' -Child (Get-ChildTestValue -Status 'pr_open' -Resolution $Resolution -LinksBack $true) -ParentEntry $script:ParentSource -Now $script:Now
        @($gaps).Count | Should -Be 1
        $gaps[0].Detail | Should -Match $Resolution
    }

    It 'reports a conflict when the child holds the id with a different text_sha256, even when it links back' {
        $other = @([pscustomobject]@{ Id = 'OD-1'; TextSha256 = 'different' })
        $gaps = Get-OwnerDirectiveRunningChildGap -ParentKind 'epic' -Child (Get-ChildTestValue -Status 'pr_open' -Entry $other -LinksBack $true) -ParentEntry $script:ParentSource -Now $script:Now
        $gaps[0].Kind | Should -BeExactly 'conflict'
    }

    It 'does not require an expired parent entry' {
        $expired = @(Get-SelectionTestSource -Name 'parent-checkpoint' -Epic -Entry (Get-SelectionTestEntry -Expires '2026-11-10T12:00:00Z'))
        @(Get-OwnerDirectiveRunningChildGap -ParentKind 'epic' -Child (Get-ChildTestValue -Status 'pr_open') -ParentEntry $expired -Now $script:Now).Count | Should -Be 0
    }
}

Describe 'OrchestratorStateOwnerDirectiveSelection purity (AC-9)' {
    It 'the module text references no clock, file, or process command' {
        $text = Get-SelectionModuleText
        foreach ($forbidden in @('Get-Date', '[DateTime]::Now', '[DateTime]::UtcNow', 'Get-Content', 'Test-Path', ('Start-' + 'Process'), '& git')) {
            $text.Contains($forbidden, [System.StringComparison]::OrdinalIgnoreCase) | Should -BeFalse -Because "the module must not reference $forbidden"
        }
    }

    It 'every time-dependent function declares -Now' {
        foreach ($name in @('Select-OwnerDirectivePassDown', 'Get-OwnerDirectiveRunningChildGap')) {
            (Get-Command -Name $name -Module 'OrchestratorStateOwnerDirectiveSelection').Parameters.ContainsKey('Now') | Should -BeTrue -Because $name
        }
    }
}
