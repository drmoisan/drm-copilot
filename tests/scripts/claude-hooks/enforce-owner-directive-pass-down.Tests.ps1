#Requires -Version 7.0

<#
.SYNOPSIS
    Relay, acknowledgement, ledger-guard, and inert-default tests for enforce-owner-directive-pass-down.ps1 (issue #1157).

.DESCRIPTION
    The hook is dot-sourced, so its entry point does not run, and Get-OwnerDirectivePassDownDecision
    is called with injected seams: an in-memory file map keyed by /synthetic-worktrees/ paths, an
    in-memory worktree listing, a fixed clock, a fixed epic resolver, and a decision-file existence
    set. No test touches the file system, git, or the wall clock.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected seam stubs mirror the production script-block signatures and ignore some parameters.')]
param()

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    . (Join-Path $script:RepoRoot '.claude/hooks/enforce-owner-directive-pass-down.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Mock Read-OwnerDirectiveFileText { $null }

    $script:Session = '/synthetic-worktrees/main'
    $script:Item = '/synthetic-worktrees/item-1157'
    $script:Epic = '/synthetic-worktrees/epic'
    $script:Branch = 'feature/owner-directive-pass-down-1157'
    $script:NowText = '2026-11-10T12:00:00Z'
    $script:ItemCheckpointPath = "$script:Item/artifacts/orchestration/orchestrator-state.json"
    $script:ItemLedgerPath = "$script:Item/artifacts/orchestration/owner-directives.jsonl"
    $script:EpicCheckpointPath = "$script:Epic/artifacts/orchestration/epic-orchestrator-state.json"
    $script:EpicLedgerPath = "$script:Epic/artifacts/orchestration/owner-directives.jsonl"
    $script:Acknowledgement = @('atomic-executor', 'atomic-planner', 'feature-review', 'task-researcher', 'prd-feature', 'python-typed-engineer', 'powershell-typed-engineer')
    $script:RelayTargets = $script:Acknowledgement + @('csharp-typed-engineer', 'typescript-engineer', 'orchestrator')

    function Get-PassDownTestEntry {
        param([string] $Id = 'OD-1', [string] $Class = 'scheduling', [long] $Issue = 1157, [string] $Branch = 'feature/owner-directive-pass-down-1157', [string] $Step = 'any', [string] $Text = 'Run the features in parallel where the merge cost is lower.')
        $digest = [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.Text.UTF8Encoding]::new($false).GetBytes($Text))).ToLowerInvariant()
        return ([ordered]@{
                id = $Id; text = $Text; text_sha256 = $digest; class = $Class; recorded_at = '2026-11-01T00:00:00Z'; expires_at = '2026-11-11T00:00:00Z'
                scope = [ordered]@{ issue = $Issue; branch = $Branch; step = $Step }; issued_by_session = 'coordinator-session-1157'
            } | ConvertTo-Json -Compress -Depth 4)
    }

    function Get-PassDownTestCheckpoint {
        param([string] $Step = 'S5', [string[]] $Directive = @(), [switch] $EpicLinked)
        $text = '{"issue-num":"1157","next_step":"' + $Step + '"'
        if ($EpicLinked) { $text += ',"epic_context":{"integration_branch":"epic/pass-down-integration"}' }
        if ($Directive.Count -gt 0) { $text += ',"owner_directives":[' + ($Directive -join ',') + ']' }
        return $text + '}'
    }

    function Get-PassDownTestBlock {
        param([string[]] $Entry, [long] $Issue = 1157)
        $source = [pscustomobject]@{ Name = 'item-ledger'; Text = ($Entry -join "`n"); IsEpicParent = $false }
        $selected = (Select-OwnerDirectivePassDown -Source @($source) -ItemIssue $Issue -ItemBranch $null -ItemStep $null -Now ([datetime]::new(2026, 11, 10, 12, 0, 0, [System.DateTimeKind]::Utc))).Selected
        return (Format-OwnerDirectiveBlock -Selected $selected)
    }

    function Invoke-PassDownTest {
        param([hashtable] $Payload, [hashtable] $Files = @{}, [string[]] $Existing = @(), [scriptblock] $ReadText, [scriptblock] $Clock)
        $map = @{}
        foreach ($key in $Files.Keys) { $map[$key] = $Files[$key] }
        $existingSet = @($Existing)
        $porcelain = @(
            'worktree /synthetic-worktrees/main', 'branch refs/heads/main', ''
            'worktree /synthetic-worktrees/item-1157', 'branch refs/heads/feature/owner-directive-pass-down-1157', ''
            'worktree /synthetic-worktrees/epic', 'branch refs/heads/epic/pass-down-integration', ''
        ) -join "`n"
        if ($null -eq $ReadText) { $ReadText = { param($Path) $map[([string] $Path).Replace('\', '/')] }.GetNewClosure() }
        if ($null -eq $Clock) { $Clock = { [datetime]::new(2026, 11, 10, 12, 0, 0, [System.DateTimeKind]::Utc) } }
        $arguments = @{
            HookInputRaw        = ($Payload | ConvertTo-Json -Compress -Depth 6)
            SessionRoot         = '/synthetic-worktrees/main'
            ReadText            = $ReadText
            ReadTranscriptHead  = { param($Path) $null }
            WorktreeListInvoker = { param($SessionRoot) $porcelain }.GetNewClosure()
            EpicResolver        = { param($IntegrationBranch, $SessionRoot) [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = '/synthetic-worktrees/epic' } }
            ParallelResolver    = { param($ParallelSlug, $SessionRoot) [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null } }
            TestFile            = { param($Path) $normalized = ([string] $Path).Replace('\', '/'); $map.ContainsKey($normalized) -or $existingSet -contains $normalized }.GetNewClosure()
            Clock               = $Clock
        }
        return (Get-OwnerDirectivePassDownDecision @arguments)
    }

    function Get-PassDownDelegation {
        param([string] $SubagentType, [string] $Prompt, [string] $Cwd = '/synthetic-worktrees/main', [string] $AgentType)
        $payload = @{ tool_name = 'Agent'; cwd = $Cwd; tool_input = @{ subagent_type = $SubagentType; prompt = $Prompt } }
        if ($AgentType) { $payload['agent_type'] = $AgentType; $payload['agent_id'] = 'parent1' }
        return $payload
    }

    function Get-PassDownWorkerCall {
        param([string] $AgentType = 'atomic-executor', [string] $AgentId = 'a1', [string] $ToolName = 'Bash', [hashtable] $ToolInput = @{ command = 'git status' })
        return @{ tool_name = $ToolName; cwd = '/synthetic-worktrees/item-1157'; agent_type = $AgentType; agent_id = $AgentId; tool_input = $ToolInput }
    }

    function Get-PassDownReason {
        param($Decision)
        return [string] $Decision.hookSpecificOutput.permissionDecisionReason
    }

    function Get-PassDownDecisionPath {
        param([string] $AgentId = 'a1', [string] $Id = 'OD-1')
        return "$script:Item/artifacts/orchestration/owner-directive-decisions/$AgentId/$Id.md"
    }

    $script:PromptHead = "Execute the plan.`nbranch: feature/owner-directive-pass-down-1157`nCanonical issue number for this feature is 1157.`n"
    $script:Entry = Get-PassDownTestEntry
    $script:Refused = Get-PassDownTestEntry -Id 'OD-2' -Class 'gate_bypass' -Text 'Merge without waiting for the required checks.'
}

Describe 'relay mode (AC-10, AC-13)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'denies a delegation to <Target> when the entry is missing from the item checkpoint' -ForEach @(
        @{ Target = 'atomic-executor' }, @{ Target = 'atomic-planner' }, @{ Target = 'feature-review' }, @{ Target = 'task-researcher' }, @{ Target = 'prd-feature' }
        @{ Target = 'python-typed-engineer' }, @{ Target = 'powershell-typed-engineer' }, @{ Target = 'csharp-typed-engineer' }, @{ Target = 'typescript-engineer' }, @{ Target = 'orchestrator' }
    ) {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint); $script:ItemLedgerPath = $script:Entry }
        $prompt = $script:PromptHead + (Get-PassDownTestBlock -Entry @($script:Entry))
        $decision = Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType $Target -Prompt $prompt) -Files $files
        $reason = Get-PassDownReason $decision
        $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
        $reason | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_RELAY_REQUIRED: *'
        $reason.Contains((Get-PassDownTestBlock -Entry @($script:Entry))) | Should -BeTrue
        $reason.Contains('JSON entries to append to owner_directives:') | Should -BeTrue
        $reason.Contains('"id":"OD-1"') | Should -BeTrue
    }

    It 'denies a delegation to <Target> when the checkpoint holds the entry but the prompt lacks its rendered lines' -ForEach @(
        @{ Target = 'atomic-executor' }, @{ Target = 'atomic-planner' }, @{ Target = 'feature-review' }, @{ Target = 'task-researcher' }, @{ Target = 'prd-feature' }
        @{ Target = 'python-typed-engineer' }, @{ Target = 'powershell-typed-engineer' }, @{ Target = 'csharp-typed-engineer' }, @{ Target = 'typescript-engineer' }, @{ Target = 'orchestrator' }
    ) {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Directive @($script:Entry)) }
        $decision = Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType $Target -Prompt $script:PromptHead) -Files $files
        $reason = Get-PassDownReason $decision
        $reason | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_RELAY_REQUIRED: *'
        $reason.Contains((Get-PassDownTestBlock -Entry @($script:Entry))) | Should -BeTrue
        $reason.Contains('JSON entries to append') | Should -BeFalse
    }

    It 'allows a delegation to <Target> when the checkpoint holds the entry and the prompt holds its rendered lines' -ForEach @(
        @{ Target = 'atomic-executor' }, @{ Target = 'csharp-typed-engineer' }, @{ Target = 'orchestrator' }
    ) {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Directive @($script:Entry)) }
        $prompt = $script:PromptHead + (Get-PassDownTestBlock -Entry @($script:Entry))
        Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType $Target -Prompt $prompt) -Files $files | Should -BeNullOrEmpty
    }

    It 'produces no output for a delegation to pr-author' {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint); $script:ItemLedgerPath = $script:Entry }
        Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType 'pr-author' -Prompt $script:PromptHead) -Files $files | Should -BeNullOrEmpty
    }
}

