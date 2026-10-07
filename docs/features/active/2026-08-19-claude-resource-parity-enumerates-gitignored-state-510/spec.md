# 2026-08-19-claude-resource-parity-enumerates-gitignored-state (Spec)

- **Issue:** #510
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T14-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug

## Context
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates the repository `.claude/**` tree with `Path.rglob("*")` and does not read `.gitignore`. Gitignored, session-scoped state files under `.claude/state/` are therefore enumerated and reported as missing from the bundle, failing the suite for a reason unrelated to the mirrors it exists to verify.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- Data source or fixture: `.claude/state/` runtime artifacts written by the batch-budget hooks

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. A green suite fails spuriously once any hook-triggering write occurs in a session. The message names a file that is correctly absent from the bundle, which misdirects diagnosis toward the mirror work actually under test. The state file is session-scoped runtime state and is gitignored; it is never distributable, so including it in a distribution-parity assertion is incorrect on its own terms.

CI is unaffected: no workflow under `.github/workflows` invokes the Claude PreToolUse hooks, so the artifact is never created on a runner. This is a local-workstation failure only.

## Repro & Evidence
Steps to Reproduce:
1. In a clean worktree, confirm the suite passes.
2. Cause the batch-budget hook to create its state file, by writing a PowerShell file through the Write or Edit tool, or by writing enough Python files to trip the Python budget. Confirm the file exists with `ls .claude/state/`.
3. Re-run the suite. It now fails, naming the state file as missing from the bundle.
4. Delete the state file and re-run. It passes again.

Expected:
The walk considers only files that are actually part of the distributed payload. Session-local and machine-local runtime state, which is gitignored and never distributable, is excluded exactly as `.claude/settings.local.json` and `.claude/agent-memory/**` already are.

Actual:
```text
AssertionError: Repo file missing from bundle: .claude/state/python-batch-budget.default.json
```

The walk excludes only `.claude/settings.local.json` and `.claude/agent-memory/**`. `.claude/state/` is gitignored at `.gitignore` line 68 but is not excluded from the walk. Observed 2026-08-22 during issue #500 orchestration; deleting the artifact returned `10 passed`.

## Scope & Non-Goals
- In scope: the test-side fix recommended by the research (`research/research.2026-09-29T14-15.md`, section 4, option (a)). Specifically:
  - Create `tests/scripts/dev_tools/claude_payload_scope_test_support.py`, a shared pure helper.
  - Edit `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` to use the helper and remove `_is_agent_memory_path` and its constant.
  - Edit `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` so `EXCLUDED_CLAUDE_SUBDIRS` is sourced from the shared helper (drift guard by import).
  - Create `tests/scripts/dev_tools/test_claude_payload_scope_support.py` with pure-function tests.
- Out of scope / non-goals: see "Out of Scope and Follow-up" below. No production file is changed by this work item.
- Explicitly excluded systems, integrations, or datasets: `scripts/dev_tools/push_down_claude_*.py`, `extensions/drm-copilot/src/lib/push-down/*`, `.gitignore`, and the bundle under `extensions/drm-copilot/resources/claude-customizations/`.

## Root Cause Analysis
The walk was written with two explicit exclusions and no general rule, so each new gitignored runtime path under `.claude/` reintroduces the failure.

The trigger has widened since the entry was first written. It originally reproduced only through `.claude/hooks/enforce-powershell-batch-budget.ps1`, which creates `.claude/state/powershell-batch-budget.<session_id>.json`. Issue #501 added an entry-point seam to the Python batch-budget hook, which creates `.claude/state/python-batch-budget.default.json`, so a Python-only session reproduces it too.

Research also shows `.claude/worktrees/**` is gitignored (`.gitignore` line 21) and, in the primary checkout, holds full repository copies that the same `rglob` would enumerate. The three local-only subdirectories are `agent-memory` (line 67), `state` (line 68), and `worktrees` (line 21). `.claude/settings.local.json` is not in `.gitignore` and is excluded by production code, so it is handled as an explicit file entry.

## Proposed Fix

### Design summary (what changes where):
Adopt research option (a): a static, part-level path predicate in a shared pure test-support module, applied to the repo-side enumeration only.

