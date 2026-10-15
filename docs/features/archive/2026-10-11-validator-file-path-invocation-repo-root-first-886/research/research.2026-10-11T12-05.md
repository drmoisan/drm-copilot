# Research — Validator file-path invocation must put the repository root first (#886)

- **Issue:** #886 (bug, minor-audit)
- **Branch:** `bug/validator-file-path-invocation-repo-root-first-886`
- **Researched:** 2026-10-11T12-05
- **Scope:** code fix and tests only. The shared `drm_copilot.pth` was already corrected by the operator. Policy files under `.claude/rules/` and `.github/instructions/` are not edited by this item.

All file:line citations below were re-derived against the current worktree tree with Read and Grep. No shell tool was available to this research session, so no command was executed (see section 6).

## 1. Current bootstrap code and lint treatment

### 1.1 Bootstrap in the dispatcher

`scripts/dev_tools/validate_orchestration_artifacts.py`:

- Lines 9-14: `from __future__ import annotations`, `import argparse`, `import re`, `import sys`, `from pathlib import Path`.
- Line 16: `# File-path invocation has no package context; make the repo root importable.`
- Line 17: `sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []`
- Lines 19-46: eleven `from scripts.dev_tools... import ...` statements that depend on line 17.
- No `# noqa` is present on line 17 or on any of the following imports.
- Line 460: `def main(argv: list[str] | None = None) -> int:`; line 497: `if __name__ == "__main__":`.
- The file is **498 lines** (Grep count of `$`). The repository limit is 500 lines, so the fix has a budget of at most two additional lines in this file.

Behavior: `parents[2]` of `scripts/dev_tools/validate_orchestration_artifacts.py` is the repository root. When the file runs by path, `__package__` is empty or `None`, so the root is **appended** after the standard library and site-packages entries. A site-packages `.pth` entry that names another checkout containing a regular `scripts` package therefore resolves `scripts` first. Under `python -m scripts.dev_tools.validate_orchestration_artifacts`, `__package__ == "scripts.dev_tools"`, so the expression appends `[]` (no-op).

### 1.2 Ruff configuration

`pyproject.toml`:

- Lines 88-91: `[tool.ruff]`, `line-length = 88`, `target-version = "py310"`.
- Lines 93-103: `[tool.ruff.lint] select = ["E", "F", "I", "B", "UP", "S", "TID", "TCH"]`. `E` includes E402 (module-import-not-at-top-of-file).
- Lines 105-112: `[tool.ruff.lint.per-file-ignores]` contains only `tests/**/*` (S101), `src/lexile_corpus_tuner/cli.py` (B008), and four test files (S311). There is **no E402 entry** for the dispatcher.
- Lines 84-86: Black `line-length = 88`.
- Lines 143-163: Pyright `typeCheckingMode = "strict"`, includes `scripts`, `src`, `tests`.

### 1.3 Why line 17 does not trigger E402 today

Verified against the Ruff source (`crates/ruff_python_semantic/src/analyze/imports.rs`, function `is_sys_path_modification`, fetched 2026-10-11). A statement before imports is exempt from E402 only when it is one of:

- `Stmt::Expr` whose value is a **direct call** to `sys.path.append|insert|extend|remove|pop|clear|reverse|sort`; or
- `Stmt::AugAssign` whose target, after `map_subscript` strips any subscript, resolves to `sys.path`.

Other exemptions in the same file cover `os.environ` mutation, `matplotlib.use`, `pytest.importorskip`, and `site.addsitedir`. Consequences for the fix:

- Line 17 (`sys.path += ...`) is an `AugAssign` on `sys.path`, so it is exempt.
- `if not __package__: sys.path.insert(0, root)` is a `Stmt::If`, which is **not** exempt; every following import would raise E402.
- `sys.path[:0] = [...]` and `sys.path.insert(0, root) if ... else None` are `Stmt::Assign` and `Stmt::Expr(IfExp)` respectively, neither exempt.
- A helper `def` placed before the imports is not exempt.
- `sys.path[:0] += [...]` is an `AugAssign` whose target is `Subscript(sys.path)`; `map_subscript` reduces it to `sys.path`, so it **is** exempt.