Describe 'relay mode at every delegation phase (AC-11)' {
    It 'next_step <Step> denies a missing entry and allows a recorded and pasted one' -ForEach @(
        @{ Step = 'S2' }, @{ Step = 'S3' }, @{ Step = 'S4' }, @{ Step = 'S5' }, @{ Step = 'R1' }, @{ Step = 'S7' }, @{ Step = 'R4' }
    ) {
        $entry = Get-PassDownTestEntry -Step $Step
        $missing = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Step $Step); $script:ItemLedgerPath = $entry }
        $denied = Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType 'atomic-executor' -Prompt $script:PromptHead) -Files $missing
        (Get-PassDownReason $denied) | Should -BeLike '*OWNER_DIRECTIVE_RELAY_REQUIRED:*'
        $held = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Step $Step -Directive @($entry)); $script:ItemLedgerPath = $entry }
        $prompt = $script:PromptHead + (Get-PassDownTestBlock -Entry @($entry))
        Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType 'atomic-executor' -Prompt $prompt) -Files $held | Should -BeNullOrEmpty
    }
}

Describe 'coordinator child orchestrator launch (AC-12)' {
    BeforeAll {
        $script:EpicFiles = @{ $script:EpicCheckpointPath = ('{"route_id":"epic","integration_branch":"epic/pass-down-integration","epic_issue_num":900,"owner_directives":[' + (Get-PassDownTestEntry -Step 'S5') + ']}') }
        $script:ChildPrompt = "Epic mode: true. integration_branch: epic/pass-down-integration.`nCanonical issue number for this feature is 1157.`n"
    }

    It 'denies the launch when the rendered lines are absent from the prompt, without a child checkpoint' {
        $decision = Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType 'orchestrator' -Prompt $script:ChildPrompt -Cwd $script:Epic -AgentType 'epic-orchestrator') -Files $script:EpicFiles
        $reason = Get-PassDownReason $decision
        $reason | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_RELAY_REQUIRED: *'
        $reason.Contains('"Run the features in parallel where the merge cost is lower."') | Should -BeTrue
    }

    It 'allows the launch when the prompt holds the rendered lines' {
        $prompt = $script:ChildPrompt + (Get-PassDownTestBlock -Entry @(Get-PassDownTestEntry -Step 'S5'))
        Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType 'orchestrator' -Prompt $prompt -Cwd $script:Epic -AgentType 'epic-orchestrator') -Files $script:EpicFiles | Should -BeNullOrEmpty
    }

    It 'applies no check to a launch for an issue the coordinator has no directive for' {
        $prompt = "Canonical issue number for this feature is 1158.`n"
        Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType 'orchestrator' -Prompt $prompt -Cwd $script:Epic -AgentType 'epic-orchestrator') -Files $script:EpicFiles | Should -BeNullOrEmpty
    }
}

