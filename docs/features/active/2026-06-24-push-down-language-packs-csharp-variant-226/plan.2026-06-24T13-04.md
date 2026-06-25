# push-down-language-packs-csharp-variant - Plan

- **Issue:** #226
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/226
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T13-04
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References

- Spec: `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/spec.md`
- Issue (13 acceptance criteria): `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/issue.md`
- User story: `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/user-story.md`
- Research: `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/20260624-push-down-claude-opt-in-packs-research.md`
- Policy reading order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/architecture-boundaries.md`

**All work must comply with these policies; do not duplicate their content here.**

## Acceptance Criteria Coverage Map

The 13 issue acceptance criteria (AC1..AC13, in issue order) are mapped to tasks:

- AC1 (no-arg backward compatibility, byte-for-byte): P2-T6, P3-T7, P7-T2, P7-T6
- AC2 (`core` always included): P2-T2, P2-T6, P3-T2
- AC3 (`--packs core,typescript` excludes other language packs): P2-T6, P3-T3
- AC4 (legacy variant files exist only under `.claude-variants/csharp-legacy/`): P1-T2, P1-T5, P5-T2
- AC5 (exactly one C# toolchain at destination, legacy lands at canonical paths): P2-T4, P2-T6, P3-T5, P5-T3
- AC6 (memory mode `overwrite`): P2-T5, P3-T4
- AC7 (memory mode `merge`, destination-existence check): P2-T5, P3-T4
- AC8 (memory mode `skip`, excludes `.claude/agent-memory/**`): P2-T5, P3-T4
- AC9 (VS Code QuickPick flow maps to CLI args): P6-T2, P6-T3
- AC10 (MCP schema gains optional fields, `workspace_root`-only stays valid): P6-T6, P6-T7, P6-T8
- AC11 (parity test excludes variant subtree): P5-T2
- AC12 (new test: variant never collides + exactly one C# toolchain): P5-T2, P5-T3
- AC13 (Python toolchain green, coverage >= 85% line / >= 75% branch): P7-T2, P7-T3, P7-T4, P7-T5
- AC (TypeScript toolchain green, coverage thresholds): P7-T6, P7-T7, P7-T8, P7-T9

## Evidence Location Invariant

All evidence artifacts MUST be written under
`docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Writing to
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical
path is a policy violation. `<FEATURE>` below denotes
`docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226`.

## Architecture Decisions Encoded in This Plan

- Pack manifests live at `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json`
  (`core`, `python`, `powershell`, `typescript`, `csharp-modern`, `csharp-legacy`). `core` is always
  included. Manifests are NOT pushed to the destination.
- The legacy C# variant lives only at the bundle-only subtree
  `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/`. It must
  never appear at the repository root `.claude` tree and must never be enumerated by the default
  push-down.
- The Python source of truth is `scripts/dev_tools/push_down_claude_customizations.py`. The shared
  engine `scripts/dev_tools/push_down_copilot_customizations.py` is unchanged in signature except as
  needed by the new caller (the existing keyword-only signature already supports the required
  parameters; no engine change is planned unless a path-collision assertion seam is required there).
- Two bundled Python copies are invoked at runtime by the extension and must carry the new logic:
  `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py` and
  `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`. The service spawns
  the `resources/templates/` copy, which bootstraps `resources/scripts/` onto `sys.path` and imports
  the shared engine. Both copies are synced from the source in Phase 4. There is no enforced
  byte-identity parity test for these copies; functional correctness requires the sync, verified by
  re-running the existing bundled-only-import test in `test_push_down_claude_customizations.py`.
- Keep every production, test, or reusable script file <= 500 lines. If
  `push_down_claude_customizations.py` would exceed 500 lines, extract pack-manifest loading,
  pack-filtering, variant resolution, and memory-mode wrapping into a sibling module
  `scripts/dev_tools/push_down_claude_pack_selection.py` (planned extraction in P2-T7).

---

### Phase 0 — Baseline Capture and Policy Reading

- [x] [P0-T1] Read the policy files in the required order and record the read.
  - Files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
    `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`,
    `.claude/rules/typescript-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`,
    `.claude/rules/quality-tiers.md`, `.claude/rules/architecture-boundaries.md`.
  - Evidence: write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` containing
    `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: artifact exists with the three required fields and lists every file above.

- [x] [P0-T2] Capture the Python format baseline.
  - Command: `poetry run black --check .`
  - Evidence: `<FEATURE>/evidence/baseline/python-black.<ISO-8601>.md` with `Timestamp:`, `Command:`,
    `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact records exit code and a one-line pass/fail summary.

- [x] [P0-T3] Capture the Python lint baseline.
  - Command: `poetry run ruff check .`
  - Evidence: `<FEATURE>/evidence/baseline/python-ruff.<ISO-8601>.md` with the four required fields.
  - Acceptance: artifact records exit code and the violation count.

- [x] [P0-T4] Capture the Python type-check baseline.
  - Command: `poetry run pyright`
  - Evidence: `<FEATURE>/evidence/baseline/python-pyright.<ISO-8601>.md` with the four required fields.
  - Acceptance: artifact records exit code and the error/warning counts.

- [x] [P0-T5] Capture the Python test + coverage baseline.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing tests/scripts/dev_tools`
  - Evidence: `<FEATURE>/evidence/baseline/python-pytest.<ISO-8601>.md` with `Timestamp:`, `Command:`,
    `EXIT_CODE:`, and `Output Summary:` that MUST record numeric baseline line coverage and branch
    coverage headline values plus the passed/failed test counts.
  - Acceptance: artifact records numeric line and branch coverage percentages (not placeholders).

- [x] [P0-T6] Capture the TypeScript format baseline.
  - Command (run from `extensions/drm-copilot/`): `npm run format`
  - Evidence: `<FEATURE>/evidence/baseline/ts-format.<ISO-8601>.md` with the four required fields.
  - Acceptance: artifact records exit code and whether any files changed.

- [x] [P0-T7] Capture the TypeScript lint baseline.
  - Command (from `extensions/drm-copilot/`): `npm run lint`
  - Evidence: `<FEATURE>/evidence/baseline/ts-lint.<ISO-8601>.md` with the four required fields.
  - Acceptance: artifact records exit code and the error count.

- [x] [P0-T8] Capture the TypeScript type-check baseline.
  - Command (from `extensions/drm-copilot/`): `npm run typecheck`
  - Evidence: `<FEATURE>/evidence/baseline/ts-typecheck.<ISO-8601>.md` with the four required fields.
  - Acceptance: artifact records exit code and the error count.

- [x] [P0-T9] Capture the TypeScript test + coverage baseline.
  - Command (from `extensions/drm-copilot/`): `npm run test -- --coverage`
  - Evidence: `<FEATURE>/evidence/baseline/ts-test.<ISO-8601>.md` with `Timestamp:`, `Command:`,
    `EXIT_CODE:`, and `Output Summary:` recording numeric line and branch coverage headline values
    plus passed/failed counts.
  - Acceptance: artifact records numeric line and branch coverage percentages (not placeholders).

---

### Phase 1 — Bundle Assets: Pack Manifests and Variant Subtree

- [x] [P1-T1] Create the six pack-manifest JSON files.
  - Files (new):
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`,
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json`,
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json`,
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/typescript.json`,
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/csharp-modern.json`,
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/csharp-legacy.json`.
  - Change: each manifest is a JSON object with keys `name` (string), `label` (string), and `paths`
    (array of `.claude`-relative POSIX path strings). `core.json` lists all non-language files
    (`settings.json`, `agents/orchestrator.md`, all hooks, non-language rules, non-language skills,
    non-language agent-memory). Each language manifest lists only that language's `.claude`-relative
    files. `csharp-modern.json` lists the four canonical C# destination paths
    (`.claude/rules/csharp.md`, `.claude/agents/csharp-typed-engineer.md`,
    `.claude/skills/csharp-qa-gate/SKILL.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`) plus
    any modern-only C# skills present at root (`.claude/skills/csharp-change-budget-router/SKILL.md`,
    `.claude/skills/csharp-orchestration-state-machine/SKILL.md`). `csharp-legacy.json` lists the same
    four canonical destination paths and additionally records a `source_prefix` field set to
    `.claude-variants/csharp-legacy` so the engine resolves the legacy source while writing to the
    canonical destination paths.
  - Acceptance: all six files are valid JSON; the union of every language manifest's `paths` plus
    `core.json` `paths` equals the full set of root `.claude` runtime files (excluding
    `settings.local.json` and the agent-memory subtree, which `core` handles via its memory entries);
    no path appears in more than one manifest except the C# canonical paths, which appear in both
    `csharp-modern.json` and `csharp-legacy.json` by design (mutual exclusion enforced at selection
    time).
  - Satisfies: AC2 (groundwork), AC4 (groundwork).

- [x] [P1-T2] Create the legacy C# variant subtree by copying the four canonical source files verbatim.
  - Files (new), copied byte-for-byte from the canonical sources:
    `artifacts/csharp.md` ->
    `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`;
    `artifacts/csharp-typed-engineer.md` ->
    `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md`;
    `artifacts/csharp-qa-gate/SKILL.md` ->
    `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`;
    `artifacts/invoke-csharp-engineer/SKILL.md` ->
    `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`.
  - Change: copy each source file content verbatim into the destination-relative path under the
    variant subtree (variant prefix `.claude-variants/csharp-legacy/` + the canonical `.claude`-relative
    tail without the leading `.claude/`).
  - Acceptance: the four files exist under `.claude-variants/csharp-legacy/` with content byte-identical
    to their `artifacts/` sources; no file is created at the repository root `.claude` tree.
  - Satisfies: AC4.

- [x] [P1-T3] Verify the variant subtree does not duplicate root content.
  - Change: for each of the four variant files, confirm its content differs from the corresponding root
    `.claude` file at the same destination-relative path (the variant must be a distinct profile, not a
    stray copy of the modern file).
  - Acceptance: each variant file's content is not byte-identical to its root `.claude` counterpart.
    If any pair is byte-identical, record the discrepancy as a blocker and stop (the supplied legacy
    source is then not actually a distinct profile). This is verified by the test in P5-T2.
  - Satisfies: AC4 (groundwork for the conflict-prevention test).

- [x] [P1-T4] Verify no `.claude-variants/` directory exists at the repository root.
  - Change: confirm the repository root contains no `.claude-variants/` directory and that the variant
    subtree exists only under `extensions/drm-copilot/resources/claude-customizations/`.
  - Acceptance: `Glob` for `.claude-variants/**` at repo root returns nothing; the subtree exists only
    in the bundle. This is enforced by the test in P5-T2.
  - Satisfies: AC4.

- [x] [P1-T5] Confirm the variant subtree is excluded from default enumeration scope.
  - Change: confirm `SCOPED_ROOTS`/`ROOT_FOLDERS` remains `(Path(".claude"),)` and that the variant
    subtree path `.claude-variants/` is not a child of `.claude/`, so the default push-down never
    enumerates it.
  - Acceptance: `.claude-variants/` is a sibling of `.claude/` in the bundle, not nested under it;
    `ROOT_FOLDERS` is unchanged. This invariant is asserted by the engine tests in Phase 3 and the
    parity test in P5-T2.
  - Satisfies: AC4.

---

### Phase 2 — Python Engine: Pack Selection, Variant Routing, Memory Modes

- [x] [P2-T1] Add a pack-manifest loader.
  - File: `scripts/dev_tools/push_down_claude_customizations.py` (or the extracted module per P2-T7).
  - Change: add a function that, given the bundle manifest directory and a set of selected pack names,
    reads each selected manifest JSON via the injected `PushDownFileSystem` adapter (no direct disk
    I/O), validates required keys (`name`, `label`, `paths`; optional `source_prefix`), and returns a
    typed structure mapping pack name to its `.claude`-relative paths and optional source prefix. Fail
    fast with a specific exception when a manifest is missing or malformed. Add full Google-style
    docstrings per `.claude/rules/self-explanatory-code-commenting.md`.
  - Toolchain (run after this task, in order, restart on any change/failure):
    `poetry run black .`; `poetry run ruff check .`; `poetry run pyright`;
    `poetry run pytest --cov --cov-branch --cov-report=term-missing tests/scripts/dev_tools`.
  - Acceptance: loader returns the expected structure for a valid manifest and raises a specific
    exception for a missing/malformed manifest; new unit tests in P2-T6 cover both paths.

- [x] [P2-T2] Add the pack-filtering predicate with `core` always included.
  - File: `scripts/dev_tools/push_down_claude_customizations.py` (or the extracted module per P2-T7).
  - Change: add a pure function that, given the selected pack names and the loaded manifests, returns
    the set of `.claude`-relative destination paths to push, always unioning `core` into the selected
    set even when `core` is not listed. When the selected-pack set is empty/None, return None to signal
    "push everything" (backward-compatible default).
  - Toolchain: same four-stage Python loop as P2-T1; restart on any change/failure.
  - Acceptance: with `{typescript}` selected, the result includes `core` paths and TypeScript paths and
    excludes Python/PowerShell/C# language paths; with empty selection, the function signals the
    push-everything default; unit tests in P2-T6 cover both.
  - Satisfies: AC2, AC3.

- [x] [P2-T3] Add the variant source-path resolver.
  - File: `scripts/dev_tools/push_down_claude_customizations.py` (or the extracted module per P2-T7).
  - Change: add a pure function that, given the selected C# variant (`modern` default | `legacy`) and a
    `.claude`-relative destination path, returns the source-relative path to read from. For `modern` it
    returns the destination path unchanged (read from `.claude/`); for `legacy` it returns the path
    under `.claude-variants/csharp-legacy/` (destination tail mapped onto the variant prefix). Non-C#
    paths always resolve to themselves.
  - Toolchain: same four-stage Python loop; restart on any change/failure.
  - Acceptance: legacy variant maps `.claude/rules/csharp.md` to
    `.claude-variants/csharp-legacy/rules/csharp.md`; modern maps it to itself; non-C# paths are
    unchanged; unit tests in P2-T6 cover all three.
  - Satisfies: AC5 (source routing).

- [x] [P2-T4] Add the C# mutual-exclusion path-collision assertion.
  - File: `scripts/dev_tools/push_down_claude_customizations.py` (or the extracted module per P2-T7).
  - Change: add a function that asserts the resolved set of destination paths contains the four C#
    canonical paths at most once each (exactly one C# toolchain), and that the modern and legacy C#
    files are never both written to the same destination path in a single run. Raise a specific
    exception if both variants' sources are selected for the same destination.
  - Toolchain: same four-stage Python loop; restart on any change/failure.
  - Acceptance: a run with both modern and legacy C# selected raises the specific exception; a run with
    exactly one variant passes; unit tests in P2-T6 cover both.
  - Satisfies: AC5.

- [x] [P2-T5] Extend the filesystem wrapper for the three memory modes.
  - File: `scripts/dev_tools/push_down_claude_customizations.py`.
  - Change: extend `_ExcludingFileSystem` (or add a focused `_MemoryModeFileSystem` wrapper composed
    with it) to accept a `memory_mode` and the `destination_root`. `overwrite` keeps current behavior.
    `skip` adds the entire `.claude/agent-memory/**` subtree to the exclusion set. `merge` performs a
    filesystem-level destination-existence check via `fs.is_file(destination_root / relative_path)` and
    excludes any general-scoped memory whose destination file already exists. The existing
    general-vs-repo scope filter still applies in all three modes. No runtime temp files; use the
    injected adapter only.
  - Toolchain: same four-stage Python loop; restart on any change/failure.
  - Acceptance: `skip` excludes all agent-memory files; `merge` excludes only pre-existing destination
    memories and keeps new ones; `overwrite` writes all general-scoped memories; unit tests in P2-T6
    cover all three modes including a memory present and absent at destination.
  - Satisfies: AC6, AC7, AC8.

- [x] [P2-T6] Wire pack selection, variant routing, memory mode, and CLI parsing into the entry point.
  - File: `scripts/dev_tools/push_down_claude_customizations.py`.
  - Change: add `--packs` (comma-separated; omitted = all), `--csharp-variant` (`modern` default |
    `legacy`), `--memory-mode` (`overwrite` default | `merge` | `skip`) to `parse_args`. Thread the
    parsed values from `main` into `push_down_customizations`, which now: loads manifests when `--packs`
    is supplied, computes the push set (with `core` always included), resolves C# source paths per the
    selected variant, applies the collision assertion, wraps the filesystem for the memory mode, and
    delegates to the shared engine. When all three arguments are absent, behavior is exactly the
    current push-everything/overwrite path (no manifest read, no variant routing). Update `__all__` as
    needed.
  - Add tests (new) in `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`:
    manifest loader valid/malformed; pack filter with `core` always included; pack filter
    `{typescript}` excludes other languages; variant resolver modern/legacy/non-C#; collision assertion
    pass/fail; memory mode overwrite/merge/skip with destination present and absent; `parse_args`
    defaults and explicit values; end-to-end `push_down_customizations` with `--packs core,typescript`
    writing only core + TypeScript files; end-to-end legacy variant writing legacy content to the four
    canonical destination paths; backward-compatible no-argument run writing the full tree and
    overwriting memories. Use the existing in-memory `RecordingFileSystem` double; no temp files.
  - Toolchain: same four-stage Python loop; restart on any change/failure. New code coverage must meet
    >= 85% line and >= 75% branch.
  - Acceptance: all new tests pass; `parse_args` defaults are `packs=None`, `csharp_variant="modern"`,
    `memory_mode="overwrite"`; the no-argument run is byte-for-byte equivalent to current behavior.
  - Satisfies: AC1, AC2, AC3, AC5, AC6, AC7, AC8.

- [x] [P2-T7] Extract pack-selection logic to a sibling module if the entry point exceeds 500 lines.
  - File (conditional new): `scripts/dev_tools/push_down_claude_pack_selection.py`.
  - Change: only if `scripts/dev_tools/push_down_claude_customizations.py` exceeds 500 lines after
    P2-T1..P2-T6, move the manifest loader, pack-filtering predicate, variant resolver, and collision
    assertion into `push_down_claude_pack_selection.py` with full docstrings, and import them back into
    the entry point. Keep both files <= 500 lines.
  - Toolchain: same four-stage Python loop; restart on any change/failure.
  - Acceptance: both files are <= 500 lines; all Phase 2 tests still pass; if no extraction is needed
    because the entry point stays <= 500 lines, mark this task complete with a note that extraction was
    unnecessary and the line count is recorded.

---

### Phase 3 — Python Engine Tests: Behavior Verification

- [x] [P3-T1] Verify manifest loader unit coverage.
  - File: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Change: confirm tests assert valid-manifest parsing and a specific exception for missing/malformed
    manifests (read via the in-memory adapter).
  - Toolchain: `poetry run pytest --cov --cov-branch tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Acceptance: both paths covered; tests pass.

- [x] [P3-T2] Verify `core`-always-included filtering.
  - File: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Change: assert that selecting `{python}` (without `core`) yields a push set that includes all
    `core.json` paths.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Acceptance: test passes; `core` paths present.
  - Satisfies: AC2.

- [x] [P3-T3] Verify `--packs core,typescript` excludes other language packs.
  - File: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Change: end-to-end `push_down_customizations` run with `--packs core,typescript` asserts the
    destination receives core + TypeScript files and receives no Python, PowerShell, or C# pack files.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Acceptance: destination file set equals core + TypeScript; language-specific files absent.
  - Satisfies: AC3.

- [x] [P3-T4] Verify the three memory modes.
  - File: `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` (extend) or
    `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Change: assert `overwrite` writes all general-scoped memories; `merge` writes only memories absent
    at destination and preserves pre-existing destination files; `skip` writes no agent-memory file.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_memory_scope.py
    tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Acceptance: all three mode assertions pass with destination memory present and absent.
  - Satisfies: AC6, AC7, AC8.

- [x] [P3-T5] Verify legacy-variant routing to canonical destination paths.
  - File: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Change: populate the in-memory filesystem with both `.claude/rules/csharp.md` (modern) and
    `.claude-variants/csharp-legacy/rules/csharp.md` (legacy) plus the other three pairs; run with
    `--packs core,csharp --csharp-variant legacy`; assert the destination `.claude/rules/csharp.md`
    contains the legacy content and that the modern content is not written to any destination path.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Acceptance: destination canonical C# paths hold legacy content; modern content absent at
    destination.
  - Satisfies: AC5.

- [x] [P3-T6] Verify the existing engine constant test still holds.
  - File: `tests/scripts/dev_tools/test_push_down_claude_customizations.py`.
  - Change: confirm `test_module_exposes_claude_root_folders_and_artifact_directory` still passes
    (`ROOT_FOLDERS == (Path(".claude"),)` unchanged), and that the bundled-only-import test
    (`_bundled_only_sys_path`) still passes after the source changes (this protects the bundled-copy
    contract before Phase 4 syncs the bundled copies).
  - Toolchain: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py`.
  - Acceptance: existing tests pass; `ROOT_FOLDERS` unchanged.
  - Satisfies: AC4 (default enumeration unchanged).

- [x] [P3-T7] Verify backward-compatible no-argument run.
  - File: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
  - Change: run `main(["--destination", "/dest"], repo_root=..., fs=RecordingFileSystem(...))` with no
    pack/variant/memory arguments and assert the written destination tree and memory-overwrite behavior
    match the pre-change behavior captured by the existing copy test.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools`.
  - Acceptance: no-argument run output is identical to current behavior; all dev_tools tests pass.
  - Satisfies: AC1.

---

### Phase 4 — Sync Bundled Python Copies

- [x] [P4-T1] Sync the bundled engine copy.
  - File: `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`.
  - Change: update this bundled copy so it carries the same pack-selection, variant-routing,
    memory-mode, and CLI logic as the source `scripts/dev_tools/push_down_claude_customizations.py`. If
    P2-T7 created `push_down_claude_pack_selection.py`, also create the bundled copy
    `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_pack_selection.py`.
  - Toolchain: `poetry run black .`; `poetry run ruff check .`; `poetry run pyright`;
    `poetry run pytest tests/scripts/dev_tools`.
  - Acceptance: bundled engine copy content matches the source logic; the bundled-only-import test in
    `test_push_down_claude_customizations.py` passes against the bundled copy.

- [x] [P4-T2] Sync the bundled template entry point.
  - File: `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`.
  - Change: update this bundled entry point so its `parse_args`/`main`/`push_down_customizations`
    surface accepts and threads `--packs`, `--csharp-variant`, `--memory-mode` identically to the
    source, preserving its existing `_ensure_bundled_scripts_import_path()` bootstrap and import
    fallbacks. The manifest directory must resolve relative to the bundle
    (`resources/claude-customizations/pack-manifests/`) and the variant subtree relative to
    `resources/claude-customizations/.claude-variants/csharp-legacy/`.
  - Toolchain: `poetry run black .`; `poetry run ruff check .`; `poetry run pyright`;
    `poetry run pytest tests/scripts/dev_tools`.
  - Acceptance: the bundled template parses the new arguments and resolves manifest/variant paths from
    the bundle; no-argument invocation remains backward-compatible.

- [x] [P4-T3] Add a parity check task for the bundled Python copies.
  - File: `tests/scripts/dev_tools/test_push_down_claude_customizations.py` (extend) or a new
    `tests/scripts/dev_tools/test_push_down_claude_bundled_parity.py`.
  - Change: add a behavioral parity test that loads the bundled engine copy via the bundled-only
    sys.path and asserts it exposes the same new public surface (`parse_args` accepts `--packs`,
    `--csharp-variant`, `--memory-mode`; `push_down_customizations` honors them) using the in-memory
    filesystem double. No temp files.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools`.
  - Acceptance: the bundled copy behaves identically to the source for a representative pack-filtered
    and legacy-variant run.

---

### Phase 5 — Parity and Conflict-Prevention Tests

- [x] [P5-T1] Confirm the manifests are excluded from the root-to-bundle parity assertion.
  - File: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  - Change: confirm that the existing `list_scoped_files` enumerates only `.claude/**` (`SCOPED_ROOTS ==
    (Path(".claude"),)`), so the new `pack-manifests/` and `.claude-variants/` directories are already
    outside the parity scope; add an explicit assertion that no `pack-manifests/` path appears in the
    bundled `.claude/**` set.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  - Acceptance: parity scope still equals `.claude/**`; manifests are not enumerated.

- [x] [P5-T2] Adapt the parity test to exclude the variant subtree and add the no-collision assertion.
  - File: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  - Change: (a) ensure `test_bundled_claude_payload_contains_all_repo_runtime_contracts` continues to
    compare only `.claude/**` and explicitly excludes any `.claude-variants/**` path from the
    root-to-bundle byte-identical assertion. (b) Add a new test
    `test_variant_subtree_is_bundle_only_and_non_colliding` asserting: no `.claude-variants/` directory
    exists at the repository root; every variant file's destination-relative path (variant prefix
    stripped, `.claude/` prepended) corresponds to an existing modern file at the root `.claude` tree
    (so the variant is a true alternative, not a stray); and each variant file's content differs from
    its root `.claude` counterpart at the same destination-relative path.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  - Acceptance: the parity test passes with the variant subtree present in the bundle; the new
    no-collision test passes.
  - Satisfies: AC4, AC11, AC12.

- [x] [P5-T3] Add the single-C#-toolchain destination assertion test.
  - File: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` (extend) or the resource
    contracts file.
  - Change: add a test asserting that a push-down with `--packs core,csharp --csharp-variant legacy`
    yields exactly one C# toolchain at the destination: each of the four canonical C# destination paths
    is written exactly once, holds legacy content, and no modern C# content is written to any
    destination path.
  - Toolchain: `poetry run pytest tests/scripts/dev_tools`.
  - Acceptance: test passes; exactly one C# toolchain present at destination.
  - Satisfies: AC5, AC12.

---

### Phase 6 — TypeScript: Service, Command UI, MCP

- [x] [P6-T1] Extend the service input type.
  - File: `extensions/drm-copilot/src/repo-automation-service.ts`.
  - Change: define `PushDownClaudeCustomizationsInput extends WorkspaceExecutionInput` adding optional
    `packs?: ReadonlyArray<string>`, `csharpVariant?: "modern" | "legacy"`, and
    `memoryMode?: "overwrite" | "merge" | "skip"`. Update the service interface method
    `pushDownClaudeCustomizations` to accept this type instead of the bare `WorkspaceExecutionInput`.
  - Toolchain (from `extensions/drm-copilot/`): `npm run format`; `npm run lint`; `npm run typecheck`;
    `npm run test`. Restart on any change/failure.
  - Acceptance: type compiles; existing callers still type-check because all new fields are optional.

- [x] [P6-T2] Build CLI args from the new fields in the service implementation.
  - File: `extensions/drm-copilot/src/repo-automation-service.ts`.
  - Change: in `DefaultRepoAutomationService.pushDownClaudeCustomizations`, construct `args` starting
    with `["--destination", input.workspaceRoot]` and append `--packs <csv>` when `input.packs` is a
    non-empty array, `--csharp-variant <value>` when `input.csharpVariant` is set, and
    `--memory-mode <value>` when `input.memoryMode` is set. When all three are absent, `args` is
    exactly `["--destination", input.workspaceRoot]` (backward-compatible).
  - Toolchain: same four-stage TypeScript loop; restart on any change/failure.
  - Acceptance: a service call with packs/variant/memory produces the expected arg vector; a
    no-argument call produces the current arg vector; unit test in P6-T4 covers both.
  - Satisfies: AC9 (arg mapping).

- [x] [P6-T3] Extend the command registration with the three QuickPick prompts.
  - File: `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`.
  - Change: in `registerPushDownClaudeCustomizationsCommand`, before calling the service: (1) show a
    multi-select QuickPick (`canPickMany: true`, all packs pre-picked) for language packs sourced from
    the bundled `pack-manifests/` labels; abort on cancellation. (2) When the C# pack is selected, use
    the existing `promptForChoice` helper to single-select the C# variant (`modern` | `legacy`); abort
    on cancellation. (3) Use `promptForChoice` to single-select memory mode (`overwrite` | `merge` |
    `skip`); abort on cancellation. Map the selections to `packs`, `csharpVariant`, and `memoryMode`
    and pass them to `service.pushDownClaudeCustomizations`. Cancellation at any step returns without
    invoking the service.
  - Toolchain: same four-stage TypeScript loop; restart on any change/failure.
  - Acceptance: the handler gathers the three selections and maps them to the service input; abort on
    cancellation at any step; unit tests in P6-T5 cover the mapping, the conditional C# step, and
    cancellation.
  - Satisfies: AC9.

- [x] [P6-T4] Add service-layer tests for arg construction.
  - File: `extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts`.
  - Change: add tests asserting the spawned args include `--packs`, `--csharp-variant`, `--memory-mode`
    when the input carries them, and that a no-field input spawns exactly
    `["--destination", workspaceRoot]`. Use the existing spawn mock pattern.
  - Toolchain: same four-stage TypeScript loop; restart on any change/failure.
  - Acceptance: both tests pass.
  - Satisfies: AC9 (arg mapping verified).

- [x] [P6-T5] Add command-registration tests for the QuickPick flow.
  - File: `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts`.
  - Change: mock `vscode.window.showQuickPick` and `promptForChoice` to assert: a multi-select returns
    packs that map to `input.packs`; the C# variant prompt is shown only when C# is selected and maps
    to `input.csharpVariant`; the memory-mode prompt maps to `input.memoryMode`; cancellation at each
    of the three steps returns without invoking the service.
  - Toolchain: same four-stage TypeScript loop; restart on any change/failure.
  - Acceptance: all flow and cancellation tests pass.
  - Satisfies: AC9.

- [x] [P6-T6] Update the MCP input resolver.
  - File: `extensions/drm-copilot/src/mcp-tool-inputs.ts`.
  - Change: extend `resolvePushDownClaudeCustomizationsToolInput` to read optional `packs` (string
    array), `csharp_variant` (enum `modern`/`legacy`), and `memory_mode` (enum
    `overwrite`/`merge`/`skip`) from the raw input, mapping them to `packs`, `csharpVariant`, and
    `memoryMode`. Leave each undefined when absent so a `workspace_root`-only invocation produces the
    backward-compatible input. Validate enum values and reject out-of-range values with a clear error.
  - Toolchain: same four-stage TypeScript loop; restart on any change/failure.
  - Acceptance: resolver maps present fields and leaves absent fields undefined; invalid enum values
    are rejected; unit test in P6-T8 covers both.
  - Satisfies: AC10.

- [x] [P6-T7] Update both MCP tool definitions consistently.
  - Files: `extensions/drm-copilot/src/mcp-tool-definitions.ts` and
    `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`.
  - Change: in the `push_down_claude_customizations` tool's `inputSchema.properties`, add optional
    `packs` (array of strings), `csharp_variant` (string enum `modern`/`legacy`), and `memory_mode`
    (string enum `overwrite`/`merge`/`skip`). Do not add any field to a `required` array. Preserve
    `additionalProperties: false`. Apply identical edits to both files to avoid drift.
  - Toolchain: same four-stage TypeScript loop; restart on any change/failure.
  - Acceptance: both files carry identical updated schemas; `additionalProperties: false` retained; no
    `required` array introduced.
  - Satisfies: AC10.

- [x] [P6-T8] Add MCP handler/dispatch and schema tests.
  - Files: `extensions/drm-copilot/test/push-down-claude-handler.test.ts`,
    `extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts`.
  - Change: add tests asserting the handler resolves the new optional fields and forwards them to the
    service; a `workspace_root`-only raw input resolves to an input with the new fields undefined and
    still dispatches to `service.pushDownClaudeCustomizations`; an input with `packs`/`csharp_variant`/
    `memory_mode` resolves and forwards correctly.
  - Toolchain: same four-stage TypeScript loop; restart on any change/failure.
  - Acceptance: all handler and dispatch tests pass; backward-compatible `workspace_root`-only path
    verified.
  - Satisfies: AC10.

---

### Phase 7 — Final Verification (Full Toolchain + Coverage)

- [x] [P7-T1] Re-read policy files if any change since Phase 0 affects them.
  - Acceptance: confirm no policy file under `.claude/rules/` was modified during implementation
    (policy files must not be edited); record confirmation in
    `<FEATURE>/evidence/qa-gates/policy-no-edit.<ISO-8601>.md`.

- [x] [P7-T2] Run the Python format gate.
  - Command: `poetry run black --check .`
  - Evidence: `<FEATURE>/evidence/qa-gates/python-black.<ISO-8601>.md` with `Timestamp:`, `Command:`,
    `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: exit code 0; if it reformats, restart the Python loop from P7-T2.
  - Satisfies: AC1 (no behavior change), AC13.

- [x] [P7-T3] Run the Python lint gate.
  - Command: `poetry run ruff check .`
  - Evidence: `<FEATURE>/evidence/qa-gates/python-ruff.<ISO-8601>.md` with the four required fields.
  - Acceptance: exit code 0, zero violations; on failure fix and restart from P7-T2.
  - Satisfies: AC13.

- [x] [P7-T4] Run the Python type-check gate.
  - Command: `poetry run pyright`
  - Evidence: `<FEATURE>/evidence/qa-gates/python-pyright.<ISO-8601>.md` with the four required fields.
  - Acceptance: exit code 0, zero errors; on failure fix and restart from P7-T2.
  - Satisfies: AC13.

- [x] [P7-T5] Run the Python test + coverage gate and verify thresholds.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing tests/scripts/dev_tools`
  - Evidence: `<FEATURE>/evidence/qa-gates/python-pytest.<ISO-8601>.md` with `Timestamp:`, `Command:`,
    `EXIT_CODE:`, and `Output Summary:` recording numeric post-change line and branch coverage plus the
    new/changed-code coverage; include a delta line comparing the P0-T5 baseline coverage to the
    post-change coverage.
  - Acceptance: all tests pass; line coverage >= 85%, branch coverage >= 75%; no regression on changed
    lines. If any value is below threshold, outcome is remediation-required, not PASS.
  - Satisfies: AC13.

- [x] [P7-T6] Run the TypeScript format gate.
  - Command (from `extensions/drm-copilot/`): `npm run format`
  - Evidence: `<FEATURE>/evidence/qa-gates/ts-format.<ISO-8601>.md` with the four required fields.
  - Acceptance: exit code 0; if it reformats, restart the TypeScript loop from P7-T6.
  - Satisfies: AC1 (no behavior change for no-arg path).

- [x] [P7-T7] Run the TypeScript lint gate.
  - Command (from `extensions/drm-copilot/`): `npm run lint`
  - Evidence: `<FEATURE>/evidence/qa-gates/ts-lint.<ISO-8601>.md` with the four required fields.
  - Acceptance: exit code 0, zero errors; on failure fix and restart from P7-T6.

- [x] [P7-T8] Run the TypeScript type-check gate.
  - Command (from `extensions/drm-copilot/`): `npm run typecheck`
  - Evidence: `<FEATURE>/evidence/qa-gates/ts-typecheck.<ISO-8601>.md` with the four required fields.
  - Acceptance: exit code 0, zero errors; on failure fix and restart from P7-T6.

- [x] [P7-T9] Run the TypeScript test + coverage gate and verify thresholds.
  - Command (from `extensions/drm-copilot/`): `npm run test -- --coverage`
  - Evidence: `<FEATURE>/evidence/qa-gates/ts-test.<ISO-8601>.md` with `Timestamp:`, `Command:`,
    `EXIT_CODE:`, and `Output Summary:` recording numeric post-change line and branch coverage and a
    delta line comparing the P0-T9 baseline.
  - Acceptance: all tests pass; line coverage >= 85%, branch coverage >= 75%; no regression on changed
    lines. If any value is below threshold, outcome is remediation-required, not PASS.
  - Satisfies: TypeScript toolchain green AC.

- [x] [P7-T10] Record the final acceptance-criteria mapping evidence.
  - Evidence: `<FEATURE>/evidence/qa-gates/ac-coverage.<ISO-8601>.md` listing AC1..AC13 plus the
    TypeScript-toolchain AC, each with the task IDs and the test(s) that verify it.
  - Acceptance: every one of the 13 issue acceptance criteria plus both toolchain ACs is mapped to at
    least one passing test or recorded gate evidence; no AC is unmapped.

---

## Notes on File-Size and Extraction Risk

- `scripts/dev_tools/push_down_claude_customizations.py` is currently 375 lines. The Phase 2 additions
  (manifest loader, pack filter, variant resolver, collision assertion, memory-mode wrapper extension,
  expanded `parse_args`/`main`) are likely to push it near or past the 500-line limit. P2-T7 plans the
  extraction to `scripts/dev_tools/push_down_claude_pack_selection.py` and the matching bundled copy in
  P4-T1 if that occurs.
- The bundled copies at `extensions/drm-copilot/resources/scripts/dev_tools/` and
  `resources/templates/` must be kept consistent with the source (Phase 4). There is no enforced
  byte-identity parity test for the `push_down_claude_customizations.py` copies; functional parity is
  verified behaviorally by the bundled-only-import tests (P4-T1, P4-T3).
- Out of scope: `.claude/schemas/orchestrator-state.schema.json` from the diverged snapshot is excluded;
  no schema-file-based orchestrator-state validation is introduced.
