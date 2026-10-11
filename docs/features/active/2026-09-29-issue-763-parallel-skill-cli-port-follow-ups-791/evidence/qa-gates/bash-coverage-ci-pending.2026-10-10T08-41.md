# Final QC — Bash Coverage Gate (CI only)

Timestamp: 2026-10-10T08-41
Task: [P8-T10] (Phase 8 loop pass 1)
Command: sh scripts/bash/shell-qc.sh test --coverage (CI: .github/workflows/_shell-coverage.yml)
EXIT_CODE: N/A
CI-DEFERRED: yes
CI-DEFERRED-ACS: AC-18

Output Summary:
- kcov has no local route; the bash coverage gate runs only in CI through `.github/workflows/_shell-coverage.yml` (called from `.github/workflows/ci.yml`).
- Thresholds: kcov line coverage >= 85% for `.claude/lib/bash/parallel-mutation.sh` and for `.claude/lib/bash/remove-parallel-item.sh`, read from the uploaded `cov.xml` artifact. Bash has no branch-coverage gate (kcov does not measure branch coverage).
- Baseline: both files did not exist ([P0-T12], 0 measured lines each).
- AC-18 is closed only by the later execution run that reads the CI `cov.xml`; it is not checked in [P9-T1].
