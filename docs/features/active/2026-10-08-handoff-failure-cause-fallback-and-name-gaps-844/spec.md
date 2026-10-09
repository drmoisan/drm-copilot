# 2026-10-08-handoff-failure-cause-fallback-and-name-gaps (Spec)

- **Issue:** #844
- **Related (referenced, not closed):** #846 (#647 CR-3, authority-service test split only)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** `bug/handoff-failure-cause-fallback-and-name-gaps-844`
- **Work Mode:** full-bug
- **Last Updated:** 2026-10-08
- **Status:** Draft
- **Version:** 0.2
- **Research:** `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/research/research.2026-10-09T03-45.md`

All source and test paths below are relative to `extensions/drm-copilot/` unless they begin with `docs/`. Line citations refer to the current worktree tree as recorded in the research document, which is authoritative for them.

## Problem Statement

#645 attached a `failureCause` to blocked handoff results that follow a caught error. Its policy audit (`docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/policy-audit.2026-10-07T22-49.md:436-438`) recorded three non-blocking gaps, which issue #844 tracks:

- **NB-2 (missing causes).** Three catch sites in the handoff modules return, or feed, a blocked result with no `failureCause`:
  - (a) authority envelope parse, `src/lib/validate/orchestration-handoff-authority-service.ts:148-157`, both arms;
  - (b) materializer destination projection, `src/lib/validate/orchestration-handoff-materializer.ts:274-293`, both the `code` arm and the no-`code` arm;
  - (c) production envelope validation, `src/lib/validate/orchestration-handoff-materializer-production.ts:25-44`, both arms. The caught error is dropped, and the result surfaces at `orchestration-handoff-materializer.ts:187-201` with no cause. The `HandoffEnvelopeValidationResult` interface (`orchestration-handoff-materializer.ts:66-71`) has no `failureCause` field.
- **NB-3 (unvalidated name).** `describeHandoffFailureCause` (`src/lib/validate/orchestration-handoff-materializer-request.ts:32-46`) checks `code` against `HANDOFF_ERROR_CODE_PATTERN`. For an `Error` it returns `${stage}: ${error.name}` without validating `name`, so a custom error class can place arbitrary text in the cause field.
- **NB-1 (documentation mismatch).** #645 `spec.md:189` (AC-8) names only `test/lib/validate/orchestration-handoff-failure-cause.test.ts`. The authority cases are in `test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts`. #645 `user-story.md:53` (US-1) carries the same single-file wording.

An additional item is taken from #846 (#647 CR-3). `test/lib/validate/orchestration-handoff-authority-service.test.ts` is exactly 500 lines and has no headroom under the 500-line limit. It is split into a test-support module and two test files.

Impact: diagnostics only (severity Low). No handoff outcome, failure code, or status changes.

## Scope and Non-Goals

### In scope

- NB-2: attach a stage-prefixed `failureCause` to both arms of each of the three catch sites (a), (b), and (c).
- NB-3: validate `error.name` against an identifier pattern before using it as the cause token, with a fallback to `Error`.
- NB-1: amend #645 `spec.md` AC-8, and #645 `user-story.md` US-1, to name both test files.
- #846 (CR-3) for one file only: split `test/lib/validate/orchestration-handoff-authority-service.test.ts` into a test-support module, the reduced original file, and a new binding test file. The split is completed before any other edit to that file.
- A new test file, `test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts`, plus added rows in the two existing failure-cause test files.

### Out of scope / non-goals

