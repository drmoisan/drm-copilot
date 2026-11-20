# Research: handoff failure-cause fallback and name gaps (Issue #844)

- Timestamp: 2026-10-09T03-45
- Branch: `bug/handoff-failure-cause-fallback-and-name-gaps-844`
- Scope: #844 NB-1, NB-2, NB-3, plus #846 (#647 CR-3) for `orchestration-handoff-authority-service.test.ts` only. `test/subagent-tree-command.test.ts` is out of scope.
- Method: every finding below was verified by reading the cited file on the current worktree tree with Read/Grep/Glob. No shell was available to this agent, so no command was executed; toolchain success tokens are taken from the #645 QA evidence artifacts recorded on 2026-10-07 and are labelled as such.
- All paths below are relative to `extensions/drm-copilot/` unless they start with `docs/`.

## 1. Current State

### 1.1 Cause plumbing that already exists

- Result types: `PortableHandoffAuthorityResult.failureCause?: string` and `TransitionPreparedOrchestrationResult.failureCause?: string` at `src/mcp-repo-automation-tool-definitions-handoff.ts:56` and `:71`.
- MCP mapping: `src/mcp-handlers/orchestration-handoff-handlers.ts:248-250` and `:274-276` add `failure_cause` by conditional spread.
- Helper: `describeHandoffFailureCause(stage, error)` at `src/lib/validate/orchestration-handoff-materializer-request.ts:32-46`. `HANDOFF_ERROR_CODE_PATTERN = /^[A-Z][A-Z0-9_]*$/` at `:18` (module-private, used only for `code` at `:38`). Lines `:42-44` return `${stage}: ${error.name}` with no check on `name`.
- Blocked builders:
  - authority: private `blocked(request, code, { handoffId?, affectedPaths?, unsupportedCapabilities?, failureCause? })` at `orchestration-handoff-authority-service.ts:98-120` (conditional spread at `:116-118`).
  - materializer: exported `blockedResult(...)` at `orchestration-handoff-materializer-request.ts:74-101`; options type `readonly failureCause?: string` at `:82`; conditional spread at `:97-99`. `authorityFailure` at `:103-122` forwards an authority cause.
- Envelope validation seam: `HandoffEnvelopeValidationResult` at `orchestration-handoff-materializer.ts:66-71` has fields `envelope`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities` and **no `failureCause` field**. The production implementation therefore has no way to return a cause today.
- `tsconfig.json:15` sets `exactOptionalPropertyTypes: true`, so passing a `string | undefined` value to an option typed `failureCause?: string` is a type error.
- Stage labels in use (spec #645 `spec.md:52` plus source): `checkpoint-read`, `envelope-decode`, `git-status`, `archive-write`, `archive-readback`, `candidate-write`, `candidate-readback`, `candidate-validate`, `candidate-replace`, `candidate-cleanup`, `envelope-read`, `plan-read`, `destination-projection`, `workspace-root`, `target-path`. `envelope-parse` is **not** used anywhere in source yet (Grep for `describeHandoffFailureCause` across the repo outside `docs/` returns only the sites listed in section 2).

### 1.2 The three NB-2 fallback arms, current code

(a) Authority envelope parse: `orchestration-handoff-authority-service.ts:148-157`

```ts
  try {
    return parseHandoffEnvelopeText(envelopeText);
  } catch (error: unknown) {
    return blocked(
      request,
      error instanceof HandoffContractError
        ? error.code
        : "HANDOFF_UNSUPPORTED_VERSION",
    );
  }
```

Neither arm carries a cause. `HandoffContractError` is imported at `:11` and used only at `:153`.

(b) Materializer projection: `orchestration-handoff-materializer.ts:274-293`

```ts
    } catch (error: unknown) {
      return blockedResult(
        request,
        error instanceof Error && "code" in error
          ? (error.code as HandoffFailureCode)
          : "HANDOFF_VALIDATOR_UNAVAILABLE",
        {
          handoffId: envelope.handoffId,
          handoffHistorySha256: lastHistoryEntry.entrySha256,
        },
      );
    }
