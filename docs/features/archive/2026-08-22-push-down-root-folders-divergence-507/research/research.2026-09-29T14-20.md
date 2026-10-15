# Research: push-down-root-folders-divergence (Issue #507)

- Issue: #507 (child of epic #770, `push-down-payload-correctness`, wave 0). Also covers #764 part 2.
- Branch: `bug/push-down-root-folders-divergence-507`
- Researched: 2026-09-29T14-20 against the worktree tree at `b7b4a2dc`.
- Mode: research only; no source changes.

## Inputs Read

- `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/issue.md`, `spec.md` (draft template), `plan.2026-09-29T14-13.md` (template).
- `docs/features/epics/push-down-payload-correctness/epic.md` (Shared Design: parity is structural; merge registry grown by #508; exclusion filter added by #621).
- `docs/features/potential/promoted/2026-09-29-push-down-payload-correctness.md`, `docs/features/potential/promoted/2026-08-22-blast-radius-config-has-no-merge-decorator.md` (#508 intake).
- GitHub #507 and #764 via public web fetch. `gh issue view --comments` could not be run (no shell tool in this session); the web page did not render comments. The 2026-09-29 consolidation of #764 part 2 into #507 is recorded in `epic.md:53-54`. #764 part 2 is the same `ROOT_FOLDERS` divergence; part 1 (missing `Test-ModifiedWorkflowNeedsGreenRun.ps1`) is out of scope.

## 1. Current State: Enumeration, Filtering, and Writing

### Python (`scripts/dev_tools/push_down_claude_customizations.py`, 403 lines)

- `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)` at line 101; `EXCLUDED_RELATIVE_PATHS = (Path(".claude/settings.local.json"),)` at line 102.
- `push_down_customizations` (188-281) wraps the caller adapter in `ExcludingFileSystem` (261-271) and delegates to the shared engine `push_down_copilot_customizations.push_down_customizations` with `root_folders=ROOT_FOLDERS` (272-281). There is no destination-side decorator: every write is a plain overwrite.
- Engine (`push_down_copilot_customizations.py`): `enumerate_source_files` (139-178) lists `effective_source / root` for each root in order and sorts by root-relative POSIX path; the copy loop (366-404) computes `destination = destination_root / source.relative_to(effective_source)`, classifies `created`/`overwritten` by `fs.is_file` before the write, then `ensure_dir` + `write_text`. No try/except in the loop; the summary artifact is written after the loop (420-426). No dry-run option exists.
- Enumeration filters (`push_down_claude_filesystem.py` `ExcludingFileSystem.list_files`, 431-448): hard exclusion set, pack filter (`_is_pack_included`, 292-310: source-relative POSIX path must be in the manifest union when `--packs` is given), agent-memory scope filter (312-351), memory mode (353-398). `write_text` is a passthrough (466-468).
- `RealPushDownFileSystem.list_files` (`push_down_copilot_customizations_filesystem.py:99-107`) is `root.rglob("*")` with no gitignore handling and no allowlist.
- Source root: the only production caller is `main()` (369-399), which passes `source_root=resolved_repo_root` (392). No Python module is shipped in the extension bundle (`extensions/drm-copilot/resources/**/*.py` matches nothing), and README lists the Claude surface as "bundled publisher" only (`README.md:251`). The Python path therefore always reads from the repository root.

### TypeScript (`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, 361 lines)

- `ROOT_FOLDERS = [".claude", "config"]` (54); `ROUTING_MERGE_RELATIVE_PATH = "config/orchestration-routing.json"` (70); `EXCLUDED_RELATIVE_PATHS = [".claude/settings.local.json"]` (73-75).
- Composition (274-306), outer to inner: `ExcludingFileSystem` -> `BlastRadiusDeriveFileSystem` -> `RoutingMergeFileSystem` -> injected adapter. After the engine returns, `deliverDestinationGitignore` (320, 346-361) merges a managed block into the destination `.gitignore` through the raw adapter.
- Engine (`copilot-customizations-engine.ts`): `enumerateSourceFiles` (156-175) and copy loop (376-425) mirror the Python engine; no try/catch; no dry-run (`PushDownEngineOptions`, 91-101).
- Source root: the only production caller is `pushDownClaudeCustomizationsServiceCall` (`push-down-service-call.ts:166-201`), which always uses `<extensionRoot>/resources/claude-customizations` as both `sourceRoot` and `bundleRoot` (169-186). The TS path therefore always reads from the bundle.
- Pack mode: `core.json` lists both config files (`resources/claude-customizations/pack-manifests/core.json:174-175`), so a pack-scoped publish keeps them (pinned by `claude-config-carriage.test.ts:65-77`).

### Files under `config/` each side would publish

| Scenario | Source directory enumerated for `config` | Published `config/` files |
|---|---|---|
| TypeScript, any mode | `resources/claude-customizations/config/` | `config/blast-radius.json` (derived, not copied), `config/orchestration-routing.json` (merged) |
| Python today | none (root absent) | none |
| Python after a naive `ROOT_FOLDERS` edit, no `--packs` | repo-root `config/` | `blast-radius.json`, `orchestration-handoff-registry.json`, `orchestration-handoff.schema.json`, `orchestration-routing.json`, `poshqc-scan.json`, all verbatim overwrites |
| Python after a naive edit, `--packs` given | repo-root `config/`, filtered by `core.json` | `blast-radius.json` (self-hosted copy, verbatim), `orchestration-routing.json` (overwrite) |
| Python after the recommended fix, any mode | bundle `config/` (redirected) | `config/blast-radius.json` (derived), `config/orchestration-routing.json` (merged) |

A naive edit is incorrect for two independent reasons:

1. The repo-root `config/blast-radius.json` is the self-hosted truth table, not the published one. `.claude/rules/parallel-orchestration.md:539-583` states that the published copy is the bundled file, that only six keys are byte-equal across the two copies, and that `config/**` in a destination holds only the two published files. Copying the self-hosted file leaks drm-copilot's layout, the defect fixed by #500/#472.
2. TypeScript never writes the bundled blast-radius bytes either. `BlastRadiusDeriveFileSystem.writeTextFile` (`claude-blast-radius-derive.ts:282-293`) replaces them with a module map derived from a depth-3 scan of the destination (`collectDestinationObservations`, 163-207; `deriveDestinationModuleMap`, `claude-blast-radius-derive-core.ts:353-394`). Adding `config` to Python therefore requires a Python port of the derivation as well as the routing merge. The epic text names only the routing merge; this finding extends the required scope.

## 2. Routing Merge Semantics (TypeScript) and Port Decision

Source: `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` (311 lines). Behavior pinned by `claude-config-carriage.test.ts:137-291`. There is no dedicated `claude-routing-merge.test.ts`.

- **Target match** (306-310): `relativeToPosix(path, destinationRoot) === "config/orchestration-routing.json"` after backslash-to-slash and trailing-slash normalization; case-sensitive. Other paths pass through (282-285).
- **Destination absent** (288-291): the source text is written unchanged. It is not parsed, validated, or re-serialized.
- **Destination present** (292-297): `mergeRoutingDocuments(destinationText, sourceText, path)` (191-219):
  - Both texts are parsed by `parseRoutingObject` (115-127). Invalid JSON, or a root that is not a plain object (array, null, scalar), raises `RoutingMergeError`. The message always reads "Destination routing document is not valid JSON and was not written: <path> (<detail>)", and `.path` is the destination path, even when the source text is the one that failed.
  - Top level: destination keys are emitted in destination order with destination values kept verbatim (source `version`, `$schema`, and other shared keys are ignored), except `routes`, which is replaced by `mergeRoutes(asObject(dest.routes), asObject(src.routes))`. Source top-level keys the destination lacks are then appended in source order. A `routes` key appended this way becomes `mergeRoutes(null, asObject(src.routes))`, which is `{}` if the source `routes` is not an object.
  - `mergeRoutes` (154-180): destination routes are emitted in destination order and kept verbatim, except `parallel`, which takes the source definition when the source defines it. Source routes the destination lacks are appended in source order. A destination `routes` value that is not an object is treated as absent and discarded.
- **Serialization** (218): `JSON.stringify(merged, null, 2) + "\n"`: 2-space indent, LF, one trailing newline, no key sorting, non-ASCII emitted raw. The result is idempotent and byte-stable on a second push (test at `claude-config-carriage.test.ts:241-263`).
- **Error handling**: the error is thrown before the inner write, so the destination bytes are unchanged (test 265-290). The engine does not catch it, so the whole run aborts. Every `.claude` file has already been written (`config` enumerates after `.claude`), the summary artifact is not written, and `.gitignore` delivery does not run. The module header's "fails that one file" describes the file outcome, not the run outcome.
- **Report behavior**: no dry-run. The summary records the merged file as `overwritten`, because the status is computed before the write.
- **JavaScript-specific quirks** (not present in the shipped document; record them, do not replicate them): (a) `name in merged` treats inherited names such as `constructor` and `toString` as present, and assigning `__proto__` mutates the prototype. (b) `Object.entries` orders integer-like keys first. (c) `JSON.parse` rejects `NaN`/`Infinity`, which Python's `json.loads` accepts by default. (d) An integral float such as `1.0` re-serializes as `1` in JavaScript and as `1.0` in Python. A grep of `config/orchestration-routing.json` for `\d\.0\b|[eE][+-]?\d|[^\x00-\x7F]` returned 0 matches, so the shipped document is unaffected.

**Decision: yes, Python must port the merge.** Evidence: the Python engine loop overwrites unconditionally (`push_down_copilot_customizations.py:394-395`), and `ExcludingFileSystem.write_text` is a passthrough (`push_down_claude_filesystem.py:466-468`). Adding `config` without the merge would destroy destination-local routes, which is the behavior #462 AC7 prohibits on the TypeScript side (`claude-config-carriage.test.ts:137-291`). The epic's Shared Design ("#507 extends the Python push-down with the routing-file merge") requires it too.

**Python port shape (recommended):**

- `scripts/dev_tools/push_down_claude_routing_merge.py` (new, pure, no I/O): `RoutingMergeError(ValueError)` with `.path` and identical message text; `merge_routing_documents(destination_text, source_text, path) -> str`. Parse with `json.loads(text, parse_constant=<raise>)` to reject `NaN`/`Infinity` as JavaScript does. Serialize with `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"`; Python's default indented separators `(",", ": ")` match `JSON.stringify` output. Use plain dict semantics and do not reproduce the prototype quirks.
- `scripts/dev_tools/push_down_claude_blast_radius_derive.py` (new, pure): port of `claude-blast-radius-derive-manifests.ts` (200 lines) and `claude-blast-radius-derive-core.ts` (394 lines): manifest vocabulary, `classify_project_directories`, ancestor pruning, top-level fallback, `PAYLOAD_MODULES = {"config": ["config/**"]}`, forbidden-glob guard, `BlastRadiusDeriveError`, `BlastRadiusGuardError`, fixed key order, and `BLAST_RADIUS_RELATIVE_PATH = "config/blast-radius.json"`. If the module exceeds about 450 lines, split it into `_manifests` and `_core` as TypeScript does.
- `scripts/dev_tools/push_down_claude_destination_writes.py` (new, adapters):
  - `MergeFunction = Callable[[str, str, Path], str]`.
  - **Merge registry seam**: `MERGED_RELATIVE_PATHS: Mapping[str, MergeFunction] = {"config/orchestration-routing.json": merge_routing_documents}`. Keys are string literals so the parity test can read them statically.
  - `DestinationMergeFileSystem(inner, destination_root, merges=MERGED_RELATIVE_PATHS)`: on `write_text`, look up the destination-relative POSIX path. When it is registered and `inner.is_file(path)` is true, write `merge(inner.read_text(path), content, path)`; otherwise write `content`.
  - `BlastRadiusDeriveFileSystem(inner, destination_root, lister=real_directory_lister)`, with a `DirectoryLister = Callable[[Path], Sequence[DirectoryEntry]]` seam. The default lister uses `os.scandir` and tolerates errors (TypeScript tolerance rule, `claude-blast-radius-derive.ts:27-35`).
  - `BundleConfigFileSystem(inner, source_root, bundle_root)`: answers `list_files(source_root/"config")` from `bundle_root/"config"` and maps `is_file`/`read_text` for `source_root/config/*` to the bundle path. It is the identity when the two directories are the same path. This follows the Codex precedent `_RoutingConfigFileSystem` (`push_down_codex_and_agents_customizations.py:126-230`), but lists the whole bundle `config/` directory to match TypeScript enumeration.
  - **Composition seam**: `build_destination_write_stack(inner, *, destination_root, lister, merges=MERGED_RELATIVE_PATHS) -> PushDownFileSystem` returns `BlastRadiusDeriveFileSystem(DestinationMergeFileSystem(inner, ...), ...)`, which is the same order as TypeScript (274-291).
- Entry module changes: `ROOT_FOLDERS = (Path(".claude"), Path("config"))`. Wire `ExcludingFileSystem(BundleConfigFileSystem(build_destination_write_stack(fs, ...)), ...)` so the pack filter still sees source-rooted `config/...` paths. Add an optional keyword `list_entries` (non-breaking), matching TS `ClaudePushDownOptions.listEntries` (216-223).

**How the downstream children extend it without restructuring:**

- #508 adds `"config/blast-radius.json": merge_blast_radius_documents` to `MERGED_RELATIVE_PATHS`. The derive layer sits above the merge layer, so the merge receives the derived document as its source text and derive-then-merge follows with no rewiring.
- #621 inserts a destination-exclusion layer as the outermost wrapper inside `build_destination_write_stack` (ahead of derive and merge), or as an enumeration predicate, from the same single composition point.
- TypeScript today: `RoutingMergeFileSystem` takes the path as a parameter but hard-codes the merge function (238-246, 292-296), and composition is inline in `pushDownCustomizations`. #508 should introduce the matching TS `MERGED_RELATIVE_PATHS` map. #507 needs no TypeScript production change.

## 3. Parity Test Design

**Precedents that parse TypeScript source text from pytest:**

- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py:103-117`: regex over `export const ROOT_FOLDERS[^=]*=\s*\[([^\]]*)\]` in `claude-customizations.ts`, compared to `skill_bundle_contract.PUBLISHED_ROOT_FOLDERS`.
- `tests/scripts/dev_tools/test_plan_gate_parity.py:61-79`: named-constant regexes over TypeScript modules. Lines 1-6 also show the verbatim-duplicated-fixture pattern for behavioral parity.
- `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py:40` reads `pr-context/models.ts`.
- No Jest test that parses Python source was found.

**Recommendation:** a new pytest module, `tests/scripts/dev_tools/test_push_down_claude_parity.py`. It reads only committed files and creates none.

- **TypeScript extraction**: strip `/* ... */` and `//` comments. Then:
  - `ROOT_FOLDERS`: string literals inside the bracketed initializer of `export const ROOT_FOLDERS`, in declaration order.
  - Merged paths: the union of the string-literal initializer of every `export const <NAME>` in `claude-customizations.ts` where `<NAME>` matches `^[A-Z_]*MERGE[A-Z_]*_RELATIVE_PATHS?$`, plus the string-literal keys or elements of a future `MERGED_RELATIVE_PATHS` object or array. Today this yields `{"config/orchestration-routing.json"}`.
  - Derived paths: `BLAST_RADIUS_RELATIVE_PATH` in `claude-blast-radius-derive-core.ts`.
  - Every extraction asserts it found at least one declaration, so the test cannot pass vacuously.
- **Python extraction**: `ast.parse` of `push_down_claude_customizations.py` and the new modules. `ROOT_FOLDERS` is a tuple of `Path("<literal>")` calls; `MERGED_RELATIVE_PATHS` is a dict literal with string-constant keys; `BLAST_RADIUS_RELATIVE_PATH` is a string constant. Reject any non-literal element with an explicit assertion message.
- **Assertions**: ordered equality of root folders (order is the summary contract, TS 46-53); set equality of merged paths; set equality of derived paths. Failure messages name both files.
- **Behavioral parity (recommended)**: a shared committed fixture, `tests/fixtures/push_down/routing-merge-parity.json` (destination/source/expected triples covering absent, new route, stale `parallel`, local keys, non-object `routes`, invalid JSON), asserted by pytest and by a new Jest case. The same is recommended for derive (observations to expected text). This pins byte-level serialization parity without a shared runtime. Precedent for Jest reading repo files: `claude-config-carriage.test.ts:84-134`.

## 4. `skill_bundle_contract.py` and Other Consumers

- `scripts/dev_tools/skill_bundle_contract.py:35-38` declares its own `PUBLISHED_ROOT_FOLDERS = (".claude", "config")`, commented as mirroring the TS constant, and uses it in `_publication_reason` (377-383). `skill_bundle_contract_cli.py:29,156` uses it to collect `bundle_files`. It already includes `config`, so **no change is required**, and the existing pin to TypeScript (`test_skill_bundle_contract_repo.py:103-117`) together with the new parity test makes all three declarations transitively equal. Do not edit this file in #507: sibling #763 (wave 0) edits it to remove the 10 `KnownUnbundledReference` occurrences, so any edit here risks a merge conflict.
- **Consumers of the Python Claude `ROOT_FOLDERS` / push-down file list** (grep of `push_down_claude_customizations|ROOT_FOLDERS` outside `docs/`): `main()` only, plus the `tests/scripts/dev_tools/test_push_down_claude_*.py` modules. `agentic_sync.ROOT_FOLDERS` and `push_down_copilot_customizations.py:21,169` refer to the Copilot constant, a different family. `.codex/config.toml:13` and the TS MCP/tool files name the TS tool `push_down_claude_customizations`, not the Python module. The manual-verification item in `issue.md:74` is answered: no consumer depends on the Python path publishing `.claude` alone.
- **Bundle and pack consequences**: none. The bundle already carries `resources/claude-customizations/config/{blast-radius.json, orchestration-routing.json}`, and `core.json:174-175` already lists both. No Python is bundled.
- **`SCOPED_ROOTS`** (`test_push_down_claude_resource_contracts.py:25`) must stay `(Path(".claude"),)`. Its mirror test (118-143) requires every repo-root file under a scoped root to exist byte-identically in the bundle. Adding `config` would fail on the three repo-only config files and on the intentionally different blast-radius copy. The config copies are already pinned by `test_orchestration_routing_config_parity.py`, `claude-config-carriage.test.ts:84-134`, and `test_blast_radius_config_parity.py`. The note in `issue.md:66` locating this gap in `.claude/rules/parallel-orchestration.md` is stale: that file no longer contains `SCOPED_ROOTS`. This file is exactly 500 lines, so it cannot grow.
- **Docs**: `README.md:251` describes the Claude payload as "(`.claude`, `CLAUDE.md`)"; update it to include `config/`. The docstrings at `push_down_claude_customizations.py:1-7,200-206` and the CLI help at 316 say "`.claude` tree"; update them.

## 5. Existing Tests

- Python: `tests/scripts/dev_tools/test_push_down_claude_customizations.py` (284 lines), `..._memory_scope.py`, `..._pack_end_to_end.py`, `..._pack_memory_modes.py`, `..._pack_selection.py`, `..._pack_manifest_completeness.py`, `..._resource_contracts.py`. Shared doubles are in `push_down_customizations_test_support.py` (`MemoryFile`, `RecordingFileSystem`). Several modules define local copies.
- TypeScript: `claude-config-carriage.test.ts` (461 lines; the only routing-merge coverage), `claude-customizations.test.ts` (asserts `ROOT_FOLDERS` at 286), `blast-radius-derive*.test.ts` (5 files), `config-carriage.test-helpers.ts`, `push-down.test-helpers.ts` (`buildInMemoryFileSystem`).
- **Temporary-file avoidance**: Python uses in-memory `RecordingFileSystem` dict stores with synthetic roots (`/repo`, `C:/repo`). TypeScript uses `buildInMemoryFileSystem` and an injected `DirectoryLister` (`layoutLister`) because the real lister cannot see in-memory trees. Real-file reads are limited to committed resources.
- **Coverage**: not obtainable without running the toolchain. Record baselines in `evidence/baseline/` during execution.
- **Tests that must change**: `test_push_down_claude_customizations.py:80` asserts `ROOT_FOLDERS == (Path(".claude"),)`. The other Python tests seed no bundle `config/` files, so under the redirect design the config root lists nothing and their counts (for example `len(summary.files) == 6` at 166, `created_count == 1` at 238) are unchanged. No TypeScript test changes are required.
- **New Python tests**: routing merge (all branches above, error path, idempotency), derive core (mirror `blast-radius-derive-core.test.ts` cases), destination-write decorators and redirect, an end-to-end carriage module mirroring TS AC6/AC7/AC8/AC16 (`claude-config-carriage.test.ts:50-291,293-381,440-461`) through `push_down_customizations` with seeded bundle config and an injected lister, and the parity module. `hypothesis` is not a declared dependency (absent from `pyproject.toml`; no test imports it), so use deterministic idempotency cases and add no dependency.

## 6. File Size

| File | Lines | Note |
|---|---|---|
| `scripts/dev_tools/push_down_claude_customizations.py` | 403 | About +20 expected; stays under 500 |
| `scripts/dev_tools/push_down_claude_filesystem.py` | 472 | Do not add code here |
| `scripts/dev_tools/push_down_copilot_customizations.py` | 504 | Already over the cap (pre-existing); do not edit |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 500 | At the cap; do not grow |
| `tests/scripts/dev_tools/test_push_down_claude_customizations.py` | 284 | One-line edit |
| `extensions/.../claude-customizations.ts` | 361 | Unchanged in #507 |
| `extensions/.../claude-routing-merge.ts` | 311 | Unchanged |
| `extensions/.../claude-blast-radius-derive.ts` / `-core.ts` / `-manifests.ts` | 306 / 394 / 200 | Port sources |

The merge port, the derive port, and the adapters must go into new modules (Section 2).

## 7. Constraints

- Do not touch `.claude/hooks/enforce-powershell-batch-budget.ps1` or its tests (#769, another session).
- No pushed-down enforcement hook gains a Python leg. The change is confined to `scripts/dev_tools/` (a repository dev tool, not shipped, not a hook) and its tests.
- Do not edit `scripts/dev_tools/skill_bundle_contract.py` (sibling #763).
- TypeScript production code is unchanged in #507.
- Enumeration order `.claude` then `config` is a summary-artifact contract.

## Out-of-Scope Divergences Found (Recommend Follow-up Issues)

1. **`.gitignore` delivery**: TS merges a managed block into the destination `.gitignore` after the copy (`claude-customizations.ts:320,346-361`; `claude-gitignore-merge.ts`). Python has no equivalent. This is independent of the `config` root. File a follow-up issue (or fold it into #621's destination-state work).
2. **Python enumerates gitignored runtime trees**: `RealPushDownFileSystem.list_files` is an unfiltered `rglob` (`push_down_copilot_customizations_filesystem.py:99-107`), and `EXCLUDED_RELATIVE_PATHS` holds only `settings.local.json`. Run from a main checkout, the Python CLI would therefore publish `.claude/worktrees/**` and `.claude/state/**` (gitignored at `.gitignore:21,68`). TS reads the curated bundle and never sees these. File a follow-up issue.
3. The Codex Python push-down overwrites `config/orchestration-routing.json` without merging (`push_down_codex_and_agents_customizations.py:72-73,318-332`). Codex is an epic non-goal; record only.

## Rejected Alternatives

- **Naive `ROOT_FOLDERS` edit (repo-root `config/`)**: publishes 5 files, including the self-hosted blast-radius table and 3 repo-only files, with overwrite semantics. Rejected (Section 1).
- **Repo-root `config/` with a 2-path allowlist**: still ships the self-hosted blast-radius content. Rejected.
- **Switch the Python CLI `source_root` to the bundle for all roots**: gives exact source parity, but it silently changes `.claude` sourcing (agent-memory origin) for every existing test and caller. Rejected as beyond minimal scope.
- **Defer the blast-radius derive port to #508 (publish the routing file only)**: leaves the issue's stated impact (`issue.md:17,62`) unfixed and requires a named parity exception. Viable only as a planner fallback if C3 scope must hold. Not recommended.

## Recommended Scope for #507

1. `ROOT_FOLDERS = (Path(".claude"), Path("config"))`, with `config` sourced from the bundle's `config/` through `BundleConfigFileSystem`.
2. A Python routing merge port with the `MERGED_RELATIVE_PATHS` registry and the `build_destination_write_stack` composition seam.
3. A Python blast-radius derive port with an injected lister.
4. A static parity test (root folders ordered; merged and derived path sets), plus shared-fixture behavioral parity for merge and derive.
5. Update `test_push_down_claude_customizations.py:80`, `README.md:251`, and the module docstrings and CLI help.
6. File follow-ups for divergences 1 and 2.

## Numeric Derivation Evidence

### Claim N1: the Python push-down publishes exactly 2 `config/` files after the fix (the TS set)

- Complete Family: regular files under `extensions/drm-copilot/resources/claude-customizations/config/`.
- Exhaustive Search Scope: that directory, recursively.
- Inclusion Rules: any tracked file at any depth.
- Exclusion Rules: none. (Both tools honor `.gitignore`; no ignore rule covers this path.)
- Primary Search Strategy or Query Expression: Glob `extensions/drm-copilot/resources/claude-customizations/config/**`.
- Primary Member Set: `blast-radius.json`, `orchestration-routing.json`.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep pattern `[\s\S]`, output mode `count`, path `extensions/drm-copilot/resources/claude-customizations/config` (enumerates every non-empty file by content match).
- Cross-check Member Set: `orchestration-routing.json` (356), `blast-radius.json` (49).
- Cross-check Count: 2.
- Member-set Comparison: normalized sets `{blast-radius.json, orchestration-routing.json}` are identical. Consistent with `core.json:174-175` and `claude-config-carriage.test.ts:449-457`.

### Claim N2: repo-root `config/` holds 5 files (the naive-edit population)

- Complete Family: regular files under repo-root `config/`.
- Exhaustive Search Scope: `config/`, recursively.
- Inclusion Rules: any tracked file.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `config/**`.
- Primary Member Set: `blast-radius.json`, `orchestration-handoff-registry.json`, `orchestration-handoff.schema.json`, `orchestration-routing.json`, `poshqc-scan.json`.
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: Grep `[\s\S]`, `count` mode, path `config`.
- Cross-check Member Set: `blast-radius.json`, `poshqc-scan.json`, `orchestration-handoff.schema.json`, `orchestration-routing.json`, `orchestration-handoff-registry.json`.
- Cross-check Count: 5.
- Member-set Comparison: identical after normalization.

### Claim N3: the Claude TS surface has exactly 1 merged path and 1 derived path under the published roots

- Complete Family: destination-relative paths whose write a Claude-surface decorator transforms rather than passing through, within `ROOT_FOLDERS`.
- Exhaustive Search Scope: `extensions/drm-copilot/src/lib/push-down/*.ts`.
- Inclusion Rules: Claude-surface classes implementing `PushDownFileSystem` whose `writeTextFile` alters content, and the constants they target.
- Exclusion Rules: Codex classes (`CodexFilteringFileSystem`, `RoutingConfigFileSystem` in `codex-agents-customizations.ts`); `RealPushDownFileSystem`; `.gitignore` (outside `ROOT_FOLDERS`, post-copy; tracked as divergence 1).
- Primary Search Strategy or Query Expression: Grep `export const [A-Z_]*RELATIVE_PATHS?\b` over the directory, then filter to Claude modules and destination targets: `ROUTING_MERGE_RELATIVE_PATH` (`claude-customizations.ts:70`), `BLAST_RADIUS_RELATIVE_PATH` (`claude-blast-radius-derive-core.ts:76`). Excluded by rule: `EXCLUDED_RELATIVE_PATHS` (source filter), `CLAUDE_GITIGNORE_RELATIVE_PATH`, and the Codex `ROUTING_CONFIG_RELATIVE_PATH`.
- Primary Member Set: merged `{config/orchestration-routing.json}`; derived `{config/blast-radius.json}`.
- Primary Count: merged 1, derived 1.
- Cross-check Search Strategy or Query Expression: Grep `implements PushDownFileSystem|public writeTextFile\(|writeTextFile\(path: string`, then read each Claude class's `writeTextFile` body: `ExcludingFileSystem` (passthrough, `claude-filesystem-adapter.ts:296-298`), `RoutingMergeFileSystem` (`isMergeTarget`, `claude-routing-merge.ts:281-310`), `BlastRadiusDeriveFileSystem` (`isDeriveTarget`, `claude-blast-radius-derive.ts:282-305`). Confirm the constructor arguments at `claude-customizations.ts:274-291`.
- Cross-check Member Set: merged `{config/orchestration-routing.json}`; derived `{config/blast-radius.json}`.
- Cross-check Count: merged 1, derived 1.
- Member-set Comparison: identical.

## Automation Feasibility

No human-interaction steps are expected. Every change is to Python modules under `scripts/dev_tools/`, pytest modules, one optional Jest test, a committed JSON fixture, and Markdown. Verification runs through the standard toolchain (Black, Ruff, Pyright, pytest with coverage; Prettier, ESLint, tsc, and Jest for the optional TS test) on in-memory filesystems and committed files. No destination workspace, credentials, VS Code host, or network access is required. The issue's manual item ("confirm no consumer depends on `.claude` alone") is resolved by the static consumer search in Section 4. Filing the two follow-up issues uses the MCP promotion path, which requires no human steps.
