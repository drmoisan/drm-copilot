# Code Review — Issue #508 (blast-radius-config-has-no-merge-decorator)

- Timestamp: 2026-09-29T19-32
- Branch: `bug/blast-radius-config-has-no-merge-decorator-exec-508` @ `4c105aa4`
- Base: `origin/epic/push-down-payload-correctness-integration` @ `fc96a144`
- Scope: full branch diff (TypeScript, Python, JSON fixtures, Markdown)

## Executive Summary

Verdict: PASS (approve with Non-blocking findings).

The change introduces a destination-owned overlay, `config/blast-radius.local.json`, composed at push time onto the regenerated `config/blast-radius.json` by a pure function in each language, and generalizes the destination-side write handling into a registry in both implementations. The design follows spec option (d), decorator ordering is correct in both languages (derive, then overlay, then write), errors are raised before any write, and test coverage of the new code is 99.55% or higher for lines and 95.88% or higher for branches.

No Blocking findings. Four Non-blocking findings are recorded: a TypeScript/Python divergence for overlay keys named after `Object.prototype` members (NB-1), a documentation statement that misdescribes the Python base document (NB-2), a non-injectable input-path map at the #621 extension seam (NB-4), and a test file at the 500-line cap (NB-5). NB-3 (line-level `pragma: no cover`) and NB-6 (absent `quality-tiers.yml`) are recorded in the policy audit as G1 and G2.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` | lines 230, 242, 316, 323 | `in` and bracket lookup consult the prototype chain, so overlay-only keys such as `constructor`, `toString`, `valueOf` are dropped in TypeScript but appended in Python (NB-1). | Use own-property checks (`Object.hasOwn`) or `Object.create(null)` maps; add a corpus fixture with a prototype-named overlay-only key. | Deviates from spec rule 8 and from byte-identical parity for this input class; practical impact is low because no schema key uses these names and consumers reject unknown keys. | Reviewer reproduction: identical inputs produce different outputs in the two languages (see NB-1 below). |
| Non-blocking | `.claude/rules/parallel-orchestration.md` and bundled mirror; `spec.md` | line 620 (both rule copies); spec lines 84, 173 | Documentation states Python composes onto the "published" base; Python composes onto the derived base since #507 (NB-2). | Correct the sentence in both rule copies (keep them byte-identical) and annotate spec decision 2 as superseded. | Misinforms destination operators; no behavioral effect. | `build_destination_write_stack` wraps `BlastRadiusDeriveFileSystem` outside `DestinationMergeFileSystem` (`push_down_claude_destination_writes.py:394-399`); the #508 docstring at line 27 already says "derived document". |
| Non-blocking | `scripts/dev_tools/push_down_claude_destination_writes.py` | lines 131-133, 269-279 | `INPUT_RELATIVE_PATHS` is a module global read directly by `DestinationMergeFileSystem`, while `merges` is injectable (NB-4). | Add an injectable `input_paths` parameter or drive the decorator from `MERGED_PATHS`. | Coupling at the seam #621 consumes; no current caller affected. | Source inspection. |
| Non-blocking | `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py` | whole file (500 lines) | File is at the 500-line cap (NB-5). | Put follow-up Python cases in a sibling module. | Compliant, but no headroom remains. | Reviewer `wc -l`. |

## Summary of the Change

- A destination-owned overlay `config/blast-radius.local.json` is composed at push time onto the regenerated `config/blast-radius.json` by a pure function in each language (`composeBlastRadiusOverlay`, `compose_blast_radius_overlay`).
- TypeScript: the hand-built decorator chain in `pushDownCustomizations` is replaced by the `DESTINATION_WRITE_DECORATORS` registry folded innermost-first (routing merge, overlay, derive), with `ExcludingFileSystem` outermost. `MERGED_RELATIVE_PATHS` is exported as a literal array.
- Python: the #507 `MERGED_RELATIVE_PATHS` mapping gains a `config/blast-radius.json` entry; `INPUT_RELATIVE_PATHS` redirects that entry's read to the overlay; `DestinationMerge`/`MERGED_PATHS` provide a read-only typed view. `DestinationMergeFileSystem.write_text` reads the redirected input path.
- Both implementations add the overlay path to `EXCLUDED_RELATIVE_PATHS`.
- A six-case shared JSON corpus pins byte-identical composition output across languages.

## Strengths (evidence-based)

- Composition is pure and I/O-free in both languages; decorators only read the overlay and delegate the write. Errors are raised before the inner write, and tests assert the destination main file keeps its prior bytes (AC05–AC07).
- Decorator ordering is correct in both languages: derivation runs first and the overlay composes onto the derived document, so overlay-authored modules are not overwritten by the derivation. Verified in `claude-customizations.ts` (registry fold order, lines 107–134) and `push_down_claude_destination_writes.py` `build_destination_write_stack` (derive wraps merge, lines 394–399).
- The Python port anticipates two JavaScript/Python semantic differences explicitly: `_strictly_equal` mirrors `===` for the `version` check (`bool` versus `int`), and `parse_constant=_reject_constant` rejects `NaN`/`Infinity` as `JSON.parse` does.
- The #507 registry and parity test are extended, not replaced: no `class`/`def` line is removed from `push_down_claude_destination_writes.py` or `test_push_down_claude_parity.py`, and the new parity file imports `REPO_ROOT`/`TS_CUSTOMIZATIONS` from the #507 parity module.
- A jest case asserts `MERGED_RELATIVE_PATHS` equals the distinct `relativePath` values of the registry in first-seen order, which guards the literal array against drift from the registry.
- Fail-before/pass-after regression evidence exists for both languages (`evidence/regression-testing/`).