Suppressing E402 instead (inline `# noqa: E402` or a `per-file-ignores` entry) is not available without user approval: `.github/instructions/python-suppressions.instructions.md` lists the only pre-authorized patterns (headings at lines 29-333) and E402 is not among them; `.claude/rules/python.md` line 14 states suppressions require pre-authorization.

## 2. Inventory of `sys.path` mutation

### 2.1 Under `scripts/` (in scope)

| Path:line | Form | File-path entry script | Already prepends |
|---|---|---|---|
| `scripts/dev_tools/validate_orchestration_artifacts.py:17` | `sys.path += [...] if not __package__ else []` (append, conditional) | Yes: `if __name__ == "__main__":` at line 497; file-path form documented at `.claude/rules/orchestrator-state.md:204` and pinned by `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` | No |

This is the only file under `scripts/` that mutates `sys.path` or reads `__package__`. The seventeen `Path(__file__).resolve().parents[N]` occurrences under `scripts/` (for example `scripts/dev_tools/format_json.py:131`, `scripts/dev_tools/generate_codex_agent_variants.py:23`, `scripts/dev_tools/atomic_executor/cli.py:147`, `scripts/dev_tools/discovery/analyzer/cli.py:66`) compute data or default paths only and do not touch `sys.path`. Other entry scripts that import `from scripts...` have no bootstrap at all and are therefore module-form only; that is unchanged by this item.

### 2.2 Outside `scripts/` (out-of-scope observations only)

- `tests/conftest.py:57-61`: `_ensure_repo_root_on_sys_path()` prepends the root with `sys.path.insert(0, ...)` guarded by `if str(repo_root) not in sys.path`. Already prepends; test infrastructure only.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py:102,112,184,197`: test fixture rebinding and assertions (see section 4).
- `.claude/` (excluding `worktrees/`), `.github/`, and `extensions/` (excluding `node_modules`): no code file mutates `sys.path`. The only hit is prose at `.claude/rules/orchestrator-state.md:204` and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md:204` (section 7).
- No `.ps1`, `.sh`, `.ts`, `.js`, `.mjs`, `.cjs`, `.yml`, or `.yaml` file contains a `sys.path` mutation.
- The repository root contains no top-level `.py` module (Grep with root-anchored glob `/*.py` returned no files) and exactly one top-level regular package, `scripts/__init__.py` (Glob `*/__init__.py`). `scripts/__init__.py` is the only `scripts/__init__.py` in the tree. Prepending the root therefore shadows nothing other than the intended `scripts` package; directories without `__init__.py` (`src`, `tests`, `docs`, `config`) only contribute namespace portions, which lose to any regular package found later on the path.

## 3. Callers of the file-path form

Grep for `validate_orchestration_artifacts.py` across the tree (excluding `docs/features/**`, `artifacts/**`, `node_modules/**`) and for `validate_orchestration_artifacts` across `.claude/hooks`, `.claude/skills`, `.claude/agents`, `.github/workflows`, `.github/skills`, `.github/agents`, `.agents`, `.codex`, and `package.json`:

