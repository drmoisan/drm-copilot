# Research: Python push-down divergence follow-ups (Issue #790)

- Issue: #790 (bug, work mode full-bug), branch `bug/issue-507-python-push-down-divergence-follow-ups-790`
- Tree read: agent worktree based on `origin/main` `e7d3779b`
- Date: 2026-10-08
- Scope: F-507-1 (Python has no managed `.gitignore` merge) and F-507-2 (Python CLI publishes gitignored `.claude/worktrees/**` and `.claude/state/**`)
- Filename note: the orchestrator supplied `research.2026-10-08T18-00.md`. That name does not match the pattern `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$` that `.claude/hooks/validate-task-researcher-output.ps1:95-98` enforces, so this artifact is written to the same `research/` directory as `2026-10-08T18-00-python-push-down-divergence-research.md`.

All citations are `path:line` against the tree above. They were confirmed with Read/Grep/Glob in this session. No shell tool was available, so `git log` and `gh` were not run. Where that matters, it is listed under Unknowns.

---

## 1. Current TypeScript gitignore merge (F-507-1 reference behavior)

### 1.1 Pure merge module: `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` (166 lines)

Constants (block literals quoted exactly):

- `CLAUDE_GITIGNORE_RELATIVE_PATH = ".gitignore"` (`:39`).
- `CLAUDE_GITIGNORE_BEGIN_SENTINEL = "# BEGIN drm-copilot managed ignores"` (`:42-43`).
- `CLAUDE_GITIGNORE_END_SENTINEL = "# END drm-copilot managed ignores"` (`:46-47`).
- `CLAUDE_MANAGED_IGNORE_ENTRIES = [".claude/state/", ".codex/state/"]` (`:56-59`). The entries are hard-coded in this module, which is their only declaration in the repository (repo-wide grep for `CLAUDE_MANAGED_IGNORE_ENTRIES\s*(:|=)` returns only `:56`). They are not read from the source repository's `.gitignore`.

The rendered block (`renderManagedBlock`, `:96-102`) is:

```
# BEGIN drm-copilot managed ignores
.claude/state/
.codex/state/
# END drm-copilot managed ignores
```

Algorithm of `mergeClaudeGitignore(currentText)` (`:112-136`):

1. Line endings: `\r\n` and lone `\r` are normalized to `\n` (`normalizeLineEndings`, `:71-73`, regex `/\r\n?/g`).
2. Splitting: `toLines` (`:83-93`) returns `[]` for `""`. Otherwise it splits on `\n` and drops one trailing empty element. Input with and without a final newline therefore produces the same line array.
3. Placement:
   - When no line equals the BEGIN sentinel exactly (`lines.indexOf`, `:116`), the block is appended (`appendManagedBlock`, `:144-161`). All trailing blank lines are removed first (`:148-154`). For an empty or blank-only document the result is the bare block (`:156-157`). Otherwise exactly one blank line separates existing content from the block (`:160`).
   - When a BEGIN sentinel exists, the first END sentinel at or after it closes the block (`:125-128`). An END sentinel before the BEGIN sentinel is ignored. If no END sentinel follows, the block is the BEGIN line alone and every later line is kept as unmanaged content (`:121-124`). The block is replaced in place (`:130-134`). Only the first BEGIN sentinel is considered.
4. Output: `toDocument` (`:164-166`) joins with `\n` and appends exactly one `\n`. The output is always LF-only and newline-terminated.
5. Idempotence: `merge(merge(x)) == merge(x)` (docstring `:19-32`; tested in `claude-gitignore-merge.test.ts:55-64, 133-144, 146-176`).
6. Duplicates: managed entries that also appear outside the block are not suppressed (`:27-30`; test `:97-118`).
7. Sentinel matching is exact whole-line equality. A sentinel with trailing whitespace does not match (inference from `indexOf` at `:116`; no test covers it).

### 1.2 Call site: `deliverDestinationGitignore` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (496 lines)

