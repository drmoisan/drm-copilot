# 2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status (Spec)

- **Issue:** #793
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug

## Context
The Python epic orchestrator-state validator raises an uncaught `TypeError` instead of reporting a validation error when a feature's `merge_status` is a list or a dict. The TypeScript port handles the same input without crashing, so the two implementations diverge. Found during #659 preparation.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `validate_orchestration_artifacts epic-orchestrator-state <checkpoint>` or a direct call to `_validate_merge_status_enum`
- Data source or fixture: an epic checkpoint whose `features[]` entry has `"merge_status": ["merged"]` or `"merge_status": {"x": 1}`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

A malformed checkpoint produces a traceback instead of an actionable error, which also defeats any caller that parses validator output.

## Repro & Evidence
Steps to Reproduce:
1. From the repository root, run `python -c "from scripts.dev_tools import validate_epic_orchestrator_state as v; print(v._validate_merge_status_enum([{'folder':'a','merge_status':['x']}]))"`.
2. Repeat with `'merge_status': {'x': 1}`.

Expected:
The validator returns an error such as `Epic checkpoint feature 'a' has invalid merge_status: ['x']`, as it does for an invalid string.

Actual:
```
File "scripts/dev_tools/validate_epic_orchestrator_state.py", line 235, in _validate_merge_status_enum
    if merge_status is not None and merge_status not in VALID_MERGE_STATUS:
TypeError: unhashable type: 'list'
```

The same error is raised with `unhashable type: 'dict'`. Reproduced on main at ae7c7779 (as reported in the issue). The research record for this feature derived the crash from the code and did not execute it; the implementation phase must run the repro before and after the fix.

Line-number note: the line numbers cited in the issue (235, 296, 385) are stale. Current locations in `scripts/dev_tools/validate_epic_orchestrator_state.py` are:
- `_validate_merge_status_enum`: line 238 (`merge_status not in VALID_MERGE_STATUS`).
- `_validate_completion`: line 321 (`feature.get("merge_status") not in MERGED_STATUSES`).
- The dependency-status membership test the issue cites as line 296 now lives in `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` (lines 144-147) and was already guarded by #659.

## Scope & Non-Goals
- In scope:
  - Add an `isinstance(merge_status, str)` guard before the set-membership test in `_validate_merge_status_enum` and in `_validate_completion` in `scripts/dev_tools/validate_epic_orchestrator_state.py`, following the pattern #659 used in `_epic_orchestrator_state_wave_barrier.py`.
  - New Python regression tests in `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py`.
  - New TypeScript parity tests in `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts`.