- `extensions/drm-copilot/test/subagent-tree-command.test.ts` and every other #846 item. The PR closes #844 and only references #846. #846 remains open.
- NB-4 through NB-8 of the #645 policy audit, which are informational.
- `authority-service.ts:296-298` (the `unavailable` checkout sentinel). It does not follow a caught error.
- Catch sites outside the four production modules, including `orchestration-handoff-path-boundary.ts:98` and `:196`.
- The pre-existing unvalidated cast of `error.code` to `HandoffFailureCode` at `materializer.ts:285-286`.
- Any change to `status`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities`, `handoffId`, `handoffHistorySha256`, MCP input schemas, the envelope schema, fixtures, or `HandoffPathBoundary`.
- `src/lib/validate/orchestration-handoff-contract.ts`, which is 497 lines and is not edited.

### Explicitly excluded systems

- Bundled mirrors under `resources/`. None exist for these modules (research section 7).
- `CHANGELOG.md`. No entry is required (research section 7).

## Root Cause Analysis

- #645 scoped its fix to the 15 bare `catch` sites. Sites (a), (b), and (c) were already bound (`catch (error: unknown)`) before #645, so they fell outside its enumeration and AC-8.
- `HandoffEnvelopeValidationResult` has no `failureCause` field. The production validator therefore cannot return a cause, and the materializer cannot forward one.
- `describeHandoffFailureCause` applied a pattern check to `code` but not to `name`.
- The #645 AC-8 text was written before the plan's pre-approved overflow branch split the tests across two files. A single file would have been 608 lines.

The research enumerates the catch sites in the four production modules (`orchestration-handoff-authority-service.ts`, `orchestration-handoff-materializer.ts`, `orchestration-handoff-materializer-production.ts`, `orchestration-handoff-materializer-request.ts`). It finds 16 catch sites (research Numeric Derivation Evidence, claim N1). Of these, 3 lack a cause on a blocked result: authority 150, production 33, and materializer 282 (claim N2). Each claim has two independent derivations with identical member sets.

## Design Decisions

### D1. Shared pure helper `describeEnvelopeParseFailure`

Add an exported pure function to `src/lib/validate/orchestration-handoff-materializer-request.ts`:

```ts
export function describeEnvelopeParseFailure(error: unknown): {
  readonly code: HandoffFailureCode;
  readonly failureCause: string;
} {
  return {
    code:
      error instanceof HandoffContractError
        ? error.code
        : "HANDOFF_UNSUPPORTED_VERSION",
    failureCause: describeHandoffFailureCause("envelope-parse", error),
  };
}
```

- Import `HandoffContractError` as a value from `./orchestration-handoff-contract-support`. That module has no imports, so no import cycle is introduced, and `instanceof` identity is unchanged.
- The authority catch (`authority-service.ts:150-156`) calls the helper and passes `{ failureCause }` to `blocked`. The now-unused `HandoffContractError` import at `authority-service.ts:11` is removed (`noUnusedLocals`).
- The production catch (`materializer-production.ts:33-43`) calls the helper and returns `primaryFailureCode: failure.code` and `failureCause: failure.failureCause`. The now-unused `HandoffContractError` import at `materializer-production.ts:7` is removed.
- Rationale: the non-`HandoffContractError` arms of (a) and (c) cannot be reached through the real parser, because `parseHandoffEnvelopeText` converts every error to `HandoffContractError`. Moving the branch into a pure helper makes it directly testable with a `TypeError`, with no module mock. The call sites also become branch-free.
- Rejected: inline causes at each catch with module mocks to reach the fallback arms. Also rejected: attaching causes only to non-contract arms, which contradicts the US-1 wording.

### D2. Validation-result pass-through

- Add `readonly failureCause?: string;` to `HandoffEnvelopeValidationResult` (`materializer.ts:66-71`).
- Widen the `blockedResult` option to `readonly failureCause?: string | undefined;` (`materializer-request.ts:82`). The widening is required by `exactOptionalPropertyTypes: true`. The existing conditional spread (`:97-99`) omits `undefined`, so the output shape is unchanged when no cause is present.
- Pass `failureCause: validation.failureCause` in the validation-failure branch at `materializer.ts:193-200`.

### D3. `destination-projection: <token>` cause on the projection catch

- Add `failureCause: describeHandoffFailureCause("destination-projection", error)` to the options object in the projection catch at `materializer.ts:288-291`. The failure codes are unchanged.
- Expected tokens:
  - code arm: `destination-projection: HANDOFF_UNSUPPORTED_VERSION`, for example with `expressionSchemaId: "codex.orchestrator-state"`;
  - no-`code` arm: `destination-projection: TypeError`, for example with an envelope whose `lifecycle` is `undefined`.

### D4. `HANDOFF_ERROR_NAME_PATTERN` with `Error` fallback

- Add a module-private constant in `materializer-request.ts` next to `HANDOFF_ERROR_CODE_PATTERN`:

  ```ts
  /** An error class name: an ASCII identifier such as `TypeError`. */
  const HANDOFF_ERROR_NAME_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/;
  ```

- For an `Error`, return `${stage}: ${error.name}` only when `HANDOFF_ERROR_NAME_PATTERN.test(error.name)` holds. Otherwise return `${stage}: Error`.
- Update the docstring of `describeHandoffFailureCause` to state the name constraint.
- The pattern admits built-in names (`Error`, `TypeError`, `SyntaxError`, `RangeError`), `HandoffContractError`, and `AbortError`. It rejects the empty string, spaces, `/`, `\`, `:`, `;`, `$`, `.`, and `-`.

### D5. Authority-service test split layout (#846 CR-3)

- New `test/lib/validate/orchestration-handoff-authority-service-test-support.ts`. It receives the current lines `:22-179` (`EnvelopeFixture`, `ScenarioOptions`, path constants, `sha256`, `loadFixture`, `createScenario`). It exports `EnvelopeFixture`, `ScenarioOptions`, `canonicalPlanPath`, and `createScenario`, and imports `jest` from `@jest/globals`.
- `test/lib/validate/orchestration-handoff-authority-service.test.ts` keeps the current `describe("portable orchestration handoff authority service")` block (`:181-328`) and imports its helpers from the support module.
- New `test/lib/validate/orchestration-handoff-authority-service-binding.test.ts`. It receives `:330-500` (`MutationTarget`, `mutate`, `observedCheckout`, and `describe("independent binding authority over a mutated envelope")`).
- Test bodies move verbatim. Only import and export lines change. The support file name does not end in `.test.ts`, so `jest.config.cjs` `testMatch` does not treat it as a suite. `collectCoverageFrom` measures only `src/`, so the support file does not enter the coverage denominator.
- Rejected: duplicating `createScenario` into the binding file, which violates the reusability rule.

### D6. New test file `orchestration-handoff-failure-cause-fallback.test.ts`

`test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts` contains:

- `describeEnvelopeParseFailure` rows:
  - a `HandoffContractError` with code `HANDOFF_HISTORY_INVALID` gives `{ code: "HANDOFF_HISTORY_INVALID", failureCause: "envelope-parse: HANDOFF_HISTORY_INVALID" }`;
  - a `TypeError` gives `{ code: "HANDOFF_UNSUPPORTED_VERSION", failureCause: "envelope-parse: TypeError" }`;
  - a thrown non-`Error` value gives the `envelope-parse:` prefix followed by the existing non-error token from `describeHandoffFailureCause`.
- Production `validateEnvelope("{")` returns `failureCause: "envelope-parse: HANDOFF_UNSUPPORTED_VERSION"`. The validator is built with `createProductionHandoffMaterializer`.
- Materializer pass-through: a validator dependency returns a validation result with `failureCause: "envelope-parse: TypeError"`, and the blocked result carries that cause.
- Projection no-`code` arm: `HANDOFF_VALIDATOR_UNAVAILABLE` and `destination-projection: TypeError`.
- Projection code arm: `HANDOFF_UNSUPPORTED_VERSION` and `destination-projection: HANDOFF_UNSUPPORTED_VERSION`.

The file reuses `createScenario` from `test/lib/validate/orchestration-handoff-materializer-test-support.ts`.

Additional rows in existing files:

- `orchestration-handoff-failure-cause.test.ts` gets the three NB-3 rows in the existing `it.each`:
  - a `name` containing non-identifier characters (for example `"Bad Name: /home/operator"`) gives `checkpoint-read: Error`;
  - `"CustomFailure"` gives `checkpoint-read: CustomFailure`;
  - `""` gives `checkpoint-read: Error`.

  The custom classes assign `name` in the constructor.
- `orchestration-handoff-failure-cause-authority.test.ts` gets an `envelopeText?: string` option on `AuthorityCase` and row A7 with `envelopeText: "{"`. A7 expects `HANDOFF_UNSUPPORTED_VERSION` and `failureCause: "envelope-parse: HANDOFF_UNSUPPORTED_VERSION"`.

### D7. Correction of #645 spec AC-8 and user-story US-1

- Amend `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md` AC-8 to name both test files:
  - the materializer cases are attributed to `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts`;
  - the authority envelope-read and plan-read cases are attributed to `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts`.
- The checkbox state (`[x]`) is preserved.
- Amend `user-story.md` US-1 in the same folder the same way: it names both failure-cause test files. Its checkbox state is preserved.

## Boundaries and Invariants

- Only the optional `failureCause` field changes. In MCP output it appears as `failure_cause` through the existing conditional spread in `src/mcp-handlers/orchestration-handoff-handlers.ts`.
- For every input, `status`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities`, `handoffId`, and `handoffHistorySha256` stay unchanged.
- Validated and materialized results carry no `failureCause`.
- No new production file is added, so no new `coverageThreshold` entry is required.
- `orchestration-handoff-materializer.ts` has about 10 lines of headroom. The 500-line limit is confirmed by a count after formatting.

