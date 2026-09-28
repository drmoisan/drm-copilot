# Human-Exception Runbook — Confirm TaskMaster Run `bugs-2026-09-11` Resumes Its Remediation Cycles

This runbook satisfies requirement HI-1 of feature F7 `taskmaster-push-down-and-resume`
(issue #674), part of the `worktree-scoped-state-resolution` epic. It covers only the
post-push-down confirmation that the previously stalled run resumes. The push-down itself is
automated via `mcp__drm-copilot__push_down_claude_customizations` and is out of scope here.

## Cue

Act on this runbook only after both of the following are true, in order:

1. The push-down to TaskMaster (`mcp__drm-copilot__push_down_claude_customizations`) has
   completed.
2. The destination-content grep required by F7's own acceptance criteria has passed — that is,
   grepping the TaskMaster destination's `.claude/hooks/` (and, where applicable, `.claude/lib/`)
   tree for a specific changed literal from the epic's fix set has found the **new** content, not
   the old content.

Do not begin the resume confirmation before step 2 has passed. The push-down's exit code reports
that files were copied, not which version of them was copied, so an exit-code-only check is not
sufficient grounds to proceed. If the operator confirms the resume before the destination-content
grep has verified the new literal is present, the observation is meaningless: any resumption
observed at that point cannot be attributed to the epic's fix, because the destination may still
be running the stale hooks that caused the original stall.

## Prerequisites

- Read access to the TaskMaster repository (a different repository from this checkout; it is not
  present here) and to that repository's orchestration/parallel-run artifacts for run
  `bugs-2026-09-11`.
- Confirmed, dated evidence that the push-down landed the new content — the destination-content
  grep result described in the Cue section above. Do not proceed without this evidence in hand.
- Familiarity with the defect class this epic fixes (below), so the two failure modes can be told
  apart by observation rather than assumed away.
- The exact location of run `bugs-2026-09-11`'s state (its checkpoint or orchestrator-state file,
  and its per-item worktrees) is **not knowable from this checkout** — TaskMaster is a separate
  repository and its directory layout is not visible here. Locate it in TaskMaster by one of:
  - The TaskMaster session or tooling that originally reported the standstill (2026-09-12/13),
    which will name the run's checkpoint path directly.
  - TaskMaster's own orchestration-state or parallel-run listing command/convention, if one
    exists in that repository — consult TaskMaster's own documentation or its
    `orchestrate`-equivalent skill, not this repository's conventions, since path conventions are
    not guaranteed to match across repositories.
  - A search within the TaskMaster checkout for an orchestrator-state artifact whose run
    identifier or a filename fragment matches `bugs-2026-09-11`.
  Do not assume a `drm-copilot`-style path (for example
  `artifacts/orchestration/orchestrator-state.json`) applies to TaskMaster without confirming it
  in that repository first.

## Background: what "resume" must be checked against

Run `bugs-2026-09-11` (2026-09-12/13) was a 13-item run that reached a complete standstill: zero
agents runnable, three items merged, five items blocked behind gates, and one blocked fix that the
orchestration which produced it was structurally unable to land. The common cause was a defect
class in which `drm-copilot` hooks and MCP tools resolved orchestration state — feature folders,
checkpoints, and diff bases — against the invoking session's current working directory rather
than against the worktree the tool call actually pertained to.

Two failure modes follow from that defect, and the operator must distinguish them when observing
the resumed run:

- **False denial** — a gate reads the wrong root, does not find a document that exists, and
  denies a delegation that should have been allowed. This stalls the run visibly and is easy to
  notice.
- **False approval** — a gate reads a sibling item's checkpoint, finds it satisfactory, and allows
  an action that was never validated against its own item's state. This is the more serious mode:
  it reports a green that means nothing, and the run proceeds on an unverified basis. It leaves no
  denial in the log to inspect after the fact, so the operator must look for it deliberately
  rather than expecting it to announce itself.

The epic's fix makes every such ambiguity deny with a distinct, greppable reason code instead of
guessing. A correctly resumed run therefore produces either a clean resumption or a denial
carrying a specific reason code — never a silent sibling-checkpoint approval.

## Step-by-step Instructions

1. In the TaskMaster repository, locate run `bugs-2026-09-11`'s current state using the discovery
   method identified under Prerequisites. Record the exact path or identifier you find; it is not
   supplied by this runbook.
2. Record the run's state as of this observation, before resuming anything: which of the 13 items
   are merged, which are blocked behind gates, and which is the one blocked fix that its own
   orchestration could not land. This is the baseline the resume is measured against. At the time
   this runbook was written, that baseline was three merged, five blocked behind gates, and one
   blocked fix.
3. Resume the run using TaskMaster's own resume mechanism for a parallel/epic orchestration run
   (for example, re-invoking its orchestrator skill against the existing checkpoint, or whatever
   equivalent TaskMaster provides). Use TaskMaster's own procedure; do not substitute a
   `drm-copilot` orchestration command, since the two repositories are not guaranteed to share
   tooling.
