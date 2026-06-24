# Coverage Delta (P9-T4)

Timestamp: 2026-06-24T13-09

Compares baseline coverage (P0-T4 PowerShell, P0-T5 Python) against post-change coverage (P9-T1 PowerShell, P9-T2 Python). PowerShell coverage is line/command coverage (JaCoCo via Pester); Pester's PowerShell coverage engine does not emit BRANCH counters, so branch coverage is reported only for Python.

| Module | Baseline line cov | Post-change line cov | Baseline branch cov | Post-change branch cov | Changed-line cov | Regression on changed lines |
|---|---|---|---|---|---|---|
| validate-task-researcher-output.ps1 | 88.1% (52/59) | 88.5% (54/61) | n/a (not emitted) | n/a (not emitted) | covered | none |
| enforce-evidence-locations.ps1 | 70.4% (19/27) | 81.5% (22/27) | n/a (not emitted) | n/a (not emitted) | covered | none |
| validate_evidence_locations.py | 100% (28/28 stmts) | 100% (28/28 stmts) | 100% (12/12) | 100% (12/12) | covered | none |

## Threshold disposition

- validate-task-researcher-output.ps1: 88.5% line >= 85%. PASS.
- validate_evidence_locations.py: 100% line >= 85%, 100% branch >= 75%. PASS.
- enforce-evidence-locations.ps1: 81.5% line, below the 85% line threshold. Coverage improved +11.1 points from the 70.4% baseline by adding tests for the previously-uncovered empty-input, missing-file_path, and malformed-JSON logic branches. The only remaining uncovered lines (146, 148, 149, 152, 154) are the script entry-point execution block, which is unreachable when the script is dot-sourced by unit tests (the dot-source guard returns first). This is a pre-existing structural condition for this small (27-line) entry-point-bound file; reaching >= 85% would require refactoring the entry-point wiring (outside this plan's scope) or an integration test that executes the script as a process. The feature's changed line (the added 'artifacts/research/' forbidden prefix) is inside the fully-covered Test-EvidenceLocationForbidden function. No regression on changed lines.

## Conclusion

No regression on changed lines for any of the three modules. Two of three modules meet the absolute 85%/75% thresholds. enforce-evidence-locations.ps1 line coverage (81.5%) is below the 85% line threshold due to a pre-existing untestable entry-point block; this is recorded transparently rather than reported as a threshold PASS. The changed lines introduced by this feature are covered in all three modules.
