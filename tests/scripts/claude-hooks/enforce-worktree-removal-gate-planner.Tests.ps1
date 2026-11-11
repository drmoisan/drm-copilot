#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the Claude planner adapter enforce-worktree-removal-gate-planner.ps1 (issue #1161).

.DESCRIPTION
    Every read goes through the two adapter seams, Get-PlannerWorktreeCheckpointText and
    Invoke-PlannerWorktreeGitExe, which each row mocks with in-memory values; the seam-body rows
    mock the module seams below them at script scope instead. No row reads a file, writes a file,
    or starts git, and every root is a synthetic forward-slash path without a drive letter.
#>

Describe 'enforce-worktree-removal-gate-planner.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:AdapterFile = Join-Path $script:RepoRoot '.claude/hooks/enforce-worktree-removal-gate-planner.ps1'
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1') -ErrorAction Stop
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1') -ErrorAction Stop
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        # Loaded after the baseline registration, so the seam under test keeps its real body here.
        . $script:AdapterFile

        $script:Session = '/synthetic-worktrees/session'
        $script:Target = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha'
        $script:PlannerPath = 'artifacts/orchestration/epic-planner-state.json'
        $script:OrchestratorPath = 'artifacts/orchestration/orchestrator-state.json'
        $script:EpicPath = 'artifacts/orchestration/epic-orchestrator-state.json'

        function Set-PlannerScenario {
            # Install the in-memory reads and git results of one row; each argument overrides a default.
            param(
                [object[]] $PlannerRead = @([pscustomobject]@{ Root = '/synthetic-worktrees/session'; Text = '{"integration_branch":"epic/alpha","planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"prepared","feature_folder":"f"}]}' }),
                [object[]] $OrchestratorRead = @(),
                [object[]] $EpicRead = @(),
                [string[]] $Listing = @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', 'worktree /synthetic-worktrees/session/.claude/worktrees/agent-alpha', 'branch refs/heads/feature/alpha-1', '', 'worktree /synthetic-worktrees/session/.claude/worktrees/agent-beta', 'branch refs/heads/feature/beta-2', ''),
                [hashtable] $Git = @{}
            )
            $script:Reads = @{ $script:PlannerPath = $PlannerRead; $script:OrchestratorPath = $OrchestratorRead; $script:EpicPath = $EpicRead }
            $script:GitResult = @{
                worktree = @{ ExitCode = 0; Output = $Listing }; status = @{ ExitCode = 0; Output = @() }; 'rev-parse' = @{ ExitCode = 0; Output = @('abc1234') }
                integration = @{ ExitCode = 0; Output = @() }; branch = @{ ExitCode = 1; Output = @() }
            }
            foreach ($key in $Git.Keys) { $script:GitResult[$key] = $Git[$key] }
            $script:GitCalls = [System.Collections.Generic.List[string]]::new()
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'mocks the planner seam in every Claude suite that names a removal gate' {
        # Each suite that loads a Claude removal gate mocks Get-PlannerWorktreeCheckpointText directly or
        # through the Claude baseline helper, so no gate suite reaches a live root (R1).
        $suites = @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.Tests.ps1' -File | Where-Object {
                $text = Get-Content -Raw -LiteralPath $_.FullName
                $text.Contains('enforce-epic-worktree-removal-gate.ps1') -or $text.Contains('enforce-parallel-worktree-removal-gate.ps1')
            })
        $suites.Count | Should -BeGreaterThan 10
        $missing = @($suites | Where-Object {
                $text = Get-Content -Raw -LiteralPath $_.FullName
                -not ($text.Contains('Mock Get-PlannerWorktreeCheckpointText') -or $text -match "Register-EpicStateBaselineMock[^\r\n]*Get-WorktreeRunCheckpointText[^\r\n]*-Surface 'Claude'")
            } | ForEach-Object { $_.Name })
        $missing | Should -BeNullOrEmpty -Because 'every Claude removal-gate suite must intercept the planner adapter read'
    }

    Context 'decision rows' {
        BeforeEach {
            Set-PlannerScenario
            Mock Get-PlannerWorktreeCheckpointText { @($script:Reads[$RelativePath]) }
            Mock Invoke-PlannerWorktreeGitExe {
                param([string[]] $GitArgs)
                $script:GitCalls.Add($GitArgs -join ' ')
                $key = $GitArgs[2]
                if ($key -eq 'merge-base') { $key = if ($GitArgs[-1] -like 'refs/remotes/origin/epic/*') { 'integration' } else { 'branch' } }
                [pscustomobject]$script:GitResult[$key]
            }
        }

        It 'allows a prepared record whose HEAD is on the integration ref' {
            $decision = Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session
            $decision.Outcome | Should -Be 'Allow'
            $decision.Suffix | Should -BeExactly ''
        }
        It 'runs exactly the listing and the target checks, in order, and allows through the branch ref' {
            Set-PlannerScenario -Git @{ integration = @{ ExitCode = 1; Output = @() }; branch = @{ ExitCode = 0; Output = @() } }
            $decision = Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session
            $decision.Outcome | Should -Be 'Allow'
            $expected = @(
                '-C /synthetic-worktrees/session worktree list --porcelain'
                "-C $($script:Target) status --porcelain=v1 --untracked-files=all"
                "-C $($script:Target) rev-parse --verify HEAD"
                "-C $($script:Target) merge-base --is-ancestor abc1234 refs/remotes/origin/epic/alpha"
                "-C $($script:Target) merge-base --is-ancestor abc1234 refs/remotes/origin/feature/alpha-1"
            )
            $script:GitCalls.ToArray() | Should -Be $expected
            @($script:GitCalls | Where-Object { $_ -match '\b(fetch|pull|ls-remote)\b' }).Count | Should -Be 0
        }
        It 'allows a fanned_in record' {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = '{"integration_branch":"epic/alpha","planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"fanned_in"}]}' })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'Allow'
        }
        It 'allows a record whose repository-relative path names the target' {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = '{"integration_branch":"epic/alpha","planner_worktrees":[{"branch":"feature/alpha-1","path":".claude/worktrees/agent-alpha","purpose":"preparation","preparation_status":"prepared"}]}' })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'Allow'
        }
        It 'returns NoRecord with zero git calls and one planner read when no planner checkpoint exists' {
            Set-PlannerScenario -PlannerRead @()
            $decision = Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session
            $decision.Outcome | Should -Be 'NoRecord'
            $decision.Suffix | Should -BeExactly ''
            $script:GitCalls.Count | Should -Be 0
            Should -Invoke Get-PlannerWorktreeCheckpointText -Times 1 -Exactly
            Should -Invoke Get-PlannerWorktreeCheckpointText -Times 1 -Exactly -ParameterFilter { $RelativePath -ceq 'artifacts/orchestration/epic-planner-state.json' -and $SessionRoot -ceq '/synthetic-worktrees/session' }
        }
        It 'returns NoRecord with zero git calls when the checkpoint holds no candidate' {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = '{"planner_worktrees":[{"branch":""}]}' })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'NoRecord'
            $script:GitCalls.Count | Should -Be 0
        }
        It 'returns NoRecord after only the listing when the candidates name another branch' {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = '{"planner_worktrees":[{"branch":"feature/beta-2","purpose":"preparation","preparation_status":"prepared"}]}' })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'NoRecord'
            $script:GitCalls.ToArray() | Should -Be @('-C /synthetic-worktrees/session worktree list --porcelain')
            Should -Invoke Get-PlannerWorktreeCheckpointText -Times 1 -Exactly
        }
        It 'never matches a detached target (AC-21)' {
            Set-PlannerScenario -Listing @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'HEAD abc1234', 'detached', '')
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'NoRecord'
        }
        It 'does not name the target when the record path <Name> (AC-21)' -ForEach @(
            @{ Name = 'points at another worktree'; Path = '.claude/worktrees/agent-beta' }
            @{ Name = 'is absolute'; Path = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha' }
            @{ Name = 'has a dot segment'; Path = '.claude/worktrees/../worktrees/agent-alpha' }
        ) {
            $text = '{"planner_worktrees":[{"branch":"feature/alpha-1","path":"' + $Path + '","purpose":"preparation","preparation_status":"prepared"}]}'
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = $text })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'NoRecord'
        }
        It 'refuses GIT_FAILED when the listing fails while a candidate exists' {
            Set-PlannerScenario -Git @{ worktree = @{ ExitCode = 128; Output = @() } }
            $decision = Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session
            $decision.Code | Should -BeExactly 'GIT_FAILED'
            $decision.Suffix | Should -BeLike " Planner worktree: PLANNER_WORKTREE_GIT_FAILED: branch 'feature/alpha-1': git worktree list exited 128."
            $script:GitCalls.Count | Should -Be 1
        }
        It 'refuses IN_USE U1 when the target equals the session root' {
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Target).Detail | Should -BeLike 'U1 *'
        }
        It 'refuses IN_USE U1 when the target encloses the session root' {
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot "$($script:Target)/src").Detail | Should -BeLike 'U1 *'
        }
        It 'refuses IN_USE U1 when the target holds the matching planner checkpoint' {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Target; Text = '{"planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"prepared"}]}' })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Detail | Should -BeLike 'U1 *'
        }
        It 'refuses IN_USE U2 when the target is the main checkout' {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = '/synthetic-worktrees/other'; Text = '{"planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"prepared"}]}' }) -Listing @('worktree /synthetic-worktrees/main', 'branch refs/heads/feature/alpha-1', '')
            $decision = Get-PlannerWorktreeRemovalTargetDecision -WorktreePath '/synthetic-worktrees/main' -SessionRoot '/synthetic-worktrees/other'
            $decision.Code | Should -BeExactly 'IN_USE'
            $decision.Detail | Should -BeLike 'U2 *'
        }
        It 'refuses IN_USE U3 when the target stanza carries a locked line' {
            Set-PlannerScenario -Listing @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'branch refs/heads/feature/alpha-1', 'locked claude agent agent-alpha (pid 4242)', '')
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Detail | Should -BeLike 'U3 *'
            Should -Invoke Get-PlannerWorktreeCheckpointText -Times 1 -Exactly
        }
        It 'refuses IN_USE U4 when the target orchestrator checkpoint is <Name>' -ForEach @(
            @{ Name = 'unparseable'; Text = '{broken' }
            @{ Name = 'not at S5_atomic_execution'; Text = '{"next_step":"S7_pr_authoring"}' }
        ) {
            Set-PlannerScenario -OrchestratorRead @([pscustomobject]@{ Root = $script:Target; Text = $Text })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Detail | Should -BeLike 'U4 *'
        }
        It 'does not apply U4 to an absent target checkpoint or one held by another root' {
            Set-PlannerScenario -OrchestratorRead @([pscustomobject]@{ Root = $script:Session; Text = '{"next_step":"S7_pr_authoring"}' }, [pscustomobject]@{ Root = $script:Target; Text = '{"next_step":"S5_atomic_execution"}' })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'Allow'
        }
        It 'refuses IN_USE U5 when a live epic checkpoint records the target through <Name>' -ForEach @(
            @{ Name = 'a relative worktree_path'; Text = '{"route_id":"epic","features":[{"worktree_path":".claude/worktrees/agent-alpha"}]}' }
            @{ Name = 'an absolute worktree_path'; Text = '{"route_id":"epic","features":[{"worktree_path":"/synthetic-worktrees/session/.claude/worktrees/agent-alpha"}]}' }
            @{ Name = 'branch_name'; Text = '{"route_id":"epic","features":[{"branch_name":"feature/alpha-1","worktree_path":"elsewhere"}]}' }
        ) {
            Set-PlannerScenario -EpicRead @([pscustomobject]@{ Root = '/synthetic-worktrees/epic-root'; Text = $Text })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Detail | Should -BeLike 'U5 *'
        }
        It 'does not apply U5 to an epic checkpoint of another route or one recording another worktree' {
            Set-PlannerScenario -EpicRead @([pscustomobject]@{ Root = $script:Session; Text = '{"route_id":"parallel","features":[{"branch_name":"feature/alpha-1"}]}' }, [pscustomobject]@{ Root = $script:Session; Text = '{"route_id":"epic","features":[{"worktree_path":".claude/worktrees/agent-beta"}]}' })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'Allow'
        }
        It 'refuses DIRTY when git status prints a change' {
            Set-PlannerScenario -Git @{ status = @{ ExitCode = 0; Output = @('?? scratch.txt') } }
            $decision = Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session
            $decision.Code | Should -BeExactly 'DIRTY'
            $decision.Suffix | Should -BeExactly " Planner worktree: PLANNER_WORKTREE_DIRTY: branch 'feature/alpha-1' has uncommitted or untracked changes."
        }
        It 'refuses NOT_PUSHED when neither remote-tracking ref holds the HEAD' {
            Set-PlannerScenario -Git @{ integration = @{ ExitCode = 1; Output = @() }; branch = @{ ExitCode = 1; Output = @() } }
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Code | Should -BeExactly 'NOT_PUSHED'
        }
        It 'refuses NOT_ELIGIBLE for <Name>' -ForEach @(
            @{ Name = 'a removed record'; Record = '"purpose":"preparation","preparation_status":"removed"' }
            @{ Name = 'a preparing record'; Record = '"purpose":"preparation","preparation_status":"preparing"' }
            @{ Name = 'an abandoned record'; Record = '"purpose":"preparation","preparation_status":"abandoned"' }
            @{ Name = 'another purpose'; Record = '"purpose":"review","preparation_status":"prepared"' }
        ) {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = '{"planner_worktrees":[{"branch":"feature/alpha-1",' + $Record + '}]}' })
            $decision = Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session
            $decision.Code | Should -BeExactly 'NOT_ELIGIBLE'
            $script:GitCalls.Count | Should -Be 1
        }
        It 'refuses AMBIGUOUS when records in two planner checkpoints name the target' {
            $text = '{"planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"prepared"}]}'
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = $text }, [pscustomobject]@{ Root = '/synthetic-worktrees/session/.claude/worktrees/agent-beta'; Text = $text })
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Code | Should -BeExactly 'AMBIGUOUS'
        }
        It 'refuses AMBIGUOUS when the branch is checked out in two live roots' {
            Set-PlannerScenario -Listing @('worktree /synthetic-worktrees/session', 'branch refs/heads/main', '', "worktree $($script:Target)", 'branch refs/heads/feature/alpha-1', '', 'worktree /synthetic-worktrees/copy', 'branch refs/heads/feature/alpha-1', '')
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Code | Should -BeExactly 'AMBIGUOUS'
        }
        It 'refuses GIT_FAILED when <Name>' -ForEach @(
            @{ Name = 'git status exits non-zero'; Git = @{ status = @{ ExitCode = 128; Output = @() } } }
            @{ Name = 'rev-parse fails'; Git = @{ 'rev-parse' = @{ ExitCode = 128; Output = @() } } }
            @{ Name = 'the integration check exits 128'; Git = @{ integration = @{ ExitCode = 128; Output = @() } } }
            @{ Name = 'the branch check exits 128'; Git = @{ integration = @{ ExitCode = 1; Output = @() }; branch = @{ ExitCode = 128; Output = @() } } }
        ) {
            Set-PlannerScenario -Git $Git
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Code | Should -BeExactly 'GIT_FAILED'
        }
        It 'tests only the branch ref when the planner checkpoint records no integration branch' {
            Set-PlannerScenario -PlannerRead @([pscustomobject]@{ Root = $script:Session; Text = '{"planner_worktrees":[{"branch":"feature/alpha-1","purpose":"preparation","preparation_status":"prepared"}]}' }) -Git @{ branch = @{ ExitCode = 0; Output = @() } }
            (Get-PlannerWorktreeRemovalTargetDecision -WorktreePath $script:Target -SessionRoot $script:Session).Outcome | Should -Be 'Allow'
            @($script:GitCalls | Where-Object { $_ -like '*merge-base*' }) | Should -Be @("-C $($script:Target) merge-base --is-ancestor abc1234 refs/remotes/origin/feature/alpha-1")
        }
    }

    Context 'seam bodies' {
        It 'reads the file beneath every live root and returns one object per root that holds it' {
            Mock Get-WorktreeItemLiveRoot { , [string[]] @('/synthetic-worktrees/session', '', '\synthetic-worktrees\agent-alpha\') }
            Mock Get-WorktreeRunCheckpointText { if ($Path -ceq '/synthetic-worktrees/session/artifacts/orchestration/epic-planner-state.json') { '{"a":1}' } else { $null } }
            $reads = @(Get-PlannerWorktreeCheckpointText -SessionRoot '/synthetic-worktrees/session' -RelativePath 'artifacts/orchestration/epic-planner-state.json')
            $reads.Count | Should -Be 1
            $reads[0].Root | Should -BeExactly '/synthetic-worktrees/session'
            $reads[0].Text | Should -BeExactly '{"a":1}'
            Should -Invoke Get-WorktreeRunCheckpointText -Times 2 -Exactly
            Should -Invoke Get-WorktreeRunCheckpointText -Times 1 -Exactly -ParameterFilter { $Path -ceq '/synthetic-worktrees/agent-alpha/artifacts/orchestration/epic-planner-state.json' }
            Should -Invoke Get-WorktreeItemLiveRoot -Times 1 -Exactly -ParameterFilter { $SessionRoot -ceq '/synthetic-worktrees/session' }
        }
        It 'returns nothing when no live root is found' {
            Mock Get-WorktreeItemLiveRoot { , [string[]] @() }
            Mock Get-WorktreeRunCheckpointText { '{}' }
            @(Get-PlannerWorktreeCheckpointText -SessionRoot '/synthetic-worktrees/session' -RelativePath 'x').Count | Should -Be 0
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly
        }
    }

    Context 'adapter shape (AST)' {
        BeforeAll {
            $tokens = $null
            $errors = $null
            $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:AdapterFile, [ref] $tokens, [ref] $errors)
            $script:Text = Get-Content -Raw -LiteralPath $script:AdapterFile
            $script:Commands = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
            function Get-EnclosingFunctionName {
                param($Node)
                $parent = $Node.Parent
                while ($null -ne $parent -and $parent -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) { $parent = $parent.Parent }
                if ($null -eq $parent) { return '' }
                return $parent.Name
            }
        }
        It 'never calls Get-Location' { @($script:Commands | Where-Object { $_.GetCommandName() -eq 'Get-Location' }).Count | Should -Be 0 }
        It 'holds no direct file read' { $script:Text | Should -Not -Match 'Get-Content|ReadAllText|ReadAllLines' }
        It 'never writes a file' {
            @($script:Commands | Where-Object { @('Set-Content', 'Add-Content', 'Out-File') -contains $_.GetCommandName() }).Count | Should -Be 0
            $script:Text | Should -Not -Match 'WriteAllText'
        }
        It 'calls the module read seams only inside Get-PlannerWorktreeCheckpointText' {
            $calls = @($script:Commands | Where-Object { @('Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText') -contains $_.GetCommandName() })
            $calls.Count | Should -Be 2
            @($calls | Where-Object { (Get-EnclosingFunctionName -Node $_) -cne 'Get-PlannerWorktreeCheckpointText' }).Count | Should -Be 0
        }
        It 'calls git only inside Invoke-PlannerWorktreeGitExe' {
            $calls = @($script:Commands | Where-Object { $_.GetCommandName() -eq 'git' })
            $calls.Count | Should -Be 1
            Get-EnclosingFunctionName -Node $calls[0] | Should -BeExactly 'Invoke-PlannerWorktreeGitExe'
        }
        It 'imports WorktreeItemResolution.psm1 in a single-statement try with -ErrorAction Stop and no -Force' {
            $tries = @($script:Ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.TryStatementAst] -and $_.Body.Extent.Text -match 'WorktreeItemResolution\.psm1' })
            $tries.Count | Should -Be 1
            @($tries[0].Body.Statements).Count | Should -Be 1
            $tries[0].Body.Extent.Text | Should -Match '-ErrorAction Stop'
            $tries[0].Body.Extent.Text | Should -Not -Match '-Force'
        }
    }
}
