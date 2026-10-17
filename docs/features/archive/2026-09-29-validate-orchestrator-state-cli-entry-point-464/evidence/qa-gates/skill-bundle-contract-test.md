# Skill-Bundle Contract Test (Issue #464)

Timestamp: 2026-09-30T09-12
Command: poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled -q -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary: `1 passed in 0.13s`. This test does not enumerate `.claude/state/`, so it passes without isolation.
