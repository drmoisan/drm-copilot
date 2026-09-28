# Remediation Inputs — cycle 1

- Timestamp: 2026-08-07T20-45
- Feature: 2026-08-07-parallel-schema-validators-444 (issue #444, epic `parallel-orchestration` child F3, wave 1)
- Entry reason: post-review correction of an inaccurate parity claim in a contract document that downstream epic children consume.
- Source audits:
  - `docs/features/active/2026-08-07-parallel-schema-validators-444/policy-audit.2026-08-07T20-36.md`
  - `docs/features/active/2026-08-07-parallel-schema-validators-444/code-review.2026-08-07T20-36.md`
  - `docs/features/active/2026-08-07-parallel-schema-validators-444/feature-audit.2026-08-07T20-36.md`
- Blocking findings at entry: 0. This cycle addresses Advisory findings only.

## Why this cycle is being run despite zero Blocking findings

`.claude/rules/parallel-orchestration.md` is the prose contract that epic children F4 (#443), F5 (#441),
F6 (#442), F7 (#440), and F8 (#446) read when they consume the parallel manifest and checkpoint schemas.
Line 182 currently asserts, without qualification, that the TypeScript port reproduces the Python
invariants "with error strings byte-identical to the Python source". Feature review empirically
disproved that claim in three specific classes by executing both runtimes against the same inputs.
Leaving an overstated claim in a contract document that five downstream features rely on is a
correctness risk that is cheaper to fix now than to discover in wave 2.

## Findings in scope for this cycle

### R1 — Rule file overstates cross-runtime parity (Advisory, in scope)

`.claude/rules/parallel-orchestration.md:182` claims unqualified byte-identity. Feature review
verified 96 of 96 error strings matched across 43 constructed documents, but then found three
divergence classes by deliberate probing beyond that corpus:

1. **Quote selection in `pythonRepr`.** `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts:112-132`
   always single-quotes. Python's `repr` switches to double quotes when the value contains a single
   quote. For `"mode": "it's open"` Python emits `found: "it's open".` and TypeScript emits
   `found: 'it\'s open'.`
2. **Integral floats.** `JSON.parse` erases Python's `int`/`float` distinction, so `issue_num: 10.0`
   produces 2 Python errors and 0 TypeScript errors.
3. **Boolean/integer equality.** `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts:228`
   uses `===`, so a boolean `generation` does not select as current-generation, whereas Python's
   `True == 1` does. The resulting error counts differ.

Required remediation: qualify the claim at line 182 so it states the verified scope (identical error
strings for all JSON-representable values that round-trip through both runtimes' native types) and
names the three known divergence classes with their causes. Do not delete the parity statement; make
it accurate.

### R2 — Plan Notes omit the records-module split (Advisory, in scope)

The plan's "Open Questions / Notes" section records the SA16 file-count divergence but not the
`_parallel_state_records.py` / `parallel-state-records.ts` split, even though both modules are absent
from the plan's named file set. Required remediation: add the split to the plan's Notes with its
500-line-cap justification, matching how the SA16 divergence is recorded.

## Findings explicitly OUT of scope for this cycle

- **Repo-wide `pythonRepr` quote-selection defect.** The same implementation exists privately in
  `epic-planner-state-core.ts:63`, `epic-orchestrator-state-resolution.ts:52`,
  `codex-topology-resolver.ts:87`, and `orchestrator-state-codex-model-routing.ts:133`. Fixing it
  correctly means changing epic validators, which this feature is forbidden to modify. Record it as a
  potential entry for separate scheduling; do not fix it here.
- **Integral-float and boolean-equality divergences themselves.** Changing TypeScript narrowing to
  emulate Python's `int`/`float` distinction and `True == 1` semantics is a behavior change beyond
  this feature's approved plan. This cycle documents them; it does not alter validator behavior.
- **Spec S2 vs. V-O invariants (non-empty identity fields) and spec S5 vs. invariant 17
  (`disposition`).** Both are spec-internal contradictions, not code defects. The code correctly
  follows the numbered invariants and says so. Reconciliation belongs at spec review.
- **F1 blast-radius under-reporting gaps** (`docs/features/potential/2026-08-07-blast-radius-under-reporting-gaps.md`).
  Scheduled against F4 (#443).

## Constraints carried into this cycle

- No production validator behavior may change. This cycle is documentation-only.
- No epic validator (`validate_epic_*`, `_epic_*`, `src/lib/validate/epic-*`) may be modified.
- `.claude/rules/parallel-orchestration.md` has a mandatory byte-identical mirror at
  `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`,
  enforced by `tests/.../test_push_down_claude_resource_contracts.py`. Both copies must be updated.
- Full Python and TypeScript toolchain loops must be re-run and must stay green
  (Python 2835 passed; TypeScript 177 suites / 2363 tests).
