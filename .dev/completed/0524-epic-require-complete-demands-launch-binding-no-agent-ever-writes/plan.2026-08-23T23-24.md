# 2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes (Plan)

- **Issue:** #524
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-24
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug
- **Requirements source:** `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/spec.md`, section `## Acceptance Criteria`. `user-story.md` is intentionally absent for this bug and must not be created.
- **Research source:** `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/research/2026-08-23T23-45-epic-launch-binding-gate-research.md`
- **Defect report:** `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/issue.md`

**Fail-closed evidence rule:** Every baseline task, final-QA task, and coverage-comparison task in this plan produces a named artifact. If any required artifact is missing, or carries a placeholder in place of a numeric value, the verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. Do not mark an evidence-backed task complete without the artifact on disk.

**Evidence location:** All evidence resolves under `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/<kind>/`, with `<kind>` drawn from `baseline`, `regression-testing`, `qa-gates`, and `other`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Any `artifacts/`-rooted evidence path is forbidden and must be rejected if supplied.

---

## The change, already decided

`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` admits the generic `require_complete` flag into an otherwise Codex-specific activation set, which made Codex-only launch evidence a universal completion requirement. The evidence has exactly one production writer, `.codex/scripts/launch-epic-child-wave.ps1`, on the Codex runtime; the Claude runtime never writes it, so the gate cannot pass there.

The correction, which this plan encodes and does not re-litigate:

1. Under `require_complete` **alone**, validate a feature's launch binding **only when that feature carries `launch_receipt_path` or `launch_status_path`**. Presence is key membership, so a key present with an empty or null value still arms the gate.
2. Under `require_codex_model_routing` or `require_codex_topology`, the gate stays **unconditional and byte-identical to today**, including the existing `skip_not_started` filter.
3. A **partial** binding — one launch path key present, the other missing — must still fail under `require_complete` alone. That property is what distinguishes this fix from deleting the gate. It is implemented deliberately as "either key", never "both keys", and it is tested in both runtimes.
4. No error string is added, removed, or reworded. Python and TypeScript error strings stay byte-identical to each other.

## Files the diff will WRITE

Production:

- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`
- `.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`

Tests:

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`

Two notes on that list.

**The last two production files are one logical change recorded twice.** They are currently byte-identical (SHA-256 prefix `c47461a7`, 12178 bytes each), and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enforces that relation. Both receive the identical edit in the same task (P3-T4); editing one without the other fails that contract test.

**Amending `.claude/rules/orchestrator-state.md` is a deliberate, authorized exception** to the baseline constraint in `.claude/skills/policy-compliance-order/SKILL.md` against modifying policy documents under `.claude/rules/`. The authorization rests on three facts: that file is the repository's declared enforcement specification for the very validator being corrected; issue #524 names it explicitly among the files that must change; and leaving it unamended would make its prose false about the gate's activation scope. The executor must not stall on this constraint, and a reviewer must not read the edit as a policy violation. No other file under `.claude/rules/` may be modified by this diff.

Feature-process artifacts written outside the code diff (not part of the enumerated production/test set): this plan file, `spec.md` (Rollout follow-up number and acceptance-criteria checkboxes), and the evidence artifacts under this feature folder's `evidence/` tree.

## Read-only policy citations (NOT written by this diff)

These files are read for policy compliance in Phase 0 and are never amended by this work:

- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/python.md`
- `.claude/rules/python-suppressions.md`
- `.claude/rules/typescript.md`
- `.claude/rules/typescript-suppressions.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/tonality.md`
- `.claude/rules/plan-acceptance-gates.md`
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

## Explicitly out of scope

- **The epic planner surface.** `scripts/dev_tools/validate_epic_planner_state.py` calls `validate_epic_planner_child_launch_bindings` unconditionally inside its `require_ready_for_execution` block and carries a structurally identical defect. It is **latent**: no Claude skill or agent passes `require_ready_for_execution`, so no symptom reproduces. It must NOT be fixed in this diff. A separate GitHub issue is filed for it in P5-T4 and its number recorded in P5-T5.
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` — unmodified for the same reason.
- `.claude/lib/orchestrator-state/` — implements no part of this gate (verified zero matches for the launch-binding identifiers across the whole `.claude/` tree).
- `.claude/hooks/validate-orchestrator-output.ps1` — performs a structural check only for the epic artifact type and never passes `require_complete`.
- `.codex/**` and `.agents/**` — the Codex runtime keeps the gate unchanged because it passes both Codex flags.
- `extensions/drm-copilot/jest.config.cjs` — no per-file coverage-threshold entry is added; post-change TypeScript coverage for the changed module is read from the `text` coverage reporter instead.
- MCP tool definitions and `scripts/dev_tools/validate_orchestration_artifacts.py` — the epic subparser already carries and dispatches all three flags.
- **PowerShell / Pester.** There is no Pester coverage of this gate, so the PowerShell toolchain is not part of this plan's QA loop. Languages in scope are **Python and TypeScript only**.

