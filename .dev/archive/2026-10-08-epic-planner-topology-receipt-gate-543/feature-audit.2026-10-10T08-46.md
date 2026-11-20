# Feature Audit: Epic planner ready gate key-gates the planner topology receipt (#543)

- Audit date: 2026-10-10
- Audit type: Remediation cycle 1 re-audit (review pass 2). Supersedes `feature-audit.2026-10-10T08-29.md`.
- Branch: `bug/epic-planner-topology-receipt-gate-543`
- Reviewer: feature-review agent

## Scope and Baseline

- Base: `origin/main` at `7bbd0b9b990737642b4eeded01a27b7c5c8348b3` (equals `git merge-base origin/main HEAD`).
- Head: `ab36c108a4f72fc710f824a26100351352526286` (equals the remote branch head).
- Diff: `git diff 7bbd0b9b...HEAD`, 74 paths; 5 code paths outside the feature folder (2 production, 3 test), 69 feature-folder paths.
- Change since the prior review (`e7612e93..HEAD`): 14 added feature-folder documents only; `spec.md` unchanged (no `spec.md` path in `git diff --name-status e7612e93..HEAD`).
- Work mode: `full-bug` (`issue.md` line 10). AC source: `spec.md` `## Acceptance Criteria` only (lines 221-236, 14 items). No `user-story.md` exists.
- Accepted non-goal (`spec.md` Non-goals and Rollout & Follow-up): per-feature `model_routing_receipt` and `topology_receipt` checks remain unconditional; the PR states "Partially addresses #543". Not treated as a gap.
- Baseline behaviour (pre-fix): `evidence/regression-testing/fail-before-python.2026-10-10T08-07.md` and `fail-before-typescript.2026-10-10T08-08.md` record the regression test failing with `['Epic planner topology_receipt must be an object.']` on pre-fix code.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Pre-review state |
|---|---|---|
| AC1 | Python `test_ready_gate_skips_planner_topology_receipt_when_key_absent`, fail-before / pass-after evidence | `[x]` |
| AC2 | Python `test_codex_flag_keeps_planner_topology_receipt_unconditional`, parametrized over both flags | `[x]` |
| AC3 | Python `test_ready_gate_validates_present_null_planner_topology_receipt` | `[x]` |
| AC4 | Python present-valid receipt test, no flag and `require_codex_topology=True` | `[x]` |
| AC5 | `test_readiness_requires_epic_preparation_topology_receipts` asserts under a Codex flag; per-feature assertions retained | `[x]` |
| AC6 | TypeScript twins of the four Python tests with byte-identical strings | `[x]` |
| AC7 | MCP service-call test asserts both flags error and key-gated does not | `[x]` |
| AC8 | Both calls conditioned on key membership or Codex flag; no `Epic planner` string literal changed | `[x]` |
| AC9 | Pre-existing present-receipt tests pass without modification | `[x]` |
| AC10 | Excluded paths unchanged | `[x]` |
| AC11 | Seven-stage toolchain single clean pass in both languages, recorded under `evidence/qa-gates/` | `[x]` |
| AC12 | Python coverage run exits 0; `validate_epic_planner_state.py` >= 85% / 75%, no regression | `[x]` |
| AC13 | Jest coverage run exits 0; `epic-planner-state-core.ts` >= 85% / 75%, no regression; both outcomes exercised | `[x]` |
| AC14 | Every named file <= 500 lines, recorded under `evidence/qa-gates/` | `[x]` |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence (reviewer-verified at ab36c108 unless stated) |
|---|---|---|
| AC1 | PASS | Test at `tests/scripts/dev_tools/test_validate_epic_planner_state.py:254-265`; fail-before (exit 1) and pass-after (exit 0) under `evidence/regression-testing/`. Reviewer re-run: passed. |
| AC2 | PASS | Parametrized over both Codex flags; exact-string membership. Reviewer re-run: both cases passed. |
| AC3 | PASS | `topology_receipt = None`, no flag, exact string asserted. Reviewer re-run: passed. |
| AC4 | PASS | `test_ready_gate_accepts_present_valid_planner_topology_receipt[False]` and `[True]`. Reviewer re-run: both passed. |
| AC5 | PASS | Line 222 passes `require_codex_topology=True`; planner and per-feature assertions retained. Reviewer re-run: passed. Non-blocking note CR-2 in the code review. |
| AC6 | PASS | `epic-planner-state-core.test.ts` lines 364-424: four tests (six cases); strings byte-identical to Python. Reviewer re-run: passed. |
| AC7 | PASS | `validate-orchestration-service-call.test.ts` lines 205-211: `routing` and `topology` contain the string; `keyGated` does not. Reviewer re-run: passed. |
| AC8 | PASS | Source read: Python line 348 `if not key_gated or "topology_receipt" in state:`; TypeScript line 444 `if (!requireLaunchPaths \|\| "topology_receipt" in value) {`. `git diff 7bbd0b9b...HEAD` on both production files: no added or removed line contains an `Epic planner` string literal. |
| AC9 | PASS | Named pre-existing tests are unmodified; reviewer targeted runs: pytest 71 passed (4 files), Jest 63 passed (5 suites including `mcp-server-epic-validation.test.ts`). |
| AC10 | PASS | `git diff --stat 7bbd0b9b...HEAD` lists none of the excluded paths (`validate_orchestration_artifacts.py`, `.claude`, `.github`, `.agents`, `.codex`, `extensions/drm-copilot/resources`, `jest.config.cjs`, `mcp-tool-inputs.ts`). |
| AC11 | PASS | `evidence/qa-gates/final-qa-clean-pass.2026-10-10T08-22.md` records a single clean pass; no code change since. Reviewer re-ran format, lint, type-check, and tests in both languages at head: all exit 0. Architecture stage is a presence check (policy audit PA-5). |
| AC12 | PASS | Executor full-suite run exit 0, 6746 passed. Reviewer parse of `artifacts/python/lcov.info` (08:19, after the last Python code commit at 08:11): 167 / 182 = 91.76% lines; 81 / 96 = 84.38% branches; baseline 91.71% / 84.04%. Added lines 348-349 hit; both `BRDA:348` arms taken. |
| AC13 | PASS | Now artifact-verified (previously executor text evidence only). The remediation run `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary` exited 0, 3951 passed (`evidence/qa-gates/typescript-lcov-coverage.2026-10-10T08-42.md`); its `text` row is `98.31 \| 93.8 \| 100 \| 98.31`, satisfying the criterion as written. Reviewer parse of `extensions/drm-copilot/coverage/lcov.info` (08:42:11, after the last TypeScript code commit at 08:14:18), record at lcov line 48368: LF 474 / LH 466 = 98.31% lines; BRF 113 / BRH 106 = 93.81% branches; baseline 98.3% / 93.57%. Both outcomes of the new conditional exercised: `BRDA:444,105,0,38` and `BRDA:444,106,0,42`; `DA:444,46`, `DA:445,42`, `DA:446,42`. |
| AC14 | PASS | Reviewer `awk 'END{print NR}'`: 375, 474, 424, 490, 232; recorded in `evidence/qa-gates/line-counts-final.2026-10-10T08-22.md`. |

