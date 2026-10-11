# Git Baseline (Remediation Cycle 1)

Timestamp: 2026-10-08T21-57

## Step 1

Command: git fetch origin
EXIT_CODE: 0
Output Summary: no output (fetch completed).

## Step 2

Command: git branch --show-current
EXIT_CODE: 0
Output Summary: c1a-824-resume

## Step 3

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: two lines, both under FEATURE/ (plan checklist state from [P0-T1]-[P0-T5] and the new remediation-baseline folder):

```text
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md
?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/
```

## Step 4

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: 2b1489be08be78a2ff59cbfdb25a0a46c551999e

## Step 5

Command: git rev-parse origin/bug/promotion-hook-raw-containment-false-positive-deny-exec-824
EXIT_CODE: 0
Output Summary: 2b1489be08be78a2ff59cbfdb25a0a46c551999e

## Step 6

Command: git rev-parse origin/epic/enforcement-hook-precision-integration
EXIT_CODE: 0
Output Summary: e1433ff3a51d386e6df953efaf10943592aff84b

## Recorded values

HEAD_SHA: 2b1489be08be78a2ff59cbfdb25a0a46c551999e
REMOTE_SHA: 2b1489be08be78a2ff59cbfdb25a0a46c551999e
INTEGRATION_SHA: e1433ff3a51d386e6df953efaf10943592aff84b
HEAD_EQUALS_REMOTE: true

## [P0-T12] Phase 0 commit and push

Timestamp: 2026-10-08T22-12

Command: git add -- docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md
EXIT_CODE: 0
Output Summary: no output.

Command: git commit -m "docs(824): record remediation cycle 1 baseline" -m "Co-Authored-By: ..." -m "Claude-Session: ..." -- <same two paths>
EXIT_CODE: 0
Output Summary: [c1a-824-resume af036e0f] docs(824): record remediation cycle 1 baseline; 8 files changed, 425 insertions(+), 11 deletions(-).

Command: git push origin HEAD:bug/promotion-hook-raw-containment-false-positive-deny-exec-824
EXIT_CODE: 0
Output Summary: `2b1489be..af036e0f  HEAD -> bug/promotion-hook-raw-containment-false-positive-deny-exec-824` (fast-forward; no forced update).

Command: git status --porcelain (post-push listing)
EXIT_CODE: 0
Output Summary: empty.

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: af036e0fedf8db317c7c9aa74f1880b7f02df2ca

PRE_MERGE_SHA: af036e0fedf8db317c7c9aa74f1880b7f02df2ca

Command: git status --porcelain (post-append listing)
EXIT_CODE: 0
Output Summary: exactly one line:

```text
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/git-baseline.2026-10-08T21-57.md
```
