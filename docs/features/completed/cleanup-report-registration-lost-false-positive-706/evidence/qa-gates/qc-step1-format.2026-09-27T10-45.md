# QC Step 1: Format (P4-T1), pass 2

Timestamp: 2026-09-27T10-45
Route: P0-T9 recorded `LOCAL-DRIFT: NONE`, so the repo-wide `format` command was used.
Reason for pass 2: the pass-1 CI run 36325350057 failed (see `ci-shell-coverage.2026-09-27T10-38.md`); three appended bats blocks were changed to load the helper through `load_helper`.

## Pre-pass observation

Command: git status --porcelain -- scripts/ tools/ .claude/lib/bash/
EXIT_CODE: 0
Output Summary: Empty listing.

Command: sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: fee0479ead8204a294eb3c453ba31e0a653c7976a92e13bd88bbb7d25070274f

## Format

Command: sh scripts/bash/shell-qc.sh format
EXIT_CODE: 0
Output Summary: The formatter printed nothing and exited 0.

## Post-pass observation

Command: git status --porcelain -- scripts/ tools/ .claude/lib/bash/
EXIT_CODE: 0
Output Summary: Empty listing, identical to the pre-pass listing.

Command: sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: fee0479ead8204a294eb3c453ba31e0a653c7976a92e13bd88bbb7d25070274f -- equal to the pre-pass hash. No file was rewritten.