- **No hook, workflow, package script, or extension source invokes the script by file path.** Every skill and agent reference uses the MCP tool `validate_orchestration_artifacts` / `mcp__drm-copilot__validate_orchestration_artifacts` (for example `.claude/skills/orchestrate/SKILL.md:85`, `.claude/skills/parallel-plan/SKILL.md:491`, `.codex/agents/orchestrator.toml:190`). The MCP server implementation is a TypeScript port (`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:42`), not a subprocess of this file.
- `.claude/skills/orchestrate/SKILL.md:85` permits "the repository-local validator CLI documented in `.claude/rules/orchestrator-state.md`" as an alternative, which makes `.claude/rules/orchestrator-state.md:204` (file-path form documented) the operator-facing consumer.
- `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py:241-253` (`test_rule_documents_both_dispatcher_invocation_forms`) asserts the rule contains the literal `python scripts/dev_tools/validate_orchestration_artifacts.py`. It does not assert the word "appends", so the code change does not break it.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` is the behavioral consumer (section 4).
- Remaining hits are prose or fixtures (`.claude/rules/plan-acceptance-gates.md:4,255`, `.claude/rules/parallel-orchestration.md:13,681`, blast-radius fixtures and Pester tests that use the path as a string) and are unaffected.

## 4. Existing tests and recommended test approach

### 4.1 Current file

`tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (204 lines, from #798):

- Helpers: `resolves_to_repo_root` (54-61), `is_scripts_module` (64-67), `provides_scripts_package` (70-77, checks `<entry>/scripts/__init__.py` exists), `repo_root_entry_count` (80-83).
- `isolated_import_state()` context manager (86-115): saves `sys.path` (the list object) and every `scripts`/`scripts.*` entry of `sys.modules`; rebinds `sys.path` to a copy without entries that name the repo root or supply a regular `scripts` package; deletes the saved modules; on exit rebinds the original list, discards `scripts.*` modules imported inside the block, and restores the originals.
- `run_file_path_form` (118-124): sets `sys.argv`, runs `runpy.run_path(SCRIPT, run_name="__main__")`, returns the `SystemExit` code. `runpy.run_path` on a file does not alter `sys.path`, so the bootstrap is the only route to `scripts`.

Tests (node IDs):

- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py::test_file_path_invocation_help_exits_zero` (127-142)
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py::test_file_path_invocation_validates_committed_fixture` (145-163)
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py::test_module_invocation_leaves_sys_path_unchanged` (166-184) — guards the `python -m` no-op.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py::test_file_path_bootstrap_appends_repo_root_once` (187-203) — **pins the defective behavior**: line 197 reads `sys.path[-1]` and line 203 asserts "the root must be appended last". This test must be rewritten, not merely supplemented.

### 4.2 Simulating a foreign checkout without temporary files

The isolation fixture removes every real route to `scripts`, so the test can add a controlled foreign route:

- Rejected: injecting a fake `scripts` object into `sys.modules`. The import system consults `sys.modules` before any path entry, so it bypasses ordering and cannot distinguish append from prepend.
- Rejected: a non-existent directory string alone. It supplies no package, so both the old and new code pass.
- **Recommended:** a sentinel `sys.path` entry backed by an in-memory path-entry finder. Inside `isolated_import_state()`, append a sentinel string (for example `"<foreign-checkout-886>"`) to the isolated `sys.path`, which mirrors the site-packages position of an editable-install `.pth` entry, and register `sys.path_importer_cache[sentinel] = ForeignScriptsFinder()`. `importlib.machinery.PathFinder` reads `sys.path_importer_cache` before `sys.path_hooks`, so no hook registration and no filesystem object is required. The finder's `find_spec("scripts", target=None)` returns `importlib.util.spec_from_loader("scripts", loader, is_package=True)` with a loader whose `exec_module` sets `module.__path__ = []` and a marker attribute; it returns `None` for any other name. Remove the cache entry in a `finally` block (or via `monkeypatch.setitem(sys.path_importer_cache, ...)`, which restores automatically).
  - Current code: the root is appended after the sentinel, `scripts` resolves to the foreign stub, and `scripts.dev_tools` raises `ModuleNotFoundError` during `run_path`. The test fails as required by plan task P2-T1 `[expect-fail]`.
  - Fixed code: the root sits at index 0, `scripts` resolves to the worktree package, and `--help` exits 0. The test can also assert `sys.modules["scripts"].__file__` resolves under `REPO_ROOT` and lacks the marker attribute.

### 4.3 Recommended test changes

1. Rewrite `test_file_path_bootstrap_appends_repo_root_once` as `test_file_path_bootstrap_prepends_repo_root_once`: same arrange/act, assert `entries_after == 1` and `resolves_to_repo_root(sys.path[0])`. Fails on current code (root is last).
2. Add `test_file_path_invocation_prefers_worktree_over_foreign_scripts_entry` using the sentinel finder from 4.2. Fails on current code with `ModuleNotFoundError`.
3. Add `test_file_path_bootstrap_keeps_existing_entries_in_order`: snapshot the isolated `sys.path`, run the file-path form, assert `sys.path[1:] == snapshot` (the bootstrap inserts exactly one entry and reorders nothing).
4. Keep `test_module_invocation_leaves_sys_path_unchanged` unchanged as the `-m` no-op guard.
5. Update the module docstring (lines 1-22) to describe the prepend contract and the sentinel-finder technique.

The finder and loader stub are test-only classes in the same test file; the file stays well under 500 lines (204 today, roughly 60-80 added). No subprocess and no temporary file is used, consistent with the existing file's stated invariant (lines 19-21).

### 4.4 Shared helper versus inline one-liner

A shared helper such as `ensure_repo_root_first(path_list, root)` is not recommended:

- Chicken-and-egg: a helper inside the `scripts` package cannot be imported until the root is already on `sys.path`. A helper outside the package (for example a top-level module beside the script, importable through the script-directory entry `sys.path[0]`) is not importable under `python -m`, would require a `try/except ImportError` before the first-party imports (not E402-exempt), and would be an unresolved import for Pyright strict.
- Any statement that calls a helper defined in the same file is preceded by a `def`, which ends the E402 exemption window.
- The inventory in section 2.1 shows exactly one file-path entry script with a bootstrap, so there is no duplication for a helper to remove.
- The dispatcher has a two-line budget before reaching the 500-line limit.

**Recommended design: replace line 17 with a single E402-exempt slice augmented assignment.**

```python
# File-path invocation has no package context; put this checkout's root first.
sys.path[:0] += [str(Path(__file__).resolve().parents[2])] if not __package__ else []
```

Semantics (Python language reference, augmented assignment to a subscription): the target `sys.path[:0]` is evaluated once, yielding a new empty list; `+=` extends that list in place; the result is stored back with `sys.path[:0] = result`, which inserts it at index 0 of the original list object. With no package context the root is inserted at index 0; with a package context the right-hand side is `[]` and the slice assignment changes nothing, preserving the `-m` contract pinned by `test_module_invocation_leaves_sys_path_unchanged`. The line is 85 characters (within Black and Ruff `line-length = 88`), keeps the file at 498 lines, needs no suppression, and keeps the same right-hand-side expression that Pyright strict accepts today on line 17. The comment line should be reworded as shown so the intent (prepend, this checkout) is explicit.

Rejected alternatives: `if not __package__: sys.path.insert(0, root)` (E402 on eleven imports, needs an unauthorized suppression); a shared helper module (section 4.4 reasons); append-then-`sys.path.sort(key=...)` (exempt but reorders the list under `-m` when the root is already present, and is harder to read).

## 5. Idempotence, de-duplication, and `python -m`

- `python -m`: `__package__ == "scripts.dev_tools"`; the recommended line performs `sys.path[:0] = []`, which leaves contents and list identity unchanged. Existing test 4.1 item 3 continues to assert `sys.path == snapshot`.
- Root already present later in `sys.path` (for example via `PYTHONPATH`, or a `.pth` that names this same checkout): the recommended line inserts a second copy at index 0 rather than moving the existing one. The first matching entry wins during import, so the later duplicate is inert; the existing entry is not reordered, which keeps the change minimal. Moving the entry would require a removal statement that is not E402-exempt (`sys.path.remove` raises `ValueError` when absent, and any guard is an `if`), or a helper, so de-duplication is not recommended. The "exactly once" assertion in the rewritten test remains valid because the isolation fixture removes all root entries first.
- Re-execution in the same process (only possible through `runpy` in tests) would prepend again; each test runs inside `isolated_import_state()`, which restores the original list object, so no accumulation crosses tests.
- Real file-path invocation: the interpreter sets `sys.path[0]` to `scripts/dev_tools`; after the fix the root precedes it. Every first-party import in the dispatcher uses the fully qualified `scripts.dev_tools.*` form, so no module changes resolution other than `scripts` itself (section 2.2 shadowing check).

## 6. Toolchain and coverage

Commands (from `.claude/rules/python.md` lines 13-16), run from the worktree root in the mandatory order:

1. `poetry run black .`
2. `poetry run ruff check .`
3. `poetry run pyright`
4. `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Targeted form using the dotted module `--cov` spelling (a file-path `--cov=<path>.py` measures nothing):

```
poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing
```

Coverage configuration: `pyproject.toml` lines 119-127 (`source = ["src", "scripts/dev_tools"]`, `data_file = "artifacts/.coverage"`), lines 129-141 (`if __name__ == .__main__.:` excluded), line 116 (`--cov-report=lcov:artifacts/python/lcov.info` added by default). Current coverage of the dispatcher was **not obtained**: this research session had no shell tool. Line 17 executes on every import of the module (the `if not __package__ else` conditional expression does not create a branch arc for coverage.py), so the change is not expected to reduce line or branch coverage; the executor must capture baseline and post-change numbers under `<FEATURE>/evidence/` per the plan's P4-T3.

## 7. Out-of-scope observations

- **Doc drift (do not edit in #886):** `.claude/rules/orchestrator-state.md:204` states the file-path form "derives the repository root from the script location and appends it to `sys.path` only when the script runs without a package context." After the fix this should read "inserts it at the front of `sys.path`". The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md:204` carries the same sentence. Both are policy surfaces owned by another item (#898) and must not be edited here.
- `tests/conftest.py:60-61` prepends the root only when the exact string is absent; this is consistent with the recommended behavior and needs no change.
- Other `scripts/dev_tools` entry scripts with `__main__` blocks and `from scripts...` imports have no file-path bootstrap and support module-form invocation only. Extending file-path support to them is not requested by #886.

## Numeric Derivation Evidence

The issue folder has no approved `spec.md` acceptance criterion with a numeric claim. The one population claim this research makes ("exactly one production file under `scripts/` mutates `sys.path`") is derived as follows so that any acceptance criterion built on it is backed.

- **Complete Family:** production Python files under `scripts/` (any depth) that mutate `sys.path` or branch on `__package__` for import bootstrapping.
- **Exhaustive Search Scope:** every `*.py` file in the worktree, then narrowed to `scripts/`; every mutation form: `+=`, `.append`, `.insert`, `.extend`, slice/index assignment, `site.addsitedir`, `PYTHONPATH`, and `__package__` reads.
- **Inclusion Rules:** a statement that changes `sys.path` contents or reads `__package__` to decide on such a change.
- **Exclusion Rules:** `Path(__file__).resolve().parents[N]` used only to compute data or default paths; prose in Markdown.
- **Primary Search Strategy or Query Expression:** Grep `sys\.path\s*(\+=|\.append|\.insert|\.extend|\[)|__package__`, glob `*.py`, whole worktree.
- **Primary Member Set:** `scripts/dev_tools/validate_orchestration_artifacts.py:17` (plus out-of-family test hits `tests/conftest.py:61`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py:197`).
- **Primary Count:** 1 (in family).
- **Cross-check Search Strategy or Query Expression:** Grep `parents\[|addsitedir|PYTHONPATH|sys\.path`, glob `*.py`, path `scripts/`, then manual classification of each of the 17 hits; plus Grep `sys\.path\s*(\+=|\.append|\.insert|\.extend|\[:0\]|=)|__package__` over `*.{py,ps1,sh,ts,js,mjs,cjs,yml,yaml}`.
- **Cross-check Member Set:** `scripts/dev_tools/validate_orchestration_artifacts.py:17` (the other 16 `parents[` hits under `scripts/` compute paths only).
- **Cross-check Count:** 1.
- **Member-set Comparison:** normalized sets are identical: `{scripts/dev_tools/validate_orchestration_artifacts.py:17}`.

## Summary

- **Affected production file:** `scripts/dev_tools/validate_orchestration_artifacts.py:16-17` (only file).
- **Affected test file:** `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (rewrite lines 187-203, add two tests, update docstring).
- **Design:** inline `sys.path[:0] += [...] if not __package__ else []`; no helper, no suppression, no line-count growth, no de-duplication.
- **Tests:** positional assertion on `sys.path[0]`, an order-preservation assertion, and a foreign-checkout regression built from a sentinel `sys.path` entry plus an in-memory `sys.path_importer_cache` finder; all fail on the current append form.
