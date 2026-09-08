#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping tests for enforce-pr-author-skill-helpers.ps1 (issue #545).

.DESCRIPTION
    Get-PrAuthorBypassReason used to classify a command by matching the raw text against
    '\bgh\s+pr\s+create\b' and '\bgh\s+pr\s+edit\b', and to detect its body flags with
    '--body-file\b' and '--body(?!-file)\b'. Both directions of the issue #545 defect class
    followed: quoted prose that merely MENTIONED the phrase was gated, and a relocating
    spelling that carried a gh global option between 'gh' and 'pr' was never gated at all.

    This file is a sibling of enforce-pr-author-skill.Tests.ps1 rather than an extension of
    it: that file measures 447 lines, and adding this 280-line matrix in place would take it
    to 727, well past the repository's 500-line cap.

    Determinism: every case drives Invoke-PrAuthorSkillDecision or a pure parser predicate.
    Every disk seam the decision can reach is mocked, so no case reads live orchestration
    state, and no case writes a temporary file or starts a process.
#>

Describe 'enforce-pr-author-skill trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest

        # SHA-256 (lowercase hex) of a single 0x41 ('A') byte.
        $script:HashOf0x41 = '559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd'

        function ConvertTo-CommandEnvelope {
            <#
            .SYNOPSIS
                Builds a PreToolUse Bash envelope carrying one command string.
            #>
            param(
                [Parameter(Mandatory)]
                [AllowEmptyString()]
                [string] $Command
            )

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    Context 'over-match removal - a quoted mention is not an invocation' {
        BeforeEach {
            # Context absent, so anything this gate classifies denies PR_CONTEXT_MISSING.
            # An allow therefore proves the command was never classified.
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
        }

        It 'allows a quoted --body-file mention inside a JSON receipt value' {
            $command = 'echo ''{"cmd":"gh pr create --body-file artifacts/pr_body_545.md"}'' > artifacts/receipt.json'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'the echo segment mentions the phrase inside a quoted span and invokes nothing'
        }
    }

    Context 'under-match removal - a relocating spelling now classifies' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
        }

        It 'classifies gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md' {
            $command = 'gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
        }

        It 'classifies gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md' {
            $command = 'gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
        }
    }

    Context 'flag distinction - --body does not match --body-file' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
        }

        It 'does not match --body against a --body-file token' {
            # The presence-only predicate replaces the '--body(?!-file)\b' lookahead. Exact
            # token comparison is the mechanism, so the distinction is checked directly.
            Test-CommandLineFlag -CommandText 'gh pr create --body-file artifacts/pr_body_545.md' `
                -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--body' |
                Should -BeFalse

            Test-CommandLineFlag -CommandText 'gh pr create --body "inline text"' `
                -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--body' |
                Should -BeTrue

            # End to end: a --body-file command must not be reported as an inline body.
            $command = 'gh pr create --title "foo" --body-file artifacts/pr_body_545.md'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }
    }

    Context 'wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
        }

        It 'wrapper deny pin 1: classifies a gh pr create relocated through xargs' {
            $command = 'echo artifacts/pr_body_545.md | xargs gh pr create'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the xargs segment is wrapper-led and scans raw'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument' {
            $command = "bash -c 'gh pr create --title x'"

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument' {
            $command = 'sh -c "gh pr create --title x"'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper' {
            $command = 'env gh pr create --title x'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier skips transparent wrappers'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper' {
            $command = 'pwsh -NoProfile -Command "gh pr create --title x"'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'pwsh is a member of the wrapper carve-out set'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'wrapper deny pin 6: classifies a heredoc body piped into bash' {
            # bash is in the wrapper carve-out set, so the segment scans raw and the
            # heredoc body stays visible. This is the deliberate reversal against masking.
            $command = @'
bash <<'EOF'
gh pr create --title x
EOF
'@

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper-led heredoc body is executed, not inert data'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'wrapper deny pin 7: classifies a live substitution inside a double-quoted span' {
            $command = 'echo "$(gh pr create --title x)"'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a live substitution inside double quotes forces a raw scan'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }
    }

    Context 'every PR_* reason code is still produced for its genuine triggering invocation' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith {
                [DateTime]::Parse('2026-06-24T12:00:00Z').ToUniversalTime()
            }
        }

        It 'PR_AUTHOR_SKILL_BLOCKED for gh pr create with no body flag' {
            $command = 'gh pr create --title "foo"'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'PR_CONTEXT_MISSING for gh pr create --body-file when the context artifact is absent' {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
            $command = 'gh pr create --title "foo" --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
        }

        It 'PR_BODY_PATH_NONCANONICAL for a --body-file path outside the canonical pattern' {
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith { $null }
            $command = 'gh pr create --title "foo" --body-file artifacts/pr_body.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_BODY_PATH_NONCANONICAL'
        }

        It 'PR_AUTHOR_RECEIPT_MISSING when the sibling receipt is absent' {
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith { $null }
            $command = 'gh pr create --title "foo" --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_MISSING'
        }

        It 'PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when the receipt number does not equal the path number' {
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                "{`"number`":12,`"sha256`":`"$script:HashOf0x41`",`"created_at`":`"2026-06-24T12:00:05Z`"}"
            }
            $command = 'gh pr create --title "foo" --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_NUMBER_MISMATCH'
        }

        It 'PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body hash does not equal the recorded hash' {
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                '{"number":545,"sha256":"0000000000000000000000000000000000000000000000000000000000000000","created_at":"2026-06-24T12:00:05Z"}'
            }
            $command = 'gh pr create --title "foo" --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_HASH_MISMATCH'
        }

        It 'PR_AUTHOR_RECEIPT_STALE when created_at is not newer than the context last-write' {
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                "{`"number`":545,`"sha256`":`"$script:HashOf0x41`",`"created_at`":`"2026-06-24T11:00:00Z`"}"
            }
            $command = 'gh pr create --title "foo" --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_STALE'
        }
    }

    Context 'R-2.c wrapper-led body flags' {
        # Every case in this context drives Invoke-PrAuthorSkillDecision through the file's
        # ConvertTo-CommandEnvelope helper with a literal fixture and mocks
        # Get-PrContextArtifactExistence, so no case reads the context artifact from disk.
        It 'R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument' {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            $command = 'bash -c "gh pr edit 42 --body ''x''"'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case' {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
            $command = 'bash -c "gh pr edit 42 --body-file artifacts/pr_body_545.md"'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'R2c-N1 still routes a non-wrapper --body-file edit to the context check' {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
            $command = 'gh pr edit 42 --body-file artifacts/pr_body_545.md'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'R2c-N2 still allows a quoted --body mention inside a JSON receipt value' {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
            $command = 'echo ''{"cmd":"gh pr edit 42 --body x"}'' > artifacts/receipt.json'

            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
