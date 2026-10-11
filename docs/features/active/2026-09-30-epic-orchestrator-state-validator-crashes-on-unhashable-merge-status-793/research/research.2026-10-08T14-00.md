# Research: Unhashable merge_status crash in the Python epic orchestrator-state validator (Issue #793)

- Date: 2026-10-08
- Work mode: full-bug
- Method: file reads and searches against the current tree. No command execution tool was available in this session (Bash and PowerShell disabled), so no crash was reproduced by running code and no coverage was measured. All crash claims below are derived by reading the code; each is labeled "derived".

## 1. Hash-requiring operations on checkpoint-derived values

Public entry: `validate_epic_orchestrator_state_text` (`scripts/dev_tools/validate_epic_orchestrator_state.py:341`). CLI dispatch: `scripts/dev_tools/validate_orchestration_artifacts.py:284` (parser) and `:422-423` (calls `validate_epic_orchestrator_state_text`). Every site below is therefore reachable from both the function and the CLI. No try/except wraps the call chain in `validate_epic_orchestrator_state_text` (lines 372-428).

### In-scope sites (merge_status)

| Site | Citation | Operation | Guard today | Status |
|---|---|---|---|---|
| A | `validate_epic_orchestrator_state.py:238` in `_validate_merge_status_enum` | `merge_status not in VALID_MERGE_STATUS` (set, defined at :54-63) | none (only `is not None`) | crashes on list/dict (derived) |
| B | `validate_epic_orchestrator_state.py:321` in `_validate_completion` | `feature.get("merge_status") not in MERGED_STATUSES` (set imported from wave_barrier, defined `_epic_orchestrator_state_wave_barrier.py:34`) | none | crashes on list/dict, only when `require_complete=True` (derived) |
| C | `_epic_orchestrator_state_wave_barrier.py:144-147` | `dep_merge_status not in MERGED_STATUSES` | `not isinstance(dep_merge_status, str) or ...` | fixed by #659; test `test_validate_wave_barrier_ordering_reports_unhashable_dependency_status` (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py:145`) |

Non-crashing merge_status uses: `_epic_orchestrator_state_wave_barrier.py:75` (`!=` comparison), `_epic_orchestrator_state_launch_binding.py:229` (`==` comparison). Equality comparisons do not hash.

Issue.md cites older line numbers (235, 296, 385). Current lines are 238, 321 and (wave barrier, already fixed) 144-147. Site B in the main file is `:321`; the comment's "about line 321" is confirmed.

### Out-of-scope hash-requiring sites discovered (same defect class, other fields)

These are not named in the issue. They are the same class of defect on different fields (derived, not run):

1. `scripts/dev_tools/_epic_orchestrator_state_resolution.py:261`: `epic_type not in _VALID_EPIC_TYPES` (set at :44). A list/dict `intent.epic_type` raises TypeError. Reachable via `validate_intent_block` (validator :395) when an `intent` object is present.
2. `scripts/dev_tools/validate_epic_orchestrator_state.py:268`: `{f.get("feature_folder"): f for f in features}` builds a dict keyed by raw `feature_folder`. A list/dict `feature_folder` raises TypeError when `waves` is a list. Earlier checks guard with `isinstance(folder, str)` (:190, `_epic_orchestrator_state_wave_barrier.py:111,121`, `_epic_orchestrator_state_resolution.py:104,177`), so this is the first unguarded point.
3. `scripts/dev_tools/_epic_orchestrator_state_resolution.py:108`: `by_issue_num[issue_num] = folder` with a list/dict `issue_num` on a feature with a string `feature_folder`. This is reached first from validator :186. `resolve_feature_reference` (:144-148) already catches TypeError for the lookup side, but the index build does not.

Guarded and safe: `resolve_feature_reference` (:144-149); `folder in seen` (validator :192, guarded by isinstance str); launch-binding `seen_branches`/`seen_delegation_ids` sets (:223-224) are only fed string values per the `set[str]` typing (the add sites were not read in full; treat as not verified).

Recommendation on scope: the issue is titled and scoped to `merge_status`. Items 1-3 are adjacent defects; they should be listed as follow-ups (or consciously included) rather than silently added. Whether to include them is a scoping decision for the spec.

## 2. Error strings and Python/TypeScript differences

### Python today (invalid string, e.g. `"unknown_status"`)

- Site A (`validate_epic_orchestrator_state.py:239-242`): `Epic checkpoint feature '<folder>' has invalid merge_status: 'unknown_status'` (value formatted with `{merge_status!r}`; folder defaults to `<unknown>` via `feature.get("feature_folder", "<unknown>")` at :236).
- Site B (`:322-325`): `Epic checkpoint completion validation failed: feature '<folder>' merge_status is not merged/worktree_removed.` (no value in the message).

