# Research: blast-radius-config-has-no-merge-decorator (Issue #508)

- Issue: #508 (child of epic `push-down-payload-correctness`, epic issue #770, wave 1, depends on #507)
- Branch: `bug/blast-radius-config-has-no-merge-decorator-508`
- Researched: 2026-09-29T14-18
- Mode: preparation (research only)

All paths are repository-relative. Line references were read at the worktree HEAD (`b7b4a2dc`).

## 1. Summary of Findings

1. **The issue premise is partly stale.** `config/blast-radius.json` is no longer a plain copy in the
   TypeScript push-down. Since issue #462/#472/#500 it is intercepted by `BlastRadiusDeriveFileSystem`
   (`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts:221-306`), which replaces
   the bundled `modules` map with one derived from the destination's own layout and carries nine other
   keys verbatim from the bundled document
   (`claude-blast-radius-derive-core.ts:138-148`, `:380-391`). The doc comment at
   `claude-customizations.ts:63-68` already says so. The defect the issue describes is still real:
   the derivation never reads the destination's existing file, so every destination-local addition
   is discarded on each push. `claude-config-carriage.test.ts:356-380` pins exactly that.
2. **The Python push-down has no config handling at all today.** `ROOT_FOLDERS = (Path(".claude"),)`
   (`scripts/dev_tools/push_down_claude_customizations.py:101`), no merge decorator, no derivation.
3. **#507 has no design yet.** The sibling worktree holds only unpopulated templates (`spec.md`,
   `plan.2026-09-29T14-13.md`, `issue.md`); there is no `research/` folder. No Python module name,
   registry shape, or parity-test name is confirmed. Every #507 name below is an assumption.
4. **Upstream risk for #507/#508: the Python CLI sources from the repository root, not the bundle.**
   `main()` passes `source_root=resolved_repo_root` (`push_down_claude_customizations.py:392`). Once
   #507 adds `config`, the Python path would publish the self-hosted `config/blast-radius.json`
   (drm-copilot modules, drm-copilot shared surfaces, a populated `path_roots`), which is the #500
   defect class. The TypeScript path reads the bundled copy
   (`push-down-service-call.ts:169-186`, `bundledSourceRoot(... "resources/claude-customizations")`).
   The routing file is unaffected because its two copies are pinned byte-identical
   (`claude-config-carriage.test.ts:84-108`); the two blast-radius copies differ by design
   (`.claude/rules/parallel-orchestration.md:539-582`).
5. **Recommendation:** a destination-local overlay file, `config/blast-radius.local.json`, that the
   payload never writes, **composed into `config/blast-radius.json` at push time** by a new registry
   entry in both implementations. No blast-radius consumer changes. See `## Recommendation`.

## 2. Current Mechanics

### 2.1 TypeScript push-down

- Entry point: `pushDownCustomizations(options)` in
  `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:239-322`.
- Decorator stack (innermost first), built at `claude-customizations.ts:274-306`:
  1. injected adapter `fs`;
  2. `RoutingMergeFileSystem(fs, destinationRoot, ROUTING_MERGE_RELATIVE_PATH)` (`:274-278`);
  3. `BlastRadiusDeriveFileSystem(mergingFs, destinationRoot[, listEntries])` (`:284-291`);
  4. `ExcludingFileSystem(derivingFs, repoRoot, EXCLUDED_RELATIVE_PATHS, {...})` (`:294-306`);
  then `enginePushDown({... rootFolders: ROOT_FOLDERS ...})` (`:308-318`) and a post-copy
  `.gitignore` merge on the raw adapter (`:320`, `:346-361`).
- Constants: `ROOT_FOLDERS = [".claude", "config"]` (`:54`);
  `ROUTING_MERGE_RELATIVE_PATH = "config/orchestration-routing.json"` (`:70`);
  `EXCLUDED_RELATIVE_PATHS = [".claude/settings.local.json"]` (`:73-75`);
  `BLAST_RADIUS_RELATIVE_PATH = "config/blast-radius.json"` (`claude-blast-radius-derive-core.ts:76`).
