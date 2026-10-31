#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    pr-author gate current-branch target derivation and deny guidance (issue #989, CB-01 to CB-16).

.DESCRIPTION
    Covers enforce-pr-author-skill.current-branch.ps1 through the parent hook: the never-throwing
    git wrapper Invoke-PrAuthorCurrentBranchGitExe, the branch reader Get-PrAuthorCurrentBranch,
    the fallback inside Resolve-PrAuthorWorktreeTarget, the TARGET_WORKTREE_NOT_DERIVABLE
    guidance text, and the skill gate's allow of the closing-reference verification command.

    No row runs the git executable. The wrapper rows pass test-local stand-ins through the
    GitInvoker parameter, so the wrapper body runs without starting a process. Every row that can
    reach the fallback mocks Get-PrAuthorCurrentBranch and Resolve-WorktreeItemTarget inside the
    row; the resolver mock uses a ParameterFilter on $Text to separate the command-text call from
    the 'branch: <name>' re-resolution. No sibling function is mocked at file level, so the CB-16
    row runs whether or not the sibling file is loaded. The shared resolver
    Resolve-HookTargetWorktree (issue #1011) is mocked at file level to the not-derivable result,
    which maps to no selection, so the --head rows start no git process and keep exercising the
    identity path.

.NOTES
    Synthetic roots use the /synthetic-worktrees/... form. No row creates a file, changes the
    working directory, spawns a process, reads a wall clock, or touches the network.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-pr-author-skill.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState -ParameterFilter { $CheckpointPath -notlike "*tests?fixtures*" } -MockWith { $null }
    Mock Get-PrAuthorCheckpointContent -ParameterFilter { $CheckpointPath -notlike "*tests?fixtures*" } -MockWith { $null }
    Mock Get-PrAuthorReceiptContent -ParameterFilter { $ReceiptFilePath -notlike "*tests?fixtures*" } -MockWith { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeRunResolution.psm1')
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/HookTargetWorktree.psm1')
    $script:SharedNoSelection = [pscustomobject]@{ WorktreeRoot = $null; Source = 'CommandOperand'; Ambiguous = $false; ReasonCode = (Get-WorktreeResolutionNoTargetReasonCode); Detail = 'shared resolver not exercised by this suite'; Candidates = [string[]] @() }
    Mock Resolve-HookTargetWorktree { $script:SharedNoSelection }

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:EditCommand = 'gh pr edit 5 --body-file artifacts/pr_body_5.md'
    $script:HeadCommand = 'gh pr create --head feature/x --base main --body-file artifacts/pr_body_5.md'
    $script:IssueCommand = "gh pr edit 5 --body-file artifacts/pr_body_5.md`nCanonical issue number for this feature is 5."

    # Test-local stand-ins for the git executable, passed to the GitInvoker parameter.
    function Invoke-CurrentBranchFakeGitEcho { $global:LASTEXITCODE = 0; '  ' + ($args -join '|') + '  ' }
    function Invoke-CurrentBranchFakeGitThrow { throw 'git could not start' }
    function Invoke-CurrentBranchFakeGitBranch { $global:LASTEXITCODE = 0; "feature/x`n" }
    function Invoke-CurrentBranchFakeGitDetached { $global:LASTEXITCODE = 0; 'HEAD' }
    function Invoke-CurrentBranchFakeGitFail { $global:LASTEXITCODE = 128 }
    function Invoke-CurrentBranchFakeGitEmpty { $global:LASTEXITCODE = 0; '' }

    # Mock the item resolver: the command-text call returns CommandStatus and the 'branch: <name>'
    # re-resolution returns BranchStatus. Results are built here and captured by the closures,
    # because a closure-bound mock body cannot resolve a function defined in this scope.
    function Set-ResolverSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [Parameter(Mandatory)] [string] $CommandStatus,
            [string] $BranchStatus = 'NoTarget',
            [string] $BranchRoot
        )
        $commandResult = New-WorktreeResolutionFixtureTarget -Status $CommandStatus -WorktreeRoot $(if ($CommandStatus -in @('SessionRoot', 'OtherWorktree')) { '/synthetic-worktrees/command-target' } else { $null })
        $branchResult = New-WorktreeResolutionFixtureTarget -Status $BranchStatus -WorktreeRoot $BranchRoot -Candidate $(if ($BranchStatus -eq 'Ambiguous') { @('/synthetic-worktrees/a', '/synthetic-worktrees/b') } else { @() })
        Mock -CommandName Resolve-WorktreeItemTarget -ParameterFilter { -not $Text.StartsWith('branch: ') } -MockWith { $commandResult }.GetNewClosure()
        Mock -CommandName Resolve-WorktreeItemTarget -ParameterFilter { $Text.StartsWith('branch: ') } -MockWith { $branchResult }.GetNewClosure()
    }
}

