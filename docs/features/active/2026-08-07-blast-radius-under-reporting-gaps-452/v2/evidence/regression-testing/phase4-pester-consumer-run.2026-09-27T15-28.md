# Phase 4 Pester Consumer Run (P4-T2)

Timestamp: 2026-09-27T15-28

Tolerance branch: NOT FOUND (P0-T29).

Command: MCP mcp__drm-copilot__run_poshqc_test, workspace_root `<worktree root>`, scan_folders ["tests/scripts/claude-lib/blast-radius"]
EXIT_CODE: 0
Output: {"ok":true,"tool":"run_poshqc_test","summary":"Ran bundled PoshQC test against '<worktree root>' with 1 selected scan folder(s)."}

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/poshqc-test.ps1 -ScanFolder tests/scripts/claude-lib/blast-radius
EXIT_CODE: 0
Output (tail):

```
Tests completed in 24.33s
Tests Passed: 463, Failed: 0, Skipped: 1, Inconclusive: 0, NotRun: 0
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/junit-report.ps1 -NameFilter "regression corpus for issue 452"
EXIT_CODE: 0
Output:

```
ALL total=464 pass=463 fail=0 skip=1
FILTER matched=26
PASS BlastRadius regression corpus for issue 452.Corpus contract.declares the contracted top-level shape
PASS BlastRadius regression corpus for issue 452.Corpus contract.matches the case shape contract for every case
PASS BlastRadius regression corpus for issue 452.Corpus contract.carries every Case List id exactly once and no other id
PASS BlastRadius regression corpus for issue 452.Corpus contract.expects a verdict consistent with each case direction
PASS BlastRadius regression corpus for issue 452.Corpus contract.resolves every pairing to an opposite-direction case of the same gap
PASS BlastRadius regression corpus for issue 452.Corpus contract.pins both directions for each gap
PASS BlastRadius regression corpus for issue 452.Corpus contract.follows the plan-line intent rule for every plan line
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-poetry-lock
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-package-lock
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-different-surfaces
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-unconfigured-root-file
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-quality-tiers-mandate-read
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-radius-quality-tiers
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-radius-quality-tiers-vs-poetry-lock
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-dir-vs-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-dir-vs-sibling-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-sibling-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-dir-vs-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-dir-vs-sibling-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-sibling-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-empty-modules-dir-vs-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-empty-modules-dir-vs-sibling-glob
PASS BlastRadius regression corpus for issue 452.Bundled configuration parity.admits the same separator-free root surfaces from both committed tables
SKIP BlastRadius regression corpus for issue 452.Tolerance branch.keeps a scheduling edge for every must-conflict case at the strictest tolerance
```

JUnit skip message for the Tolerance branch testcase (from the repository-runsettings JUnit XML):

```
<skipped message="Exception: is skipped, because  because Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.,"></skipped>
```

Output Summary: FILTER matched=26 with 25 PASS lines, one SKIP line whose name contains "Tolerance branch" (reason contains "#722"), and no FAIL line. 17 PASS lines contain "reports the corpus verdict for", including g1-plan-quality-tiers-mandate-read and g1-radius-quality-tiers. The folder total is ALL total=464, which equals the P0-T28 total 438 plus 26; fail=0 equals the P0-T28 value. The consumer was run through the self-hosted PoshQC module, which loads the repository runsettings. Authoring micro-check before this run: PSSA_FINDINGS=0 on the new file; 290 lines.
