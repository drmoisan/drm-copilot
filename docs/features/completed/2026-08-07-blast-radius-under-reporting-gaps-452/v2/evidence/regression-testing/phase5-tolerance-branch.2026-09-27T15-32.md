# Phase 5 Tolerance Branch (P5-T1)

Timestamp: 2026-09-27T15-32

Branch taken: NOT FOUND

## (a) P0-T29 search result

From baseline/phase0-tolerance-detection.2026-09-27T14-54.md: the decisive search `git grep -n -E "conflict_tolerance|overlap_tolerance|integration_cost|conflictTolerance|overlapTolerance|integrationCost" -- scripts .claude/lib .claude/hooks .codex extensions/drm-copilot/src config packages` printed no match line and exited 1; the positive control matched (count 1); `TOLERANCE_BRANCH: NOT FOUND`.

## (b) Skip lines carrying the #722 reason

Python (from regression-testing/phase3-python-consumer-run.2026-09-27T15-16.md):

```
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
```

Pester (from regression-testing/phase4-pester-consumer-run.2026-09-27T15-28.md):

```
SKIP BlastRadius regression corpus for issue 452.Tolerance branch.keeps a scheduling edge for every must-conflict case at the strictest tolerance
<skipped message="Exception: is skipped, because  because Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.,"></skipped>
```

## (c) Detection-level evidence for the eight must-conflict cases

| Case | Python PASSED node ID | Pester PASS name | Corpus expected verdict and reasons |
| --- | --- | --- | --- |
| g1-plan-poetry-lock | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-plan-poetry-lock] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-poetry-lock | conflict true; path_overlap "poetry.lock ~ poetry.lock", shared_surface_overlap "poetry.lock" |
| g1-plan-package-lock | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-plan-package-lock] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-package-lock | conflict true; path_overlap "package-lock.json ~ package-lock.json", shared_surface_overlap "package-lock.json" |
| g1-radius-quality-tiers | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-radius-quality-tiers] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-radius-quality-tiers | conflict true; path_overlap "quality-tiers.yml ~ quality-tiers.yml", shared_surface_overlap "quality-tiers.yml" |
| g2-dir-vs-glob | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-dir-vs-glob] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-dir-vs-glob | conflict true; path_overlap "scripts/dev_tools ~ scripts/dev_tools/**" |
| g2-glob-vs-dir | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-glob-vs-dir] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-glob-vs-dir | conflict true; path_overlap "scripts/dev_tools ~ scripts/dev_tools/**" |
| g2-artifacts-dir-vs-glob | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-artifacts-dir-vs-glob] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-dir-vs-glob | conflict true; path_overlap "artifacts/orchestration ~ artifacts/orchestration/**" |
| g2-artifacts-glob-vs-dir | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-artifacts-glob-vs-dir] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-glob-vs-dir | conflict true; path_overlap "artifacts/orchestration ~ artifacts/orchestration/**" |
| g2-empty-modules-dir-vs-glob | tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-empty-modules-dir-vs-glob] | BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-empty-modules-dir-vs-glob | conflict true; path_overlap "scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**" |

These detection-level verdicts are recorded in place of the strictest-tolerance scheduling-edge assertion.

## Reference count

Command: grep -c -F -e "#722" tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1
EXIT_CODE: 0
Output:

```
tests/scripts/dev_tools/test_blast_radius_regression_452.py:3
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1:2
```

Output Summary: Branch NOT FOUND. The pre-authorized skip branch is taken in both consumers with a reason naming #722; all eight must-conflict cases pass at the detection level in both runtimes; each consumer file references #722 at least once (3 and 2).
