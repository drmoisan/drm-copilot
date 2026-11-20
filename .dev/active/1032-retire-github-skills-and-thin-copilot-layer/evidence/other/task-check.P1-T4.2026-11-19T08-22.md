# Task Check P1-T4

Timestamp: 2026-11-19T08-22
Plan: plan.2026-10-30T18-39.md
Changed files: `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` (`canonical_path` returns the child 3 source `.agents/skills/<name>/SKILL.md`; `ROLE_LINK` matches the `.agents` link `](../../../.codex/agents/<role>.toml)`; `test_generated_copies_are_the_deterministic_role_link_rewrite` asserts the Claude copy equals the shared source under that rewrite (the Codex copy is the source itself); module docstring); `tests/scripts/dev_tools/test_discovery_workflow_contracts.py` (`skill` reads `.agents/skills/<name>/SKILL.md`). Child 3 had not re-anchored either symbol (P0-T4), so both are edited.
Selection rule: the two changed test modules.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `env -u VIRTUAL_ENV poetry run black --check` (2 modules) | 0 | 2 files would be left unchanged |
| `env -u VIRTUAL_ENV poetry run ruff check` (2 modules) | 0 | All checks passed |
| `env -u VIRTUAL_ENV poetry run pyright` (2 modules) | 0 | 0 errors, 0 warnings |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <2 modules> -q -p no:cacheprovider` | 0 | 204 passed |
| Grep for RETIRED-PATH and a `".github"` / `"skills"` join over both modules | 0 | 0 matches |
