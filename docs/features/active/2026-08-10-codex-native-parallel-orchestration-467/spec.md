# 2026-08-10-codex-native-parallel-orchestration — Spec

- **Issue:** #467
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-10T20-25
- **Status:** Draft
- **Version:** 0.1

## Overview

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

The scope also corrects the Codex translation basis to
`docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`, defines deterministic handling
for feature, evidence, and other translation outputs, and requires canonical feature-relative
evidence locations. The published result must execute from a payload-only destination without
Python or Poetry while retaining the repository's existing epic and Claude behavior.

## Behavior

Deliver an additive, root-controlled Codex parallel surface with the following end-to-end behavior:

- `parallel-plan` accepts an independent issue set, resolves only the forced `parallel-planner`
  profile, calculates deterministic preflight data for every item, writes the standalone parallel
  kickoff and planner checkpoint under `docs/features/parallel/`, and stops before implementation.
- `parallel-run` accepts only a committed kickoff whose deterministic validation reports
  ready-for-execution. Manual `parallel-orchestrate` accepts the same validated manifest contract
  and resolves only the forced `parallel-orchestrator` profile. Ordinary and epic orchestrators are
  rejected as parallel roots.
- Root authority, topology, model, reasoning-effort, delegation, launch, repository, branch,
  worktree, child-status, and completion receipts are persisted and validated without silent
  fallback before any write-heavy child starts.
- The root orchestrator remains the sole scheduler. Shared Python semantic authority, parity-complete
  TypeScript/MCP validation, and the published portable Bash runtime normalize inputs identically,
  derive conflict edges from blast-radius and shared-surface overlap, order Welsh-Powell vertices by
  `(-degree, item_key)`, choose the smallest available color, execute colors in ascending order, and
  fill each bounded batch by ascending item key up to `max_concurrency`.
- Every item starts from verified `origin/main` in its own external-process worktree, owns one branch
  and one pull request targeting `main`, and uses an immutable launch specification with an isolated
  `CODEX_HOME`. Native in-session agent scheduling is not the worktree or cohort authority.
- An item becomes terminal only after its current PR head has all required green checks, the PR is
  merged to `main`, and the matching worktree is removed. Parallel execution never creates an
  integration branch or final fan-in pull request.
- Layer-one admission hooks reject unauthorized roots, invalid child bindings, unresolved drift, and
  any later-cohort launch whose conflicting predecessors have not both merged and removed their
  worktrees. Layer-two Python and TypeScript validators enforce the same barriers on state
  transitions and completion.
- `parallel-add`, `parallel-remove`, and `parallel-close` apply complete, ordered mutation records.
  Recalculation pins in-flight items; merged items cannot be removed; removal of in-flight work
  requires the exact destructive detach/abandon confirmation; open mode cannot complete until
  explicitly closed; and close is rejected while work remains in flight.
- When observed pre-review files differ semantically from the declared blast radius, the scheduler
  persists a blocking drift event, stops new admission, recomputes only the unstarted graph, halts
  later-started conflicting items rather than the drifting item, and deterministically requeues the
  affected work. Scheduling resumes only after the persisted drift resolution validates.
- Resume treats the checkpoint as a cache and reconciles it against Git, GitHub, worktree, launch,
  mutation, drift, topology, model-routing, and child-status truth before scheduling. Corrupt,
  stale, incomplete, or mismatched state fails closed.
- Every new Codex hook is registered through `.codex/config.toml`, consumes native stdin JSON,
  ignores poisoned `CLAUDE_TOOL_INPUT` and `CLAUDE_SESSION_ID`, and implements the documented allow,
  deny, and malformed-input stream and exit-code contract.
- The translation enforceability ledger records every Claude gate as PRESERVED or as DEGRADED with
  a tested mechanical compensating control. Any LOST entry, missing gate, or untested DEGRADED entry
  blocks planning readiness and runtime completion; the required final count is 16 PRESERVED,
  2 DEGRADED with tested controls, and 0 LOST.
