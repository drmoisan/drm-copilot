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

        # Issue #1141: one qualifying merged feature, child-a, with optional entry overrides and removals.
        $script:FollowUpRoots = @('docs/features/active/child-a/', 'docs/features/completed/child-a/', 'docs/features/epics/sample-epic/epic-status.md')
        $script:FollowUpPredicate = { param([string] $Path) Test-EpicMergedFeaturePath -RelativePath $Path -Root $script:FollowUpRoots }

        function Get-RootsCheckpoint {
            # Return an epic checkpoint whose single feature is child-a, merged with provenance unless overridden.
            param([hashtable] $Feature = @{}, [string[]] $Remove = @(), [hashtable] $Override = @{})
            $entry = [ordered]@{ feature_folder = 'child-a'; merge_status = 'merged'; merge_commit_sha = 'ab12' * 10; pr_number = 901 }
            foreach ($key in $Feature.Keys) { $entry[$key] = $Feature[$key] }
            foreach ($key in $Remove) { $entry.Remove($key) }
            return (Get-FanInCheckpoint -Override (@{ features = @([pscustomobject]$entry) } + $Override))
        }

        function Get-FollowUpAllowance {
            # Return the follow-up allowance for one path list or command over a scope of the given checkpoint.
            param([object] $Checkpoint = (Get-RootsCheckpoint), [string[]] $FilePath = @(''), [string] $Command = '', [scriptblock] $Reader = (Get-IndexReader -Output ('docs/features/active/child-a/x.md' + [char]0)))
            return (Get-EpicMergedFeatureFollowUpAllowance -Scope (Get-FanInScope -Checkpoint $Checkpoint) -FilePath $FilePath -Command $Command -StagedIndexReader $Reader)
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

    Context 'Get-EpicMergedFeatureRoots' {
        It 'returns the active and completed roots and the status doc for a <Case> feature_folder' -ForEach @(
            @{ Case = 'bare'; Folder = 'child-a' }
            @{ Case = 'active-prefixed'; Folder = 'docs/features/active/child-a' }
            @{ Case = 'completed-prefixed'; Folder = 'docs/features/completed/child-a' }
        ) {
            $roots = @(Get-EpicMergedFeatureRoots -Checkpoint (Get-RootsCheckpoint -Feature @{ feature_folder = $Folder }))
            $roots | Should -Be @('docs/features/active/child-a/', 'docs/features/completed/child-a/', 'docs/features/epics/sample-epic/epic-status.md')
        }

        It 'qualifies a worktree_removed feature parsed from JSON with a 64-character sha' {
            $json = '{"route_id":"epic","epic_feature_folder":"sample-epic","features":[{"feature_folder":"child-c","merge_status":"worktree_removed","merge_commit_sha":"' + ('cd34' * 16) + '","pr_number":903}]}'
            @(Get-EpicMergedFeatureRoots -Checkpoint ($json | ConvertFrom-Json)) | Should -Contain 'docs/features/completed/child-c/'
        }

        It 'qualifies a [long] pr_number' {
            @(Get-EpicMergedFeatureRoots -Checkpoint (Get-RootsCheckpoint -Feature @{ pr_number = [long]901 })).Count | Should -Be 3
        }

        It 'returns no root when <Case>' -ForEach @(
            @{ Case = 'merge_status is pr_open'; Feature = @{ merge_status = 'pr_open' }; Remove = @() }
            @{ Case = 'merge_status differs in case'; Feature = @{ merge_status = 'MERGED' }; Remove = @() }
            @{ Case = 'the basename has two segments'; Feature = @{ feature_folder = 'child/a' }; Remove = @() }
            @{ Case = 'the basename is ..'; Feature = @{ feature_folder = '..' }; Remove = @() }
            @{ Case = 'the basename is blank'; Feature = @{ feature_folder = '' }; Remove = @() }
            @{ Case = 'the sha is uppercase hex'; Feature = @{ merge_commit_sha = 'AB12' * 10 }; Remove = @() }
            @{ Case = 'the sha has 39 characters'; Feature = @{ merge_commit_sha = 'a' * 39 }; Remove = @() }
            @{ Case = 'the sha has 41 characters'; Feature = @{ merge_commit_sha = 'a' * 41 }; Remove = @() }
            @{ Case = 'the sha has 63 characters'; Feature = @{ merge_commit_sha = 'a' * 63 }; Remove = @() }
            @{ Case = 'the sha is not a string'; Feature = @{ merge_commit_sha = 1234567 }; Remove = @() }
            @{ Case = 'the sha is absent'; Feature = @{}; Remove = @('merge_commit_sha') }
            @{ Case = 'pr_number is a string'; Feature = @{ pr_number = '901' }; Remove = @() }
            @{ Case = 'pr_number is 0'; Feature = @{ pr_number = 0 }; Remove = @() }
            @{ Case = 'pr_number is -1'; Feature = @{ pr_number = -1 }; Remove = @() }
            @{ Case = 'pr_number is null'; Feature = @{ pr_number = $null }; Remove = @() }
            @{ Case = 'pr_number is 7.5'; Feature = @{ pr_number = 7.5 }; Remove = @() }
            @{ Case = 'pr_number is $true'; Feature = @{ pr_number = $true }; Remove = @() }
            @{ Case = 'pr_number is absent'; Feature = @{}; Remove = @('pr_number') }
        ) {
            @(Get-EpicMergedFeatureRoots -Checkpoint (Get-RootsCheckpoint -Feature $Feature -Remove $Remove)).Count | Should -Be 0 -Because $Case
        }

        It 'returns no root for a null checkpoint, absent features, or a null feature entry' {
            @(Get-EpicMergedFeatureRoots -Checkpoint $null).Count | Should -Be 0
            @(Get-EpicMergedFeatureRoots -Checkpoint (Get-FanInCheckpoint -Override @{ features = $null })).Count | Should -Be 0
            @(Get-EpicMergedFeatureRoots -Checkpoint (Get-FanInCheckpoint -Override @{ features = @($null) })).Count | Should -Be 0
        }

        It 'keeps the feature roots but omits the status doc when the epic slug is not plain' {
            $roots = @(Get-EpicMergedFeatureRoots -Checkpoint (Get-RootsCheckpoint -Override @{ epic_feature_folder = '../sample-epic' }))
            $roots | Should -Be @('docs/features/active/child-a/', 'docs/features/completed/child-a/')
        }
    }

    Context 'Test-EpicMergedFeaturePath' {
        It 'admits <Path>' -ForEach @(
            @{ Path = 'docs/features/active/child-a/x.md' }
            @{ Path = 'docs/features/completed/child-a/evidence/other/y.json' }
            @{ Path = 'docs/features/epics/sample-epic/epic-status.md' }
        ) {
            Test-EpicMergedFeaturePath -RelativePath $Path -Root $script:FollowUpRoots | Should -BeTrue
        }

        It 'refuses <Case>' -ForEach @(
            @{ Case = 'the status doc plus a remainder'; Path = 'docs/features/epics/sample-epic/epic-status.md/x' }
            @{ Case = 'a sibling-prefix folder'; Path = 'docs/features/active/child-a-x/y.md' }
            @{ Case = 'the bare root without remainder'; Path = 'docs/features/active/child-a/' }
            @{ Case = 'the root without its trailing slash'; Path = 'docs/features/active/child-a' }
            @{ Case = 'a .. segment'; Path = 'docs/features/active/child-a/../x.md' }
            @{ Case = 'a . segment'; Path = 'docs/features/active/child-a/./x.md' }
            @{ Case = 'a backslash'; Path = 'docs/features/active/child-a' + [string][char]92 + 'x.md' }
            @{ Case = 'a * glob'; Path = 'docs/features/active/child-a/*.md' }
            @{ Case = 'a ? glob'; Path = 'docs/features/active/child-a/x?.md' }
            @{ Case = 'a [ glob'; Path = 'docs/features/active/child-a/[x].md' }
            @{ Case = 'a leading slash'; Path = '/docs/features/active/child-a/x.md' }
            @{ Case = 'a case difference'; Path = 'Docs/features/active/child-a/x.md' }
            @{ Case = 'a blank path'; Path = '' }
            @{ Case = 'code outside every root'; Path = 'scripts/x.ps1' }
        ) {
            Test-EpicMergedFeaturePath -RelativePath $Path -Root $script:FollowUpRoots | Should -BeFalse -Because $Case
        }

        It 'refuses every path when the root list is empty or blank' {
            Test-EpicMergedFeaturePath -RelativePath 'docs/features/active/child-a/x.md' -Root @() | Should -BeFalse
            Test-EpicMergedFeaturePath -RelativePath 'docs/features/active/child-a/x.md' -Root @('') | Should -BeFalse
        }
    }

    Context 'generalized predicates (issue #1141)' {
        It 'Test-EpicFanInCommitShape returns <Expected> for <Text>' -ForEach @(
            @{ Text = 'git add docs/features/active/child-a/x.md docs/features/completed/child-a/y.md'; Expected = 'add' }
            @{ Text = 'git commit -m m -- docs/features/active/child-a/x.md docs/features/epics/sample-epic/epic-status.md'; Expected = 'commit' }
        ) {
            Test-EpicFanInCommitShape -Token ($Text -split ' ') -PathPredicate $script:FollowUpPredicate | Should -BeExactly $Expected
        }

        It 'Test-EpicFanInCommitShape returns null for <Text>' -ForEach @(
            @{ Text = 'git add -A' }
            @{ Text = 'git add' }
            @{ Text = 'git add docs/features/active/child-a/x.md scripts/x.ps1' }
            @{ Text = 'git commit --all -m m' }
            @{ Text = 'git commit --no-verify -m m -- docs/features/active/child-a/x.md' }
            @{ Text = 'git commit -m m --' }
        ) {
            Test-EpicFanInCommitShape -Token ($Text -split ' ') -PathPredicate $script:FollowUpPredicate | Should -BeNullOrEmpty
        }

        It 'Test-EpicFanInStagedIndex is <Expected> when the index <Case>' -ForEach @(
            @{ Case = 'names only allowed paths'; ExitCode = 0; Output = "docs/features/active/child-a/x.md`0docs/features/completed/child-a/y.md`0"; Expected = $true }
            @{ Case = 'mixes an allowed and a disallowed path'; ExitCode = 0; Output = "docs/features/active/child-a/x.md`0scripts/x.ps1`0"; Expected = $false }
            @{ Case = 'is empty'; ExitCode = 0; Output = ''; Expected = $false }
            @{ Case = 'names one blank entry'; ExitCode = 0; Output = "`0"; Expected = $false }
            @{ Case = 'read exits non-zero'; ExitCode = 128; Output = "docs/features/active/child-a/x.md`0"; Expected = $false }
        ) {
            $staged = [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
            Test-EpicFanInStagedIndex -Staged $staged -PathPredicate $script:FollowUpPredicate | Should -Be $Expected -Because $Case
        }
    }

    Context 'Get-EpicMergedFeatureFollowUpAllowance' {
        It 'allows <Case>' -ForEach @(
            @{ Case = 'a relative path leg under the completed root'; FilePath = @('docs/features/completed/child-a/x.json'); Command = '' }
            @{ Case = 'an absolute path leg inside the integration worktree'; FilePath = @('/synthetic-worktrees/epic-integration/docs/features/active/child-a/x.json'); Command = '' }
            @{ Case = 'a git add of an active path'; FilePath = @(''); Command = 'git add docs/features/active/child-a/x.md' }
            @{ Case = 'a pathless commit whose index is under child-a'; FilePath = @(''); Command = 'git commit -m m' }
        ) {
            $result = Get-FollowUpAllowance -FilePath $FilePath -Command $Command
            $result.Allowed | Should -BeTrue -Because "$Case ($($result.Detail))"
        }

        It 'allows a commit with a pathspec without reading the index' {
            (Get-FollowUpAllowance -Command 'git commit -F /scratch/msg.txt -- docs/features/completed/child-a/x.md' -Reader { throw 'the index must not be read' }).Allowed | Should -BeTrue
        }

        It 'refuses <Case>' -ForEach @(
            @{ Case = 'a production path leg'; Override = @{}; Feature = @{}; FilePath = @('scripts/x.ps1'); Command = '' }
            @{ Case = 'route_id parallel'; Override = @{ route_id = 'parallel' }; Feature = @{}; FilePath = @(''); Command = 'git add docs/features/active/child-a/x.md' }
            @{ Case = 'a blank integration_branch'; Override = @{ integration_branch = '' }; Feature = @{}; FilePath = @(''); Command = 'git add docs/features/active/child-a/x.md' }
            @{ Case = 'an integration_branch other than Scope.Branch'; Override = @{ integration_branch = 'epic/other-integration' }; Feature = @{}; FilePath = @(''); Command = 'git add docs/features/active/child-a/x.md' }
            @{ Case = 'no qualifying feature'; Override = @{}; Feature = @{ merge_status = 'pr_open' }; FilePath = @(''); Command = 'git add docs/features/active/child-a/x.md' }
        ) {
            (Get-FollowUpAllowance -Checkpoint (Get-RootsCheckpoint -Feature $Feature -Override $Override) -FilePath $FilePath -Command $Command).Allowed | Should -BeFalse -Because $Case
        }

        It 'refuses a pathless commit when the reader throws' {
            $result = Get-FollowUpAllowance -Command 'git commit -m m' -Reader { throw 'index read failed' }
            $result.Allowed | Should -BeFalse
            $result.Detail | Should -BeLike 'allowance error:*'
        }

        It 'refuses a null scope and a checkpoint whose route_id cannot be read as text' {
            (Get-EpicMergedFeatureFollowUpAllowance -Scope $null -FilePath @('docs/features/active/child-a/x.md') -Command '' -StagedIndexReader $null).Allowed | Should -BeFalse
            $unreadable = [pscustomobject]@{}
            $unreadable | Add-Member -MemberType ScriptMethod -Name ToString -Value { throw 'route_id unreadable' } -Force
            $result = Get-FollowUpAllowance -Checkpoint (Get-RootsCheckpoint -Override @{ route_id = $unreadable }) -FilePath @('docs/features/active/child-a/x.md')
            $result.Allowed | Should -BeFalse
            $result.Detail | Should -BeLike 'allowance error:*'
        }

        It 'reads no per-item checkpoint and touches no file' {
            $text = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot "$HookDirectory/hook-epic-fan-in.ps1")
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref]$null, [ref]$null)
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() })
            $members = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.MemberExpressionAst] }, $true) | ForEach-Object { $_.Member.Extent.Text })
            $text.Contains('orchestrator-state.json') | Should -BeFalse
            $commands | Should -Not -Contain 'Get-Content'
            $commands | Should -Not -Contain 'Test-Path'
            $members | Should -Not -Contain 'ReadAllText'
            $commands | Should -Contain 'Get-EpicFanInPropertyText' -Because 'the scan must see the command calls of the file'
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
