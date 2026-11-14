#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end composition of a checkpoint-free documentation run over the hook decisions (issue #1169).

.DESCRIPTION
    One synthetic docs branch, epic/docs-integration on the session root, with no checkpoint, a
    structurally valid docs profile, docs/ pages, estate artifacts, and the docs-init workflow file.
    The A1 leg (enforce-orchestration-preimplementation-gate.ps1), the A2 leg
    (enforce-model-routing-receipt.ps1), E7 (Get-PrAuthorDocsOnlyExemption in
    enforce-pr-author-skill.ps1), M9 (Get-DocsOnlyMergeExemption in hook-docs-only-diff.ps1), and
    the A4-based docs-complete gate (enforce-docs-complete-gate.ps1) are composed in workflow order:
    git add and git commit of the init outputs and of the docs-complete estate, the pr-author receipt
    Write, Agent(pr-author), gh pr create, and gh pr merge. The same branch with one added non-docs
    path is denied at commit, delegation, pull-request creation, and merge.

    Every read goes through an injected seam: the worktree listing, the checkpoint-presence and
    profile seams of each leg, the staged index, Invoke-DocsOnlyGitExe, Invoke-DocsOnlyGhExe,
    Invoke-PrAuthorDocsOnlyGitExe, and the docs-complete gate file and root seams. No row creates a
    file, starts a process, reads a clock, or sets an environment variable.
#>