- `git ls-files` (option b) is rejected: it spawns an external process, is index-dependent, and can mask an untracked but genuinely missing distributable file.
- `.gitignore` parsing (option c) is rejected: it requires reimplementing gitignore semantics, does not cover `settings.local.json`, and could hide a missing tracked file behind a broad pattern.

### Boundaries and invariants to preserve:
- The assertion `Repo file missing from bundle: <path>` and the byte comparison are unchanged. Only the input set is narrowed to distributable paths.
- The bundle-side enumeration is not filtered; the bundle is deliberately allowed to contain scoped `agent-memory` files.
- Test files stay at or below 500 lines. No temporary files, subprocesses, or wall-clock use in tests.

### Dependencies or blocked work:
None. Research citations are verified against this worktree as of 2026-09-29.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `tests/scripts/dev_tools/claude_payload_scope_test_support.py`.
- New: `tests/scripts/dev_tools/test_claude_payload_scope_support.py`.
- Edit: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (replace inline filter at research lines 130-134; delete `_is_agent_memory_path` and `AGENT_MEMORY_RELATIVE_ROOT`; update docstrings).
- Edit: `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (lines 35-37: import the shared subdirectory set and bind `EXCLUDED_CLAUDE_SUBDIRS` to it, keeping the existing name so its usages at lines 322-326 are untouched).

#### Functions/classes/CLI commands impacted:
Helper module public surface:
- `LOCAL_ONLY_CLAUDE_SUBDIRS: frozenset[str] = frozenset({"agent-memory", "state", "worktrees"})`
- `LOCAL_ONLY_CLAUDE_FILES: frozenset[Path] = frozenset({Path(".claude/settings.local.json")})`
- `is_local_runtime_path(relative_path: Path) -> bool`: True when `relative_path.parts[:2]` is `(".claude", <member of LOCAL_ONLY_CLAUDE_SUBDIRS>)`, or the path is a member of `LOCAL_ONLY_CLAUDE_FILES`. Matching is on path parts, not substrings, so `.claude/statement.md` and `.claude/hooks/state/x.ps1` are retained.
- `filter_distributable_claude_paths(paths: Iterable[Path]) -> list[Path]`: returns the input paths, in order, for which `is_local_runtime_path` is False.

Test impacted: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` now calls `filter_distributable_claude_paths(list_scoped_files(REPO_ROOT))`.

#### Data flow and validation changes:
Repo enumeration -> `filter_distributable_claude_paths` -> existing missing-file and byte-equality loop. No other data flow changes.

#### Error handling and logging updates:
None. The existing assertion messages are preserved.

#### Rollback/feature-flag considerations (if applicable):
Not applicable; test-only change, revertible by reverting the commit.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Inputs are repository-relative `Path` objects. Output is a `list[Path]` preserving input order.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
`EXCLUDED_CLAUDE_SUBDIRS` remains importable from `test_claude_rules_frontmatter.py` with the same value.

#### Performance constraints (latency/throughput/memory):
Predicate is O(1) per path; no added I/O.

## Assumptions, Constraints, Dependencies
- Assumptions: relative paths passed to the helper are rooted at the repository root and begin with `.claude` (as produced by `list_scoped_files`). Separator handling relies on `Path.parts`, so it is platform independent.
- Constraints: 500-line limit per test file; no temporary files or external processes in unit tests (`.claude/rules/general-unit-test.md`); tests under `tests/` mirror source layout.
- External dependencies: none beyond existing pytest, black, ruff, pyright.
- Drift-guard decision: the import approach was chosen because the research (section 4, step 3) identifies no blocking reason, the import lowers the line count of the frontmatter test file, and both modules are under `tests.scripts.dev_tools`. A supplementary equality assertion in the new test file guards against the import being reverted to an independent literal.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none.

## Out of Scope and Follow-up
Separate production defect, not fixed here and requiring its own issue (to be opened after this work item; no issue number exists at authoring time):

