<!-- markdownlint-disable-file -->

# Task Research Notes: Portable Prepared Orchestration Handoff (#614)

## Research Executed

### File Analysis

- `C:/Users/DanMoisan/.codex/sessions/2026/08/30/rollout-2026-08-30T21-56-17-01a05588-18d5-7e62-941b-8030557aae0d.jsonl`
  - Parsed the JSONL records in timestamp and ordinal order. The first denied operation was the initial read-only intake command at `2026-08-31T01:58:41.139Z`, before plan conversion, topology resolution, validation, or execution could begin.
  - Distinguished the first causal blocker from two later blockers: unavailable consumer-repository Python authority and 16 unrelated modified `.csproj` files.
- `C:/Users/DanMoisan/repos/TaskMaster/.claude/worktrees/agent-aa906dbb07d340591/artifacts/orchestration/orchestrator-state.json`
  - Verified the live 169-byte checkpoint contains only `issue-num: 469`, the feature folder, `route_id: preparation`, and `lifecycle_ready: true`.
  - Recorded its raw-byte SHA-256 as `558de827d94b8f51fc135227a7f70a0933807e2c558f7c0f40a8bff1181e0fdd` for the proposed end-to-end fixture.
- `C:/Users/DanMoisan/repos/TaskMaster/.claude/worktrees/agent-aa906dbb07d340591/.codex/hooks/enforce-epic-planning-only.ps1`
  - Verified that a canonical checkpoint with `route_id: preparation` activates a preparation-only gate.
  - Verified that the hook makes `route_id: preparation` immutable through ordinary `apply_patch`, restricts shell commands to a preparation allowlist, and compares MCP tool names as literal transport identifiers.
  - The allowlist uses `mcp__drm-copilot__validate_orchestration_artifacts`, while the active Codex tool was `mcp__drm_copilot__validate_orchestration_artifacts`.
- `C:/Users/DanMoisan/repos/TaskMaster/.claude/worktrees/agent-aa906dbb07d340591/docs/features/active/2026-08-07-qfc-collection-move-diagnostics-defects-469/plan.2026-08-29T12-22.md`
  - Verified the exact existing plan path, its 101,998-byte size, and raw-byte SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`.
  - Verified the plan contains provider-specific Claude expressions. Those expressions require an adapter or execution-time translation, but they did not cause the first denial because the hook prevented the inspection command itself.
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/{issue.md,spec.md,user-story.md}`
  - Extracted the required bidirectional handoff, provenance, binding, validation, clean-worktree, TaskMaster #469 fixture, and scope-separation behavior.
- `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`
  - Verified that logical `C1` through `C4` complexity is already shared in one policy document, while Claude model tiers and Codex model/profile/reasoning selections are provider-specific blocks in that same document.
  - Verified that topology selection is independent from complexity selection and that `preparation`, `parallel`, and `epic` are recognized logical routes.
- `scripts/dev_tools/validate_orchestrator_state.py`
  - Verified the current ordinary checkpoint contract has no general schema-version or provider discriminator.
  - Verified it requires one legacy top-level shape and optionally validates Claude model receipts, Codex model receipts, and Codex topology receipts in the same artifact.
  - The four-field TaskMaster preparation checkpoint does not satisfy that current full ordinary shape. Correcting the hook alias alone would therefore expose another validation blocker rather than complete the handoff.
  - Verified validation is non-mutating and that legacy list and namespaced delegation-receipt forms are already tolerated.
- `scripts/dev_tools/validate_epic_planner_state.py`
  - Verified that `require_ready_for_execution` unconditionally invokes `validate_epic_planner_child_launch_bindings(features)`. This is the Codex-launch-binding defect owned by issue #543, not by #614.
- `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, and `scripts/dev_tools/atomic_executor/{plan_parser.py,plan_discovery.py}`
  - Verified a shared phase/task syntax exists, but plan discovery can choose a different file over time. A portable handoff therefore must persist an exact repository-relative plan path and raw-byte content hash rather than rediscover a plan by directory.
- `.claude/skills/parallel-{plan,orchestrate,run}/SKILL.md`, `.claude/agents/parallel-{planner,orchestrator}.md`, `scripts/dev_tools/validate_parallel_{planner,orchestrator}_state.py`, and `scripts/dev_tools/parallel_kickoff_contract.py`
  - Verified the Claude parallel planner prepares children through preflight, records the exact child plan and worktree, and stops before atomic execution.
  - Verified the parallel orchestrator owns cohorts, barriers, drift checks, worktree lifecycle, and child completion; an ordinary child orchestrator resumes the prepared child at execution.
- `.agents/skills/epic-{plan,run,orchestrate}/SKILL.md`, `.claude/skills/epic-{plan,run,orchestrate}/SKILL.md`, `.codex/agents/epic-{planner,orchestrator}.toml`, and `.claude/agents/epic-{planner,orchestrator}.md`
  - Verified both providers have epic planning and execution surfaces with functional differences appropriate to their runtimes.
  - Claude uses native worktree/background agents. Codex persists immutable launch specifications and statuses and invokes external PowerShell launch/resume scripts because native delegation does not establish the required child worktree binding.
  - Claude `epic-run` can read a kickoff from the integration branch with `git cat-file`/`git show`; the Codex `epic-run` currently requires the kickoff in the invoking worktree.
- `.claude/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.codex/agents/orchestrator*.toml`, and the ordinary state-machine skills and hooks
  - Verified both providers implement the ordinary lifecycle, but neither current expression defines a provider-neutral, provenance-preserving `preparation -> execution` ownership transfer.
- `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, and `extensions/drm-copilot/src/repo-automation-tool-names.ts`
  - Verified the extension contains an in-process TypeScript topology resolver and a workspace-explicit orchestration validator.
  - Verified the MCP tool registry does not expose topology resolution as a callable consumer-repository tool.
