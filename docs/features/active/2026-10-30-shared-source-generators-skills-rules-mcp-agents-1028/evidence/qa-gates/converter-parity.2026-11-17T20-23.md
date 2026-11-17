# Converter parity record and documentation ([P2-T3])

Timestamp: 2026-11-17T20-23
Command: grep -c 'bundled Python runner' README.md; grep -c 'merged into the generated' README.md; grep -c 'standing-instruction roots' README.md; grep -c 'reported as not emitted' README.md; grep -c 'authoritative Python implementation' scripts/dev_tools/codex_native_converter/README.md
EXIT_CODE: 0
Output Summary: `README.md` has 0 matches each for `bundled Python runner`, `merged into the generated` and `standing-instruction roots`, and 1 match for `reported as not emitted`. `scripts/dev_tools/codex_native_converter/README.md` has 0 matches for `authoritative Python implementation`. All seven behaviors below have a Jest test and a pytest test, and each test passed in [P2-T1] (`evidence/qa-gates/converter-ts.2026-11-17T20-13.md`) or [P2-T2] (`evidence/qa-gates/converter-py.2026-11-17T20-21.md`).

## Documentation changes
- `README.md` `## Codex-native converter`: the extension command `drmCopilotExtension.runCodexNativeConverter` and the MCP tool `run_codex_native_converter` run the in-process TypeScript port, and the Poetry script `codex-native-converter` runs the Python package, kept in parity. Standing-guidance sources are "reported as not emitted" because `AGENTS.md` is hand-authored, and reference rewrites to `AGENTS.md` remain.
- `README.md` `### Fail-closed validation model`: names both implementations.
- `README.md` `## Repository layout`: `AGENTS.md` is the hand-authored source that `CLAUDE.md` imports.
- `scripts/dev_tools/codex_native_converter/README.md`: names the TypeScript port as the implementation behind the VS Code and MCP surfaces.

## Parity pairs

| Behavior | Jest test (TypeScript port) | pytest test (Python package) |
| --- | --- | --- |
| Planning | `mapping.test.ts` `leaves standing guidance unemitted with the hand-authored-source reason` | `test_mapping.py::test_plan_target_paths_leaves_standing_guidance_unemitted_with_reason` |
| Generated output | `engine.test.ts` `does not emit AGENTS.md for repo-wide standing-guidance sources` | `test_end_to_end.py::test_github_copilot_fixture_emits_no_agents_target_for_standing_guidance` |
| Apply mode | `engine.test.ts` `does not create a destination AGENTS.md in apply mode` and `leaves an existing destination AGENTS.md unchanged in apply mode` | `test_cli_apply.py::test_apply_mode_writes_no_destination_agents_file` and `test_cli_apply.py::test_apply_mode_leaves_existing_destination_agents_file_unchanged` |
| Report disposition | `engine.test.ts` `reports each standing-guidance source as not emitted with the hand-authored-source reason` | `test_end_to_end.py::test_github_copilot_fixture_reports_standing_guidance_as_not_emitted` |
| Reference rewrites | `engine.test.ts` `keeps standing-guidance reference rewrites to AGENTS.md in other outputs` | `test_end_to_end.py::test_github_copilot_fixture_keeps_standing_guidance_reference_rewrites` |
| Topology | `pipeline.test.ts` `adds no AGENTS.md destination when standing guidance is not emitted` | `test_reporting_topology_end_to_end.py::test_conversion_report_topology_shows_decomposed_agent_fan_out` |
| Duplicate targets | `validation.test.ts` `reports duplicate-target-path for two records targeting AGENTS.md` (and `ignores unemitted standing-guidance records in duplicate-target checks`) | `test_validation.py::test_validate_conversion_plan_reports_duplicate_agents_targets` (and `test_validate_conversion_plan_ignores_unemitted_standing_guidance_records`) |

The not-emitted note literal is identical in both implementations: `STANDING_GUIDANCE_NOT_EMITTED_NOTE` in `mapping.ts` and in `mapping.py`, each asserted by its planning test.
