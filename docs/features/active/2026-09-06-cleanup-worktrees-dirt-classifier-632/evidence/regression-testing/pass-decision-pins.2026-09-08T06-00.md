# Pass — the two recorded decisions are pinned

Timestamp: 2026-09-08T07-10

Task: [P7-T6] of `remediation-plan.2026-09-08T05-00.md`
Findings: R6a (Decision A) and R6b (Decision B)

Command:

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_regression.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats
```

EXIT_CODE: 0

TAP plan line: `1..36`
Lines beginning `ok`: 36
Lines beginning `not ok`: 0

## The two descriptions quoted in [P7-T4] and [P7-T5]

```
ok 12 report mode over dirty_worktree_status_error returns the status read exit code and emits no dirt record
ok 36 no status read the classifier issues carries --ignored
```

## What each pins

The first pins Decision A. Report mode over `dirty_worktree_status_error` exits 128 — the
exit code the fixture's `status._repo-wt_dirty.rc` supplies — and emits no `DIRTFILE|` and no
`DIRTSUM|` record for that worktree. The `WORKTREE|/repo-wt/dirty|feature-dirty|` record is
asserted as the positive control, so the two absence assertions cannot pass merely because
nothing ran. Before this test the behaviour existed and nothing held it; the byte-identity
suite pinned this scenario in apply mode only.

The second pins Decision B. No status read the classifier issues carries `--ignored`, with
`status --porcelain` in the argv log as the positive control. This is the assertion that
stops `DISPOSABLE_SESSION_ARTIFACT` being made reachable in drm-copilot by the one change
that would do it, which would at the same time pull every ignored build output into the
classified set and, for any entry matching a disposable rung, into the cleared set.

## Documentation half

Both decisions are also documented in `.claude/skills/cleanup-merged-worktrees/SKILL.md`
`## Report Line Contract`, mirrored byte-identically into the bundle copy, recorded at
`evidence/qa-gates/skill-mirror-parity.2026-09-08T06-00.md`, and carried by new acceptance
criteria AC-43 and AC-44 in `spec.md`.

Output Summary: All 36 tests across the two suites pass with exit code 0 and 0 `not ok`
lines. [P7-T7] demonstrates the report-mode exit pin can fail.
