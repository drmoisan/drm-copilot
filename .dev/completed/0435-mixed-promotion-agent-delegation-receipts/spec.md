# mixed-promotion-agent-delegation-receipts (Spec)

- **Issue:** #435
- **Parent (optional):** none
- **Owner:** TBD
- **Last Updated:** 2026-08-04T10-00
- **Status:** Draft
- **Version:** 0.1

## Context
The canonical orchestrator checkpoint cannot retain raw lifecycle promotion
receipts and strict-completion agent delegation receipts at the same time.
Both receipt classes are assigned incompatible shapes under
`delegation_receipts`.

The provided research is sufficient for implementation planning: it identifies
the affected Python and TypeScript validator/reader surfaces, the supported
checkpoint representations, and the required regression coverage. No new
external dependency or schema migration is required.

Environment:
- OS/version: Windows 11
- Python version: Repository-supported Poetry environment
- Command/flags used: `validate_orchestration_artifacts` with orchestrator-state completion, Codex topology, and model-routing gates
- Data source or fixture: A large-route checkpoint containing lifecycle promotion receipts and required agent receipts

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Store the policy-required raw promotion receipts under
   `delegation_receipts.promotion.*`.
2. Add the large-route agent delegation receipts required by strict completion.
3. Run strict completion, Codex topology, and model-routing validation.

Expected:
The checkpoint accepts a canonical mixed representation that retains both raw
promotion receipts and validated agent delegation receipts.

Actual:
Object-form `delegation_receipts` permits only `promotion`, while list form is
required for agent receipt collection. Object form therefore reports all
required agent receipts missing, and replacing it with list form discards the
canonical promotion-receipt namespace.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `delegation_receipts: object key 'agents' is not allowed`; strict completion then reports missing required agent receipts when only `promotion` is present.


## Scope & Non-Goals
- In scope:
  - Define the canonical mixed `delegation_receipts` object as an optional
    `agents` list and an optional `promotion` object.
  - Preserve strict validation of every agent receipt by delegating the mixed
    object's `agents` member to the existing list validator.
  - Make the Python completion readers and TypeScript MCP readers derive agent
    names from either the legacy top-level list or the canonical object's
    `agents` member.
  - Document the canonical mixed, legacy-list, and promotion-only forms in the
    canonical runtime sources, then regenerate generated profiles and preserve
    root-to-bundle parity.
- Out of scope / non-goals:
  - Changing the required fields or semantics of a strict agent delegation
    receipt.
  - Normalizing, interpreting, or moving raw promotion payload values.
  - Changing route matrices, model-selection policy, MCP request parameters,
    or the required completion gates.
- Explicitly excluded systems, integrations, or datasets:
  - External services and persisted historical checkpoints beyond validating
    their existing supported representation.

## Root Cause Analysis
`validate_orchestrator_state.py` validates list-form agents or object-form
promotion receipts, while routing, topology, and model-routing collectors read
agents only from list form. A compatible object form should allow exactly
`agents` and `promotion`, while retaining legacy list acceptance.

The TypeScript MCP validator uses the same promotion-only object restriction
and list-only agent readers. Updating only the Python path would leave the
documented `validate_orchestration_artifacts` completion boundary with a
different result for the same checkpoint.


## Proposed Fix

### Design summary (what changes where):

Adopt an additive namespaced object contract in both validation surfaces. A
top-level receipt value remains either a legacy strict-agent list or an object.
The object admits exactly `agents` and `promotion`: `agents`, when present, is
a list passed unchanged to the established strict receipt validator;
`promotion`, when present, remains an object with only the recognized raw
lifecycle child names. The mixed object is canonical, while both existing
representations remain compatible.

### Boundaries and invariants to preserve:

- Strict agent receipt fields, `artifact_paths` list validation, and current
  malformed-receipt errors remain unchanged.
- Promotion values remain opaque raw MCP payloads; the validator checks only
  container type and recognized child names.
- Unknown object namespaces and promotion child keys remain validation errors.
- All strict readers must observe the same agent collection for a given
  checkpoint across Python and TypeScript MCP surfaces.
- Generated orchestrator variants and bundled runtime copies are derived and
  synchronized rather than manually diverged from canonical sources.

### Dependencies or blocked work:

