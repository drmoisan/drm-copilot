# P4-T1 — bash format pre-seal (before bundle mirror)

Timestamp: 2026-08-30T07-47

Command:
`wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && { digest() { bash -c "source scripts/bash/shell_qc_lib.sh; discover_shell_scripts" | xargs sha256sum | sha256sum; }; echo "BEFORE=$(digest)"; rc=0; bash scripts/bash/shell-qc.sh format || rc=$?; echo "FORMAT_RC=${rc}"; echo "AFTER=$(digest)"; git status --porcelain -- .claude/lib/bash tests/shell scripts tools; exit "$rc"; } > /tmp/p4t1.txt 2>&1'`

EXIT_CODE: 0

Output Summary:

```
BEFORE=9ea52de8b8c26b9a0d84ba71c7a22a9c7754105d663af2fed6498ae6e5a57a0d  -
FORMAT_RC=0
AFTER=9ea52de8b8c26b9a0d84ba71c7a22a9c7754105d663af2fed6498ae6e5a57a0d  -
fatal: not a git repository: /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501/C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/agent-ab2cbeea5d3050501
```

Acceptance evaluation:

- `EXIT_CODE: 0` — met (the trailing `exit "$rc"` re-raises the formatter's own status).
- `FORMAT_RC=0` — met.
- `BEFORE=` and `AFTER=` identical — met
  (`9ea52de8b8c26b9a0d84ba71c7a22a9c7754105d663af2fed6498ae6e5a57a0d`). The digest is taken over the
  exact file set `run_format` writes, so identity means `shfmt -w` rewrote no discovered file.

## Deviation 1 — inner redirection was required to capture stdout

The plan's command form as written loses all stdout when it is invoked through `wsl.exe` from the
harness: the recorded output contained only the `git` stderr line and none of the three `echo`
lines, reproducibly, across two invocations. Wrapping the sequence in `{ ...; } > /tmp/p4t1.txt 2>&1`
inside the WSL command and reading that file back reproduces the full stream. The command text,
its ordering, and its `exit "$rc"` semantics are unchanged; only the capture mechanism differs.

## Deviation 2 — the porcelain span cannot run inside WSL in this worktree

`git status --porcelain` fails inside WSL with
`fatal: not a git repository: .../agent-ab2cbeea5d3050501/C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/agent-ab2cbeea5d3050501`.
The worktree's `.git` file records a Windows-absolute `gitdir:` path, which WSL resolves relative to
the current directory. This span is supplementary context in the plan's own words, not the
acceptance, so its failure does not affect the result. The equivalent listing was taken from the
Windows side instead:

```
git -C C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 status --porcelain
  -> (empty), exit 0
git -C C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 diff --name-status HEAD
  -> (empty), exit 0
```

## Stronger observation than the digest

The plan states that both new bash files are untracked for the whole of this plan and that a
porcelain listing therefore cannot discriminate a clean run from a repairing one. The tree
contradicts that: the orchestrator committed Phases 0 through 3 at `54de2daa`, so both new bash
files are tracked and the worktree was clean before this task ran. An empty
`git diff --name-status HEAD` after the formatter ran is therefore decisive on the Windows side and
covers every formatter invocation made during this task, including the first one whose stdout was
lost.

Conclusion: `shell-qc.sh format` rewrote no file. No re-mirror is required before P4-T2, and
Ordering Constraint 3 is satisfied.

## Attribution

P0-T2 recorded `shell-qc.sh check` exiting 0 with empty output against the pre-Phase-1 tree, so no
pre-existing drift could have been silently repaired by this run.
