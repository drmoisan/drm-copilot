# csharp-agents (Issue #53)

- Date captured: 2026-02-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/csharp-agents/ (Issue #53)

- Issue: #53
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/53
- Last Updated: 2026-02-23
## Problem / Why

Today the repository has a mature Python orchestration path (orchestrator + delegated subagents), but no equivalent first-class path for C#-centric implementation work. This creates an uneven developer experience: Python tasks can be planned/executed with consistent automation while C# tasks require ad-hoc manual flow. We need C# orchestration parity so cross-language feature delivery is predictable, policy-compliant, and reproducible.

## Proposed Behavior

Add a C# ecosystem orchestration path that mirrors the existing Python orchestrator lifecycle: intake, policy/instruction loading, planning, delegated subagent execution, evidence capture, and final QA reporting.

The C# path should use the same promotion lifecycle and work-mode semantics already used by Python (for example, `full` vs `minor-audit`) while routing implementation/testing expectations to C#-appropriate tooling and conventions.

At a workflow level, users should be able to start from a potential/active feature artifact and run a deterministic C# orchestration flow that produces comparable outputs (plan checkpoints, implementation evidence, and completion status) to the Python path.

## Acceptance Criteria (early draft)

- [ ] A C# orchestration entry path exists that can execute an end-to-end feature flow (intake → plan → delegated execution → completion) without requiring manual step stitching.
- [ ] C# orchestration supports subagent delegation with explicit contracts (inputs, expected outputs, and completion/failure signals) equivalent in rigor to the Python subagent model.
- [ ] Work mode handling is deterministic and persisted in generated feature artifacts, with fail-closed behavior to `full` mode when `minor-audit` eligibility is not satisfied.
- [ ] Policy and instruction loading for C# runs is explicit, ordered, and auditable in run outputs/logs.
- [ ] Failure scenarios are handled with actionable diagnostics (missing required artifacts, invalid mode requests, subagent failure, or incomplete handoff artifacts).
- [ ] At least one representative C# feature run produces required planning/evidence artifacts and passes final QA checks defined by repository policy.

## Constraints & Risks

- C# orchestration must not break or regress the existing Python orchestration behavior.
- Scope risk: parity does not mean a line-by-line clone; language-specific differences (toolchain, test runners, project structure) must be mapped intentionally.
- Contract drift risk: if Python and C# orchestration contracts diverge, maintenance burden and reliability issues will increase.
- Compatibility risk across Windows/macOS/Linux environments for C# toolchain discovery and execution.
- Evidence quality risk: incomplete or inconsistent artifact output will make audits and PR verification unreliable.

## Test Conditions to Consider

- [ ] Unit coverage areas: mode selection/fallback, subagent handoff contract validation, artifact path resolution, and error classification.
- [ ] Integration scenarios: full C# orchestration happy path; minor-audit eligibility accepted; minor-audit rejected with fail-closed fallback to full.
- [ ] Integration scenarios: subagent failure propagation and recovery behavior with clear checkpoint/evidence output.
- [ ] CLI/API examples: invoke C# orchestration with explicit feature path + mode and verify emitted artifacts/log fields.
- [ ] Regression checks: existing Python orchestration tests and workflows remain green after introducing C# orchestration support.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/csharp-agents/` folder from the template
