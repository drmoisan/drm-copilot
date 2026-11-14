#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Receipt revision rule of .claude/hooks/enforce-docs-complete-gate.ps1 (issue #1169).

.DESCRIPTION
    Dot-sources the hook and drives Invoke-DocsCompleteGateDecision for an integration pull
    request whose receipt was written at an earlier revision than headRefOid. The root, receipt
    root, file, gh, and git seams are mocked; Invoke-DocsOnlyGitExe is mocked by its GitArgs, so no
    row starts a process or writes a file. Paths are forward-slash relative with exact case.
#>

Describe 'enforce-docs-complete-gate receipt revision rule (issue #1169)' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-docs-complete-gate.ps1").Path
        $script:ReceiptRevision = '1111111111111111111111111111111111111111'
        $script:Head = '2222222222222222222222222222222222222222'
        $script:Envelope = @{ session_id = 's-1169'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 7 --merge' } } | ConvertTo-Json -Depth 5 -Compress
        Mock Get-DocsCompleteGateRepositoryRoot { 'repo-root' }
        Mock Get-DocsCompleteGateReceiptRoot { 'repo-root' }

        function Set-TestRevisionSeam {
            <#
            .SYNOPSIS
                Mock the file, gh, and git seams for one receipt revision and one head.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            [CmdletBinding()]
            param(
                [string] $Head = $script:Head,
                [int] $AncestorExit = 0,
                [int] $DiffExit = 0,
                [string] $DiffOutput = "docs/a.md`0"
            )

            $profileText = [ordered]@{ artifact_paths = [ordered]@{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'; inventory_snapshot = 'docs/documentation-estate/surface-inventory-snapshot.json' }; surface_selection = [ordered]@{ source_roots = @('src') }; completion_gates = [ordered]@{ integration_pr_gate = [ordered]@{ enabled = $true } } } | ConvertTo-Json -Depth 5 -Compress
            $receiptText = [ordered]@{ artifact_kind = 'docs-validation-receipt'; mode = 'docs-complete'; revision = $script:ReceiptRevision; validation_result = 'pass' } | ConvertTo-Json -Compress
            $snapshotText = [ordered]@{ revision = $script:ReceiptRevision } | ConvertTo-Json -Compress
            $files = @{
                (Join-Path -Path 'repo-root' -ChildPath 'docs/documentation-estate/docs-profile.json')               = $profileText
                (Join-Path -Path 'repo-root' -ChildPath 'docs/documentation-estate/docs-validation-receipt.json')    = $receiptText
                (Join-Path -Path 'repo-root' -ChildPath 'docs/documentation-estate/surface-inventory-snapshot.json') = $snapshotText
            }
            Mock Get-DocsCompleteGateFileText -MockWith ({ param([string] $Path) if ($files.ContainsKey($Path)) { $files[$Path] } else { $null } }.GetNewClosure())
            $prText = [ordered]@{ baseRefName = 'main'; headRefName = 'epic/docs-integration'; headRefOid = $Head } | ConvertTo-Json -Compress
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $prText } }.GetNewClosure())
            $ancestorResult = [pscustomobject]@{ ExitCode = $AncestorExit; Output = '' }
            $diffResult = [pscustomobject]@{ ExitCode = $DiffExit; Output = $DiffOutput }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'merge-base' } -MockWith ({ $ancestorResult }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' } -MockWith ({ $diffResult }.GetNewClosure())
        }
    }

    AfterAll {
        Remove-Module -Name HookPayload, DocsCompleteGate, DocsReceiptRevision, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, AgentTargetWorktree, HookTargetWorktree -Force -ErrorAction SilentlyContinue
    }

    It 'allows an ancestor receipt revision with no source drift and runs the bounded ancestry and diff calls' {
        # Arrange
        Set-TestRevisionSeam

        # Act
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $script:Envelope

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        $expectedAncestor = "merge-base --is-ancestor $($script:ReceiptRevision) $($script:Head)"
        $expectedDiff = "diff --name-only -z --no-renames --no-relative $($script:ReceiptRevision) $($script:Head)"
        Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq $expectedAncestor -and $WorktreeRoot -ceq 'repo-root' }
        Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq $expectedDiff -and $WorktreeRoot -ceq 'repo-root' }
    }

    It 'denies RECEIPT_SOURCE_DRIFT when a changed path lies under a source root' {
        # Arrange
        Set-TestRevisionSeam -DiffOutput "docs/a.md`0src/tool.py`0"

        # Act
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $script:Envelope
        $reason = [string] $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_SOURCE_DRIFT: *'
        $reason | Should -BeLike "*'src/tool.py'*"
    }

    It 'denies RECEIPT_REVISION_NOT_ANCESTOR when git reports exit 1 for the ancestry check' {
        # Arrange
        Set-TestRevisionSeam -AncestorExit 1

        # Act
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $script:Envelope

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_REVISION_NOT_ANCESTOR: *'
    }

    It 'denies RECEIPT_REVISION_UNRESOLVED for <Case>' -ForEach @(
        @{ Case = 'an ancestry timeout (exit 124)'; AncestorExit = 124; DiffExit = 0; DiffOutput = "docs/a.md`0" }
        @{ Case = 'an ancestry non-zero exit (exit 128)'; AncestorExit = 128; DiffExit = 0; DiffOutput = "docs/a.md`0" }
        @{ Case = 'a diff timeout (exit 124)'; AncestorExit = 0; DiffExit = 124; DiffOutput = '' }
        @{ Case = 'a diff non-zero exit (exit 128)'; AncestorExit = 0; DiffExit = 128; DiffOutput = '' }
        @{ Case = 'diff output without a trailing NUL'; AncestorExit = 0; DiffExit = 0; DiffOutput = 'docs/a.md' }
    ) {
        # Arrange
        Set-TestRevisionSeam -AncestorExit $AncestorExit -DiffExit $DiffExit -DiffOutput $DiffOutput

        # Act
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $script:Envelope
        $reason = [string] $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_REVISION_UNRESOLVED: *'
        $reason | Should -BeLike '*git fetch*'
    }

    It 'allows a receipt revision equal to headRefOid with no Invoke-DocsOnlyGitExe call' {
        # Arrange
        Set-TestRevisionSeam -Head $script:ReceiptRevision

        # Act
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $script:Envelope

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies RECEIPT_REVISION_SNAPSHOT_MISMATCH when the snapshot is absent beneath the receipt root' {
        # Arrange
        Set-TestRevisionSeam
        $absentSnapshotKey = Join-Path -Path 'repo-root' -ChildPath 'docs/documentation-estate/surface-inventory-snapshot.json'
        Mock Get-DocsCompleteGateFileText -ParameterFilter { $Path -ceq $absentSnapshotKey } -MockWith { $null }

        # Act
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $script:Envelope

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_REVISION_SNAPSHOT_MISMATCH: *'
    }
}