Describe 'acknowledgement mode (AC-14, AC-15, AC-20, AC-24)' {
    It 'holds <AgentType> with the block, the refused note, each decision path, the grammar, and the clock' -ForEach @(
        @{ AgentType = 'atomic-executor' }, @{ AgentType = 'atomic-planner' }, @{ AgentType = 'feature-review' }, @{ AgentType = 'task-researcher' }
        @{ AgentType = 'prd-feature' }, @{ AgentType = 'python-typed-engineer' }, @{ AgentType = 'powershell-typed-engineer' }
    ) {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Directive @($script:Entry, $script:Refused)) }
        $reason = Get-PassDownReason (Invoke-PassDownTest -Payload (Get-PassDownWorkerCall -AgentType $AgentType) -Files $files)
        $reason | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_DECISION_REQUIRED: *'
        $reason.Contains((Get-PassDownTestBlock -Entry @($script:Entry, $script:Refused))) | Should -BeTrue
        $reason.Contains('Always refused: OD-2 has class gate_bypass') | Should -BeTrue
        $reason.Contains('Always refused: OD-1') | Should -BeFalse
        $reason.Contains((Get-PassDownDecisionPath -Id 'OD-1')) | Should -BeTrue
        $reason.Contains((Get-PassDownDecisionPath -Id 'OD-2')) | Should -BeTrue
        $reason.Contains('OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at|-> | <reason') | Should -BeTrue
        $reason.Contains("Hook clock (use as decided_at): $script:NowText") | Should -BeTrue
    }

    It 'releases the agent once every selected entry has a decision file, and holds it again for a later ledger entry only' {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Directive @($script:Entry, $script:Refused)) }
        $existing = @((Get-PassDownDecisionPath -Id 'OD-1'), (Get-PassDownDecisionPath -Id 'OD-2'))
        Invoke-PassDownTest -Payload (Get-PassDownWorkerCall) -Files $files -Existing $existing | Should -BeNullOrEmpty
        $files[$script:ItemLedgerPath] = Get-PassDownTestEntry -Id 'OD-3' -Text 'Narrow the scope to the hook only.' -Class 'scope_narrowing'
        $reason = Get-PassDownReason (Invoke-PassDownTest -Payload (Get-PassDownWorkerCall) -Files $files -Existing $existing)
        $reason.Contains((Get-PassDownDecisionPath -Id 'OD-3')) | Should -BeTrue
        $reason.Contains('Decision file for OD-1') | Should -BeFalse
        $reason.Contains('Decision file for OD-2') | Should -BeFalse
    }

    It 'holds the worker for a parent-ledger entry with an unchanged item checkpoint' {
        $files = @{
            $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -EpicLinked)
            $script:EpicCheckpointPath = '{"route_id":"epic","integration_branch":"epic/pass-down-integration","epic_issue_num":900}'
            $script:EpicLedgerPath     = $script:Entry
        }
        $reason = Get-PassDownReason (Invoke-PassDownTest -Payload (Get-PassDownWorkerCall) -Files $files)
        $reason | Should -BeLike '*OWNER_DIRECTIVE_DECISION_REQUIRED:*'
        $reason.Contains((Get-PassDownDecisionPath -Id 'OD-1')) | Should -BeTrue
    }

    It 'holds the worker for an epic fan-out entry in the parent checkpoint' {
        $files = @{
            $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -EpicLinked)
            $script:EpicCheckpointPath = '{"route_id":"epic","integration_branch":"epic/pass-down-integration","epic_issue_num":900,"owner_directives":[' + (Get-PassDownTestEntry -Issue 900 -Branch 'epic/pass-down-integration') + ']}'
        }
        (Get-PassDownReason (Invoke-PassDownTest -Payload (Get-PassDownWorkerCall) -Files $files)) | Should -BeLike '*OWNER_DIRECTIVE_DECISION_REQUIRED:*'
    }

    It 'is inert for the agent id <AgentId>' -ForEach @(@{ AgentId = '-leading' }, @{ AgentId = 'a/b' }, @{ AgentId = '' }) {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Directive @($script:Entry)) }
        Invoke-PassDownTest -Payload (Get-PassDownWorkerCall -AgentId $AgentId) -Files $files | Should -BeNullOrEmpty
    }

    It 'never holds <Caller> in acknowledgement mode' -ForEach @(
        @{ Caller = 'the main session'; AgentType = '' }, @{ Caller = 'orchestrator'; AgentType = 'orchestrator' }
        @{ Caller = 'csharp-typed-engineer'; AgentType = 'csharp-typed-engineer' }, @{ Caller = 'typescript-engineer'; AgentType = 'typescript-engineer' }
    ) {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Directive @($script:Entry)) }
        $payload = Get-PassDownWorkerCall -AgentType $AgentType
        if (-not $AgentType) { $payload.Remove('agent_type'); $payload.Remove('agent_id') }
        Invoke-PassDownTest -Payload $payload -Files $files | Should -BeNullOrEmpty
    }
}

