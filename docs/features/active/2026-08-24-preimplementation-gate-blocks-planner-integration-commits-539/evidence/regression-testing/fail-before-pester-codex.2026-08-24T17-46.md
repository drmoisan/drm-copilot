# Fail-Before — Codex side — issue #539 [P1-T4] [expect-fail]

Timestamp: 2026-08-24T17-46

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5` and `scan_folders = ["tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1"]`

Result-extraction command: `python <scratchpad>/junit_summary.py artifacts/pester/pester-junit.xml`

EXIT_CODE: 8

ExpectedExitCode: 8

## Why this run is expected to fail

The suite was authored against the UNMODIFIED canonical Codex hook `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (SHA-256 `E8A2DFC7...`, 336 lines, recorded by [P0-T10]). That hook's `Test-ImplementationCommand` classifies every trigger-matching staging or integration invocation as implementation with no pathspec inspection, so with an explicitly not-ready checkpoint every allow case must be denied and therefore must fail.

## Codex decision-entry idiom honored

The Codex copy of `Invoke-OrchestrationPreimplementationGateDecision` accepts the MAPPED `tool_input` JSON directly (for example `{"command":"..."}`), not the outer PreToolUse envelope the Claude copy consumes through `Resolve-ClaudeHookToolInput`. The suite's builder therefore emits bare `tool_input` text, matching the idiom the existing Codex contract suite uses at `legacy-codex-hook-contracts.Tests.ps1` for its pure-decision assertions. No cross-runtime import of `.claude/lib/hook-payload/HookPayload.psm1` is introduced.

## Observed result

```
TOTALS tests=58 failures=8 errors=0 time=2.217
PASSING_COUNT 50
FAILING_COUNT 8
```

- Total cases: 58
- Failing: 8 — exactly the eight allow cases
- Passing: 50 — the 4 mixed-pathspec deny cases, the 45 D4 rule-table deny cases, and the 1 residual here-document deny case
- Errors: 0 (no discovery or parse failure; the suite AST-parses cleanly)

## The eight failing allow cases (all from `issue #539 orchestration-tree staging exemption allow cases`)

1. `allows staging an epic document under the epics tree`
2. `allows staging a parallel manifest and its kickoff in one two-operand invocation`
3. `allows a quoted operand under the active feature tree`
4. `allows a backslash-spelled operand after separator normalization (D4 row 18)`
5. `allows staging a kickoff markdown file under the orchestration artifacts tree`
6. `allows the pathspec-bearing integration form with a message option and a double-dash separator`
7. `allows a chained two-segment line whose every segment is independently exempt`
8. `allows staging a lifecycle record under the potential feature tree`

## Scenario parity with the Claude side

The case counts and the failing set are identical to the Claude-side fail-before run recorded in `fail-before-pester-claude.2026-08-24T17-43.md`: 58 cases, 8 failing allow cases, 50 passing deny cases, 0 errors. Both suites carry the same three named `Context` blocks, the same eight allow cases, the same four mixed-deny extension cases, at least one named case per D4 row 1 through 17 and row 19, and the here-document deny case. Row 18 is exercised as allow case 4 on both sides, so it is deliberately absent from the deny table on both sides.

Output Summary: EXPECTED FAIL. Exit code 8 equals the declared expectation, so this gate normalizes to pass. 58 cases, 8 failures, 0 errors. All eight allow cases fail against the unmodified Codex hook and all 50 deny cases pass, matching the Claude-side fail-before signal exactly. Pass-after verification is [P3-T5].
