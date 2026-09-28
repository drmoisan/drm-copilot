# P6-T15 — Non-goals untouched

Timestamp: 2026-08-30T20-45

Both commands were run from the worktree root.

## Command 1 — no committed change

```
git diff --stat origin/main...HEAD -- .claude/rules/parallel-orchestration.md .claude/skills/parallel-remove/SKILL.md .claude/hooks/enforce-discovery-artifact-gate.ps1 .claude/hooks/validate-discovery-artifact-gate.ps1
```

EXIT_CODE: 0

Output:

```
(empty)
```

## Command 2 — no working-tree change

```
git status --porcelain -- .claude/rules .claude/skills/parallel-remove .claude/hooks
```

EXIT_CODE: 0

Output:

```
(empty)
```

## Acceptance

Satisfied. Both outputs are empty, proving no committed change and no working-tree change to any
of the four non-goal files.

The status companion is required and is not redundant: a name-listing or stat diff taken against
a ref cannot observe an untracked or unstaged edit, so command 1 alone would not detect a
non-goal file modified but not committed. Command 2's path arguments are deliberately broader
than command 1's — the three parent directories rather than the four files — so an edit to any
neighbouring file in those trees would also surface here. It did not.

The `...` three-dot form in command 1 compares against the merge base of `origin/main` and
`HEAD`, so the result is unaffected by commits landing on `origin/main` after this branch was
cut.
