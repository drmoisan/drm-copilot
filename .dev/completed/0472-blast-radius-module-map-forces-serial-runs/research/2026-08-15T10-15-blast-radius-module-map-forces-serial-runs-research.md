# Blast-radius module map forces serial runs (issue #472) — implementation research

- Issue: #472
- Feature folder: `docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/`
- Date: 2026-08-15
- Author: task-researcher
- Status: RESEARCH COMPLETE

Diagnosis is taken as given from `issue.md` (verified by the orchestrator; not re-derived here). The owner decisions are fixed: (1) drop the `docs` and `tests` location buckets from both config copies; (2) add a regression gate asserting two items with disjoint production paths produce zero conflict edges; (3) derive the destination module map from the destination repository's actual layout at push-down time, in both the Python and TypeScript push-down surfaces. This document determines HOW to implement them, with most effort on decision 3.

## 1. Current State Analysis

### 1.1 The two config copies

- Repo-root truth table `config/blast-radius.json` — 14 modules including `"tests": ["tests/**"]` (line 33) and `"docs": ["docs/**"]` (line 34). `config/blast-radius.json` is itself listed as a shared surface (line 12).
- Bundled generic default `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` — 4 modules: `claude-runtime`, `config`, `docs`, `tests` (lines 9–14). This is the file a destination receives verbatim today.

### 1.2 Defect sites (confirmed at cited lines)

- `scripts/dev_tools/compute_blast_radius.py:265` — `entries.add(_feature_folder_glob(...))` unconditionally injects `docs/features/active/<slug>/**` into every radius.
- `scripts/dev_tools/_blast_radius_conflicts.py:167-177` — the level table makes module overlap a conflict disjunct via plain set intersection.
- `scripts/dev_tools/_blast_radius_validation.py:263-288` — `resolve_modules` marks a module as soon as one of its globs covers one path entry, so the feature-folder glob alone resolves module `docs` for every item.
- Note: `conflicts()` reads no key from `config` (`_blast_radius_conflicts.py:145-147`); module overlap is computed from the modules already stored on each radius. The fix is therefore entirely a truth-table (map content) fix — no relation code changes.

### 1.3 How `config/blast-radius.json` reaches a destination today

**TypeScript surface** (`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`):

- `ROOT_FOLDERS = [".claude", "config"]` (line 46). `config` is appended after `.claude`; enumeration order is the summary-artifact contract (comment at lines 38–45).
- `ROUTING_MERGE_RELATIVE_PATH = "config/orchestration-routing.json"` (line 56) is the one merged path, handled by the `RoutingMergeFileSystem` decorator composed closest to the real adapter (lines 244–248). The doc comment at `claude-routing-merge.ts:20` states explicitly: "Every other published file, **including `config/blast-radius.json`, is a plain overwrite**."
- Composition order in `pushDownCustomizations` (lines 244–263): raw adapter → `RoutingMergeFileSystem` → `ExcludingFileSystem` → shared engine.
- The bundled file is the copy source: the engine enumerates `sourceRoot/config` and writes `destinationRoot/config/blast-radius.json` byte-for-byte (LF-normalized).

**Python surface** (`scripts/dev_tools/push_down_claude_customizations.py`):

- `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)` (line 101). **The Python surface does not publish the `config/` tree at all** — no routing merge exists and no blast-radius file is written. Pinned by `tests/scripts/dev_tools/test_push_down_claude_customizations.py:80` (`assert module.ROOT_FOLDERS == (Path(".claude"),)`).
- This is a verified parity gap: issue #462's config carriage (AC6/AC7/AC8/AC16) was delivered on the TypeScript surface and the bundle payload only. Decision 3 ("both surfaces") therefore forces the Python surface to gain config carriage first; a destination pushed via `python -m scripts.dev_tools.push_down_claude_customizations` currently receives neither config file and cannot run the parallel surface regardless of this fix.

