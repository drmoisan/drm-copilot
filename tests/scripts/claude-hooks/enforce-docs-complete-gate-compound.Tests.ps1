#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the compound-command scope of .claude/hooks/enforce-docs-complete-gate.ps1
    (issue #1034, finding F3).

.DESCRIPTION
    Dot-sources the hook and drives Invoke-DocsCompleteGateDecision with mocked root, file and gh
    seams. With the gate enabled, every merge that is not one plain gh pr merge denies
    PR_UNRESOLVED before any lookup; with the gate disabled or the profile absent the same command
    allows with no gh call. Text that only quotes a merge allows in both states. No row starts a
    process, runs gh or git, or writes a file.
#>

Describe 'enforce-docs-complete-gate compound commands (issue #1034)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-docs-complete-gate.ps1").Path
        . $script:UnderTest

        Mock Get-DocsCompleteGateRepositoryRoot { 'repo-root' }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        function ConvertTo-TestEnvelope {
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command)

            return (@{ session_id = 'session-1034'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Get-TestProfileText {
            [CmdletBinding()]
            [OutputType([string])]
            param([object] $Enabled = $true, [object] $ReceiptPath = 'docs/documentation-estate/docs-validation-receipt.json')

            return ([ordered]@{ artifact_paths = [ordered]@{ validation_receipt = $ReceiptPath }; completion_gates = [ordered]@{ integration_pr_gate = [ordered]@{ enabled = $Enabled } } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-TestFileSeam {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            [CmdletBinding()]
            param([AllowNull()][object] $ProfileText, [AllowNull()][object] $ReceiptText)

            $profileValue = $ProfileText
            $receiptValue = $ReceiptText
            # The hook joins the root and the relative path with Join-Path, which inserts the
            # platform separator; the expected paths are built the same way so the filters match
            # on Windows and Linux.
            Mock Get-DocsCompleteGateFileText -ParameterFilter { $Path -ceq (Join-Path -Path 'repo-root' -ChildPath 'docs/documentation-estate/docs-profile.json') } -MockWith ({ $profileValue }.GetNewClosure())
            Mock Get-DocsCompleteGateFileText -ParameterFilter { $Path -ceq (Join-Path -Path 'repo-root' -ChildPath 'docs/documentation-estate/docs-validation-receipt.json') } -MockWith ({ $receiptValue }.GetNewClosure())
        }
    }

    AfterAll {
        Remove-Module -Name HookPayload, DocsCompleteGate, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
    }

    Context 'compound merge scope (F3)' {
        BeforeDiscovery {
            $script:CompoundCommands = @(
                'if gh pr checks 12; then gh pr merge 12 --merge; fi'
                'for n in 12; do gh pr merge "$n" --merge; done'
                '! gh pr merge 12'
                'exec gh pr merge 12'
                'while true; do gh pr merge 12 --merge; break; done'
                'if false; then echo x; else gh pr merge 12; fi'
                'until gh pr merge 12; do sleep 1; done'
                'sudo gh pr merge 12'
                'nice gh pr merge 12'
                'coproc gh pr merge 12'
                'find . -maxdepth 0 -exec gh pr merge 12 \;'
                'gh pr checks 12 && gh pr merge 12 --merge'
                'case x in x) gh pr merge 12;; esac'
                'f() { gh pr merge 12; }; f'
                'time gh pr merge 12'
                'nohup gh pr merge 12'
                '(gh pr merge 12)'
                '{ gh pr merge 12; }'
                'if true; then gh api -X PUT repos/o/r/pulls/12/merge; fi'
                "! gh api graphql -f query='mutation{mergePullRequest(x)}'"
                'gh api -X PUT repos/{owner}/{repo}/pulls/12/merge'
            )
        }

        It 'denies PR_UNRESOLVED with no gh call for <Command>' -ForEach @(
            foreach ($command in $script:CompoundCommands) { @{ Command = $command } }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $null

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: *'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'allows <Command> with no gh call when the profile is <State>' -ForEach @(
            foreach ($state in @('disabled', 'absent')) {
                foreach ($command in $script:CompoundCommands) { @{ State = $state; Command = $command } }
            }
        ) {
            # Arrange
            $profileText = if ($State -eq 'absent') { $null } else { Get-TestProfileText -Enabled $false }
            Set-TestFileSeam -ProfileText $profileText -ReceiptText $null

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }
    }

    Context 'merge mentions' {
        It 'allows the quoted mention <Command> with no gh call when the gate is <State>' -ForEach @(
            foreach ($state in @('enabled', 'disabled')) {
                foreach ($command in @("git commit -m 'gh pr merge 12'", 'echo "gh pr merge 12"')) {
                    @{ State = $state; Command = $command }
                }
            }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText -Enabled ($State -eq 'enabled')) -ReceiptText $null

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'denies PR_UNRESOLVED with no gh call for the unquoted mention <Command> when the gate is enabled' -ForEach @(
            @{ Command = 'echo gh pr merge 12' }
            @{ Command = 'gh pr view 12 && git merge main' }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $null

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: *'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'allows the unquoted mention <Command> with no gh call when the gate is disabled' -ForEach @(
            @{ Command = 'echo gh pr merge 12' }
            @{ Command = 'gh pr view 12 && git merge main' }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText -Enabled $false) -ReceiptText $null

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }
    }
}
