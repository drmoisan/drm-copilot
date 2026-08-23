<!-- markdownlint-disable-file -->

# Task Research Notes: Orchestrator Remediation Loop Control (Issue 484)

## Research Executed

### File Analysis

- `.github/agents/task-researcher.agent.md`
  - The canonical task-researcher profile restricts writes to an orchestrator-supplied tracked research root under `docs/features/<feature>/research/` or `docs/research/`.
- `.agents/skills/research-issue/SKILL.md`
  - The skill still requires `artifacts/research/<timestamp>-<short-name>-research.md`, which conflicts with the canonical agent and the enforced feature-local destination supplied for issue 484.
- `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/issue.md`
  - Issue 484 defines the defect as conflation of review verdict with autonomous remediation actionability, inconsistent attempt/cycle accounting, missing no-delta terminal transitions, legacy routing checks leaking into Codex validation, duplicated strict Codex diagnostics, and absence of a runtime capability compatibility preflight.
- `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/spec.md`
  - The draft spec preserves the same root-cause list and requires unit, integration, and manual release-boundary validation, but its design, API, compatibility, and detailed acceptance sections remain intentionally unfilled pending research.
- `artifacts/orchestration/orchestrator-state.json`
  - The checkpoint objective requires non-actionable blockers to avoid remediation-cycle creation or consumption, canonical validated cycle accounting, capability-compatible Codex routing validation, and parity between repository routing policy and published MCP bundles.
  - The checkpoint selects the large, cross-cutting Python/TypeScript route with an estimate of 11 production files, 14 test files, 10 workflow/config files, and 30 generated or mirrored files. It records issue 484, the correct feature-local `research-path`, and the `artifacts/research/` contract drift incident.

### Code Search Results

- `git status --short --branch`
  - The verified branch is `bug/orchestrator-remediation-loop-control-484`; the active feature folder is currently untracked, so research must preserve all files owned by the parent orchestration session.
- Feature-folder inventory
  - Issue 484 currently contains `issue.md`, `spec.md`, the pre-existing plan, and this single research artifact.
- `remediation_loop|remediation-pass|REVIEW_STATUS|PRE_R5_STATUS|candidate_applied`
  - The active R1-R5 contract is distributed across `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.github/agents/orchestrator.agent.md`, generated Codex/Claude surfaces, Python validation modules, TypeScript validation modules, and their tests.
- `require_model_routing|require_codex_topology|require_codex_model_routing`
  - Python validation is split across `validate_orchestrator_state.py` and dedicated legacy/Codex routing modules; TypeScript mirrors those concerns under `extensions/drm-copilot/src/lib/validate/`. Strict orchestration-artifact validation and service-call adapters are separate entry points that must be checked for duplicate execution.
- MCP and routing inventory
  - Canonical routing policy is `config/orchestration-routing.json`; mirrors include `extensions/drm-copilot/resources/config/orchestration-routing.json` and Claude/Codex customization resources. The publishable package is `packages/mcp-server`, while `extensions/drm-copilot/src/mcp-server.ts` is the source MCP surface and `esbuild-mcp-server.cjs`/`prepack.cjs` build the bundles.
- `artifacts/research|docs/features/.*/research|docs/research`
  - `.github/agents/task-researcher.agent.md` and `.github/prompts/research-issue.prompt.md` use tracked research roots, but every `.codex/agents/task-researcher*.toml`, every `.codex/agents/orchestrator*.toml`, `.agents/skills/research-issue/SKILL.md`, and `.agents/skills/orchestrate/SKILL.md` still direct research to `artifacts/research/`. `.codex/hooks/enforce-evidence-locations.ps1`, `scripts/dev_tools/validate_evidence_locations.py`, and their tests prohibit that retired root and accept feature-local or `docs/research/` paths.

### External Research

- #githubRepo:"pending authoritative implementation references"
  - External comparison is in progress.
- #fetch:pending-authoritative-documentation
  - External comparison is in progress.

### Project Conventions

- Standards referenced: `AGENTS.md`; `.github/agents/task-researcher.agent.md`; `.agents/skills/research-issue/SKILL.md`
- Instructions followed: research-only scope; orchestrator-supplied feature-local output; verified evidence only; compare multiple approaches and retain only a brief rejected-alternatives summary after selection