- Out of scope / non-goals:
  - The wave-barrier dependency-status site (fixed by #659; retained only as a non-regression note).
  - Any TypeScript production change (the TS port is already correct).
  - Adjacent unhashable-value sites on other fields (recorded under Rollout & Follow-up).
  - Aligning the Python `repr` and TypeScript `JSON.stringify` formatting of the value in the invalid-merge_status message (pre-existing, unchanged).
  - Filing follow-up issues in this run.
- Explicitly excluded systems, integrations, or datasets: PowerShell hooks and bundled `extensions/drm-copilot/resources/**` copies. Research found no PowerShell port or bundled mirror of this validator that performs a merge_status membership test.

## Root Cause Analysis
`VALID_MERGE_STATUS` and `MERGED_STATUSES` are Python sets. A membership test (`x in set`) hashes the operand, so a list or dict operand raises `TypeError: unhashable type`. `_validate_merge_status_enum` guards only against `None`, and `_validate_completion` has no guard. No `try/except` wraps the call chain in `validate_epic_orchestrator_state_text`, so the exception reaches the caller and the CLI as a traceback.

The TypeScript port is not affected: `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` checks `typeof mergeStatus === "string"` before the set lookup in `validateMergeStatusEnum` (around lines 224-228) and `validateCompletion` (around line 401).

int and bool values are hashable and already produce the error in Python today; they need regression rows to lock behavior, and the guard keeps their outcome identical.

## Proposed Fix

### Design summary (what changes where):
In `scripts/dev_tools/validate_epic_orchestrator_state.py`:
- `_validate_merge_status_enum`: change the condition to `merge_status is not None and (not isinstance(merge_status, str) or merge_status not in VALID_MERGE_STATUS)`.
- `_validate_completion`: read `merge_status = feature.get("merge_status")` and change the condition to `not isinstance(merge_status, str) or merge_status not in MERGED_STATUSES`.

### Boundaries and invariants to preserve:
- `None` or missing `merge_status` remains skipped by `_validate_merge_status_enum` and remains reported by `_validate_completion`.
- All valid string statuses continue to pass; invalid strings continue to fail with unchanged text.
- `VALID_MERGE_STATUS`, `MERGED_STATUSES`, and all other messages are unchanged.
- No broad `try/except TypeError` is introduced (rejected: it would mask unrelated defects).
- Production file remains below 500 lines (429 lines at research time).

### Dependencies or blocked work:
None. #659 is already merged and provides the reference pattern.

### Implementation strategy (what changes, not sequencing):
Two inline `isinstance` guards. A shared membership helper was considered and rejected because it widens the diff to include the already-fixed wave-barrier site.

#### Files/modules to change:
- `scripts/dev_tools/validate_epic_orchestrator_state.py` (production).
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` (new).
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts` (new).

#### Functions/classes/CLI commands impacted:
- `_validate_merge_status_enum`, `_validate_completion`.
- Public entry `validate_epic_orchestrator_state_text` and CLI `scripts/dev_tools/validate_orchestration_artifacts.py epic-orchestrator-state` (behavioral effect: error report and exit code 1 instead of traceback for list/dict values).

#### Data flow and validation changes:
Non-string, non-None `merge_status` values are classified as invalid before any hashing occurs.

#### Error handling and logging updates:
Existing error strings are reused:
- Enum site: `Epic checkpoint feature '<folder>' has invalid merge_status: <repr>` (value via `{merge_status!r}`).
- Completion site: `Epic checkpoint completion validation failed: feature '<folder>' merge_status is not merged/worktree_removed.`

No new logging.

#### Rollback/feature-flag considerations (if applicable):
None. The change is a revertible two-condition edit.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
No signature changes. Inputs with non-string `merge_status` now yield entries in the returned error list rather than raising.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
Behavior for string, None, int, and bool values is unchanged. Only list and dict values change, from an uncaught exception to a reported error.

#### Performance constraints (latency/throughput/memory):
No measurable change; an `isinstance` check is added per feature.

## Assumptions, Constraints, Dependencies

Assumptions and decisions (recorded because the operator was unavailable for questions):
- Decision D-1: Scope is limited to the two `merge_status` sites in `validate_epic_orchestrator_state.py`. The wave-barrier site is already fixed by #659 and is a non-regression note only.
- Decision D-2: The Python message value continues to use `{merge_status!r}`. Byte parity with the TypeScript `JSON.stringify` value is not required; no shared corpus pins it, and tests assert at the level of the `invalid merge_status` substring plus the exact Python text where Python behavior is under test.
- Decision D-3: Python tests go in a new file because `test_validate_epic_orchestrator_state.py` is at 496 lines, near the 500-line limit. TypeScript tests go in a new file because `epic-orchestrator-state-core.test.ts` is at 475 lines.
- Decision D-4: No TypeScript production change. The TS tests are parity assertions only.
- Decision D-5: Adjacent unhashable sites on other fields are deferred as follow-ups, with no issue filing in this run.
- Assumption: `scripts/dev_tools` is tier T4 per `quality-tiers.yml`; uniform gates apply (line coverage >= 85%, branch coverage >= 75%, no regression on changed lines). T4 requires no property, mutation, or golden tests.

Constraints:
- 500-line file limit for production and test files.
- Test files must live under `tests/` mirroring the source tree for Python. No temporary files in tests.
- Coverage must be measured with the dotted module form (for example `--cov=scripts.dev_tools.validate_epic_orchestrator_state`); a `.py` path measures nothing.

External dependencies: none.

## Data / API / Config Impact
- User-facing or API changes: malformed checkpoints with list/dict `merge_status` now produce validation errors (CLI exit 1) instead of a traceback.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag, schema, or version changes.

## Test Strategy

Python tests, `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` (AAA structure, `pytest.mark.parametrize`):
- Enum site: rows for list (`["x"]`), dict (`{"x": 1}`), int (`5`), and bool (`True`) calling `_validate_merge_status_enum` directly; assert the returned error equals the expected Python-repr message and that no exception is raised.
- Completion site: the same values calling `_validate_completion` directly; assert the completion sentence and no exception.
- Entry-point row: `validate_epic_orchestrator_state_text` with a valid checkpoint built by mutating a feature's `merge_status` to list and dict, asserting an error is reported and no exception escapes (including with `require_complete=True`).
- CLI-dispatch check (if an existing in-process dispatch test pattern is available): `validate_orchestration_artifacts epic-orchestrator-state` returns exit code 1 for list/dict values.
- Preservation rows: string valid, string invalid, and `None` behavior remain as before at both sites.

TypeScript tests, `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts`:
- For list, dict, number, and boolean `merge_status`, assert `validateEpicOrchestratorStateText` (or the equivalent core entry) reports an error containing `invalid merge_status` and does not throw, at the enum site; and reports the completion sentence at the completion site.

Coverage and toolchain:
- Both new branches (non-string value at each site) must be exercised; changed lines must not regress; module line coverage >= 85% and branch >= 75%.
- Python: `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-branch --cov-report=term-missing`.
- TypeScript (in `extensions/drm-copilot`): prettier, eslint, `tsc`, and jest for the new test file.
- Manual validation: run the issue repro commands before and after the fix; confirm the traceback becomes an error message.

## Acceptance Criteria
- [ ] AC-1: `_validate_merge_status_enum` in `scripts/dev_tools/validate_epic_orchestrator_state.py` guards the set-membership test with an `isinstance(merge_status, str)` check, and a non-string, non-None `merge_status` (list, dict, int, bool) returns the existing `invalid merge_status` error for that feature without raising.
- [ ] AC-2: `_validate_completion` in `scripts/dev_tools/validate_epic_orchestrator_state.py` guards the set-membership test with an `isinstance(merge_status, str)` check, and a non-string `merge_status` (list, dict, int, bool) returns the existing completion-failure error for that feature without raising.
- [ ] AC-3: Error message text and behavior for string and `None`/missing `merge_status` values are unchanged at both sites (valid strings pass, invalid strings fail with the same text, `None` is skipped by the enum check and reported by the completion check).
- [ ] AC-4: `validate_epic_orchestrator_state_text` returns errors (and the CLI `scripts/dev_tools/validate_orchestration_artifacts.py epic-orchestrator-state` exits 1) rather than raising a traceback when a feature's `merge_status` is a list or a dict, including with `require_complete=True`.
- [ ] AC-5: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` exists with parametrized rows for list, dict, int, and bool at the enum site and the completion site, plus an entry-point row, and all rows pass.
- [ ] AC-6: `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts` exists and asserts that the TypeScript port reports an error and does not throw for list, dict, number, and boolean `merge_status` at the enum site and the completion site, and the tests pass.
- [ ] AC-7: No production TypeScript file is changed, and the wave-barrier module `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` and its existing test remain unchanged and passing (non-regression).
- [ ] AC-8: Python full toolchain passes (black, ruff, pyright, pytest) with line coverage >= 85% and branch coverage >= 75% for `scripts.dev_tools.validate_epic_orchestrator_state`, with no coverage regression on changed lines.
- [ ] AC-9: TypeScript toolchain passes for the new test file (prettier, eslint, tsc, jest).
- [ ] AC-10: No new or modified production or test file exceeds 500 lines, and no unintended behavior changes occur outside the defined scope.

## Risks & Mitigations
- Technical or operational risks:
  - Research derived the crash from code without executing it; actual behavior may differ in detail. Mitigation: run the repro before and after the change and record the output as evidence.
  - Python `repr` and TS `JSON.stringify` format values differently (for example `{'x': 1}` versus `{"x":1}`). Mitigation: TS parity tests assert only the `invalid merge_status` substring and the completion sentence.
  - Adjacent unhashable sites remain after this fix, so other malformed fields can still produce a traceback. Mitigation: documented as follow-ups below.
- Mitigations and rollbacks: the change is two inline conditions plus tests; revert the commit to roll back.

## Rollout & Follow-up
- Release/rollout steps: standard PR merge; no packaging or push-down impact (T4 dev tooling, no bundled mirror).
- Post-fix monitoring or clean-up tasks. Follow-ups recorded only; no issues are filed in this run:
  - `intent.epic_type` membership test `epic_type not in _VALID_EPIC_TYPES` in `scripts/dev_tools/_epic_orchestrator_state_resolution.py` (around line 261) raises on list/dict values.
  - The `{f.get("feature_folder"): f for f in features}` dict build in `scripts/dev_tools/validate_epic_orchestrator_state.py` (around line 268) raises on list/dict `feature_folder` when `waves` is a list.
  - The `by_issue_num[issue_num] = folder` index build in `scripts/dev_tools/_epic_orchestrator_state_resolution.py` (around line 108) raises on list/dict `issue_num`.
  - The pre-existing Python `repr` versus TypeScript `JSON.stringify` formatting difference in the invalid-merge_status message value is not changed here.
- Links: issue #793 (https://github.com/drmoisan/drm-copilot/issues/793), related #659, research `research/research.2026-10-08T14-00.md`.
