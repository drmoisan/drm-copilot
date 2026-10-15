# Code Review: Push-Down Root Folders Divergence (#507)

- Branch: `bug/push-down-root-folders-divergence-exec-507`
- Head commit: `977a1011`
- Review base: `origin/epic/push-down-payload-correctness-integration...HEAD`
- Review timestamp: 2026-09-29T18-12
- Files reviewed: 6 Python production files, 10 Python test files (9 new, 1 modified), 1 JSON fixture, 1 Jest test file, `README.md`

## Executive Summary

The change is a faithful, well-factored port of the TypeScript Claude push-down write path to Python. The routing merge, blast-radius derivation, and decorator composition were compared line by line against `claude-routing-merge.ts`, `claude-blast-radius-derive-core.ts`, `claude-blast-radius-derive-manifests.ts`, and `claude-blast-radius-derive.ts`; no semantic divergence was found for the constructs the shipped documents contain. The composition order in `push_down_customizations` matches the spec's data-flow diagram (`ExcludingFileSystem` over `BundleConfigFileSystem` over derive over merge over the inner adapter). Pure logic is separated from I/O, errors are raised before the inner write, and the extension seams for #508 and #621 are single, named, and pinned by tests.

No blocking findings. Seven non-blocking findings are recorded below; the most material is the broad `except Exception` in `_list_tolerantly`, which is spec-pinned parity behavior but does not log.

The four executor deviations named by the caller are classified as follows:

1. P10-T3 unchecked (missing `Claude-Session:` trailer): non-blocking. The commit exists with the specified subject; session attribution guidance governs trailers.
2. Direct edits instead of typed-engineer delegation: non-blocking. The code was independently re-verified with the full per-language toolchain.
3. #621 docstring sentence wraps across two lines: non-blocking. AC15's `rg` check matches and the docstring test normalizes whitespace.
4. Read-only `inner` property on the write decorators: non-blocking. Additive, read-only, and useful for #621 introspection.

## Semantic Parity Review

