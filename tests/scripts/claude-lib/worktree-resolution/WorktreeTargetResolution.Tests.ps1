#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for call-target derivation (issue #669).

.DESCRIPTION
    Covers the target result factory, the three signal extractors, the required
    matrix of cwd x path form x target, every Ambiguous sub-case, NoTarget
    distinguishability, the Ruling B precedence rules, path composition, and the
    deny-reason concatenation a gate performs.

    Worktree topologies are modelled entirely by mocks of the three seams in
    WorktreeResolution.psm1, registered with -ModuleName 'WorktreeResolution'
    because every filesystem read runs inside that module even when the call
    starts here. No test creates, writes, or reads a temporary file, reads a wall
    clock, spawns a process, or touches the network.
#>

BeforeAll {
    # Resolve both modules four levels up (worktree-resolution -> claude-lib ->
    # scripts -> tests -> repo root), File 1 first. Resolve-Path normalizes
    # separators so Pester coverage breakpoints bind to the run-settings paths.
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution/WorktreeResolution.psm1").Path -Force
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1").Path -Force

    function New-TestTopology {
        # A main checkout at C:/repo on branch main, three linked worktrees, and the
        # supplied feature folders. $Branch overrides a linked worktree's branch.
        param([string[]] $Directory = @(), [hashtable] $Branch = @{})

        $linked = @(
            @{ Name = 'session'; Root = 'C:/repo-wt/session'; Branch = 'feature/session' }
            @{ Name = 'item'; Root = 'C:/repo/.claude/worktrees/item'; Branch = 'feature/item-700' }
            @{ Name = 'sibling'; Root = 'C:/repo-wt/sibling'; Branch = 'feature/sibling-701' }
        )
        $topology = @{
            Kind     = @{ 'C:/repo/.git' = 'Directory' }
            Text     = @{ 'C:/repo/.git/HEAD' = 'ref: refs/heads/main' }
            Children = @{ 'C:/repo/.git/worktrees' = [string[]] @('session', 'item', 'sibling') }
        }
        foreach ($worktree in $linked) {
            $admin = "C:/repo/.git/worktrees/$($worktree.Name)"
            $name = if ($Branch.ContainsKey($worktree.Name)) { $Branch[$worktree.Name] } else { $worktree.Branch }
            $topology.Kind["$($worktree.Root)/.git"] = 'File'
            $topology.Text["$($worktree.Root)/.git"] = "gitdir: $admin"
            $topology.Text["$admin/commondir"] = '../..'
            $topology.Text["$admin/gitdir"] = "$($worktree.Root)/.git"
            $topology.Text["$admin/HEAD"] = "ref: refs/heads/$name"
        }
        foreach ($path in $Directory) {
            $topology.Kind[$path] = 'Directory'
        }
        return $topology
    }

    function Set-TopologyMock {
        # Route the three seams to the $Topology variable of the calling test.
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith {
            param([string] $Path)
            if ($Topology.Kind.ContainsKey($Path)) { $Topology.Kind[$Path] } else { 'None' }
        }
        Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith {
            param([string] $Path)
            $Topology.Text[$Path]
        }
        Mock -CommandName Get-WorktreeResolutionDirectoryChildName -ModuleName 'WorktreeResolution' -MockWith {
            param([string] $Path)
            if ($Topology.Children.ContainsKey($Path)) { , [string[]] $Topology.Children[$Path] } else { , [string[]] @() }
        }
    }

    # The standard feature folders: one per worktree that holds state, one absent.
    $script:StandardFolders = @(
        'C:/repo-wt/session/docs/features/active/2026-09-13-session-699'
        'C:/repo/.claude/worktrees/item/docs/features/active/2026-09-13-item-700'
        'C:/repo-wt/sibling/docs/features/active/2026-09-13-sibling-701'
    )
}

