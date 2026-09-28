# Final QA — Bundled-Configuration Parity Evidence (P8-T6)

Timestamp: 2026-09-27T15-56

Command: none (extraction from recorded artifacts)

EXIT_CODE: 0

Python (newest P3-T2 artifact: regression-testing/phase3-python-consumer-run.2026-09-27T15-16.md, line 46):

```
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset PASSED [ 96%]
```

PowerShell (newest P7-T3 artifact: qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md, line 66):

```
PASS BlastRadius regression corpus for issue 452.Bundled configuration parity.admits the same separator-free root surfaces from both committed tables
```

Acceptance evaluation:

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| Python PASSED node ID ending in test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset | present | present | pass |
| Pester PASS line containing "Bundled configuration parity" | present | present | pass |

Output Summary: PASS. Both consumers assert and pass bundled-configuration parity: the Python parity test PASSED in the newest P3-T2 run, and the Pester parity test PASSED in the repository-wide P7-T3 run (AC-13).
