# Python Test-File Split (Fix #4, Remediation Cycle 1)

- **Timestamp:** 2026-07-02T23-35
- **Tasks:** [P4-T3], [P4-T4], [P4-T5], [P4-T6], [P4-T7]

## [P4-T3] Line-Count Result

- **Command:** `(Get-Content tests/scripts/dev_tools/test_validate_orchestration_artifacts.py).Count`
- **EXIT_CODE:** 0
- **Output Summary:** **513 lines** — down from the [P0-T6] baseline of 739 lines (a reduction of
  226 lines), but still 13 lines above the 500-line hard cap.

**Residual-gap rationale:** the plan's [P4-T1] task named exactly 10 functions to relocate (5
CLI-dispatch integration tests plus 5 `epic-orchestrator-state` dispatch tests), and [P4-T2]
explicitly required "leaving every other existing test and helper in place and unmodified." The
remaining 513 lines consist of: the module docstring/imports (13 lines), 7 shared builder helpers
(`build_valid_orchestrator_state`, `build_valid_policy_audit_text`, `build_read_text_stub`,
`get_first_receipt`, `build_namespaced_orchestrator_state`, `build_complete_large_orchestrator_state`)
that back both this file's remaining 12 `test_` functions and the new dispatch module's imports,
and those 12 remaining tests themselves (plan-text validation, policy-audit text validation,
code-review/feature-audit text validation, the split-entrypoint re-export lock-in test, and the
`orchestrator-state` payload-shape tests, several of which depend directly on
`get_first_receipt`/`build_namespaced_orchestrator_state`). None of these were named for
relocation by the plan, and moving any of them would duplicate or fragment the shared-fixture
helpers across three files rather than two, which the plan's fix-4 scope did not authorize.
Per the plan's own fallback acceptance clause, this is recorded as: line count lower than the
739-line baseline, with the residual 13-line gap and this rationale documented here.

## [P4-T4] Format Check

- **Command:** `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`
- **EXIT_CODE:** 0
- **Output Summary:** `All done! 208 files would be left unchanged.` Zero files require
  reformatting.

## [P4-T5] Lint Check

- **Command:** `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`
- **EXIT_CODE:** 0
- **Output Summary:** `All checks passed!` Zero violations.

## [P4-T6] Type-Check

- **Command:** `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`
- **EXIT_CODE:** 0
- **Output Summary:** `0 errors, 0 warnings, 0 informations`.

## [P4-T7] Test Run

- **Command:** `poetry run pytest tests/scripts/dev_tools -q`
- **EXIT_CODE:** 0
- **Output Summary:** **1184 passed, 19 skipped, 0 failed** — equal to the [P0-T10] baseline pass
  count (the split relocated tests without adding or removing any; the 9 collectible test
  functions moved into `test_validate_orchestration_artifacts_dispatch.py` and the corresponding
  9 tests removed from `test_validate_orchestration_artifacts.py` net to zero change in total
  count). The 19 skips are the same pre-existing `.codex`/`.agents` gitignore-unavailable-in-CI
  skips recorded at baseline.
