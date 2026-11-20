# Potential: Parallel F6 mutation-protocol invariants absent from the TypeScript parity port

- **Recorded:** 2026-08-09
- **Source:** remediation cycle 1 of issue #442 (`parallel-mutation-protocol`, epic
  `parallel-orchestration` child F6, wave 4), finding R4 / policy-audit finding P3
- **Status:** Deferred, recorded. No TypeScript port is attempted on the F6 branch.

## The Gap

`scripts/dev_tools/_parallel_orchestrator_state_mutations.py` (F6-owned) adds three families of
validator errors that the TypeScript parity core
`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` does **not**
implement:

1. mutation-entry field-set completeness — every one of F3's seven `mutations[]` fields must be
   PRESENT, and no eighth field may be invented;
2. the COMPLETENESS side of F3's nullability rule — a field that F3's rule leaves non-null must in
   fact carry a value;
3. the mode-dependent completion invariant of spec FR7, in its two-signal formalization.

**Concrete divergence:** a checkpoint whose `add` entry omits `new_state` yields a Python error and
**zero** TypeScript errors. F3 reads every field through `dict.get`, so an omitted field is
indistinguishable there from an explicit null; the Python helper is what catches it, and the
TypeScript core does not.

**Nothing detects the divergence.** `grep -rln "parity" extensions/drm-copilot/src --include=*.test.ts`
returns nothing, so no automated parity test exists.

Verified at recording time: `grep -n "mutation\|BEGIN\|END" extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
shows F3's own `validateMutations` dispatch at lines 198-200 and the F7 extension seam at lines
307-314, and **no F6 invariant**.

## Why the Deferral Was Correct

Three independent reasons, each verified rather than asserted:

1. **No acceptance criterion required a port.** `spec.md` S9 names only the Python helper
   (`scripts/dev_tools/_parallel_orchestrator_state_mutations.py`) and the single additive Python
   call site in the F3-owned validator. Neither S9 nor any other AC, and no task in the base atomic
   plan, required an F6 TypeScript port.
2. **F6 had no designated TypeScript seam of its own.** The only comment-delimited seam in
   `parallel-orchestrator-state-core.ts` is explicitly F7's, marked
   `BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` at line 307 and `END ...` at line
   314. Both `.claude/rules/parallel-orchestration.md` § F7 Seam and the base plan's confinement
   Check C forbid F6 from writing inside it. A port would therefore have required either contending
   for F7's seam or creating an unsanctioned one **during a concurrent wave** in which F7 (#440) and
   F8 (#446) are executing against the same integration branch.
3. **The rule file's parity claim is scoped to F3's invariants, and F6 may not amend it.**
   `.claude/rules/parallel-orchestration.md` § Enforcement scopes its verified parity statement
   ("96 of 96 error strings matched across 43 constructed documents") to the F3 invariants it
   enumerates, **1 through 21**. F6's FR9 invariants are additive to that set and outside the
   claim's stated scope. Amending that rule file is prohibited to this feature (plan Constraint 2:
   no file under `.claude/rules/**` is modified).

Pulling the port into scope would be a scope addition requiring a further spec amendment, so the
correct minimal action is this recorded deferral.

## Scope Note for a Future Reader

The parity statement in `.claude/rules/parallel-orchestration.md` § Enforcement should be read as
scoped to **F3's invariants 1-21**. It does not assert parity for the F6 mutation-protocol
invariants, and after this feature it is no longer true that the two runtimes emit the same error
set for every checkpoint: they diverge exactly on the three families above.

## Suggested Follow-Up (not performed here)

- Port the three F6 invariant families into
  `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`, using a seam of
  F6's own rather than F7's.
- Add a parity test that constructs a checkpoint per invariant family and asserts the Python and
  TypeScript error lists match, which is the control whose absence let this gap open.
- Amend the `§ Enforcement` parity statement to name the invariant range it actually covers.

**No file under `extensions/drm-copilot/src/` is modified by the F6 branch.** Verified:
`git status --porcelain -- extensions/drm-copilot/src/` reports no modified or untracked path.
