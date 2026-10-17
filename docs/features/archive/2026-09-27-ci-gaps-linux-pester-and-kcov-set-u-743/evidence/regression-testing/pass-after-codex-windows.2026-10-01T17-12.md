# Pass-After: Modified Codex Suites (P5-T8)

Timestamp: 2026-10-01T17-12
Deviations: D10 (CI JUnit plus MCP run in place of SP6), D9 (Python JUnit helper), D13 (the Phase 5 test edits were first captured by the out-of-band WIP commit 3f85b23d).

Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <REPO_ROOT>, scan_folders = ["tests/scripts/codex-hooks"])
EXIT_CODE: 0
Output Summary: `ok: true`; summary `Ran bundled PoshQC test against '<REPO_ROOT>' with 1 selected scan folder(s).`

CI evidence: run https://github.com/drmoisan/drm-copilot/actions/runs/36896422867 (workflow_dispatch of `_poshqc.yml`, dispatched 2026-10-01T17:02:17Z), headSha a412698b8f2a0e6c0582907231a23c48e3c07907 (Phase 5 boundary push).

## Windows (job `PowerShell QC`, databaseId 110484453544, conclusion `success`)

Command: gh run view 36896422867 --log --job 110484453544 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6091, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/windows-p5/pester-junit.xml --case <five names>
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=6101 failures=0 errors=0`. The three modified Codex suites report 61 tests, 0 failures (FAILED-COUNT 0; PASSED-COUNT 61, equal to the P0-T14 passed count of 61). Each of the five P0-T14 names is PASSED.

```
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=0 | errors=0 | skipped=0
CASE: ...decision-surface.Tests.ps1 | ...resolves a relative path against the supplied working directory | PASSED
CASE: ...decision-surface.Tests.ps1 | ...keeps a rooted path and trims a trailing separator | PASSED
CASE: ...epic-child-launch-hardening.Tests.ps1 | ...uses inline project trust, ignores user config, and denies Codex install paths | PASSED
CASE: ...epic-child-launch-hardening.Tests.ps1 | ...preflights the elevated Windows sandbox from an isolated CODEX_HOME | PASSED
CASE: ...epic-child-worktree-launcher.Tests.ps1 | ...builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree | PASSED
```

## Linux (job `PowerShell hook suites (Linux)`, databaseId 110484453999, conclusion `failure`) — iteration check

Command: gh run view 36896422867 --log --job 110484453999 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 3400, Failed: 12, Skipped: 0, Inconclusive: 0, NotRun: 0`

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/linux-p5/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=3412 failures=12 errors=0`. The three modified Codex suites report `failures=0` (20, 19, 22 tests). The 12 remaining `FAIL:` lines are exactly inventory rows 1 to 12, all marked REMEDIATION-REQUIRED by P5-T7 (enforce-parallel-drift-gate x8, enforce-powershell-batch-budget-routing, enforce-python-batch-budget-routing, codex-powershell-batch-budget-routing, codex-python-batch-budget-routing). Inventory rows 13 to 21 (the plan's own rows) no longer fail. Per the run constraints, iteration stops: only REMEDIATION-REQUIRED rows remain.