- Routing merge function: `mergeRoutingDocuments(destinationText: string, sourceText: string, path: string): string`
  (`claude-routing-merge.ts:191-219`). Decorator write path `writeTextFile` (`:281-298`): non-target
  path passes through; target absent in destination writes source unchanged (`:288-290`); otherwise
  reads the destination via `this.inner.readTextFile(path)` and writes the merge (`:292-297`).
  Target matching is `relativeToPosix(path, destinationRoot) === mergeRelativePath` (`:306-310`).
- Routing error handling: `RoutingMergeError(path, detail)` (`claude-routing-merge.ts:60-76`) thrown
  by `parseRoutingObject` for a parse failure or a non-object root (`:115-127`). It is raised before
  the inner write, so the destination bytes stay untouched (pinned by
  `claude-config-carriage.test.ts:265-290`).
- Blast-radius derivation: `BlastRadiusDeriveFileSystem.writeTextFile` (`claude-blast-radius-derive.ts:282-293`)
  scans the destination (`collectDestinationObservations`, `:163-207`) and writes
  `deriveDestinationModuleMap(observations, content)` (`claude-blast-radius-derive-core.ts:353-394`).
  It never reads the destination's current `config/blast-radius.json`. Errors:
  `BlastRadiusDeriveError` (bundled document unparseable, `:159-175`) and `BlastRadiusGuardError`
  (forbidden glob `**`, `docs/**`, `tests/**`, `:117-121`, `:186-206`, `:291-301`); both are raised
  before the inner write.
- Emitted key order is fixed: `version, shared_surfaces, shared_surface_globs, mandate_reads,
  mergeable_paths, conflict_tolerance, write_intent_extraction, path_roots, modules,
  over_breadth_fraction` (`claude-blast-radius-derive-core.ts:380-391`); serialization is
  `JSON.stringify(document, null, 2) + "\n"` (`:393`).

### 2.2 Python push-down

- Entry point: `push_down_customizations(*, repo_root, destination_root, fs, source_root=None, artifact_root=None, packs=None, csharp_variant="modern", memory_mode="overwrite", bundle_root=None)`
  (`scripts/dev_tools/push_down_claude_customizations.py:188-281`). It wraps `fs` in
  `ExcludingFileSystem` (`:261-271`) and delegates to the shared engine
  `push_down_scoped_customizations(... root_folders=ROOT_FOLDERS ...)` (`:272-281`).
- `ROOT_FOLDERS = (Path(".claude"),)` (`:101`); `EXCLUDED_RELATIVE_PATHS = (Path(".claude/settings.local.json"),)` (`:102`).
- Write loop: `scripts/dev_tools/push_down_copilot_customizations.py:366-404`. For each enumerated
  source file it reads, rewrites, `fs.ensure_dir(parent)`, then `fs.write_text(destination_path, rewritten_text)`
  (`:394-395`). There is no merge hook; the only interception seam is a `PushDownFileSystem`
  decorator, the same seam the TypeScript side uses. Protocol:
  `scripts/dev_tools/push_down_copilot_customizations_filesystem.py:17-53` (`list_files`, `is_dir`,
  `is_file`, `read_text`, `write_text`, `ensure_dir`).
- `ExcludingFileSystem.write_text` is a passthrough (`scripts/dev_tools/push_down_claude_filesystem.py:466-468`).
- CLI: `main()` (`push_down_claude_customizations.py:369-399`) sets `source_root=resolved_repo_root`
  (`:392`); see Finding 4.
- Tests: `tests/scripts/dev_tools/test_push_down_claude_customizations.py` (in-memory
  `RecordingFileSystem`, `:22-66`), plus `test_push_down_claude_memory_scope.py`,
  `test_push_down_claude_pack_end_to_end.py`, `test_push_down_claude_pack_manifest_completeness.py`,
  `test_push_down_claude_pack_memory_modes.py`, `test_push_down_claude_pack_selection.py`,
  `test_push_down_claude_resource_contracts.py` (`SCOPED_ROOTS = (Path(".claude"),)` at `:25`).

