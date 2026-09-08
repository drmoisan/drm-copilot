#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for .claude/hooks/enforce-parallel-abandon-gate.ps1
    (issue #545). Covers spec Test Strategy rows AT-11 and AT-12.

.DESCRIPTION
    Expected state BEFORE [P10-T15]: all three cases fail. The gate collapses whitespace
    and then asks whether the WHOLE command string contains the literal
    '--disposition abandon', so:
      - AT-11 over-matches: a grep whose quoted search term is that literal is treated as
        an abandon invocation and denied.
      - AT-12 under-matches: the equals-joined spelling '--disposition=abandon', which the
        producer's argparse registration accepts as the same invocation, contains no such
        substring, so the gate never fires. The executed pre-change confirmation of that
        bypass is recorded in
        evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md.
      - The confirmation test is likewise a whole-string containment, so a confirmation
        marker sitting in an unrelated segment satisfies it.

    Determinism: every case drives a pure decision seam or a pure string function with
    literal fixtures. No disk I/O, no child process, no temporary file, no live executable.
#>

Describe 'enforce-parallel-abandon-gate.ps1 trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-abandon-gate.ps1").Path
        . $script:UnderTest

        function ConvertTo-AbandonGateEnvelope {
            <#
            .SYNOPSIS
                Wrap a Bash command string in the PreToolUse envelope the hook reads.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

            return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    It 'AT-11 takes a grep whose quoted search term is the disposition token out of scope' {
        # Searching the source for the token is not requesting an abandon. The tokenizer
        # keeps the quoted span as ONE token, so it is neither the adjacent pair
        # '--disposition' 'abandon' nor the equals-joined single token.
        $envelope = ConvertTo-AbandonGateEnvelope -Command 'grep -n "--disposition abandon" scripts/dev_tools/parallel_mutation_abandon_cli.py'
        $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $envelope
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'AT-12 brings the equals-joined spelling of the disposition option into scope' {
        # argparse accepts '--disposition=abandon' and '--disposition abandon' as the same
        # invocation, so the gate must too.
        $normalized = Get-ParallelAbandonNormalizedCommand -CommandText 'poetry run python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition=abandon'
        Test-ParallelAbandonCommandInScope -NormalizedCommand $normalized | Should -BeTrue
    }

    It 'does not accept a confirmation marker that sits in a different segment from the disposition token' {
        # The confirmation is the caller's deliberate acknowledgement of THIS abandon, so
        # it must travel in the same segment. An echo of the marker in a preceding segment
        # is not an acknowledgement of the command that follows it.
        $envelope = ConvertTo-AbandonGateEnvelope -Command 'echo --confirm-abandon && run --disposition abandon'
        $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $envelope
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
    }

    Context 'R-2.b wrapper-led disposition' {
        # Every case in this context drives Invoke-ParallelAbandonGateDecision through the
        # file's ConvertTo-AbandonGateEnvelope helper with a literal fixture. No disk I/O,
        # no child process, no temporary file, no live executable, no ambient state.
        It 'R2b-C1 denies the space-separated disposition carried inside a bash -c argument' {
            $envelope = ConvertTo-AbandonGateEnvelope -Command 'bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition abandon"'
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
        }

        It 'R2b-C2 denies the equals-joined disposition carried inside a bash -c argument' {
            $envelope = ConvertTo-AbandonGateEnvelope -Command 'bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition=abandon"'
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
        }

        It 'R2b-C3 allows a wrapper-led abandon carrying the confirmation marker in the same segment' {
            $envelope = ConvertTo-AbandonGateEnvelope -Command 'bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition abandon --confirm-abandon"'
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'R2b-N1 still allows a commit message quoting the disposition token' {
            $envelope = ConvertTo-AbandonGateEnvelope -Command 'git commit -m "note that --disposition abandon is gated"'
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
