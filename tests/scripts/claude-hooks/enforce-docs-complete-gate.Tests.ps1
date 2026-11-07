#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/hooks/enforce-docs-complete-gate.ps1 (issue #1034).

.DESCRIPTION
    Dot-sources the hook and drives Invoke-DocsCompleteGateDecision with mocked root, file and
    gh seams. Envelopes are built with ConvertTo-Json. No row starts a process, runs gh or git,
    or writes a file; the seam rows read only the hook's own committed file and the hook
    directory, which forces a real read failure with no temporary file. Paths are forward-slash
    relative with exact case.
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

        # Answers by selector as gh does: no selector is the current branch, 99 is an unrelated pull
        # request, and every spelling of the integration pull request resolves it. Anything else
        # exits 1, so a lookup that loses the selector or the repository cannot pass by accident.
        $script:JsonSuffix = ' --json baseRefName,headRefName,headRefOid'
        $integrationPr = [ordered]@{ baseRefName = 'main'; headRefName = 'epic/x-integration'; headRefOid = $script:Head } | ConvertTo-Json -Compress
        $unrelatedPr = [ordered]@{ baseRefName = 'main'; headRefName = 'feature/other'; headRefOid = $script:Head } | ConvertTo-Json -Compress
        $script:LookupAnswers = @{
            "pr view$($script:JsonSuffix)"                                = [ordered]@{ baseRefName = 'development'; headRefName = 'feature/current-branch'; headRefOid = $script:Head } | ConvertTo-Json -Compress
            "pr view 99$($script:JsonSuffix)"                             = $unrelatedPr
            "pr view #99$($script:JsonSuffix)"                            = $unrelatedPr
            "pr view 1$($script:JsonSuffix)"                              = $unrelatedPr
            "pr view 12$($script:JsonSuffix)"                             = $integrationPr
            "pr view #12$($script:JsonSuffix)"                            = $integrationPr
            "pr view epic/x-integration$($script:JsonSuffix)"             = $integrationPr
            "pr view https://github.com/o/r/pull/12$($script:JsonSuffix)" = $integrationPr
            "pr view 12 --repo other/repo$($script:JsonSuffix)"           = $integrationPr
        }

        function Set-TestTargetSeam {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            [CmdletBinding()]
            param()

            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $null
            Mock Invoke-DocsOnlyGhExe -MockWith {
                $key = $GhArgs -join ' '
                if ($script:LookupAnswers.ContainsKey($key)) { return [pscustomobject]@{ ExitCode = 0; Output = $script:LookupAnswers[$key] } }
                return [pscustomobject]@{ ExitCode = 1; Output = '' }
            }
        }

        # A checkout of the integration branch: no selector resolves the integration pull request,
        # and #99 and 1 each resolve an unrelated one, so a lookup that reads a comment or a boolean
        # flag value as a selector finds a pull request the gate allows.
        $script:CheckoutAnswers = @{
            "pr view$($script:JsonSuffix)"     = $integrationPr
            "pr view #99$($script:JsonSuffix)" = $unrelatedPr
            "pr view 1$($script:JsonSuffix)"   = $unrelatedPr
        }

        function Set-TestIntegrationCheckoutSeam {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            [CmdletBinding()]
            param()

            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $null
            Mock Invoke-DocsOnlyGhExe -MockWith {
                $key = $GhArgs -join ' '
                if ($script:CheckoutAnswers.ContainsKey($key)) { return [pscustomobject]@{ ExitCode = 0; Output = $script:CheckoutAnswers[$key] } }
                return [pscustomobject]@{ ExitCode = 1; Output = '' }
            }
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

    Context 'merge target binding (F1)' {
        It 'looks up <Lookup> and denies RECEIPT_ABSENT for <Command>' -ForEach @(
            @{ Command = 'gh pr merge https://github.com/o/r/pull/12 --merge'; Lookup = 'https://github.com/o/r/pull/12' }
            @{ Command = 'gh pr merge epic/x-integration --merge'; Lookup = 'epic/x-integration' }
            @{ Command = 'gh pr merge --merge -- epic/x-integration'; Lookup = 'epic/x-integration' }
            @{ Command = 'gh pr merge --subject title epic/x-integration'; Lookup = 'epic/x-integration' }
            @{ Command = 'gh pr merge -sd epic/x-integration'; Lookup = 'epic/x-integration' }
            @{ Command = 'gh pr merge -sb 99 epic/x-integration'; Lookup = 'epic/x-integration' }
            @{ Command = 'gh pr merge 12 -R other/repo'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh pr merge 12 --repo other/repo'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh pr merge 12 --repo=other/repo'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh pr merge 12 -Rother/repo'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh pr merge 12 -R=other/repo'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh --repo other/repo pr merge 12'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh pr -R other/repo merge 12'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh --repo other/repo pr merge 12 -R other/repo'; Lookup = '12 --repo other/repo' }
            @{ Command = 'gh pr merge epic/x-integration > log'; Lookup = 'epic/x-integration' }
            @{ Command = 'gh pr merge epic/x-integration >log'; Lookup = 'epic/x-integration' }
            @{ Command = 'gh pr merge 12 #99'; Lookup = '12' }
            @{ Command = 'gh pr merge 12 # note; echo done'; Lookup = '12' }
            @{ Command = 'gh pr merge 12 # --disable-auto'; Lookup = '12' }
            @{ Command = 'gh pr merge 12 --subject --disable-auto'; Lookup = '12' }
            @{ Command = 'gh pr merge 12 --disable-auto=false'; Lookup = '12' }
            @{ Command = 'gh pr merge 12 --disable-auto=true'; Lookup = '12' }
            @{ Command = 'gh pr merge 12 --disable-auto --disable-auto=false'; Lookup = '12' }
            @{ Command = 'gh pr merge --merge=1 12'; Lookup = '12' }
            @{ Command = 'gh pr merge 12 >/dev/null 2>&1'; Lookup = '12' }
            @{ Command = 'gh pr merge "12"'; Lookup = '12' }
            @{ Command = "gh pr merge --subject 'a; b' 12"; Lookup = '12' }
            @{ Command = 'gh pr merge 12 --disable-auto --auto=false'; Lookup = '12' }
            @{ Command = 'gh pr merge "#12"'; Lookup = '#12' }
        ) {
            # Arrange
            Set-TestTargetSeam
            $expected = "pr view $Lookup$($script:JsonSuffix)"

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_ABSENT: *'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq $expected }
        }

        It 'denies PR_UNRESOLVED with no gh call for <Command>' -ForEach @(
            @{ Command = "gh api graphql -f query='mutation{mergePullRequest(input:{pullRequestId:`"PR_kw`"}){clientMutationId}}'" }
            @{ Command = "gh api graphql -f query='mutation{enqueuePullRequest(input:{pullRequestId:`"PR_kw`"}){clientMutationId}}'" }
            @{ Command = "gh api graphql -f query='mutation{enablePullRequestAutoMerge(input:{pullRequestId:`"PR_kw`"}){clientMutationId}}'" }
            @{ Command = "gh api graphql -f query='mutation{mergePullRequest(x)}' repos/o/r/pulls/12/merge" }
            @{ Command = 'gh pr merge 99 --merge; gh pr merge 12 --merge' }
            @{ Command = 'gh pr merge 99 --merge; gh api -X PUT repos/o/r/pulls/12/merge' }
            @{ Command = 'gh --unknown pr merge 12' }
            @{ Command = "gh pr merge 12 'unbalanced" }
            @{ Command = 'echo 12 | xargs gh pr merge --merge' }
            @{ Command = 'gh pr merge $PR' }
            @{ Command = 'gh pr merge 12 -R $REPO' }
            @{ Command = 'gh pr merge 12 --unknown' }
            @{ Command = 'gh pr merge 12 -z' }
            @{ Command = 'gh pr merge 12 13' }
            @{ Command = 'gh pr merge -- -x' }
            @{ Command = 'gh pr merge 12 --repo bad' }
            @{ Command = 'gh pr merge 12 --repo' }
            @{ Command = 'gh --repo a/b pr merge 12 -R c/d' }
            @{ Command = 'gh api -X PUT https://api.github.com/repos/o/r/pulls/12/merge' }
            @{ Command = 'gh api --hostname ghe.example.com -X PUT repos/o/r/pulls/12/merge' }
            @{ Command = 'gh api -X PUT repos/o/r/pulls/12/merge repos/o/r/pulls/13/merge' }
            @{ Command = 'gh api -X PUT repos/$OWNER/r/pulls/12/merge' }
            @{ Command = 'cd ../other && gh pr merge 12 --merge' }
            @{ Command = 'pushd ../other; gh pr merge 12' }
            @{ Command = 'chdir ../other; gh pr merge 12' }
            @{ Command = 'Set-Location ../other; gh pr merge 12' }
            @{ Command = 'Push-Location ../other; gh pr merge 12' }
            @{ Command = 'sl ../other; gh pr merge 12' }
            @{ Command = 'GH_REPO=other/repo gh pr merge 12' }
            @{ Command = 'GH_HOST=ghe.example.com gh pr merge 12' }
            @{ Command = 'export GH_REPO=other/repo; gh pr merge 12' }
            @{ Command = 'gh pr merge 2>&1 12' }
            @{ Command = 'gh pr merge --merge 2>&1 epic/x-integration' }
            @{ Command = 'gh pr merge >log 2>&1 12' }
            @{ Command = 'gh pr merge &>log 12' }
            @{ Command = 'gh pr merge >&2 12' }
            @{ Command = 'gh pr merge {12..12}' }
            @{ Command = 'gh pr merge 1{2..2}' }
            @{ Command = 'gh pr merge 2>/dev/null 12' }
            @{ Command = 'gh pr merge > 99 12' }
            @{ Command = 'gh pr merge 12 &' }
            @{ Command = 'gh pr merge 12;' }
            @{ Command = 'env --chdir=../other gh pr merge 12' }
            @{ Command = 'builtin cd ../other; gh pr merge 12' }
            @{ Command = 'GIT_DIR=../other gh pr merge 12' }
            @{ Command = 'read GH_REPO; gh pr merge 12' }
            @{ Command = 'export GH_REPO; gh pr merge 12' }
            @{ Command = 'gh api -X PUT repos/other/repo/pulls/12/merge' }
            @{ Command = 'gh api -X PUT /repos/other/repo/pulls/12/merge' }
            @{ Command = 'timeout 30 gh pr merge epic/x-integration' }
            @{ Command = "sh -c 'gh pr merge epic/x-integration'" }
            @{ Command = 'gh pr merge 99 --disable-auto; gh pr merge epic/x-integration --merge' }
            @{ Command = 'cd ../other && gh pr merge https://github.com/o/r/pull/12 --merge' }
            @{ Command = 'gh pr merge 12 --merge; echo done' }
            @{ Command = 'gh pr view 12; gh pr merge 12 --merge' }
            @{ Command = "gh api -X PUT 'repos/{owner}/{repo}/pulls/12/merge'" }
            @{ Command = 'gh pr merge 12 --unknown x' }
        ) {
            # Arrange
            Set-TestTargetSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: *'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }
    }

    Context 'integration checkout (F1)' {
        It 'looks up the current branch and denies RECEIPT_ABSENT for <Command>' -ForEach @(
            @{ Command = 'gh pr merge #99' }
            @{ Command = 'gh pr merge --merge=1' }
            @{ Command = 'gh pr merge --merge' }
        ) {
            # Arrange
            Set-TestIntegrationCheckoutSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_ABSENT: *'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view --json baseRefName,headRefName,headRefOid' }
        }
    }

    Context 'merge target controls' {
        It 'looks up number 12 and denies RECEIPT_ABSENT for <Command>' -ForEach @(
            @{ Command = 'gh pr merge 12 --merge' }
            @{ Command = 'gh pr merge --merge=12' }
            @{ Command = 'gh pr merge 12 --merge 2>&1' }
        ) {
            # Arrange
            Set-TestTargetSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_ABSENT: *'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 12 --json baseRefName,headRefName,headRefOid' }
        }

        It 'looks up the current branch and allows <Command>' -ForEach @(
            @{ Command = 'gh pr merge --squash' }
            @{ Command = 'gh pr merge --help' }
            @{ Command = 'gh pr merge --squash 2>&1' }
            @{ Command = 'gh pr merge 12>x' }
        ) {
            # Arrange
            Set-TestTargetSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view --json baseRefName,headRefName,headRefOid' }
        }

        It 'allows <Command> with no gh call' -ForEach @(
            @{ Command = 'gh pr merge 12 --disable-auto' }
            @{ Command = "gh api graphql -f query='query{viewer{login}}'" }
            @{ Command = 'gh pr merge 12 --disable-auto # note' }
            @{ Command = 'gh pr view feature/merge' }
            @{ Command = 'gh --help pr merge' }
        ) {
            # Arrange
            Set-TestTargetSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'denies PR_UNRESOLVED for a full-length uppercase headRefOid' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)
            Set-TestPullRequestSeam -HeadOid $script:Head.ToUpperInvariant()

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: *'
        }
    }

    Context 'read failures (F2)' {
        It 'denies PROFILE_UNREADABLE with no gh call when the profile read throws' {
            # Arrange
            Mock Get-DocsCompleteGateFileText -MockWith { throw [System.IO.IOException]::new('locked: repo-root/docs/docs-profile.json') }

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PROFILE_UNREADABLE: *'
            $reason | Should -Not -Match '[\\/]'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'denies RECEIPT_UNREADABLE without claiming an absent file when the receipt read throws' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $null
            Mock Get-DocsCompleteGateFileText -ParameterFilter { $Path -like '*docs-validation-receipt.json' } -MockWith { throw [System.IO.IOException]::new('locked: repo-root/docs/receipt.json') }
            Set-TestPullRequestSeam

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_UNREADABLE: *'
            $reason | Should -Not -Match 'RECEIPT_ABSENT'
            $reason | Should -Not -Match '[\\/]'
        }

        It 'denies PR_UNRESOLVED when Invoke-DocsOnlyGhExe throws' {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText (Get-TestReceiptText)
            Mock Invoke-DocsOnlyGhExe -MockWith { throw [System.InvalidOperationException]::new('gh failed at repo-root/bin/gh') }

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command 'gh pr merge 7 --merge')

            # Assert
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: *'
            $reason | Should -Not -Match '[\\/]'
        }

        It 'returns 0 and emits a PAYLOAD_ANOMALY deny when ReadPayload throws' {
            # Act
            $output = @(Invoke-DocsCompleteGateEntryPoint -ReadPayload { throw 'read failed' })

            # Assert
            $output[-1] | Should -Be 0
            $reason = ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'DOCS_COMPLETE_GATE_BLOCKED: PAYLOAD_ANOMALY: *'
            $reason | Should -Not -Match '[\\/]'
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

    It 'returns $null when a parent directory does not exist' {
        # Act
        $text = Get-DocsCompleteGateFileText -Path (Join-Path -Path (Split-Path -Parent $script:HookPath) -ChildPath 'absent-directory/enforce-docs-complete-gate.absent.json')

        # Assert
        $text | Should -BeNullOrEmpty
    }

    It 'throws for an existing path that cannot be read as a file' {
        # Arrange
        $hookDirectory = Split-Path -Parent $script:HookPath

        # Act and Assert
        { Get-DocsCompleteGateFileText -Path $hookDirectory } | Should -Throw
    }

    It 'returns the text of an existing file (the hook itself, read only)' {
        # Act
        $text = Get-DocsCompleteGateFileText -Path $script:HookPath

        # Assert
        $text | Should -Match 'DOCS_COMPLETE_GATE_BLOCKED'
    }
}
