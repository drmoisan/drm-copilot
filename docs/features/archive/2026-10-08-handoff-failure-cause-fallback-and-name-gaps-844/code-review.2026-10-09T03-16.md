# Code Review: Handoff Failure-Cause Fallback and Name Gaps (Issue #844)

- Branch: `bug/handoff-failure-cause-fallback-and-name-gaps-844` at `b27a9f8c552a9c8fcdc61c78a2279ff027558cc9`
- Base: `origin/main` at `e7d3779b398604af919678c16c877c8539a86cc0`
- Scope: full branch diff (`git diff origin/main...HEAD`); TypeScript under `extensions/drm-copilot/` plus Markdown
- Review timestamp: 2026-10-09T03-16 (host clock)

## Executive Summary

The change adds a stage-prefixed `failureCause` to three catch sites that previously returned or fed a blocked handoff result without one, and restricts the `error.name` token in `describeHandoffFailureCause` to ASCII identifiers. It also splits a 500-line test file into a support module and two test files.

The production change is small (4 files, about 60 added lines), additive, and does not alter any failure code, status, or path field. The shared helper `describeEnvelopeParseFailure` removes a duplicated ternary from two call sites and makes the non-contract-error arm directly testable without module mocks. The regression-first evidence shows the new cases failing before the fix and passing after it. Lint, typecheck, Prettier, and focused tests were re-run by this reviewer and pass.

