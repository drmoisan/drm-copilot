# Research: claude resource parity enumerates gitignored state (Issue #510)

Date: 2026-09-29. All citations verified against the worktree tree on this date. No production or test file was modified.

## 1. Enumeration and filtering in the parity test

File: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (501 lines per the reader; policy limit is 500, so the file is at the limit and must not grow).

- `SCOPED_ROOTS = (Path(".claude"),)` at line 25.
- `list_scoped_files(root)` at lines 51-60: `scoped_path.rglob("*")` at line 57, `is_file()` filter at line 58, sorted relative paths returned. No gitignore awareness.
- `_is_agent_memory_path` at lines 88-115 (prefix `.claude/agent-memory`, constant at line 85).
- Repo-side filter, lines 130-134: `list_scoped_files(REPO_ROOT)` filtered by `f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)`. Bundle-side call at line 127: `list_scoped_files(BUNDLED_ROOT)`.
- The assertion loop at lines 136-143 fails with `Repo file missing from bundle: <path>` for any repo file absent from the bundle, then compares bytes.

All callers of `list_scoped_files` in this file:

| Line | Test | Root | Effect of a change to the function |
|---|---|---|---|
| 75 | `test_bundled_claude_payload_contains_required_runtime_files` | bundle | Bundle-side only; anchor files present |
| 127 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | bundle | Bundle side of the failing test |
| 132 | same test | repo | The defect site |
| 191 | `test_pack_manifests_are_outside_the_parity_scope` | bundle | Negative assertion; a stricter filter cannot cause failure |
| 219 | `test_bundled_claude_payload_excludes_variant_subtree_from_parity` | bundle | Negative assertion; same |

