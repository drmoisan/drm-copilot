# Prohibited constructs and porcelain status (P3-T6)

Timestamp: 2026-11-04T16-10
Command: sh SCRATCH/issue-1067-prohibited5.sh (git grep -n -F for TestDrive, GetTempPath, New-TemporaryFile and git grep -n -E -e '-Skip([:[:space:]]|$)' over the five change-set files; git status --porcelain --untracked-files=all)
EXIT_CODE: 0

| Search | Matches |
|---|---|
| `TestDrive` | 0 |
| `GetTempPath` | 0 |
| `New-TemporaryFile` | 0 |
| `-Skip([:[:space:]]|$)` | 0 |

Porcelain status paths outside `<FEATURE>/` (exactly the five change-set files, all ` M`):

```
tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
tests/scripts/dev-tools/link-feature-docs.Tests.ps1
tests/scripts/dev-tools/link-parent-child.Tests.ps1
```

Every other porcelain entry is an untracked file under `<FEATURE>/` (this cycle's plan, remediation inputs, and evidence). Test runs wrote nothing else to the tracked or untracked tree (`artifacts/` is ignored).

Output Summary: 0 matches for each of the four searches; porcelain lists exactly the five change-set files plus `<FEATURE>/` paths.
