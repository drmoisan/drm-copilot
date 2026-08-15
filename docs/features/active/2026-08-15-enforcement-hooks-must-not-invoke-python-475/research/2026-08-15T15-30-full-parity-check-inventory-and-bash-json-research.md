# Research: Full-Parity Check Inventory and Bash JSON-Parsing Assessment (Issue #475)

- Timestamp: 2026-08-15T15-30
- Issue: #475
- Scope: Prepare both branches of the pending owner decision (HI-1) on the target language for a complete-parity port of the orchestrator-state completion validator. Deliverable 1 enumerates every check the Python validator performs for the hook's call (the PowerShell-branch parity checklist). Deliverable 2 assesses `jq` versus a hand-rolled bash JSON parser (the bash-branch implementation decision). This document does NOT recommend a language; that decision is the owner's.
- Method: Read-only file analysis. No Python was executed. Every claim cites a file path and line number from worktree state at the time of writing. This document extends `research/2026-08-15T09-00-python-free-enforcement-hooks-research.md` (sections 3.2 and 3.4) and reuses its U/C/M family labels.

## 1. Scope of the validated call

The hook's Python invocation is `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete --require-model-routing` (`validate-orchestrator-output.ps1:196-197`, per prior research §3.1). The CLI maps this to `validate_orchestrator_state_text(text, require_complete=True, require_model_routing=True)` with all other keywords `False` (`validate_orchestration_artifacts.py:319-329`).

Consequences verified from the CLI source:

- `strict_route_membership` has NO CLI flag at all (`build_parser`, `validate_orchestration_artifacts.py:188-229`). `validate_route_membership` is still EXECUTED unconditionally (`validate_orchestrator_state.py:465-470`) but its errors are discarded for every CLI call. Its disk read is not discarded — see §3.
- `--require-pr-creation-ready`, `--require-codex-model-routing`, `--require-codex-topology` exist but are not passed by the hook; their gates do not fire. The codex RECEIPT validators still fire key-gated in the unconditional block (rows U6.X, U6.T below) — the flags control only the codex existence GATES.
- Missing checkpoint file: `_read_text` raises `OSError` (`validate_orchestration_artifacts.py:46-66`) which nothing catches; the process terminates with a traceback and non-zero exit. Fail-closed in effect, but with traceback text rather than a validator error string.
- Per defect D-1 (prior research §1.3), the hook is also wired for `epic-orchestrator-state` and `parallel-orchestrator-state` (`settings.json:265,274`). For those artifact types the Python behavior under the hook's flags is an argparse usage error (exit 2) because neither subparser defines `--require-model-routing` (`validate_orchestration_artifacts.py:231-270`). The Python validator therefore performs ZERO checkpoint checks for those types under the hook's call; there is no check list to port. The parity target for the epic/parallel wiring is a design decision the feature must make explicitly, not an inventory item. The epic/parallel validators themselves (`validate_epic_orchestrator_state.py`, `validate_parallel_orchestrator_state.py`) are out of scope of this inventory per the delegation's module list.

## 2. Deliverable 1 — Full-parity check inventory

Row conventions:

- Check ID: stable, assigned here; aligned with the prior research's U/C/M families.
- Trigger: `always` (every call), `key-gated` (runs only when the named key is present), `value-gated` (runs only for specific field values), `flag-gated:complete` / `flag-gated:model-routing` (the hook passes both flags, so these fire on every hook call subject to their inner gates), `route-gated` (depends on the selected route / routing matrix), `config-read` (reads `config/orchestration-routing.json` from disk at validation time — see §3).
- Error strings are exact templates from source. `{x}` marks Python interpolation; `{x!r}` marks Python `repr()` interpolation.
- PowerShell equivalent cites `.claude/lib/orchestrator-state/OrchestratorState.psm1` (OS), `OrchestratorStateCompletion.psm1` (OSC), `.claude/lib/model-routing/ModelRouting.psm1` (MR), or is `ABSENT`.

### 2.1 U family — unconditional block

#### U1 — parse and root

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U1.1 | `validate_orchestrator_state.py:405-408` | always | `Checkpoint is not valid JSON: {exc}` | PARTIAL — OS:175-183 emits `Checkpoint file '<path>' is not valid JSON: <msg>` (different text; also adds missing-file OS:153-159 and empty-file OS:165-171 errors the Python CLI surfaces only as an OSError traceback) |
| U1.2 | `validate_orchestrator_state.py:410-411` | always | `Checkpoint root must be a JSON object.` | PARTIAL — OS:187-193, text `Checkpoint file '<path>' root must be a JSON object.` |

#### U2-U4 — required keys, step status, blocked_reason

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U2.1 | keys `validate_orchestrator_state.py:69-92`, loop `:416-418` | always (22 keys, one error each) | `Checkpoint missing required key: {key}` | PRESENT — OS:37-60 (constants), OS:260-264 |
| U3.1 | `_orchestrator_state_step_status.py:112-148` (shared set `validate_orchestrator_state.py:93-102`, extras `_orchestrator_state_step_status.py:64-69`) | always; per present non-null step key | `Checkpoint has invalid {key}: {value}` | PRESENT — OS:64-93 (constants incl. per-key extras), OS:269-278 |
| U4.1 | `validate_orchestrator_state.py:103-111,426-428` | always; when `blocked_reason` present and non-null | `Checkpoint has invalid blocked_reason: {blocked_reason}` | PRESENT — OS:97-105, OS:281-284 |

