# Bundle Parity (P5-T1)

Timestamp: 2026-10-28T13-25
Command: sh SCRATCH/issue-989-run.sh SCRATCH/issue-989-bundle.ps1 (PowerShell 7: Copy-Item -LiteralPath <source> -Destination extensions/drm-copilot/resources/claude-customizations/<source> -Force for each file, then Get-FileHash -Algorithm SHA256 on both copies)
EXIT_CODE: 0

| File | Source SHA-256 | Bundle SHA-256 | Equal |
|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 6651675c40aefcd03d49cf83387fad3d812d837bbaa546b6c51b6f8e1f9e1b6d | 6651675c40aefcd03d49cf83387fad3d812d837bbaa546b6c51b6f8e1f9e1b6d | True |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 069e13760925a9d7ba683abd7d46bcdf1b22cbb146df1a10a36cd215851543f7 | 069e13760925a9d7ba683abd7d46bcdf1b22cbb146df1a10a36cd215851543f7 | True |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 7d618ed8b50a4b83425149f34599c1e7b233eda6f03d7651320b8d2c6a4fc8d6 | 7d618ed8b50a4b83425149f34599c1e7b233eda6f03d7651320b8d2c6a4fc8d6 | True |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | f799b773b5e8a1da6373b4c6c0f694038370e05133de1c73d07b6f7adad091ce | f799b773b5e8a1da6373b4c6c0f694038370e05133de1c73d07b6f7adad091ce | True |
| `.claude/skills/orchestrate/SKILL.md` | 472a94fcd5bd50a9651a81734d114181d795c5bcc5e7d83757fb78dc6e59ca12 | 472a94fcd5bd50a9651a81734d114181d795c5bcc5e7d83757fb78dc6e59ca12 | True |
| `.claude/skills/pr-author/SKILL.md` | ba390804cc056046c2ab2231658a067c25753db35646986ab063441cc5b4fec6 | ba390804cc056046c2ab2231658a067c25753db35646986ab063441cc5b4fec6 | True |
| `.claude/agents/orchestrator.md` | 4af279084d649c3a5ccd17f732472a781cc657a569467cb28f2563314e61f5c9 | 4af279084d649c3a5ccd17f732472a781cc657a569467cb28f2563314e61f5c9 | True |
| `.claude/agents/pr-author.md` | d7bb095f21263db92f784d1b18e1e69818bcb1a117645812d6f4e0bf58edfb2d | d7bb095f21263db92f784d1b18e1e69818bcb1a117645812d6f4e0bf58edfb2d | True |

Output Summary: eight source/bundle SHA-256 pairs, all equal (ALL_EQUAL=True).
