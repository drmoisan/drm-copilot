# Research: epic wave-barrier start guard (Issue #659, absorbs #692)

- Issue: #659 (absorbs #692)
- Branch: `bug/epic-wave-barrier-violations-lack-start-guard-659`
- Tree inspected: worktree based on origin/main `37096891`
- Work mode: minor-audit (no `spec.md` / `user-story.md`)
- Requirements source: `issue.md` sections `## Consolidated Scope (2026-09-29)` and `## Acceptance Criteria` (AC-1..AC-7); `docs/features/potential/promoted/2026-09-17-epic-wave-barrier-flags-unstarted-features.md` (#692 record)
- Timestamp: 2026-09-30T01-25

All line numbers below were re-derived with Read/Grep against the current tree in this session. Nothing was executed; toolchain output quoted below comes from committed evidence artifacts, which are cited.

## 1. Current State

### 1.1 Python authority: `_validate_wave_barrier_ordering`

File: `scripts/dev_tools/validate_epic_orchestrator_state.py` (492 lines).

| Item | Line(s) |
|---|---|
| `VALID_MERGE_STATUS` (8 members, includes `not_started`) | 50-59 |
| `MERGED_STATUSES = {"merged", "worktree_removed"}` | 60 |
| `_validate_merge_status_enum` (`merge_status not in VALID_MERGE_STATUS`) | 215-240 (test at 235) |
| `def _validate_wave_barrier_ordering` | 243 |
| Per-feature skip: non-string `feature_folder` or non-list `depends_on` | 279-280 |
| Dependent's `worktree_created_at` read | 281 |
| Unresolved dependency skipped | 292-293 |
| `status_violation = dep_merge_status not in MERGED_STATUSES` (unguarded) | 296 |
| `timing_violation` (`dep_confirmed_at > worktree_created_at`, both `str`) | 297-301 |
| Single message for both cases | 302-306 (text at 304-305) |
| Caller in `validate_epic_orchestrator_state_text` | 455 |
| `_validate_completion` uses `MERGED_STATUSES` | 385 |

Emitted text (304-305): `f"EPIC_WAVE_BARRIER_VIOLATION: {folder} started before " f"dependency {dependency} merged"`.

The function tests only the dependency's state. Nothing reads the dependent's `merge_status`, so a `not_started` dependent with no `worktree_created_at` emits the status violation for every unmerged dependency. The timing term already requires a string `worktree_created_at` and is therefore always `False` for an unstarted dependent; only the status term is unguarded (confirms the #692 root-cause statement).

### 1.2 TypeScript port: `validateWaveBarrierOrdering`

File: `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` (453 lines).

| Item | Line(s) |
|---|---|
| `VALID_MERGE_STATUS` | 60-69 |
| `MERGED_STATUSES` | 71-74 |
| `function validateWaveBarrierOrdering` | 241 |
| Skip on non-string folder / non-array `depends_on` | 260-262 |
| `statusViolation = typeof depMergeStatus !== "string" \|\| !MERGED_STATUSES.has(depMergeStatus)` | 276-278 |
| `timingViolation` | 279-282 |
| Message | 283-287 (text at 285) |
| Caller | 424 |

The core imports its two sibling helpers at 28-34 (`./epic-orchestrator-state-resolution`, `./epic-orchestrator-state-launch-binding`), mirroring the Python split.

### 1.3 Parity differences (verified by reading both sources)

| # | Difference | Effect | In scope |
|---|---|---|---|
| P1 | Python `dep_merge_status not in MERGED_STATUSES` (296) vs TS `typeof !== "string" \|\| !has(...)` (276-278) | Identical for every hashable JSON value (str, int, float, bool, None). For an unhashable value (JSON array/object) Python set membership raises `TypeError` (Python language semantics; not executed in this session) while TS reports a violation. | Yes: write the Python helper as `not isinstance(dep_merge_status, str) or dep_merge_status not in MERGED_STATUSES` so the barrier itself matches TS exactly. |
| P2 | Same unhashable hazard in `_validate_merge_status_enum` (235) and `_validate_completion` (385), both outside the barrier function. `_validate_merge_status_enum` runs before the barrier (454 vs 455), so a list/dict `merge_status` still crashes the Python validator after this fix. | Pre-existing; not introduced or worsened by #659. | No. Record as a follow-up potential entry. Test matrices must not use list/dict `merge_status` values. |
| P3 | `{dependency}` (Python `str()`) vs `${String(dependency)}` | Identical for strings and integers. Diverges for integral floats (`300.0` vs `300`) and booleans (`True` vs `true`); resolution also diverges for bool vs int keys (Python `True == 1` hashes equal; a JS `Map` does not). | No. These are the divergence classes already recorded in `.claude/rules/parallel-orchestration.md:620`; avoid them in fixtures, as the cohort-barrier corpus does. |
| P4 | Python `str >` compares code points; JS compares UTF-16 code units | Differs only for astral-plane characters; ISO-8601 timestamps are ASCII. | No. |

## 2. Start-Guard Predicate

### 2.1 Recommended predicate

A dependent feature is treated as started when either condition holds:

- `worktree_created_at` is a string (any string, including empty; fail closed), or
- `merge_status` is not equal to the literal `"not_started"` (a missing key, `null`, or any non-string value is therefore started).

Python (proposed helper, pure):

```python
NOT_STARTED_MERGE_STATUS = "not_started"

def feature_has_started(feature: dict[str, Any]) -> bool:
    if isinstance(feature.get("worktree_created_at"), str):
        return True
    return feature.get("merge_status") != NOT_STARTED_MERGE_STATUS
```

TypeScript (same truth table):

```ts
typeof feature["worktree_created_at"] === "string" ||
  feature["merge_status"] !== NOT_STARTED_MERGE_STATUS
```

Application point: evaluate once per dependent, immediately after the existing `folder`/`depends_on` skip (Python 279-280, TS 260-262), and `continue` when the dependent has not started. Because the timing term already requires a string `worktree_created_at`, skipping an unstarted dependent removes only the false status violations; no existing true violation is lost (satisfies the #692 "keep every existing violation for a started feature" constraint).

For JSON-decoded values, Python `!=` against a `str` and TS `!==` against a string literal agree for every type (no hashing is involved), so the predicate is parity-safe including for list/dict values.

### 2.2 Confirmation against the schema and writers

- `not_started` is a member of `VALID_MERGE_STATUS` in both runtimes (Python 51, TS 61) and is the only "not yet started" value; the other seven values all denote progress (`worktree_created` onward) or terminal states. The predicate therefore matches the issue's requirement "a `merge_status` other than `not_started`".
- No deterministic script writes epic checkpoint `features[]`. Grep across `scripts/` and `extensions/drm-copilot/src/` for `epic-orchestrator-state.json` and `"features"` writers found only readers/validators. The checkpoint is authored by the `epic-orchestrator` agent per `.claude/agents/epic-orchestrator.md:131-139` ("`features[]` (including `merge_status` and the four lifecycle timestamps)") and `.claude/skills/epic-orchestrate/SKILL.md:273-276` (kickoff seeds each row as `not_started`; transitions to `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `merged`, `worktree_removed`) and `:295-296` (enum). The schema example in `docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md:134-151` carries `worktree_created_at`, `pr_opened_at`, `ci_green_at`, `merge_confirmed_at`, `worktree_removed_at` per feature.
- Because the writer is an agent rather than code, a record can be inconsistent (for example `not_started` with a `worktree_created_at`). The existing test fixture is such a record: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py:41-49` and `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts:38-46` give `2026-07-02-child-b-301` `merge_status: "not_started"` and `worktree_created_at: "2026-07-02T19-00"`. Under the predicate it is started (timestamp evidence wins), which is the fail-closed reading the issue requires.
- Precedent in the same validator family: the epic launch-binding filter skips only on `feature.get("merge_status") == "not_started"` (`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py:226`; TS `epic-orchestrator-state-launch-binding.ts:258`), so a missing `merge_status` is already treated as launched there. The recommended predicate is consistent with it.
- Deliberate difference from the parallel cohort barrier: `_has_started` in `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py:221-238` requires a non-empty stripped timestamp and treats an absent `merge_status` as `not_started` (parallel invariant 7, `.claude/rules/parallel-orchestration.md:56`). The epic schema has no "absent means not_started" rule, and #692 mandates fail-closed for a missing/non-string value, so the epic predicate must not reuse the parallel helper. Record this in the helper docstring.
- Layer 1 hook `.claude/hooks/enforce-epic-wave-barrier.ps1:150-202` gates launches on the dependency's status only and is independent of the validator; it is unaffected.

## 3. Error Text (AC-4)

### 3.1 Cases in which a violation is emitted after the guard

Only for a started dependent (Section 2), per resolved dependency edge:

1. Status case: the dependency's `merge_status` is not a string in `{merged, worktree_removed}`.
2. Timing case: the dependency is merged, and its `merge_confirmed_at` is later than the dependent's `worktree_created_at` (both strings).
3. Both hold: emit the status message only, so each violated edge yields exactly one error (AC-2).

The current single text asserts "started", which is not evidenced when the dependent is started only by the fail-closed rule (missing/non-string `merge_status`), and "merged" is imprecise for the timing case, where the dependency has in fact merged.

### 3.2 Recommended verbatim strings

Status case (Python f-string / TS template):

```
EPIC_WAVE_BARRIER_VIOLATION: {folder} is treated as started while dependency {dependency} is not merged
```

Timing case:

```
EPIC_WAVE_BARRIER_VIOLATION: {folder} worktree_created_at precedes dependency {dependency} merge_confirmed_at
```

Rationale: "is treated as started" is accurate for every started branch, including the fail-closed branch, because it states the validator's classification rather than asserting an observed start. The timing text names the two compared fields, which is literally what the comparison checks. Both keep the `EPIC_WAVE_BARRIER_VIOLATION: ` prefix and name the dependent (`{folder}`) and the dependency (`{dependency}`, the raw `depends_on` entry, as today). Neither interpolates a status value, which avoids the `repr`/`JSON.stringify` quoting divergence.

Rejected wording: "has started" (false for the fail-closed branch); "has left not_started" (false for a `not_started` record carrying a timestamp); including `merge_status` values in the message (quote-style divergence between runtimes).

### 3.3 Consumers of the text or its prefix

Full-text consumers (must change):

| # | File:line | Kind | Required change |
|---|---|---|---|
| C1 | `scripts/dev_tools/validate_epic_orchestrator_state.py:304-305` | Producer | Moves into the new helper with the two new strings |
| C2 | `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts:285` | Producer | Two new strings |
| C3 | `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py:262-263` | Exact-substring assertion (status case: dependency `pr_open`) | Replace with the status string |
| C4 | `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts:211` | Exact-substring assertion (status case) | Replace with the status string |
| C5 | `.claude/skills/epic-orchestrate/SKILL.md:244-245` | Documentation quote (also says "timing invariant" only) | Rewrite Layer 2 bullet |
| C6 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md:244-245` | Bundled mirror | Identical edit to C5 |

Prefix-only consumers (no change needed; the prefix is retained):

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py:250` (absence), `:277` (presence, timing case).
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts:198` (absence), `:222` (presence, timing case).
- Docstrings: `validate_epic_orchestrator_state.py:256`, `epic-orchestrator-state-core.ts:239`.
- `scripts/dev_tools/_parallel_orchestrator_state_drift.py:46-47` names the token as a precedent "in `validate_epic_orchestrator_state.py`". The token is still emitted through that module's public validator after the extraction, so the reference remains accurate at that level. No change recommended; editing it would add a fourth production file.

Not consumers: `EPIC_WAVE_BARRIER_BLOCKED` in `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.codex/hooks/enforce-epic-wave-barrier.ps1`, their bundled copies, and `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1` / `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1:363` are a different token. No match exists in `.github/`, `.codex/` skills, `.agents/`, JSON, or YAML. Historical documents under `docs/features/completed/**` and `docs/features/epics/claude-runtime-portability/epic-status.md:300-305` quote the old text as records of past behaviour and should not be edited.

### 3.4 Mirror parity test

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (118-143) requires every repo `.claude/**` file (except `settings.local.json` and `agent-memory/**`) to exist in the bundle and asserts `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (UTF-8 decoded text equality, lines 140-143). The mirror must therefore be content-identical; the comparison is on decoded text with universal-newline translation, not `read_bytes`, so it is not strictly byte-level. The byte-level assertions in the same file (146-156, 159-174) cover other named paths, not `epic-orchestrate/SKILL.md`. The skill is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:96`; the path is unchanged, so the manifest needs no edit. Copy the edited SKILL.md to the mirror verbatim and keep LF endings.

### 3.5 Unrelated inaccuracy observed (follow-up, not in scope)

`.claude/skills/epic-orchestrate/SKILL.md:241-243`, `.claude/agents/epic-orchestrator.md:125-127`, and `.claude/hooks/enforce-epic-wave-barrier.ps1:23-26` state that the Layer 2 check runs at `epic-orchestrator` `SubagentStop` via `validate-orchestrator-output.ps1`. The hook's default invoker runs only a structural check (exists, parses, object root) for `epic-orchestrator-state` (`.claude/hooks/validate-orchestrator-output.ps1:218-225`, `:267-275`, `Test-OrchestratorCheckpointStructure` at `:152-196`). This agrees with the issue's note that "the SubagentStop gate does not run this check". Record a follow-up potential entry; do not widen #659.

## 4. Existing Tests That Depend on the Violation

Python (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`):

| Node ID | Current assertion | After guard |
|---|---|---|
| `...::test_validate_wave_barrier_ordering_passes_when_dependency_merged_first` (245) | no violation | Unchanged, passes |
| `...::test_validate_wave_barrier_ordering_rejects_unmerged_dependency` (253) | exact old text | Dependent is started via its `worktree_created_at` string, so the violation still fires; only the literal must change to the status string |
| `...::test_validate_wave_barrier_ordering_rejects_out_of_order_timestamps` (268) | prefix present | Timing case; prefix assertion still passes |
| `...::test_validate_rejects_dependency_cycle` (198) | `"cycle"` present | Also produces a barrier violation today (child-a depends on child-b, which is unmerged; child-a is `merged`, so started); not asserted, unaffected |
| `...::test_validate_accepts_all_valid_merge_status_values` (214) | no `invalid merge_status` | Varies the dependent's status with a merged dependency; no barrier assertion, unaffected |

TypeScript (`extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`), same fixture shape (11-49):

| Test name | Line | After guard |
|---|---|---|
| `validateEpicOrchestratorStateText passes wave-barrier ordering when the dependency merged first` | 194 | Unchanged |
| `validateEpicOrchestratorStateText rejects wave-barrier ordering when a dependency has not yet merged` | 203 | Literal at 211 must change to the status string |
| `validateEpicOrchestratorStateText rejects wave-barrier ordering on out-of-order timestamps` | 217 | Unchanged (prefix) |

Other suites that call the validator (`test_validate_epic_orchestrator_state_launch_binding.py`, `_codex_routing.py`, `_codex_topology.py`, `test_validate_orchestration_artifacts*.py`, the TS `epic-orchestrator-state-{launch-binding,codex-topology,codex-model-routing}.test.ts`, `orchestration-artifacts.test.ts`, `mcp-*epic*.test.ts`) use fixtures whose features have `depends_on: []` (grep: `test_validate_orchestration_artifacts_dispatch.py:176`, `test_validate_epic_orchestrator_state_launch_binding.py:29`, `_codex_topology.py:32`, `_codex_routing.py:31`, TS `launch-binding.test.ts:23`, `codex-topology.test.ts:22`, `codex-model-routing.test.ts:23`). The launch-binding suites filter errors through `_launch_errors`/`launchErrors`. The guard only removes errors, so `errors == []` assertions cannot regress. No existing fixture has a `not_started` dependent without `worktree_created_at` and an unmerged dependency; no existing test changes outcome.

No test imports `_validate_wave_barrier_ordering` or `MERGED_STATUSES` directly; the only importers of the module import `validate_epic_orchestrator_state_text` (`scripts/dev_tools/validate_orchestration_artifacts.py:23-25` and the four Python test files). Extraction breaks no import.

## 5. File Placement and the 500-Line Limit

Current sizes (Grep line count): Python validator 492, Python test 496, TS core 453, TS core test 463, `_epic_orchestrator_state_resolution.py` 288, `_epic_orchestrator_state_launch_binding.py` 298, TS resolution 287, TS launch-binding 325.

### 5.1 Python: extraction required

Adding the predicate (with the repository docstring format), a second message branch, and the `isinstance` hardening adds roughly 30 lines, which exceeds 500. Recommended:

- New `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` holding `NOT_STARTED_MERGE_STATUS`, `MERGED_STATUSES`, `feature_has_started`, and `validate_wave_barrier_ordering(features)`. It imports `build_feature_reference_index` and `resolve_feature_reference` from `_epic_orchestrator_state_resolution` (same as today). Estimated 130-150 lines.
- `MERGED_STATUSES` moves into the helper to avoid a circular import (the validator imports the helper; the helper cannot import the validator). The validator imports it back for `_validate_completion` (385). No external module imports it.
- Validator: delete 243-307, import `MERGED_STATUSES` and `validate_wave_barrier_ordering`, and call it at 455. Estimated result about 430 lines.
- The name matches `config/blast-radius.json:18` shared-surface glob `scripts/dev_tools/_epic_orchestrator_state_*.py`, so blast-radius classification needs no config change.

### 5.2 TypeScript: in-place change recommended

Estimate for the in-place edit to `epic-orchestrator-state-core.ts`: constant (+2), `hasStarted` with JSDoc (+16), guard in the skip condition (+3 to +5), two-branch message (+4), for about 478-482 lines, under the limit. No parity test compares module layout; parity is behavioural and asserted through the public entry point. The TS split used for resolution/launch-binding is a convention, not a requirement. Keeping the TS change in place also keeps the production-file count at three (Section 7) and avoids a `jest.config.cjs` edit (a new `src/` module has no per-file threshold unless one is added, per the comments at `jest.config.cjs:242-262`).

Fallback: if the executed diff takes the core above about 495 lines, create `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts` and add a `"./src/lib/validate/epic-orchestrator-state-wave-barrier.ts": { lines: 85, branches: 75 }` entry to `jest.config.cjs`. That takes the change outside the minor-audit file budget (Section 7).

### 5.3 Architecture boundaries

No dependency-cruiser, import-linter, or NetArchTest configuration exists in `pyproject.toml`, `extensions/drm-copilot/package.json`, or the repository config files (Grep for `dependency-cruiser|import-linter|importlinter|NetArchTest` returned no matches). `pyproject.toml` ruff selects `TID` and `TCH` (93-103); the helper's `Any` import is runtime-used in annotations under `from __future__ import annotations`, following the sibling modules. No `quality-tiers.yml` exists at the repository root of this tree (Glob returned nothing), so no tier entry is needed for a new module in an existing project.

### 5.4 Test placement

- Existing files: edit only the literal at Python 262-263 and TS 211. Keep the Python test at or below 498 lines (black may wrap the longer literal to two or three lines).
- New Python test: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py`, following the `test_validate_epic_orchestrator_state_launch_binding.py` naming for `_epic_orchestrator_state_launch_binding.py`.
- New Jest test: `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts`.
- Shared parity fixture (selected approach): one committed file `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` containing an array of cases (`name`, `features`, `expected_barrier_errors`). Both suites run each case through the public entry point (`validate_epic_orchestrator_state_text` / `validateEpicOrchestratorStateText`), filter to strings starting with `EPIC_WAVE_BARRIER_VIOLATION: `, and assert list equality in order. This follows the cross-runtime corpus precedent (`tests/fixtures/parallel_cohort_barrier/*.json`, loaded by `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py:61-62,189-193` and `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts:58-68`), whose header (7-51) records that per-side suites cannot detect cross-runtime divergence. Reading a committed fixture is permitted; no temporary file is created.
- Rejected alternative: two independent per-side suites with duplicated literals. This satisfies AC-5 textually, but a string can drift on one side without the other suite noticing.

## 6. Toolchain Commands (from committed evidence)

Python, repository root (source: `docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/qa-gates/final-qa-clean-pass.2026-08-25T08-23.md:27-47`, and `docs/features/completed/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/qa-gates/final-{black,ruff,pyright,pytest-validator-coverage}.md`):

| Stage | Command | Recorded success output |
|---|---|---|
| Format | `poetry run black <files>` (check: `poetry run black --check <files>`) | `All done!` / `N files would be left unchanged.` |
| Lint | `poetry run ruff check <files>` | `All checks passed!` |
| Type check | `poetry run pyright <files>` | `0 errors, 0 warnings, 0 informations` (plus a harmless `venv .venv subdirectory not found` notice and a version notice) |
| Tests + coverage | `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py --cov=scripts.dev_tools._epic_orchestrator_state_wave_barrier --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-branch --cov-report=term-missing` | `N passed in X.XXs`; per-module row such as `scripts\dev_tools\validate_epic_orchestrator_state.py  149  20  87%  <missing lines>` (#663 artifact, 87% at 149 statements) |

Use the dotted `--cov=scripts.dev_tools.<module>` form; a `--cov=<path>.py` target measures nothing. `pyproject.toml:115` `addopts` also writes `artifacts/python/lcov.info`, which can be used for changed-line coverage. `--cov-branch` is required for the branch figure (the #663 artifact omitted it and reported line-only `Cover`). The full-suite form recorded in #524 is `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` (`4117 passed, 5 skipped`). That artifact also records a known local-only failure of `test_bundled_claude_payload_contains_all_repo_runtime_contracts` caused by gitignored `.claude/state/python-batch-budget.default.json`; it is environmental.

TypeScript, run from `extensions/drm-copilot` in the same shell invocation as the `cd` (source: same #524 artifact 53-93, `final-typescript-test-coverage.2026-08-24T23-19.md`, `final-typescript-format.2026-08-24T23-15.md`; scripts in `extensions/drm-copilot/package.json:202-213`):

| Stage | Command | Underlying | Recorded success output |
|---|---|---|---|
| Format | `npm run format` | `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | each file reported `(unchanged)` |
| Lint | `npm run lint` | `eslint --no-error-on-unmatched-pattern src test` | no output, exit 0 |
| Type check | `npm run typecheck` | `tsc -p ./ --noEmit` | no output, exit 0 |
| Tests + coverage | `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` | Jest 30, ts-jest, v8 provider (`jest.config.cjs:1-19`) | `Test Suites: N passed, N total`, `Tests: N passed, N total`, the `Coverage summary` block, and per-file rows such as `epic-orchestrator-state-launch-binding.ts \| 96 \| 92.72 \| 100 \| 96 \| ...` |

Environment notes recorded in #524: running `npm run format` from the repository root rewrites unrelated `tests/fixtures` JSON files (a wider root glob), so run it from `extensions/drm-copilot`. A worktree without `node_modules` fails lint on `@eslint/js`; `npm ci` in `extensions/drm-copilot` fixes this. `epic-orchestrator-state-core.ts` has no per-file threshold entry in `jest.config.cjs`, so its per-file figure is read from the `text` reporter, as #524 did (artifact 77-79). TS lcov is written to `extensions/drm-copilot/coverage/lcov.info` (`jest.config.cjs:18-19`) for changed-line coverage.

Evidence artifacts go to `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/<kind>/` (baseline, qa-gates, regression-testing).

## 7. Scope Fit (minor-audit)

| Category | Files |
|---|---|
| Production (3) | `scripts/dev_tools/validate_epic_orchestrator_state.py` (modify), `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` (new), `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` (modify) |
| Documentation (2) | `.claude/skills/epic-orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` |
| Tests (4) + fixture (1) | modify `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`, modify `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`, new `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py`, new `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts`, new `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` |

This fits minor-audit (three production files plus tests and two documentation mirrors). Minor-audit no longer fits if the TypeScript helper is also split out (four production files plus a `jest.config.cjs` edit) or if the drift-module docstring or the SubagentStop documentation inaccuracy (Section 3.5) is folded in.

## Numeric Derivation Evidence

Claim: the set of files/lines that carry the full violation text (not only the prefix) has six members (Section 3.3, C1-C6).

- Complete Family: every non-historical repository location, in production code, tests, hooks, skills, bundled mirrors, config, and CI, that contains the full `EPIC_WAVE_BARRIER_VIOLATION: <f> started before dependency <d> merged` text, including forms split across lines.
- Exhaustive Search Scope: the whole worktree excluding `docs/**` (historical records are excluded; searched separately to confirm they are historical only).
- Inclusion Rules: a line or adjacent line pair containing both the token and the `started before ... dependency ... merged` wording, or a literal instance of it.
- Exclusion Rules: prefix-only mentions (token without the sentence), `EPIC_WAVE_BARRIER_BLOCKED`, and `docs/**`.
- Primary Search Strategy: Grep `EPIC_WAVE_BARRIER_VIOLATION` with glob `!docs/**`, then keep lines whose text (or the following continuation line) contains the sentence.
- Primary Member Set: `validate_epic_orchestrator_state.py:304(-305)`; `epic-orchestrator-state-core.ts:285`; `epic-orchestrator-state-core.test.ts:211`; `test_validate_epic_orchestrator_state.py:262(-263)`; `.claude/skills/epic-orchestrate/SKILL.md:244`; bundled mirror `SKILL.md:244`.
- Primary Count: 6.
- Cross-check Search Strategy: two token-independent fragment greps, then their union: (a) `before (dependency|dep)\b` with glob `!docs/**`; (b) `(dependency \{dependency\} merged|dependency 2026-07-02-child-a-300 merged|started before "$)` with glob `!docs/**`. Strategy (b) catches the line-split Python forms that (a) misses.
- Cross-check Member Set: (a) `core.ts:285`, mirror `SKILL.md:244`, `core.test.ts:211`, `.claude/.../SKILL.md:244`; (b) `validate_epic_orchestrator_state.py:304`, `:305`, `core.test.ts:211`, `test_validate_epic_orchestrator_state.py:262`, `:263`. Union normalized to file-level sites: validator 304-305, core.ts 285, core.test.ts 211, test py 262-263, SKILL.md 244, mirror SKILL.md 244.
- Cross-check Count: 6.
- Member-set Comparison: the normalized primary and cross-check sets are identical (6 = 6, same members). The count is used only to scope the edit list; it is not proposed as an acceptance-criterion number.

## Test Strategy (no test code)

Matrix cases for the shared fixture, each asserted as the exact ordered list of barrier messages in both runtimes. Values are restricted to strings, integers, `null`, and absent keys: no integral floats, no booleans as references, and no list/dict `merge_status` (P2).

1. AC-1: dependent `not_started`, no `worktree_created_at`, dependency `pr_open`: `[]`.
2. AC-1 variant: dependent `not_started`, `worktree_created_at: null`, dependency `worktree_created`: `[]`.
3. AC-2: dependent `worktree_created` (no timestamp), dependency `pr_open`: one status message.
4. AC-2: dependent `merge_status` key absent, dependency `pr_open`: one status message.
5. AC-2: dependent `merge_status: null`, dependency `ci_green`: one status message.
6. AC-2: dependent `not_started` with a string `worktree_created_at`, dependency `pr_open`: one status message (timestamp evidence).
7. AC-2: dependency with `merge_status` absent, dependent started: one status message.
8. AC-2: started dependent with two unmerged dependencies: two status messages in `depends_on` order.
9. AC-3: started dependent, dependency `merged` with `merge_confirmed_at` later than `worktree_created_at`: one timing message.
10. AC-3: started dependent, dependencies `merged` / `worktree_removed` confirmed earlier or equal: `[]`.
11. Both conditions on one edge (dependency `pr_open` with a later `merge_confirmed_at`): exactly one status message.
12. Dependency referenced by integer `issue_num`, started dependent, unmerged dependency: status message renders the integer identically (`str` / `String`).
13. AC-6: epic #678 shape (`2026-09-13-taskmaster-push-down-and-resume-674` `not_started`, no timestamp, depending on `2026-09-13-false-approval-elimination-pr-author-model-routing-673` unmerged): `[]`.
14. AC-6: kickoff shape, all features `not_started`, four `depends_on` edges: `[]`.

Python-only unit tests of `feature_has_started` cover each predicate branch directly (string timestamp, empty-string timestamp, `not_started`, other status, absent, `null`, integer). A regression case (1 or 13) must fail before the fix (evidence under `evidence/regression-testing/`). Coverage targets: line >= 85% and branch >= 75% on `_epic_orchestrator_state_wave_barrier.py`, `validate_epic_orchestrator_state.py`, and `epic-orchestrator-state-core.ts`, with no regression on changed lines against a Phase 0 baseline.

## Recommendations

1. Predicate: started when `worktree_created_at` is a string, or `merge_status != "not_started"` (absent/non-string counts as started). Apply once per dependent and skip unstarted dependents before the edge loop, in both runtimes.
2. Messages: status case `EPIC_WAVE_BARRIER_VIOLATION: {folder} is treated as started while dependency {dependency} is not merged`; timing case `EPIC_WAVE_BARRIER_VIOLATION: {folder} worktree_created_at precedes dependency {dependency} merge_confirmed_at`. Emit exactly one per edge, status taking precedence.
3. Python: extract to new `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` (move `MERGED_STATUSES` there, import it back), and harden the dependency status check with `isinstance(..., str)` to match TS.
4. TypeScript: edit `epic-orchestrator-state-core.ts` in place (estimated 478-482 lines). Split only if it would exceed about 495 lines, and add a `jest.config.cjs` threshold entry if so.
5. Update the literals at Python test 262-263 and TS test 211. Add the two new wave-barrier test files driven by one shared fixture `tests/fixtures/epic_wave_barrier/start-guard-matrix.json`.
6. Rewrite the Layer 2 bullet at `.claude/skills/epic-orchestrate/SKILL.md:241-245` to state the start guard and both messages, and copy it verbatim to the bundled mirror (text-equality parity test).
7. Record follow-up potential entries for: (a) the Python unhashable-`merge_status` `TypeError` in `_validate_merge_status_enum`/`_validate_completion` (P2); (b) the documentation claim that Layer 2 runs at SubagentStop (Section 3.5).
8. Scope stays within minor-audit at three production files.
