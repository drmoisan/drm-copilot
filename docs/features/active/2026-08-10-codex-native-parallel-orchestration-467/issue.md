# codex-native-parallel-orchestration (Issue #467)

- Date captured: 2026-08-10
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-native-parallel-orchestration/ (Issue #467)

- Issue: #467
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/467
- Last Updated: 2026-08-11
- Work Mode: full-feature

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

## Proposed Behavior

Deliver an additive root-controlled Codex parallel surface with:

- `parallel-plan`, `parallel-run`, and manual `parallel-orchestrate` root entry points plus
  `parallel-add`, `parallel-remove`, and `parallel-close` mutation entry points.
- Forced Codex `parallel-planner` and `parallel-orchestrator` personas with deterministic topology,
  model, authority, delegation, launch, worktree, and completion receipts.
- Cohort and bounded-batch scheduling computed from shared blast-radius truth, with slots filled in
  ascending item-key order and later cohorts barred until predecessors merge and remove worktrees.
- One verified `origin/main` worktree, branch, and pull request to `main` per item; no integration
  branch or final fan-in PR.
- Durable planner/orchestrator checkpoints, authoritative resume reconciliation, open/closed mode
  semantics, deterministic add/remove/close/abandon handling, and mutation logs.
- Drift detection that quiesces scheduling, records the event, recomputes the unstarted graph,
  halts later-started conflicts, and deterministically requeues affected work.
- Codex-native provenance, cohort, drift, worktree-removal, abandon, child-binding, routing/model,
  and completion controls registered through the actual Codex hook transport.
- Shared launcher extraction from the hardened Codex epic child process pattern so write-heavy
  children run in isolated external processes without inheriting epic integration-branch behavior.
- Additive destination publishing through both Python and TypeScript Codex publishers, fixed
  cross-runtime selection of the portable issue-462 assets, pack membership, and root/bundle byte
  parity.

## Acceptance Criteria (early draft)

- [x] Root plan/run/manual entry resolves only its forced authorized parallel persona; ordinary and
      epic orchestrators are mechanically rejected as parallel roots.
- [x] Planning cannot implement, and execution requires a committed kickoff that passes deterministic
      ready-for-execution validation.
- [x] Identical normalized inputs produce identical conflicts, cohorts, and bounded batches across
      Python, TypeScript/MCP, and the published portable Bash runtime.
- [x] Each item launches in a distinct verified `origin/main` worktree with sealed exact-profile,
      model, reasoning, authority, branch, and worktree receipts before mutation begins.
- [x] Each item owns one PR to `main`; current-head green checks, merge, and matching worktree removal
      gate terminal completion. No integration branch or fan-in PR is permitted.
- [x] Both cohort enforcement layers reject premature admission, including conflicting later-cohort
      starts before predecessor merge and worktree removal.
- [x] Drift detection quiesces scheduling, persists the event, recomputes deterministically, halts
      only later-started conflicts, and requeues affected work; Python and MCP accept and reject the
      same drift fixtures.
- [x] Add/remove/close/abandon enforces ordered complete mutation records, pinned in-flight items,
      explicit destructive confirmation, and open/closed completion semantics; Python and MCP accept
      and reject the same mutation fixtures.
- [x] Resume rejects corrupt, stale, or mismatched Git, GitHub, worktree, launch, mutation, drift,
      topology, or model receipt state before new scheduling.
- [x] Every new registered Codex hook passes actual-registration process tests for allow, deny,
      malformed or missing stdin, poisoned `CLAUDE_TOOL_INPUT`, poisoned `CLAUDE_SESSION_ID`, exact
      stdout, exact stderr, and exact exit code.
- [x] Every Claude mechanical gate is recorded in a translation enforceability ledger as PRESERVED
      or DEGRADED with a tested mechanical compensating control; LOST remains zero.
- [x] Existing epic and Claude suites remain green and `.claude/` source files are byte-unchanged.
- [x] Root/bundle byte parity, pack membership, registration existence, and Python/TypeScript
      publisher-output parity cover every new Codex file and selected portable asset.
- [x] A published payload-only destination validates manifests and computes cohorts/batches without
      Python or Poetry, using the issue-462 portability assets and additive destination configuration.
- [ ] Language formatting, linting, type checking, unit/integration tests, coverage, Pester, Bats,
      parity, pack, registration, destination, and required CI gates pass for the current PR head.
      Deferred to the orchestrator: local toolchain and coverage gates are complete, but the combined
      issue criterion also requires hosted CI for the exact final published head.

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

## Test Conditions to Consider

- [ ] Differential Python/TypeScript/Bash fixtures for normalization, conflict edges, cohort coloring,
      bounded batching, mutation completeness/sequence, open/closed modes, and semantic drift.
- [ ] Pester process tests invoke every new hook through its actual `.codex/config.toml` registration
      and assert native transport, poisoned environment handling, output streams, and exit codes.
- [x] Launcher contract tests cover immutable hashes, wrong agent/model/branch/repository/worktree,
      corrupt status, interrupted resume, bounded concurrency, and ascending item launch order.
- [ ] Publisher tests cover Python/TypeScript output equality, additive route merge, portable asset
      allowlisting, collision handling, full and selected packs, no unrelated `.claude` publication,
      root/bundle byte parity, and payload-only destination execution.
- [ ] Regression suites cover existing epic launch/security behavior and every delivered Claude
      parallel contract without changing `.claude/`.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/codex-native-parallel-orchestration/` folder from the template
