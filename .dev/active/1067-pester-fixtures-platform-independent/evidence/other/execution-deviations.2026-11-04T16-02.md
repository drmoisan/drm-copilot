# Execution Deviations — Remediation cycle 1

Timestamp: 2026-11-04T16-02
Plan: docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067/remediation-plan.2026-11-04T15-31.md

## 1. `[P1-T2]` removal path for the gh stub

- Observed: after the `[P1-T2]` edit as written (`Remove-Item -Path Function:\global:gh -Force -ErrorAction SilentlyContinue`), the `[P1-T4]` run reported `PROBE GH-FUNCTION=present`.
- Cause: `SCRATCH/issue-1067-remove-probe.ps1` showed that `Remove-Item` with the scope-qualified path `Function:\global:gh` leaves the function defined and records no error; the unqualified path `Function:\gh` removes the global function (`AFTER-QUALIFIED=True`, `AFTER-UNQUALIFIED=False`, `AFTER-LITERAL-UNQUALIFIED=False`).
- Action: the removal branch uses `Remove-Item -Path Function:\gh`, the form of the R1-F5 reference pattern (`Remove-Item -Path Function:\prompt` in `Enter-DrmCopilotShell.Tests.ps1`), with a one-line comment. The restore branch keeps `Set-Item -Path Function:\global:gh`, which `[P1-T7]` verified (`PRIOR-GH-AFTER=issue-1067-prior-gh`). `[P1-T2]`'s acceptance tokens are unaffected.
- Related search: `git grep` for `Remove-Item` with a `Function:` path qualified by `global:` or `script:` under `tests`, `scripts`, `.claude`, `.codex`, and `extensions/drm-copilot/resources` returns no match, so the no-op form does not occur elsewhere.

## 2. `[P3-T5]` first run: one failure outside the change set

- Observed: the first `[P3-T5]` run (2026-11-04T15-53 to 16-01, 8 workers, wall clock 444.59 s) had shard 8 exit 1 with one failure in `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` (`returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location`). Shards 1 to 7 exited 0 with 0 failures.
- Failure text (from `artifacts/pester/parallel/shard-8/shard.log`): the child process for `enforce-epic-planning-only.ps1` with the `mcp__drm_copilot__run_poshqc_format` payload exited 134 with `Unhandled exception. System.IO.FileLoadException: The given assembly name was invalid.` for the truncated name `em.ComponentModel.TypeConverter, Version=10.0.0.0`. This is a .NET runtime fault while the child PowerShell process loads an assembly, not an assertion on hook logic.
- Relation to this cycle: none found. None of the five change-set suites ran in shard 8 (they ran in shards 2, 3, 4, and 6), every shard is a separate process, and the five edits change only test-file setup, teardown, and script-block source text. The crash text occurs in no other shard log.
- Classification run: `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` alone in a fresh process (2026-11-04T16-02): `TOTAL Tests=3 Passed=3 Failed=0`.
- Action: per the plan's Phase 3 rule, the loop restarts from `[P3-T1]` with no file change (the cause is not in the five change-set files), and `[P3-T5]` is re-run. If the crash recurs, it is reported as a host finding outside this cycle.
