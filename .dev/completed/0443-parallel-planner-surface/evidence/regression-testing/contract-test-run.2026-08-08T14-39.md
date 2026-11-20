# Phase 6 Contract Test Run — [P6-T4]

Timestamp: 2026-08-08T14-39

## Command (as stated in [P6-T4])

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py -v`

EXIT_CODE: 0

Output Summary: 15 passed in 0.06s. Collected 15 items, 0 failed, 0 skipped,
0 errors. Python 3.13.12, pytest 9.0.2, rootdir
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59`.
Every test in the module passed.

Tests executed:

- `test_parallel_planner_surface_files_exist`
- `test_agent_frontmatter_declares_required_tool_allowlist`
- `test_agent_frontmatter_declares_name_and_preloaded_skills`
- `test_skill_frontmatter_routes_to_the_parallel_planner_agent`
- `test_skill_carries_the_preparation_mode_kickoff_markers`
- `test_skill_branches_preparation_worktrees_from_origin_main`
- `test_skill_names_the_planner_checkpoint_and_manifest_paths`
- `test_skill_names_both_kickoff_artifact_paths`
- `test_agent_frontmatter_declares_no_epic_docs_scope`
- `test_preparation_kickoff_line_carries_neither_mode_marker`
- `test_skill_omission_of_mode_markers_is_stated_deliberately`
- `test_skill_contains_no_dependency_authoring_instruction`
- `test_skill_contains_no_integration_branch_creation_instruction`
- `test_skill_contains_no_worthiness_gate`
- `test_protected_surfaces_retain_their_identifying_content`

## Command (split companion module)

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py -v`

EXIT_CODE: 0

Output Summary: 8 passed in 0.05s. Collected 8 items, 0 failed, 0 skipped,
0 errors. Every test in the module passed.

Tests executed:

- `test_skill_cites_three_argument_contention_signature`
- `test_skill_uses_import_only_upstream_invocation`
- `test_skill_cites_two_parameter_cohort_seeding_signature`
- `test_skill_cites_derivation_over_document_text`
- `test_skill_documents_the_cohort_recomputation_parity_obligation`
- `test_skill_attributes_git_integrity_verification_to_f4`
- `test_skill_claims_the_kickoff_contract_as_delivered_by_this_feature`
- `test_skill_cites_planner_invariant_p5_as_the_parity_basis`

Combined total across both Phase 6 modules: 23 passed, 0 failed.

## Conditional Split Record ([P6-T3])

The 500-line production/test file limit in `.claude/rules/general-code-change.md`
required splitting the Phase 6 contract test. After [P6-T1] and [P6-T2] the
single module measured 410 lines; adding the [P6-T3] landed-contract and
F4-obligation assertions to the same file would have exceeded 500 lines.

The split follows the scenario-class convention already applied in this feature
to `test_parallel_kickoff_contract.py` / `test_parallel_kickoff_contract_tables.py`,
including the module-level import of shared helpers from the first module.

Measured line counts:

| Module | Lines | Scenario class |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` | 410 | [P6-T1] positive surface assertions and [P6-T2] negative assertions plus unmodified-surface content guards |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py` | 260 | [P6-T3] landed-contract supersessions and F4-obligation assertions |

Both modules are under the 500-line limit. The second module imports
`read_repo_text` and `PARALLEL_PLAN_SKILL_RELATIVE` from the first via
`from tests.scripts.dev_tools.test_parallel_planner_surface_contracts import ...`.

## Discriminating-Assertion Evidence ([P6-T3] acceptance)

[P6-T3] requires that the recomputation-parity assertion and the
`conflicts(a, b, config)` assertion each fail against skill text lacking them.
Each guarantee is expressed as a predicate over document text and asserted
twice per test: true against the delivered skill, false against the in-memory
`SUPERSEDED_SKILL_TEXT` counterexample carrying the pre-Phase-1 phrasing
(`conflicts(a, b)`, `python -m` CLI invocations, a pinned-set seeding argument,
F3-owned git integrity, and the kickoff module as a pending F3 recommendation).
No temporary file and no external process is used.

## Toolchain Status (Python)

| Stage | Command | Result |
| --- | --- | --- |
| Format | `poetry run black --check <both modules>` | EXIT_CODE 0 — 2 files would be left unchanged |
| Lint | `poetry run ruff check <both modules>` | EXIT_CODE 0 — All checks passed |
| Type check | `poetry run pyright <both modules>` | EXIT_CODE 0 — 0 errors, 0 warnings, 0 informations |
| Test | recorded above | EXIT_CODE 0 — 23 passed |