**Pack manifests**: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:126-127` lists `config/orchestration-routing.json` and `config/blast-radius.json` in the always-included core pack, so pack-scoped publishes carry both files (asserted by `claude-config-carriage.test.ts:173-185`).

**Filesystem seam** (both languages): the six-member adapter contract — `list_files/is_dir/is_file/read_text/write_text/ensure_dir` in `scripts/dev_tools/push_down_copilot_customizations_filesystem.py:17-53`, mirrored one-to-one by `extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts:29-53`. Neither contract has a shallow directory listing; `listFiles` is an unpruned recursive walk (`filesystem-adapter.ts:111-144`), which is prohibitively expensive against a real destination (`node_modules`, `.git`).

### 1.4 Consumption at the destination

The core pack ships the PowerShell mirror `.claude/lib/blast-radius/*.psm1` (`core.json:110-114`) and the bash cohort layer (`core.json:117-125`). The destination planner resolves modules through the PowerShell mirror against the destination's `config/blast-radius.json`. Consumption code needs no change; only the published map content changes.

## 2. Recommended Approach

**Fix Defect A** by deleting the `"docs"` and `"tests"` entries from the `modules` object in both config copies. Twelve modules remain in the repo-root copy; `claude-runtime` and `config` remain in the bundled copy. No library code changes. The issue's manual verification table (issue.md lines 85–90) confirms this restores concurrency for disjoint items while preserving detection of a shared production file (path + module), a shared test file (path level: two items citing the same `tests/...` file still produce `path_overlap`), and a shared surface (all three levels).

**Fix Defect B** with a write-intercepting derivation decorator on both push-down surfaces, backed by one shared pure derivation core per language and a shared parity fixture corpus.

### 2.1 Seam: a `BlastRadiusDeriveFileSystem` decorator (per language)

- TypeScript: new module `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts`, modeled on `claude-routing-merge.ts`. It wraps the adapter, intercepts `writeTextFile` for the destination-relative path `config/blast-radius.json`, and writes a derived document instead of the source bytes. Compose it adjacent to `RoutingMergeFileSystem` in `pushDownCustomizations` (`claude-customizations.ts:244-263`). The `claude-routing-merge.ts` header comment (line 54–56 of `claude-customizations.ts`, "including `config/blast-radius.json`, is a plain overwrite") must be amended.
- Python: new module `scripts/dev_tools/push_down_claude_blast_radius.py` with the mirrored decorator, composed in `push_down_customizations` (`push_down_claude_customizations.py:188-281`). Prerequisite parity port in the same change: `ROOT_FOLDERS` becomes `(Path(".claude"), Path("config"))` and a Python routing-merge port (mirror of `claude-routing-merge.ts`) is added, because publishing `config/` without the merge would clobber destination-local routing — the exact hazard the TS decorator exists to prevent.
- Derivation timing: the interception fires when the engine writes `config/blast-radius.json`, i.e., after `.claude` has been published (root order `.claude`, then `config`). This is harmless because the scan excludes `.claude` and `config` from source-module discovery (they are represented by the fixed payload modules), which also makes a second push byte-stable.
- Pure core: `deriveDestinationModuleMap(observations, sourceDocumentText)` in a dedicated module per language, taking a deterministic, already-collected observation list (no I/O), mirroring the blast-radius library's purity discipline (`compute_blast_radius.py` docstring: "no filesystem, subprocess, network, or wall-clock access").

### 2.2 Destination scanning: a narrow directory-lister seam, not a contract change

The derivation needs shallow listing (immediate entries of a directory with a file/dir flag). Rather than widening the frozen six-member `PushDownFileSystem` contract (which would touch every adapter, decorator, and in-memory fake in both languages), inject a minimal lister into the decorator:

- Python: `list_entries: Callable[[Path], Sequence[tuple[str, bool]]]` (name, is_dir), constructor parameter with a real default built on `Path.iterdir()`, sorted ordinally; tests inject a fake. This follows the repo's "smallest seam" dependency rule (`.claude/rules/python.md`, Dependency seams).
- TypeScript: `listEntries: (root: string) => ReadonlyArray<{ name: string; isDir: boolean }>` option on the decorator, real default on `fs.readdirSync(..., { withFileTypes: true })`, sorted; hermetic tests supply a fake consistent with `InMemoryPushDownFileSystem` (`push-down.test-helpers.ts:43`).
- Error tolerance mirrors `RealPushDownFileSystem.listFiles` (`filesystem-adapter.ts:122-127`): an unreadable directory contributes no entries. An unparseable bundled source document fails fast with an explicit path-naming error, following the `RoutingMergeError` precedent (`claude-routing-merge.ts:57-73`).

### 2.3 Derivation algorithm (deterministic, both languages byte-for-byte)

Constants, identical literals in both implementations:

- `MANIFEST_FILENAMES` (exact-name signals): `build.gradle`, `build.gradle.kts`, `Cargo.toml`, `go.mod`, `package.json`, `pom.xml`, `pyproject.toml`, `setup.py`.
- `MANIFEST_SUFFIXES` (extension signals): `.csproj`, `.fsproj`, `.vbproj`, `.sln`, `.slnx`.
- `EXCLUDED_DIR_NAMES`: `__pycache__`, `artifacts`, `bin`, `build`, `coverage`, `dist`, `doc`, `docs`, `node_modules`, `obj`, `out`, `target`, `test`, `tests`, `venv` — plus every name beginning with `.` (covers `.git`, `.claude`, `.github`, `.vscode`, `.venv`, `.codex`, `.agents`).
- `SCAN_DEPTH_LIMIT = 3` (top level plus two nested levels).
- `PAYLOAD_MODULES`: `claude-runtime` → `[".claude/**"]`, `config` → `["config/**"]`.

Steps:

1. **Scan.** Breadth-first from the destination root to depth 3, visiting subdirectories in ordinal name order, pruning `EXCLUDED_DIR_NAMES` and dot-prefixed names.
2. **Classify.** A visited directory `D` (never the root itself) is a *project directory* when its shallow listing contains an exact `MANIFEST_FILENAMES` member or a file ending in a `MANIFEST_SUFFIXES` member. The root is categorically excluded because a root-level manifest would otherwise yield the universal glob `**` — a location bucket over the entire repository, the defect class being fixed.
3. **Prune ancestors.** Drop any project directory that is a proper ancestor of another project directory. Leaf granularity maximizes concurrency; an umbrella module (`src/**` above `src/Foo` and `src/Bar`) would re-couple sibling projects exactly the way `docs` coupled everything. Files directly in a dropped ancestor resolve to no module; the path level still covers them, which is the documented fail-open posture of the module level.
4. **Name and glob.** Each remaining project directory becomes one module: name = its destination-relative POSIX path (e.g., `src/TaskMaster.Domain`, `packages/mcp-server`), glob = `<relpath>/**`. Relative-path names cannot collide and are deterministic.
5. **Fallback.** If steps 1–4 produce zero modules, every non-excluded top-level directory becomes a module (name = directory name, glob = `<name>/**`). This covers layouts with no recognized manifest (e.g., plain script folders).
6. **No-signal floor.** If the fallback also yields zero modules, the emitted map is `PAYLOAD_MODULES` alone. This is a computed outcome for a genuinely structureless destination, not a shipped empty default; the path, shared-surface, and contract levels carry the contention signal there.
7. **Assemble.** Union derived modules with `PAYLOAD_MODULES` (on a name collision the payload definition wins); sort module names ordinally; carry `version`, `shared_surfaces`, `shared_surface_globs`, and `over_breadth_fraction` verbatim from the parsed bundled source document; emit keys in the source document's fixed order (`version`, `shared_surfaces`, `shared_surface_globs`, `modules`, `over_breadth_fraction`).
8. **Guard.** Fail fast if any emitted glob is `**`, `docs/**`, or `tests/**`. This is the in-code assertion that the derivation can never recreate the defect it fixes.

Serialization: Python `json.dumps(document, indent=2) + "\n"`; TypeScript `JSON.stringify(document, null, 2) + "\n"`. With key insertion order controlled and values restricted to strings, string arrays, the integer `1`, and the literal `0.25`, the two runtimes emit identical bytes. Known ordinal-sort caveat: Python sorts by code point, TypeScript by UTF-16 code unit; they diverge only for astral-plane directory names. This is the same accepted divergence class recorded for the parallel validators (`.claude/rules/parallel-orchestration.md`, Enforcement bullet on the TypeScript parity port); it should be recorded in the new modules' doc comments.

Idempotency: a second push scans a destination whose only new top-level entries are `.claude` (dot-prefixed, skipped) and `config` (no manifest; in fallback mode it derives `config` → `config/**`, identical to the payload module). The derived document is therefore byte-stable across pushes given an unchanged destination layout.

### 2.4 Rejected alternatives (brief)

- **Exclude item-private paths (feature folder, tests) from module resolution instead of dropping the buckets** — explicitly rejected by owner decision 1; also touches resolver code in three implementations (Python, PowerShell, and their parity corpus) for a problem the truth table causes.
- **Derive the map at destination runtime (first `parallel-plan` run)** — contradicts the fixed owner decision ("at push-down time") and would require derivation implementations in the destination runtimes (PowerShell and bash) rather than the two push-down surfaces.
- **Per-stack static default packs or an empty published map** — both explicitly prohibited by owner decision 3.
- **Widen the `PushDownFileSystem` contract with a shallow-listing member** — viable, but it forces edits to every implementer and decorator in both languages (`RealPushDownFileSystem`, `InMemoryPushDownFileSystem`, `ExcludingFileSystem`, `RoutingMergeFileSystem`, Python equivalents and fakes). The injected lister achieves the same hermeticity with a strictly smaller blast radius.
- **Python surface writes only the derived `config/blast-radius.json` without full config carriage** — rejected: it would publish half a config tree (no `config/orchestration-routing.json`), leave the #462 blockers standing for CLI-pushed destinations, and diverge from the TS enumeration contract instead of converging on it.

## 3. Behavior Semantics and Edge Cases

- **Success:** push-down completes; destination `config/blast-radius.json` holds the derived document; summary artifact records the same copied-file set as today (content substitution does not change file counts — the routing merge already established this precedent).
- **Failure, unparseable bundled source doc:** the one file fails with an explicit error naming the path; destination bytes untouched (RoutingMergeError model).
- **Failure, guard tripped:** derivation raises before writing; push-down fails fast rather than shipping a serializing map.
- **Unreadable destination subdirectory:** contributes no entries (matches `listFiles` tolerance); result stays deterministic for identical visibility.
- **Empty destination (fresh repo):** no-signal floor emits payload modules only.
- **Destination with root-level manifest only** (e.g., single `package.json` at root, sources in `src/`): root excluded; `src` has no manifest → fallback emits `src` → `src/**` plus payload modules.
- **C# solution** (`Foo.sln` at root, `Foo/Foo.csproj`, `Foo.Tests/Foo.Tests.csproj`): modules `Foo`, `Foo.Tests`. A shared test *project* is genuine contention (a concrete directory two items would edit), unlike the universal `tests/**` bucket; the item-private test files of destination repos governed by the pushed-down policy live under top-level `tests/**`, which stays excluded.
- **Monorepo** (`packages/a/package.json`, `packages/b/package.json`): ancestor pruning keeps `packages/a`, `packages/b`; `packages` itself is not a module.
- **Ordering rules:** all collections ordinally sorted at every stage (matches `require_str_tuple` discipline in `_blast_radius_validation.py:126-152`).

## 4. Requirements Mapping to Design

Required file changes:

| # | File | Change |
| --- | --- | --- |
| 1 | `config/blast-radius.json` | Delete `"docs"` and `"tests"` module entries (lines 33–34) |
| 2 | `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | Delete `"docs"` and `"tests"` module entries (lines 12–13) |
| 3 | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts` (new) | Derivation decorator + pure core (or core split into a sibling module to respect the 500-line limit) |
| 4 | `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | Compose the decorator (lines 244–263); amend the "plain overwrite" comment (lines 50–56); add optional `listEntries` to `ClaudePushDownOptions` |
| 5 | `scripts/dev_tools/push_down_claude_blast_radius.py` (new) | Python mirror of #3 |
| 6 | `scripts/dev_tools/push_down_claude_routing_merge.py` (new) | Python port of `claude-routing-merge.ts` (prerequisite for config carriage) |
| 7 | `scripts/dev_tools/push_down_claude_customizations.py` | `ROOT_FOLDERS` → `(Path(".claude"), Path("config"))` (line 101); compose both decorators; optional `list_entries` keyword |
| 8 | `tests/fixtures/destination_module_map/*.json` (new corpus) | Layout observations + source doc → expected serialized document |
| 9 | Test amendments/additions | Section 5 |

Internal API boundaries: the pure derivation core takes observations + source text and returns the serialized document string; the decorator owns I/O routing; the lister is the only new seam. No public signature breaks — new parameters are optional keywords/options, matching the extensibility rule in `.claude/rules/general-code-change.md`.

## 5. Testing Implications (strategy only; no test code here)

### 5.1 Parity obligations and the established pattern

The blast-radius surface's parity discipline is a shared, file-read-only fixture corpus asserted independently by each implementation:

- Corpus: `tests/fixtures/blast_radius/*.json` (26 fixtures; e.g., `derivation-basic.json`).
- Python driver: `tests/scripts/dev_tools/test_blast_radius_parity.py` (`MINIMUM_FIXTURE_COUNT = 26`, line 56; on-disk-count equality at lines 325–330).
- PowerShell driver: `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (floor at line 57; header cites the `ModelRouting.Parity.Tests.ps1` discipline: read-only, no temp files, no cross-process execution).

The new derivation owes the same pattern between Python and TypeScript: a new corpus `tests/fixtures/destination_module_map/*.json`, each fixture holding the observation list and bundled source document as input and the expected serialized document (a single string compared byte-for-byte) as output, driven by a new pytest suite (`tests/scripts/dev_tools/test_destination_module_map_parity.py`) and a new Jest suite (`extensions/drm-copilot/test/lib/push-down/blast-radius-derive-parity.test.ts`). Jest tests already read real repo files via `REPO_ROOT` (`claude-config-carriage.test.ts:46`), so the corpus is reachable from both runtimes. Byte-for-byte comparison of the serialized string subsumes key order, sorting, and float formatting in one assertion. No PowerShell derivation exists (push-down has no PowerShell surface), so no third driver is owed.

### 5.2 Regression gate (owner decision 2)

- Python, against the **committed** config (the defect lived in the committed map, so a test-local map proves nothing): add to `tests/scripts/dev_tools/test_blast_radius_config.py` — derive two radii with distinct feature folders and disjoint production paths (mirroring the issue's reproduction: `scripts/benchmarks/run.py` + a matching test file vs `extensions/drm-copilot/src/lib/foo.ts`) and assert `conflicts(...)` is `False` with zero reasons. Add a companion negative pin: no committed module glob equals `docs/**` or `tests/**`.
- PowerShell mirror: add the matching disjoint-items and negative-pin cases to the `Committed blast-radius truth table shape` Describe in `BlastRadius.Parity.Tests.ps1` (lines 302–395), which already reads `config/blast-radius.json`.
- Corpus: add one conflict fixture (disjoint items under a realistic map → `conflict: false`) so both parity drivers pin the behavior automatically; the two floors (26) remain valid and may optionally be bumped to keep them tight.

### 5.3 Existing tests bound to the current map or published default

| Test | Disposition | Why |
| --- | --- | --- |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:375` (AC8) | **Amend — this is the failed genericity gate.** | `SOURCE_BLAST_RADIUS` (lines 64–83) hardcodes the `docs`/`tests` buckets; the first AC8 test asserts published == seeded source. Rewrite to: seed a destination layout (e.g., `src/App/App.csproj`), assert the published document contains the derived destination module and does **not** contain `docs/**`, `tests/**`, or the drm-copilot-only entries already listed (lines 386–393). The strengthened assertion is what would have caught Defect B. |
| Same file, `overwrites the destination blast-radius rather than merging it` (line 396) | **Amend expectation.** | Overwrite semantics stand, but the written bytes become the derived document, not `SOURCE_BLAST_RADIUS`. |
| Same file, AC6 (lines 158–216) and AC16 (lines 469–489) | Unchanged | Presence/order assertions only. |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (`MINIMUM_CONFIG_FILE_COUNT = 2`, lines 57–64; path list at 237–245) | Unchanged | Path-presence only; the bundled file remains shipped as the derivation's base document. |
| `tests/scripts/dev_tools/test_push_down_claude_customizations.py:80` | **Amend.** | Pins `ROOT_FOLDERS == (Path(".claude"),)`; becomes `(Path(".claude"), Path("config"))`. New Python suites mirroring the TS config-carriage/merge/derivation coverage are owed alongside. |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | No amendment; **additions** per 5.2 | Shape-pinning parametrizes whatever map is committed; removing two modules shrinks the parametrization without breaking any assertion. |
| `tests/scripts/dev_tools/test_compute_blast_radius.py`; `tests/scripts/claude-lib/blast-radius/*.Tests.ps1` (unit suites); `tests/fixtures/blast_radius/derivation-basic.json` and peers | Unchanged | They exercise resolver mechanics against test-local configs that happen to include `docs`/`tests` maps; those remain valid inputs for the machinery under test and are independent of the committed map. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | Additions per 5.2 | Committed-shape checks (module map non-empty, glob lists non-empty) stay satisfied by the 12 remaining modules. |
| `tests/shell/parallel_payload_only.bats:52-56` | Unchanged | Asserts the payload file exists; content-agnostic. |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py` | Unchanged | Pins skill-document wording about the landed contracts, not map content. |

### 5.4 Toolchain

Per-language loops per `.claude/rules/python.md`, `.claude/rules/typescript.md`, `.claude/rules/powershell.md`: Black/Ruff/Pyright/pytest; Prettier/ESLint/TSC/Jest; Invoke-Formatter/PSScriptAnalyzer/Pester via MCP. Coverage floors 85%/75% apply to the new modules; the pure derivation cores are fully unit-testable without I/O, and the decorators test hermetically through the in-memory adapters plus injected fake listers.

## 6. Blast Radius of This Change Itself

- **Paths:** `config/blast-radius.json`; `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`; `scripts/dev_tools/push_down_claude_customizations.py`; new `scripts/dev_tools/push_down_claude_blast_radius.py` and `scripts/dev_tools/push_down_claude_routing_merge.py`; `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`; new `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts`; test files and fixtures per section 5; the feature folder `docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/**`.
- **Modules (under the post-fix map):** `config`, `python-dev-tools`, `vscode-extension`.
- **Shared surfaces:** `config/blast-radius.json` is itself a declared shared surface (`config/blast-radius.json:12`) and must be enumerated explicitly in the implementing item's `shared_surfaces` (V2, `_blast_radius_validation.py:398-437`). No `scripts/dev_tools/validate_*.py` glob is matched.
- **Contracts:** the derived-document serialization contract (new, pinned by the parity corpus); `ClaudePushDownOptions` and `push_down_customizations` gain optional members (non-breaking); Python `ROOT_FOLDERS` value change (breaking only for its pin test); the enumeration-order summary contract (`config` appended after `.claude`) now applies to both surfaces. The six-member `PushDownFileSystem` contract is deliberately left untouched.
- **Explicitly out of scope:** `.github/instructions/**` (canonical policy, not modified); the conflict relation, resolver, and PowerShell mirror code; the bash cohort layer; `config/orchestration-routing.json` content.

## Automation Feasibility

No step requires human interaction. This work touches no third-party UI: every change is a repository file edit, and every verification is a local toolchain run (Poetry/pytest, npm/Jest/TSC/ESLint/Prettier, Pester via the PoshQC MCP commands, and optionally the bats payload suite). The reproduction and the regression gate execute as ordinary unit tests against the committed config; the push-down derivation is testable hermetically through the in-memory adapters with injected fake listers, so no real destination repository, network access, credential, or interactive approval is needed. The whole change is achievable autonomously end-to-end.