#### U5 — delegation_receipts shape (`validate_orchestrator_state.py:430-445`; runs when `delegation_receipts` is not `None`)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U5.1 | `:302-304` | list form, per non-object entry | `Checkpoint delegation receipt #{index} must be an object.` | ABSENT |
| U5.2 | `:306-310` (keys `:112-121`, 8 keys) | list form, per missing key per receipt | `Checkpoint delegation receipt #{index} missing key: {key}` | ABSENT |
| U5.3 | `:311-316` | list form, when `artifact_paths` present non-null and not a list | `Checkpoint delegation receipt #{index} artifact_paths must be a list.` | ABSENT |
| U5.4 | `:343-351` | object form, per key outside `{agents, promotion}` | `Checkpoint delegation_receipts object contains unsupported key: {key}` | ABSENT |
| U5.5 | `:353-360` | object form, `agents` present and not a list (else U5.1-U5.3 applied to it) | `Checkpoint delegation_receipts.agents must be a list.` | ABSENT |
| U5.6 | `:362-369` | object form, `promotion` present and not an object | `Checkpoint delegation_receipts.promotion must be an object namespace.` | ABSENT |
| U5.7 | `:371-383` (keys `:124-128`) | object form, per promotion key outside `{potential_entry, issue, feature_folder}` | `Checkpoint delegation_receipts.promotion contains unsupported key: {key}` | ABSENT |
| U5.8 | `:442-445` | `delegation_receipts` neither list nor object | `Checkpoint delegation_receipts must be a list or object namespace.` | ABSENT |

#### U6.R — remediation_loop (key-gated; dispatch `validate_orchestrator_state.py:447-463`; a non-object `remediation_loop` or non-list `cycles` yields ZERO errors, `:206-217`)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U6.R1 | `:222-224` | per non-object cycle | `Checkpoint remediation cycle #{index} must be an object.` | ABSENT |
| U6.R2 | `:170-176` | per cycle | `Checkpoint remediation cycle #{index} plan_path must be a non-empty string.` | ABSENT |
| U6.R3 | `:179-194` (statuses `:134-139`) | per cycle whose `execution_status` in `{in_progress, complete, failed}` and `preflight.final_status != 'clear'` | `Checkpoint remediation cycle #{index} execution_status is {execution_status} but preflight.final_status is not 'clear'.` | ABSENT |
| U6.R4 | `:196-201` | per cycle with `exit_condition_met is True` and `blocking_count != 0` | `Checkpoint remediation cycle #{index} exit_condition_met is true but blocking_count is not 0.` | ABSENT |

#### U6.H — human_interaction (key-gated; `_orchestrator_state_human_interaction.py`)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U6.H1 | `:86-88` | key present, value not object | `Checkpoint human_interaction must be an object when present.` | ABSENT in libs; hook-internal `Test-HumanInteractionShape` exists and is STRICTER (blocks `halt`, verifies runbook file existence) per prior research §3.3 — parity vs. the stricter hook check must be reconciled explicitly |
| U6.H2 | `:92-95` | `requirements` missing or not a list | `Checkpoint human_interaction.requirements must be a list.` | same note as U6.H1 |
| U6.H3 | `:101-105` | per non-object requirement | `Checkpoint human_interaction.requirements #{index} must be an object.` | same note |
| U6.H4 | `:109-116` | per requirement, `response` outside `{scope_change, exception, halt}` | `Checkpoint human_interaction.requirements #{index} response must be one of scope_change, exception, halt; got: {response}` | same note |
| U6.H5 | `:118-125` | per `exception` requirement with missing/empty `runbook_path` | `Checkpoint human_interaction.requirements #{index} response is exception but runbook_path is missing or empty.` | same note |

#### U6.C — complexity_assessments per-entry (key-gated; `_orchestrator_state_complexity.py`)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U6.C1 | `:88-92` | key present, not a list | `Checkpoint complexity_assessments must be a list when present.` | ABSENT |
| U6.C2 | `:97-101` | per non-object entry | `Checkpoint complexity_assessments #{index} must be an object.` | ABSENT |
| U6.C3 | `:138-143` | per entry, `band` outside `{C1..C4}` | `Checkpoint complexity_assessments #{index} band must be one of C1, C2, C3, C4; got: {band}.` | ABSENT |
| U6.C4 | `:146-152` | per entry, `signals_present` not a list of strings | `Checkpoint complexity_assessments #{index} signals_present must be a list of strings.` | ABSENT |
| U6.C5 | `:154-161` | per entry with valid signals list, `floor != compute_complexity_floor(signals_present)` | `Checkpoint complexity_assessments #{index} floor {floor} does not equal compute_complexity_floor(signals_present) {expected_floor}.` | FORMULA PRESENT (`Get-ComplexityFloor`, MR:88-144); the per-entry check wiring is ABSENT |
| U6.C6 | `:163-173` | per entry with both bands valid, `band < floor` | `Checkpoint complexity_assessments #{index} band {band} is below its floor {floor}.` | ABSENT |
| U6.C7 | `:175-180` | per entry, `rationale` not a non-empty string | `Checkpoint complexity_assessments #{index} rationale must be a non-empty string.` | ABSENT |

