#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Relative worktree_path record rows for the parallel worktree-removal gate (issue #995).

.DESCRIPTION
    A parallel run checkpoint records items[].worktree_path relative to the main checkout,
    while the removal command names the absolute path. These rows drive
    Invoke-ParallelWorktreeRemovalGateDecision end to end through the shipped record
    resolver: the checkpoint is held in a planning worktree, the main checkout root is
    supplied by a mock of Get-WorktreeRunMainCheckoutRoot, and the command names the target
    under that root. The allow rows cover merge_status merged and worktree_removed; the deny
    rows cover every unsafe status, a different agent directory, unsafe relative records,
    and an ambiguous checkpoint copy.

    The resolution seams are mocked with -ModuleName 'WorktreeRunResolution', the gate's
    checkpoint seams and Get-WorktreeRunMainCheckoutRoot in script scope, and the manifest
    reader with -ModuleName 'CleanupWorktreeManifest'. A mock of a command that is not yet
    defined is skipped, so the deny rows evaluate the unchanged gate. Synthetic roots use
    the /synthetic-worktrees/<name> form and Join-Path, because this folder also runs in
    the Linux hook-suite job. No row reads, creates, or writes a file, reads a wall clock,
    starts a process, or touches the network.

    The issue #1163 rows (RP7 to RP11) drive a host-moved record: its absolute worktree_path
    names no live root and its branch_name is mapped to the target by a suite-local resolver
    seam that records each invocation. A suite argument builder passes -BranchWorktreeResolver
    and -LiveWorktreeRoot only when Get-Command reports that the command under test declares
    them, so the identical rows run against the unmodified gate (fail-before) and the changed
    gate (pass-after).
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    # The shipped epic read seam, captured before the baseline mock below replaces it by name.
    $script:ShippedCheckpointReader = ${function:Get-ParallelWorktreeRemovalGateEpicCheckpointContent}
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    # Baseline null mocks for every read seam in the loaded closure (epic-state isolation guard).
    Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest { $null }
    Mock Get-ParallelWorktreeRemovalGateCheckpointContent { $null }
    Mock Get-ParallelWorktreeRemovalGateEpicCheckpointContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Get-WorktreeRunMainCheckoutRoot { $null }
    Mock Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution { $null }

    $script:Main = '/synthetic-worktrees/main'
    $script:Planning = '/synthetic-worktrees/planning'
    $script:Relative = '.claude/worktrees/agent-x'
    $script:Target = Join-Path -Path $script:Main -ChildPath $script:Relative
    $script:Target = $script:Target.Replace([string][char]92, '/')

    function ConvertTo-RemovalPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    function Get-ItemCheckpointText {
        param([AllowEmptyString()] [string] $WorktreePath, [AllowNull()] [string] $MergeStatus)
        $item = [ordered]@{ issue_num = 101; worktree_path = $WorktreePath }
        if ($null -ne $MergeStatus) { $item.merge_status = $MergeStatus }
        return ([ordered]@{ route_id = 'parallel'; items = @($item) } | ConvertTo-Json -Compress -Depth 5)
    }

    # True when the module-scope session state of a loaded module resolves the command.
    function Test-ModuleScopeCommand {
        param([string] $ModuleName, [string] $CommandName)
        $module = Get-Module -Name $ModuleName | Select-Object -First 1
        if ($null -eq $module) { return $false }
        return [bool] (& $module { param($Name) Get-Command -Name $Name -ErrorAction SilentlyContinue } $CommandName)
    }

    # Model the topology: the live roots, the checkpoint text held by each root, and the
    # main checkout root. The same text feeds the gate's own read seam.
    function Set-RelativeTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([hashtable] $Parallel = @{}, [string[]] $Live = @('/synthetic-worktrees/main', '/synthetic-worktrees/planning'), [hashtable] $Epic = @{})
        $liveSet = $Live
        $mainRoot = $script:Main
        $textMap = @{}
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        # Issue #1163: the optional epic map feeds the epic checkpoint path of both read seams;
        # rows that pass no -Epic keep a null epic read.
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith { , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        if (Test-ModuleScopeCommand -ModuleName WorktreeRunResolution -CommandName Get-WorktreeRunMainCheckoutRoot) {
            Mock -CommandName Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution -MockWith { $mainRoot }.GetNewClosure()
        }
        if (Get-Command -Name Get-WorktreeRunMainCheckoutRoot -ErrorAction SilentlyContinue) {
            Mock -CommandName Get-WorktreeRunMainCheckoutRoot -MockWith { $mainRoot }.GetNewClosure()
        }
        Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }

    # Issue #1163 (D9) fixture: a host-moved record names a worktree_path that is no live root,
    # and its branch_name is mapped to the target by the resolver seam.
    $script:HostMoved = '/host-a/repo/.claude/worktrees/agent-x'
    $script:Sibling = '/synthetic-worktrees/main/.claude/worktrees/agent-y'
    $script:Branch = 'feature/issue-1163-agent-x'
    $script:MovedLive = @($script:Main, $script:Planning, $script:Sibling, $script:Target)

    # One run checkpoint of one kind. Without -WithLiveSibling it holds the host-moved record;
    # with it, record A names the live sibling (same branch_name, merged) and record B names
    # the target directly with the given merge_status.
    function Get-HostMovedCheckpointText {
        param([ValidateSet('epic', 'parallel')] [string] $Kind, [string] $MergeStatus, [switch] $WithLiveSibling)
        $records = if ($WithLiveSibling) {
            @([ordered]@{ worktree_path = $script:Sibling; branch_name = $script:Branch; merge_status = 'merged' }, [ordered]@{ worktree_path = $script:Target; merge_status = $MergeStatus })
        }
        else { @([ordered]@{ worktree_path = $script:HostMoved; branch_name = $script:Branch; merge_status = $MergeStatus }) }
        foreach ($record in $records) { if ($Kind -eq 'parallel') { $record.issue_num = 101 } else { $record.feature_folder = 'child-a' } }
        $document = if ($Kind -eq 'parallel') { [ordered]@{ route_id = 'parallel'; items = $records } } else { [ordered]@{ route_id = 'epic'; features = $records } }
        return ($document | ConvertTo-Json -Compress -Depth 5)
    }

    # Places one checkpoint of the given kind in the planning root over the host-moved live set.
    function Set-HostMovedTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Kind, [string] $Text)
        if ($Kind -eq 'parallel') { Set-RelativeTopology -Parallel @{ $script:Planning = $Text } -Live $script:MovedLive }
        else { Set-RelativeTopology -Epic @{ $script:Planning = $Text } -Live $script:MovedLive }
    }

    # The D9 resolver seam: the fixture branch gives Root, any other branch or a ReasonCode gives a
    # null root and that code, and every invocation is appended to the row's Calls list.
    function Get-BranchResolverSeam {
        param([AllowNull()] [string] $Root, [AllowNull()] [string] $ReasonCode, [System.Collections.Generic.List[string]] $Calls)
        $mapped = $Root; $code = $ReasonCode; $callList = $Calls; $known = $script:Branch
        return {
            param($Branch)
            $callList.Add([string] $Branch)
            if ([string]::IsNullOrEmpty($code) -and [string] $Branch -ceq $known) { return [pscustomobject]@{ WorktreeRoot = $mapped; ReasonCode = $null } }
            return [pscustomobject]@{ WorktreeRoot = $null; ReasonCode = $(if ($code) { $code } else { 'TARGET_WORKTREE_NOT_DERIVABLE' }) }
        }.GetNewClosure()
    }

    # Issue #1163 argument builder: each optional argument is passed only when Get-Command reports
    # that the command declares it, so the RP7 to RP11 rows run unchanged against the unmodified
    # gate (fail-before) and the changed gate.
    function Get-DeclaredArgument {
        param([string] $CommandName, [hashtable] $Arguments, [hashtable] $Optional = @{})
        $declared = (Get-Command -Name $CommandName).Parameters
        foreach ($key in $Optional.Keys) { if ($declared.ContainsKey($key)) { $Arguments[$key] = $Optional[$key] } }
        return $Arguments
    }

    function Get-RemovalDecisionArgument {
        param([scriptblock] $Resolver)
        return (Get-DeclaredArgument -CommandName Invoke-ParallelWorktreeRemovalGateDecision -Arguments @{ ToolInputRaw = (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)") } -Optional @{ BranchWorktreeResolver = $Resolver })
    }
}

Describe 'parallel worktree-removal gate with a relative worktree_path record' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'RP1 allows removal of the absolute target when the relative record has merge_status <Status>' -ForEach @(
        @{ Status = 'merged' }
        @{ Status = 'worktree_removed' }
    ) {
        # Arrange
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/planning' = (Get-ItemCheckpointText -WorktreePath $script:Relative -MergeStatus $Status) }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'RP2 denies when <Label>' -ForEach @(
        @{ Label = 'the relative record has merge_status pr_open'; Recorded = '.claude/worktrees/agent-x'; Status = 'pr_open' }
        @{ Label = 'the relative record has merge_status worktree_created'; Recorded = '.claude/worktrees/agent-x'; Status = 'worktree_created' }
        @{ Label = 'the relative record has no merge_status'; Recorded = '.claude/worktrees/agent-x'; Status = $null }
        @{ Label = 'the relative record names a different agent directory'; Recorded = '.claude/worktrees/agent-y'; Status = 'merged' }
        @{ Label = 'the relative record is ..'; Recorded = '..'; Status = 'merged' }
        @{ Label = 'the relative record is blank'; Recorded = ''; Status = 'merged' }
    ) {
        # Arrange
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/planning' = (Get-ItemCheckpointText -WorktreePath $Recorded -MergeStatus $Status) }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('PARALLEL_WORKTREE_REMOVAL_BLOCKED') | Should -BeTrue
    }

    It 'RP3 denies when the same merged relative record is held in both live roots (ambiguous)' {
        # Arrange
        $text = Get-ItemCheckpointText -WorktreePath $script:Relative -MergeStatus 'merged'
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/main' = $text; '/synthetic-worktrees/planning' = $text }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('PARALLEL_WORKTREE_REMOVAL_BLOCKED') | Should -BeTrue
    }

    It 'RP4 finds a relative epic features[] record through Find-ParallelWorktreeItemRecord -BaseRoot' {
        # Arrange
        $checkpoint = '{"route_id":"epic","features":[{"feature_folder":"child-a","worktree_path":".claude/worktrees/agent-x","merge_status":"merged"}]}' | ConvertFrom-Json

        # Act
        $record = Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath $script:Target -RecordArrayName 'features' -BaseRoot @($script:Main, $script:Planning)

        # Assert
        $record | Should -Not -BeNullOrEmpty
        $record.feature_folder | Should -Be 'child-a'
    }

    It 'RP5 returns no text from the shipped epic checkpoint reader when the checkpoint file is absent' {
        # Arrange: the file-system probe is mocked, so no file is read.
        Mock -CommandName Test-Path -MockWith { $false }
        Mock -CommandName Get-Content -MockWith { 'unexpected' }

        # Act
        $text = & $script:ShippedCheckpointReader -Path '/synthetic-worktrees/planning/artifacts/orchestration/epic-orchestrator-state.json'

        # Assert
        $text | Should -BeNullOrEmpty
        Should -Invoke -CommandName Get-Content -Times 0 -Exactly
    }

    It 'RP6 returns the checkpoint text from the shipped epic checkpoint reader when the file is present' {
        # Arrange: both the probe and the read are mocked, so no file is read.
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Get-Content -MockWith { '{"route_id":"epic"}' }

        # Act
        $text = & $script:ShippedCheckpointReader -Path '/synthetic-worktrees/planning/artifacts/orchestration/epic-orchestrator-state.json'

        # Assert
        $text | Should -Be '{"route_id":"epic"}'
    }
}

