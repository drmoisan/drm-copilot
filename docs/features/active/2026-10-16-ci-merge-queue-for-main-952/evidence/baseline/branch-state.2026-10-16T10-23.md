# Baseline Branch State (P0-T2)

Timestamp: 2026-10-16T10-23
Command: git fetch origin; git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base origin/main HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary:
- git fetch origin: EXIT_CODE 0
- git rev-parse --abbrev-ref HEAD: bug/ci-merge-queue-for-main-952 (EXIT_CODE 0)
- PLAN_BASE_SHA=f1445b472dfa36e56f1e379b38244cd8da9b525e (git rev-parse HEAD, EXIT_CODE 0)
- origin/main=5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea (git rev-parse origin/main, EXIT_CODE 0)
- B=04f594f2ad2b891cbd8d1388a2e7fe2c67044d28 (git merge-base origin/main HEAD, EXIT_CODE 0)
- git status --porcelain (EXIT_CODE 0), verbatim:
  `?? docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/phase0-instructions-read.2026-10-16T10-22.md`

Notes:
- The porcelain output lists only the untracked P0-T1 artifact, as required.
- The directive check is recorded separately in `directive-removed.2026-10-16T10-23.md` because its expected exit code is 1.
- origin/main has advanced past B (it includes PR #955); B is unchanged because this branch has not merged that commit. P0-T4 checks the plan-cited files for concurrent changes.
