# Coverage Comparison (P8-T1)

Timestamp: 2026-10-09T04-40
Command: none executed in this task; values tabulated from P0-T11, P0-T17, P6-T7, P6-T8, and P7-T5 artifacts
EXIT_CODE: 0
Output Summary: every value is numeric. Python line 100.0% (>= 85) and branch 100.0% (>= 75) for both modules; PowerShell line 100.0% (>= 85) for both modules. No post-change value is below its baseline. Changed-line result: no uncovered added line or branch.

| Module | Metric | Baseline | Source | Post-change | Source |
|---|---|---|---|---|---|
| scripts.dev_tools._blast_radius_extraction | line | 101/101 = 100.0% | P0-T11 | 97/97 = 100.0% | P6-T7 |
| scripts.dev_tools._blast_radius_extraction | branch | 46/46 = 100.0% | P0-T11 | 44/44 = 100.0% | P6-T7 |
| scripts.dev_tools._blast_radius_token_shapes | line | 14/14 = 100.0% | P0-T11 | 25/25 = 100.0% | P6-T7 |
| scripts.dev_tools._blast_radius_token_shapes | branch | 4/4 = 100.0% | P0-T11 | 8/8 = 100.0% | P6-T7 |
| BlastRadiusExtraction.psm1 | line | 86/86 = 100.0% | P0-T17 | 80/80 = 100.0% | P7-T5 |
| BlastRadiusTokenShape.psm1 | line | 20/20 = 100.0% | P0-T17 | 31/31 = 100.0% | P7-T5 |

Changed-line result (P6-T8): missing_lines [] and missing_branches [] for both Python modules. PowerShell: no uncovered line in either module (P7-T5).

Note: the PowerShell values come from the JaCoCo report written by the PoshQC MCP test run (substitute route; see the P0-T17 and P7-T5 artifacts).