- The user authorizes `translate-claude-to-codex` with `mode=apply` for this feature. Translation uses
  the corrected Codex research basis and classifies generated outputs as feature, evidence, or
  other. Feature documents stay in the active feature folder. Apply-mode translation evidence is
  written exactly to `<FEATURE>/evidence/other/translation-plan.<yyyy-MM-ddTHH-mm>.md`,
  `<FEATURE>/evidence/other/translation-diff.<yyyy-MM-ddTHH-mm>.md`, and
  `<FEATURE>/evidence/other/translation-snapshots/`. A requested `artifacts/translation/**`
  destination is rejected and recorded as
  `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...`.
- Both Python and TypeScript Codex publishers additively publish the new Codex files and select only
  the fixed issue-462 portable Bash, blast-radius, and configuration assets. Destination-owned
  routes survive additive merge, collisions fail deterministically, full and selected packs contain
  their complete dependency closures, and no unrelated `.claude/` content is published.
- Each new root customization has a byte-identical bundle counterpart. Publisher output, pack
  membership, registration existence, destination execution, root/bundle parity, language QA,
  coverage, existing epic/Claude regression suites, `.claude/` immutability, and required CI must
  all validate against the same current PR head.


## Inputs / Outputs

- Inputs:
  - A root invocation of `parallel-plan`, `parallel-run`, or `parallel-orchestrate`, or a mutation
    invocation of `parallel-add`, `parallel-remove`, or `parallel-close`, with the parallel slug,
    canonical kickoff or manifest, affected item keys, and explicit destructive confirmation when
    detach/abandon is requested.
  - Independent issue and feature inputs, normalized item keys, declared blast-radius paths and
    shared surfaces, dependencies, operating mode, and a positive `max_concurrency` value.
  - The committed standalone kickoff and durable planner/orchestrator state under
    `docs/features/parallel/`, plus current Git, GitHub, worktree, launch-status, mutation, and drift
    state used for preflight and resume reconciliation.
  - `config/orchestration-routing.json`, `config/blast-radius.json`, the shared Python and
    TypeScript/MCP validators, the fixed issue-462 portable assets, and the corrected Codex research
    basis `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`.
  - Native Codex hook stdin JSON containing the hook, tool, and `tool_input` fields. Hook decisions
    must not consume Claude compatibility environment variables.
- Outputs:
  - A validated parallel kickoff, deterministic conflict graph, numbered cohorts, bounded batches,
    planner/orchestrator checkpoints, ordered mutation records, drift events and resolutions, and
    topology/model/delegation/launch/worktree/completion receipts.
  - One isolated worktree, branch, pull request to `main`, exact-head check result, merge result, and
    matching removal record per item.
  - Native hook allow/deny results and explicit malformed-input diagnostics with exact stdout,
    stderr, and exit codes.
  - Translation outputs classified as feature, evidence, or other. The user-authorized
    `translate-claude-to-codex` `mode=apply` evidence outputs are
    `<FEATURE>/evidence/other/translation-plan.<yyyy-MM-ddTHH-mm>.md`,
    `<FEATURE>/evidence/other/translation-diff.<yyyy-MM-ddTHH-mm>.md`, and
    `<FEATURE>/evidence/other/translation-snapshots/`; attempts to use
    `artifacts/translation/**` record `EVIDENCE_LOCATION_OVERRIDE_REJECTED:
    artifacts/translation/** replaced with <FEATURE>/evidence/other/...`.
  - Root and byte-identical bundle files, complete pack payloads, additive destination configuration,
    and equal Python/TypeScript publisher output containing only the approved cross-runtime assets.
