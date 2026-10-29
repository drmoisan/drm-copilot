# P14-T5 Execution-environment brief: Test Runtime section

Timestamp: 2026-10-29T10-24
Task: [P14-T5] Publish the test-runtime diagnosis in the execution-environment brief, byte-identical in all six copies.
Command: poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -p no:cacheprovider; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: pytest `152 passed in 1.78s` (exit 0), including the new `test_brief_test_runtime_section_orders_diagnosis_before_parallelism` and the updated `test_brief_has_required_headings`. The generator check exited 0 with empty output (no drift). All six brief copies share one SHA-256. Black "1 file left unchanged.", Ruff "All checks passed!", Pyright "0 errors, 0 warnings, 0 informations" on the contract test. `wc -l` of tests/scripts/dev_tools/test_execution_environment_brief_contracts.py = 477 (at most 500).

## Change

- Authored in `.github/skills/execution-environment/SKILL.md`: new `## Test Runtime` section between `## Coverage and File-Size Gates` and `## Test Isolation Checks` (six bullets: unit-test time expectation and the 15-minute suite and 10-second test indicators; JUnit aggregation with `--junitxml`, then `cProfile` and `pstats`; fix repeated production work first, built once per owning instance; share an immutable fixture with its own copy per test; shards reduce wall-clock time only; measure a candidate fix with `-p <module>` and `PYTHONPATH` from `SCRATCH`). The `description` frontmatter gains the topic "test runtime".
- The section names no consuming product, cites no line position or commit identifier, and adds no dependency.
- Copied byte-for-byte to the five other committed copies. The gitignored build output under packages/mcp-server/resources/ was not edited (P14-T12 refreshes it).
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: `"## Test Runtime"` added to `_REQUIRED_HEADINGS` between the two named headings; new test `test_brief_test_runtime_section_orders_diagnosis_before_parallelism` asserts the eight tokens.

## SHA-256 of the six copies

| Copy | SHA-256 |
| --- | --- |
| .github/skills/execution-environment/SKILL.md | 82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76 |
| .claude/skills/execution-environment/SKILL.md | 82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76 |
| .agents/skills/execution-environment/SKILL.md | 82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76 |
| extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md | 82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76 |
| extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md | 82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md | 82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76 |

## Existing assertion dispositions

- Unchanged and passing: `test_brief_copies_are_byte_identical`, `test_brief_has_no_consuming_names`, `test_brief_has_no_g11_or_g12_findings` and every other test in the brief contract module; `test_execution_environment_fact_is_unchanged_across_copies` in test_discovery_documentation_contracts.py; the brief tokens in test_single_pass_preflight_contracts.py.
- Updated: `test_brief_has_required_headings` through the new `_REQUIRED_HEADINGS` entry.

Result: PASS
