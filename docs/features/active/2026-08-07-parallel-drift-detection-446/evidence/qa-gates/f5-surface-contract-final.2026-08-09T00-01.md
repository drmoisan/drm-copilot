# F5 Surface-Contract Suite — Final QC, Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P8-T8]

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`

EXIT_CODE: 0

## Output Summary

**36 passed**, 0 failed. The suite passes in full against the amended
`.claude/skills/parallel-orchestrate/SKILL.md`, and the test file itself is **unmodified by this
cycle** (`git status --porcelain` reports no change to it, confirmed under [P7-T6]), so the assertions
are the F5-owned ones rather than assertions relaxed to fit this cycle's edits.

The four assertion families the task names all pass, identified by test name from a verbose run:

| Assertion family | Test | Result |
| --- | --- | --- |
| Sixteen-`##` layout | `test_orchestrate_skill_first_thirteen_headings_match_required_layout` | PASSED |
| Reserved-section ordering | `test_orchestrate_skill_reserved_wave_four_sections_close_the_file` | PASSED |
| `RESERVED_HEADINGS` / `FILLED_RESERVED_HEADINGS` | `test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body` | PASSED |
| Heading-set integrity | `test_agent_body_contains_exactly_the_nine_required_headings`, `test_orchestrate_skill_intro_heading_precedes_prerequisites` | PASSED |

These are the tests that would fail if this cycle had added a `##` heading, retitled or relocated
either sibling reserved section, changed their one-line reserved bodies, or moved
`## Radius Drift Detection (F8)` off the end of the file. They pass, which corroborates the
independent structural verification recorded in [P7-T2]: sixteen `##` headings, F6 at line 435 and F7
at line 439 byte-identical to the [P0-T11] reference, and F8 at line 443 still closing the file.

Also passing and relevant to this cycle's confinement constraints:

- `test_frozen_epic_surface_matches_pinned_baseline_digest` for both
  `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` — the pinned
  digests still match, so no epic-surface file was touched.
- `test_skill_names_both_f7_dependency_block_reasons` — the F7 dependency block reasons are still
  named, so this cycle's SKILL.md edits did not disturb F7's recorded surface.
- `test_delivered_runtime_files_carry_no_prescriptive_epic_literal` for all three checked paths.