- Ordering: the engine copy runs first (`enginePushDown`, `:414-424`), then the delivery runs (`:426-430`), then the exclusion report is assembled (`:431-440`). The delivery runs after the copy and after the summary artifact is written by the engine. It runs before `appendExclusionsToArtifact` (`:439`).
- It runs whether or not a pack selection is supplied (no conditional around `:426`; test `claude-gitignore-delivery.test.ts:57-67`).
- It uses the raw injected adapter `fs`, not any decorator (`:452-456`, `:426-430`). This bypasses both the exclusion write guard and the destination-write decorator registry.
- Manifest interaction (#621): if the destination `.push-down-exclusions` manifest has an entry matching `.gitignore`, the function returns a `SkippedPath` record with `destinationStatus` `present` or `absent`, and performs no read and no write (`:477-487`). The record is appended to the exclusion report (`:434-438`). Test: `claude-exclusion-filter.test.ts:279-305`.
- Absent destination `.gitignore`: treated as `""` (`:488-490`). The result is a file containing only the block.
- Write suppression: the write happens only when `mergedText !== currentText` (`:491-494`). A second publish performs no write (test `claude-gitignore-delivery.test.ts:69-93`).
- Summary: the `.gitignore` write is not recorded in `summary.files`, `created_count`, or `overwritten_count`. Those are produced inside the engine before the delivery.
- Dry run: none. Grep for `(?i)dry.?run` under `extensions/drm-copilot/src` matches only the unrelated orchestration-handoff `dry_run` mode. Grep under `scripts/` matches only PowerShell scripts. Neither push-down has a dry-run path.

### 1.3 I/O line-ending behavior (TypeScript)

- `RealPushDownFileSystem.readTextFile` returns raw bytes decoded as UTF-8 with no newline translation (`filesystem-adapter.ts:174-176`, `fs.readFileSync(path, "utf8")`).
- `writeTextFile` normalizes CRLF/CR to LF (`filesystem-adapter.ts:188-194`).
- Consequence: for a CRLF destination file that already contains an up-to-date block, `currentText` contains `\r`. The merged LF text differs, so TypeScript rewrites the whole file as LF. Every unmanaged line is then rewritten with LF endings. The issue's expected behavior ("Lines outside the managed block are preserved byte for byte", `issue.md:31`) holds for content but not for CRLF line endings, in either implementation.

---

## 2. Existing Python coverage of F-507-1 and F-507-2 on main

### 2.1 No Python gitignore handling exists

- Case-insensitive grep for `gitignore` under `scripts/` returns no Python matches. The matches are `scripts/powershell/Publish-DrmCopilotExtension.ps1` and `scripts/dev-tools/bootstrap-host.ps1`, and both are dry-run text.
- Repo-wide grep for `drm-copilot managed ignores|mergeClaudeGitignore|merge_claude_gitignore|deliverDestinationGitignore` matches only the TypeScript source and tests, plus docs under `docs/features/**`.
- `push_down_claude_customizations.py:357-371`: after the engine call, Python only assembles the exclusion report. There is no post-copy destination write.

### 2.2 Status of #621 and related work

- #621 (public issue page fetched with WebFetch): **Closed**, linked PR #783. The issue concerns the destination exclusion manifest and does not address `.gitignore` delivery in Python or `.claude/worktrees`/`.claude/state`.
- #621 spec explicitly deferred Python delivery: "Python delivers no `.gitignore` today, so the parity corpus carries no `.gitignore` scenario until Python delivers it" (`docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/spec.md:86-88`). Out of scope: "A `.gitignore` delivery in Python (not present today; out of scope)" (`:198`).
- #507 spec recorded both defects as follow-ups only (`docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md:71-72, 263, 279-280`).
- #510 (PR #834 per `issue.md:41-43`) changed only the test-side enumeration: `tests/scripts/dev_tools/claude_payload_scope_test_support.py` exists in this tree, and production `ExcludingFileSystem.list_files` has no prefix filter (`push_down_claude_filesystem.py:431-448`).
- #790 issue page (WebFetch): **Open**, no linked PRs.
- Conclusion: on this tree, neither F-507-1 nor F-507-2 is fixed. Verified by reading the production modules (§2.1, §4.1).

---

## 3. Existing Python/TypeScript parity tests

### 3.1 `tests/scripts/dev_tools/test_push_down_claude_parity.py` (438 lines), the #507 parity test

- Static parity: the TypeScript text has comments stripped (`_strip_ts_comments`, `:60-85`) and `export const` initializers extracted (`_ts_declarations`, `:110-117`). Python module-level assignments are extracted with `ast` (`_py_assignment`, `:181-192`). Tests compare `ROOT_FOLDERS` in order (`:257-263`), merged-path sets (`:266-280`), and derived paths (`:283-295`). Failures name both files (`_assert_same`, `:245-254`). Negative self-tests are at `:298-394`.
- Behavioral parity: `test_routing_merge_fixture_parity` (`:397-438`) reads the shared fixture `tests/fixtures/push_down/routing-merge-parity.json` (`:43`) and asserts the Python merge reproduces every case byte for byte. Production modules are imported inside the test body (`importlib`, `:406-411`) so the file collects before new modules exist (module docstring `:11-13`).
- TypeScript counterpart: `extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts` (164 lines) loads the same fixture through `REPO_ROOT` (`:99-112`), narrows its shape (`:60-91`), and runs `it.each` over the cases (`:116-163`).
- Other shared-fixture parity: `tests/fixtures/push_down_exclusions/{matcher,manifest,plan}-corpus.json`, used by `test_push_down_claude_exclusion_parity.py` and `claude-exclusion-parity.test.ts`. That suite pins case counts (`test_push_down_claude_exclusion_parity.py:104-107, 125-128, 153-156`: 18/14/9). Adding a case there changes pinned counts on both sides. The `.gitignore` skip is not computed by `plan_exclusions`, so that corpus is not the right home for it.

### 3.2 How a gitignore-merge parity assertion fits

Recommended: a new shared fixture `tests/fixtures/push_down/gitignore-merge-parity.json` with the shape `{"cases": [{"name", "current", "expected"}]}`. It mirrors the routing-merge fixture mechanism.

- Python: add `test_gitignore_merge_fixture_parity` to `test_push_down_claude_parity.py`, importing `scripts.dev_tools.push_down_claude_gitignore_merge` inside the test body. Estimated +20 lines, giving about 458.
- TypeScript: new `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`, modeled on `claude-routing-merge-parity.test.ts`.
- Because each `expected` string contains the sentinels and entries, byte equality on both sides also pins the sentinel and entry constants. No separate static-constant extraction is needed for F-507-1.
- Suggested cases, all derived from §1.1: absent (`""`); content without a block; up-to-date block (fixed point); stale block replaced in place with surrounding content; managed entry duplicated outside the block; no trailing newline; CRLF input; lone-CR input; BEGIN without END; END before BEGIN; multiple trailing blank lines before append.
- "Fails if either side drops the merge" requires a call-site check on each side. TypeScript already has `claude-gitignore-delivery.test.ts`. Python needs an equivalent end-to-end delivery test (§5.2). Each side's fixture test fails if its pure function is removed or diverges.

---

## 4. F-507-2: Python enumeration chain and the exclusion point

### 4.1 Call chain (CLI entry to `rglob`)

1. `main` (`push_down_claude_customizations.py:462-495`) uses `RealPushDownFileSystem()` (`:479`) with `repo_root = source_root = artifact_root = cwd` (`:477, 481-490`).
2. `push_down_customizations` (`:242-371`) composes, innermost first: `fs`, then `build_destination_write_stack` (`:334-338`; `BlastRadiusDeriveFileSystem` over `DestinationMergeFileSystem`), then `BundleConfigFileSystem` (`:340-342`), then `ExcludingFileSystem` (`:339-351`), then optionally `ExclusionFilterFileSystem` (`:352-356`).
3. Engine: `push_down_scoped_customizations` = `push_down_copilot_customizations.push_down_customizations` (`push_down_copilot_customizations.py:335-439`). It calls `enumerate_source_files` (`:366-371`, `:139-178`), which calls `fs.list_files(source_root / root)` for `ROOT_FOLDERS = (".claude", "config")` (`push_down_claude_customizations.py:145`).
4. `ExclusionFilterFileSystem.list_files` (`push_down_claude_exclusion_filter.py:174-191`) delegates to `ExcludingFileSystem.list_files` (`push_down_claude_filesystem.py:431-448`). Its filters are exact-file exclusion (`p.resolve() not in self._excluded`, built from `EXCLUDED_RELATIVE_PATHS` at `:272-274`), pack, agent-memory scope, and memory mode. There is no directory-prefix filter.
5. `BundleConfigFileSystem.list_files` (`push_down_claude_destination_writes.py:352-360`) redirects only `<source>/config` to `<bundle>/config`. The `.claude` root passes through.
6. `RealPushDownFileSystem.list_files` (`push_down_copilot_customizations_filesystem.py:80-107`) is an unfiltered `root.rglob("*")` (`:104-106`).

`EXCLUDED_RELATIVE_PATHS` (`push_down_claude_customizations.py:149-152`) contains only `.claude/settings.local.json` and `config/blast-radius.local.json`, both exact files.

Only the `.claude` root is enumerated from the checkout. `config/` comes from the bundle. The affected surface is therefore `.claude/**`.

### 4.2 Gitignored `.claude` subtrees and what each should do

Root `.gitignore` (the only `.gitignore` in the tree, per Glob `**/.gitignore`): `.claude/worktrees` (`:23`), `.claude/agent-memory` (`:69`), `.claude/state/` (`:70`). There is also `.codex/state/` (`:71`).

- `.claude/worktrees/**` and `.claude/state/**`: machine-local runtime state, absent from the bundle (Glob of `extensions/drm-copilot/resources/**/{state,worktrees}/**` finds none). These must be excluded. This is the F-507-2 defect.
- `.claude/agent-memory/**`: **not** a candidate for blanket exclusion.
  - The bundle ships 13 agent-memory files under `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/` (Glob). `test_push_down_claude_resource_contracts.py:259-302` requires those to be `general` scope (non-index) or `repo` scope (`MEMORY.md`).
  - The production scope filter (`push_down_claude_filesystem.py:312-351`) and memory-mode filter (`:353-398`) intentionally publish general-scoped memories.
  - A blanket exclusion would change `memory_mode` semantics and diverge from TypeScript, which publishes the bundle's general memories.
  - Residual divergence, not fixed by this issue: from a main checkout, Python reads the local, gitignored `.claude/agent-memory/` rather than the bundle copy, so its general-memory set can differ from TypeScript's for the same revision. A clean worktree has no files there (Glob `.claude/agent-memory/**` returns none). This is recorded under Unknowns as a decision for the spec author.
- `tests/scripts/dev_tools/claude_payload_scope_test_support.py:27-32` defines `LOCAL_ONLY_CLAUDE_SUBDIRS = {"agent-memory", "state", "worktrees"}`. That set governs the repo-to-bundle mirror test (`test_push_down_claude_resource_contracts.py:89-110`), not publication. It should not be imported by production code (test support), and its `agent-memory` member does not apply to the production filter.

### 4.3 Is the Copilot or Codex push-down affected?

- Copilot (`push_down_copilot_customizations.py`): its roots are `.github/agents`, `.github/instructions`, `.github/prompts`, `.github/skills` (`agentic_sync.py:24-29`). No gitignored runtime subtree lives under those roots, so it is not affected. It shares `RealPushDownFileSystem` (`push_down_copilot_customizations.py:22-25, 491`) with the Claude and Codex CLIs.
- Codex (`push_down_codex_and_agents_customizations.py`): uses its own `ExcludingFileSystem` from `push_down_codex_filesystem.py` (`:16`). That class already excludes `.codex/state/` with a source-relative prefix check (`_is_publishable_source_path`, `push_down_codex_filesystem.py:67-71`, applied in `list_files` `:83-90`). This is an in-repo precedent for the recommended approach.
- The Claude `ExcludingFileSystem` is constructed only at `push_down_claude_customizations.py:339`. A repo-wide grep for `ExcludingFileSystem(` in `*.py` and `tests/` finds no other construction.

### 4.4 Where the exclusion fits most simply

| Location | Effect | Assessment |
|---|---|---|
| `RealPushDownFileSystem.list_files` | Would also prune the walk, avoiding traversal of large worktree trees | Rejected: shared by the Copilot, Codex, and Claude CLIs, and its contract is "all files beneath root" (`push_down_copilot_customizations_filesystem.py:35, 80-107`). Changing it alters two unaffected publishers. |
| `EXCLUDED_RELATIVE_PATHS` | Exact-path set compared with `p.resolve() not in` (`push_down_claude_filesystem.py:444`) | Rejected: semantics are exact-file. Prefix matching would change the meaning of an existing parameter. The host module is also 499 lines (§6). |
| `ExcludingFileSystem.list_files` (Python) and `ExcludingFileSystem.listFiles` (TypeScript) | Filters enumeration for the Claude publisher only | **Recommended.** Matches the Codex precedent. Mirrors one-to-one into `claude-filesystem-adapter.ts`. Already owns the other enumeration filters. |

Recommended design (Python, `scripts/dev_tools/push_down_claude_filesystem.py`):

- Add module constant `LOCAL_RUNTIME_RELATIVE_DIRECTORIES: tuple[str, ...] = (".claude/state", ".claude/worktrees")`.
- Add predicate `_is_local_runtime_path(path)`: compute `self._source_relative_posix(path)` (`:276-290`), return `False` for `None`, otherwise test `relative == d or relative.startswith(d + "/")` for any `d`. This is segment-safe: `.claude/statement.md`, `.claude/worktrees-notes.md`, and `.claude/hooks/state/x.ps1` are retained, consistent with the lookalike rules in `claude_payload_scope_test_support.py:13-14`.
- Make the predicate the first operand in `list_files` (`:441-448`) so excluded paths never reach the scope filter's content read.
- Use the source-relative form, not repo-relative, because the engine derives destination paths from `source_root` (`push_down_copilot_customizations.py:372`). In the CLI, source and repo roots are equal.

### 4.5 Recommendation: explicit prefix list rather than honoring `.gitignore`

Recommend the explicit prefix list.

1. **No new dependencies.** Honoring `.gitignore` faithfully needs a gitignore-pattern engine (for example `pathspec`, which is not a declared dependency; `pyproject.toml:38-41` lists only tooling) or a `git check-ignore` subprocess. The subprocess adds an external process, a `git` requirement, and I/O that the in-memory unit tests cannot model.
2. **Determinism and testability.** A constant list is pure and is unit-testable with the existing in-memory `RecordingFileSystem`. A `.gitignore`-driven result depends on files outside `.claude/` and on global or user excludes.
3. **Behavioral correctness.** Root `.gitignore:69` ignores `.claude/agent-memory`, but publication of general-scoped memories is intended (§4.2). Honoring `.gitignore` would silently remove that behavior.
4. **Parity.** TypeScript enumerates the curated bundle, which has no `.gitignore` to honor. A shared literal list can be pinned by the static parity test (§5.3).
5. **Precedent.** `push_down_codex_filesystem.py:67-71` already uses a literal `.codex/state/` prefix.

Rejected alternative: honoring `.gitignore` via `git check-ignore` or a pattern library, for reasons 1-4.

Known limitation: filtering after `rglob` still walks `.claude/worktrees/**` on disk, and `ExcludingFileSystem.list_files` calls `p.resolve()` per path (`:444`). The fix removes the writes, which is the reported impact (`issue.md:39`), but not the traversal cost. Pruning would require changing the shared `RealPushDownFileSystem` and is recommended as out of scope.

---

## 5. TypeScript side, tests, and bundled mirrors

### 5.1 TypeScript adapter

- `ExcludingFileSystem.listFiles` (`claude-filesystem-adapter.ts:266-278`) applies the exact-path set (`:160`, `:273`), pack, scope, and memory-mode filters. There is no prefix filter.
- The gap is latent. The extension passes the bundled `resources/claude-customizations` as `sourceRoot`, `repoRoot`, and `bundleRoot` (`push-down-service-call.ts:172-189`), and the bundle contains no `state/` or `worktrees/` trees.
- Adding the same exclusion is warranted for parity and defense in depth. It costs about 15-20 lines: an exported `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` constant plus a private predicate using the existing `sourceRelativePosix` (`:169-171`). The static parity test can then pin both lists.
- Jest test file: `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` (306 lines). It uses `buildInMemoryFileSystem` from `./push-down.test-helpers` (`:8`).
- Coverage gate: `jest.config.cjs` has per-file thresholds only (`:20-25`) and **no entry** for `./src/lib/push-down/claude-filesystem-adapter.ts`. The repository convention (comments at `:294-303`) is to add a `{ lines: 85, branches: 75 }` entry for changed files. Current per-file coverage of that module is unknown (see Unknowns).

### 5.2 Python tests

- `tests/scripts/dev_tools/test_push_down_claude_customizations.py` (284 lines) defines its own local `MemoryFile`/`RecordingFileSystem` (`:15-66`). The same classes are shared from `tests/scripts/dev_tools/push_down_customizations_test_support.py:24-74`. `list_files` returns every stored path under `root` (`:30-40`), so seeding `/repo/.claude/state/...` reproduces the defect without the real filesystem.
- Tests must inject `list_entries` (for example an empty lister, as in `test_push_down_claude_exclusion_filter.py:91-94, 118-131`) so `real_directory_lister` is never called. Several existing tests in `test_push_down_claude_customizations.py` omit it; new tests should not.
- No existing push-down test seeds `.claude/state` or `.claude/worktrees` paths. Grep across `tests/scripts/dev_tools/test_push_down*.py` and `extensions/drm-copilot/test/**push-down**` finds only gitignore-merge string literals and doc comments, so the F-507-2 change does not invalidate existing expectations.
- Impact of the F-507-1 change on existing Python tests (reviewed):
  - Artifact counts and `summary.files` exclude the `.gitignore` write. Assertions such as `created_count == 1` (`test_push_down_claude_customizations.py:238`) and `len(summary.files) == 6` (`:166`) are unaffected.
  - `test_push_down_claude_pack_end_to_end.py:350-390` compares two destination maps that would both gain an identical `.gitignore`.
  - No plan-corpus manifest matches `.gitignore` (`plan-corpus.json` manifests at `:21, 47, 76, 105, 130, 156, 182, 201, 225`), so `test_cli_prints_exclusion_lines_after_artifact_line` (`test_push_down_claude_exclusion_filter.py:348-363`) is unaffected.
  - `test_absent_manifest_artifact_keys_and_single_write_unchanged` (`:333-345`) counts only artifact writes.
  - Executors should still run the full `tests/scripts/dev_tools/test_push_down_claude*.py` set. This review covered the assertions surfaced by grep, not every line of every file.
- Write path: the Python delivery must write through the raw `fs`, as TypeScript does. Writing through `engine_fs` would raise `ExclusionViolationError` when the manifest matches `.gitignore` (`push_down_claude_exclusion_filter.py:213-235`). The manifest check must use `find_first_match(manifest, ".gitignore")` (`push_down_exclusion_manifest.py:250`) and produce a `SkippedPath` (`:116-130`) with the TypeScript record shape.

### 5.3 Static parity extension for F-507-2

Add one test to `test_push_down_claude_parity.py`:

- Extract the TypeScript `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` with `_ts_declarations` (`:110-117`). The bracketed-literal parsing used by `_ts_root_folders` (`:120-129`) would need a name parameter.
- Extract the Python tuple with `_py_assignment` (`:181-192`).
- Compare as sets. The test asserts the lists are equal; any element count it asserts must come from the `## Numeric Derivation Evidence` section below.
- Estimated +15 to +25 lines. Together with §3.2, this keeps the file under 500 (about 475-483). If it would exceed 500, move the gitignore fixture case into a new `test_push_down_claude_gitignore_parity.py`.

### 5.4 Bundled mirrors

- There is no Python file under `extensions/drm-copilot/resources/**` (Glob `**/*.py` returns none). The `dev_tools.*` fallback imports (for example `push_down_claude_customizations.py:64-104`) are not exercised by any bundled copy in this tree.
- The TypeScript push-down modules are compiled by esbuild (`package.json:203-206`). They are not mirrored as source under `resources/`.
- `resources/claude-customizations/.claude/**` mirrors repo `.claude/**` (`test_push_down_claude_resource_contracts.py:89-110`). The recommended fix changes no file under `.claude/`, so no bundle mirror update is required.
- Repo-wide references to `push_down_claude*` and `claude-filesystem-adapter`/`claude-gitignore` under `.github/`, `.claude/`, `.codex/`, `.agents/`: only `.codex/config.toml:13`, which is an MCP tool name. Nothing needs syncing.

---

## 6. File sizes against the 500-line limit

Counts were taken with a per-line grep count; they match Read's last line number where both were checked.

| File | Lines now | Expected change | Projected | Note |
|---|---|---|---|---|
| `scripts/dev_tools/push_down_claude_customizations.py` | 499 | +6 import lines (two try/except branches), +3 call-site lines | about 508 | **Over the limit; an extraction is required** |
| `scripts/dev_tools/push_down_claude_filesystem.py` | 472 | +about 18 (constant, predicate, filter operand, docstring) | about 490 | Fits; keep the docstring short |
| `scripts/dev_tools/push_down_claude_pack_selection.py` | 401 | +about 50 if it receives `resolve_published_paths` | about 451 | Fits |
| New `scripts/dev_tools/push_down_claude_gitignore_merge.py` | 0 | about 150-180 | about 170 | New module |
| `scripts/dev_tools/push_down_claude_exclusion_filter.py` | 346 | 0 | 346 | Not changed under the recommendation |
| `scripts/dev_tools/push_down_copilot_customizations.py` | 504 | 0 | 504 | Already over; do not touch |
| `scripts/dev_tools/push_down_copilot_customizations_filesystem.py` | 217 | 0 | 217 | Not changed |
| `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` | 303 | +about 18 | about 321 | Fits |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | 496 | 0 | 496 | Not changed |
| `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` | 166 | 0 | 166 | Not changed |
| `tests/scripts/dev_tools/test_push_down_claude_parity.py` | 438 | +about 35-45 | about 475-483 | Fits; split per §5.3 if needed |
| `tests/scripts/dev_tools/test_push_down_claude_customizations.py` | 284 | +about 60 (F-507-2 regression tests) | about 345 | Fits |
| New `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` | 0 | about 150 | about 150 | Pure-merge unit tests |
| New `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py` | 0 | about 170 | about 170 | End-to-end delivery and manifest skip |
| `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` | 348 | +about 25 if `resolve_published_paths` gets direct tests | about 373 | Optional |
| `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` | 306 | +about 45 | about 351 | Fits |
| New `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts` | 0 | about 90 | about 90 | Fixture parity |
| `extensions/drm-copilot/jest.config.cjs` | 470 | +4 | 474 | Config, not code |
| `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` | 650 | 0 | 650 | Already over; not touched |

Proposed split for `push_down_claude_customizations.py`: move `_resolve_published_paths` (`:191-239` plus surrounding blank lines, about 51 lines) into `push_down_claude_pack_selection.py` as public `resolve_published_paths`. Then:

- Collapse the four now-unused pack-selection imports (`PackManifest`, `assert_single_csharp_toolchain`, `compute_published_paths`, `load_pack_manifests`, `:50-58` and `:91-99`) to one name per branch, saving about 6 lines.
- `PACK_MANIFEST_SUBDIR` (`:115`) is in `__all__` (`:166`). Either keep it in the entry module and pass `manifest_dir` to the moved function, or move it and re-export it.
- `_resolve_published_paths` has no test references (grep), so no alias is needed.
- Projected entry-module size is about 451 lines.

Alternative with a smaller move: relocate `_parse_packs_argument` (`:439-459`), keeping an alias because `test_push_down_claude_pack_selection.py:310-326` calls `module._parse_packs_argument`. That projects about 490 lines with little headroom, so it is not preferred.

Where to put the Python delivery function: in the new `push_down_claude_gitignore_merge.py`, next to the pure `merge_claude_gitignore`. It performs I/O only through the injected `PushDownFileSystem`. This differs from TypeScript, where `deliverDestinationGitignore` sits in `claude-customizations.ts` (`:468-496`); the deviation is forced by the 500-line cap on the entry module. Document it in the module docstring.

---

## 7. Toolchain commands and quality tiers

Tiers (`quality-tiers.yml`):

- `scripts/dev_tools`: **T4** (`:16-18`).
- `extensions/drm-copilot`: **T3** (`:7-9`).
- Coverage thresholds are uniform across tiers: line at least 85%, branch at least 75% (`.claude/rules/quality-tiers.md`).
- Property tests are not required for T3 or T4. `hypothesis` is not a declared dependency (`pyproject.toml` grep).

Python (repository root):

1. `poetry run black .` (or `poetry run black --check .` to verify)
2. `poetry run ruff check .`
3. `poetry run pyright` (strict mode, `pyproject.toml:142-145`)
4. Architecture-boundary stage: no Python boundary tool is configured. Record N/A.
5. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing`
   - Use the dotted `--cov=` form. `pyproject.toml:116` adds `--cov-report=lcov:artifacts/python/lcov.info` through `addopts`.
   - Run `poetry run pytest tests/scripts/dev_tools -k push_down` as the wider regression pass.
6. Contract stage: N/A (no schema change).
7. Integration: the push-down suites above are hermetic in-memory tests.

TypeScript (`extensions/drm-copilot`, scripts at `package.json:202-214`):

1. `npm run format` (`prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`), or `npx prettier --check <files>` to verify
2. `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`)
3. `npm run typecheck` (`tsc -p ./ --noEmit && tsc -p tsconfig.jest.json --noEmit`)
4. Architecture-boundary stage: no `.dependency-cruiser*` file exists in the tree (Glob). Record N/A.
5. `npm run test -- test/lib/push-down/claude-filesystem-adapter.test.ts test/lib/push-down/claude-gitignore-merge-parity.test.ts test/lib/push-down/claude-gitignore-merge.test.ts test/lib/push-down/claude-gitignore-delivery.test.ts`
6. `npm run test:coverage`. Per-file thresholds come from `jest.config.cjs`.

Evidence artifacts go under `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/<kind>/`.

---

## 8. Files a minimal fix would write

Production:

1. `scripts/dev_tools/push_down_claude_gitignore_merge.py` (new):
   - `GITIGNORE_RELATIVE_PATH`, `GITIGNORE_BEGIN_SENTINEL`, `GITIGNORE_END_SENTINEL`, `MANAGED_IGNORE_ENTRIES`.
   - `merge_claude_gitignore(current_text: str) -> str`: a pure, line-for-line port of §1.1.
   - `deliver_destination_gitignore(fs, destination_root, manifest) -> SkippedPath | None`: a port of `claude-customizations.ts:468-496`.
2. `scripts/dev_tools/push_down_claude_customizations.py`:
   - Call `deliver_destination_gitignore(fs, destination_root, manifest)` after the engine call (after `:357-366`, before `:367`).
   - Pass `[*engine_fs.skipped, gitignore_skip]` (when the skip is not `None`) to `build_exclusion_report`.
   - Update the docstring.
   - Remove `_resolve_published_paths` (moved).
3. `scripts/dev_tools/push_down_claude_pack_selection.py`: receives `resolve_published_paths`.
4. `scripts/dev_tools/push_down_claude_filesystem.py`: `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` plus the prefix predicate in `ExcludingFileSystem.list_files`.
5. `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`: the same constant and predicate in `listFiles`.

Tests and fixtures:

6. `tests/fixtures/push_down/gitignore-merge-parity.json` (new, shared).
7. `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` (new): pure-merge cases.
8. `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py` (new). Cases:
   - unscoped and pack-scoped delivery
   - second publish performs no write
   - unrelated entries preserved in order
   - manifest `.gitignore` skip with `absent` and `present`
   - absent destination file
9. `tests/scripts/dev_tools/test_push_down_claude_customizations.py`: F-507-2 regression tests.
   - `.claude/state/**` and `.claude/worktrees/**` are neither written nor listed in `summary.files`.
   - Lookalike paths are retained.
   - General-scope agent memory is still published.
   - A direct `ExcludingFileSystem.list_files` case.
10. `tests/scripts/dev_tools/test_push_down_claude_parity.py`: gitignore fixture parity plus runtime-directory list parity.
11. `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts` (new).
12. `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`: prefix-exclusion cases, including lookalikes.
13. Optional: `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`, with direct tests of the moved `resolve_published_paths` if coverage of the moved lines requires it. Existing end-to-end tests already exercise it through the entry point.

Config:

14. `extensions/drm-copilot/jest.config.cjs`: per-file threshold entry for `./src/lib/push-down/claude-filesystem-adapter.ts`.

Bundled mirrors: none (§5.4). Documentation: `README.md` has no `.gitignore` or runtime-subtree statement (grep), so no README change is required. A one-line note is optional.

---

## Behavior Semantics (target state)

- F-507-1 success: after a Python push-down, `<dest>/.gitignore` equals `merge_claude_gitignore(previous)`. Absent counts as `""`. The text is byte-identical to the TypeScript result for the same input under the shared fixture.
  - A second run performs no write.
  - With a manifest entry matching `.gitignore`, there is no read or write, and one `SkippedPath(relative_path=".gitignore", entry=<normalized>, line=<n>, destination_status="present"|"absent")` is appended after the enumeration skips. It is reported in the artifact and the CLI lines.
- F-507-1 ordering: destination validation, then copy, then summary artifact, then `.gitignore` delivery, then exclusion report appended to the artifact. A failure in validation or copy means no delivery.
- F-507-2 success: no source path whose source-relative POSIX form equals or starts with `.claude/state/` or `.claude/worktrees/` is enumerated, read, written, or listed in `summary.files`, on either side.
- Known residual line-ending divergence: for a CRLF destination file that already holds an up-to-date block, TypeScript rewrites it to LF (§1.3). Python's `Path.read_text` (`push_down_copilot_customizations_filesystem.py:171`) applies universal-newline translation, so the merged text equals the read text and Python performs no write. The file keeps CRLF. Both implementations converge on LF whenever any change is needed. Closing this gap requires a raw-read method on the shared `PushDownFileSystem` protocol. Recommend recording it as an accepted limitation.

## Numeric Derivation Evidence

Claim A. Proposed AC wording: the managed block delivered by both implementations contains exactly 2 entries.

- Numeric spec.md acceptance criterion: the shared gitignore fixture's expected block lists 2 managed entries
- Complete Family: CLAUDE_MANAGED_IGNORE_ENTRIES
- Exhaustive Search Scope: entire repository tree searched for every declaration of the managed ignore entry list (repo-wide grep `CLAUDE_MANAGED_IGNORE_ENTRIES\s*(:|=)` returned one declaration, claude-gitignore-merge.ts:56)
- Inclusion Rules: string literals inside the CLAUDE_MANAGED_IGNORE_ENTRIES array initializer
- Exclusion Rules: sentinel lines, comments, and test-file literals that mention the same paths
- Primary Search Strategy or Query Expression: Read of extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts lines 56-59 enumerating the CLAUDE_MANAGED_IGNORE_ENTRIES array literal
- Primary Member Set: .claude/state/, .codex/state/
- Primary Count: 2
- Cross-check Search Strategy or Query Expression: content grep with regex `"\.[a-z]+/state/"` over claude-gitignore-merge.ts, confirming each hit lies in the CLAUDE_MANAGED_IGNORE_ENTRIES initializer (hits at lines 57 and 58)
- Cross-check Member Set: .claude/state/, .codex/state/
- Cross-check Count: 2
- Member-set Comparison: primary and cross-check member sets are equal (identical two members)

Claim B. Supporting count for the F-507-2 directory list: gitignored `.claude/` subtrees anchored in repository `.gitignore` files. The proposed prefix list is this family minus `agent-memory`, which is published by design (§4.2), giving 2.

- Numeric spec.md acceptance criterion: repository .gitignore files declare 3 .claude subtrees, of which 2 are excluded by prefix
- Complete Family: .claude/worktrees, .claude/agent-memory, .claude/state
- Exhaustive Search Scope: all .gitignore files in the entire repository tree (Glob `**/.gitignore` found only the root file)
- Inclusion Rules: non-comment, non-negation .gitignore lines whose pattern begins with .claude/
- Exclusion Rules: negation lines (`!`), comments, and generic patterns not anchored at .claude/
- Primary Search Strategy or Query Expression: full Read of the root .gitignore (73 lines) and manual enumeration of lines naming .claude/worktrees, .claude/agent-memory, .claude/state
- Primary Member Set: .claude/worktrees, .claude/agent-memory, .claude/state
- Primary Count: 3
- Cross-check Search Strategy or Query Expression: grep regex `^[^#!]*\.claude/?[a-z-]+` with glob `**/.gitignore` across the repository, hits at .gitignore:23 (.claude/worktrees), :69 (.claude/agent-memory), :70 (.claude/state)
- Cross-check Member Set: .claude/worktrees, .claude/agent-memory, .claude/state
- Cross-check Count: 3
- Member-set Comparison: primary and cross-check member sets are equal; independently, the test-side set LOCAL_ONLY_CLAUDE_SUBDIRS (claude_payload_scope_test_support.py:27-29) also matches these three names

Derived value: the prefix list has 2 members (`.claude/state`, `.claude/worktrees`) = family of 3 minus `.claude/agent-memory`. The exclusion of `.claude/agent-memory` is a design decision with evidence in §4.2, not a search result.

## Testing Implications

- Regression first. Each new test fails before the fix:
  - F-507-2: seeding `/repo/.claude/state/x.json` and `/repo/.claude/worktrees/wt/.claude/settings.json` currently results in destination writes, because `RecordingFileSystem.list_files` returns them and no filter drops them.
  - F-507-1: the delivery test finds no `/dest/.gitignore`.
  - The pure-merge and parity tests import the new module inside the test body. They then fail with `ModuleNotFoundError` instead of a collection error, following `test_push_down_claude_parity.py:11-13`.
- All tests use in-memory filesystems. No temporary files (repository policy). The fixture is read-only from the repository.
- Scenario coverage for the merge:
  - positive: absent, append, replace
  - idempotence and fixed point
  - edge cases: no trailing newline, CRLF, lone CR, blank-only input, unterminated BEGIN, END before BEGIN, duplicate entries outside the block
- Scenario coverage for delivery: unscoped, pack-scoped, second publish with no write, manifest skip `absent`/`present`, and a write through the raw `fs` (not blocked by the exclusion guard).
- Scenario coverage for F-507-2: excluded subtrees; lookalikes retained (`.claude/statement.md`, `.claude/worktrees-notes.md`, `.claude/hooks/state/x.ps1`); general-scope agent memory still published; paths outside the source root pass through.
- Coverage: at least 85% line and at least 75% branch on changed and new modules. Baseline and post-change coverage artifacts go under the feature `evidence/` tree.

## Automation Feasibility

The fix, tests, and toolchain runs need no human interaction. Every test is hermetic and in-memory. The toolchain commands are non-interactive. No credentials, external services, or manual verification steps are required. The only human-facing inputs are the scope decisions under Unknowns, which the spec author can settle in `spec.md` before execution.

## Unknowns and open decisions

1. Commit history on the affected files was not inspected (`git log` unavailable in this session). The conclusion that neither defect is fixed rests on reading the current production modules (§2) and the open state of #790 (WebFetch).
2. Current per-file coverage of `claude-filesystem-adapter.ts` is unknown. Adding a jest threshold entry could fail if existing coverage is below 85/75, independent of this change. Measure at baseline.
3. Agent-memory source divergence (§4.2): Python reads the local gitignored `.claude/agent-memory/` while TypeScript reads the bundle copy. Whether to align this (for example by reading agent memory from the bundle in the Python CLI) is a scope decision. Recommend treating it as out of scope for #790 and recording it as a follow-up candidate.
4. CRLF up-to-date case (Behavior Semantics): recommend accepting it as a documented limitation rather than extending the shared `PushDownFileSystem` protocol.
5. Whether `.claude/settings.local.json` is ignored through a global or user excludes file is unknown. It is already excluded explicitly (`push_down_claude_customizations.py:149-152`), so this does not affect the fix.
6. Whether `Path.rglob` follows directory symlinks or junctions inside `.claude/worktrees` on the host was not verified. The prefix filter works on the enumerated paths regardless, but `p.resolve()` (`push_down_claude_filesystem.py:444`, `:288`) on a junction target outside the source root returns `None` from `_source_relative_posix`, and such paths would pass through the prefix predicate. Tests should seed regular paths only. Junction behavior should be recorded as unverified.

## Rejected alternatives (summary)

- Honoring `.gitignore` (pattern library or `git check-ignore`): adds a dependency or subprocess, is non-deterministic in unit tests, and would drop intended general-memory publication (§4.5).
- Filtering in `RealPushDownFileSystem`: shared by three publishers, which would widen the blast radius (§4.4).
- Extending `EXCLUDED_RELATIVE_PATHS` with directory semantics: overloads an exact-path parameter, and its host file is at the line cap (§4.4, §6).
- Adding a `.gitignore` case to the exclusion plan corpus: the gitignore skip is not produced by `plan_exclusions`, and the change would alter pinned corpus counts on both sides (§3.1).