BeforeAll {
    $hookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    . (Join-Path $hookRoot 'enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $hookRoot 'enforce-model-routing-receipt.ps1')
    . (Join-Path $hookRoot 'enforce-pr-author-skill.ps1')
    . (Join-Path $hookRoot 'enforce-docs-complete-gate.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    # Issue #1182: the parallel records leg calls these from hook scope, where the module-scoped baseline mocks do not reach.
    Mock Get-EpicScopeWorktreeHeadBranch { $null }
    Mock Get-WorktreeRunCheckpointText { $null }
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { '/synthetic-worktrees/main' }

    # The scenario, defined once.
    $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:Nul = [string][char]0
    $script:Branch = 'epic/docs-integration'
    $script:ReceiptRevision = '1111111111111111111111111111111111111111'
    $script:Head = '2222222222222222222222222222222222222222'
    $script:BaseCommit = '3333333333333333333333333333333333333333'
    $script:Profile1169 = [ordered]@{ artifact_kind = 'docs-profile'; documentation_roots = @(@{ id = 'docs-root'; path = 'docs' }); surface_selection = @{ source_roots = @('src') }; artifact_paths = [ordered]@{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'; inventory_snapshot = 'docs/documentation-estate/surface-inventory-snapshot.json' }; completion_gates = @{ integration_pr_gate = @{ enabled = $true } } } | ConvertTo-Json -Depth 6 -Compress
    $script:ReceiptText = [ordered]@{ artifact_kind = 'docs-validation-receipt'; mode = 'docs-complete'; revision = $script:ReceiptRevision; validation_result = 'pass' } | ConvertTo-Json -Compress
    $script:SnapshotText = [ordered]@{ revision = $script:ReceiptRevision } | ConvertTo-Json -Compress
    $script:InitOutputs = @('docs/documentation-estate/docs-profile.json', 'docs/documentation-estate/.vale.ini', 'docs/documentation-estate/.markdownlint.json', '.github/workflows/_docs-quality.yml')
    $script:Estate = @('docs/reference/cli.md', 'docs/documentation-estate/surface-inventory-snapshot.json', 'docs/documentation-estate/docs-coverage-ledger.json', 'docs/documentation-estate/docs-validation-receipt.json')
    $script:Prompt = "Open the documentation pull request.`nbranch: $($script:Branch)`nbase: main`nCanonical issue number for this feature is 12.`nAuthor-asserted autoclose issues: #12`ngh pr create --head $($script:Branch) --base main"

    function ConvertTo-DocsRunNulList {
        param([string[]] $Path)
        return (($Path | ForEach-Object { $_ + $script:Nul }) -join '')
    }

    function Set-DocsRunScenario {
        <#
        .SYNOPSIS
            Register every seam for one branch state: the staged index, the branch diff, and the files.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([Parameter(Mandatory)] [string[]] $Staged, [Parameter(Mandatory)] [string[]] $BranchPath)

        $listing = "worktree $($script:Session)`nbranch refs/heads/$($script:Branch)`n"
        $stagedResult = [pscustomobject]@{ ExitCode = 0; Output = (ConvertTo-DocsRunNulList -Path $Staged) }
        $branchDiff = [pscustomobject]@{ ExitCode = 0; Output = (ConvertTo-DocsRunNulList -Path $BranchPath) }
        $receiptDiff = [pscustomobject]@{ ExitCode = 0; Output = (ConvertTo-DocsRunNulList -Path $BranchPath) }
        $baseResult = [pscustomobject]@{ ExitCode = 0; Output = $script:BaseCommit }
        $headResult = [pscustomobject]@{ ExitCode = 0; Output = $script:Head }
        $prView = [ordered]@{ baseRefName = 'main'; headRefName = $script:Branch; headRefOid = $script:Head } | ConvertTo-Json -Compress
        $profileText = $script:Profile1169
        $files = @{
            (Join-Path -Path $script:Session -ChildPath 'docs/documentation-estate/docs-profile.json')               = $script:Profile1169
            (Join-Path -Path $script:Session -ChildPath 'docs/documentation-estate/docs-validation-receipt.json')    = $script:ReceiptText
            (Join-Path -Path $script:Session -ChildPath 'docs/documentation-estate/surface-inventory-snapshot.json') = $script:SnapshotText
        }
        $root = $script:Session

        # A1: no checkpoint, the profile, the listing, and the staged index.
        Mock Get-OrchestrationGateWorktreeList { $listing }.GetNewClosure()
        Mock Get-OrchestrationGateStagedIndex { $stagedResult }.GetNewClosure()
        Mock Test-OrchestrationDocsEstateCheckpointPresent { $false }
        Mock Get-WorktreeResolutionGitFileText { $profileText }.GetNewClosure() -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        # A2: the resolved root, no checkpoint, the profile, receipt, and snapshot texts.
        Mock Resolve-ModelRoutingWorktreeTarget ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $root; ReasonCode = $null; Detail = 'synthetic docs run' } }.GetNewClosure())
        Mock Get-ModelRoutingCheckpoint { $null }
        Mock Get-ModelRoutingDocsEstateFileText -MockWith ({ param([string] $Path) if ($files.ContainsKey($Path)) { $files[$Path] } else { $null } }.GetNewClosure())
        # Shared git and gh seams of A2, M9, and the docs-complete gate.
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 128; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and $GitArgs[-1].StartsWith('refs/remotes/origin/', [System.StringComparison]::Ordinal) } -MockWith ({ $baseResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and -not $GitArgs[-1].StartsWith('refs/remotes/origin/', [System.StringComparison]::Ordinal) } -MockWith ({ $headResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' -and $GitArgs[-1].Contains('...') } -MockWith ({ $branchDiff }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'merge-base' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' -and -not $GitArgs[-1].Contains('...') } -MockWith ({ $receiptDiff }.GetNewClosure())
        Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $prView } }.GetNewClosure())
        # E7: no checkpoint and the same branch diff through its own seam.
        Mock Test-PrAuthorDocsOnlyCheckpointPresence { $false }
        Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' } -MockWith ({ $baseResult }.GetNewClosure())
        Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' } -MockWith ({ $branchDiff }.GetNewClosure())
        # The docs-complete gate reads beneath the session root.
        Mock Get-DocsCompleteGateRepositoryRoot ({ $root }.GetNewClosure())
        Mock Get-DocsCompleteGateReceiptRoot ({ $root }.GetNewClosure())
        Mock Get-DocsCompleteGateFileText -MockWith ({ param([string] $Path) if ($files.ContainsKey($Path)) { $files[$Path] } else { $null } }.GetNewClosure())
    }

    function Invoke-DocsRunStep {
        <#
        .SYNOPSIS
            Return @{ Decision; Reason } of one workflow step.
        #>
        param([Parameter(Mandatory)] [ValidateSet('AddInit', 'CommitInit', 'AddEstate', 'CommitEstate', 'ReceiptWrite', 'Delegate', 'CreatePr', 'MergeM9', 'MergeDocsComplete')] [string] $Step, [string[]] $AddPath = @())
        switch ($Step) {
            { $_ -in @('AddInit', 'AddEstate') } {
                $payload = @{ tool_name = 'Bash'; tool_input = @{ command = 'git add -- ' + ($AddPath -join ' ') } } | ConvertTo-Json -Compress -Depth 5
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload
                return @{ Decision = $decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
            }
            { $_ -in @('CommitInit', 'CommitEstate') } {
                $payload = @{ tool_name = 'Bash'; tool_input = @{ command = 'git commit -F artifacts/commit-message.txt' } } | ConvertTo-Json -Compress -Depth 5
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload
                return @{ Decision = $decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
            }
            'ReceiptWrite' {
                $payload = @{ tool_name = 'Write'; tool_input = @{ file_path = 'artifacts/pr_body_12.receipt.json'; content = '{}' } } | ConvertTo-Json -Compress -Depth 5
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload
                return @{ Decision = $decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
            }
            'Delegate' {
                $payload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'pr-author'; prompt = $script:Prompt } } | ConvertTo-Json -Compress -Depth 5
                $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
                return @{ Decision = $decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
            }
            'CreatePr' {
                $result = Get-PrAuthorDocsOnlyExemption -CommandText "gh pr create --head $($script:Branch) --base main --title Docs --body-file artifacts/pr_body_12.md" -WorktreeRoot $script:Session -CheckpointPath "$($script:Session)/artifacts/orchestration/orchestrator-state.json"
                return @{ Decision = $(if ($result.Exempt) { 'allow' } else { 'deny' }); Reason = [string]$result.Reason }
            }
            'MergeM9' {
                $result = Get-DocsOnlyMergeExemption -CommandText 'gh pr merge 7 --merge' -PrNumber 7 -WorktreeRoot $PSScriptRoot
                return @{ Decision = $(if ($result.Exempt) { 'allow' } else { 'deny' }); Reason = [string]$result.Reason }
            }
            'MergeDocsComplete' {
                $payload = @{ tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 7 --merge' } } | ConvertTo-Json -Compress -Depth 5
                $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $payload
                return @{ Decision = $decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
            }
        }
    }
}

AfterAll {
    # Remove the top-level functions of the four dot-sourced hooks and of the docs-leg files they load.
    $hookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    $loaded = @('enforce-orchestration-preimplementation-gate.ps1', 'enforce-model-routing-receipt.ps1', 'enforce-pr-author-skill.ps1', 'enforce-docs-complete-gate.ps1', 'enforce-orchestration-preimplementation-gate-docs.ps1', 'enforce-model-routing-receipt-docs.ps1', 'hook-docs-estate-context.ps1')
    foreach ($file in $loaded | ForEach-Object { Join-Path $hookRoot $_ }) {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
}

Describe 'docs-estate workflow end to end (issue #1169)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'a docs-only branch' {
        BeforeEach {
            Set-DocsRunScenario -Staged ($script:InitOutputs) -BranchPath ($script:InitOutputs + $script:Estate)
        }

        It 'allows git add and git commit of the docs-init outputs' {
            # Act
            $add = Invoke-DocsRunStep -Step 'AddInit' -AddPath $script:InitOutputs
            $commit = Invoke-DocsRunStep -Step 'CommitInit'

            # Assert
            $add.Decision | Should -Be 'allow' -Because $add.Reason
            $commit.Decision | Should -Be 'allow' -Because $commit.Reason
        }

        It 'allows git add and git commit of the docs-complete estate' {
            # Arrange
            Set-DocsRunScenario -Staged $script:Estate -BranchPath ($script:InitOutputs + $script:Estate)

            # Act
            $add = Invoke-DocsRunStep -Step 'AddEstate' -AddPath $script:Estate
            $commit = Invoke-DocsRunStep -Step 'CommitEstate'

            # Assert
            $add.Decision | Should -Be 'allow' -Because $add.Reason
            $commit.Decision | Should -Be 'allow' -Because $commit.Reason
        }

        It 'allows the pr-author receipt Write' {
            # Act
            $write = Invoke-DocsRunStep -Step 'ReceiptWrite'

            # Assert
            $write.Decision | Should -Be 'allow' -Because $write.Reason
        }

        It 'allows Agent(pr-author) through the docs-estate delegation leg' {
            # Act
            $delegate = Invoke-DocsRunStep -Step 'Delegate'

            # Assert
            $delegate.Decision | Should -Be 'allow' -Because $delegate.Reason
        }

        It 'allows gh pr create through E7' {
            # Act
            $create = Invoke-DocsRunStep -Step 'CreatePr'

            # Assert
            $create.Decision | Should -Be 'allow' -Because $create.Reason
        }

        It 'allows the merge through M9 and the docs-complete gate' {
            # Act
            $m9 = Invoke-DocsRunStep -Step 'MergeM9'
            $docsComplete = Invoke-DocsRunStep -Step 'MergeDocsComplete'

            # Assert
            $m9.Decision | Should -Be 'allow' -Because $m9.Reason
            $docsComplete.Decision | Should -Be 'allow' -Because $docsComplete.Reason
            Should -Invoke Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'merge-base' } -Scope It
        }
    }

    Context 'the same branch with one added non-docs path' {
        BeforeEach {
            Set-DocsRunScenario -Staged ($script:Estate + @('src/tool.py')) -BranchPath ($script:InitOutputs + $script:Estate + @('src/tool.py'))
        }

        It 'denies the commit with DOCS_LEG_STAGED_PATH_NOT_ALLOWED' {
            # Act
            $commit = Invoke-DocsRunStep -Step 'CommitEstate'

            # Assert
            $commit.Decision | Should -Be 'deny'
            $commit.Reason | Should -BeLike '*Docs-estate leg not applied: DOCS_LEG_STAGED_PATH_NOT_ALLOWED*'
        }

        It 'denies the delegation with DOCS_DELEGATION_PATH_NOT_ALLOWED' {
            # Act
            $delegate = Invoke-DocsRunStep -Step 'Delegate'

            # Assert
            $delegate.Decision | Should -Be 'deny'
            $delegate.Reason | Should -BeLike '*Docs-estate delegation leg not applied: DOCS_DELEGATION_PATH_NOT_ALLOWED*'
        }

        It 'denies gh pr create through E7 with DOCS_ONLY_EXEMPTION_NON_DOCS_PATH' {
            # Act
            $create = Invoke-DocsRunStep -Step 'CreatePr'

            # Assert
            $create.Decision | Should -Be 'deny'
            $create.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
        }

        It 'denies the merge through M9 and through the docs-complete gate' {
            # Act
            $m9 = Invoke-DocsRunStep -Step 'MergeM9'
            $docsComplete = Invoke-DocsRunStep -Step 'MergeDocsComplete'

            # Assert
            $m9.Decision | Should -Be 'deny'
            $m9.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
            $docsComplete.Decision | Should -Be 'deny'
            $docsComplete.Reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_SOURCE_DRIFT: *'
        }
    }
}
