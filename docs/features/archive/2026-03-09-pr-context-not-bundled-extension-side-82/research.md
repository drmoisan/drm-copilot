<!-- markdownlint-disable-file -->

# Task Research Notes: Extension-side PR Context Package Bundling (Issue #82)

## Research Executed

### File Analysis

- `extensions/drm-copilot/src/extension.ts` (full, ~490 lines)
  - Contains two execution patterns: `executeBundledScript` and `executePythonModule`
  - `collectPrContext` command uses `executePythonModule` — the broken path
  - `collectCommitContext` command uses `executeBundledScript` — the working model

- `extensions/drm-copilot/resources/templates/collect_commit_context.py` (full, ~190 lines)
  - Fully self-contained: all git operations inline, no external package imports
  - Uses argparse with `--output` arg; runs in workspace cwd
  - Working bundled script model

- `extensions/drm-copilot/resources/templates/collect_pr_context.py` (full, ~80 lines)
  - Thin wrapper that delegates via `subprocess.run(["python", "-m", "scripts.dev_tools.pr_context.collector", ...])`
  - **ROOT CAUSE**: Requires `scripts.dev_tools.pr_context` to be importable from cwd
  - Even if called via `executeBundledScript`, the subprocess delegation still fails because it runs with workspace cwd

- `scripts/dev_tools/pr_context/` — 11 Python source files:
  - `__init__.py`, `collector.py`, `feature_docs.py`, `git.py`, `github.py`, `models.py`, `render.py`, `render_feature_excerpts.py`, `render_pr_helpers.py`, `summary_helpers.py`, `verification_evidence.py`

- `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` (full, ~380 lines)
  - 7 test cases; key test: "collectPrContext executes canonical package module" asserts `args[0] === "-m"` and `args[1] === "scripts.dev_tools.pr_context.collector"`

- `extensions/drm-copilot/test/extension.integration.test.ts` (full, ~300 lines)
  - 7 test cases; key test: "collectPrContext executes canonical package module in destination workspace" asserts `args` contains `-m` and `scripts.dev_tools.pr_context.collector`

- `extensions/drm-copilot/package.json` (full)
  - No `.vscodeignore` file exists — all files in extension directory are bundled in VSIX by default
  - No `files` field in package.json
  - Extension output: `./out/extension.js`

### Project Conventions

- Standards referenced: general-code-change, typescript-code-change, python-code-change
- Instructions followed: bundled script execution pattern from existing `collectCommitContext`

---

## Key Discoveries

### 1. Two Execution Patterns in extension.ts

#### `executeBundledScript` (lines ~310-350) — WORKING

```typescript
async function executeBundledScript(
  context: vscode.ExtensionContext,
  output: vscode.OutputChannel,
  spec: CommandSpec,
): Promise<void> {
  const workspaceRoot = getWorkspaceRoot();
  // ... runtime detection ...
  const scriptPath = vscode.Uri.joinPath(
    context.extensionUri,
    spec.bundledRelativePath,
  ).fsPath;
  const args = [...runtime.argsPrefix, scriptPath, ...specScriptArgs];
  await runCommandWithOutput(output, runtime.executable, args, workspaceRoot);
}
```

Key behavior:
- Resolves script path from `context.extensionUri` + `bundledRelativePath`
- Script runs from **extension directory** as an absolute path
- `cwd` is set to **workspace root**
- Interface: `CommandSpec` with `runtimeKind`, `bundledRelativePath`, `commandId`, `args?`

#### `executePythonModule` (lines ~352-385) — BROKEN

```typescript
async function executePythonModule(
  output: vscode.OutputChannel,
  spec: PythonModuleCommandSpec,
): Promise<void> {
  const workspaceRoot = getWorkspaceRoot();
  // ... runtime detection ...
  const moduleArgs = ["-m", spec.moduleName, ...(spec.args ?? [])];
  await runCommandWithOutput(output, runtime.executable, moduleArgs, workspaceRoot);
}
```

Key behavior:
- Runs `python -m <module>` with `cwd` = workspace root
- **No `context` parameter** — cannot resolve extension-relative paths
- Requires module to be importable from cwd (workspace)
- This is fundamentally broken: the module only exists in the extension source repo

### 2. Current collectPrContext Registration (extension.ts ~435-465)

