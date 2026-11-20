# Baseline — format-stage substitution record

Timestamp: 2026-09-08T09-49
Task: [P0-T7]
Command: bash scripts/bash/shell-qc.sh format (deliberately not executed at baseline)
EXIT_CODE: 0
ExpectedExitCode: 0

RouteSubstitution (twofold, both recorded because both apply to this stage):

1. **Write-mode substitution, from the plan itself.** `bash scripts/bash/shell-qc.sh format` is a
   write-mode command and is deliberately not executed at baseline. Its read-only counterpart
   `shfmt -d`, which is the first stage of `bash scripts/bash/shell-qc.sh check`, supplies the
   baseline drift signal in its place.
2. **Route substitution, from this environment.** The plan's wrapped form
   `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bash scripts/bash/shell-qc.sh format'"`
   is denied in this worktree because `pwsh` is refused unconditionally by the harness-level
   worktree-isolation guard. When the format stage is run in Phase 10 it runs through the verified
   local substitute
   `cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bash scripts/bash/shell-qc.sh format`,
   with `shfmt` taken from the Git Bash PATH. That substitution is recorded here so the Phase 10
   task inherits it rather than rediscovering it. **No write-mode format run is performed in this
   delegation.**

Output Summary:

**Rationale.** The format stage rewrites tracked source. `run_format` at
`scripts/bash/shell_qc_lib.sh` lines 204-227 calls the writer `shfmt -w` at
**`scripts/bash/shell_qc_lib.sh` line 222**, whose exact text is:

    "$shfmt_bin" -w "${files[@]}" || rc=$?

`shfmt -w` writes files in place and prints nothing on either a clean run or a repairing run, so its
stdout carries no literal distinguishing the two and its exit code is 0 in both cases. Running that
writer during Phase 0 baseline capture would silently repair any pre-existing drift, which would
turn the Phase 10 no-rewrite gate into a blanket waiver: the gate would then be asserting only that
a tree the baseline itself had already normalized was still normalized.

**Baseline signal for this stage, copied from the `[P0-T3]` artifact**
(`evidence/baseline/baseline-shell-qc-check.2026-09-08T09-49.md`):

> **`shfmt -d` stage — diff hunks printed: 0.** `shfmt -d scripts .claude/lib/bash` exited 0 and its
> combined stdout+stderr was **0 lines**. No file carries formatting drift at baseline.

That observation is the primary no-rewrite evidence the plan's
`## Write-mode observation for `shell-qc.sh format`` section relies on: a pre-format `shfmt -d` run
that printed no diff hunk establishes that a writer run afterwards has nothing to rewrite. The
before-and-after porcelain capture the Phase 10 task performs is corroborating rather than primary,
because a porcelain listing prints the same `??` line for an untracked file and the same ` M` line
for an already-modified file whether or not `shfmt -w` changed its bytes.

Verdict: PASS. The substitution is recorded and the baseline drift signal is zero.