## 3. Upstream Contract from #507

| Item | Status | Source |
| --- | --- | --- |
| `config` added to Python `ROOT_FOLDERS` | Confirmed intent | epic manifest `Scope`, #507 bullet |
| Python port of the routing merge | Confirmed intent | epic manifest `Scope` and `Shared Design` |
| Port structured so a second merged path can be added without restructuring | Confirmed intent | delegation prompt; epic `Shared Design` ("#508 generalizes this from one merged path to a set") |
| Python/TypeScript parity test over roots and merged paths | Confirmed intent | epic `leading_indicators[0]`, `Shared Design` |
| Python module name for the routing merge | **Assumed**; no #507 artifact names it | sibling `spec.md` sections are empty |
| Registry shape (mapping vs. single decorator) | **Assumed** | same |
| Parity-test file and test names | **Assumed** | same |
| Source root for Python `config/` reads (repo root vs. bundle) | **Unresolved**; see Finding 4 | `push_down_claude_customizations.py:392` |

The #508 design below states its own names and marks each as adaptable to whatever #507 lands.

## 4. Blast-Radius Schema and Consumer Semantics

### 4.1 Keys (bundled copy `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`)

| Key | Type | Reader(s) | Interpretation | Direction of widening |
| --- | --- | --- | --- | --- |
| `version` | int | none found in readers | schema marker | n/a |
| `shared_surfaces` | list[str] | `config_string_list`, `resolve_shared_surfaces`, `config_root_surfaces` (`scripts/dev_tools/_blast_radius_validation.py:115-172`, `:265-293`); PS `Get-ConfigStringList`, `Get-ConfigRootSurface`, `Resolve-BlastRadiusSharedSurface` (`.claude/lib/blast-radius/BlastRadiusConfig.psm1:197-283`, `:410-462`) | exact-member set; a hit yields hard `shared_surface_overlap`; separator-free members also gate token extraction (#452) | more contention (fail-closed); unmatched entries inert |
| `shared_surface_globs` | list[str] | same readers | membership globs | more contention |
| `mandate_reads` | list[str] | `config_mandate_reads` (`_blast_radius_validation.py:174-203`); PS `Get-ConfigMandateRead` (`BlastRadiusConfig.psm1:285-313`) | exclusion set removed from harvest | less contention (relaxation) |
| `mergeable_paths` | list[str] | `config_mergeable_paths` (`_blast_radius_mergeable.py:53-80`), used only in `conflicts` (`_blast_radius_conflicts.py:187-191`); PS `Test-BlastRadiusConflict` | excluded from path-overlap only | less contention (relaxation) |
| `conflict_tolerance` | object | `config_conflict_tolerance` (`_blast_radius_scheduling.py:73`, `:218`); PS `BlastRadiusScheduling.psm1` | scheduling policy; fail-fast shape validation | higher tolerance = fewer edges |
| `write_intent_extraction` | bool | `config_write_intent_extraction` (`_blast_radius_write_intent.py:70`, `:106`) | enables W1-W6 | true = fewer tokens |
| `path_roots` | list[str] | `config_path_roots` (`_blast_radius_write_intent.py:71`, `:131`) | W4 root anchoring; empty disables | more roots = more tokens kept |
| `modules` | object name -> list[str] | `config_modules`, `resolve_modules` (`_blast_radius_validation.py:206-262`); PS `Get-ConfigModuleEntry` (`BlastRadiusConfig.psm1:315-364`) | a module joins a radius when any glob covers any entry; two radii sharing a module get `module_overlap` | a broader module = more contention on every pair it touches |
| `over_breadth_fraction` | number in (0, 1] | `config_over_breadth_fraction` (`_blast_radius_thresholds.py:47-50`); PS `Get-ConfigOverBreadthFraction` (`BlastRadiusConfig.psm1:366-408`) | V3 threshold | scalar |

The surfaces-versus-modules asymmetry is doctrine: an unmatched surface entry is inert, an
over-matching module glob costs concurrency on every pair (`.claude/rules/parallel-orchestration.md:584-593`,
`:383-399`). Every reader treats an absent optional key as "no effect" and validates shape fail-fast.
All list readers deduplicate and ordinally sort (`BlastRadiusConfig.psm1:117-139`), so list order in the
file has no semantic effect.

### 4.2 Consumers that load the file from disk

Verified by `Grep` for `blast-radius.json` across `scripts/`, `.claude/lib/`, `.claude/hooks/`,
`.claude/skills/`, `.claude/agents/`, `.claude/rules/`:

- PowerShell: `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1:171-172`
  (`Get-Content ... | ConvertFrom-Json`).
- Python (not bundled; #763 ports it): `scripts/dev_tools/parallel_drift_detection_cli.py:133`,
  `:206-207`, `:360`.
- Agent-performed reads directed by prose: `.claude/skills/parallel-plan/SKILL.md:203-214`,
  `.claude/skills/parallel-add/SKILL.md:70`, `.claude/skills/parallel-orchestrate/SKILL.md:887`,
  `.claude/agents/parallel-planner.md:162`; each has a bundle mirror under
  `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- Every library reader (`.claude/lib/blast-radius/*.psm1`, `scripts/dev_tools/_blast_radius_*.py`)
  takes an already-parsed `-Config`/`config` value and performs no file I/O.
- Bash: none. `.claude/lib/bash/*` matches only the manifest item field `blast_radius`
  (`parallel-items-validate.sh:60-91`), not the truth table.
- Hooks: none. `.claude/hooks/enforce-parallel-cohort-barrier.ps1:12` mentions blast-radius in a
  comment only; `enforce-parallel-drift-gate-helpers.ps1` reads `items[].blast_radius`.

## 5. Design Options

### (a) Merge the destination's `config/blast-radius.json` on write

Mirror `RoutingMergeFileSystem`: read the destination file and union it into the new document.

- The routing policy is "destination wins except the authoritative `parallel` route; source-only
  entries appended" (`claude-routing-merge.ts:21-31`, `:154-180`, `:191-219`). It works for routing
  because routes are few, named, and hand-authored in both places.
- For blast-radius the destination file is itself push-down output. After one push it contains
  derived modules and shipped surfaces that are indistinguishable from local additions. A merge that
  reads it therefore cannot clear stale entries: a module derived from a directory the destination
  later deleted, or a shipped surface removed upstream (as #500 removed drm-copilot entries), survives
  forever under union. The only fix is provenance tracking, which the file format does not carry and
  which the exhaustive key-partition gate forbids adding as a new top-level key
  (`.claude/rules/parallel-orchestration.md:605-612`).
- The `modules` key conflicts with derivation: "destination wins" freezes the first push's derived
  map; "derived wins" discards the local modules the issue wants kept.
- Verdict: rejected. Idempotent, but cannot clear stale entries and has no correct `modules` rule.

### (b) Destination-local overlay merged at read time

- Requires a new loader in every runtime and a change at every load site in section 4.2: PowerShell
  `Resolve-MergeableConflict.ps1:171-172`, a new `Read-BlastRadiusConfig`-style PowerShell loader,
  the Python drift CLI and its #763 port, four skill/agent prose sites plus their four bundle
  mirrors, and parity tests for the loader in Python and PowerShell. A missed site silently reads
  the un-overlaid table.
- It collides with #763 (same CLI) inside the same epic.
- Verdict: rejected. Correct semantics, but high change surface and drift risk across three runtimes.

### (c) Document the overwrite as intended

- Leaves the observed case (a destination with eighteen hand-added modules, `issue.md:57`) with no
  durable mechanism; contradicts the epic leading indicator "A destination blast-radius file with
  local additions survives a push-down unchanged in those additions" (`epic.md:11`).
- Verdict: rejected.

### (d) Selected: overlay file composed at push time

A destination-owned `config/blast-radius.local.json` that no payload contains. On each push the
blast-radius registry entry composes it onto the freshly generated base document and writes the
result to `config/blast-radius.json`.

- Consumers are unchanged: they still read one file.
- Provenance is explicit: the base is regenerated each push (so stale shipped/derived entries clear),
  and the overlay is authored only by the destination (so local entries persist).
- The function is pure over (bundle, destination layout, overlay), so two consecutive pushes are
  byte-identical.
- The `.local` suffix follows the existing `.claude/settings.local.json` precedent
  (`claude-customizations.ts:73-75`, `push_down_claude_customizations.py:102`).
- The issue's Expected Behavior explicitly admits "a documented destination-local extension point
  that survives a push" (`issue.md:34`).

## 6. Recommendation

Adopt option (d) in both implementations, in one PR, extending the #507 parity test.

### 6.1 Per-key composition semantics

Let `B` be the base document (TypeScript: the derived document from `deriveDestinationModuleMap`;
Python: the bundled source text, since Python has no derivation) and `O` the parsed overlay.

1. **Overlay absent:** write `B` unchanged, byte-identical to today's output.
2. **Overlay unparseable, or its root is not a JSON object:** throw `BlastRadiusOverlayError(path, detail)`
   naming the overlay path; `config/blast-radius.json` is not written (routing precedent).
3. **`version`:** `B` wins. An `O.version` that is present and not equal to `B.version` is an error
   (the overlay was authored against a different schema).
4. **String-list keys** `shared_surfaces`, `shared_surface_globs`, `mandate_reads`, `mergeable_paths`,
   `path_roots`: ordered union, `B` entries in `B` order, then `O` entries not already present, in `O`
   order. A non-list or non-string member in `O` is an error naming the key.
5. **`modules`:** per module name. An `O` module name absent from `B` is added; an `O` module name
   present in `B` (derived or payload) **replaces** that module's glob list, which lets a destination
   narrow an over-broad derived module. Module names are emitted in ordinal order, matching
   `assembleModules` (`claude-blast-radius-derive-core.ts:273-282`). The forbidden-glob guard
   (`FORBIDDEN_GLOBS`, `:117-121`) runs on the composed map and throws `BlastRadiusGuardError` before
   any write.
6. **Object-valued keys** (`conflict_tolerance`): recursive, per member. Nested string lists
   (`append_only_paths`) take the ordered union; nested objects (`weights`, `band_durations`) merge per
   member; nested scalars take the `O` value.
7. **Scalar keys** (`over_breadth_fraction`, `write_intent_extraction`): `O` wins when present.
8. **Keys only in `O`:** appended after `B`'s keys in `O` order. `B`'s fixed emission order is kept.
9. **Shadowing:** an `O` list entry equal to a `B` entry is deduplicated; an `O` module equal in name
   to a `B` module replaces it (rule 5).
10. **Serialization:** 2-space indentation plus trailing newline in both languages. Python must use
    `json.dumps(value, indent=2, ensure_ascii=False) + "\n"` to match `JSON.stringify(v, null, 2)`.
    Integral floats (`1.0`) remain a known divergence class
    (`.claude/rules/parallel-orchestration.md:620`); the parity fixture should avoid them.
11. **Idempotence:** `compose(compose(B, O), O) == compose(B, O)` holds (union and replacement are
    idempotent), and `B` is never read from the destination, so pushing twice produces identical bytes.
12. **Stale entries:** shipped or derived entries that disappear upstream disappear from the output
    on the next push. Overlay entries persist until the destination removes them.
13. **Out of scope:** the overlay cannot remove a shipped surface or a derived module (see Open
    Questions). Shape validation beyond rules 2-5 stays with the consumer readers, which already
    fail fast on malformed values.

The push-down must also add `config/blast-radius.local.json` to `EXCLUDED_RELATIVE_PATHS` in both
implementations so a source-side overlay (for example one in this repository, which the Python CLI
reads as its source root) is never published.

### 6.2 Generalization into a merged-path registry

- **TypeScript.** Replace the hand-built decorator chain at `claude-customizations.ts:274-291` with a
  data registry of decorator factories, composed innermost-first:
  `DESTINATION_WRITE_DECORATORS: ReadonlyArray<{ relativePath: string; wrap(inner, destinationRoot, options): PushDownFileSystem }>`
  in order routing merge, blast-radius overlay, blast-radius derive. Export
  `MERGED_RELATIVE_PATHS: ReadonlyArray<string>` (distinct `relativePath` values, as a literal array
  so the parity test can read it). The overlay decorator must sit **inside** the derive decorator,
  because the derive decorator calls `inner.writeTextFile(path, derived)` and the overlay then
  composes onto the derived text; this leaves `claude-blast-radius-derive.ts` unchanged. Keep
  `RoutingMergeFileSystem`, `BlastRadiusDeriveFileSystem`, and their errors exported
  (`claude-customizations.ts:97-108`) to avoid a breaking change.
- **Python.** A frozen dataclass entry `DestinationMerge(relative_path, input_relative_path, merge)`
  where `merge(source_text, destination_input_text, path) -> str`, a tuple registry
  `MERGED_PATHS`, and one decorator whose `write_text` consults it. `input_relative_path` is needed
  because the routing entry reads the destination path it writes, while the blast-radius entry reads
  the overlay path. If #507 lands a different shape, #508 adapts it to carry `input_relative_path`
  rather than replacing it.
- **#621 consumption.** The exclusion filter wraps outside the composed chain (TypeScript: between
  the registry chain and `ExcludingFileSystem`; Python: outside the merge decorator). It skips or
  reports an excluded path before any registry entry runs, and it can name merged paths in its
  report from `MERGED_RELATIVE_PATHS` / `MERGED_PATHS` without restructuring.

### 6.3 Files to change

| File | Change | Lines now |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` (new) | pure `composeBlastRadiusOverlay(baseText, overlayText, overlayPath): string`, `BlastRadiusOverlayError`, `BLAST_RADIUS_OVERLAY_RELATIVE_PATH`, and `BlastRadiusOverlayFileSystem` | 0 |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | registry, `MERGED_RELATIVE_PATHS`, overlay exclusion, doc comment at `:56-70` | 361 |
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | module header comment only (`:5-12`) | 311 |
| `extensions/drm-copilot/jest.config.cjs` | `coverageThreshold` entry `./src/lib/push-down/claude-blast-radius-overlay.ts` {lines 85, branches 75}; the map has no `global` key, so an unlisted file is ungated (`:242-244`) | 325 |
| `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay.test.ts` (new) | unit and property cases for the pure function and decorator | 0 |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | carriage cases for the overlay (two-push survival, stale clearing); the case at `:356-380` stays valid and should be retitled to state that the main file is regenerated | 461 |
| `scripts/dev_tools/push_down_claude_blast_radius_overlay.py` (new, name assumed) | Python port of the pure compose function and error | 0 |
| Python merge-registry module from #507 (name unknown) | add the blast-radius entry and `input_relative_path` | unknown |
| `scripts/dev_tools/push_down_claude_customizations.py` | overlay exclusion in `EXCLUDED_RELATIVE_PATHS` (`:102`) | 403 |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py` (new) | Python unit and property cases | 0 |
| #507 parity test (name unknown) | assert equal merged-path sets, equal overlay constant, overlay in both exclusion lists, and byte-equal compose output on shared fixtures | unknown |
| `.claude/rules/parallel-orchestration.md` and its bundle mirror | document the overlay under "The published truth table is not a copy of this one" (`:539-612`) | Markdown (no cap) |

Do not touch `.claude/hooks/enforce-powershell-batch-budget.ps1` or its tests (#769). No hook
changes are needed, so no enforcement hook gains a Python leg. No new dependency is needed.

## 7. Testing Implications

- **TypeScript unit** (new overlay test file): each rule in 6.1 (absent overlay byte-identity;
  unparseable and non-object overlay errors with the destination file unchanged; version equal,
  absent, and mismatched; union order and deduplication per list key; module add, replace, and
  forbidden-glob rejection; nested `conflict_tolerance` merge; scalar override; overlay-only key
  appended; non-list value error).
- **TypeScript carriage** (`claude-config-carriage.test.ts`): an overlay addition survives two
  consecutive pushes; the two outputs are byte-identical; a module previously present only in the
  destination main file is cleared; a derived module can be replaced from the overlay; the overlay
  file itself is never written or modified by the push.
- **Property tests.** Neither `fast-check` nor `hypothesis` is a dependency (no match in
  `extensions/drm-copilot/package.json` or `pyproject.toml`), and the repository precedent is
  exhaustive enumeration over a fixed finite domain
  (`tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py:11-19`). Properties:
  identity (`O = {}` yields `B`), idempotence, superset (every `B` list entry survives), overlay
  inclusion, determinism, and `version` preservation. The same pattern applies in jest.
- **Python unit**: mirror the TypeScript cases with the in-memory `RecordingFileSystem` pattern
  (`test_push_down_claude_customizations.py:22-66`); no temporary files.
- **Parity**: shared fixture pairs `(B, O)` whose composed bytes must be equal in both languages.
- **Coverage**: Python coverage source already includes `scripts/dev_tools`
  (`pyproject.toml:118-119`); the new TypeScript file needs the jest entry above. Targets are line
  >= 85% and branch >= 75%.

## 8. File-Size Budget

| File | Lines | Headroom to 500 |
| --- | --- | --- |
| `claude-customizations.ts` | 361 | 139 |
| `claude-routing-merge.ts` | 311 | 189 |
| `claude-blast-radius-derive.ts` | 306 | 194 (no change planned) |
| `claude-blast-radius-derive-core.ts` | 394 | 106 (no change planned) |
| `claude-config-carriage.test.ts` | 461 | 39 (put most new cases in the new test file) |
| `config-carriage.test-helpers.ts` | 254 | 246 |
| `blast-radius-derive.test.ts` | 484 | 16 (do not extend) |
| `blast-radius-derive-core.test.ts` | 486 | 14 (do not extend) |
| `jest.config.cjs` | 325 | config file |
| `push_down_claude_customizations.py` | 403 | 97 |
| `push_down_claude_filesystem.py` | 472 | 28 (do not extend) |
| `push_down_copilot_customizations.py` | 504 | already over the cap (pre-existing; do not extend) |
| `test_push_down_claude_customizations.py` | 284 | 216 |
| `test_push_down_claude_resource_contracts.py` | 500 | 0 (do not extend) |
| `test_blast_radius_config.py` | 499 | 1 (do not extend) |
| `test_blast_radius_config_parity.py` | 499 | 1 (do not extend) |

Counts were taken with `Grep` pattern `^` in count mode, which counts every line.

## Numeric Derivation Evidence

Numeric claim: the Claude TypeScript push-down intercepts exactly **2** destination-relative write
paths, and that count remains 2 after #508 (the overlay applies to an existing path).

- **Complete Family:** destination-relative paths whose write is intercepted by a Claude push-down
  write-path decorator in `extensions/drm-copilot/src/lib/push-down/`.
- **Exhaustive Search Scope:** every `*.ts` file in `extensions/drm-copilot/src/lib/push-down/`.
- **Inclusion Rules:** a `PushDownFileSystem` implementation composed by `claude-customizations.ts`
  whose `writeTextFile` branches on a destination-relative path.
- **Exclusion Rules:** `RealPushDownFileSystem` (real I/O); `ExcludingFileSystem` (passthrough write,
  `claude-filesystem-adapter.ts:296-298`); Codex `CodexFilteringFileSystem` and
  `RoutingConfigFileSystem` (Codex surface, out of scope per `epic.md:73-74`); `.gitignore`
  (post-copy merge on the raw adapter at `claude-customizations.ts:320`, not a published source file).
- **Primary Search Strategy or Query Expression:** `Grep "implements PushDownFileSystem"` in the scope,
  then inclusion rules applied.
- **Primary Member Set:** `RoutingMergeFileSystem` -> `config/orchestration-routing.json`;
  `BlastRadiusDeriveFileSystem` -> `config/blast-radius.json`.
- **Primary Count:** 2.
- **Cross-check Search Strategy or Query Expression:** `Grep "isDeriveTarget|isMergeTarget|relativeToPosix\(path, this\.destinationRoot\) ==="`
  plus `Grep "export const \w*RELATIVE_PATH\w* *="` in the scope, with exclusion rules applied.
- **Cross-check Member Set:** `claude-routing-merge.ts:306-308` with `ROUTING_MERGE_RELATIVE_PATH`
  (`claude-customizations.ts:70`) -> `config/orchestration-routing.json`;
  `claude-blast-radius-derive.ts:301-303` with `BLAST_RADIUS_RELATIVE_PATH`
  (`claude-blast-radius-derive-core.ts:76`) -> `config/blast-radius.json`.
  (`CLAUDE_GITIGNORE_RELATIVE_PATH` and Codex `ROUTING_CONFIG_RELATIVE_PATH` excluded by rule.)
- **Cross-check Count:** 2.
- **Member-set Comparison:** normalized sets `{config/blast-radius.json, config/orchestration-routing.json}`
  are identical. The assertion "`MERGED_RELATIVE_PATHS` has exactly two members" may be proposed.

The Python count is 0 today (no decorator in `scripts/dev_tools/push_down_claude_*.py`; the only
`write_text` override there is the passthrough at `push_down_claude_filesystem.py:466-468`). Its
post-#507 value is not asserted here because #507's design is unconfirmed.

## Automation Feasibility

Fully automatable with no human interaction. All work is source and test edits in TypeScript and
Python, verified by jest and pytest against in-memory filesystems. No external service, credential,
manual UI step, or destination repository is required. The issue's manual item ("confirm no existing
destination depends on the current overwrite to clear stale local entries") is satisfied by design:
the main file is still regenerated on every push, so stale-entry clearing is preserved.

## Rejected Alternatives

- (a) Merge the destination main file: cannot distinguish local additions from prior push output,
  so stale entries never clear, and it has no correct rule for `modules`.
- (b) Read-time overlay: correct, but changes every load site in PowerShell, Python, and skill prose
  plus mirrors, and overlaps #763.
- (c) Document the overwrite: leaves the defect and contradicts the epic leading indicator.

## Open Questions

1. **Python base document and source root (#507).** Will #507 source `config/` from the bundle for
   the Python CLI? If it keeps `source_root=repo_root`, the Python path publishes the self-hosted
   blast-radius table (Finding 4). #508's overlay semantics are unaffected, but the base differs.
2. **Python derivation parity.** TypeScript composes onto a derived base; Python composes onto the
   bundled base because it has no derivation. Accept this as a documented divergence, or file a
   follow-up to port the derivation (about 1,000 lines across three TypeScript files)?
3. **Migration.** A destination whose main file already holds hand-added entries (the eighteen-module
   case) loses them on the first push after this change unless it first moves them into the overlay.
   Is documentation enough, or should the push report destination entries it is about to discard?
   The current `PushDownSummary` has no warnings field.
4. **Removal.** Should the overlay be able to remove a shipped surface or a derived module (for
   example a `remove` block)? The recommendation excludes it; module replacement (rule 5) covers the
   over-broad-derived-module case.
5. **Guard scope.** Should `FORBIDDEN_GLOBS` apply to overlay-authored modules (recommended, rule 5)
   or only to derived ones?
6. **`version` mismatch.** Error (recommended, rule 3) or silently ignore?
7. **#507 names.** Python registry module name, entry type, and parity-test file are unknown and
   must be reconciled when #507's plan is approved.
