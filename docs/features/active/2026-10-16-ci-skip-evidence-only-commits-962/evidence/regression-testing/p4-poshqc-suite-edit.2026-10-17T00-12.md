# _poshqc.yml gating and A4/A4C, rule 17 RI-3 re-run of P4-T6

Timestamp: 2026-10-17T00-12
Command: git diff --numstat origin/main -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 .github/workflows/_poshqc.yml
EXIT_CODE: 0
Output Summary: The latest edit-points artifact (edit-points.2026-10-17T00-09.md) records POSHQC-SHAPE: sharded, the same shape as before the re-integration. origin/main b8fcd7790 did not change _poshqc.yml or PoshQcWorkflow.Tests.ps1, so the committed G6-sharded edits and the A4/A4C lines are unchanged and still correct; no re-edit was needed. Against origin/main the suite shows exactly the two A4 lines (`2	2`) and _poshqc.yml shows 22 added lines (G0 inputs, three job-level gates, seven aggregator step gates). The HEAD-anchored numstat prints nothing because the edits are committed (plan-trivial-fixes Fix 4). WF02 and WF03 are observed by the RI-4 re-run of P4-T12.

POSHQC-SHAPE: sharded

## A4 record (unchanged)

- A4C line 51: `        # -or, exits 1, carries no step-level if condition other than the issue #962 run-heavy gate, and precedes the completeness and merge steps.`
- A4 line 85: `            if ($gate -match '(?m)^ {8}if:' -and $gate -notmatch '(?m)^ {8}if:[ \t]*\$\{\{ inputs\.run-heavy \}\}[ \t]*$') {`

## numstat output

```
22	0	.github/workflows/_poshqc.yml
2	2	tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
```
