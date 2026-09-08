#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision-surface coverage for the Codex epic merge gate (issue #545, [P12-T9]).

.DESCRIPTION
    tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 and
    tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 between
    them drive the ready and unready checkpoint paths through
    Invoke-CodexEpicMergeDecision. Four decision branches carried no named case: the
    empty-and-required and malformed-and-optional branches of ConvertFrom-CodexMergeJson,
    the CI-gate conjunct of Test-CodexEpicMergeReady, and the non-Bash early return of the
    decision router. The entry point had none. This file supplies them.

    Entry-point cases: the hook's stdin-to-exit-code block is exercised in process by
    redirecting [System.Console]::In and [System.Console]::Error to in-memory readers and
    writers, which is the harness already established by
    tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1. The original readers are
    restored in a finally block.

    The entry point reads the two orchestration checkpoint files from disk before it calls
    the decision seam. Both entry-point cases below are therefore written so that their
    asserted outcome is invariant to the content and to the presence of those files: one
    supplies a non-Bash tool name, which returns before either checkpoint is consulted, and
    the other supplies malformed stdin, which throws before either checkpoint is consulted.
    No case writes to disk and no case creates a temporary file.

    Determinism: every other case drives a pure function with a literal fixture. No child
    process, no live executable, no ambient state in any assertion.
#>

Describe 'Codex enforce-epic-merge-gate decision surface (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
        . $script:UnderTest

        function Invoke-CodexMergeGateEntryPoint {
            <#
                Runs the hook's entry point in process against an in-memory stdin reader
                and captures its stdout, stderr, and exit code. The console readers and
                writers are restored in finally, so no later case observes a redirected
                console.
            #>
            param(
                [Parameter(Mandatory)][string] $HookPath,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $HookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = ($stdout -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
            }
        }
    }

    Context 'ConvertFrom-CodexMergeJson separates required from optional sources' {
        It 'throws a named EPIC_MERGE_GATE_BLOCKED error for an empty required source' {
            { ConvertFrom-CodexMergeJson -Raw '' -Name 'PreToolUse input' } |
                Should -Throw -ExpectedMessage 'EPIC_MERGE_GATE_BLOCKED: PreToolUse input is empty.'
        }

        It 'returns null rather than throwing for an empty optional source' {
            ConvertFrom-CodexMergeJson -Raw '' -Name 'child checkpoint' -Optional | Should -BeNullOrEmpty
        }

        It 'returns null rather than throwing for a malformed optional source' {
            # A corrupt checkpoint on the optional leg degrades to "no checkpoint", which
            # the readiness predicates then treat as not ready, rather than failing the hook.
            ConvertFrom-CodexMergeJson -Raw '{broken' -Name 'epic checkpoint' -Optional |
                Should -BeNullOrEmpty
        }

        It 'throws a named EPIC_MERGE_GATE_BLOCKED error for a malformed required source' {
            { ConvertFrom-CodexMergeJson -Raw '{broken' -Name 'PreToolUse input' } |
                Should -Throw -ExpectedMessage 'EPIC_MERGE_GATE_BLOCKED: PreToolUse input is malformed JSON:*'
        }

        It 'returns the parsed object for a well-formed required source' {
            $parsed = ConvertFrom-CodexMergeJson -Raw '{"route_id":"epic"}' -Name 'PreToolUse input'

            $parsed.route_id | Should -Be 'epic'
        }
    }

    Context 'Test-CodexEpicMergeReady requires a successful CI gate' {
        It 'reports not ready when the epic merge PR carries no ci_gate record' {
            $checkpoint = '{"epic_merge_pr":{"pr_number":410}}' | ConvertFrom-Json

            Test-CodexEpicMergeReady -Checkpoint $checkpoint -CommandPrNumber 410 | Should -BeFalse
        }

        It 'reports not ready when the ci_gate conclusion is not success' {
            $checkpoint = '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"failure"}}}' | ConvertFrom-Json

            Test-CodexEpicMergeReady -Checkpoint $checkpoint -CommandPrNumber 410 | Should -BeFalse
        }

        It 'reports ready when the ci_gate succeeded and the command names no PR number' {
            $checkpoint = '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"success"}}}' | ConvertFrom-Json

            Test-CodexEpicMergeReady -Checkpoint $checkpoint -CommandPrNumber $null | Should -BeTrue
        }
    }

    Context 'Test-CodexChildMergeReady requires a boolean epic_mode and a green step 9' {
        It 'reports not ready when epic_mode is the string true rather than the boolean' {
            $checkpoint = '{"epic_mode":"true","step9_status":"passed"}' | ConvertFrom-Json

            Test-CodexChildMergeReady -Checkpoint $checkpoint | Should -BeFalse
        }

        It 'reports not ready when step9_status is pending' {
            $checkpoint = '{"epic_mode":true,"step9_status":"pending"}' | ConvertFrom-Json

            Test-CodexChildMergeReady -Checkpoint $checkpoint | Should -BeFalse
        }
    }

    Context 'the decision router leaves non-Bash tool invocations out of scope' {
        It 'returns null for a Write payload without consulting either checkpoint' {
            $payload = '{"hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"docs/notes.md"}}'

            Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' |
                Should -BeNullOrEmpty
        }
    }

    Context 'the hook entry point reads stdin and reports through the exit code' {
        It 'writes nothing and exits 0 for a non-Bash payload on stdin' {
            $payload = '{"hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"docs/notes.md"}}'

            $result = Invoke-CodexMergeGateEntryPoint -HookPath $script:UnderTest -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'writes the reason to stderr and exits 2 for malformed stdin' {
            $result = Invoke-CodexMergeGateEntryPoint -HookPath $script:UnderTest -PayloadRaw '{broken'

            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'EPIC_MERGE_GATE_BLOCKED: PreToolUse input is malformed JSON'
        }
    }
}
