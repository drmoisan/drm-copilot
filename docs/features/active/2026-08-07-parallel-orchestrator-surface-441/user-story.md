# `2026-08-07-parallel-orchestrator-surface` — User Story

- Issue: #441
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-08-07
- Work Mode: full-feature
- Companion spec: `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md`

## Story Statement

- As a repository maintainer with a backlog of thematically unrelated bugs and features, I want
  a `parallel-orchestrator` agent that consumes the planner's manifest and seeded cohorts and
  drives each item to `main` on its own PR, so that non-conflicting items deliver concurrently
  without an integration branch or a hand-authored dependency graph.
- As an operator of a planned parallel run, I want a `/parallel-run <slug>` entry point that
  replays the committed kickoff artifact and resumes each item at atomic execution from its
  committed plan-path, so that launching the run requires no re-promotion, re-research, or
  re-planning.
- As an operator monitoring a live run, I want a generated
  `docs/features/parallel/<slug>/parallel-status.md` projection regenerated at defined
  boundaries, so that I can read cohort assignments, per-item merge status, and PR links from
  one document without inspecting the checkpoint JSON.
- As an operator recovering from an interruption, I want the orchestrator to resume from the
  `artifacts/orchestration/parallel-orchestrator-state.json` checkpoint using durable git/gh
  ground truth, so that a restart continues the run instead of relaunching completed items.

## Problem / Why

The `parallel-orchestration` epic delivers a `parallel` surface that runs unrelated items
concurrently, scheduled by computed blast-radius contention. The planning half (F4) produces a
manifest, prepared child plans, and seeded cohorts, but nothing consumes them: no agent reads
the manifest, schedules cohorts, fans out child orchestrations onto isolated worktrees, or
drives each item to `main`.

The existing `epic-orchestrator` cannot serve this role. It fans results into a shared
integration branch and drives one integration-to-`main` PR; the parallel design (§4 of
`docs/research/2026-08-07-parallel-orchestration-design-research.md`) removes the integration
branch entirely and requires each item to merge to `main` independently. The epic surface is
out of scope for modification: reuse is by near-verbatim adaptation into new `parallel`-named
files.

## Personas & Scenarios

- **Persona: repository maintainer (run owner).** Plans and launches parallel runs. Cares about
  throughput without relaxed merge safety; constrained by the additive-only rule (the epic
  surface and shared child contract must not change) and by upstream ownership (F3 owns
  schemas, F4 owns planning outputs). Frustration to remove: unrelated small items serialize
  today because the only concurrent surface (epics) requires a themed integration branch.
- **Persona: run operator.** Starts, monitors, and resumes runs. Cares about a single readable
  status document, deterministic scheduling, and clear stop conditions. Needs to know in
  advance which commands a live run cannot yet complete (the F7 hook dependency) so a blocked
  merge or worktree removal is not misdiagnosed as a defect.

- **Scenario: launch a prepared run.** The maintainer has completed `/parallel-plan` for slug
  `<slug>` and invokes `/parallel-run <slug>`. The skill resolves
  `docs/features/parallel/<slug>/`, finds the committed kickoff artifact, and executes its
  invocation prompt in the `parallel-orchestrator` agent. The orchestrator parses the manifest,
  records cohort 0, fetches `origin/main`, and launches up to `max_concurrency` cohort-0 items
  in ascending item-key order, each as a child `Agent(orchestrator)` on an isolated worktree
  branched from the same `main` tip, each kickoff carrying the literal `Parallel mode: true`
  marker and the item's committed plan-path. Each item resumes at atomic execution.
- **Scenario: per-item merge and cohort advance.** A child finishes at DONE with its PR open
  and CI green. The parent durably confirms the PR state via `gh`, merges the PR into `main`
  with `gh pr merge --merge`, records the merge commit, removes the worktree, refills the freed
  slot with the next cohort item in ascending key order, and regenerates `parallel-status.md`.
  Only when every cohort-0 item is `merged` or `worktree_removed` does the parent fetch the new
  `main` tip and start cohort 1.
- **Scenario: non-mergeable PR.** One item's PR conflicts with `main` at merge time. The
  parent writes a synthetic Blocking finding into that item's own remediation inputs and
  re-delegates the child, which remediates against `origin/main` through its unmodified R1–R5
  loop (cap 3). If the loop exhausts, the parent records the terminal `blocked_ci_loop_limit`,
  the status document shows the blocked item, and the cohort barrier holds. Other cohort items
  are unaffected.