#### U6.M — model_routing_receipts per-entry (key-gated; `_orchestrator_state_model_routing.py`)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U6.M1 | `:88-90` | key present, not a list | `Checkpoint model_routing_receipts must be a list when present.` | ABSENT |
| U6.M2 | `:95-99` | per non-object entry | `Checkpoint model_routing_receipts #{index} must be an object.` | ABSENT |
| U6.M3 | `:139-145` | per receipt, `complexity_band` outside enum (stops that receipt) | `Checkpoint model_routing_receipts #{index} complexity_band must be one of C1, C2, C3, C4; got: {band}.` | ABSENT |
| U6.M4 | `:147-160` | per receipt | `Checkpoint model_routing_receipts #{index} model {model} does not equal resolve_delegation_model(agent, complexity_band, fable_policy) {expected_model}.` | FORMULA PRESENT (`Resolve-DelegationModel`, MR:146-227); check wiring ABSENT |
| U6.M5 | `:196-203` | per receipt with `fable_policy == 'disabled'` and `model == 'fable'` | `Checkpoint model_routing_receipts #{index} model must not be fable under fable_policy disabled.` | ABSENT |
| U6.M6 | `:205-214` | per disabled-policy receipt with `table_model == 'fable'` lacking clamp provenance | `Checkpoint model_routing_receipts #{index} table_model fable under fable_policy disabled must record clamped_from fable and model opus.` | ABSENT |

#### U6.X — codex_model_routing_receipts per-entry (key-gated; `_orchestrator_state_codex_model_routing.py`; depends on `resolve_codex_deployment.py`, 254 lines, no PowerShell port exists)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U6.X1 | `:69-73` | key present, not a list | `Checkpoint codex_model_routing_receipts must be a list when present.` | ABSENT |
| U6.X2 | `:79-80` | per non-object entry | `Checkpoint codex_model_routing_receipts[{index}] must be an object.` | ABSENT |
| U6.X3 | `:83-85` (keys `:11-22`, 10 keys) | per entry with missing keys (stops entry) | `Checkpoint codex_model_routing_receipts[{index}] missing required keys: {keys}.` | ABSENT |
| U6.X4 | `:87-88` | per entry, `phase` not a non-empty string | `Checkpoint codex_model_routing_receipts[{index}].phase must be a non-empty string.` | ABSENT |
| U6.X5 | `:90-98` | per entry, resolver `ValueError` | `Checkpoint codex_model_routing_receipts[{index}] has invalid routing inputs: {exc}` | ABSENT |
| U6.X6 | `:101-107` | per entry whose resolved ceiling drops below the previous entry's | `Checkpoint codex_model_routing_receipts[{index}].orchestration_complexity_ceiling must be monotonic; found {current} after {previous}.` | ABSENT |
| U6.X7 | `:37-41` | per entry with no ceiling rise but a present `ceiling_transition` | `Checkpoint codex_model_routing_receipts[{index}].ceiling_transition must be absent unless the ceiling rises.` | ABSENT |
| U6.X8 | `:42-43` | per rising entry, transition not an object | `Checkpoint codex_model_routing_receipts[{index}].ceiling_transition must record a ceiling increase.` | ABSENT |
| U6.X9 | `:47-50` | per rising entry, `from`/`to` mismatch | `Checkpoint codex_model_routing_receipts[{index}].ceiling_transition must record {previous} to {current}.` | ABSENT |
| U6.X10 | `:51-63` | per rising entry, `affected_delegation_ids` empty / non-string / duplicated | `Checkpoint codex_model_routing_receipts[{index}].ceiling_transition.affected_delegation_ids must be a non-empty unique string list.` | ABSENT |
| U6.X11 | `:126-131` (9 resolved keys, `:23`) | per entry, per resolved key differing from the resolver output | `Checkpoint codex_model_routing_receipts[{index}].{key} must be {expected!r}, found {actual!r}.` | ABSENT |

#### U6.T — codex_topology_receipts per-entry (key-gated; `_orchestrator_state_codex_topology.py`; depends on `resolve_codex_topology.py`, 291 lines, no PowerShell port exists)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| U6.T1 | `:88-91` | key present, not a list | `Checkpoint codex_topology_receipts must be a list when present.` | ABSENT |
| U6.T2 | `:96-98` | per non-object entry | `Checkpoint codex_topology_receipts[{index}] must be an object.` | ABSENT |
| U6.T3 | `:100-102` (keys `:18-32`, 13 keys) | per entry with missing keys (stops entry) | `Checkpoint codex_topology_receipts[{index}] missing required keys: {keys}.` | ABSENT |
| U6.T4 | `:104-105` | per entry, `phase` not a non-empty string | `Checkpoint codex_topology_receipts[{index}].phase must be a non-empty string.` | ABSENT |
| U6.T5 | `:53-58` | per entry, `languages` not a list of non-empty strings | `Checkpoint codex_topology_receipts[{index}].languages must be a list of non-empty strings.` | ABSENT |
| U6.T6 | `:59-62` | per entry, `production_file_count` / `test_file_count` boolean or non-integer (bool explicitly rejected) | `Checkpoint codex_topology_receipts[{index}].{key} must be an integer.` | ABSENT |
| U6.T7 | `:63-64` | per entry, `cross_cutting` not a boolean | `Checkpoint codex_topology_receipts[{index}].cross_cutting must be a boolean.` | ABSENT |
| U6.T8 | `:65-66` | per entry, `execution_context` not a string | `Checkpoint codex_topology_receipts[{index}].execution_context must be a string.` | ABSENT |
| U6.T9 | `:67-72` | per entry, `root_persona` neither null nor in `FORCED_ROOT_PERSONAS` | `Checkpoint codex_topology_receipts[{index}].root_persona must be null or one of {tuple}.` | ABSENT |
| U6.T10 | `:111-114` | per entry, resolver `ValueError` | `Checkpoint codex_topology_receipts[{index}] has invalid routing inputs: {exc}` | ABSENT |
| U6.T11 | `:117-122` (12 resolved keys, `:33`) | per entry, per resolved key mismatch | `Checkpoint codex_topology_receipts[{index}].{key} must be {expected!r}, found {actual!r}.` | ABSENT |

