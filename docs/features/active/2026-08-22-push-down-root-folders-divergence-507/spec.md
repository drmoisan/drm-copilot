# 2026-08-22-push-down-root-folders-divergence (Spec)

- **Issue:** #507 (also covers #764 part 2)
- **Parent (optional):** epic #770, `push-down-payload-correctness` (wave 0)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T14-20
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Research:** `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/research/research.2026-09-29T14-20.md`

## Context

The Python and TypeScript implementations of the Claude push-down publish different sets of root folders. The TypeScript path publishes `.claude` and `config`; the Python path publishes `.claude` only. A destination pushed through the Python entry point therefore never receives the `config` tree, including `config/blast-radius.json` and `config/orchestration-routing.json`.

Research found that adding `config` to the Python declaration alone is not sufficient. The TypeScript path reads `config/` from the extension bundle, merges `config/orchestration-routing.json` into an existing destination file, and derives `config/blast-radius.json` from the destination layout rather than copying the bundled bytes. The Python path reads from the repository root and overwrites every file unconditionally. A naive declaration change would publish five repo-root files, including the self-hosted blast-radius table and three repo-only files, with overwrite semantics (research Section 1, claim N2).

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: source inspection of both push-down implementations
- Data source or fixture: `scripts/dev_tools/push_down_claude_customizations.py` and `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. A destination pushed through the Python path silently lacks the blast-radius and orchestration-routing truth tables it is expected to carry. The blast-radius library then falls back to whatever the destination already had, or to nothing, and the resulting conflict graph is not the one the payload intended. The severity is not higher only because the TypeScript path appears to be the one in routine use.

## Repro & Evidence

Steps to Reproduce:
1. Read `scripts/dev_tools/push_down_claude_customizations.py` line 101.
2. Read `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` line 54 (line 50 at commit `627c45d1`).
3. Compare the two declarations.

Expected:
The two implementations publish the same payload. A destination receives the same files whichever entry point performed the push, so the two surfaces cannot drift into producing different destination states.

Actual:

```text
scripts/dev_tools/push_down_claude_customizations.py:101
  ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)

extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:54
  export const ROOT_FOLDERS: ReadonlyArray<string> = [".claude", "config"];
