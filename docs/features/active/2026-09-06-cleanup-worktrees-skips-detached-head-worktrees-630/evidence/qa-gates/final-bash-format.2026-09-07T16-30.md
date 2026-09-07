# Final QC Stage 1 — Bash Format

Timestamp: 2026-09-07T16-30
Task: [P6-T1]
Iteration: 1

Command: `sh scripts/bash/shell-qc.sh format`
EXIT_CODE: 0

`format` runs `shfmt -w` and prints nothing on a clean run. Its exit code is 0 whether or not it
rewrote a file, so the exit code alone does not distinguish a clean run from a repairing one. The
observation used here is the read-only `PreCheck:` run together with the byte-identity of the
`Before:` and `After:` porcelain listings.

## (a0) PreCheck — read-only

Command: `sh scripts/bash/shell-qc.sh check`
EXIT_CODE: 0

PreCheck: (empty — 0 bytes on stdout and 0 bytes on stderr)

`check` runs `shfmt -d` once over the discovered file list and then `shellcheck` once per discovered
file. `shfmt -d` prints a unified diff for any unformatted discovered file, so empty output before
`format` runs is positive evidence that `format` had nothing to repair.

## (a) Before

Command: `git status --porcelain -- tools scripts .claude/lib/bash`
EXIT_CODE: 0

Before:

```
 M scripts/bash/cleanup-worktrees.sh
```

## (b) Format

Command: `sh scripts/bash/shell-qc.sh format`
EXIT_CODE: 0

The command printed no output on stdout or stderr.

## (c) After

Command: `git status --porcelain -- tools scripts .claude/lib/bash`
EXIT_CODE: 0

After:

```
 M scripts/bash/cleanup-worktrees.sh
```

## Byte-identity assertion

The `Before:` and `After:` listings are byte-identical to each other. Both consist of the single
line ` M scripts/bash/cleanup-worktrees.sh`.

The listing is non-empty on this run. Phase 5 task [P5-T5] added an operator-facing paragraph to the
`usage()` heredoc of `scripts/bash/cleanup-worktrees.sh`, and that change was not yet committed when
this stage ran, so the porcelain span reports one modified tracked path. Byte-identity across a
non-empty listing is a stronger observation than byte-identity across two empty listings: an empty
pair only shows that no path entered the span, whereas this pair shows that a tracked file already
carrying an uncommitted modification was not further rewritten by `format`. Had `shfmt -w`
reformatted any other discovered file, that file would have appeared as an additional line in the
`After:` listing and the two listings would have differed.

Output Summary: `format` printed no output and exited 0. The `PreCheck:` output is empty on both
stdout and stderr with exit code 0. The `Before:` and `After:` porcelain listings are byte-identical
to each other, each carrying the single line ` M scripts/bash/cleanup-worktrees.sh`. No file was
rewritten by this stage, so no restart of the loop is required. This is iteration 1.
