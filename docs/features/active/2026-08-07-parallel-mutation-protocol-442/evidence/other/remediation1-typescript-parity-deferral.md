# Remediation Cycle 1 — TypeScript Parity Deferral (finding R4 / P3)

Timestamp: 2026-08-09T08-48

Task: [P6-T7]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442

## Potential-Entry Path

`docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md`

**This is the ONLY `docs/features/potential/` entry this cycle creates.** In particular, no entry
was created for the C2 recolor pinned-edge observation, because that gap was **closed in code** in
this cycle rather than deferred (see `<FEATURE>/evidence/other/remediation1-finding-disposition.md`
and the remediation plan's `## Residual Gap Assessment`).

## Deferral Rationale (recorded in the potential entry, summarized here)

The gap: `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` adds three families of
validator errors — mutation-entry field-set completeness, the completeness side of F3's nullability
rule, and the mode-dependent completion invariant — that
`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` does not implement. A
checkpoint whose `add` entry omits `new_state` therefore yields a Python error and zero TypeScript
errors, and no parity test exists to detect it.

The three reasons the deferral is correct:

1. **No AC required a port.** `spec.md` S9 names only the Python helper and the single additive
   Python call site. No acceptance criterion and no base-plan task required an F6 TypeScript port.
2. **F6 has no TypeScript seam of its own.** The only comment-delimited seam in that file is
   explicitly F7's (`BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` at line 307, `END`
   at line 314), which both `.claude/rules/parallel-orchestration.md` § F7 Seam and the base plan's
   Check C forbid F6 from writing inside. A port would have meant contending for F7's seam or
   creating an unsanctioned one during a concurrent wave with F7 (#440) and F8 (#446) live.
3. **The rule file's parity claim is scoped to F3's invariants 1-21**, and plan Constraint 2
   prohibits F6 from modifying any file under `.claude/rules/**`.

Pulling the port into scope would require a further spec amendment, so a recorded deferral is the
correct minimal action.

## Explicit Statement: No TypeScript Task in This Cycle

**This remediation cycle adds no TypeScript task.** No TypeScript port is attempted, no seam is
created, and no file under `extensions/drm-copilot/src/` is modified by this plan.

Command: `git status --porcelain -- extensions/drm-copilot/src/`
EXIT_CODE: 0
Output Summary: **empty output** — no modified and no untracked path under
`extensions/drm-copilot/src/`, confirming the TypeScript source tree is untouched.

Command: `grep -n "mutation\|BEGIN\|END" extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
EXIT_CODE: 0
Output Summary: shows F3's own `validateMutations` dispatch at lines 198-200 and the F7 extension
seam at 307-314, and **no F6 invariant**, confirming the gap as recorded and confirming the seam is
F7's rather than F6's.

Note: the bundle mirror under
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/**` WAS updated by [P5-T4]
through [P5-T6], but that is the `.claude` resource mirror required by the landed contract test, not
TypeScript source. The prohibition above concerns `extensions/drm-copilot/src/` only.