## Acceptance-condition authoring notes

Literals this plan instructs the executor to create, quoted here verbatim so a search for them is a real assertion rather than a search that can never match:

- The new rule-file section heading is `## Epic Launch-Binding Activation Scope`, added to both copies of the orchestrator-state rule file.
- The new Python test names are `test_require_complete_skips_feature_without_launch_paths` and `test_require_complete_rejects_partial_launch_binding`.
- The new Jest test names are `skips launch binding for a feature with no launch paths under requireComplete` and `rejects a partial launch binding under requireComplete`.
- The removed Python test name is `test_require_complete_requires_binding_for_every_feature`; the removed Jest test name is `requires evidence for every feature under requireComplete`.
- The byte-identical partial-binding error string both runtimes must assert is: `Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.`

Coverage arguments in this plan always use the importable dotted `--cov=` form. `src/` holds no Python, so `--cov=scripts.dev_tools` is equivalent to the configured `[tool.coverage.run] source` and is the whole-suite form used throughout.

---

### Phase 0 — Policy reads and baseline capture

- [x] [P0-T1] Read the policy files in the order defined by `policy-compliance-order` and write the Phase 0 read record.
  - Files, in order: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.claude/rules/typescript.md`; `.claude/rules/typescript-suppressions.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/tonality.md`; `.claude/rules/plan-acceptance-gates.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
  - Acceptance: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/baseline/phase0-instructions-read.<yyyy-MM-ddTHH-mm>.md` exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read. No Phase 1 task begins before this artifact exists.

- [x] [P0-T2] Read `spec.md`, the research artifact, and `issue.md` in this feature folder, and record the confirmed scope.
  - Acceptance: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/baseline/scope-confirmation.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, the six enumerated production and test file paths, the excluded-path list from the Out of scope section above, and an explicit statement that the `.claude/rules/orchestrator-state.md` edit is authorized by issue #524.

- [x] [P0-T3] Capture the Python formatting baseline by running `poetry run black --check .` from the repository root.
  - Acceptance: `.../evidence/baseline/baseline-python-format.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the number of files that would be reformatted, or `unchanged`.

- [x] [P0-T4] Capture the Python lint baseline by running `poetry run ruff check .` from the repository root.
  - Acceptance: `.../evidence/baseline/baseline-python-lint.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the numeric finding count or `All checks passed`.

- [x] [P0-T5] Capture the Python type-check baseline by running `poetry run pyright` from the repository root.
  - Acceptance: `.../evidence/baseline/baseline-python-typecheck.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording numeric error and warning counts.

- [x] [P0-T6] Capture the Python test and coverage baseline by running `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` from the repository root.
  - Acceptance: `.../evidence/baseline/baseline-python-test-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying four numeric values with no placeholders: total line coverage percent, total branch coverage percent, the passed test count, and the failed test count. The summary must additionally record the per-file line and branch percentages from the `term-missing` table for the row `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`.

- [x] [P0-T7] Capture the TypeScript formatting baseline by running `npm run format` in `extensions/drm-copilot/` followed by `git status --porcelain`.
  - Acceptance: `.../evidence/baseline/baseline-typescript-format.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording whether any file changed and, if so, which.

- [x] [P0-T8] Capture the TypeScript lint baseline by running `npm run lint` in `extensions/drm-copilot/`.
  - Acceptance: `.../evidence/baseline/baseline-typescript-lint.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording numeric error and warning counts.

- [x] [P0-T9] Capture the TypeScript type-check baseline by running `npm run typecheck` in `extensions/drm-copilot/`.
  - Acceptance: `.../evidence/baseline/baseline-typescript-typecheck.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the numeric error count.

