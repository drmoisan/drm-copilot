# Phase 0 Baseline Summary

Timestamp: 2026-09-30T09-40

Plan task: [P0-T15]

Output Summary: 12 of 13 rows are GREEN. One row, [P0-T14], is NOT GREEN: the plan's planning-time digest literal no longer matches, because upstream commit 8ae639e3 (#690) re-pinned the skill digest and arrived through the origin/main merge. B_TS is `none`. Per the [P0-T15] acceptance, execution stops before Phase 1 and this row is a plan-revision input.

| Task | Artifact | Status |
|---|---|---|
| [P0-T2] | `evidence/baseline/minor-audit-preconditions.md` | GREEN |
| [P0-T3] | `evidence/baseline/p0-base-ref.md` | GREEN |
| [P0-T4] | `evidence/baseline/p0-line-counts.md` | GREEN |
| [P0-T5] | `evidence/baseline/p0-npm-ci.md` | GREEN |
| [P0-T6] | `evidence/baseline/p0-python-black.md` | GREEN |
| [P0-T7] | `evidence/baseline/p0-python-ruff.md` | GREEN |
| [P0-T8] | `evidence/baseline/p0-python-pyright.md` | GREEN |
| [P0-T9] | `evidence/baseline/p0-python-coverage.md` | GREEN |
| [P0-T10] | `evidence/baseline/p0-typescript-prettier.md` | GREEN |
| [P0-T11] | `evidence/baseline/p0-typescript-lint.md` | GREEN |
| [P0-T12] | `evidence/baseline/p0-typescript-typecheck.md` | GREEN |
| [P0-T13] | `evidence/baseline/p0-typescript-coverage.md` | GREEN |
| [P0-T14] | `evidence/baseline/p0-frozen-surface-pin.md` | NOT GREEN - sha256 of `.claude/skills/epic-orchestrate/SKILL.md` is `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8`, not the planning-time `620183f57a337dedf6158d61264b2257d012762454a9af0b3b6f059ff79ab00b`; the current pin at `parallel_orchestrator_surface_expectations.py` line 150 equals the observed digest and the test passes (36 passed); the change came from upstream commit 8ae639e3 (#690) |

## Baseline headline values

- BASELINE_PY_VALIDATOR_LINE_PCT: 96.64 (LH 144 / LF 149); BASELINE_PY_VALIDATOR_BRANCH_PCT: 93.06 (BRH 67 / BRF 72); terminal Cover 95%; 67 passed.
- BASELINE_TS_CORE_LINE_PCT: 97.79; BASELINE_TS_CORE_BRANCH_PCT: 89.87; full suite 3315 of 3315 tests passed across 236 suites.
- B_TS: none.

## Planning-time literal discrepancies (all introduced by the origin/main merge 09750b68)

1. `.claude/skills/epic-orchestrate/SKILL.md` and its bundled mirror: 325 lines (planning time 323). The Layer 2 bullet that plan section 4 cites at lines 241-245 now occupies lines 243-247, and its text is unchanged. Informational only; [P0-T4] is GREEN.
2. Skill digest pin: now `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8`, which affects [P0-T14], plan section 1 "Frozen digest pin", and [P1-T15]. This is the NOT GREEN row.

## Plan-revision input

Replace the digest literal `620183f57a337dedf6158d61264b2257d012762454a9af0b3b6f059ff79ab00b` with `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8` wherever the plan treats it as the current pin. A search of the plan for `620183f5` finds it only in section 1 "Frozen digest pin" (plan line 46), [P0-T14] (plan line 147), and [P1-T15] (plan line 166); no Phase 2 task names it. Update the SKILL.md Layer 2 bullet location in section 4 (plan line 114) from lines 241-245 to lines 243-247. Then re-run [P0-T14] and [P0-T15].

## Result

NOT GREEN (one row). Execution stops before Phase 1.
