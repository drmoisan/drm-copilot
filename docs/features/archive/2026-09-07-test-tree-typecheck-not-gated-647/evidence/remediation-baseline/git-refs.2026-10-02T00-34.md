# Git References — Remediation Cycle 1 Baseline (issue #647)

Timestamp: 2026-10-02T00-34
Command: git branch --show-current; git rev-parse HEAD; git merge-base origin/main HEAD; git status --porcelain --untracked-files=all; echo "EXIT=$?"
EXIT_CODE: 0
Output Summary:
- Branch: `bug/test-tree-typecheck-not-gated-647` (expected value; pass).
- P0_HEAD_SHA: `933cf50683810d7ee7a5cac62d788f175926d4a3` (40 hexadecimal characters).
- BASE_SHA: `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9` (40 hexadecimal characters); equals the audit base `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9`: yes.
- No path outside `FEATURE/` is listed: pass.

Status output (verbatim):

```
 M docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/remediation-plan.2026-10-02T00-06.md
?? docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/evidence/other/remediation-1-preflight-round-3.2026-10-02T00-34.md
?? docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/evidence/remediation-baseline/phase0-instructions-read.2026-10-02T00-34.md
```

PRE_EXISTING_FEATURE_PATHS:

- `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/evidence/other/remediation-1-preflight-round-3.2026-10-02T00-34.md`