4. Observe the five items that were previously blocked behind gates. For each one, record:
   - Whether the gate that previously blocked it now allows the delegation or action, and
   - If it still denies, whether the denial now carries one of the epic's distinct, greppable
     reason codes (indicating the fix is active and correctly identifying a genuine ambiguity or
     absence) rather than a generic or unlabeled denial.
5. Observe the one item whose fix its own orchestration was structurally unable to land. Record
   whether that fix can now be committed and merged through the run's normal path (for example,
   via the standalone-merge authorization record introduced by epic feature F3, if that item's
   situation matches RULING 1's scope).
6. For every item that proceeds (gate allows, or fix lands), identify **which item's checkpoint or
   state the deciding gate actually read**. Do this by inspecting the gate's own log output or
   decision record for the item identifier or checkpoint path it consulted, not merely by
   observing that the run moved forward. This step is what separates a genuine resumption from an
   unverified one; see Verification below for what to compare it against.
7. Continue observing until the run reaches a new stable state (all items resolved, or a new,
   distinctly-coded denial halts an item). Record the final state of all 13 items.

## Verification

**PASS** requires all of the following to hold, based on the observations recorded in steps 4-7:

- At least the five previously gate-blocked items and the one previously unlandable fix show a
  changed outcome from the pre-resume baseline (recorded in step 2): each either now proceeds
  through a gate that previously denied it, or now denies with a distinct, greppable reason code
  where the gate is correctly identifying a genuine absence or ambiguity.
- For every item that proceeded, the checkpoint or state that the deciding gate consulted (per
  step 6) matches that item's **own** identifier — not a sibling item's. If this cannot be
  confirmed for an item, that item's outcome cannot be counted as a verified pass, regardless of
  whether the run moved forward.
- No denial observed during the resume is unlabeled or generic where the epic specifies a distinct
  reason code for that ambiguity.

**FAIL** if any of the following is observed:

- One or more of the previously blocked items remains blocked with no change from the baseline.
- A gate denies without a distinct, greppable reason code where the epic requires one (indicates
  the fix did not land or is not active in this run).
- The push-down's destination-content grep (the Cue precondition) was not confirmed before this
  observation began. In that case, no conclusion may be drawn from this run's behavior either way,
  and the observation must be repeated after that precondition is met.

**Explicit false-approval case — read this before concluding PASS from a run that "proceeded":**
A run in which all items proceed is **not** automatically a pass. A gate that silently reads a
sibling item's checkpoint also lets the run proceed, and that outcome is indistinguishable from a
genuine pass by forward progress alone. The only way to rule this out is step 6: for each item
that proceeded, confirm the deciding gate's log or decision record names that item's own
identifier or checkpoint, not a different item's. An operator who reports PASS solely because "the
run moved forward" without performing step 6 has not verified the fix; they have observed the same
surface behavior the false-approval mode is defined to produce.

## What to Write Back (Evidence)

Record the observation as an evidence artifact at:

```
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/confirm-run-resume.<yyyy-MM-ddTHH-mm>.md
```

per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (canonical `<FEATURE>/evidence/other/`
location; `artifacts/baselines/`, `artifacts/qa/`, and `artifacts/evidence/` paths are forbidden).
The artifact must include:

- `Timestamp: <ISO-8601, yyyy-MM-ddTHH-mm>`
- The pre-resume baseline recorded in step 2 (counts of merged / gate-blocked / unlandable-fix
  items).
- The post-resume outcome for each of the five previously gate-blocked items and the one
  previously unlandable fix, including the reason code observed for any denial.
- For each item that proceeded, the checkpoint or item identifier the deciding gate consulted (the
  step 6 check), so the false-approval case is independently auditable by a third party without
  re-running the observation.
- The **PASS** or **FAIL** conclusion per the Verification section above, stated in one sentence
  that a third party can check against the recorded observations without needing to ask the
  operator for clarification.
- If any negative claim is made (for example, "no unlabeled denial was observed"), record
  `SearchScope`, `SearchPatterns`, and `SearchResult` per the evidence-and-timestamp-conventions
  skill's negative-evidence-claims rule.

## Source and Citation

- `docs/features/epics/worktree-scoped-state-resolution/epic.md` — sections `## Goal`, `## Origin`,
  `## Scope` (false denial / false approval definitions), and `## Human-Interaction Assessment
  (Autonomous-Execution Mandate)` (HI-1 record) — repository-internal source, captured 2026-09-13.
- `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/issue.md` — sections
  `## Problem / Why`, `## Proposed Behavior`, `## The verification trap`, and `## Human-interaction
  assessments (autonomous-execution mandate)` — repository-internal source, captured 2026-09-13.
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — evidence path and timestamp
  format conventions applied in the "What to Write Back" section above — repository-internal
  source, captured 2026-09-13.

This runbook does not include third-party UI navigation steps; all instructions concern
TaskMaster's own orchestration tooling and state, which is external to this repository and not
independently documented here. No MCP documentation-retrieval tool was available in this
repository at authoring time (repo-wide search found no `mcp__*` documentation tool wired as a
dependency), so no MCP or web source exists for TaskMaster-internal resume mechanics; the operator
must consult TaskMaster's own documentation for the exact resume command, per the Prerequisites
section above.
