# `enforcement-hooks-must-not-invoke-python` — User Story

- Issue: #475
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-15
- Work Mode: full-feature (acceptance criteria live in this file and in `spec.md`)

## Story Statement

- As the repository owner pushing governance packs to destination repositories, I want every enforcement hook implemented entirely in PowerShell with no Python invocation, so that the same gate enforces the same rule with the same implementation in every repository, regardless of which toolchains are installed there.
- As the repository owner, I want the orchestrator-state completion validator ported at complete parity with the Python check surface, so that removing Python never weakens the gate anywhere — not in drm-copilot and not in any destination.
- As an orchestrator agent gated by these hooks, I want the hook verdict to come from a single implementation, so that a preflight that passes is not later blocked by a divergent second implementation of the same rule.
- As a maintainer of the hook surface, I want a structural guard in the test suite, so that a future hook or library edit cannot reintroduce a Python invocation without failing CI.
- As the future implementer of the bash migration of the hook surface, I want the language-selection decision record and a full-parity Pester suite preserved, so that the bash port runs against a behavioral oracle instead of porting blind and does not relitigate the dependency analysis.

## Problem / Why

An enforcement hook that shells out to Python carries a second implementation of the rule it enforces, and the implementations drift. This already produced an observed defect: the MCP TypeScript validator reported `ok: true` for a checkpoint the Python validator rejected, so an orchestrator recorded a passing preflight that the hook then blocked.

The portability failure is more serious than the drift. `OrchestratorState.psm1` defers to the Python CLI whenever Python is importable, so the same hook enforces via a different implementation depending on the repository: the Python leg in drm-copilot, the PowerShell mirror in a destination workspace with no Poetry environment. A pushed-down governance payload must run in destination repositories of arbitrary stacks; a C# or TypeScript destination has no reason to carry a Python environment, so a Python-dependent hook either silently degrades to a different code path or fails outright. A hook whose behavior depends on whether an unrelated toolchain happens to be installed is not a dependable gate.

Removing the Python leg without a complete port would create the opposite defect: a gate that is quietly weaker than the one it replaced. The owner rejected that outcome (HI-1, resolved 2026-08-15T15:45Z): the completion validator is ported at complete parity, measured row by row against the enumerated 85-check inventory, extending the existing tested PowerShell mirror.

## Personas & Scenarios

- Persona: **Repository owner (drmoisan)**
  - Maintains drm-copilot and pushes its `.claude` governance pack into destination repositories.
  - Cares about: identical enforcement behavior everywhere; no hidden toolchain prerequisites; no reduction in gate strictness anywhere — every deviation from literal Python behavior must be explicit and owner-visible (PD-1, PD-2, PD-3 in `spec.md`).
  - Constraints: destination repositories may run PowerShell 7.0–7.3, where `Test-Json -SchemaFile` Draft 2020-12 support is unavailable; destination repositories do not receive `config/orchestration-routing.json`; the bash migration of the hook surface is deliberately deferred.
  - Goal: one implementation everywhere at full strength; frustration: gates that behave differently on different machines, or that silently drop checks.

- Persona: **Orchestrator agent**
  - Runs the orchestration workflow whose completion gate (`validate-orchestrator-output.ps1`) and PR-author gate (`OrchestratorState.psm1` preflight) are the hooks being changed.
  - Cares about: deterministic, fail-closed verdicts; stable message prefixes (`ROUTING_CONTRACT_BLOCKED:`, `MODEL_ROUTING_BLOCKED:`, `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`) its remediation logic keys on; a completion gate that enforces the same 85 checks the Python leg enforced.
  - Constraint: these hooks gate the very run that modifies them, so each hook must be verified working immediately after modification.

- Persona: **Epic/parallel orchestrator agent**
  - Is wired to the same completion hook with `-ArtifactType epic-orchestrator-state` or `parallel-orchestrator-state`.
  - Today, defect D-1 blocks it unconditionally: the Python leg exits with an argparse usage error and the portable fallback applies the wrong (standard-checkpoint) schema. This persona currently cannot pass its own completion gate on a valid checkpoint. Because the Python CLI runs zero checks for these types under the hook's flags, there is no Python behavior to be parity with (PD-3); the fix defines fail-closed behavior rather than porting one.

- Persona: **Future bash-migration implementer**
  - Will move the whole hook surface to bash in later work.
  - Needs: the decision record explaining why PowerShell was chosen now (the portability argument does not transfer from Python to bash; a single-component bash port adds bash plus a JSON parser on top of the `pwsh` dependency all 34 hooks already impose); the preserved bash-branch conclusion (`jq` with a fail-closed `command -v jq` probe, not a hand-rolled parser); and the full-parity Pester suite as the behavioral oracle.

