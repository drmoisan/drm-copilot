<!-- markdownlint-disable-file -->

# Task Research Notes: TypeScript engineer agent definition (repo-aligned)

## Research Executed

### File Analysis

- `/workspaces/drm-copilot/.github/agents/python-typed-engineer.agent.md`
  - Verified the reference agent structure and enforcement model: precedence of policy docs, absolute guardrails, explicit scope/budget gates, phased workflow (baseline → plan → implement → final QA), and a mandatory toolchain order.
- `/workspaces/drm-copilot/.github/instructions/typescript-code-change.instructions.md`
  - Verified repo TypeScript “law”: required toolchain (Prettier → ESLint → TSC → Jest), avoidance of `any`, separation of pure logic from VS Code/I/O, and suppression governance via the TS suppression policy.
- `/workspaces/drm-copilot/.github/instructions/typescript-suppressions.instructions.md`
  - Verified the only pre-authorized suppression formats: single-line `eslint-disable-next-line` for one rule with a concrete reason, and single-line `@ts-expect-error -- reason`. Prohibits file-level ESLint disables, `@ts-ignore`, and `@ts-nocheck`.
- `/workspaces/drm-copilot/.github/instructions/typescript-unit-test.instructions.md`
  - Verified Jest-only unit test rules: tests must not require VS Code host; isolation expectations; preferred `afterEach(() => { jest.resetAllMocks(); })`; prefer fake timers or injected clocks.
- `/workspaces/drm-copilot/package.json`
  - Verified the exact script names and their semantics:
    - `format`: Prettier writes formatting across `src/`, `tests/`, and key config files.
    - `lint`: `eslint src tests`.
    - `typecheck`: `tsc -p ./ --noEmit`.
    - `test:unit`: `jest --config jest.config.cjs`.
    - `test:integration`/`test`: `vscode-test`.
  - Verified relevant devDependencies (selected): `typescript@^5.9.3`, `eslint@^9.39.2`, `typescript-eslint@^8.52.0`, `jest@^30.0.0`, `ts-jest@^29.4.0`, `prettier@^3.6.0`, `@vscode/test-cli@^0.0.12`, `@vscode/test-electron@^2.5.2`.
- `/workspaces/drm-copilot/eslint.config.mjs`
  - Verified ESLint uses a flat config and the repo’s lint script targets `src` and `tests`.
- `/workspaces/drm-copilot/jest.config.cjs`
  - Verified unit tests run in `node` env; match `tests/unit/**/*.test.ts`; use `ts-jest` with `tsconfig.jest.json`.
- `/workspaces/drm-copilot/tsconfig.json`
  - Verified strict compiler posture for the repo (selected flags): `strict: true`, `exactOptionalPropertyTypes: true`, `noUncheckedIndexedAccess: true`, `noImplicitReturns: true`, `noUnusedLocals: true`, `noUnusedParameters: true`, `noPropertyAccessFromIndexSignature: true`.
- `/workspaces/drm-copilot/.vscode-test.mjs`
  - Verified integration test runner uses `@vscode/test-cli` `defineConfig({ files: "out/test/**/*.test.js" })`.
- `/workspaces/drm-copilot/tests/unit/*.test.ts` (sample)
  - Verified real test patterns:
    - `extension.test.ts`: virtual `vscode` mock (`jest.mock(..., { virtual: true })`), `jest.clearAllMocks()` in `beforeEach`.
    - `input-collection.test.ts` + `workspace-context.test.ts`: `afterEach(() => { jest.resetAllMocks(); })` pattern.
    - `tool-preflight.test.ts`: deterministic manipulation/restoration of `process.env.PATH` within a `try/finally`.

### Code Search Results

- `resetAllMocks\(|clearAllMocks\(|restoreAllMocks\(|useFakeTimers\(`
  - Matches found in:
    - `tests/unit/extension.test.ts` (`jest.clearAllMocks()`)
    - `tests/unit/input-collection.test.ts` (`jest.resetAllMocks()`)
    - `tests/unit/workspace-context.test.ts` (`jest.resetAllMocks()`)

### External Research

- #fetch:https://typescript-eslint.io/users/what-about-formatting
  - Verified guidance to keep formatting concerns in Prettier (or a dedicated formatter), and avoid running Prettier via ESLint rules/plugins for performance and ergonomics.
- #fetch:https://jestjs.io/docs/jest-object
  - Verified definitions of key isolation APIs:
    - `jest.clearAllMocks()` clears calls/instances/results.
    - `jest.resetAllMocks()` resets state (equivalent to `.mockReset()` everywhere).
    - `jest.restoreAllMocks()` restores spies/replaced properties (works for `jest.spyOn` and `jest.replaceProperty` only).
  - Verified fake timer APIs and their configuration surface (`jest.useFakeTimers({ doNotFake, now, timerLimit, ... })`, `jest.useRealTimers()`, `advanceTimersByTime`, `runOnlyPendingTimers`, etc.).
- #fetch:https://jestjs.io/docs/timer-mocks
  - Verified canonical usage patterns for fake timers and “recursive timer” tests using `runOnlyPendingTimers()`.
- #fetch:https://github.com/microsoft/vscode-test-cli/blob/main/src/config.cts
  - Verified `@vscode/test-cli` configuration schema details (examples):
    - `files` (glob(s) relative to `.vscode-test.*` location)
    - `version` (stable/insiders/version/commit)
    - `extensionDevelopmentPath`, `workspaceFolder`, `launchArgs`, `env`, `installExtensions`, etc.

### Project Conventions

