# Baseline Pester with Coverage — Claude side — issue #539 [P0-T8]

Timestamp: 2026-08-24T17-23

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5` and `scan_folders = ["tests/scripts/claude-hooks"]`

Coverage extraction command: `python <scratchpad>/cov_extract.py artifacts/pester/powershell-coverage.xml "hooks/enforce-orchestration-preimplementation-gate"`

EXIT_CODE: 0

## Scope note

The scan set is the FOLDER `tests/scripts/claude-hooks`, deliberately identical to the Claude-side scan set the final QA run [P7-T3] uses, so the [P7-T4] baseline-versus-final coverage comparison is like-for-like. It is therefore broader than a single-suite run and its coverage figure is not comparable to a single-file invocation.

## Runner-output freshness verification

`artifacts/pester/powershell-coverage.xml` initially carried an mtime older than the sibling `pester-junit.xml` and `powershell-coverage.koverage.xml`, which left open the possibility of a stale coverage artifact. The three runner outputs were removed and the identical scoped command was re-run. All three were recreated, and the JaCoCo report name advanced from `Pester (08/24/2026 17:16:14)` to `Pester (08/24/2026 17:23:22)`. The mtime skew is a property of the runner's write ordering (Pester writes the JaCoCo report mid-run; the wrapper writes the JUnit and koverage outputs at the end), not staleness. The numbers below are from the verified-fresh `Pester (08/24/2026 17:23:22)` report.

## Test result

JUnit summary element from `artifacts/pester/pester-junit.xml`:

```
<testsuites name="Pester" tests="1055" errors="0" failures="0" disabled="0" time="23.902">
```

- Total tests: 1055
- Passed: 1055
- Failed: 0
- Errors: 0
- Test suites (files): 47

## Coverage (numeric, per-file line coverage, keyed on package element)

Extracted from `artifacts/pester/powershell-coverage.xml` by the enclosing `package` element plus the `class` element, never by bare filename, because `enforce-orchestration-preimplementation-gate.ps1` appears under both the `.claude/hooks` and `.codex/hooks` package elements.

| Package element | Source file | LINE covered | LINE total | Line coverage |
| --- | --- | --- | --- | --- |
| `<worktree>/.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 99 | 110 | **90.0%** |
| `<worktree>/.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 0 | 122 | 0.0% |

**Baseline value of record for [P7-T4] on the Claude side: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` = 90.0% (99/110 lines).**

The `.codex` row reads 0.0% because the Codex hook is in the standing `CodeCoverage.Path` allow-list but no Codex-side suite executes under this Claude-scoped scan set. Its baseline of record is captured separately by [P0-T9]. The 0.0% figure here is a scoping artifact, not a coverage deficiency, and must not be used as a comparison basis.

Output Summary: PASS. 1055 tests, 0 failures, 0 errors across 47 suites. Baseline numeric per-file line coverage for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is 90.0% (99 of 110 lines covered), above the uniform 85% line threshold. Runner-output freshness was independently verified by clearing and re-running.