| Behavior | TypeScript | Python | Result |
|---|---|---|---|
| Destination absent | Writes source text unchanged | `DestinationMergeFileSystem.write_text` writes source content when `is_file` is false | Equivalent |
| `parallel` replacement | `sourceDefinition !== undefined` | `name in source_routes` | Equivalent, including a JSON `null` source definition |
| Non-object `routes` | `asObject` returns `null` for arrays, primitives, `null` | `_as_object` returns `None` for non-`dict` | Equivalent |
| Parse rejection | `JSON.parse` rejects `NaN`/`Infinity` | `parse_constant=_reject_constant` | Equivalent |
| Serialization | `JSON.stringify(obj, null, 2) + "\n"` | `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"` | Equivalent for the shipped document; integral-float and integer-key ordering quirks are documented as out of scope in the spec |
| Error message path | `path` string (POSIX in TS) | `path.as_posix()` | Equivalent on Windows and POSIX |
| Carried blast-radius keys | Absent key yields `undefined`, omitted by `JSON.stringify` | `if key in source` omits absent keys | Equivalent |
| Module sort | `compareOrdinal` (UTF-16 code units) | `sorted` (code points) | Equivalent for BMP names; documented in the manifests module |
| Scan tolerance | `catch {}` at any level | `except Exception: return []` | Equivalent (see finding F1) |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (non-blocking) | `scripts/dev_tools/push_down_claude_blast_radius_derive.py` | `_list_tolerantly`, lines 97-109 | Broad `except Exception` returns an empty listing and does not log, so a programming error in an injected lister (for example a `TypeError`) is silently converted into "no entries". | Add a `logging.debug` call naming the path and exception type, or narrow to `(OSError, ValueError)` together with the TypeScript side in a follow-up. | `.claude/rules/python.md` asks that broad handlers carry context. The spec and `claude-blast-radius-derive.ts:27-35` pin "any failure contributes no entries", and the docstring states that rationale, so this is not a defect against the spec. | `test_collect_observations_tolerates_lister_errors` and the root-failure test raise `PermissionError` and `RuntimeError` and assert an empty observation. |
| Minor (non-blocking) | `scripts/dev_tools/push_down_claude_destination_writes.py` | `MERGED_RELATIVE_PATHS`, lines 86-88; default arguments at lines 166 and 293 | The registry is a mutable module-level `dict` typed as `Mapping` and used as a default argument. A caller that mutates it through a cast would change behavior for every later push in the process. | Keep the literal (AC12 and the `ast` parity extraction require it) and document that the mapping must not be mutated at runtime; #508 should extend the literal rather than mutate it. | The `Mapping` annotation already prevents mutation under Pyright; the risk is limited to untyped callers. | Lines 86-88, 166, 293. |
| Minor (non-blocking) | `scripts/dev_tools/push_down_claude_destination_writes.py` | `_DelegatingFileSystem.inner`, lines 121-125 | Caller deviation 4: a public read-only `inner` property was added to all three decorators for test introspection. | Keep. Mention in the #621 hand-off that the property is the supported way to inspect the stack. | Additive, read-only, and avoids tests reaching into `_inner`. The TypeScript decorators keep `inner` private, so this is a Python-only surface, which is acceptable because the parity test does not compare decorator internals. | `test_build_stack_layer_order_derive_over_merge_over_inner` asserts `stack.inner` and `stack.inner.inner`. |
| Informational | `scripts/dev_tools/push_down_claude_destination_writes.py` | Module docstring, lines 24-27 | Caller deviation 3: the #621 sentence wraps across lines 25-26 and the #508 and "Downstream children" sentences sit outside the indented docstring sections. | No change required. | The 88-column limit forces the wrap; AC15's `rg -n "#508|#621"` returns lines 24 and 25; the docstring test normalizes whitespace before matching the full sentences. | `test_module_docstring_names_downstream_seams`. |
| Informational | `scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py` | `compare_ordinal` (line 130), `is_manifest_file_name` (line 159) | Both functions are exported and tested but have no production caller in Python. | Keep for parity with the TypeScript module's exports, or remove in a later clean-up if parity of the export surface is not a goal. | They are small, pure, and covered; they mirror exported TypeScript symbols. | `rg "compare_ordinal|is_manifest_file_name\("` finds only the definition and test callers. |
| Informational | `scripts/dev_tools/push_down_claude_destination_writes.py` | `BundleConfigFileSystem.list_files`, lines 267-275 | Redirection applies only when `root` equals the source `config` directory exactly; a listing of a nested `config/` subdirectory would not be redirected. | No change required now. If the bundle `config/` ever gains subdirectories, extend `list_files` to redirect any root under the source `config` tree. | The engine lists each root folder exactly once (`push_down_copilot_customizations.py:171-176`), and the bundle `config/` holds two flat files, so the current behavior is correct. `is_file` and `read_text` already redirect any descendant path. | `test_bundle_config_lists_bundle_files_under_source_config_root`, engine enumeration loop. |
| Informational | `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/plan.2026-09-29T14-13.md` | P10-T3, line 165 | Caller deviations 1 and 2: P10-T3 is unchecked (its acceptance demands a `Claude-Session:` trailer, and it says not to push), and the plan's delegation line (line 23) was not followed. | Annotate P10-T3 with the reason it remains unchecked so a later reader does not treat the commit as absent. | Commit `977a1011` exists with the planned subject and the full change set, and earlier phase commits `e8f00ca3` through `e263e942` do carry the trailer. The session attribution guidance supersedes plan text for trailers. The code outcome of direct edits was re-verified by the reviewer with Black, Ruff, Pyright, pytest, Prettier, ESLint, and Jest. | `git log origin/epic/push-down-payload-correctness-integration..HEAD`. |

## Positive Observations

- `push_down_claude_customizations.py:115` declares `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"), Path("config"))` on a single line, which keeps the `ast` extraction in the parity test simple.
- Errors are raised before `self._inner.write_text`, so destination bytes are preserved on `RoutingMergeError`, `BlastRadiusDeriveError`, and `BlastRadiusGuardError`; both the decorator tests and the end-to-end carriage test assert this.
- The parity test strips TypeScript comments while preserving string literals, asserts that each extraction finds at least one declaration, and includes synthetic divergence tests, so it cannot pass vacuously.
- The shared fixture is exercised by both pytest and Jest, which pins byte-level serialization parity for the nine cases on both sides.
- `test_push_down_customizations_obtains_decorators_only_through_stack` checks both behavior (the patched stack builder is called once) and structure (the entry-point source does not name either decorator), which enforces the single-assembly-point seam.
- All new modules are well under the 500-line limit (largest new production module: 314 lines).

## Verification Performed

- Read every new and changed production module in full and compared it against its TypeScript counterpart.
- Re-ran Black, Ruff, and Pyright on all 15 changed Python files: clean.
- Re-ran `pytest tests/scripts/dev_tools -k push_down_claude` with per-module branch coverage: 194 passed; per-module figures identical to the executor's recorded evidence.
- Re-ran the full pytest suite with repo-wide coverage: 5472 passed, 6 skipped.
- Re-ran Prettier, ESLint, and Jest on the new Jest file: clean; 9 tests passed.

## Blocking Findings

None.
