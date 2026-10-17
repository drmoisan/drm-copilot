# QA Gate: Python Contract Tests (Issue #973, Phase 4 pass 1)

Timestamp: 2026-10-17T13-57
Command: sh SCRATCH/issue-973-pytest.sh <worktree> (per file: poetry run pytest tests/scripts/dev_tools/<file>.py -q --no-cov -p no:cacheprovider -rfE); sh SCRATCH/issue-973-pyextra.sh <worktree> (verbose run of the brief contract file; the two pack-manifest completeness files; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0

| File | Passed | Failed | Skipped | Exit |
|---|---|---|---|---|
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | 18 | 0 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 | 0 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | 9 | 0 | 0 | 0 |
| `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | 12 | 0 | 0 | 0 |

Named tests in the verbose run: `test_brief_copies_are_byte_identical` PASSED, `test_brief_ci_section_names_jobs_and_required_contexts` PASSED, `test_brief_has_no_g11_or_g12_findings` PASSED.

Additional mirror checks named by the execution-environment brief (`## Contract Tests That Pin Mirrored Files`): `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_codex_and_agents_pack_manifest_completeness.py` 4 passed, 0 failed; Codex generator `--check` exit code 0.

Output Summary: failed count 0 for each of the four files (53 passed in total); the three named brief tests pass; pack-manifest completeness and the Codex generator check also pass.