- Config keys and defaults:
  - The parallel base and PR target are fixed to `main`; integration-branch and fan-in fields are
    invalid for this surface.
  - Manifest `max_concurrency` bounds deterministic batches; available Codex thread capacity is
    only an upper resource limit and cannot change batch order.
  - Open mode requires an explicit close mutation. Closed mode can complete only when every item and
    all residual worktree state satisfy terminal invariants.
  - Topology/model routing uses the exact configured profile and monotonic orchestration ceiling;
    absent or mismatched receipts fail closed and never select a fallback profile.
- Versioning and compatibility constraints:
  - New checkpoint, launch, mutation, drift, and receipt schemas are versioned and validated before
    use. Any additive shared fields must retain compatibility with existing Claude fixtures.
  - Existing epic public parameters and behavior remain compatible through thin epic adapters over
    a surface-neutral launcher core.
  - `.claude/` source files remain byte-unchanged; portable assets remain canonical there and are
    selected by publishers rather than copied into the Codex bundle.

## API / CLI Surface

- `parallel-plan`: root-only planning entry. It accepts the parallel definition and planning inputs,
  produces a fully preflighted standalone kickoff and planner checkpoint, and must not launch
  implementation. Expected result: a deterministic ready or not-ready validation result with all
  item preparation state persisted.
- `parallel-run`: root-only execution entry for a committed, ready kickoff. Expected result: forced
  parallel-orchestrator routing, authoritative resume validation, and bounded per-item launches in
  persisted cohort/batch order.
- `parallel-orchestrate`: root-only execution entry for a manually authored manifest. Expected
  result: the same validation, routing, isolation, scheduling, and completion gates as
  `parallel-run`; manual authorship does not bypass preflight.
- `parallel-add`: validates a new item, appends a complete ordered mutation record, recomputes the
  unstarted graph, preserves pinned in-flight work, and rejects duplicate or invalid item keys.
- `parallel-remove`: removes only an eligible unstarted item and recomputes deterministically.
  Merged removal is invalid; an in-flight item requires the exact detach/abandon operation and
  confirmation bound to the item and worktree.
- `parallel-close`: changes an open manifest to closed only when no item is in flight, records the
  mutation, and enables terminal completion evaluation. A second close or a close with in-flight
  work fails without partial mutation.
- Concise usage forms:
  - `parallel-plan` with an independent issue set returns a validated kickoff and no implementation
    launches.
  - `parallel-run` with the committed kickoff launches only the first eligible bounded batch.
  - `parallel-orchestrate` with a valid manual manifest applies the same scheduler and receipt
    contracts.
  - `parallel-add`, `parallel-remove`, and `parallel-close` return the updated mutation sequence and
    recomputed state or a deterministic rejection reason.
- Native hook request contract: stdin JSON is parsed for hook/tool/tool-input identity, the relevant
  checkpoint and receipts are loaded, and the shared semantic validator is called. Allow returns
  exit 0 with empty stdout and stderr; deny returns exit 0 with one native JSON deny envelope and
  empty stderr; malformed or missing stdin returns exit 2 with empty stdout and a diagnostic on
  stderr.
- Validation rules: root authority and forced persona must match; planning cannot implement; a run
  requires a committed ready kickoff; the base and PR target must be `main`; item keys, receipt
  hashes, profiles, model/reasoning settings, branches, repositories, worktrees, and status files
  must match; unresolved drift and incomplete mutations block admission and completion; any LOST
  ledger entry blocks release.

## Data & State

- Source data flows from issue definitions and the parallel manifest into normalized item records.
  Shared blast-radius configuration expands declared paths and shared surfaces, then the same
  normalization and conflict-edge fixtures feed Python, TypeScript/MCP, and portable Bash.
- The deterministic graph transformation orders vertices by descending degree and ascending item
  key, assigns the smallest available color, orders cohorts by color, and partitions each cohort by
  ascending item key into batches no larger than `max_concurrency`. Equivalent normalized input
  must produce byte-equivalent semantic results across all three runtimes.
- Planner and orchestrator checkpoints persist phase, mode, item state, cohort/batch assignment,
  mutation sequence, drift status, and references to immutable routing, launch, worktree, and
  completion receipts. Parallel checkpoints never reuse epic checkpoints.
