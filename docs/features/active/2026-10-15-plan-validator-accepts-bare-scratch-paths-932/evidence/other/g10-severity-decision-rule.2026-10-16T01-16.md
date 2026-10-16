# G10 Severity Decision Rule (pre-declared) — Issue #932

Timestamp: 2026-10-16T01-16
Task: [P5-T1]

This rule is written and committed before the G10 corpus measurement ([P5-T4]) runs. It records no count.

## Decision rule

G10 ships Blocking if and only if the measured finding count is greater than zero and the recorded false-positive count is zero; otherwise the measurement indicates Warning.

This is the same two-conjunct rule used for G5 through G9 in `.claude/rules/plan-acceptance-gates.md`: the shipped severity is Blocking if and only if the total finding count for the rule is greater than zero **and** the recorded false-positive count for the rule is zero.

## Definitions

- False positive: a flagged logical line that is not a SCRATCH definition, or that defines SCRATCH in the canonical issue-namespaced form.
- True positive: a flagged logical line that defines SCRATCH without an accepted issue namespace.

## Corpus derivation

Every path listed by `git ls-tree -r -z --name-only <MERGE_BASE> -- docs` whose final path component matches the case-sensitive glob `*plan.*.md`, read at `<MERGE_BASE>` with `git show`. This includes `docs/features/active/`, `docs/features/archive/`, and every other `docs/` tree. `<MERGE_BASE>` is the value recorded by [P0-T2] (adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99), or the re-derived `git merge-base origin/main HEAD` value if the branch has been rebased.

## Scope statement

G10 ships Blocking by operator-approved scope for issue #932. A Warning outcome from this rule is recorded as a discrepancy (`SEVERITY-DISCREPANCY:` in the measurement artifact) and is not acted on by changing `G10_SEVERITY` or by narrowing the predicate.
