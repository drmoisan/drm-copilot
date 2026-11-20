# Phase 0 baseline: Pester per-file line coverage (P0-T1)

Timestamp: 2026-11-08T13-52
Command: python SCRATCH/issue-1130-cov.py artifacts/pester/powershell-coverage.xml (reads the LINE counters of the merged coverage report written by the Phase 0 Invoke-PoshQCParallelTest run; no other Pester run preceded this read)
EXIT_CODE: 0
Output Summary:
- Source run: pester-baseline.2026-11-08T13-29.md (Invoke-PoshQCParallelTest, exit code 0, 19584 tests, 0 failures); merged report written 2026-11-08T13-28 UTC.
- Baseline artifacts confirmed: pytest-baseline.2026-11-08T13-27.md and pester-baseline.2026-11-08T13-29.md each carry Timestamp, Command, EXIT_CODE, and an Output Summary with pass and fail counts and numeric coverage.
- .claude/hooks/enforce-epic-merge-gate.ps1: 141/143 = 98.60%
- .codex/hooks/enforce-epic-merge-gate.ps1: 167/168 = 99.40%
- Related helpers (reference only): .claude/hooks/enforce-epic-merge-gate-review.ps1 99.39%; .codex/hooks/enforce-epic-merge-gate-review.ps1 92.64%; .claude/hooks/enforce-epic-merge-gate-resolution.ps1 93.62%; .claude/hooks/enforce-epic-merge-gate-authorization.ps1 99.03%; .claude/hooks/enforce-epic-merge-gate-green-ci.ps1 100.00%; both enforce-epic-merge-gate-command.ps1 copies 100.00%.
- Repo-wide PowerShell LINE coverage of the same run: 95.56% (35308/36947).