- Scenario: **Push-down to a Python-free destination**
  - The owner pushes the governance pack into a TypeScript destination repository with no Python installed.
  - Before this change: `enforce-pr-author-skill.ps1` runs the PowerShell mirror there but the Python leg in drm-copilot, so the two repositories enforce different check sets and can disagree on the same checkpoint. Worse, the Python validator cannot run at all in the destination — it crashes on the missing `config/orchestration-routing.json` (PD-1).
  - After this change: both repositories run the identical PowerShell path enforcing all 85 inventory checks; the route-gated checks work in destinations via pinned routing-matrix constants with a config-parity test. The verdict for a given checkpoint is the same in both. No degraded mode exists because no Python code path exists.

- Scenario: **Epic orchestrator reaches its completion gate**
  - An epic orchestrator finishes and the SubagentStop hook runs with `-ArtifactType epic-orchestrator-state`.
  - Before this change: the gate blocks regardless of checkpoint content (D-1).
  - After this change: the dispatch applies a type-scoped structural check — a well-formed epic checkpoint passes; a missing or JSON-invalid one is denied. This is defined fail-closed behavior in a region where Python parity is undefined (PD-3), not a deferral: the epic/parallel deep validators are outside the parity inventory and outside this feature's scope.

- Scenario: **A future contributor adds a hook that shells out to Python**
  - A new hook under `.claude/hooks/` calls `& python -m ...` or `poetry run ...`.
  - The AST guard's repository scan fails in CI (the full Pester tree runs on every push), naming the file and the offending invocation. The six existing hooks that merely mention the word `python` in messages, paths, or `Invoke-Python*` function names produce no findings, so the guard is not disabled as noisy. The guard carries zero allowlist entries.

- Scenario: **A destination on PowerShell 7.0–7.3 reaches the discovery-validation module**
  - The owner pushed the governance pack to a destination whose operator runs PowerShell 7.3. A workflow reaches the shared discovery-validation module.
  - The module fails closed at a runtime version check with an explicit, actionable message naming the required version (PowerShell 7.4+), naming `Test-Json -SchemaFile` JSON Schema Draft 2020-12 support as the reason, and identifying issue #475 — the operator learns the exact remedy at the point of failure instead of debugging an obscure schema-validation error or receiving a silently degraded verdict. The same 7.4+ floor is stated in the module's comment-based help, which is the destination-visible surface: the pushed-down pack contains only `config/` and `pack-manifests/` alongside `.claude/**`, so the module's own help text carries the floor. The floor is deliberate: the Draft 2020-12-free alternatives (downgrading the seven schemas — a contract change — or hand-rolling a JSON Schema validator) were assessed and rejected in the spec's "Destination Version Floor" section.

- Scenario: **A newly enforced check fails against the live checkpoint (plan Phases 10–11)**
  - The completion validator goes live while gating the run that ships it: the SubagentStop wiring subjects the live `artifacts/orchestration/orchestrator-state.json` to 79 newly enforced checks, and one of them fails against real checkpoint state.
  - Per the invariant stated verbatim in `spec.md` — **"The reconciliation branch corrects the checkpoint, never the check."** — this is the gate working correctly, not a defect in the check. The run corrects the checkpoint and records the failing check IDs in the evidence artifact. Adjusting the check, weakening a row, or relaxing a threshold to let this run pass is prohibited: a validator that a run edits to let itself through is worse than no validator. If correcting the checkpoint cannot resolve the failure, the run halts and reports it as a finding.

- Scenario: **The hook surface later migrates to bash**
  - The whole-surface bash migration begins. The implementer reads the Decision Record in `spec.md`, inherits the `jq`-with-fail-closed-probe conclusion, and ports each check against the full-parity Pester suite, which serves as the behavioral oracle: a bash implementation whose verdicts and error strings match the suite's fixtures is correct by construction against the same 85-row inventory.

## Acceptance Criteria

