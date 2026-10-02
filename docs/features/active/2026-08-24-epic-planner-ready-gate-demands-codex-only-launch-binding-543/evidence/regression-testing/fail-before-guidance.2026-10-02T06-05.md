# Fail-before: guidance flags test (issue #543)

Timestamp: 2026-10-02T06-05
Task: P6-T2 [expect-fail]
Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_epic_planner_ready_gate_guidance_passes_both_codex_flags" -v` (before any guidance edit)
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- `1 failed in 0.14s` (0 passed).
- Assertion message: `AssertionError: <REPO_ROOT>: .agents/skills/epic-plan/SKILL.md` (the worktree's absolute root is redacted here as `<REPO_ROOT>`). The first checked pair, the root copy of `.agents/skills/epic-plan/SKILL.md`, lacks the collapsed phrase, which is the expected pre-edit state.
- P6-T1: the test function exists with a one-line docstring; `awk 'END{print NR}'` on the test file prints 436 (at or below 500).
