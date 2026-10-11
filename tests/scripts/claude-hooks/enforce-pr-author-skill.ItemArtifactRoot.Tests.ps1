#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    pr-author gate reads PR artifacts beneath the resolved worktree (issue #850).

.DESCRIPTION
    Covers the artifact root the gate resolves once per call: the context summary, the body,
    the receipt, and the summary timestamp are read beneath the resolved item worktree (or
    the epic checkpoint's worktree under epic scope); an unresolvable or ambiguous target
    denies ahead of PR_CONTEXT_MISSING; and the Check 1 binding accepts a relative body path
    only for the session worktree and an absolute one only beneath the resolved root, with
    drive-letter and UNC paths compared case-insensitively and POSIX paths case-sensitively.

    Every row enters through Invoke-PrAuthorSkillDecision. Rows 1 and 2 read committed
    fixture bytes with an explicit working directory; every other row mocks the four
    artifact seams and records the paths they receive. The orchestrator-state preflight
    passes and the Check 6 checkpoint seam returns $null unless a row states otherwise. No
    row creates, writes, or deletes a file, reads a wall clock, or touches the network.
#>

BeforeAll {
    # The hook is dot-sourced first; the library modules are imported without -Force so the
    # suite binds to the instances the hook already loaded, and both epic-state reads are
    # isolated from any gitignored local checkpoint.
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-pr-author-skill.ps1')
    $script:RealGetPrAuthorReceiptContent = ${function:Get-PrAuthorReceiptContent}
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
    Mock Get-PrAuthorReceiptContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeRunResolution.psm1')
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:SessionRootDir = Get-WorktreeResolutionFixturePath 'pr-author/session-root'
    $script:OwnReady = Get-WorktreeResolutionFixturePath 'pr-author/item-own-ready'
    $script:OwnNotReady = Get-WorktreeResolutionFixturePath 'pr-author/item-own-not-ready'
    $script:ItemRoot = '/synthetic-worktrees/item-a'
    $script:ItemBodyCommand = 'gh pr create --head f5-fixture-own --title "B" --body-file /synthetic-worktrees/item-a/artifacts/pr_body_1.md'
    $script:ItemCheckpointPath = '/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json'

    Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $false; ErrorText = '' } }
    Mock Get-PrAuthorCheckpointContent { $null }

    # Return a Bash PreToolUse payload carrying one command string.
    function New-BashPayload {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory payload factory in a test file; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $Command)
        return (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
    }

    # Mock the hook's resolution seam with a finished target object.
    function Set-ResolvedSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $Status, [string] $WorktreeRoot, [string[]] $Candidate = @())
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $WorktreeRoot -Candidate $Candidate
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith { return $target }.GetNewClosure()
    }

    # Mock the four artifact seams; each records the path it receives in $script:CapturedPaths.
    function Set-ArtifactSeamCapture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param()
        $script:CapturedPaths = [System.Collections.Generic.List[string]]::new()
        $captured = $script:CapturedPaths
        Mock -CommandName Get-PrContextArtifactExistence -MockWith { param($Path) $captured.Add($Path); $true }.GetNewClosure()
        Mock -CommandName Get-PrBodyFileBytes -MockWith { param($BodyFilePath) $captured.Add($BodyFilePath); , [byte[]] @(0x41) }.GetNewClosure()
        Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
            param($ReceiptFilePath)
            $captured.Add($ReceiptFilePath)
            '{"number":1,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-27T12:00:00Z"}'
        }.GetNewClosure()
        Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { param($Path) $captured.Add($Path); [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }.GetNewClosure()
    }

    # A finished epic-scope result whose checkpoint path is supplied by the row.
    function Set-EpicScopeSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $CheckpointPath)
        $scope = [pscustomobject]@{
            IsEpicScope    = $true
            CheckpointPath = $CheckpointPath
            Checkpoint     = [pscustomobject]@{ route_id = 'epic' }
            WorktreeRoot   = '/synthetic-worktrees/session'
            Branch         = 'epic/x-integration'
        }
        Mock -CommandName Resolve-EpicScopeCheckpoint -MockWith { $scope }.GetNewClosure()
        Mock -CommandName Get-EpicPrCreationReadinessFailure -MockWith { $null }
        Mock -CommandName Test-EpicBaseBranchOverride -MockWith { $null }
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith { throw 'epic scope must not resolve an item target' }
    }
}

