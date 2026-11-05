# Fixture Run: publish-sideloaded-extension.Tests.ps1 (P5-T6)

Timestamp: 2026-11-04T04-09
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=18 Passed=18 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 tests=18 failed=0 (baseline: 16 failed)
- Changes: portable root `publish-sideloaded-extension-root`; `-RepoRoot`, `-VsixOutputDir`, `$script:fixtureVsixPath`, the `Test-Path` filter value, and the `Resolve-ExtensionProjectRoot` mock value are built from the root.
- Intermediate run (same command, before the closure change): 17 failed with "The variable '$script:VsixDir' cannot be retrieved because it has not been set." The mocks execute while the entry script runs, where `$script:` names the entry script's scope; the three affected mocks now close over local copies (`GetNewClosure`), the same pattern the Discovery entry suite already uses. Assertions are unchanged.