Describe 'decision files (AC-18, AC-19)' {
    BeforeAll {
        $script:DecisionFiles = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -Directive @($script:Entry)) }
        $script:ValidLine = "OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | $script:NowText | The items run in parallel as the owner asked.`n"
    }

    It 'allows a Write of a pending decision file holding one valid line' {
        $call = Get-PassDownWorkerCall -ToolName 'Write' -ToolInput @{ file_path = (Get-PassDownDecisionPath); content = $script:ValidLine }
        Invoke-PassDownTest -Payload $call -Files $script:DecisionFiles | Should -BeNullOrEmpty
    }

    It 'denies a Write of a pending decision file holding <Case>' -ForEach @(
        @{ Case = 'an unparseable line'; Content = 'honored' }
        @{ Case = 'a short reason'; Content = 'OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | too short' }
        @{ Case = 'two lines'; Content = "OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | The items run in parallel as asked.`nsecond line" }
        @{ Case = 'a mismatched class'; Content = 'OWNER-DIRECTIVE-DECISION: OD-1 | merge_timing | honored | - | The items run in parallel as asked.' }
    ) {
        $call = Get-PassDownWorkerCall -ToolName 'Write' -ToolInput @{ file_path = (Get-PassDownDecisionPath); content = $Content }
        (Get-PassDownReason (Invoke-PassDownTest -Payload $call -Files $script:DecisionFiles)) | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_DECISION_INVALID: *'
    }

    It 'denies a Write to an existing decision file' {
        $call = Get-PassDownWorkerCall -ToolName 'Write' -ToolInput @{ file_path = (Get-PassDownDecisionPath); content = $script:ValidLine }
        $reason = Get-PassDownReason (Invoke-PassDownTest -Payload $call -Files $script:DecisionFiles -Existing @(Get-PassDownDecisionPath))
        $reason | Should -BeLike '*OWNER_DIRECTIVE_DECISION_INVALID:*write-once*'
    }

    It 'denies an Edit of a decision file' {
        $call = Get-PassDownWorkerCall -ToolName 'Edit' -ToolInput @{ file_path = (Get-PassDownDecisionPath); old_string = 'a'; new_string = 'b' }
        (Get-PassDownReason (Invoke-PassDownTest -Payload $call -Files $script:DecisionFiles)) | Should -BeLike '*OWNER_DIRECTIVE_DECISION_INVALID:*Edit*'
    }

    It 'denies a Write of a decision file under another agent id' {
        $call = Get-PassDownWorkerCall -ToolName 'Write' -ToolInput @{ file_path = (Get-PassDownDecisionPath -AgentId 'other'); content = $script:ValidLine }
        (Get-PassDownReason (Invoke-PassDownTest -Payload $call -Files $script:DecisionFiles)) | Should -BeLike "*OWNER_DIRECTIVE_DECISION_INVALID:*agent 'other'*"
    }

    It 'denies a Write of a decision file that names no pending directive' {
        $call = Get-PassDownWorkerCall -ToolName 'Write' -ToolInput @{ file_path = (Get-PassDownDecisionPath -Id 'OD-9'); content = $script:ValidLine }
        (Get-PassDownReason (Invoke-PassDownTest -Payload $call -Files $script:DecisionFiles)) | Should -BeLike '*OD-9 names no pending owner directive.'
    }
}

