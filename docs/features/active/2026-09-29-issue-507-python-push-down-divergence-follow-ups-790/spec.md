# 2026-09-29-issue-507-python-push-down-divergence-follow-ups (Spec)

- **Issue:** #790
- **Parent (optional):** epic #770 (`push-down-payload-correctness`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T18-30
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md` is produced)
- **Research:** `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research/2026-10-08T18-00-python-push-down-divergence-research.md`

## Context

- Summary: the Python Claude push-down (`scripts/dev_tools/push_down_claude_customizations.py`) and the TypeScript push-down in the extension leave a destination in different states in two ways that #507 recorded but did not fix.
  - **F-507-1:** the TypeScript push-down merges a managed block into the destination `.gitignore` after the copy (`deliverDestinationGitignore` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, pure merge in `claude-gitignore-merge.ts`). The Python push-down has no `.gitignore` handling.
  - **F-507-2:** when the Python CLI runs from a main checkout, it publishes the gitignored runtime subtrees `.claude/worktrees/**` and `.claude/state/**`. `RealPushDownFileSystem.list_files` is an unfiltered `root.rglob("*")`, and the Claude `ExcludingFileSystem.list_files` filters only exact paths. The TypeScript push-down reads the curated bundle, which contains neither subtree, so its adapter gap is latent.
- Observed environment: Windows 11 Pro, repository Poetry environment, Python CLI run from a main checkout.
- Impact and severity: Medium. F-507-2 can write a large number of files, because `.claude/worktrees/**` can contain complete repository checkouts. F-507-1 leaves Python-published destinations without the managed ignores for `.claude/state/` and `.codex/state/`.
- First observed: preparation of #507 (`docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md`, Rollout & Follow-up). The defects are present on `origin/main` as read for the research (research §2).

## Repro & Evidence

- Steps to reproduce:
  1. F-507-1: run the Python push-down and the TypeScript push-down against equivalent destinations and compare `<dest>/.gitignore`. Python leaves it absent or unchanged; TypeScript writes the managed block.
  2. F-507-2: run the Python push-down from a checkout that contains `.claude/worktrees/` and `.claude/state/`. Both subtrees appear in the destination and in `summary.files`.
- Expected: both implementations leave the same managed `.gitignore` block and publish the same file set for the same source revision. Lines outside the managed block are preserved in content and order.
- Actual: see Context.
- Evidence: research §1 (TypeScript reference behavior with line citations), §2 (absence of Python handling), §4.1 (Python enumeration chain to `rglob`).
- Frequency: deterministic. F-507-2 occurs whenever the source checkout contains either subtree.

## Scope & Non-Goals

- In scope:
  - F-507-1: a Python port of the TypeScript managed `.gitignore` merge and its delivery step, invoked after the copy, with a shared parity fixture consumed by a Python test and a TypeScript test.
  - F-507-2: an explicit source-relative directory-prefix exclusion for `.claude/state` and `.claude/worktrees` in the Python Claude `ExcludingFileSystem.list_files` and in the TypeScript `ExcludingFileSystem.listFiles` (`claude-filesystem-adapter.ts`), with a static parity test that pins both lists.
  - The extraction of `_resolve_published_paths` from `push_down_claude_customizations.py` into `push_down_claude_pack_selection.py`, required to keep the entry module under the 500-line limit.
  - The jest per-file coverage threshold entry for `claude-filesystem-adapter.ts`.
- Out of scope / non-goals: see "Out of Scope and Follow-up" under Rollout & Follow-up.
- Explicitly excluded systems: the Copilot push-down (`push_down_copilot_customizations.py`), the Codex push-down (`push_down_codex_and_agents_customizations.py`, `push_down_codex_filesystem.py`), and the shared `RealPushDownFileSystem` (`push_down_copilot_customizations_filesystem.py`). None of them is changed.

## Root Cause Analysis

- Confirmed root cause, F-507-1: the managed-block merge was implemented only in TypeScript. No Python module contains `gitignore` handling (research §2.1), and `push_down_customizations` in the Python entry module performs no destination write after the engine call (`push_down_claude_customizations.py:357-371`). The #621 spec deferred Python delivery explicitly (research §2.2).
- Confirmed root cause, F-507-2: the Python enumeration chain ends in an unfiltered `rglob` (`push_down_copilot_customizations_filesystem.py:104-106`), and the Claude `ExcludingFileSystem.list_files` (`push_down_claude_filesystem.py:431-448`) applies only an exact-file exclusion built from `EXCLUDED_RELATIVE_PATHS` (`.claude/settings.local.json`, `config/blast-radius.local.json`), plus pack, scope, and memory-mode filters. There is no directory-prefix filter. The TypeScript `listFiles` (`claude-filesystem-adapter.ts:266-278`) has the same structure.
- Affected components: `scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_claude_filesystem.py`, `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`.

## Proposed Fix

### Design summary (what changes where):

- **F-507-1.** New module `scripts/dev_tools/push_down_claude_gitignore_merge.py` with:
  - Constants `GITIGNORE_RELATIVE_PATH = ".gitignore"`, `GITIGNORE_BEGIN_SENTINEL = "# BEGIN drm-copilot managed ignores"`, `GITIGNORE_END_SENTINEL = "# END drm-copilot managed ignores"`, `MANAGED_IGNORE_ENTRIES = (".claude/state/", ".codex/state/")`. Values are identical to the TypeScript constants in `claude-gitignore-merge.ts:39-59`.
  - `merge_claude_gitignore(current_text: str) -> str`: a pure, line-for-line port of `mergeClaudeGitignore` (research §1.1).
  - `deliver_destination_gitignore(fs, destination_root, manifest) -> SkippedPath | None`: a port of `deliverDestinationGitignore` (`claude-customizations.ts:468-496`). It performs I/O only through the injected `PushDownFileSystem`.
  - `push_down_customizations` in the entry module calls the delivery function immediately after the engine copy and before the exclusion report is assembled, and appends a returned `SkippedPath` after the enumeration skips.
- **F-507-2.** Module constant `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` in `push_down_claude_filesystem.py` and an exported constant of the same name in `claude-filesystem-adapter.ts`, each holding `.claude/state` and `.claude/worktrees`. A private predicate tests the source-relative POSIX path for whole-segment prefix membership, and it is the first filter in `list_files` / `listFiles`.
- **Line limit.** `_resolve_published_paths` moves to `push_down_claude_pack_selection.py` as public `resolve_published_paths`.

### Boundaries and invariants to preserve:

- Lines outside the managed block are preserved in content and order.
- The `.gitignore` write is not recorded in `summary.files`, `created_count`, or `overwritten_count`, matching TypeScript (research §1.2).
- General-scoped agent memory under `.claude/agent-memory/` continues to be published under the existing scope and memory-mode filters.
- `EXCLUDED_RELATIVE_PATHS` keeps exact-file semantics.
- `RealPushDownFileSystem` keeps its "all files beneath root" contract.
- `PACK_MANIFEST_SUBDIR` remains importable from `push_down_claude_customizations` and remains in its `__all__`.
- `scripts/dev_tools/push_down_copilot_customizations.py` (504 lines) and `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` (650 lines) are already over the limit and are not modified.

### Dependencies or blocked work:

- None. #621 (destination exclusion manifest) is closed and provides `find_first_match` and `SkippedPath`, which the delivery uses. No new third-party dependency is introduced.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production:

1. `scripts/dev_tools/push_down_claude_gitignore_merge.py` (new): constants, `merge_claude_gitignore`, `deliver_destination_gitignore`.
2. `scripts/dev_tools/push_down_claude_customizations.py`: delivery call after the engine call; skip record passed to `build_exclusion_report`; docstring update; `_resolve_published_paths` removed; pack-selection imports reduced to the names still used.
3. `scripts/dev_tools/push_down_claude_pack_selection.py`: receives `resolve_published_paths`.
4. `scripts/dev_tools/push_down_claude_filesystem.py`: `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` and the prefix predicate in `ExcludingFileSystem.list_files`.
5. `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`: exported `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` and the prefix predicate in `ExcludingFileSystem.listFiles`.

Tests and fixtures:

6. `tests/fixtures/push_down/gitignore-merge-parity.json` (new, shared).
7. `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` (new): pure-merge unit tests.
8. `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py` (new): end-to-end delivery and manifest-skip tests.
9. `tests/scripts/dev_tools/test_push_down_claude_customizations.py`: F-507-2 regression tests.
10. `tests/scripts/dev_tools/test_push_down_claude_parity.py`: gitignore fixture parity and runtime-directory list parity. If the file would exceed 500 lines, the gitignore fixture test moves to a new `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`.
11. `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts` (new).
12. `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`: prefix-exclusion cases, including lookalikes.
13. Conditional: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`, with direct tests of `resolve_published_paths` only if coverage of the moved lines requires them.

Config:

14. `extensions/drm-copilot/jest.config.cjs`: per-file threshold entry `{ lines: 85, branches: 75 }` for `./src/lib/push-down/claude-filesystem-adapter.ts`.

No file under `extensions/drm-copilot/resources/**`, `.claude/**`, `.github/**`, `.codex/**`, or `.agents/**` is written (research §5.4).

#### Functions/classes/CLI commands impacted:

- New: `merge_claude_gitignore`, `deliver_destination_gitignore` (Python).
- Changed: `push_down_customizations` (Python entry module), `ExcludingFileSystem.list_files` (Python), `ExcludingFileSystem.listFiles` (TypeScript).
- Moved: `_resolve_published_paths` becomes `push_down_claude_pack_selection.resolve_published_paths`. It has no test references, so no alias is kept.
- CLI: `push_down_claude_customizations.py` has no new flags. Its output gains one exclusion line when the manifest skips `.gitignore`.

#### Data flow and validation changes:

- Python push-down order after the fix: destination validation, engine copy, summary artifact write, `.gitignore` delivery, exclusion report appended to the artifact. A failure in validation or copy raises before delivery, so no `.gitignore` is written.
- Delivery steps:
  1. If `find_first_match(manifest, ".gitignore")` returns an entry, return `SkippedPath(relative_path=".gitignore", entry=<normalized entry>, line=<line>, destination_status="present" | "absent")` without reading or writing the file.
  2. Otherwise read `<dest>/.gitignore`, treating a missing file as `""`.
  3. Compute `merge_claude_gitignore(current)`.
  4. Write only when the merged text differs from the read text.
- Delivery writes through the raw injected `fs`, not through `engine_fs`, so the exclusion write guard does not raise `ExclusionViolationError` for `.gitignore` (research §5.2).
- Merge semantics (port of research §1.1):
  - `\r\n` and lone `\r` are normalized to `\n`.
  - `""` splits to no lines. Otherwise the text is split on `\n` and one trailing empty element is dropped.
  - Without an exact whole-line BEGIN sentinel, all trailing blank lines are removed and the block is appended. A blank-only or empty document yields the bare block. Otherwise exactly one blank line separates existing content from the block.
  - With a BEGIN sentinel, the first END sentinel at or after it closes the block, which is replaced in place. An END before BEGIN is ignored. A BEGIN without a later END is treated as a one-line block, and later lines are kept. Only the first BEGIN is considered.
  - Output is LF-only, joined with `\n`, with exactly one trailing `\n`.
  - Managed entries that also appear outside the block are not removed.
  - `merge(merge(x)) == merge(x)`.
- F-507-2 predicate: compute the source-relative POSIX path. If it is `None` (the path is outside the source root), keep the path. Otherwise exclude it when, for any `d` in `LOCAL_RUNTIME_RELATIVE_DIRECTORIES`, `relative == d` or `relative.startswith(d + "/")`. Paths such as `.claude/statement.md`, `.claude/worktrees-notes.md`, and `.claude/hooks/state/x.ps1` are retained. The predicate runs before the scope filter, so excluded paths are never read.

#### Error handling and logging updates:

- No new error types. Read and write errors from `fs` propagate unchanged, consistent with TypeScript.
- The manifest skip is reported through the existing exclusion report and CLI exclusion lines. No other logging changes.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the change set. The delivery is idempotent, and destinations already written by TypeScript are a fixed point of the Python merge.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `merge_claude_gitignore(current_text: str) -> str`: any string in; LF-only, newline-terminated string out.
- `deliver_destination_gitignore(fs: PushDownFileSystem, destination_root: Path, manifest: <manifest type used by find_first_match>) -> SkippedPath | None`.
- Shared fixture `tests/fixtures/push_down/gitignore-merge-parity.json`: `{"cases": [{"name": str, "current": str, "expected": str}]}`.

#### Required configuration keys and defaults:

- None. `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` and `MANAGED_IGNORE_ENTRIES` are module constants, not configuration.

#### Backward-compatibility expectations:

- Public names in `push_down_claude_customizations.__all__` are unchanged.
- Destinations previously published by TypeScript are not rewritten by Python unless the block is stale (fixed point).
- Python-published destinations gain the managed block on the next run.

#### Performance constraints (latency/throughput/memory):

- The F-507-2 fix removes the writes from `.claude/worktrees/**` and `.claude/state/**`. It does not remove traversal: `rglob` still walks those trees and `list_files` still resolves each path. This is accepted (see Risks and Out of Scope).
- The delivery adds at most one read and one write per push-down.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - The CLI runs with `source_root == repo_root == cwd` (`push_down_claude_customizations.py:477-490`), so source-relative and repo-relative paths coincide in production.
  - Tests seed regular paths only. Behavior for directory junctions or symlinks under `.claude/worktrees` is unverified (research Unknowns item 6).
- Constraints:
  - 500-line limit for every production and test file written by this change.
  - No temporary files in tests. All tests use the in-memory `RecordingFileSystem` (Python) or `buildInMemoryFileSystem` (TypeScript). New Python push-down tests inject `list_entries` so that `real_directory_lister` is not called.
  - Tiers: `scripts/dev_tools` is T4 and `extensions/drm-copilot` is T3. Property tests are not required.
- External dependencies: none added.

### Recorded decisions

- **D1. Explicit prefix list instead of honoring `.gitignore`.** The prefix list is `.claude/state` and `.claude/worktrees`. Reasons: no new dependency (a pattern library such as `pathspec` is not declared) and no `git check-ignore` subprocess; the list is pure and testable in memory; root `.gitignore:69` ignores `.claude/agent-memory`, whose general-scoped memories are published by design, so honoring `.gitignore` would remove intended behavior; the TypeScript bundle has no `.gitignore` to honor; `push_down_codex_filesystem.py:67-71` already uses a literal `.codex/state/` prefix. The family of gitignored `.claude/` subtrees is `.claude/worktrees`, `.claude/agent-memory`, `.claude/state` (research "Numeric Derivation Evidence", Claim B); `.claude/agent-memory` is omitted from the list by this decision.
- **D2. CRLF residual difference is an accepted, documented limitation.** Python's `RealPushDownFileSystem.read_text` uses `Path.read_text`, which applies universal-newline translation. For a CRLF destination that already holds an up-to-date block, the merged text equals the read text, so Python performs no write and the file keeps CRLF. TypeScript reads raw text and rewrites the file as LF. Matching TypeScript requires a raw-read method (for example a `newline=""` read) on the shared `PushDownFileSystem` protocol, which is also implemented by the Copilot and Codex adapters and by test fakes. That is additional complexity outside this change, so the spec requires the limitation rather than the match. Whenever any change to the file is needed, both implementations write LF. The limitation is stated in the new module's docstring and pinned by a test.
- **D3. Delivery placement deviates from TypeScript.** `deliver_destination_gitignore` lives in the new merge module, not in the entry module, because the entry module is at the 500-line limit. The deviation is stated in the new module's docstring.
- **D4. Prefix filter location.** The filter is in the Claude `ExcludingFileSystem` on both sides, not in `RealPushDownFileSystem` (shared by three publishers) and not in `EXCLUDED_RELATIVE_PATHS` (exact-file semantics).

## Data / API / Config Impact

- User-facing changes: a Python push-down now writes or updates `<dest>/.gitignore` with the managed block, and no longer publishes `.claude/state/**` or `.claude/worktrees/**`.
- Data or migration: none. Files previously published from those subtrees into a destination are not removed by this change.
- Logging/telemetry: one additional exclusion line when the manifest skips `.gitignore`.
- Compatibility: no CLI flag or config schema changes. The jest configuration gains one per-file threshold entry.

## Test Strategy

- Regression-first: each new F-507-1 delivery test and F-507-2 regression test is run against the unfixed code and fails before the fix. Pure-merge and parity tests import the new module inside the test body, so they fail with `ModuleNotFoundError` instead of a collection error (pattern from `test_push_down_claude_parity.py:11-13`). The failing-before and passing-after runs are recorded under `<FEATURE>/evidence/regression/`.
- Python unit tests (`test_push_down_claude_gitignore_merge.py`): absent input, append to content, replace a stale block in place, up-to-date block as a fixed point, idempotence, no trailing newline, CRLF input, lone-CR input, blank-only input, multiple trailing blank lines before append, BEGIN without END, END before BEGIN, a managed entry duplicated outside the block, and a sentinel with trailing whitespace that does not match.
- Shared fixture cases (`gitignore-merge-parity.json`): absent; content without a block; up-to-date block; stale block with surrounding content; duplicated managed entry outside the block; no trailing newline; CRLF input; lone-CR input; BEGIN without END; END before BEGIN; multiple trailing blank lines before append.
- Python delivery tests (`test_push_down_claude_gitignore_delivery.py`): unscoped and pack-scoped delivery; absent destination file; unrelated entries preserved in order; second publish performs no write; manifest skip with `destination_status` `absent` and `present`, with no read and no write; skip record present in the artifact and CLI output; write succeeds through the raw `fs` when an exclusion manifest is active; no delivery when destination validation fails; `.gitignore` absent from `summary.files` and counts; CRLF up-to-date destination is not rewritten (D2).
- F-507-2 Python tests (`test_push_down_claude_customizations.py`): `.claude/state/**` and `.claude/worktrees/**` are neither written nor listed in `summary.files`; lookalikes retained; general-scope agent memory still published; paths outside the source root pass through; a direct `ExcludingFileSystem.list_files` case.
- TypeScript tests: `claude-gitignore-merge-parity.test.ts` runs every fixture case through `mergeClaudeGitignore`. `claude-filesystem-adapter.test.ts` adds prefix-exclusion and lookalike cases. The existing `claude-gitignore-merge.test.ts` and `claude-gitignore-delivery.test.ts` continue to pass.
- Static parity: `test_push_down_claude_parity.py` compares the Python and TypeScript `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` as sets, with a negative self-test showing a mismatch is reported with both file names.
- Coverage: line >= 85% and branch >= 75% for `push_down_claude_gitignore_merge`, `push_down_claude_filesystem`, `push_down_claude_customizations`, `push_down_claude_pack_selection`, and `claude-filesystem-adapter.ts`. No regression on changed lines. Baseline and post-change artifacts go under `<FEATURE>/evidence/coverage/` and `<FEATURE>/evidence/baselines/`, where `<FEATURE>` is `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`.
- Toolchain commands:
  - Python (repository root): `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`; architecture-boundary stage N/A (no Python boundary tool configured); `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing` (dotted `--cov=` form); wider pass `poetry run pytest tests/scripts/dev_tools -k push_down`; contract stage N/A; integration covered by the hermetic push-down suites.
  - TypeScript (`extensions/drm-copilot`): `npm run format`; `npm run lint`; `npm run typecheck`; architecture-boundary stage N/A (no dependency-cruiser config); `npm run test -- test/lib/push-down/claude-filesystem-adapter.test.ts test/lib/push-down/claude-gitignore-merge-parity.test.ts test/lib/push-down/claude-gitignore-merge.test.ts test/lib/push-down/claude-gitignore-delivery.test.ts`; `npm run test:coverage`.
- Manual validation: none required.

## Acceptance Criteria

- [ ] AC-1 `scripts/dev_tools/push_down_claude_gitignore_merge.py` exists and defines `GITIGNORE_RELATIVE_PATH`, `GITIGNORE_BEGIN_SENTINEL`, `GITIGNORE_END_SENTINEL`, `MANAGED_IGNORE_ENTRIES`, `merge_claude_gitignore`, and `deliver_destination_gitignore`, with constant values identical to `claude-gitignore-merge.ts:39-59`. Verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` passing.
- [ ] AC-2 `merge_claude_gitignore` implements the merge semantics in "Data flow and validation changes": absent input, append with one blank-line separator, in-place replacement, fixed point, idempotence, no trailing newline, CRLF and lone-CR normalization, blank-only input, trailing blank lines before append, BEGIN without END, END before BEGIN, duplicated managed entry retained outside the block, and exact whole-line sentinel matching. Each scenario has a named test in `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py`, and the file passes.
- [ ] AC-3 `tests/fixtures/push_down/gitignore-merge-parity.json` exists with shape `{"cases": [{"name", "current", "expected"}]}` and contains every fixture case listed in Test Strategy. `test_gitignore_merge_fixture_parity` (in `test_push_down_claude_parity.py`, or in `test_push_down_claude_gitignore_parity.py` if moved for the line limit) asserts that `merge_claude_gitignore(current) == expected` byte for byte for every case, and passes.
- [ ] AC-4 `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts` loads the same fixture file and asserts that `mergeClaudeGitignore(current) === expected` for every case. It passes under `npm run test -- test/lib/push-down/claude-gitignore-merge-parity.test.ts`.
- [ ] AC-5 In every fixture `expected` value, the managed block lists exactly 2 entries, `.claude/state/` and `.codex/state/`, between the BEGIN and END sentinels (research "Numeric Derivation Evidence", Claim A). Verified by the byte-equality assertions in AC-3 and AC-4.
- [ ] AC-6 After a Python `push_down_customizations` call, `<dest>/.gitignore` equals `merge_claude_gitignore(previous)`, with a missing file treated as `""`, for both an unscoped and a pack-scoped push-down, and unrelated lines are preserved in order. Verified by named tests in `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py` that pass.
- [ ] AC-7 A second Python push-down against a destination whose `.gitignore` is already merged performs no write to `.gitignore`. Verified by a named test in `test_push_down_claude_gitignore_delivery.py` that asserts the recorded write count for that path.
- [ ] AC-8 When the destination `.push-down-exclusions` manifest matches `.gitignore`, the Python delivery performs no read and no write of `.gitignore` and returns a `SkippedPath` with `relative_path=".gitignore"`, the normalized entry, its line number, and `destination_status` of `absent` or `present`. The record follows the enumeration skips in the exclusion report and appears in the summary artifact and the CLI exclusion lines. Verified by named tests covering both statuses in `test_push_down_claude_gitignore_delivery.py`.
- [ ] AC-9 The delivery runs after the engine copy and the summary artifact write and before the exclusion report is appended. A destination-validation failure results in no `.gitignore` write. The `.gitignore` write is absent from `summary.files`, `created_count`, and `overwritten_count`. Verified by named tests in `test_push_down_claude_gitignore_delivery.py`.
- [ ] AC-10 The delivery writes through the raw injected `fs`; a push-down with an active exclusion manifest that does not match `.gitignore` writes `.gitignore` without raising `ExclusionViolationError`. Verified by a named test in `test_push_down_claude_gitignore_delivery.py`.
- [ ] AC-11 Removing the merge from either side fails a test. Python: the AC-6 tests fail if the delivery call is removed from `push_down_customizations`, and AC-3 fails if `merge_claude_gitignore` diverges from the fixture. TypeScript: the existing `claude-gitignore-delivery.test.ts` and `claude-gitignore-merge.test.ts` pass unchanged, and AC-4 fails if `mergeClaudeGitignore` diverges from the fixture. Verified by the regression-first evidence for the Python delivery tests under `<FEATURE>/evidence/regression/` and by both TypeScript suites passing.
- [ ] AC-12 The CRLF limitation (decision D2) is implemented as specified: a Python push-down against a CRLF destination `.gitignore` that already holds an up-to-date block performs no write and leaves the file unchanged, and a CRLF destination that needs a change is written LF-only. The limitation is stated in the docstring of `push_down_claude_gitignore_merge.py`. Verified by a named test in `test_push_down_claude_gitignore_delivery.py` and by `poetry run python -c "import scripts.dev_tools.push_down_claude_gitignore_merge as m; assert 'CRLF' in (m.__doc__ or '')"` exiting 0.
- [ ] AC-13 `scripts/dev_tools/push_down_claude_filesystem.py` defines `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` with the members `.claude/state` and `.claude/worktrees` (decision D1), and `ExcludingFileSystem.list_files` drops every path whose source-relative POSIX form equals a member or starts with a member followed by `/`, before any other filter. Verified by a direct `ExcludingFileSystem.list_files` test in `tests/scripts/dev_tools/test_push_down_claude_customizations.py` that passes.
- [ ] AC-14 A Python push-down whose in-memory source contains `/repo/.claude/state/...` and `/repo/.claude/worktrees/...` files writes none of them to the destination and lists none of them in `summary.files`. Verified by a named test in `test_push_down_claude_customizations.py`, with regression-first evidence under `<FEATURE>/evidence/regression/` showing it fails on the unfixed code.
- [ ] AC-15 Lookalike paths `.claude/statement.md`, `.claude/worktrees-notes.md`, and `.claude/hooks/state/x.ps1` are still published, general-scope agent memory under `.claude/agent-memory/` is still published, and paths outside the source root pass through the prefix predicate. Verified by named tests in `test_push_down_claude_customizations.py`.
- [ ] AC-16 `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` exports `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` with the same members as AC-13, and `ExcludingFileSystem.listFiles` applies the same whole-segment prefix exclusion. `claude-filesystem-adapter.test.ts` contains passing tests for excluded `.claude/state/**` and `.claude/worktrees/**` paths and for the three lookalike paths in AC-15, using `buildInMemoryFileSystem`.
- [ ] AC-17 `tests/scripts/dev_tools/test_push_down_claude_parity.py` contains a static parity test that extracts `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` from both production files and asserts set equality, plus a negative self-test showing that a mismatch fails with a message naming both files. Both pass.
- [ ] AC-18 `_resolve_published_paths` is removed from `push_down_claude_customizations.py`, and `resolve_published_paths` is defined in `push_down_claude_pack_selection.py` and used by the entry module. `PACK_MANIFEST_SUBDIR` remains importable from `push_down_claude_customizations` and remains in its `__all__`. Verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` passing and by a grep for `def _resolve_published_paths` under `scripts/dev_tools` returning no match.
- [ ] AC-19 Every production and test file written by this change (Files/modules to change, items 1-13) has at most 500 lines. Verified by a per-file line count recorded under `<FEATURE>/evidence/qa/`.
- [ ] AC-20 `scripts/dev_tools/push_down_copilot_customizations_filesystem.py`, `scripts/dev_tools/push_down_copilot_customizations.py`, `scripts/dev_tools/push_down_codex_filesystem.py`, `scripts/dev_tools/push_down_codex_and_agents_customizations.py`, `scripts/dev_tools/push_down_claude_exclusion_filter.py`, `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, and `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` are unchanged. Verified by `git diff --name-only origin/main...HEAD -- <those paths>` producing no output.
- [ ] AC-21 No bundled mirror or customization surface is changed: `git diff --name-only origin/main...HEAD -- extensions/drm-copilot/resources .claude .github .codex .agents` produces no output, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [ ] AC-22 Python coverage for `scripts.dev_tools.push_down_claude_gitignore_merge`, `scripts.dev_tools.push_down_claude_filesystem`, `scripts.dev_tools.push_down_claude_customizations`, and `scripts.dev_tools.push_down_claude_pack_selection` is at least 85% line and at least 75% branch, with no coverage regression on changed lines against the baseline. Verified by the Test Strategy pytest command, with baseline and post-change reports under `<FEATURE>/evidence/baselines/` and `<FEATURE>/evidence/coverage/`.
- [ ] AC-23 `extensions/drm-copilot/jest.config.cjs` contains a per-file threshold `{ lines: 85, branches: 75 }` for `./src/lib/push-down/claude-filesystem-adapter.ts`, and `npm run test:coverage` passes in `extensions/drm-copilot`, with the report recorded under `<FEATURE>/evidence/coverage/`.
- [ ] AC-24 The Python toolchain passes in a single pass: `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, the Test Strategy pytest command, and `poetry run pytest tests/scripts/dev_tools -k push_down`. Results recorded under `<FEATURE>/evidence/qa/`.
- [ ] AC-25 The TypeScript toolchain passes in a single pass in `extensions/drm-copilot`: `npm run format` with no file changes, `npm run lint`, `npm run typecheck`, and the Test Strategy `npm run test` command. Results recorded under `<FEATURE>/evidence/qa/`.
- [ ] AC-26 The docstring of `push_down_claude_gitignore_merge.py` states that delivery is placed in that module rather than the entry module because of the line limit (decision D3), and the docstring of `push_down_customizations` describes the post-copy `.gitignore` delivery. Verified by inspection during feature review.

## Risks & Mitigations

- Risk: the new jest threshold for `claude-filesystem-adapter.ts` fails because existing coverage is below 85/75, independent of this change (research Unknowns item 2). Mitigation: measure at baseline; add tests to the adapter file until the threshold holds.
- Risk: the entry-module extraction breaks pack-scoped publication. Mitigation: the existing pack-selection and pack end-to-end suites run unchanged (AC-18); add direct tests of `resolve_published_paths` if coverage requires.
- Risk: `test_push_down_claude_parity.py` exceeds 500 lines. Mitigation: move the gitignore fixture test to `test_push_down_claude_gitignore_parity.py` (AC-3, AC-19).
- Risk: paths reached through a junction or symlink under `.claude/worktrees` resolve outside the source root, so `_source_relative_posix` returns `None` and the prefix predicate keeps them. Mitigation: recorded as unverified; tests use regular paths. Walk pruning is a follow-up.
- Risk: traversal of large `.claude/worktrees/**` trees still costs time. Mitigation: accepted; the reported impact (writes) is removed. Walk pruning is a follow-up.
- Risk: the delivery writes through the raw `fs`, bypassing the destination-write decorators. Mitigation: this matches TypeScript; the manifest check runs first (AC-8, AC-10).
- Rollback: revert the change set. No data migration is involved.

## Rollout & Follow-up

- Release/rollout: merge to `main` through the standard PR flow. No extension rebuild is needed for F-507-1, which is Python-only. The F-507-2 TypeScript change ships with the next extension build.
- Post-fix clean-up: destinations that already received `.claude/state/**` or `.claude/worktrees/**` files from earlier Python push-downs keep them; this change does not delete destination files.

### Out of Scope and Follow-up

- `.claude/agent-memory` source divergence: from a main checkout, Python reads the local gitignored `.claude/agent-memory/`, while TypeScript reads the bundle copy, so the published general-memory set can differ for the same revision. Follow-up candidate.
- Walk pruning: avoiding traversal of `.claude/worktrees/**` requires changing the shared `RealPushDownFileSystem`. Follow-up candidate.
- Raw-read support on `PushDownFileSystem` to close the CRLF difference (D2). Follow-up candidate only if the limitation causes observed churn.
- Honoring `.gitignore` in the Python enumeration (rejected by D1).
- Removing previously published runtime files from destinations.
- Adding a `.gitignore` case to the exclusion plan corpus (`tests/fixtures/push_down_exclusions/plan-corpus.json`); the skip is not produced by `plan_exclusions`, and pinned corpus counts would change on both sides.
- `README.md` changes (no existing statement covers this behavior).

- Links: issue #790; related #507, #510 (PR #834), #621 (PR #783); research `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research/2026-10-08T18-00-python-push-down-divergence-research.md`.