## Test Strategy

- Regression first. Run the new rows (D4, D6, and A7) against the pre-fix tree and record the failures before the production change: the cause is absent, or the name is unfiltered.
- Before the split, record the test count of `orchestration-handoff-authority-service.test.ts` from a focused jest run. Compare it with the sum after the split.
- Toolchain, run from `extensions/drm-copilot`:
  1. `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
  2. `npm run lint`
  3. `npm run typecheck`
  4. Architecture-boundary tests: none are configured, so record this stage as not applicable.
  5. `npm run test:coverage`
  6. Contract and schema checks: none are affected.
  7. Integration: the MCP handler tests run inside stage 5.
- Do not use a focused `--coverage` run as the coverage gate. `collectCoverageFrom` includes every `src` file.
- No temporary files, wall-clock reads, or network access are used in tests.

## Acceptance Criteria

- [x] AC-1: `describeEnvelopeParseFailure` is exported from `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts`. `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts` contains passing named cases for:
  - a `HandoffContractError` input, which returns `{ code: "HANDOFF_HISTORY_INVALID", failureCause: "envelope-parse: HANDOFF_HISTORY_INVALID" }`;
  - a `TypeError` input, which returns `{ code: "HANDOFF_UNSUPPORTED_VERSION", failureCause: "envelope-parse: TypeError" }`;
  - a thrown non-`Error` value, which returns a `failureCause` beginning with `envelope-parse: `.
- [x] AC-2: The authority envelope-parse catch in `orchestration-handoff-authority-service.ts` obtains its code and cause from `describeEnvelopeParseFailure` and passes `failureCause` to `blocked`. Row A7 (`envelopeText: "{"`) in `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts` passes and asserts `primaryFailureCode` `HANDOFF_UNSUPPORTED_VERSION` and `failureCause` `envelope-parse: HANDOFF_UNSUPPORTED_VERSION`.
- [x] AC-3: `HandoffEnvelopeValidationResult` declares `readonly failureCause?: string`. The production `validateEnvelope` in `orchestration-handoff-materializer-production.ts` returns the helper's code and cause in its catch. A passing named case in the fallback test file asserts that production `validateEnvelope("{")` returns `failureCause: "envelope-parse: HANDOFF_UNSUPPORTED_VERSION"`.
- [x] AC-4: The materializer validation-failure branch forwards `validation.failureCause` to `blockedResult`. A passing named case in the fallback test file asserts that a validator result carrying `failureCause: "envelope-parse: TypeError"` produces a blocked result with that exact `failureCause`.
- [x] AC-5: The projection catch in `orchestration-handoff-materializer.ts` attaches `describeHandoffFailureCause("destination-projection", error)`. Passing named cases in the fallback test file assert:
  - (i) the no-`code` arm returns `HANDOFF_VALIDATOR_UNAVAILABLE` with `failureCause` `destination-projection: TypeError`;
  - (ii) the code arm returns `HANDOFF_UNSUPPORTED_VERSION` with `failureCause` `destination-projection: HANDOFF_UNSUPPORTED_VERSION`.
- [x] AC-6: No blocked result that follows a caught error in the four production modules lacks `failureCause`. The four modules are `orchestration-handoff-authority-service.ts`, `orchestration-handoff-materializer.ts`, `orchestration-handoff-materializer-production.ts`, and `orchestration-handoff-materializer-request.ts`. This is verified by an evidence artifact under the feature folder's `evidence/` tree. The artifact re-enumerates every catch site in the four modules after the fix, using two independent search strategies with compared member sets. It classifies each site and records that every site that returns or feeds a blocked result supplies a `failureCause` on every arm.
- [x] AC-7: `describeHandoffFailureCause` uses `error.name` only when it matches the module-private `HANDOFF_ERROR_NAME_PATTERN` (`/^[A-Za-z_][A-Za-z0-9_]*$/`); otherwise the token is `Error`. Three new rows in the existing `it.each` of `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts` pass:
  - a custom class whose `name` contains non-identifier characters gives `checkpoint-read: Error`;
  - `name` `CustomFailure` gives `checkpoint-read: CustomFailure`;
  - an empty `name` gives `checkpoint-read: Error`.
- [x] AC-8: The regression-first evidence artifact records that the new cases for AC-2, AC-3, AC-4, AC-5, and AC-7 fail on the pre-fix production code and pass after the fix.
- [x] AC-9: Every existing test in `extensions/drm-copilot/test/lib/validate/` and `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts` passes without modification to its assertions. The exception is the import-line changes required by the split in AC-10. The assertions that validated and materialized results carry no `failureCause` still pass.
- [x] AC-10: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` is split per D5 into three files:
  - that file;
  - `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-test-support.ts`;
  - `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-binding.test.ts`.

  Test bodies are moved verbatim. The split is committed before any other change to `orchestration-handoff-authority-service.test.ts`.
