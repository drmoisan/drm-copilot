# PowerShell Coverage Comparison

Timestamp: 2026-10-28T22-12
Command: parse the report LINE counter and the per-sourcefile LINE counters of artifacts/pester/powershell-coverage.xml from the [P7-T3] run, and compare with the baseline copy of the same file from [P0-T5] (both copies kept under SCRATCH)
EXIT_CODE: 0
Output Summary:
- Baseline overall line coverage ([P0-T5]): 92.71% (17787 of 19185 lines).
- Post-change overall line coverage ([P7-T3]): 92.88% (18232 of 19630 lines). Not below baseline (+0.17 points).
- Per-file line coverage of the new production files (repository paths; the bundle copies are outside the coverage population derived from `config/poshqc-coverage.json`):

| File | Line coverage | Covered / total |
|---|---|---|
| `.claude/lib/file-size-policy/FileSizePolicy.psm1` | 100.00% | 104 / 104 |
| `.claude/hooks/enforce-file-size-limit.ps1` | 100.00% | 71 / 71 |
| `.codex/hooks/file-size-policy.ps1` | 100.00% | 101 / 101 |
| `.codex/hooks/enforce-file-size-limit.ps1` | 100.00% | 83 / 83 |
| `scripts/ci/FileSizeBaseline.psm1` | 100.00% | 54 / 54 |
| `scripts/ci/New-FileSizeBaseline.ps1` | 100.00% | 32 / 32 |

- Every new file is at or above the 85% line threshold. No sibling module was created under the [P1-T2] split contingency (the module is 415 lines).
- No branch figure is recorded: Pester measures no branch coverage, and no PowerShell branch gate applies.
- Command coverage reported by Pester (informational only): 92.13% post-change, 91.95% baseline.
