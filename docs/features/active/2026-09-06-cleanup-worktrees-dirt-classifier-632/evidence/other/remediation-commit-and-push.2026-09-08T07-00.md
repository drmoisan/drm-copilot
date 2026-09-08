# Remediation commit and push

Timestamp: 2026-09-08T07-52

Task: [P8-T5] of `remediation-plan.2026-09-08T05-00.md`

Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`

## Head SHAs, read on either side of the final commit

PreCommitHeadSha: a226a1c59369544fc50ed96da6ebd9d35dfc4536
PostCommitHeadSha: ea1baef8aad811c6c9d6d12e32c8ab05f636ecaa

The two values differ, so a commit landed. The comparison is stated against the pre-commit
SHA this artifact itself records rather than against a SHA quoted in the plan: a quoted SHA
goes stale on every further docs-only commit to this branch, and against a superseded SHA the
condition would hold before the executor committed anything. The self-relative form cannot go
stale, because both SHAs are read in the same task on either side of the commit.

## Commands and exit codes

```
git rev-parse HEAD
git add docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632
git commit -F - <<'EOF' ... EOF
git rev-parse HEAD
git status --porcelain
git push origin bug/cleanup-worktrees-dirt-classifier-632-r2
git diff --name-status origin/epic/cleanup-merged-worktrees-hardening-integration...HEAD
```

AddExitCode: 0
CommitExitCode: 0
PushExitCode: 0

Push output:

```
To https://github.com/drmoisan/drm-copilot.git
   d836dbb6..ea1baef8  bug/cleanup-worktrees-dirt-classifier-632-r2 -> bug/cleanup-worktrees-dirt-classifier-632-r2
```

## Working-tree status after the commit

```
git status --porcelain
```

The span is EMPTY. Nothing is unstaged, staged-but-uncommitted, or untracked.

## Anchored name-status span

```
git diff --name-status origin/epic/cleanup-merged-worktrees-hardening-integration...HEAD
```

356 entries. The four paths the acceptance condition names are all present:

```
A	scripts/bash/cleanup_worktrees_dirt_lib.sh
A	tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
M	.claude/skills/cleanup-merged-worktrees/SKILL.md
A	docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md
```

The bundle mirror
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
also appears, which is required for the push-down contract to stay green.

`scripts/bash/cleanup_worktrees_dirt_lib.sh` shows as `A` rather than `M` because the whole
classifier library is new on this branch relative to the epic integration base; this cycle
modified it, and the three-dot span reports its status against the merge base.

The coverage-evidence file was committed earlier on this branch and is therefore already
tracked; it still appears here because the three-dot span covers every commit on this branch
since the merge base with `origin/epic/cleanup-merged-worktrees-hardening-integration`.

## Why both spans are recorded

The porcelain span and the anchored name-status span are complementary and each alone is
wrong in one state: the anchored diff cannot report a newly created file until it is staged,
and the porcelain span goes empty once the commit lands. Together they establish that the
change is complete and committed.

## Commits in this remediation cycle

| SHA | Subject |
|---|---|
| `d70a9ad1` | docs(632): record remediation decisions and reconcile spec acceptance criteria |
| `a6f064be` | fix(632): gate the staged-tree rung on the porcelain Y column |
| `84151205` | fix(632): apply the rename payload split only to R and C entries |
| `58dfdafa` | fix(632): anchor the diff header skip to the forms the diff emits |
| `49591c3f` | test(632): pin the staged-tree rung in all five material directions |
| `4ad222fc` | test(632): drive the remaining fail-closed branches with checked-in scenarios |
| `a226a1c5` | docs(632): document and pin the report-mode exit code and the session-artifact decision |
| `ea1baef8` | chore(632): record the final QC gate results for the remediation cycle |

Output Summary: All three exit codes are 0, the working tree is clean, the anchored
name-status span lists all four required paths, and the recorded pre-commit and post-commit
head SHAs differ. `ea1baef8` is the pushed commit that the CI coverage dispatch in [P8-T6]
measures.