- [x] [P0-T10] Capture the TypeScript test and coverage baseline by running `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` in `extensions/drm-copilot/`.
  - Acceptance: `.../evidence/baseline/baseline-typescript-test-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying numeric total line and branch percentages, passed and failed suite/test counts, and the per-file line and branch percentages from the `text` table for `src/lib/validate/epic-orchestrator-state-launch-binding.ts`. No placeholders.

### Phase 1 — Pre-change regression evidence (fail-before)

- [x] [P1-T1] Construct the four-feature Claude-shape epic checkpoint fixture that reproduces the destination failure and write it to `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-no-launch-paths.json`.
  - Shape: model the checkpoint on the `_state` and `_feature` helpers in `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`, with four features `child-a` through `child-d` carrying `issue_num` 101 through 104, all in `wave_number` 0, all with `depends_on` empty and `merge_status` set to `merged`, and with the top-level key `epic_merge_pr` set to an object whose `merge_commit_sha` is a non-empty string.
  - Per-feature deviations that reproduce the destination shape: `branch_name` present, unique, and well formed; `worktree_path` written as a drive-qualified forward-slash Windows path such as `C:/repo/worktrees/child-a`, which the canonicality predicate rejects; and the four keys `launch_receipt_path`, `launch_status_path`, `delegation_receipt`, and `model_routing_receipt` all **absent**.
  - Acceptance: the file exists, parses as JSON, and its `features` array has exactly four entries, none of which carries either launch path key.

- [x] [P1-T2] Construct the one-unmerged variant and write it to `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json`.
  - Shape: byte-identical to the P1-T1 fixture except that the `child-d` feature's `merge_status` is `worktree_created` rather than `merged`.
  - Acceptance: the file exists, parses as JSON, and exactly one of its four features has a `merge_status` outside the merged set.

- [x] [P1-T3] [expect-fail] Record the pre-change launch-binding error count for the no-launch-paths fixture by running `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-no-launch-paths.json --require-complete`.
  - Acceptance: `.../evidence/regression-testing/before-no-launch-paths.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:` recording the total error count and the count of error lines whose text contains the phrase `launch binding`. The launch-binding count must be exactly 20 (five per feature across four features). If it is not 20, correct the fixture to the destination shape described in P1-T1 and re-run before proceeding; do not proceed on a different count.

- [x] [P1-T4] [expect-fail] Record the pre-change error profile for the one-unmerged fixture by running `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json --require-complete`.
  - Acceptance: `.../evidence/regression-testing/before-one-unmerged.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:` recording a total of 21 errors, of which exactly 20 are launch-binding errors and exactly 1 contains the phrase `merge_status is not merged/worktree_removed`. The total of 21 is the destination reproduction recorded in `issue.md`.

### Phase 2 — Failing regression tests

- [x] [P2-T1] Add the Python test `test_require_complete_skips_feature_without_launch_paths` to `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`.
  - Body: build a state from `_state` with one feature derived from `_feature(merge_status="merged")` whose `launch_receipt_path`, `launch_status_path`, `delegation_receipt`, and `model_routing_receipt` keys are all removed; set `epic_merge_pr` with a non-empty `merge_commit_sha`; call `validate_epic_orchestrator_state_text` with `require_complete=True` and both Codex flags left at their defaults; assert the returned list equals the empty list.
  - Acceptance: the test function exists in that file with exactly that name, follows Arrange-Act-Assert, and adds no filesystem, clock, or temporary-file dependency.

- [x] [P2-T2] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py -k test_require_complete_skips_feature_without_launch_paths` and record the failing run.
  - Acceptance: `.../evidence/regression-testing/fail-before-python.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:` showing 1 failed and 0 passed, with the assertion diff listing the launch-binding errors the unfixed validator returned.

- [x] [P2-T3] Add the Jest test `skips launch binding for a feature with no launch paths under requireComplete` to `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`.
  - Body: the direct twin of P2-T1 built from the file's existing `state` and `feature` helpers, calling `validateEpicOrchestratorStateText` with `{ requireComplete: true }` and asserting `toEqual([])`.
  - Acceptance: the test exists with exactly that name inside the `epic child launch binding` describe block.

- [x] [P2-T4] [expect-fail] Run `node run-jest.cjs test/lib/validate/epic-orchestrator-state-launch-binding.test.ts -t "skips launch binding for a feature with no launch paths under requireComplete"` in `extensions/drm-copilot/` and record the failing run.
  - Acceptance: `.../evidence/regression-testing/fail-before-typescript.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:` showing 1 failed and 0 passed for that test name.

