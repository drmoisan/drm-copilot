# Bundle Mirror Hashes

Timestamp: 2026-09-17T08:26:58-04:00
Command: New-Item -ItemType Directory -Path 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution' -Force ; Copy-Item -LiteralPath '.claude/lib/worktree-resolution/<Module>.psm1' -Destination 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/<Module>.psm1' -Force ; (Get-FileHash -Algorithm SHA256 -LiteralPath <repo>).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath <bundle>).Hash
EXIT_CODE: 0
Output Summary: Both mirrors were produced with Copy-Item. Both SHA-256 comparisons evaluate to True.

| Module | Repo-side SHA-256 | Bundle SHA-256 | Equal |
| --- | --- | --- | --- |
| WorktreeResolution.psm1 | EC8050D168F6D96A5DE8AC5F4C5B3F1F6C547CCC8AA28642534D27C13C7AF3DB | EC8050D168F6D96A5DE8AC5F4C5B3F1F6C547CCC8AA28642534D27C13C7AF3DB | True |
| WorktreeTargetResolution.psm1 | EDE6AD1659E73812870DD0D3DE204D06E4FDF51EA09F98FBDA81C9407729A3A5 | EDE6AD1659E73812870DD0D3DE204D06E4FDF51EA09F98FBDA81C9407729A3A5 | True |