- [x] AC-11: Before the split, the plan measures the test count of `orchestration-handoff-authority-service.test.ts` from a focused jest run and records it in an evidence artifact. After the split, the sum of the `Tests:` counts of `orchestration-handoff-authority-service.test.ts` and `orchestration-handoff-authority-service-binding.test.ts` equals that recorded value. All of those tests pass.
- [x] AC-12: `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md` AC-8 names both `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts` and `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts`. `user-story.md` US-1 in the same folder also names both files. The checkbox state of both items is unchanged.
- [x] AC-13: After formatting, every file listed under Files in scope that is under `extensions/drm-copilot/` has a line count of 500 or fewer, as recorded in an evidence artifact.
- [x] AC-14: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` run from `extensions/drm-copilot` exits 0.
- [x] AC-15: `npm run lint` run from `extensions/drm-copilot` exits 0 with no errors.
- [x] AC-16: `npm run typecheck` run from `extensions/drm-copilot` exits 0 with no diagnostics. This includes `typecheck:test` over `test/**/*.ts`.
- [x] AC-17: `npm run test:coverage` run from `extensions/drm-copilot` exits 0 with all suites passing. The per-file thresholds (lines >= 85%, branches >= 75%) hold for each of the four touched production files under `extensions/drm-copilot/src/lib/validate/`: `orchestration-handoff-authority-service.ts`, `orchestration-handoff-materializer.ts`, `orchestration-handoff-materializer-production.ts`, and `orchestration-handoff-materializer-request.ts`. No changed line in those files is uncovered.
- [ ] AC-18: The branch diff against `main` contains no change to `extensions/drm-copilot/test/subagent-tree-command.test.ts`, `extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts`, `CHANGELOG.md`, MCP input schemas, the envelope schema, or fixtures. The PR body contains a closing keyword for #844 and references #846 without a closing keyword.

## Assumptions

Recorded decisions made without operator input:

- **Work mode:** `full-bug` was selected because the change spans four production modules and a test-file restructuring, which exceeds a minor-audit change. `spec.md` is the sole acceptance-criteria source, and no `user-story.md` is produced for this folder.
- **CHANGELOG:** no entry is added. `CHANGELOG.md` has an empty `## [Unreleased]` section and no per-fix convention, and no `.claude/` or `.github/` policy references it (research section 7).
- **Bundled mirrors:** none exist for the four modules or the helper symbols (research section 7), so no mirror update is required.
- **#645 user-story.md:** amended (D7, AC-12). US-1 repeats the single-file wording that NB-1 corrects in AC-8. Leaving it unchanged would keep the two documents inconsistent, and the edit is limited to the file reference. The `[x]` states of #645 AC-8 and US-1 are preserved, because the delivered behavior they describe is unchanged. Only the file attribution is corrected.
- **Cause on both arms:** causes are attached to both the contract-error arm and the fallback arm of each NB-2 site, not only the fallback arm. This follows the US-1 wording that the issue cites as expected behavior.
- **Authority test file not edited for #844:** under D1 and D6, the A7 row goes in `orchestration-handoff-failure-cause-authority.test.ts`, so the authority-service test file is touched only by the #846 split.
- **Toolchain observations:** the research could not execute commands. Its success tokens come from the #645 QA evidence dated 2026-10-07. All gate outcomes for this fix must be observed fresh during execution.
- **Pre-split test count:** the count is not stated in this spec. The plan measures it (AC-11).

## Risks and Mitigations

- **Line budget:** `orchestration-handoff-materializer.ts` (488 lines before the change) may exceed 500 lines after Prettier reflows the options objects. Mitigation: count lines after formatting (AC-13). If the count exceeds 500, move the pass-through or the projection cause construction into `materializer-request.ts` helpers.
- **Type error:** the `exactOptionalPropertyTypes` setting rejects `string | undefined` passed as `failureCause`. Mitigation: widen the option type (D2).
- **Lost tests in the split:** the split could silently drop tests. Mitigation: the recorded pre-split count must equal the post-split sum (AC-11).

## Files in scope

- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-test-support.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-binding.test.ts`
- `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md`
- `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/user-story.md`
- `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/spec.md`
- `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/plan.2026-10-08T23-42.md`

Evidence artifacts (the pre-split test count, regression-first results, the catch-site inventory, line counts, and QA gates) are written to timestamped files under the feature folder's evidence directory, per the evidence-and-timestamp conventions. Their file names are determined at execution time.

## Rollout and Follow-up

- Release: no flag or migration. The change is additive diagnostics.
- Follow-up: the remaining #846 items, including `test/subagent-tree-command.test.ts`, stay open under #846.
- Links: issue #844; related #846, #645, and #647.
