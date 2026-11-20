# propagate-claude-ecosystem-hardening — Spec

- **Issue:** #187
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-16T10-28
- **Status:** Draft
- **Version:** 0.1

## Overview

A Claude customization tree copied from another repository (`artifacts/tocompare/.claude`) was audited against this repository's canonical `.claude` runtime and its bundled mirrors. The audit (`artifacts/research/20260616-tocompare-claude-ecosystem-hardening-audit-research.md`) identified seven hardened elements present in the source tree that this repository lacks or has in a weaker form. These elements form a coherent autonomous-execution / human-exception enforcement subsystem plus two independent rule and skill improvements. Without them, the orchestrator can write DONE while unautomatable steps remain unresolved, research artifacts can omit automation-feasibility assessments, coverage measurement can silently exclude production paths, and remediation handoff cycles can be malformed.


## Behavior

Propagate the seven hardened elements into the canonical `.claude` runtime and both bundled mirrors (`extensions/drm-copilot/resources/claude-customizations/` and `packages/mcp-server/resources/claude-customizations/`), and extend the Python orchestrator-state validator:

1. Add `Test-HumanInteractionShape` to `hooks/validate-orchestrator-output.ps1` — block DONE when `human_interaction` requirements are unresolved, halted, or an exception lacks a runbook.
2. Add `Test-AutomationFeasibilitySection` to `hooks/validate-task-researcher-output.ps1` — block autonomous-execution research artifacts lacking an `## Automation Feasibility` section.
3. Add `## Autonomous-Execution Mandate` section to `skills/orchestrate/SKILL.md`.
4. Create `skills/human-exception-runbook/` (SKILL.md + example.runbook.md).
5. Port `human_interaction` invariants into `scripts/dev_tools/validate_orchestrator_state.py` and update `rules/orchestrator-state.md` accordingly.
6. Add `## Coverage Exclusion Policy` and `## Test File Location` sections to `rules/general-unit-test.md`.
7. Replace `skills/remediation-handoff-atomic-planner/SKILL.md` with the expanded source version.


## Acceptance Criteria

A feature-review agent can verify each criterion below against the repository state. "Canonical + both mirrors" means the canonical `.claude/` file and the corresponding files under `extensions/drm-copilot/resources/claude-customizations/.claude/...` and `packages/mcp-server/resources/claude-customizations/.claude/...` are byte-identical.

Item 1 — `Test-HumanInteractionShape`:
- [x] `Test-HumanInteractionShape` is added to `validate-orchestrator-output.ps1` (canonical + both mirrors) and wired into `Invoke-OrchestratorOutputValidation`.
- [x] The function passes when `human_interaction` is absent (backward-compatible); blocks when `requirements` is missing; blocks when a requirement has no `response`; blocks when `response` is outside the enum `scope_change | exception | halt`; blocks when `response == halt`; blocks when `response == exception` and `runbook_path` is empty or does not exist on disk.
- [x] Pester unit tests cover absent-key, missing-requirements, missing-response, invalid-enum, halt, and exception-without-runbook cases, using the injectable `$FileExistsCheck` seam.

Item 2 — `Test-AutomationFeasibilitySection`:
- [x] `Test-AutomationFeasibilitySection` is added to `validate-task-researcher-output.ps1` (canonical + both mirrors) and wired into `Invoke-TaskResearcherOutputValidation`.
- [x] The function passes non-matching research artifacts unaffected and, for artifacts matching `autonomous-execution|human-interaction` (filename or content), requires an `## Automation Feasibility` heading.
- [x] Pester unit tests cover matching (section present, section absent) and non-matching artifacts, using the injectable `$ReadFileContent` seam.

Item 3 — Autonomous-Execution Mandate:
- [x] `## Autonomous-Execution Mandate` section is present in `orchestrate/SKILL.md` (canonical + both mirrors), defining detection points, the three permitted responses (`scope_change`, `exception`, `halt`), the exception-runbook requirement, and the three named enforcement points.

