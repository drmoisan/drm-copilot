# epic-merge-gate-parses-pr-number-from-whole-command-line (User Story)

- **Issue:** #591
- **Parent:** epic `cleanup-merged-worktrees-hardening` (child I, wave 1)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07
- **Work Mode:** full-bug

## Why this document exists, and what it is not

Under work mode `full-bug`, the `acceptance-criteria-tracking` skill resolves `spec.md` as the
**sole** acceptance-criteria source, and a `user-story.md` is normally not produced at all. This
document exists for one reason: `scripts/dev_tools/epic_planner_readiness.py` requires `issue.md`,
`spec.md`, and `user-story.md` to be present in every prepared epic child folder, and this feature
is a prepared child of the `cleanup-merged-worktrees-hardening` epic. Without this file, the
readiness check fails and the child cannot be handed to the epic planner.

Accordingly this document carries **no checkbox acceptance-criteria list**. The authoritative
acceptance criteria for this feature live in `spec.md`, in its `## Acceptance Criteria` section, and
nowhere else. Nothing written here adds to, narrows, or reinterprets them. If this narrative and
`spec.md` ever disagree, `spec.md` governs.

## Who is affected

**An epic or parallel orchestrator standing at the per-item merge gate.** This is the operator whose
run stops. It has completed an item's work, CI is green, the checkpoint records the item as ready,
and it issues the merge command the orchestration skills document.

**Any agent whose command text merely mentions the gated subcommand.** This is a much larger group
and most of them are not merging anything: an agent writing a memory note about the gate, appending
a lesson to a Markdown file, committing with a message that names the gate, or grepping the hooks
directory to read how the gate works. None of these executes a merge. All of them are affected.

A third group is affected without noticing: **anyone relying on the gate to enforce the merge
procedure**. The gate can be armed by text that never runs, and it can fail to arm on a merge that
does run.

## What goes wrong

The hook decides both "is this a merge I govern?" and "which pull request is it merging?" by
matching patterns against the raw text of the whole command line. It has no model of where one
command ends and the next begins, and no model of which parts of that text are quoted data rather
than instructions. Everything below follows from that.

**Things are denied that should proceed.** An orchestrator working inside a worktree whose path
contains a date-like number issues its merge with a `cd` prefix. The hook scans the entire line for
a run of digits, finds the one in the path, and compares that to the pull request the checkpoint
pinned. They do not match, so the merge is refused. The refusal is presented as a governance denial,
not as a parse error, so the operator is told the merge is unauthorized rather than that the path
prefix supplied the wrong number. The work is finished and green; the run simply stops. Separately,
an agent that writes a note naming the gated command, or commits with a message that mentions it, is
denied for the same underlying reason: the text mentions the command, so the hook treats the line as
if it were the command.

**Things proceed that should be denied.** The mirror image is the direction the original bug report
did not record, and it matters more than its rarity suggests. If the stray number the hook picks up
happens to match a *different* item that the checkpoint has authorized, the hook approves the line —
and the shell then merges the pull request the command actually named, which the checkpoint had not
authorized. Chaining two merges on one line has the same effect: the hook validates the first and
the shell runs both. In the other direction again, a merge command that places a repository option
between `gh` and its subcommand is not recognized as a merge at all, so the gate never arms and the
command passes without any check.

It is worth being precise about the consequence, because it is easy to overstate. `main` is
protected by a repository ruleset that enforces required status checks under a strict policy, so a
failing pull request cannot merge no matter what this hook decides. What these gaps allow is a
**procedure** violation — an item merging out of checkpoint order, or before its status was durably
recorded — not the merging of broken code. The gate is a procedure deterrent. The denial direction,
by contrast, has no compensating control at all: when the gate refuses a correct merge, nothing else
recovers the run.

## What "done" looks like

The hook reads the command line as a structure rather than as a string. It splits the line into
segments, resolves which spans are quoted data, and asks its two questions of one segment at a time.

For the orchestrator at the merge gate, the outcome is that the command it was told to issue works,
with or without a `cd` prefix, and regardless of what digits appear in the path. The pull request the
gate checks is the one the command actually names — read from that invocation's own operand, whether
that operand is a number before the strategy flag, a number after it, or a pull-request URL. A merge
command with no operand still behaves exactly as it does today, because the surrounding logic depends
on that. When a line carries more than one merge, every one of them must be authorized before any of
them runs.

For the agent that was only writing about the gate, the outcome is that quoted text is treated as
text. A note, a commit message, a heredoc body, or a documentation line that names the gated command
proceeds, because nothing on that line executes a merge. The one exception is deliberate: when the
quoted text is being handed to a shell or a wrapper that will run it, the gate still arms, because in
that case the quoted text *is* a command. Every one of those wrapper forms that is refused today is
still refused afterwards; that is checked explicitly, because a fix that relaxed them would be worse
than the defect it replaced.

For the reviewer, "done" is visible as evidence rather than as assertion: for each of the two
defects, a recorded test that fails before the change and passes after it in the denial direction,
and another that fails before and passes after in the permission direction. A change that only stops
the false denials, and leaves the commands that slip past unaddressed, is not this feature.

Two known weaknesses are left in place on purpose and are recorded rather than quietly carried: a
qualifying child checkpoint still authorizes a merge of any pull request, because closing that needs
a checkpoint-schema field that does not exist yet; and the parallel Codex copy of this hook keeps its
own version of the quoted-text problem, because that file has a different owner. Both get a filed
follow-up. `spec.md` records the reasoning for each.
