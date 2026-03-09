# pr-context-not-bundled-extension-side (Issue #82)

- Date captured: 2026-03-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-context-not-bundled-extension-side/ (Issue #82)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #82
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/82
- Last Updated: 2026-03-09
- Work Mode: full

## Summary

The extension's `collectPrContext` command uses `executePythonModule()` which runs `python -m scripts.dev_tools.pr_context.collector` with `cwd` set to the destination workspace. This expects the `scripts.dev_tools.pr_context` package to exist in the destination workspace, but it only exists in the extension's source repository. This violates the core extension architecture: all utilities must run extension-side, and only artifacts/context live workspace-side. Relates to and supersedes GitHub issue #81 (blank PR context artifacts).

## Environment

- OS/version: Windows 11
- Python version: 3.12+
- Command/flags used: VS Code command `scaffoldExtension.collectPrContext`
- Data source or fixture: Any destination workspace without the `scripts/dev_tools/pr_context` package

## Steps to Reproduce

1. Install the drm-copilot extension (side-loaded VSIX) in a destination workspace that does not contain `scripts/dev_tools/pr_context/`.
2. Run the command `drm-copilot: Collect PR Context` from the command palette.
3. Select a base branch when prompted.
4. Observe that the command fails because Python cannot import `scripts.dev_tools.pr_context.collector` from the destination workspace.

## Expected Behavior

The extension should bundle the `scripts/dev_tools/pr_context/` package in its own resources and execute it from the extension directory. The collector should receive `--repo-root <workspace_path>` so it operates on the destination workspace's Git history while running from the extension's bundled Python code. Output artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) should be written relative to the destination workspace.

## Actual Behavior

The extension runs `python -m scripts.dev_tools.pr_context.collector` with the destination workspace as the working directory. Since the package doesn't exist there, Python raises `ModuleNotFoundError` and the artifacts are either blank or never created. Issue #81 was filed for blank artifacts, but the prior fix incorrectly redirected to a non-existent version of the package in the destination workspace rather than bundling it extension-side.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `ModuleNotFoundError: No module named 'scripts.dev_tools.pr_context'` when running from a destination workspace without the package.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The PR context collection command is a core extension utility and is completely non-functional in any destination workspace.

## Suspected Cause / Notes

- `extension.ts` line ~466: uses `executePythonModule` with `moduleName: "scripts.dev_tools.pr_context.collector"` which requires the module in `cwd`.
- The existing wrapper at `resources/templates/collect_pr_context.py` also delegates to `python -m scripts.dev_tools.pr_context.collector` via subprocess, propagating the same issue.
- The `collect_commit_context.py` bundled script is fully self-contained and works correctly—it should serve as the model for the fix.
- The `pr_context` package has no third-party dependencies (only stdlib), making bundling straightforward.

## Proposed Fix / Validation Ideas

- [x] Bundle `scripts/dev_tools/pr_context/` package into `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/`
- [x] Add parent `__init__.py` files for proper package resolution
- [x] Rewrite `collect_pr_context.py` wrapper to manipulate `sys.path` and import the bundled package directly
- [x] Change `extension.ts` to use `executeBundledScript` instead of `executePythonModule`, passing `--repo-root` for workspace context
- [x] Update TypeScript tests to validate the new bundled execution pattern
- [ ] Integration test: verify artifacts are non-blank after running from a clean workspace

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch