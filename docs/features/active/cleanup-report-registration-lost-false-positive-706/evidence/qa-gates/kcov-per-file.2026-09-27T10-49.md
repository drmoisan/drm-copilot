# Post-Change Per-File Coverage: scripts/bash/cleanup_worktrees_scan_helper.sh (P4-T12)

Timestamp: 2026-09-27T10-49
RUN_ID: 36326020967

## Download

Command: gh run download 36326020967 --name shell-coverage --dir <session-scratchpad>/kcov-final-706
EXIT_CODE: 0
Output Summary: Artifact downloaded; `cov.xml` present at the directory root (used for extraction).

## Class block extraction

Command: sed -n '/cleanup_worktrees_scan_helper\.sh"/,/<\/class>/p' <session-scratchpad>/kcov-final-706/cov.xml
EXIT_CODE: 0
Output Summary: Class `cleanup_worktrees_scan_helper_sh__41`, filename `scripts/bash/cleanup_worktrees_scan_helper.sh`, line-rate="0.875".

Zero-hit lines in the block: 55, 70, 113, 114, 152, 170, 171 (the same seven pre-existing uncovered statements as the baseline, shifted by the inserted lines).

## Counts

Command: grep -c '<line ' <class block>
EXIT_CODE: 0
Output Summary: 56

Command: grep -c 'hits="0"' <class block>
EXIT_CODE: 0
Output Summary: 7

## Result

- line-rate: 0.875 (at least 0.85)
- Total instrumented lines: 56
- Zero-hit lines: 7
- Covered/total: 49/56