Describe 'WorktreeTargetResolution' {
    BeforeAll {
        # Default seam behavior: nothing exists. Topology tests re-register the seams.
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'None' }
        Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith { $null }
        Mock -CommandName Get-WorktreeResolutionDirectoryChildName -ModuleName 'WorktreeResolution' -MockWith { , [string[]] @() }
    }

    Context 'result factory and field invariants' {
        It 'enforces the field invariants for Status <Status>' -ForEach @(
            @{ Status = 'SessionRoot'; Root = 'C:\repo\'; Candidate = @('C:/repo'); Resolved = $true }
            @{ Status = 'OtherWorktree'; Root = 'C:/repo-wt/sibling'; Candidate = @('C:/repo-wt/sibling'); Resolved = $true }
            @{ Status = 'NoTarget'; Root = 'C:/ignored'; Candidate = @('C:/ignored'); Resolved = $false }
            @{ Status = 'Ambiguous'; Root = 'C:/ignored'; Candidate = @(); Resolved = $false }
        ) {
            # Arrange / Act: build a result through the single factory.
            $result = New-WorktreeResolutionTargetResult -Status $Status -SessionRoot 'C:\repo-wt\session\' -WorktreeRoot $Root -Signal 'Branch' -SignalValue 'feature/x' -Candidate $Candidate -Detail 'a clause'

            # Assert: the shape a caller relies on without a null check.
            $result | Should -BeOfType [pscustomobject]
            $result.SessionRoot | Should -BeExactly 'C:/repo-wt/session'
            , $result.Candidates | Should -BeOfType [string[]]
            $result.Detail | Should -Not -BeNullOrEmpty
            if ($Status -eq 'Ambiguous') { $result.ReasonCode | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS' } else { $result.ReasonCode | Should -BeNullOrEmpty }
            if ($Resolved) { $result.WorktreeRoot | Should -Not -BeNullOrEmpty } else { $result.WorktreeRoot | Should -BeNullOrEmpty }
            if ($Status -eq 'NoTarget') {
                $result.Signal | Should -BeNullOrEmpty
                $result.SignalValue | Should -BeNullOrEmpty
                $result.Candidates.Count | Should -Be 0
            }
        }

        It 'refuses a resolved Status without a WorktreeRoot' {
            # Arrange / Act / Assert: a resolved result with no root would read as unresolved.
            { New-WorktreeResolutionTargetResult -Status 'OtherWorktree' -SessionRoot 'C:/repo' -Detail 'a clause' } | Should -Throw '*requires a WorktreeRoot*'
        }

        It 'refuses an empty Detail or SessionRoot and an unknown Status' {
            # Arrange / Act / Assert: the always-populated fields cannot be blank.
            { New-WorktreeResolutionTargetResult -Status 'NoTarget' -SessionRoot 'C:/repo' -Detail ' ' } | Should -Throw
            { New-WorktreeResolutionTargetResult -Status 'NoTarget' -SessionRoot ' ' -Detail 'a clause' } | Should -Throw
            { New-WorktreeResolutionTargetResult -Status 'Resolved' -SessionRoot 'C:/repo' -Detail 'a clause' } | Should -Throw
        }

        It 'returns an object carrying exactly the eight contract fields from Resolve-WorktreeCallTarget' {
            # Arrange / Act: a call with no signal at all.
            $result = Resolve-WorktreeCallTarget -Text 'no target here' -SessionRoot 'C:/repo'

            # Assert: never null, and the field set is the published contract.
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [pscustomobject]
            @($result.PSObject.Properties.Name) | Should -Be @('Status', 'WorktreeRoot', 'SessionRoot', 'Signal', 'SignalValue', 'Candidates', 'ReasonCode', 'Detail')
        }

        It 'defaults SessionRoot to the worktree containing the current location' {
            # Arrange: the current location sits below the session worktree.
            $Topology = New-TestTopology
            Set-TopologyMock
            Mock -CommandName Get-Location -ModuleName 'WorktreeTargetResolution' -MockWith { [pscustomobject]@{ ProviderPath = 'C:\repo-wt\session\scripts' } }

            # Act: resolve without an explicit session root.
            $result = Resolve-WorktreeCallTarget -Text 'nothing named'

            # Assert: the locator's answer, not the raw location, is the session root.
            $result.SessionRoot | Should -BeExactly 'C:/repo-wt/session'
        }

        It 'falls back to the normalised current location when no worktree contains it' {
            # Arrange: default mocks, so no level carries a marker.
            Mock -CommandName Get-Location -ModuleName 'WorktreeTargetResolution' -MockWith { [pscustomobject]@{ ProviderPath = 'D:\scratch\' } }

            # Act / Assert: SessionRoot is still populated.
            (Resolve-WorktreeCallTarget -Text '').SessionRoot | Should -BeExactly 'D:/scratch'
        }
    }

    Context 'signal extraction' {
        It 'preserves the absolute prefix of a Windows-style feature-folder path' {
            # Arrange: a prompt naming a spec file by its absolute path.
            $text = 'Plan C:\Users\dev\repo-wt\session\docs\features\active\2026-09-13-item-700\spec.md now.'

            # Act: extract the feature-folder token.
            $actual = Find-WorktreeResolutionFeatureFolderSignal -Text $text

            # Assert: the drive and worktree prefix survive; the token ends at the folder.
            $actual | Should -BeExactly 'C:\Users\dev\repo-wt\session\docs\features\active\2026-09-13-item-700'
        }

        It 'returns the bare token for <Label>' -ForEach @(
            @{ Label = 'a repo-relative path'; Text = 'see docs/features/active/2026-09-13-item-700/spec.md'; Expected = 'docs/features/active/2026-09-13-item-700' }
            @{ Label = 'a quoted path ending a sentence'; Text = 'folder "docs/features/active/2026-09-13-item-700".'; Expected = 'docs/features/active/2026-09-13-item-700' }
        ) {
            # Arrange / Act: extract from a prompt with no absolute prefix.
            $actual = Find-WorktreeResolutionFeatureFolderSignal -Text $Text

            # Assert: nothing is invented in front of a relative token.
            $actual | Should -BeExactly $Expected
        }

        It 'reads a branch from <Label>' -ForEach @(
            @{ Label = 'a --head option'; Text = 'gh pr create --head feature/item-700 --base main'; Expected = 'feature/item-700' }
            @{ Label = 'a --branch= option'; Text = 'run --branch=feature/sibling-701.'; Expected = 'feature/sibling-701' }
            @{ Label = 'a branch: label'; Text = 'Branch: main'; Expected = 'main' }
        ) {
            # Arrange / Act: extract the branch token.
            $actual = Find-WorktreeResolutionBranchSignal -Text $Text

            # Assert: only the name is returned.
            $actual | Should -BeExactly $Expected
        }

        It 'reads an absolute file path from <Label>' -ForEach @(
            @{ Label = 'a drive-rooted path'; Text = 'edit C:\repo\scripts\tool.ps1 please'; Expected = 'C:\repo\scripts\tool.ps1' }
            @{ Label = 'a slash-rooted path'; Text = "open '/srv/repo/notes/a.md'"; Expected = '/srv/repo/notes/a.md' }
        ) {
            # Arrange / Act: extract the file-path token.
            $actual = Find-WorktreeResolutionFilePathSignal -Text $Text

            # Assert: the absolute path is returned verbatim.
            $actual | Should -BeExactly $Expected
        }

        It 'returns null from <Extractor> for <Label>' -ForEach @(
            @{ Extractor = 'Find-WorktreeResolutionFeatureFolderSignal'; Label = 'an embedded non-token'; Text = 'foo-docs/features/active/x and scripts/tool.ps1' }
            @{ Extractor = 'Find-WorktreeResolutionBranchSignal'; Label = 'prose naming no branch'; Text = 'the feature branch is ready' }
            @{ Extractor = 'Find-WorktreeResolutionFilePathSignal'; Label = 'relative paths and a URL'; Text = 'edit scripts/tool.ps1 and https://example.test/a.md' }
            @{ Extractor = 'Find-WorktreeResolutionFeatureFolderSignal'; Label = 'a null payload'; Text = $null }
        ) {
            # Arrange / Act: scan a payload that names nothing of this kind.
            $actual = & $Extractor -Text $Text

            # Assert: absence is null, never an empty or partial token.
            $actual | Should -BeNullOrEmpty
        }
    }

    Context 'required matrix' {
        # cwd (session root C:/repo-wt/session versus item worktree
        # C:/repo/.claude/worktrees/item) x path form x target. "own" names a folder in
        # the cwd's worktree, "sibling" a folder only in C:/repo-wt/sibling, and "absent"
        # a folder in no worktree while sibling state is present. Rows whose cwd and
        # target coincide are the regression guards for today's behaviour.
        It 'required matrix row: cwd <Cwd>, <Form> path, <Target> target resolves to <ExpectedStatus>' -ForEach @(
            @{ Cwd = 'session'; Form = 'relative'; Target = 'own'; Session = 'C:/repo-wt/session'; Token = 'docs/features/active/2026-09-13-session-699'; ExpectedStatus = 'SessionRoot'; ExpectedRoot = 'C:/repo-wt/session' }
            @{ Cwd = 'session'; Form = 'absolute'; Target = 'own'; Session = 'C:/repo-wt/session'; Token = 'C:\repo-wt\session\docs\features\active\2026-09-13-session-699\spec.md'; ExpectedStatus = 'SessionRoot'; ExpectedRoot = 'C:/repo-wt/session' }
            @{ Cwd = 'session'; Form = 'relative'; Target = 'sibling'; Session = 'C:/repo-wt/session'; Token = 'docs/features/active/2026-09-13-sibling-701'; ExpectedStatus = 'OtherWorktree'; ExpectedRoot = 'C:/repo-wt/sibling' }
            @{ Cwd = 'session'; Form = 'absolute'; Target = 'sibling'; Session = 'C:/repo-wt/session'; Token = 'C:\repo-wt\sibling\docs\features\active\2026-09-13-sibling-701\plan.md'; ExpectedStatus = 'OtherWorktree'; ExpectedRoot = 'C:/repo-wt/sibling' }
            @{ Cwd = 'session'; Form = 'relative'; Target = 'absent'; Session = 'C:/repo-wt/session'; Token = 'docs/features/active/2026-09-13-absent-702'; ExpectedStatus = 'Ambiguous'; ExpectedRoot = $null }
            @{ Cwd = 'session'; Form = 'absolute'; Target = 'absent'; Session = 'C:/repo-wt/session'; Token = 'D:\elsewhere\docs\features\active\2026-09-13-absent-702'; ExpectedStatus = 'Ambiguous'; ExpectedRoot = $null }
            @{ Cwd = 'item'; Form = 'relative'; Target = 'own'; Session = 'C:/repo/.claude/worktrees/item'; Token = 'docs/features/active/2026-09-13-item-700'; ExpectedStatus = 'SessionRoot'; ExpectedRoot = 'C:/repo/.claude/worktrees/item' }
            @{ Cwd = 'item'; Form = 'absolute'; Target = 'own'; Session = 'C:/repo/.claude/worktrees/item'; Token = 'C:/repo/.claude/worktrees/item/docs/features/active/2026-09-13-item-700'; ExpectedStatus = 'SessionRoot'; ExpectedRoot = 'C:/repo/.claude/worktrees/item' }
            @{ Cwd = 'item'; Form = 'relative'; Target = 'sibling'; Session = 'C:/repo/.claude/worktrees/item'; Token = 'docs/features/active/2026-09-13-sibling-701'; ExpectedStatus = 'OtherWorktree'; ExpectedRoot = 'C:/repo-wt/sibling' }
            @{ Cwd = 'item'; Form = 'absolute'; Target = 'sibling'; Session = 'C:/repo/.claude/worktrees/item'; Token = 'C:/repo-wt/sibling/docs/features/active/2026-09-13-sibling-701'; ExpectedStatus = 'OtherWorktree'; ExpectedRoot = 'C:/repo-wt/sibling' }
            @{ Cwd = 'item'; Form = 'relative'; Target = 'absent'; Session = 'C:/repo/.claude/worktrees/item'; Token = 'docs/features/active/2026-09-13-absent-702'; ExpectedStatus = 'Ambiguous'; ExpectedRoot = $null }
            @{ Cwd = 'item'; Form = 'absolute'; Target = 'absent'; Session = 'C:/repo/.claude/worktrees/item'; Token = 'D:/elsewhere/docs/features/active/2026-09-13-absent-702'; ExpectedStatus = 'Ambiguous'; ExpectedRoot = $null }
        ) {
            # Arrange: the standard three-worktree topology with its feature folders.
            $Topology = New-TestTopology -Directory $script:StandardFolders
            Set-TopologyMock

            # Act: derive the target of a prompt naming the row's token.
            $result = Resolve-WorktreeCallTarget -Text "Plan the work in $Token." -SessionRoot $Session

            # Assert: the row's state, and never a resolved root for an absent target.
            $result.Status | Should -BeExactly $ExpectedStatus
            $result.SessionRoot | Should -BeExactly $Session
            $result.Signal | Should -BeExactly 'FeatureFolderPath'
            if ($ExpectedStatus -eq 'Ambiguous') {
                $result.WorktreeRoot | Should -BeNullOrEmpty
                $result.ReasonCode | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
                $result.Candidates.Count | Should -Be 0
            } else {
                $result.WorktreeRoot | Should -BeExactly $ExpectedRoot
                $result.ReasonCode | Should -BeNullOrEmpty
                $result.Candidates | Should -Be @($ExpectedRoot)
            }
            if ($ExpectedStatus -eq 'SessionRoot') {
                $result.WorktreeRoot | Should -BeExactly $result.SessionRoot
            }
        }
    }

    Context 'ambiguity, no target, and Ruling B' {
        It 'ambiguous sub-case: <Label>' -ForEach @(
            @{ Label = 'a relative feature-folder token present in two worktrees'; Text = 'docs/features/active/2026-09-13-shared-703'; Branch = ''; Signal = 'FeatureFolderPath'; Count = 2 }
            @{ Label = 'a relative feature-folder token present in no worktree'; Text = 'docs/features/active/2026-09-13-absent-702'; Branch = ''; Signal = 'FeatureFolderPath'; Count = 0 }
            @{ Label = 'an absolute path whose upward walk finds no .git entry'; Text = 'D:\elsewhere\docs\features\active\2026-09-13-item-700'; Branch = ''; Signal = 'FeatureFolderPath'; Count = 0 }
            @{ Label = 'a branch matching no worktree'; Text = ''; Branch = 'feature/none'; Signal = 'Branch'; Count = 0 }
            @{ Label = 'a branch matching more than one worktree'; Text = 'gh pr create --head feature/shared'; Branch = ''; Signal = 'Branch'; Count = 2 }
            @{ Label = 'two signals resolving to different worktree roots'; Text = 'C:/repo/.claude/worktrees/item/docs/features/active/2026-09-13-item-700'; Branch = 'feature/sibling-701'; Signal = 'FeatureFolderPath'; Count = 2 }
        ) {
            # Arrange: the shared folder exists in two worktrees and two worktrees share a branch.
            $folders = $script:StandardFolders + @('C:/repo-wt/session/docs/features/active/2026-09-13-shared-703', 'C:/repo-wt/sibling/docs/features/active/2026-09-13-shared-703')
            $Topology = New-TestTopology -Directory $folders -Branch @{ session = 'feature/shared'; item = 'feature/shared' }
            if ($Branch -eq 'feature/sibling-701') { $Topology = New-TestTopology -Directory $folders }
            Set-TopologyMock

            # Act: derive the target from the row's signals.
            $result = Resolve-WorktreeCallTarget -Text $Text -Branch $Branch -SessionRoot 'C:/repo-wt/session'

            # Assert: a present signal that cannot be placed once denies with the code.
            $result.Status | Should -BeExactly 'Ambiguous'
            $result.ReasonCode | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
            $result.WorktreeRoot | Should -BeNullOrEmpty
            $result.Signal | Should -BeExactly $Signal
            $result.SignalValue | Should -Not -BeNullOrEmpty
            $result.Candidates.Count | Should -Be $Count
            $result.Detail | Should -Not -BeNullOrEmpty
        }

        It 'returns NoTarget with empty signal fields for a payload naming nothing, without reading the filesystem' {
            # Arrange / Act: a prompt with no feature folder, file path, or branch.
            $result = Resolve-WorktreeCallTarget -Text 'Summarise the discussion so far.' -SessionRoot 'C:/repo-wt/session'

            # Assert: the untargeted state, reached with no seam call at all.
            $result.Status | Should -BeExactly 'NoTarget'
            $result.Signal | Should -BeNullOrEmpty
            $result.SignalValue | Should -BeNullOrEmpty
            $result.WorktreeRoot | Should -BeNullOrEmpty
            $result.ReasonCode | Should -BeNullOrEmpty
            , $result.Candidates | Should -BeOfType [string[]]
            $result.Candidates.Count | Should -Be 0
            Should -Invoke -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -Times 0 -Exactly
        }

        It 'distinguishes NoTarget from Ambiguous by Status and ReasonCode alone' {
            # Arrange: default mocks, so a named folder cannot be placed.
            $noTarget = Resolve-WorktreeCallTarget -Text 'no signal' -SessionRoot 'C:/repo'
            $ambiguous = Resolve-WorktreeCallTarget -Text 'docs/features/active/2026-09-13-item-700' -SessionRoot 'C:/repo'

            # Act: classify each result from its own fields only.
            $classify = { param($r) if ($null -ne $r.ReasonCode) { 'deny' } elseif ($null -eq $r.WorktreeRoot) { 'fallback' } else { 'resolved' } }

            # Assert: both fields separate the two unresolved states.
            $noTarget.Status | Should -Not -Be $ambiguous.Status
            $noTarget.ReasonCode | Should -Not -Be $ambiguous.ReasonCode
            (& $classify $noTarget) | Should -BeExactly 'fallback'
            (& $classify $ambiguous) | Should -BeExactly 'deny'
        }

        It 'deduplicates two agreeing signals and reports the higher-precedence kind <Expected>' -ForEach @(
            @{ Text = 'docs/features/active/2026-09-13-item-700 on --head feature/item-700'; FilePath = ''; Expected = 'FeatureFolderPath' }
            @{ Text = 'push --head feature/item-700'; FilePath = 'C:\repo\.claude\worktrees\item\scripts\tool.ps1'; Expected = 'FilePath' }
        ) {
            # Arrange: every signal names the item worktree.
            $Topology = New-TestTopology -Directory $script:StandardFolders
            Set-TopologyMock

            # Act: derive the target from the agreeing signals.
            $result = Resolve-WorktreeCallTarget -Text $Text -FilePath $FilePath -SessionRoot 'C:/repo-wt/session'

            # Assert: one candidate, resolved normally, with the precedence-reported kind.
            $result.Status | Should -BeExactly 'OtherWorktree'
            $result.WorktreeRoot | Should -BeExactly 'C:/repo/.claude/worktrees/item'
            $result.Candidates | Should -Be @('C:/repo/.claude/worktrees/item')
            $result.Signal | Should -BeExactly $Expected
        }

        It 'never lets precedence suppress a disagreement between a relative file path and a branch' {
            # Arrange: a relative file path present only in the session worktree, a branch on the sibling.
            $Topology = New-TestTopology -Directory @('C:/repo-wt/session/notes/todo.md')
            Set-TopologyMock

            # Act: FilePath outranks Branch, but the two name different worktrees.
            $result = Resolve-WorktreeCallTarget -FilePath 'notes\todo.md' -Branch 'feature/sibling-701' -SessionRoot 'C:/repo-wt/session'

            # Assert: the disagreement denies; the higher-precedence kind is only reported.
            $result.Status | Should -BeExactly 'Ambiguous'
            $result.Signal | Should -BeExactly 'FilePath'
            $result.Candidates | Should -Be @('C:/repo-wt/session', 'C:/repo-wt/sibling')
        }

        It 'concatenates into a gate deny reason carrying both tokens' {
            # Arrange: an ambiguous result for a folder no worktree holds.
            $result = Resolve-WorktreeCallTarget -Text 'docs/features/active/2026-09-13-item-700' -SessionRoot 'C:/repo'

            # Act: compose the reason exactly as a gate would.
            $reason = 'PRD_FEATURE_BLOCKED: ' + $result.ReasonCode + ' - ' + $result.Detail

            # Assert: greppable by the gate token and by the cause code.
            $reason | Should -BeLike 'PRD_FEATURE_BLOCKED: *'
            $reason | Should -BeLike '*TARGET_WORKTREE_AMBIGUOUS*'
            $reason | Should -BeLike "*docs/features/active/2026-09-13-item-700*"
        }

        It 'produces each of the four Status values from a documented input' {
            # Arrange: the standard topology.
            $Topology = New-TestTopology -Directory $script:StandardFolders
            Set-TopologyMock

            # Act: one documented input per state.
            $statuses = @(
                (Resolve-WorktreeCallTarget -Text 'docs/features/active/2026-09-13-session-699' -SessionRoot 'C:/repo-wt/session').Status
                (Resolve-WorktreeCallTarget -Text 'docs/features/active/2026-09-13-item-700' -SessionRoot 'C:/repo-wt/session').Status
                (Resolve-WorktreeCallTarget -Text 'nothing named' -SessionRoot 'C:/repo-wt/session').Status
                (Resolve-WorktreeCallTarget -Text 'docs/features/active/2026-09-13-absent-702' -SessionRoot 'C:/repo-wt/session').Status
            )

            # Assert: the closed set is fully reachable.
            $statuses | Should -Be @('SessionRoot', 'OtherWorktree', 'NoTarget', 'Ambiguous')
        }
    }

    Context 'path composition' {
        It 'join composes an absolute path from <Label>' -ForEach @(
            @{ Label = 'a backslash-separated root'; Root = 'C:\repo-wt\session'; Relative = 'artifacts\orchestration\orchestrator-state.json'; Expected = 'C:/repo-wt/session/artifacts/orchestration/orchestrator-state.json' }
            @{ Label = 'a root with a trailing slash'; Root = 'C:/repo/'; Relative = './docs/features/'; Expected = 'C:/repo/docs/features' }
            @{ Label = 'a remainder deeper than four segments'; Root = '/srv/repo'; Relative = 'a/b/c/d/e/f.md'; Expected = '/srv/repo/a/b/c/d/e/f.md' }
            @{ Label = 'a blank remainder'; Root = 'C:/repo'; Relative = ' '; Expected = 'C:/repo' }
        ) {
            # Arrange / Act: compose the row's root and remainder.
            $actual = Join-WorktreeResolutionPath -WorktreeRoot $Root -RepoRelativePath $Relative

            # Assert: absolute, forward slashes, no trailing slash, nothing dropped.
            $actual | Should -BeExactly $Expected
        }

        It 'refuses a relative worktree root' {
            # Arrange / Act / Assert: a relative root would reintroduce cwd-relative resolution.
            { Join-WorktreeResolutionPath -WorktreeRoot 'repo' -RepoRelativePath 'docs' } | Should -Throw '*absolute path*'
        }
    }
}
