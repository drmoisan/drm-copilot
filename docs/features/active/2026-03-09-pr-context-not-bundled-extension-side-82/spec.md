# 2026-03-09-pr-context-not-bundled-extension-side (Spec)

- **Issue:** #82
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-09T11-14
- **Status:** Draft
- **Version:** 0.1

## Context
The extension's `collectPrContext` command uses `executePythonModule()` which runs `python -m scripts.dev_tools.pr_context.collector` with `cwd` set to the destination workspace. This expects the `scripts.dev_tools.pr_context` package to exist in the destination workspace, but it only exists in the extension's source repository. This violates the core extension architecture: all utilities must run extension-side, and only artifacts/context live workspace-side. Relates to and supersedes GitHub issue #81 (blank PR context artifacts).

Environment:
- OS/version: Windows 11
- Python version: 3.12+
- Command/flags used: VS Code command `scaffoldExtension.collectPrContext`
- Data source or fixture: Any destination workspace without the `scripts/dev_tools/pr_context` package

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The PR context collection command is a core extension utility and is completely non-functional in any destination workspace.


## Repro & Evidence
Steps to Reproduce:
1. Install the drm-copilot extension (side-loaded VSIX) in a destination workspace that does not contain `scripts/dev_tools/pr_context/`.
2. Run the command `drm-copilot: Collect PR Context` from the command palette.
3. Select a base branch when prompted.
4. Observe that the command fails because Python cannot import `scripts.dev_tools.pr_context.collector` from the destination workspace.

Expected:
The extension should bundle the `scripts/dev_tools/pr_context/` package in its own resources and execute it from the extension directory. The collector should receive `--repo-root <workspace_path>` so it operates on the destination workspace's Git history while running from the extension's bundled Python code. Output artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) should be written relative to the destination workspace.

Actual:
The extension runs `python -m scripts.dev_tools.pr_context.collector` with the destination workspace as the working directory. Since the package doesn't exist there, Python raises `ModuleNotFoundError` and the artifacts are either blank or never created. Issue #81 was filed for blank artifacts, but the prior fix incorrectly redirected to a non-existent version of the package in the destination workspace rather than bundling it extension-side.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `ModuleNotFoundError: No module named 'scripts.dev_tools.pr_context'` when running from a destination workspace without the package.


## Scope & Non-Goals
- In scope: Bundle `scripts/dev_tools/pr_context/` package into extension resources; rewrite wrapper to use sys.path + direct import; switch extension.ts from `executePythonModule` to `executeBundledScript`; update TypeScript tests; pass `--repo-root` explicitly.
- Out of scope / non-goals: Refactoring the `pr_context` Python package itself; changing `collect_commit_context` pattern; adding new collector CLI arguments.
- Explicitly excluded systems, integrations, or datasets: No changes to the canonical `scripts/dev_tools/pr_context/` source package—only copy/bundle into extension resources.

## Root Cause Analysis
- `extension.ts` line ~466: uses `executePythonModule` with `moduleName: "scripts.dev_tools.pr_context.collector"` which requires the module in `cwd`.
- The existing wrapper at `resources/templates/collect_pr_context.py` also delegates to `python -m scripts.dev_tools.pr_context.collector` via subprocess, propagating the same issue.
- The `collect_commit_context.py` bundled script is fully self-contained and works correctly—it should serve as the model for the fix.
- The `pr_context` package has no third-party dependencies (only stdlib), making bundling straightforward.


## Proposed Fix

### Design summary (what changes where):
1. **Bundle**: Copy all 10 Python source files from `scripts/dev_tools/pr_context/` into `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/` with empty `__init__.py` markers.
2. **Rewrite wrapper**: Replace subprocess delegation in `resources/templates/collect_pr_context.py` with `sys.path.insert(0, scripts_dir)` + direct import of `collector.main()`.
3. **Switch execution**: Change `extension.ts` `collectPrContext` command from `executePythonModule` to `executeBundledScript`, adding `--repo-root` to args.
4. **Update tests**: Modify TypeScript tests to assert bundled script path execution instead of `-m` module pattern.

### Boundaries and invariants to preserve:
- Branch discovery (git spawnSync) and QuickPick UX in extension.ts are unchanged.
- Output artifacts remain at `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` relative to workspace.
- The canonical `scripts/dev_tools/pr_context/` package source is not modified.
- `cwd` remains workspace root for the spawned Python process.

### Dependencies or blocked work:
- None — the pr_context package has zero third-party dependencies.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- `extensions/drm-copilot/src/extension.ts` — switch from `executePythonModule` to `executeBundledScript`
- `extensions/drm-copilot/resources/templates/collect_pr_context.py` — rewrite as direct-import entry point
- `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` — update spawn arg assertions
- `extensions/drm-copilot/test/extension.integration.test.ts` — update execution pattern assertions

