# Phase 7 Final QA — Coverage Delta (#362, Remediation Cycle 1)

Timestamp: 2026-07-18T12-18
Command: comparison of Phase 0 baseline (`evidence/remediation-baseline/r1c1-phase0-pytest-baseline.2026-07-18T12-18.md`) vs Phase 7 post-change (`evidence/qa-gates/r1c1-pytest.2026-07-18T12-18.md`), both `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
EXIT_CODE: 0

Output Summary:

| Metric | Baseline (Phase 0) | Post-change (Phase 7) | Delta |
|---|---|---|---|
| Line coverage | 88.16% (9951/11287) | 88.17% (9954/11290) | +0.01 pp |
| Branch coverage | 78.9% (3350/4246) | 78.9% (3350/4246) | 0.00 pp |
| Combined percent_covered | 85.63% | 85.63% | 0.00 pp |
| Tests passed | 1704 | 1708 | +4 |
| Tests skipped | 1 | 0 | -1 |

Threshold checks:
- Line coverage >= 85%: PASS (88.17%).
- Branch coverage >= 75%: PASS (78.9%).
- No regression on changed lines: PASS. The only changed production file is `scripts/dev_tools/discovery/__init__.py`, which is at 100% line coverage (0 missing lines) post-change; overall line coverage rose (+0.01 pp) and branch coverage is unchanged. The seven artifact JSON templates and `domain-profile.yaml` are data files (not executable code) and are not in the coverage denominator; test files are excluded from coverage measurement per policy.

Changed/new code coverage:
- `scripts/dev_tools/discovery/__init__.py` (re-export surface restored): 100% line coverage, exercised by the new `tests/scripts/dev_tools/discovery/test_package_exports.py` and by existing package importers.
- New tests (`test_package_exports.py`, `test_domain_profile_template_parses_with_real_loader`, `test_generated_artifacts_conform_to_real_schemas`): excluded from coverage denominator (test code) but all pass and exercise the production import surface and data templates.
