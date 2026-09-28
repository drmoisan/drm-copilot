# Fail-Before — Claude side — issue #539 [P1-T2] [expect-fail]

Timestamp: 2026-08-24T17-43

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5` and `scan_folders = ["tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1"]`

Result-extraction command: `python <scratchpad>/junit_summary.py artifacts/pester/pester-junit.xml`

EXIT_CODE: 8

ExpectedExitCode: 8

## Why this run is expected to fail

This is a genuine fail-before run, not an exception dossier. The suite was authored against the UNMODIFIED canonical Claude hook `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (SHA-256 `F57FAE11...`, 340 lines, recorded by [P0-T10]). That hook's `Test-ImplementationCommand` classifies every trigger-matching staging or integration invocation as implementation with no pathspec inspection, so with an explicitly not-ready checkpoint (route id empty, lifecycle readiness false) every allow case must be denied and therefore must fail. The deny cases assert the pre-existing behaviour and must pass.

## Observed result

```
TOTALS tests=58 failures=8 errors=0 time=1.335
PASSING_COUNT 50
FAILING_COUNT 8
```

- Total cases: 58
- Failing: 8 — exactly the eight allow cases required by [P1-T1](a)
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

Failing count equals the required allow-case count, and the failing set is exactly the allow-case set. No deny case failed, which confirms the suite does not assert any behaviour the unfixed hook already lacks beyond the exemption itself.

## Passing deny-case coverage in this same run

- `issue #539 mixed pathspec deny cases`: 4 of 4 passing (`.ps1`, `.py`, `.ts`, `.cs`).
- `issue #539 fail-closed rule table deny cases`: 45 of 45 passing, covering D4 rows 1 through 17 and row 19. Row 18 is deliberately absent from this context because it is allow-case 4 above.
- `issue #539 residual whole-command-text behaviour (D3 and D8)`: 1 of 1 passing (here-document body quoting the staging literal still denies).

Every deny fixture was authored to match the unchanged trigger regex, so each passing deny case asserts a decision the exemption must decline to grant, never an under-match of the trigger itself.

Output Summary: EXPECTED FAIL. Exit code 8 equals the declared expectation, so this gate normalizes to pass. 58 cases, 8 failures, 0 errors. All eight [P1-T1](a) allow cases fail against the unmodified hook and all 50 deny cases pass, which is precisely the fail-before signal the plan requires. Pass-after verification is [P2-T5].
