# parallel-schema-validators (Issue #444) — Research

- Date: 2026-08-07
- Feature: F3 of the `parallel-orchestration` epic (wave 1)
- Mode: preparation (research only; no implementation in this run)
- Authoritative design: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (cited below as §N)
- Epic narrative: `docs/features/epics/parallel-orchestration/epic.md`
- Issue: `docs/features/active/2026-08-07-parallel-schema-validators-444/issue.md`
- Enforcement precedent: `.claude/rules/orchestrator-state.md`

## 1. Current-State Analysis (verified against the repository)

### 1.1 Python validator precedent

`scripts/dev_tools/validate_epic_orchestrator_state.py` (492 lines) establishes the module shape
this feature must pattern-match:

- Public entry point `validate_epic_orchestrator_state_text(text: str, *, require_complete: bool = False, require_codex_model_routing: bool = False, require_codex_topology: bool = False) -> list[str]`.
  It parses JSON, rejects non-object roots, then accumulates errors from small private helpers
  (`_missing_baseline_and_epic_keys`, `_validate_route_id`, `_extract_features`,
  `_validate_feature_folder_uniqueness_and_dependencies`, `_validate_merge_status_enum`,
  `_validate_wave_barrier_ordering`, `_validate_waves_consistency`, `_validate_completion`).
- The validator returns a list of error strings and never mutates its input; invalid JSON returns
  a single-element list (`"Epic checkpoint is not valid JSON: {exc}"`); a non-object root returns
  `["Epic checkpoint root must be a JSON object."]`.
- Required keys are module-level tuples (`REQUIRED_BASELINE_KEYS` = objective, completed_steps,
  next_step, last_updated; `REQUIRED_EPIC_KEYS`); enums are module-level sets
  (`VALID_MERGE_STATUS`, `MERGED_STATUSES`).
- Error messages are literal, context-prefixed strings (`"Epic checkpoint feature '{folder}' has invalid merge_status: {value!r}"`);
  barrier violations use an ALL-CAPS token prefix (`EPIC_WAVE_BARRIER_VIOLATION: ...`).
- Keyword modes are opt-in booleans; the completion gate runs only under `require_complete`.
- Cross-cutting logic lives in underscore helper modules imported absolutely
  (`scripts.dev_tools._epic_orchestrator_state_resolution`, `_epic_orchestrator_state_launch_binding`,
  `_orchestrator_state_codex_model_routing`, `_orchestrator_state_codex_topology`).

`scripts/dev_tools/validate_epic_planner_state.py` (354 lines) follows the same shape:
`validate_epic_planner_state_text(text, *, require_ready_for_execution=False, readiness_context=None)`,
module-level `REQUIRED_KEYS` / `REQUIRED_FEATURE_KEYS`, per-index error prefixes
(`"Epic planner checkpoint features[{index}]"`), and a readiness next-step sentinel
(`READY_NEXT_STEP = "EPIC_EXECUTION_READY"`). The readiness gate additionally requires >= 2
features, `preparation_status == "prepared"`, `preflight_status == "PREFLIGHT: ALL CLEAR"`, and an
expected kickoff path `artifacts/orchestration/epic-kickoff-{slug}.md`.

Helper-module decomposition precedent (all under the 500-line cap except one pre-existing file):
`_epic_orchestrator_state_resolution.py` (288), `_epic_orchestrator_state_launch_binding.py` (285),
`_orchestrator_state_complexity.py` (207), `_orchestrator_state_model_routing.py` (216),
`_orchestrator_state_model_routing_gate.py` (298), `_orchestrator_state_human_interaction.py` (127),
and others. `_orchestrator_state_complexity.py` documents the pattern explicitly: the helper holds
the optional-key constant plus one `_validate_*` function listed in `__all__` as a deliberate
re-export, and the primary validator invokes it only when the key is present so an absent key
contributes zero errors ("key-gated additive invariant"). (`_orchestrator_state_routing.py` is 595
lines — a pre-existing exception; new files must stay under 500.)

### 1.2 Key-gated additive-invariant pattern

`scripts/dev_tools/validate_orchestrator_state.py` and `.claude/rules/orchestrator-state.md`
establish the enforcement doctrine this feature must reproduce for the `parallel` surface:

- Invariants are expressed as numbered prose in a `.claude/rules/*.md` file and enforced by
  Python validator logic, never by an imported JSON Schema ("Foreign Schema Warning": the
  disqualified foreign schema is identified by the `drmoisan.github.io/mix-calculator/` `$id`;
  the enforcement mechanism is validator prose-and-logic, not a schema file).
- Optional blocks validate only when their key is present; a checkpoint without the key validates
  byte-identically to before.
- Opt-in strict modes are keyword flags with CLI mirrors (`--require-complete`, etc.).

### 1.3 CLI dispatcher (Python)

`scripts/dev_tools/validate_orchestration_artifacts.py` (357 lines) is the stable CLI:
`build_parser()` registers one subparser per artifact type (`plan`, `policy-audit`, `code-review`,
`feature-audit`, `epic-kickoff`, `orchestrator-state`, `epic-orchestrator-state`,
`epic-planner-state`), each with a `path` positional and per-type flags;
`_validate_from_args()` routes by `args.artifact_type`; unknown types return
`["Unsupported artifact type: {type}"]`; `main()` prints errors to stderr and returns 1, or prints
`"{artifact_type} validation passed: {path}"` and returns 0. File reads go through `_read_text`,
which tests monkeypatch to inject in-memory text (no temp files).

### 1.4 MCP TypeScript surface — complete edit-point trace (verified)

The MCP tool `validate_orchestration_artifacts` is served in-process by the extension's
TypeScript port; there is no subprocess call to the Python CLI. Dispatch chain:

1. `extensions/drm-copilot/src/mcp-tool-definitions.ts` — tool schema. The `artifact_type`
   property `enum` (lines ~401–412) lists the eight supported types; flag descriptions at
   lines ~420–444 name the artifact types they apply to.
2. `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` — a second, parallel
   definition surface with the same `artifact_type` enum (lines ~342–343) and descriptions
   (~356, ~376). The test `extensions/drm-copilot/test/mcp-epic-validation-definitions.test.ts`
   asserts both surfaces stay aligned.
3. `extensions/drm-copilot/src/mcp-tool-inputs.ts` — `VALID_ARTIFACT_TYPES` set (line ~427) and
   `resolveValidateOrchestrationArtifactsToolInput` which rejects unknown types with
   `"Field 'artifact_type' must be one of: ..."`. (The existing negative test at
   `test/mcp-tool-inputs.test.ts:114` asserts only the message prefix, so adding enum members
   does not break it — verified.)