### Phase 3 — Production change

- [x] [P3-T1] In `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`, add the module-private predicate `_carries_launch_path(feature)` returning `True` when the feature mapping contains the key `launch_receipt_path` or the key `launch_status_path`, judged by key membership rather than by value truthiness.
  - Acceptance: the function is defined, fully type-annotated, carries a one-line docstring, and `poetry run pyright` reports no new error for that file.

- [x] [P3-T2] In the same file, add the keyword-only parameter `require_launch_paths: bool` defaulting to `False` to `_validate_launch_bindings`, apply the skip `if require_launch_paths and not _carries_launch_path(feature): continue` immediately after the existing `skip_not_started` filter, and pass `require_launch_paths=False` explicitly from `validate_epic_planner_child_launch_bindings`.
  - Acceptance: the default is `False`, so every existing caller is behaviourally unchanged. `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` reports exactly one failing test, and that failing test is `test_require_complete_skips_feature_without_launch_paths`; `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` reports zero failures.

- [x] [P3-T3] In the same file, change `validate_epic_child_launch_bindings` so that it passes `require_launch_paths=not (require_codex_model_routing or require_codex_topology)` into `_validate_launch_bindings`, leaving the activation condition, the `skip_not_started=not require_complete` expression, the non-list `features` early return, and every error string unchanged.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py -k test_require_complete_skips_feature_without_launch_paths` reports 1 passed and 0 failed, and the file remains under the 500-line cap.

- [x] [P3-T4] Mirror the change in `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` by adding a `featureCarriesLaunchPath` predicate, adding `requireLaunchPaths: boolean` to the `LaunchBindingContext` interface, applying the same per-feature skip after the `skipNotStarted` check, passing `requireLaunchPaths: false` from `validateEpicPlannerChildLaunchBindings`, and passing `requireLaunchPaths: options.requireCodexModelRouting !== true && options.requireCodexTopology !== true` from `validateEpicChildLaunchBindings`.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-orchestrator-state-launch-binding.test.ts -t "skips launch binding for a feature with no launch paths under requireComplete"` in `extensions/drm-copilot/` reports 1 passed and 0 failed, and no error string in the file is added, removed, or reworded.

- [x] [P3-T5] Add the section `## Epic Launch-Binding Activation Scope` to `.claude/rules/orchestrator-state.md` and write the byte-identical section into `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` in the same task, at the same position, immediately before the file's final `## Enforcement` section.
  - Content: state that epic launch-binding validation is unconditional under the two Codex enforcement flags `require_codex_model_routing` and `require_codex_topology`; that under `require_complete` alone it is key-gated per feature and applies only to a feature carrying `launch_receipt_path` or `launch_status_path`; that the presence test is deliberately either-key so a partial binding still fails; that the sole production writer of the evidence is the Codex launcher and no Claude-runtime producer exists; and that enforcement is validator logic plus this prose, never an imported JSON Schema.
  - Acceptance: `git grep -n -F "Epic Launch-Binding Activation Scope" -- .claude/rules/orchestrator-state.md` returns at least one match, the same search against `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` returns at least one match, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` reports zero failures.

### Phase 4 — Test-suite alignment and preserved-negative verification

- [x] [P4-T1] Remove the Python test `test_require_complete_requires_binding_for_every_feature` from `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`, since it pins the defect as intended behaviour.
  - Acceptance: `git grep -n -F "test_require_complete_requires_binding_for_every_feature" -- tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` returns no match, and no other test in the repository asserts that a feature carrying no launch evidence fails under `require_complete` alone.

- [x] [P4-T2] Add the Python test `test_require_complete_rejects_partial_launch_binding` to the same file.
  - Body: build a state from `_state(_feature(merge_status="merged"))`, remove only the `launch_status_path` key from the feature so `launch_receipt_path` remains, set `epic_merge_pr` with a non-empty `merge_commit_sha`, call the validator with `require_complete=True` and both Codex flags at their defaults, and assert that `_launch_errors(errors)` equals a single-element list holding exactly the string `Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.`
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py -k test_require_complete_rejects_partial_launch_binding` reports 1 passed and 0 failed.

- [x] [P4-T3] Remove the Jest test `requires evidence for every feature under requireComplete` from `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`.
  - Acceptance: `git grep -n -F "requires evidence for every feature under requireComplete" -- extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` returns no match.