## Remediation Verification

| Prior finding | Status | Evidence |
|---|---|---|
| PA-1 (Blocking): TypeScript coverage artifact absent | RESOLVED | `extensions/drm-copilot/coverage/lcov.info` exists (712929 bytes); reviewer-parsed values listed under AC13 match the evidence record exactly; definition of done in `remediation-inputs.2026-10-10T08-29.md` line 26 met (>= 85 / 75, no decrease from 98.3 / 93.57, non-zero hits on added lines). Constraints met: no source, test, `jest.config.cjs`, or `spec.md` change (`git diff --name-status e7612e93..HEAD`). |
| CR-1, CR-2, CR-3, PA-2 to PA-5 (Non-blocking) | Open, carried forward | Optional per the remediation inputs; follow-up candidates. |

## Summary

- 14 of 14 acceptance criteria evaluated PASS; AC13 is now verified against the lcov artifact rather than executor text output alone.
- The issue's Expected Behavior is delivered for the planner-level receipt in both runtimes. The end-to-end outcome for a Claude-prepared checkpoint still depends on the per-feature receipts, an accepted, documented non-goal; the PR must state "Partially addresses #543" without a closing keyword.
- Blocking findings in this artifact: 0. Branch-level blocking findings: 0 (PA-1 resolved). Non-blocking: CR-1 to CR-3; PA-2 to PA-7.
- Overall feature verdict: PASS; ready for PR authoring.

## Acceptance Criteria Check-off

All 14 criteria were already checked `[x]` and each evaluated PASS in this review, so no checkbox was changed. `spec.md` was not modified by the reviewer.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` (`## Acceptance Criteria`)
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: none