### 2.2 C family — `--require-complete` block (`validate_orchestrator_state.py:472-491`)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| C1.1 | `_orchestrator_state_step_status.py:151-184` (blocking set `:73-79`) | flag-gated:complete; per step key whose value is in `{pending, blocked, failed_remediation_required, blocked_ci_loop_limit, blocked_remediation_loop_limit}` | `Checkpoint completion validation failed: {key} is {value}.` | ABSENT on the completion path (OSC checks base presence + M1 only, OSC:196-241). A NARROWER PR-readiness analogue exists (OS:316-321: steps 5-8 only, blocking set `{pending, blocked, blocked_remediation_loop_limit}`, different message prefix) |
| C2.1 | `validate_orchestrator_state.py:478-481` | flag-gated:complete; `blocked_reason` not in `{None, "none"}` | ``Checkpoint completion validation failed: blocked_reason is not `none`.`` | ABSENT on completion path; PR-readiness analogue OS:325-328 (different message) |
| C3.1 | `_orchestrator_state_routing.py:293-330` (gate `:63-104`) | flag-gated:complete + route-gated (`requires_pr_gate is True`) + config-read; `pr_gate` not an object | `Checkpoint completion validation failed: pr_gate must be an object with keys: pr_number, pr_url, head_branch, head_sha.` | ABSENT |
| C3.2 | `:331-335` (keys `:12`, absent-or-blank-string counts as missing `:286-290`) | same gates; missing/blank pr_gate keys | `Checkpoint completion validation failed: pr_gate missing required fields: {missing}.` | ABSENT |
| C4.1 | `validate_orchestrator_state.py:243-250` (gate `_orchestrator_state_routing.py:107-153`) | flag-gated:complete + route-gated (`requires_ci_gate is not False`; absent flag keeps the gate ON) + config-read; `ci_gate` not an object | `Checkpoint completion validation failed: ci_gate must be an object with keys: conclusion, head_sha, verified_at.` | ABSENT |
| C4.2 | `:251-256` (keys `:129`) | same gates; missing/blank ci_gate keys | `Checkpoint completion validation failed: ci_gate missing required fields: {missing}.` | ABSENT |
| C4.3 | `:257-262` | same gates; `conclusion != "success"` | `Checkpoint completion validation failed: ci_gate.conclusion must be success.` | ABSENT |
| C4.4 | `:263-273` | same gates; `pr_gate.head_sha` non-null and `ci_gate.head_sha` differs | `Checkpoint completion validation failed: ci_gate.head_sha must match pr_gate.head_sha.` | ABSENT |
| C5.1 | `_orchestrator_state_routing.py:202-256` (static map `:23-26`: only `small` and `preparation` impose phases `S3_promotion`, `S4_atomic_planning`) | flag-gated:complete + route-gated; NO config read (static map) | `Checkpoint completion validation failed: route {route_id} is missing mandatory phase {phase}.` | ABSENT |
| C6.1 | `_orchestrator_state_routing.py:535-538` | flag-gated:complete + config-read; matrix lacks `routes` object | `Routing matrix missing routes object.` | ABSENT |
| C6.2 | `:541-543` | route id absent/blank | `Checkpoint route_id or path_selected must select a route.` | ABSENT |
| C6.3 | `:544-546` | route id not a matrix entry | `Checkpoint selected route has no routing-matrix entry: {route_id}.` | ABSENT |
| C6.4 | `:561-565` | checkpoint `required_agents` list differs from the matrix route's | `Checkpoint required_agents must match routing matrix for route {route_id}.` | ABSENT |
| C6.5 | `:566-570` | same for `required_skills` | `Checkpoint required_skills must match routing matrix for route {route_id}.` | ABSENT |
| C6.6 | `:571-575` (bug-promotion tool substitution `:357-406`: `new_potential_entry` → `new_potential_bug_entry` only when `promotion-type == "bug"`) | same for `required_mcp_tools` after substitution | `Checkpoint required_mcp_tools must match routing matrix for route {route_id}.` | ABSENT |
| C6.7 | `:577-580` (receipt harvest `:435-443`) | per required agent lacking a delegation receipt | `Checkpoint missing required agent receipt: {agent}.` | ABSENT |
| C6.8 | `:582-585` (skill receipts count only when `required is True` and `evidence` non-empty, `:446-468`) | per required skill lacking a receipt | `Checkpoint missing required skill receipt: {skill}.` | ABSENT |
| C6.9 | `:587-590` (tool receipts count only when `ok is True` and `evidence` non-empty, `:471-493`) | per required MCP tool lacking a successful receipt | `Checkpoint missing successful MCP receipt: {tool}.` | ABSENT |
| C6.10 | `:496-504,592` | `local_execution_overrides` not a list / non-empty | `Checkpoint local_execution_overrides must be an empty list at completion.` (non-list) or `Checkpoint local_execution_overrides must be empty at completion.` (non-empty) — two variants | ABSENT on completion path; PR-readiness analogue OS:333-341 (single combined message, present-key semantics differ: Python C6.10 requires the key to EXIST as a list; the PR-readiness version tolerates absence) |
| C6.11 | same helper, `:593` | same for `delegation_bypasses` | same two variants with `delegation_bypasses` | same note as C6.10 |
| C6.12 | `:507-514,594` | `lifecycle_operations` present and not a list | `Checkpoint lifecycle_operations must be a list when present.` | ABSENT |
| C6.13 | `:516-521` | per non-object operation | `Checkpoint lifecycle_operations #{index} must be an object.` | ABSENT |
| C6.14 | `:522-526` | per operation whose `surface != "mcp"` | `Checkpoint lifecycle_operations #{index} did not use MCP surface.` | ABSENT |
| C7.1 | `_orchestrator_state_preparation_terminal.py:18-29` | flag-gated:complete + value-gated (`route_id`/`path_selected == "preparation"`) | `Preparation checkpoint next_step must be {'S5_atomic_execution'!r}, found {next_step!r}.` (repr interpolation) | ABSENT |
| C7.2 | `:30-35` | same gate; per step key not `'not-applicable'` (all six keys) | `Preparation checkpoint {key} must be 'not-applicable', found {value!r}.` | ABSENT |

