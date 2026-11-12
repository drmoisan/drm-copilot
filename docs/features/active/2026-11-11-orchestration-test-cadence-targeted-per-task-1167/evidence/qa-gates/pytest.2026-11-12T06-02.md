# Pytest Final Gate ([P2-T3], remediation cycle R1)

Timestamp: 2026-11-12T06-02
Command: sh SCRATCH/issue-1167-pytest.sh p2t3 (env -u VIRTUAL_ENV poetry run pytest -n auto -q --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/issue-1167-p2t3-cov.json, from the item worktree root; totals read from the JSON report)
EXIT_CODE: 0
Output Summary:
- One pytest -n auto run: 16598 passed, 6 skipped, 0 failed, 0 errors in 173.56 s; exit 0. The run includes test_plan_templates_carry_premortem_skeleton, test_copilot_bundle_copies_match_canonical, test_atomic_plan_contract_matches_bundled_mirror, and the push-down resource contracts, all passing.
- Repo-wide line coverage (JSON totals): 34334 / 35355 = 97.11%.
- Repo-wide branch coverage (JSON totals): 12668 / 13424 = 94.37%.
- Comparison with the Phase 0 baseline (pytest.2026-11-12T03-29.md: 16598 passed, 0 failed, line 97.11%, branch 94.37%): no new failing test; line and branch coverage equal the baseline and are above 85% and 75%. No Python production file changed, so no per-file comparison applies.
