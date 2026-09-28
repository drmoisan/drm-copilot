# Phase 0 — Requirement and Finding Sources Read (remediation cycle 2)

Timestamp: 2026-08-28T01-27
Task: [P0-T2]
Command: Read tool applied to `spec.md`, `remediation-inputs.2026-08-28T00-30.md`, and
`policy-audit.2026-08-28T00-30.md`, all under
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/`
EXIT_CODE: 0

Work Mode: full-bug

## Acceptance-criteria source

`docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` is the **sole**
acceptance-criteria source for this feature. Work mode `full-bug` resolves to `spec.md` only;
`user-story.md` is absent by default and is not required. `issue.md` is not an acceptance-criteria
source under this mode.

## Acceptance-criterion counts in `spec.md`

- Checked acceptance criteria: **35**
- Unchecked acceptance criteria: **0**

Counted with `grep -c '^- \[x\]' spec.md` and `grep -c '^- \[ \]' spec.md` against the worktree copy
of `spec.md` (1031 lines). The `## Acceptance Criteria` section begins at line 900.

## Blocking findings for this cycle

Exactly one Blocking finding is recorded in `remediation-inputs.2026-08-28T00-30.md`.

### B5 — the Codex twin of B2 is open, and three artifacts state a false fact about it

**Component 1 — a two-line coverage gap.** Lines 197 and 206 of
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` are uncovered and belong to no named
exception.

| Line | Text | Role in `Test-PreparationModeDelegation` |
| --- | --- | --- |
| 197 | `return $false` | the non-`orchestrator` subagent-type branch |
| 206 | `return $true` | the all-conjuncts-hold return |

Both were covered at the merge base `1e991b86` through merge-base line 213 inside
`Test-ImplementationDelegation`. This branch removed that call site, orphaning
`Test-PreparationModeDelegation` on both surfaces. Remediation `R5` is test-only: add two `It`
cases calling the predicate directly from
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`.

**Component 2 — three propagated statements of a false fact.** Three locations assert that Codex
lines 197 and 206 were uncovered at the merge base. They were covered.

1. `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md`, lines 100-102.
2. `policy-audit.2026-08-27T22-47.md`, line 173 and the derived-baseline figure at line 181 (the
   origin of the error; the cycle-2 policy audit already states the correction).
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`,
   the comment block at line 82.

`evidence/qa-gates/coverage-delta.2026-08-27T22-47.md` is **retained unaltered**: its statement that
zero uncovered *added* lines are unattributed is true as worded. The defect there was the omission
of the two uncovered *pre-existing* lines, supplied by the re-issue at
`evidence/qa-gates/coverage-delta.2026-08-28T00-30.md`.

Cycle-1 findings B1, B2, B3, and B4 are all closed and require no further work.

## Do-not-change constraints recorded by the finding source

- No production `.ps1` file, self-hosted or mirrored, may change. All eight hash-compare UNCHANGED.
- The four `-helpers.ps1` copies stay byte-untouched.
- The six pre-existing test suites stay unmodified.
- No acceptance-criterion text or checkbox in `spec.md` may change.
- The `## DECLARED BLAST RADIUS` section is complete; statement `(e)` forward-declares later cycles'
  root-level artifacts.
- `[P6-T6]` in `plan.2026-08-26T08-40.md` stays unchecked.
- Codex lines 426-443 are the accepted issue #555 shipping exception and must not be covered.

## Mirror-pair reference hashes carried forward from `policy-audit.2026-08-28T00-30.md`

| Pair | SHA-256 |
| --- | --- |
| Claude gate hook | `0c8c55ce222ee9241b061a2964d5a0bb7154eb57f2b91a9d0f049b4da82b863e` |
| Claude modes sibling | `0ffab72ef27b3ae38f60a38dc1ba60a5f974fac91a4fa7d28f5094a790b455a4` |
| Codex gate hook | `b978bad8b304b2917afbe524f0043f5018ff0f06c7719a27550c6e888a3b706d` |
| Codex modes sibling | `8e1165818ae0ae20b63486d2aa51d98a7875fea9ba7d2f15e0762df850aa4f0a` |

Output Summary: Work Mode is `full-bug`; `spec.md` is the sole acceptance-criteria source and carries
35 checked criteria and 0 unchecked. B5 is the single Blocking finding, with a two-line coverage
component and a three-location false-fact component. EXIT_CODE 0.
