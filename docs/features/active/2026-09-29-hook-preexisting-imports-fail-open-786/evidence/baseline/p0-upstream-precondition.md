# Upstream Precondition ([P0-T5])

Timestamp: 2026-10-09T21-54
Command: git log --merges --first-parent --format=%H%x09%s origin/epic/enforcement-hook-precision-integration; gh pr list --repo drmoisan/drm-copilot --base epic/enforcement-hook-precision-integration --state merged --limit 200 --json number,headRefName,mergeCommit; git merge-base --is-ancestor <mergeCommit.oid> origin/epic/enforcement-hook-precision-integration (per selected PR)
EXIT_CODE: 0
Output Summary: #732, #850, and #787 are each merged into epic/enforcement-hook-precision-integration (one matching merge subject each; one matching merged PR each, ancestry exit code 0).

## N = 732

- (i) subjects matching `^Merge pull request #\d+ from \S+-732$`: 1
  - `73201b5fe7a2106d07b3e0a4f55a72ede6a1965c	Merge pull request #858 from drmoisan/bug/exempt-operand-bypass-brace-and-dot-segments-exec-732`
- (ii) PRs with headRefName ending `-732`: #858 `bug/exempt-operand-bypass-brace-and-dot-segments-exec-732`, mergeCommit `73201b5fe7a2106d07b3e0a4f55a72ede6a1965c`, ancestry exit code 0

## N = 850

- (i) subjects matching: 1
  - `f8f7d0ab1b0ed927cccfedd25608a48d28083c57	Merge pull request #857 from drmoisan/bug/pr-author-and-merge-gates-read-session-root-files-exec-850`
- (ii) PRs: #857 `bug/pr-author-and-merge-gates-read-session-root-files-exec-850`, mergeCommit `f8f7d0ab1b0ed927cccfedd25608a48d28083c57`, ancestry exit code 0

## N = 787

- (i) subjects matching: 1
  - `191e69069d0198ef66be581568da781ea89fa3fb	Merge pull request #856 from drmoisan/bug/validate-orchestrator-output-session-relative-read-exec-787`
- (ii) PRs: #856 `bug/validate-orchestrator-output-session-relative-read-exec-787`, mergeCommit `191e69069d0198ef66be581568da781ea89fa3fb`, ancestry exit code 0

UPSTREAM-732: PRESENT
UPSTREAM-850: PRESENT
UPSTREAM-787: PRESENT