## Key Discoveries

### Project Structure

Issue 484 is an active full-bug feature. Its checkpoint identifies a cross-runtime change spanning orchestration instructions, Python and TypeScript validators, MCP capabilities, generated/mirrored surfaces, and release parity rather than a single-module correction. The repository already separates canonical policy/configuration, source validators, generated customization resources, extension tests, and the publishable MCP package, so parity must be enforced across all five layers.

### Implementation Patterns

- Python `validate_orchestrator_state_text` composes independent optional validators and opt-in gates. `remediation_loop` is not a required checkpoint key; when present, a non-object loop or non-list `cycles` value returns no error. Each object cycle currently enforces only non-empty `plan_path`, clear preflight before execution status, and zero blockers when `exit_condition_met` is true.
- TypeScript `validateRemediationLoop` intentionally mirrors those Python semantics and exact diagnostics. `validateOrchestratorStateText` invokes it only when the top-level key exists, so both validators permit checkpoints without canonical cycle accounting.
- The Python CLI supports an independent `--require-pr-creation-ready` gate. The TypeScript `ValidateOrchestratorStateOptions`, dispatcher, MCP input schema, service-call builder, and service contract expose `require_complete`, legacy routing, and Codex routing flags but do not expose PR-creation readiness.
- The MCP server handshake reports only package version and the standard `tools` capability. It does not report validator contract version, supported validation flags/outcomes, routing-policy digest, or bundle/source identity.
- The extension and publishable MCP package both declare version `1.0.24`. `packages/mcp-server/esbuild-mcp-server.cjs` bundles the extension's `src/mcp-server.ts` directly; `prepack.cjs` copies extension resources while excluding Python. The publish workflow runs extension tests, copies resources, builds the standalone bundle, and publishes only on an `mcp-server-v*` tag.

### Complete Examples

```text
Verified implementation examples are being collected.
```

### API and Schema Documentation

- Current Python validator flags: `require_complete`, `require_pr_creation_ready`, `require_model_routing`, `require_codex_model_routing`, and `require_codex_topology`.
- Current MCP validator flags: `require_complete`, `require_model_routing`, `require_codex_model_routing`, `require_codex_topology`, and `require_ready_for_execution`; the schema rejects additional properties.
- Current remediation-cycle fields enforced by both runtimes: `plan_path`, `preflight.final_status`, `execution_status`, `exit_condition_met`, and `blocking_count`. No required cycle identifier, attempt count, candidate-applied state, blocker fingerprint, exception binding, terminal disposition, or completed-cycle count is validated.

### Configuration Examples

```text
packages/mcp-server/package.json version: 1.0.24
extensions/drm-copilot/package.json version: 1.0.24
publish trigger: tags matching mcp-server-v*
publish build source: extensions/drm-copilot/src/mcp-server.ts
```

### Technical Requirements

- Treat delivery verdict and autonomous next action as independent values.
- Do not create or consume a remediation cycle for external runtime incompatibility, unavailable evidence awaiting CI, required human decisions, or execution that applies no candidate.
- Define attempts separately from completed remediation cycles and make `remediation_loop.cycles[]` canonical rather than optional/ad hoc.
- Separate legacy model-routing gates from Codex-native topology/model-routing gates and return each diagnostic once.
- Reject an incompatible validator runtime before remediation by checking capability, version, and routing-policy digest.
- Keep source, built, mirrored, and published MCP behavior in parity, and do not pin a package version until it is published.
- Correct the verified research-output contract drift between the canonical task-researcher profile, the `research-issue` skill, generated task-researcher profiles, orchestration instructions, and enforced evidence-location policy.

**Mandatory unachievable objective callout**:
- No objective has been proven unachievable at this stage.

## Recommended Approach

The selected approach will be recorded after comparison of at least two viable designs.

## Implementation Guidance

- **Objectives**: Define deterministic remediation-loop semantics and cross-runtime validation for issue 484.
- **Key Tasks**: Pending evidence-based requirements mapping.
- **Dependencies**: Pending repository and package-surface analysis.
- **Success Criteria**: Pending acceptance-criteria mapping and regression-test design.
