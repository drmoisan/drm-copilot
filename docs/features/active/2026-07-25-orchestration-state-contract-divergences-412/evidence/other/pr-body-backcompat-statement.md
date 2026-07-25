# PR-body backward-compatibility statement — Divergence 2 (Issue #412)

Task: [P6-T16]

Timestamp: 2026-07-25T19-00

Purpose: this text is ready for verbatim inclusion in the PR body by `Agent(pr-author)`. It
satisfies spec.md §Backward-compatibility expectations and the spec acceptance criterion "The PR
body records the divergence-2 backward-compatibility statement".

---

## Backward compatibility — complexity-floor formula change (divergence 2)

`compute_complexity_floor` (Python) and `Get-ComplexityFloor` (PowerShell) previously returned
`C3` for any non-empty `signals_present` list. They now return `C3` only when the list intersects
the floor-signal set `{classifier_or_model_logic, auth_or_token_handling,
concurrency_or_ordering, cross_module_contract_change}` — the four names flagged `"floor": true`
in `config/orchestration-routing.json` — and `C1` otherwise. Unknown and `"floor": false` signal
names contribute no floor candidate. The change is accepted with **no grace or
legacy-acceptance rule**, because such a rule would permanently weaken invariant 3 of
`.claude/rules/orchestrator-state.md` and would be indistinguishable from the defect it excuses.

**Stored assessments invalidated: zero.**

- Committed JSON files carrying `complexity_assessments`: **0**. Verified with
  `git grep -l "complexity_assessments" -- "*.json"` from the repository root, which returned no
  matches (exit 1).
- The single runtime checkpoint that carries `complexity_assessments` is
  `artifacts/orchestration/orchestrator-state.json`, which is untracked (verified with
  `git ls-files --error-unmatch`). All four of its entries — phases `S3a_research`,
  `S3b_feature_documents`, `S4_atomic_planning`, and `S5_atomic_execution` — record
  `signals_present: ["cross_module_contract_change"]`, a `"floor": true` signal, and each records
  `floor: "C3"`. The recomputed floor for every entry is `C3` both before and after this change,
  so no stored entry's recomputed floor changes and no stored entry becomes invalid.
- Test fixtures asserting the previous any-non-empty behavior: **0**. Existing Python and Pester
  floor tests derive their inputs exclusively from `"floor": true` catalog names and remain green;
  all new cases are additive.

**Repair path for pre-change checkpoints outside this repository.** A checkpoint written before
this change whose assessment recorded only non-floor signals necessarily recorded `floor: "C3"`.
Post-change it fails validation with a floor-mismatch error naming the recomputed value `C1`. It
is repaired by re-recording the affected `complexity_assessments[]` entry through the documented
resume reconciliation in `.claude/skills/orchestrate/SKILL.md`, which recomputes the floor and
rewrites the entry. No data migration, feature flag, or tooling change is required; rollback is a
plain revert of the change.

**Divergence 1 compatibility.** Divergence 1 is purely widening in plain validation mode:
previously invalid values become valid and no previously valid value becomes invalid. The
completion-gate extension newly rejects `failed_remediation_required`, `blocked_ci_loop_limit`,
and `blocked_remediation_loop_limit`, but no stored checkpoint can carry those values because
they were unwritable before this fix.

---

## Verification commands used to produce the counts above

| Command | Result |
|---|---|
| `git grep -l "complexity_assessments" -- "*.json"` | no matches (exit 1) — zero committed JSON files |
| `grep -rln "complexity_assessments" --include=*.json .` | `./artifacts/orchestration/orchestrator-state.json` only |
| `git ls-files --error-unmatch artifacts/orchestration/orchestrator-state.json` | exit 1 — file is untracked |
| inspection of `artifacts/orchestration/orchestrator-state.json` lines 178–218 | 4 entries, each `signals_present: ["cross_module_contract_change"]`, each `floor: "C3"` |