Item 4 — Human-Exception Runbook skill:
- [x] `skills/human-exception-runbook/SKILL.md` and `skills/human-exception-runbook/example.runbook.md` exist (canonical + both mirrors), defining the canonical runbook path `<FEATURE>/runbooks/<name>.runbook.md`, the five required sections, and the MCP-first / web-second sourcing rule.

Item 5 — `human_interaction` validator invariants:
- [x] `validate_orchestrator_state.py` enforces the `human_interaction` invariants (required `requirements`, per-requirement `response` enum membership, exception-requires-`runbook_path`) using the existing error-string style; `schemas/orchestrator-state.schema.json` is not copied verbatim.
- [x] pytest coverage includes the new invariants and a backward-compatibility case proving a checkpoint without `human_interaction` still validates unchanged.
- [x] `rules/orchestrator-state.md` documents the `human_interaction` invariants alongside the existing three, without regressing the existing prose.

Item 6 — `general-unit-test.md` sections:
- [x] `general-unit-test.md` contains the `## Coverage Exclusion Policy` and `## Test File Location` sections (canonical + both mirrors).

Item 7 — Remediation handoff skill:
- [x] `remediation-handoff-atomic-planner/SKILL.md` matches the expanded SOURCE version (canonical + both mirrors), including the Full Handoff Chain diagram, Required Artifacts (entry-vs-exit timestamp contract), Plan Shape, Preflight Sub-Loop, and Exit Gate sections.

Mirror parity and toolchain:
- [x] Every canonical `.claude/` file changed or created by items 1–7 is mirrored byte-identically to both bundled mirrors.
- [x] `settings.local.json` and `agent-memory/**` are NOT propagated from the SOURCE tree.
- [x] Bundle-sync contract tests (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) pass.
- [x] PowerShell toolchain (PoshQC formatting/lint, Pester) passes.
- [x] Python toolchain (Black, Ruff, Pyright, Pytest) passes.


## Inputs / Outputs

This feature changes static runtime-customization assets and one Python validator. It introduces no new CLI binaries, services, or network surface.

- Inputs:
  - SOURCE tree of reference content: `artifacts/tocompare/.claude` (read-only; provenance only).
  - Orchestrator-state checkpoint JSON consumed by `scripts/dev_tools/validate_orchestrator_state.py`, optionally carrying a top-level `human_interaction` object.
  - Hook stdin payloads consumed by `validate-orchestrator-output.ps1` and `validate-task-researcher-output.ps1` (existing hook contract; unchanged invocation surface).
- Outputs:
  - Edited and created files under `.claude/` (canonical runtime) and both bundled mirrors.
  - Additional validation error strings returned by `validate_orchestrator_state.py` when `human_interaction` invariants are violated.
  - Additional Blocking-classified hook findings emitted by the two PowerShell hooks when their new checks fail.
- Config keys and defaults: none added. The two new PowerShell functions accept injectable scriptblocks (`$FileExistsCheck`, `$ReadFileContent`) with production defaults, used only for test seams.
- Versioning / backward-compatibility constraints:
  - A checkpoint without a `human_interaction` key MUST validate exactly as it does today (additive invariant).
  - A `human_interaction` key absent from hook input MUST pass `Test-HumanInteractionShape` (backward-compatible).
  - A research artifact whose filename and content do not match the `autonomous-execution|human-interaction` detection pattern MUST pass `Test-AutomationFeasibilitySection` unaffected.
  - `schemas/orchestrator-state.schema.json` MUST NOT be copied verbatim; the foreign-schema policy in `rules/orchestrator-state.md` is preserved.

## API / CLI Surface

No public CLI surface changes. The affected surfaces are the existing hook and validator contracts.

