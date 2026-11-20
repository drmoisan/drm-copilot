# Gate — no force flag reaches any staging call

Timestamp: 2026-09-08T10-30
Task: `[P4-T3]`
Command: grep -n -F -- cleanup_wt_git scripts/bash/cleanup_worktrees_preserve_lib.sh
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Six matched lines, each inspected below. The two that are actual invocations pass
`check-ignore -q` and `add` respectively; neither carries `-f` or `--force`, and no other line in
the file invokes the seam. Verdict PASS on every matched line.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -n -F -- cleanup_wt_git /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5/scripts/bash/cleanup_worktrees_preserve_lib.sh'"`
- Substitute actually run: the identical `grep -n -F --` invocation executed locally in Git Bash
  against the same file by absolute path. Only the shell that hosts `grep` differs; the tool, the
  flags, the search literal, and the file are the same, so the observation is the same one the plan
  specifies.
- Reason: the `pwsh`-wrapped WSL form is refused unconditionally in this worktree by the
  harness-level isolation guard, and a bare `wsl` invocation is prohibited by binding amendment
  EA-1.

## Matched lines, verbatim, with the verdict for each

     12:# cleanup_worktrees_actions_lib.sh, because it calls cleanup_wt_git (defined in the
     23:# Seams. All git commands go through cleanup_wt_git (CLEANUP_WT_GIT_BIN). The jq binary
     36:# require -f. No cleanup_wt_git invocation in this library passes -f or --force ever.
     41:  # Mirrors the resolution and 127 contract of cleanup_wt_git exactly: when
    270:  if cleanup_wt_git -C "$PRESERVE_CWT" check-ignore -q -- "$tgt"; then
    359:    elif ! cleanup_wt_git -C "$PRESERVE_CWT" add -- "$tgt"; then

| Line | Kind | Verdict |
| --- | --- | --- |
| 12 | Header comment naming the dependency | PASS — not an invocation |
| 23 | Header comment naming the seam | PASS — not an invocation |
| 36 | Header comment stating the prohibition itself | PASS — not an invocation |
| 41 | Function comment citing the 127 contract | PASS — not an invocation |
| 270 | Invocation: `-C <worktree> check-ignore -q -- <target>` | PASS — no `-f`, no `--force` |
| 359 | Invocation: `-C <worktree> add -- <target>` | PASS — no `-f`, no `--force` |

Two of the six matched lines are invocations and four are comments. Both invocations were read in
full and neither carries a force flag in any position.

## Why a file-scoped search for `-f` alone is not used

`[P4-T1]` and `[P4-T2]` require file-existence checks, which are ordinarily written with a `-f`
file test, so a file-scoped search for the bare token `-f` matches whatever the implementation does
and could not fail. The matched-line inspection above is scoped to the seam and can fail: adding
`--force` to either invocation would make the corresponding row read FAIL.

## Companion behavioral assertion

The source-level prohibition recorded here is one half. The other half is behavioral and lives in
the test `an ignored target path is refused without a force flag`: on the refusal path no staging
call is made at all, so a force-flag search over that path's output would hold whatever the
implementation did. That test asserts the absence of the extended regular expression
`stub-git: .*[[:space:]]add[[:space:]]`, which is the plan's prescribed substitution for AC-30's
unsatisfiable literal.

Verdict: PASS.
