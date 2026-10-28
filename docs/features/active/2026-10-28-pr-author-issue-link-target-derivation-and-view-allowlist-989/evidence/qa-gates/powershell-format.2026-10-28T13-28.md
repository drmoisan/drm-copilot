# Format Stage (P6-T1, loop pass 1)

Timestamp: 2026-10-28T13-28
Command: sh SCRATCH/issue-989-run.sh SCRATCH/issue-989-format.ps1 (PowerShell 7: per file, Get-FileHash SHA256 before; Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; write only when the output differs; Get-FileHash SHA256 after)
EXIT_CODE: 0

| File | SHA-256 before | SHA-256 after | Equal |
|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 6651675c40aefcd03d49cf83387fad3d812d837bbaa546b6c51b6f8e1f9e1b6d | 6651675c40aefcd03d49cf83387fad3d812d837bbaa546b6c51b6f8e1f9e1b6d | True |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 069e13760925a9d7ba683abd7d46bcdf1b22cbb146df1a10a36cd215851543f7 | 069e13760925a9d7ba683abd7d46bcdf1b22cbb146df1a10a36cd215851543f7 | True |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 7d618ed8b50a4b83425149f34599c1e7b233eda6f03d7651320b8d2c6a4fc8d6 | 7d618ed8b50a4b83425149f34599c1e7b233eda6f03d7651320b8d2c6a4fc8d6 | True |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | f799b773b5e8a1da6373b4c6c0f694038370e05133de1c73d07b6f7adad091ce | f799b773b5e8a1da6373b4c6c0f694038370e05133de1c73d07b6f7adad091ce | True |
| bundle `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 6651675c40aefcd03d49cf83387fad3d812d837bbaa546b6c51b6f8e1f9e1b6d | 6651675c40aefcd03d49cf83387fad3d812d837bbaa546b6c51b6f8e1f9e1b6d | True |
| bundle `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 069e13760925a9d7ba683abd7d46bcdf1b22cbb146df1a10a36cd215851543f7 | 069e13760925a9d7ba683abd7d46bcdf1b22cbb146df1a10a36cd215851543f7 | True |
| bundle `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 7d618ed8b50a4b83425149f34599c1e7b233eda6f03d7651320b8d2c6a4fc8d6 | 7d618ed8b50a4b83425149f34599c1e7b233eda6f03d7651320b8d2c6a4fc8d6 | True |
| bundle `.claude/hooks/enforce-model-routing-receipt.ps1` | f799b773b5e8a1da6373b4c6c0f694038370e05133de1c73d07b6f7adad091ce | f799b773b5e8a1da6373b4c6c0f694038370e05133de1c73d07b6f7adad091ce | True |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` | 53ff90839ae97fff5c7b99a0ddf5b4a81376883b6184e7b0b22c11bddca3422c | 53ff90839ae97fff5c7b99a0ddf5b4a81376883b6184e7b0b22c11bddca3422c | True |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1` | c499b98e83afd689d55309860bea3eebf9bac6bb4a49fba06339179ecb8fd011 | c499b98e83afd689d55309860bea3eebf9bac6bb4a49fba06339179ecb8fd011 | True |
| `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` | 636ff1dffa2e35d9b0856f686eafc622281fb3f67b40e5f60597301afa4d97b2 | 636ff1dffa2e35d9b0856f686eafc622281fb3f67b40e5f60597301afa4d97b2 | True |
| `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1` | 20b31d31559316b6cb33fbfee08f5504d1270258f768946c3ec7460668f64f02 | 20b31d31559316b6cb33fbfee08f5504d1270258f768946c3ec7460668f64f02 | True |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 8e6fe54300cb796949a7a3ecb3240a42d2d5e8d96961f5aad73480aac636626e | 8e6fe54300cb796949a7a3ecb3240a42d2d5e8d96961f5aad73480aac636626e | True |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 408f0a0f542dc4fe3dd5d00b2bc2a0f6e30f6a9f7802670b9d3a5ea4d934a55c | 408f0a0f542dc4fe3dd5d00b2bc2a0f6e30f6a9f7802670b9d3a5ea4d934a55c | True |

"bundle" denotes `extensions/drm-copilot/resources/claude-customizations/`.

Output Summary: FILES_CHANGED=0; all 14 before/after pairs equal, so the formatter rewrote nothing.
