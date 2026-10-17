# Branch state (remediation cycle 1, issue #952)

Timestamp: 2026-10-16T15-18
Task: [P0-T2]
Command: git fetch origin; git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base origin/main HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary:
BRANCH=bug/ci-merge-queue-for-main-952
REM_BASE_SHA=f9d18c2bd605b94bd63805df3f6e092d6ae79607
ORIGIN_MAIN=5d2d9a9728b3763cb4398bdae1e54ef84ee98936
B_NOW=5d2d9a9728b3763cb4398bdae1e54ef84ee98936 (equals the B= value of FEATURE/evidence/baseline/ci-baseline.2026-10-16T14-23.md)
Porcelain (verbatim):
 M docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md
?? docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/
Porcelain check: one `??` line for the remediation-baseline directory; the only other line is the permitted plan checklist line. PASS.

| Command | EXIT_CODE | Output |
|---|---|---|
| git fetch origin | 0 | (none) |
| git rev-parse --abbrev-ref HEAD | 0 | bug/ci-merge-queue-for-main-952 |
| git rev-parse HEAD | 0 | f9d18c2bd605b94bd63805df3f6e092d6ae79607 |
| git rev-parse origin/main | 0 | 5d2d9a9728b3763cb4398bdae1e54ef84ee98936 |
| git merge-base origin/main HEAD | 0 | 5d2d9a9728b3763cb4398bdae1e54ef84ee98936 |
| git status --porcelain | 0 | two lines above |
