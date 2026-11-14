# Preflight Fixes — Issue #1164

Timestamp: 2026-11-09T22-57
Plan: docs/features/active/parallel-planner-time-based-edge-rule-1164/plan.2026-11-09T16-56.md
Directive: PREFLIGHT VALIDATION ONLY (single pass; task text only; no task added, removed, reordered, or checked)
Validator (branch Python CLI, plan subcommand, VIRTUAL_ENV unset): passed before and after the fixes, EXIT_CODE 0.
Validator (installed MCP): ok after the fixes.

## Fixes

1. [P1-T3] | validator-blind class: changed behavior with asserting tests outside the task file set | Added dispositions. `test_committed_conflict_tolerance_reads_cleanly` carries two literal assertions (the `band_durations` map and the `append_only_paths` tuple) that are not read through `COMMITTED_CONFLICT_TOLERANCE`, so the task now updates them. `claude-config-carriage.test.ts` `keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource` compares `SOURCE_BLAST_RADIUS` in `config-carriage.test-helpers.ts` structurally with the bundled config, so the task now updates that constant; its other consumers assert no tolerance value and are named unchanged.
2. [P3-T4] | validator-blind class: existing asserting tests not named | Named `tests/shell/parallel_bash_manifest_membership.bats` (glob discovery, core.json entry, byte-identical mirror) and `tests/shell/parallel_payload_only.bats` (payload run with PATH limited to the `sort`, `cut`, `cat`, `dirname` shims) as unchanged, and added both to the acceptance list.
3. [P5-T1] | ambiguous anchor | The rule carries two `**Configuration.**` paragraphs; the task now names the one inside `### Integration-cost scheduling (issue #722)`.
4. [P5-T3] | validator-blind class: existing asserting tests not named | Stated that edits add no `##` heading and keep the issue #1013 `observed_resolution` telemetry statement; named `test_agent_body_contains_exactly_the_nine_required_headings`, `test_orchestrate_skill_first_thirteen_headings_match_required_layout`, and `test_agent_frontmatter_declares_required_tool_allowlist` as unchanged.
5. [P5-T4] | literal formatting (undefined "next to" absence check) | Replaced "tolerated-not-validated next to `tolerated_overlaps`" with the concrete former literal "Get-BlastRadiusConflictEdge (tolerated-not-validated)". As written, the check would also match the orchestrator agent's still-accurate `observed_resolution` telemetry sentence, which P5-T3 keeps.
6. [P6-T8] | evidence field omission | The shell-ci artifact now records the `Run shell-qc check (shfmt diff + shellcheck)` step result and finding count as the bash final static record (one final-QC static record per touched language).
