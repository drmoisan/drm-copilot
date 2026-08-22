#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the enforce-evidence-locations.ps1 PreToolUse hook.

.DESCRIPTION
    Drives the decision function with the documented nested PreToolUse envelope
    (issue #501). Envelope anomalies fail closed as a deny; a well-formed tool_input
    carrying no file_path still allows, because that is the hook's scope filter.

    Exit codes are asserted through the entry-point function's [int] return value,
    which is the last element of its output pipeline; no test spawns a child process
    or mutates the process environment.
#>

BeforeAll {
    # Dot-source the hook to load its functions without executing the entrypoint block.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-evidence-locations.ps1'
    . $hookPath

    function ConvertTo-EvidenceLocationEnvelope {
        param(
            [Parameter(Mandatory)]
            [string] $FilePath,

            [string] $ToolName = 'Write'
        )

        return (@{
                tool_name  = $ToolName
                tool_input = @{ file_path = $FilePath; content = 'body' }
            } | ConvertTo-Json -Compress -Depth 5)
    }
}

Describe 'enforce-evidence-locations.ps1' {
    Context 'forbidden evidence locations' {
        It 'denies writes to artifacts/baselines/ (forbidden prefix)' {
            $nested = ConvertTo-EvidenceLocationEnvelope -FilePath 'artifacts/baselines/foo.md'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }

        It 'denies every forbidden prefix under the nested envelope' {
            $forbidden = @(
                'artifacts/baseline/x.md',
                'artifacts/qa/x.md',
                'artifacts/qa-gates/x.md',
                'artifacts/coverage/x.md',
                'artifacts/evidence/x.md',
                'artifacts/regression-testing/x.md',
                'artifacts/post-change/x.md'
            )

            foreach ($path in $forbidden) {
                $result = Invoke-EvidenceLocationDecision -ToolInputRaw (ConvertTo-EvidenceLocationEnvelope -FilePath $path)
                $result.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "$path is a forbidden evidence prefix"
            }
        }
    }

    Context 'allowed artifacts/ sub-paths' {
        It 'allows writes to artifacts/orchestration/ (permitted orchestration path)' {
            $nested = ConvertTo-EvidenceLocationEnvelope -FilePath 'artifacts/orchestration/orchestrator-state.json'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies writes to artifacts/research/ (retired research path)' {
            # Research is no longer a permitted artifacts/ sub-path; it must now resolve
            # to a tracked docs/ root and is denied here.
            $nested = ConvertTo-EvidenceLocationEnvelope -FilePath 'artifacts/research/notes.md'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }
    }

    Context 'canonical evidence paths' {
        It 'allows writes to <FEATURE>/evidence/baseline/ (canonical evidence path)' {
            $nested = ConvertTo-EvidenceLocationEnvelope -FilePath 'docs/features/active/my-feature/evidence/baseline/baseline.md'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows writes to the docs/features research subfolder (canonical feature research path)' {
            $nested = ConvertTo-EvidenceLocationEnvelope -FilePath 'docs/features/active/my-feature/research/2026-06-24T13-02-foo-research.md'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows writes to docs/research/ (canonical one-off research path)' {
            $nested = ConvertTo-EvidenceLocationEnvelope -FilePath 'docs/research/2026-06-24T13-02-foo-research.md'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'source code paths' {
        It 'allows writes to source code files (non-artifacts path)' {
            $nested = ConvertTo-EvidenceLocationEnvelope -FilePath 'src/hello-typescript.ts'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an Edit-shaped tool_input carrying new_string rather than content' {
            $nested = '{"tool_name":"Edit","tool_input":{"file_path":"src/hello.ts","old_string":"a","new_string":"b"}}'

            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $nested

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'envelope anomalies fail closed' {
        It 'denies an empty payload' {
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw ''

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw '{ not valid json'

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw '{"file_path":"artifacts/qa/x.md"}'

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }

        It 'denies a null tool_input' {
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw '{"tool_name":"Write","tool_input":null}'

            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'tool_input is null'
        }
    }

    Context 'property-level tolerance inside a well-formed tool_input' {
        It 'allows when the tool_input has no file_path field (scope filter)' {
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'entry-point dispatch' {
        It 'returns exit code 0 and emits allow JSON for an allowed path' {
            $allowed = ConvertTo-EvidenceLocationEnvelope -FilePath 'src/hello-typescript.ts'

            # The function emits the JSON on the output stream and returns the int exit
            # code as the final pipeline element; collect both.
            $emitted = @(Invoke-EvidenceLocationEntryPoint -ToolInputRaw $allowed)
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            $code | Should -Be 0
            $parsed = $stdout | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'returns exit code 0 and never 1 for unparseable input' {
            $emitted = @(Invoke-EvidenceLocationEntryPoint -ToolInputRaw '{ not valid json')
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            $code | Should -Be 0
            $code | Should -Not -Be 1
            ($stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = @(Invoke-EvidenceLocationEntryPoint -ReadPayload $emptyReader)
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            $code | Should -Be 0
            ($stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'returns exit code 0 and emits deny JSON for a forbidden path' {
            $forbidden = ConvertTo-EvidenceLocationEnvelope -FilePath 'artifacts/research/notes.md'

            $emitted = @(Invoke-EvidenceLocationEntryPoint -ToolInputRaw $forbidden)
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            $code | Should -Be 0
            $parsed = $stdout | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }
    }
}