- Item state transitions preserve one item-to-worktree-to-branch-to-PR binding. Terminal completion
  requires exact-head checks, merge to `main`, and matching worktree removal; an integration branch
  or fan-in state is structurally invalid.
- Mutation sequence numbers are complete and ordered. Recalculation may change only unstarted work;
  in-flight items remain pinned. Open/closed mode and abandon/detach confirmation are durable state,
  not caller-local assumptions.
- Drift state records the declared and observed pre-review file sets, affected conflicts, quiescence,
  halted later-started items, recomputed graph, requeue order, and resolution. An unresolved event
  is a blocking state for both admission and completion.
- Checkpoints are durable caches, not external truth. Every resume revalidates Git, GitHub,
  worktrees, launch specs and hashes, child status, mutation and drift records, topology, and model
  receipts before accepting cached transitions.
- Translation state records the user's authorization for `translate-claude-to-codex` `mode=apply`,
  the corrected research basis, the feature/evidence/other classification, each emitted path, every
  enforcement-ledger disposition, and any rejected evidence-path override. Apply-mode translation
  evidence consists of `<FEATURE>/evidence/other/translation-plan.<yyyy-MM-ddTHH-mm>.md`,
  `<FEATURE>/evidence/other/translation-diff.<yyyy-MM-ddTHH-mm>.md`, and
  `<FEATURE>/evidence/other/translation-snapshots/`.
- No migration or backfill of Claude parallel state is required. The Codex surface and schemas are
  additive; existing epic and Claude checkpoints remain under their current contracts.

## Constraints & Risks

- `.claude/` is immutable; the Codex surface is additive and reuses shared authorities without
  copying Claude runtime files into a second semantic source of truth.
- The TypeScript/MCP mutation and semantic-drift gaps must close before runtime completion can be
  enabled; false acceptance by the MCP validator is release-blocking.
- External child processes, not ordinary in-session agent spawning, must bind write-heavy children
  to isolated worktrees with immutable launch specifications.
- Epic behavior must remain compatible while launcher logic is extracted into a surface-neutral
  core; parallel adapters must require `main` and reject integration fan-in.
- Codex lacks identical per-agent tool allowlists and Claude-style hard SubagentStop rejection.
  These are acceptable only with the tested permission/sandbox/PreToolUse/launch-spec/checkpoint/CI
  compensating controls documented by the enforceability ledger.
- All production and reusable script files must remain below 500 lines; no unapproved dependency or
  suppression may be introduced.
- The translation basis path embedded by existing guidance is incorrect. Implementations must use
  `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md` and test that the absent
  `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md` path is not treated as authoritative.
