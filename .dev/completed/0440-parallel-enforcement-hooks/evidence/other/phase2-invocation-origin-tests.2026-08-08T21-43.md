# Phase 2 — Invocation-Origin Test Extension — Issue #440 (F7)

Timestamp: 2026-08-08T21-43

Task: [P2-T2]

Target file: `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (262 lines, under the 500-line limit)

## Append-Only Proof

Command: `git diff --numstat -- tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` and `git diff -U0 -- <same>`

EXIT_CODE: 0

```
154     0       tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
removed-line count (lines matching ^-[^-]): 0
hunk headers: @@ -107,0 +108,154 @@ Describe 'enforce-epic-invocation-origin.ps1' {
```

A single pure-insertion hunk with 154 added lines and 0 deleted lines. `-107,0` means no original line was consumed, so every pre-existing test in the file is unmodified. The insertion sits after the last pre-existing `Context` block and before the closing brace of the `Describe` block.

## New Context Blocks Added (4)

1. `deny PARALLEL_INVOCATION_ORIGIN_BLOCKED for orchestrator-originated parallel invocations` — 4 tests
   - denies parallel-orchestrator invoked from an orchestrator agent
   - denies parallel-planner invoked from an orchestrator agent
   - does not use the epic deny prefix for a parallel target
   - denies when a parallel target arrives only via the payload tool_input fallback
2. `allow when a parallel agent is invoked outside an orchestrator context` — 6 tests
   - allows parallel-orchestrator from the main thread (no agent_type field)
   - allows parallel-planner from the main thread (no agent_type field)
   - allows parallel-orchestrator when agent_type is blank
   - allows parallel-planner when agent_type is blank
   - allows parallel-orchestrator invoked from a non-orchestrator agent
   - allows parallel-planner invoked from a non-orchestrator agent
3. `epic behavior is byte-identical after the parallel extension` — 2 tests, each an exact `Should -Be` assertion (not a substring match) against the full rendered epic deny reason
   - renders the epic deny reason for epic-orchestrator byte-for-byte
   - renders the epic deny reason for epic-planner byte-for-byte
4. `non-gated targets still allow without parsing the hook payload` — 2 tests
   - allows a non-gated target whose hook payload is malformed JSON
   - allows a target whose name merely resembles a gated parallel type

## Targeted Verification Run

Command: `pwsh -NoProfile -File <scratchpad>/run-invocation-origin-tests.ps1 -TestPath tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (Invoke-Pester with `PassThru = $true` and an explicit non-zero exit on failure)

EXIT_CODE: 0

```
Discovery found 27 tests in 133ms.
Tests Passed: 27, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
TOTAL=27
PASSED=27
FAILED=0
```

13 pre-existing tests plus 14 new tests, all passing. No temp files are created by the tests; the hook is dot-sourced and all state is injected through inline JSON payload strings passed to `Invoke-EpicInvocationOriginDecision`, so no live checkpoint file is read. The runner script is a throwaway outside the repository. The authoritative full-suite result is recorded by [P2-T7].

Output Summary: PASS. Four new `Context` blocks (14 tests) appended; `git diff` proves a single pure-insertion hunk with 154 added and 0 removed lines, so no pre-existing test line changed. Both parallel targets are asserted to deny with the `PARALLEL_INVOCATION_ORIGIN_BLOCKED` prefix from an `orchestrator` caller and to allow from the main thread, from a blank `agent_type`, and from a non-orchestrator agent. Epic byte-identity is asserted with exact `Should -Be` comparisons on the full deny reason for both epic targets. Non-gated no-parse behavior is re-asserted, including a near-miss target name proving the gate matches exact values rather than prefixes. Targeted Pester run: 27 of 27 passed, 0 failed.