- The Python push-down CLI passes `source_root=resolved_repo_root` (`scripts/dev_tools/push_down_claude_customizations.py:392`; `push_down_copilot_customizations.py:496`), so `effective_source` is the repository root (`push_down_copilot_customizations.py:168`).
- Enumeration uses `fs.list_files(effective_source / ".claude")` (`push_down_copilot_customizations.py:172-174`), implemented by `RealPushDownFileSystem.list_files` with `root.rglob("*")` (`push_down_copilot_customizations_filesystem.py:104-107`).
- The wrapping `ExcludingFileSystem.list_files` (`push_down_claude_filesystem.py:431-448`) applies exact-path exclusion (`EXCLUDED_RELATIVE_PATHS`, `push_down_claude_customizations.py:102`, exact files only), the pack filter, the agent-memory scope filter (`push_down_claude_filesystem.py:336-351`), and memory mode. None filters `.claude/state/` or `.claude/worktrees/`.
- Consequence (code-reading finding, not exercised end to end): a CLI push-down from a checkout containing `.claude/state/*.json` or `.claude/worktrees/**` enumerates and copies those files to the destination.
- The TypeScript counterpart is `claude-filesystem-adapter.ts:266-270` (`listFiles`), with `EXCLUDED_RELATIVE_PATHS = [".claude/settings.local.json"]` at `claude-customizations.ts:73-75`. The extension path pushes from the bundle (`push-down-service-call.ts:171`), which contains no `state/` or `worktrees/` files, so it is affected only if such files are copied into the bundle.
- Suggested direction for the future issue (not a specification here): a directory-prefix exclusion for `.claude/state` and `.claude/worktrees`, mirrored in the TS adapter, with unit tests over the in-memory `MemoryFile` filesystem in `tests/scripts/dev_tools/test_push_down_claude_customizations.py`.

Also unresolved: the Python pack-manifest completeness suite was not located in research, so the issue checklist item on its exposure is unverified. The TypeScript suite (`claude-pack-manifest-completeness.test.ts`) enumerates named subdirectories only and is not exposed. Whether `.claude/settings.local.json` is ignored at user level was not verified.

## Test Strategy
Pure-function tests over literal `Path` lists in `tests/scripts/dev_tools/test_claude_payload_scope_support.py`. No disk writes, temporary files, or subprocesses.

- Regression tests to add or update: the new test file below; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` continues to run against the real tree and must pass with and without a local `.claude/state/` directory.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - `test_state_file_from_issue_report_is_excluded`
  - `test_nested_state_paths_are_excluded`
  - `test_worktrees_paths_are_excluded`
  - `test_agent_memory_paths_remain_excluded`
  - `test_settings_local_json_remains_excluded`
  - `test_lookalike_and_tracked_paths_are_retained` (parametrized: `.claude/settings.json`, `.claude/rules/python.md`, `.claude/statement.md`, `.claude/hooks/state/x.ps1`, `.claude/settings.local.json.bak`)
  - `test_filter_preserves_order_and_returns_list`
  - `test_missing_tracked_file_is_still_reported`
  - `test_subdirs_match_frontmatter_excluded_subdirs`
- Edge cases and negative scenarios: single-part path `.claude`; empty input list; `.claude/state` as a bare path with no child.
- Error handling and logging verification: not applicable; the helper raises no errors.
- Coverage impact and targets for changed lines/modules: the helper resides under `tests/`, which `pyproject.toml` `[tool.coverage.run]` excludes through `source = ["src", "scripts/dev_tools"]` and `omit = ["tests/*", "*/tests/*", ...]`. A default run therefore reports nothing for the helper. Measurement uses an override rc file (see Acceptance Criteria) that removes the `omit` entries. No production module changes, so there is no production coverage delta.
- Toolchain commands to run (format -> lint -> type-check -> test): `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, then the pytest command below.
- Manual validation steps (if required): optional local reproduction, by allowing a batch-budget hook to create `.claude/state/`, then running the contracts test; do not create the state file from a test.