No external dependency, feature flag, or data migration is required. The
implementation depends on updating the Python and TypeScript mirror surfaces
in the same change; a single-surface update is incomplete because the MCP
completion gate would retain the incompatible contract.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- `scripts/dev_tools/validate_orchestrator_state.py`
- `scripts/dev_tools/_orchestrator_state_routing.py`
- `scripts/dev_tools/_orchestrator_state_codex_topology.py`
- `scripts/dev_tools/_orchestrator_state_codex_model_routing.py`
- `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-topology.ts`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts`
- The four canonical runtime documentation sources identified in research,
  followed by the repository generator and synchronization process.

#### Functions/classes/CLI commands impacted:

- `_validate_namespaced_delegation_receipts` and
  `_validate_list_delegation_receipts` in the Python state validator.
- `_list_receipts` / `_receipt_agents` in the routing reader;
  `_delegated_agent_names` in the Codex topology and Codex model-routing
  readers; and `_delegated_agents` in the legacy model-routing gate.
- The corresponding TypeScript state-core and strict-reader functions.
- The `validate_orchestration_artifacts` completion command when strict
  completion, Codex topology, or Codex model-routing requirements are enabled.

#### Data flow and validation changes:

1. Read `delegation_receipts` from the checkpoint.
2. If it is a list, retain the existing legacy strict-agent validation and
   reader behavior.
3. If it is an object, allow only `agents` and `promotion`.
4. Validate `agents` as a list and pass its contents to the existing strict
   list validator; validate `promotion` as the existing recognized-child
   object without transforming its values.
5. For strict completion, routing, topology, and model-routing checks, collect
   agent identities from the list itself or from object-form `agents`.

#### Error handling and logging updates:

Preserve existing explicit validation diagnostics for malformed strict receipts.
Add explicit structural errors for a non-list `agents`, a non-object
`promotion`, and unsupported object or promotion-child keys. No new telemetry
or log stream is required because this change affects schema validation output.

#### Rollback/feature-flag considerations (if applicable):

No feature flag is required. Reverting the additive object support restores
the previous behavior, but is not compatible with checkpoints that use the
canonical mixed form; legacy-list and promotion-only checkpoints are not
migrated or rewritten by this change.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Supported input formats for `delegation_receipts` are:

```text
legacy list: [<strict agent receipt>, ...]
promotion-only object: { "promotion": { ... } }
canonical mixed object: { "agents": [<strict agent receipt>, ...], "promotion": { ... } }
```

The mixed object admits only `agents` and `promotion`. `agents` must be a list
whose entries satisfy the current strict receipt contract. `promotion` must be
an object whose recognized child keys are `potential_entry`, `issue`, and
`feature_folder`; each child value remains raw and unnormalized.

#### Required configuration keys and defaults:

`delegation_receipts` remains optional where the current state schema permits
it. There are no new command-line flags or configuration defaults. When the
object form is used, either `agents`, `promotion`, or both may be present;
unknown keys are invalid.

#### Backward-compatibility expectations:

The legacy top-level strict-agent list and the promotion-only object must
continue to validate and retain their current reader behavior. The canonical
mixed object adds coexistence without changing the semantics of receipt fields,
promotion payloads, or completion requirements.

#### Performance constraints (latency/throughput/memory):

Validation remains linear in the number of agent receipts. No additional I/O,
network calls, persistence, or material memory growth is introduced.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Repository-supported Poetry and Node/TypeScript toolchains are available
    for the existing Python and MCP test suites.
  - Fixtures can construct checkpoints in memory; tests must not require
    external services or temporary files.
- Constraints (budget, performance, compatibility):
  - Preserve the existing strict receipt-validation contract and the opaque
    promotion-payload boundary.
  - Keep Python CLI and TypeScript MCP schema behavior equivalent.
  - Preserve generated-runtime and bundled-copy parity after documentation
    changes.
- External dependencies (services, libraries, releases):
  - None.

## Data / API / Config Impact
- User-facing or API changes:
  - The documented checkpoint schema gains the canonical mixed object form.
    `validate_orchestration_artifacts` can then validate both promotion and
    agent evidence from one checkpoint without changing its command surface.
- Data or migration considerations:
  - No migration or rewrite is required. Existing legacy-list and
    promotion-only checkpoint data remains valid.
- Logging/telemetry updates (if any):
  - No new telemetry. Validation errors must identify the invalid namespace,
    container type, or malformed strict receipt using the established error
    style.
- Compatibility notes (CLI flags, config schemas, versioning):
  - No CLI flags or versioning changes. The schema expansion is additive and
    accepts exactly the three documented representations.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: state shape, routing completion, Codex topology, and Codex model-routing validators
- [x] Integration scenario to retest: a complete large-route checkpoint containing both receipt classes
- [x] Manual verification notes: retain legacy list-form and promotion-only object-form compatibility

- Regression tests to add or update:
  - Extend `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py`
    and `test_validate_orchestrator_state.py` for mixed-object acceptance,
    non-list `agents`, malformed or incomplete nested agent receipts, and
    continued promotion-only acceptance.
  - Extend `test_validate_orchestrator_state_routing_contract.py`,
    `test_validate_orchestrator_state_codex_topology.py`,
    `test_validate_orchestrator_state_codex_model_routing.py`, and
    `test_validate_orchestrator_state_model_routing_gate.py` to prove that
    mixed-object agents satisfy or fail the existing strict reader gates.
  - Add matching TypeScript coverage in the state-core, routing, Codex
    topology, Codex model-routing, and orchestration-artifacts test suites.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - Use deterministic in-memory checkpoint fixtures for all three supported
    representations and assert both successful validation and exact
    structural-error paths.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Reject unknown top-level namespaces, unknown promotion child keys,
    non-list `agents`, non-object `promotion`, and malformed strict receipt
    entries while leaving valid promotion-only checkpoints delegation-free.
- Error handling and logging verification:
  - Assert explicit validator errors for invalid containers and keys; confirm
    strict readers retain their existing missing-required-agent diagnostics.
- Coverage impact and targets for changed lines/modules:
  - Cover every new schema branch and both reader extraction paths. Preserve
    repository-wide coverage of at least 80 percent and target at least 90
    percent coverage for newly introduced code.
- Toolchain commands to run (format → lint → type-check → test):
  - Run the repository-required Python and TypeScript formatting, linting,
    type-checking, and test commands in order. Restart the complete pass if a
    formatter changes files or any later stage fails. Include runtime
    generator and root-to-bundle parity checks.
- Manual validation steps (if required):
  - Run the complete mixed checkpoint with strict completion, Codex topology,
    and Codex model-routing requirements enabled on both the Python and MCP
    completion paths. Re-run legacy-list and promotion-only fixtures to confirm
    compatibility.


## Acceptance Criteria
- [x] Python state validation accepts the canonical mixed object containing a
  strict `agents` list and opaque `promotion` object, while strict completion,
  routing, Codex topology, legacy model routing, and Codex model routing
  consume the nested agent receipts.
- [x] The TypeScript MCP validator and its strict readers accept and consume
  the same canonical mixed object as the Python path when the corresponding
  completion gates are enabled.
- [x] The legacy top-level strict-agent list and promotion-only object remain
  accepted with their existing validation and reader behavior.
- [x] Non-list `agents`, non-object `promotion`, unknown top-level namespaces,
  unknown promotion child keys, and malformed strict agent receipts fail with
  explicit validation errors.
- [x] Focused Python and TypeScript regression tests cover the mixed-object
  success path, compatibility forms, strict-reader behavior, and all specified
  invalid schema boundaries.
- [x] A complete mixed large-route checkpoint passes strict completion, Codex
  topology, and Codex model-routing validation on both Python and MCP paths.
- [x] Canonical runtime documentation states the three supported forms;
  generated profiles and bundled runtime copies pass the repository parity and
  generator checks.
- [x] The required Python and TypeScript formatting, linting, type-checking,
  and test toolchain passes complete without errors in one final pass.

## Risks & Mitigations
- Technical or operational risks:
  - Python and TypeScript validators could diverge, producing different
    completion outcomes for the same checkpoint.
  - A new reader could accept object-form receipts but silently omit agents,
    weakening strict completion requirements.
  - Documentation or generated-profile changes could drift from bundled
    runtime copies.
- Mitigations and rollbacks:
  - Add mirrored tests for both validation surfaces and exercise every strict
    gate with a mixed fixture.
  - Reuse the existing strict list validator rather than duplicate or relax
    its receipt checks.
  - Run the established generator and parity validation after canonical
    documentation changes; retain legacy representations as rollback-safe
    inputs.

## Rollout & Follow-up
- Release/rollout steps:
  - Publish the implementation only after the Python and TypeScript completion
    paths, generator, parity checks, and full toolchain gate pass.
- Post-fix monitoring or clean-up tasks:
  - Review future checkpoint-validation failures for unexpected receipt shapes;
    no telemetry change is required for this bug fix.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/435
  - Research: `artifacts/research/20260804-mixed-delegation-receipts-research.md`
