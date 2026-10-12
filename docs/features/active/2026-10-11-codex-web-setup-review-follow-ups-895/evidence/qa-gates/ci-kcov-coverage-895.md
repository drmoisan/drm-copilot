# CI kcov coverage (issue 895)

Timestamp: 2026-10-12T18-07
Command: CI step "Run shell-qc test with coverage" in job shell-coverage of .github/workflows/_shell-coverage.yml; not run locally per Option A.
EXIT_CODE: DEFERRED-S9
Output Summary: The orchestrator records the printed "Bash coverage (lines): NN.N%" line, read from that same single step log, for the PR head, compares it with the baseline in ci-baseline-kcov-coverage-895.md, and confirms it stays at or above 85 percent with no regression.
S9-EVIDENCE: PENDING
