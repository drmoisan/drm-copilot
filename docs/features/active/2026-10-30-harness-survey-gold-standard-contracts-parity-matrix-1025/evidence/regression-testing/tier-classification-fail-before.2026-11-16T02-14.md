# Tier Classification Fail-Before (P2-T5)

Timestamp: 2026-11-16T02-14
Command: git add scripts/harness; env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: with the three scripts/harness modules staged (the tier check discovers projects from git ls-files) and no quality-tiers.yml entry, the tier check reports the unclassified project and exits 1:

QT008: discovered project 'scripts/harness' has no entry
