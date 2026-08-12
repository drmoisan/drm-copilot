# `2026-08-10-codex-native-parallel-orchestration` — User Story

- Issue: #467
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-10T20-25

## Story Statement

- As a repository maintainer, I want to plan unrelated issues through a root-controlled Codex
  parallel planner with deterministic blast-radius cohorts and complete preflight, so that I can
  review and commit an execution-ready kickoff without starting implementation.
- As an orchestration operator, I want Codex to execute each prepared item in an isolated
  `origin/main` worktree with its own PR to `main`, durable mutation and drift handling, and
  mechanically enforced completion gates, so that concurrent delivery remains reproducible,
  resumable, auditable, and independent of epic fan-in.

## Problem / Why

The repository has a delivered and hardened Claude parallel-orchestration runtime, but the Codex
surface supports only standalone feature orchestration and epic fan-in. Codex therefore cannot
plan or execute an independent set of unrelated issues concurrently with deterministic
blast-radius cohorts, isolated worktrees, per-item pull requests to `main`, durable mutation and
drift handling, and mechanically enforced completion gates.

The required result is a Codex-native capability, not a file-for-file Claude port. It must reuse
the repository's shared Python, TypeScript/MCP, and portable Bash authorities; preserve `.claude/`
unchanged; retain root/bundle/publisher/pack parity; and account for every Claude mechanical gate
as PRESERVED or DEGRADED only when a tested mechanical compensating control exists. A LOST gate
blocks delivery.


## Personas & Scenarios

- Persona: Repository maintainer preparing an independent delivery set
  - The maintainer selects unrelated issues that should proceed concurrently without being modeled
    as one epic or merged through an integration branch.
  - They require deterministic conflict analysis, reviewable cohorts and bounded batches, exact
    routing/model provenance, complete item preflight, and a planning boundary that cannot modify
    production state.
  - They must preserve delivered Claude behavior, shared semantic authorities, repository policy,
    and a translation ledger in which every mechanical gate is accounted for and LOST remains zero.
  - Their goal is a committed, ready-for-execution kickoff whose results can be reproduced by
    Python, TypeScript/MCP, and the published portable Bash runtime.
- Persona: Orchestration operator executing and resuming parallel work
  - The operator runs prepared or manually authored parallel work from the repository root and
    expects only the forced parallel orchestrator to receive authority.
  - They need each write-heavy child bound to a separate external-process worktree, branch, exact
    agent/model/reasoning profile, and PR to `main`, with no silent fallback or fan-in state.
  - They must safely add, remove, close, detach, or abandon items; respond to semantic drift; and
    resume after interruption without trusting stale checkpoint data.
  - Their goal is independent per-item completion only after current-head CI, merge, and matching
    worktree removal, with durable evidence for every gate. For this feature, the user authorizes
    `translate-claude-to-codex` with `mode=apply` and requires its evidence in the canonical feature
    evidence tree.
- Scenario: Plan, mutate, execute, and resume an independent issue set
  - A maintainer invokes `parallel-plan` for several unrelated issues and a bounded concurrency
    limit. The forced planner normalizes each item's blast radius, computes conflicts, colors cohorts
    deterministically, prepares every item, writes standalone parallel state, and stops before
    implementation.
  - The maintainer reviews and commits the ready kickoff. An operator invokes `parallel-run`; root
    provenance and the committed kickoff are validated, exact topology/model receipts are sealed,
    and only the first eligible batch is launched in isolated `origin/main` worktrees.
  - While execution is open, the operator adds an unstarted item. The mutation is recorded in order,
    in-flight items remain pinned, and only the unstarted graph is recomputed. A removal request for
    an in-flight item is rejected until the operator supplies the exact detach/abandon confirmation.
  - One item reports pre-review files outside its declaration. Scheduling quiesces, the drift event
    is persisted, later-started conflicts are halted, the unstarted graph is recomputed, and affected
    work is requeued deterministically before admission resumes.
  - After an interruption, resume reconciles Git, GitHub, worktrees, launch status, receipts,
    mutations, and drift state. Each item proceeds through its own PR to `main`; terminal completion
    is accepted only after current-head checks pass, the PR merges, its matching worktree is removed,
    open mode is explicitly closed, all registered hooks and QA gates pass, and no LOST translation
    gate or `.claude/` source change exists.


## Acceptance Criteria

- [x] Root `parallel-plan`, `parallel-run`, and manual `parallel-orchestrate` entry resolves only its
      forced authorized parallel persona; ordinary and epic orchestrators are mechanically rejected
      as parallel roots, and no silent topology or model fallback occurs.
- [x] Planning cannot launch implementation, and execution requires a committed kickoff that passes
      deterministic ready-for-execution validation with complete item preflight and required
      authority, topology, and model-routing receipts.
- [x] Identical normalized inputs produce identical conflict edges, Welsh-Powell cohorts, and
      ascending item-key batches bounded by `max_concurrency` across Python, TypeScript/MCP, and the
      published portable Bash runtime.
- [x] Each item launches in a distinct verified worktree created from `origin/main` with sealed
      exact-profile, model, reasoning, authority, repository, branch, worktree, launch-hash, and
      child-status receipts before the child can mutate files.
