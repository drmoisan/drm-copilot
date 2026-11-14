#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the pure planner worktree-removal helper (issue #1161).

.DESCRIPTION
    Runs every row against both byte-identical copies, .claude/hooks/hook-planner-worktree-removal.ps1
    and .codex/hooks/hook-planner-worktree-removal.ps1. The helper holds only function definitions,
    so every row passes in-memory values: no file is read or written, no process starts, and every
    root is a synthetic forward-slash path without a drive letter.
#>

Describe 'hook-planner-worktree-removal.ps1 (<HelperPath>)' -ForEach @(
    @{ HelperPath = '.claude/hooks/hook-planner-worktree-removal.ps1' }
    @{ HelperPath = '.codex/hooks/hook-planner-worktree-removal.ps1' }
) {
    BeforeAll {
        $script:HelperFile = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path $HelperPath
        . $script:HelperFile
        $script:Branch = 'feature/alpha-1'
        $script:Target = '/synthetic-worktrees/session/.claude/worktrees/agent-alpha'

        function Get-PlannerFactFixture {
            # A facts hashtable for one eligible, clean, matched record; each row overrides one fact.
            param([hashtable] $Override = @{})
            $facts = @{
                ListingExitCode = 0; Branch = $script:Branch; MatchCount = 1; BranchRootCount = 1
                Record = [pscustomobject]@{ branch = $script:Branch; purpose = 'preparation'; preparation_status = 'prepared' }
                IntegrationBranch = 'epic/alpha'; U1 = $false; U2 = $false; U3 = $false; U4 = $false; U5 = $false
                StatusExitCode = 0; StatusOutput = ''; HeadExitCode = 0; Head = 'abc1234'
                IntegrationAncestorExitCode = 0; BranchAncestorExitCode = $null
            }
            foreach ($key in $Override.Keys) { $facts[$key] = $Override[$key] }
            return $facts
        }
    }

    Context 'record parsing' {
        It 'returns one candidate per object entry with a non-empty string branch' {
            $text = '{"integration_branch":"epic/alpha","planner_worktrees":[{"branch":"feature/alpha-1"},{"branch":"feature/beta-2","path":"x"}]}'
            $candidates = @(Get-PlannerWorktreeCandidateRecord -Text $text)
            $candidates.Count | Should -Be 2
            $candidates[0].Branch | Should -BeExactly 'feature/alpha-1'
            $candidates[1].Record.path | Should -BeExactly 'x'
            $candidates[0].IntegrationBranch | Should -BeExactly 'epic/alpha'
        }
        It 'yields no candidate for <Name>' -ForEach @(
            @{ Name = 'null text'; Text = $null }
            @{ Name = 'unparseable text'; Text = '{not json' }
            @{ Name = 'an array root'; Text = '[{"planner_worktrees":[{"branch":"feature/alpha-1"}]}]' }
            @{ Name = 'an absent planner_worktrees'; Text = '{"features":[]}' }
            @{ Name = 'a non-list planner_worktrees'; Text = '{"planner_worktrees":{"branch":"feature/alpha-1"}}' }
            @{ Name = 'a non-object entry'; Text = '{"planner_worktrees":["feature/alpha-1",3]}' }
            @{ Name = 'an empty branch'; Text = '{"planner_worktrees":[{"branch":""}]}' }
            @{ Name = 'a non-string branch'; Text = '{"planner_worktrees":[{"branch":7}]}' }
            @{ Name = 'an entry without branch'; Text = '{"planner_worktrees":[{"purpose":"preparation"}]}' }
        ) {
            @(Get-PlannerWorktreeCandidateRecord -Text $Text).Count | Should -Be 0
        }
        It 'reports an empty integration branch when it is absent or not a string' {
            $absent = @(Get-PlannerWorktreeCandidateRecord -Text '{"planner_worktrees":[{"branch":"feature/alpha-1"}]}')
            $nonString = @(Get-PlannerWorktreeCandidateRecord -Text '{"integration_branch":5,"planner_worktrees":[{"branch":"feature/alpha-1"}]}')
            $absent[0].IntegrationBranch | Should -BeExactly ''
            $nonString[0].IntegrationBranch | Should -BeExactly ''
        }
    }

    Context 'eligibility' {
        It 'treats preparation_status <Status> with purpose <Purpose> as eligible: <Expected>' -ForEach @(
            @{ Purpose = 'preparation'; Status = 'prepared'; Expected = $true }
            @{ Purpose = 'preparation'; Status = 'fanned_in'; Expected = $true }
            @{ Purpose = 'preparation'; Status = 'preparing'; Expected = $false }
            @{ Purpose = 'preparation'; Status = 'removed'; Expected = $false }
            @{ Purpose = 'preparation'; Status = 'abandoned'; Expected = $false }
            @{ Purpose = 'preparation'; Status = 'Prepared'; Expected = $false }
            @{ Purpose = 'Preparation'; Status = 'prepared'; Expected = $false }
            @{ Purpose = 'review'; Status = 'fanned_in'; Expected = $false }
        ) {
            $record = [pscustomobject]@{ branch = 'feature/alpha-1'; purpose = $Purpose; preparation_status = $Status }
            Test-PlannerWorktreeRecordEligible -Record $record | Should -Be $Expected
        }
        It 'rejects a null record, a record without the fields, and non-string values' {
            Test-PlannerWorktreeRecordEligible -Record $null | Should -BeFalse
            Test-PlannerWorktreeRecordEligible -Record ([pscustomobject]@{ branch = 'feature/alpha-1' }) | Should -BeFalse
            Test-PlannerWorktreeRecordEligible -Record ([pscustomobject]@{ purpose = 1; preparation_status = 'prepared' }) | Should -BeFalse
        }
    }

    Context 'porcelain parsing' {
        BeforeAll {
            $script:Porcelain = @(
                'worktree /synthetic-worktrees/session', 'HEAD 1111111', 'branch refs/heads/main', ''
                'worktree /synthetic-worktrees/bare-store', 'bare', ''
                'worktree /synthetic-worktrees/agent-alpha', 'HEAD 2222222', 'branch refs/heads/feature/alpha-1', 'locked claude agent agent-alpha (pid 4242)', ''
                'worktree /synthetic-worktrees/agent-beta', 'HEAD 3333333', 'branch refs/heads/feature/beta-2', 'locked', ''
                'worktree /synthetic-worktrees/agent-gamma', 'HEAD 4444444', 'detached', ''
            )
            $script:Stanzas = @(ConvertFrom-PlannerWorktreePorcelain -Text $script:Porcelain)
        }
        It 'skips the bare stanza and keeps the four others in order' {
            $script:Stanzas.Count | Should -Be 4
            ($script:Stanzas | ForEach-Object { $_.Root }) -join ',' | Should -BeExactly '/synthetic-worktrees/session,/synthetic-worktrees/agent-alpha,/synthetic-worktrees/agent-beta,/synthetic-worktrees/agent-gamma'
        }
        It 'marks only the first stanza as the main checkout' {
            $script:Stanzas[0].IsMain | Should -BeTrue
            @($script:Stanzas | Where-Object { $_.IsMain }).Count | Should -Be 1
        }
        It 'reads a locked line with a reason' { $script:Stanzas[1].Locked | Should -BeTrue }
        It 'reads a bare locked line' { $script:Stanzas[2].Locked | Should -BeTrue }
        It 'leaves an unlocked stanza unlocked' { $script:Stanzas[0].Locked | Should -BeFalse }
        It 'strips refs/heads/ from the branch' { $script:Stanzas[1].Branch | Should -BeExactly 'feature/alpha-1' }
        It 'reports a detached stanza with a null branch' { $script:Stanzas[3].Branch | Should -BeNullOrEmpty }
        It 'parses one joined string the same way and keeps a non-heads ref verbatim' {
            $parsed = @(ConvertFrom-PlannerWorktreePorcelain -Text "worktree /synthetic-worktrees/x`nbranch refs/remotes/origin/y`n")
            $parsed[0].Branch | Should -BeExactly 'refs/remotes/origin/y'
        }
        It 'returns nothing for empty or null input and ignores lines before the first stanza' {
            @(ConvertFrom-PlannerWorktreePorcelain -Text $null).Count | Should -Be 0
            @(ConvertFrom-PlannerWorktreePorcelain -Text @('branch refs/heads/x', '')).Count | Should -Be 0
        }
    }

    Context 'paths' {
        It 'compares <Left> and <Right> as equal: <Expected>' -ForEach @(
            @{ Left = '/synthetic-worktrees/a/'; Right = '/synthetic-worktrees/a'; Expected = $true }
            @{ Left = '/synthetic-worktrees/A'; Right = '/synthetic-worktrees/a'; Expected = $false }
            @{ Left = '\\synthetic-host\share\A'; Right = '//synthetic-host/share/a'; Expected = $true }
            @{ Left = ''; Right = '/synthetic-worktrees/a'; Expected = $false }
        ) {
            Test-PlannerWorktreePathEqual -Left $Left -Right $Right | Should -Be $Expected
        }
        It 'reports <Outer> enclosing <Inner>: <Expected>' -ForEach @(
            @{ Outer = '/synthetic-worktrees/session'; Inner = '/synthetic-worktrees/session'; Expected = $true }
            @{ Outer = '/synthetic-worktrees'; Inner = '/synthetic-worktrees/session/sub'; Expected = $true }
            @{ Outer = '/synthetic-worktrees/sess'; Inner = '/synthetic-worktrees/session'; Expected = $false }
            @{ Outer = '/synthetic-worktrees/session/sub'; Inner = '/synthetic-worktrees/session'; Expected = $false }
            @{ Outer = ''; Inner = '/synthetic-worktrees/session'; Expected = $false }
        ) {
            Test-PlannerWorktreePathEnclosure -Outer $Outer -Inner $Inner | Should -Be $Expected
        }
        It 'accepts a safe relative path <Path>: <Expected>' -ForEach @(
            @{ Path = '.claude/worktrees/agent-alpha'; Expected = $true }
            @{ Path = ''; Expected = $false }
            @{ Path = '/abs'; Expected = $false }
            @{ Path = 'a\b'; Expected = $false }
            @{ Path = 'Z:'; Expected = $false }
            @{ Path = 'a/./b'; Expected = $false }
            @{ Path = 'a/../b'; Expected = $false }
            @{ Path = 'a//b'; Expected = $false }
        ) {
            Test-PlannerWorktreeRelativePathSafe -Path $Path | Should -Be $Expected
        }
        It 'rejects a non-string path' { Test-PlannerWorktreeRelativePathSafe -Path 5 | Should -BeFalse }
        It 'matches a record path joined to the main root, and a record without path' {
            $main = '/synthetic-worktrees/session'
            Test-PlannerWorktreeRecordPathMatch -Record ([pscustomobject]@{ branch = 'b' }) -TargetPath $script:Target -MainRoot $main | Should -BeTrue
            Test-PlannerWorktreeRecordPathMatch -Record ([pscustomobject]@{ path = '.claude/worktrees/agent-alpha' }) -TargetPath $script:Target -MainRoot $main | Should -BeTrue
        }
        It 'does not match a record path that <Name>' -ForEach @(
            @{ Name = 'points elsewhere'; Record = [pscustomobject]@{ path = '.claude/worktrees/agent-other' }; Main = '/synthetic-worktrees/session' }
            @{ Name = 'is unsafe'; Record = [pscustomobject]@{ path = '../agent-alpha' }; Main = '/synthetic-worktrees/session' }
            @{ Name = 'has no main root'; Record = [pscustomobject]@{ path = '.claude/worktrees/agent-alpha' }; Main = '' }
            @{ Name = 'belongs to a null record'; Record = $null; Main = '/synthetic-worktrees/session' }
        ) {
            Test-PlannerWorktreeRecordPathMatch -Record $Record -TargetPath $script:Target -MainRoot $Main | Should -BeFalse
        }
    }

    Context 'U4 and U5 facts' {
        It 'treats the target checkpoint <Name> as in use: <Expected>' -ForEach @(
            @{ Name = 'absent'; Text = $null; Expected = $false }
            @{ Name = 'empty'; Text = ''; Expected = $true }
            @{ Name = 'unparseable'; Text = '{oops'; Expected = $true }
            @{ Name = 'without next_step'; Text = '{"issue":1}'; Expected = $true }
            @{ Name = 'at another step'; Text = '{"next_step":"S6_review"}'; Expected = $true }
            @{ Name = 'at a case variant'; Text = '{"next_step":"s5_atomic_execution"}'; Expected = $true }
            @{ Name = 'at S5_atomic_execution'; Text = '{"next_step":"S5_atomic_execution"}'; Expected = $false }
        ) {
            Test-PlannerWorktreeTargetCheckpointInUse -Text $Text | Should -Be $Expected
        }
        It 'reads branch_name and worktree_path from an epic checkpoint' {
            $checkpoint = ConvertFrom-PlannerWorktreeJson -Text '{"route_id":"epic","features":[{"branch_name":"feature/alpha-1","worktree_path":".claude/worktrees/a"},{"worktree_path":5},"x"]}'
            $fact = Get-PlannerWorktreeEpicRecordFact -Checkpoint $checkpoint -Branch 'feature/alpha-1'
            $fact.BranchNamed | Should -BeTrue
            @($fact.WorktreePath) | Should -Be @('.claude/worktrees/a')
        }
        It 'ignores a checkpoint that <Name>' -ForEach @(
            @{ Name = 'is null'; Text = $null }
            @{ Name = 'has another route'; Text = '{"route_id":"parallel","features":[{"branch_name":"feature/alpha-1"}]}' }
            @{ Name = 'has a case-variant route'; Text = '{"route_id":"Epic","features":[{"branch_name":"feature/alpha-1"}]}' }
            @{ Name = 'has no features'; Text = '{"route_id":"epic"}' }
            @{ Name = 'is an array'; Text = '[{"route_id":"epic","features":[{"branch_name":"feature/alpha-1"}]}]' }
        ) {
            $fact = Get-PlannerWorktreeEpicRecordFact -Checkpoint (ConvertFrom-PlannerWorktreeJson -Text $Text) -Branch 'feature/alpha-1'
            $fact.BranchNamed | Should -BeFalse
            @($fact.WorktreePath).Count | Should -Be 0
        }
        It 'does not name a branch that differs only in case' {
            $checkpoint = ConvertFrom-PlannerWorktreeJson -Text '{"route_id":"epic","features":[{"branch_name":"Feature/Alpha-1"}]}'
            (Get-PlannerWorktreeEpicRecordFact -Checkpoint $checkpoint -Branch 'feature/alpha-1').BranchNamed | Should -BeFalse
        }
    }

    Context 'decision order' {
        It 'returns NoRecord when no record names the target' {
            (Get-PlannerWorktreeRemovalDecision -Facts (Get-PlannerFactFixture -Override @{ MatchCount = 0 })).Outcome | Should -Be 'NoRecord'
        }
        It 'allows when the HEAD is an ancestor of the integration ref' {
            (Get-PlannerWorktreeRemovalDecision -Facts (Get-PlannerFactFixture)).Outcome | Should -Be 'Allow'
        }
        It 'allows through the branch ref after the integration check exits 1' {
            $facts = Get-PlannerFactFixture -Override @{ IntegrationAncestorExitCode = 1; BranchAncestorExitCode = 0 }
            (Get-PlannerWorktreeRemovalDecision -Facts $facts).Outcome | Should -Be 'Allow'
        }
        It 'tests only the branch ref when the integration branch is <Name>' -ForEach @(
            @{ Name = 'absent'; Value = $null }
            @{ Name = 'empty'; Value = '' }
        ) {
            $facts = Get-PlannerFactFixture -Override @{ IntegrationBranch = $Value; IntegrationAncestorExitCode = $null }
            $decision = Get-PlannerWorktreeRemovalDecision -Facts $facts
            $decision.Outcome | Should -Be 'Pending'
            $decision.Pending | Should -Be 'BranchAncestor'
        }
        It 'refuses <Code> when <Name>' -ForEach @(
            @{ Name = 'the listing failed'; Code = 'GIT_FAILED'; Override = @{ ListingExitCode = 128 } }
            @{ Name = 'two records match'; Code = 'AMBIGUOUS'; Override = @{ MatchCount = 2 } }
            @{ Name = 'two live roots hold the branch'; Code = 'AMBIGUOUS'; Override = @{ BranchRootCount = 2 } }
            @{ Name = 'the record is not eligible'; Code = 'NOT_ELIGIBLE'; Override = @{ Record = [pscustomobject]@{ purpose = 'preparation'; preparation_status = 'removed' } } }
            @{ Name = 'git status failed'; Code = 'GIT_FAILED'; Override = @{ StatusExitCode = 128 } }
            @{ Name = 'the worktree is dirty'; Code = 'DIRTY'; Override = @{ StatusOutput = '?? new.txt' } }
            @{ Name = 'rev-parse failed'; Code = 'GIT_FAILED'; Override = @{ HeadExitCode = 128; Head = '' } }
            @{ Name = 'rev-parse printed no commit'; Code = 'GIT_FAILED'; Override = @{ Head = '' } }
            @{ Name = 'the integration check exited 128'; Code = 'GIT_FAILED'; Override = @{ IntegrationAncestorExitCode = 128 } }
            @{ Name = 'the branch check exited 128'; Code = 'GIT_FAILED'; Override = @{ IntegrationAncestorExitCode = 1; BranchAncestorExitCode = 128 } }
            @{ Name = 'neither ref holds the HEAD'; Code = 'NOT_PUSHED'; Override = @{ IntegrationAncestorExitCode = 1; BranchAncestorExitCode = 1 } }
        ) {
            $decision = Get-PlannerWorktreeRemovalDecision -Facts (Get-PlannerFactFixture -Override $Override)
            $decision.Outcome | Should -Be 'Refuse'
            $decision.Code | Should -BeExactly $Code
            $decision.Detail | Should -BeLike "*'feature/alpha-1'*"
            $decision.Detail | Should -Not -BeLike '*/synthetic-worktrees*'
        }
        It 'refuses IN_USE with detail beginning <Condition> when only <Condition> holds' -ForEach @(
            @{ Condition = 'U1' }, @{ Condition = 'U2' }, @{ Condition = 'U3' }, @{ Condition = 'U4' }, @{ Condition = 'U5' }
        ) {
            $decision = Get-PlannerWorktreeRemovalDecision -Facts (Get-PlannerFactFixture -Override @{ $Condition = $true })
            $decision.Code | Should -BeExactly 'IN_USE'
            $decision.Detail | Should -BeLike "$Condition *"
        }
        It 'reports the first in-use condition when several hold' {
            $decision = Get-PlannerWorktreeRemovalDecision -Facts (Get-PlannerFactFixture -Override @{ U3 = $true; U5 = $true })
            $decision.Detail | Should -BeLike 'U3 *'
        }
        It 'checks eligibility before the in-use conditions' {
            $facts = Get-PlannerFactFixture -Override @{ U1 = $true; Record = [pscustomobject]@{ purpose = 'preparation'; preparation_status = 'preparing' } }
            (Get-PlannerWorktreeRemovalDecision -Facts $facts).Code | Should -BeExactly 'NOT_ELIGIBLE'
        }
        It 'checks cleanliness before the push check, even when the status is dirty and the HEAD is unpushed' {
            $facts = Get-PlannerFactFixture -Override @{ StatusOutput = ' M a.txt'; IntegrationAncestorExitCode = 1; BranchAncestorExitCode = 1 }
            (Get-PlannerWorktreeRemovalDecision -Facts $facts).Code | Should -BeExactly 'DIRTY'
        }
        It 'asks for <Pending> while that fact is missing' -ForEach @(
            @{ Pending = 'Status'; Override = @{ StatusExitCode = $null } }
            @{ Pending = 'Head'; Override = @{ HeadExitCode = $null } }
            @{ Pending = 'IntegrationAncestor'; Override = @{ IntegrationAncestorExitCode = $null } }
            @{ Pending = 'BranchAncestor'; Override = @{ IntegrationAncestorExitCode = 1 } }
        ) {
            $decision = Get-PlannerWorktreeRemovalDecision -Facts (Get-PlannerFactFixture -Override $Override)
            $decision.Outcome | Should -Be 'Pending'
            $decision.Pending | Should -BeExactly $Pending
        }
    }

    Context 'git fact arguments' {
        It 'builds the <Pending> arguments' -ForEach @(
            @{ Pending = 'Status'; Expected = '-C|/t|status|--porcelain=v1|--untracked-files=all' }
            @{ Pending = 'Head'; Expected = '-C|/t|rev-parse|--verify|HEAD' }
            @{ Pending = 'IntegrationAncestor'; Expected = '-C|/t|merge-base|--is-ancestor|abc1234|refs/remotes/origin/epic/alpha' }
            @{ Pending = 'BranchAncestor'; Expected = '-C|/t|merge-base|--is-ancestor|abc1234|refs/remotes/origin/feature/alpha-1' }
        ) {
            $facts = @{ Head = 'abc1234'; IntegrationBranch = 'epic/alpha'; Branch = 'feature/alpha-1' }
            (Get-PlannerWorktreeGitFactArgument -Pending $Pending -WorktreePath '/t' -Facts $facts) -join '|' | Should -BeExactly $Expected
        }
        It 'records the <Pending> result' -ForEach @(
            @{ Pending = 'Status'; Key = 'StatusOutput'; Expected = ' M a.txt' }
            @{ Pending = 'Head'; Key = 'Head'; Expected = 'abc1234' }
            @{ Pending = 'IntegrationAncestor'; Key = 'IntegrationAncestorExitCode'; Expected = 3 }
            @{ Pending = 'BranchAncestor'; Key = 'BranchAncestorExitCode'; Expected = 3 }
        ) {
            $facts = @{}
            $output = if ($Pending -eq 'Head') { @('abc1234 ') } else { @(' M a.txt') }
            Add-PlannerWorktreeGitFact -Pending $Pending -Result ([pscustomobject]@{ ExitCode = 3; Output = $output }) -Facts $facts
            $facts[$Key] | Should -Be $Expected
        }
    }

    Context 'refusal sentence' {
        It 'formats the sentence with the code and a closing period' {
            Format-PlannerWorktreeRefusalSentence -Code 'DIRTY' -Detail "branch 'feature/alpha-1' has uncommitted or untracked changes" |
                Should -BeExactly "Planner worktree: PLANNER_WORKTREE_DIRTY: branch 'feature/alpha-1' has uncommitted or untracked changes."
        }
        It 'returns a leading space and the sentence only for a refusal' {
            Get-PlannerWorktreeDenySuffix -Decision ([pscustomobject]@{ Outcome = 'Refuse'; Code = 'NOT_PUSHED'; Detail = 'd' }) | Should -BeExactly ' Planner worktree: PLANNER_WORKTREE_NOT_PUSHED: d.'
            Get-PlannerWorktreeDenySuffix -Decision ([pscustomobject]@{ Outcome = 'NoRecord' }) | Should -BeExactly ''
            Get-PlannerWorktreeDenySuffix -Decision $null | Should -BeExactly ''
        }
        It 'completes a decision with its suffix' {
            $complete = Complete-PlannerWorktreeDecision -Decision ([pscustomobject]@{ Outcome = 'Refuse'; Code = 'AMBIGUOUS'; Detail = 'd' })
            $complete.Outcome | Should -Be 'Refuse'
            $complete.Code | Should -BeExactly 'AMBIGUOUS'
            $complete.Suffix | Should -BeExactly ' Planner worktree: PLANNER_WORKTREE_AMBIGUOUS: d.'
            (Complete-PlannerWorktreeDecision -Decision (Get-PlannerWorktreeOutcome -Outcome Allow)).Suffix | Should -BeExactly ''
        }
    }

    Context 'purity (AST)' {
        BeforeAll {
            $tokens = $null
            $errors = $null
            $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HelperFile, [ref] $tokens, [ref] $errors)
            $script:ParseErrors = $errors
        }
        It 'parses without errors' { @($script:ParseErrors).Count | Should -Be 0 }
        It 'holds only function definitions at the top level' {
            $statements = @($script:Ast.EndBlock.Statements) + @($script:Ast.BeginBlock.Statements) + @($script:Ast.ProcessBlock.Statements)
            @($statements | Where-Object { $_ -and $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] }).Count | Should -Be 0
        }
        It 'calls no I/O, session-state, or process command' {
            # The process cmdlet name is composed so this file does not spell it.
            $forbidden = @('Set-StrictMode', 'Get-Content', 'Set-Content', 'Test-Path', 'Get-Item', 'Get-ChildItem', 'Get-Location', (('Start', 'Process') -join '-'), 'git')
            $names = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() })
            @($names | Where-Object { $forbidden -contains $_ -or ($_ -like 'Invoke-*' -and $_ -like '*Exe') }).Count | Should -Be 0
        }
        It 'makes no member call on a System.IO or Console type' {
            $calls = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $node.Static }, $true))
            @($calls | Where-Object { $_.Expression.TypeName.FullName -match '^(System\.)?(IO\.|Console$)' }).Count | Should -Be 0
        }
        It 'assigns no preference variable' {
            $assignments = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true))
            @($assignments | Where-Object { $_.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and $_.Left.VariablePath.UserPath -like '*Preference' }).Count | Should -Be 0
        }
    }
}
