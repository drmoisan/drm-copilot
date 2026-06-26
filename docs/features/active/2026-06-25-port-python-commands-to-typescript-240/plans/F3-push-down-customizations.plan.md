# Plan — F3 `ts-push-down-customizations` (Epic #240)

- Issue: #240
- Feature: F3 — port the three push-down command variants (copilot, codex+agents, claude) to in-process TypeScript and wire the three `RepoAutomationService` methods.
- Work mode: full-feature
- Authoritative inventory: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/research/python-to-typescript-inventory.md` (Section 7.2 F3; Section 2.7 cluster F; Section 6.6; Section 6.7).
- Spec: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/spec.md`.
- Toolchain: `extensions/drm-copilot/` uses **Jest** (`ts-jest`, `run-jest.cjs`), NOT Vitest (see spec decision D1). All tests use `@jest/globals`, `jest.fn()`, `jest.mock`, AAA.

## Evidence Location Invariant

All evidence artifacts MUST be written under
`docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Writing to
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other
non-canonical path is a policy violation caught by the
`enforce-evidence-locations.ps1` PreToolUse hook. This clause is non-overridable.

Evidence base path (abbreviated `<EV>` below):
`docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence`

## Scope and Constraints (binding)

- REUSE the F1 shared lib at `extensions/drm-copilot/src/lib/`: `file-system.ts`,
  `subprocess-runner.ts`, `json-config.ts`. Do NOT re-port them. NOTE: the F1
  `FileSystem` interface (`glob`/`isFile`/`readTextFile`/`writeTextFile`/`ensureDir`)
  does NOT match the Python `PushDownFileSystem` protocol
  (`list_files`/`is_dir`/`is_file`/`read_text`/`write_text`/`ensure_dir`). F3
  therefore introduces a dedicated push-down filesystem protocol in
  `filesystem-adapter.ts` (the TS port of
  `push_down_copilot_customizations_filesystem.py`) — this is a new interface, not
  a re-port of F1 `file-system.ts`.
- Source of truth for behavior is the BUNDLED Python under
  `extensions/drm-copilot/resources/scripts/dev_tools/` (the copies the service
  invokes). The `scripts/dev_tools/` copies are references only.
- No production, test, or reusable script file may exceed 500 lines. Split any
  file that would exceed 500 lines.
- Line coverage >= 85%, branch coverage >= 75% on new files (uniform tier policy).
- Tests must be hermetic: inject the push-down filesystem; no temp files, no real
  subprocess, in-memory fakes only.
- ES modules, strong typing, no `any`; kebab-case filenames; AAA test structure.
- Do NOT modify `command-runtime.ts`, the `"python"` branch, or Python
  `scripts/dev_tools/**` / `resources/**/*.py` (removal is F11).
- `repo-automation-service.ts` is ~498 lines; do NOT push it over 500. Route all
  new wiring through `push-down-service-call.ts` (new helper) and the existing
  `repo-automation-service-push-down.ts`. The three service methods change to
  call the new helper instead of `this.executeScript(...)`.

## TS target files (all under `extensions/drm-copilot/src/lib/push-down/` unless noted)

- `copilot-customizations-engine.ts` — engine half of the 504-line copilot module
  (enumerate/validate/artifact-path/render/write-summary/`pushDownCustomizations`).
- `copilot-customizations.ts` — public entry + CLI-equivalent surface
  (`resolveCliPath`, public `pushDownCustomizations` re-export, summary types).
- `filesystem-adapter.ts` — `PushDownFileSystem` interface + `RealPushDownFileSystem`.
- `reference-rewrites.ts` — rewrite catalog + `rewriteTextReferences`.
- `codex-agents-customizations.ts` — `.codex`/`.agents` push-down + passthrough rewrite.
- `claude-customizations.ts` — claude entry + `_resolvePublishedPaths` + pack arg parsing.
- `claude-filesystem-adapter.ts` — frontmatter scope parser + `ExcludingFileSystem`.
- `claude-pack-selection.ts` — manifest load/validate, path compute, variant routing,
  C# exclusion assertion.
- `push-down-service-call.ts` — service wiring helper for the three methods.
- (Split any file projected over 500 lines into `-engine`/`-core` companions; the
  copilot split is mandatory and pre-declared above.)

## Test target files (all under `extensions/drm-copilot/test/lib/push-down/`)

- `filesystem-adapter.test.ts`
- `reference-rewrites.test.ts`
- `copilot-customizations-engine.test.ts`
- `copilot-customizations.test.ts`
- `codex-agents-customizations.test.ts`
- `claude-pack-selection.test.ts`
- `claude-filesystem-adapter.test.ts` (includes memory-scope frontmatter cases)
- `claude-customizations.test.ts` (includes pack end-to-end + bundled-parity)
- `push-down-service-call.test.ts`
- `push-down.test-helpers.ts` (in-memory `PushDownFileSystem` fake + builders;
  shared by the above; not a `*.test.ts` file so Jest does not treat it as a suite)

## Source-root wiring facts (preserve exactly)

- Copilot template resolves `source_root`/`repo_root` to
  `<extensionRoot>/resources/customizations`; `artifact_root` to the workspace
  (cwd in the Python path). The service result preserves
  `summary: "Pushed bundled Copilot customizations into the destination workspace."`
  and the artifact path parsed from `Wrote push-down summary artifact to: <path>`.
- Codex/agents template resolves source/repo root to
  `<extensionRoot>/resources/codex-and-agents-customizations`; root folders
  `(.codex, .agents)`; passthrough rewrite; artifact dir
  `artifacts/codex-and-agents-customizations`.
- Claude template resolves source/repo/bundle root to
  `<extensionRoot>/resources/claude-customizations`; root folders `(.claude,)`;
  passthrough rewrite; artifact dir `artifacts/claude-customizations`; manifests
  under `<bundle>/pack-manifests`; legacy variant under
  `<bundle>/.claude-variants/csharp-legacy/`.
- `agentic_sync.ROOT_FOLDERS` (copilot) inlines to the typed tuple
  `(".github/agents", ".github/instructions", ".github/prompts", ".github/skills")`.
- Destination/artifact roots: the in-process port writes the summary artifact and
  copied files through the injected filesystem; the service helper supplies the
  destination root (= `input.workspaceRoot`) and an artifact root that preserves
  the prior `artifact_root` semantics (workspace root). The parsed/returned
  artifact path must match the prior `stdoutArtifactPattern` contract value.

---

### Phase 0 — Baseline capture and policy reading

- [x] [P0-T1] Read policy files in required order and record evidence. Read, in order:
  `CLAUDE.md`; `.claude/rules/general-code-change.md`;
  `.claude/rules/general-unit-test.md`; `.claude/rules/typescript.md`;
  `.claude/rules/typescript-suppressions.md`;
  `.claude/rules/quality-tiers.md`;
  `.claude/rules/architecture-boundaries.md`;
  `.claude/rules/self-explanatory-code-commenting.md`;
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Write
  `<EV>/baseline/phase0-instructions-read.md` containing `Timestamp:`,
  `Policy Order:`, and the explicit list of files read. Acceptance: the artifact
  exists and lists every file above.

- [x] [P0-T2] Capture TypeScript format baseline. From `extensions/drm-copilot/`
  run `npm run format`. Write `<EV>/baseline/baseline-ts-format.md` with
  `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, `Output Summary:`.
  Acceptance: artifact exists with all four fields populated.

- [x] [P0-T3] Capture TypeScript lint baseline. From `extensions/drm-copilot/`
  run `npm run lint`. Write `<EV>/baseline/baseline-ts-lint.md` with
  `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, `Output Summary:`.
  Acceptance: artifact exists with all four fields populated.

- [x] [P0-T4] Capture TypeScript type-check baseline. From
  `extensions/drm-copilot/` run `npm run typecheck`. Write
  `<EV>/baseline/baseline-ts-typecheck.md` with `Timestamp:`,
  `Command: npm run typecheck`, `EXIT_CODE:`, `Output Summary:`. Acceptance:
  artifact exists with all four fields populated.

- [x] [P0-T5] Capture TypeScript test + coverage baseline. From
  `extensions/drm-copilot/` run
  `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`. Write
  `<EV>/baseline/baseline-ts-test-coverage.md` with `Timestamp:`,
  `Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`,
  `EXIT_CODE:`, and `Output Summary:` that records numeric headline values:
  total tests passed/failed and the `src/lib/**` line% and branch% from the
  coverage table. Acceptance: artifact exists and `Output Summary:` contains
  numeric line% and branch% values (not placeholders).

---

### Phase 1 — Copilot sub-cluster (engine, filesystem, rewrites)

- [x] [P1-T1] Create `extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts`
  porting `push_down_copilot_customizations_filesystem.py`. Define the
  `PushDownFileSystem` interface (`listFiles`, `isDir`, `isFile`, `readTextFile`,
  `writeTextFile`, `ensureDir`; all path args as forward-slash POSIX strings) and
  `RealPushDownFileSystem` backed by `node:fs` with recursive sorted enumeration,
  UTF-8 read, and LF-normalized write (mirror Python `newline="\n"`). Acceptance:
  file compiles under `npm run typecheck`, exports both symbols, stays <= 500 lines.

- [x] [P1-T2] Create
  `extensions/drm-copilot/test/lib/push-down/push-down.test-helpers.ts`
  providing an in-memory `PushDownFileSystem` fake (deterministic sorted
  `listFiles`, tracked directories, in-memory text store) mirroring the Python
  `RecordingFileSystem`, plus a builder for seeding files. Acceptance: helper
  compiles under typecheck; it is NOT named `*.test.ts`.

- [x] [P1-T3] Create
  `extensions/drm-copilot/test/lib/push-down/filesystem-adapter.test.ts`
  (Jest, AAA) covering `RealPushDownFileSystem` behavior using the injected
  in-memory paths where possible and `node:fs` mocks otherwise: empty enumeration
  for a missing root, sorted file enumeration, `isDir`/`isFile` predicates, read,
  and write with parent-dir creation. Acceptance: `node run-jest.cjs` runs this
  suite green.

- [x] [P1-T4] Create
  `extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts` porting
  `push_down_copilot_customizations_rewrites.py`. Replicate exactly:
  `TRAILING_PUNCTUATION`, the `SCRIPT_REFERENCE_PATTERN` regex, `RewriteTarget`
  type, `buildRewriteCatalog` (all seven catalog entries with identical
  `normalizedKey`/`commandId`/`title`/`scriptReference`/`isPlaceholder` values),
  `renderCommandReference`, `normalizeReferenceForLookup`,
  `splitTrailingPunctuation`, `rewriteMatchedReference`, and `rewriteTextReferences`
  returning `[text, rewrittenCount, placeholderCount, unmatchedRefs]` with
  first-seen unmatched ordering. Acceptance: file compiles, exports
  `rewriteTextReferences`, stays <= 500 lines.

- [x] [P1-T5] Create
  `extensions/drm-copilot/test/lib/push-down/reference-rewrites.test.ts`
  (Jest, AAA) porting `test_push_down_copilot_customizations_rewrites.py` and the
  rewrite cases in `test_push_down_copilot_customizations_helpers.py`: each catalog
  entry rewrite, trailing-punctuation preservation, `${workspaceFolder}` and
  slash-variant normalization, `poetry run python -m` prefix stripping, unmatched
  reference reporting with deterministic order and counts, and no-match passthrough.
  Acceptance: suite green; covers every catalog key.

- [x] [P1-T6] Create
  `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts`
  porting the engine half of `push_down_copilot_customizations.py`: inline
  `ROOT_FOLDERS` tuple (Section 6.7), `PushDownFileResult`/`PushDownSummary` types,
  `PushDownSummaryPayload` shape, `enumerateSourceFiles` (root-order then
  path-order), `validateDestination` (identical error messages for missing dir and
  destination==source), `buildArtifactPath` (`push-down-%Y%m%dT%H%M%SZ.json` under
  the artifact directory), `renderPushDownSummary` (JSON `indent=2, sort_keys=true`
  semantics: 2-space indent with sorted keys; `files` rendered via per-result object
  with the same field names), `writeSummaryArtifact`, and the core
  `pushDownCustomizations` orchestration (validate → enumerate → per-file
  created/overwritten classification → rewrite → ensureDir → write → accumulate
  counts and first-seen unmatched → write artifact → return summary with
  `artifactPath`). Use an injected clock seam for `startedAt`/`finishedAt`
  (no direct `Date.now()` in production code, per typescript.md). Acceptance: file
  compiles, stays <= 500 lines; `renderPushDownSummary` produces deterministic
  sorted-key 2-space JSON.

- [x] [P1-T7] Create
  `extensions/drm-copilot/src/lib/push-down/copilot-customizations.ts` porting the
  public/CLI-facing surface of `push_down_copilot_customizations.py`:
  `resolveCliPath` (preserve the Windows-absolute-on-POSIX guard semantics in a
  Node-equivalent form), the `ARTIFACT_DIRECTORY` constant
  (`artifacts/copilot-customizations`), and a public `pushDownCustomizations`
  wrapper that defaults `rewriteReferences` to `rewriteTextReferences` and
  `rootFolders` to the inlined copilot tuple. Re-export the engine summary types.
  Acceptance: file compiles, stays <= 500 lines, exports the public entry.

- [x] [P1-T8] Create
  `extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts`
  (Jest, AAA, injected fake FS + fixed clock) porting
  `test_push_down_copilot_customizations.py` core scenarios: destination-missing
  error, destination-equals-source error, created-vs-overwritten classification,
  deterministic root+path enumeration order, rewrite counters and unmatched
  aggregation, summary artifact written at the deterministic path, and the
  returned summary `artifactPath`. Acceptance: suite green.

- [x] [P1-T9] Create
  `extensions/drm-copilot/test/lib/push-down/copilot-customizations.test.ts`
  (Jest, AAA) porting `test_push_down_copilot_customizations_helpers.py` (non-rewrite
  helpers): `resolveCliPath` behavior, `buildArtifactPath` naming, summary JSON
  shape parity (`renderPushDownSummary` keys, sorted, 2-space), and the public
  wrapper defaults. Acceptance: suite green; asserts the exact JSON key set
  `repo_root, destination_root, started_at, finished_at, created_count,
  overwritten_count, rewritten_reference_count, placeholder_rewrite_count,
  unmatched_references, files`.

---

### Phase 2 — Codex/agents sub-cluster

- [x] [P2-T1] Create
  `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`
  porting `push_down_codex_and_agents_customizations.py`: inline
  `ROOT_FOLDERS = (".codex", ".agents")`, `ARTIFACT_DIRECTORY =
  "artifacts/codex-and-agents-customizations"`, a passthrough rewrite
  (`[text, 0, 0, []]`), and a `pushDownCustomizations` that delegates to the shared
  copilot engine with those root folders, artifact directory, and the passthrough
  rewrite. Acceptance: file compiles, stays <= 500 lines, reuses the engine
  (no duplicated copy logic).

- [x] [P2-T2] Create
  `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts`
  (Jest, AAA, injected fake FS + fixed clock) porting
  `test_push_down_codex_and_agents_customizations.py`: `.codex`/`.agents` tree copy
  with deterministic ordering, passthrough leaves content byte-identical and yields
  zero rewrite/placeholder counts and no unmatched references, artifact written
  under the codex/agents artifact directory, and created-vs-overwritten
  classification. Acceptance: suite green.

---

### Phase 3 — Claude sub-cluster (pack selection, filtering FS, entry)

- [x] [P3-T1] Create
  `extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts` porting
  `push_down_claude_pack_selection.py`: constants `CORE_PACK_NAME`,
  `CSHARP_CANONICAL_PATHS` (the four exact paths), `CSHARP_PACK_NAMES`,
  `LEGACY_VARIANT_SOURCE_PREFIX`, `CSharpVariant`/`MemoryMode` literal unions,
  `ManifestError`, `PackManifest` type, `loadPackManifests` (always includes
  `core`, sorted deterministic load, identical missing/invalid-JSON/non-object/
  bad-name/bad-label/bad-paths/bad-source_prefix error messages),
  `_parseManifest`, `computePublishedPaths` (union + always-core, `None`/undefined
  for empty selection, error for missing loaded manifest),
  `resolveVariantSourcePath` (legacy C# routing; modern/non-C# passthrough), and
  `assertSingleCsharpToolchain` (reject both C# packs with the exact message).
  Acceptance: file compiles, stays <= 500 lines, exports all listed symbols.

- [x] [P3-T2] Create
  `extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts`
  (Jest, AAA) porting `test_push_down_claude_pack_selection.py`: manifest load
  success, each manifest validation error path with its exact message, `core`
  always loaded, `computePublishedPaths` union and always-core and empty-selection
  -> undefined, `resolveVariantSourcePath` for modern/legacy/non-C# inputs, and
  `assertSingleCsharpToolchain` rejecting both C# packs. Acceptance: suite green;
  asserts the exact error message strings.

- [x] [P3-T3] Create
  `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` porting
  `push_down_claude_filesystem.py`: constants `AGENT_MEMORY_RELATIVE_ROOT`,
  `GENERAL_MEMORY_SCOPE`, `REPO_MEMORY_SCOPE`; the three regexes
  (`_FRONTMATTER_PATTERN`, `_METADATA_BLOCK_PATTERN`, `_SCOPE_LEAF_PATTERN`) with
  identical semantics (CRLF tolerance, DOTALL frontmatter, metadata block capture,
  scope-leaf capture, quote stripping, exact `general` comparison, fail-safe
  `repo`); `readMemoryScope`; `isGeneralMemoryFile`; and the `ExcludingFileSystem`
  class wrapping a `PushDownFileSystem` with the four enumeration filters
  (hard exclusions, pack inclusion, agent-memory scope, memory mode) plus the
  legacy C# read redirection (`_resolveReadSource`) and the source-relative POSIX
  helper. Preserve the resolved-vs-unresolved root distinction using POSIX path
  normalization (no `Path.resolve()` host dependence; replicate the comparison
  semantics on normalized POSIX strings so tests stay hermetic). Acceptance: file
  compiles, stays <= 500 lines; if projected over 500 lines, split the
  frontmatter-parser helpers into a sibling `claude-memory-scope.ts` and import
  them (declare the split in the task completion note).

- [x] [P3-T4] Create
  `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`
  (Jest, AAA) porting `test_push_down_claude_memory_scope.py` and the
  `ExcludingFileSystem` cases in `test_push_down_claude_customizations.py` and
  `test_push_down_claude_pack_memory_modes.py`: `readMemoryScope` for present
  frontmatter (general, quoted general, with inline comment), absent/unterminated
  frontmatter, no metadata block, no scope leaf, non-general value, and top-level
  scope outside metadata (all fail-safe to `repo`); `isGeneralMemoryFile` for
  in-subtree vs out-of-subtree paths; and `ExcludingFileSystem` filtering for
  hard-excluded `settings.local.json`, pack inclusion/exclusion, scope filtering,
  memory modes `overwrite`/`skip`/`merge` (merge excludes only memories already
  present at destination), and legacy C# read redirection. Acceptance: suite green;
  covers every `readMemoryScope` branch.

- [x] [P3-T5] Create
  `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` porting
  `push_down_claude_customizations.py`: constants `ARTIFACT_DIRECTORY`
  (`artifacts/claude-customizations`), `ROOT_FOLDERS = (".claude",)`,
  `EXCLUDED_RELATIVE_PATHS = (".claude/settings.local.json",)`,
  `BUNDLE_ROOT_RELATIVE_DIR`, `PACK_MANIFEST_SUBDIR`, `CSHARP_VARIANT_CHOICES`,
  `MEMORY_MODE_CHOICES`; the passthrough rewrite; `_resolvePublishedPaths`
  (no manifest read for empty selection, otherwise load + compute + assert);
  `parsePacksArgument` (comma-split, trim, drop empties, undefined for empty);
  and `pushDownCustomizations` composing `ExcludingFileSystem` over the injected
  adapter and delegating to the shared copilot engine with the claude root folders,
  artifact dir, and passthrough rewrite. Preserve `bundleRoot` default
  (`source / BUNDLE_ROOT_RELATIVE_DIR`) AND allow an explicit `bundleRoot`
  (the bundled template passes the customizations dir directly). Acceptance: file
  compiles, stays <= 500 lines; if projected over 500 lines, extract
  `_resolvePublishedPaths` + `parsePacksArgument` into a sibling
  `claude-customizations-core.ts` (declare the split in the completion note).

- [x] [P3-T6] Create
  `extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts`
  (Jest, AAA, injected fake FS + fixed clock) porting
  `test_push_down_claude_customizations.py`,
  `test_push_down_claude_pack_end_to_end.py`, and
  `test_push_down_claude_bundled_parity.py` (and the resource-contract assertions in
  `test_push_down_claude_resource_contracts.py` that are filesystem-checkable via
  the in-memory fake): no-selection publish-everything path performs no manifest
  read; pack selection restricts published paths and always includes core; legacy
  C# variant routes reads to the legacy source while writing canonical destination
  paths; both-C#-packs selection raises the exclusion `ManifestError`; memory
  modes thread through to `ExcludingFileSystem`; `parsePacksArgument` edge cases;
  and summary artifact written under the claude artifact directory. Acceptance:
  suite green.

---

### Phase 4 — Service wiring

- [x] [P4-T1] Create
  `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` providing
  three exported functions —
  `pushDownCopilotCustomizationsServiceCall`,
  `pushDownCodexAndAgentsCustomizationsServiceCall`,
  `pushDownClaudeCustomizationsServiceCall` — each accepting the injected
  `PushDownFileSystem`, the `extensionRoot`, the `workspaceRoot` (destination), an
  optional clock, an optional log sink, and (for claude) `packs`/`csharpVariant`/
  `memoryMode`. Each function resolves the bundled source/bundle root from
  `extensionRoot` (copilot -> `resources/customizations`; codex ->
  `resources/codex-and-agents-customizations`; claude ->
  `resources/claude-customizations`), invokes the matching in-process
  `pushDownCustomizations`, and returns a `RepoAutomationExecutionResult`-shaped
  record preserving the exact prior `tool`, `summary`, and `artifacts` contract:
  - copilot summary: `"Pushed bundled Copilot customizations into the destination workspace."`
  - codex summary: `"Pushed bundled Codex and agents customizations into the destination workspace."`
  - claude summary: `"Pushed bundled Claude Code customizations into the destination workspace."`
  - `artifacts`: a single-element array with the normalized summary artifact path
    (same value the prior `stdoutArtifactPattern` parse produced). Use
    `normalizeGeneratedPath` from `repo-automation-service-support`.
  Acceptance: file compiles, stays <= 500 lines, exports all three functions.

- [x] [P4-T2] Create
  `extensions/drm-copilot/test/lib/push-down/push-down-service-call.test.ts`
  (Jest, AAA, injected fake FS + fixed clock) verifying each of the three service
  -call functions returns the exact `tool`, `summary`, and single-element
  normalized `artifacts` path, resolves the correct bundled source root from
  `extensionRoot`, and threads claude `packs`/`csharpVariant`/`memoryMode`.
  Acceptance: suite green.

- [x] [P4-T3] Update
  `extensions/drm-copilot/src/repo-automation-service-push-down.ts` to export a
  builder/options object (or pass-through input shape) for the claude in-process
  call that replaces `buildPushDownClaudeCustomizationsOptions`' Python arg-vector
  construction. Remove the Python `--destination/--packs/--csharp-variant/
  --memory-mode` arg-building and `bundledRelativePath`/`runtimeKind` fields; the
  new export carries `workspaceRoot` plus the optional `packs`/`csharpVariant`/
  `memoryMode` forwarded to `pushDownClaudeCustomizationsServiceCall`. Acceptance:
  file compiles; no `runtimeKind: "python"` or `resources/templates/...py`
  reference remains in this file.

- [x] [P4-T4] Update `extensions/drm-copilot/src/repo-automation-service.ts`:
  replace the bodies of `pushDownCopilotCustomizations`,
  `pushDownCodexAndAgentsCustomizations`, and `pushDownClaudeCustomizations` so each
  delegates to the matching `push-down-service-call.ts` function (passing
  `this.fileSystem` as a `PushDownFileSystem`, `this.extensionRoot`,
  `input.workspaceRoot`, a log sink wired to `this.output.appendLine`, and — for
  claude — the optional `packs`/`csharpVariant`/`memoryMode`). Remove the three
  `this.executeScript({... runtimeKind: "python" ...})` call sites for these
  methods and the `buildPushDownClaudeCustomizationsOptions` import if it is no
  longer referenced. Do NOT modify `executeScript`, `command-runtime.ts`, or any
  other method. Acceptance: `repo-automation-service.ts` compiles, contains no
  `runtimeKind: "python"` for the three push-down methods, and remains <= 500
  lines (verify the line count after the edit).

- [x] [P4-T5] Reconcile the `RealFileSystem`/`PushDownFileSystem` injection in the
  service constructor. The service currently injects an F1 `FileSystem`
  (`options.fileSystem ?? new RealFileSystem()`). Because `PushDownFileSystem` is a
  distinct interface, add a `RealPushDownFileSystem` instance to the service
  (constructed once, default `new RealPushDownFileSystem()`, overridable via a new
  optional `RepoAutomationServiceOptions.pushDownFileSystem` for tests) and pass it
  to the three service-call helpers. Do NOT change the existing `fileSystem` field
  or other methods' behavior. Acceptance: service compiles; existing
  `validateOrchestrationArtifacts`/`collectCommitContext`/`newPotentialBugEntry`/
  resolve-prompt wiring is unchanged.

---

### Phase 5 — Update existing extension tests that assert a Python spawn

- [x] [P5-T1] Update
  `extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts`
  to assert the in-process behavior instead of a Python spawn: replace the
  `childProcessMock.spawn`/`node:child_process` assertions with assertions on the
  returned `RepoAutomationExecutionResult` (`tool === "push_down_claude_customizations"`,
  the exact `summary`, and an `artifacts` entry) using an injected
  `pushDownFileSystem` fake seeded with a minimal `.claude` tree and pack
  manifests. Preserve the existing invocationId-default and
  packs/variant/memory-mode behavioral cases by asserting they reach the
  in-process port (e.g., pack filtering reflected in copied files / published set),
  not by inspecting spawn args. Acceptance: suite green; no `spawn` assertion for
  this command remains.

- [x] [P5-T2] Update the copilot and codex/agents cases in
  `extensions/drm-copilot/test/extension.integration.test.ts` (the blocks at the
  `push_down_copilot_customizations.py` / `push_down_codex_and_agents_customizations.py`
  spawn assertions, currently around lines 400-490) to assert in-process delegation:
  replace the `executable === "python"` / bundled-template-path spawn assertions
  with assertions that the service returns the preserved `tool`/`summary`/`artifacts`
  contract via the in-process port (mirror the F4 `collectCommitContext` precedent
  that removed its Python spawn integration cases). Use an injected
  `pushDownFileSystem` fake. Do NOT alter unrelated spawn-based cases (PowerShell
  commands, still-Python commands such as `collect_pr_context`, `potential_to_issue`).
  Acceptance: suite green; the two push-down commands no longer assert a Python spawn.

- [x] [P5-T3] Update `extensions/drm-copilot/test/mcp-server.test.ts` and any other
  suite identified by grep (`push_down_copilot_customizations`,
  `push_down_codex_and_agents_customizations`, `push_down_claude_customizations`)
  that asserts a Python spawn or bundled `resources/templates/push_down_*.py`
  path for these three tools. Convert each such assertion to the in-process
  contract (or remove it where it duplicates a now-covered service-call unit test),
  leaving handler-routing and input-resolution assertions intact. Run
  `Grep push_down_.*customizations` across `extensions/drm-copilot/test` to confirm
  no remaining suite asserts a Python spawn for the three commands. Acceptance:
  `node run-jest.cjs` runs the full extension suite green; grep shows no surviving
  Python-spawn assertion for the three push-down tools.

---

### Phase 6 — Final QA loop (full toolchain, coverage-gated)

Run the loop in order. If any step fails or changes files, restart from P6-T1.

- [x] [P6-T1] Run `npm run format` from `extensions/drm-copilot/`. Write
  `<EV>/qa-gates/final-ts-format.md` with `Timestamp:`, `Command: npm run format`,
  `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0 and no unexpected file
  changes (if files changed, restart the loop).

- [x] [P6-T2] Run `npm run lint` from `extensions/drm-copilot/`. Write
  `<EV>/qa-gates/final-ts-lint.md` with `Timestamp:`, `Command: npm run lint`,
  `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0, zero lint errors.

- [x] [P6-T3] Run `npm run typecheck` from `extensions/drm-copilot/`. Write
  `<EV>/qa-gates/final-ts-typecheck.md` with `Timestamp:`,
  `Command: npm run typecheck`, `EXIT_CODE:`, `Output Summary:`. Acceptance:
  EXIT_CODE 0, zero type errors.

- [x] [P6-T4] Run
  `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` from
  `extensions/drm-copilot/`. Write `<EV>/qa-gates/final-ts-test-coverage.md` with
  `Timestamp:`, the exact `Command:`, `EXIT_CODE:`, and `Output Summary:` recording
  numeric post-change values: total tests passed, overall `src/lib/**` line% and
  branch%, AND the per-file line%/branch% for each new
  `src/lib/push-down/*.ts` file. Acceptance: EXIT_CODE 0; every new
  `src/lib/push-down/*.ts` file reports line >= 85% and branch >= 75%.

- [x] [P6-T5] Coverage delta/threshold verification. Compare the Phase 0 baseline
  (`<EV>/baseline/baseline-ts-test-coverage.md`) against the final coverage
  (`<EV>/qa-gates/final-ts-test-coverage.md`). Write
  `<EV>/qa-gates/coverage-delta.md` with `Timestamp:` and a table reporting:
  baseline `src/lib/**` line%/branch%, post-change `src/lib/**` line%/branch%, and
  the new-code (each `src/lib/push-down/*.ts`) line%/branch%. Acceptance: no
  regression in overall `src/lib/**` line% or branch% versus baseline, and every
  new push-down file meets line >= 85% / branch >= 75%. If any value is below
  threshold, the outcome is remediation-required (restart from P6-T1 after adding
  tests); do NOT report PASS.

- [x] [P6-T6] File-size verification. Confirm no new or modified file under
  `extensions/drm-copilot/src/lib/push-down/`,
  `extensions/drm-copilot/src/repo-automation-service.ts`, or
  `extensions/drm-copilot/src/repo-automation-service-push-down.ts` exceeds 500
  lines. Write `<EV>/qa-gates/file-size-check.md` with `Timestamp:`,
  `Command:` (the line-count command used), `EXIT_CODE:`, and `Output Summary:`
  listing each checked file with its line count. Acceptance: every listed file
  <= 500 lines; `repo-automation-service.ts` <= 500 lines.

---

## F3 Acceptance Criteria Checklist

- [x] AC-F3-1: `copilot-customizations-engine.ts` + `copilot-customizations.ts`
  port `push_down_copilot_customizations.py` (split across two files, each <= 500
  lines) with identical enumeration order, created/overwritten classification,
  validation error messages, summary JSON shape (keys, sorted, 2-space), and
  deterministic artifact path naming.
- [x] AC-F3-2: `filesystem-adapter.ts` ports
  `push_down_copilot_customizations_filesystem.py` (`PushDownFileSystem` interface
  + `RealPushDownFileSystem`) with sorted enumeration and LF-normalized writes.
- [x] AC-F3-3: `reference-rewrites.ts` ports
  `push_down_copilot_customizations_rewrites.py` with the identical regex, full
  seven-entry catalog, normalization, trailing-punctuation handling, and
  deterministic unmatched ordering and counts.
- [x] AC-F3-4: `codex-agents-customizations.ts` ports
  `push_down_codex_and_agents_customizations.py` with `.codex`/`.agents` root
  folders, passthrough rewrite, and the codex/agents artifact directory, reusing
  the shared engine.
- [x] AC-F3-5: `claude-pack-selection.ts` ports
  `push_down_claude_pack_selection.py` with identical manifest validation messages,
  always-core union semantics, variant source routing, and C# mutual-exclusion
  assertion.
- [x] AC-F3-6: `claude-filesystem-adapter.ts` ports
  `push_down_claude_filesystem.py` with the regex-based frontmatter memory-scope
  parser (fail-safe `repo` default) and the `ExcludingFileSystem` four-filter
  enumeration plus legacy C# read redirection.
- [x] AC-F3-7: `claude-customizations.ts` ports
  `push_down_claude_customizations.py` with pack selection, C# variant routing,
  memory modes, exclusion of `settings.local.json`, and the claude artifact
  directory.
- [x] AC-F3-8: `repo-automation-service.ts` `pushDownCopilotCustomizations`,
  `pushDownCodexAndAgentsCustomizations`, and `pushDownClaudeCustomizations` invoke
  in-process TypeScript (via `push-down-service-call.ts`) instead of spawning
  Python, preserving the exact `tool`, `summary`, and `artifacts` return contract
  and (for claude) the `packs`/`csharpVariant`/`memoryMode` inputs.
- [x] AC-F3-9: `repo-automation-service.ts` remains <= 500 lines; new wiring is
  routed through `push-down-service-call.ts` and
  `repo-automation-service-push-down.ts`.
- [x] AC-F3-10: Existing extension tests that asserted a Python spawn for the three
  push-down commands are updated to assert the in-process contract; no surviving
  suite asserts a Python spawn for these three tools.
- [x] AC-F3-11: New `src/lib/push-down/**` files are covered by Jest tests with
  line >= 85% and branch >= 75% per file; no overall `src/lib/**` coverage
  regression versus the Phase 0 baseline.
- [x] AC-F3-12: Format, lint, type-check, and coverage-enabled test all pass from
  `extensions/drm-copilot/`.
- [x] AC-F3-13: No file exceeds 500 lines; tests are hermetic (injected
  `PushDownFileSystem`, no real subprocess, no temp files).
- [x] AC-F3-14: No changes to `command-runtime.ts`, the `"python"` branch, or any
  Python `scripts/dev_tools/**` / `resources/**/*.py` file (removal is F11).