```typescript
const collectPrContextDisposable = vscode.commands.registerCommand(
  "drmCopilotExtension.collectPrContext",
  async () => {
    // ... branch discovery with Git spawnSync ...
    // ... QuickPick for base branch selection ...
    await executePythonModule(output, {
      commandId,
      moduleName: "scripts.dev_tools.pr_context.collector",
      args: [
        "--base", selectedBase,
        "--out", "artifacts/pr_context.summary.txt",
        "--appendix-out", "artifacts/pr_context.appendix.txt",
      ],
    });
  },
);
```

**Missing args**: No `--repo-root` is passed. The collector defaults `--repo-root` to `"."` (cwd), which happens to work when running in the repo but will need explicit `--repo-root <workspace>` when running from extension context.

### 3. PR Context Package Dependency Map

All imports traced — **zero third-party dependencies**. Every module uses only Python stdlib:

| Module | Internal Imports | Stdlib Imports |
|--------|-----------------|----------------|
| `__init__.py` | `.collector`, `.git`, `.github`, `.models`, `.render` | — |
| `collector.py` | `.feature_docs`, `.git`, `.github`, `.models`, `.render`, `.render_pr_helpers`, `.summary_helpers`, `.verification_evidence` | `argparse`, `pathlib`, `typing` |
| `models.py` | — | `re`, `dataclasses`, `typing` |
| `git.py` | `.models` | `subprocess`, `pathlib`, `typing` |
| `github.py` | `.models` | `base64`, `json`, `shutil`, `typing` |
| `render.py` | `.models`, `.render_feature_excerpts`, `.render_pr_helpers` | `re`, `subprocess`, `typing` |
| `render_pr_helpers.py` | `.models`, (`.render` via `summary_helpers`) | `re`, `pathlib`, `typing` |
| `render_feature_excerpts.py` | `.models` | `re`, `pathlib`, `typing` |
| `feature_docs.py` | `.models`, `.verification_evidence` | `re`, `pathlib`, `typing` |
| `summary_helpers.py` | `.models`, (`.render` via format_diff_path) | `re`, `datetime`, `typing` |
| `verification_evidence.py` | — | `dataclasses`, `typing` |

**Cross-module dependency note**: `summary_helpers.py` imports `format_diff_path` from `.render` (via local import inside function body at line ~end of file). This creates a minor circular reference `.render` → `.render_pr_helpers` → `.models` and `.summary_helpers` → `.render`.

### 4. Collector CLI Interface (collector.py lines 564-620)

```python
def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Collect PR context for GitHub.")
    parser.add_argument("--base", dest="base")
    parser.add_argument("--head", dest="head")
    parser.add_argument("--out", dest="out", default="artifacts/pr_context.summary.txt")
    parser.add_argument("--appendix-out", dest="appendix_out", default="artifacts/pr_context.appendix.txt")
    parser.add_argument("--repo-root", dest="repo_root", default=".")
    parser.add_argument("--append", dest="append", action="store_true")
    parser.add_argument("--no-untracked", dest="no_untracked", action="store_true")
    return parser.parse_args(argv)

def main(argv: Sequence[str] | None = None) -> None:
    args = parse_args(argv)
    out_path = Path(args.out).expanduser()
    repo_root = Path(args.repo_root).expanduser().resolve()
    collect_and_write(
        base=args.base, head=args.head, out=out_path,
        appendix_out=Path(args.appendix_out).expanduser(),
        repo_root=repo_root, append=bool(args.append),
        include_untracked=not bool(args.no_untracked),
    )
```

**Critical: `--repo-root`** defaults to `"."`. When running bundled:
- `cwd` will be workspace root (from `executeBundledScript`)
- `--repo-root` should be explicitly set to workspace root path for clarity and correctness
- Output paths (`--out`, `--appendix-out`) are relative and will resolve against cwd (workspace)
- `repo_root` is used by `GitClient` and `GhClient` for all git/gh operations and for reading feature docs

**`repo_root` usage in `collect_and_write`:**
- Passed to `GitClient(runner, repo_root)` — sets cwd for all git commands
- Passed to `GhClient(runner, resolved_root)` — sets cwd for all gh commands  
- Used by `gather_feature_excerpts(resolved_root, ...)` — reads docs/features/active/
- Used by `_render_verification_evidence_section(resolved_root=...)` — reads evidence files