4. `extensions/drm-copilot/src/mcp-tools.ts` (case `"validate_orchestration_artifacts"`, ~line 251)
   → `src/mcp-handlers/template-validation-handlers.ts` (`handleValidateOrchestrationArtifacts`)
   → `RepoAutomationService.validateOrchestrationArtifacts`
   → `src/lib/validate/validate-orchestration-service-call.ts` (generic pass-through of
   `artifactType` and flags; reads the artifact via the injected `FileSystem`)
   → `src/lib/validate/orchestration-artifacts.ts` `validateArtifact()` — the `switch` on
   `input.artifactType` (lines ~186–256) with a default branch returning
   `["Unsupported artifact type: {type}"]`.
5. Per-type TS validator cores: `epic-orchestrator-state-core.ts` (453 lines),
   `epic-planner-state-core.ts` (460 lines), plus helpers
   (`epic-orchestrator-state-resolution.ts` 287, `epic-orchestrator-state-launch-binding.ts` 312,
   etc.). The epic types were wired with full in-process TS ports whose error strings are
   byte-identical to the Python source (stated in the `orchestration-artifacts.ts` module
   docstring: "Phase/task regexes and error-message strings are identical to the Python source").

Files verified as requiring **no** change for a new artifact type: `mcp-tools.ts`,
`template-validation-handlers.ts`, `validate-orchestration-service-call.ts`,
`repo-automation-tool-names.ts` (the tool name is unchanged), `mcp-server.ts`.

### 1.5 Routing configuration

`config/orchestration-routing.json` `routes` currently holds `small`, `large`, `remediation`,
`preparation`, `epic`. Route entries are objects with `description`, optional
`requires_pr_gate` / `requires_ci_gate`, `required_agents`, `required_skills`,
`required_mcp_tools`. Consumption (verified in `scripts/dev_tools/_orchestrator_state_routing.py`):

- `validate_route_membership` rejects any checkpoint `route_id` that is not a key of
  `matrix["routes"]` — this is why `route_id: parallel` must be added before any parallel
  checkpoint can reference it.
- `route_requires_pr_gate` / `route_requires_ci_gate` read the per-route booleans.
- `validate_routing_contract` compares a standard orchestrator checkpoint's `required_agents` /
  `required_skills` / `required_mcp_tools` lists and receipts against the matrix entry. It applies
  to the standard `orchestrator-state` checkpoint, not to the epic (or future parallel) checkpoint
  validators, which validate `route_id` equality directly.
- `MANDATORY_ROUTE_PHASES` maps only `small` and `preparation`; routes absent from the map impose
  no phase-completeness requirement, so `parallel` needs no entry.

**Byte-identity constraint (verified):**
`tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` asserts
`config/orchestration-routing.json` and the bundled mirror
`extensions/drm-copilot/resources/config/orchestration-routing.json` are byte-for-byte identical.
Adding the `parallel` route requires editing both files identically. No test asserts a closed set
of route ids (searched `tests/` and `extensions/drm-copilot/test/`), so adding a route key is
additive-safe.

### 1.6 Test precedent

