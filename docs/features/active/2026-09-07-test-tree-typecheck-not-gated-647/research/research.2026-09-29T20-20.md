# Research: Gate the extension test-tree type check (Issue #647)

- Timestamp: 2026-09-29T20-20
- Issue: #647
- Branch: `bug/test-tree-typecheck-not-gated-647`
- Feature folder: `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647`
- Work mode: full-bug (preparation-mode orchestration)
- Baseline input: `evidence/baseline/tsc-jest-diagnostics.2026-09-29T20-15.log` (origin/main 43c9e95e)
- Baseline command: `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
- Baseline EXIT_CODE: 2
- Consolidated scope: #645 R20 (missing `INDEPENDENT_CONTEXT` in `test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`) is in scope. #645 R16-R19 are out of scope.

All file:line citations were verified by reading or searching files in this worktree on 2026-09-29. Paths below are relative to `extensions/drm-copilot/` unless they start with `.github/`, `.claude/`, `docs/`, or `tests/`.

---

## 1. Configuration Analysis

### 1.1 The two tsconfig files

| Setting | `tsconfig.json` | `tsconfig.jest.json` |
|---|---|---|
| Base | none (no `extends`) | `"extends": "./tsconfig.json"` (`:2`) |
| `rootDir` | `"src"` (`:8`) | `"."` (`:4`) |
| `isolatedModules` | not set | `true` (`:5`) |
| `types` | `["node"]` (`:19`) | `["node", "jest"]` (`:6`) |
| `include` | `["src/**/*.ts"]` (`:23`) | `["src/**/*.ts", "test/**/*.ts"]` (`:8`) |
| Strict flags | `strict`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `noPropertyAccessFromIndexSignature`, `noUnusedLocals/Parameters` (`:9-17`) | inherited unchanged |

There is no further base config. The repository root has its own unrelated `tsconfig.json`/`tsconfig.tests.json`/`tsconfig.jest.json` chain (Section 6.3).

### 1.2 Why the two production files fail only under the jest config

`TS1205` ("Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'") is emitted only when `isolatedModules` is on. `tsconfig.json` does not set it, so `npm run typecheck` (`package.json:209`, `tsc -p ./ --noEmit`) never reports it; `tsconfig.jest.json:5` does.

- `src/lib/codex-native-converter/models.ts:24-36` re-exports from `./models-intermediate` without a `type` modifier. Five of the names are interfaces: `PlannedEmission` (`:25`), `SectionIntent` (`:26`), `SemanticCue` (`:28`), `SourceSection` (`:30`), `TranslationTrace` (`:32`). They are declared as `export interface` at `models-intermediate.ts:89`, `:100`, `:116`, `:130`, `:146`. The other re-exported names (`SectionIntentKind`, `SemanticCueKind`, `TargetRole`) are `const` + `type` pairs (`models-intermediate.ts:30/42`, `:51/63`, `:71/81`) and are not flagged.
- `src/lib/codex-native-converter/index.ts:14-35` re-exports `PlannedEmission` (`:18`), `SectionIntent` (`:21`), `SemanticCue` (`:23`), `TranslationTrace` (`:32`) without `type`; `SourceSection` at `:28` already carries `type` and is not flagged.

Fix: add the inline `type` modifier to the 9 flagged specifiers. The modifier is erased at emit, so runtime behavior is unchanged. These are the only production-file changes required (Section 6.2).

`TS2323`/`TS2484` in `test/extension-test-harness.ts` are not caused by `isolatedModules`: `resolveCodexExecutable` is exported by declaration at `:433` and exported a second time in the trailing export list at `:460`. The diagnostic appears only under the jest config because that config is the only one that includes `test/**`. Fix: remove `resolveCodexExecutable` from the list at `:460`.

### 1.3 Jest and ts-jest configuration

- `jest.config.cjs:7-9`: `transform: { "^.+\\.tsx?$": ["ts-jest", { tsconfig: "<rootDir>/tsconfig.jest.json" }] }`. No ts-jest `diagnostics` or `isolatedModules` option is passed.
- `run-jest.cjs:25-32` spawns `jest --config jest.config.cjs`; it does not change the transform.
- ts-jest version: 29.4.14 (`node_modules/ts-jest/package.json:3`).
- ts-jest reads `isolatedModules` from the parsed tsconfig: `node_modules/ts-jest/dist/legacy/config/config-set.js:228` (`this.isolatedModules = this.parsedTsConfig.options.isolatedModules ?? false`).
- When `isolatedModules` is true the language service is never created (`dist/legacy/compiler/ts-compiler.js:78`, `:97`) and each file is compiled with `transpileModule` (`ts-compiler.js:360-397`). `transpileModule` reports only syntactic diagnostics, so no semantic type error in the test tree can fail a Jest run.

Conclusion: the defect is the absence of any semantic type check that includes `test/**`, not a ts-jest misconfiguration. Keep `isolatedModules: true`; it makes Jest runs fast, and a type check against the same config ensures the checked code is the code Jest compiles.

---

## 2. Error-Class Taxonomy

The 353 diagnostics fall into 11 root-cause classes. Counts were derived per file (Section 9) and cross-checked by independent log greps.

### C1. Untyped `jest.fn()` used with `mockResolvedValue*` (TS2345 "parameter of type 'never'"): 101

- Root cause: `@jest/globals` 30 types `jest.fn()` with no type argument as `Mock<UnknownFunction>` (`node_modules/jest-mock/build/index.d.ts:258`, `:416`). `mockResolvedValue(value: ResolveType<T>)` (`:183`) resolves to `never` for a function whose return type is `unknown` (`:362-364`).
- Representative: `test/extension-test-harness.ts:24-31` declares `showInputBoxMock`, `showQuickPickMock`, `showOpenDialogMock`, `showWarningMessageMock`, `showInformationMessageMock`, `showErrorMessageMock`, `openTextDocumentMock`, and `showTextDocumentMock` as bare `jest.fn()`. `test/codex-worktree-session-command.test.ts:44` calls `showInputBoxMock.mockResolvedValueOnce("Start the Codex session.")`. Local copies of the same pattern: `test/extension-command-helpers.test.ts:21-23`, `test/repo-automation-command-registration-admin.test.ts:13`, `test/subagent-tree-command.test.ts:27-28`.
- Canonical fix: give each host mock an explicit signature, for example `jest.fn<(options?: unknown) => Promise<string | undefined>>()` for input boxes and `jest.fn<(items: unknown, options?: unknown) => Promise<unknown>>()` for quick picks. When a test calls `mockImplementation` with typed parameters (class C2), the declared parameter types must match those parameters.
- Cascade: the harness exports these mocks. Typing them in `extension-test-harness.ts` clears the `never` errors in all eight harness-consuming files that have diagnostics (Phase 5, 73 diagnostics after the harness's own 7). The files that declare local mocks need per-file fixes.

### C2. `mockImplementation` with typed parameters on an `UnknownFunction` mock (TS2345 "parameter of type 'UnknownFunction'"): 20

- Representative: `test/extension-test-harness.ts:381` (`openTextDocumentMock.mockImplementation(async (uri: { fsPath: string }) => ...)`), `test/extension-command-helpers.test.ts:173`, `test/repo-automation-execute-discovery.test.ts:59`, `test/lib/validate/orchestration-handoff-materializer-production.test.ts:102`.
- Canonical fix: declare the mock with the implementation's signature, for example `jest.fn<(uri: { fsPath: string }) => Promise<{ uri: { fsPath: string } }>>()`. Do not widen the implementation's parameters to `unknown` plus casts.

### C3. Mock signature arity drift in typed matchers (TS2554, TS2352, TS2493, TS2339, TS2556): 13 + 2 + 1 + 2 + 2 = 20

- Root cause: `expect(mock).toHaveBeenCalledWith(...expected: MockParameters<T>)` is typed from the mock's parameters (`node_modules/expect/build/index.d.ts:191`, `:195`). A mock built as `jest.fn(() => Promise.resolve())` or `jest.fn<() => X>()` has zero parameters, so asserting arguments fails.
- Representative: `test/repo-automation-command-registration-admin.test.ts:107` (`jest.fn(() => Promise.resolve())`) asserted with one argument at `:127`; `test/codex-native-converter-handlers.test.ts:22` (`jest.fn<() => Promise<...>>()`) asserted at `:37`; `test/extension.potential-to-issue.test.ts:303-309` (`toHaveBeenNthCalledWith` with 3 arguments). In the harness, `createTerminalMock = jest.fn((): MockTerminal => ...)` (`test/extension-test-harness.ts:40`) makes `mock.calls[0]` type `[]`. That produces TS2352 at `test/codex-worktree-session-command.test.ts:52` and `test/extension.workflow-commands.test.ts:286`, and TS2493 at `test/extension.run-poshqc-commands.test.ts:208`. TS2556 at `test/subagent-tree-command.test.ts:54-56` spreads `unknown[]` into zero-parameter mocks (`:50-51`). The TS2339 at `test/mcp-server.test.ts:439` and the one at `test/extension.run-poshqc-commands.test.ts:237` come from a handler or service type whose return is `void | Promise<void>`, or from a non-`Mocked` member.
- Canonical fix: declare the real parameter list on the mock, for example `jest.fn((_selection: PushDownSelection) => Promise.resolve())` or `jest.fn<RepoAutomationService["runCodexNativeConverter"]>()`. For `createTerminalMock`, add an options parameter to the harness declaration.

### C4. `FileSystem` test doubles missing `exists`/`isDirectory`/`listDirectory` (TS2345 + TS2739 + TS2420): 50 + 34 + 9 = 93

- Root cause: `src/lib/file-system.ts:25-89` now declares `exists` (`:46`), `isDirectory` (`:56`), and `listDirectory` (`:70`). Older fakes implement only `glob`/`isFile`/`readTextFile`/`writeTextFile`/`ensureDir`.
- Class fakes (TS2420 at the class, TS2345/TS2739 at every use): `test/lib/collect-commit-context.test-helpers.ts:58` (shared by `collect-commit-context.test.ts` and `collect-commit-context.run-git.test.ts`), `test/lib/json-config.test.ts:51`, `test/lib/markdown-label-formatter.test.ts:21`, `test/lib/new-potential-bug-entry.test.ts:31`, `test/lib/new-potential-bug-entry-service-call.test.ts:19`, `test/lib/validate/evidence-locations.test.ts:16`, `test/lib/validate/json-validator.test.ts:47`, `test/lib/validate/validate-orchestration-service-call.test.ts:18`, `test/repo-automation-orchestration-validation.test.ts:168`.
- Object-literal stubs (TS2739): `test/lib/resolve/file-prompt-core.test.ts:19`, `file-prompt-variables.test.ts:36`, `hard-lock-prompt.test.ts:26`, `resolve-prompts-service-call.test.ts:21`, `test/lib/validate/build-validate-orchestration-service-call-input.test.ts:11`, `test/lib/validate/evidence-locations.test.ts:123`, `:146`, `test/repo-automation-dispatch.test.ts:159`, `test/repo-automation-hard-lock-prompt.test.ts:53`, `test/repo-automation-service.resolve-atomic-plan-prompt.test.ts:42`.
- Canonical fix: add the three members to each fake. Unused members throw `new Error("not used")`, matching `collect-commit-context.test-helpers.ts:62-72`. Fakes that need tree semantics can follow `test/lib/codex-native-converter/in-memory-file-system.ts:56-81`, which already implements all eight members. One edit to each class clears every use-site error in its file. The single edit to `collect-commit-context.test-helpers.ts` clears 18 diagnostics across 3 files.

### C5. `noPropertyAccessFromIndexSignature` (TS4111): 50

- 37 are `process.env.PATH` / `process.env.PATHEXT`, for example `test/extension-test-harness.ts:346-347`, `test/lib/executable-resolver.test.ts:196-236`, and `test/extension.collect-pr-context-gh-resolution.test.ts:170-217`. 13 are record-field reads in `test/lib/codex-native-converter/models.test.ts:149-347` and `parser.test.ts:75-107`.
- Canonical fix: bracket access (`process.env["PATH"]`, `record["target_path"]`). Runtime behavior is identical and no line count changes.

### C6. `noUncheckedIndexedAccess` (TS2532, TS18048, TS2322 at `parallel-kickoff-template-seam.test.ts:103`): 38 + 1 + 1 = 40

- Representative: `test/remove-worktrees.test.ts:28-31` (`entries[0].path`), `test/lib/validate/epic-orchestrator-state-core.test.ts:148` (`features[1]["depends_on"] = ...`), `test/mcp-provider.test.ts:182`, `test/lib/push-down/claude-config-carriage.test.ts:171`/`:199`, and `test/lib/validate/parallel-kickoff-template-seam.test.ts:103` (`return match[1]`).
- Canonical fix: in assertions, use optional chaining (`expect(entries[0]?.path).toBe(...)`). The assertion still fails clearly if the element is missing, and no assertion operator is needed. At mutation sites and helper returns, add an explicit guard that throws a descriptive error (`const second = features[1]; if (second === undefined) throw new Error(...)`). A small file-local helper is acceptable where one file has many sites; `epic-orchestrator-state-core.test.ts` has 16. Non-null `!` has repository precedent (61 occurrences across 10 test files), but prefer guards because `.claude/rules/typescript.md:23` discourages unjustified assertions.

### C7. `exactOptionalPropertyTypes` (TS2379): 3

- `test/lib/pr-context/gh-client-core.test.ts:30`: `this.calls.push({ args, options })`. Fix: `...(options ? { options } : {})`, the pattern already used at `collect-commit-context.test-helpers.ts:36`.
- `test/repo-automation-dispatch-pr-context-verification.test.ts:93`: `fileSystem: FileSystem | undefined`. Fix: conditional spread.
- `test/lib/validate/build-validate-orchestration-service-call-input.test.ts:75-89` passes explicit `undefined` for five optional flags. Fix: omit the keys. The production builder branches on `=== undefined` (`src/lib/validate/build-validate-orchestration-service-call-input.ts:44-58`), so an omitted key and an explicit `undefined` take identical branches and coverage is unchanged. Widening the production parameter type is not required.

### C8. Request and contract literal drift (TS2740, TS2322, TS2345): 5

- R20: `test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts:182-190` builds a `TransitionPreparedOrchestrationRequest` without the independent expected context. Fix: spread `INDEPENDENT_CONTEXT` from `test/lib/validate/orchestration-handoff-materializer-test-support.ts:42-53`, as that module does at `:291`. Override `expectedWorkspaceRoot: "C:/workspace"` so the context matches this scenario's `workspaceRoot` (`:183`). The materializer only forwards these fields (`src/lib/validate/orchestration-handoff-materializer-request.ts:22-41`) to the mocked topology and routing resolvers, so the observable assertions at `:231-266` are unaffected. The same file's TS2554 at `:255` belongs to C3 (the `gitStatus` mock arity).
- `test/lib/validate/orchestration-handoff-authority-service.test.ts:99` (`expectedWorkMode` typed `string`, not `PortableHandoffWorkMode`) and `:150` (`unknown` to `string`). Fix: narrow with a type guard or type the fixture field.
- `test/lib/validate/plan-gate-discrimination-cov.test.ts:135`: the literal lacks the required `taskText`. Fix: add `taskText`.
- `test/mcp-server-test-service.ts:58`: `transitionPreparedOrchestration` is optional on `RepoAutomationService` (`src/repo-automation-service-contract.ts:186-188`), so `jest.Mocked<>` leaves it unmapped. Fix: `jest.fn<NonNullable<RepoAutomationService["transitionPreparedOrchestration"]>>()`. The optional `resolveOrchestrationTopology`/`resolveProviderRouting` (`:180-185`) are not mocked here.

### C9. Record narrowing and indexing (TS2322, TS7053, TS2769): 2 + 1 + 1 = 4

- `test/lib/validate/epic-orchestrator-state-launch-binding.test.ts:5-10` and `epic-planner-state-launch-binding.test.ts:10`: `record()` returns the `object`-narrowed value as `Record<string, unknown>`. Fix: a type-guard predicate `isRecord(value): value is Record<string, unknown>`.
- `test/lib/validate/orchestration-handoff-contract.test.ts:94`: `current[segment]` on `any[] | Record<string, unknown>`. Fix: branch on `typeof segment`/`Array.isArray` as done at `:84-87`.
- `test/lib/push-down/claude-config-carriage.test.ts:171` (TS2769, `Object.keys` of a possibly-undefined value). Fix: use the same guard as C6 (the TS18048 at `:199` in the same file is counted in C6).

Class totals: C1 101 + C2 20 + C3 20 + C4 93 + C5 50 + C6 40 + C7 3 + C8 5 + C9 4 + C10 5 + C11 12 = 353.

### C10. Node `fs` overload, Buffer, and negative-input typing (TS2345): 5

- `test/lib/file-system.test.ts:129`, `:170` and `test/lib/new-active-feature-folder/models.test.ts:48`: `readdirSync` is mocked as `jest.MockedFunction<typeof fs.readdirSync>` (`file-system.test.ts:14-16`). Its overload set requires a `string[]` return, while the implementation returns `Dirent[]`. Fix: type the mock as the `withFileTypes` overload, `jest.MockedFunction<(path: fs.PathLike, options: { withFileTypes: true }) => fs.Dirent[]>`.
- `test/lib/push-down/filesystem-adapter.test.ts:165`: `"content" as unknown as Buffer`. Fix: `mockReturnValue("content")`. The parameter union already accepts `string`, so the cast is removed.
- `test/lib/push-down/claude-pack-selection.test.ts:82`: `manifestJson([1, 2, 3])` for a deliberate non-object negative test. Fix: widen the file-local `manifestJson` helper parameter to `unknown` (it only feeds `JSON.stringify`).

### C11. Structural (TS1205, TS2323, TS2484): 9 + 2 + 1 = 12

See Section 1.2.

### Per-code reconciliation

TS2345 178 = C1 101 + C4 50 + C2 20 + 7 others. The 7 others are C10's `file-system.test.ts:129`, `:170`, `new-active-feature-folder/models.test.ts:48`, `claude-pack-selection.test.ts:82`, and `filesystem-adapter.test.ts:165`, plus C8's `orchestration-handoff-authority-service.test.ts:150` and `plan-gate-discrimination-cov.test.ts:135`. The per-code totals in the log are TS2345 178, TS4111 50, TS2532 38, TS2739 34, TS2554 13, TS2420 9, TS1205 9, TS2322 5, TS2379 3, and 2 each for TS2556, TS2352, TS2339, TS2323, plus 1 each for TS7053, TS2769, TS2740, TS2493, TS2484, TS18048. That sums to 353.

### Shared helpers whose fix cascades

| Helper | Diagnostics in helper | Consumer diagnostics cleared or enabled |
|---|---|---|
| `test/extension-test-harness.ts` | 7 | C1/C3 errors in 8 consumer files (73 diagnostics, Phase 5) |
| `test/lib/collect-commit-context.test-helpers.ts` | 1 | 17 in `collect-commit-context.test.ts` and `collect-commit-context.run-git.test.ts` |
| `test/mcp-server-test-service.ts` | 1 | TS2339 at `test/mcp-server.test.ts:439` |

`test/lib/validate/orchestration-handoff-materializer-test-support.ts` has no diagnostics and is the source of the R20 fix. A single shared `VirtualFileSystem` module was considered and rejected (Section 3.2).

---

## 3. Phasing

### 3.1 Phases

Every file with a diagnostic appears in exactly one phase. Each helper is in the same phase as its consumers. Each phase leaves the Jest suite green, because the fixes are type-level. Counts are diagnostics per file.

**Phase 1: codex-native-converter production re-exports and lib FileSystem fakes (12 files: 2 src + 10 test; 74 diagnostics)**
1. `extensions/drm-copilot/src/lib/codex-native-converter/index.ts` (4)
2. `extensions/drm-copilot/src/lib/codex-native-converter/models.ts` (5)
3. `extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts` (9)
4. `extensions/drm-copilot/test/lib/codex-native-converter/parser.test.ts` (4)
5. `extensions/drm-copilot/test/codex-native-converter-handlers.test.ts` (1)
6. `extensions/drm-copilot/test/lib/collect-commit-context.test-helpers.ts` (1)
7. `extensions/drm-copilot/test/lib/collect-commit-context.run-git.test.ts` (4)
8. `extensions/drm-copilot/test/lib/collect-commit-context.test.ts` (13)
9. `extensions/drm-copilot/test/lib/json-config.test.ts` (14)
10. `extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts` (5)
11. `extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts` (5)
12. `extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts` (9)

**Phase 2: remaining `test/lib` outside `validate/` (11 files; 22 diagnostics)**
1. `extensions/drm-copilot/test/lib/executable-resolver.test.ts` (10)
2. `extensions/drm-copilot/test/lib/file-system.test.ts` (2)
3. `extensions/drm-copilot/test/lib/new-active-feature-folder/models.test.ts` (1)
4. `extensions/drm-copilot/test/lib/pr-context/gh-client-core.test.ts` (1)
5. `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` (2)
6. `extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts` (1)
7. `extensions/drm-copilot/test/lib/push-down/filesystem-adapter.test.ts` (1)
8. `extensions/drm-copilot/test/lib/resolve/file-prompt-core.test.ts` (1)
9. `extensions/drm-copilot/test/lib/resolve/file-prompt-variables.test.ts` (1)
10. `extensions/drm-copilot/test/lib/resolve/hard-lock-prompt.test.ts` (1)
11. `extensions/drm-copilot/test/lib/resolve/resolve-prompts-service-call.test.ts` (1)

**Phase 3: `test/lib/validate` state and validator tests (9 files; 49 diagnostics)**
1. `extensions/drm-copilot/test/lib/validate/build-validate-orchestration-service-call-input.test.ts` (2)
2. `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (16)
3. `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` (1)
4. `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` (1)
5. `extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts` (7)
6. `extensions/drm-copilot/test/lib/validate/json-validator.test.ts` (13)
7. `extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts` (1)
8. `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-cov.test.ts` (1)
9. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (7)

**Phase 4: portable handoff and MCP service mocks, including R20 (8 files; 15 diagnostics)**
1. `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` (4)
2. `extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts` (1)
3. `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts` (2; R20)
4. `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts` (2)
5. `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts` (3)
6. `extensions/drm-copilot/test/mcp-server-test-service.ts` (1)
7. `extensions/drm-copilot/test/mcp-server.test.ts` (1)
8. `extensions/drm-copilot/test/mcp-provider.test.ts` (1)

**Phase 5: `extension-test-harness.ts` and its consumers (9 files; 80 diagnostics)**
1. `extensions/drm-copilot/test/extension-test-harness.ts` (7)
2. `extensions/drm-copilot/test/codex-worktree-session-command.test.ts` (12)
3. `extensions/drm-copilot/test/extension.discovery-commands.test.ts` (9)
4. `extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts` (5)
5. `extensions/drm-copilot/test/extension.resolve-policy-audit-template.test.ts` (1)
6. `extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts` (8)
7. `extensions/drm-copilot/test/extension.run-poshqc-suite.test.ts` (2)
8. `extensions/drm-copilot/test/extension.test.ts` (3)
9. `extensions/drm-copilot/test/extension.workflow-commands.test.ts` (33)

**Phase 6: extension command tests with file-local mocks (10 files; 51 diagnostics)**
1. `extensions/drm-copilot/test/extension-command-helpers.test.ts` (16)
2. `extensions/drm-copilot/test/extension.collect-commit-context.integration.test.ts` (1)
3. `extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts` (12)
4. `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` (5)
5. `extensions/drm-copilot/test/extension.integration.test.ts` (5)
6. `extensions/drm-copilot/test/extension.new-active-feature-folder-inprocess.test.ts` (2)
7. `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` (2)
8. `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` (4)
9. `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` (2)
10. `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` (2)

**Phase 7: repo-automation, worktree, PoshQC, and subagent-tree tests (12 files; 62 diagnostics)**
1. `extensions/drm-copilot/test/poshqc-folder-picker.test.ts` (6)
2. `extensions/drm-copilot/test/push-down-claude-handler.test.ts` (1)
3. `extensions/drm-copilot/test/remove-worktrees-runner.test.ts` (3)
4. `extensions/drm-copilot/test/remove-worktrees.test.ts` (16)
5. `extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts` (11)
6. `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` (1)
7. `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` (4)
8. `extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts` (2)
9. `extensions/drm-copilot/test/repo-automation-hard-lock-prompt.test.ts` (1)
10. `extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts` (9)
11. `extensions/drm-copilot/test/repo-automation-service.resolve-atomic-plan-prompt.test.ts` (1)
12. `extensions/drm-copilot/test/subagent-tree-command.test.ts` (7)

**Phase 8: gate and regression guard (no diagnostic-bearing files)**
- `extensions/drm-copilot/package.json`: add `typecheck:test` and chain it into `typecheck` (Section 4).
- `.github/workflows/_drm-copilot-extension-tests.yml`: add the type-check step.
- New `extensions/drm-copilot/test/package-typecheck-script.test.ts`: the regression guard (Section 5).
- Acceptance: `npm --prefix extensions/drm-copilot run typecheck` exits 0, and the baseline command exits 0 with zero `error TS` lines.

Totals: 71 files (2 src + 69 test tree, of which 3 are helper modules and 66 are `*.test.ts`). Diagnostics: 74 + 22 + 49 + 15 + 80 + 51 + 62 = 353.

### 3.2 Rejected alternatives

- **Consolidate the five local `VirtualFileSystem` classes into one shared module.** This is reusable in principle. However, the classes differ in behavior per file, and consolidation would move semantics across 5 test files. Adding three members in place is smaller and does not couple unrelated suites.
- **Baseline ratchet (fail only on new diagnostics).** This needs a committed baseline file and a comparison script. The backlog is mechanical and fully enumerated, so a clean gate is achievable in the same change.

---

## 4. Gate Design

### 4.1 Current state

- `.github/workflows/ci.yml:29-30` calls `_drm-copilot-extension-tests.yml`. Its only steps are checkout, setup-node, `npm --prefix extensions/drm-copilot ci` (`:26-27`), and `npm --prefix extensions/drm-copilot run test` (`:29-30`).
- No CI job runs the extension `typecheck` or `lint` script. `_quality-checks.yml:54-80` is Python only (Black, Ruff, Pyright, Pytest). `_build-check.yml` is Poetry packaging. `_root-typescript-tests.yml:26-30` runs the root package's `npm test`.
- `publish-extension.yml:37` runs `run test`, and `:56` runs `run compile`. `publish-mcp-npm.yml:37` runs `run test`. The extension `package.json` has no `vscode:prepublish` script (a search for `prepublish` in the file returned no match), so the publish path is `compile` only.
- `compile` and `build` (`package.json:203-204`) run `tsc -p ./ --noEmit` and then the esbuild bundles. They are src-only and must stay that way.

### 4.2 Recommendation: option (a) plus a one-step workflow addition

1. In `extensions/drm-copilot/package.json`:
   - `"typecheck:test": "tsc -p tsconfig.jest.json --noEmit"`
   - `"typecheck": "tsc -p ./ --noEmit && npm run typecheck:test"`
   - Leave `compile`, `build`, and `test` unchanged. The test tree then does not enter the publish or bundle path, and local Jest runs stay fast.
   - Keep the `tsc -p ./` leg. It checks `src` without `jest` global types, so a production file cannot reference Jest globals. The jest config alone would allow that (`tsconfig.jest.json:6`).
2. In `.github/workflows/_drm-copilot-extension-tests.yml`, insert a step between `:27` and `:29`:
   ```yaml
         - name: Type-check extension source and test tree
           run: npm --prefix extensions/drm-copilot run typecheck
   ```
   It runs on both matrix legs. That is the simplest form; the check is OS-independent and takes a few seconds.

Rationale: option (a) alone does not gate CI, because no workflow runs `typecheck`. Option (b) alone would leave the documented toolchain command `npm run typecheck` (`.claude/rules/typescript.md:15`) reporting success while tests fail. The atomic executor's QC runner also invokes `npm run typecheck` (`tests/scripts/dev_tools/atomic_executor/test_qc_runner.py:472`), so chaining extends the local toolchain loop at no extra cost. Chaining into `test` or `pretest` was rejected: it would add tsc to every local Jest run and to the publish workflows' test step.

### 4.3 Policy and test impacts of the gate change

- `modified-workflow-needs-green-run` (`.claude/skills/feature-review-workflow/SKILL.md:68-70`): a change under `.github/workflows/**` needs a green workflow run against the branch head. The PR's `ci.yml` run satisfies this (`ci.yml:6-7`, `pull_request` into `main`). Record that run as evidence.
- No test asserts on the extension's `package.json` scripts or on `_drm-copilot-extension-tests.yml` content. Searching `tests/` for `drm-copilot-extension-tests`, `"typecheck"`, and `tsconfig.jest` found only the argv at `test_qc_runner.py:472`, which is unaffected. The workflow Pester tests cover only `PublishMcpNpmWorkflow` and `VerifyPublishedReleasesWorkflow`. `test/jest-config-resolution.test.ts:20` mentions the workflow only in a comment.
- `.github/workflows/README.md:18` lists the workflow and its dispatch command. No update is required; an optional one-line note is acceptable.

---

## 5. Policy Constraints and Compliant Fix Patterns

- **No `any`** (`.claude/rules/typescript.md:15`): use explicit mock signatures and `unknown` with guards. The tier table's escape-hatch limit also applies. `quality-tiers.yml` is not present at the worktree root (a read attempt returned "Path does not exist"), so the extension's tier cannot be confirmed here. Assume zero new `any`.
- **Suppressions** (`.claude/rules/typescript-suppressions.md:23-58`): only `// @ts-expect-error -- <reason>` and `// eslint-disable-next-line <rule> -- <reason>` are pre-authorized. `@ts-ignore`, `@ts-nocheck`, and file-level `eslint-disable` are prohibited without user approval. No class above needs a suppression. Do not add one; if one appears necessary, follow the escalation path at `:17-21`.
- **Type assertions** (`.claude/rules/typescript.md:23`): avoid unless justified. `as unknown as` is not explicitly prohibited and is already widespread in tests (for example `test/repo-automation-command-registration-admin.test.ts:78`, `test/mcp-provider.test.ts:172`). Do not add new instances where a typed mock or guard works. The C10 `readdirSync` mock may keep its existing cast to a narrower overload signature.
- **ESLint on tests**: `eslint.config.mjs:4-17` applies `tseslint.configs.recommended` to `src/**` and `test/**` with `project: false`. `no-non-null-assertion` is not in the recommended set. Prefer optional chaining and guards anyway (C6).
- **500-line limit** (`.claude/rules/general-code-change.md`, "File Size Limit"): line counts measured with a `^` count search:
  - `test/extension.workflow-commands.test.ts` is 800 lines, a pre-existing violation acknowledged in the file at `:155-165`. Fixes there must be net non-positive in line count.
  - At or near the limit: `extension.collect-pr-context.test.ts` 499, `repo-automation-dispatch.test.ts` 499, `subagent-tree-command.test.ts` 499, `orchestration-handoff-authority-service.test.ts` 495, `extension.integration.test.ts` 491, `remove-worktrees.test.ts` 485, `mcp-server.test.ts` 483, `extension-test-harness.ts` 471.
  - Fixes in these files must not grow them past 500 after Prettier. Bracket access (C5) and optional chaining (C6) are line-neutral. For typed `jest.fn<...>()` declarations, check the post-Prettier line count.
  - Adding the three `FileSystem` members costs about 9-12 lines per class. The largest class-fake file, `repo-automation-orchestration-validation.test.ts`, is 454 lines, so it stays under the limit.

---

## 6. Risks

### 6.1 Runtime behavior risk from typing fixes

- Low overall. Type arguments, `type` modifiers, bracket access, and optional chaining are erased or runtime-identical.
- Changes that do alter runtime code paths:
  - The R20 request gains the independent context. It is forwarded to mocked resolvers only (Section C8). Run the file to confirm all 6 cases still pass.
  - Guards that throw on missing array elements (C6) change only the failure message when a fixture is wrong.
  - `build-validate-orchestration-service-call-input.test.ts` omits keys instead of passing `undefined`; the same branches execute (C7).
  - The new `FileSystem` members on "not used" fakes throw if the code under test starts calling them. This surfaces an existing hidden dependency rather than creating one; the suites pass today without those members.
  - Removing the duplicate export at `extension-test-harness.ts:460` removes a redundant CommonJS assignment.
- Verification: the full `npm --prefix extensions/drm-copilot run test` must pass after each phase.

### 6.2 Production files changed

Only `src/lib/codex-native-converter/models.ts` and `src/lib/codex-native-converter/index.ts` change, and only by adding `type` modifiers to export specifiers. No executable line changes, so coverage on changed lines is unaffected. Neither file is in the `coverageThreshold` map in `jest.config.cjs`. After the change, confirm that `npm --prefix extensions/drm-copilot run compile` (the esbuild bundles) still succeeds. The effect of the currently untyped re-export on the esbuild output was not verified.

### 6.3 Root-level TypeScript

The root package does not share this defect. Root `tsconfig.json:23` includes `tests/**/*.ts`, and root `pretest` (`package.json:33`) runs `compile` (`:28`, `tsc -p ./`), so `_root-typescript-tests.yml:29-30` (`npm test`) type-checks the root test tree. This is out of scope.

### 6.4 Out-of-scope observations (not to be fixed here)

- No CI job runs the extension `lint` script.
- `eslint.config.mjs:11` sets `project: false` and uses `recommended`, not the `strict-type-checked` stack described in `.claude/rules/typescript.md:34-38`.
- `test/extension.workflow-commands.test.ts` exceeds 500 lines (pre-existing).

---

## 7. Feasibility Verdict

**Land #647 as one item (gate plus all fixes) in a single PR, executed as the 8 phases above with the gate last.**

Rationale:
- All 353 diagnostics are enumerated and mapped to 11 mechanical classes with known fix patterns. No class needs a production behavior change, a suppression, or a dependency.
- Three helper edits (harness, commit-context helpers, MCP test service) resolve about 100 diagnostics.
- Splitting would either ship fixes without a gate, allowing new drift in the interval, or require a ratchet script and baseline file that would be deleted when the gate lands.
- Each phase is bounded to at most 12 files and keeps the Jest suite green. If a phase exceeds its budget, the executor can pause between phases without leaving a red gate, because the gate is added only in Phase 8.
- The diff is broad (71 files plus 2 config files plus 1 new test) but shallow; most edits are 1-3 lines per diagnostic.

---

## 8. Testing Implications

- **Regression guard (fail before, pass after):** new `extensions/drm-copilot/test/package-typecheck-script.test.ts`. It loads `package.json` (following the `require` pattern and single-line `eslint-disable-next-line @typescript-eslint/no-require-imports -- <reason>` at `test/jest-config-resolution.test.ts:36-37`) and asserts:
  1. `scripts.typecheck` invokes `typecheck:test`.
  2. `scripts["typecheck:test"]` references `tsconfig.jest.json`.
  3. `scripts.compile` and `scripts.build` do not reference `tsconfig.jest.json`, so the test tree stays out of the publish path.
  Assertions 1 and 2 fail at baseline. It reads no temporary files.
- **Gate evidence:**
  - Fail-before: the existing baseline log (EXIT_CODE 2, 353 diagnostics).
  - Pass-after: rerun the same command and `npm --prefix extensions/drm-copilot run typecheck`, and record EXIT_CODE 0 under `evidence/qa-gates/`.
- **Toolchain per phase:** `npm run format` then `lint`, then `typecheck` (while phases 1-7 are in progress, use `typecheck:test` or the baseline command and confirm that the phase's files report zero diagnostics), then `test`. Coverage (`test:coverage`) must not regress on changed lines; only test files and export specifiers change.
- **Workflow:** a green PR CI run of `drm-copilot-extension-tests` (both OS legs) at the branch head.

---

## 9. Numeric Derivation Evidence

### N1. Total diagnostics = 353; distinct files = 71 (2 src + 69 test tree)

- **Complete Family:** every line matching `error TS` in `evidence/baseline/tsc-jest-diagnostics.2026-09-29T20-15.log`, and the set of distinct file paths prefixing those lines.
- **Exhaustive Search Scope:** the full log (492 lines, read in two pages: lines 1-316 and 317-492).
- **Inclusion Rules:** a line beginning `extensions/drm-copilot/<path>(<line>,<col>): error TS<code>:`.
- **Exclusion Rules:** indented continuation lines (message elaboration) are not diagnostics.
- **Primary Search Strategy or Query Expression:** manual per-file tally while reading the log end to end, recording each file's diagnostic count and codes.
- **Primary Member Set:** the 71 files listed in Section 3.1 Phases 1-7, with the per-file counts shown there.
- **Primary Count:** 353 diagnostics; 71 files.
- **Cross-check Search Strategy or Query Expression:**
  1. Grep count `error TS` on the log: 353.
  2. Grep `-o` of `^extensions/drm-copilot/[^(]+` to extract one path per diagnostic.
  3. On that extract, seven anchored exact-path alternation counts, one regex per phase. The regexes are disjoint because each alternation lists full paths ending in `$`.
- **Cross-check Member Set:** the seven phase regexes. Their counts were 74, 22, 49, 15, 80, 51, 62, which sum to 353. Every extracted path line therefore matches exactly one listed file, and no unlisted file exists. Directory-bucket counts on the same extract also agree: `src/` 9, `test/lib/` 144 (`test/lib/validate/` 58), `test/extension*` 119, `test/(repo-automation|remove-worktrees|poshqc|push-down-claude|subagent-tree)` 62, `test/(mcp|codex)` 19. These sum to 353.
- **Cross-check Count:** 353 diagnostics; 71 files (the union of the phase alternations).
- **Member-set Comparison:** the primary per-phase sums (74/22/49/15/80/51/62) equal the cross-check regex counts phase by phase, and every primary file has a count of at least 1. The sets agree. The issue's earlier figure (331/69) is superseded by 353/71 at 43c9e95e.

### N2. Class counts (C1 101, C2 20, C4 93, C5-PATH 37, and the TS2532/TS2554/TS1205/TS2379/TS2322 group total 68)

- **Complete Family:** the `error TS` lines of the same log, partitioned by message.
- **Exhaustive Search Scope:** the full log.
- **Inclusion Rules:**
  - C1: TS2345 with `parameter of type 'never'`.
  - C2: TS2345 with `parameter of type 'UnknownFunction'`.
  - C4: TS2345, TS2739, or TS2420 whose message names `FileSystem'`.
  - C5-PATH: TS4111 on `PATH`/`PATHEXT`.
- **Exclusion Rules:** the TS2322 at `mcp-server-test-service.ts:58` mentions `Mock<UnknownFunction>` but is not a TS2345 and is excluded from C2.
- **Primary Search Strategy or Query Expression:** manual per-file sub-tally during the end-to-end read. For C1, the per-file counts were 11, 12, 1, 9, 3, 5, 1, 6, 2, 2, 31, 6, 9, 3 = 101. For C4: 50 + 34 + 9. For C2: 4, 1, 1, 3, 3, 2, 2, 2, 2 = 20.
- **Primary Member Set:** the per-file entries named in Section 2.
- **Primary Count:** C1 101; C2 20; C4 93; C5-PATH 37; group 38 + 13 + 9 + 3 + 5 = 68.
- **Cross-check Search Strategy or Query Expression:** Grep counts on the log for `error TS2345: .*parameter of type 'never'` (101), `error TS2345: .*parameter of type 'UnknownFunction'` (20), `error TS(2345|2739|2420): .*FileSystem'` (93), `error TS4111: Property '(PATH|PATHEXT)'` (37), and `error TS(2532|2554|1205|2379|2322): ` (68).
- **Cross-check Member Set:** the lines matched by each regex.
- **Cross-check Count:** 101; 20; 93; 37; 68.
- **Member-set Comparison:** every primary and cross-check count agrees.

---

## Automation Feasibility

No human interaction is required.
- All fixes are mechanical source edits with known patterns.
- The gate uses existing scripts and one workflow step.
- The workflow green-run evidence is produced by the PR's automatic `ci.yml` run.
- No suppression requiring user approval is anticipated.

A human decision would be needed only if an executor concludes that a suppression outside the pre-authorized `@ts-expect-error -- <reason>` / `eslint-disable-next-line <rule> -- <reason>` patterns is unavoidable. Under `.claude/rules/typescript-suppressions.md:17-21`, that requires explicit user approval. No such case was identified.