- [x] [P4-T4] Add the Jest test `rejects a partial launch binding under requireComplete` to the same file, asserting the byte-identical partial-binding error string the Python test asserts.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-orchestrator-state-launch-binding.test.ts -t "rejects a partial launch binding under requireComplete"` in `extensions/drm-copilot/` reports 1 passed and 0 failed, and the asserted string in the Jest test is character-for-character the same as the string asserted in P4-T2.

- [x] [P4-T5] Run the full Python launch-binding suite and confirm every preserved test passes with no change to its body, by running `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`.
  - Preserved tests that must pass unmodified: `test_model_routing_gate_accepts_complete_launch_binding`, `test_topology_gate_activates_launch_binding_validation`, `test_unlaunched_feature_does_not_require_binding_under_routing_gate`, `test_launch_binding_is_dormant_without_an_enforcement_gate`, `test_require_complete_accepts_complete_persisted_binding`, `test_require_complete_rejects_unmerged_feature`, `test_require_complete_rejects_missing_merge_commit_sha`, `test_require_complete_remains_disabled_by_default`, and every parametrised case supplying `require_codex_model_routing=True`.
  - Acceptance: `.../evidence/regression-testing/preserved-python-tests.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` naming each preserved test above as passed and recording that no preserved test body was edited.

- [x] [P4-T6] Run the full TypeScript validate suite and confirm every preserved Jest test passes with no change to its body, by running `node run-jest.cjs test/lib/validate` in `extensions/drm-copilot/`.
  - Preserved tests that must pass unmodified: `accepts complete evidence under the model-routing gate`, `activates under the topology gate`, `does not require evidence before the feature launches`, `remains dormant without a routing or completion gate`, `accepts complete persisted evidence at completion`, `rejects requireComplete when a feature is not merged/worktree_removed`, `rejects requireComplete when epic_merge_pr.merge_commit_sha is missing`, `accepts a fully complete checkpoint under requireComplete`, and `defaults requireComplete to false (backward-compatible)`.
  - Acceptance: `.../evidence/regression-testing/preserved-typescript-tests.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` naming each preserved test above as passed and recording that no preserved test body was edited.

### Phase 5 — Post-change regression evidence, documentation, and follow-up

- [x] [P5-T1] Record the post-change result for the no-launch-paths fixture by re-running `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-no-launch-paths.json --require-complete`.
  - Acceptance: `.../evidence/regression-testing/after-no-launch-paths.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording 0 launch-binding errors and 0 total errors.

- [x] [P5-T2] Record the post-change result for the one-unmerged fixture by re-running `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json --require-complete`.
  - Acceptance: `.../evidence/regression-testing/after-one-unmerged.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:` recording 0 launch-binding errors and exactly 1 error containing the phrase `merge_status is not merged/worktree_removed`. This is the discrimination guarantee: the completion gate still fails on a genuinely incomplete epic.

- [x] [P5-T3] Write the consolidated regression artifact that satisfies the spec's regression acceptance criterion.
  - Acceptance: `.../evidence/regression-testing/launch-binding-regression.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:` and a table recording, for the four-feature no-launch-paths checkpoint, 20 launch-binding errors before the change and 0 after; and for the one-unmerged variant, exactly 1 completion error in both the before run and the after run. It cites the four per-run artifact paths from P1-T3, P1-T4, P5-T1, and P5-T2.

- [x] [P5-T4] File a separate GitHub issue for the latent `require_ready_for_execution` launch-binding defect in `scripts/dev_tools/validate_epic_planner_state.py`.
  - Content: the defect shape (`validate_epic_planner_child_launch_bindings` is called unconditionally inside the `require_ready_for_execution` block and additionally sets `require_generated_orchestrator=True`, restricting `agent_name` to five Codex-generated persona names absent from the Claude runtime), the reason it is latent (no Claude skill or agent passes that flag), and a reference to issue #524 and this feature folder.
  - Acceptance: the issue exists with a numeric issue number, and `.../evidence/issue-updates/planner-followup-issue.<yyyy-MM-ddTHH-mm>.md` records `Timestamp:`, the exact text filed, `PostedAs: body`, and the issue URL.

- [x] [P5-T5] Record the P5-T4 issue number in the `## Rollout & Follow-up` section of `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/spec.md`.
  - Acceptance: the Rollout follow-up bullet in `spec.md` names the numeric issue number filed in P5-T4, replacing the current placeholder wording.

