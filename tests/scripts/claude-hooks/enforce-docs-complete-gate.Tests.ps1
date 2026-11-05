#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/hooks/enforce-docs-complete-gate.ps1 (issue #1034).

.DESCRIPTION
    Dot-sources the hook and drives Invoke-DocsCompleteGateDecision with mocked root, file and
    gh seams. Envelopes are built with ConvertTo-Json. No row starts a process, runs gh or git,
    or writes a file; the seam rows read only the hook's own committed file. Paths are
    forward-slash relative with exact case.
#>

Describe 'enforce-docs-complete-gate (issue #1034)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-docs-complete-gate.ps1").Path
        . $script:UnderTest

        $script:Root = 'repo-root'
        $script:ProfileSuffix = 'docs/documentation-estate/docs-profile.json'
        $script:ReceiptSuffix = 'docs/documentation-estate/docs-validation-receipt.json'
        $script:Head = '0123456789abcdef0123456789abcdef01234567'
        $script:OtherHead = 'fedcba9876543210fedcba9876543210fedcba98'
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

        function Get-TestReceiptText {
            [CmdletBinding()]
            [OutputType([string])]
            param([string] $Kind = 'docs-validation-receipt', [string] $Mode = 'docs-complete', [string] $Result = 'pass', [string] $Revision = '0123456789abcdef0123456789abcdef01234567')

            return ([ordered]@{ artifact_kind = $Kind; mode = $Mode; revision = $Revision; validation_result = $Result } | ConvertTo-Json -Compress)
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

        function Set-TestPullRequestSeam {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            [CmdletBinding()]
            param([string] $Base = 'main', [string] $HeadRef = 'epic/documentation-estate-tooling-integration', [string] $HeadOid = '0123456789abcdef0123456789abcdef01234567')

            $output = [ordered]@{ baseRefName = $Base; headRefName = $HeadRef; headRefOid = $HeadOid } | ConvertTo-Json -Compress
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $output } }.GetNewClosure())
        }
    }

    AfterAll {
        Remove-Module -Name HookPayload, DocsCompleteGate, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
    }

    Context 'gate disabled' {
        It 'allows <Command> with no gh call when the profile is <State>' -ForEach @(
            foreach ($state in @('absent', 'disabled')) {
                foreach ($command in @('gh pr merge', 'gh pr merge 7 --squash', 'gh pr merge 7 --auto', 'gh pr merge 7 --admin', 'gh api -X PUT repos/o/r/pulls/7/merge', 'git status', 'gh pr view 7')) {
                    @{ State = $state; Command = $command }
                }
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

    Context 'gate enabled' {
        It 'allows a non-merge command with no file read and no gh call' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'git log --oneline')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Get-DocsCompleteGateFileText -Times 0 -Exactly
        }

        It 'allows an envelope whose tool_input has no command' {
            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw '{"session_id":"s","tool_name":"Bash","tool_input":{"description":"no command"}}'

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a passing receipt whose revision equals headRefOid and looks up the named pull request' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 7 --json baseRefName,headRefName,headRefOid' -and $WorkingRoot -ceq 'repo-root' }
        }

        It 'looks up the current-branch pull request for a bare merge' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge --squash')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view --json baseRefName,headRefName,headRefOid' }
        }

        It 'allows a merge whose pull request is not the integration target (<Case>)' -ForEach @(
            @{ Case = 'feature head'; Base = 'main'; HeadRef = 'feature/x-1' }
            @{ Case = 'integration head into another base'; Base = 'development'; HeadRef = 'epic/docs-integration' }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $null
            Set-TestPullRequestSeam -Base $Base -HeadRef $HeadRef

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies <Code> for an integration pull request' -ForEach @(
            @{ Code = 'RECEIPT_ABSENT'; Receipt = $null }
            @{ Code = 'RECEIPT_UNREADABLE'; Receipt = '{"artifact_kind":' }
            @{ Code = 'RECEIPT_MODE'; Receipt = '{"artifact_kind":"docs-validation-receipt","mode":"matrix","revision":"0123456789abcdef0123456789abcdef01234567","validation_result":"pass"}' }
            @{ Code = 'RECEIPT_FAILING'; Receipt = '{"artifact_kind":"docs-validation-receipt","mode":"docs-complete","revision":"0123456789abcdef0123456789abcdef01234567","validation_result":"fail"}' }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $Receipt
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED:*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "DOCS_COMPLETE_GATE_BLOCKED: ${Code}: *"
        }

        It 'denies RECEIPT_REVISION_MISMATCH and names both revisions' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText -Revision $script:OtherHead)
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_REVISION_MISMATCH: *'
            $reason | Should -Match $script:OtherHead
            $reason | Should -Match $script:Head
        }

        It 'denies PROFILE_UNREADABLE for a malformed profile with no gh call' {
            # Arrange
            Set-TestFileSeam -ProfileText '{"completion_gates":' -ReceiptText $null

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PROFILE_UNREADABLE: *'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'denies PR_UNRESOLVED when <Case>' -ForEach @(
            @{ Case = 'gh fails'; ExitCode = 1; Output = '' }
            @{ Case = 'gh returns unreadable text'; ExitCode = 0; Output = 'not json' }
            @{ Case = 'the head revision is not a full lowercase object id'; ExitCode = 0; Output = '{"baseRefName":"main","headRefName":"epic/docs-integration","headRefOid":"ABC"}' }
            @{ Case = 'a field is missing'; ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)
            $code = $ExitCode
            $text = $Output
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = $code; Output = $text } }.GetNewClosure())

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: *'
        }

        It 'denies MATCH_HEAD_MISMATCH when --match-head-commit differs from headRefOid' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command "gh pr merge 7 --merge --match-head-commit $($script:OtherHead)")

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: MATCH_HEAD_MISMATCH: *'
        }

        It 'allows when --match-head-commit equals headRefOid' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command "gh pr merge 7 --merge --match-head-commit $($script:Head)")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies RECEIPT_PATH_INVALID when the receipt path is <Case>' -ForEach @(
            @{ Case = 'absolute'; ReceiptPath = '/tmp/receipt.json' }
            @{ Case = 'a parent traversal'; ReceiptPath = '../receipt.json' }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText -ReceiptPath $ReceiptPath) -ReceiptText (Get-TestReceiptText)
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_PATH_INVALID: *'
        }
    }

    Context 'payload anomaly' {
        It 'denies an envelope it cannot read (<Case>)' -ForEach @(
            @{ Case = 'empty payload'; Raw = '' }
            @{ Case = 'unparseable JSON'; Raw = '{not json' }
        ) {
            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $Raw

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PAYLOAD_ANOMALY: *'
        }
    }

    Context 'entry point' {
        It 'writes the compact decision JSON and returns 0 for a supplied payload' {
            # Act
            $output = @(Invoke-DocsCompleteGateEntryPoint -ToolInputRaw (ConvertTo-TestEnvelope -Command 'git status'))

            # Assert
            $output[-1] | Should -Be 0
            ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'acquires the payload through the ReadPayload seam when none is supplied' {
            # Act
            $output = @(Invoke-DocsCompleteGateEntryPoint -ReadPayload { '' })

            # Assert
            $output[-1] | Should -Be 0
            ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

}

Describe 'enforce-docs-complete-gate seams (issue #1034)' {
    BeforeAll {
        $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-docs-complete-gate.ps1").Path
        . $script:HookPath
    }

    AfterAll {
        Remove-Module -Name HookPayload, DocsCompleteGate, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
    }

    It 'returns the repository root two levels above the hook directory' {
        # Act
        $root = Get-DocsCompleteGateRepositoryRoot

        # Assert
        $expected = [System.IO.Path]::GetFullPath((Join-Path -Path (Split-Path -Parent $script:HookPath) -ChildPath '../..'))
        $root | Should -BeExactly $expected
    }

    It 'returns $null for a path that does not exist' {
        # Act
        $text = Get-DocsCompleteGateFileText -Path (Join-Path -Path (Split-Path -Parent $script:HookPath) -ChildPath 'enforce-docs-complete-gate.absent.json')

        # Assert
        $text | Should -BeNullOrEmpty
    }

    It 'returns the text of an existing file (the hook itself, read only)' {
        # Act
        $text = Get-DocsCompleteGateFileText -Path $script:HookPath

        # Assert
        $text | Should -Match 'DOCS_COMPLETE_GATE_BLOCKED'
    }
}
