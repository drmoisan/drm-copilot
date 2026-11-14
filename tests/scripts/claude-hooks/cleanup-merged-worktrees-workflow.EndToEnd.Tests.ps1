#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end composition of the cleanup-merged-worktrees workflow over the hook decisions (issue #1026).

.DESCRIPTION
    One in-memory scenario with no orchestrator-state.json anywhere: a porcelain listing with the
    main worktree at the session root, the consolidation worktree on branch
    documentationandmemories, and one SAFE_TO_DELETE worktree; a fresh valid manifest that
    authorizes the removal of that worktree; an allowlisted staged index and branch diff; and the
    body and receipt bytes of the consolidation pull request. Every checkpoint seam returns
    nothing.

    The five gates that read a checkpoint or the manifest for these calls are composed:
    enforce-orchestration-preimplementation-gate.ps1, enforce-model-routing-receipt.ps1,
    enforce-pr-author-skill.ps1, enforce-parallel-worktree-removal-gate.ps1, and
    enforce-epic-worktree-removal-gate.ps1. They are loaded once in the outermost BeforeAll, which
    the epic-state isolation guard requires so that every read seam of the loaded closure is
    null-mocked there; the five hooks define no function name with two different bodies and
    share their script-scope literals, so one scope composes them. Each Context arranges one
    workflow step and asserts the decision of every composed hook registered for that tool call.
    The inventory row reads .claude/settings.json and fails when a hook registered for the Bash,
    Write, Edit, or Agent matchers is neither composed nor listed in the exemption table with a
    reason; the exempted hooks are covered by the post-merge live run.

    No row creates a file, starts a process, reads a clock, or touches the network.
#>

