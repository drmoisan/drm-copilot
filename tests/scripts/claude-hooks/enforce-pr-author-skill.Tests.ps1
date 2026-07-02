#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-pr-author-skill.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest

        # SHA-256 (lowercase hex) of a single 0x41 ('A') byte, used by the receipt allow/hash tests.
        $script:HashOf0x41 = '559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd'
    }

    Context 'tool input parsing' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when JSON has no command field' {
            $json = '{"other":"value"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-PrAuthorSkillDecision -ToolInputRaw '{not-json' } | Should -Throw
        }
    }

    Context 'gh pr create - inline body (Case A)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
        }

        It 'blocks gh pr create --body "inline string"' {
            $json = '{"command":"gh pr create --title \"foo\" --body \"inline string\""}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It "blocks gh pr create --body='inline' (equals-sign form)" {
            $json = '{"command":"gh pr create --title \"foo\" --body=''inline text''"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }
    }

    Context 'gh pr edit - inline body (Case A)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
        }

        It 'blocks gh pr edit --body "inline text" (no --body-file)' {
            # Inline --body on gh pr edit must be blocked by Case A before the no-body allow path.
            $json = '{"command":"gh pr edit 42 --body \"inline text\""}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It "blocks gh pr edit --body='inline' (equals-sign form, no --body-file)" {
            # Equals-sign inline --body on gh pr edit must also be blocked by Case A.
            $json = '{"command":"gh pr edit 42 --body=''inline''"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'allows gh pr edit --title "x" (no body flag remains allowed)' {
            # Regression guard: an edit with no body flag must remain allowed after the Case A change.
            $json = '{"command":"gh pr edit 42 --title \"x\""}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'gh pr create - missing body (Case B)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
        }

        It 'blocks gh pr create with no body flags' {
            $json = '{"command":"gh pr create"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '--body-file'
        }

        It 'blocks gh pr create --title foo with no body flags' {
            $json = '{"command":"gh pr create --title \"my feature\""}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '--body-file'
        }
    }

    Context 'gh pr create/edit - missing context artifact (Case C)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $false }
        }

        It 'blocks gh pr create --body-file artifacts/pr_body_12.md when context is absent' {
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'collect_pr_context'
        }

        It 'blocks gh pr edit --body-file artifacts/pr_body_12.md when context is absent' {
            $json = '{"command":"gh pr edit 42 --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_CONTEXT_MISSING'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'collect_pr_context'
        }
    }

    Context 'allowed commands' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            # A passing preflight mock so the existing allow assertions remain valid under the
            # new orchestrator-state check (see 'orchestrator-state preflight' Context above).
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
            # Supply a matching, in-date receipt so the extended --body-file path still allows.
            # Body bytes are a single 0x41 ('A'); the receipt sha256 is its SHA-256; created_at is
            # strictly newer than the mocked context-summary last-write time.
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                "{`"number`":12,`"sha256`":`"$script:HashOf0x41`",`"created_at`":`"2026-06-24T12:00:05Z`"}"
            }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-24T12:00:00Z').ToUniversalTime() }
        }

        It 'allows gh pr create --body-file artifacts/pr_body_12.md when context exists' {
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr edit --body-file artifacts/pr_body_12.md when context exists' {
            $json = '{"command":"gh pr edit 42 --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr edit --title "new title" (no body flag)' {
            $json = '{"command":"gh pr edit 42 --title \"new title\""}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr edit --add-label bug (no body flag)' {
            $json = '{"command":"gh pr edit 42 --add-label bug"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr view 13' {
            $json = '{"command":"gh pr view 13"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr list' {
            $json = '{"command":"gh pr list"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr merge' {
            $json = '{"command":"gh pr merge 42 --squash"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr checkout 13' {
            $json = '{"command":"gh pr checkout 13"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh issue create (not guarded by this hook)' {
            $json = '{"command":"gh issue create --title foo"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
        }

        It 'blocks a --body-file artifacts/pr_body.md (no number) with PR_BODY_PATH_NONCANONICAL' {
            # The canonical pattern requires artifacts/pr_body_<N>.md; a numberless path is rejected
            # before any receipt read, using injectable seams only (no disk/network/temp files).
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_BODY_PATH_NONCANONICAL'
        }
    }

    Context 'receipt - missing (PR_AUTHOR_RECEIPT_MISSING)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
        }

        It 'blocks with PR_AUTHOR_RECEIPT_MISSING when the receipt read seam returns null' {
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith { $null }
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_MISSING'
        }
    }

    Context 'receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
        }

        It 'blocks with PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when receipt.number does not match the path number' {
            # Canonical path number is 5; the receipt declares number 7.
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                '{"number":7,"sha256":"abc","created_at":"2026-06-24T12:00:05Z"}'
            }
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_5.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_NUMBER_MISMATCH'
        }
    }

    Context 'receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
        }

        It 'blocks with PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body SHA-256 does not match receipt.sha256' {
            # Number matches first; body bytes are 0x41 but the receipt sha256 is a wrong value.
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                '{"number":12,"sha256":"0000000000000000000000000000000000000000000000000000000000000000","created_at":"2026-06-24T12:00:05Z"}'
            }
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_HASH_MISMATCH'
        }
    }

    Context 'receipt - stale (PR_AUTHOR_RECEIPT_STALE)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
        }

        It 'blocks with PR_AUTHOR_RECEIPT_STALE when created_at is not strictly newer than the context last-write' {
            # Number and sha256 match (body = 0x41); created_at equals/precedes the context last-write.
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                "{`"number`":12,`"sha256`":`"$script:HashOf0x41`",`"created_at`":`"2026-06-27T10:00:00Z`"}"
            }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_RECEIPT_STALE'
        }
    }

    Context 'receipt - all checks pass (allow)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
            # Canonical path, present receipt, matching number, matching inline-computed sha256, and
            # a created_at strictly newer than the context last-write time.
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                "{`"number`":12,`"sha256`":`"$script:HashOf0x41`",`"created_at`":`"2026-06-27T12:00:00Z`"}"
            }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }
        }

        It 'allows when all five receipt checks pass' {
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Get-PrAuthorBypassReason helper' {
        BeforeEach {
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
            # Matching, in-date receipt so the extended --body-file path still allows.
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                "{`"number`":1,`"sha256`":`"$script:HashOf0x41`",`"created_at`":`"2026-06-27T12:00:00Z`"}"
            }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }
        }

        It 'returns null for allowed command' {
            $result = Get-PrAuthorBypassReason -CommandText 'gh pr create --body-file artifacts/pr_body_1.md' -ContextExists $true
            $result | Should -BeNullOrEmpty
        }

        It 'returns PR_AUTHOR_SKILL_BLOCKED for inline --body' {
            $result = Get-PrAuthorBypassReason -CommandText 'gh pr create --body "some text"' -ContextExists $true
            $result | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'returns PR_CONTEXT_MISSING when --body-file present but context absent' {
            $result = Get-PrAuthorBypassReason -CommandText 'gh pr create --body-file artifacts/pr_body_1.md' -ContextExists $false
            $result | Should -Match 'PR_CONTEXT_MISSING'
        }
    }

    Context 'decision builders emit the PreToolUse schema' {
        It 'Get-PrAuthorSkillBlockDecision yields hookEventName=PreToolUse and permissionDecision=deny after serialize-then-parse' {
            $d = Get-PrAuthorSkillBlockDecision -Reason 'PR_AUTHOR_SKILL_BLOCKED: test reason'
            $parsed = $d | ConvertTo-Json -Depth 5 | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'Get-PrAuthorSkillAllowDecision yields permissionDecision=allow' {
            $d = Get-PrAuthorSkillAllowDecision
            $parsed = $d | ConvertTo-Json -Depth 5 | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Test-PrAuthorBypassRequired helper' {
        BeforeEach {
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
            # Matching, in-date receipt so the extended --body-file path still allows.
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                "{`"number`":1,`"sha256`":`"$script:HashOf0x41`",`"created_at`":`"2026-06-27T12:00:00Z`"}"
            }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }
        }

        It 'returns false for an allowed command' {
            Test-PrAuthorBypassRequired -CommandText 'gh pr create --body-file artifacts/pr_body_1.md' -ContextExists $true |
                Should -BeFalse
        }

        It 'returns true for a blocked command (inline --body)' {
            Test-PrAuthorBypassRequired -CommandText 'gh pr create --body "text"' -ContextExists $true |
                Should -BeTrue
        }

        It 'returns true when context is missing for --body-file command' {
            Test-PrAuthorBypassRequired -CommandText 'gh pr edit 5 --body-file artifacts/pr_body_1.md' -ContextExists $false |
                Should -BeTrue
        }
    }

    Context 'Get-PrContextArtifactExistence real Test-Path wrapper' {
        It 'returns a boolean result without throwing' {
            $result = Get-PrContextArtifactExistence
            $result | Should -BeOfType [bool]
        }
    }

    Context 'Get-PrBodyFileBytes real read seam' {
        It 'returns $null when the body-file path does not exist' {
            Get-PrBodyFileBytes -BodyFilePath 'artifacts/this-body-path-does-not-exist.md' | Should -BeNullOrEmpty
        }

        It 'returns the raw bytes when the path exists (points at the hook script itself)' {
            # Point the seam at an existing real file (no temporary file is created).
            $bytes = Get-PrBodyFileBytes -BodyFilePath $script:UnderTest
            $bytes | Should -Not -BeNullOrEmpty
            $bytes.Count | Should -BeGreaterThan 0
        }
    }

    Context 'Get-PrAuthorReceiptContent real read seam' {
        It 'returns $null when the receipt path does not exist' {
            Get-PrAuthorReceiptContent -ReceiptFilePath 'artifacts/this-receipt-path-does-not-exist.json' | Should -BeNullOrEmpty
        }

        It 'returns the raw file text when the receipt path exists (points at the hook script itself)' {
            # Point the seam at an existing real file (no temporary file is created).
            $content = Get-PrAuthorReceiptContent -ReceiptFilePath $script:UnderTest
            $content | Should -Not -BeNullOrEmpty
            $content | Should -Match 'PR_AUTHOR_RECEIPT_MISSING'
        }
    }

    Context 'Get-PrContextSummaryLastWriteUtc real seam' {
        It 'returns $null when the context summary path does not exist' {
            $prev = $script:PrContextArtifactPath
            try {
                $script:PrContextArtifactPath = 'artifacts/this-context-path-does-not-exist.txt'
                Get-PrContextSummaryLastWriteUtc | Should -BeNullOrEmpty
            } finally {
                $script:PrContextArtifactPath = $prev
            }
        }

        It 'returns a UTC DateTime when the context path exists (points at the hook script itself)' {
            $prev = $script:PrContextArtifactPath
            try {
                $script:PrContextArtifactPath = $script:UnderTest
                $when = Get-PrContextSummaryLastWriteUtc
                $when | Should -BeOfType [datetime]
                $when.Kind | Should -Be ([System.DateTimeKind]::Utc)
            } finally {
                $script:PrContextArtifactPath = $prev
            }
        }
    }

    Context 'Invoke-PrAuthorSkillDecision without mock (real context lookup)' {
        It 'blocks gh pr create with no body flags regardless of context artifact' {
            $json = '{"command":"gh pr create --title \"foo\""}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }
    }

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                ($out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'blocks gh pr create inline --body end-to-end (exit 0, block, PR_AUTHOR_SKILL_BLOCKED)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{"command":"gh pr create --title \"foo\" --body \"inline\""}'
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                $parsed = $out | ConvertFrom-Json
                $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
                $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'exits 1 on malformed JSON' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