### TypeScript (`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`)

- `validateMergeStatusEnum` (:217-235): condition is `mergeStatus !== undefined && mergeStatus !== null && !(typeof mergeStatus === "string" && VALID_MERGE_STATUS.has(mergeStatus))` (:224-228). Message (:230): `Epic checkpoint feature '${String(folder)}' has invalid merge_status: ${JSON.stringify(mergeStatus)}`. Any non-string non-null value (list, dict, int, bool) therefore produces an error.
- `validateCompletion` (:393-406): condition `typeof mergeStatus !== "string" || !MERGED_STATUSES.has(mergeStatus)` (:401). Message (:403) is identical in wording to Python site B, with `String(folder)`.
- The wave-barrier TS site is at :308-312 (`!MERGED_STATUSES.has(depMergeStatus)`), unchanged by this issue.

### Format differences for the value in the site A message

| Value | Python `!r` | TS `JSON.stringify` |
|---|---|---|
| `"unknown_status"` | `'unknown_status'` | `"unknown_status"` |
| `["x"]` | `['x']` | `["x"]` |
| `{"x": 1}` | `{'x': 1}` | `{"x":1}` |
| `5` | `5` | `5` |
| `True` / `true` | `True` | `true` |

So the value portion already differs between the runtimes for a plain invalid string, before this fix. The completion message (site B) has no value and is byte-identical across runtimes. The TS resolution module has a local `pythonRepr` (`epic-orchestrator-state-resolution.ts:52-63`) that handles null/boolean/string only (lists and dicts fall to `String(value)`, which would print `x` for `["x"]`); it is not used for merge_status.

### Pinning of strings

- No shared parity corpus pins `invalid merge_status` strings. Search for `invalid merge_status` found only: Python test `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (substring check), TS test `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (substring check, lines 192/203), the two implementations, and docs.
- The only shared fixture is `tests/fixtures/epic_wave_barrier/start-guard-matrix.json`, which pins only `EPIC_WAVE_BARRIER_VIOLATION:` strings (used by `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py` and `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts`).
- Consequence: matching is required only at the level of "an error whose text contains `invalid merge_status`" for site A and the exact fixed sentence for site B. Using Python `!r` for the non-string value is the natural match to the issue's expected text (`invalid merge_status: ['x']`); exact byte parity of the value with TypeScript is not currently achievable or pinned.

## 3. bool, int, None and missing behavior

Current Python behavior (derived from the code):

- `int` (for example `5`) and `bool` (`True`): hashable, so no crash. `5 not in VALID_MERGE_STATUS` is True, so site A already reports `invalid merge_status: 5` / `True`. Site B already reports the completion error. These need regression rows only to lock behavior in; adding an `isinstance(str)` guard keeps the outcome identical (non-string is treated as invalid).
- `None`: site A skips the check (`merge_status is not None`), same as TS (`!== null`). A missing key is read as `None` by `.get`, so also skipped at site A. TS treats `undefined` (missing) the same way.
- Site B treats `None`/missing the same as any non-member: `.get(...)` returns `None`, `None not in MERGED_STATUSES` is True, so the completion error is reported. TS: `typeof undefined !== "string"` is true, so the same error. The two implementations agree. Nothing distinguishes None from other non-strings at site B.
- Wave-barrier start guard (`_epic_orchestrator_state_wave_barrier.py:73-75`) treats missing/None/non-string as started; unchanged.

## 4. Ports and mirrors

- No PowerShell port of this validator exists. Searches for `validate_epic_orchestrator_state` and `EpicOrchestratorState` across the repo (excluding docs) found PowerShell files only as callers/documentation: `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment lines 17, 28 reference the Python function), `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, and their bundled copies under `extensions/drm-copilot/resources/**`. None implements a merge_status membership test (only references were listed; the gate-modes scripts were not read in full).
- No bundled mirror of the Python file exists under `extensions/drm-copilot/resources/**`: a glob for `**/*epic*orchestrator*state*` returned the Python files under `scripts/dev_tools/`, the TS port, and tests; no `resources/` copy of any `validate_epic_orchestrator_state*.py`.
- The TypeScript port already behaves correctly; no TS source change is required.

## 5. Existing tests

