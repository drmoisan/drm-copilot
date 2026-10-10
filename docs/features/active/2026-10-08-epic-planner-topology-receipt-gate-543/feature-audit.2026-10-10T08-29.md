# Feature Audit: Epic planner ready gate key-gates the planner topology receipt (#543)

- Audit date: 2026-10-10
- Branch: `bug/epic-planner-topology-receipt-gate-543`
- Reviewer: feature-review agent

## Scope and Baseline

- Base: `origin/main` at `7bbd0b9b990737642b4eeded01a27b7c5c8348b3` (equals `git merge-base origin/main HEAD`).
- Head: `e7612e93a4e88f68eadae6ee9e34ead251c82872`.
- Diff: `git diff 7bbd0b9b...HEAD`, 60 paths; 5 code paths outside the feature folder (2 production, 3 test), 55 feature-folder paths (issue, spec, research, plan, 51 evidence files).
- Work mode: `full-bug` (`issue.md` line 10). AC source: `spec.md` `## Acceptance Criteria` only (lines 221-236, 14 items). No `user-story.md` exists, as `spec.md` line 9 records.
- Plan: `plan.2026-10-08T13-56.md`, 64 of 64 tasks checked; `## Plan Deviations` lists 8 execution-route deviations, none affecting the write set or any assertion.
- Accepted non-goal (per `spec.md` lines 55-56 and 253-255, and confirmed by the caller): per-feature `model_routing_receipt` and `topology_receipt` checks remain unconditional; the PR will state "Partially addresses #543". This is not treated as a gap.
- Baseline behaviour (pre-fix): `fail-before-python.2026-10-10T08-07.md` and `fail-before-typescript.2026-10-10T08-08.md` record the regression test failing with `['Epic planner topology_receipt must be an object.']` on pre-fix code in both runtimes.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Pre-review state |
|---|---|---|
| AC1 | Python `test_ready_gate_skips_planner_topology_receipt_when_key_absent`, fail-before / pass-after evidence | `[x]` |
| AC2 | Python `test_codex_flag_keeps_planner_topology_receipt_unconditional`, parametrized over both flags | `[x]` |
| AC3 | Python `test_ready_gate_validates_present_null_planner_topology_receipt` | `[x]` |
| AC4 | Python present-valid receipt test, no flag and `require_codex_topology=True` | `[x]` |
| AC5 | `test_readiness_requires_epic_preparation_topology_receipts` updated to assert under a Codex flag; per-feature assertions retained | `[x]` |
| AC6 | TypeScript twins of the four Python tests with byte-identical strings | `[x]` |
| AC7 | MCP service-call test asserts both flags error and key-gated does not | `[x]` |
| AC8 | Both calls conditioned on key membership or Codex flag; no `Epic planner` string literal changed | `[x]` |
| AC9 | Pre-existing present-receipt tests pass without modification | `[x]` |
| AC10 | Excluded paths unchanged (`git diff` empty) | `[x]` |
| AC11 | Seven-stage toolchain single clean pass in both languages, recorded under `evidence/qa-gates/` | `[x]` |
| AC12 | Python full-suite coverage exits 0; `validate_epic_planner_state.py` >= 85% lines, >= 75% branches, no regression | `[x]` |
| AC13 | Jest coverage run exits 0; `epic-planner-state-core.ts` text row >= 85% / 75%, no regression; both outcomes exercised | `[x]` |
| AC14 | Every named file <= 500 lines, recorded under `evidence/qa-gates/` | `[x]` |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence (reviewer-verified unless stated) |
|---|---|---|
| AC1 | PASS | Test at `tests/scripts/dev_tools/test_validate_epic_planner_state.py:254-265` pops the key, calls with `require_ready_for_execution=True` and no flag, asserts no error contains `Epic planner topology_receipt`. Fail-before (exit 1, `assert ['Epic planner topology_receipt must be an object.'] == []`) and pass-after (exit 0) recorded under `evidence/regression-testing/`. Commit order (test `38d21557c` before fix `0192f0a0f`) is consistent. Reviewer re-run: passed. |
| AC2 | PASS | Parametrized over `["require_codex_model_routing", "require_codex_topology"]`, pops the key, asserts the exact string is in errors. Reviewer re-run: both cases passed. |
| AC3 | PASS | Sets `topology_receipt` to `None`, no flag, asserts the exact string. Reviewer re-run: passed. |
| AC4 | PASS | `test_ready_gate_accepts_present_valid_planner_topology_receipt` parametrized over `require_codex_topology` `[False, True]`, asserts no `Epic planner topology_receipt` error. Reviewer re-run: both passed. |
| AC5 | PASS | Line 222 now passes `require_codex_topology=True`; assertions at lines 225-234 (planner and per-feature) retained. Reviewer re-run: passed. See code-review CR-2 for a non-blocking note on the key-gated per-feature invariant. |
| AC6 | PASS | `epic-planner-state-core.test.ts` lines 364-424: key absent no flag (filter equals `[]`); `it.each(codexFlagCases)` over `requireCodexModelRouting` and `requireCodexTopology` (`toContain`); present `null` no flag (`toContain`); `it.each(validReceiptCases)` over `{}` and `{ requireCodexTopology: true }` (filter equals `[]`). Strings byte-identical to Python. Reviewer re-run: passed. |
| AC7 | PASS | `validate-orchestration-service-call.test.ts` lines 205-211 add `routing` and `topology` `toContain("Epic planner topology_receipt must be an object.")` and `keyGated` `not.toContain("Epic planner topology_receipt")`. Reviewer re-run: passed. |
| AC8 | PASS | Read source: Python line 348 `if not key_gated or "topology_receipt" in state:`; TypeScript line 444 `if (!requireLaunchPaths \|\| "topology_receipt" in value) {`. Reviewer `git diff 7bbd0b9b...HEAD` on both production files: no added or removed line contains `Epic planner`; only comment, docstring, and condition lines changed. The criterion names `git diff main`; the merge base equals the `origin/main` tip, so the comparison is identical. |
| AC9 | PASS | `test_readiness_requires_forced_epic_planner_persona` (lines 237-251), `test_cli_dispatches_planner_readiness_flag`, `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`, and `requires the forced epic-planner topology receipt` are unmodified (diff hunks are pure insertions apart from line 222; `test_push_down_codex_and_agents_customizations.py` is not in the diff). Reviewer re-ran the spec's targeted pytest selection (71 passed) and the targeted Jest selection plus `mcp-server-epic-validation.test.ts` (63 passed). |
| AC10 | PASS | Reviewer `git diff --stat 7bbd0b9b...HEAD` lists no path under `scripts/dev_tools/validate_orchestration_artifacts.py`, `.claude`, `.github`, `.agents`, `.codex`, `extensions/drm-copilot/resources`, `extensions/drm-copilot/jest.config.cjs`, or `extensions/drm-copilot/src/mcp-tool-inputs.ts`. Executor evidence `evidence/qa-gates/scope-exclusions.2026-10-10T08-16.md` agrees. |
| AC11 | PASS | `evidence/qa-gates/final-qa-clean-pass.2026-10-10T08-22.md`: both seven-stage loops completed in iteration 1 with 0 restarts. Reviewer re-ran format, lint, type-check, and tests in both languages at head: all exit 0. The architecture stage is a presence check because no boundary tool is configured (policy audit PA-5). |
| AC12 | PASS | Executor full-suite run exit 0, 6746 passed (`final-python-test-coverage.2026-10-10T08-17.md`). Reviewer parse of `artifacts/python/lcov.info` (written 08:19, after the last Python code commit at 08:11): LF 182 / LH 167 = 91.76% lines; BRF 96 / BRH 81 = 84.38% branches. Baseline 91.71% / 84.04%. Added executable lines 348-349 covered; both arcs from 348 executed (`coverage-delta-verification.2026-10-10T08-21.md`). |
| AC13 | PASS (executor evidence) | The criterion specifies the `text` reporter row, and `final-typescript-test-coverage.2026-10-10T08-20.md` records it verbatim: `98.31 \| 93.8 \| 100 \| 98.31 \| 69-70,75-76,78-79,273-274`, exit 0, 3951 passed; baseline 98.3 / 93.57. Lines 444-446 are absent from `Uncovered Line #s`, and both outcomes of the condition are exercised by the passing tests named in AC6. The reviewer could not independently re-derive these values because no TypeScript coverage artifact exists and the agent contract forbids regenerating coverage; that artifact gap is a policy-audit finding (PA-1), not a failure of this criterion as written. |
| AC14 | PASS | Reviewer `awk 'END{print NR}'`: `validate_epic_planner_state.py` 375, `epic-planner-state-core.ts` 474, `test_validate_epic_planner_state.py` 424, `epic-planner-state-core.test.ts` 490, `validate-orchestration-service-call.test.ts` 232. Recorded in `evidence/qa-gates/line-counts-final.2026-10-10T08-22.md` (the criterion names `(Get-Content <path>).Count`; `awk` returns the same physical line count). |

## Summary

- 14 of 14 acceptance criteria evaluated PASS. AC13 rests on executor text-reporter evidence that the reviewer could not re-derive from an artifact; it is marked PASS because the criterion specifies exactly that evidence form.
- The issue's Expected Behavior (`issue.md` lines 29-31) is delivered for the planner-level receipt in both runtimes. The end-to-end outcome for a Claude-prepared checkpoint is not reached, because the per-feature receipt checks remain unconditional; this is an accepted, documented non-goal (`spec.md` line 253), and the PR must state "Partially addresses #543" without a closing keyword.
- Blocking findings in this artifact: 0. Branch-level blocking item: policy audit PA-1 (TypeScript coverage artifact absent). Non-blocking notes: code review CR-1 through CR-3; policy audit PA-2 through PA-5.
- Overall feature verdict: acceptance criteria met; branch requires PA-1 remediation (evidence only, no code change expected) before PR authoring.

## Acceptance Criteria Check-off

All 14 criteria were already checked `[x]` by the executor (`evidence/qa-gates/acceptance-checkoff.2026-10-10T08-23.md`). Each evaluated PASS in this review, so no checkbox was changed and none was unchecked. `spec.md` was not modified by the reviewer.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` (`## Acceptance Criteria`)
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: none
