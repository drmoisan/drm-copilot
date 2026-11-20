# Feature Audit — Issue #524 (Epic `require_complete` Launch-Binding Fix)

- Timestamp: 2026-08-25T08-36
- Branch: `bug/epic-require-complete-demands-launch-binding-no-agent-ever-writes-524-r3`
- HEAD: `83b45f36` (merge base with `origin/main`: `429d8bc866`)
- Work mode: `full-bug` — acceptance-criteria source is `spec.md` only (marker verified in `issue.md`)
- AC source: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/spec.md`, `## Acceptance Criteria` (16 checkbox items, all ticked by the executor)

Every tick was re-verified against evidence in this session rather than accepted. Verification commands were run at merged HEAD `83b45f36` unless noted; full-suite evidence artifacts were produced at ancestor `14e9cac0`, whose four changed code files are byte-identical to HEAD (`git diff 14e9cac0..HEAD` over them is empty).

## Per-Criterion Evaluation

AC numbers follow spec order.

| # | Criterion (abbreviated) | Verdict | Verification performed this session |
| --- | --- | --- | --- |
| 1 | New Python test: empty result for features with neither launch path key under `require_complete` alone | **PASS** | `test_require_complete_skips_feature_without_launch_paths` present in the diff (removes all four launch-evidence keys, `merged` feature, asserts `errors == []`); suite run at HEAD: 27 passed |
| 2 | New Jest test: same empty result under `requireComplete` alone | **PASS** | `skips launch binding for a feature with no launch paths under requireComplete` present in the diff; `node run-jest.cjs test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`: 24 passed |
| 3 | New Python test: partial binding (`launch_receipt_path` only) still produces the `launch_status_path` error | **PASS** | `test_require_complete_rejects_partial_launch_binding` asserts `_launch_errors(errors)` equals exactly the one error; suite passes at HEAD |
| 4 | New Jest partial-binding test with a byte-identical error string | **PASS** | `rejects a partial launch binding under requireComplete` asserts `Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.` — byte-identical to the Python assertion (compared character-for-character across both test files) |
| 5 | Neither deleted test remains; no test pins the defect | **PASS** | `git grep -n -F "test_require_complete_requires_binding_for_every_feature" -- tests/ scripts/` exit 1; `git grep -n -F "requires evidence for every feature under requireComplete" -- extensions/` exit 1 |
| 6 | Three named Python gate tests plus every `require_codex_model_routing=True` parametrised case pass unmodified | **PASS** | All three names present (`grep` at lines 78, 88, 104); AST byte-identity record in `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md` (15/15 preserved functions unchanged, 17 parametrised Codex cases passed); diff hunk touches only the replaced tests; 27 tests pass at HEAD |
| 7 | Three named Jest tests pass unmodified | **PASS** | Names present at lines 71, 80, 94 of the test file; diff touches only the replaced/added tests; 24 tests pass at HEAD |
| 8 | Codex-shaped acceptance tests unchanged in both runtimes | **PASS** | `test_require_complete_accepts_complete_persisted_binding` (line 184) unmodified per AST record and diff; Jest `accepts a fully complete checkpoint under requireComplete` lives in `epic-orchestrator-state-core.test.ts` (line 271), a file absent from the diff; core suite: 31 passed at HEAD |
| 9 | Python unmerged-feature and missing-`merge_commit_sha` tests unchanged and named as discrimination evidence | **PASS** | Both present (lines 197, 213) and byte-identical per the AST record; named in `preserved-python-tests.2026-08-24T22-52.md` and in `launch-binding-regression.2026-08-24T23-06.md`; corroborated by this session's fixture re-run (one-unmerged variant: exit 1, exactly one completion error) |
| 10 | Jest twins of the two rejection tests unchanged | **PASS** | Both live in `epic-orchestrator-state-core.test.ts` (lines 241, 256), outside the diff, therefore unmodified; core suite 31 passed at HEAD |
| 11 | Dormant/default-off tests pass unmodified in both runtimes | **PASS** | `test_launch_binding_is_dormant_without_an_enforcement_gate` (line 125), `test_require_complete_remains_disabled_by_default` (line 226) unchanged per AST record; Jest `remains dormant without a routing or completion gate` (launch-binding suite, line 115) and `defaults requireComplete to false (backward-compatible)` (core suite, line 305, outside diff); both suites pass at HEAD |
| 12 | Rule section added; bundle twin updated; push-down contract test passes | **PASS** | `git grep -n -F "Epic Launch-Binding Activation Scope"` matches line 85 of both files; `cmp` reports the two rule files byte-identical; `test_push_down_claude_resource_contracts.py` passed at HEAD (within the 37-test run) |
| 13 | Regression artifact: 20 launch-binding errors before → 0 after; one-unmerged variant produces exactly one completion error in both runs | **PASS** | Artifact `evidence/regression-testing/launch-binding-regression.2026-08-24T23-06.md` records the table citing four per-run artifacts; independently re-verified at HEAD: `validate_orchestration_artifacts epic-orchestrator-state <fixture> --require-complete` gives exit 0 for the no-launch-paths fixture and exit 1 with exactly `Epic checkpoint completion validation failed: feature 'child-d' merge_status is not merged/worktree_removed.` for the one-unmerged variant |
| 14 | Diff touches only the named production and test files; all excluded surfaces unmodified | **PASS** | `git diff origin/main...HEAD --name-status` over `validate_epic_planner_state.py`, `epic-planner-state-core.ts`, `.claude/lib/orchestrator-state`, `validate-orchestrator-output.ps1`, `.codex`, `.agents`, `jest.config.cjs` returned empty; full diff is the six named code/rule files, the feature folder, and the #543 promotion lifecycle record (a non-code doc produced by planned task P5-T4, recorded in `evidence/qa-gates/scope-verification.2026-08-25T08-27.md`) |
| 15 | Separate issue filed for the latent planner defect, number recorded in Rollout | **PASS** | `gh issue view 543 --json number,title,state` → `OPEN`, `Bug: epic-planner-ready-gate-demands-codex-only-launch-binding`; number recorded in spec `## Rollout & Follow-up`; local record `evidence/issue-updates/planner-followup-issue.2026-08-24T23-07.md`; lifecycle record in diff |
| 16 | Seven-stage toolchain clean in a single pass; coverage >= 85% line / >= 75% branch on both changed modules with no regression on changed lines | **PASS** | Evidence: `evidence/qa-gates/final-qa-clean-pass.2026-08-25T08-23.md` (all stages exit 0; pytest 4117 passed; Jest 2658 passed) and `evidence/qa-gates/coverage-delta-verification.2026-08-25T08-25.md` (Python module 97.48%/94.64%, TS module 96.00%/92.72%, new code 100% both runtimes, no measure decreased). Corroborated at merged HEAD this session: black/ruff/pyright clean on changed Python files; prettier/eslint clean on changed TS files; `tsc -p ./ --noEmit` clean project-wide; targeted coverage run reproduces the per-module figures within the single-file floor (113/119, 51/56 from the one test file alone) |

## Baseline-Relative Behavior Verification

- Before-state evidence (`evidence/regression-testing/before-*.md`, produced against the pre-change code) records 20 launch-binding errors for the Claude-shape fixture and 21 total for the one-unmerged variant; after-state at HEAD reproduces 0 and 1 respectively (re-run in this session). The completion gate's discrimination is preserved: a genuinely incomplete epic still fails with exactly its genuine error.
- No-flag and Codex-flag behavior is byte-identical to baseline: the activation short-circuit is unchanged, and all 17 preserved parametrised Codex cases plus the dormancy/default tests pass unmodified.

## Newly Checked-Off Items

None. All 16 items were already ticked by the executor; this audit confirms each tick is genuinely satisfied. No item was unticked.

### Acceptance Criteria Status
- Source: docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/spec.md
- Total AC items: 16
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: none

## Verdict

All 16 acceptance criteria PASS against verified evidence. No PARTIAL, FAIL, or UNVERIFIED items. Findings from the companion artifacts: 0 Blocking, 2 Non-blocking (code-review CR-1 naming, CR-2 twin asymmetry). The feature is complete relative to its spec.
