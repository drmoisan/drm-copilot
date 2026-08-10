# QA Gate — RI-4 `.gitignore` Anchoring Verification

Timestamp: 2026-08-10T21-44
Issue: #462
Task: [P1-T2] (verifies the [P1-T1] edit)
File under change: `.gitignore`

## Change Applied (P1-T1)

- Line 20 `lib/` -> `/lib/`
- Line 38 `lib64/` -> `/lib64/`
- Deleted negation lines 22-25, 29-32, 36-37 and the explanatory comment lines 21, 26-27, 33-35 that
  existed only to counteract the unanchored form.
- Line 28 `.claude/worktrees` preserved in place; every other line unchanged.

`git diff -- .gitignore` shows exactly those changes and nothing else. `grep -n "^!" .gitignore |
grep -c "lib"` reports `0`: no negation line referencing `lib` remains. Four unrelated negation lines
(63-66, `codex-and-agents-customizations/.agents` and `.codex`) are untouched and out of scope.

## Command (a) — the five formerly-negated paths must be unignored

Command:

```
git check-ignore -v extensions/drm-copilot/src/lib extensions/drm-copilot/test/lib .claude/lib extensions/drm-copilot/resources/claude-customizations/.claude/lib tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh
```

EXIT_CODE: 1

Output Summary: empty output. `git check-ignore` exits 1 when none of the supplied paths is ignored,
so exit 1 with no output is the pass condition for this check. All five paths — including the
Shell-QC discovery fixture `tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh` whose silent
exclusion motivated RI-4 — are unignored without needing any negation line.

## Command (b) — positive control: the anchored rule still catches the real build artifact

Command: `git check-ignore -v lib/placeholder.txt`

EXIT_CODE: 0

Output Summary:

```
.gitignore:20:/lib/	lib/placeholder.txt
```

The repository-root `lib/` Python build artifact is still ignored, and the matching rule is reported
as the anchored `/lib/` at line 20. The anchoring narrowed the rule without disabling it.

## Command (c) — no newly untracked files

Command: `git status --porcelain`

EXIT_CODE: 0

Output Summary:

```
 M .gitignore
?? docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/remediation-baseline/
?? docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/remediation-inputs.2026-08-10T21-03.md
?? docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/remediation-plan.2026-08-10T21-03.md
```

The only modification is `.gitignore` itself. The three untracked entries are this cycle's own
artifacts: the remediation inputs and plan (already untracked before the edit, per the session-start
`git status`) and the Phase 0 evidence directory created by P0-T1 through P0-T4. No production file
became newly untracked and no previously-tracked file became ignored.

## Discriminating-Power Note

Checks (a) and (c) are non-discriminating: both produce these same results before the P1-T1 edit,
because the deleted negation lines were already re-including the five paths. They are retained as a
regression guard proving the deletions did not re-expose any path. The discriminating evidence for
RI-4 is the P1-T1 `git diff` acceptance (the two anchoring edits plus the eight negation deletions)
together with check (b), which shows the surviving rule is now the anchored `/lib/` form rather than
the unanchored `lib/` form.

Output Summary: All five named paths are unignored (exit 1, empty). The positive control confirms
`/lib/` still ignores the root build artifact. `git status` shows no newly untracked file. RI-4 is
delivered: the rule is root-anchored and the eight compensating negation lines are gone.