Sibling exposure: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:112-122` defines its own `list_scoped_files` and already filters `.codex/state` through `is_publishable_runtime_path` (lines 106-109, `relative_path.parts[:2] != (".codex", "state")`). This is direct in-repo precedent for a path predicate applied inside the enumerator. The Claude test has no equivalent.

## 2. Gitignored paths under `.claude/`

`.gitignore` (verified by grep; no `.claude/.gitignore` exists):

- Line 21: `.claude/worktrees`
- Line 67: `.claude/agent-memory`
- Line 68: `.claude/state/`

`.claude/settings.local.json` is NOT listed in the repository `.gitignore` (grep for `settings\.local` returned no match). It is excluded from distribution by production code (see section 3), and may be ignored through a user-level or `.git/info/exclude` rule, which was not verified. Any `.gitignore`-parsing approach would therefore not exclude it on its own.

In the primary checkout `.claude/worktrees/` holds full repository copies, so the current `rglob` also walks those (in this worktree it does not exist locally). The `.claude/worktrees/**` files would be reported missing from the bundle just as state files are.

Bundle contents: `extensions/drm-copilot/resources/claude-customizations/.claude/` contains no `state/` or `worktrees/` files (Glob returned none). It does contain `agent-memory/` (for example `.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md`); the root `.gitignore` entry is anchored at `.claude/agent-memory`, so the bundle copy is tracked. The bundle-side agent-memory files are distributed by scope, which is why the existing test exempts that subtree from the mirror comparison. No gitignored `.claude/` content legitimately belongs in the bundle other than these scoped agent memories.

Local state at time of research: `.claude/state/` does not exist in this worktree (Glob returned none), so the defect cannot be reproduced here without triggering a batch-budget hook.

## 3. Existing exclusion constants and production behavior

Precedent constants and helpers:

- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:35-37`: `EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory", "worktrees", "state"})`, applied at lines 322-326 on `candidate.relative_to(CLAUDE_ROOT).parts[0]`. This is a static exclusion set of the three gitignored subdirectories and is the closest precedent. It is a module-level constant in a test file, not shared.
- `scripts/dev_tools/push_down_claude_filesystem.py:60`: `AGENT_MEMORY_RELATIVE_ROOT`; `scripts/dev_tools/push_down_claude_customizations.py:102`: `EXCLUDED_RELATIVE_PATHS = (Path(".claude/settings.local.json"),)` (exact file only).
- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:73-75`: TS `EXCLUDED_RELATIVE_PATHS = [".claude/settings.local.json"]`.
- `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts:57-58`: pushes `.claude/state/` and `.codex/state/` into the destination's `.gitignore`, confirming state is treated as non-distributable runtime output.
- `tests/scripts/dev_tools/push_down_handoff_test_support.py` (read lines 1-40) holds handoff assertions only; it has no exclusion constant.
- The TS pack-manifest completeness test (`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`) enumerates named subdirectories (agents, hooks, skills, rules via `readdirSync` at lines 82-111, and `lib` and `config` via `walkFilesRelative`, lines 120 and 164). It does not walk `.claude/state` or `.claude/worktrees`, so it is not exposed to this defect. The Python pack-manifest completeness suite was not located in this pass; the issue's checklist item on it remains unverified.

Production defect finding (in scope, reported per instruction):

- The repository CLI passes `source_root=resolved_repo_root` (`push_down_claude_customizations.py:392`, and `push_down_copilot_customizations.py:496`), so `effective_source` is the repository root (`push_down_copilot_customizations.py:168`).
- Enumeration is `fs.list_files(effective_source / ".claude")` (`push_down_copilot_customizations.py:172-174`), which is `RealPushDownFileSystem.list_files` doing `root.rglob("*")` (`push_down_copilot_customizations_filesystem.py:104-107`).
- The wrapping `ExcludingFileSystem.list_files` (`push_down_claude_filesystem.py:431-448`) applies four filters: exact-path exclusion (`self._excluded` is a frozenset of resolved exact files, lines 272-274), pack filter, agent-memory scope filter (only `.claude/agent-memory`, lines 336-351), and memory mode. None filters `.claude/state/` or `.claude/worktrees/`.
- Consequence: when the Python CLI push-down runs from a checkout that has `.claude/state/*.json` or `.claude/worktrees/**`, those files are enumerated and copied to the destination. This is a verified code-reading finding; it was not exercised end to end. The pack filter (`_is_pack_included`) is inert when no `--packs` is supplied (lines 303-306). The extension path pushes from the bundle (`push-down-service-call.ts:171`, `resources/claude-customizations`), which is clean, so it is unaffected unless state is copied into the bundle.
- No script that copies the repo `.claude` into the bundle was found (Grep for `claude-customizations` in `scripts/` `.sh/.ps1/.mjs/.js` returned nothing; only the Python push-down, `skill_bundle_contract*.py`, and pack-selection modules reference the path). The bundle appears to be maintained by commit, so state reaches it only through manual copying.
- Recommendation for the production finding: treat as a separate, adjacent fix rather than folding into the test fix (the issue title and steps concern the test only). If the orchestrator elects to fix it, add a directory-prefix exclusion for `.claude/state` and `.claude/worktrees` in `ExcludingFileSystem` (exact-path `EXCLUDED_RELATIVE_PATHS` cannot express a subtree), mirror it in the TS adapter (`claude-filesystem-adapter.ts:266-270` `listFiles`), and add unit tests using the in-memory `MemoryFile` filesystem already used in `tests/scripts/dev_tools/test_push_down_claude_customizations.py`. Production coverage would then apply (see section 5).

## 4. Fix options

Repository policy constraints: no temp files and no external processes in unit tests (`.claude/rules/general-unit-test.md`); 500-line file limit (`general-code-change.md`); test files under `tests/` mirroring source.

| Option | Assessment |
|---|---|
| (a) Static exclusion set | Pure function over relative paths, deterministic, no I/O beyond the existing walk, matches the frontmatter test precedent and the codex `is_publishable_runtime_path` precedent. Weakness: each new gitignored runtime path needs a set entry (the issue's stated root cause), mitigated by a drift guard test (below). |
| (b) `git ls-files` | Spawns an external process, which the unit test policy forbids; depends on git state and index (an untracked, not-yet-added distributable file would be silently omitted, masking a genuinely missing file); fails in exported trees. Rejected. |
| (c) Parse `.gitignore` | Requires reimplementing gitignore semantics (anchoring, negation such as lines 63-66 for bundle paths, trailing slash), reads a file the test does not otherwise control, and would not cover `settings.local.json` (not in `.gitignore`). Could mask a missing tracked file if a broad ignore pattern is added. Rejected. |

Recommendation: option (a), implemented as a shared pure helper.

Files (repository-relative):

1. Create `tests/scripts/dev_tools/claude_payload_scope_test_support.py` (sibling test-support module, consistent with existing `*_test_support.py` files such as `push_down_handoff_test_support.py`). Contents:
   - `LOCAL_ONLY_CLAUDE_SUBDIRS: frozenset[str] = frozenset({"agent-memory", "worktrees", "state"})` with a comment that these are gitignored, machine-local subtrees (`.gitignore` lines 21, 67, 68).
   - `LOCAL_ONLY_CLAUDE_FILES: frozenset[Path] = frozenset({Path(".claude/settings.local.json")})`.
   - `is_local_runtime_path(relative_path: Path) -> bool`: True when `relative_path.parts[:2]` is `(".claude", <subdir in LOCAL_ONLY_CLAUDE_SUBDIRS>)` or the path is in the files set. Using the part-level prefix covers nested paths under `.claude/state/` (issue checklist item) and avoids the substring false positives of string matching (for example `.claude/statement.md`).
   - `filter_distributable_claude_paths(paths: Iterable[Path]) -> list[Path]`.
2. Edit `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`: replace the inline filter at lines 130-134 with a call to `filter_distributable_claude_paths(list_scoped_files(REPO_ROOT))`, and delete `_is_agent_memory_path` and `AGENT_MEMORY_RELATIVE_ROOT` (lines 85-115, about 31 lines) if no other use remains (Grep showed uses only at lines 85-133 of this file). Update the docstring at lines 119-125 and module docstring lines 5-6. Net line count decreases, keeping the file under 500. Apply the same predicate to the bundle-side call is NOT required (the bundle is deliberately allowed to contain agent-memory).
3. Optionally edit `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:35-37` to import `LOCAL_ONLY_CLAUDE_SUBDIRS` instead of its own constant, removing the duplicate. Low priority; keep as a follow-up if it risks scope growth. Note that file's docstring says it is also outside `general-*` scope of this issue.
4. Create `tests/scripts/dev_tools/test_claude_payload_scope_support.py` (tests for the helper; file location mirrors the support module per the tests layout rule). Pure-function tests with literal `Path` lists, no disk writes:
   - `.claude/state/python-batch-budget.default.json` is excluded (the reported case).
   - Nested `.claude/state/a/b/c.json` and `.claude/worktrees/x/.claude/rules/y.md` are excluded.
   - `.claude/agent-memory/orchestrator/m.md` and `.claude/settings.local.json` remain excluded.
   - Negative controls: `.claude/settings.json`, `.claude/rules/python.md`, `.claude/statement.md`, and `.claude/hooks/state/x.ps1` are retained (a tracked file under a non-top-level `state` directory must still be compared).
   - The assertion still fails for a genuinely missing tracked file: build `repo = [Path(".claude/rules/new.md"), Path(".claude/state/x.json")]`, `bundle = []`, and assert the filtered list equals `[Path(".claude/rules/new.md")]` so the missing-file check would still trip.
   - Drift guard: assert that `LOCAL_ONLY_CLAUDE_SUBDIRS` equals `EXCLUDED_CLAUDE_SUBDIRS` from `test_claude_rules_frontmatter.py` if step 3 is not done, so the two lists cannot diverge silently. Importing across test modules is acceptable here because both are under `tests.scripts.dev_tools`; if step 3 is done this guard is unnecessary.
5. Optional hardening (recommended): a test that parses `.gitignore` text is rejected by option (c), but a lightweight guard can read the committed `.gitignore` as a string (read-only, not a temp file) and assert each `.claude/<subdir>` gitignore entry has a matching member in `LOCAL_ONLY_CLAUDE_SUBDIRS`. This addresses the "new gitignored path reintroduces failure" cause without gitignore semantics. Treat as optional; it adds a repository-file read to a unit test, which is permitted (only temp files and external services are prohibited).

## 5. Verification commands and caveats

Commands (Poetry, from the worktree root; source `.claude/rules/python.md:13-16`):

- `poetry run black .`
- `poetry run ruff check .`
- `poetry run pyright`
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_payload_scope_support.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q`
- Full loop: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (`--cov-report=lcov:artifacts/python/lcov.info` is in `addopts`, `pyproject.toml:115`).
- For a scoped coverage run use dotted-module form only, for example `--cov=scripts.dev_tools.push_down_claude_filesystem`, never `--cov=<path>.py` (a path form measures nothing; see memory note on gates that cannot fail). The test-only fix touches no production module, so there is no production-line coverage delta; the new helper lives under `tests/` and is exercised by its own tests. If the production fix in section 3 is chosen, the dotted-module targets are `scripts.dev_tools.push_down_claude_filesystem` and `scripts.dev_tools.push_down_claude_customizations`.
- Line count check on the edited test file must stay at or below 500 lines.

Environment caveats:

- CI is unaffected (issue text; not re-verified in this pass). The defect is local: `.claude/state/` exists only after a batch-budget hook writes it, and `.claude/worktrees/` only in the primary checkout.
- To exercise the fix locally end to end, a state file must exist (created by a PowerShell or Python write that trips the hook). Do not create it manually in the repository from a test; use the pure-function tests as proof, and treat a manual local reproduction as optional evidence.
- The repo-side walk uses `REPO_ROOT` derived from `__file__` (`parents[3]`, line 21), so in an agent worktree it walks that worktree's `.claude`, not the primary checkout's.
- Whether `.claude/settings.local.json` is ignored at user level was not verified.

## Rejected alternatives

- `git ls-files` enumeration: external process, index-dependent, can mask untracked missing files.
- `.gitignore` parsing: reimplements gitignore semantics, does not cover `settings.local.json`, and could hide a missing tracked file behind a future broad pattern.
