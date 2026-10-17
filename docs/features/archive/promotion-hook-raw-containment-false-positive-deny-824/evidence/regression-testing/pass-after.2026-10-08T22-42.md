# Pass-After: Named Regression Rows (T-REG) Against the Delivered Production Tree ([P8-T1])

Timestamp: 2026-10-08T22-42
Command: sh <SCRATCHPAD>/s-pester.sh REG
EXIT_CODE: 0
Output Summary:
PESTER_SET: REG FILES=1 (tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1)
PESTER_TOTAL: 23
PESTER_PASSED: 23
PESTER_FAILED: 0
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 0
PESTER_FAILED_CONTAINERS: 0

Production state: HEAD 8c1b4892 (Phases 0-7 committed and pushed). No production file was changed for this run.

## Per-row result

| Row | Named regression | Result |
|---|---|---|
| REG-01 (claude) | R-824-MAIN | RESULT Passed |
| REG-01 (codex) | R-824-MAIN | RESULT Passed |
| REG-02 | R-824-ADD1 (Claude epic gate) | RESULT Passed |
| REG-03 | R-742-1 (Claude epic gate) | RESULT Passed |
| REG-04 | R-824-ADD1 (Claude parallel gate) | RESULT Passed |
| REG-05 | R-742-1 (Claude parallel gate) | RESULT Passed |
| REG-06 | R-824-ADD1 (Codex epic gate) | RESULT Passed |
| REG-07 | R-742-1 (Codex epic gate) | RESULT Passed |
| REG-08 (claude) | R-742-1 (preimplementation gate) | RESULT Passed |
| REG-08 (codex) | R-742-1 (preimplementation gate) | RESULT Passed |
| REG-09 | R-733-714 | RESULT Passed |
| REG-10 | R-733-GREP G1 | RESULT Passed |
| REG-11 | R-733-GREP G2 | RESULT Passed |
| REG-12 | R-733-GREP G3 | RESULT Passed |
| REG-13 | R-733-715 S1 | RESULT Passed |
| REG-14 | R-733-715 S2 | RESULT Passed |
| REG-15 | R-733-715 S3 | RESULT Passed |
| REG-16 | R-733-715 S4 | RESULT Passed |
| REG-17 | R-733-715 S5 | RESULT Passed |
| REG-18 | R-733-712 chain | RESULT Passed |
| REG-19 | R-733-712 single (git log) | RESULT Passed |
| REG-20 | R-733-712 single (sha256sum) | RESULT Passed |
| REG-21 | R-733-712 single (date) | RESULT Passed |

## RESULT lines (verbatim)

```
RESULT Passed Issue #824 regression: promotion gate (claude).REG-01 allows R-824-MAIN, whose prose only contains the letters of gh issue new
RESULT Passed Issue #824 regression: promotion gate (codex).REG-01 allows R-824-MAIN, whose prose only contains the letters of gh issue new
RESULT Passed Issue #824 regression: Claude epic worktree-removal gate.REG-02 allows R-824-ADD1, which removes a file and no worktree
RESULT Passed Issue #824 regression: Claude epic worktree-removal gate.REG-03 allows R-742-1, git --version
RESULT Passed Issue #824 regression: Claude parallel worktree-removal gate.REG-04 allows R-824-ADD1, which removes a file and no worktree
RESULT Passed Issue #824 regression: Claude parallel worktree-removal gate.REG-05 allows R-742-1, git --version
RESULT Passed Issue #824 regression: Codex epic worktree-removal gate.REG-06 returns no decision for R-824-ADD1, which removes a file and no worktree
RESULT Passed Issue #824 regression: Codex epic worktree-removal gate.REG-07 returns no decision for R-742-1, git --version
RESULT Passed Issue #824 regression: preimplementation gate (claude).REG-08 does not classify R-742-1, git --version, as an implementation command
RESULT Passed Issue #824 regression: preimplementation gate (codex).REG-08 does not classify R-742-1, git --version, as an implementation command
RESULT Passed Issue #824 regression: Claude pr-author skill gate.commands that mention gh pr create without invoking it (R-733-714, R-733-GREP).REG-09 allows R-733-714, a commit whose heredoc body contains the letters of gh pr create
RESULT Passed Issue #824 regression: Claude pr-author skill gate.commands that mention gh pr create without invoking it (R-733-714, R-733-GREP).REG-10 allows R-733-GREP G1, a Select-String search for a phrase
RESULT Passed Issue #824 regression: Claude pr-author skill gate.commands that mention gh pr create without invoking it (R-733-714, R-733-GREP).REG-11 allows R-733-GREP G2, a grep inside a command substitution
RESULT Passed Issue #824 regression: Claude pr-author skill gate.commands that mention gh pr create without invoking it (R-733-714, R-733-GREP).REG-12 allows R-733-GREP G3, a grep whose pattern is the literal gh pr create
RESULT Passed Issue #824 regression: Claude pr-author skill gate.body-file spellings reach receipt verification (R-733-715).REG-13 accepts S1, a double-quoted body-file path
RESULT Passed Issue #824 regression: Claude pr-author skill gate.body-file spellings reach receipt verification (R-733-715).REG-14 accepts S2, the --body-file= form
RESULT Passed Issue #824 regression: Claude pr-author skill gate.body-file spellings reach receipt verification (R-733-715).REG-15 accepts S3, an absolute path under the session root
RESULT Passed Issue #824 regression: Claude pr-author skill gate.body-file spellings reach receipt verification (R-733-715).REG-16 accepts S4, a ./-prefixed relative path
RESULT Passed Issue #824 regression: Claude pr-author skill gate.body-file spellings reach receipt verification (R-733-715).REG-17 accepts S5, a backslash-separated path
RESULT Passed Issue #824 regression: pr-author command allowlist.REG-18 denies the R-733-712 chained receipt procedure
RESULT Passed Issue #824 regression: pr-author command allowlist.REG-19 allows git log -1 --format=%H run alone
RESULT Passed Issue #824 regression: pr-author command allowlist.REG-20 allows sha256sum artifacts/pr_body_5.md run alone
RESULT Passed Issue #824 regression: pr-author command allowlist.REG-21 allows date -u +%Y-%m-%dT%H:%M:%SZ run alone
```
