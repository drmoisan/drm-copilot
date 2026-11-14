#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Preimplementation gate post-fan-in allowance rows for the epic integration branch (issue #1136).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision for the writes the epic
    orchestrator and pr-author make on the integration branch after every child feature has
    merged: the pr-author body and receipt under artifacts/, and the epic status document
    commit. The epic checkpoint is fan-in complete (every merge_status merged or
    worktree_removed) and no merge is in progress, so the readiness predicate fails with
    'merge-in-progress'; the allowance admits only the allowlisted operations.

    The fixtures follow enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1: the
    gate is dot-sourced first, EpicScopeResolution.psm1 is imported without -Force, and the
    resolver seams are mocked inside that module. The ascent maps the session root and any
    path under /synthetic-worktrees/epic-coordinator to that root and returns any other
    /synthetic-worktrees/ path unchanged. The staged index is read through the mocked
    Get-OrchestrationGateStagedIndex seam. No row creates a file or changes the working
    directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Mock Get-CheckpointContent { $null }
    Mock Get-EpicCheckpointContent { $null }
    Mock Get-ParallelCheckpointContent { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')

    $script:FanInEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}]}'
    $script:NotReadySingleFeature = '{"issue-num":"1136","route_id":"large","lifecycle_ready":false}'
    $script:IntegrationRoot = '/synthetic-worktrees/epic-coordinator'
    $script:StatusDoc = 'docs/features/epics/sample-epic/epic-status.md'

    function ConvertTo-GateBashPayload {
        # Return a Bash PreToolUse payload carrying one command string.
        param([Parameter(Mandatory)] [string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
    }

    function ConvertTo-GateFilePayload {
        # Return a Write or Edit PreToolUse payload for one file path.
        param([Parameter(Mandatory)] [string] $ToolName, [Parameter(Mandatory)] [string] $FilePath)
        return (@{ tool_name = $ToolName; tool_input = @{ file_path = $FilePath } } | ConvertTo-Json -Depth 5 -Compress)
    }

    function Set-EpicScopeSeam {
        <#
            Mock the resolver seams inside EpicScopeResolution. The bodies close over local
            copies because a module-scoped mock body cannot see this scope otherwise.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [AllowNull()] [string] $CheckpointText,
            [string] $HeadBranch = 'epic/sample-epic-integration',
            [bool] $MergeInProgress = $false
        )
        $text = $CheckpointText
        $head = $HeadBranch
        $merge = $MergeInProgress
        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
            if ($Path -like '/synthetic-worktrees/epic-coordinator*') { return '/synthetic-worktrees/epic-coordinator' }
            if ($Path -like '/synthetic-worktrees/*') { return $Path }
            return '/synthetic-worktrees/epic-coordinator'
        }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $text }.GetNewClosure()
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { $head }.GetNewClosure()
        Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $merge }.GetNewClosure()
    }

    function Set-StagedIndexSeam {
        # Mock the staged-index read with one exit code and output text.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([int] $ExitCode = 0, [AllowEmptyString()] [string] $Output = '')
        $code = $ExitCode
        $text = $Output
        Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = $code; Output = $text } }.GetNewClosure()
    }

    $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
    $script:EpicCheckpointPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'

    function Get-FanInFixtureText {
        # Return the epic checkpoint text of one fixture kind, derived from the fan-in-complete checkpoint.
        param([Parameter(Mandatory)] [string] $Kind)
        if ($Kind -eq 'absent') { return $null }
        if ($Kind -eq 'unparseable') { return '{"route_id":"epic",' }
        $checkpoint = $script:FanInEpicJson | ConvertFrom-Json
        switch ($Kind) {
            'fan-in' { }
            'pr-open' { $checkpoint.features[1].merge_status = 'pr_open' }
            'empty-features' { $checkpoint.features = @() }
            'blank-slug' { $checkpoint.epic_feature_folder = '' }
            'non-plain-slug' { $checkpoint.epic_feature_folder = '../sample-epic' }
            'disagreeing-doc' { $checkpoint | Add-Member -NotePropertyName 'epic_status_doc_path' -NotePropertyValue 'docs/features/epics/other-epic/epic-status.md' }
            'blank-manifest' { $checkpoint.epic_manifest_path = '' }
            default { throw "Unknown fixture kind '$Kind'." }
        }
        return ($checkpoint | ConvertTo-Json -Depth 6 -Compress)
    }

    function Set-StagedIndexFixture {
        # Mock the staged-index read for one fixture kind.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $Kind)
        $nul = [string][char]0
        switch ($Kind) {
            'exact' { Set-StagedIndexSeam -Output ($script:StatusDoc + $nul) }
            'other-epic' { Set-StagedIndexSeam -Output ('docs/features/epics/other-epic/epic-status.md' + $nul) }
            'extra' { Set-StagedIndexSeam -Output ($script:StatusDoc + $nul + 'scripts/powershell/Sample.ps1' + $nul) }
            'empty' { Set-StagedIndexSeam -Output '' }
            'exit-128' { Set-StagedIndexSeam -ExitCode 128 -Output ($script:StatusDoc + $nul) }
            'no-nul' { Set-StagedIndexSeam -Output $script:StatusDoc }
            'throws' { Mock Get-OrchestrationGateStagedIndex { throw 'staged index read failed' } }
            default { throw "Unknown staged-index kind '$Kind'." }
        }
    }

    function Get-EpicScopeDenyReason {
        # Return the unchanged session-root epic-scope deny text for one failed predicate, built by the production outcome function.
        param([Parameter(Mandatory)] [string] $Failure)
        $failed = $Failure
        $verdict = [pscustomobject]@{
            Verdict     = 'evaluate'
            Evaluations = @([pscustomobject]@{ Target = '/synthetic-worktrees/epic-coordinator'; IsSessionRoot = $true; Scope = [pscustomobject]@{ CheckpointPath = $script:EpicCheckpointPath } })
        }
        return (Resolve-OrchestrationEpicTargetOutcome -Verdict $verdict -ReadinessFailure { $failed }.GetNewClosure()).Reason
    }

    Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeRunResolution.psm1')
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    # Issue #1182: the parallel records leg calls these from hook scope, where the module-scoped mocks above do not reach.
    Mock Get-EpicScopeWorktreeHeadBranch { $null }
    Mock Get-WorktreeRunCheckpointText { $null }
    Mock Resolve-WorktreeEpicTarget -ModuleName EpicScopeResolution { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $SessionRoot; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
}

