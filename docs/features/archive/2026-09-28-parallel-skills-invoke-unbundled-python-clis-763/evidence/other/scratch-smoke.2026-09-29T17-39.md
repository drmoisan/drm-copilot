# Scratch Script Creation and Smoke Test (P0-T7)

Timestamp: 2026-09-29T17-39
Command: sh SCRATCH/run-ps.sh SCRATCH/psd1-parse.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ; sh SCRATCH/ac-count.sh FEATURE/spec.md ; sh SCRATCH/mirror-check.sh .claude/skills/parallel-orchestrate/SKILL.md
EXIT_CODE: 0
Output Summary:
- run 1 (psd1-parse): EXIT=0, `PSD1-OK file=scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- run 2 (ac-count): EXIT=0, `AC-CHECKED=0 AC-UNCHECKED=18`
- run 3 (mirror-check): EXIT=0, `MIRROR SAME .claude/skills/parallel-orchestrate/SKILL.md` and `MIRROR-SUMMARY same=1 diff=0 missing=0`

SCRATCH is a dedicated subdirectory of the session scratchpad (outside the repository, never
committed), used so that same-named files written by other sessions cannot collide.

## Scratch scripts created verbatim from Appendix A (25)

1. A1 run-ps.sh
2. A2 pester-selfhosted.ps1
3. A3 junit-cases.py
4. A4 jacoco-files.py
5. A5 mirror-check.sh
6. A5b file-hashes.sh
7. A6 ps-format-check.ps1
8. A7 py-cov-files.py
9. A8 reset-batch-budget.ps1
10. A9 pssa-count.ps1
11. A10 psd1-parse.ps1
12. A11 json-parse.py
13. A12 shell-lint.sh
14. A13 shell-format.sh
15. A14 ci-wait.sh
16. A15 ci-shell-log.sh
17. A16 cobertura-files.py
18. A17 no-temp-sweep.sh
19. A18 drift-expected.py
20. A19 changed-lines-cov.py
21. A19b json-equal.py
22. A20 surface-token-count.sh
23. A21 ac-count.sh
24. A22 line-counts.sh
25. A23 bats-parity-local.sh
