# Codex Bundle Mirror Hashes (issue #1009)

Timestamp: 2026-10-30T17-43
Command: cp each source to `extensions/drm-copilot/resources/codex-and-agents-customizations/<same path>`, then sha256sum over each pair
EXIT_CODE: 0
Output Summary: three pairs, all byte-identical.

| Source | SHA-256 (source = bundle) |
|---|---|
| `.codex/hooks/hook-target-worktree.ps1` | 5bb5453db9cfda9055cc6c4226f10e5dcad565726d8f9ebf9572a23d69e64c85 |
| `.codex/hooks/enforce-python-batch-budget.ps1` | e4c857217e42d2c58b1608a26423d7aa3481d035010e7bcf1e2074c02be38455 |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 4ce9a58413cb2ecec629f2ce13db89d2469ae064e3ac4637539f91e7bebfa652 |

Note: [P9-T1] re-copies any source the formatter changes; the final pair hashes are re-verified by the resource-contract pytests in [P9-T7].