BeforeAll {
    $hookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    . (Join-Path $hookRoot 'enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $hookRoot 'enforce-model-routing-receipt.ps1')
    . (Join-Path $hookRoot 'enforce-pr-author-skill.ps1')
    . (Join-Path $hookRoot 'enforce-parallel-worktree-removal-gate.ps1')
    . (Join-Path $hookRoot 'enforce-epic-worktree-removal-gate.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicWorktreeGateCheckpointContent { $null } }
    if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicWorktreeGateParallelCheckpointContent { $null } }
    if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelWorktreeRemovalGateCheckpointContent { $null } }
    if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelWorktreeRemovalGateEpicCheckpointContent { $null } }
    Mock Get-WorktreeRunMainCheckoutRoot { $null }
    Mock Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution { $null }
    Mock Get-ModelRoutingCheckpoint { $null }
    Mock Get-PrAuthorCheckpointContent { $null }
    Mock Get-PrAuthorReceiptContent { $null }
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { '/synthetic-worktrees/main' }
    Mock Resolve-EpicWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/main'; ReasonCode = $null; Detail = 'synthetic session root (issue #1026)' } }
    Mock Resolve-ParallelWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/main'; ReasonCode = $null; Detail = 'synthetic session root (issue #1026)' } }

    # The scenario, defined once.
    $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:Consolidation = '/synthetic-worktrees/documentationandmemories'
    $script:SafeToDelete = '/synthetic-worktrees/stale-item'
    $script:Nul = [string][char]0
    $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Consolidation)`nbranch refs/heads/documentationandmemories`n`nworktree $($script:SafeToDelete)`nbranch refs/heads/bug/stale-item`n"
    $script:ManifestJson = '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"cleanup-run-1026","removals":[{"worktree_path":"/synthetic-worktrees/stale-item","branch":"bug/stale-item","branch_state":"HAS_UNIQUE_RESIDUALS","removal_disposition":"SAFE_TO_DELETE","verdict":"ALREADY_SOLVED_ELSEWHERE","evidence":"The residual commit is already fixed on main."}],"preserved_files":[]}'
    $script:Now = [datetime]::new(2026, 11, 3, 12, 0, 0, [System.DateTimeKind]::Utc)
    $script:StagedPaths = "docs/research/cleanup-notes.md$($script:Nul).claude/agent-memory/atomic-executor/lesson.md$($script:Nul)"
    $script:BranchDiff = $script:StagedPaths
    $script:BodyBytes = [byte[]] @(0x41)
    $script:Receipt = '{"skill":"pr-author","pr_body_path":"artifacts/pr_body_7.md","number":7,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","context_summary_path":"artifacts/pr_context.summary.txt","created_at":"2026-11-03T11:30:00Z"}'
    $script:Script = 'bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh'

    # Every hook registered for the Bash, Write, Edit, or Agent matchers that this suite does not
    # compose, with the reason it is outside the cleanup legs.
    $script:ComposedHook = @('enforce-orchestration-preimplementation-gate.ps1', 'enforce-model-routing-receipt.ps1', 'enforce-pr-author-skill.ps1', 'enforce-parallel-worktree-removal-gate.ps1', 'enforce-epic-worktree-removal-gate.ps1')
    $script:ExemptHook = [ordered]@{
        'validate-bash.ps1'                      = 'blocks dangerous Bash patterns; the workflow commands carry none and it reads no checkpoint'
        'enforce-promotion-mcp-only.ps1'         = 'blocks promotion-script bypass commands; the workflow runs none'
        'enforce-epic-merge-gate.ps1'            = 'gates pull-request merges; the workflow creates a pull request and does not merge one'
        'enforce-docs-complete-gate.ps1'         = 'gates integration pull-request merges on a docs receipt; the workflow creates a pull request and does not merge one'
        'enforce-parallel-abandon-gate.ps1'      = 'gates the parallel abandon disposition; the workflow runs none'
        'check-python-test-purity.ps1'           = 'inspects Python unit-test files; the workflow writes none'
        'enforce-python-batch-budget.ps1'        = 'counts production Python files in a worktree; the workflow writes none'
        'check-powershell-test-purity.ps1'       = 'inspects Pester test files; the workflow writes none'
        'enforce-powershell-batch-budget.ps1'    = 'counts production PowerShell files inside a worktree; a scratch file outside every worktree root consumes no slot'
        'enforce-evidence-locations.ps1'         = 'blocks non-canonical evidence locations; the workflow writes no evidence artifact'
        'enforce-file-size-limit.ps1'            = 'blocks files above 800 lines; the manifest, receipt, and notes are small'
        'enforce-feature-folder-order.ps1'       = 'orders feature-folder plan writes; the workflow writes no plan'
        'enforce-checkpoint-monotonic.ps1'       = 'guards orchestrator checkpoint writes; the manifest is not a checkpoint'
        'enforce-completion-consistency.ps1'     = 'guards orchestrator checkpoint writes; the workflow writes no checkpoint'
        'enforce-mermaid-validation.ps1'         = 'validates Mermaid diagrams in written content; content-only'
        'enforce-discovery-artifact-gate.ps1'    = 'authorizes discovery agents; the workflow is not a discovery run'
        'enforce-prd-feature-before-planner.ps1' = 'gates atomic-planner delegations; the workflow delegates only pr-author'
        'enforce-discovery-planning-gate.ps1'    = 'gates planner and orchestrator delegations; the workflow delegates only pr-author'
        'enforce-epic-wave-barrier.ps1'          = 'gates epic wave delegations; the workflow is not an epic run'
        'enforce-epic-invocation-origin.ps1'     = 'gates epic-planner and epic-orchestrator invocations; the workflow invokes neither'
        'enforce-parallel-cohort-barrier.ps1'    = 'gates parallel cohort delegations; the workflow is not a parallel run'
        'enforce-parallel-drift-gate.ps1'        = 'gates parallel delegations; the workflow is not a parallel run'
        'enforce-docs-role-write-scope.ps1'      = 'acts only for the four documentation roles; the workflow runs in the main session, which carries no agent_type'
        'enforce-worktree-poetry-venv.ps1'       = 'denies mutating Poetry commands aimed at an outside VIRTUAL_ENV; the workflow runs no Poetry command'
        'enforce-owner-directive-pass-down.ps1'  = 'acts only for worker agent types and for delegations to workers or orchestrator; the workflow delegates only pr-author from the main session'
    }

    function ConvertTo-WorkflowPayload {
        param([string] $Tool, [hashtable] $ToolInput)
        return (@{ tool_name = $Tool; tool_input = $ToolInput } | ConvertTo-Json -Compress -Depth 5)
    }

    # Return the decision of every composed hook registered for a Bash call, keyed by hook.
    function Get-BashWorkflowDecision {
        param([string] $Command)
        $payload = ConvertTo-WorkflowPayload -Tool 'Bash' -ToolInput @{ command = $Command }
        return [ordered]@{
            'enforce-orchestration-preimplementation-gate.ps1' = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
            'enforce-pr-author-skill.ps1'                      = (Invoke-PrAuthorSkillDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
            'enforce-parallel-worktree-removal-gate.ps1'       = (Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
            'enforce-epic-worktree-removal-gate.ps1'           = (Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
        }
    }

    function Assert-AllAllowed {
        param([System.Collections.IDictionary] $Decision)
        foreach ($hook in $Decision.Keys) { $Decision[$hook] | Should -Be 'allow' -Because "$hook must allow this workflow step" }
    }

    # Register the scenario seams of the preimplementation gate, the PR-author gate, and the
    # model-routing gate. The removal gates read the manifest inside CleanupWorktreeManifest, so
    # their manifest and clock mocks are module-scoped and built from literals.
    function Set-WorkflowScenario {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one block only; it changes no system state.')]
        param()
        $listing = $script:Listing
        $staged = [pscustomobject]@{ ExitCode = 0; Output = $script:StagedPaths }
        $diff = [pscustomobject]@{ ExitCode = 0; Output = $script:BranchDiff }
        $manifest = $script:ManifestJson
        $now = $script:Now
        $receipt = $script:Receipt
        $target = [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $script:Consolidation; ReasonCode = $null; Detail = 'synthetic consolidation worktree' }
        Mock Get-OrchestrationGateWorktreeList { $listing }.GetNewClosure()
        Mock Get-OrchestrationGateTemporaryRoot { , [string[]] @('/synthetic-users/LONGUS~1/AppData/Local/Temp/') }
        Mock Get-OrchestrationGateStagedIndex { $staged }.GetNewClosure()
        Mock Get-CleanupWorktreeManifestContent { $manifest }.GetNewClosure()
        Mock Get-CleanupWorktreeManifestUtcNow { $now }.GetNewClosure()
        Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest -MockWith ([scriptblock]::Create("'$manifest'"))
        Mock Get-CleanupWorktreeManifestUtcNow -ModuleName CleanupWorktreeManifest -MockWith ([scriptblock]::Create('[datetime]::new(2026, 11, 3, 12, 0, 0, [System.DateTimeKind]::Utc)'))
        Mock Resolve-PrAuthorWorktreeTarget { $target }.GetNewClosure()
        Mock Resolve-ModelRoutingWorktreeTarget { $target }.GetNewClosure()
        Mock Get-PrContextArtifactExistence { $true }
        Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $true; ErrorText = '' } }
        Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('a' * 40) } }
        Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { $diff }.GetNewClosure()
        Mock Get-PrAuthorCleanupPublishedHead { [pscustomobject]@{ Remote = ('a' * 40); Head = ('a' * 40) } }
        Mock Get-PrBodyFileBytes { , [byte[]] @(0x41) }
        Mock Get-PrAuthorReceiptContent { $receipt }.GetNewClosure()
        Mock Get-PrContextSummaryLastWriteUtc { [datetime]::new(2026, 11, 3, 11, 0, 0, [System.DateTimeKind]::Utc) }
    }
}

AfterAll {
    # The gates replace the run module; discard only the stale fixture-owned scope binding.
    Reset-EpicStateProbeModuleBinding
}

Describe 'cleanup-merged-worktrees workflow end to end with no checkpoint (issue #1026)' {
    BeforeEach {
        Set-WorkflowScenario
    }

    It 'lists every hook registered for the Bash, Write|Edit, and Agent matchers as composed or exempted' {
        # Arrange
        $settings = Get-Content -Raw -LiteralPath (Resolve-Path "$PSScriptRoot/../../../.claude/settings.json").Path | ConvertFrom-Json
        $tools = @('Bash', 'Write', 'Edit', 'Agent')
        $registered = @(foreach ($entry in @($settings.hooks.PreToolUse)) {
                if (@(([string]$entry.matcher) -split '\|' | Where-Object { $tools -ccontains $_ }).Count -eq 0) { continue }
                foreach ($hook in @($entry.hooks)) {
                    $match = [regex]::Match([string]$hook.command, '\.claude/hooks/(?<leaf>[A-Za-z0-9._-]+\.ps1)')
                    if ($match.Success) { $match.Groups['leaf'].Value }
                }
            }) | Select-Object -Unique

        # Act
        $unaccounted = @($registered | Where-Object { $script:ComposedHook -notcontains $_ -and -not $script:ExemptHook.Contains($_) })
        $stale = @($script:ExemptHook.Keys | Where-Object { $registered -notcontains $_ })

        # Assert
        $registered.Count | Should -BeGreaterThan 0
        $unaccounted | Should -BeNullOrEmpty -Because 'a newly registered hook must be composed here or exempted with a reason'
        $stale | Should -BeNullOrEmpty -Because 'every exemption names a registered hook'
        foreach ($hook in $script:ComposedHook) { $registered | Should -Contain $hook }
        foreach ($reason in $script:ExemptHook.Values) { $reason.Length | Should -BeGreaterThan 20 }
    }

    Context 'report' {
        It 'allows the report run in every composed Bash hook' {
            Assert-AllAllowed -Decision (Get-BashWorkflowDecision -Command $script:Script)
        }
    }

    Context 'manifest Write' {
        It 'allows the session-root manifest Write in the preimplementation gate' {
            # Act
            $payload = ConvertTo-WorkflowPayload -Tool 'Write' -ToolInput @{ file_path = "$($script:Session)/artifacts/orchestration/cleanup-worktrees-manifest.json"; content = $script:ManifestJson }

            # Assert
            (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context '--preserve' {
        It 'allows the preserve run in every composed Bash hook' {
            Assert-AllAllowed -Decision (Get-BashWorkflowDecision -Command "$($script:Script) --preserve")
        }
    }

    Context 'git commit' {
        It 'allows the consolidation commit of the preserved staged index in every composed Bash hook' {
            # Act
            $decision = Get-BashWorkflowDecision -Command "git -C $($script:Consolidation) commit -F /synthetic-users/LONGUS~1/AppData/Local/Temp/issue-1026-msg.txt"

            # Assert
            Assert-AllAllowed -Decision $decision
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq $script:Consolidation }
        }
    }

    Context 'git push' {
        It 'allows the consolidation branch push in every composed Bash hook' {
            Assert-AllAllowed -Decision (Get-BashWorkflowDecision -Command "git -C $($script:Consolidation) push -u origin documentationandmemories")
        }
    }

    Context 'Agent(pr-author) delegation' {
        It 'allows the non-isolated pr-author delegation in every composed Agent hook' {
            # Arrange
            $payload = ConvertTo-WorkflowPayload -Tool 'Agent' -ToolInput @{ subagent_type = 'pr-author'; prompt = "Open the consolidation pull request with an absolute body path.`nbranch: documentationandmemories" }

            # Act
            $decision = [ordered]@{
                'enforce-orchestration-preimplementation-gate.ps1' = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
                'enforce-model-routing-receipt.ps1'                = (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision
            }

            # Assert
            Assert-AllAllowed -Decision $decision
        }
    }

    Context 'receipt Write' {
        It 'allows the pr-author receipt Write beneath the consolidation worktree in the preimplementation gate' {
            # Act
            $payload = ConvertTo-WorkflowPayload -Tool 'Write' -ToolInput @{ file_path = "$($script:Consolidation)/artifacts/pr_body_7.receipt.json"; content = $script:Receipt }

            # Assert
            (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'gh pr create' {
        It 'allows the consolidation pull request in every composed Bash hook' {
            Assert-AllAllowed -Decision (Get-BashWorkflowDecision -Command "gh pr create --head documentationandmemories --base main --title Consolidate --body-file $($script:Consolidation)/artifacts/pr_body_7.md")
        }
    }

    Context '--apply' {
        It 'allows the apply run in every composed Bash hook' {
            Assert-AllAllowed -Decision (Get-BashWorkflowDecision -Command "$($script:Script) --apply")
        }
    }

    Context 'manifest-authorized removal' {
        It 'allows git worktree remove of the SAFE_TO_DELETE path in both removal gates with no checkpoint' {
            # Act
            $decision = Get-BashWorkflowDecision -Command "git worktree remove $($script:SafeToDelete)"

            # Assert
            Assert-AllAllowed -Decision $decision
        }

        It 'denies git worktree remove of a path the manifest does not authorize in both removal gates' {
            # Act
            $decision = Get-BashWorkflowDecision -Command 'git worktree remove /synthetic-worktrees/unlisted-item'

            # Assert
            $decision['enforce-parallel-worktree-removal-gate.ps1'] | Should -Be 'deny'
            $decision['enforce-epic-worktree-removal-gate.ps1'] | Should -Be 'deny'
        }
    }
}