### 2.3 M family — `--require-model-routing` block (`validate_orchestrator_state.py:498-500`; `_orchestrator_state_model_routing_gate.py:223-298`; fires only when the delegated-agent set is non-empty, derived from list-form `delegation_receipts[].agent_name` plus a `next_step` naming one of the six `_DELEGATING_AGENTS`, `:73-82,85-129`)

| ID | Source | Trigger | Error string | PowerShell equivalent |
| --- | --- | --- | --- | --- |
| M1.1 | `:264-270` | per delegated agent with no `model_routing_receipts[].agent` match, sorted | `Checkpoint model_routing_receipts is missing a receipt for delegated agent: {agent}.` | PRESENT — OSC:149-194 (identical error text at OSC:190; agent constants OSC:40-47 match `_DELEGATING_AGENTS`) |
| M2.1 | `:272-281` | per phase named by a matched routing receipt lacking a `complexity_assessments[]` entry, sorted by `repr` | `Checkpoint complexity_assessments is missing an entry for phase {phase} referenced by a model_routing_receipts entry.` | ABSENT |
| M3.1 | `:283-296` | key-gated re-run of U6.M and U6.C per-entry validators inside the gate | no new strings — re-emits U6.M/U6.C strings | ABSENT |

**Parity subtlety (duplicate emission).** For the hook's call, U6.C and U6.M already ran in the unconditional optional-key block (`validate_orchestrator_state.py:447-463`), and M3.1 runs them AGAIN when the keys are present and the gate fires. A malformed receipt or assessment therefore appears TWICE in the error output under `--require-complete --require-model-routing`. A parity port must reproduce this duplication or record a deliberate divergence; a hook that counts errors or deduplicates would behave differently.

### 2.4 Checks defined in the walked modules that do NOT fire for the hook's call

| ID | Source | Why inert | Notes |
| --- | --- | --- | --- |
| RM.1 | `validate_route_membership`, `_orchestrator_state_routing.py:156-199`; called at `validate_orchestrator_state.py:465-470` | errors added only under `strict_route_membership`, which has no CLI flag | The function still EXECUTES and reads the routing matrix from disk (see §3). Its three error strings (`Checkpoint route_id or path_selected must select a route.`, `Routing matrix missing routes object.`, `Checkpoint selected route is not a routing-matrix route: {route_id}.`) never reach any CLI caller |
| P.1-P.3 | `_orchestrator_state_pr_creation_readiness.py:70-128` | `--require-pr-creation-ready` not passed by this hook | Fires only on the pr-author preflight path; already fully mirrored by `Test-OrchestratorStatePrCreationReadiness` (OS:290-344) per prior research §3.3 |
| XG.1 | `validate_codex_model_routing_gate`, `_orchestrator_state_codex_model_routing.py:153-184` | `--require-codex-model-routing` not passed | Existence gate + re-run of U6.X |
| TG.1 | `validate_codex_topology_gate`, `_orchestrator_state_codex_topology.py:178-228` | `--require-codex-topology` not passed | Existence/consistency gate + re-run of U6.T |

### 2.5 Totals