## Acceptance Criteria
- [x] The reported path `.claude/state/python-batch-budget.default.json` is excluded: `poetry run pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_state_file_from_issue_report_is_excluded -q` passes.
- [x] Nested paths under `.claude/state/` and `.claude/worktrees/` (for example `.claude/state/a/b/c.json`, `.claude/worktrees/x/.claude/rules/y.md`) are excluded: `test_nested_state_paths_are_excluded` and `test_worktrees_paths_are_excluded` in `tests/scripts/dev_tools/test_claude_payload_scope_support.py` pass.
- [x] `.claude/agent-memory/**` and `.claude/settings.local.json` remain excluded: `test_agent_memory_paths_remain_excluded` and `test_settings_local_json_remains_excluded` in `tests/scripts/dev_tools/test_claude_payload_scope_support.py` pass.
- [x] Lookalike and tracked paths are retained (`.claude/statement.md`, `.claude/hooks/state/x.ps1`, `.claude/settings.json`, `.claude/rules/python.md`): `test_lookalike_and_tracked_paths_are_retained` (all parametrized cases) passes.
- [ ] A genuinely missing tracked `.claude` file is still reported and the assertion is not weakened: `test_missing_tracked_file_is_still_reported` passes; and in `test_push_down_claude_resource_contracts.py` the `Repo file missing from bundle` assertion and byte-comparison loop are unchanged (verified by `git diff` showing only filter, constant, and docstring edits in that region).
- [ ] `test_bundled_claude_payload_contains_all_repo_runtime_contracts` uses `filter_distributable_claude_paths`, and `_is_agent_memory_path` and `AGENT_MEMORY_RELATIVE_ROOT` no longer exist: `git grep -n "_is_agent_memory_path\|AGENT_MEMORY_RELATIVE_ROOT" -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` returns no match, and the test passes.
- [ ] Drift guard: `EXCLUDED_CLAUDE_SUBDIRS` in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` is imported from (bound to) `LOCAL_ONLY_CLAUDE_SUBDIRS`, and `tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_subdirs_match_frontmatter_excluded_subdirs` passes.
- [ ] All created and modified test files are at or under 500 lines: `wc -l` (or an equivalent line count) on `tests/scripts/dev_tools/claude_payload_scope_test_support.py`, `tests/scripts/dev_tools/test_claude_payload_scope_support.py`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, and `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` reports <= 500 for each.
- [ ] `poetry run black --check .`, `poetry run ruff check .`, and `poetry run pyright` report zero errors.
- [ ] The three affected test files pass: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_payload_scope_support.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q` exits 0.
- [ ] Coverage of the new helper meets thresholds (line >= 85%, branch >= 75%). Because `pyproject.toml` omits `tests/*`, measurement uses an override rc file stored at `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/coverage/coveragerc-helper.ini` containing `[run]` with `branch = True` and no `omit` entry: `poetry run pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py --cov=tests.scripts.dev_tools.claude_payload_scope_test_support --cov-branch --cov-config=<that rc file> --cov-report=term-missing` reports the helper module line coverage >= 85% and branch coverage >= 75%. The dotted module form is required; a `.py` path form measures nothing.
- [ ] No production file is modified: `git diff --name-only main...HEAD` lists no path under `scripts/`, `src/`, or `extensions/`.
- [ ] The out-of-scope production defect (Python CLI and TS adapter copying `.claude/state` and `.claude/worktrees`) is recorded in "Out of Scope and Follow-up" with its research citations, and a separate follow-up issue is requested in the completion report.

## Risks & Mitigations
- Technical or operational risks:
  - A new gitignored `.claude/<subdir>` runtime path added later is not covered by the static set. Mitigation: the shared constant is the single place to extend, and the drift guard keeps the frontmatter test aligned. The optional research hardening (a read-only `.gitignore` string check that each `.claude/<subdir>` entry has a set member) is deferred and may be filed with the follow-up.
  - Excluding `.claude/hooks/state/**` by mistake would hide a tracked file. Mitigation: predicate matches `parts[:2]` only, verified by `test_lookalike_and_tracked_paths_are_retained`.
  - Coverage measurement of files under `tests/` is not part of the default configuration. Mitigation: explicit rc override in the verification command; the default configuration is not modified.
- Mitigations and rollbacks: revert the commit; no runtime or data impact.

## Rollout & Follow-up
- Release/rollout steps: none; test-only change merged through the normal PR path.
- Post-fix monitoring or clean-up tasks: open a separate issue for the production defect described above; check the Python pack-manifest completeness suite for unfiltered-walk exposure.
- Links: issue #510 (https://github.com/drmoisan/drm-copilot/issues/510), `issue.md`, `research/research.2026-09-29T14-15.md`.