#### Files/modules to create:
- `extensions/drm-copilot/resources/scripts/dev_tools/__init__.py` — empty package marker
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/__init__.py` — minimal package marker
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/collector.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/feature_docs.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/git.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/github.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/models.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_feature_excerpts.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_pr_helpers.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/summary_helpers.py` — copy from source
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/verification_evidence.py` — copy from source

#### Functions/classes/CLI commands impacted:
- `collectPrContext` command handler in extension.ts
- `collect_pr_context.py` wrapper main function
- `executePythonModule` — will become unused and can be removed

#### Data flow and validation changes:
- `--repo-root` now explicitly passed as workspace root path
- Wrapper uses `sys.path` manipulation to import bundled package

#### Error handling and logging updates:
- Existing error handling in `executeBundledScript` applies automatically
- Wrapper error messages for missing Python resolved from existing shutil.which pattern

#### Rollback/feature-flag considerations (if applicable):
None — clean replacement of broken execution path.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: `--base <branch> --repo-root <path> --out <path> --appendix-out <path>` via bundled wrapper
- Output: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` relative to workspace cwd

#### Required configuration keys and defaults:
- `--repo-root` defaults to `"."` in collector but will be explicitly set by extension

#### Backward-compatibility expectations:
- Artifact output paths unchanged
- Command ID and UX unchanged  
- Branch discovery unchanged

#### Performance constraints (latency/throughput/memory):
- Single-process Python execution (no subprocess from wrapper) improves startup latency

## Assumptions, Constraints, Dependencies
- Assumptions: Python 3.12+ available on PATH in destination workspace; destination workspace has git history
- Constraints: No third-party Python dependencies allowed in bundled package
- External dependencies: git CLI for branch operations; gh CLI for GitHub API calls (already required)

## Data / API / Config Impact
- User-facing or API changes: None — same command, same artifacts
- Data or migration considerations: None
- Logging/telemetry updates: Output channel logging pattern preserved via executeBundledScript
- Compatibility notes: The bundled package is a snapshot of the canonical source; future changes to `scripts/dev_tools/pr_context/` need manual re-bundling

## Test Strategy
Seeded from issue:

- [x] Bundle `scripts/dev_tools/pr_context/` package into `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/`
- [x] Add parent `__init__.py` files for proper package resolution
- [x] Rewrite `collect_pr_context.py` wrapper to manipulate `sys.path` and import the bundled package directly
- [x] Change `extension.ts` to use `executeBundledScript` instead of `executePythonModule`, passing `--repo-root` for workspace context
- [x] Update TypeScript tests to validate the new bundled execution pattern
- [ ] Integration test: verify artifacts are non-blank after running from a clean workspace

- Regression tests to add or update: Update 3 tests in `extension.collect-pr-context.test.ts` and 2-3 tests in `extension.integration.test.ts` to assert bundled script path instead of `-m` module.
- Unit tests (pytest) for the fixed behavior and boundaries: Wrapper script import/sys.path logic is tested via TS test spawn arg assertions.
- Edge cases and negative scenarios: Python not on PATH, workspace paths with spaces/unicode, non-zero collector exit
- Error handling and logging verification: Verify output channel logs show bundled path resolution
- Coverage impact and targets for changed lines/modules: Extension TypeScript coverage maintained; Python bundled wrapper is not in pytest scope (tested via TS tests)
- Toolchain commands to run: TS: prettier → eslint → tsc → jest; Python: black → ruff → pyright → pytest (for source package)
- Manual validation steps: Side-load VSIX in clean workspace without pr_context package; run Collect PR Context; verify non-blank artifacts

## Acceptance Criteria
- [ ] Extension spawns `python <bundled_script_path>` (NOT `python -m scripts.dev_tools.pr_context.collector`)
- [ ] Bundled script resolves and imports bundled package via sys.path manipulation
- [ ] `--repo-root` is passed explicitly with workspace path
- [ ] Output artifacts are written relative to destination workspace
- [ ] All existing branch discovery and QuickPick UX works unchanged
- [ ] TypeScript tests pass with updated assertions for bundled execution pattern
- [ ] `executePythonModule` function and `PythonModuleCommandSpec` type are removed (dead code cleanup)
- [ ] Repro steps now produce the expected behavior in all documented environments
- [ ] Regression test(s) added and passing
- [ ] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [ ] No unintended behavior changes outside the defined scope.
- [ ] Required logs/telemetry updated and validated (if applicable).
- [ ] Performance constraints met or explicitly waived with rationale.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs
