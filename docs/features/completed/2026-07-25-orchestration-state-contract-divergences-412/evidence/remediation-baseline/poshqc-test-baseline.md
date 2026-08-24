# Remediation Baseline — PoshQC Test and Coverage (Issue #412, Cycle 1)

Timestamp: 2026-07-25T19-51

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`

EXIT_CODE: 0

## Tool Response

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585","summary":"Ran bundled PoshQC test against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585'."}
```

## Test totals

Read from `artifacts/pester/pester-junit.xml` root `testsuites` attributes:

```
tests="1393" errors="0" failures="0" disabled="9" time="39.922"
```

| Metric | Recorded baseline | This run | Delta |
|---|---|---|---|
| Tests | 1391 | 1393 | +2 |
| Failures | 0 | 0 | 0 |
| Errors | 0 | 0 | 0 |
| Disabled | 9 | 9 | 0 |

The +2 test delta versus the recorded post-Phase-6 baseline is an upward difference with zero
failures and zero errors, so it is not a regression. Working-tree HEAD is unchanged
(`81f3df3fb122db6d2dd8c51520e9ab8a2b1f7da5`) and no tracked file is modified; no Pester file in
`tests/` uses dynamic discovery (`BeforeDiscovery`, or `-ForEach (Get-ChildItem ...)`), verified by
search, so the delta does not originate from working-tree discovery inputs. The most likely origin
is the npx-cached published PoshQC bundle that this tool executes (see caveat below). Recorded as
an observation; acceptance for this task is exit 0 with 0 failures and numeric values recorded.

## Numeric coverage

Read from `artifacts/pester/powershell-coverage.xml` (report name `Pester (07/25/2026 19:54:00)`;
`INSTRUCTION` counters are Pester's command counts).

| Scope | Covered / analyzed | Percent |
|---|---|---|
| Overall commands (`INSTRUCTION`) | 2944 / 3281 | **89.73%** |
| Overall lines (`LINE`) | 2159 / 2392 | **90.26%** |

Per-file counts for the module under change in this cycle:

| File | Commands covered / analyzed | Command % | Lines covered / analyzed | Line % |
|---|---|---|---|---|
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 144 / 149 | 96.64% | 103 / 106 | 97.17% |

Comparison with recorded baselines: overall command coverage 89.73% (recorded 89.73%, 2945/3282 —
this run analyzed 3281 commands and covered 2944, a one-command difference in both numerator and
denominator that leaves the percentage identical to two decimal places); overall line coverage
90.26% (2159/2392), identical to the recorded baseline; `OrchestratorState.psm1` 144/149 (96.64%),
identical to the recorded baseline.

## Caveats

- `mcp__drm-copilot__run_poshqc_test` executes the npx-cached published MCP bundle, not the working
  tree. It is the mandated gate and the coverage denominator, but it does not exercise working-tree
  edits to `.claude/lib/**`. [P0-T6] covers the working-tree module directly via repo-root Pester.
- Pester 5 with the `CoverageGutters` format reports **command** coverage, not branch coverage.
  Branch coverage is not obtainable from this tooling. This is a tooling limitation, not a missing
  measurement, and no value is recorded as `UNVERIFIED`.

Output Summary: PoshQC test exit 0. 1393 tests, 0 failures, 0 errors, 9 disabled (recorded baseline
1391/0/0/9; +2 tests, no failures). Overall command coverage 89.73% (2944/3281); overall line
coverage 90.26% (2159/2392); `OrchestratorState.psm1` 144/149 commands (96.64%) and 103/106 lines
(97.17%). All values numeric. Branch coverage is not reported by Pester 5 CoverageGutters
(tooling limitation).
