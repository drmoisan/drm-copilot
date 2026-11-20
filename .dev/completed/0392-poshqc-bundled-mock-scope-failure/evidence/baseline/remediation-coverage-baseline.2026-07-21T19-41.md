Timestamp: 2026-07-21T19-41

Command: pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1
EXIT_CODE: 0

Output Summary:
- Format stage: `Already formatted` / `Formatted: /repo/test.ps1` (transient dry-run publish fixture; no PoshQC-scanned production/test file changed) — 0 files changed under scanned scope.
- Analyze stage: `PSScriptAnalyzer passed: no findings under /repo` (reported twice, once per scan pass) — 0 findings.
- Test stage: `Tests Passed: 1332, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0` — 0 failed.
- Coverage stage: `Covered 87.92% / 0%. 3,253 analyzed Commands in 31 Files.` (INSTRUCTION-basis summary line from Pester; LINE-basis percentages below parsed directly from artifacts/pester/powershell-coverage.xml).

Per-file LINE coverage (parsed from artifacts/pester/powershell-coverage.xml, sourcefile name="PoshQC.Testing.psm1"):
- LINE counter: missed=46, covered=149, total=195
- Percentage: 149/195 = 76.41%

Repo measured-set aggregate LINE coverage (parsed from artifacts/pester/powershell-coverage.xml, top-level <report> counters):
- LINE counter: missed=279, covered=2097, total=2376
- Percentage: 2097/2376 = 88.26%

Uncovered lines for PoshQC.Testing.psm1 (46 lines, ci=0 and mi>0 in the per-line detail):
98, 291, 309, 314, 315, 316, 322, 332, 340, 341, 342, 346, 350, 351, 352, 353, 354, 356, 357, 359, 368, 369, 401, 402, 403, 410, 411, 412, 413, 414, 415, 417, 418, 419, 420, 423, 424, 427, 428, 433, 434, 435, 436, 437, 438, 439

This exactly matches the uncovered-line list and 76.41% (149/195) figure recorded in remediation-inputs.2026-07-21T19-23.md and the remediation plan's Objective statement.
