# P6-T18 — Known Residual: epic-owner action

Timestamp: 2026-08-30T20-45

Manifest: `docs/features/epics/claude-runtime-portability/epic.md`

## The two indicators

**Manifest line 14** — the broad leading indicator:

> Of the five infrastructure-class executable Python invocation sites under .claude/**, the three
> in scope (epic-orchestrate/SKILL.md, parallel-orchestrate/SKILL.md validator,
> parallel-plan/SKILL.md lane assertion) no longer require an interpreter. Two remain by explicit
> design and are named non-goals: the drift-detection CLI and the mutation-abandon CLI, both of
> which are gate-coupled and cannot be replaced without co-designing their hooks. This indicator
> was narrowed on 2026-08-29; its earlier absolute form would not have held on delivery.

**Manifest line 15** — the narrow leading indicator:

> The lane-assertion diagnostic runs to completion on a destination runtime with no Python
> interpreter present.

## Disposition

**Line 15 is fully satisfied after this feature lands.** Its evidence is the payload-only case
added in P4-T8, which exercises the diagnostic from the bundled payload tree with no repository
checkout and no interpreter on the path.

**Line 14 is not fully satisfied after this feature lands**, because non-goals 1 and 2 remain by
deliberate decision. The drift-detection CLI and the mutation-abandon CLI are both gate-coupled:
each is invoked by a hook that consumes its exit status and its stdout shape, so neither can be
replaced without co-designing the hook alongside it. That co-design was scoped out of this
feature at planning time and is not attempted here.

## Corrective action

The corrective action is **a manifest rewording owned by the epic owner**. Line 14 states its own
scope narrowing in its final sentence, but its leading clause still reads as a claim about all
five sites; the rewording should make the three-of-five scope the subject of the sentence rather
than a qualification appended to it.

**No implementation change is made here.** This artifact records the residual and assigns it;
it does not resolve it. Nothing in this feature's diff touches either non-goal CLI or either of
their hooks, which `evidence/qa-gates/non-goals-untouched.2026-08-30T20-45.md` verifies against
both the committed diff and the working tree.
