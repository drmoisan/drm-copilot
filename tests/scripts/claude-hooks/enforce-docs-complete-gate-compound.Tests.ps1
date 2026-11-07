#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the compound-command scope of .claude/hooks/enforce-docs-complete-gate.ps1
    (issue #1034, finding F3).

.DESCRIPTION
    Dot-sources the hook and drives Invoke-DocsCompleteGateDecision with mocked root, file and gh
    seams. With the gate enabled, a merge the hook reads that is not one plain gh pr merge denies
    PR_UNRESOLVED before any lookup; with the gate disabled or the profile absent the same command
    allows with no gh call. Text that only quotes a merge allows in both states. Context
    'residual limits' pins forms outside what the hook observes, which allow with the gate
    enabled. No row starts a process, runs gh or git, or writes a file.
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
                # F4: a comment joined to a later command by a backslash-newline. Bash ends a
                # comment at the newline, so the later command runs.
                "gh pr merge 34 # x\`ngh pr merge 12"
                "gh pr merge 34 # first line \`ngh pr merge 12 # second"
                "gh pr merge 34 \`n# x\`ngh pr merge 12"
                "gh pr view 34 # x\`ngh pr merge 12"
                "gh pr merge --disable-auto # x\`ngh pr merge 12"
                "gh pr view 34 --json title # x\`ngh api -X PUT repos/o/r/pulls/12/merge"
                "gh pr merge 34 # x\`r`ngh pr merge 12"
                "gh pr merge \`n12 # note"
                # W: a word split by a backslash-newline, which bash joins.
                "gh pr mer\`nge 12"
                "g\`nh pr merge 12"
                "gh p\`nr merge 12"
                "gh pr mer\`r`nge 12"
                "true; gh pr mer\`nge 12"
                # F5: a quoted payload beside an evaluator word, and a backslash in a word.
                "if true; then sh -c 'gh pr merge 12'; fi"
                'if true; then bash -c "gh pr merge 12"; fi'
                "! sh -c 'gh pr merge 12'"
                "exec sh -c 'gh pr merge 12'"
                'for n in 12; do sh -c "gh pr merge $n"; done'
                "if true; then eval 'gh pr merge 12'; fi"
                "! eval 'gh pr merge 12'"
                "nice sh -c 'gh pr merge 12'"
                "find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;"
                "sudo sh -c 'gh pr merge 12'"
                "if true; then bash <<EOF`ngh pr merge 12`nEOF`nfi"
                "echo 'gh pr merge 12' | sh"
                "printf 'gh pr merge 12' | bash"
                'g\h pr merge 12'
                'gh pr mer\ge 12'
                'gh p\r merge 12'
                'true; g\h pr merge 12'
                'g\h api -X PUT repos/o/r/pulls/12/merge'
                "if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi"
                "echo 'gh api -X PUT repos/o/r/pulls/12/merge' | bash"
                "if true; then ksh -c 'gh pr merge 12'; fi"
                "if true; then pwsh -Command 'gh pr merge 12'; fi"
                "source <(echo 'gh pr merge 12')"
                "echo bash 'gh pr merge 12'"
                "./run.sh 'gh pr merge 12'"
                # D: an accepted false deny the limit statement names.
                'gh api -X GET repos/o/r/pulls/12/merge'
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
                foreach ($command in @("git commit -m 'gh pr merge 12'", 'echo "gh pr merge 12"', "git log --grep='gh pr merge'", "git commit -m 'gh api -X PUT repos/o/r/pulls/12/merge'")) {
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

    Context 'residual limits' {
        # These rows pin the limit statement of the hook header. A later change that makes one of
        # them deny is a stated change of that limit.
        It 'allows <Command> with no gh call with the gate enabled because it is outside what the hook observes' -ForEach @(
            @{ Command = 'python -c "import os; os.system(''gh pr merge 12'')"' }
            @{ Command = 'node -e "require(''child_process'').execSync(''gh pr merge 12'')"' }
            @{ Command = 'curl -X PUT https://api.github.com/repos/o/r/pulls/12/merge' }
            @{ Command = './merge.sh' }
            @{ Command = 'sh merge.sh' }
            @{ Command = 'a=g; b=h; $a$b pr merge 12' }
            @{ Command = '$(echo ''gh pr merge 12'')' }
            @{ Command = 'if true; then "gh" pr merge 12; fi' }
            @{ Command = '! gh pr ''merge'' 12' }
            @{ Command = 'exec gh ''pr'' merge 12' }
            @{ Command = 'gh pr me${x}rge 12' }
            @{ Command = 'trap ''gh pr merge 12'' EXIT' }
            @{ Command = 'gh alias set m ''pr merge 12''; gh m' }
            @{ Command = 'gh api graphql -F query=@f.graphql' }
            @{ Command = 'gh api graphql --input f' }
            @{ Command = 'gh api -X PUT repos/o/r/pulls/$n/merge' }
            @{ Command = 'git push origin HEAD:main' }
        ) {
            # Arrange
            Set-TestFileSeam -ProfileText (Get-TestProfileText) -ReceiptText $null

            # Act
            $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-TestEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }
    }
}
