# Format Gate, Final Pass (issue #1009)

Timestamp: 2026-10-30T18-27
Command: sh SCRATCH/issue-1009-ps.sh issue-1009-format.ps1 -ListFile SCRATCH/issue-1009-inventory-ps.txt (per file: LF-normalize, Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, write only when the output differs; SHA-256 taken before and after)
EXIT_CODE: 0
Output Summary: FORMAT_FILES=20 FORMAT_CHANGED=0. No file changed on this final pass; every before hash equals its after hash.

Why the loop restarted after `format.2026-10-30T18-00.md`: the first fresh full run ([P9-T10]) failed two rows of `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`. The two Claude target-worktree suites named their hook with a single `.claude/hooks/<name>.ps1` literal; the guard resolves such a literal against both `.claude/hooks` and `.codex/hooks`, so it counted the Codex hook's cwd-derived root default as a seam of the Claude suites. Both suites now build the hook path from separate segments, matching the existing sibling suites, and the loop restarted at this gate.

Hashes are unchanged from `format.2026-10-30T18-00.md` for all files except these two:

| File | SHA-256 before = after |
|---|---|
| `tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1` | 6f6e5a1ed83b36dfadc89a8959375c37ac71d80fa5fab158ca98aea577e96018 |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1` | 3a0728d769b6bf578b2ba96e9eaf4589181b1feaef6e35a1bf49412c687c70b8 |
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` and bundle | 1df32add07d2eafbfb1cef260603afd648f8335a5c9d79633811a9602a54f3e3 |
| `.codex/hooks/hook-target-worktree.ps1` and bundle | da5e02f068033688c10fae086ac028583b591861b6dd6fcaaffc70aab4895bf5 |
| `.claude/hooks/enforce-python-batch-budget.ps1` and bundle | ef7b868ee207a6fc719846584798bd9ccea327f19e0e4758fdedcb28892ce127 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` and bundle | d14aa8a1a8bbdc50460bb6306e20080090e1eda987e3b377e349cef5cdf071f0 |
| `.codex/hooks/enforce-python-batch-budget.ps1` and bundle | e4c857217e42d2c58b1608a26423d7aa3481d035010e7bcf1e2074c02be38455 |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` and bundle | 4ce9a58413cb2ecec629f2ce13db89d2469ae064e3ac4637539f91e7bebfa652 |
| `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` | 4220769385245e85dc77a09118fc4d7c71b0426f5d293b4eae62682f8d411b1d |
| `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Rows.Helpers.ps1` | a4199bc401e522b2a585e7fc1336f4afde6930c8b9a78abd7cef47684541eca3 |
| `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` | eff6d566c186bf9e7bf2643645727059ec2d9049372bc12546c47b2a57ed38e6 |
| `tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1` | 7da2532f588e6af19206cb13014786d822462a190b45516f1136b5cc6556ce62 |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | 911acea6d49d83b5cb1d40e9a6c58a9e53be3ef051cce7ae2b075fd73ecb6db2 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 056cc3bbc7023750ed1e2cb0972f0ae51a00dcb38261c201bdc0f8e8c6560c83 |
