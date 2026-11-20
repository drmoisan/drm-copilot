# CLI Tests After CLI Module (Issue #464)

Timestamp: 2026-09-30T08-38
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py --deselect tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py::test_validator_module_main_guard_reaches_cli_main -q -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary:
- `20 passed, 1 deselected`; 0 failed.
- The same command with `--collect-only` printed `20/21 tests collected (1 deselected)`, so the passed count (20) equals the number of collected non-guard items (20).
- Deviation recorded: the first run of `test_main_returns_zero_for_complete_small_state_with_require_complete` failed (`ci_gate must be an object with keys: conclusion, head_sha, verified_at`) because `build_complete_small_state()` alone does not satisfy `--require-complete` (the sibling tests in `test_validate_orchestrator_state_completion.py` add `pr_gate` and `ci_gate`). The test now adds a `pr_gate` and a matching `ci_gate` to the fixture before writing it; the assertions are unchanged.
