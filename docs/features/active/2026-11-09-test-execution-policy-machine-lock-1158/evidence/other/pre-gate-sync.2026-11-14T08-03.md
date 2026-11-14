# Pre-Gate Sync (P6-T9), corrected record

Timestamp: 2026-11-14T08-03
Command: `git log --oneline --merges origin/main` filtered by sibling branch names; the commands and results of `pre-gate-sync.2026-11-14T08-02.md` otherwise apply unchanged
EXIT_CODE: 0
Output Summary: this record supersedes the sibling table of `pre-gate-sync.2026-11-14T08-02.md`, which stated #1156 as merged and #1162 as unobserved without a check. A check of the merge commits on `origin/main` finds the pull requests of #1157 (#1171), #1160 (#1174), #1161 (#1176), and #1163 (#1170) merged, and no merge for #1156, #1159, or #1162. Every other statement of the earlier record stands: plain merge with no conflict, registration branch A in force, ledger entry `0012` in force, no re-application needed, ledger tests 20 passed, Registration test 8 passed, `test-execution-command-form.Tests.ps1` 322 passed, `parallel-gate-wording.Tests.ps1` 88 passed, pytest contract selection 84 passed, generator `--check` exit 0, `git status --porcelain` empty after the merge commit.

## Sibling Status (verified)

| Sibling | Merged into `origin/main` | Effect on this item |
|---|---|---|
| #1156 | no | none |
| #1157 | yes (PR #1171) | none on this item's files beyond text merges |
| #1159 | no | registration branch A in force; no `pretooluse-dispatch.json` registry exists at `.claude/hooks/` or `.codex/hooks/`, so there are no #1159 registry or timeout-sum tests to name |
| #1160 | yes (PR #1174) | `Read-CommandLineInvocationSegment` and `Skip-CommandLineTransparentWrapper` changed since P0-T1; `test-execution-command-form.Tests.ps1` re-run as a debugging run: 322 passed |
| #1161 | yes (PR #1176) | none |
| #1162 | no | none |
| #1163 | yes (PR #1170) | none |