Findings: 0 Blocking, 5 Non-blocking. Total blocking count: **0**.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Non-blocking | `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts` | F6, `lifecycle: undefined as unknown as HandoffEnvelope["lifecycle"]` | Double type assertion with no justification comment. It is the only `as unknown as` in the handoff test files. | Add a one-line comment stating that the cast removes `lifecycle` to force a `TypeError` without a `code` inside projection. | `.claude/rules/typescript.md` line 23: avoid type assertions unless justified. The intent is inferable from the test title, so the impact is limited to readability. | `grep -rn "as unknown as" test/lib/validate/` returns one handoff match |
| Non-blocking | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` | lines 189-201 (validation-failure branch) | `validation.failureCause` is forwarded whenever the branch is taken, including the case where `primaryFailureCode` is non-null and an envelope was parsed. The production validator sets `failureCause` only in its catch, so no current path produces a misattributed cause. A future validator that sets a cause on a non-error result would also surface it. | No change required. If the validator contract grows, document in `HandoffEnvelopeValidationResult` that `failureCause` is set only after a caught error. | The interface field has no TSDoc stating when it is populated. | `orchestration-handoff-materializer.ts:66-72`, `:193-201`; `orchestration-handoff-materializer-production.ts:24-43` |
| Non-blocking | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` | file length | File is 494 lines after the change, 6 lines under the 500-line limit. | Plan the next edit to this file with a line budget, or extract a helper to `orchestration-handoff-materializer-request.ts`. | File size limit in `.claude/rules/general-code-change.md`. | `wc -l` at HEAD: 494 |
| Non-blocking | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` | projection catch, about lines 284-298 | The pre-existing cast of `error.code` to `HandoffFailureCode` remains unvalidated. Spec lists it as out of scope. | Track in a follow-up issue if not already tracked. | The new cause token uses `describeHandoffFailureCause`, which pattern-checks `code`, so the cause string is safe; the failure code itself is not checked against the registry. | `spec.md` Out of scope, item 4 |
| Non-blocking | `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/evidence/` | 37 of 39 evidence filenames | Filename timestamps are later than the commit that added each file (for example `ts-jest-coverage.2026-10-09T03-47.md` committed at 03:06), so they were composed rather than read from the host clock. | Read timestamps from the host clock at record time. | `evidence-and-timestamp-conventions` SKILL line 49. Reviewer re-verification of the gate results means no verdict depends on the timestamps. | `git log --name-only --diff-filter=A` over the evidence folder compared with `%ad` |

Blocking findings: 0.

## Detailed Review

### Production changes

1. `orchestration-handoff-materializer-request.ts`
   - `HANDOFF_ERROR_NAME_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/` is module-private and anchored at both ends. It admits built-in error names and `HandoffContractError`; it rejects empty strings, spaces, `/`, `:`, `.`, `-`, and `$`. This closes NB-3 of the #645 audit.
   - `describeEnvelopeParseFailure(error: unknown)` is pure, returns a readonly object, and imports `HandoffContractError` as a value from `orchestration-handoff-contract-support.ts`. That module has no imports, so no cycle is introduced. `orchestration-handoff-contract.ts:34` re-exports the same class, so `instanceof` checks agree across modules.
   - The `blockedResult` option type is widened to `string | undefined`, which `exactOptionalPropertyTypes` requires for the pass-through. The existing conditional spread keeps the output shape unchanged when no cause is present.
2. `orchestration-handoff-authority-service.ts` and `orchestration-handoff-materializer-production.ts`
   - Both catch blocks now call the helper; the duplicated ternary and the now-unused `HandoffContractError` imports are removed. The failure code for each input is unchanged.
   - Behavior note: the `HandoffContractError` arm also gains a cause (`envelope-parse: <code>`). This is intended per spec Assumptions ("Cause on both arms").
3. `orchestration-handoff-materializer.ts`
   - `HandoffEnvelopeValidationResult` gains `readonly failureCause?: string`.
   - The validation-failure branch forwards `validation.failureCause`.
   - The projection catch adds `describeHandoffFailureCause("destination-projection", error)` to the options object; both failure-code arms of the existing ternary receive the cause.

### Catch-site completeness (AC-6)

This reviewer listed `catch` sites in the four modules with `grep -n "catch"` and found 16: authority-service 142, 152, 177; materializer 168, 183, 284, 315, 369, 379, 403, 413, 445, 457, 490; materializer-production 33, 49; materializer-request none. This matches `evidence/qa-gates/ac6-catch-site-inventory.2026-10-09T03-52.md`. Sites at materializer 445, 457 and 490 were read and route through `discardedCandidateResult`, which always sets `failureCause`. Production site 49 returns a message array; its consumer attaches the literal `destination-projection: invalid`.

### Test changes

- The split was checked by this reviewer: the support module equals pre-split lines 22-179 except for the added import block and four `export` keywords; the reduced file equals lines 181-328 plus a 6-line import block; the binding file equals lines 330-500 plus an 8-line import block. Exactly one commit (`59d4e2ba`) touches the three files, and it precedes the regression-test and fix commits.
- Focused runs: authority-service 11 tests, binding 17 tests; total 28 equals the pre-split count.
- The new fallback suite uses no module mocks. F4 uses a `satisfies FileSystem` in-memory object and a stub runner. F5 injects a validator returning a cause. F6 and F7 drive the real projection through `createScenario({ transformEnvelope })`.
- Existing assertions are unchanged. The only removed line in the edited failure-cause files is `const envelopeText = JSON.stringify(fixture);`, replaced by `scenario.envelopeText ?? JSON.stringify(fixture)`.

### Documentation changes

- #645 `spec.md` AC-8 and `user-story.md` US-1 each have exactly one line replaced; both keep `[x]`; both now name `orchestration-handoff-failure-cause-authority.test.ts`.

### Verification run by this reviewer

| Check | Command | Result |
| --- | --- | --- |
| Lint | `npm --prefix extensions/drm-copilot run lint` | exit 0 |
| Typecheck | `npm --prefix extensions/drm-copilot run typecheck` | exit 0 |
| Format | `prettier --check` on the 10 changed `.ts` files | exit 0 |
| Tests | `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestration-handoff test/mcp-handlers/orchestration-handoff-handlers.test.ts` | 14 suites, 247 tests passed |
| Coverage | `coverage/lcov.info` per-file LH/LF, BRH/BRF and zero-hit DA records | 4 modules at or above 85% / 75%; no changed line uncovered |

## Verdict

Approve. 0 Blocking findings. The Non-blocking items do not affect behavior and can be handled in follow-up work.