Checks that can fire for the hook's call (`orchestrator-state --require-complete --require-model-routing`), counted at error-string granularity as enumerated above:

- U family: 57 (U1: 2, U2-U4: 3, U5: 8, U6.R: 4, U6.H: 5, U6.C: 7, U6.M: 6, U6.X: 11, U6.T: 11)
- C family: 25 (C1: 1, C2: 1, C3: 2, C4: 4, C5: 1, C6: 14, C7: 2)
- M family: 3 (M1, M2, M3-reuse)
- **Total: 85 enumerated checks.**

PowerShell coverage today: 7 of 85 fully or substantially present (U1.1, U1.2 with divergent message text; U2.1; U3.1; U4.1; M1.1) plus the two pure formulas (`Get-ComplexityFloor`, `Resolve-DelegationModel`) that back U6.C5 and U6.M4 without check wiring. The two codex resolver references (`resolve_codex_deployment.py`, 254 lines; `resolve_codex_topology.py`, 291 lines) have NO PowerShell port anywhere under `.claude/lib/` (verified by module listing: only `blast-radius`, `model-routing`, `orchestrator-state` modules exist) and would need porting for U6.X/U6.T parity.

## 3. Config-read checks — behavior in a repository without `config/orchestration-routing.json`

The following read `config/orchestration-routing.json` from disk at validation time via `load_routing_matrix` (`_orchestrator_state_routing.py:9-11,29-33`, `json.loads(path.read_text())`, no exception handling):

| Reader | When it reads | Checks affected |
| --- | --- | --- |
| `validate_route_membership` | EVERY call, including the plain call — invoked unconditionally at `validate_orchestrator_state.py:468` even though its errors are discarded without the strict flag | none surfaced, but the read still happens |
| `route_requires_pr_gate` (via `validate_completion_pr_gate`) | `--require-complete` | C3.1, C3.2 (gate decision) |
| `route_requires_ci_gate` | `--require-complete` | C4.1-C4.4 (gate decision) |
| `validate_routing_contract` | `--require-complete` | C6.1-C6.14 |

Consequence, verified by code reading: in a repository where `config/orchestration-routing.json` does not exist, `load_routing_matrix` raises `FileNotFoundError`, nothing catches it, and even the PLAIN validator call crashes with a traceback (non-zero exit). The Python validator is therefore not runnable at all in a destination repository — the config is explicitly NOT shipped to consumers (`ModelRouting.psm1:37-39` records this as the reason its constants are hard-coded, with a static config-parity Pester test pinning them). Any portable full-parity implementation, in EITHER language, must make one of two explicit decisions the Python surface never had to make:

1. Fail closed with a named error when the config is absent (strictest; makes the completion gate inoperable in destinations until the config ships), or
2. Embed the routing matrix content (or the subset the checks consume: per-route `requires_pr_gate`, `requires_ci_gate`, `required_agents`, `required_skills`, `required_mcp_tools`) as pinned constants with a config-parity test, following the established `ModelRouting.psm1` pattern.

C5.1 (`MANDATORY_ROUTE_PHASES`) and C7 (`preparation` terminal contract) are already static and portable as-is.

## 4. Deliverable 2 — bash branch: `jq` dependency versus hand-rolled JSON parser

### 4.1 Verified baseline facts

