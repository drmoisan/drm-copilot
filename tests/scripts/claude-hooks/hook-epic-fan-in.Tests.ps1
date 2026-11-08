#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit rows for the post-fan-in allowance functions of hook-epic-fan-in.ps1 (issue #1136).

.DESCRIPTION
    Runs the same rows against the Claude copy (.claude/hooks) and the Codex copy
    (.codex/hooks), each loaded with its own surface's dependencies: the helpers file of that
    surface, plus HookTargetWorktree.psm1 on Claude or hook-target-worktree.ps1 on Codex. The
    staged index is supplied by an in-memory reader script block. The terminal merge statuses
    are pinned equal to $script:TerminalMergeStatuses of EpicScopeReadiness.psm1, and
    Test-EpicFanInComplete is compared with Get-EpicPrCreationReadinessFailure over a fixture
    matrix. No row creates a file, changes the working directory, or sets global state.
#>

Describe 'hook-epic-fan-in.ps1 <Surface> copy (issue #1136)' -ForEach @(
    @{ Surface = 'Claude'; HookDirectory = '.claude/hooks' }
    @{ Surface = 'Codex'; HookDirectory = '.codex/hooks' }
) {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot "$HookDirectory/enforce-orchestration-preimplementation-gate-helpers.ps1")
        if ($Surface -eq 'Claude') {
            Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/HookTargetWorktree.psm1')
        } else {
            . (Join-Path $script:RepoRoot '.codex/hooks/hook-target-worktree.ps1')
        }
        . (Join-Path $script:RepoRoot "$HookDirectory/hook-epic-fan-in.ps1")
        $script:ReadinessModule = Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeReadiness.psm1') -PassThru

        $script:StatusDoc = 'docs/features/epics/sample-epic/epic-status.md'
        $script:Root = '/synthetic-worktrees/epic-integration'
        $script:Branch = 'epic/sample-epic-integration'

        function Get-FanInCheckpoint {
            # Return a fan-in-complete epic checkpoint with optional property overrides.
            param([hashtable] $Override = @{})
            $checkpoint = [ordered]@{
                route_id            = 'epic'
                epic_feature_folder = 'sample-epic'
                integration_branch  = 'epic/sample-epic-integration'
                features            = @(
                    [pscustomobject]@{ feature_folder = 'child-a'; merge_status = 'merged' }
                    [pscustomobject]@{ feature_folder = 'child-b'; merge_status = 'worktree_removed' }
                )
            }
            foreach ($key in $Override.Keys) { $checkpoint[$key] = $Override[$key] }
            return [pscustomobject]$checkpoint
        }

        function Get-FanInScope {
            # Return a resolved epic scope object over one checkpoint.
            param([object] $Checkpoint = (Get-FanInCheckpoint))
            return [pscustomobject]@{
                IsEpicScope = $true; CheckpointPath = "$script:Root/artifacts/orchestration/epic-orchestrator-state.json"
                Checkpoint = $Checkpoint; WorktreeRoot = $script:Root; Branch = $script:Branch; MergeInProgress = $false; Reason = 'epic-scope'
            }
        }

        function Get-IndexReader {
            # Return a staged-index reader script block yielding one exit code and output.
            param([int] $ExitCode = 0, [AllowEmptyString()] [string] $Output = '')
            $code = $ExitCode
            $text = $Output
            return { param([string] $WorktreeRoot) [pscustomobject]@{ ExitCode = $code; Output = $text; Root = $WorktreeRoot } }.GetNewClosure()
        }

        function Get-CommandAllowance {
            # Return the allowance for one command with a reader over the given index text.
            param([string] $Command, [scriptblock] $Reader = (Get-IndexReader -Output ($script:StatusDoc + [char]0)))
            return (Get-EpicFanInAllowance -Scope (Get-FanInScope) -FilePath @('') -Command $Command -StagedIndexReader $Reader)
        }
    }

    Context 'Test-EpicFanInComplete' {
        It 'is true when every feature is merged or worktree_removed on the integration branch' {
            Test-EpicFanInComplete -Checkpoint (Get-FanInCheckpoint) -Branch $script:Branch | Should -BeTrue
        }

        It 'is false when <Case>' -ForEach @(
            @{ Case = 'a feature is pr_open'; Override = @{ features = @([pscustomobject]@{ merge_status = 'merged' }, [pscustomobject]@{ merge_status = 'pr_open' }) }; Branch = 'epic/sample-epic-integration' }
            @{ Case = 'features is empty'; Override = @{ features = @() }; Branch = 'epic/sample-epic-integration' }
            @{ Case = 'features is absent'; Override = @{ features = $null }; Branch = 'epic/sample-epic-integration' }
            @{ Case = 'route_id is parallel'; Override = @{ route_id = 'parallel' }; Branch = 'epic/sample-epic-integration' }
            @{ Case = 'the branch differs only in case'; Override = @{}; Branch = 'Epic/Sample-Epic-Integration' }
            @{ Case = 'the branch is blank'; Override = @{}; Branch = '' }
            @{ Case = 'integration_branch is blank'; Override = @{ integration_branch = '' }; Branch = '' }
        ) {
            Test-EpicFanInComplete -Checkpoint (Get-FanInCheckpoint -Override $Override) -Branch $Branch | Should -BeFalse -Because $Case
        }

        It 'is false for a null checkpoint' {
            Test-EpicFanInComplete -Checkpoint $null -Branch $script:Branch | Should -BeFalse
        }
    }

    Context 'Get-EpicFanInStatusDocRelativePath' {
        It 'derives the status document from a plain slug' {
            Get-EpicFanInStatusDocRelativePath -Checkpoint (Get-FanInCheckpoint) | Should -BeExactly $script:StatusDoc
        }

        It 'accepts an epic_status_doc_path that agrees after backslash normalisation' {
            $checkpoint = Get-FanInCheckpoint -Override @{ epic_status_doc_path = 'docs\features\epics\sample-epic\epic-status.md' }
            Get-EpicFanInStatusDocRelativePath -Checkpoint $checkpoint | Should -BeExactly $script:StatusDoc
        }

        It 'returns null when <Case>' -ForEach @(
            @{ Case = 'the slug is blank'; Override = @{ epic_feature_folder = ' ' } }
            @{ Case = 'the slug climbs'; Override = @{ epic_feature_folder = '../sample-epic' } }
            @{ Case = 'the slug has two segments'; Override = @{ epic_feature_folder = 'sample/epic' } }
            @{ Case = 'epic_status_doc_path disagrees'; Override = @{ epic_status_doc_path = 'docs/features/epics/other-epic/epic-status.md' } }
        ) {
            Get-EpicFanInStatusDocRelativePath -Checkpoint (Get-FanInCheckpoint -Override $Override) | Should -BeNullOrEmpty -Because $Case
        }
    }

    Context 'Test-EpicFanInWriteRelativePath' {
        It 'admits <Path>' -ForEach @(
            @{ Path = 'artifacts/pr_body_7.receipt.json' }
            @{ Path = 'artifacts/pr_body_12.md' }
            @{ Path = 'docs/features/epics/sample-epic/epic-status.md' }
        ) {
            Test-EpicFanInWriteRelativePath -RelativePath $Path -Checkpoint (Get-FanInCheckpoint) | Should -BeTrue
        }

        It 'refuses <Path>' -ForEach @(
            @{ Path = 'artifacts/pr_body_7.json' }
            @{ Path = 'artifacts/pr_body_x.md' }
            @{ Path = 'scripts/powershell/Sample.ps1' }
            @{ Path = 'docs/features/epics/other-epic/epic-status.md' }
            @{ Path = '' }
        ) {
            Test-EpicFanInWriteRelativePath -RelativePath $Path -Checkpoint (Get-FanInCheckpoint) | Should -BeFalse
        }
    }

    Context 'Test-EpicFanInCommitShape' {
        It 'returns <Expected> for <Text>' -ForEach @(
            @{ Text = 'git add docs/features/epics/sample-epic/epic-status.md'; Expected = 'add' }
            @{ Text = 'git add -- docs/features/epics/sample-epic/epic-status.md'; Expected = 'add' }
            @{ Text = 'git -C /synthetic-worktrees/epic-integration add docs/features/epics/sample-epic/epic-status.md'; Expected = 'add' }
            @{ Text = 'git commit -m status'; Expected = 'commit' }
            @{ Text = 'git commit --message status'; Expected = 'commit' }
            @{ Text = 'git commit --file /scratch/msg.txt'; Expected = 'commit' }
            @{ Text = 'git commit -m status --trailer Co-Authored-By:x'; Expected = 'commit' }
            @{ Text = 'git commit -F /scratch/msg.txt -- docs/features/epics/sample-epic/epic-status.md'; Expected = 'commit' }
        ) {
            Test-EpicFanInCommitShape -Token ($Text -split ' ') -StatusDocPath $script:StatusDoc | Should -BeExactly $Expected
        }

        It 'returns null for <Text>' -ForEach @(
            @{ Text = 'git commit --amend -m status' }
            @{ Text = 'git commit -a -m status' }
            @{ Text = 'git commit -m' }
            @{ Text = 'git commit -m status -- scripts/powershell/Sample.ps1' }
            @{ Text = 'git commit -m status scripts/powershell/Sample.ps1' }
            @{ Text = 'git add scripts/powershell/Sample.ps1' }
            @{ Text = 'git add docs/features/epics/sample-epic/epic-status.md scripts/powershell/Sample.ps1' }
            @{ Text = 'git -C relative/root add docs/features/epics/sample-epic/epic-status.md' }
            @{ Text = 'git -C' }
            @{ Text = 'git push origin' }
            @{ Text = 'npm run build' }
        ) {
            Test-EpicFanInCommitShape -Token ($Text -split ' ') -StatusDocPath $script:StatusDoc | Should -BeNullOrEmpty
        }

        It 'returns null when the status document is unknown' {
            Test-EpicFanInCommitShape -Token @('git', 'add', $script:StatusDoc) -StatusDocPath '' | Should -BeNullOrEmpty
        }
    }

    Context 'Get-EpicFanInAllowance' {
        It 'allows a pathless commit when the staged index is exactly the status doc and reads the scope root' {
            $seen = [System.Collections.Generic.List[string]]::new()
            $reader = { param([string] $WorktreeRoot) $seen.Add($WorktreeRoot); [pscustomobject]@{ ExitCode = 0; Output = 'docs/features/epics/sample-epic/epic-status.md' + [char]0 } }.GetNewClosure()
            (Get-CommandAllowance -Command 'git commit -m "docs: epic status"' -Reader $reader).Allowed | Should -BeTrue
            $seen | Should -Be @($script:Root)
        }

        It 'allows a commit with a status-doc pathspec without reading the index' {
            $reader = { throw 'the index must not be read' }
            (Get-CommandAllowance -Command 'git commit -F /scratch/msg.txt -- docs/features/epics/sample-epic/epic-status.md' -Reader $reader).Allowed | Should -BeTrue
        }

        It 'allows a chained add and pathless commit when the staged index is exactly the status doc' {
            (Get-CommandAllowance -Command 'git add docs/features/epics/sample-epic/epic-status.md && git commit -m status').Allowed | Should -BeTrue
        }

        It 'refuses a pathless commit when the staged index <Case>' -ForEach @(
            @{ Case = 'has an extra path'; ExitCode = 0; Output = "docs/features/epics/sample-epic/epic-status.md`0scripts/powershell/Sample.ps1`0" }
            @{ Case = 'is empty'; ExitCode = 0; Output = '' }
            @{ Case = 'is unreadable'; ExitCode = 128; Output = "docs/features/epics/sample-epic/epic-status.md`0" }
            @{ Case = 'is not NUL-terminated'; ExitCode = 0; Output = 'docs/features/epics/sample-epic/epic-status.md' }
        ) {
            (Get-CommandAllowance -Command 'git commit -m status' -Reader (Get-IndexReader -ExitCode $ExitCode -Output $Output)).Allowed | Should -BeFalse -Because $Case
        }

        It 'refuses a pathless commit when the reader throws' {
            $result = Get-CommandAllowance -Command 'git commit -m status' -Reader { throw 'index read failed' }
            $result.Allowed | Should -BeFalse
            $result.Detail | Should -BeLike 'allowance error:*'
        }

        It 'refuses <Case>' -ForEach @(
            @{ Case = 'a -F value with a backslash'; Command = 'git commit -F C:\msg.txt' }
            @{ Case = 'an unterminated quote'; Command = 'git commit -m "unterminated message' }
            @{ Case = 'a chained production add'; Command = 'git add docs/features/epics/sample-epic/epic-status.md && git add scripts/powershell/Sample.ps1' }
            @{ Case = 'a blank command'; Command = '' }
        ) {
            (Get-CommandAllowance -Command $Command).Allowed | Should -BeFalse -Because $Case
        }

        It 'refuses an absolute path outside the integration worktree' {
            $result = Get-EpicFanInAllowance -Scope (Get-FanInScope) -FilePath @('/synthetic-worktrees/other/artifacts/pr_body_7.receipt.json') -Command '' -StagedIndexReader $null
            $result.Allowed | Should -BeFalse
        }

        It 'allows an absolute receipt path inside the integration worktree' {
            $result = Get-EpicFanInAllowance -Scope (Get-FanInScope) -FilePath @("$script:Root/artifacts/pr_body_7.receipt.json") -Command '' -StagedIndexReader $null
            $result.Allowed | Should -BeTrue
        }

        It 'refuses a two-entry path leg holding one allowlisted and one production path' {
            $result = Get-EpicFanInAllowance -Scope (Get-FanInScope) -FilePath @('artifacts/pr_body_7.md', 'scripts/powershell/Sample.ps1') -Command '' -StagedIndexReader $null
            $result.Allowed | Should -BeFalse
        }

        It 'allows a two-entry path leg holding the receipt and the body' {
            $result = Get-EpicFanInAllowance -Scope (Get-FanInScope) -FilePath @('artifacts/pr_body_7.receipt.json', '', 'artifacts/pr_body_7.md') -Command '' -StagedIndexReader $null
            $result.Allowed | Should -BeTrue
        }

        It 'refuses a call with no resolved scope' {
            (Get-EpicFanInAllowance -Scope $null -FilePath @('artifacts/pr_body_7.md') -Command '' -StagedIndexReader $null).Allowed | Should -BeFalse
        }
    }

    Context 'pins' {
        It 'restates the terminal merge statuses of EpicScopeReadiness' {
            $reference = & $script:ReadinessModule { $script:TerminalMergeStatuses }
            $script:EpicFanInTerminalMergeStatuses | Should -Be $reference
        }

        It 'agrees with Get-EpicPrCreationReadinessFailure over the fixture matrix' {
            $matrix = @(
                @{ Checkpoint = (Get-FanInCheckpoint); Branch = 'epic/sample-epic-integration' }
                @{ Checkpoint = (Get-FanInCheckpoint -Override @{ features = @([pscustomobject]@{ merge_status = 'pr_open' }) }); Branch = 'epic/sample-epic-integration' }
                @{ Checkpoint = (Get-FanInCheckpoint -Override @{ features = @([pscustomobject]@{ merge_status = 'MERGED' }) }); Branch = 'epic/sample-epic-integration' }
                @{ Checkpoint = (Get-FanInCheckpoint -Override @{ features = @() }); Branch = 'epic/sample-epic-integration' }
                @{ Checkpoint = (Get-FanInCheckpoint -Override @{ route_id = 'Epic' }); Branch = 'epic/sample-epic-integration' }
                @{ Checkpoint = (Get-FanInCheckpoint -Override @{ integration_branch = '' }); Branch = 'epic/sample-epic-integration' }
                @{ Checkpoint = (Get-FanInCheckpoint); Branch = 'epic/other-integration' }
                @{ Checkpoint = $null; Branch = 'epic/sample-epic-integration' }
            )
            foreach ($row in $matrix) {
                $expected = (Get-EpicPrCreationReadinessFailure -Checkpoint $row.Checkpoint -HeadBranch $row.Branch) -eq ''
                Test-EpicFanInComplete -Checkpoint $row.Checkpoint -Branch $row.Branch | Should -Be $expected -Because "branch $($row.Branch)"
            }
        }
    }
}

Describe 'hook-epic-fan-in.ps1 mirror parity (issue #1136)' {
    It 'keeps the four copies of hook-epic-fan-in.ps1 byte-identical' {
        # Arrange
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $copies = @(
            '.claude/hooks/hook-epic-fan-in.ps1'
            '.codex/hooks/hook-epic-fan-in.ps1'
            'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-epic-fan-in.ps1'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-epic-fan-in.ps1'
        )

        # Act
        $hashes = @(foreach ($copy in $copies) { (Get-FileHash -LiteralPath (Join-Path $repoRoot $copy) -Algorithm SHA256).Hash })

        # Assert
        @($hashes | Select-Object -Unique).Count | Should -Be 1 -Because 'the four copies must be byte-identical'
    }
}
