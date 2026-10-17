# Baseline test disposition: t-claude-hooks

Timestamp: 2026-10-16T15-36
Task: [P0-T8]
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/claude-hooks]; then Grep WORKTREE_ROOT/artifacts/pester/pester-junit.xml for `<testsuite name=`, `status="Failed"`, the known pin testcase, and testsuite lines with a non-zero errors or failures attribute
EXIT_CODE: 1
Disposition: RAISED
Output Summary: error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 1."}
JUnitFreshness: FRESH
Baseline: GREEN-AFTER-PIN
KNOWN_BASELINE_FAILURE=makes no docs-only call for a bare merge and keeps its exact deny text (issue #927)

Freshness checks:
- F1: 164 lines match `<testsuite name=`; 164 lines match `<testsuite name="[^"]*claude-hooks`. Every suite line contains the scan-folder text `claude-hooks`.
- F2: the known pin testcase is present (junit line 612), classname ends with `enforce-epic-merge-gate.DocsOnly.Tests.ps1`.

Failing set (repository-relative):
- testcase `enforce-epic-merge-gate docs-only branch (issue #927).a checkpoint target resolves or the command is bare.makes no docs-only call for a bare merge and keeps its exact deny text (issue #927)` status="Failed", classname `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`
- testsuites with a non-zero errors attribute: none (Grep `<testsuite [^>]*errors="[1-9]`: no match)
- testsuites with a non-zero failures attribute: `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` (tests="14" errors="0" failures="1"), contributing only the testcase above

The failing set is exactly the known pin testcase of this key (Scope, R-MERGE; CI run 38915280068).

Per-suite Passed counts and coverage come from CI (P0-T9 for the baseline; ORCH-R1 to ORCH-R3 after the change), not from this call.