- `jq` is absent on this host (given as a verified fact in the delegation; consistent with this session's scans).
- No file under `.github/workflows/` references `jq` (ripgrep `\bjq\b`, zero matches). No file under `.claude/lib/bash/` or `scripts/bash/` references `jq` (the repo-wide match list contains neither directory).
- GitHub-hosted `ubuntu-latest` (Ubuntu 24.04) preinstalls `jq` 1.7 (verified against `actions/runner-images` `Ubuntu2404-Readme.md`). `_shell-coverage.yml` runs on `ubuntu-latest` and installs shellcheck, bats, shfmt 3.8.0, and kcov v43 (`.github/workflows/_shell-coverage.yml:10,16-49`) — it installs no `jq` because none is currently needed; bats tests of a jq-dependent validator would use the preinstalled binary with no workflow change.
- `.claude/rules/shell.md` applies the shell toolchain (shfmt, shellcheck, bats, kcov >= 85% line coverage) to `.claude/lib/bash/`; `bats` and `kcov` are absent locally, so local verification of any new bash code is not possible on this host — the established verification path is CI dispatch of `_shell-coverage.yml`.
- The nine existing files in `.claude/lib/bash/` total 2,073 lines; the largest single concern is the hand-rolled YAML parser pair `parallel-yaml-scan.sh` (335 lines) + `parallel-yaml-emit.sh` (340 lines).

### 4.2 Option A — depend on `jq`

**CI availability.** Present (preinstalled 1.7 on `ubuntu-latest`); no workflow change required for CI test runs.

**Destination burden.** A destination repository (and every developer host that executes the hook) must install one static binary. There is no existing repo mechanism that installs tools on hook-execution hosts; the hook surface currently assumes only `pwsh`. The live checkpoint's HI-1 findings record that all 34 hook commands are `pwsh -NoProfile -File` (`artifacts/orchestration/orchestrator-state.json`, HI-1 finding 1), so a bash validator adds bash AND jq to the effective host dependency set regardless of this A/B choice; Option A adds jq specifically.

**Design-intent conflict.** The existing bash library's zero-dependency posture is documented as deliberate: `parallel-yaml-scan.sh:7-10` states the hand-rolled parser exists "so the manifest validator can run in a destination workspace that has no Python, no yq, and no Node," and `parallel-common.sh:8-10` pins the library to "pure string and arithmetic helpers only: nothing here reads a file, starts a process." Adding jq breaks that posture. Two mitigating observations: (1) the documented rationale is scoped to the manifest validator, not stated as a global ban; (2) the posture was achievable there only because the manifest is machine-authored in a repo-controlled restricted subset — a precondition the orchestrator-state checkpoint does not satisfy (§4.3). If Option A is adopted, the posture change should be recorded in `.claude/rules/shell.md` (or a sibling rule) rather than left implicit.

**Missing-jq behavior.** Must fail closed: probe `command -v jq` (honoring the established `SHELL_QC_<TOOL>_BIN`-style override seam for tests), and on absence exit non-zero with a single actionable error line that the hook surfaces verbatim. Consequence to state plainly: on every host without jq — including this Windows host today — the completion gate would block every checkpoint until jq is installed. Fail-closed here means "gate inoperable blocks DONE," which is the correct direction for an enforcement gate but is an operational cost the plan must acknowledge.

**Type-fidelity fit.** jq natively provides the exact distinctions the inventory turns on: `has("key")` distinguishes absent from null (needed by U4, U5.3, C2, C4.4, C6.10/11, U6.R3); `type` distinguishes `boolean` from `number` (needed by U6.T6/T7, U6.R4); `IN(...)`/set logic covers the enum and superset checks. jq 1.7 preserves integer literals on round-trip. The 85 checks and the Python `str()`/`repr()` interpolation in error strings (C7, U6.X11, U6.T11) still have to be re-expressed in jq/bash — Option A removes the parsing risk, not the check-logic drift risk.

### 4.3 Option B — hand-rolled bash JSON parser

**Required input shape (measured against the live checkpoint and the schema prose).** `artifacts/orchestration/orchestrator-state.json` is 224 lines with nesting to depth 4 (`human_interaction.requirements[0].findings[]`, `promotion_receipts.issue.artifacts[]`, `preflight.history[0]`), arrays of objects (`delegation_receipts`, `complexity_assessments` × 4, `model_routing_receipts` × 4), booleans (`epic_mode`, `blocks_done`, `required`, `ok`, `destination_path_verified`), nulls (`clamped_from`), integers (`issue-num`, `blocking_findings`), and long free-prose strings containing apostrophes, backticks, parentheses, and colons. `.claude/rules/orchestrator-state.md` adds `remediation_loop.cycles[]`, `ci_gate{}`, `pr_gate{}`, and the codex receipt arrays. The content of the prose fields is unconstrained: any JSON string escape (`\"`, `\\`, `\n`, `\uXXXX` including surrogate pairs) can legitimately appear, because orchestrators write free text into `rationale`, `findings`, `summary`, and similar fields.

**Capability full parity genuinely requires.** Arbitrary-depth object/array nesting; complete JSON string-escape decoding including `\uXXXX`; the full JSON number grammar; and lexical type tagging that preserves absent-vs-null, int-vs-bool, and int-vs-float distinctions, because named invariants turn on them (U6.T6 rejects booleans where integers are required; U6.R4 compares `blocking_count != 0`; C2/C6.10/U5.3 distinguish absent, null, and present-empty; C6.8/C6.9 require `is True`, not truthiness). None of these can be subset-restricted away.

**Precedent value of `parallel-yaml-scan.sh`.** The precedent is real but its enabling condition does not transfer. The YAML pair is 675 lines for a deliberately RESTRICTED subset: it rejects escape sequences inside double-quoted scalars, floats, non-empty flow collections, anchors, tags, and block scalars, and fails closed on all of them (`parallel-yaml-scan.sh:15-37,183-262`). Its own header states the design judgment: "silently mis-parsing one would produce a validator verdict that disagrees with the Python authority, which is worse than refusing to answer" (`:29-31`). That fail-closed-on-subset strategy worked because the manifest is machine-authored under repo control and the subset was designed first. The checkpoint's free-prose strings make an equivalent subset impossible: rejecting `\u` escapes or `\"` would block legitimate checkpoints, so the parser must accept full JSON — at which point it is no longer a subset parser and the precedent's core risk-control is unavailable.

**Size estimate.** A parity-grade bash JSON lexer/parser with escape decoding and type tagging is realistically 500-800 lines (larger than the YAML scan half because of string escapes and the number grammar; the 500-line file cap forces a two-file split mirroring the scan/emit pattern), plus the validator logic for 85 checks with exact error-string rendering including Python `repr()` emulation (the existing `pc_repr`/`pc_repr_string` helpers in `parallel-common.sh:93-156` show the flavor and the known quote-selection divergence class recorded in `.claude/rules/parallel-orchestration.md`), plus the routing-matrix constant embedding or config parsing from §3. A defensible total is roughly 2,000-3,000 new bash lines across 5-8 files, all subject to the >= 85% kcov line-coverage floor that no local agent can currently measure.

### 4.4 Tradeoff and recommendation (bash-internal only; not a bash-vs-PowerShell recommendation)

| Dimension | Option A (jq) | Option B (hand-rolled) |
| --- | --- | --- |
| Parse correctness risk | Low — mature parser; risk shifts to check-logic drift only | High — defects concentrate exactly where the invariants turn (escape decoding, absent-vs-null, int-vs-bool); a mis-parse yields a WRONG VERDICT on a governance gate, not an error |
| Failure mode when preconditions unmet | Explicit fail-closed "jq missing" block with an actionable message | Silent risk unless every unsupported construct is detected and rejected — and rejection is not viable for free-prose JSON |
| New code volume | Validator logic only (~85 checks in jq filters/bash) | Parser (500-800 lines) + the same validator logic |
| Dependency cost | jq on every hook-execution host and destination; preinstalled in CI; absent on this host today | none beyond bash 4+ (associative arrays, as the parallel library already requires) |
| Repo design-intent | Breaks the documented zero-dependency posture of `.claude/lib/bash/`; requires an explicit rule amendment | Consistent with the posture; inconsistent with the posture's enabling precondition (controlled input subset) |
| Coverage burden | Smaller surface to cover at >= 85% kcov lines | 2,000-3,000 lines to cover, with no local measurement path |

**Recommendation: Option A (depend on `jq`), with a fail-closed `command -v jq` probe and a test-override seam.** The deciding factor is the direction of the residual risk. Option A's residual risks are operational and visible: a missing binary blocks the gate loudly with an installable remedy, and CI already has the binary. Option B's residual risk is a silent wrong verdict from a parser defect in exactly the type-fidelity territory (escapes, absent-vs-null, int-vs-bool) that the 85-check inventory depends on — the failure class the repository's own bash precedent explicitly ranks as worse than refusing to answer, and the one that cannot be mitigated by subset rejection because checkpoint prose is unconstrained. Option B also roughly doubles the code and coverage burden while the local toolchain (`bats`, `kcov`) cannot verify any of it without CI dispatch. If Option A is adopted, the zero-dependency posture change must be recorded in the shell rule file, and the missing-jq block message should name the install command per platform.

Rejected alternative (within the bash branch): hand-rolled parser (Option B) — rejected for the correctness-risk direction and the doubled size/coverage burden described above. A hybrid (hand-rolled parser that fails closed on `\u` escapes and floats) was considered and rejected because legitimate checkpoints contain unconstrained prose, so the fail-closed subset would block valid checkpoints in normal operation.

## 5. Cross-branch findings both plans must address

1. **Routing-matrix availability (§3)** is language-independent: full parity for C3/C4/C6 requires the routing matrix at validation time, the config is not shipped to destinations, and even the plain Python call crashes without it. Either branch must choose fail-closed-on-missing-config or the `ModelRouting.psm1` pinned-constants-plus-parity-test pattern, and record the choice.
2. **Duplicate-emission behavior (§2.3)** under the hook's flag pair must be reproduced or declared a divergence.
3. **Epic/parallel dispatch (§1, defect D-1)**: under the hook's current flags the Python surface performs zero checks for those artifact types (argparse exit 2). "Complete parity" is well-defined only for `orchestrator-state`; the epic/parallel behavior is a design decision, not a port target.
4. **Load-error message divergence (U1)**: the existing PowerShell loader emits path-prefixed messages that differ from the Python strings, and handles missing/empty files that Python surfaces only as a traceback. A parity port must pick one contract; exact-string parity with the traceback is neither attainable nor useful, so the fail-closed exit-code contract plus documented message divergence is the realistic target.
5. **Stricter hook-internal human-interaction check (U6.H)**: the hook's `Test-HumanInteractionShape` blocks `halt` and verifies runbook existence, which is stricter than the Python U6.H checks. Parity work must decide whether the stricter behavior is retained alongside, or reconciled with, ported U6.H.

## 6. Testing implications

- The 85-row inventory in §2 is the parity checklist: a port's test suite should carry at least one fixture per row asserting the exact error string (or the documented divergence), plus one passing fixture per family. The live checkpoint at `artifacts/orchestration/orchestrator-state.json` is a realistic in-repo fixture source (as a read-only checked-in input, consistent with the no-temp-files rule).
- PowerShell branch: fixtures drive `Test-OrchestratorStateCompletionReadiness` (or its successor) through in-memory JSON strings / mocked `Get-Content` seams; coverage falls under the pinned Pester coverage targets (prior research §7.2).
- Bash branch: bats fixtures under `tests/shell/` with checked-in fixture files per `.claude/rules/shell.md`; local execution is not possible on this host (`bats`/`kcov` absent), so verification is CI dispatch of `_shell-coverage.yml`, which conflicts with a no-push stop condition if one is in force — the plan must sequence this explicitly.
- Formula reuse: U6.C5/U6.M4 tests should assert reuse of the single ported formula implementation (`Get-ComplexityFloor`/`Resolve-DelegationModel` in PowerShell; a single jq/bash function in bash) rather than a re-implementation, mirroring the Python gate's reuse constraint (`_orchestrator_state_model_routing_gate.py:25-27`).

## Automation Feasibility

Not applicable. This work touches no third-party UI; all analysis targets repository-local Python, PowerShell, bash, and CI configuration files.
