# D2 Anchor Re-Verification (Issue #479, [P2-T1])

Timestamp: 2026-08-17T00-52

Command: `git grep -n` over the cited files plus targeted `Read` of each cited range

EXIT_CODE: 0

## Output Summary

Every cited D2 anchor is VERIFIED at its stated location. Zero drift.

### Production constants and interpolated error messages

| Anchor | Disposition | Observed |
|---|---|---|
| `scripts/dev_tools/parallel_manifest_contract.py:65` | VERIFIED | `MAX_CONCURRENCY = 8` |
| `scripts/dev_tools/parallel_manifest_contract.py:264-267` | VERIFIED | M4 error is an f-string interpolating `{MIN_CONCURRENCY} through {MAX_CONCURRENCY}` at `:266`; no hardcoded `8` |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py:71` | VERIFIED | `MAX_CONCURRENCY = 8` |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py:144-148` | VERIFIED | invariant-4 error interpolates the constants at `:148` |
| `scripts/dev_tools/validate_parallel_planner_state.py:64` | VERIFIED | `MAX_CONCURRENCY = 8` |
| `scripts/dev_tools/validate_parallel_planner_state.py:168-172` | VERIFIED | P2 error interpolates the constants at `:172` |
| `scripts/dev_tools/_parallel_state_common.py:196-197` | VERIFIED | docstring `` ``max_concurrency``, whose accepted range is 1 through 8 (A7). `` at `:197` |
| `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts:70` | VERIFIED | `const MAX_CONCURRENCY = 8;` |
| `.../parallel-orchestrator-state-core.ts:144-147` | VERIFIED | template literal interpolates `${MIN_CONCURRENCY} through ${MAX_CONCURRENCY}` at `:147` |
| `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts:66` | VERIFIED | `const MAX_CONCURRENCY = 8;` |
| `.../parallel-planner-state-core.ts:192-195` | VERIFIED | template literal interpolates at `:195` |
| `.claude/lib/bash/parallel-manifest-validate.sh:44-46` | VERIFIED | `PM_MAX_CONCURRENCY=8` at `:46` (with `PM_DEFAULT_MAX_CONCURRENCY=4` at `:42`) |
| `.claude/lib/bash/parallel-manifest-validate.sh:118-119` | VERIFIED | error interpolates `$PM_MIN_CONCURRENCY through $PM_MAX_CONCURRENCY` at `:119` |

All five error messages interpolate the constant. **No error string requires editing**, and
introducing a literal `32` into any of them would be a defect.

### Test anchors ([P2-T6], [P2-T7], [P2-T8])

| Anchor | Disposition | Observed |
|---|---|---|
| `tests/scripts/dev_tools/test_parallel_manifest_contract.py:252` | VERIFIED | `@pytest.mark.parametrize("concurrency", [1, 2, 4, 8])` |
| `.../test_parallel_manifest_contract.py:254` | VERIFIED | docstring `Concurrency values inside the 1..8 bound validate cleanly.` |
| `.../test_parallel_manifest_contract.py:262-272` | VERIFIED | reject list `[0, -1, 9, 100, "4", 1.5, True, None]` at `:262`; error string with literal `1 through 8` at `:270` |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py:191` | VERIFIED | `@pytest.mark.parametrize("concurrency", [1, 4, 8])` |
| `.../test_validate_parallel_orchestrator_state.py:201-213` | VERIFIED | reject list `[0, 9, -1, True, "4", 4.0, None]` at `:201`; error prefix at `:210` |
| `tests/scripts/dev_tools/test_validate_parallel_planner_state.py:211` | VERIFIED | reject list `[0, -1, 9, "4", 1.5, True, None]` |
| `.../test_validate_parallel_planner_state.py:220` | VERIFIED | error string with literal `1 through 8`. Confirmed: this module has NO in-range accept test; its only other `max_concurrency` reference is the fixture at `:72`. |
| `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts:111-133` | VERIFIED | in-range `it.each` at `:111`, `[9, "9"]` reject row at `:120`, error template at `:131` |
| `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts:181-196` | VERIFIED | `[9, "9"]` reject row at `:184`, error template at `:194`. Confirmed: NO in-range accept `it.each` exists in this file. |
| `tests/shell/parallel_manifest_validate.bats` | VERIFIED | `:70` value `12`, `:74` expected `found: 12.`, `:92` value `8` with `:95` accessor `= "8"`, `:119` and `:125` bound text, `:130` value `9` with `:131` expected error and `:132` accessor `= "9"` |

### Fixture anchors

| Fixture | Disposition |
|---|---|
| `manifest_m4_above_upper_bound.json` | VERIFIED — value `9`, `expected_errors` bound `8`, `expected_max_concurrency: 9`, stale `notes` "the inclusive upper bound is 8" |
| `manifest_m4_below_lower_bound.json` | VERIFIED — error text bound only (value `0`, `expected_max_concurrency: 0`) |
| `manifest_m4_boolean_rejected.json` | VERIFIED — error text bound only (`found: True.`, accessor falls back to 4) |
| `manifest_m4_non_integer.json` | VERIFIED — error text bound only (`found: 'four'.`) |
| `manifest_multiple_identity_errors_in_field_order.json` | VERIFIED — value `12`, `expected_max_concurrency: 12` |
| `manifest_accessor_open_mode_max_cap.json` | VERIFIED — value `8`, `expected_max_concurrency: 8`, stale `notes` "the upper-bound cap of 8" |

### Prose anchors

| Anchor | Disposition |
|---|---|
| `.claude/rules/parallel-orchestration.md:29` (invariant 4) | VERIFIED — `an integer from 1 through 8, and must not be a boolean` |
| `.claude/rules/parallel-orchestration.md:101` (M4) | VERIFIED — `an integer from 1 through 8` |
| `.claude/rules/parallel-orchestration.md:138` (A7) | VERIFIED — carries the epic-symmetry rationale to be dropped |
| `.claude/skills/parallel-orchestrate/SKILL.md:67-68` | VERIFIED — phrase wraps: `:67` ends `an integer from 1`, `:68` begins `through 8, defaulting to 4)`. Confirms the plan's two-token `through 8` gate is required. |
| `.claude/skills/parallel-plan/SKILL.md:256` | VERIFIED — `default 4, bounded 1 through 8 by the F3 schema` |
| `.claude/skills/parallel-plan/SKILL.md:288` | VERIFIED — `an integer from 1 through 8; defaults to \`4\` when absent` |
| `docs/features/templates/parallel/parallel-status.md:31` | VERIFIED — `_(integer 1 through 8; defaults to 4)_` |
