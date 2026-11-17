# Converter Python package — standing guidance not emitted ([P2-T2])

Timestamp: 2026-11-17T20-21
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/codex_native_converter (the launcher runs `poetry run pytest -n auto`); the same launcher with the 11 node IDs listed below; grep -rn render_merged_standing_guidance scripts tests
EXIT_CODE: 0
Output Summary: `pytest -n auto` over `tests/scripts/dev_tools/codex_native_converter` reports "85 passed". The 11 named nodes report "11 passed". The search for `render_merged_standing_guidance` under `scripts` and `tests` returns 0 matches. No Python module was added.

Production changes (in parity with [P2-T1]):
- `mapping.py` `plan_target_paths`: a `TargetRole.STANDING_GUIDANCE` record keeps its role and conversion class, gets `target_path=None`, and gains `STANDING_GUIDANCE_NOT_EMITTED_NOTE` ("Not emitted: AGENTS.md is a hand-authored source maintained outside the converter.", the same literal as the TypeScript constant) after its existing notes.
- `engine.py` `_render_generated_output` and `pipeline.py` `build_topology_edges`: standing-guidance source paths derive from the role alone, and the `AGENTS.md` merge branch is removed.
- `pipeline.py`: `render_merged_standing_guidance` and the standing-guidance branch of `_wrap_rendered_target_content` are deleted.
- `validation.py` `_validate_duplicate_targets`: the `AGENTS.md` exemption is removed.
- Docstrings are updated.

Tests (existing modules only; all passed):
- Updated: `test_end_to_end.py::test_github_copilot_fixture_review_run_produces_required_report_set` (no proposed-tree `AGENTS.md`); `test_github_copilot_fixture_merges_repo_wide_instructions_into_agents` renamed `test_github_copilot_fixture_emits_no_agents_target_for_standing_guidance` (no `AGENTS.md` output key, no `Converted standing guidance` text, null targets, no `duplicate-target-path`); `test_cli_review.py::test_review_mode_writes_required_artifacts_without_destination_mutation`; `test_reporting_topology_end_to_end.py::test_conversion_report_topology_shows_decomposed_agent_fan_out` (no edge endpoint `AGENTS.md` in any of the three charts); `test_validation.py::test_validate_conversion_plan_allows_merged_standing_guidance_targets` renamed `test_validate_conversion_plan_ignores_unemitted_standing_guidance_records`.
- New: `test_mapping.py::test_plan_target_paths_leaves_standing_guidance_unemitted_with_reason`; `test_end_to_end.py::test_github_copilot_fixture_reports_standing_guidance_as_not_emitted` and `test_github_copilot_fixture_keeps_standing_guidance_reference_rewrites` (the `beast-topology` output still names `AGENTS.md`); `test_cli_apply.py::test_apply_mode_writes_no_destination_agents_file` and `test_apply_mode_leaves_existing_destination_agents_file_unchanged` (the recording file system is seeded with a destination `AGENTS.md` whose content is unchanged after `run_apply_mode`); `test_validation.py::test_validate_conversion_plan_reports_duplicate_agents_targets`.
