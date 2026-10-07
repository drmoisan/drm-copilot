# Anchor Ref (P0-T2)

Timestamp: 2026-10-02T07-45
Command: git rev-parse HEAD; git rev-parse --abbrev-ref HEAD; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: HEAD 589b51a30d856dca973a2ed9988f9443c35339cf on branch bug/poshqc-coverage-denominator-not-reproducible-527; porcelain listing empty (clean tree); both execution preconditions hold.

BASE_SHA: 589b51a30d856dca973a2ed9988f9443c35339cf
BRANCH: bug/poshqc-coverage-denominator-not-reproducible-527
PRECONDITION_BRANCH=True
PRECONDITION_PORCELAIN=True

Porcelain output (`git status --porcelain --untracked-files=all`):

```text
(empty: no modified, staged, or untracked paths)
```

Note: an empty listing satisfies PRECONDITION_PORCELAIN vacuously (no path lies outside the feature folder). HEAD 589b51a3 is the orchestrator's classification commit on top of merge commit 8f0483ec (origin/main 71f8dcb4 merged); see DEV-MERGE in `evidence/other/plan-deviations.2026-10-02T07-45.md`.
