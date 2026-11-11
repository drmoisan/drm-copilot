#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the Codex planner adapter and the planner branch of the Codex epic
    worktree-removal gate (issue #1161).

.DESCRIPTION
    Adapter rows call Get-CodexPlannerWorktreeRemovalDecision; gate rows call
    Invoke-CodexWorktreeRemovalDecision with -PlannerCheckpointRaw and an in-memory
    -TargetCheckpointReader. Git is reached only through the mocked seam
    Invoke-CodexPlannerWorktreeGitExe, so no process starts, and no row reads or writes a file.
    Roots are synthetic forward-slash paths without a drive letter; expected git arguments are
    derived through the gate's own path normalizer, so the rows hold on every host.
#>

Describe 'Codex planner worktree branch (issue #1161)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:GateFile = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-worktree-removal-gate.ps1'
        $script:AdapterFile = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1'
        . $script:GateFile
        . $script:AdapterFile
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest { $null }
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicWorktreeGateCheckpointContent { $null } }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicWorktreeGateParallelCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:Session = '/synthetic-worktrees/session'
        $script:Target = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha'
        $script:NormTarget = Get-NormalizedCodexWorktreePath -Path $script:Target -WorkingDirectory $script:Session
        $script:Planner = '{"integration_branch":"epic/alpha","planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"prepared","feature_folder":"f"}]}'
        $script:DefaultListing = @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'branch refs/heads/feature/alpha-1', '')

        function Set-CodexPlannerScenario {
            # Install the git results of one row; each key overrides a default.
            param([string[]] $Listing = $script:DefaultListing, [hashtable] $Git = @{})
            $script:GitResult = @{
                worktree = @{ ExitCode = 0; Output = $Listing }; status = @{ ExitCode = 0; Output = @() }; 'rev-parse' = @{ ExitCode = 0; Output = @('abc1234') }
                integration = @{ ExitCode = 0; Output = @() }; branch = @{ ExitCode = 1; Output = @() }
            }
            foreach ($key in $Git.Keys) { $script:GitResult[$key] = $Git[$key] }
            $script:GitCalls = [System.Collections.Generic.List[string]]::new()
        }

        function Get-CodexPlannerPayload {
            # The Codex PreToolUse stdin payload for a removal command run from the session root.
            param([Parameter(Mandatory)][string] $Command)
            return ([ordered]@{ hook_event_name = 'PreToolUse'; tool_name = 'Bash'; tool_input = @{ command = $Command }; cwd = $script:Session } | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-CodexPlannerAdapter {
            # Run the adapter for the default target with the given planner text and optional overrides.
            param([string] $Text = $script:Planner, $Epic = $null, [scriptblock] $Reader = $null, [string] $Target = $script:Target, [string] $WorkingDirectory = $script:Session, [string] $RepositoryRoot = '/synthetic-worktrees/repository')
            return Get-CodexPlannerWorktreeRemovalDecision -Target $Target -WorkingDirectory $WorkingDirectory -EpicCheckpoint $Epic -PlannerCheckpointText $Text -TargetCheckpointReader $Reader -RepositoryRoot $RepositoryRoot
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'adapter and gate rows' {
        BeforeEach {
            Set-CodexPlannerScenario
            Mock Invoke-CodexPlannerWorktreeGitExe {
                param([string[]] $GitArgs)
                $script:GitCalls.Add($GitArgs -join ' ')
                $key = $GitArgs[2]
                if ($key -eq 'merge-base') { $key = if ($GitArgs[-1] -like 'refs/remotes/origin/epic/*') { 'integration' } else { 'branch' } }
                [pscustomobject]$script:GitResult[$key]
            }
        }

        It 'adapter: allows and runs exactly the listing and target checks in order' {
            Set-CodexPlannerScenario -Git @{ integration = @{ ExitCode = 1; Output = @() }; branch = @{ ExitCode = 0; Output = @() } }
            (Invoke-CodexPlannerAdapter).Outcome | Should -Be 'Allow'
            $expected = @(
                '-C /synthetic-worktrees/session worktree list --porcelain'
                "-C $($script:NormTarget) status --porcelain=v1 --untracked-files=all"
                "-C $($script:NormTarget) rev-parse --verify HEAD"
                "-C $($script:NormTarget) merge-base --is-ancestor abc1234 refs/remotes/origin/epic/alpha"
                "-C $($script:NormTarget) merge-base --is-ancestor abc1234 refs/remotes/origin/feature/alpha-1"
            )
            $script:GitCalls.ToArray() | Should -Be $expected
            @($script:GitCalls | Where-Object { $_ -match '\b(fetch|pull|ls-remote)\b' }).Count | Should -Be 0
        }
        It 'adapter: returns NoRecord before any seam or reader call for <Name>' -ForEach @(
            @{ Name = 'empty text'; Text = '' }
            @{ Name = 'text without a candidate'; Text = '{"planner_worktrees":[]}' }
        ) {
            $decision = Invoke-CodexPlannerAdapter -Text $Text -Reader { throw 'reader must not run' }
            $decision.Outcome | Should -Be 'NoRecord'
            $decision.Suffix | Should -BeExactly ''
            $script:GitCalls.Count | Should -Be 0
        }
        It 'adapter: lists once and returns NoRecord when the candidates name another branch' {
            $decision = Invoke-CodexPlannerAdapter -Text '{"planner_worktrees":[{"branch":"feature/beta-2","purpose":"preparation","preparation_status":"prepared"}]}' -Reader { throw 'reader must not run' }
            $decision.Outcome | Should -Be 'NoRecord'
            $script:GitCalls.ToArray() | Should -Be @('-C /synthetic-worktrees/session worktree list --porcelain')
        }
        It 'adapter: never matches a detached target stanza (AC-21)' {
            Set-CodexPlannerScenario -Listing @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'HEAD abc1234', 'detached', '')
            (Invoke-CodexPlannerAdapter).Outcome | Should -Be 'NoRecord'
        }
        It 'adapter: does not name the target when the record path does not match it (AC-21)' {
            (Invoke-CodexPlannerAdapter -Text '{"planner_worktrees":[{"branch":"feature/alpha-1","path":".claude/worktrees/agent-beta","purpose":"preparation","preparation_status":"prepared"}]}').Outcome | Should -Be 'NoRecord'
        }
        It 'adapter: allows a record whose repository-relative path names the target' {
            (Invoke-CodexPlannerAdapter -Text '{"integration_branch":"epic/alpha","planner_worktrees":[{"branch":"feature/alpha-1","path":".claude/worktrees/agent-alpha","purpose":"preparation","preparation_status":"prepared"}]}').Outcome | Should -Be 'Allow'
        }
        It 'adapter: refuses GIT_FAILED when the listing fails while a candidate exists' {
            Set-CodexPlannerScenario -Git @{ worktree = @{ ExitCode = 128; Output = @() } }
            (Invoke-CodexPlannerAdapter).Code | Should -BeExactly 'GIT_FAILED'
            $script:GitCalls.Count | Should -Be 1
        }
        It 'adapter: refuses U1 when the target <Name>' -ForEach @(
            @{ Name = 'equals the working directory'; WorkingDirectory = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha'; RepositoryRoot = '/synthetic-worktrees/repository' }
            @{ Name = 'encloses the working directory'; WorkingDirectory = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha/src'; RepositoryRoot = '/synthetic-worktrees/repository' }
            @{ Name = 'is the repository root that holds the planner checkpoint'; WorkingDirectory = '/synthetic-worktrees/session'; RepositoryRoot = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha' }
        ) {
            (Invoke-CodexPlannerAdapter -WorkingDirectory $WorkingDirectory -RepositoryRoot $RepositoryRoot).Detail | Should -BeLike 'U1 *'
        }
        It 'adapter: refuses U2 when the target is the main checkout' {
            Set-CodexPlannerScenario -Listing @('worktree /synthetic-worktrees/main', 'branch refs/heads/feature/alpha-1', '')
            (Invoke-CodexPlannerAdapter -Target '/synthetic-worktrees/main').Detail | Should -BeLike 'U2 *'
        }
        It 'adapter: refuses U3 for a locked target without reading its checkpoint' {
            Set-CodexPlannerScenario -Listing @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'branch refs/heads/feature/alpha-1', 'locked claude agent agent-alpha (pid 4242)', '')
            (Invoke-CodexPlannerAdapter -Reader { throw 'reader must not run' }).Detail | Should -BeLike 'U3 *'
        }
        It 'adapter: reads the target orchestrator checkpoint path and refuses U4 when <Name>' -ForEach @(
            @{ Name = 'it is unparseable'; Text = '{broken' }
            @{ Name = 'it is not at S5_atomic_execution'; Text = '{"next_step":"S8_ci_gate"}' }
        ) {
            $body = $Text
            $reader = { $body }.GetNewClosure()
            (Invoke-CodexPlannerAdapter -Reader $reader).Detail | Should -BeLike 'U4 *'
        }
        It 'adapter: passes the target checkpoint path to the reader and treats an absent file as not in use' {
            $seen = [System.Collections.Generic.List[string]]::new()
            $reader = { param($Path) $seen.Add($Path); $null }.GetNewClosure()
            (Invoke-CodexPlannerAdapter -Reader $reader).Outcome | Should -Be 'Allow'
            $seen.ToArray() | Should -Be @("$($script:NormTarget)/artifacts/orchestration/orchestrator-state.json")
        }
        It 'adapter: refuses U5 when the passed epic checkpoint records <Name>' -ForEach @(
            @{ Name = 'the target worktree_path'; Epic = '{"route_id":"epic","features":[{"worktree_path":"/synthetic-worktrees/session/.claude/worktrees/agent-alpha"}]}' }
            @{ Name = 'the record branch_name'; Epic = '{"route_id":"epic","features":[{"branch_name":"feature/alpha-1"}]}' }
        ) {
            (Invoke-CodexPlannerAdapter -Epic ($Epic | ConvertFrom-Json)).Detail | Should -BeLike 'U5 *'
        }
        It 'gate: allows a <Status> record (AC-7)' -ForEach @(@{ Status = 'prepared' }, @{ Status = 'fanned_in' }) {
            $planner = $script:Planner.Replace('"prepared"', """$Status""")
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (Get-CodexPlannerPayload -Command "git worktree remove $($script:Target)") -EpicCheckpointRaw '' -PlannerCheckpointRaw $planner -TargetCheckpointReader { $null }
            $decision | Should -BeNullOrEmpty
        }
        It 'gate: denies a dirty recorded target even with --force (AC-9)' {
            Set-CodexPlannerScenario -Git @{ status = @{ ExitCode = 0; Output = @(' M file.txt') } }
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (Get-CodexPlannerPayload -Command "git worktree remove --force $($script:Target)") -EpicCheckpointRaw '' -PlannerCheckpointRaw $script:Planner -TargetCheckpointReader { $null }
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly ("EPIC_WORKTREE_REMOVAL_BLOCKED: '$($script:Target)' requires a matching epic feature with merge_status merged or worktree_removed. Planner worktree: PLANNER_WORKTREE_DIRTY: branch 'feature/alpha-1' has uncommitted or untracked changes.")
        }
        It 'gate: keeps the unrecorded deny text byte-identical (AC-10)' {
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (Get-CodexPlannerPayload -Command 'git worktree remove /synthetic-worktrees/unrecorded') -EpicCheckpointRaw '' -PlannerCheckpointRaw $script:Planner -TargetCheckpointReader { $null }
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly "EPIC_WORKTREE_REMOVAL_BLOCKED: '/synthetic-worktrees/unrecorded' requires a matching epic feature with merge_status merged or worktree_removed."
        }
        It 'gate: refuses <Code> when <Name>' -ForEach @(
            @{ Name = 'the working directory is the target (U1)'; Code = 'IN_USE'; Detail = 'U1 *'; Cwd = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha'; Listing = $null; Git = @{}; Planner = $null; Epic = ''; Reader = { $null } }
            @{ Name = 'the target is the main checkout (U2)'; Code = 'IN_USE'; Detail = 'U2 *'; Cwd = '/synthetic-worktrees/other'; Listing = @('worktree /synthetic-worktrees/session/.claude/worktrees/agent-alpha', 'branch refs/heads/feature/alpha-1', ''); Git = @{}; Planner = $null; Epic = ''; Reader = { $null } }
            @{ Name = 'the target is locked (U3)'; Code = 'IN_USE'; Detail = 'U3 *'; Cwd = $null; Listing = @('worktree /synthetic-worktrees/session', '', 'worktree /synthetic-worktrees/session/.claude/worktrees/agent-alpha', 'branch refs/heads/feature/alpha-1', 'locked', ''); Git = @{}; Planner = $null; Epic = ''; Reader = { $null } }
            @{ Name = 'the target checkpoint is not at S5 (U4)'; Code = 'IN_USE'; Detail = 'U4 *'; Cwd = $null; Listing = $null; Git = @{}; Planner = $null; Epic = ''; Reader = { '{"next_step":"S6_review"}' } }
            @{ Name = 'the epic checkpoint names the branch (U5)'; Code = 'IN_USE'; Detail = 'U5 *'; Cwd = $null; Listing = $null; Git = @{}; Planner = $null; Epic = '{"route_id":"epic","features":[{"branch_name":"feature/alpha-1","merge_status":"in_progress"}]}'; Reader = { $null } }
            @{ Name = 'the HEAD is not pushed'; Code = 'NOT_PUSHED'; Detail = "branch 'feature/alpha-1'*"; Cwd = $null; Listing = $null; Git = @{ integration = @{ ExitCode = 1; Output = @() } }; Planner = $null; Epic = ''; Reader = { $null } }
            @{ Name = 'the record is not eligible'; Code = 'NOT_ELIGIBLE'; Detail = "branch 'feature/alpha-1'*"; Cwd = $null; Listing = $null; Git = @{}; Planner = '{"planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"abandoned"}]}'; Epic = ''; Reader = { $null } }
            @{ Name = 'the branch is checked out twice'; Code = 'AMBIGUOUS'; Detail = "branch 'feature/alpha-1'*"; Cwd = $null; Listing = @('worktree /synthetic-worktrees/session', '', 'worktree /synthetic-worktrees/session/.claude/worktrees/agent-alpha', 'branch refs/heads/feature/alpha-1', '', 'worktree /synthetic-worktrees/copy', 'branch refs/heads/feature/alpha-1', ''); Git = @{}; Planner = $null; Epic = ''; Reader = { $null } }
            @{ Name = 'rev-parse fails'; Code = 'GIT_FAILED'; Detail = "branch 'feature/alpha-1'*"; Cwd = $null; Listing = $null; Git = @{ 'rev-parse' = @{ ExitCode = 128; Output = @() } }; Planner = $null; Epic = ''; Reader = { $null } }
        ) {
            if ($null -ne $Listing) { Set-CodexPlannerScenario -Listing $Listing -Git $Git } else { Set-CodexPlannerScenario -Git $Git }
            $cwd = if ($Cwd) { $Cwd } else { $script:Session }
            $payload = [ordered]@{ tool_name = 'Bash'; tool_input = @{ command = "git worktree remove $($script:Target)" }; cwd = $cwd } | ConvertTo-Json -Compress -Depth 5
            $plannerText = if ($Planner) { $Planner } else { $script:Planner }
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw $payload -EpicCheckpointRaw $Epic -PlannerCheckpointRaw $plannerText -TargetCheckpointReader $Reader
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike "EPIC_WORKTREE_REMOVAL_BLOCKED: '$($script:Target)' requires a matching epic feature with merge_status merged or worktree_removed. Planner worktree: PLANNER_WORKTREE_$($Code): *."
            $reason.Substring($reason.IndexOf("PLANNER_WORKTREE_$($Code): ") + "PLANNER_WORKTREE_$($Code): ".Length) | Should -BeLike $Detail
            ([regex]::Matches($reason, 'EPIC_WORKTREE_REMOVAL_BLOCKED')).Count | Should -Be 1
        }
        It 'gate: keeps an epic-checkpoint allow ahead of the planner branch' {
            $epic = '{"features":[{"worktree_path":"/synthetic-worktrees/session/.claude/worktrees/agent-alpha","merge_status":"merged"}]}'
            Invoke-CodexWorktreeRemovalDecision -PayloadRaw (Get-CodexPlannerPayload -Command "git worktree remove $($script:Target)") -EpicCheckpointRaw $epic -PlannerCheckpointRaw $script:Planner -TargetCheckpointReader { throw 'reader must not run' } | Should -BeNullOrEmpty
            $script:GitCalls.Count | Should -Be 0
        }
        It 'existing-suite row: without -PlannerCheckpointRaw the deny text is unchanged and no seam or reader runs' {
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (Get-CodexPlannerPayload -Command "git worktree remove $($script:Target)") -EpicCheckpointRaw '' -TargetCheckpointReader { throw 'reader must not run' }
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly "EPIC_WORKTREE_REMOVAL_BLOCKED: '$($script:Target)' requires a matching epic feature with merge_status merged or worktree_removed."
            Should -Invoke Invoke-CodexPlannerWorktreeGitExe -Times 0 -Exactly
        }
    }

    Context 'adapter shape (AST)' {
        BeforeAll {
            $tokens = $null
            $errors = $null
            $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:AdapterFile, [ref] $tokens, [ref] $errors)
            $script:Text = Get-Content -Raw -LiteralPath $script:AdapterFile
            $script:Commands = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
        }
        It 'never calls Get-Location' { @($script:Commands | Where-Object { $_.GetCommandName() -eq 'Get-Location' }).Count | Should -Be 0 }
        It 'holds no direct file read or existence check' { $script:Text | Should -Not -Match 'Get-Content|ReadAllText|ReadAllLines|Test-Path' }
        It 'never writes a file' {
            @($script:Commands | Where-Object { @('Set-Content', 'Add-Content', 'Out-File') -contains $_.GetCommandName() }).Count | Should -Be 0
            $script:Text | Should -Not -Match 'WriteAllText'
        }
        It 'calls git only inside Invoke-CodexPlannerWorktreeGitExe' {
            $calls = @($script:Commands | Where-Object { $_.GetCommandName() -eq 'git' })
            $calls.Count | Should -Be 1
            $parent = $calls[0].Parent
            while ($parent -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) { $parent = $parent.Parent }
            $parent.Name | Should -BeExactly 'Invoke-CodexPlannerWorktreeGitExe'
        }
    }
}