Describe 'enforce-pr-author-skill.ps1 item artifact root' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'allows an OtherWorktree target whose artifacts exist only in the item worktree' {
        # Arrange: the process runs in a worktree without artifacts; the resolved one holds them.
        Mock Get-PrAuthorReceiptContent -MockWith $script:RealGetPrAuthorReceiptContent
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:OwnReady
        $payload = New-BashPayload -Command "gh pr create --head f5-fixture-own --title ""B"" --body-file $($script:OwnReady)/artifacts/pr_body_1.md"

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:OwnNotReady -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'ignores session-root PR artifacts when the target is another worktree' {
        # Arrange: the session root holds artifacts; the resolved worktree holds none.
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:OwnNotReady
        $payload = New-BashPayload -Command "gh pr create --head f5-fixture-own --title ""B"" --body-file $($script:OwnNotReady)/artifacts/pr_body_1.md"
        $expectedRoot = ConvertTo-WorktreeResolutionNormalizedPath -Path $script:OwnNotReady

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }
        $reason = $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $reason | Should -BeLike 'PR_CONTEXT_MISSING*'
        $reason.Contains($expectedRoot) | Should -BeTrue -Because 'the deny names the worktree the summary was looked for in'
    }

    It 'reads summary, body, receipt and summary timestamp beneath the resolved item root' {
        # Arrange
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:ItemRoot
        Set-ArtifactSeamCapture

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command $script:ItemBodyCommand)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-PrContextArtifactExistence -Times 1
        Should -Invoke Get-PrBodyFileBytes -Times 1
        Should -Invoke Get-PrAuthorReceiptContent -Times 1
        Should -Invoke Get-PrContextSummaryLastWriteUtc -Times 1
        foreach ($path in $script:CapturedPaths) {
            $path.StartsWith('/synthetic-worktrees/item-a/artifacts/') | Should -BeTrue -Because "every artifact read is beneath the item root ($path)"
        }
    }

    It 'compares receipt freshness against the item worktree summary' {
        # Arrange: only the item worktree's summary is newer than the receipt.
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:ItemRoot
        Set-ArtifactSeamCapture
        Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith {
            param($Path)
            if ($Path -like '/synthetic-worktrees/item-a/*') { return [DateTime]::Parse('2026-06-27T13:00:00Z').ToUniversalTime() }
            return [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime()
        }

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command $script:ItemBodyCommand)

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_RECEIPT_STALE*'
        Should -Invoke Get-PrContextSummaryLastWriteUtc -Times 1 -Exactly -ParameterFilter { $Path -like '/synthetic-worktrees/item-a/*' }
    }

    It 'resolves the target once and reuses it for artifacts, preflight and Check 6' {
        # Arrange
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:ItemRoot
        Set-ArtifactSeamCapture
        $script:CapturedPreflightPath = $null
        $script:CapturedEpicPath = $null
        Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
            param([string] $CheckpointPath)
            $script:CapturedPreflightPath = $CheckpointPath
            return @{ HasErrors = $false; ErrorText = '' }
        }
        Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
            param([string] $CheckpointPath)
            $script:CapturedEpicPath = $CheckpointPath
            return $null
        }

        # Act
        $null = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command $script:ItemBodyCommand)

        # Assert
        Should -Invoke Resolve-PrAuthorWorktreeTarget -Times 1 -Exactly
        $script:CapturedPreflightPath | Should -Be $script:ItemCheckpointPath
        $script:CapturedEpicPath | Should -Be $script:ItemCheckpointPath
        $script:CapturedPaths | Should -Contain '/synthetic-worktrees/item-a/artifacts/pr_context.summary.txt'
    }

    It 'denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING' {
        # Arrange
        Set-ResolvedSeam -Status 'NoTarget'
        Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
        Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { throw 'the preflight must not be reached' }

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command $script:ItemBodyCommand)

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
        Should -Invoke Invoke-OrchestratorStatePreflight -Times 0 -Exactly
    }

    It 'denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING' {
        # Arrange
        Set-ResolvedSeam -Status 'Ambiguous' -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
        Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { throw 'the preflight must not be reached' }

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command $script:ItemBodyCommand)

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:AmbiguityCode)
        Should -Invoke Invoke-OrchestratorStatePreflight -Times 0 -Exactly
    }

    It 'denies a relative body path for an OtherWorktree target and names the absolute path' {
        # Arrange
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:ItemRoot
        Set-ArtifactSeamCapture

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --head f5-fixture-own --title "B" --body-file artifacts/pr_body_1.md')
        $reason = $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
        $reason.Contains('/synthetic-worktrees/item-a/artifacts/pr_body_1.md') | Should -BeTrue -Because 'the deny names the absolute canonical path'
    }

    It 'denies an absolute body path outside the resolved root' {
        # Arrange
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:ItemRoot
        Set-ArtifactSeamCapture

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --head f5-fixture-own --title "B" --body-file /synthetic-worktrees/session/artifacts/pr_body_1.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
    }

    It 'applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison' {
        # Arrange, act, and assert once per root spelling.
        $cases = @(
            @{ Root = 'C:/Repo/Item-A'; Body = 'c:/repo/item-a/artifacts/pr_body_1.md'; Expected = 'allow' }
            @{ Root = '//Server/Share/Item'; Body = '//server/share/ITEM/artifacts/pr_body_1.md'; Expected = 'allow' }
            @{ Root = '/synthetic-worktrees/Item-A'; Body = '/synthetic-worktrees/item-a/artifacts/pr_body_1.md'; Expected = 'deny' }
        )
        foreach ($case in $cases) {
            Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $case.Root
            Set-ArtifactSeamCapture
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command "gh pr create --head f5-fixture-own --title ""B"" --body-file $($case.Body)")
            $decision.hookSpecificOutput.permissionDecision | Should -Be $case.Expected -Because "root '$($case.Root)' against body '$($case.Body)'"
            if ($case.Expected -eq 'deny') {
                $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
            }
        }
    }

    It 'keeps SessionRoot behavior with absolute artifact paths' {
        # Arrange
        Set-ResolvedSeam -Status 'SessionRoot' -WorktreeRoot '/synthetic-worktrees/session'
        Set-ArtifactSeamCapture

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --head f5-fixture-own --title "B" --body-file artifacts/pr_body_1.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:CapturedPaths.Count | Should -BeGreaterThan 0
        foreach ($path in $script:CapturedPaths) {
            $path.StartsWith('/synthetic-worktrees/session/artifacts/') | Should -BeTrue -Because "every artifact read is beneath the session root ($path)"
        }
    }

    It 'reads epic-scope PR artifacts beneath the epic checkpoint worktree' {
        # Arrange
        Set-EpicScopeSeam -CheckpointPath '/synthetic-worktrees/epic-wt/artifacts/orchestration/epic-orchestrator-state.json'
        Set-ArtifactSeamCapture

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --head epic/x-integration --base main --title "E" --body-file /synthetic-worktrees/epic-wt/artifacts/pr_body_1.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:CapturedPaths.Count | Should -BeGreaterThan 0
        foreach ($path in $script:CapturedPaths) {
            $path.StartsWith('/synthetic-worktrees/epic-wt/artifacts/') | Should -BeTrue -Because "every artifact read is beneath the epic worktree ($path)"
        }
        Should -Invoke Resolve-PrAuthorWorktreeTarget -Times 0 -Exactly
    }

    It 'performs no resolution for commands without a body file' {
        # Arrange
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith { throw 'no resolution expected' }
        Mock -CommandName Resolve-EpicScopeCheckpoint -MockWith { throw 'no resolution expected' }

        # Act
        $inline = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --body "x"')
        $noBody = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --title x')
        $edit = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr edit 5 --title x')

        # Assert
        $inline.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $noBody.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $edit.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-PrAuthorWorktreeTarget -Times 0 -Exactly
        Should -Invoke Resolve-EpicScopeCheckpoint -Times 0 -Exactly
    }

    It 'denies when the epic checkpoint path does not end with the epic checkpoint suffix' {
        # Arrange
        Set-EpicScopeSeam -CheckpointPath '/synthetic-worktrees/epic-wt/elsewhere.json'
        Set-ArtifactSeamCapture

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --head epic/x-integration --base main --title "E" --body-file /synthetic-worktrees/epic-wt/artifacts/pr_body_1.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
    }

    It 'denies a body-file value that names no pr_body file' {
        # Arrange
        Set-ResolvedSeam -Status 'SessionRoot' -WorktreeRoot '/synthetic-worktrees/session'
        Set-ArtifactSeamCapture

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (New-BashPayload -Command 'gh pr create --head f5-fixture-own --title "B" --body-file artifacts/notes.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
    }
}
