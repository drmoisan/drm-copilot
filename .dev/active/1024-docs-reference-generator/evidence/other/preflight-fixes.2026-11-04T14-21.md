# Preflight Fixes: Issue 1024 Remediation Cycle 1

Timestamp: 2026-11-04T14-21
Plan: docs/features/active/2026-10-30-docs-reference-generator-1024/remediation-plan.2026-11-04T14-13.md
Preflight outcome: PREFLIGHT: REVISIONS REQUIRED (one substantive defect returned; see below)

## Fixes Applied In Place

1. [P3-T7] | literal-formatting / anchor correction | The delegation commits after each phase, so at [P3-T7] the R1 files are already committed and `git status --porcelain` cannot list them, while the plan file itself is modified (task check-offs) rather than new. `git diff HEAD --stat` "before any commit" therefore observed only the uncommitted Phase 3 state. The task now records `git status --porcelain` together with `git diff --name-only` from the cycle-start commit (the commit that added the plan file, derived with `git log --diff-filter=A`) to `HEAD`, and the requirement-document `--stat` from that same commit; the acceptance accepts "new or modified files under `<FEATURE>/`". The asserted meaning is unchanged: only the three R1 files and feature-folder files change in this cycle, and no requirement document changes.

## Substantive Defect Returned (not fixed in place)

- [P1-T1] / [P3-T3] / [P3-T4] | missing test coverage for designed behavior; unsatisfiable acceptance | The design requires `Test-DocsReferenceCanonicalNumberRejected` to walk `PSCustomObject` property values and non-string `IEnumerable` items, but none of the five planned `It` blocks, and no existing suite (extension fixtures hold strings, `[long]` values, or empty dictionaries only), passes an array or a `PSCustomObject` inside `extensions`. A direct implementation leaves those traversal lines with zero covered instructions, so [P3-T4] cannot pass, and adding the missing tests during execution would break the "exactly these five new `It` names" condition of [P1-T1] and the "[P0-T2] total plus 5" condition of [P3-T3].