Describe 'ledger guard (AC-27)' {
    BeforeAll {
        $script:LedgerFiles = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint); $script:ItemLedgerPath = $script:Entry }
        function Get-PassDownLedgerCall {
            param([string] $ToolName = 'Write', [string] $Content, [string] $AgentType)
            $toolInput = if ($ToolName -eq 'NotebookEdit') { @{ notebook_path = $script:ItemLedgerPath } } else { @{ file_path = $script:ItemLedgerPath; content = $Content } }
            $payload = @{ tool_name = $ToolName; cwd = $script:Session; tool_input = $toolInput }
            if ($AgentType) { $payload['agent_type'] = $AgentType; $payload['agent_id'] = 'a1' }
            return $payload
        }
    }

    It 'denies a ledger write by a subagent, with or without directive sources' {
        $call = Get-PassDownLedgerCall -Content ($script:Entry + "`n") -AgentType 'orchestrator'
        (Get-PassDownReason (Invoke-PassDownTest -Payload $call -Files $script:LedgerFiles)) | Should -BeLike 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_LEDGER_WRITE_DENIED: *main session*'
        (Get-PassDownReason (Invoke-PassDownTest -Payload $call -Files @{})) | Should -BeLike '*OWNER_DIRECTIVE_LEDGER_WRITE_DENIED:*'
    }

    It 'denies a main-session <ToolName> of a ledger' -ForEach @(@{ ToolName = 'Edit' }, @{ ToolName = 'MultiEdit' }, @{ ToolName = 'NotebookEdit' }) {
        (Get-PassDownReason (Invoke-PassDownTest -Payload (Get-PassDownLedgerCall -ToolName $ToolName -Content 'x') -Files $script:LedgerFiles)) | Should -BeLike "*OWNER_DIRECTIVE_LEDGER_WRITE_DENIED:*$ToolName is not admitted*"
    }

    It 'denies a main-session Write that <Case>' -ForEach @(
        @{ Case = 'changes an existing line'; Content = { (Get-PassDownTestEntry -Text 'Changed.') + "`n" } }
        @{ Case = 'removes an existing line'; Content = { '' } }
        @{ Case = 'appends an invalid line'; Content = { $script:Entry + "`n" + '{"id":"OD-2"}' + "`n" } }
    ) {
        (Get-PassDownReason (Invoke-PassDownTest -Payload (Get-PassDownLedgerCall -Content (& $Content)) -Files $script:LedgerFiles)) | Should -BeLike '*OWNER_DIRECTIVE_LEDGER_WRITE_DENIED:*'
    }

    It 'allows a main-session Write that appends valid lines' {
        $content = $script:Entry + "`n" + (Get-PassDownTestEntry -Id 'OD-2' -Text 'Second instruction.') + "`n"
        Invoke-PassDownTest -Payload (Get-PassDownLedgerCall -Content $content) -Files $script:LedgerFiles | Should -BeNullOrEmpty
    }
}

