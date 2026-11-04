# Final QA: Format (P4-T1)

Timestamp: 2026-11-04T01-46
Command: pwsh -NoProfile -File SCRATCH/issue-1066-format-lint.ps1 -Root <worktree> -Files tests/scripts/dev-tools/run-actionlint.Tests.ps1,tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1, compare only, no write)
EXIT_CODE: 0
Output Summary:
- Final pass (pass 2, after the P4-T2 fix): TARGET `unchanged`; GUARD `unchanged`.
- Pass 1: both files `unchanged`; the loop restarted from P4-T1 because P4-T2 pass 1 reported two findings in GUARD.
- No file was written by the formatter in either pass.
- File hashes after the final pass: TARGET e76684b6fbeeb460c73e0e27fc23e006533403e8573046fa988cea57d16b1a1a; GUARD 966d7e74dd57c4e63d2324f1fb963152546ed24ee66ebd9ae3a8b7074ba00be1.