- **Scenario: resume after interruption.** The session hosting the orchestrator ends mid-run.
  The operator re-invokes `/parallel-run <slug>`. The agent's startup protocol reads the
  checkpoint, re-derives durable state from `git worktree list --porcelain`, `git branch`, and
  `gh pr view`, and continues from the recorded `current_cohort` and item states instead of
  relaunching merged items.
- **Scenario: blocked by a pre-F7 gate.** An operator attempts a live end-to-end run before F7
  has landed. The merge step is denied with `EPIC_MERGE_GATE_BLOCKED` and worktree removal
  with `EPIC_WORKTREE_REMOVAL_BLOCKED`, because the existing epic hooks fail closed for
  non-epic checkpoints. The delivered skill text states this dependency explicitly, so the
  operator recognizes a known sequencing limitation (resolved by F7) rather than a defect.

## Non-Goals

- No mutation commands (`/parallel-add`, `/parallel-remove`, `/parallel-close`), admission
  control, or mutation-log writes — F6.
- No enforcement hooks and no `.claude/settings.json` changes — F7. The run is not executable
  end-to-end until F7 lands; this is a documented limitation, not part of this story's
  acceptance.
- No drift detection, `drift_events[]` writes, `blocked_drift` transitions, quiesce, or
  requeue — F8.
- No schema, validator, rule-file, or routing-config changes — F3.
- No cohort computation or recoloring — cohorts arrive seeded from F4.
- No modification of `.claude/agents/epic-orchestrator.md`,
  `.claude/skills/epic-orchestrate/SKILL.md`, or `.claude/skills/orchestrate/SKILL.md`
  (spec Decisions 1 and 2).

## Acceptance Criteria

- [ ] Invoking `/parallel-run` reaches the parallel execution agent:
      `.claude/skills/parallel-run/SKILL.md` exists and its frontmatter declares
      `context: fork` and `agent: parallel-orchestrator`.
- [ ] An unprepared run stops with actionable guidance: the `parallel-run` procedure contains a
      STOP path, taken when no kickoff artifact is found at the parallel home, whose text names
      `/parallel-plan`.
- [ ] Direct invocation without the entry point is available:
      `.claude/skills/parallel-orchestrate/SKILL.md` exists and its frontmatter declares an
      argument hint accepting the parallel manifest path or slug.
- [ ] Launched items resume rather than re-plan: the delivered `parallel-run` and
      `parallel-orchestrate` skill text both state that items resume at atomic execution from
      their committed `plan-path` rather than re-running promotion, research, or planning.
- [ ] Every child launch is identifiable as a parallel child: the
      `## Parallel-Mode Kickoff Parameter` section of `parallel-orchestrate/SKILL.md` contains
      the literal marker `Parallel mode: true` and requires the item's
      `docs/features/active/<basename>` folder path and canonical issue number in the kickoff
      prompt.
- [ ] Concurrency never exceeds the configured cap: the skill text states that
      `max_concurrency` bounds simultaneous in-flight items independently of cohort size and
      that slots fill in `ascending item-key order`.
- [ ] The operator can read run progress from one document: the skill's
      `## Documentation Maintenance Boundaries` section requires the `parallel-status.md`
      header fields `parallel_slug`, `mode`, `max_concurrency`, `current_cohort`,
      `recolor_generation`, and `last_updated`, an item table with a cohort column, and a
      cohort table carrying `generation`.
- [ ] Each item ships independently: the three delivered runtime files contain no instruction
      to create an integration branch or a final integration PR — none contains the literals
      `Epic mode: true`, `--base epic/`, or `integration-to-main`.
- [ ] An interrupted run resumes: the agent's `## Startup Protocol` section requires reading
      `artifacts/orchestration/parallel-orchestrator-state.json` and re-deriving state via
      `git worktree list --porcelain`, `git branch`, and `gh pr view`.
- [ ] Open-mode runs never complete silently: the skill's `## Completion Requirements` section
      states that `open` mode has no automatic completion and terminates only via
      `/parallel-close`, while `closed` mode completes when every non-withdrawn item is
      `merged` or `worktree_removed`.
- [ ] The pre-F7 limitation is discoverable by the operator: the delivered skill text names
      `EPIC_MERGE_GATE_BLOCKED` and `EPIC_WORKTREE_REMOVAL_BLOCKED` as the block conditions a
      live run encounters until F7 lands.
