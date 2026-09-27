# Baseline Per-File Coverage: scripts/bash/cleanup_worktrees_scan_helper.sh (P0-T14)

Timestamp: 2026-09-27T10-10
RUN_ID: 36324413557

## Download

Command: gh run download 36324413557 --name shell-coverage --dir <session-scratchpad>/kcov-baseline-706
EXIT_CODE: 0
Output Summary: Artifact downloaded; `cov.xml` present at the directory root (used for extraction).

## Class block extraction

Command: sed -n '/cleanup_worktrees_scan_helper\.sh"/,/<\/class>/p' <session-scratchpad>/kcov-baseline-706/cov.xml
EXIT_CODE: 0
Output Summary: Class `cleanup_worktrees_scan_helper_sh__41`, filename `scripts/bash/cleanup_worktrees_scan_helper.sh`, line-rate="0.868".

Zero-hit lines in the block: 54, 69, 88, 89, 127, 145, 146.

## Counts

Command: grep -c '<line ' <class block>
EXIT_CODE: 0
Output Summary: 53

Command: grep -c 'hits="0"' <class block>
EXIT_CODE: 0
Output Summary: 7

## Pre-change line numbers

Command: git show 849aae609787172240c1ae7c33d10d6dd337d497:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -n -F -e 'if [[ $target != /* ]]; then' -e 'target="$dir/$target"' -e 'if [[ -e $target ]]; then'
EXIT_CODE: 0
Output Summary: `91:	if [[ $target != /* ]]; then`, `92:		target="$dir/$target"`, `94:	if [[ -e $target ]]; then`.

## Result

- line-rate: 0.868
- Total instrumented lines: 53
- Zero-hit lines: 7
- Covered/total: 46/53 (matches the 2026-09-08 figure)
- Pre-change line 91 (`if [[ $target != /* ]]; then`): hits=1
- Pre-change line 92 (`target="$dir/$target"`): hits=1
- Pre-change line 94 (`if [[ -e $target ]]; then`): hits=1