### 5. Existing Resources Directory Structure

```
extensions/drm-copilot/resources/
└── templates/
    ├── collect_commit_context.py
    ├── collect_pr_context.py
    ├── hello_pwsh.ps1
    └── hello_python.py
```

No `scripts/` subdirectory exists yet under `resources/`.

### 6. Test Files That Need Updating

#### extension.collect-pr-context.test.ts — 7 tests

| # | Test Name | Key Assertions | Impact |
|---|-----------|---------------|--------|
| 1 | collectPrContext cancels before spawn | `spawn` not called on cancel | **No change needed** — branch discovery logic unchanged |
| 2 | collectPrContext fails when no workspace folder | throws "No workspace folder" | **No change needed** |
| 3 | collectPrContext selects deterministic default base branch | QuickPick items, default label | **No change needed** — branch discovery unchanged |
| 4 | collectPrContext passes base and artifact args | asserts `args.toContain("-m")`, `args.toContain("scripts.dev_tools.pr_context.collector")` | **MUST CHANGE**: Will need to assert bundled script path instead of `-m` module |
| 5 | collectPrContext git branch discovery failure | rejects with git error | **No change needed** |
| 6 | collectPrContext non-zero collector exit diagnostics | rejects with exit code 7 | **May need update** if spawn args pattern changes |
| 7 | collectPrContext executes canonical package module | `args[0] === "-m"`, `args[1] === "scripts.dev_tools.pr_context.collector"` | **MUST CHANGE**: Core assertion about execution pattern |

#### extension.integration.test.ts — 2 PR context tests

| # | Test Name | Key Assertions | Impact |
|---|-----------|---------------|--------|
| 1 | collectPrContext executes canonical package module in destination workspace | `args.toContain("-m")`, `args.toContain("scripts.dev_tools.pr_context.collector")`, `options.cwd === "C:/workspace"` | **MUST CHANGE**: execution pattern assertions |
| 2 | collectPrContext handles workspace paths with spaces or unicode | `options.cwd` with spaces/unicode, artifact paths | **MUST CHANGE**: spawn args pattern |
| 3 | collectPrContext writes summary and appendix artifacts | artifact content validation | **May need update** depending on arg structure |

### 7. VSIX Packaging

No `.vscodeignore` file exists. No `files` field in `package.json`. This means:
- By default, `vsce package` includes everything in the extension directory except `.gitignore`-d files
- New files placed under `resources/scripts/` will be automatically included in the VSIX
- No packaging configuration changes needed

---

## Recommended Approach

### Architecture: Rewrite wrapper + bundle package + switch to `executeBundledScript`

The fix has three parts:

#### Part 1: Bundle the PR context package

Copy the entire `scripts/dev_tools/pr_context/` package into the extension resources:

```
extensions/drm-copilot/resources/
├── scripts/
│   ├── __init__.py          (empty, package marker)
│   └── dev_tools/
│       ├── __init__.py      (empty, package marker)
│       └── pr_context/
│           ├── __init__.py  (simplified — no re-exports needed)
│           ├── collector.py
│           ├── feature_docs.py
│           ├── git.py
│           ├── github.py
│           ├── models.py
│           ├── render.py
│           ├── render_feature_excerpts.py
│           ├── render_pr_helpers.py
│           ├── summary_helpers.py
│           └── verification_evidence.py
└── templates/
    ├── collect_commit_context.py
    ├── collect_pr_context.py  (rewritten)
    ├── hello_pwsh.ps1
    └── hello_python.py
```

**`__init__.py` files needed at each level:**
- `resources/scripts/__init__.py` — package marker for `scripts`
- `resources/scripts/dev_tools/__init__.py` — package marker for `dev_tools`
- `resources/scripts/dev_tools/pr_context/__init__.py` — simplified package marker (can be minimal, not the full re-export `__init__.py` from source)

#### Part 2: Rewrite collect_pr_context.py wrapper

