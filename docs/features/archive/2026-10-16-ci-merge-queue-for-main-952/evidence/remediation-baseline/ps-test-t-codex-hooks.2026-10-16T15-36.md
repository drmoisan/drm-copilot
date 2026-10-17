# Baseline test disposition: t-codex-hooks

Timestamp: 2026-10-16T15-36
Task: [P0-T8]
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/codex-hooks]; then Grep WORKTREE_ROOT/artifacts/pester/pester-junit.xml for `<testsuite name=`, `status="Failed"`, the known pin testcase, and testsuite lines with a non-zero errors or failures attribute
EXIT_CODE: 1
Disposition: RAISED
Output Summary: error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 1."}
JUnitFreshness: FRESH
Baseline: GREEN-AFTER-PIN
KNOWN_BASELINE_FAILURE=keeps the bare-merge deny text unchanged (codex, issue #927)

Freshness checks:
- F1: 67 lines match `<testsuite name=`; 67 lines match `<testsuite name="[^"]*codex-hooks`. Every suite line contains the scan-folder text `codex-hooks` (the preceding call wrote 164 claude-hooks suites, so this file is a new write).
- F2: the known pin testcase is present (junit line 999), classname ends with `enforce-epic-merge-gate-docs-only.Tests.ps1`.

Failing set (repository-relative):
- testcase `Codex enforce-epic-merge-gate docs-only branch (issue #927).keeps the bare-merge deny text unchanged (codex, issue #927)` status="Failed", classname `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`
- testsuites with a non-zero errors attribute: none
- testsuites with a non-zero failures attribute: `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (tests="9" errors="0" failures="1"), contributing only the testcase above

The failing set is exactly the known pin testcase of this key (Scope, R-MERGE; CI run 38915280068).

Per-suite Passed counts and coverage come from CI (P0-T9 for the baseline; ORCH-R1 to ORCH-R3 after the change), not from this call.
