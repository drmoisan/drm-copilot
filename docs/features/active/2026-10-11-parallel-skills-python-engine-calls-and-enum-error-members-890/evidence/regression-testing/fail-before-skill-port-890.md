# Fail-Before: Mutation Skills Invoke the Bundled Script (Issue #890)

Timestamp: 2026-10-12T20-22
Task: P1-T20 [expect-fail]
Command: `poetry run pytest "tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_mutation_skills_invoke_bundled_mutation_script"`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `3 failed in 0.14s`, run before any skill edit. Each case failed at assertion (a): `.claude/lib/bash/mutate-parallel-run.sh` is not extracted from the unedited skill.

Failing node IDs:

- `test_mutation_skills_invoke_bundled_mutation_script[parallel-add]`
- `test_mutation_skills_invoke_bundled_mutation_script[parallel-close]`
- `test_mutation_skills_invoke_bundled_mutation_script[parallel-orchestrate]`
