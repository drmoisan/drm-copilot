# QC Pass 2: Deny-Reason Tokens ([P10-T16])

Timestamp: 2026-10-08T23-24
Command: sh <SCRATCHPAD>/s-tokens.sh
EXIT_CODE: 0
Output Summary:
NEW_TOKEN: PR_AUTHOR_COMMAND_NOT_ALLOWED:
NEW_TOKEN: TARGET_WORKTREE_NOT_DERIVABLE:
NEW_TOKEN_COUNT: 2

Both new tokens are in the permitted set. `PR_AUTHOR_COMMAND_NOT_ALLOWED:` is the only new leading token. `TARGET_WORKTREE_NOT_DERIVABLE:` is the existing reason code defined at `.claude/lib/worktree-resolution/WorktreeResolution.psm1:59`, written by DC-18 as a detail after the existing leading tokens `EPIC_WORKTREE_REMOVAL_BLOCKED:` and `PARALLEL_WORKTREE_REMOVAL_BLOCKED:`. Tokens are compared case-sensitively across the 19 write-set production files at BASE_SHA 991aae0a180a09d504b59bc9460ec4b00b85d11b and now.