Describe 'parallel worktree-removal gate with a host-moved worktree_path record (issue #1163)' {
    It 'RP7 allows removal of a host-moved <Kind> record through its branch_name' -ForEach @(@{ Kind = 'parallel' }, @{ Kind = 'epic' }) {
        # Arrange (fails before: the host-moved record names no live root and matches nothing)
        $calls = [System.Collections.Generic.List[string]]::new()
        Set-HostMovedTopology -Kind $Kind -Text (Get-HostMovedCheckpointText -Kind $Kind -MergeStatus 'merged')
        $arguments = Get-RemovalDecisionArgument -Resolver (Get-BranchResolverSeam -Root $script:Target -Calls $calls)

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision @arguments

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'RP8 finds a host-moved epic features[] record through Find-ParallelWorktreeItemRecord' {
        # Arrange (fails before: the matcher cannot see the host-moved record)
        $calls = [System.Collections.Generic.List[string]]::new()
        $checkpoint = (Get-HostMovedCheckpointText -Kind epic -MergeStatus 'merged') | ConvertFrom-Json
        $resolver = Get-BranchResolverSeam -Root $script:Target -Calls $calls
        $arguments = Get-DeclaredArgument -CommandName Find-ParallelWorktreeItemRecord -Arguments @{ Checkpoint = $checkpoint; WorktreePath = $script:Target; RecordArrayName = 'features'; BaseRoot = @($script:Main, $script:Planning) } -Optional @{ LiveWorktreeRoot = $script:MovedLive; BranchWorktreeResolver = $resolver }

        # Act
        $record = Find-ParallelWorktreeItemRecord @arguments

        # Assert
        $record | Should -Not -BeNullOrEmpty
        $record.feature_folder | Should -Be 'child-a'
    }

    It 'RP9 denies a host-moved <Kind> record whose branch resolves to <ReasonCode>' -ForEach @(
        @{ Kind = 'parallel'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE' }
        @{ Kind = 'parallel'; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS' }
        @{ Kind = 'epic'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE' }
        @{ Kind = 'epic'; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS' }
    ) {
        # Arrange (unchanged deny)
        $calls = [System.Collections.Generic.List[string]]::new()
        Set-HostMovedTopology -Kind $Kind -Text (Get-HostMovedCheckpointText -Kind $Kind -MergeStatus 'merged')
        $arguments = Get-RemovalDecisionArgument -Resolver (Get-BranchResolverSeam -ReasonCode $ReasonCode -Calls $calls)

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision @arguments

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('PARALLEL_WORKTREE_REMOVAL_BLOCKED') | Should -BeTrue
    }

    It 'RP10 keeps the deny without calling the resolver when a <Kind> record names another live worktree' -ForEach @(@{ Kind = 'parallel' }, @{ Kind = 'epic' }) {
        # Arrange (unchanged decision): record A names the live sibling, record B names the target
        $calls = [System.Collections.Generic.List[string]]::new()
        Set-HostMovedTopology -Kind $Kind -Text (Get-HostMovedCheckpointText -Kind $Kind -MergeStatus 'pr_open' -WithLiveSibling)
        $arguments = Get-RemovalDecisionArgument -Resolver (Get-BranchResolverSeam -Root $script:Target -Calls $calls)

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision @arguments

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $calls.Count | Should -Be 0
    }

    It 'RP11 applies the default resolver to a host-moved <Kind> record' -ForEach @(@{ Kind = 'parallel' }, @{ Kind = 'epic' }) {
        # Arrange (fails before: the unmodified gate has no default resolver)
        Set-HostMovedTopology -Kind $Kind -Text (Get-HostMovedCheckpointText -Kind $Kind -MergeStatus 'merged')
        $target = $script:Target
        if (Get-Command -Name Resolve-AgentTargetWorktree -ErrorAction SilentlyContinue) {
            Mock -CommandName Resolve-AgentTargetWorktree -MockWith { [pscustomobject]@{ WorktreeRoot = $target; ReasonCode = $null } }.GetNewClosure()
        }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $branch = $script:Branch
        Should -Invoke Resolve-AgentTargetWorktree -ParameterFilter { $CommandBranch -eq $branch -and $Policy -eq 'FailClosedOnIdentity' }
    }
}
