# Manifest Suite Run Record — WorktreeResolution.Manifest.Tests.ps1

Timestamp: 2026-09-17T08:27:32-04:00
Command: $r = Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1' -PassThru; $r.PassedCount; $r.FailedCount; $r.SkippedCount; $r.Passed.ExpandedPath ; Select-String -LiteralPath 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1' -SimpleMatch -Pattern 'bundle mirror byte identity'
EXIT_CODE: 0
Output Summary: PassedCount=7, FailedCount=0, SkippedCount=0. The suite carries all four DiscoveryValidation-pattern assertions: -Contain (2 rows), exactly-once via an exact string-equality filter compared to 1 (2 rows), on-disk coverage of the expected-path list (1), and a separate SHA-256 byte-identity Describe with a Test-Path -LiteralPath $bundleFile guard (2 rows). The phrase search returns exactly 1 match.

## Counts

- PassedCount: 7
- FailedCount: 0
- SkippedCount: 0
- `Select-String ... -SimpleMatch -Pattern 'bundle mirror byte identity'`: 1 match

## Passed tests (full names, verbatim)

```text
WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 in core.json paths
WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 in core.json paths
WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 exactly once
WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 exactly once
WorktreeResolution core.json manifest membership.registers every on-disk worktree-resolution module so none is unregistered
WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeResolution.psm1 byte-identically into the bundle
WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 byte-identically into the bundle
```
