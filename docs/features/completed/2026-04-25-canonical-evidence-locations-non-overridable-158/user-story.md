# `2026-04-25-canonical-evidence-locations-non-overridable` — User Story

- Issue: #158
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-25T14-37

## Story Statement

- As an orchestration author, I want all agent-generated evidence files to be written to `<FEATURE>/evidence/<kind>/` regardless of what any delegation prompt, plan, or upstream instruction specifies, so that evidence is always discoverable at the canonical location and post-run audits are reliable.
- As a repository maintainer, I want any attempt to write evidence files to non-canonical `artifacts/` sub-paths to be blocked at the tool layer, flagged by the feature-review agent, and detectable by a standalone validator script, so that the defect cannot recur without immediate, visible detection.

## Problem / Why

An end-to-end orchestration cycle in a downstream repository wrote approximately 95 evidence files to non-canonical paths (`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`). The canonical convention in `evidence-and-timestamp-conventions/SKILL.md` requires all baseline, QA-gate, regression-testing, and issue-update evidence to reside under `<FEATURE>/evidence/<kind>/`. The violation was not prevented because the orchestrator's delegation prompt explicitly directed the planner to use non-canonical paths, and neither the agent contracts, the skill definitions, nor the PreToolUse hook layer contained any enforcement that would reject that instruction. Post-run evidence was therefore scattered across ad-hoc paths, making audits unreliable and review automation unable to locate expected artifacts.


## Personas & Scenarios

- Persona: Orchestration author
  - An engineer who designs and runs multi-agent orchestration workflows in this repository.
  - They care that evidence files produced during a feature cycle are placed in predictable, discoverable locations so that post-run reviews, coverage checks, and audit scripts operate correctly.
  - Their constraint is that they often write delegation prompts in advance and cannot anticipate every path a downstream planner may adopt.
  - Their goal is to trust that the system enforces canonical paths unconditionally, without relying on the planner or executor to remember the convention.
  - Their frustration is discovering after a full orchestration run that 95 evidence files are scattered in non-canonical directories and that no automated system flagged the deviation.

- Persona: Repository maintainer
  - An engineer responsible for the agent infrastructure (skills, hooks, agent definitions, CI toolchain) in this repository.
  - They care that the enforcement layer is auditable, testable, and does not require modification every time a new agent or skill is introduced.
  - Their constraint is that all enforcement must work with existing runtimes (PowerShell 7, Python 3) and must not add new package dependencies.
  - Their goal is to have a defense-in-depth stack (skill-level, agent-level, hook-level, validator-level) so that a single layer failure does not silently allow a violation.

- Scenario: Orchestration run with a non-canonical path override
  - An orchestration author authors a delegation prompt for a new feature cycle. The prompt inadvertently includes an instruction to store baseline evidence under `artifacts/baselines/`.
  - The atomic-planner receives the delegation and generates a plan whose tasks write to `artifacts/baselines/`.
  - Without this feature: the atomic-executor follows the plan, writes 95 files to `artifacts/baselines/`, and no system raises an error. Post-run, the feature-review agent does not detect the deviation, and the evidence is effectively lost to audit scripts.
  - With this feature: the `enforce-evidence-locations.ps1` PreToolUse hook intercepts the first Write tool call to `artifacts/baselines/foo.md`, emits a block decision JSON with reason `EVIDENCE_LOCATION_BLOCKED: artifacts/baselines/foo.md is not a canonical evidence location. Use <FEATURE>/evidence/baseline/ instead.`, and the executor re-issues the write to the canonical path. If any non-canonical files do reach the branch (via another mechanism), the feature-review agent scans the diff and records a FAIL finding in the policy-audit. The standalone validator script, when run manually or in CI, exits non-zero and prints the canonical replacement path for every violation found.


## Acceptance Criteria

- [x] `evidence-and-timestamp-conventions/SKILL.md` contains the `## Non-Overridable Authority` section listing the 6 canonical sub-paths and stating that no delegation prompt, plan, or upstream agent may override them.
- [x] All QA-gate skills (`python-qa-gate`, `csharp-qa-gate`, `powershell-qa-gate`) reference `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/` paths and include the canonical-authority pointer line.
- [x] All invoke-engineer skills (`invoke-python-engineer`, `invoke-csharp-engineer`, `invoke-powershell-engineer`) reference `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/` paths and include the canonical-authority pointer line.
- [x] `orchestrate/SKILL.md` contains the `## Evidence Location Authority` section with an explicit allow-list of permitted `artifacts/`-rooted sub-paths.
- [x] `atomic-plan-contract/SKILL.md` contains the non-overridable clause prohibiting plan tasks from accepting evidence path overrides.
- [x] All 12 agent definition files under `.claude/agents/` contain the `## Evidence Location Invariant` section with the verbatim rejection-and-logging instruction.
- [x] `feature-review.md` additionally contains the diff-scan FAIL-finding requirement for non-canonical evidence paths.
- [x] The `enforce-evidence-locations.ps1` PreToolUse hook is registered for Write and Edit tool events in `.claude/settings.json`, blocks the forbidden prefixes (`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`, `artifacts/baseline/`, `artifacts/qa-gates/`, `artifacts/regression-testing/`, `artifacts/post-change/`), allows the explicit exceptions (`artifacts/orchestration/`, `artifacts/research/`), and emits the block decision JSON format to stdout.
- [x] The hook self-test `enforce-evidence-locations.Tests.ps1` passes all five cases: blocked path, allowed orchestration path, allowed research path, canonical evidence path, regular source-code path.
- [x] `validate_evidence_locations.py` exists, walks the repository tree, exits non-zero on a seeded violation, prints the canonical replacement path, and is referenced from the feature-review policy-audit step.
- [x] A demonstration run confirms that a deliberate Write to `artifacts/baselines/test.md` is blocked at the tool layer and the agent re-issues the write to the canonical path.
- [ ] All four toolchain steps (format, lint, type-check, test) pass after the changes in a single clean pass.

## Non-Goals

- This feature does not change the canonical path scheme itself. `<FEATURE>/evidence/<kind>/` remains the required form.
- This feature does not migrate historical non-canonical evidence files from other branches or repositories.
- This feature does not alter `artifacts/orchestration/`, `artifacts/research/`, or feature-audit report paths; those paths remain unblocked.
- This feature does not add enforcement for evidence file content or naming beyond path location.
- This feature does not introduce new package dependencies for either the Python validator or the PowerShell hook.
