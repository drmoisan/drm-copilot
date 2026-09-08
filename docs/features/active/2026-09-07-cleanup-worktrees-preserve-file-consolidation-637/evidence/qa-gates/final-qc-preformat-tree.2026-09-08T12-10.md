# Final QC — `[P10-T1]`, the pre-format tree state and the pre-format drift signal

Timestamp: 2026-09-08T12-10
Task: `[P10-T1]`
Command: bash scripts/bash/shell-qc.sh check
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: The `check` span exited 0 with completely empty output: the `shfmt -d` stage printed
**no diff hunk** and `shellcheck` printed **0 findings**. The pre-format porcelain listing, scoped to
`scripts tools .claude/lib/bash`, is **empty**; that span exited 0. Twenty-four shell scripts were
discovered and both tools resolved, so the empty output is a clean pass and not a skipped stage.

## Route substitution, recorded rather than silently taken

The plan's span two is
`pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh check'"`.
That wrapped form is refused unconditionally in this agent-isolated worktree by the harness-level
isolation guard, and a bare `wsl` invocation is prohibited. The substitute is the same command run
directly in Git Bash on the Windows side:

    cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5
    bash scripts/bash/shell-qc.sh check

The substitution is sound for this stage because `shfmt` and `shellcheck` are both resolvable on the
Git Bash PATH, which is what the `check` stage needs and all it needs. The stages that are genuinely
unavailable locally are the ones requiring `bats` and `kcov`, neither of which is installed here;
those are `[P10-T4]` and `[P10-T6]` and both are left to the final CI round.

## Span one — the pre-format porcelain listing

    Command: git status --porcelain -- scripts tools .claude/lib/bash
    EXIT_CODE: 0
    Output: (empty)

The listing is empty. The pathspec names the three roots `discover_shell_scripts` walks at
`scripts/bash/shell_qc_lib.sh` line 85, which are the only paths `shfmt -w` can rewrite. `tools` does
not exist in this tree; `git status` exits 0 on a pathspec operand that matches nothing.

An empty pre-format listing is the strongest state this comparison can be in: every file the format
stage can reach is tracked and clean, which is exactly the case in which a porcelain comparison
discriminates. The coverage-remediation work that preceded this task added files only under
`tests/`, which the format stage does not walk and this pathspec does not observe.

## Span two — the pre-format drift and lint signal

    Command: bash scripts/bash/shell-qc.sh check
    EXIT_CODE: 0
    Output: (empty — zero bytes)

Recorded separately as the plan requires:

- **`shfmt -d` diff hunks printed: none.** `run_check` at `scripts/bash/shell_qc_lib.sh` lines
  186-191 runs `shfmt -d` once over the full discovered file list and captures its exit code without
  aborting. A differing file makes `shfmt -d` print a unified diff and return non-zero, which would
  have raised `exit_code`. The command exited 0 and printed nothing, so no file differs from its
  formatted form.
- **`shellcheck` findings printed: 0.** Lines 194-200 lint each discovered file independently. Any
  finding would have been printed and would have raised `exit_code`.

The empty output is not the no-scripts path and not a missing-tool path. `run_check` prints
`No shell scripts found; skipping.` when the file list is empty and prints a five-line
`Missing required tool:` block and returns 127 when either tool is unresolvable. Neither string
appears. The discovery and resolution were confirmed directly:

    discovered=24
    shfmt=/c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/mvdan.shfmt_.../shfmt
    shellcheck=/c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/koalaman.shellcheck_.../shellcheck
    shfmt_version=v3.12.0
    shellcheck_version=version: 0.11.0

**This observation is the primary no-rewrite evidence for `[P10-T2]`.** A pre-format `shfmt -d` run
that printed no diff hunk establishes that the `shfmt -w` which follows it has nothing to rewrite.
The porcelain comparison in `[P10-T2]` is corroborating rather than primary, as the plan's
`## Write-mode observation for shell-qc.sh format` section states.

This task does not require exit 0; it is an observation. It exited 0 regardless.