- [x] US-1: No file under `.claude/hooks/**` or `.claude/lib/**` (excluding `.claude/lib/bash/**`) contains a Python or `poetry` invocation; the four previously inventoried sites (`enforce-discovery-artifact-gate.ps1`, `validate-discovery-artifact-gate.ps1`, `validate-orchestrator-output.ps1`, `OrchestratorState.psm1`) are Python-free, verified structurally by the repository-scan guard rather than by PATH manipulation.
- [x] US-2: The PR-author preflight and the orchestrator completion gate return the same fail-closed verdicts for missing, unreadable, and structurally invalid checkpoints as before the change, with all existing verdict message prefixes preserved, so downstream remediation behavior is unchanged.
- [x] US-3: An epic or parallel orchestrator with a well-formed checkpoint is no longer blocked unconditionally by its completion gate (defect D-1 fixed via `$ArtifactType` dispatch, as defined fail-closed behavior per PD-3), and an invalid or missing epic/parallel checkpoint is still denied.
- [x] US-4: A passing discovery-artifact validation results in an allow verdict (defect D-2 no longer latent: success produces empty validator output, so the deny-on-output logic is correct).
- [x] US-5: The guard test fails when a Python/`poetry` invocation is introduced anywhere in the guarded tree, and produces zero findings on the current tree, including the six hooks that mention `python` without invoking it — none of which are modified by this change.
- [x] US-6 (superseded and replaced under HI-1): The version 1.0 criterion required a potential entry recording a reduction in completion-gate strictness with deferred check families. That criterion is void — no reduction occurs and no check family is deferred. Replacement criterion: the hook-enforced completion gate demonstrably covers all 85 checks of the parity inventory (spec AC-19), no artifact of this feature records a completion-validator check-family deferral, and the only divergences from literal Python behavior are the owner-visible deviations PD-1, PD-2, and PD-3 with their stated resolutions.
- [x] US-7: Destination repositories receive the identical behavior: the bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/**` is byte-identical to the repo-root files, and every new library module is registered in the pack manifest so it travels with the pushed-down pack.
- [x] US-8 (amended): The documented constraint for destinations on PowerShell 7.0–7.3 (no `Test-Json -SchemaFile` Draft 2020-12 support) is recorded in the new module header and in the rescoped potential entry (spec AC-14), which records that constraint and defect D-2's disposition — not any check-family deferral.
- [x] US-9: The completion gate works in a destination repository that lacks `config/orchestration-routing.json`: the route-gated checks (C3/C4/C6) run against pinned constants with a config-parity test, and no code path crashes or blanket-blocks on the missing config (PD-1 resolution).
- [x] US-10: The language-selection decision record (the substantive correction that the portability argument does not transfer from Python to bash, the accepted sequencing rationale, the preserved `jq`-with-fail-closed-probe conclusion) survives in `spec.md`, and the parity test suite header states its intent to serve as the behavioral oracle for the eventual bash migration.
- [x] US-11: The PowerShell 7.4+ destination version floor is enforced and visible at the point of failure: on PowerShell < 7.4 the shared discovery-validation module fails closed with an explicit, actionable message naming the required version, `Test-Json -SchemaFile` Draft 2020-12 support as the reason, and issue #475; the module's comment-based help states the same floor; and the fail-closed behavior is tested deterministically through an injectable version seam without mutating the real `$PSVersionTable` (spec AC-26 through AC-28).
- [x] US-12: The self-gating invariant — "The reconciliation branch corrects the checkpoint, never the check." — governs the go-live of the 79 newly enforced checks against the live `artifacts/orchestration/orchestrator-state.json`: a failing check is resolved only by correcting the checkpoint and recording the failing check IDs in the evidence artifact, never by adjusting a check, weakening a row, or relaxing a threshold; a failure not resolvable by correcting the checkpoint halts the run and is reported as a finding (spec AC-29).

## Non-Goals

- Porting any hook to bash or moving logic into `.claude/lib/bash/`; the bash migration is separate later work and inherits the Decision Record in `spec.md`.
- Modifying the six hooks that mention `python` without invoking it.
- Removing or changing the Python validators under `scripts/dev_tools/` or the MCP TypeScript validator surface; the MCP surface stays as a non-enforcement convenience, and only the hook's verdict is binding.
- Redesigning the discovery gate's fail-open declaration default (`TODO(#9001)`).
- Deep epic/parallel checkpoint validation in the hook; the epic/parallel deep validators are outside the parity inventory (PD-3) and outside this feature's scope.
- Byte-level parity with `jsonschema` error text (discovery surface) or with Python `OSError` tracebacks (U1 load errors); the documented divergences in the spec's Parity Contract govern.
- Superseded non-goal, recorded for traceability: a previous revision listed faithful parity with the ~1,900-line Python orchestration validation surface as a non-goal. That entry is void under HI-1; complete parity is now a binding requirement.
