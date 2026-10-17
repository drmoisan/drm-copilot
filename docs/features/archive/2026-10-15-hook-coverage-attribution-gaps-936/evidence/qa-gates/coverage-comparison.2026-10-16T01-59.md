# Coverage comparison (P2-T4)

Timestamp: 2026-10-16T01-59
Command: poetry run python -I SCRATCH/cov936.py counter SCRATCH/p2-full/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: Baseline (coverage-full artifact): missed=667 covered=11613 LinePercent=94.57. Post-change: missed=667 covered=11613 LinePercent=94.57. Post-change LinePercent is greater than or equal to baseline (equal). ChangedExecutableLines=0: P1-T5 and P1-T6 report HEADER-ONLY=True; every changed line is comment-help text in a test file under tests/, which is outside the coverage population.
Threshold85=MET