- `scripts/dev_tools/push_down_codex_and_agents_customizations.py` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
  - Verified Codex publishing copies `.codex`, `.agents`, and `config`, but not `scripts/dev_tools`; the core pack therefore cannot make `python -m scripts.dev_tools.resolve_codex_topology` available in TaskMaster.
  - Verified the core manifest explicitly controls which runtime files reach consumer repositories, so every new schema, adapter, hook, skill, or local resolver must be registered and covered by source/bundle/pack tests.
- `C:/Users/DanMoisan/repos/TaskMaster/.claude/worktrees/agent-aa906dbb07d340591/{artifacts/orchestration,docs/features/parallel}`
  - Verified the child worktree contains the ordinary preparation checkpoint and a parallel selection document, but no parallel planner checkpoint or kickoff artifact from which to reconstruct run, item, cohort, parent-checkpoint, and scheduler-return identity.
  - The transcript-created `claude-backup` and `codex-migration-blocked` sidecars record an attempted recovery, but they do not establish an authorized transition or recover the absent parent scheduler contract.
- `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-08-30T22-15/artifacts/translation/2026-08-31T02-40-38Z/plan.md`
  - Used only as a source of hypotheses. All material claims retained here were independently checked against the live transcript, worktrees, repository files, issue state, or primary documentation.

### Code Search Results

- `route_id`, `preparation`, `EPIC_PLANNING_ONLY_BLOCKED`, and `AllowedPreparationMcpTools`
  - Found the activating state check, literal MCP allowlist, shell restrictions, and checkpoint mutation denial in `.codex/hooks/enforce-epic-planning-only.ps1` and its published bundle copy.
- `mcp__drm-copilot__` and `mcp__drm_copilot__`
  - Found hyphenated names in the preparation hook and the underscore spelling in the active transcript tool call. No shared semantic-name normalizer was found.
- `resolve_codex_topology`
  - Found the authoritative Python developer module and an extension-internal TypeScript implementation. No corresponding registered MCP operation or published consumer Python module was found.
- `parallel`
  - Found the complete Claude planner/orchestrator/run/mutation/hook surface. The equivalent search under `.agents` and `.codex` found no Codex-native parallel planner, orchestrator, run skill, or scheduler hook surface; this is issue #467 scope.
- `require_ready_for_execution` and `validate_epic_planner_child_launch_bindings`
  - Found the unconditional Codex-specific child-launch validation in the shared epic-planner ready gate; this is issue #543 scope.
- `plan.md`, `plan.*.md`, and `resolve_feature_plan`
  - Found discovery behavior that can prefer `plan.md` or the newest timestamped plan. The handoff must not invoke discovery once a prepared checkpoint has selected a plan.
- `PUBLISHED_ROOT_FOLDERS`, `pack-manifests`, and customization parity tests
  - Found `.codex`/`.agents`/`config` publishing boundaries and manifest-completeness tests. Python developer tooling is not part of the consumer payload.

### External Research

