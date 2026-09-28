# Final QA loop — shell-qc format (P5-T1)

Timestamp: 2026-09-08T10-00
WorkingDirectory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`

The working directory is the worktree root, the same one P0-T3 used, because
`discover_shell_scripts` collects its roots as the relative paths `tools`, `scripts` and
`.claude/lib/bash` (`shell_qc_lib.sh:85`) and returns nothing at all from any other directory.

Command: `bash scripts/bash/shell-qc.sh format`
EXIT_CODE: 0

## Output Summary

The command's combined stdout and stderr was empty. Reproduced verbatim:

```
```

The captured stream measured 0 bytes. `run_format` (`shell_qc_lib.sh:204-224`) prints nothing on
success, so the empty stream is the expected shape and carries no information about whether a file
was rewritten. The observations below are what answer that question.

## The four observation fields

StatusBefore: (empty)

StatusAfter: (empty)

TreeDigestBefore: DENIED
TreeDigestAfter: DENIED

`git status --porcelain` printed nothing before the run and nothing after it, so both fields carry
the literal `(empty)` as the task's acceptance provides for. `StatusAfter` lists no path absent from
`StatusBefore`, because both listings are empty.

## The two digest fields are denied by the environment

The task requires the digests to be computed with the identical command P0-T3 names. That command
was issued and refused:

```
bash -c 'source scripts/bash/shell_qc_lib.sh; discover_shell_scripts' | LC_ALL=C sort | xargs md5sum | md5sum
```

```
This agent is isolated in the worktree C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d,
but this command hands bash the text source scripts/bash/shell_qc_lib.sh;…, which runs source in a
plain command; what it reads or is handed as shell text cannot be shown not to run git. Refusing to
run it — a worktree-isolated agent's git operations must target its own worktree.
```

EXIT_CODE: DENIED

The permission layer refuses any command line containing `source`, and `source` is the only route to
`discover_shell_scripts` because `shell-qc.sh` exposes no subcommand that prints the discovered file
list. The denial is a property of the environment, not of this run. It is the same denial recorded
for P0-T3 in `evidence/remediation-baseline/shell-qc-format.2026-09-08T07-30.md` and adjudicated in
`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`.

**No digest value is assumed, inferred, or substituted into `TreeDigestBefore:` or
`TreeDigestAfter:`.** Because those two fields cannot be produced, this task's acceptance — which
requires all four observation fields present and the two digest fields non-empty — is **not met**,
and **[P5-T1] remains unchecked**, exactly as P0-T3 does.

## Supplementary observation, clearly not the denied digest

The following is recorded as a separate, weaker channel and is **not** the value of either digest
field above. A `-name '*.sh'` digest was taken over the two discovery roots that exist in this tree,
the command was run a second time, and the digest was taken again:

Command: `find scripts .claude/lib/bash -type f -name '*.sh' | LC_ALL=C sort | xargs md5sum | md5sum`
EXIT_CODE: 0

ShDigestBeforeSecondRun: 1867505c43f7bda96924b9dfa1ff2d56
ShDigestAfterSecondRun: 1867505c43f7bda96924b9dfa1ff2d56

The two are equal. `tools/` does not exist in this tree, so the discovery roots reduce to `scripts`
and `.claude/lib/bash`; the P0-T3 adjudication verified that every file under those two roots
carrying a `^#!.*\b(bash|sh)\b` shebang has a `.sh` suffix, so `discover_shell_scripts` and the
`-name '*.sh'` predicate select the same set here and this weaker digest's blind spot over the
denied one is an empty set. This is a supplementary observation only; it does not discharge the
acceptance.

## Did the write-mode run rewrite any file?

No. No path was rewritten, and the artifact therefore lists none.

Two independent observations support that. First, `git status --porcelain` is empty both before and
after the run: the tree was clean at the Phase 4 commit `e8fe310f` and is clean after, so no tracked
file changed and no untracked file appeared. A rewrite of any tracked file — with or without a `.sh`
suffix — would have appeared in `StatusAfter`, and an untracked discovered script would have
appeared as a `??` entry in `StatusBefore`, of which there are none. Second, the supplementary
digest above is unchanged across a further invocation of the same command.

The two digests could not be compared because both are denied, so the sentence "the two digests are
equal" is not asserted here. The toolchain loop is therefore **not** restarted on a digest
difference; the restart condition the task names is unevaluable, and the status channel shows no
rewrite to review.