Python, `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (plain pytest functions, no parametrize, shared builder `build_valid_epic_state()` at :12, tests mutate `state["features"][1]["merge_status"]` and call `validate_epic_orchestrator_state_text(json.dumps(state))`):
- `test_validate_accepts_all_valid_merge_status_values` (:214, loop over 8 values)
- `test_validate_rejects_invalid_merge_status_value` (:234, string `unknown_status`, substring assertion)
- Completion-gate coverage lives elsewhere in the same file or sibling files (search for `require_complete` was not exhaustively run); no test exercises a non-string merge_status at site A or site B.

Other relevant Python tests:
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py` uses `pytest.mark.parametrize` (:90, :106) and an AAA-commented style with a hand-built `features` list (:145-170) for the already-fixed site C.
- Dispatch tests: `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (not read in detail).

TypeScript, `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`: has string-only rows (`accepts every documented merge_status enum value` :176, `rejects an invalid merge_status value` :198, helper `featureAt(features, n)`, completion error text asserted around :262). It has no non-string merge_status rows. A TS parity row is optional (the TS port is already correct) but the issue's proposed-fix list requests one.

## 6. Quality tier and coverage

- `quality-tiers.yml`: `scripts/dev_tools` is T4 ("Repository-internal Python dev tooling (validators, CLIs); not published by push-down"). The TS port under `extensions/drm-copilot` is classified separately (not read in this pass).
- Consequences (from `.claude/rules/quality-tiers.md` and `general-unit-test.md`): uniform gates apply (format, lint, type check, line coverage >= 85%, branch coverage >= 75%, no regression on changed lines). Property-test density, mutation score and golden tests are "none" for T4; no property test is required. `any`-style escape hatches unlimited for T4.
- `pyproject.toml` `[tool.coverage.run]` has `source = ["src", "scripts/dev_tools"]` (line 119-120).
- Coverage command form: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-report=term-missing` (dotted module name; a `.py` path measures nothing per the repo memory note). Current coverage: not measured (no execution tool). Both new branches (non-string value at site A and at site B) would be covered by the new rows.

## 7. Recommendation and file list

Recommended minimal fix: add an `isinstance(merge_status, str)` guard before each set test, matching the pattern already used at `_epic_orchestrator_state_wave_barrier.py:144-147`.

- Site A: change the condition to `merge_status is not None and (not isinstance(merge_status, str) or merge_status not in VALID_MERGE_STATUS)`; message unchanged (`{merge_status!r}` renders list/dict/int/bool as Python repr).
- Site B: change to `not isinstance(merge_status, str) or merge_status not in MERGED_STATUSES` with `merge_status = feature.get("merge_status")`; message unchanged.
- Preserve: None/missing skipped at site A, reported at site B; no change to sets or other messages; file remains well under 500 lines (429 lines now).

Alternative considered and rejected: a shared helper such as `is_member(value, allowed)` in the wave-barrier module. It would touch three call sites plus the already-fixed one, increase the diff, and the two-line guards are the established pattern from #659. A broader `try/except TypeError` is rejected: it would mask other defects and violates the repo's no-broad-catch rule.

Tests to add (Python, in `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`, which is about 500 lines per the last test at :490; check the 500-line limit before appending, and place the new rows in a new sibling file such as `test_validate_epic_orchestrator_state_merge_status.py` if the existing file would exceed the limit):
- A `pytest.mark.parametrize` over `["x"]`, `{"x": 1}`, `5`, `True` for the enum path asserting the exact error string with Python repr, and no exception.
- The same four values with `require_complete=True` asserting the exact completion sentence, no exception, and a call through `validate_epic_orchestrator_state_text` (the public entry), plus optional direct calls to `_validate_merge_status_enum` / `_validate_completion` mirroring the issue repro.
- Optional TS rows in `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` for list/dict/int/bool asserting `invalid merge_status` substring and the completion sentence.

Files a fix would write:
1. `scripts/dev_tools/validate_epic_orchestrator_state.py` (two guards).
2. `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` or a new sibling `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` (new rows).
3. `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (optional parity rows, no production TS change).
4. Feature documents under `docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/` (spec, plan, evidence) per workflow.

No `resources/` mirror, PowerShell port, or fixture JSON needs to change.

## Automation Feasibility

No human interaction is required. The change is a deterministic two-condition guard in a single Python file plus parameterized unit rows; all verification is by automated pytest (and optionally Jest) runs with no network, GUI, credentials, or host-specific resources. The only limitation observed in this research session was the absence of a command execution tool; the implementation phase should run the reproduction commands and coverage measurement noted above.

## Open items for the spec author

- Decide whether to include the adjacent unhashable sites (`epic_type` at `_epic_orchestrator_state_resolution.py:261`, `feature_folder` dict key at `validate_epic_orchestrator_state.py:268`, `issue_num` index at `_epic_orchestrator_state_resolution.py:108`) or file them as follow-ups.
- Confirm exact-value format expectation (Python `!r`; TS `JSON.stringify` differs and is not pinned).
- Verify the 500-line limit of the existing Python test file before appending.
