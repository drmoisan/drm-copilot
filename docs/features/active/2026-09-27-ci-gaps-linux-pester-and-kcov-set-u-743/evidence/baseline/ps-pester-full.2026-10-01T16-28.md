# Baseline Full Windows Pester Run (P0-T12)

Timestamp: 2026-10-01T16-28
Deviation: D4 (test results) and D9 (JUnit summary by the Python helper). SP4 and SP7 were not written or run as PowerShell.

Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <REPO_ROOT>)
EXIT_CODE: 0
Output Summary: `ok: true`; summary `Ran bundled PoshQC test against '<REPO_ROOT>'.` The tool returns no counts.

Command: gh run view 36890793420 --log --job 110465608484 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6084, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0` (CI run https://github.com/drmoisan/drm-copilot/actions/runs/36890793420, job `PowerShell QC` 110465608484, head 7282fb31153adb4d3449e5653d64c6b50e09de75).

Command: gh run download 36890793420 --name poshqc-test-results --dir <session-scratchpad>/poshqc-baseline-743
EXIT_CODE: 0
Output Summary: pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/poshqc-baseline-743/pester-junit.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=6094 failures=0 errors=0`; 256 `SUITE:` lines; no `FAIL:` line.

Local PowerShell baseline failure set: none

SUITE lines for the three Codex suites:

```
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=0 | errors=0 | skipped=0
```

Note: the failure set above is taken from the CI Windows run (D4) because no local Pester run with readable output was permitted in this session.
