# Contract Correction: Tests Asserting Changed Existing Behavior (#964)

Timestamp: 2026-10-17T03-37
Command: poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_plan_gate_document_docs.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
EXIT_CODE: 0
Output Summary: 87 passed. One proportionate contract correction applied: the design-level plan contract and the execution-environment brief now cover a task that changes existing observable behavior without naming the tests that assert it. All bundle copies are byte-identical; Codex generator check, Black, Ruff, and Pyright pass.

## Finding

Orchestrator step O1 re-planned an external spec under this branch's planning contract (`evidence/other/replan-962/`). Its single-pass preflight returned two substantive defects of one class: the plan changed the behavior of an existing function (the `run_test` and `run_test_coverage` argv) and of an existing test stub (the kcov stub output) without naming the existing tests that assert the current behavior. Those tests would fail once the change landed, so the plan's own acceptance could not be met. Neither the contract nor the brief stated this obligation. Per the spec's Risks section this is a finding about the contract, handled by one proportionate correction in this item.

## Changed Text Locations

- `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, heading `## Design-Level Plan Contract (Mandatory)`: new rule bullet "Changed existing behavior names its asserting tests." It requires a task that changes the signature, argv, output, exit status, or written files of an existing function, script, fixture, or test stub to name every existing test that asserts that behavior, found by searching the test tree for the symbol, the file name, and the asserted output, with a disposition per test (unchanged because unaffected, or updated with the reason), and states that the planner's adversarial self-review includes this search. The text is identical in the three surfaces.
- `.claude/skills/execution-environment/SKILL.md`, heading `## Preflight Defect Classes the Validator Cannot See`: new bullet for the class and the preflight check (search the test tree for the changed symbol, the file name, and the asserted output; confirm each matching test is named with its disposition). Copied byte-identically to the other five brief locations.
- Bundle mirrors under `extensions/drm-copilot/resources/` for the three contract copies and the three brief copies, written by the SCRATCH mirror-copy script.
- `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`: new test `test_contract_requires_tests_asserting_changed_existing_behavior`, which pins the rule inside the design-level section of every contract copy.
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: new test `test_brief_preflight_classes_include_changed_existing_behavior`, which pins the class inside the preflight-defect section of the brief.

Not changed: the agent summaries that paraphrase the design-level contract (`.claude/agents/atomic-planner.md`, `.github/agents/atomic_planning.agent.md`, and their variants) refer to the contract section by heading and do not restate its full rule list, so the new rule reaches them by that reference.

## Verifying Commands

| Command | EXIT_CODE | Result |
|---|---|---|
| `poetry run python SCRATCH/issue-964-correction.py <worktree root>` | 0 | four files edited (three contracts, canonical brief) |
| `sh SCRATCH/issue-964-mirror-copy.sh` | 0 | `COPIED=60 MISMATCH=0` |
| `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` | 0 | no file changed (porcelain status unchanged before and after) |
| `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | generated outputs current |
| `poetry run black --check scripts tests` and `poetry run black --check .` | 0 | `620 files would be left unchanged.` |
| `poetry run ruff check scripts tests` and `poetry run ruff check` | 0 | `All checks passed!` |
| `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| contract suite command in the header | 0 | 87 passed |
| pytest on the two new tests, `test_brief_has_no_g11_or_g12_findings`, and `test_brief_copies_are_byte_identical` | 0 | 4 passed; the brief has no G11 or G12 finding |
| `git show HEAD:<file> \| grep -c <new token>` for the canonical contract and brief | 1 (count 0) | the pinned tokens are absent at the parent commit, so the new tests fail against the pre-change text |

## Tonality

The new sentences were checked against `.claude/rules/tonality.md`: they are declarative, contain no humor, hyperbole, or metaphor, and state the failure mechanism without dramatizing it.
