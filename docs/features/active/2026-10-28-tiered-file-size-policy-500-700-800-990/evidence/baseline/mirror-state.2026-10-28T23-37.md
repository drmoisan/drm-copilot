# Baseline mirror state (cycle 2, unchanged tree)

Timestamp: 2026-10-28T23-37
Command: `Get-FileHash -Algorithm SHA256` per source and bundle file, and `@(Get-Content -LiteralPath <path>).Count` per file, run from a PowerShell 7 script stored under `SCRATCH`.
EXIT_CODE: 0
Output Summary: both source/bundle pairs are identical at baseline.

| Pair | SHA256 (source = bundle) | Identical |
|---|---|---|
| `.claude/lib/file-size-policy/FileSizePolicy.psm1` vs its bundle copy | 6512789ACE4F10F8327324C899C43A0AE036E9FDEB7973680B09C1CBA8CDC968 | yes |
| `.codex/hooks/file-size-policy.ps1` vs its bundle copy | A2BB6289282BE5195179252ADEBAD19BAF7542A6360092FD6FA4DE1837F1CF0E | yes |

Physical line counts:
- `.claude/lib/file-size-policy/FileSizePolicy.psm1`: 415
- `.codex/hooks/file-size-policy.ps1`: 403
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`: 103
- `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1`: 131
- `tests/scripts/codex-hooks/file-size-policy.Tests.ps1`: 117
