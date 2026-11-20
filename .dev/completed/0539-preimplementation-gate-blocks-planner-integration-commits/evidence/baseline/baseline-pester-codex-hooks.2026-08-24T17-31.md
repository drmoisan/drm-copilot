# Baseline Pester with Coverage — Codex side — issue #539 [P0-T9]

Timestamp: 2026-08-24T17-31

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5` and `scan_folders = ["tests/scripts/codex-hooks"]`

Coverage extraction command: `python <scratchpad>/cov_extract.py artifacts/pester/powershell-coverage.xml "hooks/enforce-orchestration-preimplementation-gate"`

EXIT_CODE: 0

## Scope note

The scan set is the FOLDER `tests/scripts/codex-hooks`, deliberately identical to the Codex-side scan set the final QA run [P7-T3] uses, so the [P7-T4] baseline-versus-final coverage comparison is like-for-like.

## Runner-output freshness verification

`artifacts/pester/powershell-coverage.xml` was removed before this run. It was recreated by the run and the JaCoCo report name is `Pester (08/24/2026 17:31:21)`, distinct from the [P0-T8] report `Pester (08/24/2026 17:23:22)`. The extracted figures are therefore this run's, not carried over from the Claude-side baseline.

## Test result

JUnit summary element from `artifacts/pester/pester-junit.xml`:

```
<testsuites name="Pester" tests="477" errors="0" failures="0" disabled="0" time="90.598">
```

- Total tests: 477
- Passed: 477
- Failed: 0
- Errors: 0
- Test suites (files): 19

## Coverage (numeric, per-file line coverage, keyed on package element)

Extracted from `artifacts/pester/powershell-coverage.xml` by the enclosing `package` element plus the `class` element, never by bare filename, because `enforce-orchestration-preimplementation-gate.ps1` appears under both the `.claude/hooks` and `.codex/hooks` package elements.

| Package element | Source file | LINE covered | LINE total | Line coverage |
| --- | --- | --- | --- | --- |
| `<worktree>/.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 121 | 122 | **99.2%** |
| `<worktree>/.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 0 | 110 | 0.0% |

**Baseline value of record for [P7-T4] on the Codex side: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` = 99.2% (121/122 lines).**

The `.claude` row reads 0.0% because the Claude hook is in the standing `CodeCoverage.Path` allow-list but no Claude-side suite executes under this Codex-scoped scan set. Its baseline of record is [P0-T8]. The 0.0% figure here is a scoping artifact and must not be used as a comparison basis.

## Cross-reference

The two hook line totals differ (110 for the `.claude` copy, 122 for the `.codex` copy), which is consistent with the plan preamble's statement that the two canonical copies are deliberately divergent implementations of the same contract, not mirrors of one another.

Output Summary: PASS. 477 tests, 0 failures, 0 errors across 19 suites. Baseline numeric per-file line coverage for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is 99.2% (121 of 122 lines covered), above the uniform 85% line threshold. Combined with [P0-T8], both canonical hook baselines are numerically recorded: Claude 90.0%, Codex 99.2%.