- [x] [P5-T6] Tick each satisfied checkbox in the `## Acceptance Criteria` section of `spec.md`, appending the evidence path or test name that satisfies it.
  - Acceptance: every acceptance criterion is either ticked with a cited artifact path or test name, or left unticked with a one-line statement of what remains. No criterion is ticked without a citation.

### Phase 6 — Final QA loop

Run the loop in language order, Python first then TypeScript, and in stage order within each language: format, lint, type-check, test. If any stage fails or changes files, restart that language's loop from its format stage. Every task below is unconditional; `SKIPPED` is not a valid outcome for any of them.

- [x] [P6-T1] Run `poetry run black .` from the repository root as the Python format stage, followed by `git status --porcelain`.
  - Acceptance: `.../evidence/qa-gates/final-python-format.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the reformatted-file count. If any file changed, restart the Python loop at this task after recording the restart.

- [x] [P6-T2] Run `poetry run ruff check .` from the repository root as the Python lint stage.
  - Acceptance: `.../evidence/qa-gates/final-python-lint.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording zero findings. A non-zero exit requires a fix and a restart from P6-T1.

- [x] [P6-T3] Run `poetry run pyright` from the repository root as the Python type-check stage.
  - Acceptance: `.../evidence/qa-gates/final-python-typecheck.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording zero errors.

- [x] [P6-T4] Run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` from the repository root as the Python test stage.
  - Acceptance: `.../evidence/qa-gates/final-python-test-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` carrying numeric post-change total line and branch coverage percentages, passed and failed test counts, and the per-file line and branch percentages for the `term-missing` row `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`. No placeholders.

- [x] [P6-T5] Run `npm run format` in `extensions/drm-copilot/` as the TypeScript format stage, followed by `git status --porcelain`.
  - Acceptance: `.../evidence/qa-gates/final-typescript-format.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording whether any file changed. If any file changed, restart the TypeScript loop at this task after recording the restart.

- [x] [P6-T6] Run `npm run lint` in `extensions/drm-copilot/` as the TypeScript lint stage.
  - Acceptance: `.../evidence/qa-gates/final-typescript-lint.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording zero errors and zero warnings.

- [x] [P6-T7] Run `npm run typecheck` in `extensions/drm-copilot/` as the TypeScript type-check stage.
  - Acceptance: `.../evidence/qa-gates/final-typescript-typecheck.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording zero errors.

- [x] [P6-T8] Run `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` in `extensions/drm-copilot/` as the TypeScript test stage.
  - Acceptance: `.../evidence/qa-gates/final-typescript-test-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` carrying numeric post-change total line and branch percentages, passed and failed suite/test counts, and the per-file line and branch percentages from the `text` table for `src/lib/validate/epic-orchestrator-state-launch-binding.ts`. No placeholders.

- [x] [P6-T9] Confirm a single clean pass of both language loops with no file changes and no failures in that pass.
  - Acceptance: `.../evidence/qa-gates/final-qa-clean-pass.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:` and a stage-by-stage table for Python and TypeScript recording each stage's `EXIT_CODE`, plus the number of loop restarts performed and the reason for each.

- [x] [P6-T10] Verify coverage deltas and thresholds against the uniform gate of `.claude/rules/quality-tiers.md`.
  - Acceptance: `.../evidence/qa-gates/coverage-delta-verification.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:` and reports, per language, three numeric groups: baseline coverage from P0-T6 and P0-T10, post-change coverage from P6-T4 and P6-T8, and new/changed-code coverage for the lines added in P3-T1 through P3-T4. It confirms line coverage at or above 85 percent and branch coverage at or above 75 percent for `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` and `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`, and confirms no regression on changed lines. A missing numeric value makes the verdict INCOMPLETE, not PASS.

- [x] [P6-T11] Verify that the code diff touches only the enumerated production and test files, by running `git status --porcelain` from the repository root and reviewing the changed-path list.
  - Acceptance: `.../evidence/qa-gates/scope-verification.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` showing that the changed paths outside this feature folder are exactly the six enumerated files, and that `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `.claude/lib/orchestrator-state/`, `.claude/hooks/validate-orchestrator-output.ps1`, `.codex/`, `.agents/`, and `extensions/drm-copilot/jest.config.cjs` are unmodified.