## Findings

### NB-1 (Non-blocking) — TypeScript drops overlay keys that collide with `Object.prototype` member names; Python keeps them

- Location: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts:242` (`if (!(key in merged))`), `:323` (`if (!(key in composed))`); related lookups `overlay[key]` at `:230` and `:316`.
- Behavior: `in` consults the prototype chain, so an overlay-only key such as `constructor`, `toString`, `valueOf`, or `hasOwnProperty` is treated as already present and silently skipped. Python dictionary membership has no such chain, so the Python port appends the key.
- Reviewer reproduction (TypeScript transpiled in-process and Python run against the same inputs): base `{"version":1,"conflict_tolerance":{"weights":{"a":1}}}`, overlay `{"constructor":"x","toString":["y"],"conflict_tolerance":{"valueOf":3}}`. TypeScript output omits `constructor`, `toString`, and `conflict_tolerance.valueOf`; Python output includes all three.
- Impact: deviation from spec rule 8 (overlay-only keys appended) and from the byte-identical parity claim for these inputs. Practical impact is low: none of these names is a blast-radius schema key, and consumer readers reject unknown keys. The shared corpus does not exercise the case, so parity tests pass.
- Recommendation: use own-property checks (`Object.hasOwn(merged, key)` / `Object.prototype.hasOwnProperty.call`) for membership and lookup, or build intermediate maps with `Object.create(null)`; add a corpus fixture with a prototype-named overlay-only key so both languages are pinned.

### NB-2 (Non-blocking) — Documentation states Python composes onto the "published" base, but Python composes onto the derived base

- Locations:
  - `.claude/rules/parallel-orchestration.md:620` and the bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md:620`: "(the derived document in TypeScript, the published document in Python)".
  - `spec.md:84` ("Python: ... (no derivation exists in Python)") and `spec.md:173` (decision 2, "Python derivation gap").
- Observed code: #507 landed a Python `BlastRadiusDeriveFileSystem` using `derive_destination_module_map`, and `build_destination_write_stack` wraps it outside `DestinationMergeFileSystem`. The #508 code itself documents this correctly (`push_down_claude_destination_writes.py:27`, "onto the derived document"; `merge_blast_radius_overlay` docstring, "Derived `config/blast-radius.json`").
- Impact: the published rule text misdescribes the Python base to destination operators. No behavioral effect.
- Recommendation: change "the published document in Python" to state that both implementations compose onto the derived document, in both copies of the rule (keeping them byte-identical), and annotate spec decision 2 as superseded by #507's derivation port.

### NB-4 (Non-blocking) — `INPUT_RELATIVE_PATHS` is module-global while `merges` is injectable

- Location: `scripts/dev_tools/push_down_claude_destination_writes.py:131–133` (module constant) and `:269–279` (`DestinationMergeFileSystem.write_text` reads `INPUT_RELATIVE_PATHS` directly).
- Behavior: `build_destination_write_stack(..., merges=...)` and `DestinationMergeFileSystem(..., merges=...)` accept a replacement merge map, but the input-path redirection cannot be supplied alongside it. A caller that registers its own function for `config/blast-radius.json` still has its input redirected to the overlay path.
- Impact: design coupling at an extension seam that #621 will consume; no current caller is affected.
- Recommendation: accept an optional `input_paths: Mapping[str, str] = INPUT_RELATIVE_PATHS` parameter next to `merges`, or drive the decorator from `MERGED_PATHS` (which already carries `input_relative_path`) so the registry has one source.

### NB-5 (Non-blocking) — Test file at the 500-line cap

- Location: `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py` (500 lines).
- Impact: compliant, but any future case (for example the NB-1 fixture) must go to a new file.
- Recommendation: place follow-up Python cases in a sibling test module.

## Additional Review Notes (no action required)

- `composeModules` applies the forbidden-glob guard only when the overlay supplies `modules`. When it does not, the base `modules` map is the derived map, which the derive decorator already guards. This matches spec rule 5 and decision 5.
- `mergeValues` returns the overlay value when base and overlay types differ (for example base object, overlay scalar). Spec rule 13 assigns shape validation beyond rules 2–5 to consumer readers; behavior is consistent across languages.
- Duplicate entries inside the base list are preserved; duplicates contributed by the overlay are removed. Both languages behave identically.
- `relativeToPosix`/`normalizePosix` duplicate helpers in `claude-routing-merge.ts`; the duplication is documented in the doc comment. A shared helper would reduce duplication but is outside the defect scope.
- `pushDownCustomizations` passes `{}` or `{ listEntries }` to every decorator; only the derive entry reads it. Acceptable for a three-entry registry.

## Test Quality

- Tests follow Arrange–Act–Assert with comments, use in-memory file systems, and read only committed fixtures.
- Negative paths are covered: unparseable overlay and base, non-object root, non-list and non-string members, version mismatch (including `true` versus `1` in Python), forbidden globs from the overlay (all three globs).
- Property tests use exhaustive enumeration over 24 base/overlay pairs in each language (identity, idempotence, superset, overlay inclusion, determinism, version preservation).
- Reviewer reruns: jest (overlay, carriage, customizations) 5 suites / 92 tests passed; pytest (5 files) 90 passed.
