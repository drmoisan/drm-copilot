# Pre-Declared Severity Decision Rule — [P6-T1]

Timestamp: 2026-08-26T13-23
Task: [P6-T1]

## Status of this artifact

**This artifact was written before any corpus count was taken.** It is written first precisely so that the severity of each new rule is fixed by a rule declared in ignorance of the outcome, and is not chosen afterwards to produce a preferred result.

**This artifact contains no count.** The only numeral appearing below is the threshold that the decision rule itself names. No measured value, no corpus size, no candidate tally, and no finding tally appears anywhere in this document. Those are recorded in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md` by [P6-T3], and the rule below is applied to them mechanically by [P6-T5].

Severity is measured, never chosen. A rule is not promoted to the blocking channel because promotion would read as a stronger result, and it is not demoted to the warning channel because demotion would let a gate pass. The rule below is the whole of the decision procedure.

## The decision rule, stated per rule

### G7 — write-mode command with no observation marker

The shipped severity of G7 is **the blocking channel if and only if both of the following hold**:

1. the total G7 finding count over the measured corpus is greater than zero, **and**
2. the recorded G7 false-positive count over that same measurement is zero.

**Otherwise the shipped severity of G7 is the warning channel.**

### G8 — unanchored `git diff`

The shipped severity of G8 is **the blocking channel if and only if both of the following hold**:

1. the total G8 finding count over the measured corpus is greater than zero, **and**
2. the recorded G8 false-positive count over that same measurement is zero.

**Otherwise the shipped severity of G8 is the warning channel.**

### G8b — name-listing diff with no companion span

**The shipped severity of G8b is the warning channel, unconditionally.**

G8b is exempt from the two-condition rule above and cannot reach the blocking channel by any measured outcome. The reason is that it carries the highest false-positive surface of the set. Its predicate reports a name-listing diff whose attributed task text carries neither a staging span nor a porcelain-status span, and a plan may legitimately observe a created path by a mechanism the predicate does not enumerate — an explicit filesystem read, a test that asserts the path exists, or an artifact requirement stated in prose. The two companion spans G8b recognises are the two common forms, not the exhaustive set, so a well-formed plan can be reported.

This exemption is declared here, in advance of measurement, and is not contingent on what the measurement shows. A measurement that happens to record no G8b false positive does not license promoting it, because a false-positive count taken over one corpus does not bound the false-positive surface of the predicate.

### G9 — coverage command with no terminal reporter

The shipped severity of G9 is **the blocking channel if and only if both of the following hold**:

1. the total G9 finding count over the measured corpus is greater than zero, **and**
2. the recorded G9 false-positive count over that same measurement is zero.

**Otherwise the shipped severity of G9 is the warning channel.**

## Vacuity

The first conjunct of the two-condition rule exists to reject a vacuous measurement. A false-positive count of zero taken over a finding count of zero measures nothing at all: no finding was examined, so no finding was found not to be a false positive. Under the rule as stated, a rule whose total finding count is zero fails the first conjunct and therefore takes the warning channel, whatever its false-positive count reads.

This is the same discipline that fixed the shipped severity of G5, whose corpus measurement produced a total finding count of zero and which ships as a warning on that basis. The precedent is followed here rather than re-argued.

[P6-T4] additionally requires that a rule whose measured finding count is zero carries an explicit invalid-measurement declaration together with four driver-integrity checks — non-vacuous candidate enumeration, a working repository seam, a self-hit on every sampled lookup, and predicate-order equivalence with the shipped rule. Those checks establish that a zero count is a property of the corpus rather than a defect in the driver. They do not change the channel the rule above assigns; a zero finding count takes the warning channel either way.

## What counts as a false positive

A finding is a false positive when the acceptance condition it reports is in fact falsifiable — that is, when the plan states an observation sufficient to distinguish a passing run from a failing one, by a mechanism the rule's predicate does not recognise. A finding is a true positive when the acceptance condition it reports genuinely cannot fail, or can only be satisfied vacuously.

The classification is made against the plan text as written, not against what the plan author may have intended. Every false positive is named in the measurement artifact by plan path and offending span, so the classification is auditable rather than asserted.

## Application

[P6-T5] applies the rule above to the counts [P6-T3] records, mechanically and per rule, and sets `G7_SEVERITY`, `G8_SEVERITY`, `G8B_SEVERITY`, and `G9_SEVERITY` in both `scripts/dev_tools/plan_gate_observability.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` to the resulting values. No constant is set by any other means, and no rule carries the blocking channel unless its measurement was non-vacuous and its recorded false-positive count is zero.