```

Issue #462 added the `config` tree to the shipped payload on the TypeScript side. The Python side was not extended.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: the two declarations quoted above, read at commit `627c45d1` and re-verified at `b7b4a2dc`.

## Scope & Non-Goals

- In scope:
  - Add `config` to Python `ROOT_FOLDERS` so both implementations publish `(".claude", "config")` in that order.
  - Source the Python `config/` root from the extension bundle (`extensions/drm-copilot/resources/claude-customizations/config/`), the same source of truth TypeScript uses.
  - Port the TypeScript routing-file merge (`claude-routing-merge.ts`) to Python with identical semantics.
  - Port the TypeScript blast-radius derivation (`claude-blast-radius-derive.ts`, `-core.ts`, `-manifests.ts`) to Python.
  - Introduce the `MERGED_RELATIVE_PATHS` merge registry and the `build_destination_write_stack()` composition seam used by #508 and #621.
  - Add a static Python/TypeScript parity test and a shared routing-merge behavioral fixture.
  - Update the existing root-folder assertion, `README.md`, module docstrings, and CLI help.
  - File follow-up issues for the two out-of-scope divergences listed below.
- Out of scope / non-goals:
  - #764 part 1 (missing `Test-ModifiedWorkflowNeedsGreenRun.ps1`).
  - Python `.gitignore` managed-block merge (TypeScript `deliverDestinationGitignore`). Follow-up issue.
  - Python publishing gitignored `.claude` subtrees (`.claude/worktrees/**`, `.claude/state/**`) when run from a main checkout. Follow-up issue.
  - The Codex Python push-down overwriting `config/orchestration-routing.json` (epic non-goal; recorded only).
  - Blast-radius merge (#508) and destination exclusion manifest (#621).
  - Changing `.claude` sourcing in the Python CLI (it continues to read `.claude` from the repository root).
- Explicitly excluded systems, integrations, or datasets:
  - TypeScript production code under `extensions/drm-copilot/src/**` (no changes).
  - `scripts/dev_tools/skill_bundle_contract.py` (edited by sibling #763; it already declares `PUBLISHED_ROOT_FOLDERS = (".claude", "config")`).
  - `scripts/dev_tools/push_down_copilot_customizations.py` (504 lines, over the size cap; not edited).
  - `scripts/dev_tools/push_down_claude_filesystem.py` (472 lines; no code added).
  - `SCOPED_ROOTS` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (remains `(Path(".claude"),)`; file is at 500 lines).
  - `.claude/hooks/enforce-powershell-batch-budget.ps1` and its tests (#769).

## Root Cause Analysis

Issue #462 extended one implementation and not the other. This is the same class of gap that produced issue #500: a payload contract expressed in two places where only one was updated. No test compared the two declarations. The existing pin in `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py:103-117` compares the TypeScript constant to `skill_bundle_contract.PUBLISHED_ROOT_FOLDERS`, not to the Python push-down constant.

The divergence extends beyond the declaration. The TypeScript write path wraps the adapter in `BlastRadiusDeriveFileSystem` and `RoutingMergeFileSystem` (`claude-customizations.ts:274-306`); the Python write path has no destination-side decorator (`push_down_claude_customizations.py:261-281`). The Python path also sources from the repository root, whose `config/` holds five files, while the bundle `config/` holds two.

The note in `issue.md` that locates the `SCOPED_ROOTS` gap in `.claude/rules/parallel-orchestration.md` is stale; that file no longer contains `SCOPED_ROOTS`. `SCOPED_ROOTS` must remain `.claude`-only because its mirror test requires repo-root files to be byte-identical in the bundle, which the repo-only config files and the self-hosted blast-radius table are not.

## Proposed Fix

### Design summary (what changes where):

1. `scripts/dev_tools/push_down_claude_customizations.py`: `ROOT_FOLDERS = (Path(".claude"), Path("config"))`. The run composes `ExcludingFileSystem(BundleConfigFileSystem(build_destination_write_stack(fs, ...)), ...)` so the pack filter still sees source-rooted `config/...` paths, `config/` is read from the bundle, and destination writes pass through derive then merge.
2. New pure module `scripts/dev_tools/push_down_claude_routing_merge.py`: Python port of `claude-routing-merge.ts`.
3. New pure module(s) `scripts/dev_tools/push_down_claude_blast_radius_derive.py` (split into `_manifests` and `_core` modules if it would exceed about 450 lines): Python port of the TypeScript derivation.
4. New adapter module `scripts/dev_tools/push_down_claude_destination_writes.py`: `MERGED_RELATIVE_PATHS`, `DestinationMergeFileSystem`, `BlastRadiusDeriveFileSystem`, `BundleConfigFileSystem`, and `build_destination_write_stack()`.
5. New parity test `tests/scripts/dev_tools/test_push_down_claude_parity.py` and shared fixture `tests/fixtures/push_down/routing-merge-parity.json`, exercised by pytest and by a new Jest case.

### Boundaries and invariants to preserve:

- Enumeration order `.claude` then `config` is a summary-artifact contract and must match TypeScript.
- The published `config/` population is the bundle population: `config/blast-radius.json` (derived) and `config/orchestration-routing.json` (merged). The repo-only files `orchestration-handoff-registry.json`, `orchestration-handoff.schema.json`, and `poshqc-scan.json`, and the repo-root self-hosted `blast-radius.json` bytes, are never published.
- A merge or derivation error is raised before the inner write, so the destination file bytes are unchanged.
- `.claude` sourcing, pack filtering, agent-memory scope filtering, and memory modes behave as before.
- Pushed-down enforcement hooks gain no Python legs. All changes are in `scripts/dev_tools/` (a repository dev tool, not shipped) and tests.
- Every new or changed production and test file stays under 500 lines.

### Dependencies or blocked work:

- No upstream dependency. #508 (wave 1) and #621 (wave 2) depend on this change and extend its seams.
- Sibling #763 (wave 0) edits `skill_bundle_contract.py`; this change does not touch that file.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| File | Change |
|---|---|
| `scripts/dev_tools/push_down_claude_customizations.py` (403 lines) | `ROOT_FOLDERS`, bundle-root resolution, stack wiring, optional `list_entries` keyword, docstrings, CLI help. About +20 lines. |
| `scripts/dev_tools/push_down_claude_routing_merge.py` | New, pure. |
| `scripts/dev_tools/push_down_claude_blast_radius_derive*.py` | New, pure. |
| `scripts/dev_tools/push_down_claude_destination_writes.py` | New, adapters and seams. |
| `tests/scripts/dev_tools/test_push_down_claude_customizations.py` | Line ~80 assertion updated to `(Path(".claude"), Path("config"))`. |
| `tests/scripts/dev_tools/test_push_down_claude_routing_merge.py` | New. |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive*.py` | New. |
| `tests/scripts/dev_tools/test_push_down_claude_destination_writes.py` | New. |
| `tests/scripts/dev_tools/test_push_down_claude_config_carriage.py` | New, end-to-end through `push_down_customizations`. |
| `tests/scripts/dev_tools/test_push_down_claude_parity.py` | New, static parity plus shared-fixture merge parity. |
| `tests/fixtures/push_down/routing-merge-parity.json` | New committed fixture. |
| `extensions/drm-copilot/src/**/*.test.ts` (one new Jest case) | Reads the shared fixture and asserts `mergeRoutingDocuments` output. Test code only. |
| `README.md` (~251) | Claude payload description includes `config/`. |

#### Functions/classes/CLI commands impacted:

- `push_down_claude_customizations.ROOT_FOLDERS`, `push_down_customizations(...)` (new optional keyword `list_entries`, non-breaking), `main()` (resolves the bundle root; help text).
- New: `RoutingMergeError`, `merge_routing_documents`, `BlastRadiusDeriveError`, `BlastRadiusGuardError`, `BLAST_RADIUS_RELATIVE_PATH`, `MergeFunction`, `MERGED_RELATIVE_PATHS`, `DestinationMergeFileSystem`, `BlastRadiusDeriveFileSystem`, `BundleConfigFileSystem`, `DirectoryLister`, `build_destination_write_stack`.

#### Data flow and validation changes:

Composition, outer to inner, matching TypeScript `claude-customizations.ts:274-291`:

```text
ExcludingFileSystem            (enumeration filters: exclusions, packs, memory scope)
  -> BundleConfigFileSystem    (source_root/config/* answered from bundle_root/config/*)
    -> build_destination_write_stack(inner, ...):
         BlastRadiusDeriveFileSystem   (replaces config/blast-radius.json content with derived text)
           -> DestinationMergeFileSystem (merges registered paths into existing destination text)
             -> inner adapter
```

Because derive sits above merge, a merge registered for `config/blast-radius.json` by #508 receives the derived document as its source text with no rewiring.

#### Extension seams (binding contract for downstream children):

- **`MERGED_RELATIVE_PATHS: Mapping[str, MergeFunction]`**, where `MergeFunction = Callable[[str, str, Path], str]` takes `(destination_text, source_text, path)`. Initial value: `{"config/orchestration-routing.json": merge_routing_documents}`. Keys are string literals so the parity test reads them statically. `DestinationMergeFileSystem` looks up the destination-relative POSIX path; when registered and the destination file exists, it writes the merge result; otherwise it writes the source content. #508 extends this mapping to a set of merged paths by adding `"config/blast-radius.json": merge_blast_radius_documents`.
- **`build_destination_write_stack(inner, *, destination_root, lister, merges=MERGED_RELATIVE_PATHS) -> PushDownFileSystem`** is the single assembly point for destination-side write decorators. #621 inserts its destination exclusion filter here, as the outermost layer ahead of derive and merge.
- Downstream children extend these seams. They do not replace, bypass, or duplicate them. Any child that changes either seam extends `test_push_down_claude_parity.py` in the same PR.

#### Routing merge semantics (port of `claude-routing-merge.ts`):

- Target match: destination-relative POSIX path equals `config/orchestration-routing.json` after backslash normalization; case-sensitive.
- Destination absent: the source text is written unchanged (not parsed or re-serialized).
- Destination present: both texts parsed; destination top-level keys emitted in destination order with destination values kept, except `routes`, which is replaced by the route merge; source top-level keys absent from the destination appended in source order (an appended `routes` is merged against an empty destination, and becomes `{}` when the source `routes` is not an object).
- Route merge: destination routes kept in destination order, except `parallel`, which takes the source definition when the source defines it; source routes absent from the destination appended in source order; a non-object destination `routes` is treated as absent.
- Serialization: `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"`, no key sorting. Output is byte-stable on a second push.
- JavaScript-specific quirks (prototype-name membership, integer-key ordering, integral-float rendering) are not reproduced; the shipped document contains none of the affected constructs (research Section 2).

#### Error handling and logging updates:

- `RoutingMergeError(ValueError)` carries `.path` (the destination path) and the message "Destination routing document is not valid JSON and was not written: <path> (<detail>)", identical to TypeScript, for invalid JSON, `NaN`/`Infinity` (rejected via `parse_constant`), or a non-object root in either text.
- Derivation errors raise `BlastRadiusDeriveError` or `BlastRadiusGuardError` (forbidden-glob guard) as in TypeScript.
- Errors propagate uncaught from the engine; the run aborts as it does in TypeScript. The destination file for the failing path is not written.
- The default directory lister tolerates filesystem errors per the TypeScript tolerance rule (`claude-blast-radius-derive.ts:27-35`).
- No new logging is introduced; the summary artifact continues to record merged and derived files as `overwritten` when the destination file existed, matching TypeScript.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Rollback is a revert of the PR; no destination state migration is involved.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Input: repository `.claude/` tree (unchanged) and bundle `extensions/drm-copilot/resources/claude-customizations/config/` (two files).
- Output: destination `.claude/**`, `config/orchestration-routing.json` (merged or copied), `config/blast-radius.json` (derived from a depth-3 scan of the destination).

#### Required configuration keys and defaults:

- No new configuration keys. The bundle root defaults to `<repo_root>/extensions/drm-copilot/resources/claude-customizations`. `BundleConfigFileSystem` is the identity when source and bundle `config/` directories are the same path.

#### Backward-compatibility expectations:

- `push_down_customizations` keeps its existing signature; `list_entries` is keyword-only and optional.
- The Python push-down now additionally writes `config/`. Research Section 4 found no consumer that depends on the Python path publishing `.claude` alone (answers the manual-verification item in `issue.md`).
- Existing Python push-down tests seed no bundle `config/` files, so their file counts are unchanged.

#### Performance constraints (latency/throughput/memory):

The derivation adds one bounded depth-3 directory scan of the destination per push, as TypeScript does. No other performance constraint applies.

## Assumptions, Constraints, Dependencies

- Assumptions: the bundle directory is present in the repository checkout that runs the Python CLI; the bundled `config/orchestration-routing.json` contains no integral floats, exponents, or non-ASCII characters (verified by grep in research Section 2).
- Constraints: 500-line file cap; no temporary files in tests (in-memory `RecordingFileSystem` and an injected `DirectoryLister`); line coverage >= 85% and branch coverage >= 75% for new Python modules; no TypeScript production changes; no edits to `skill_bundle_contract.py`, `push_down_copilot_customizations.py`, `SCOPED_ROOTS`, or #769 files.
- Property-based tests: `hypothesis` is not a declared dependency (absent from `pyproject.toml`), and no `quality-tiers.yml` classification for `scripts/dev_tools/` was found in this worktree. Per research Section 5, no dependency is added; idempotency and order-preservation properties are covered by deterministic table-driven cases. If the planner confirms a T1/T2 classification requiring property tests, adding `hypothesis` requires explicit approval as a new dependency.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: the Python CLI `push_down_claude_customizations` publishes `config/` in addition to `.claude/`; CLI help text updated.
- Data or migration considerations: an existing destination `config/orchestration-routing.json` is merged, preserving destination-local routes and keys. An existing destination `config/blast-radius.json` is replaced by the derived document, matching TypeScript until #508 adds a merge.
- Logging/telemetry updates: none.
- Compatibility notes: no CLI flag changes; no schema changes.

## Test Strategy

Seeded from issue (resolution):

- [ ] Decide which implementation is authoritative, then align the other: TypeScript is authoritative for roots, sourcing, merge, and derivation; Python is aligned to it.
- [ ] Add a parity assertion that fails when the two root-folder sets differ: `test_push_down_claude_parity.py`.
- [ ] Unit coverage areas: root-folder declarations, merge, derivation, decorators, redirect, parity extraction.
- [ ] Integration scenario: an in-memory push through the Python entry point produces the TypeScript destination `config/` file set.
- [ ] Manual verification: resolved by the static consumer search in research Section 4.

- Regression tests to add or update: `test_push_down_claude_customizations.py` (root-folder assertion); new `test_push_down_claude_config_carriage.py` mirroring TypeScript AC6/AC7/AC8/AC16 in `claude-config-carriage.test.ts`.
- Unit tests (pytest): routing merge (every branch in the semantics section, error paths, idempotency); derivation (mirroring `blast-radius-derive-core.test.ts` cases); `DestinationMergeFileSystem`, `BlastRadiusDeriveFileSystem`, `BundleConfigFileSystem`, `build_destination_write_stack` layer order.
- Parity tests: TypeScript text parsed after stripping `/* */` and `//` comments; Python parsed with `ast`. Ordered equality of root folders; set equality of merged paths (`ROUTING_MERGE_RELATIVE_PATH` and any future `MERGED_RELATIVE_PATHS` in TypeScript versus Python `MERGED_RELATIVE_PATHS` keys); set equality of derived paths (`BLAST_RADIUS_RELATIVE_PATH` on both sides). Each extraction asserts at least one declaration was found. Extraction helpers are tested against synthetic source strings to prove a divergence fails.
- Behavioral parity: shared committed fixture `tests/fixtures/push_down/routing-merge-parity.json` (destination/source/expected triples: destination absent, new route, stale `parallel`, destination-local keys, non-object `routes`, invalid JSON) asserted byte-for-byte by pytest and by one new Jest case. Research supports this with existing precedents (`test_plan_gate_parity.py:1-6`, `claude-config-carriage.test.ts:84-134`). A second shared fixture for derivation output is optional and not required by this spec.
- Edge cases and negative scenarios: invalid JSON in destination or source, non-object roots, `NaN`/`Infinity`, non-object `routes`, case-mismatched paths passing through, backslash paths, bundle `config/` absent, empty destination scan, forbidden-glob guard.
- Error handling verification: destination bytes unchanged after `RoutingMergeError`; error `.path` and message text asserted.
- Coverage: line >= 85%, branch >= 75% for each new module; no regression on changed lines of `push_down_claude_customizations.py`. Baselines recorded under `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/`.
- Toolchain: `poetry run black --check`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov=scripts/dev_tools --cov-branch`; for the Jest case, Prettier, ESLint, `tsc`, and Jest in `extensions/drm-copilot`.
- Manual validation: none required.

## Acceptance Criteria

- [x] AC1: `push_down_claude_customizations.ROOT_FOLDERS` equals `(Path(".claude"), Path("config"))`, verified by the updated assertion near line 80 of `tests/scripts/dev_tools/test_push_down_claude_customizations.py` passing.
- [x] AC2: `tests/scripts/dev_tools/test_push_down_claude_parity.py` passes and asserts ordered equality of the TypeScript `ROOT_FOLDERS` (comment-stripped text extraction from `claude-customizations.ts`) and the Python `ROOT_FOLDERS` (`ast` extraction), with a failure message naming both files.
- [x] AC3: `test_push_down_claude_parity.py` asserts set equality of merged paths (TypeScript `ROUTING_MERGE_RELATIVE_PATH` and any `MERGED_RELATIVE_PATHS` declaration versus Python `MERGED_RELATIVE_PATHS` keys) and of derived paths (`BLAST_RADIUS_RELATIVE_PATH` on both sides); each set contains exactly 1 member today.
- [x] AC4: `test_push_down_claude_parity.py` contains tests that feed synthetic divergent TypeScript and Python source text to the extraction and comparison helpers and assert a failure, and tests that assert an extraction finding zero declarations fails rather than passing vacuously.
- [x] AC5: `tests/scripts/dev_tools/test_push_down_claude_config_carriage.py` runs `push_down_customizations` on an in-memory filesystem seeded with a repo-root `config/` containing all five repo-root files and a bundle `config/` containing the two bundle files, and asserts the destination `config/` contains exactly 2 files, `config/blast-radius.json` and `config/orchestration-routing.json`, and none of `orchestration-handoff-registry.json`, `orchestration-handoff.schema.json`, or `poshqc-scan.json`.
- [x] AC6: The same carriage test module asserts the summary lists every `.claude` file before any `config` file, and that the published `config/blast-radius.json` equals the derived document for the injected lister layout, not the repo-root or bundled bytes.
- [x] AC7: `tests/scripts/dev_tools/test_push_down_claude_routing_merge.py` passes and covers: destination absent (source bytes written unchanged); destination keys and values preserved in destination order; `routes.parallel` replaced by the source definition; source-only routes and top-level keys appended in source order; non-object destination `routes` treated as absent; appended non-object source `routes` becoming `{}`.
- [x] AC8: `test_push_down_claude_routing_merge.py` asserts `RoutingMergeError` (a `ValueError` subclass) is raised with `.path` equal to the destination path and the TypeScript message text for invalid JSON, `NaN`/`Infinity`, and non-object roots in either the destination or the source text.
- [x] AC9: A test in `test_push_down_claude_config_carriage.py` or `test_push_down_claude_destination_writes.py` asserts that after a `RoutingMergeError` the destination `config/orchestration-routing.json` bytes are unchanged.
- [x] AC10: A test asserts idempotency: pushing twice into the same in-memory destination produces byte-identical `config/orchestration-routing.json` output after the first and second pushes.
- [x] AC11: `tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive*.py` passes and covers the cases in the TypeScript `blast-radius-derive-core.test.ts` suite, including ancestor pruning, top-level fallback, the `config` payload module, fixed key order, and `BlastRadiusGuardError` on a forbidden glob, using an injected `DirectoryLister` and no filesystem access.
- [x] AC12: `scripts/dev_tools/push_down_claude_destination_writes.py` declares `MERGED_RELATIVE_PATHS` as a module-level mapping literal whose initial content is exactly `{"config/orchestration-routing.json": merge_routing_documents}`, verified by a test in `tests/scripts/dev_tools/test_push_down_claude_destination_writes.py`.
- [x] AC13: `test_push_down_claude_destination_writes.py` asserts that `build_destination_write_stack()` returns `BlastRadiusDeriveFileSystem` wrapping `DestinationMergeFileSystem` wrapping the supplied inner filesystem, that a caller-supplied `merges` mapping replaces the default registry, and that `push_down_customizations` obtains its destination decorators only through `build_destination_write_stack()`.
- [x] AC14: `test_push_down_claude_destination_writes.py` asserts `BundleConfigFileSystem` answers `list_files`, `is_file`, and `read_text` for `<source_root>/config/*` from `<bundle_root>/config/*`, passes other paths through, and is the identity when both roots are the same path.
- [ ] AC15: The spec's Extension seams section (this file) and the module docstring of `push_down_claude_destination_writes.py` both state that #508 extends `MERGED_RELATIVE_PATHS` and #621 inserts its exclusion filter in `build_destination_write_stack()`, and that downstream children extend these seams rather than replacing them; verified by `rg -n "#508|#621" scripts/dev_tools/push_down_claude_destination_writes.py` returning matches.
- [ ] AC16: The shared fixture `tests/fixtures/push_down/routing-merge-parity.json` exists, and both a pytest case in `test_push_down_claude_parity.py` and a new Jest case in `extensions/drm-copilot` assert byte-identical merge output against its expected values; `npx jest <new test file>` and the pytest case pass.
- [x] AC17: All pre-existing Python push-down tests (`tests/scripts/dev_tools/test_push_down_claude_*.py`) pass with no change other than the AC1 assertion, verified by `poetry run pytest tests/scripts/dev_tools -k push_down_claude`.
- [ ] AC18: `git diff --name-only origin/epic/push-down-payload-correctness-integration...HEAD` lists no path under `extensions/drm-copilot/src/` other than test files (`*.test.ts` or test-helper files), and none of `scripts/dev_tools/skill_bundle_contract.py`, `scripts/dev_tools/push_down_copilot_customizations.py`, `scripts/dev_tools/push_down_claude_filesystem.py`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, or its tests.
- [ ] AC19: No new or changed test uses temporary files, verified by `rg -n "tmp_path|tempfile|TemporaryDirectory|mkdtemp" tests/scripts/dev_tools/test_push_down_claude_*.py` returning no matches in files added or changed by this branch.
- [ ] AC20: Every new or changed production and test file is under 500 lines, verified by a line count of each file in `git diff --name-only origin/epic/push-down-payload-correctness-integration...HEAD` (Markdown and JSON fixtures excepted).
- [ ] AC21: Each new Python module reports line coverage >= 85% and branch coverage >= 75%, and changed lines of `push_down_claude_customizations.py` show no coverage regression, verified by `poetry run pytest` with one dotted `--cov=scripts.dev_tools.<module>` argument per new or changed module plus `--cov-branch` and `--cov-report=term-missing`, with results recorded under `evidence/qa-gates/` in the feature folder.
- [ ] AC22: The full toolchain passes in a single pass: `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest`, and, for the new Jest case, Prettier check, ESLint, `tsc --noEmit`, and Jest in `extensions/drm-copilot`, with results recorded under `evidence/qa-gates/` in the feature folder.
- [ ] AC23: `README.md` (near line 251) describes the Claude payload as including `config/`, and the module docstrings and CLI help in `push_down_claude_customizations.py` no longer describe the payload as the `.claude` tree only, verified by `rg -n "config" README.md scripts/dev_tools/push_down_claude_customizations.py`.
- [ ] AC24: The Rollout & Follow-up section of this spec records two follow-up candidates, each with a problem statement and an evidence citation: (a) the Python `.gitignore` managed-block merge and (b) the Python CLI publishing gitignored `.claude` subtrees from a main checkout. Filing them as issues is performed by the epic orchestration session through the MCP promotion path and is not an execution task of this plan.
- [ ] AC25: The PR description references #507 and #764 (part 2) and states that #764 part 1 is out of scope.

## Risks & Mitigations

- Technical or operational risks:
  - Serialization drift between `json.dumps` and `JSON.stringify` on constructs absent from today's document (integral floats, exponents). Mitigation: the shared fixture pins byte output; a later document change that introduces such constructs fails the Jest or pytest case.
  - Derivation port drift from TypeScript. Mitigation: port the TypeScript core test cases one-to-one (AC11); an optional shared derivation fixture can be added later.
  - A downstream child bypassing the seams. Mitigation: AC13 pins the single assembly point; the epic Shared Design requires each child to extend the parity test.
  - Bundle directory absent in an unusual checkout. Mitigation: `BundleConfigFileSystem` lists nothing when the bundle `config/` is absent, so the push publishes `.claude` only rather than repo-root `config/`.
- Mitigations and rollbacks: revert the PR; no data migration.

## Rollout & Follow-up

- Release/rollout steps: merge into the epic integration branch `epic/push-down-payload-correctness-integration`; #508 then extends `MERGED_RELATIVE_PATHS`.
- Post-fix monitoring or clean-up tasks:
  - Follow-up issue: Python `.gitignore` managed-block merge. Issue number: to be assigned when the epic session files it. Evidence: research artifact, Python has no counterpart to the TypeScript `.gitignore` managed-block merge.
  - Follow-up issue: Python CLI publishes gitignored `.claude` subtrees from a main checkout. Issue number: to be assigned when the epic session files it. Evidence: research artifact, `push_down_copilot_customizations_filesystem.py:99-107` lists every file with no ignore filter.
  - #508 should introduce a matching TypeScript `MERGED_RELATIVE_PATHS` map; the parity extraction already accepts it.
  - The Codex Python routing overwrite is recorded only (epic non-goal).
- Links: issue #507, issue #764, epic #770, research `research/research.2026-09-29T14-20.md`, epic `docs/features/epics/push-down-payload-correctness/epic.md`.
