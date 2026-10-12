# Pass-After: Mutation Skills Invoke the Bundled Script (Issue #890)

Timestamp: 2026-10-12T20-27
Task: P1-T26
Command: `poetry run pytest "tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_mutation_skills_invoke_bundled_mutation_script"`
EXIT_CODE: 0
Output Summary: `3 passed in 0.08s` — `[parallel-add]`, `[parallel-close]`, and `[parallel-orchestrate]` each extract `.claude/lib/bash/mutate-parallel-run.sh`, carry their required subcommand forms, and name none of the seven Python engine items.