The wrapper must:
1. Determine its own directory (the extension's `resources/templates/` directory)
2. Compute the path to `resources/scripts/` relative to itself
3. Insert that path into `sys.path` so `scripts.dev_tools.pr_context` becomes importable
4. Import and call `collector.main()` directly — **no subprocess delegation**

```python
"""Extension-bundled entry point for PR context collection.

Purpose:
    Run the bundled pr_context collector package from the extension's
    resources directory. Uses sys.path manipulation to make the bundled
    package importable without requiring it in the destination workspace.

Usage:
    python collect_pr_context.py --base <ref> --repo-root <path> \
        --out <path> --appendix-out <path>
"""
from __future__ import annotations

import sys
from pathlib import Path

def main() -> None:
    # Resolve the bundled scripts directory relative to this wrapper file.
    # This file lives at: resources/templates/collect_pr_context.py
    # Bundled package lives at: resources/scripts/dev_tools/pr_context/
    scripts_dir = str(Path(__file__).resolve().parent.parent / "scripts")
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)

    from dev_tools.pr_context.collector import main as collector_main
    collector_main()

if __name__ == "__main__":
    main()
```

**Why `sys.path` + direct import instead of subprocess:**
- Avoids the same `ModuleNotFoundError` that the current wrapper has
- Single process — no subprocess overhead or error propagation complexity
- The wrapper resolves its own filesystem location (from `__file__`) which is in the extension directory regardless of cwd

**`sys.path` mechanics:**
- `scripts_dir` = `<extension>/resources/scripts/`
- After inserting into `sys.path`, Python can resolve `dev_tools.pr_context.collector`
- Note: we import `dev_tools.pr_context.collector`, NOT `scripts.dev_tools.pr_context.collector`, because `scripts_dir` itself is on the path (so `scripts` is the root, and `dev_tools` is the first package level)

**Actually, let me reconsider.** If `sys.path` points to `resources/scripts/`, then the import should be `from dev_tools.pr_context.collector import main`. But the package's internal imports all use relative imports (e.g., `from .models import ...`), which means they're agnostic about the top-level package name. This approach works.

**Alternative: insert `resources/` into `sys.path`** — then imports would be `from scripts.dev_tools.pr_context.collector import main`. This matches the repo-native package path but requires a `scripts/__init__.py` at the `resources/scripts/` level. Either approach works; the key difference is just naming.

**Recommended**: Insert `resources/scripts/` so imports are `dev_tools.pr_context.collector`. This avoids needing the `scripts/__init__.py` and is cleaner. However, we need `__init__.py` at `dev_tools/` and `dev_tools/pr_context/`.

**Wait — correction on directory structure.** Since the package's relative imports use `from .models import ...` etc., the internal package structure works regardless of how the top-level resolves. We only need to ensure:
1. `sys.path` includes a directory that has `dev_tools/pr_context/` as a valid package hierarchy
2. `dev_tools/__init__.py` exists
3. `dev_tools/pr_context/__init__.py` exists

Simplified directory:
```
extensions/drm-copilot/resources/
├── scripts/
│   └── dev_tools/
│       ├── __init__.py      (empty)
│       └── pr_context/
│           ├── __init__.py  (empty or minimal)
│           ├── collector.py
│           ├── ... (all 10 source files)
└── templates/
    └── collect_pr_context.py  (rewritten)
```

The wrapper inserts `resources/scripts/` into `sys.path`, then `from dev_tools.pr_context.collector import main` works.

#### Part 3: Update extension.ts to use `executeBundledScript`

Change the `collectPrContext` registration from:
```typescript
await executePythonModule(output, {
  commandId,
  moduleName: "scripts.dev_tools.pr_context.collector",
  args: [...],
});
```

To:
```typescript
await executeBundledScript(context, output, {
  runtimeKind: "python",
  bundledRelativePath: "resources/templates/collect_pr_context.py",
  commandId,
  args: [
    "--base", selectedBase,
    "--repo-root", workspaceRoot,
    "--out", "artifacts/pr_context.summary.txt",
    "--appendix-out", "artifacts/pr_context.appendix.txt",
  ],
});
```

**Key change**: Adding `--repo-root` with the workspace path. Since `cwd` is already workspace root (set by `executeBundledScript`), and `--repo-root` defaults to `"."`, this is technically redundant but makes the contract explicit and safe.

#### Part 4: Update TypeScript tests

Tests must update assertions from `-m module` pattern to bundled script pattern:

**Before:**
```typescript
expect(args).toContain("-m");
expect(args).toContain("scripts.dev_tools.pr_context.collector");
```

**After:**
```typescript
expect(args[0]).toBe("C:/extension/resources/templates/collect_pr_context.py");
expect(args).toContain("--repo-root");
```

---

## Implementation Guidance

### Files to CREATE

| File | Purpose |
|------|---------|
| `extensions/drm-copilot/resources/scripts/dev_tools/__init__.py` | Empty package marker |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/__init__.py` | Empty or minimal package marker |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/collector.py` | Copy from `scripts/dev_tools/pr_context/collector.py` |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/feature_docs.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/git.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/github.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/models.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_feature_excerpts.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_pr_helpers.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/summary_helpers.py` | Copy from source |
| `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/verification_evidence.py` | Copy from source |

### Files to MODIFY

| File | Change |
|------|--------|
| `extensions/drm-copilot/resources/templates/collect_pr_context.py` | Rewrite: remove subprocess delegation, add `sys.path` manipulation, import bundled collector directly |
| `extensions/drm-copilot/src/extension.ts` | Change `collectPrContext` handler: replace `executePythonModule` with `executeBundledScript`, add `--repo-root` arg |
| `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` | Update assertions: bundled script path instead of `-m` module, add `--repo-root` assertion |
| `extensions/drm-copilot/test/extension.integration.test.ts` | Update assertions: bundled script path instead of `-m` module, add `--repo-root` assertion |

### Files to DELETE

None.

### Objectives

1. Bundle the `pr_context` package into extension resources
2. Rewrite the wrapper to use `sys.path` + direct import instead of subprocess
3. Switch `extension.ts` from `executePythonModule` to `executeBundledScript`
4. Pass `--repo-root` explicitly so the collector operates on the workspace's git history
5. Update all TypeScript tests to validate the new execution pattern

### Dependencies

- No new third-party dependencies (Python package is stdlib-only)
- No changes to the collector's Python logic or CLI interface
- The `--repo-root` argument already exists in the collector

### Risk Areas

1. **Circular import in `summary_helpers.py`**: The `format_diff_path` function in `summary_helpers.py` does a local import from `.render`. This works in CPython but is a fragile pattern. Since we're copying files verbatim, this is inherited risk, not new risk.

2. **`__file__` resolution in wrapper**: The `sys.path` manipulation depends on `Path(__file__).resolve()` correctly resolving the wrapper's location. This is standard Python behavior and works on all platforms, including when the extension is installed from VSIX.

3. **Relative output paths**: `--out` and `--appendix-out` use relative paths. Since `cwd` = workspace root (set by `executeBundledScript`), these resolve correctly to `<workspace>/artifacts/pr_context.summary.txt`. No change needed.

4. **Git operations cwd**: `GitClient` and `GhClient` use `repo_root` (passed via `--repo-root`) as their cwd for all git/gh commands. With `--repo-root` set to workspace root, all git operations target the correct repository.

5. **Feature docs reading**: `gather_feature_excerpts` reads from `resolved_root / "docs" / "features" / "active"`. With `--repo-root` pointing to workspace, this correctly reads from the destination workspace's feature docs.

6. **Copy drift**: Bundled Python files are copies, not symlinks. When the source package is updated, the bundled copy must be manually synced. Consider adding a sync script or CI check in the future.

### Success Criteria

1. `drm-copilot: Collect PR Context` command works in any destination workspace (even those without `scripts/dev_tools/pr_context/`)
2. Output artifacts (`pr_context.summary.txt`, `pr_context.appendix.txt`) are written to `<workspace>/artifacts/`
3. Artifacts contain non-trivial content (git diff data, feature docs, etc.)
4. All TypeScript extension tests pass
5. Extension VSIX packages correctly with bundled Python files

### Rejected Alternatives

- **Subprocess delegation with modified PYTHONPATH**: Instead of `sys.path` in the wrapper, set `PYTHONPATH` in the TypeScript `spawn` call. Rejected because it adds complexity to the TypeScript side and the `executeBundledScript` interface doesn't support environment variables.
- **Make `collect_pr_context.py` self-contained** (like `collect_commit_context.py`): Would require duplicating ~2000+ lines of complex PR context logic into a single script. Rejected because the PR context package is much more complex than commit context and maintaining a duplicate would be error-prone.
- **Install the package into the workspace via pip**: Rejected because it modifies the destination workspace's environment, requires pip availability, and violates the extension architecture principle of running utilities extension-side.
