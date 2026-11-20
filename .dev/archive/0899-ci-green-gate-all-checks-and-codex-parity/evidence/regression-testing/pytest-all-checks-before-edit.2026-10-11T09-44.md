# Fail-Before Run: All-Checks Contract Module (P1-T2, expect-fail)

Timestamp: 2026-10-12T16-20
Task: P1-T2 [expect-fail]
Command: poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
32 failed, 2 passed in 0.18s
- Failing nodes (32): the ten section-contract cases (test_s9_queries_every_check_without_required_flag x2, test_s9_states_no_checks_error_is_never_green x2, test_merge_on_green_always_rereads_every_check x2, test_codex_ci_green_gate_invokes_parser_with_epic_child_guard x2, test_codex_ci_green_gate_fails_closed_without_parser x2) and the 22 test_surface_restates_no_required_only_population cases.
- Passing nodes (2): test_required_only_phrases_reports_wrapped_superseded_wording and test_required_only_phrases_accepts_all_checks_wording (in-memory detector tests).
- Representative failure messages: `.claude/skills/orchestrate/SKILL.md restates: ['failed required check', 'required checks on a non-epic pr']`; `.agents/skills/orchestrate/SKILL.md restates: ['required ci check', 'required github check', 'failed required check', 'required checks pass', 'required checks were observed']`; parallel-orchestrate merge step is missing the five MERGE_ON_GREEN_FRAGMENTS.
- Result matches the expected summary `32 failed, 2 passed`; the module discriminates the pre-edit tree.