```

Neither arm carries a cause (the issue names only the no-`code` arm; the `code` arm is also cause-less).

(c) Production envelope validation: `orchestration-handoff-materializer-production.ts:25-44`

```ts
  } catch (error: unknown) {
    return {
      envelope: null,
      primaryFailureCode:
        error instanceof HandoffContractError
          ? error.code
          : "HANDOFF_UNSUPPORTED_VERSION",
      affectedPaths: [],
      unsupportedCapabilities: [],
    };
  }
```

The caught error is dropped. The result surfaces at `orchestration-handoff-materializer.ts:187-201`:

```ts
    if (
      validation.primaryFailureCode !== null ||
      validation.envelope === null
    ) {
      return blockedResult(
        request,
        validation.primaryFailureCode ?? "HANDOFF_VALIDATOR_UNAVAILABLE",
        {
          affectedPaths: validation.affectedPaths,
          unsupportedCapabilities: validation.unsupportedCapabilities,
        },
      );
    }
```

### 1.3 Reachability of the non-`HandoffContractError` arms

- `parseHandoffEnvelopeText` (`src/lib/validate/orchestration-handoff-contract.ts:471-479`) wraps `JSON.parse` and `parseHandoffEnvelope` in its own `try`; any non-`HandoffContractError` is converted by `fail("handoff", "must be valid JSON")`, and `fail` (`orchestration-handoff-contract-support.ts:161-167`) always throws `HandoffContractError`.
- Consequence: arms (a) and (c) `"HANDOFF_UNSUPPORTED_VERSION"` fallbacks are unreachable through the real parser. They are defensive arms. A test cannot reach them through the call site without replacing `parseHandoffEnvelopeText` (module mock). This drives the design choice in section 3.
- Arm (b) without `code` is reachable: `projectDestinationCheckpoint` (`orchestration-handoff-provider-adapters.ts:157-179`) dereferences `envelope.lifecycle.nextTransition` at `:179` after `validateProviderSource` (`:91-120`) and two `requireProjectionDigest` calls. A materializer scenario with `transformEnvelope: (e) => ({ ...e, lifecycle: undefined as unknown as HandoffEnvelope["lifecycle"] })` throws a `TypeError` (no `code`) at `:179`. The materializer reads no `lifecycle` field before the projection (`orchestration-handoff-materializer.ts:202-272` reads `handoffHistory`, `source`, `binding`, `destinationProvider`, `destinationCheckpointPath`), so the throw lands in the projection catch.
- Arm (b) with `code` is reachable today: the existing "provider adapter rejection" row (`test/lib/validate/orchestration-handoff-materializer.test.ts:131-143`, `expressionSchemaId: "codex.orchestrator-state"`) produces `HandoffContractError` with `HANDOFF_UNSUPPORTED_VERSION` (`orchestration-handoff-provider-adapters.ts:98-102`).

### 1.4 Existing tests over these arms

| Arm | Covering test today | Asserts cause? |
|---|---|---|
| (a) contract-error arm | `test/lib/validate/orchestration-handoff-authority-service.test.ts:241-251` ("reports contract parse failure before plan resolution", `envelopeText: "{"`) | No; asserts code and read count only |
| (a) fallback arm | none (unreachable, 1.3) | n/a |
| (b) code arm | `orchestration-handoff-materializer.test.ts:131-143` ("provider adapter rejection") | No; asserts status, code, no mutation (`:209-227`) |
| (b) no-code arm | none found | n/a |
| (c) contract-error arm | `test/lib/validate/orchestration-handoff-materializer-production.test.ts:190-193` (`validateEnvelope("{")` with `toMatchObject`) | No |
| (c) fallback arm | none (unreachable, 1.3) | n/a |
| (c) surfacing at materializer `:189-201` | `orchestration-handoff-materializer.test.ts:84-88` ("contract validator rejection", via the test-support fake at `orchestration-handoff-materializer-test-support.ts:260-269`) | No |

No existing assertion pins `failureCause` as absent on any of these arms. Every `not.toHaveProperty("failureCause")` / `not.toHaveProperty("failure_cause")` in the test tree is on a validated or materialized result: `orchestration-handoff-failure-cause.test.ts:351-357` (M12, M17), `orchestration-handoff-failure-cause-authority.test.ts:178-180` (A6), `test/mcp-handlers/orchestration-handoff-handlers.test.ts:400,402` (mocked validated/materialized). The production assertion at `orchestration-handoff-materializer-production.test.ts:190` uses `toMatchObject`, which tolerates an added key. A Grep for `toStrictEqual(` and `toEqual({` over `test/**/*handoff*` found no whole-object assertion on a blocked result. No existing assertion needs updating.

## 2. All catch sites in the four modules

Classification of every `catch` in `orchestration-handoff-authority-service.ts`, `orchestration-handoff-materializer.ts`, `orchestration-handoff-materializer-production.ts`, `orchestration-handoff-materializer-request.ts` (the last has none):

| # | Site | Stage | Blocked result carries cause? |
|---|---|---|---|
| 1 | authority-service.ts:140 | envelope-read | Yes (`:141-143`) |
| 2 | authority-service.ts:150 | (none) | **No, both arms** (NB-2 a) |
| 3 | authority-service.ts:177 | plan-read | Yes, via caller `:338-342` |
| 4 | materializer-production.ts:33 | (none) | **No, both arms**; surfaces at materializer.ts:189-201 (NB-2 c) |
| 5 | materializer-production.ts:50 | destination-projection | Not a blocked result; returns a message containing the token; consumer materializer.ts:296-302 attaches `destination-projection: invalid` (D1 of #645) |
| 6 | materializer.ts:167 | checkpoint-read | Yes |
| 7 | materializer.ts:182 | envelope-decode | Yes |
| 8 | materializer.ts:282 | (none) | **No, both arms** (NB-2 b) |
| 9 | materializer.ts:309 | git-status | Yes |
| 10 | materializer.ts:363 | archive-write | Yes (`:378`, `:386`) |
| 11 | materializer.ts:373 | archive-readback | Yes (`:378`) |
| 12 | materializer.ts:397 | candidate-write | Yes (`:412`, `:420`) |
| 13 | materializer.ts:407 | candidate-readback | Yes (`:412`) |
| 14 | materializer.ts:439 | candidate-validate | Yes (`:440-444`) |
| 15 | materializer.ts:451 | candidate-replace | Yes (`:452-456`) |
| 16 | materializer.ts:484 | candidate-cleanup | Yes, appended at `:472` |

Result: exactly the three NB-2 sites (2, 4, 8) lack a cause; no fourth site exists in these modules. Related observations outside the catch family, not in scope:

- `authority-service.ts:296-298` returns `HANDOFF_VALIDATOR_UNAVAILABLE` without a cause when the checkout observation is `unavailable`. `orchestration-handoff-checkout-context.ts` contains no `catch` (Grep), and `unavailable` is a sentinel built at `:117`, not a caught error. Out of scope for NB-2.
- `orchestration-handoff-path-boundary.ts:98` and `:196` are catches outside the four files; `:98` already produces a cause that callers replace with fixed sentinels (#645 D1, NB-4).
- `materializer.ts:285-286` casts an unvalidated `error.code` to `HandoffFailureCode`. Pre-existing; not changed by this fix.

## 3. Candidate Approaches (NB-2)

### Selected: shared envelope-parse helper plus direct cause attachment

1. Add to `orchestration-handoff-materializer-request.ts` an exported pure helper, for example:

   ```ts
   export function describeEnvelopeParseFailure(error: unknown): {
     readonly code: HandoffFailureCode;
     readonly failureCause: string;
   } {
     return {
       code: error instanceof HandoffContractError ? error.code : "HANDOFF_UNSUPPORTED_VERSION",
       failureCause: describeHandoffFailureCause("envelope-parse", error),
     };
   }
   ```

   Import `HandoffContractError` as a value from `./orchestration-handoff-contract-support` (that module has no imports, verified by Grep, so no cycle is introduced; `orchestration-handoff-contract.ts:34` re-exports the same class, so `instanceof` identity is unchanged).
2. Authority catch (`authority-service.ts:150-156`): call the helper and pass `{ failureCause }` to `blocked`. Remove the now-unused `HandoffContractError` import at `:11` (`noUnusedLocals: true`, `tsconfig.json:12`).
3. Production catch (`materializer-production.ts:33-43`): call the helper; return `primaryFailureCode: failure.code` and `failureCause: failure.failureCause`. Remove the now-unused `HandoffContractError` import at `:7`.
4. Add `readonly failureCause?: string;` to `HandoffEnvelopeValidationResult` (`materializer.ts:66-71`).
5. Widen `blockedResult` option `failureCause` to `readonly failureCause?: string | undefined;` (`materializer-request.ts:82`). The existing conditional spread at `:97-99` already omits `undefined`, so output shape is unchanged. Then pass `failureCause: validation.failureCause` at `materializer.ts:196-199` (one line).
6. Projection catch (`materializer.ts:288-291`): add `failureCause: describeHandoffFailureCause("destination-projection", error),` to the options object (one line). Codes are unchanged.

Rationale:
- Both arms of each catch receive a cause, which satisfies the US-1 sentence ("every blocked handoff result that follows a caught error") literally. Token values: contract-error arms yield `envelope-parse: HANDOFF_<CODE>` / `destination-projection: HANDOFF_<CODE>` (the code matches `HANDOFF_ERROR_CODE_PATTERN`); the fallback arms yield `envelope-parse: <Name>` / `destination-projection: TypeError`.
- The unreachable fallback branch moves into a pure helper that is directly unit-testable with a `TypeError`, so no module mock is needed and the authority and production call sites become branch-free.
- `status`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities`, `handoffId`, `handoffHistorySha256` are unchanged for every input (#645 US-3 invariant). The only change is an additive optional field, which also appears as `failure_cause` in MCP output for these results.
- No new production file, so no new `coverageThreshold` entry is required.

### Rejected alternatives

- Inline `failureCause: describeHandoffFailureCause("envelope-parse", error)` at each catch, keeping the ternaries: equivalent output, but the authority and production fallback arms stay unreachable and can be exercised only by `jest.mock` of `orchestration-handoff-contract` with a `requireActual` passthrough. More test machinery for the same behavior.
- Attach a cause only on the non-`HandoffContractError` arms (the narrowest reading of the issue title): leaves the reachable contract-error arms without a cause, which contradicts the US-1 wording the issue cites as Expected.

## 4. NB-3: identifier pattern for `error.name`

- Existing constants: no identifier pattern exists in the handoff modules. Nearby patterns (`orchestration-handoff-contract-support.ts:136-141`: `SHA256`, `SEMVER`, `HANDOFF_ID`, `FAILURE_CODE`) are not identifier patterns; `HANDOFF_ID` admits `.`, `:` and `-`, so it is unsuitable (`:` is the stage delimiter and `; ` is the cause separator).
- Proposed: a module-private constant next to `HANDOFF_ERROR_CODE_PATTERN` in `orchestration-handoff-materializer-request.ts`:

  ```ts
  /** An error class name: an ASCII identifier such as `TypeError`. */
  const HANDOFF_ERROR_NAME_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/;
  ```

  and at `:42-44`:

  ```ts
  if (error instanceof Error) {
    return `${stage}: ${HANDOFF_ERROR_NAME_PATTERN.test(error.name) ? error.name : "Error"}`;
  }
  ```

  Update the docstring at `:23-26` to state the name constraint. The pattern admits every built-in name (`Error`, `TypeError`, `SyntaxError`, `RangeError`), `HandoffContractError`, and `AbortError`; it rejects empty strings, spaces, `/`, `\`, `:`, `;`, `$`, `.`, and `-`.
- Existing rows that remain valid: `(d)` `TypeError` (`orchestration-handoff-failure-cause.test.ts:101-105`), `(b)`/`(c)` fall back to `Error` (`:91-100`), M6/M8 `...: Error` (`:218-245`), P1 `SyntaxError` (`:438-440`).
- New rows (in the `it.each` at `orchestration-handoff-failure-cause.test.ts:85-121`): a custom class whose constructor assigns `this.name = "Bad Name: /home/operator"` (expect `checkpoint-read: Error`); a custom class with `this.name = "CustomFailure"` (expect `checkpoint-read: CustomFailure`); a custom class with `this.name = ""` (expect `checkpoint-read: Error`). Assign `name` in the constructor (the `HandoffContractError` style, `contract-support.ts:126-133`); a class field `name = ...` would require the `override` modifier under `noImplicitOverride` (`tsconfig.json:15`).

## 5. NB-1: #645 AC-8 text

- `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md:189` names only `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts`.
- The authority cases A1-A6 are in `test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts:130-186`.
- The #645 folder is still under `docs/features/active/`; no completed-folder copy exists (Glob `docs/features/*/*645*/*.md`).
- The same single-file wording also appears in `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/user-story.md:53` (US-1). NB-1 names only AC-8; amending US-1 is optional and should be decided by the planner.
- Proposed AC-8 text: name both files, and attribute the authority envelope-read and plan-read cases to `orchestration-handoff-failure-cause-authority.test.ts`.

## 6. #846 (#647 CR-3): split of `orchestration-handoff-authority-service.test.ts`

- Current size: 500 lines (`rg` line count, cross-checked by Read: last line `500 });`). Zero headroom.
- Under the selected design the authority envelope-parse case goes in `orchestration-handoff-failure-cause-authority.test.ts`, so this file need not be edited for #844. The split is still in scope per the delegation.
- Structure today:
  - `:1-20` imports; `:22-55` `EnvelopeFixture` and `ScenarioOptions`; `:57-63` path constants; `:65-73` `sha256`, `loadFixture`; `:75-179` `createScenario`.
  - `:181-328` `describe("portable orchestration handoff authority service")`: 9 tests (path escapes, read failures, hash mismatch, parse failure, provider mismatch, precedence ordering, topology/routing resolution).
  - `:330-354` `MutationTarget`, `mutate`, `observedCheckout` helpers.
  - `:356-500` `describe("independent binding authority over a mutated envelope")`: 8 tests including the registry-order precedence test at `:466-482` (referenced by #645 AC-12 at `spec.md:208`).
- Proposed split:
  1. New `test/lib/validate/orchestration-handoff-authority-service-test-support.ts`: move `:22-179` (`EnvelopeFixture`, `ScenarioOptions`, constants, `sha256`, `loadFixture`, `createScenario`) and export `EnvelopeFixture`, `ScenarioOptions`, `canonicalPlanPath`, `createScenario`. Import `jest` from `@jest/globals` (precedent: `orchestration-handoff-materializer-test-support.ts:1`). About 170 lines.
  2. `orchestration-handoff-authority-service.test.ts` keeps `:181-328` plus imports from the support file. About 160 lines.
  3. New `test/lib/validate/orchestration-handoff-authority-service-binding.test.ts`: move `:330-500` (`mutate`, `observedCheckout`, and the binding `describe`), importing `createScenario`, `EnvelopeFixture`, and `CheckoutObservation`. About 185 lines.
  - Test bodies move verbatim; only import lines change.
- Discovery and tooling:
  - `jest.config.cjs:4` `testMatch: ["**/test/**/*.test.ts"]` picks up `...-binding.test.ts` and does not treat `...-test-support.ts` as a suite (it does not end in `.test.ts`).
  - `jest.config.cjs:17` `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` measures only `src`, so test-support files do not enter the coverage denominator.
  - `tsconfig.jest.json:8` includes `test/**/*.ts`; `package.json` `lint` covers `src test`; `format` covers `test/**/*.ts`.
  - No non-`docs` file references `orchestration-handoff-authority-service.test` (Grep), so nothing else needs to change. #645 AC-12's file reference is historical and is not rewritten.
- Rejected: moving only the binding `describe` and duplicating `createScenario` (about 150 duplicated lines; violates the reusability rule).

## 7. Bundled mirrors and CHANGELOG

- Mirrors: Glob `**/orchestration-handoff-materializer*` over the whole worktree returns only `src/` and `test/` files; Grep for the four module names under `resources/` returns nothing; Grep for `describeHandoffFailureCause|HANDOFF_ERROR_CODE_PATTERN` outside `docs/` returns only `src/` and `test/` files. No bundled mirror exists.
- CHANGELOG: `CHANGELOG.md:8` has an empty `## [Unreleased]` and its only release entry is `[0.0.1] - 2026-05-02` (`:10`), while `package.json:6` is `1.1.18`. No `.claude/` or `.github/` file mentions `CHANGELOG` (Grep). There is no per-fix CHANGELOG convention, so no entry is required.

## 8. Toolchain (run from `extensions/drm-copilot`)

`package.json:202-214` scripts and `run-jest.cjs`. Success tokens are taken from the #645 QA artifacts dated 2026-10-07 (`docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/qa-gates/`). They were not re-observed in this session because this agent has no shell tool.

| Stage | Command | Success-case output (prior observation) |
|---|---|---|
| 1 Format (check) | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (no `format:check` script exists; `npm run format` writes) | exit 0; `Checking formatting...` / `All matched files use Prettier code style!` (`ts-prettier.2026-10-07T22-28.md:5-7`) |
| 2 Lint | `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`) | exit 0, empty output (`ts-eslint.2026-10-07T22-28.md:5-7`) |
| 3 Type check | `npm run typecheck` (`tsc -p ./ --noEmit && npm run typecheck:test`; `typecheck:test` = `tsc -p tsconfig.jest.json --noEmit`, which includes `test/**/*.ts`) | exit 0, no diagnostics (`ts-typecheck...md:5-7`, `ts-tsc-jest-diagnostics...md:5-8`) |
| 4 Architecture | none configured; no `.dependency-cruiser*` under `extensions/drm-copilot` (Glob), consistent with #645 NB-7 | n/a; record as not applicable |
| 5 Unit + coverage | `npm --prefix extensions/drm-copilot run test:coverage` (`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`) | exit 0; `Test Suites: N passed, N total`, `Tests: M passed, M total`; text-summary `Lines : ...%` (`ts-jest-coverage.2026-10-07T22-28.md:7-13`; then 253 suites / 3852 tests) |
| 5 focused | `node run-jest.cjs test/lib/validate/orchestration-handoff-failure-cause.test.ts test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts` (no `--coverage`) | exit 0; `Tests: N passed, N total` |
| 6 Contract/schema | none affected (no MCP `inputSchema`, envelope schema, or fixture change) | n/a |
| 7 Integration | handler tests run inside the jest suite (`test/mcp-handlers/orchestration-handoff-handlers.test.ts`) | covered by stage 5 |

Notes:
- `run-jest.cjs:9-19` rejects `--passWithNoTests`, `--onlyChanged`, `--lastCommit`, and rewrites `--testPathPattern` (`:21-23`).
- Coverage thresholds: per-file `{ lines: 85, branches: 75 }` with no `global` key (`jest.config.cjs:20-25`). All in-scope production files have entries: authority-service `:413`, materializer-production `:429`, materializer-request `:433`, materializer `:441` (also contract `:425`, path-boundary `:445`).
- A focused run with `--coverage` will probably fail thresholds for unloaded files, because `collectCoverageFrom` includes every `src` file. This is an inference and was not executed. Use the full `test:coverage` run for the coverage gate.
- Prior coverage for the touched modules (`ts-jest-coverage.2026-10-07T22-28.md:19-26`): authority-service 98.97% lines / 90.14% branches; materializer-production 100 / 97.50; materializer-request 100 / 100; materializer 98.98 / 96.43.

## 9. Line counts and budgets (limit 500)

Counts from Grep `^` line counts on the current tree.

| File | Lines now | Projected after the selected design |
|---|---|---|
| `src/lib/validate/orchestration-handoff-authority-service.ts` | 390 | ~391 |
| `src/lib/validate/orchestration-handoff-materializer.ts` | 488 | ~490 (+1 interface field, +1 validation pass-through, +1 projection cause, -0) |
| `src/lib/validate/orchestration-handoff-materializer-production.ts` | 139 | ~141 |
| `src/lib/validate/orchestration-handoff-materializer-request.ts` | 122 | ~145 |
| `src/lib/validate/orchestration-handoff-contract.ts` (not edited) | 497 | 497 |
| `test/lib/validate/orchestration-handoff-failure-cause.test.ts` | 442 | ~465 (NB-3 rows only) |
| `test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts` | 186 | ~196 (A7 envelope-parse row plus `envelopeText` option) |
| new `test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts` | 0 | ~150 |
| `test/lib/validate/orchestration-handoff-authority-service.test.ts` | 500 | ~160 after split |
| new `...-authority-service-test-support.ts` / `...-authority-service-binding.test.ts` | 0 | ~170 / ~185 |
| `test/lib/validate/orchestration-handoff-materializer.test.ts` (not edited) | 492 | 492 |
| `test/lib/validate/orchestration-handoff-materializer-production.test.ts` (not edited) | 423 | 423 |
| `test/lib/validate/orchestration-handoff-materializer-test-support.ts` (not edited) | 323 | 323 |
| `test/mcp-handlers/orchestration-handoff-handlers.test.ts` (not edited) | 404 | 404 |

`orchestration-handoff-materializer.ts` keeps about 10 lines of headroom. The implementer must re-count after formatting. Prettier may break the `blockedResult(...)` options differently, so the 500-line limit must be confirmed by a post-format count.

## 10. Requirements Mapping (proposed)

- R1 (NB-2 a): authority envelope-parse blocked results carry `envelope-parse: <token>`. Contract errors produce `envelope-parse: HANDOFF_UNSUPPORTED_VERSION` for `"{"`.
- R2 (NB-2 c): production `validateEnvelope` returns `failureCause`, and the materializer forwards it at `:193-200`.
- R3 (NB-2 b): projection blocked results carry `destination-projection: <token>`, for example `destination-projection: TypeError` (no-code arm) and `destination-projection: HANDOFF_UNSUPPORTED_VERSION` (code arm).
- R4 (NB-3): `error.name` is used only when it matches `^[A-Za-z_][A-Za-z0-9_]*$`; otherwise the token is `Error`.
- R5 (NB-1): #645 AC-8 names both test files.
- R6 (#846): split `orchestration-handoff-authority-service.test.ts` as in section 6; no test body changes.
- Invariants: no change to `status`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities`, `handoffId`, `handoffHistorySha256`, MCP input schemas, envelope schema, fixtures, or `HandoffPathBoundary`. Validated and materialized results carry no cause.

## 11. Testing Implications

- `orchestration-handoff-failure-cause.test.ts`: the three NB-3 rows from section 4.
- New `orchestration-handoff-failure-cause-fallback.test.ts`:
  - `describeEnvelopeParseFailure` rows: a `HandoffContractError` with code `HANDOFF_HISTORY_INVALID` gives `{ code: "HANDOFF_HISTORY_INVALID", failureCause: "envelope-parse: HANDOFF_HISTORY_INVALID" }`; a `TypeError` gives `{ code: "HANDOFF_UNSUPPORTED_VERSION", failureCause: "envelope-parse: TypeError" }`; a thrown string gives `envelope-parse: non-error value`.
  - Production `validateEnvelope("{")` gives `failureCause: "envelope-parse: HANDOFF_UNSUPPORTED_VERSION"`, built with `createProductionHandoffMaterializer`, as in P1 at `orchestration-handoff-failure-cause.test.ts:413-441`.
  - Materializer pass-through: a validator dependency returning `{ envelope: null, primaryFailureCode: "HANDOFF_UNSUPPORTED_VERSION", failureCause: "envelope-parse: TypeError", ... }` gives a blocked result with that cause.
  - Projection no-code arm: `transformEnvelope` with `lifecycle: undefined` gives `HANDOFF_VALIDATOR_UNAVAILABLE` and `destination-projection: TypeError`.
  - Projection code arm: `expressionSchemaId: "codex.orchestrator-state"` gives `HANDOFF_UNSUPPORTED_VERSION` and `destination-projection: HANDOFF_UNSUPPORTED_VERSION`.
  - Reuse `createScenario` from `orchestration-handoff-materializer-test-support.ts`.
- `orchestration-handoff-failure-cause-authority.test.ts`: add `envelopeText?: string` to `AuthorityCase`. `runAuthority` already hashes the envelope text at `:63-68`, so the request hash stays consistent. Add row A7 `envelopeText: "{"`, which gives `HANDOFF_UNSUPPORTED_VERSION` and `envelope-parse: HANDOFF_UNSUPPORTED_VERSION`.
- Regression-first: R1-R4 rows fail on the current tree because the cause is absent or the name is unfiltered. The A7 and projection rows fail with `failureCause` `undefined`.
- No temporary files, no wall-clock reads, no network.

## Numeric Derivation Evidence

### Claim N1: catch sites in the four modules = 16

- Complete Family: every `catch` clause in `src/lib/validate/orchestration-handoff-{authority-service,materializer,materializer-production,materializer-request}.ts`.
- Exhaustive Search Scope: those four files on the current worktree.
- Inclusion Rules: any `catch` keyword that begins a catch clause, whether bound or bare.
- Exclusion Rules: comments and strings (none found).
- Primary Search Strategy or Query Expression: Grep content `catch \(` over the four files.
- Primary Member Set: authority 140, 150, 177; production 33, 50; materializer 167, 182, 282, 309, 363, 373, 397, 407, 439, 451, 484.
- Primary Count: 16.
- Cross-check Search Strategy or Query Expression: Grep content `\bcatch\b` (word match, which also catches bare `catch {` and any comment), with line numbers.
- Cross-check Member Set: identical 16 file:line pairs.
- Cross-check Count: 16.
- Member-set Comparison: the normalized sets are identical. A count query `catch\s*\{|catch\s*\(` also returned 3/2/11 = 16.

### Claim N2: blocked-after-catch sites without a cause = 3

- Complete Family: the 16 sites of N1 whose catch body returns, or feeds, a blocked result.
- Exhaustive Search Scope: the 16 catch bodies and their consumers.
- Inclusion Rules: the catch body builds a blocked result, or a validation result that becomes one, with no `failureCause`.
- Exclusion Rules: site 50 (production) returns a message array, not a blocked result. Its consumer attaches a cause per #645 D1.
- Primary Search Strategy or Query Expression: full Read of each catch body (section 2 table).
- Primary Member Set: authority 150; production 33; materializer 282.
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: Grep `catch \(` with `-A 6` over authority-service and production, plus a Grep of `failureCause:|describeHandoffFailureCause` lines in materializer.ts mapped to the enclosing catch. A site counts as lacking a cause when neither token appears in its body or consumer.
- Cross-check Member Set: authority 150; production 33; materializer 282. The materializer cause lines 169, 184, 313, 378, 386, 412, 420, 443, 455, 485 map to sites 167, 182, 309, 363/373, 397/407, 439, 451, 484. No cause line falls in 282-293.
- Cross-check Count: 3.
- Member-set Comparison: identical.

## Automation Feasibility

All work can be done by agents without human interaction:

- source edits in four production files;
- test additions and the test-file split;
- a docs edit to #645 `spec.md:189`;
- toolchain runs through `npm`/`npx` in `extensions/drm-copilot`.

No credentials, UI, external service, or manual verification is needed. The one manual note in the issue (the AC-8 amendment) is a text edit that an agent can make.
