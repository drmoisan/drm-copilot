# Baseline — targeted bats run output shape

Timestamp: 2026-09-08T05-43

Task: [P0-T6] of `remediation-plan.2026-09-08T05-00.md`

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_regression.bats`

EXIT_CODE: 0

## First three output lines, verbatim

```
1..11
ok 1 report mode output for merged_with_worktree is byte-identical to the checked-in expected output
ok 2 report mode output for merged_no_worktree is byte-identical to the checked-in expected output
```

TAP plan line: `1..11`
Lines beginning `ok`: 11
Lines beginning `not ok`: 0

## Observed passing-line prefix, verbatim

`ok 1 report mode output for merged_with_worktree is byte-identical to the checked-in expected output`

The prefix form for a passing test is `ok <n> <description>`: the literal `ok`, one space,
the one-based ordinal, one space, then the test description exactly as written in the
`@test` header, with no separating punctuation and no trailing annotation.

## Observed failing-line prefix

The form for a failing test is `not ok <n> <description>`, followed by indented `# ` diagnostic
lines carrying the failing assertion and its line number. No test failed in this run, so the
failing form is recorded from the TAP specification the `tap` formatter implements rather than
observed here; every acceptance condition in the plan that reads a failing line searches for
the substring `not ok` together with the test description, and both halves of that search are
satisfied by this form.

Output Summary: The targeted run passed with exit code 0. The plan line is `1..11`, there
are 11 `ok` lines and 0 `not ok` lines. The observed passing-line form is exactly
`ok <n> <description>`, which is the form every later acceptance condition in this plan
assumes, so no later condition needs restating.
