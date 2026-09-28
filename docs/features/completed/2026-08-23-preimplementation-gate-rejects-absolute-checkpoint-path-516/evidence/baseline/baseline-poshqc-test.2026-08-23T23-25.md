# Baseline — PoshQC Test / Pester Full Suite (issue #516)

Timestamp: 2026-08-24T15-26
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e` and **no** `scan_folders` argument, so the full configured scan set executes and `artifacts/pester/powershell-coverage.xml` reflects the whole suite
EXIT_CODE: 0

## Raw Result

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e'."}
```

## Counts Read From `artifacts/pester/pester-junit.xml`

Read command:

```powershell
$x=[xml](Get-Content -Raw 'artifacts/pester/pester-junit.xml'); $s=$x.testsuites; 'tests={0} failures={1} errors={2} skipped={3} time={4}' -f $s.tests,$s.failures,$s.errors,$s.skipped,$s.time
```

Result:

```text
tests=3408 failures=0 errors=0 skipped= time=138.216
```

| Counter | Baseline value |
| --- | --- |
| Total tests | 3408 |
| Passed | 3408 |
| Failed | 0 |
| Errored | 0 |
| Skipped | 0 (attribute empty) |
| Test time (seconds) | 138.216 |

Passed is derived as total minus failures minus errors minus skipped: 3408 − 0 − 0 − 0 = **3408**.

## Coverage Artifacts Produced by This Run

- `artifacts/pester/powershell-coverage.xml` (JaCoCo 1.1 format, report name `Pester (08/24/2026 15:16:03)`) — consumed by [P0-T11].
- `artifacts/pester/powershell-coverage.koverage.xml`
- `artifacts/pester/pester-junit.xml`

Output Summary: Baseline full-suite Pester run completed with `ok: true`, EXIT_CODE 0. 3408 tests passed, 0 failed, 0 errored, 0 skipped, in 138.216 seconds. The suite is fully green at baseline, so any failure appearing in the [P4-T4] final run is attributable to this item's change. Coverage output was produced at `artifacts/pester/powershell-coverage.xml` for the whole configured scan set.
