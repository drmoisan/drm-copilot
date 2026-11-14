#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Docs-estate delegation leg of the model-routing receipt gate (issue #1169).

.DESCRIPTION
    Drives Invoke-ModelRoutingReceiptDecision for checkpoint-free Agent(pr-author) delegations.
    The resolution seam Resolve-ModelRoutingWorktreeTarget returns the synthetic worktree
    /synthetic-worktrees/docs-run, Get-ModelRoutingCheckpoint returns $null unless a row supplies
    a checkpoint, Get-ModelRoutingDocsEstateFileText returns texts from an in-memory map keyed by
    the joined path, and Invoke-DocsOnlyGitExe is mocked by its arguments. No row creates a file,
    starts a process, reads a clock, or sets an environment variable.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { '/synthetic-worktrees/main' }
    Mock Get-ModelRoutingCheckpoint { $null }

    $script:Root = '/synthetic-worktrees/docs-run'
    $script:Receipt = '1111111111111111111111111111111111111111'
    $script:Head = '2222222222222222222222222222222222222222'
    $script:BaseCommit = '3333333333333333333333333333333333333333'
    $script:Nul = [string][char]0
    $script:Blocked = "MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."
    $script:Prompt = "Open the docs pull request.`nbranch: docs/estate-refresh`nbase: main`nCanonical issue number for this feature is 12.`nAuthor-asserted autoclose issues: #12"

    function New-DocsEstateAgentPayload {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory payload factory in a test file; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $Prompt, [string] $Subagent = 'pr-author')
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $Subagent; prompt = $Prompt } } | ConvertTo-Json -Depth 5 -Compress)
    }

    function Set-DocsEstateRoutingFixture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [AllowNull()][object] $ProfileText = 'valid',
            [AllowNull()][object] $ReceiptText = 'valid',
            [string] $SnapshotRevision = '1111111111111111111111111111111111111111',
            [int] $BaseExit = 0,
            [int] $HeadExit = 0,
            [int] $DiffExit = 0,
            [string] $DiffOutput = "docs/a.md$([char]0).github/workflows/_docs-quality.yml$([char]0)",
            [int] $AncestorExit = 0,
            [string] $ChangedOutput = "docs/a.md$([char]0)",
            [AllowNull()][object] $Checkpoint = $null
        )
        $profileValue = if ($ProfileText -ceq 'valid') { [ordered]@{ artifact_kind = 'docs-profile'; documentation_roots = @(@{ id = 'docs-root'; path = 'docs' }); surface_selection = @{ source_roots = @('src') }; artifact_paths = [ordered]@{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'; inventory_snapshot = 'docs/documentation-estate/surface-inventory-snapshot.json' } } | ConvertTo-Json -Depth 6 -Compress } else { $ProfileText }
        $receiptValue = if ($ReceiptText -ceq 'valid') { [ordered]@{ artifact_kind = 'docs-validation-receipt'; mode = 'docs-complete'; revision = $script:Receipt; validation_result = 'pass' } | ConvertTo-Json -Compress } else { $ReceiptText }
        $files = @{
            (Join-Path -Path $script:Root -ChildPath 'docs/documentation-estate/docs-profile.json')               = $profileValue
            (Join-Path -Path $script:Root -ChildPath 'docs/documentation-estate/docs-validation-receipt.json')    = $receiptValue
            (Join-Path -Path $script:Root -ChildPath 'docs/documentation-estate/surface-inventory-snapshot.json') = ([ordered]@{ revision = $SnapshotRevision } | ConvertTo-Json -Compress)
        }
        $target = [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $script:Root; ReasonCode = $null; Detail = 'synthetic docs root' }
        $checkpointObject = $Checkpoint
        $baseResult = [pscustomobject]@{ ExitCode = $BaseExit; Output = $script:BaseCommit }
        $headResult = [pscustomobject]@{ ExitCode = $HeadExit; Output = $script:Head }
        $diffResult = [pscustomobject]@{ ExitCode = $DiffExit; Output = $DiffOutput }
        $ancestorResult = [pscustomobject]@{ ExitCode = $AncestorExit; Output = '' }
        $changedResult = [pscustomobject]@{ ExitCode = 0; Output = $ChangedOutput }
        Mock Resolve-ModelRoutingWorktreeTarget { $target }.GetNewClosure()
        Mock Get-ModelRoutingCheckpoint { $checkpointObject }.GetNewClosure()
        Mock Get-ModelRoutingDocsEstateFileText -MockWith ({ param([string] $Path) if ($files.ContainsKey($Path)) { $files[$Path] } else { $null } }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 128; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and $GitArgs[-1].StartsWith('refs/remotes/origin/', [System.StringComparison]::Ordinal) } -MockWith ({ $baseResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and $GitArgs[-1] -ceq 'HEAD^{commit}' } -MockWith ({ $headResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' -and $GitArgs[-1].EndsWith('...HEAD') } -MockWith ({ $diffResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'merge-base' } -MockWith ({ $ancestorResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' -and -not $GitArgs[-1].EndsWith('...HEAD') } -MockWith ({ $changedResult }.GetNewClosure())
    }

    function Get-DocsEstateRoutingDecision {
        param([string] $Prompt = $script:Prompt, [string] $Subagent = 'pr-author')
        return (Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-DocsEstateAgentPayload -Prompt $Prompt -Subagent $Subagent))
    }

    function Assert-DocsEstateRoutingDeny {
        param([Parameter(Mandatory)] $Decision, [Parameter(Mandatory)] [string] $SubCode)
        $reason = [string]$Decision.hookSpecificOutput.permissionDecisionReason
        $Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.StartsWith("$($script:Blocked) Docs-estate delegation leg not applied: $($SubCode): ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' must carry $SubCode after the unchanged text"
    }
}

AfterAll {
    # Remove the top-level functions of the dot-sourced gate and of the docs-leg files it loads.
    foreach ($file in @('enforce-model-routing-receipt.ps1', 'enforce-model-routing-receipt-docs.ps1', 'enforce-orchestration-preimplementation-gate-docs.ps1', 'hook-docs-estate-context.ps1') | ForEach-Object { Join-Path $script:HookRoot "hooks/$_" }) {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
}

Describe 'model-routing gate docs-estate delegation leg (issue #1169)' {
    BeforeEach {
        Set-DocsEstateRoutingFixture
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allowed delegations' {
        It 'allows a checkpoint-free Agent(pr-author) with one branch and one base line, a docs-only diff, and a passing receipt' {
            # Act
            $decision = Get-DocsEstateRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'diff --name-only -z --no-renames --no-relative refs/remotes/origin/main...HEAD' -and $WorktreeRoot -ceq '/synthetic-worktrees/docs-run' }
        }

        It 'accepts an epic integration base when the other conditions hold' {
            # Arrange
            # The fixture resolves any origin base, so only the prompt names the epic base.
            $prompt = $script:Prompt.Replace('base: main', 'base: epic/docs-integration')

            # Act
            $decision = Get-DocsEstateRoutingDecision -Prompt $prompt

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'diff --name-only -z --no-renames --no-relative refs/remotes/origin/epic/docs-integration...HEAD' }
        }

        It 'allows a receipt whose revision is the head revision with no ancestry or receipt diff call' {
            # Arrange
            $receipt = [ordered]@{ artifact_kind = 'docs-validation-receipt'; mode = 'docs-complete'; revision = $script:Head; validation_result = 'pass' } | ConvertTo-Json -Compress
            Set-DocsEstateRoutingFixture -SnapshotRevision $script:Head -ReceiptText $receipt

            # Act
            $decision = Get-DocsEstateRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -ceq 'merge-base' }
        }
    }

    Context 'denials with a docs-estate sub-code' {
        It 'denies DOCS_DELEGATION_LABEL_INVALID for <Case>' -ForEach @(
            @{ Case = 'a missing branch line'; Prompt = "Open the docs pull request.`nbase: main" }
            @{ Case = 'a duplicated branch line'; Prompt = "branch: docs/a`nbranch: docs/b`nbase: main" }
            @{ Case = 'a missing base line'; Prompt = "branch: docs/a" }
            @{ Case = 'a duplicated base line'; Prompt = "branch: docs/a`nbase: main`nbase: main" }
            @{ Case = 'a branch value with ..'; Prompt = "branch: docs/a..b`nbase: main" }
            @{ Case = 'a base value with ..'; Prompt = "branch: docs/a`nbase: ../main" }
        ) {
            # Act
            $decision = Get-DocsEstateRoutingDecision -Prompt $Prompt

            # Assert
            Assert-DocsEstateRoutingDeny -Decision $decision -SubCode 'DOCS_DELEGATION_LABEL_INVALID'
        }

        It 'denies DOCS_DELEGATION_PROFILE_INVALID for an invalid profile' {
            # Arrange
            Set-DocsEstateRoutingFixture -ProfileText '{"artifact_kind":"docs-profile"}'

            # Act and Assert
            Assert-DocsEstateRoutingDeny -Decision (Get-DocsEstateRoutingDecision) -SubCode 'DOCS_DELEGATION_PROFILE_INVALID'
        }

        It 'denies DOCS_DELEGATION_DIFF_UNREADABLE for <Case>' -ForEach @(
            @{ Case = 'an unresolvable origin base'; BaseExit = 1; HeadExit = 0; DiffExit = 0; DiffOutput = "docs/a.md$([char]0)" }
            @{ Case = 'an unresolvable HEAD'; BaseExit = 0; HeadExit = 128; DiffExit = 0; DiffOutput = "docs/a.md$([char]0)" }
            @{ Case = 'a diff timeout of the mocked Invoke-DocsOnlyGitExe'; BaseExit = 0; HeadExit = 0; DiffExit = 124; DiffOutput = '' }
            @{ Case = 'a diff non-zero exit of the mocked Invoke-DocsOnlyGitExe'; BaseExit = 0; HeadExit = 0; DiffExit = 128; DiffOutput = '' }
            @{ Case = 'a diff without the trailing NUL'; BaseExit = 0; HeadExit = 0; DiffExit = 0; DiffOutput = 'docs/a.md' }
        ) {
            # Arrange
            Set-DocsEstateRoutingFixture -BaseExit $BaseExit -HeadExit $HeadExit -DiffExit $DiffExit -DiffOutput $DiffOutput

            # Act and Assert
            Assert-DocsEstateRoutingDeny -Decision (Get-DocsEstateRoutingDecision) -SubCode 'DOCS_DELEGATION_DIFF_UNREADABLE'
        }

        It 'denies DOCS_DELEGATION_DIFF_EMPTY for an empty diff' {
            # Arrange
            Set-DocsEstateRoutingFixture -DiffOutput ''

            # Act and Assert
            Assert-DocsEstateRoutingDeny -Decision (Get-DocsEstateRoutingDecision) -SubCode 'DOCS_DELEGATION_DIFF_EMPTY'
        }

        It 'denies DOCS_DELEGATION_PATH_NOT_ALLOWED for a diff path outside the docs path set' {
            # Arrange
            Set-DocsEstateRoutingFixture -DiffOutput "docs/a.md$($script:Nul)src/a.ps1$($script:Nul)"

            # Act
            $decision = Get-DocsEstateRoutingDecision

            # Assert
            Assert-DocsEstateRoutingDeny -Decision $decision -SubCode 'DOCS_DELEGATION_PATH_NOT_ALLOWED'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*'src/a.ps1'*"
        }

        It 'denies DOCS_DELEGATION_PATH_NOT_ALLOWED for a diff path <Outside> outside docs/ under a root or artifact directory' -ForEach @(
            @{ Outside = 'guide/start.md' }
            @{ Outside = 'scripts/evil.ps1' }
        ) {
            # Arrange
            # Under the pre-CR3 rule this profile admits guide/start.md (a .md file under a root) and
            # scripts/evil.ps1 (under an artifact directory); under the CR3 rule it admits neither.
            $profileText = [ordered]@{ artifact_kind = 'docs-profile'; documentation_roots = @(@{ id = 'docs-root'; path = 'docs' }, @{ id = 'guide'; path = 'guide' }); artifact_paths = [ordered]@{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'; extra = 'scripts/x.json' } } | ConvertTo-Json -Depth 6 -Compress
            Set-DocsEstateRoutingFixture -ProfileText $profileText -DiffOutput "docs/a.md$($script:Nul)$Outside$($script:Nul)"

            # Act
            $decision = Get-DocsEstateRoutingDecision

            # Assert
            Assert-DocsEstateRoutingDeny -Decision $decision -SubCode 'DOCS_DELEGATION_PATH_NOT_ALLOWED'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*'$Outside'*"
        }

        It 'denies DOCS_DELEGATION_RECEIPT_INVALID for <Case>' -ForEach @(
            @{ Case = 'an absent receipt'; Receipt = $null }
            @{ Case = 'an unreadable receipt'; Receipt = '{"artifact_kind":' }
            @{ Case = 'the wrong artifact kind'; Receipt = '{"artifact_kind":"docs-profile","mode":"docs-complete","validation_result":"pass","revision":"1111111111111111111111111111111111111111"}' }
            @{ Case = 'the wrong mode'; Receipt = '{"artifact_kind":"docs-validation-receipt","mode":"ledger","validation_result":"pass","revision":"1111111111111111111111111111111111111111"}' }
            @{ Case = 'a failing result'; Receipt = '{"artifact_kind":"docs-validation-receipt","mode":"docs-complete","validation_result":"fail","revision":"1111111111111111111111111111111111111111"}' }
        ) {
            # Arrange
            Set-DocsEstateRoutingFixture -ReceiptText $Receipt

            # Act and Assert
            Assert-DocsEstateRoutingDeny -Decision (Get-DocsEstateRoutingDecision) -SubCode 'DOCS_DELEGATION_RECEIPT_INVALID'
        }

        It 'denies with the receipt revision reason <Reason>' -ForEach @(
            @{ Reason = 'RECEIPT_REVISION_SNAPSHOT_MISMATCH'; Snapshot = '4444444444444444444444444444444444444444'; AncestorExit = 0; Changed = "docs/a.md$([char]0)" }
            @{ Reason = 'RECEIPT_REVISION_NOT_ANCESTOR'; Snapshot = '1111111111111111111111111111111111111111'; AncestorExit = 1; Changed = "docs/a.md$([char]0)" }
            @{ Reason = 'RECEIPT_REVISION_UNRESOLVED'; Snapshot = '1111111111111111111111111111111111111111'; AncestorExit = 124; Changed = "docs/a.md$([char]0)" }
            @{ Reason = 'RECEIPT_SOURCE_DRIFT'; Snapshot = '1111111111111111111111111111111111111111'; AncestorExit = 0; Changed = "src/tool.py$([char]0)" }
        ) {
            # Arrange
            Set-DocsEstateRoutingFixture -SnapshotRevision $Snapshot -AncestorExit $AncestorExit -ChangedOutput $Changed

            # Act and Assert
            Assert-DocsEstateRoutingDeny -Decision (Get-DocsEstateRoutingDecision) -SubCode $Reason
        }
    }

    Context 'unchanged behavior' {
        It 'keeps the deny text byte-identical without a profile file' {
            # Arrange
            Set-DocsEstateRoutingFixture -ProfileText $null

            # Act
            $decision = Get-DocsEstateRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'does not apply the docs leg when a checkpoint is present and the receipt check governs' {
            # Arrange
            Set-DocsEstateRoutingFixture -Checkpoint ([pscustomobject]@{ model_routing_receipts = @() })

            # Act
            $decision = Get-DocsEstateRoutingDecision

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            Should -Invoke Get-ModelRoutingDocsEstateFileText -Times 0 -Exactly
        }

        It 'does not apply the docs leg to a subagent other than pr-author' {
            # Act
            $decision = Get-DocsEstateRoutingDecision -Subagent 'atomic-executor'

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Should -Invoke Get-ModelRoutingDocsEstateFileText -Times 0 -Exactly
        }

        It 'declines without throwing when a seam throws' {
            # Arrange
            Mock Get-ModelRoutingDocsEstateFileText { throw [System.IO.IOException]::new('locked') }

            # Act
            $decision = Get-DocsEstateRoutingDecision

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }
    }
}