Describe 'inert default and fast path (AC-25 hook part, AC-33 worker part)' {
    BeforeAll {
        $script:NoSource = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint -EpicLinked); $script:EpicCheckpointPath = '{"route_id":"epic","integration_branch":"epic/pass-down-integration"}' }
    }

    It 'emits nothing without a directive source for <Case>' -ForEach @(
        @{ Case = 'a relay delegation'; Payload = { Get-PassDownDelegation -SubagentType 'atomic-executor' -Prompt $script:PromptHead } }
        @{ Case = 'an orchestrator delegation'; Payload = { Get-PassDownDelegation -SubagentType 'orchestrator' -Prompt $script:PromptHead } }
        @{ Case = 'an acknowledgement-set Bash call'; Payload = { Get-PassDownWorkerCall } }
        @{ Case = 'an acknowledgement-set Write'; Payload = { Get-PassDownWorkerCall -ToolName 'Write' -ToolInput @{ file_path = "$script:Item/src/a.ps1"; content = 'x' } } }
        @{ Case = 'an acknowledgement-set Edit'; Payload = { Get-PassDownWorkerCall -ToolName 'Edit' -ToolInput @{ file_path = "$script:Item/src/a.ps1"; old_string = 'a'; new_string = 'b' } } }
        @{ Case = 'an acknowledgement-set mcp__ call'; Payload = { Get-PassDownWorkerCall -ToolName 'mcp__drm-copilot__run_poshqc_format' -ToolInput @{ workspace_root = $script:Item } } }
        @{ Case = 'a decision-file write'; Payload = { Get-PassDownWorkerCall -ToolName 'Write' -ToolInput @{ file_path = (Get-PassDownDecisionPath); content = 'x' } } }
        @{ Case = 'a main-session valid first ledger append'; Payload = { @{ tool_name = 'Write'; cwd = $script:Session; tool_input = @{ file_path = $script:ItemLedgerPath; content = $script:Entry } } } }
    ) {
        Invoke-PassDownTest -Payload (& $Payload) -Files $script:NoSource | Should -BeNullOrEmpty
    }

    It 'returns before any file, worktree, or clock read for a call outside the three cases' {
        $throwing = { param($Path) throw 'no read expected' }
        $payload = @{ tool_name = 'Bash'; cwd = $script:Session; tool_input = @{ command = 'git status' } }
        Invoke-PassDownTest -Payload $payload -ReadText $throwing -Clock { throw 'no clock expected' } | Should -BeNullOrEmpty
        Invoke-PassDownTest -Payload (Get-PassDownWorkerCall -AgentType 'pr-author') -ReadText $throwing -Clock { throw 'no clock expected' } | Should -BeNullOrEmpty
    }

    It 'emits nothing for an item ledger whose only line fails a B rule' {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint); $script:ItemLedgerPath = '{"id":"OD-1","text":"x"}' }
        Invoke-PassDownTest -Payload (Get-PassDownWorkerCall) -Files $files | Should -BeNullOrEmpty
        Invoke-PassDownTest -Payload (Get-PassDownDelegation -SubagentType 'atomic-executor' -Prompt $script:PromptHead) -Files $files | Should -BeNullOrEmpty
    }

    It 'holds the worker for the valid entry only when the ledger also holds an invalid line' {
        $files = @{ $script:ItemCheckpointPath = (Get-PassDownTestCheckpoint); $script:ItemLedgerPath = ('{"id":"OD-1","text":"x"}' + "`n" + (Get-PassDownTestEntry -Id 'OD-2')) }
        $reason = Get-PassDownReason (Invoke-PassDownTest -Payload (Get-PassDownWorkerCall) -Files $files)
        $reason.Contains((Get-PassDownDecisionPath -Id 'OD-2')) | Should -BeTrue
        $reason.Contains('Decision file for OD-1') | Should -BeFalse
    }

    It 'returns $null for a blank or unparseable payload' {
        Get-OwnerDirectivePassDownDecision -HookInputRaw '' | Should -BeNullOrEmpty
        Get-OwnerDirectivePassDownDecision -HookInputRaw '{not json' | Should -BeNullOrEmpty
    }
}
