# Fail-Before Exception: #793 L20 and L21 (P4-T4)

Timestamp: 2026-10-13T11-22

WhyFailingRunImpossible: L20 converts a loop into a parametrized test and L21 narrows a parametrize table to the `value` column; both restructure tests over unchanged production code (`scripts/dev_tools/validate_epic_orchestrator_state.py` is not edited), so no assertion can fail before the change. Precedent: #846 spec A8 (test-structure changes carry an exception dossier rather than a failing run).

## Alternative proof

The P4-T3 run (`evidence/regression-testing/p8-793-after.2026-10-13T11-22.md`, `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py -v`, EXIT_CODE 0, 28 passed) lists the restructured nodes:

- 8 nodes `test_enum_site_accepts_every_valid_string_status[<status>]`, one per member of `validator.VALID_MERGE_STATUS` (`blocked_conflict_loop_limit`, `ci_green`, `merge_conflict`, `merged`, `not_started`, `pr_open`, `worktree_created`, `worktree_removed`), each with a per-status assertion message.
- 4 nodes `test_completion_site_reports_non_string_merge_status[list|dict|int|bool]` driven by the new `NON_STRING_ROWS` constant, with `expected_repr` removed from the signature; `VALUE_ROWS` remains in use by `test_enum_site_reports_non_string_merge_status`.
