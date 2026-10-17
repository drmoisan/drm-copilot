# Pre-edit Scope Baseline (P0-T10)

Timestamp: 2026-10-08T02-38
Command: git rev-parse HEAD ; git merge-base HEAD origin/main ; git diff --name-only 6dac65b0930b299dc7b3c3925a607735a05fca35 -- extensions/drm-copilot scripts ; git status --porcelain -- extensions/drm-copilot scripts
EXIT_CODE: 0
Output Summary: PASS. HEAD_SHA 14fecbec873920f118cd275d95b3be32c11ced37; BASE_SHA 6dac65b0930b299dc7b3c3925a607735a05fca35 (matches the DEV-3 expectation). BASELINE-DRIFT is empty (diff and status both printed nothing).

- HEAD_SHA: 14fecbec873920f118cd275d95b3be32c11ced37
- BASE_SHA: 6dac65b0930b299dc7b3c3925a607735a05fca35
- BASELINE-DRIFT: (empty)

Commands were issued as `git -C REPO <subcommand>` because the worktree isolation guard refused a `cd`-chained compound form; the subcommands and arguments are unchanged.