Python (Pytest, under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`):

- `test_validate_epic_orchestrator_state.py` (487 lines): a `build_valid_epic_state()` builder
  returning a minimally valid checkpoint dict, then one test per invariant that mutates one field
  and asserts on the exact or substring error message. No temp files; JSON passed as text.
- `test_validate_epic_planner_state.py` (360 lines): same builder-plus-mutation shape.
- `test_validate_orchestration_artifacts_dispatch.py`: CLI dispatch tests that monkeypatch
  `validator._read_text` with `build_read_text_stub(...)` and call `validator.main([...])`,
  asserting exit codes. Its module docstring records that it was split out of
  `test_validate_orchestration_artifacts.py` when that file exceeded the 500-line cap, and that
  shared builders are imported from the sibling module rather than duplicated.

TypeScript (Jest, under `extensions/drm-copilot/test/`):

- `test/lib/validate/epic-orchestrator-state-core.test.ts` and
  `epic-planner-state-core.test.ts` — per-invariant unit tests of the TS cores.
- `test/mcp-tool-inputs-epic-validation.test.ts` — `it.each` over the epic artifact types
  asserting `resolveValidateOrchestrationArtifactsToolInput` accepts them and forwards flags.
- `test/mcp-epic-validation-definitions.test.ts` — asserts both definition surfaces
  (`toolDefinitions` and `REPO_AUTOMATION_TOOL_DEFINITIONS`) carry the epic artifact types via
  `expect.arrayContaining`.
- `test/mcp-server-epic-validation.test.ts` — in-memory MCP client/server round trip
  (`InMemoryTransport.createLinkedPair()`) against a fully mocked `RepoAutomationService`,
  asserting the tool call is forwarded with resolved input.
- `test/repo-automation-orchestration-validation.test.ts` — service-level dispatch tests.

Note: the extension's Jest tests live in `extensions/drm-copilot/test/` (the package's established
mirror tree), not the repo-root `tests/` tree used by Pytest and Pester.

### 1.7 Frontmatter parsing capability

PyYAML is a declared dependency (`pyproject.toml` line 19: `PyYAML = ">=6.0"`), and
`scripts/dev_tools/codex_native_converter/parser.py` and `new_active_feature_folder_markdown.py`
already work with YAML frontmatter. No epic-manifest frontmatter validator exists in
`scripts/dev_tools` — the epic manifest is consumed by the planner agent and mirrored into the
checkpoint, which is what the validators check. The parallel manifest validator is therefore new
surface with no direct predecessor; the closest structural precedent is
`epic_kickoff_contract.py` (263 lines): a standalone `validate_*_text` module re-exported through
the planner validator. Line-ending tolerance is a known repository requirement (commit `b845c505`,
"fix(plan-validator): support CRLF and CR line endings").

### 1.8 Rules directory

`.claude/rules/` contains no epic-specific rule file; `.claude/rules/orchestrator-state.md` is the
single prose-rule precedent. `.claude/rules/parallel-orchestration.md` will be the first
surface-specific sibling. Rule files are Markdown (exempt from the 500-line cap).

## 2. Upstream Contracts (F1, F2) — Stated Assumptions

**Verified:** neither `parallel-blast-radius` nor `parallel-cohort-scheduler` has a feature folder
under `docs/features/active/` on this branch (glob returned no `*parallel*` folder other than this
feature's own). Their specs have not landed.

**ASSUMPTION A1 (blast-radius shape, from design §5.1–§5.2, not from a landed F1 spec):** the
`blast_radius` block is `{ paths: [glob...], modules: [project...], shared_surfaces: [path...],
contracts: [identifier...], source: derived|declared|observed, computed_at: iso8601 }`. All four
collection fields are lists of strings; `paths` is the primary signal.

**ASSUMPTION A2 (contention relation, from design §5.4, not from a landed F1 spec):**
`conflicts(a, b) = path_overlap OR module_overlap OR shared_surface_overlap OR contract_dependency`,
failing closed. This implies the `conflict_edges[].reason` enum recommended in §5.4 of this
document: `path_overlap | module_overlap | shared_surface_overlap | contract_dependency`.

**ASSUMPTION A3 (cohort shape, from design §6 and §12, not from a landed F2 spec):** a cohort is
`{ index: int >= 0, generation: int >= 0, item_keys: [item_key...] }`; `recolor_generation`
increments on each recompute (§8.6); coloring is deterministic Welsh-Powell with ties broken by
ascending item key; `max_concurrency` caps fan-out with slots filled in ascending item-key order.

**ASSUMPTION A4 (item key):** `issue_num` is the primary key (§11, epic shared-design decision 3),
so `item_key` values in `cohorts[].item_keys`, `conflict_edges[].a/b`, `mutations[].item_key`, and
`drift_events[].item_key` are integers equal to an `items[].issue_num`. "Ascending item key" in §6
is numeric ascending `issue_num`.

The spec must carry A1–A4 forward explicitly so that if F1/F2 specs land with a divergent shape,
the conflict is caught at spec review rather than at wave-4 integration.

## 3. Candidate Approaches and Recommendation

### 3.1 Decision — TypeScript MCP surface depth

- **Option A — full-parity TS port (epic precedent).** New TS core validators mirror the Python
  invariant set with byte-identical error strings, as `epic-orchestrator-state-core.ts` /
  `epic-planner-state-core.ts` do. Advantages: matches the established epic wiring exactly; the
  MCP tool (the agent-facing gate during parallel runs) enforces the same contract as the
  SubagentStop hooks that call the Python CLI; consistent with the repository's TS/Python parity
  goal (promoted potential entries `docs/features/potential/promoted/2026-07-10-validate-orchestration-ts-python-parity.md`
  and `2026-07-24-ts-validator-promotion-type-parity-gap.md`). Cost: roughly 900–1100 additional
  TS lines plus mirrored Jest tests.
- **Option B — thin TS structural check, Python authoritative.** Precedent exists in the
  `require_model_routing` gate ("The MCP TypeScript surface performs the existence check only; the
  Python validator remains authoritative", `.claude/rules/orchestrator-state.md`). Cost is far
  lower, but a structurally invalid parallel checkpoint would pass the MCP gate and be rejected
  only later by hooks — precisely the divergence the parity potential entries were filed to
  eliminate, and a trap for the F5/F7 consumers who will treat the MCP result as authoritative.

**Recommendation: Option A.** The model-routing exception was justified because its full check
requires recomputing a Python reference formula; the parallel validators are pure structural
checks with no such dependency, so the exception's rationale does not apply.

### 3.2 Decision — manifest validation placement

- **Option A — standalone manifest module, no new MCP artifact type.** Deliver
  `scripts/dev_tools/parallel_manifest_contract.py` exposing
  `validate_parallel_manifest_text(text) -> list[str]` plus default-resolving accessors; the
  planner-state validator reuses the same shared item/blast-radius helpers for the checkpoint's
  mirrored `items[]`. F4 wires manifest validation into the planner workflow.
- **Option B — third MCP artifact type `parallel-manifest`.** Uniform tooling access, but expands
  the MCP surface beyond the issue's acceptance criteria (which name exactly two new
  `artifact_type` values) and beyond the epic precedent (the epic manifest has no artifact type;
  only the kickoff document does).

**Recommendation: Option A.** It satisfies acceptance criterion "manifest schema is defined and
validated" while holding the MCP scope at exactly the two promised artifact types. If F4 finds it
needs MCP-reachable manifest validation, adding the artifact type then is additive.

### Rejected alternatives (summary)

- TS thin check (Option 3.1-B): rejected — parity divergence at the agent-facing gate.
- MCP `parallel-manifest` artifact type (Option 3.2-B): rejected for scope discipline; additive later.
- Importing or authoring a JSON Schema file for either checkpoint: rejected outright per the
  Foreign Schema Warning in `.claude/rules/orchestrator-state.md` and issue constraint "No foreign
  JSON Schema". Enforcement is Python validator logic plus prose rules.
- Refactoring epic validators into shared abstractions consumed by both surfaces: rejected —
  epic non-goal "Reuse is by near-verbatim adaptation into new files, not by refactoring the epic
  implementations into a shared abstraction", and issue constraint "the existing epic validators
  must not be modified or refactored".

## 4. Proposed Schemas (complete, field-by-field)

### 4.1 Manifest — `docs/features/parallel/<slug>/parallel.md` frontmatter (design §11)

| Field | Type | Required | Default | Constraint |
| --- | --- | --- | --- | --- |
| `parallel` | string | required | — | non-empty slug |
| `mode` | string | optional | `closed` | enum `closed \| open` |
| `max_concurrency` | int | optional | `4` | integer, `1 <= n <= 8` (bound recommendation, see note) |
| `created_at` | string | required | — | non-empty ISO-8601 text |
| `items` | list | required | — | may be empty at authoring time; each entry an object |
| `items[].issue_num` | int | required | — | positive integer; unique across items (primary key) |
| `items[].feature_folder` | string | required | — | non-empty resolvable-hint basename |
| `items[].kind` | string | required | — | enum `feature \| bug` |
| `items[].state` | string | required | — | enum `proposed \| admitted \| prepared \| scheduled \| in_flight \| merged \| withdrawn \| blocked` |
| `items[].blast_radius` | object | required | — | shape below (ASSUMPTION A1) |
| `items[].blast_radius.paths` | list[str] | required | — | list of non-empty glob/path strings |
| `items[].blast_radius.modules` | list[str] | required | — | list of non-empty strings (may be empty list) |
| `items[].blast_radius.shared_surfaces` | list[str] | required | — | list of non-empty strings (may be empty list) |
| `items[].blast_radius.contracts` | list[str] | required | — | list of non-empty strings (may be empty list) |
| `items[].blast_radius.source` | string | required | — | enum `derived \| declared \| observed` |
| `items[].blast_radius.computed_at` | string | required | — | non-empty ISO-8601 text |

Prohibited keys (explicit rejection, not mere absence): `depends_on` at any level;
`integration_branch` at top level. This converts the two acceptance criteria "no `depends_on` /
no integration-branch field exists anywhere" into testable negative invariants.

`max_concurrency` bound note: the design (§11, §13.4) sets only the default of 4. The 1–8 bound is
a recommendation for symmetry with the epic surface (`max_parallel_features` validated as
`1..8`, matching `codex_topology_policy.parallelism.hard_max_parallel_features: 8`). If the spec
author prefers no upper bound, the invariant reduces to "positive integer"; either choice must be
recorded in `.claude/rules/parallel-orchestration.md`.

### 4.2 Orchestrator checkpoint — `artifacts/orchestration/parallel-orchestrator-state.json` (design §12)

Baseline keys (mirroring the epic baseline so the existing structural hook checks can be reused
unmodified): `objective` (string), `completed_steps` (list), `next_step` (string),
`last_updated` (string). All required.

| Field | Type | Required | Constraint |
| --- | --- | --- | --- |
| `route_id` | string | required | exactly `"parallel"` |
| `parallel_slug` | string | required | non-empty |
| `parallel_manifest_path` | string | required | non-empty; expected form `docs/features/parallel/<slug>/parallel.md` |
| `parallel_status_doc_path` | string | required | non-empty; expected form `docs/features/parallel/<slug>/parallel-status.md` |
| `mode` | string | required | enum `closed \| open` (explicit in the checkpoint; the manifest default has been resolved by write time) |
| `max_concurrency` | int | required | integer `1..8` (same bound decision as manifest) |
| `current_cohort` | int | required | `>= 0` |
| `recolor_generation` | int | required | `>= 0` |
| `cohorts` | list | required | entries `{ index: int >= 0, generation: int >= 0, item_keys: [int...] }` (ASSUMPTION A3) |
| `items` | list | required | entries per table below |
| `conflict_edges` | list | required | entries `{ a: int, b: int, reason: enum }` |
| `mutations` | list | required (may be empty) | entries per §4.5 |
| `drift_events` | list | required (may be empty) | entries per §4.6 |
| `delegation_receipts` | list | optional | list when present (loose receipt shape, matching `_orchestrator_state_routing._list_receipts` tolerance) |
| `skill_receipts` | list | optional | list when present |
| `mcp_call_receipts` | list | optional | list when present |

`items[]` entries:

| Field | Type | Required | Constraint |
| --- | --- | --- | --- |
| `issue_num` | int | required | positive; unique (primary key) |
| `feature_folder` | string | required | non-empty |
| `state` | string | required | item-state enum (§4.4) |
| `blast_radius` | object | required | §4.1 shape |
| `worktree_path` | string or null | optional | non-empty when string |
| `branch_name` | string or null | optional | non-empty when string |
| `pr_number` | int or null | optional | positive when int |
| `pr_url` | string or null | optional | non-empty when string |
| `merge_status` | string | optional | merge-status enum (§4.4); treated as `not_started` when absent |
| `merge_commit_sha` | string or null | optional | non-empty when string |
| `worktree_created_at`, `started_at`, `merged_at`, `worktree_removed_at` | string or null | optional | lifecycle timestamps; non-empty when string |

Cache doctrine (issue constraint, design §12): every field above is re-derivable from
`git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`;
the checkpoint is a cache of durable state, not the source of truth. The rule file must restate
this so no downstream feature treats the checkpoint as authoritative.

### 4.3 Planner checkpoint — `artifacts/orchestration/parallel-planner-state.json`

Design §3 names this artifact but §12 details only the orchestrator checkpoint.
**ASSUMPTION A5:** the planner checkpoint shape below is F3-proposed by adaptation of
`validate_epic_planner_state.py` (`REQUIRED_KEYS` / `REQUIRED_FEATURE_KEYS`) with parallel
substitutions; F4 consumes it and must not add schema fields.

Required top-level keys: `objective`, `parallel_slug`, `parallel_manifest_path`, `mode`,
`max_concurrency`, `items`, `cohorts`, `conflict_edges`, `recolor_generation`,
`completed_steps`, `next_step`, `last_updated`. Optional: `kickoff_prompt_path` (string;
readiness-gated, see invariant P9).

Required per-item keys: `issue_num`, `feature_folder`, `kind`, `state`, `blast_radius`,
`preparation_status`, `research_path`, `plan_path`, `preflight_status`. (`complexity_band` is
recommended as optional, validated against `C1..C4` when present, mirroring the epic planner;
the spec should confirm whether F4 needs it required.)

Readiness sentinel: `next_step == "PARALLEL_EXECUTION_READY"` under the ready gate (mirror of
`EPIC_EXECUTION_READY`). No `epic_worthiness` analogue is carried: the parallel surface has no
worthiness verdict in the design; scale assessment happens before `/parallel-plan` is invoked.

Deliberately excluded from F3 (left to F4): the deep readiness-integrity machinery
(`epic_planner_readiness.py`-style git integrity, launch-evidence binding, kickoff-contract
cross-checks). F3's `require_ready_for_execution` gate is structural only (invariants P6–P9
below); F4 may layer repository-aware checks behind an additional keyword without changing the
schema.

### 4.4 Enums (all owned by F3; F6/F7/F8 consume, never extend)

- `mode`: `closed | open` (default `closed`) — §3, §8.7.
- Item `state`: `proposed | admitted | prepared | scheduled | in_flight | merged | withdrawn | blocked` — §8.2, §11.
- Per-item `merge_status`: `not_started | worktree_created | pr_open | ci_green | merged | worktree_removed | blocked_drift | blocked_ci_loop_limit` — §12.
- `blast_radius.source`: `derived | declared | observed` — §5.2.
- `items[].kind`: `feature | bug` — §11.
- `conflict_edges[].reason`: `path_overlap | module_overlap | shared_surface_overlap | contract_dependency` — recommended enum, one value per disjunct of the §5.4 relation (ASSUMPTION A2). The relation is a disjunction, so a single reason (the first matching disjunct in the order above) is sufficient to justify an edge; recording one edge per pair with its strongest/first reason keeps the graph simple and the recomputation deterministic.
- `mutations[].op`: `add | remove | close | requeue` — §8.6 ("every add, remove, close, and drift-induced requeue").
- `mutations[].disposition`: `detach | abandon | null` — §8.4.
- `drift_events[].action`: `raised_blocking_finding | halted_later_started_item` — recommended enum from the §7 procedure: step 2 always raises a Blocking finding; step 5 additionally halts the later-started item of a newly conflicting pair. Recommended recording rule (F3-owned decision, to be restated in the rule file): one event per drift occurrence carrying the strongest action taken (`halted_later_started_item` subsumes the finding).

### 4.5 `mutations[]` entry (design §8.6)

`{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`

| Field | Type | Constraint |
| --- | --- | --- |
| `op` | string | enum §4.4 |
| `item_key` | int or null | must resolve to an `items[].issue_num` for `add`/`remove`/`requeue`; must be null for `close` (a run-level operation) |
| `at` | string | non-empty ISO-8601 text |
| `prior_state` | string or null | item-state enum member or null; must be null for `add` and `close` |
| `new_state` | string or null | item-state enum member or null; must be null for `close` |
| `disposition` | string or null | must be null unless `op == "remove"`; must be exactly `detach` or `abandon` when `op == "remove"` and `prior_state == "in_flight"` (the accepted in-flight-removal decision, §3/§8.4) |
| `recolor_generation` | int | `>= 0` and `<=` the top-level `recolor_generation` |

Transition legality (which state may follow which) is F6 behavior, not F3 schema; F3 validates
shape, enum membership, and the null-rules above only.

### 4.6 `drift_events[]` entry (design §7)

`{ item_key, declared, observed, escaped_paths, at, action }`

| Field | Type | Constraint |
| --- | --- | --- |
| `item_key` | int | must resolve to an `items[].issue_num` |
| `declared` | list[str] | the declared `blast_radius.paths` at detection time; list of non-empty strings |
| `observed` | list[str] | the observed diff path set; list of non-empty strings |
| `escaped_paths` | list[str] | non-empty list of non-empty strings (an event with zero escaped paths is not a drift event) |
| `at` | string | non-empty ISO-8601 text |
| `action` | string | enum §4.4 |

### 4.7 `conflict_edges[]` entry (design §12)

`{ a: int, b: int, reason: enum }` — `a` and `b` must resolve to distinct `items[].issue_num`
values; recommended normalization `a < b` (numeric) so recomputation is deterministic and edge
identity is canonical; duplicate `(a, b)` pairs are malformed.

### 4.8 Fields present in the epic checkpoint schema that MUST be omitted (issue constraint 3)

| Epic field | Disposition in parallel schema |
| --- | --- |
| `integration_branch` (top level) | OMITTED — no integration branch (§4); its presence is a prohibited-key violation |
| `epic_merge_pr` / `epic_merge_pr.merge_commit_sha` | OMITTED — no final integration PR; the completion gate checks per-item terminal states instead |
| `features[].depends_on` | OMITTED everywhere — ordering is derived from blast-radius overlap (§4, §11); presence is a prohibited-key violation |
| `waves[]`, `features[].wave_number`, `current_wave` | REPLACED by `cohorts[]` / `current_cohort` / `recolor_generation` |
| `max_parallel_features` | REPLACED by `max_concurrency` |
| `epic_feature_folder` | REPLACED by `parallel_slug` (+ `parallel_manifest_path`, `parallel_status_doc_path`) |
| merge-status values `merge_conflict`, `blocked_conflict_loop_limit` | REPLACED by `blocked_drift`, `blocked_ci_loop_limit` — the fan-in merge-conflict path does not exist; drift and per-item CI loops are the parallel failure modes |
| planner `epic_worthiness`, `NON_EPIC_RECOMMENDED` branch | OMITTED — no worthiness verdict in the parallel planner contract |

Per-item `merge_commit_sha` is retained (§12 lists it in `items[]`); only the run-level merge-PR
block is omitted.

## 5. Proposed Validator Invariants (numbered prose, `.claude/rules/orchestrator-state.md` style)

These are drafted so `.claude/rules/parallel-orchestration.md` can carry them nearly verbatim.
Each names the malformed condition. Error strings should use the prefixes `Parallel checkpoint`,
`Parallel planner checkpoint`, and `Parallel manifest` respectively, following the literal
context-prefixed epic style.

### 5.1 Invariants — parallel-orchestrator checkpoint (`validate_parallel_orchestrator_state_text`)

1. **Required keys.** The checkpoint must carry `objective`, `completed_steps`, `next_step`,
   `last_updated`, `route_id`, `parallel_slug`, `parallel_manifest_path`,
   `parallel_status_doc_path`, `mode`, `max_concurrency`, `current_cohort`,
   `recolor_generation`, `cohorts`, `items`, `conflict_edges`, `mutations`, and `drift_events`.
   A missing key is a malformed checkpoint (one error per missing key).
2. **Route identity.** `route_id` must be exactly `'parallel'`. Any other value is a malformed
   checkpoint.
3. **Mode enum.** `mode` must be `closed` or `open`. Any other value is a malformed checkpoint.
4. **Bounded concurrency.** `max_concurrency` must be an integer from 1 through 8 (not a boolean).
   Any other value is a malformed checkpoint. (Bound per §4.1 note.)
5. **Item uniqueness and shape.** Each `items[]` entry must be an object whose `issue_num` is a
   positive integer unique across items and whose `feature_folder` is a non-empty string. A
   duplicate `issue_num`, a non-positive or missing `issue_num`, or an empty `feature_folder` is a
   malformed item.
6. **Item state enum.** Each item's `state` must be one of the eight item-state values (§4.4).
   A missing or out-of-enum `state` is a malformed item.
7. **Merge-status enum.** Each item's `merge_status`, when present, must be one of the eight
   merge-status values (§4.4). An out-of-enum value is a malformed item.
8. **State/merge-status consistency.** An item whose `merge_status` is `merged` or
   `worktree_removed` must have `state == 'merged'`; an item whose `merge_status` is
   `blocked_drift` or `blocked_ci_loop_limit` must have `state == 'blocked'`. Any other pairing of
   those merge statuses is a malformed item.
9. **Blast-radius shape.** Each item's `blast_radius` must be an object carrying `paths`,
   `modules`, `shared_surfaces`, and `contracts` as lists of non-empty strings, a `source` in
   `{derived, declared, observed}`, and a non-empty `computed_at` string. A missing block, a
   missing field, a non-list collection, or an out-of-enum `source` is a malformed item.
10. **Prohibited dependency edges.** No object anywhere in the checkpoint's `items[]` (and no
    top level key) may carry a `depends_on` key. A present `depends_on` key is a malformed
    checkpoint — ordering is expressed only as blast-radius overlap (§4, §11).
11. **Prohibited integration-branch fields.** The checkpoint must not carry `integration_branch`
    or `epic_merge_pr` at any level. A present key is a malformed checkpoint — each parallel item
    PRs to `main` independently (§4).
12. **Cohort shape and resolution.** Each `cohorts[]` entry must be an object with a non-negative
    integer `index`, a non-negative integer `generation` that is `<= recolor_generation`, and an
    `item_keys` list in which every entry resolves to an `items[].issue_num`. An unresolved item
    key, a negative index, or a generation above `recolor_generation` is a malformed cohort.
13. **Current-generation cohort uniqueness.** Among the `cohorts[]` entries whose `generation`
    equals `recolor_generation`, `index` values must be unique and every non-withdrawn item must
    appear in exactly one such cohort's `item_keys`. A duplicated index or a doubly-assigned item
    is a malformed cohort table. (An item in no current-generation cohort is permitted only in
    state `withdrawn`, `merged`, or `blocked`.)
14. **Current-cohort bound.** `current_cohort` must be a non-negative integer; when any
    current-generation cohort exists, `current_cohort` must not exceed the maximum
    current-generation `index`. A violation is a malformed checkpoint.
15. **Conflict-edge shape.** Each `conflict_edges[]` entry must be an object whose `a` and `b`
    resolve to distinct `items[].issue_num` values with `a < b`, and whose `reason` is one of
    `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`. A
    self-edge, an unresolved endpoint, an unnormalized or duplicate pair, or an out-of-enum
    reason is a malformed edge.
16. **Mutation shape.** Each `mutations[]` entry must satisfy the §4.5 table: `op` in the enum;
    `item_key` resolving for `add`/`remove`/`requeue` and null for `close`; non-empty `at`;
    `prior_state`/`new_state` null or in the item-state enum, with the op-specific null rules;
    `recolor_generation` a non-negative integer `<=` the top-level `recolor_generation`. A
    violation is a malformed mutation.
17. **In-flight removal requires a disposition.** A `mutations[]` entry with `op == 'remove'` and
    `prior_state == 'in_flight'` must carry `disposition` exactly `'detach'` or `'abandon'`; a
    `disposition` on any other entry must be null. A violation is a malformed mutation (§3, §8.4).
18. **Drift-event shape.** Each `drift_events[]` entry must satisfy the §4.6 table, including a
    resolving `item_key`, list-of-string `declared`/`observed`, a non-empty `escaped_paths` list,
    a non-empty `at`, and an `action` in the enum. A violation is a malformed drift event.
19. **Receipt arrays.** `delegation_receipts`, `skill_receipts`, and `mcp_call_receipts`, when
    present, must each be a list. A non-list value is a malformed checkpoint. (Per-receipt content
    validation follows the loose tolerance of the standard checkpoint validators.)
20. **Completion gate (`require_complete`, closed mode).** Under `require_complete` with
    `mode == 'closed'`, every item whose `state` is not `withdrawn` must have `merge_status` in
    `{merged, worktree_removed}`. Any other status is a completion failure (§8.7).
21. **Completion gate (`require_complete`, open mode).** Under `require_complete` with
    `mode == 'open'`, the checkpoint must additionally record a `mutations[]` entry with
    `op == 'close'` (the `/parallel-close` record, §8.5); invariant 20's per-item condition
    applies as well. An open-mode checkpoint with no close mutation is a completion failure.

Not in F3: the retrospective cohort-ordering invariant (`PARALLEL_COHORT_BARRIER_VIOLATION`,
design §9 Layer 2) is F7's explicitly assigned addition to this validator. F3 must structure the
module so F7 can add it as one new helper call without reflowing existing code (a distinct,
appendable helper-invocation block in the entry point, matching the epic wave-4 contention rule).

### 5.2 Invariants — parallel-planner checkpoint (`validate_parallel_planner_state_text`)

P1. **Required keys.** The §4.3 top-level key set must be present; one error per missing key.
P2. **Route-consistent identity.** `parallel_slug` and `parallel_manifest_path` must be non-empty
    strings; `mode` and `max_concurrency` satisfy orchestrator invariants 3 and 4.
P3. **Item shape.** Each `items[]` entry must carry the §4.3 per-item required keys; `issue_num`
    unique positive integer; `kind` in `{feature, bug}`; `state` in the item-state enum;
    `blast_radius` per orchestrator invariant 9; `complexity_band`, when present, in
    `{C1, C2, C3, C4}`. Prohibited keys per orchestrator invariants 10–11 apply.
P4. **Cohort and edge shape.** `cohorts[]`, `conflict_edges[]`, and `recolor_generation` satisfy
    orchestrator invariants 12–15.
P5. **Deterministic recoloring seam.** (Deliberately absent: F3 does not recompute the coloring.
    Recomputation parity against `parallel_cohort_computation.py` is F4's planner-side check, the
    analogue of the epic planner's `compute_wave_numbers` cross-check. Recorded here so the spec
    states the omission explicitly.)
P6. **Ready gate — cardinality.** Under `require_ready_for_execution`, `items` must contain at
    least two entries. Fewer is a readiness failure.
P7. **Ready gate — preparation.** Under `require_ready_for_execution`, each item must have
    `preparation_status == 'prepared'`, `preflight_status == 'PREFLIGHT: ALL CLEAR'`, non-empty
    `research_path` and `plan_path`, and `blast_radius.source == 'declared'` (§5.2: only the
    planner-computed radius is authoritative for scheduling). Any other value is a readiness
    failure.
P8. **Ready gate — sentinel.** Under `require_ready_for_execution`, `next_step` must be exactly
    `'PARALLEL_EXECUTION_READY'`.
P9. **Ready gate — kickoff path.** Under `require_ready_for_execution`, `kickoff_prompt_path`
    must be exactly `artifacts/orchestration/parallel-kickoff-<parallel_slug>.md` (mirror of the
    epic kickoff-path invariant). ASSUMPTION A6: the kickoff filename convention is F3-proposed by
    adaptation; F4 consumes it.

### 5.3 Invariants — manifest (`validate_parallel_manifest_text`)

M1. **Frontmatter block.** The document must open with a `---` YAML frontmatter block terminated
    by `---`, parseable by `yaml.safe_load` into a mapping, tolerant of LF, CRLF, and CR line
    endings (precedent: commit `b845c505`). A missing, unterminated, unparseable, or non-mapping
    block is a malformed manifest.
M2. **Slug.** `parallel` must be a non-empty string.
M3. **Mode default.** `mode`, when present, must be `closed` or `open`; when absent it defaults to
    `closed` (the accessor `manifest_mode(mapping)` returns the default; the validator emits no
    error for absence). An out-of-enum value is a malformed manifest.
M4. **Concurrency default.** `max_concurrency`, when present, must be an integer from 1 through 8;
    when absent it defaults to 4 (accessor `manifest_max_concurrency(mapping)`). An out-of-range
    or non-integer value is a malformed manifest.
M5. **Created-at.** `created_at` must be a non-empty string.
M6. **Items.** `items` must be a list; each entry must satisfy the §4.1 item table, including
    `issue_num` uniqueness and the full `blast_radius` shape.
M7. **Prohibited keys.** No `depends_on` key may appear at any level and no `integration_branch`
    key at top level. A present key is a malformed manifest.

## 6. Files to Create and Modify

### 6.1 New Python production files (all under `scripts/dev_tools/`, est. lines include the mandatory docstring/comment density)

| File | Content | Est. lines |
| --- | --- | --- |
| `_parallel_state_common.py` | All enums as module constants (`VALID_ITEM_STATES`, `VALID_MERGE_STATUS`, `VALID_SOURCES`, `VALID_KINDS`, `VALID_MODES`, `VALID_MUTATION_OPS`, `VALID_DISPOSITIONS`, `VALID_EDGE_REASONS`, `VALID_DRIFT_ACTIONS`); `blast_radius` block validator; item-shape validator (uniqueness, state/merge-status enums + consistency); prohibited-key scanner (`depends_on`, `integration_branch`, `epic_merge_pr`); shared string/int helpers | ~300 |
| `_parallel_state_structures.py` | `cohorts[]` (+ current-generation uniqueness/coverage), `conflict_edges[]`, `mutations[]`, `drift_events[]`, receipt-array validators | ~330 |
| `validate_parallel_orchestrator_state.py` | Entry point `validate_parallel_orchestrator_state_text(text, *, require_complete=False)`; required keys; route/mode/concurrency; helper orchestration; mode-dependent completion gate; a clearly delimited appendable block for F7's Layer-2 invariant | ~300 |
| `parallel_manifest_contract.py` | Frontmatter extraction (CR/LF/CRLF tolerant), `validate_parallel_manifest_text(text)`, accessors `manifest_mode(...)` / `manifest_max_concurrency(...)` returning defaults; reuses `_parallel_state_common` item validators | ~260 |
| `validate_parallel_planner_state.py` | Entry point `validate_parallel_planner_state_text(text, *, require_ready_for_execution=False)`; P1–P4 structural checks; P6–P9 ready gate | ~300 |

### 6.2 New TypeScript production files (under `extensions/drm-copilot/src/lib/validate/`)

| File | Content | Est. lines |
| --- | --- | --- |
| `parallel-state-shared.ts` | Enum constants + shared item/blast-radius/prohibited-key validators; error strings byte-identical to `_parallel_state_common.py` | ~280 |
| `parallel-state-structures.ts` | cohorts/conflict-edges/mutations/drift-events validators; parity with `_parallel_state_structures.py` | ~320 |
| `parallel-orchestrator-state-core.ts` | `validateParallelOrchestratorStateText(text, options)` mirroring the Python entry point | ~280 |
| `parallel-planner-state-core.ts` | `validateParallelPlannerStateText(text, options)` | ~280 |

### 6.3 New documentation / configuration

| File | Content |
| --- | --- |
| `.claude/rules/parallel-orchestration.md` | The §5 invariants as numbered prose; the Foreign Schema Warning restated for the parallel artifacts; the cache-not-source-of-truth doctrine; the omitted-epic-fields table; the enum ownership statement (F6/F7/F8 consume, never extend); Markdown, exempt from the line cap |

### 6.4 Modified files (every one additive; epic validators untouched)

| File | Change |
| --- | --- |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | Two new subparsers (`parallel-orchestrator-state` with `--require-complete`; `parallel-planner-state` with `--require-ready-for-execution`) + two dispatch branches + two imports. ~+45 lines on a 357-line file — within cap |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | Two new `switch` cases + imports + two option-threading blocks; extend `ValidateArtifactInput` docs if a new flag name is needed (none is: `requireComplete` and `requireReadyForExecution` already exist). ~+45 lines on a 257-line file |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | Add `"parallel-orchestrator-state"`, `"parallel-planner-state"` to `VALID_ARTIFACT_TYPES` (line ~427) |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | Add both values to the `artifact_type` enum (~line 403); update the `require_complete` and `require_ready_for_execution` descriptions to name the parallel types |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | Identical enum + description edits (~line 342) — kept aligned by `mcp-epic-validation-definitions.test.ts`-style assertions |
| `config/orchestration-routing.json` | Add the `parallel` route entry (§7 below) |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | Byte-identical mirror of the same edit (enforced by `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`) |

Files verified as requiring no change: `mcp-tools.ts`, `mcp-handlers/template-validation-handlers.ts`,
`lib/validate/validate-orchestration-service-call.ts`, `repo-automation-tool-names.ts`,
`mcp-server.ts`, all `validate_epic_*` / `_epic_*` Python modules, all `epic-*` TS modules.

## 7. Proposed `parallel` Route Entry

Adapted from the `epic` entry with the structural deltas applied:

```json
"parallel": {
  "description": "Parallel path for scheduling independent items into blast-radius cohorts across parallel worktrees; each item PRs to main independently with no integration branch.",
  "requires_pr_gate": false,
  "required_agents": ["orchestrator", "pr-author"],
  "required_skills": [
    "parallel-orchestrate",
    "orchestrate",
    "feature-promotion-lifecycle",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "evidence-and-timestamp-conventions",
    "pr-context-artifacts",
    "pr-base-branch-merge-base"
  ],
  "required_mcp_tools": ["collect_pr_context", "validate_orchestration_artifacts"]
}
```

Rationale and verified safety:

- `requires_pr_gate: false` because there is no single run-level PR to gate (§4); each child's own
  `large`-route checkpoint enforces its per-item PR gate. (The epic route sets `true` for its
  final integration PR, which the parallel surface deliberately lacks.)
- `validate_route_membership` only checks key membership, so adding the route is what makes
  `route_id: "parallel"` checkpoints valid — no other consumer enumerates a closed route set
  (verified: no test asserts the route-id list; the only routing-config test is the byte-identity
  parity test).
- `required_skills` names `parallel-orchestrate` before that skill exists (F5). This is data, not
  a file reference; `validate_routing_contract` compares checkpoint lists against the matrix only
  for standard orchestrator checkpoints, which never select `route_id: parallel`. Provisional
  status must be recorded in the spec so F5 confirms or amends the list.
- `MANDATORY_ROUTE_PHASES` needs no `parallel` entry (routes absent from the map impose no
  phase-completeness requirement — verified in `_orchestrator_state_routing.py`).

## 8. Test Surface (mapped to invariants; targets line >= 85% / branch >= 75%)

### 8.1 Python (Pytest, `tests/scripts/dev_tools/`, mirroring production placement)

| Test file | Covers | Est. lines |
| --- | --- | --- |
| `test_validate_parallel_orchestrator_state.py` | Builder `build_valid_parallel_state()`; invariants 1–11, 14, 19; invalid-JSON / non-object root; absent-optional-receipts backward-compat case | ~450 |
| `test_validate_parallel_orchestrator_state_structures.py` | Invariants 12–13, 15–18 (cohorts, edges, mutations incl. disposition rule, drift events); shares the builder via sibling import (established convention per the dispatch-test docstring) | ~430 |
| `test_validate_parallel_orchestrator_state_completion.py` | Invariants 20–21 (closed/open completion, close-mutation requirement); withdrawn-item exemption | ~200 |
| `test_validate_parallel_planner_state.py` | P1–P4, P6–P9; ready-gate positive and per-field negative cases | ~400 |
| `test_parallel_manifest_contract.py` | M1–M7; CRLF/CR tolerance; `mode`/`max_concurrency` default accessors; `depends_on` rejection | ~350 |
| `test_validate_orchestration_artifacts_parallel_dispatch.py` | New CLI subparsers and dispatch branches via monkeypatched `_read_text` + `validator.main([...])` exit codes; a **new file** so the existing epic dispatch test is untouched (acceptance criterion: epic validators and their tests unchanged) | ~180 |

Per-invariant coverage discipline (from the seeded test conditions): valid case, each malformed
case, and — where a key is optional — the absent-key case. Enum-membership tests should use
`pytest.mark.parametrize` over each enum. No temp files; state built as dicts and serialized with
`json.dumps` (established pattern). Property-based tests: the validators are T2-adjacent dev
tooling; if the spec classifies the new modules at T1/T2 in `quality-tiers.yml`, add at least one
`hypothesis` property per pure helper (e.g., prohibited-key scanner over arbitrary nested dicts;
edge-normalization over arbitrary int pairs); otherwise unit tests suffice per the tier matrix.

### 8.2 TypeScript (Jest, `extensions/drm-copilot/test/`)

| Test file | Covers |
| --- | --- |
| `lib/validate/parallel-orchestrator-state-core.test.ts` | TS mirror of invariants 1–21, error strings asserted byte-identical to Python |
| `lib/validate/parallel-planner-state-core.test.ts` | TS mirror of P1–P9 |
| `mcp-tool-inputs-parallel-validation.test.ts` | `it.each` over both new artifact types; flag forwarding; mirrors `mcp-tool-inputs-epic-validation.test.ts` |
| `mcp-parallel-validation-definitions.test.ts` | Both definition surfaces carry both new enum values (`expect.arrayContaining`); mirrors `mcp-epic-validation-definitions.test.ts` |
| `mcp-server-parallel-validation.test.ts` | In-memory MCP round trip with mocked `RepoAutomationService` (`InMemoryTransport.createLinkedPair()`); mirrors `mcp-server-epic-validation.test.ts` |

Unknown-artifact-type regression: already covered by the existing prefix-asserting negative test
(`mcp-tool-inputs.test.ts:114`) and the `validateArtifact` default branch; add one explicit
unknown-type case in the new dispatch tests on both sides to satisfy the seeded condition
"unknown `artifact_type` values still fail".

### 8.3 Epic-unchanged regression evidence

The acceptance criterion "existing epic validators are unmodified" is best evidenced by the
feature-review diff (no hunks under `validate_epic_*`, `_epic_*`, `epic-*-core.ts`, or their
tests), not by a brittle checksum unit test. Recommend recording this as a review checklist item
in the spec rather than a test.

## 9. Assumptions Register (carry into spec verbatim)

- **A1** `blast_radius` shape taken from design §5.1–§5.2; F1 spec not landed (verified absent).
- **A2** `conflict_edges[].reason` enum derived from the §5.4 disjuncts; F1 spec not landed.
- **A3** `cohorts[]` shape `{index, generation, item_keys[]}` and `recolor_generation` semantics
  taken from design §6/§8.6/§12; F2 spec not landed (verified absent).
- **A4** `item_key == issue_num` (integer) in all cross-referencing arrays; "ascending item key"
  is numeric ascending `issue_num`.
- **A5** Planner-checkpoint shape is F3-proposed by adaptation of the epic planner validator;
  design §12 details only the orchestrator checkpoint. F4 consumes without adding fields.
- **A6** Kickoff path convention `artifacts/orchestration/parallel-kickoff-<slug>.md` is
  F3-proposed by adaptation of the epic invariant; F4 consumes.
- **A7** `max_concurrency` upper bound of 8 is an F3 recommendation for epic symmetry, not a
  design requirement; the spec must accept or strike it.
- **A8** `drift_events[].action` enum and single-event-strongest-action recording rule are
  F3-owned decisions derived from the §7 procedure; F8 consumes without extending.

## 10. Applicable Policy Citations

- `.claude/rules/python.md` — Black/Ruff/Pyright/Pytest loop; full type hints; absolute imports;
  coverage line >= 85%, branch >= 75%; no temp files or external processes in unit tests.
- `.claude/rules/self-explanatory-code-commenting.md` — mandatory docstrings on every function
  including private helpers; intent comments on loops and branches (inflates line estimates; the
  §6 figures account for it).
- `.claude/rules/general-code-change.md` — 500-line hard cap on production and test files
  (drives the helper-module decomposition and the three-way test split); fail-fast error handling.
- `.claude/rules/general-unit-test.md` — tests in `tests/` mirroring production structure
  (Python); AAA structure; determinism; temp files prohibited. The extension's Jest tests follow
  the package-local `extensions/drm-copilot/test/` mirror (established convention, verified).
- `.claude/rules/typescript.md` — Prettier/ESLint/TSC/Jest loop; no new runtime dependencies;
  kebab-case filenames; `unknown` + narrowing over `any`.
- `.claude/rules/orchestrator-state.md` — prose-plus-validator enforcement; Foreign Schema
  Warning; key-gated additive invariants; literal context-prefixed error style.
- `.claude/rules/quality-tiers.md` — the new modules must be classified in `quality-tiers.yml`
  if that file exists by execution time (see risk R3).

## 11. Risks and Open Questions for Spec Authoring

- **R1 — F1/F2 shape drift.** If either sibling spec lands with a shape differing from A1–A4, this
  feature's schema must be reconciled at spec review. Mitigation: the assumptions register.
- **R2 — TS parity cost.** Option 3.1-A adds ~1,160 TS production lines plus tests; the atomic
  plan should sequence Python first (authoritative), then port with byte-identical strings, so the
  Python tests serve as the parity oracle.
- **R3 — `quality-tiers.yml` absence.** `.claude/rules/quality-tiers.md` mandates a repo-root
  `quality-tiers.yml`, but the epic's F1 section records that no such file exists yet. F3's new
  modules should be classified if the file exists when F3 executes (F1 may create it in wave 0);
  otherwise no classification action is possible — record the state observed at execution time.
- **R4 — F7 seam.** The orchestrator validator must expose a clearly delimited insertion point for
  F7's cohort-ordering invariant (`PARALLEL_COHORT_BARRIER_VIOLATION`) so the wave-4 edit is one
  appended helper call, per the epic's wave-4 contention rule.
- **R5 — invariant 13 strictness.** Requiring every non-withdrawn item to appear in exactly one
  current-generation cohort assumes the planner always emits a full coloring. If F4 finds partial
  colorings legitimate mid-mutation, the invariant may need to relax to "at most one". The spec
  should confirm with the §8.1 pinning model (recoloring is a pure function over the unstarted
  subgraph, which implies full coverage of unstarted items).
