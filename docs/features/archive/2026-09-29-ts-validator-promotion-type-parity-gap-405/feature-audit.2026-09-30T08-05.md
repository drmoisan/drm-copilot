# Feature Audit: issue #405

- Timestamp: 2026-09-30T08-05
- Work mode: full-bug; AC source `spec.md` (16 items); `issue.md` `## Acceptance Criteria` (5 items) tracked as secondary
- Baseline: `cbb53d7a` (P0-T3 base for scope; drift verified in `qa-gates/diff-scope.2026-09-30T07-57.md`)
- Overall verdict: PASS (16/16 spec, 5/5 issue)

## Scope and Baseline

- Work mode: full-bug; AC source `spec.md` (16 items); `issue.md` `## Acceptance Criteria` (5 items) tracked as secondary.
- Baseline: `cbb53d7a`; scope is the full branch diff against it.

## Acceptance Criteria Inventory

- `spec.md`: 16 criteria (evaluated below, numbered 1-16).
- `issue.md`: 5 criteria (evaluated in the issue.md subsection).
- Total: 21 criteria.

## Acceptance Criteria Evaluation

### spec.md acceptance criteria

| # | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|
| 1 | Bug `large` checkpoint yields no TS routing error | PASS | corpus case `bug-large-bug-tool-declared-and-recorded` passes in TS after fix; expect-fail run failed before (`ts-parity-expect-fail`), passes after (`ts-regression-pass-after`). |
| 2 | TS tests mirror four PR #402 tests | PASS | `orchestrator-state-routing.promotion-type.test.ts` (177 lines), real matrix. |
| 3 | Shared parity test, Python vs TS identical | PASS | Same 12 fixtures asserted by Python, TS, and Pester readers; all pass. |
| 4 | Pure `resolvePromotionEntryTools` with exact-match semantics | PASS | Source read; strict equality, hyphenated key, new array. |
| 5 | Resolved list computed once, used for equality and receipt loop | PASS | Diff of `routing.ts` (single `requiredMcpTools` definition). |
| 6 | Resolver unit tests cover listed inputs | PASS | `orchestrator-state-promotion-tools.test.ts`, 194 lines; `ts-resolver-unit-tests` evidence. |
| 7 | Corpus at `tests/fixtures/orchestrator_state_promotion_type/*.json` with required cases | PASS | 12 files, shape guarded by readers; covers bug/feature/only-feature-tool/absent/"Bug"/" bug"/non-string/small/preparation/remediation/epic (+ null). |
| 8 | Python reader with size guard | PASS | `test_orchestrator_state_promotion_type_parity.py`, 15 pass. |
| 9 | TS reader, real matrix, size guard | PASS | Reviewed in full (`MINIMUM_CORPUS_COUNT = 12`). |
| 10 | Pester reader with size guard | PASS | 15 tests, 0 failures. |
| 11 | TS tests use real matrix | PASS | Parity reader loads `config/orchestration-routing.json`. |
| 12 | Per-file jest threshold 85/75 passes | PASS | `jest.config.cjs` diff; lcov 51/51 lines, 7/7 branches. |
| 13 | Existing checkpoints validate identically | PASS | `ts-validate-dir-pass-after` evidence plus eight non-substituting corpus cases; Jest 3357 pass. |
| 14 | No file over 500 lines | PASS | Max 455. |
| 15 | No production change to PS/Python/mirror; no #343/#509/#769/hook work | PASS | `git diff --name-status` shows only the listed TS files and tests. |
| 16 | Full toolchain with coverage >= 85/75 | PASS | Format/lint/typecheck/coverage evidence; TS 97.03/91.19, Py 93.4/86.3, PS 96.25 line. Only pre-existing Pester failures (accepted). |

### issue.md acceptance criteria

All five are checked in `issue.md` and are supported by the same evidence: resolution mirrors Python (1); bug `large` passes (2); feature `large` still requires `new_potential_entry`, verified by corpus case `feature-large-feature-tool-declared-and-recorded` and no-regression tests (3); new TS tests cover both plus dead-skill-name and only-feature-tool rejection (4); toolchain passes with no coverage regression (5).

## Acceptance Criteria Check-off

No new check-offs required; all items were already `[x]` in `spec.md` and `issue.md`, and this review found no item that should be unchecked.

## Summary

Overall verdict: PASS (16/16 spec, 5/5 issue).

### Acceptance Criteria Status
- Source: `spec.md`, `issue.md`
- Total AC items: 21 (16 + 5)
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: none

## Open items (non-blocking)

- Issue #405 body was not retrievable during execution; the criteria were taken from `issue.md`. Reconfirm when `gh` is available.
- Two pre-existing Pester failures remain (accepted baseline).
- Property-test substitution (fixed grid) noted in the policy audit.
