# Bundle Mirror Hashes — After the Final Format and Analyze Stages

Timestamp: 2026-09-17T08:35:51-04:00
Command: Copy-Item -LiteralPath '.claude/lib/worktree-resolution/<Module>.psm1' -Destination 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/<Module>.psm1' -Force (both modules) ; (Get-FileHash -Algorithm SHA256 -LiteralPath <repo>).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath <bundle>).Hash
EXIT_CODE: 0
Output Summary: Both mirrors re-copied with Copy-Item; for each module the repo-side hash equals the bundle hash. WorktreeResolution.psm1 changed after [P3-T6] (the two OutputType repairs from the [P4-T3] loop), so its hash differs from the [P3-T6] record; WorktreeTargetResolution.psm1 is unchanged.

| Module | Repo-side SHA-256 | Bundle SHA-256 | Equal |
| --- | --- | --- | --- |
| WorktreeResolution.psm1 | E5C1C03C0C97E21F7ADA4932227A0C41323999F132060D0766539DED26884109 | E5C1C03C0C97E21F7ADA4932227A0C41323999F132060D0766539DED26884109 | True |
| WorktreeTargetResolution.psm1 | EDE6AD1659E73812870DD0D3DE204D06E4FDF51EA09F98FBDA81C9407729A3A5 | EDE6AD1659E73812870DD0D3DE204D06E4FDF51EA09F98FBDA81C9407729A3A5 | True |