- #githubRepo:"drmoisan/drm-copilot issues 614 467 543; drmoisan/TaskMaster issue 469"
  - Live GitHub queries on 2026-08-31 verified [drm-copilot #614](https://github.com/drmoisan/drm-copilot/issues/614), [drm-copilot #467](https://github.com/drmoisan/drm-copilot/issues/467), [drm-copilot #543](https://github.com/drmoisan/drm-copilot/issues/543), and [TaskMaster #469](https://github.com/drmoisan/TaskMaster/issues/469) are open. #467 owns the Codex-native parallel scheduler surface; #543 owns the epic-planner ready-gate defect; #614 owns the narrow portable prepared-state handoff.
- #githubRepo:"in-toto/attestation subject digest predicate provenance envelope"
  - The in-toto Attestation Framework separates an envelope, a statement, and a typed predicate. A statement binds identified subjects to digests and a predicate type. This supports preserving the provider checkpoint as an immutable digest-bound subject while evolving the portable handoff predicate independently: [in-toto attestation specification](https://github.com/in-toto/attestation/blob/main/spec/README.md).
- #githubRepo:"json-schema-org/json-schema-spec draft 2020-12 schema dialect versioning"
  - The official specification repository defines the current JSON Schema documents and vocabularies. The handoff should use a published schema URI and an explicit contract version rather than infer a version from field presence: [JSON Schema specification repository](https://github.com/json-schema-org/json-schema-spec).
- #fetch:https://json-schema.org/draft/2020-12
  - Draft 2020-12 provides the versioned general-schema basis and the `$schema` dialect identifier required for deterministic validator selection: [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12).
- #fetch:https://json-schema.org/draft/2020-12/json-schema-core
  - The core specification requires schema resources to identify their dialect and defines extension vocabulary behavior. This supports a stable required core plus namespaced provider extensions: [JSON Schema Core](https://json-schema.org/draft/2020-12/json-schema-core).
- #fetch:https://docs.python.org/3/library/hashlib.html
  - Python's standard library provides SHA-256 without adding a dependency. Hash raw bytes, not parsed/reformatted JSON, so source and plan identity remain stable: [Python `hashlib` documentation](https://docs.python.org/3/library/hashlib.html).
- #fetch:https://docs.python.org/3/library/os.html#os.replace
  - `os.replace` provides replacement semantics and, when successful, atomic rename behavior on the same filesystem. The destination checkpoint should be fully written and validated beside the canonical file before replacement: [Python `os.replace` documentation](https://docs.python.org/3/library/os.html#os.replace).
- #fetch:https://git-scm.com/docs/git-merge-base
  - `git merge-base --is-ancestor` provides the explicit ancestry predicate needed to distinguish an allowed descendant HEAD from a wrong branch lineage: [Git `merge-base` documentation](https://git-scm.com/docs/git-merge-base.html).

### Project Conventions

- Standards referenced: `AGENTS.md`, `.agents/skills/tonality/SKILL.md`, `.agents/skills/research-issue/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/orchestrator-state/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, and the current orchestration routing configuration.
- Instructions followed: research-only scope; verified-evidence requirement; exact Task Researcher template; one selected recommendation after evaluating multiple viable approaches; no source, configuration, test, issue, checkpoint, or GitHub mutation; and research output under the orchestrator-supplied tracked feature research root.

## Key Discoveries

### Project Structure

#### Exact failure chronology and causality

| Order | Verified event | Causal significance |
| --- | --- | --- |
| 1 | The user asked Codex to establish state, inspect/convert the Claude plan, and continue issue #469. | Establishes that the desired operation was a provider handoff from completed parallel preparation into ordinary execution. |
| 2 | The first tool call was a read-only `rg` over Codex memory. At `01:58:41.139Z` it was denied with `EPIC_PLANNING_ONLY_BLOCKED`. | This is the first actual blocker. No plan conversion, topology decision, artifact validation, or execution had occurred. |
| 3 | A permitted `git status --short --branch` exposed 16 unrelated modified `.csproj` files. | This was discovered early in time but did not cause the prior denial. It is a later execution-safety blocker. |
| 4 | A permitted read exposed the four-field checkpoint with `route_id: preparation`. | This identifies the state that activated the hook. |
| 5 | Plan inspection through `rg` and the canonical topology-resolution command were each denied by the same preparation gate. | The hook prevented the normal route-selection path required to leave preparation. |
| 6 | The workspace-explicit MCP validator call used `mcp__drm_copilot__validate_orchestration_artifacts` and was rejected because the hook allowed only the literal hyphenated transport name. | The one validation authority that did not depend on TaskMaster source files was unavailable because transport spelling was treated as semantic identity. |
| 7 | Direct Python fallbacks failed because TaskMaster had no `pyproject.toml`, no `scripts.dev_tools` module, and no `resolve_codex_topology.py`. | This is the second, later portability defect: consumer repositories do not receive or expose the required resolver/validator authority. |

The failure was therefore not caused first by the dirty worktree, missing Python module, Claude-specific plan prose, or rate limiting. The first cause was a state/enforcement deadlock: the Claude preparation checkpoint activated a Codex hook that prohibited the ordinary transition path, made the activating route immutable to ordinary edits, and rejected the available MCP validator because of a transport-name alias mismatch. The current contract has no authorized semantic operation that can preserve the preparation record and materialize a destination execution checkpoint.

#### Functional-parity gap analysis

Functional parity means preserving outcomes, invariants, and recovery behavior while allowing each provider to use its native launch and enforcement mechanisms.

| Surface | Claude current capability | Codex current capability | Durable state and launch behavior | Verified gap and scope owner |
| --- | --- | --- | --- | --- |
| Ordinary orchestrator | Full lifecycle skill and orchestrator agent; checkpointed resume through the ordinary state machine. | Full lifecycle skill and generated orchestrator profiles selected through topology/model routing. | Both use `artifacts/orchestration/orchestrator-state.json`; provider receipt shapes and enforcement differ. | Neither has a provider-neutral prepared-to-execution transfer. The reproduced Codex gate blocks Claude state. Narrow handoff is #614. |
| Parallel planner | Complete batch intake, child preparation, cohort/radius analysis, preflight, kickoff, and preparation checkpoints. | No Codex-native parallel planner surface found. | Claude persists `parallel-planner-state.json`, per-child checkpoints, `parallel.md`, and kickoff artifacts. | Codex-native functional surface belongs to open issue #467. |
| Parallel orchestrator and run surface | Complete cohort scheduler, worktree launcher, barriers, drift enforcement, mutation commands, resume, PR-to-main, and cleanup. | No Codex-native parallel orchestrator, run skill, mutation skills, or scheduler hooks found. | Claude owns scheduler state in `parallel-orchestrator-state.json`; ordinary child orchestrators execute prepared plans. | Full scheduling parity belongs to #467. #614 supplies only the portable child handoff and return contract that #467 can consume. |
| Epic planner | Complete epic worthiness, child preparation, dependencies/waves, integration worktree, committed manifest and kickoff. | Equivalent Codex planner persona and preparation workflow with Codex launch-binding state. | Both persist `epic-planner-state.json`, committed `epic.md`, and `epic-kickoff.md`; provider launch evidence differs. | Shared ready validation currently assumes Codex launch bindings under the strict flag. Open issue #543 owns that defect. |
| Epic runner/orchestrator | Executes prepared epic waves with native worktree/background agents and can discover kickoff content on the integration ref. | Executes prepared epic waves using immutable launch specs/status and external PowerShell launchers to guarantee child worktree binding. | Both persist `epic-orchestrator-state.json`, enforce wave/fan-in ownership, and produce one integration PR. | Core execution functionality is present in both. Codex still lacks Claude's integration-ref kickoff discovery; track as parity work without replacing Codex's native launcher design. |
| Piecemeal continuation of a scheduled child | Ordinary orchestrators are the execution unit, but no provider-neutral ownership/return contract exists. | Ordinary orchestrators can execute prepared plans, but the reproduced preparation hook prevents cross-provider transition. | Scheduler must continue to own cohort/wave order, fan-in, worktree lifecycle, and final status; the child owns only its ordinary lifecycle interval. | #614 must define a signed/digest-bound child handoff and result projection. It must not let the ordinary child become the parallel or epic scheduler. |

### Implementation Patterns

#### Existing reusable patterns

- The routing document already separates topology from C1-C4 model selection conceptually. The new contract should complete that separation structurally: portable state records logical complexity and execution context; a destination adapter resolves only its own future model/profile evidence.
- The MCP validator already accepts an explicit `workspace_root` and runs the TypeScript validation implementation inside the extension. This is the appropriate consumer-repository authority boundary because it does not require the consumer to vendor drm-copilot's Python package.
- Codex epic execution already uses immutable launch specifications plus append-only statuses when native delegation cannot satisfy a worktree invariant. This demonstrates that functional parity can be achieved through a provider-specific adapter rather than a direct Claude implementation port.
- Existing artifact validators are non-mutating. Preserve that property: validation and transition/materialization must be distinct operations.
- Existing push-down pack manifests and source/bundle tests are the publishing boundary. A root-only fix is incomplete because TaskMaster and other consumers execute the bundled runtime.

#### Current coupling that must be removed

- `route_id: preparation` currently serves both as historical lifecycle evidence and as a live authorization switch. A portable contract needs an immutable source route plus a separately authorized transition to a destination execution route.
- MCP allowlists compare transport spellings rather than a registered semantic operation.
- One ordinary checkpoint schema mixes general lifecycle state, Claude routing evidence, and Codex routing/topology evidence.
- Plan discovery is repeated even after preparation has selected a plan, so a later `plan.md` or timestamped plan can change the executor target.
- Parallel and epic kickoff prose records significant scheduler context, but ordinary continuation needs a structured parent/child ownership and return contract that adapters can validate without interpreting provider prose.

### Complete Examples

The following is a concrete proposed handoff-envelope instance for the observed TaskMaster checkpoint. It is a contract example, not an existing repository artifact. Values not available from the four-field legacy checkpoint must be supplied and verified from the original parallel kickoff/planner checkpoint; they must not be inferred.

```json
{
  "$schema": "https://drm-copilot.dev/schemas/orchestration-handoff/2.0.0/schema.json",
  "schema_version": "2.0.0",
  "kind": "portable_orchestration_handoff",
  "handoff_id": "taskmaster-469-claude-to-codex-01",
  "identity": {
    "objective_id": "github:drmoisan/TaskMaster#469",
    "issue_number": 469,
    "feature_folder": "docs/features/active/2026-08-07-qfc-collection-move-diagnostics-defects-469",
    "work_mode": "full-bug"
  },
  "binding": {
    "repository_id": "github.com/drmoisan/TaskMaster",
    "workspace_root": "C:/Users/DanMoisan/repos/TaskMaster/.claude/worktrees/agent-aa906dbb07d340591",
    "branch": "bug/qfc-collection-move-diagnostics-defects-469",
    "source_head_sha": "30d2aeb298c9b2689dc69b38a5c733512c6e22f5",
    "allowed_head_relationship": "equal_or_descendant"
  },
  "source": {
    "provider": "claude",
    "checkpoint": {
      "path": "artifacts/orchestration/orchestrator-state.json",
      "sha256": "558de827d94b8f51fc135227a7f70a0933807e2c558f7c0f40a8bff1181e0fdd",
      "archive_path": "artifacts/orchestration/handoffs/sources/sha256/558de827d94b8f51fc135227a7f70a0933807e2c558f7c0f40a8bff1181e0fdd.json"
    },
    "expression": {
      "schema_id": "claude.orchestrator-state",
      "schema_version": "legacy-v1",
      "historical_receipts": {
        "mode": "opaque",
        "references": []
      }
    }
  },
  "plan": {
    "path": "docs/features/active/2026-08-07-qfc-collection-move-diagnostics-defects-469/plan.2026-08-29T12-22.md",
    "sha256": "54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f",
    "contract_version": "atomic-plan-v1"
  },
  "lifecycle": {
    "logical_complexity": "<required-from-verified-complexity-assessment>",
    "route_intent": "prepared_child_to_ordinary_execution",
    "completed_phases": [
      "intake",
      "promotion",
      "research",
      "feature_documents",
      "atomic_planning",
      "preflight"
    ],
    "next_transition": "atomic_execution",
    "replay_policy": "forbid_completed_phases"
  },
  "scheduler_context": {
    "kind": "parallel",
    "run_id": "<required-from-verified-parallel-kickoff>",
    "item_id": "<required-from-verified-parallel-kickoff>",
    "kickoff_path": "<required-from-verified-parallel-kickoff>",
    "kickoff_sha256": "<required-sha256>",
    "parent_checkpoint_path": "<required-from-verified-parallel-planner-state>",
    "parent_checkpoint_sha256": "<required-sha256>",
    "cohort_or_wave": "<required-from-verified-parallel-kickoff>",
    "scheduler_owner": "parallel_orchestrator",
    "child_execution_owner": "ordinary_orchestrator",
    "return_contract": "portable_child_result-v1"
  },
  "capabilities": {
    "required": [
      "handoff-schema:2",
      "transition:prepared_to_atomic_execution",
      "plan-contract:atomic-plan-v1",
      "semantic-tool:drm-copilot.validate_orchestration_artifacts",
      "workspace-explicit-routing",
      "atomic-checkpoint-materialization"
    ]
  },
  "handoff_history": [
    {
      "sequence": 1,
      "from_provider": "claude",
      "to_provider": "codex",
      "source_checkpoint_sha256": "558de827d94b8f51fc135227a7f70a0933807e2c558f7c0f40a8bff1181e0fdd",
      "requested_at": "2026-08-31T01:58:26Z",
      "previous_entry_sha256": null,
      "entry_sha256": "<computed-over-canonical-history-entry>",
      "status": "requested",
      "adapter_version": "claude-to-codex-v1"
    }
  ]
}
```

The destination checkpoint is a new provider expression. It references the envelope and archived source hash, maps `next_transition: atomic_execution` to the destination's ordinary execution route, and contains no Codex receipt dated before transition completion. Codex topology/model receipts are created only when Codex performs its first new delegation.

### API and Schema Documentation

#### Contract layers and ownership

| Layer | Portable content | Owner | Mutation rule |
| --- | --- | --- | --- |
| General handoff envelope | Identity, repository/workspace/branch binding, lifecycle phases, exact plan identity, source provenance, transition, scheduler context, capability requirements, handoff history. | Shared versioned JSON Schema and common semantic validator. | Append-only history; previously hashed source and history entries cannot change. |
| Provider expression | Claude or Codex checkpoint field names, provider receipts, model/profile evidence, launch attestations, hook authorization. | Provider adapter and provider-native validators. | Historical source expression remains opaque and immutable; destination adds only new evidence. |
| Operational projection | Active canonical `orchestrator-state.json` used by the destination runtime. | Dedicated transition service, never an agent-authored patch. | Write complete candidate beside the canonical file, validate, archive source bytes, then atomically replace on the same filesystem. |
| Scheduler projection | Parallel/epic run, item, cohort/wave, parent checkpoint, ownership, and bounded return result. | Scheduler-specific adapter and state validator. | Parent remains scheduler authority; child can append only its allowed result/status fields. |

#### Required general-schema fields

- Schema identity: `$schema`, semantic `schema_version`, `kind`, and globally unique `handoff_id`.
- Objective identity: stable objective identifier or digest, issue number, feature folder, and work mode.
- Binding: normalized repository identity, exact resolved workspace root, branch, source HEAD, and explicit allowed HEAD relationship.
- Source provenance: source provider, exact checkpoint path, raw-byte SHA-256, content-addressed archive path, source expression schema/version, and opaque receipt references/digests.
- Plan identity: normalized repository-relative POSIX path, raw-byte SHA-256, and atomic-plan contract version. Absolute paths, `..`, symlink escapes, directory discovery, and hash drift are invalid.
- Lifecycle: provider-neutral phase IDs, ordered completed phases, exact next transition, route intent, logical complexity, and replay policy.
- Scheduler context: optional `ordinary`, `parallel`, or `epic` kind; run/item identifier; manifest/kickoff path and hash; parent checkpoint path and hash; cohort/wave; scheduler owner; child owner; and return contract.
- Capability negotiation: required schema major, transition, plan contract, scheduler context, semantic tools, validation authority, routing authority, and atomic materialization capability.
- History: monotonically increasing sequence, previous-entry digest, entry digest, source/destination providers, timestamps, source/envelope/target hashes, adapter ID/version, outcome, and deterministic failure code when blocked. The destination checkpoint and scheduler parent retain the accepted envelope/history digest so later rewriting is detectable.

#### Lifecycle identities and transition semantics

Use stable logical phase identifiers independent of the provider's current step labels: `intake`, `promotion`, `research`, `feature_documents`, `atomic_planning`, `preflight`, `atomic_execution`, `qa`, `feature_review`, `pr_creation`, `ci_verification`, and `completion`.

| Source state | Requested transition | Required checks | Result |
| --- | --- | --- | --- |
| Legacy v1 checkpoint | `migrate_legacy` | Explicit source provider; source-provider validation; source hash/archive; unambiguous identity; exact verified plan; scheduler kickoff when applicable. | Create a v2 envelope without mutating the source. Unknown or missing history remains opaque/unknown. |
| `preparation_complete` | `prepared_to_atomic_execution` | Schema/version, append-only history, source hash, repository/workspace/issue/feature/branch binding, plan hash, scheduler ownership, and destination capabilities. | Mark the envelope validated; do not execute or materialize yet. |
| Validated handoff | `materialize_destination` | Recheck all hashes/bindings, run non-mutating clean-worktree preflight, resolve destination execution route, and validate the complete candidate checkpoint. | Archive source bytes and atomically replace the active canonical checkpoint with a destination projection linked to the envelope. |
| Destination materialized | `atomic_execution` | Exact plan read proof; destination topology/model resolution; launch/delegation availability. | Resume at the recorded plan execution task. Do not rerun any completed phase. |
| Child execution terminal | `return_to_scheduler` | Child result schema, child checkpoint hash, plan/result evidence, matching parent/run/item binding. | Append bounded child status to the scheduler state. Scheduler retains barrier, fan-in, merge, and cleanup ownership. |
| Any terminal or completed phase | Replay of an earlier phase | Always rejected unless a separately versioned remediation transition explicitly authorizes it. | `HANDOFF_TRANSITION_NOT_ALLOWED`; no files changed. |

#### Semantic MCP identity

Parse only registered identifiers of the form `mcp__<server>__<operation>`. Normalize a registered server alias by lowercasing and mapping `_`/`-` spellings to canonical `drm-copilot`; compare the exact registered operation as semantic identity such as `drm-copilot.validate_orchestration_artifacts`. Do not normalize arbitrary servers or approximate operation names. Both hooks and validators must call one shared alias registry and reject malformed, unregistered, or unrelated identities.

#### Validation order and failure codes

Validation must be deterministic and stop before mutation. Use one ordered error-precedence contract across MCP, Python/TypeScript validators, and hook output:

1. `HANDOFF_UNSUPPORTED_VERSION`
2. `HANDOFF_SOURCE_HASH_MISMATCH`
3. `HANDOFF_HISTORY_INVALID`
4. `HANDOFF_REPOSITORY_MISMATCH`
5. `HANDOFF_WORKSPACE_MISMATCH`
6. `HANDOFF_ISSUE_FEATURE_MISMATCH`
7. `HANDOFF_BRANCH_LINEAGE_MISMATCH`
8. `HANDOFF_PLAN_PATH_INVALID`
9. `HANDOFF_PLAN_HASH_MISMATCH`
10. `HANDOFF_SCHEDULER_BINDING_MISMATCH`
11. `HANDOFF_TRANSITION_NOT_ALLOWED`
12. `HANDOFF_CAPABILITY_UNAVAILABLE`
13. `HANDOFF_VALIDATOR_UNAVAILABLE`
14. `HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE`
15. `HANDOFF_PROVIDER_ROUTING_UNAVAILABLE`
16. `HANDOFF_DIRTY_WORKTREE`

The TaskMaster checkout's 16 unrelated `.csproj` changes should produce only `HANDOFF_DIRTY_WORKTREE` after schema, authority, binding, and plan checks pass. The preflight must use a read-only porcelain status, report the paths, and must not stage, stash, reset, delete, or otherwise alter them.

#### Migration and versioning

- Treat an artifact with no portable schema version as legacy v1. Require the caller to name the source provider when the legacy shape cannot prove it.
- Validate legacy source bytes with the source-provider validator when available. The observed four-field TaskMaster checkpoint cannot by itself prove the full completed history or parallel parent binding; migration must resolve those facts from an explicitly selected and hash-bound planner checkpoint/kickoff or stop as ambiguous.
- Copy raw source bytes to a content-addressed archive before canonical replacement. Calculate the digest over the original bytes; never reserialize first.
- Produce and validate the side-by-side envelope in dry-run mode before any active-checkpoint change.
- Use same-directory candidate writing and same-filesystem atomic replacement. If candidate validation or replacement fails, the original canonical checkpoint remains unchanged and the history records no completed transition.
- Schema major versions are compatibility boundaries. A destination may accept newer minor versions only when the declared vocabulary and required capabilities are supported; unknown required fields or transitions fail closed.
- Migration never fabricates delegation, model, topology, launch, preflight, or validator receipts. Historical provider evidence is copied or referenced as opaque bytes plus digests.

### Configuration Examples

The neutral registry should identify semantic tools and provider adapters without placing provider model choices in portable state:

```json
{
  "$schema": "https://drm-copilot.dev/schemas/orchestration-handoff-registry/1.0.0/schema.json",
  "version": "1.0.0",
  "semantic_tools": {
    "drm-copilot.validate_orchestration_artifacts": {
      "transport_aliases": [
        "mcp__drm-copilot__validate_orchestration_artifacts",
        "mcp__drm_copilot__validate_orchestration_artifacts"
      ]
    },
    "drm-copilot.transition_prepared_orchestration": {
      "transport_aliases": [
        "mcp__drm-copilot__transition_prepared_orchestration",
        "mcp__drm_copilot__transition_prepared_orchestration"
      ]
    }
  },
  "provider_adapters": {
    "claude": {
      "checkpoint_expression": "claude.orchestrator-state",
      "routing_policy": "model_policy"
    },
    "codex": {
      "checkpoint_expression": "codex.orchestrator-state",
      "routing_policy": "codex_model_policy",
      "topology_policy": "codex_topology_policy"
    }
  }
}
```

`logical_complexity: C3` is portable. A source Claude C3 model receipt remains opaque Claude evidence. On the next Codex delegation, the Codex adapter consults the then-current `codex_model_policy` and persists a new Codex routing receipt. The reverse path follows the same rule. A handoff never translates a historical model name into a destination model name.

### Technical Requirements

- Expose a read-only, workspace-explicit validation/resolution API from the extension for consumer repositories. Extend `validate_orchestration_artifacts` with the portable artifact types and expose topology/provider-delegation resolution rather than requiring `scripts.dev_tools` in TaskMaster.
- Add a separate explicit mutating MCP operation such as `transition_prepared_orchestration`. Its input must include `workspace_root`, exact source checkpoint path and expected hash, envelope path/hash, destination provider, and dry-run/materialize mode. It must be the only allowed way through a preparation gate to change active checkpoint authority.
- Keep shell and ordinary `apply_patch` attempts to remove/change `route_id: preparation` denied. The hook should allow the registered semantic transition operation, not broaden the preparation shell surface.
- Preserve provider-native launch behavior. Codex may continue using external launch specs/status; Claude may continue using native worktree/background agents. Adapters must satisfy the same worktree, ownership, resume, evidence, and terminal-result semantics.
- Persist structured scheduler kickoff metadata for parallel and epic children. An ordinary orchestrator may execute one child piecemeal, but it cannot advance cohorts/waves, merge integration state, remove worktrees, or declare the parent run complete.
- Bind plans by normalized repository-relative path and raw SHA-256. Provider-specific plan instructions may be expressed through provider overlays or resolved prompts, but portable task IDs, dependencies, acceptance-criteria mapping, and completion state remain unchanged.
- Publish every runtime file through both source and extension bundle surfaces and register it in the applicable core/variant manifest. Test the installed/pushed-down consumer payload, not only the drm-copilot source tree.
- Perform all handoff validation before the dirty-worktree check, but perform the dirty-worktree check before archive/materialization or execution. This separates contract defects from environmental safety blockers without changing user files.
- **No requested objective was found to be technically unachievable.** Full Codex parallel scheduling is not present today, but its delivery is independently scoped in #467; the portable handoff can be delivered first and used by ordinary and epic continuations.

## Recommended Approach

Implement a versioned, digest-bound sidecar handoff envelope with provider adapters and controlled atomic destination materialization.

This approach retains the original provider checkpoint as an auditable subject, makes the portable semantics explicit in a separately versioned envelope, and lets the destination produce a canonical checkpoint it can already execute. It avoids coupling historical Claude evidence to Codex receipt rules or historical Codex evidence to Claude model rules. It also provides one place to bind the exact plan, workspace, repository, branch, issue, feature, scheduler owner, and next transition.

Use the extension MCP service as the primary consumer-repository validation and transition authority. The extension already has a workspace-explicit validator and in-process topology code; extending that boundary avoids depending on unshipped `scripts.dev_tools`. Publish only the schema, provider invocation adapters, hooks, skills, and alias registry needed at runtime, with root/bundle/pack parity. Maintain Python and TypeScript validation parity inside drm-copilot for development and CI.

The narrow #614 transition should proceed in these dependency phases:

| Phase | Deliverable | Dependency/scope boundary |
| --- | --- | --- |
| A: Shared contract | Draft 2020-12 handoff/envelope schema, lifecycle IDs, exact plan identity, provenance archive, append-only history, capability negotiation, deterministic failures, and v1 migration reader. | #614 only; no scheduler implementation. |
| B: Consumer authority | MCP validation/resolution and dry-run transition APIs, registered semantic tool aliases, non-mutating binding/clean checks, and controlled atomic materialization. | Reuse extension TypeScript authority; do not require consumer Python modules. |
| C: Provider adapters | Claude-to-Codex and Codex-to-Claude checkpoint projections; destination-only routing receipts; preparation-hook semantic allowlist; ordinary scheduled-child ownership/return projection. | Preserve provider-native launch mechanisms. |
| D: Publishing and fixture gate | Root/bundle/pack parity, installed consumer tests, TaskMaster #469 fixture with pinned source/plan hashes, inverse fixture, tamper/stale/wrong-workspace/dirty cases. | #614 completion gate. |
| E: Codex parallel parity | Native Codex parallel plan/run/orchestrate/mutation/scheduler/launcher surfaces consume the shared contract. | Open issue #467 remains sole owner. |
| F: Epic ready-gate correction | Make provider-specific child launch binding conditional on provider/capability evidence. | Open issue #543 remains sole owner. |
| G: Remaining parity hardening | Add Codex integration-ref kickoff discovery and full cross-provider scheduled-run resume matrices. | Follow-up parity work; do not replace functional provider differences. |

Rejected alternatives:

- A single in-place normalized checkpoint v2 was viable but rejected because migration would overwrite or reserialize historical evidence, pressure adapters to populate unavailable provider fields, and couple all validators to one rapidly growing union shape.
- Two simultaneously active provider checkpoints with an overlay were viable but rejected because hooks and orchestrators would have competing `next_step` and ownership authorities. The recommended envelope retains side-by-side evidence while allowing only one atomically materialized active projection.

## Implementation Guidance

- **Objectives**: Enable deterministic Claude-to-Codex and Codex-to-Claude continuation from completed preparation; preserve provenance; resume the exact plan at the exact next phase; retain parent scheduler ownership; and establish functional, not file-for-file, parity boundaries.
- **Key Tasks**: Add the shared schema and alias registry; implement v1 migration and digest/archive logic; add portable validators and explicit transition MCP tooling; add provider projections; update preparation hooks; add structured parallel/epic child metadata; update root and extension bundles/manifests; and build the bidirectional and negative fixture matrix.
- **Dependencies**: Likely implementation boundaries include `scripts/dev_tools/validate_orchestrator_state.py`, new shared handoff validation modules, `extensions/drm-copilot/src/lib/validate/`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `extensions/drm-copilot/src/repo-automation-tool-names.ts`, MCP service dispatch, `.codex/hooks/enforce-epic-planning-only.ps1`, both provider orchestrate/state skills, routing/schema resources, both provider customization bundles, pack manifests, and their parity/installed-consumer tests. #467 and #543 are related but not dependencies for the narrow handoff.
- **Success Criteria**: In one clean pass, schema/unit tests validate ordered failures; hook process tests accept both registered server spellings and reject unrelated names; legacy migration preserves raw source bytes and leaves the canonical checkpoint untouched on any failure; TaskMaster #469 reaches a Codex execution-ready projection with its pinned plan and no completed-phase replay; the inverse fixture reaches Claude execution readiness; parallel/epic child fixtures return status without transferring scheduler ownership; tamper, stale plan, wrong repository/workspace/branch/issue/feature, unsupported version/capability, unavailable authority, and dirty worktree fixtures fail deterministically; and source/bundle/pack/install parity tests prove the authority works without drm-copilot source modules.
