# Minor-Audit Preconditions

Timestamp: 2026-09-30T09-28

Plan task: [P0-T2]

Command: git grep --untracked -n -F -e "## Acceptance Criteria" -- docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/issue.md

EXIT_CODE: 0

Output Summary: The `## Acceptance Criteria` heading occurs exactly once in `issue.md` (line 27); `issue.md` holds 7 unchecked `AC-` items; `spec.md` and `user-story.md` are absent (empty `git ls-files` output). All three minor-audit preconditions hold.

## Step 1 - Acceptance Criteria heading

Command: git grep --untracked -n -F -e "## Acceptance Criteria" -- docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/issue.md

EXIT_CODE: 0

```text
docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/issue.md:27:## Acceptance Criteria
```

Line count of output: 1

## Step 2 - Unchecked AC count

Command: git grep --untracked -c -e "^- \[ \] AC-" -- docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/issue.md

EXIT_CODE: 0

```text
docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/issue.md:7
```

The count output ends with `:7`.

## Step 3 - spec.md and user-story.md absence

Command: git ls-files --cached --others --exclude-standard -- docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/spec.md docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/user-story.md

EXIT_CODE: 0

```text
(empty output)
```

## Result

GREEN: one heading line, count `:7`, empty `git ls-files` output.
