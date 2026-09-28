# Constraint 9 Verification as Amended by the Epic-Manifest Adjudication ([P8-T4])

Timestamp: 2026-08-08T14-41

This task has deliberately mixed polarity. It asserts that the surfaces which
remain F3-owned are ABSENT from the change set, and that the two adjudicated F4
additions are PRESENT. The presence of those two paths is the required outcome,
not a violation.

## Merge Base

Command: `git merge-base origin/epic/parallel-orchestration-integration HEAD`

EXIT_CODE: 0

Resolved `<BASE>`: `b086cf6958ee4b628f60309cda80aac772304bc8`

## Change-Set Commands

Command: `git diff --name-only b086cf6958ee4b628f60309cda80aac772304bc8`

EXIT_CODE: 0

Output Summary: 36 paths (committed changes on the feature branch relative to
the merge base).

Command: `git status --porcelain --untracked-files=all`

EXIT_CODE: 0

Output Summary: 8 entries — 2 modified tracked paths and 6 untracked paths
(covering staged, unstaged, and untracked working-tree state).

## Union Change Set

The change set is the union of the two command outputs above (42 unique paths),
covering committed, staged, unstaged, and untracked paths. The full enumerated
list is recorded in
`docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/non-modification-atomic-plan-contract.2026-08-08T14-41.md`
and is identical for this task; it is not duplicated here.

## Assert ABSENT — Surfaces That Remain F3-Owned

| Pattern or path | Present in union? |
| --- | --- |
| `scripts/dev_tools/validate_parallel_*` (any) | No |
| `scripts/dev_tools/_parallel_state_*` (any) | No |
| `scripts/dev_tools/parallel_manifest_contract.py` | No |
| `.claude/rules/parallel-orchestration.md` | No |
| `config/orchestration-routing.json` | No |

A regular-expression search of the union for all five patterns returned no
match.

**No remaining-F3-owned path appears in the union change set.** F4 consumed the
F3 schemas, validators, rules prose, and route entry without defining or
altering any of them.

### Near-miss paths disambiguated

Two union paths resemble the absent patterns but match none of them, and are
recorded here so a later reader does not misread the table:

- `scripts/dev_tools/_parallel_kickoff_tables.py` — an F4-owned `_`-prefixed
  helper module extracted from the F4 kickoff-contract module under the
  500-line limit. It matches `_parallel_kickoff_*`, not the F3-owned
  `_parallel_state_*` pattern.
- `scripts/dev_tools/validate_orchestration_artifacts.py` — the shared CLI
  registration surface (see the note below). It matches
  `validate_orchestration_*`, not the F3-owned `validate_parallel_*` pattern.

## Assert PRESENT — The Two Adjudicated F4 Additions

| Path | Present in union? | Union line |
| --- | --- | --- |
| `scripts/dev_tools/parallel_kickoff_contract.py` | Yes | 35 |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | Yes | 26 |

**Both adjudicated F4 paths DO appear in the union change set, as required by
design.**

### Citation 1 — epic manifest

`docs/features/epics/parallel-orchestration/epic.md`, section "Planner
Adjudication: the kickoff-contract boundary (F3 / F4)", records the verdict
"Adjudication: F4 owns it", assigning the kickoff-contract module and the
`parallel-kickoff` artifact type to F4 by producer ownership.

### Citation 2 — F3's landed rules file

`.claude/rules/parallel-orchestration.md`, section "F3 Scope Boundary — kickoff
contract deferred to F4", records the same boundary from F3's side: "F3
deliberately excludes the kickoff-prompt contract module
`scripts/dev_tools/parallel_kickoff_contract.py` and the `parallel-kickoff`
`artifact_type`. Both are F4's scope."

### Supersession of the prior v1.0 assertion

Plan revision v1.0 asserted these two paths were ABSENT. That assertion was
superseded when the spec R5 kickoff-validation contingency fired: F3 landed
WITHOUT `parallel_kickoff_contract.py` and WITHOUT the `parallel-kickoff`
wiring, which is the adjudicated and expected outcome. The contingency verdict
is recorded in
`docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/upstream-reconciliation.2026-08-08T13-56.md`
([P1-T3] verdict: `fired`). Under the revised plan the presence of both paths is
the required outcome and their absence would be the defect.

## Shared Registration Surfaces (not F3-owned)

The following four paths appear in the union. They are shared registration
surfaces that received the adjudicated additive `parallel-kickoff` wiring. They
are not F3-owned surfaces, and their presence is neither a violation nor an
adjudicated-addition assertion:

1. `scripts/dev_tools/validate_orchestration_artifacts.py` — Python CLI
   subparser tuple and dispatch branch.
2. `extensions/drm-copilot/src/mcp-tool-definitions.ts` — `artifact_type` enum.
3. `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` —
   `artifact_type` enum.
4. `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` —
   TypeScript dispatch case.

Each edit is a single distinct named addition made under the epic wave-4
confinement discipline, with no reflow, reordering, or reformatting of existing
entries.

## Verdict

- Remaining-F3-owned surfaces absent: PASS.
- Both adjudicated F4 additions present: PASS.

VERDICT: PASS — constraint 9, as amended by the epic-manifest adjudication, is
satisfied.
