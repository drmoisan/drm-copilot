# P1-T9 — Fixture listing and parity check

Timestamp: 2026-09-27T01-30
Task: [P1-T9]
Working directory: repository worktree root

## Listing

Command: `ls -1 tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree`
EXIT_CODE: 0

```
tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree:
for-each-ref.out
rev-parse.abbrev-ref-HEAD.out
rev-parse.show-toplevel.out
worktree-list.out

tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out:
for-each-ref.out
rev-parse.abbrev-ref-HEAD.out
rev-parse.show-toplevel.out
worktree-list.out
```

## Byte comparison of the two for-each-ref.out files

Command: `cmp tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/for-each-ref.out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/for-each-ref.out`
EXIT_CODE: 0

Output Summary:
- Each directory holds exactly the four names from P1-T1..P1-T4: `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`, `worktree-list.out`.
- `cmp` printed nothing and exited 0: the two `for-each-ref.out` files are byte-identical.
- Supplementary `od -c` inspection: files begin with the first content byte (no byte-order mark) and use `\n` line terminators; each `worktree-list.out` ends with `\n\n` (the terminating empty line).
- The carriage-return search is recorded separately in `fixtures-crlf-check.2026-09-27T01-30.md`.
