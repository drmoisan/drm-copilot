# Remediation Scope Baseline (P0-T2)

Timestamp: 2026-11-04T01-15
Command: git fetch origin main; git merge-base origin/main HEAD; git branch --show-current; wc -l TARGET GUARD; sha256sum TARGET; ls SCRATCH/issue-1066-{run-list,junit-sets,order,junit-writer,poshqc-run,global-state}.ps1
EXIT_CODE: 0
Output Summary:
- MERGE_BASE: fe522d2cb05f2729f97fb189acc13259008d06a4 (merge base of origin/main and HEAD; origin/main has not moved since APPROVED P0-T2).
- Branch: bug/test-path-leak-run-actionlint.
- TARGET (tests/scripts/dev-tools/run-actionlint.Tests.ps1) physical lines: 537 (under 680).
- GUARD (tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1) physical lines: 119 (under 680).
- TARGET SHA-256: c73d16b203eaf275e368721be3bd89cd63881a9ad38faf26e09accccb1e07bee.
- SCRATCH tooling: issue-1066-run-list.ps1, issue-1066-junit-sets.ps1, issue-1066-order.ps1, issue-1066-junit-writer.ps1, issue-1066-poshqc-run.ps1, issue-1066-global-state.ps1 are all present; none was recreated.
