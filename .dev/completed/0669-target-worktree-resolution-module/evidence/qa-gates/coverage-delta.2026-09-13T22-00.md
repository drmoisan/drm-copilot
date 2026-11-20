# Coverage Delta

Timestamp: 2026-09-17T08:42:51-04:00 (file write time)
Command: comparison of evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md, evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md, and evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md (no new command executed)
EXIT_CODE: 0
Output Summary: Repository-wide line coverage baseline 95.48% (8914/9336) -> post-change 95.48% (8914/9336), signed delta +0.00 percentage points. New-code line coverage: WorktreeResolution.psm1 98.59% (140 covered / 2 missed), WorktreeTargetResolution.psm1 100.00% (101 / 0), combined 99.18% (241 covered / 2 missed). The new-code aggregate is at or above 85.00.

| Figure | Covered | Missed | Percentage | Source |
| --- | --- | --- | --- | --- |
| Repository-wide baseline (MCP) | 8914 | 422 | 95.48 | evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md |
| Repository-wide post-change (MCP) | 8914 | 422 | 95.48 | evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md |
| New code: WorktreeResolution.psm1 (self-hosted) | 140 | 2 | 98.59 | evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md |
| New code: WorktreeTargetResolution.psm1 (self-hosted) | 101 | 0 | 100.00 | evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md |
| New code: combined aggregate | 241 | 2 | 99.18 | sum of the two rows above |

Signed repository-wide delta: +0.00 percentage points (95.48 -> 95.48).

The repository-wide MCP figure is unchanged because the MCP runner did not include the two new modules in
its denominator ([P4-T6]: INSTALLED-EXTENSION-SETTINGS). The new-code figures come from the self-hosted run,
which read the in-repo run settings that register both modules.

These figures are read from the coverage XML files, not inferred from a passing run:
`CoveragePercentTarget = 0` (`pester.runsettings.psd1:285`) means a green run gates no threshold.

Statement: the new-code aggregate (99.18) is at or above 85.00, and each module individually is at or above 85.00.
