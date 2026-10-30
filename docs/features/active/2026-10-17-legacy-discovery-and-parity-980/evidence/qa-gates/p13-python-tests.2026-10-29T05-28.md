# P13-T1 Python test gate with coverage on the final tree

Timestamp: 2026-10-29T05-28
Task: [P13-T1] Repeat the Python formatting, lint, type and full coverage loop.
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p13t1-coverage.json --junitxml=SCRATCH/issue-980-p13t1-junit.xml -p no:cacheprovider; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-980-p13t1-coverage.json --min-line 85 --min-branch 75
EXIT_CODE: 0 (pytest), 0 (threshold gate)
Output Summary: 15657 passed, 6 skipped, 0 failed, 0 errors in 17965.16s (4:59:25) over the complete `tests` population, run from 2026-10-29T00-28 to 05-28 (UTC). The six skips are the same six pre-existing skips as the baseline and P11-T2.

Repository coverage from the JSON report totals: lines 31975/33079 (96.66%) and branches 11639/12438 (93.58%), above the 85% line and 75% branch floors. The terminal TOTAL row is `33079 1104 12438 553 96%`, and the CI threshold gate passes at 85/75. P11-T5 recorded 96.67% lines and 93.61% branches over 32507 statements, so Phase 12 adds 572 statements at the same aggregate coverage. The per-file figures for P13-T4 come from `SCRATCH/issue-980-p13t1-coverage.json`.

## Loop record

- Pass 1 (2026-10-28, before the rebase onto origin/main): Black, Ruff and Pyright clean (`p13-python-{format,lint,types}.2026-10-28T20-46.md`). The full coverage run returned 15656 passed, 1 failed: `tests/discovery_runtime/test_extension_inputs.py::test_repository_roles_retain_pins_and_reject_conflicting_local_identity[True]`.
  - Cause: the P12-T12 profile binding rule refuses a related repository entry that reuses the local checkout id when the profile is constructed (`PROFILE_BINDING`), before the projection's own guard is reached.
  - Repair: the parametrized test is split into `test_repository_roles_retain_related_pins` and `test_repository_roles_reject_a_conflicting_local_identity`. The second still asserts the projection's "conflicting identities" refusal, driven through the module's real `repository_pins` seam.
  - The construction-time refusal itself is asserted by `tests/discovery_runtime/test_profile_v2.py::test_repository_entry_cannot_reuse_the_local_checkout_identifier`. No assertion was weakened.
- Pass 2 (this run, restarted from formatting on the rebased tree): Black "971 files would be left unchanged.", Ruff "All checks passed!", and Pyright "0 errors, 0 warnings, 0 informations" (`p13-python-{format,lint}.2026-10-29T00-26.md`, `p13-python-types.2026-10-29T00-27.md`), then the clean coverage run above.

During this run, three non-Python files changed: the two TypeScript test corrections of P13-T2 and the one-line comment in `DiscoveryAuthorization.psm1` and its two bundle copies (P13-T3). None is in the Python toolchain's scope. The Python contract suites that read those files were re-run on the final tree afterwards (`p13-mirror-and-publication-contracts.2026-10-29T02-34.md`: 9541 passed).
Result: PASS
