# Claude Bundle Mirror Hashes (issue #1009)

Timestamp: 2026-10-30T17-43
Command: cp each source to `extensions/drm-copilot/resources/claude-customizations/<same path>`, then sha256sum over each pair
EXIT_CODE: 0
Output Summary: three pairs, all byte-identical.

| Source | SHA-256 (source = bundle) |
|---|---|
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | 7e6a04a6376c999c06f1860dff74c53b4e649579cee84df7ef81d9b74f93789f |
| `.claude/hooks/enforce-python-batch-budget.ps1` | ef7b868ee207a6fc719846584798bd9ccea327f19e0e4758fdedcb28892ce127 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | d14aa8a1a8bbdc50460bb6306e20080090e1eda987e3b377e349cef5cdf071f0 |

Note: [P9-T1] re-copies any source the formatter changes; the final pair hashes are re-verified by the resource-contract pytests in [P9-T7].
