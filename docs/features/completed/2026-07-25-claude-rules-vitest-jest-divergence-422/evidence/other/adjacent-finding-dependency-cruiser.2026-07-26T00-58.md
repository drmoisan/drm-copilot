# Adjacent Finding (Report-Only, NOT Fixed) — Missing `.dependency-cruiser.cjs` (Issue #422)

Timestamp: 2026-07-26T00-58

Status: RECORDED FOR SEPARATE FILING. Not fixed in this feature.

## Finding

`.claude/rules/typescript.md` line 57, in the `## Architecture Boundaries` section, reads:

> Layer rules and the No-COM architecture assertions are defined in `.claude/rules/architecture-boundaries.md`. The TypeScript enforcement tool is `dependency-cruiser` with configuration file `.dependency-cruiser.cjs`.

The named configuration file `.dependency-cruiser.cjs` does not exist anywhere in the repository.

Verification:
```
find . -name ".dependency-cruiser*" -not -path "./node_modules/*"
```
Result: no matches.

The same filename also appears in the permitted coverage-exclude list at `.claude/rules/general-unit-test.md` line 40 (and its mirror `.agents/skills/general-unit-test/SKILL.md` line 45), which is a second instance of the same stale reference. Those lines were edited in `[P2-T2]` and `[P2-T5]` only to replace `vitest.config.ts` with `jest.config.cjs`; the `.dependency-cruiser.cjs` token on those lines was deliberately left untouched.

## Why it was not fixed here

This is a separate accuracy defect. It is unrelated to the Vitest/Jest framework divergence that issue #422 addresses: it concerns a missing architecture-boundary tool configuration, not the unit-test framework or its commands. `spec.md` records it as an explicit out-of-scope observation, and the plan's hard constraint 5 forbids fixing it in this feature. Folding it in would expand the change beyond the adjudicated scope.

## Proof that no edit was made to the line-57 content

```
git diff --stat .claude/rules/typescript.md
```
Result: `1 file changed, 5 insertions(+), 5 deletions(-)` — exactly the five paired line replacements applied by `[P2-T1]` (lines 16, 42, 47, 51, 73). Line 57 is not among them; its text is unchanged from the pre-fix tree.

## Recommended follow-up (for the separate issue)

Determine whether `dependency-cruiser` is actually part of this repository's toolchain. Either add the missing `.dependency-cruiser.cjs` configuration and the corresponding dependency, or correct the instruction text to describe the architecture-boundary enforcement mechanism the repository actually uses. `spec.md` `## Rollout & Follow-up` already lists this as a post-fix clean-up task.

## Related, also out of scope

`spec.md` records a planner-optional follow-up from research: `README.md` lines 303 and 318 describe the TypeScript toolchain as Vitest. `README.md` is not in this feature's owned file set and was not edited.
