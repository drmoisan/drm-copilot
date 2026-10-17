# Baseline Codex Suites (P0-T14)

Timestamp: 2026-10-01T16-28
Deviation: D6. SP6 was not written or run. Per-testcase results come from the CI JUnit of run 36890793420 (job `PowerShell QC` 110465608484, head 7282fb31153adb4d3449e5653d64c6b50e09de75).

Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <REPO_ROOT>, scan_folders = ["tests/scripts/codex-hooks"])
EXIT_CODE: 0
Output Summary: `ok: true`; summary `Ran bundled PoshQC test against '<REPO_ROOT>' with 1 selected scan folder(s).`

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/poshqc-baseline-743/pester-junit.xml --case <each of the five names>
EXIT_CODE: 0
Output Summary: the three suites report 61 tests, 0 failures, 0 errors, 0 skipped (20 + 19 + 22). FAILED-COUNT equivalent: 0; PASSED-COUNT equivalent: 61. All five named testcases are PASSED.

```
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=0 | errors=0 | skipped=0
CASE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | Codex enforce-epic-worktree-removal-gate decision surface (issue #545).Get-NormalizedCodexWorktreePath resolves both rooted and relative inputs.resolves a relative path against the supplied working directory | PASSED
CASE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | Codex enforce-epic-worktree-removal-gate decision surface (issue #545).Get-NormalizedCodexWorktreePath resolves both rooted and relative inputs.keeps a rooted path and trims a trailing separator | PASSED
CASE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | Codex epic-child launcher hardening.uses inline project trust, ignores user config, and denies Codex install paths | PASSED
CASE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | Codex epic-child launcher hardening.preflights the elevated Windows sandbox from an isolated CODEX_HOME | PASSED
CASE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | Codex epic-child worktree launcher and guard.immutable launch specification validation.builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree | PASSED
```

Baseline passed count for the three Codex suites: 61.
