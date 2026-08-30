# B-2 fail-before — `mergeClaudeGitignore` drops content after an unterminated managed block

Timestamp: 2026-08-30T01-22

Task: [P3-T2] [expect-fail] of
`docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command: `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-gitignore-merge.test.ts`

Command as executed (absolute-path prefix applied; the plan's command text above is
worktree-relative and every Bash call starts outside the worktree):
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot" && npx jest test/lib/push-down/claude-gitignore-merge.test.ts`

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: The run failed as predicted. Jest reported
`Tests:       1 failed, 7 passed, 8 total`. The single failing test carries the title
`preserves content following an opening sentinel that has no closing sentinel`, which is the
test [P3-T1] added. The seven pre-existing tests passed unchanged. The prohibited flags
`--passWithNoTests`, `--onlyChanged`, and `--lastCommit` were not used.

## Asserted result line, verbatim

```
Tests:       1 failed, 7 passed, 8 total
```

## Failing test title, verbatim

```
mergeClaudeGitignore › preserves content following an opening sentinel that has no closing sentinel
```

## Complete console output, verbatim

```
FAIL test/lib/push-down/claude-gitignore-merge.test.ts
  ● mergeClaudeGitignore › preserves content following an opening sentinel that has no closing sentinel

    expect(received).toBe(expected) // Object.is equality

    - Expected  - 4
    + Received  + 1

      a/
      # BEGIN drm-copilot managed ignores
      .claude/state/
      .codex/state/
    - # END drm-copilot managed ignores
    - .old/
    - b/
    - c/
    + # END drm-copilot managed ignores
      ↵

     159 |
     160 |     // Assert
    >161 |     expect(merged).toBe(
         |                    ^
     162 |       [
     163 |         "a/",
     164 |         CLAUDE_GITIGNORE_BEGIN_SENTINEL,

      at Object.<anonymous> (test/lib/push-down/claude-gitignore-merge.test.ts:161:20)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 7 passed, 8 total
Snapshots:   0 total
Time:        0.391 s, estimated 1 s
Ran all test suites matching test/lib/push-down/claude-gitignore-merge.test.ts.
```

ANSI colour escape sequences present in the terminal rendering have been stripped from the
transcript above; no other alteration was made.

## Derivation of the failure, confirmed against the observed diff

`extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts:126` reads, before the
[P3-T3] edit:

```
  const endIndex = endOffset === -1 ? lines.length - 1 : beginIndex + endOffset;
```

For the input `"a/\n# BEGIN drm-copilot managed ignores\n.old/\nb/\nc/\n"` the line array is
`["a/", BEGIN, ".old/", "b/", "c/"]`, so `beginIndex` is 1 and `lines.slice(1).indexOf(END)`
is `-1`. `endIndex` therefore becomes `lines.length - 1`, which is 4, and `lines.slice(5)` is
empty. The three lines `.old/`, `b/`, and `c/` are dropped from the output. The Jest diff
confirms this exactly: the received text terminates at the end sentinel and the expected text
carries `.old/`, `b/`, and `c/` after it.

## Scope of the failure

The failing set is exactly one test. The seven pre-existing tests each supply either no
opening sentinel or a well-formed sentinel pair, so `endOffset === -1` is false for every one
of them and none is affected by the defective arm. `7 passed` in the result line confirms this.

## Baseline cross-reference

`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/typescript-pushdown-suite.2026-08-29T23-07.md`
recorded `7 passed, 7 total` for this same command before [P3-T1]. The total rose to 8 by
exactly the one test added, and the increment is the failing one.
