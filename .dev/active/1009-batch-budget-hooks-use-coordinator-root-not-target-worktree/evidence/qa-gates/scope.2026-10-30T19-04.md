# Scope Verification (issue #1009)

Timestamp: 2026-10-30T19-04
Command: git diff --name-only origin/main...HEAD; git status --porcelain (after git fetch origin main)
EXIT_CODE: 0
Output Summary: every changed or new path is a File Inventory path, a `<FEATURE>` file, or the `docs/features/potential/promoted/` lifecycle file. No path from the plan's not-edited list appears.

Committed since the merge base (`origin/main...HEAD`): only `<FEATURE>` files (issue.md, spec.md, the plan, research, two preflight-fix records) and `docs/features/potential/promoted/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree.md`.

Working tree, modified (all File Inventory Edit paths, plus `<FEATURE>` plan.md and spec.md):
- `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1` and their claude-customizations bundles
- `.codex/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1` and their codex-and-agents-customizations bundles
- both `pack-manifests/core.json` files
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- the six execution-environment brief copies; `.claude/rules/orchestrator-state.md` and its bundle

Working tree, untracked (all File Inventory Create paths, plus `<FEATURE>/evidence/`):
- `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` and bundle; `.codex/hooks/hook-target-worktree.ps1` and bundle
- `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1`, `HookTargetWorktree.Rows.Helpers.ps1`; `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`; the three `*.TargetWorktree.Tests.ps1` suites

Not-edited list, confirmed absent from both listings: `enforce-batch-budget-route.ps1` (all four copies); the #1010 and #1011 consumer files; `.claude/hooks/enforce-model-routing-receipt.ps1`; `.claude/settings.json`; `.codex/config.toml`; the Claude `python.json` and `powershell.json` manifests; the existing `WorktreeResolution*.psm1` modules; `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`; every suite named in AC-26.
