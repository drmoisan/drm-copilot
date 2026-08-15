# blast-radius-module-map-forces-serial-runs (Spec)

- **Issue:** #472
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-15
- **Status:** Ready for Planning
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole acceptance-criteria source; no user-story document exists)

## Context

The blast-radius module level makes every parallel run fully serial, and the module map published to a destination repository describes drm-copilot's own governance payload rather than the destination's layout. A parallel orchestrator pushed down to a destination repository therefore cannot schedule any two items concurrently.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `derive_blast_radius` and `conflicts` from `scripts/dev_tools/compute_blast_radius.py`, read against `config/blast-radius.json`
- Data source or fixture: `config/blast-radius.json` and the published copy at `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The parallel orchestration surface cannot deliver concurrency in any repository, which is its entire purpose.

## Repro & Evidence

Steps to Reproduce:
1. Derive a blast radius for two thematically unrelated items that share no production file. Item A cites `scripts/benchmarks/run.py`; item B cites `extensions/drm-copilot/src/lib/foo.ts`.
2. Call `conflicts(a, b, config)` with the parsed `config/blast-radius.json`.
3. Observe the verdict and reasons.
4. Separately, push the Claude customizations down into a destination repository whose source tree is not organized like drm-copilot (for example a C# solution) and inspect the destination's `config/blast-radius.json`.

Expected:
Two items that share no production file, no shared surface, and no contract identifier are non-contending and belong in the same cohort. A destination repository receives a module map that describes its own source layout, so the module level carries real contention signal there.

Actual:
Two items sharing zero production files conflict:

```
A paths   : ['docs/features/active/.../**', 'scripts/benchmarks/run.py', 'tests/benchmarks/test_run.py']
B paths   : ['docs/features/active/.../**', 'extensions/drm-copilot/src/lib/foo.ts']
CONFLICT  : True
  reason  : module_overlap -> docs
```

Because every pair conflicts, the conflict graph is complete, greedy coloring assigns one item per cohort, and the run is fully serial. A destination-repository parallel planner correctly refuses to emit a plan, reporting that `config/blast-radius.json` forces a fully serial run.

In a destination repository the published module map lists `.claude/**`, `config/**`, `docs/**`, and `tests/**`. Those are drm-copilot's governance-payload directories. None of the destination's own source directories appear, so every real source path there resolves to no module at all.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: see the reproduction output under Actual Behavior.

## Scope & Non-Goals

### Binding owner decisions (encoded in this spec; do not re-litigate)

1. **Defect A fix — drop the location buckets.** Remove the `docs` and `tests` modules from the module map in BOTH `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`. The fix is NOT to exclude item-private paths from module resolution.
2. **Regression gate — required.** A test asserting two items with disjoint production paths produce zero conflict edges, plus a pin that the committed config contains no location-bucket module.
3. **Defect B fix — derive the destination module map from the destination repository's actual layout at push-down time.**
4. **Derivation is scoped to the TypeScript push-down surface ONLY.** This supersedes the "both surfaces" phrasing in the research document. The Python surface publishes `ROOT_FOLDERS = (Path(".claude"),)` and never carries `config/`; it is out of scope and must remain unchanged, including its pinned test at `tests/scripts/dev_tools/test_push_down_claude_customizations.py:80`.

### In scope

- Deleting the `docs` and `tests` module entries from both blast-radius config copies.
- The regression gate: a committed-config test that two items with disjoint production paths produce zero conflict edges, plus a negative pin that no location-bucket module is present in either committed config copy.
- A new destination-layout derivation for `config/blast-radius.json` in the TypeScript push-down surface (`extensions/drm-copilot/src/lib/push-down/`), composed as a write-intercepting decorator with a pure derivation core.
- Rewriting the AC8 genericity test at `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:375` to assert a genericity property instead of equality against a seeded constant, and amending the companion overwrite-semantics test at line 396.
- Amending the "plain overwrite" documentation comment in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (and the referencing comment in `claude-routing-merge.ts`), which currently states that `config/blast-radius.json` is a plain overwrite.

### Out of scope / non-goals

- The Python push-down surface (`scripts/dev_tools/push_down_claude_customizations.py`): no config-carriage port, no routing-merge port, no derivation core, no `ROOT_FOLDERS` change. Its pinned test remains byte-identical.
- A cross-language parity fixture corpus for the derivation. There is exactly one derivation implementation (TypeScript), so no parity corpus is owed.
- Excluding item-private paths (feature folder, test files) from module resolution — explicitly rejected by owner decision 1.
- Deriving the map at destination runtime (first `parallel-plan` run) — contradicts owner decision 3 ("at push-down time").
- Per-stack static default packs or an empty published map — prohibited by owner decision 3.
- The conflict relation, resolver, PowerShell blast-radius mirror code, and bash cohort layer: unchanged. `conflicts()` reads no key from `config` (`_blast_radius_conflicts.py:145-147`); the Defect A fix is entirely truth-table content.
- Widening the six-member `PushDownFileSystem` contract — the derivation uses an injected shallow-lister seam instead.
- `config/orchestration-routing.json` content and the routing-merge behavior.
- `.github/instructions/**` — canonical policy, not modified.

### Explicitly excluded systems, integrations, or datasets

- No network, GitHub API, or destination-repository access is required; all verification is local toolchain execution.
- Issue #452 (blast-radius under-reporting) is related but distinct and is not addressed here.

## Root Cause Analysis

Two distinct defects compose.

**Defect A — universal conflict from location buckets.** `derive_blast_radius` unconditionally injects each item's own feature folder into its paths (`compute_blast_radius.py:265`), because every item writes its own spec, plan, research, and evidence. The module map buckets all of `docs/**` into one module named `docs`. Every item therefore resolves module `docs`, and module overlap is a conflict disjunct (`_blast_radius_conflicts.py:167-177`). The `tests` bucket repeats the defect: repository policy requires every item's tests to live under `tests/**`.

The path level already handles this correctly — `docs/features/active/A/**` and `docs/features/active/B/**` are disjoint globs and produce no path overlap. The module level is a coarser abstraction layered on top, and for location buckets such as `docs` and `tests` it is not a coherent unit of contention; it is a directory that every module's files pass through.

**Defect B — the published default describes the wrong repository.** The module map shipped to a destination is drm-copilot's own layout with entries removed, not a generic or destination-derived map. The two defects compose badly: the module level is fail-closed on the paths carrying no signal (coupling every item into a serial run) and fail-open on the paths carrying all the signal (the destination's real source directories, which resolve to nothing).

The push-down test named `issue #462 AC8: the published blast-radius default is generic` (`extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:375`) asserts genericity and was satisfied by a non-generic document. Its seed constant `SOURCE_BLAST_RADIUS` (lines 64-83) hardcodes the defective `docs` and `tests` buckets, and the test asserts `published == seeded`, so it certified whatever was seeded — including a non-generic document. It is the test that should have caught Defect B.

Related but distinct: issue #452 tracks blast-radius under-reporting. This entry is the over-reporting direction at the module level, plus the destination-map defect.

## Proposed Fix

### Design summary (what changes where)

1. **Config content (Defect A).** Delete the `"docs"` and `"tests"` entries from the `modules` object in both `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`. No other key changes. The repo-root copy retains exactly twelve modules; the bundled copy retains exactly two.
2. **Regression gate (owner decision 2).** Add committed-config tests: disjoint production paths yield zero conflict edges; no committed module is a location bucket.
3. **Destination derivation (Defect B, TypeScript surface only).** Add a write-intercepting `BlastRadiusDeriveFileSystem` decorator modeled on `RoutingMergeFileSystem` (`claude-routing-merge.ts`), composed in `pushDownCustomizations` (`claude-customizations.ts:244-263`). When the shared engine writes the destination-relative path `config/blast-radius.json`, the decorator writes a derived document computed by a pure core from a deterministic observation list of the destination's layout, instead of the bundled bytes.
4. **Failed-gate test rewrite.** Replace the AC8 equality assertion with a genericity-property assertion (see Test Strategy).

### Boundaries and invariants to preserve

- The four contention outcomes verified by the orchestrator against the proposed map must hold (see Test Strategy behavior-preservation matrix).
- The six-member `PushDownFileSystem` contract (`filesystem-adapter.ts:29-53`) is untouched; the shallow lister is a new optional seam on the decorator only.
- The pure derivation core performs no I/O, matching the blast-radius library's purity discipline (`compute_blast_radius.py` docstring).
- `config/orchestration-routing.json` merge behavior and the enumeration-order summary contract are unchanged.
- The Python push-down surface is byte-identical, including `ROOT_FOLDERS == (Path(".claude"),)` and its pin test.
- File size limit 500 lines per production/test file (`.claude/rules/general-code-change.md`); split the derivation core from the decorator if needed.

### Dependencies or blocked work

- None. No new runtime dependencies. All verification runs locally.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

| # | File | Change |
| --- | --- | --- |
| 1 | `config/blast-radius.json` | Delete the `"docs"` and `"tests"` module entries; no other change |
| 2 | `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | Delete the `"docs"` and `"tests"` module entries; no other change |
| 3 | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts` (new) | Derivation decorator plus pure core (core may be a sibling module to respect the 500-line limit) |
| 4 | `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | Compose the decorator adjacent to `RoutingMergeFileSystem` (lines 244-263); amend the "plain overwrite" comment (lines 50-56); add optional `listEntries` member to `ClaudePushDownOptions` |
| 5 | `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | Amend the doc comment stating `config/blast-radius.json` is a plain overwrite |
| 6 | `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | Rewrite the AC8 genericity test (line 375) and amend the overwrite-semantics expectation (line 396); update `SOURCE_BLAST_RADIUS` seed to the corrected bundled document |
| 7 | `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` (new) | Hermetic unit tests for the pure core and decorator via in-memory adapter and injected fake lister |
| 8 | `tests/scripts/dev_tools/test_blast_radius_config.py` | Add the regression-gate and negative-pin tests against the committed config |
| 9 | `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | Add the matching disjoint-items and negative-pin cases to the `Committed blast-radius truth table shape` Describe block |

No Python production file changes. The exact new-test filenames may vary at planning time provided they satisfy the test-location rule (`tests/` tree mirroring source).

#### Functions/classes/CLI commands impacted

- New: `BlastRadiusDeriveFileSystem` decorator; pure core `deriveDestinationModuleMap(observations, sourceDocumentText): string`.
- Amended: `pushDownCustomizations` composition and `ClaudePushDownOptions` (optional `listEntries: (root: string) => ReadonlyArray<{ name: string; isDir: boolean }>`, real default on `fs.readdirSync(..., { withFileTypes: true })`, entries sorted ordinally).
- Unchanged: `derive_blast_radius`, `conflicts`, `resolve_modules`, the PowerShell mirror, the shared push-down engine, and all Python push-down entry points.

#### Data flow and validation changes (derivation algorithm)

Deterministic algorithm, executed once per push against the destination root:

1. **Scan.** Breadth-first from the destination root to depth 3 (top level plus two nested levels), visiting subdirectories in ordinal name order, pruning `EXCLUDED_DIR_NAMES` (`__pycache__`, `artifacts`, `bin`, `build`, `coverage`, `dist`, `doc`, `docs`, `node_modules`, `obj`, `out`, `target`, `test`, `tests`, `venv`) and every name beginning with `.`.
2. **Classify.** A visited directory (never the root itself) is a project directory when its shallow listing contains an exact member of `MANIFEST_FILENAMES` (`build.gradle`, `build.gradle.kts`, `Cargo.toml`, `go.mod`, `package.json`, `pom.xml`, `pyproject.toml`, `setup.py`) or a file ending in a member of `MANIFEST_SUFFIXES` (`.csproj`, `.fsproj`, `.vbproj`, `.sln`, `.slnx`). The root is categorically excluded because a root-level manifest would yield the universal glob `**` — the defect class being fixed.
3. **Prune ancestors.** Drop any project directory that is a proper ancestor of another project directory (leaf granularity maximizes concurrency; an umbrella module would re-couple siblings the way `docs` coupled everything).
4. **Name and glob.** Each remaining project directory becomes one module: name = destination-relative POSIX path; glob = `<relpath>/**`.
5. **Fallback.** If steps 1-4 yield zero modules, every non-excluded top-level directory becomes a module (name = directory name, glob = `<name>/**`).
6. **No-signal floor.** If the fallback also yields zero modules, the emitted map is `PAYLOAD_MODULES` alone (`claude-runtime` → `[".claude/**"]`, `config` → `["config/**"]`). This is a computed outcome for a structureless destination, not a shipped empty default.
7. **Assemble.** Union derived modules with `PAYLOAD_MODULES` (payload wins on name collision); sort module names ordinally; carry `version`, `shared_surfaces`, `shared_surface_globs`, and `over_breadth_fraction` verbatim from the parsed bundled source document; emit keys in the fixed order `version`, `shared_surfaces`, `shared_surface_globs`, `modules`, `over_breadth_fraction`; serialize as `JSON.stringify(document, null, 2) + "\n"`.
8. **Guard.** Fail fast before writing if any emitted glob is `**`, `docs/**`, or `tests/**` — the in-code assertion that the derivation can never recreate the defect it fixes.

Idempotency: a second push scans a destination whose new top-level entries are `.claude` (dot-prefixed, skipped) and `config` (derives or unions to `config` → `config/**`, identical to the payload module), so the derived document is byte-stable across pushes given an unchanged destination layout.

#### Error handling and logging updates

- Unparseable bundled source document: fail fast with an explicit error naming the path, following the `RoutingMergeError` precedent (`claude-routing-merge.ts:57-73`); destination bytes untouched.
- Guard trip (step 8): derivation raises before writing; the push-down fails rather than shipping a serializing map.
- Unreadable destination subdirectory: contributes no entries, mirroring `RealPushDownFileSystem.listFiles` tolerance (`filesystem-adapter.ts:122-127`); the result stays deterministic for identical visibility.

#### Rollback/feature-flag considerations (if applicable)

- No feature flag. Rollback is a revert of the config deletions and the decorator composition; both are additive and isolated.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Derivation core input: a deterministic, already-collected observation list of destination directories plus the bundled source document text. Output: the serialized destination document (single string).
- Resulting repo-root `config/blast-radius.json` `modules` set (exactly twelve): `python-dev-tools`, `powershell-dev-tools`, `poshqc`, `benchmarks`, `claude-runtime`, `codex-runtime`, `copilot-surface`, `agents-surface`, `mcp-server`, `vscode-extension`, `config`, `schemas`.
- Resulting bundled `modules` set (exactly two): `claude-runtime`, `config`. The bundled file remains shipped as the derivation's base document.

#### Required configuration keys and defaults

- No new configuration keys. `ClaudePushDownOptions.listEntries` is optional with a real-filesystem default.

#### Backward-compatibility expectations

- `ClaudePushDownOptions` grows only optional members (non-breaking per `.claude/rules/general-code-change.md`).
- The pack manifest (`core.json`) continues to list `config/blast-radius.json`; file counts and the summary-artifact contract are unchanged (content substitution, not file-set change — the routing merge established this precedent).
- Destination consumption code (PowerShell mirror, bash cohort layer) needs no change; only published map content changes.

#### Performance constraints (latency/throughput/memory)

- The destination scan is depth-limited (3) with directory pruning; it must not perform an unpruned recursive walk of the destination (which would traverse `node_modules`/`.git`).

## Assumptions, Constraints, Dependencies

- Assumptions: the four-outcome verification recorded in `artifacts/orchestration/orchestrator-state.json` (`defect_analysis.verification_of_chosen_fix`) is accurate; the committed config copies are the only two blast-radius truth tables.
- Constraints: no temporary files in tests; hermetic tests only (in-memory adapters, injected fake listers); 500-line file limit; ordinal sorting at every derivation stage.
- Constraint (self-referential blast radius): `config/blast-radius.json` is itself a declared shared surface (`config/blast-radius.json:12`). The implementing item's own declared blast radius must enumerate `config/blast-radius.json` in `shared_surfaces` to satisfy V2 validation (`_blast_radius_validation.py:398-437`).
- External dependencies: none added.

## Data / API / Config Impact

- User-facing or API changes: destination repositories pushed via the TypeScript surface receive a derived `config/blast-radius.json` describing their own layout instead of the bundled bytes.
- Data or migration considerations: none; existing destination files are overwritten on next push (existing overwrite semantics preserved, with derived content).
- Logging/telemetry updates: none beyond the explicit fail-fast errors above.
- Compatibility notes: two module entries removed from each committed config copy; the document schema (keys, types, `version: 1`) is unchanged.

## Test Strategy

### Behavior-preservation matrix (verified outcomes; must be pinned by tests)

The orchestrator verified these four outcomes against the proposed map with `docs` and `tests` removed:

```
disjoint items           conflict=False reasons=none
same production file     conflict=True  reasons=path_overlap->..., module_overlap->python-dev-tools
same test file only      conflict=True  reasons=path_overlap->tests/scripts/dev_tools/test_shared.py
shared surface           conflict=True  reasons=path_overlap->..., module_overlap->config, shared_surface_overlap->...
```

### Regression gate (owner decision 2)

- Python, against the **committed** config (the defect lived in the committed map, so a test-local map proves nothing): in `tests/scripts/dev_tools/test_blast_radius_config.py`, derive two radii with distinct feature folders and disjoint production paths (mirroring the reproduction: `scripts/benchmarks/run.py` plus a matching test file vs `extensions/drm-copilot/src/lib/foo.ts`) and assert `conflicts(...)` is `False` with zero reasons.
- Negative pin, both committed copies: no module named `docs` or `tests`, and no module glob equal to `docs/**` or `tests/**`.
- PowerShell mirror: matching disjoint-items and negative-pin cases in the `Committed blast-radius truth table shape` Describe block of `BlastRadius.Parity.Tests.ps1`, which already reads `config/blast-radius.json`.

### Derivation tests (TypeScript only; no cross-language corpus)

Hermetic Jest tests through the in-memory push-down adapter plus an injected fake lister covering: project-manifest classification (exact names and suffixes), root exclusion, ancestor pruning (monorepo `packages/a` + `packages/b`), the C# solution layout (`Foo/Foo.csproj`, `Foo.Tests/Foo.Tests.csproj` → modules `Foo`, `Foo.Tests`), the top-level fallback, the no-signal floor, determinism (same observations → identical output string), ordinal sorting, the guard (never `**`, `docs/**`, `tests/**`), idempotency (second push byte-stable), unreadable-directory tolerance, and the unparseable-source fail-fast path. No parity fixture corpus is created for the derivation: there is exactly one implementation.

### Failed-gate rewrite (the AC8 genericity test)

`claude-config-carriage.test.ts:375` currently seeds `SOURCE_BLAST_RADIUS` with the defective buckets and asserts `expect(published).toBe(SOURCE_BLAST_RADIUS)` — equality against a seeded constant, which certifies any seeded document as generic. The replacement asserts a genericity PROPERTY: seed a destination layout (for example `src/App/App.csproj`), run the push, and assert the published document (a) contains the derived destination module, (b) does not contain `docs/**`, `tests/**`, or a bare `**` module glob, and (c) does not contain the drm-copilot-only entries already listed (`scripts/dev_tools`, `packages/mcp-server`, `poetry.lock`, `package-lock.json`). No assertion of byte-equality against the seed remains. The companion test at line 396 keeps overwrite semantics (destination file replaced, not merged) with the expectation amended to the derived document.

### Existing-test dispositions

- `tests/scripts/dev_tools/test_push_down_claude_customizations.py:80` — **unchanged and passing** (pins the out-of-scope Python surface).
- `test_blast_radius_config.py` shape parametrization — no amendment needed; removing two modules shrinks the parametrization.
- `test_compute_blast_radius.py`, PowerShell unit suites, and `tests/fixtures/blast_radius/*` — unchanged (test-local configs remain valid resolver inputs).
- `claude-pack-manifest-completeness.test.ts`, AC6/AC16 carriage tests, `tests/shell/parallel_payload_only.bats` — unchanged (path-presence/order assertions only).

### Coverage impact and targets

- New and changed production modules must hold line coverage >= 85% and branch coverage >= 75% per `.claude/rules/general-unit-test.md`; no coverage regression on changed lines. The pure derivation core is fully unit-testable without I/O.

### Toolchain commands to run

- Python: Black → Ruff → Pyright → pytest (Poetry environment).
- TypeScript: Prettier → ESLint → TSC → Jest (`npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`; coverage via `npm run test:unit:coverage`).
- PowerShell: Invoke-Formatter → PSScriptAnalyzer → Pester (via the PoshQC MCP commands).
- Repeat each loop from formatting until a clean single pass per `.claude/rules/general-code-change.md`.

### Manual validation steps (if required)

- None required; every criterion below is verified by a command or a test assertion.

## Acceptance Criteria

Each criterion is independently verifiable by the stated command or assertion.

- [x] **AC1 — Repo-root module map corrected.** `config/blast-radius.json` contains a `modules` object with exactly the twelve keys `python-dev-tools`, `powershell-dev-tools`, `poshqc`, `benchmarks`, `claude-runtime`, `codex-runtime`, `copilot-surface`, `agents-surface`, `mcp-server`, `vscode-extension`, `config`, `schemas`; the keys `docs` and `tests` are absent; all other top-level keys (`version`, `shared_surfaces`, `shared_surface_globs`, `over_breadth_fraction`) are byte-identical to their pre-change values. Verify: parse the file and compare the key set.
- [x] **AC2 — Bundled module map corrected.** `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` contains a `modules` object with exactly the two keys `claude-runtime`, `config`; the keys `docs` and `tests` are absent; all other top-level keys are unchanged. Verify: parse the file and compare the key set.
- [x] **AC3 — Disjoint items no longer conflict.** Against the committed `config/blast-radius.json`, two derived radii with distinct feature folders and disjoint production paths (item A: `scripts/benchmarks/run.py` plus its test file; item B: `extensions/drm-copilot/src/lib/foo.ts`) produce `conflicts(...) == False` with zero reasons. Verify: the new pytest case in `tests/scripts/dev_tools/test_blast_radius_config.py` passes.
- [x] **AC4 — Shared production file still conflicts.** Two items citing the same production file under `scripts/dev_tools/` produce `conflict=True` with reasons including `path_overlap` and `module_overlap -> python-dev-tools`. Verify: pytest assertion against the committed config.
- [x] **AC5 — Shared test file still conflicts.** Two items whose only shared path is the same test file under `tests/**` produce `conflict=True` with a `path_overlap` reason (the path level covers test files after the `tests` bucket is removed). Verify: pytest assertion against the committed config.
- [x] **AC6 — Shared surface still conflicts.** Two items both citing `config/blast-radius.json` produce `conflict=True` with reasons including `path_overlap`, `module_overlap -> config`, and `shared_surface_overlap`. Verify: pytest assertion against the committed config.
- [x] **AC7 — Location-bucket negative pin.** Tests assert that in BOTH committed config copies no module is named `docs` or `tests` and no module glob equals `docs/**` or `tests/**`. Verify: pytest case in `test_blast_radius_config.py` plus the matching Pester case in `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` pass.
- [x] **AC8 — Derivation exists and is deterministic.** The TypeScript push-down surface derives the destination `config/blast-radius.json` from the destination repository's actual layout at push-down time via a pure core (`deriveDestinationModuleMap`) with no I/O; identical observation lists and source text produce byte-identical output strings, and all module names and per-stage collections are ordinally sorted. Verify: Jest determinism and sorting assertions in the new derivation test file.
- [x] **AC9 — Derivation never emits a location bucket or universal glob.** No derived document contains a module glob equal to `**`, `docs/**`, or `tests/**`; the in-code guard raises before any write when such a glob would be emitted, and the destination file is untouched in that case. Verify: Jest negative-path assertions, including a root-manifest layout (manifest at destination root only) that must not yield `**`.
- [x] **AC10 — No-signal behavior is defined.** For a destination yielding no project-manifest signal and no non-excluded top-level directory, the derived document's `modules` object contains exactly `claude-runtime` → `[".claude/**"]` and `config` → `["config/**"]` (the payload modules), with `version`, `shared_surfaces`, `shared_surface_globs`, and `over_breadth_fraction` carried verbatim from the bundled source document. Verify: Jest assertion on an empty in-memory destination.
- [x] **AC11 — Destination-layout outcomes.** For a seeded C# layout (`Foo/Foo.csproj`, `Foo.Tests/Foo.Tests.csproj`) the derived modules include `Foo` and `Foo.Tests`; for a monorepo layout (`packages/a/package.json`, `packages/b/package.json`) the derived modules include `packages/a` and `packages/b` but not `packages`; for a src-only layout with a root-level manifest the fallback emits `src` → `src/**`. Verify: Jest assertions per layout.
- [x] **AC12 — Failure and tolerance semantics.** An unparseable bundled source document fails the push for that file with an error naming the path and leaves destination bytes untouched; an unreadable destination subdirectory contributes no entries without failing the derivation. Verify: Jest negative-path assertions.
- [x] **AC13 — Idempotency.** A second push against a destination whose layout is unchanged (other than the previously pushed `.claude` and `config` trees) writes a byte-identical `config/blast-radius.json`. Verify: Jest double-push assertion.
- [x] **AC14 — AC8 genericity test rewritten as a property.** The test at `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:375` no longer asserts equality between the published document and a seeded constant. It seeds a destination layout and asserts the published document contains the derived destination module, does not contain `docs/**`, `tests/**`, or a bare `**` glob, and does not contain `scripts/dev_tools`, `packages/mcp-server`, `poetry.lock`, or `package-lock.json`. The companion overwrite test (line 396) asserts the pre-existing destination file is replaced by the derived document, not merged. Verify: read the test file (no `toBe(SOURCE_BLAST_RADIUS)` assertion on the published blast-radius document remains) and Jest passes.
- [x] **AC15 — Python surface unchanged.** `scripts/dev_tools/push_down_claude_customizations.py` still publishes `ROOT_FOLDERS == (Path(".claude"),)`; the pinned test at `tests/scripts/dev_tools/test_push_down_claude_customizations.py:80` is unmodified and passing; no new Python push-down module (config carriage, routing merge, or derivation) is introduced. Verify: `git diff` shows no change to the Python push-down surface or its pin test; pytest passes.
- [x] **AC16 — Documentation comments corrected.** The doc comments in `claude-customizations.ts` and `claude-routing-merge.ts` no longer state that `config/blast-radius.json` is a plain overwrite; they describe the derivation interception. Verify: grep the two files for the stale claim.
- [x] **AC17 — Coverage thresholds held.** New and changed production modules report line coverage >= 85% and branch coverage >= 75%, with no coverage regression on changed lines. Verify: `npm run test:unit:coverage` output for the TypeScript modules; pytest coverage output for touched Python test scope.
- [x] **AC18 — Full toolchain pass.** Python (Black, Ruff, Pyright, pytest), TypeScript (Prettier, ESLint, TSC, Jest), and PowerShell (Invoke-Formatter, PSScriptAnalyzer, Pester) loops each complete without errors in a single pass. Verify: command exit codes.

### AC Status Summary

- Source: `docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/spec.md` (work mode `full-bug`; `spec.md` is the sole acceptance-criteria source)
- Total AC items: 18
- Checked off (delivered and verified): 18
- Remaining (unchecked): 0
- Items remaining: none

Every criterion below was checked only after the cited evidence was written to
disk and verified. Evidence paths are relative to the feature folder
`docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/`.

| AC | Verifying task(s) | Evidence artifact(s) |
| --- | --- | --- |
| AC1 | P2-T1, P2-T6 | `evidence/regression-testing/pass-after-config-keys.2026-08-15T11-20.md` |
| AC2 | P2-T2, P2-T6 | `evidence/regression-testing/pass-after-config-keys.2026-08-15T11-20.md` |
| AC3 | P1-T1, P1-T5, P2-T4 | `evidence/regression-testing/fail-before-pytest.2026-08-15T11-05.md`; `evidence/regression-testing/pass-after-pytest.2026-08-15T11-15.md` |
| AC4 | P1-T2, P2-T4 | `evidence/regression-testing/pass-after-pytest.2026-08-15T11-15.md` |
| AC5 | P1-T2, P2-T4 | `evidence/regression-testing/pass-after-pytest.2026-08-15T11-15.md` |
| AC6 | P1-T2, P2-T4 | `evidence/regression-testing/pass-after-pytest.2026-08-15T11-15.md` |
| AC7 | P1-T3, P1-T4, P1-T5, P1-T6, P2-T4, P2-T5 | `evidence/regression-testing/fail-before-pytest.2026-08-15T11-05.md`; `evidence/regression-testing/fail-before-pester.2026-08-15T11-08.md`; `evidence/regression-testing/pass-after-pytest.2026-08-15T11-15.md`; `evidence/regression-testing/pass-after-pester.2026-08-15T11-18.md` |
| AC8 | P3-T1, P3-T2, P4-T1, P4-T3 | `evidence/regression-testing/expected-red-ts-phase4.2026-08-15T11-55.md`; `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| AC9 | P3-T1, P3-T2, P4-T1, P4-T2 | `evidence/regression-testing/expected-red-ts-phase4.2026-08-15T11-55.md`; `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| AC10 | P3-T1, P4-T1 | `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| AC11 | P4-T1 | `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| AC12 | P3-T2, P4-T2 | `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| AC13 | P4-T2 | `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| AC14 | P5-T2, P5-T3, P5-T4, P5-T5 | `evidence/regression-testing/expected-red-ts-phase3.2026-08-15T11-40.md`; `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| AC15 | P6-T1 | `evidence/qa-gates/ac15-python-surface-unchanged.2026-08-15T12-10.md` |
| AC16 | P3-T3, P3-T4 | `evidence/qa-gates/final-qa-summary.2026-08-15T12-38.md` (comment-only diff recorded; grep sweep run at P3-T3) |
| AC17 | P0-T7, P0-T11, P7-T4, P7-T8, P7-T12 | `evidence/baseline/phase0-ts-test-coverage.md`; `evidence/baseline/phase0-py-pytest-coverage.md`; `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md`; `evidence/qa-gates/final-py-pytest-coverage.2026-08-15T12-29.md`; `evidence/qa-gates/coverage-comparison.2026-08-15T12-36.md` |
| AC18 | P2-T3, P7-T1 through P7-T11, P7-T13 | `evidence/qa-gates/final-ts-format.2026-08-15T12-20.md`; `evidence/qa-gates/final-ts-lint.2026-08-15T12-21.md`; `evidence/qa-gates/final-ts-typecheck.2026-08-15T12-22.md`; `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md`; `evidence/qa-gates/final-py-black.2026-08-15T12-26.md`; `evidence/qa-gates/final-py-ruff.2026-08-15T12-27.md`; `evidence/qa-gates/final-py-pyright.2026-08-15T12-28.md`; `evidence/qa-gates/final-py-pytest-coverage.2026-08-15T12-29.md`; `evidence/qa-gates/final-ps-format.2026-08-15T12-32.md`; `evidence/qa-gates/final-ps-analyze.2026-08-15T12-33.md`; `evidence/qa-gates/final-ps-pester.2026-08-15T12-34.md`; `evidence/qa-gates/final-qa-summary.2026-08-15T12-38.md` |

#### Implementation note on AC9

AC9 has two clauses. The first — no derived document contains a module glob equal
to `**`, `docs/**`, or `tests/**` — is verified end-to-end through the decorator
in `blast-radius-derive.test.ts`, including the root-manifest layout the
criterion names explicitly. The second — the in-code guard raises before any
write and the destination file is untouched — is verified directly in
`blast-radius-derive-core.test.ts`.

Implementation established that a guard trip is unreachable through the composed
decorator: the destination scan prunes `docs` and `tests` by name (algorithm step
1) before either can become an observation, and a root-level manifest is
categorically excluded, so no forbidden glob can be offered to the guard. That
pruning is correct and was deliberately not relaxed, because a destination
workspace legitimately containing `docs/package.json` must publish successfully
rather than fail the push. The guard therefore stands as defense in depth. Full
detail is recorded in
`evidence/regression-testing/expected-red-ts-phase4.2026-08-15T11-55.md`.

## Risks & Mitigations

- **Risk:** removing the `docs`/`tests` modules weakens contention detection for genuinely shared documentation or test files. **Mitigation:** the path level still detects identical shared files (AC5 pins this); only the coarse location-bucket coupling is removed, and the four-outcome matrix (AC3-AC6) pins every contention level.
- **Risk:** the derivation misclassifies a destination layout and emits an unhelpful map. **Mitigation:** the module level is documented fail-open — unresolved paths still carry path-, shared-surface-, and contract-level signal; the guard (AC9) prevents the harmful direction (over-broad buckets); the fallback and no-signal floor (AC10, AC11) give defined coarse outcomes.
- **Risk:** the destination scan is slow on large repositories. **Mitigation:** depth limit 3, ordinal-sorted shallow listings, and pruned directory names; no unpruned recursive walk.
- **Risk:** the rewritten genericity test regresses into another tautology. **Mitigation:** AC14 requires the property form and explicitly prohibits equality against a seeded constant.

## Rollout & Follow-up

- Release/rollout steps: standard branch → PR → merge on `bug/blast-radius-module-map-forces-serial-runs-472`; destinations pick up the derived map on their next push-down; no migration needed.
- Post-fix monitoring or clean-up tasks: on the next real destination push, confirm the destination's `config/blast-radius.json` lists that repository's own source directories. Issue #452 (under-reporting) remains open and separate.
- Links: issue [#472](https://github.com/drmoisan/drm-copilot/issues/472); research `docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/research/2026-08-15T10-15-blast-radius-module-map-forces-serial-runs-research.md`; owner decisions and defect analysis in `artifacts/orchestration/orchestrator-state.json`; related issue #452.