Describe 'preimplementation gate post-fan-in allowance (issue #1136)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'fail-before' {
        It 'allows a Write of artifacts/pr_body_7.receipt.json in epic scope with fan-in complete' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson
            $payload = ConvertTo-GateFilePayload -ToolName 'Write' -FilePath 'artifacts/pr_body_7.receipt.json'

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "the pr-author receipt is allowlisted after fan-in (decision reason: $reason)"
        }

        It 'allows a pathless git commit -m when the staged index is exactly the status doc' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson
            Set-StagedIndexSeam -Output ($script:StatusDoc + [char]0)
            $payload = ConvertTo-GateBashPayload -Command 'git commit -m "docs: update epic status"'

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "a pathless commit of exactly the status document is allowed after fan-in (decision reason: $reason)"
        }
    }

    Context 'allows' {
        It 'allows a <Case>' -ForEach @(
            @{ Case = 'receipt Write with a relative path'; Tool = 'Write'; Operand = 'artifacts/pr_body_7.receipt.json' }
            @{ Case = 'receipt Write with an absolute path into the integration worktree'; Tool = 'Write'; Operand = '/synthetic-worktrees/epic-coordinator/artifacts/pr_body_7.receipt.json' }
            @{ Case = 'Write of artifacts/pr_body_7.md'; Tool = 'Write'; Operand = 'artifacts/pr_body_7.md' }
            @{ Case = 'git add of the status doc'; Tool = 'Bash'; Operand = 'git add docs/features/epics/sample-epic/epic-status.md' }
            @{ Case = 'git -C absolute-root commit -m with the staged index exactly the status doc'; Tool = 'Bash'; Operand = 'git -C /synthetic-worktrees/epic-coordinator commit -m status' }
            @{ Case = 'git commit -F with no pathspec and the staged index exactly the status doc'; Tool = 'Bash'; Operand = 'git commit -F /scratch/msg.txt' }
            @{ Case = 'git commit -F with the status doc pathspec'; Tool = 'Bash'; Operand = 'git commit -F /scratch/msg.txt -- docs/features/epics/sample-epic/epic-status.md' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson
            Set-StagedIndexSeam -Output ($script:StatusDoc + [char]0)
            $payload = if ($Tool -eq 'Bash') { ConvertTo-GateBashPayload -Command $Operand } else { ConvertTo-GateFilePayload -ToolName $Tool -FilePath $Operand }

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "$Case is a sanctioned post-fan-in write (decision reason: $reason)"
        }
    }

    Context 'denies with unchanged text' {
        It 'denies <Case> naming <Failure>' -ForEach @(
            @{ Case = 'a receipt Write when a feature is pr_open'; Checkpoint = 'pr-open'; Tool = 'Write'; Operand = 'artifacts/pr_body_7.receipt.json'; Index = 'exact'; Failure = 'merge-in-progress' }
            @{ Case = 'a receipt Write when features is empty'; Checkpoint = 'empty-features'; Tool = 'Write'; Operand = 'artifacts/pr_body_7.receipt.json'; Index = 'exact'; Failure = 'features' }
            @{ Case = 'a Write of artifacts/pr_body_7.json'; Checkpoint = 'fan-in'; Tool = 'Write'; Operand = 'artifacts/pr_body_7.json'; Index = 'exact'; Failure = 'merge-in-progress' }
            @{ Case = 'a Write of a production script'; Checkpoint = 'fan-in'; Tool = 'Write'; Operand = 'scripts/powershell/Sample.ps1'; Index = 'exact'; Failure = 'merge-in-progress' }
            @{ Case = 'a pathless commit whose staged index is another slug status doc'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'other-epic'; Failure = 'merge-in-progress' }
            @{ Case = 'a pathless commit whose staged index has an extra path'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'extra'; Failure = 'merge-in-progress' }
            @{ Case = 'a pathless commit whose staged index is empty'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'empty'; Failure = 'merge-in-progress' }
            @{ Case = 'a pathless commit whose staged index read exits non-zero'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'exit-128'; Failure = 'merge-in-progress' }
            @{ Case = 'a pathless commit whose staged index is not NUL-terminated'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'no-nul'; Failure = 'merge-in-progress' }
            @{ Case = 'a pathless commit whose staged index read throws'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'throws'; Failure = 'merge-in-progress' }
            @{ Case = 'a commit carrying --amend'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit --amend -m status'; Index = 'exact'; Failure = 'merge-in-progress' }
            @{ Case = 'a commit carrying -a'; Checkpoint = 'fan-in'; Tool = 'Bash'; Operand = 'git commit -a -m status'; Index = 'exact'; Failure = 'merge-in-progress' }
            @{ Case = 'a receipt Write when epic_feature_folder is blank'; Checkpoint = 'blank-slug'; Tool = 'Write'; Operand = 'artifacts/pr_body_7.receipt.json'; Index = 'exact'; Failure = 'epic_feature_folder' }
            @{ Case = 'a pathless commit when epic_feature_folder is not a plain segment'; Checkpoint = 'non-plain-slug'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'exact'; Failure = 'merge-in-progress' }
            @{ Case = 'a pathless commit when epic_status_doc_path disagrees'; Checkpoint = 'disagreeing-doc'; Tool = 'Bash'; Operand = 'git commit -m status'; Index = 'exact'; Failure = 'merge-in-progress' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FanInFixtureText -Kind $Checkpoint)
            Set-StagedIndexFixture -Kind $Index
            $payload = if ($Tool -eq 'Bash') { ConvertTo-GateBashPayload -Command $Operand } else { ConvertTo-GateFilePayload -ToolName $Tool -FilePath $Operand }

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeExactly (Get-EpicScopeDenyReason -Failure $Failure) -Because 'the epic-scope deny text is unchanged'
        }

        It 'denies a receipt Write when the readiness failure is epic_manifest_path rather than merge-in-progress' {
            # Arrange: fan-in complete with slug sample-epic, but a blank epic_manifest_path.
            Set-EpicScopeSeam -CheckpointText (Get-FanInFixtureText -Kind 'blank-manifest')
            $payload = ConvertTo-GateFilePayload -ToolName 'Write' -FilePath 'artifacts/pr_body_7.receipt.json'

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

            # Assert: the allowance applies only to the exact merge-in-progress failure.
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-EpicScopeDenyReason -Failure 'epic_manifest_path')
        }
    }

    Context 'outside epic scope' {
        It 'returns the unchanged single-feature deny for a receipt Write when <Case>' -ForEach @(
            @{ Case = 'HEAD is not the integration_branch'; Kind = 'fan-in'; Head = 'feature/standalone-item' }
            @{ Case = 'the epic checkpoint is missing'; Kind = 'absent'; Head = 'epic/sample-epic-integration' }
            @{ Case = 'the epic checkpoint is unparseable'; Kind = 'unparseable'; Head = 'epic/sample-epic-integration' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FanInFixtureText -Kind $Kind) -HeadBranch $Head
            $payload = ConvertTo-GateFilePayload -ToolName 'Write' -FilePath 'artifacts/pr_body_7.receipt.json'

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
        }
    }

    Context 'regeneration allowance without a config (issue #1156)' {
        It 'decides <Case> the same with no regeneration config as with the allowance mocked to not allowed' -ForEach @(
            @{ Case = 'the fan-in status-document add'; Tool = 'Bash'; Value = 'git add docs/features/epics/sample-epic/epic-status.md' }
            @{ Case = 'the fan-in status-document commit'; Tool = 'Bash'; Value = 'git commit -m status' }
            @{ Case = 'a merged-feature follow-up Write'; Tool = 'Write'; Value = 'docs/features/active/2026-09-25-child-a-901/notes.md' }
            @{ Case = 'a code-path Write'; Tool = 'Write'; Value = 'src/code.ps1' }
            @{ Case = 'a chained command'; Tool = 'Bash'; Value = 'git add -- gen/a.json && git commit -m regen' }
            @{ Case = 'a bare git commit -a'; Tool = 'Bash'; Value = 'git commit -a -m regen' }
        ) {
            # Arrange: no config file exists beneath the integration worktree.
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson
            Set-StagedIndexSeam -Output ($script:StatusDoc + [char]0)
            Mock Test-Path { $false } -ParameterFilter { [string]$LiteralPath -like '*/config/orchestration-regeneration.json' }
            $payload = if ($Tool -eq 'Bash') { ConvertTo-GateBashPayload -Command $Value } else { ConvertTo-GateFilePayload -ToolName $Tool -FilePath $Value }

            # Act
            $withoutConfig = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature
            Mock Get-EpicRegenerationAllowance { [pscustomobject]@{ Allowed = $false; Detail = 'mocked not allowed' } }
            $mockedOff = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            [string]$withoutConfig.hookSpecificOutput.permissionDecision | Should -BeExactly ([string]$mockedOff.hookSpecificOutput.permissionDecision)
            [string]$withoutConfig.hookSpecificOutput.permissionDecisionReason | Should -BeExactly ([string]$mockedOff.hookSpecificOutput.permissionDecisionReason)
        }
    }

    Context 'regeneration allowance wiring (issue #1156)' {
        BeforeAll {
            $script:EpicScopeAst = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:HookRoot 'hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1'), [ref]$null, [ref]$null)

            function Get-AstArgumentText {
                # Return the extent text of the argument that follows a named parameter of a command.
                param([Parameter(Mandatory)] $CommandAst, [Parameter(Mandatory)] [string] $Name)
                $elements = @($CommandAst.CommandElements)
                for ($i = 0; $i -lt $elements.Count - 1; $i++) {
                    if ($elements[$i] -is [System.Management.Automation.Language.CommandParameterAst] -and $elements[$i].ParameterName -ceq $Name) { return $elements[$i + 1].Extent.Text }
                }
                return $null
            }
        }

        It 'admits git add -- gen/a.json under merge-in-progress when the allowance reports Allowed, passing the leg arguments' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson
            Mock Get-EpicRegenerationAllowance { [pscustomobject]@{ Allowed = $true; Detail = 'mocked allowed' } }

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-GateBashPayload -Command 'git add -- gen/a.json') -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because ([string]$decision.hookSpecificOutput.permissionDecisionReason)
            Should -Invoke Get-EpicRegenerationAllowance -Times 1 -Exactly -ParameterFilter { $ConfigReader -is [scriptblock] -and $StagedIndexReader -is [scriptblock] }
            Should -Invoke Get-EpicRegenerationAllowance -Times 1 -Exactly -ParameterFilter {
                $Command -ceq 'git add -- gen/a.json' -and @($FilePath).Count -eq 1 -and [string]@($FilePath)[0] -ceq '' -and
                $Scope.Branch -ceq 'epic/sample-epic-integration' -and $Scope.WorktreeRoot -ceq '/synthetic-worktrees/epic-coordinator'
            }
        }

        It 'denies a matching regeneration commit with the unchanged reason when the readiness failure is not merge-in-progress' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FanInFixtureText -Kind 'blank-manifest')
            Mock Get-EpicRegenerationAllowance { [pscustomobject]@{ Allowed = $true; Detail = 'mocked allowed' } }

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-GateBashPayload -Command 'git commit -m regen -- gen/a.json') -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-EpicScopeDenyReason -Failure 'epic_manifest_path')
            Should -Invoke Get-EpicRegenerationAllowance -Times 0 -Exactly
        }

        It 'holds exactly one guarded dot-source of hook-epic-regeneration.ps1 after the fan-in dot-source and before the first function' {
            # Arrange
            $statements = @($script:EpicScopeAst.EndBlock.Statements)
            $index = @(for ($i = 0; $i -lt $statements.Count; $i++) { if ($statements[$i] -is [System.Management.Automation.Language.TryStatementAst] -and $statements[$i].Body.Extent.Text.Contains('hook-epic-regeneration.ps1')) { $i } })
            $fanIn = @(for ($i = 0; $i -lt $statements.Count; $i++) { if ($statements[$i] -is [System.Management.Automation.Language.TryStatementAst] -and $statements[$i].Body.Extent.Text.Contains('hook-epic-fan-in.ps1')) { $i } })
            $firstFunction = @(for ($i = 0; $i -lt $statements.Count; $i++) { if ($statements[$i] -is [System.Management.Automation.Language.FunctionDefinitionAst]) { $i } })[0]

            # Assert
            $index.Count | Should -Be 1
            $try = $statements[$index[0]]
            ($try.Body.Statements[0].Extent.Text -replace '\s+', ' ') | Should -BeExactly ". (Join-Path `$PSScriptRoot 'hook-epic-regeneration.ps1')"
            ($try.CatchClauses[0].Body.Extent.Text -replace '\s+', ' ') | Should -BeExactly "{ Add-HookDependencyFailure -Name 'hook-epic-regeneration.ps1' -ErrorRecord `$_ }"
            $index[0] | Should -BeGreaterThan $fanIn[0]
            $index[0] | Should -BeLessThan $firstFunction
        }

        It 'calls Get-EpicRegenerationAllowance once in Get-OrchestrationEpicScopeDecision under the exact merge-in-progress guard' {
            # Arrange
            $function = $script:EpicScopeAst.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Get-OrchestrationEpicScopeDecision' }, $true)
            $calls = @($script:EpicScopeAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq 'Get-EpicRegenerationAllowance' }, $true))
            $readerAssignment = $function.Find({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and $node.Left.Extent.Text -ceq '$reader' }, $true)

            # Assert
            $calls.Count | Should -Be 1
            $call = $calls[0]
            ($call.Extent.StartOffset -gt $function.Extent.StartOffset -and $call.Extent.EndOffset -lt $function.Extent.EndOffset) | Should -BeTrue
            $guard = $call.Parent
            while ($null -ne $guard -and $guard -isnot [System.Management.Automation.Language.IfStatementAst]) { $guard = $guard.Parent }
            $guard.Clauses[0].Item1.Extent.Text.Contains("`$failure -ceq 'merge-in-progress'") | Should -BeTrue
            $call.Extent.StartOffset | Should -BeGreaterThan $readerAssignment.Extent.EndOffset
            Get-AstArgumentText -CommandAst $call -Name 'ConfigReader' | Should -BeExactly '${function:Read-EpicRegenerationConfig}'
            Get-AstArgumentText -CommandAst $call -Name 'StagedIndexReader' | Should -BeExactly '$reader'
            Get-AstArgumentText -CommandAst $call -Name 'Scope' | Should -BeExactly '$Scope'
            Get-AstArgumentText -CommandAst $call -Name 'FilePath' | Should -BeExactly '@($FilePath)'
            Get-AstArgumentText -CommandAst $call -Name 'Command' | Should -BeExactly '$epicScopeText'
        }
    }
}