- [x] Each item owns exactly one branch and one PR targeting `main`; current-head green checks, merge,
      and matching worktree removal gate terminal completion, while integration branches and fan-in
      PRs are rejected.
- [x] Both cohort enforcement layers reject premature admission, including any conflicting
      later-cohort start before all required predecessors have both merged and removed their
      worktrees; green CI alone is insufficient.
- [x] Drift detection compares observed pre-review files with the declaration, persists a blocking
      event, quiesces new scheduling, recomputes the unstarted graph deterministically, halts only
      later-started conflicts, and requeues affected work; Python and MCP accept and reject the same
      drift fixtures.
- [x] Add, remove, close, detach, and abandon operations enforce complete ordered mutation records,
      unique sequence numbers, pinned in-flight items, rejection of merged removal, exact destructive
      confirmation, and open/closed completion semantics; Python and MCP accept and reject the same
      mutation fixtures.
- [x] Resume rejects corrupt, stale, incomplete, or mismatched Git, GitHub, PR-head, worktree, launch,
      child-status, mutation, drift, topology, model-routing, authority, or completion state before
      any new scheduling.
- [x] Every new Codex hook is registered in `.codex/config.toml` and passes actual-registration
      process tests for allow, deny, malformed and missing stdin, poisoned `CLAUDE_TOOL_INPUT`,
      poisoned `CLAUDE_SESSION_ID`, exact stdout, exact stderr, and exact exit code.
- [x] Native hook behavior is consistent: allow exits 0 with empty streams, deny exits 0 with one
      native JSON deny envelope and empty stderr, and malformed or missing stdin exits 2 with empty
      stdout and a deterministic stderr diagnostic.
- [x] Every Claude mechanical gate is recorded in the translation enforceability ledger as
      PRESERVED or DEGRADED with a tested mechanical compensating control; the final ledger contains
      16 PRESERVED, 2 tested DEGRADED, 0 LOST, and no omitted gate.
- [x] Translation uses `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md` as the
      corrected Codex basis and does not treat the absent artifacts research path as authoritative.
- [x] The user-authorized `translate-claude-to-codex` `mode=apply` operation classifies every output
      as feature, evidence, or other and writes its evidence exactly to
      `<FEATURE>/evidence/other/translation-plan.<yyyy-MM-ddTHH-mm>.md`,
      `<FEATURE>/evidence/other/translation-diff.<yyyy-MM-ddTHH-mm>.md`, and
      `<FEATURE>/evidence/other/translation-snapshots/`; a request for
      `artifacts/translation/**` is redirected and recorded as
      `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...`.
- [x] Existing epic and Claude parallel suites remain green, the surface-neutral launcher retains
      epic public behavior through thin adapters, and a byte-level check reports no `.claude/` source
      changes.
- [x] Every new Codex root file has a byte-identical bundle counterpart, every registered path
      exists, and full and selected packs include the complete dependency closure or a justified
      exclusion.
- [x] Python and TypeScript publishers emit equal payloads, merge destination routing additively,
      preserve destination-owned routes, apply identical collision rules, deliver
      `config/blast-radius.json`, and select only the fixed issue-462 portable assets rather than
      unrelated `.claude/` content.
- [x] A published payload-only destination validates manifests and computes deterministic cohorts
      and bounded batches without Python or Poetry, using the issue-462 portability assets and
      additive destination configuration.
- [x] Formatting, linting, type checking where applicable, unit and integration tests, Pester, Bats,
      differential parity, root/bundle parity, pack, registration, destination, and zero-regression
      gates pass in one clean toolchain loop.
- [x] Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage
      remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-
      line coverage does not regress, and baseline, QA-gate, regression, and coverage evidence is
      stored under the active feature's canonical `evidence/` subtree; QA-gate evidence uses
      `<FEATURE>/evidence/qa-gates/`.
- [ ] All required GitHub checks pass for the exact current PR head SHA; results from an earlier head
      do not satisfy merge or completion.


## Non-Goals

- Changing, regenerating, or copying the delivered `.claude/` runtime, its parallel skills, agents,
  hooks, or portable semantic authorities.
- Replacing shared Python, TypeScript/MCP, or portable Bash algorithms with PowerShell hook-local
  state machines or Codex thread scheduling decisions.
- Treating unrelated items as an epic, creating an integration branch, opening a final fan-in PR, or
  reusing epic checkpoints for standalone parallel work.
- Allowing native in-session agent spawning to substitute for isolated external-process worktrees
  for write-heavy children.
- Relaxing ready-for-execution, mutation, drift, cohort, receipt, current-head CI, merge, worktree
  removal, publishing, parity, pack, destination, coverage, or completion gates.
- Adding new dependencies, changing existing public epic contracts, or modifying CI workflows unless
  a verified test-discovery gap requires it.
- Publishing all `.claude/` content to Codex destinations or duplicating issue-462 portable assets
  into the Codex source or bundle.
- Migrating or backfilling existing Claude or epic state into the new standalone Codex parallel
  checkpoints.