- Feature, evidence, and other translation outputs must be distinguished before writing. The
  authorized `mode=apply` translation plan, diff, and snapshots must use the exact
  `<FEATURE>/evidence/other/` destinations defined above. A request for
  `artifacts/translation/**` must be rejected, redirected to the canonical destination, and logged
  as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with
  <FEATURE>/evidence/other/...`.
- Registered-hook correctness cannot be inferred from direct script tests. Each matcher and command
  must be resolved from `.codex/config.toml` and exercised as a process with native stdin and
  poisoned Claude compatibility variables.
- Publisher selection must remain an explicit allowlist. Broad `.claude/` copying, route overwrite,
  missing pack membership, root/bundle divergence, and Python/TypeScript output divergence are
  release-blocking.
- CI discovery must be verified before workflow changes. CI configuration changes are permitted only
  for a demonstrated discovery gap, and completion evidence must correspond to the current PR head.


## Implementation Strategy

- Implementation scope:
  - Close TypeScript/MCP mutation completeness, sequencing, mode, and semantic-drift parity against
    the shared Python authority and differential fixtures.
  - Add the six root skills, forced parallel planner/orchestrator profiles, standalone checkpoints,
    root authority and routing/model contexts, and native registered admission/completion hooks.
  - Extract the immutable launch, isolated `CODEX_HOME`, receipt hashing, status persistence,
    sandbox preflight, and resume behavior from the epic launcher into a surface-neutral core with
    thin epic and parallel adapters.
  - Add standalone scheduler, per-item `main` PR, exact-head CI, merge, worktree removal, mutation,
    abandon, drift, resume, and terminal-completion integration without importing epic fan-in.
  - Execute the user-authorized `translate-claude-to-codex` `mode=apply` operation using the corrected
    research basis; require feature/evidence/other output classification, the exact translation
    plan/diff/snapshots locations under `<FEATURE>/evidence/other/`, rejected-override recording,
    and a complete enforceability ledger.
  - Extend root/bundle mirrors, both Codex publishers, additive routing merge, explicit portable-asset
    selection, pack manifests, destination behavior, parity checks, and CI contracts.
- New and updated components:
  - Surface-neutral child-launch contract, runtime, persistence, sandbox, resume, and post-session
    functions, plus thin parallel and backward-compatible epic adapters.
  - Parallel root authorization, provenance, cohort, drift, worktree-removal, abandon, child-binding,
    routing/model, output, and completion validators registered through the native hook transport.
  - TypeScript/MCP mutation and semantic-drift validators adjacent to the existing parallel state
    validation surface, with shared differential fixtures.
  - Python and TypeScript publisher selectors and additive configuration-merge helpers with identical
    allowlist, collision, pack, and destination semantics.
- Dependency changes: no new runtime or test dependency is expected. Use the repository's existing
  Python, TypeScript, PowerShell/Pester, Bash/Bats, Git, GitHub, and Codex process tooling. Any newly
  required dependency needs separate approval and documented justification.
- Logging and telemetry:
  - Persist structured topology, model, authority, delegation, launch, worktree, mutation, drift,
    abandon, child-status, and completion receipts in the standalone parallel state contract.
  - Record denied admission, malformed hook input, resume mismatch, path override rejection, and
    terminal gate failure with stable reason codes and no secret-bearing environment content.
  - No remote telemetry is required; durable artifacts and exact process streams provide the audit
    record.
- Rollout plan:
  - Keep the Codex parallel surface unavailable until Python/TypeScript/Bash parity, all registered
    hook matrices, the 16/2/0 enforceability ledger, launcher and epic regression tests, publishing
    parity, destination execution, coverage, and current-head CI pass in one accepted revision.
  - Publish additively without migrating existing state. If a gate fails, disable or withhold the
    Codex parallel entry surface while leaving Claude and epic behavior unchanged.

## Definition of Done

- [x] Every acceptance criterion in `spec.md` and `user-story.md` is mapped to named automated tests
      or a deterministic process demonstration, with evidence retained under this feature's
      canonical `evidence/` subtree.
- [x] Root provenance, forced planner/orchestrator routing, planning-only behavior, committed-kickoff
      readiness, monotonic topology/model routing, and no-fallback receipt validation pass.
      Evidence: [R4 authority traceability and current validators](evidence/qa-gates/remediation-traceability.md#r4--dedicated-parallel-authority-contract).
- [x] Differential Python, TypeScript/MCP, and portable Bash fixtures prove identical normalization,
      conflict edges, cohorts, bounded batches, mutation decisions, open/closed behavior, and drift
      decisions.
- [x] External launcher and resume tests prove immutable hashes, isolated `CODEX_HOME`, exact
      profile/model/reasoning/authority/worktree binding, bounded concurrency, ascending launch
      order, interrupted resume, and rejection of corrupt or mismatched status.
- [x] Integration tests prove one `origin/main` worktree, branch, and PR to `main` per item; exact-head
      green checks, merge, and matching worktree removal gate completion; no integration branch or
      fan-in PR is accepted.
- [x] Mutation, pinning, close, detach/abandon, drift quiescence, deterministic recomputation,
      later-started conflict handling, requeue, and authoritative resume edge cases pass in both
      Python and TypeScript/MCP.
- [x] Every new hook passes the actual `.codex/config.toml` registered-process matrix for allow,
      deny, malformed and missing stdin, poisoned Claude variables, exact stdout, exact stderr, and
      exact exit code.
- [x] The translation enforceability ledger accounts for every Claude mechanical gate and reports
      16 PRESERVED, 2 DEGRADED with tested compensating controls, and 0 LOST.
- [x] The user-authorized `translate-claude-to-codex` `mode=apply` operation uses the corrected Codex
      research basis, classifies feature/evidence/other outputs, writes
      `<FEATURE>/evidence/other/translation-plan.<yyyy-MM-ddTHH-mm>.md`,
      `<FEATURE>/evidence/other/translation-diff.<yyyy-MM-ddTHH-mm>.md`, and
      `<FEATURE>/evidence/other/translation-snapshots/`, and records
      `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with
      <FEATURE>/evidence/other/...` when the non-canonical destination is supplied.
- [x] Root/bundle byte parity, registration existence, full and selected pack membership, collision
      behavior, additive route merge, issue-462 asset allowlisting, and Python/TypeScript publisher
      output parity pass for every new or selected file.
- [x] A published payload-only destination validates manifests and computes cohorts and bounded
      batches without Python or Poetry and does not contain unrelated `.claude/` files.
- [x] Existing Codex epic and delivered Claude parallel suites pass, and a before/after byte audit
      reports no `.claude/` source changes.
- [ ] All changed Python, TypeScript, PowerShell, and Bash surfaces pass repository formatting,
      linting, type checking where applicable, unit and integration tests, Pester, Bats, and
      zero-regression checks in the required order.
      Evidence: [final four-language QA index](evidence/qa-gates/index.md).
- [ ] Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage
      remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-
      line coverage does not regress, and coverage evidence is stored under the canonical feature
      evidence path; QA-gate evidence uses `<FEATURE>/evidence/qa-gates/`.
      Evidence: [R1–R3 numeric coverage traceability](evidence/qa-gates/remediation-traceability.md#r1--python-newmodified-file-coverage).
- [ ] All required GitHub checks pass for the current PR head SHA; stale-head results do not satisfy
      completion.
      Deferred to the orchestrator: requires hosted CI for the exact final published head; local
      evidence does not satisfy this criterion.

## Seeded Test Conditions (from potential)
- [x] Differential Python/TypeScript/Bash fixtures cover normalization, conflict edges, Welsh-Powell
      cohort coloring, ascending bounded batching, mutation completeness and sequence, open/closed
      modes, pinning, abandon, and semantic drift.
- [x] Pester process tests invoke every new hook through its actual `.codex/config.toml` registration
      and assert native transport, allow and deny paths, missing and malformed stdin, poisoned
      environment handling, exact output streams, and exact exit codes.
- [x] Launcher contract tests cover immutable hashes, wrong agent/model/reasoning/authority,
      branch/repository/worktree mismatch, corrupt status, interrupted resume, bounded concurrency,
      ascending item launch order, and rejection of epic integration/fan-in state.
- [x] Publisher tests cover Python/TypeScript output equality, additive route merge, portable asset
      allowlisting, collision handling, complete full and selected packs, no unrelated `.claude/`
      publication, root/bundle byte parity, and payload-only destination execution.
- [x] Translation tests cover the corrected research basis, feature/evidence/other classification,
      canonical evidence paths, rejected override recording, and a ledger with no omitted or LOST
      mechanical gate.
- [x] Regression suites cover existing epic launch/security behavior and every delivered Claude
      parallel contract while a byte-level guard verifies that `.claude/` is unchanged.
- [x] Current-head CI tests reject stale check suites and retain language coverage thresholds and
      zero-regression requirements.