- Standards referenced: repo “toolchain loop” and “scope/budget gates” conventions (from the Python engineer agent), plus TypeScript policy docs under `.github/instructions/`.
- Instructions followed:
  - `.github/instructions/general-code-change.instructions.md` (referenced by policy chain)
  - `.github/instructions/general-unit-test.instructions.md` (no temp files / no external dependencies)
  - `.github/instructions/typescript-code-change.instructions.md`
  - `.github/instructions/typescript-suppressions.instructions.md`
  - `.github/instructions/typescript-unit-test.instructions.md`

## Key Discoveries

### Project Structure

- Agent templates live under `.github/agents/` and currently include 28 templates; `python-typed-engineer.agent.md` is the closest structural reference.
- TypeScript source lives under `src/`; unit tests under `tests/unit/`; integration tests are run via `vscode-test` (VS Code extension host tooling).

### Implementation Patterns

- The repo’s enforceable TS toolchain is explicitly defined by scripts and TS policy docs:
  - Prettier via `npm run format`
  - ESLint via `npm run lint`
  - TSC typecheck via `npm run typecheck`
  - Jest unit tests via `npm run test:unit`
- ESLint configuration is intentionally lightweight at present; it uses the typescript-eslint parser/plugin.
- Unit tests show two mock-hygiene patterns in use (`clearAllMocks` in `beforeEach` vs `resetAllMocks` in `afterEach`). Policy prefers the latter; the TS engineer agent should codify a consistent default while acknowledging existing tests.
- Repo TS compilation is strict and includes flags that strongly discourage unsafe indexing and optional property misuse (`noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noPropertyAccessFromIndexSignature`). This pushes “great TS” behavior toward:
  - preferring `unknown` + narrowing;
  - explicit domain types and runtime guards at boundaries;
  - eliminating unchecked index access.

### Complete Examples

```typescript
// Verified in this repo: virtual mocking of VS Code APIs in Jest unit tests.
jest.mock(
  "vscode",
  () => ({
    window: {
      showInputBox: jest.fn(),
    },
  }),
  { virtual: true },
);

afterEach(() => {
  // Repo policy preferred pattern for isolation.
  jest.resetAllMocks();
});
```

### API and Schema Documentation

- `@vscode/test-cli` supports a `.vscode-test.(js|mjs|json)` configuration where `files` selects the compiled JS tests to execute. Repo uses `files: "out/test/**/*.test.js"`.

### Technical Requirements

- The new TypeScript engineer agent must be consistent with:
  - TypeScript policy toolchain commands and ordering.
  - TS suppression policy’s allowed formats.
  - Jest unit test isolation requirements (no VS Code host for unit tests).
  - General unit test policy prohibiting temp files and external dependencies.
- The agent should be grounded in repo reality:
  - current minimal ESLint rules;
  - strict `tsconfig.json` compiler flags;
  - existing unit test patterns.

**Mandatory unachievable objective callout**:
- None found. Creating a TypeScript engineer agent definition file under `.github/agents/` appears feasible within current repo conventions.

## Recommended Approach

Draft a new agent definition under `.github/agents/` that mirrors the *structure and hard gates* of `python-typed-engineer.agent.md`, but swaps in the TypeScript toolchain and TypeScript-specific engineering heuristics.

Key properties to encode (all are grounded in verified repo policy/config):

- **Policy precedence**: explicitly cite `.github/instructions/general-code-change.instructions.md` and the TS-specific instruction files (code change, suppressions, unit tests).
- **Absolute guardrails**:
  - scope/budget gates (adapt the Python agent’s 3-prod/3-test “batch” gate and “approval required” expansion model), while fitting TS work patterns.
  - prohibit new dependencies unless explicitly approved.
  - prohibit broad suppressions; enforce pre-authorized patterns only.
- **Phased workflow**:
  - Phase A baseline capture (read-only): confirm scope and current toolchain status.
  - Phase B plan: explicit list of API changes, contracts, boundary seams, and test plan.
  - Phase C implement in small batches: maintain the toolchain loop and enforce “hard stop” on regressions.
  - Phase D final QA: run full toolchain in order and report deltas.
- **Toolchain hard gate order (repo scripts)**:
  1) `npm run format`
  2) `npm run lint`
  3) `npm run typecheck`
  4) `npm run test:unit`
- **TS “great engineer” heuristics**:
  - avoid `any` and type assertions; prefer `unknown` + narrowing.
  - use discriminated unions for stateful flows.
  - isolate VS Code APIs behind small adapters so unit tests do not require the extension host.
  - in tests, prefer `afterEach(jest.resetAllMocks)`; use fake timers or injected clocks for time.

## Implementation Guidance

- **Objectives**: Create a new TS engineer agent template that (1) matches the reference Python agent’s rigor and gating model, (2) enforces this repo’s TS toolchain and suppression rules, and (3) sets high standards for strict, testable TypeScript.
- **Key Tasks**:
  - Choose filename + name/description metadata for the new agent.
  - Mirror the Python agent’s “role/objective”, “guardrails”, “phases”, and “reporting requirements” sections.
  - Replace Python-specific commands with repo TS scripts.
  - Encode suppression policy verbatim (only pre-authorized patterns).
  - Encode Jest unit testing policy and observed repo patterns.
- **Dependencies**: None required to *draft* the agent file.
- **Success Criteria**:
  - Agent file lives under `.github/agents/` and is consistent with repo policies.
  - Toolchain commands cited match `package.json` scripts.
  - Suppression patterns match `typescript-suppressions.instructions.md` exactly.
  - Guidance does not contradict repo config.
