# enforcement-hook-trigger-matches-whole-command-text (User Story)

- **Issue:** #545 (folds in #591)
- **Parent:** epic `cleanup-merged-worktrees-hardening`, child E
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06
- **Work Mode:** full-bug

## Why this document exists

`full-bug` normally omits `user-story.md`; `spec.md` is the sole acceptance-criteria source for this
work mode, and this document carries **no acceptance criteria**.

It exists because `scripts/dev_tools/epic_planner_readiness.py` requires `issue.md`, `spec.md`, and
`user-story.md` to be present in every prepared epic child folder (the required-file loop at line
187). This child is prepared under that gate, so the file is created to satisfy the readiness check
rather than because the work is feature-shaped. All normative content — scope, design decisions,
test strategy, and acceptance criteria — lives in `spec.md`.

## Who is affected

The enforcement hooks in `.claude/hooks/` and `.codex/hooks/` sit on the PreToolUse `Bash` matcher.
Every Bash command issued in a governed session passes through them, so the affected parties are:

- **Agents** operating under the hook family — orchestrators, planners, executors, and reviewers.
  They are the parties whose commands are allowed or denied, and the parties whose destructive
  commands the gates exist to authorize.
- **The operator** — the human running these sessions. The operator experiences the defect as
  friction when ordinary work is blocked, and bears the consequence when an unauthorized command is
  not blocked.

Neither party interacts with the hooks directly. Both experience them only as decisions on commands.

## Outcome 1 — the operator is blocked from writing ordinary prose

**As** an operator or an agent writing documentation, a memory note, a checkpoint file, or a commit
message,
**I want** text that merely *mentions* a gated command to be written without obstruction,
**so that** I can record what a gate does without the gate blocking the record.

Today this fails. A `printf` whose quoted text names a gated subcommand is denied. A heredoc whose
JSON body names promotion tools as required receipt *values* is denied — and the checkpoint schema
requires exactly those values, so the two requirements are individually reasonable and jointly
unsatisfiable on that route. Writing a memory file that documents this defect is denied, because the
file necessarily quotes the token it warns about. Five instances were observed in a single session
on 2026-08-24, and the direction reproduced again on 2026-09-06 against the current tree.

The user-visible cost is friction rather than incorrectness. A documented workaround exists — reword
the prose, or use a different write route — and applying it is disclosed, not a bypass. No unsafe
action succeeds as a result. The cost is that the workaround is required repeatedly, and that some
records cannot be written in their accurate form at all.

## Outcome 2 — an unauthorized destructive command proceeds because no gate classified it

**As** an operator relying on the gates to authorize destructive operations against a checkpoint,
**I want** a governed command to be classified regardless of how its options are spelled,
**so that** an unauthorized removal, merge, force push, or abandon cannot proceed unevaluated.

Today this fails. A relocating spelling that separates the command name from its subcommand is not
matched, so the gate returns allow and the command runs with no checkpoint authorization at all.
`git -C /repo/main worktree remove /repo/worktrees/item-a-101` removes a worktree that no checkpoint
record authorizes. `git -C ../wt push --force` performs a force push that the dangerous-command
denylist never sees. A relocating `gh` spelling creates a pull request, edits one, or creates an
issue outside the routes those gates govern.

This direction is the more serious of the two in principle, because it is a latent bypass of an
enforcement control rather than an inconvenience. It is rated Medium rather than High only because
no agent has been observed emitting a relocating spelling in practice, and the failure is fail-open
by omission rather than by an incorrect allow decision.

The two outcomes have a single cause and must be fixed together. A change that removed only the
false positives would narrow the trigger, which is a fail-open change on its own; a change that
closed only the bypass would leave the friction in place. `spec.md` records the design that
addresses both directions and the reasoning that keeps the net change fail-closed.

## Related user-visible defect

`git push --force-with-lease` — the lease-safe form the repository's own workflow prescribes — is
denied today, because the literal `git push --force` is a prefix substring of it. This is a third
user-visible outcome of the same matching design: the operator is blocked from the safe spelling of
an operation while the unsafe spelling remains reachable by relocation. It is in scope for this
change.

## Out of scope for this document

Design decisions, the parser contract, the copy set, registration obligations, test strategy, and
every acceptance criterion. All of those are in `spec.md`, which is the sole acceptance-criteria
source for this `full-bug` feature.