- `validate_orchestrator_state.py` — `validate_orchestrator_state_text(text, *, require_complete=False) -> list[str]` retains its signature. New `human_interaction` invariants append error strings using the existing literal, checkpoint-context-prefixed message style. The function continues to return error strings and never mutates its input.
- `validate-orchestrator-output.ps1` — adds internal function `Test-HumanInteractionShape`, wired into `Invoke-OrchestratorOutputValidation`. SOURCE reference: `artifacts/tocompare/.claude/hooks/validate-orchestrator-output.ps1`.
- `validate-task-researcher-output.ps1` — adds internal function `Test-AutomationFeasibilitySection`, wired into `Invoke-TaskResearcherOutputValidation`. SOURCE reference: `artifacts/tocompare/.claude/hooks/validate-task-researcher-output.ps1`.
- Contracts and validation rules:
  - `human_interaction.requirements` is required when `human_interaction` is present; each requirement requires `response` within the enum `scope_change | exception | halt`.
  - `response == halt` blocks DONE; `response == exception` requires a non-empty `runbook_path` referencing an existing on-disk file under `<FEATURE>/runbooks/<name>.runbook.md`.
  - Research artifacts matching `autonomous-execution|human-interaction` (filename or content) require an `## Automation Feasibility` heading.

## Data & State

- Data transformations and invariants: the Python validator gains read-only inspection of an optional top-level `human_interaction` object. It enforces presence of `requirements`, per-requirement `response` membership in the enum, and the exception-requires-`runbook_path` conditional, mirroring the SOURCE schema invariants described in research Section 5. No verbatim schema import.
- Caching or persistence details: none. All changes are stateless validation and static documentation/skill assets.
- Migration or backfill requirements: none. Existing checkpoints without `human_interaction` and existing research artifacts without the detection-pattern markers are unaffected.

## Constraints & Risks

- Do not copy `schemas/orchestrator-state.schema.json` verbatim (foreign-schema policy in `rules/orchestrator-state.md`); enforce `human_interaction` invariants via the existing Python validator pattern.
- Do not propagate `settings.local.json` or `agent-memory/**` from the source tree (developer-local / other-repo project memory).
- Every runtime file edit must be mirrored to both bundled mirrors; the contract test enforces parity for the `extensions/` mirror.
- The repo is ahead on `rules/orchestrator-state.md`; do not regress it.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
  - Edit two PowerShell hooks, three skill files, one rule file (`general-unit-test.md`), one rule file (`orchestrator-state.md`), and one Python validator in the canonical `.claude/` runtime and `scripts/`.
  - Create one new skill directory (`human-exception-runbook`) with two files.
  - Mirror every canonical `.claude/` change byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/...` and `packages/mcp-server/resources/claude-customizations/.claude/...`.
- New classes/functions/commands to add or update:
  - PowerShell `Test-HumanInteractionShape` (new) and its call sites in `Invoke-OrchestratorOutputValidation`.
  - PowerShell `Test-AutomationFeasibilitySection` (new) and its call site in `Invoke-TaskResearcherOutputValidation`.
  - Python `human_interaction` invariant logic in `validate_orchestrator_state.py`, following the established helper-plus-error-list pattern used by the existing remediation-cycle invariants.
- Dependency changes: none. No new packages are added.
- Logging/telemetry additions: none. Enforcement is expressed as validator/hook findings only.
- Rollout plan: no feature flags. All additions are backward-compatible (absent-key passes). The bundle-sync contract test (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) is the parity gate for the `extensions/` mirror; the `packages/mcp-server/` mirror has no automated parity gate (research Section 2) and must be updated manually in the same change.
- Suggested dependency ordering (per research Section 7): items 1–4 are self-contained; item 5 depends on items 1 and 4 being present; items 6 and 7 are independent. Sequencing is non-binding for this spec.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, docs/features/active/... links)
- [x] Telemetry/logging added or updated (if applicable)
- [x] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Pester unit tests for both new PowerShell hook functions.
- [x] pytest tests for the new `human_interaction` validator invariants (backward-compatibility for checkpoints without `human_interaction`).
- [x] Bundle-sync contract tests for mirror parity.