Describe 'enforce-pr-author-skill.ps1 current-branch target derivation (issue #989)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'CB-01 Invoke-PrAuthorCurrentBranchGitExe returns the exit code and trimmed output of the invoker' {
        # Act
        $result = Invoke-PrAuthorCurrentBranchGitExe -GitArgs @('rev-parse', '--abbrev-ref', 'HEAD') -GitInvoker ${function:Invoke-CurrentBranchFakeGitEcho}

        # Assert: the arguments reach the invoker in order and surrounding whitespace is removed.
        $result.ExitCode | Should -Be 0
        $result.Output | Should -BeExactly 'rev-parse|--abbrev-ref|HEAD'
    }

    It 'CB-02 Invoke-PrAuthorCurrentBranchGitExe returns ExitCode -1 and does not throw when the invoker throws' {
        # Act
        $result = Invoke-PrAuthorCurrentBranchGitExe -GitArgs @('rev-parse', '--abbrev-ref', 'HEAD') -GitInvoker ${function:Invoke-CurrentBranchFakeGitThrow}

        # Assert
        $result.ExitCode | Should -Be -1
        $result.Output | Should -BeExactly ''
    }

    It 'CB-03 Get-PrAuthorCurrentBranch returns the branch name for exit 0' {
        Get-PrAuthorCurrentBranch -GitInvoker ${function:Invoke-CurrentBranchFakeGitBranch} | Should -BeExactly 'feature/x'
    }

    It 'CB-04 Get-PrAuthorCurrentBranch returns $null for a detached HEAD' {
        Get-PrAuthorCurrentBranch -GitInvoker ${function:Invoke-CurrentBranchFakeGitDetached} | Should -BeNullOrEmpty
    }

    It 'CB-05 Get-PrAuthorCurrentBranch returns $null for a non-zero git exit' {
        Get-PrAuthorCurrentBranch -GitInvoker ${function:Invoke-CurrentBranchFakeGitFail} | Should -BeNullOrEmpty
    }

    It 'CB-06 Get-PrAuthorCurrentBranch returns $null for empty output' {
        Get-PrAuthorCurrentBranch -GitInvoker ${function:Invoke-CurrentBranchFakeGitEmpty} | Should -BeNullOrEmpty
    }

    It 'CB-07 a no-signal gh pr edit resolves to SessionRoot through the derived branch' {
        # Arrange
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { 'feature/x' }
        Set-ResolverSeam -CommandStatus 'NoTarget' -BranchStatus 'SessionRoot' -BranchRoot '/synthetic-worktrees/item-x'

        # Act
        $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:EditCommand

        # Assert: the derived branch is re-resolved through the existing resolver.
        $target.Status | Should -Be 'SessionRoot'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/item-x'
        Should -Invoke -CommandName Resolve-WorktreeItemTarget -Times 1 -Exactly -ParameterFilter { $Text -ceq 'branch: feature/x' }
    }

    It 'CB-08 a no-signal gh pr edit resolves to OtherWorktree through the derived branch' {
        # Arrange
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { 'feature/x' }
        Set-ResolverSeam -CommandStatus 'NoTarget' -BranchStatus 'OtherWorktree' -BranchRoot '/synthetic-worktrees/item-x'

        # Act
        $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:EditCommand

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/item-x'
    }

    It 'CB-09 an Ambiguous re-resolution from the derived branch is returned unchanged' {
        # Arrange
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { 'feature/x' }
        Set-ResolverSeam -CommandStatus 'NoTarget' -BranchStatus 'Ambiguous'

        # Act
        $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:EditCommand

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        @($target.Candidates).Count | Should -Be 2
    }

    It 'CB-10 a $null derived branch returns the original NoTarget result' {
        # Arrange
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { $null }
        Set-ResolverSeam -CommandStatus 'NoTarget' -BranchStatus 'SessionRoot' -BranchRoot '/synthetic-worktrees/item-x'

        # Act
        $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:EditCommand

        # Assert: the branch re-resolution never ran.
        $target.Status | Should -Be 'NoTarget'
        Should -Invoke -CommandName Get-PrAuthorCurrentBranch -Times 1 -Exactly
        Should -Invoke -CommandName Resolve-WorktreeItemTarget -Times 0 -Exactly -ParameterFilter { $Text.StartsWith('branch: ') }
    }

    It 'CB-11 a --head command that resolves never reads the current branch' {
        # Arrange
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { 'feature/other' }
        Set-ResolverSeam -CommandStatus 'OtherWorktree'

        # Act
        $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        Should -Invoke -CommandName Get-PrAuthorCurrentBranch -Times 0 -Exactly
    }

    It 'CB-12 a --head branch that matches no worktree stays NoTarget without reading the current branch' {
        # Arrange: a signal that places the call nowhere does not trigger the fallback.
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { 'feature/other' }
        Set-ResolverSeam -CommandStatus 'NoTarget' -BranchStatus 'SessionRoot' -BranchRoot '/synthetic-worktrees/item-x'

        # Act
        $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:HeadCommand

        # Assert
        $target.Status | Should -Be 'NoTarget'
        Should -Invoke -CommandName Get-PrAuthorCurrentBranch -Times 0 -Exactly
    }

    It 'CB-13 a canonical issue line in the command never reads the current branch' {
        # Arrange
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { 'feature/other' }
        Set-ResolverSeam -CommandStatus 'NoTarget' -BranchStatus 'SessionRoot' -BranchRoot '/synthetic-worktrees/item-x'

        # Act
        $target = Resolve-PrAuthorWorktreeTarget -CommandText $script:IssueCommand

        # Assert
        $target.Status | Should -Be 'NoTarget'
        Should -Invoke -CommandName Get-PrAuthorCurrentBranch -Times 0 -Exactly
    }

    It 'CB-14 the NoTarget deny keeps its reason code and names the accepted create and edit forms' {
        # Arrange
        $noTarget = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith { $noTarget }.GetNewClosure()

        # Act
        $resolution = Get-PrAuthorTargetCheckpointResolution -CommandText $script:EditCommand

        # Assert
        $reason = [string]$resolution.Reason
        $reason.StartsWith($script:NoTargetCode) | Should -BeTrue -Because $reason
        $reason.Contains('gh pr create --head <branch>') | Should -BeTrue -Because $reason
        $reason.Contains('# branch: <branch>') | Should -BeTrue -Because $reason
        $reason.Contains('--head is not valid for gh pr edit') | Should -BeTrue -Because $reason
    }

    It 'CB-15 the existing checks apply to the item derived from the current branch' {
        # Arrange: the derived item worktree holds no PR context summary.
        Mock -CommandName Get-PrAuthorCurrentBranch -MockWith { 'feature/x' }
        Set-ResolverSeam -CommandStatus 'NoTarget' -BranchStatus 'OtherWorktree' -BranchRoot '/synthetic-worktrees/item-x'
        Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }

        # Act
        $reason = Get-PrAuthorBypassReason -CommandText $script:EditCommand

        # Assert
        $reason | Should -BeLike 'PR_CONTEXT_MISSING:*'
        $reason.Contains('/synthetic-worktrees/item-x') | Should -BeTrue -Because $reason
    }

    It 'CB-16 the skill gate allows the closing-reference verification command' {
        # Arrange
        $payload = @{ tool_input = @{ command = 'gh pr view 5 --json closingIssuesReferences,body' } } | ConvertTo-Json -Depth 5 -Compress

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }
}
