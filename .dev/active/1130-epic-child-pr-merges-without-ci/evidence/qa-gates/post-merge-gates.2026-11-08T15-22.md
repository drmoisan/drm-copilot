# Post-merge final gates (after merging origin/main at 27830d06c)

Timestamp: 2026-11-08T15-22
Command: sh SCRATCH/issue-1130-pester-postmerge.sh (one Invoke-PoshQCParallelTest run) and sh SCRATCH/issue-1130-pytest-postmerge.sh (one pytest -n auto run with --cov=scripts --cov-branch)
EXIT_CODE: 0
Output Summary:
- Pester: workers=8, wall-clock=976.05s, exit 0; tests=19762, failures=0, errors=0 (baseline 19584, 0 failures).
- PowerShell repo-wide LINE: 35482/37124 = 95.58% (baseline 95.56%).
- .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 (new) 83/83 = 100.00%; .codex/hooks/enforce-epic-merge-gate-child-ci.ps1 (new) 81/83 = 97.59%.
- .claude/hooks/enforce-epic-merge-gate.ps1 144/146 = 98.63% (baseline 98.60%); .codex/hooks/enforce-epic-merge-gate.ps1 175/176 = 99.43% (baseline 99.40%).
- pytest: 16537 passed, 6 skipped, 0 failed in 445.75s; scripts coverage 94% (baseline 94%).
