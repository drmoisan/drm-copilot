# 2026-08-25-epic-orchestrator-always-on-context-footprint (User Story)

- **Issue:** #559
- **Owner:** drmoisan
- **Last Updated:** 2026-08-26
- **Status:** Draft
- **Work Mode:** `full-bug`

> **This document carries no acceptance criteria.** Under the `acceptance-criteria-tracking` skill,
> `full-bug` makes `spec.md` the sole acceptance-criteria source. This file exists because the issue
> spans six distinct defects with different affected parties, and a narrative statement of who is
> harmed and how is useful context for planning and review. All acceptance criteria live in
> `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md`.

## Summary Statement

**As** an operator running an epic orchestration, and as every other agent in this repository,
**I want** the always-on context injected before a delegation to contain only content that applies
to the work at hand, **so that** the usable context budget is spent on the epic rather than on
duplicated, misdirected, or inapplicable standing text.

## Who Is Harmed, and How

The six defects do not share a single victim. They are grouped below by who pays for each.

### 1. The epic-orchestrator agent — pays for all six

Every `Agent(epic-orchestrator)` delegation begins with 2,158 measured lines of standing context
before the delegation prompt is read. Of that:

- 501 lines are three preloaded skills that serve delegations the agent's own Delegation Model
  forbids it to make (F2).
- 685 lines are rules governing surfaces an epic run does not touch (F3).
- Two lines instruct the agent to read files the runtime has already injected verbatim, and a
  further block in the epic skill does the same (F1).
- Three citations point at a section reference the agent cannot resolve from where it sits (F4).
- A duplicated policy body restates a rule file that is loaded alongside it (F5's mechanical half).

The agent has no way to decline any of it. The cost is paid on every delegation, whether the epic
has two child features or twenty.

### 2. Every agent in the repository — pays for F3

Five files in `.claude/rules/` carry no frontmatter block at all. Absence of a `paths:` key means
unconditional load, so omission silently produces the broadest possible scope. The result is that
685 lines describing parallel-run schema invariants, plan-acceptance gate rules, orchestrator-state
checkpoint invariants, CI workflow authoring, and benchmark baseline provenance are injected into
every agent in this repository regardless of what that agent is doing.

A Python agent editing a classifier module receives 390 lines of parallel-orchestration schema
prose. A documentation agent receives benchmark baseline provenance rules for a `scripts/benchmarks/`
directory that does not exist in this repository. Neither can act on any of it, and neither is
consulted about receiving it.

This defect was invisible because no repository test asserts that a rules file carries frontmatter.
The failure mode of omission is silent breadth, not an error.

### 3. The parent context of an epic wave — pays for F6, and pays more as the epic grows

`epic-orchestrate` launches a wave of child `orchestrator` agents. Each child returns an
unconstrained prose report into the parent's context. The parent then deliberately distrusts those
reports and re-derives authoritative state from `git worktree list --porcelain`, `git branch`, and
`gh pr view --json state,mergedAt,headRefOid`.

The parent therefore pays for N prose reports and uses none of them. This is the only defect in the
set whose cost scales: a two-feature epic pays twice, a ten-feature epic pays ten times, and the
growth is in the parent's single context window.

The child is not at fault. Nothing in `.claude/skills/orchestrate/SKILL.md` instructs it to be
terse. Its `## Completion Requirements` section constrains artifacts on disk, validation gates,
checkpoint state, and the model-routing gate — and says nothing at all about what the agent reports
to its caller. The child has never been told what the parent will do with the report.

### 4. A reader following a cross-reference — pays for F4

Three places in the epic surface cite section numbers of "`spec.md` ... of this feature". The
referent exists — `docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md` carries the
cited sections — but the citation is relative and unqualified, and the originating feature has since
moved from `active/` to `completed/`. A reader of the runtime file has no path to follow and no way
to discover which feature "this feature" meant. The content those citations point at is fully
restated in `.claude/skills/epic-orchestrate/SKILL.md` and in
`scripts/dev_tools/validate_epic_orchestrator_state.py`, so the reader is being sent away from an
authority that is already in front of them.

### 5. An agent trying to comply with two contradicting policy statements — the F5 case

The repository states a coverage floor and a toolchain loop in more than one place, and the
statements disagree. `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` state
a line floor of 85 percent with a 75 percent branch companion, against a per-tier full-production
denominator. `AGENTS.md` and `.github/instructions/general-unit-test.instructions.md` state a
repository-wide floor of 80 percent with a separate 90 percent new-module target. Separately,
`.claude/rules/general-code-change.md` specifies a seven-stage toolchain loop while `AGENTS.md`
specifies four steps.

An agent instructed to comply with both cannot. The correct behavior on a genuine policy conflict is
to halt, which means the contradiction is not merely wasteful — it is a startup hazard.

**This work does not resolve that contradiction.** Selecting a coverage floor and selecting a
toolchain stage count are policy decisions reserved for a human, and this change deliberately makes
neither. The relevant acceptance criterion in `spec.md` is left unchecked, and that is the intended
outcome. What this change does deliver is the mechanical half: `CLAUDE.md` stops restating a policy
body that its own always-loaded rule file already carries.

A correction worth stating plainly, because the issue text assumed otherwise: the contradicting
statements are **not in `CLAUDE.md`**. `CLAUDE.md` is 59 lines and contains no coverage figure and
no toolchain loop. The statements live in `AGENTS.md` at lines 117-118 and 44-51. `AGENTS.md` is not
written by this change.

## What Success Looks Like, Narratively

After this change, an operator launching an epic orchestration sees an agent that starts with
roughly 970 lines of standing context instead of 2,158. The agent no longer carries instructions to
re-read what it has already been given, no longer carries three skills describing work it is
forbidden to do, and no longer carries citations it cannot follow.

Every other agent in the repository stops receiving 685 lines of rules about surfaces it is not
touching, because those rules now declare the paths they govern in the same way the other fourteen
rules files already do.

A wave of child orchestrators returns six named fields each, and the parent's context grows by a
bounded amount per child rather than by however much prose the child chose to write.

And the coverage-floor and toolchain-loop contradiction remains recorded, visible, and explicitly
unresolved, waiting on the person whose decision it is.

## What This Story Deliberately Does Not Claim

- It does not claim a token figure. The issue estimated 33,000 to 35,000 tokens; the research
  measured lines, not tokens, and the line counts above are the measured values. The token estimate
  is not restated as a verified fact.
- It does not claim the projected after-state as achieved. The approximately 970-line figure is a
  projection. `spec.md` requires the after-state to be measured and recorded as evidence.
- It does not claim that scoping a rule guarantees it activates where intended. No repository code
  reads `paths:` frontmatter; the consumer is the Claude Code runtime, and glob correctness cannot
  be asserted by any repository test. `spec.md` records this limitation and restricts its criteria
  to structural assertions.
- It does not claim the reduction is free of offset. Scoping `.claude/rules/orchestrator-state.md`
  broadly enough to reach the ten surfaces that write orchestrator checkpoints means that rule
  re-enters the context of any session editing an orchestration persona. That is correct behavior,
  and it partially offsets the saving for exactly that class of work.

## Related Documents

- Acceptance criteria and full technical specification:
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md`
- Promoted issue:
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/issue.md`
- Measured research, including the five corrections to the issue text:
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/research/2026-08-25T23-10-epic-orchestrator-context-footprint-research.md`
