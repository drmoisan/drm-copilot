# Stage F1 Format, Lint, Mirror, and Ledger Gate

Timestamp: 2026-11-07T16-42
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1: Invoke-PoshQCFormat in check mode (no-op -WriteFile) and Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the 15 .ps1 and .psm1 files in the diff from the merge base of origin/main and HEAD; poetry run black --check, poetry run ruff check --no-fix, poetry run pyright over the 3 .py files in that diff; in extensions/drm-copilot npx prettier --check, npx eslint, npx tsc -p tsconfig.jest.json --noEmit for the 1 .ts file; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; git hash-object of every source and bundle pair in the 0006 and 0001 path sets; SCRATCH/f1/issue-1097-f1-allreplay.ps1 (Test-ProcessReductionLedger over Read-ProcessReductionLedger, Invoke-ProcessReductionRevert of every Revert Block of entries 0001 to 0006); git apply -R --check of docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch
EXIT_CODE: 0
Output Summary:
  Changed files (merge base of origin/main and HEAD is the PR #1108 merge commit after the merge): 15 PowerShell (.ps1/.psm1), 3 Python, 1 TypeScript; working-tree status adds none.
  PowerShell: every file logs 'Already formatted: ' (already=1 each) and no 'Formatted: ' line (formatted=0 for all 15); analyzer findings 0 in each file (total 0).
  Python: Black "3 files would be left unchanged." (exit 0); Ruff "All checks passed!" (exit 0); Pyright "0 errors, 0 warnings, 0 informations" (exit 0).
  TypeScript: Prettier "All matched files use Prettier code style!" (exit 0); ESLint exit 0; tsc with tsconfig.jest.json exit 0.
  Codex generator --check: exit 0.
  Mirrors: the five conflicted pairs equal by git hash-object; every bundle pair in the 0006 and 0001 path sets: 115 pairs, 115 equal (6 bundle-only csharp-legacy variant files have no source and are not pairs).
  Ledger: Test-ProcessReductionLedger IsValid=True (6 rows, 6 entries). Revert Blocks replayed to their stated Prior text after line-ending normalization: 0001 4/4, 0002 30/30, 0003 49/49, 0004 3/3, 0005 44/44, 0006 25/25; differing-path count 0.
  git apply -R --check of the 0006 patch against the working tree: exit 0.
  Not part of this gate's conditions, recorded for completeness: the chained reverse check of the 0001 patch still fails for 44 paths that predate the merge (see stage-f1-patch-rebase-0001).
