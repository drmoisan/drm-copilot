# 2026-02-19-minor-audit-small-change — Spec

- **Issue:** #28
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-19T12-02
- **Status:** Locked
- **Version:** 3.0

![Status: Locked](https://img.shields.io/badge/Status-Locked-brightgreen)

## Overview

Small or bootstrapped feature work currently has two sub-optimal choices:

1. Fill out full `user-story.md` + `spec.md` + `plan.md` templates with high authoring overhead for minor scope.
2. Skip active feature docs and lose the repository's required traceability and audit trail.

The repo's playbooks and templates expect an active feature folder before coding, but there is no explicit lightweight standard for minimal-scope feature documentation.

- Target users/personas and primary use cases:
	- Repo maintainers executing small, pre-cooked changes that do not justify full feature-design overhead.
	- Reviewers who still need deterministic acceptance and evidence before approving merge.
- Success metrics or expected impact:
	- Reduce authoring overhead for qualifying minor work while preserving traceability.
	- Keep auditability by requiring explicit baseline/end-state/targeted verification evidence.
	- Prevent bypass of full process for non-qualifying work through explicit eligibility gates.


## Behavior

Define and adopt a **Minor Change Audit Path** that uses an expanded `issue.md` as the primary documentation artifact for bootstrapped work, minor features, and small fixes:

- Qualifying work requires one of two conditions:
    - bootstrapped work that was completed in another project
    - new changes with a very small scope (3 or fewer production files and corresponding test files)
- For qualifying work, `issue.md` becomes the canonical planning + audit surface.
- `issue.md` must include:
	- problem/why
	- implementation intent (what is being plugged in and where)
	- minimum acceptance criteria
	- dependencies/risks
	- verification steps
	- minimum evidence checklist
- Full design-heavy artifacts (`user-story.md`, deep `spec.md`, extensive plan breakdown) should not exist in this path.
- Evidence expectations are reduced to a minimal path:
	- baseline capture (before)
	- end-state capture (after)
	- targeted verification for changed behavior
	- no broad regression campaign unless risk profile demands it.

- Main user flow (happy path):
	1. Author records change as potential and promotes to GitHub issue via existing promotion tooling.
	2. Maintainer marks work as Minor Change Audit Path candidate.
	3. Eligibility is evaluated (bootstrapped/pre-cooked OR <=3 production files with low integration risk).
	4. `issue.md` is expanded to include required minor-audit sections.
	5. Implementation proceeds with baseline capture, end-state capture, and targeted verification evidence.
	6. Reviewer validates completion from `issue.md` + evidence artifacts.
- Alternate/edge flows:
	- If eligibility fails, workflow falls back to full feature path (`user-story.md`, `spec.md`, plan execution).
	- If integration risk increases during implementation, path is escalated to full-feature verification.
	- If targeted verification reveals adjacent risk, broader regression is required before completion.
- Error handling and recovery behavior:
	- Missing required issue sections blocks minor-audit qualification.
	- Missing baseline or end-state evidence blocks review readiness.
	- Ambiguous scope (file-count or risk not explicit) defaults to full-feature path.

Additionally, define a deterministic, persisted mode signal so downstream reviewers and automation can branch correctly without heuristics:

- `issue.md` MUST contain a single work-mode marker line in its metadata block (above the first `##` heading):
	- `- Work Mode: minor-audit`
	- `- Work Mode: full`
- Mode-aware consumers (review agents and status updater) must branch based on this marker:
	- `minor-audit`: acceptance criteria are extracted from `issue.md`; missing `spec.md`/`user-story.md` is not a failure by itself.
	- `full`: acceptance criteria remain extracted from `spec.md` + `user-story.md` (backward-compatible with existing expectations).
- “Fail closed” rule: if the marker is missing or malformed, consumers must assume `full` mode to avoid under-auditing.

Define a shared mode-resolution contract for planning and execution stages so downstream behavior is deterministic and auditable:

- Mode source precedence:
	1. Persisted marker in `issue.md` (`- Work Mode: minor-audit|full`)
	2. Explicit CLI/workflow override only when policy allows, and only if reconciled against `issue.md`
	3. Fail-closed default to `full`
- Preflight branch expectations:
	- For `minor-audit`, plans MUST include explicit baseline evidence, targeted verification evidence, and end-state evidence tasks.
	- For `minor-audit`, missing `spec.md`/`user-story.md` is not an automatic failure.
	- For `full`, existing full-feature expectations remain in effect.
- Determinism objective:
	- The system targets bounded determinism (machine-readable routing + hard preflight gates + test enforcement), not perfect deterministic generation.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Source issue context: `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md`.
	- Research context: `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/research.md`.
	- Existing promotion input file: potential markdown consumed by `scripts/dev_tools/potential_to_issue.py`.
	- Existing active-folder input: feature name/type/issue number consumed by `scripts/dev_tools/new_active_feature_folder.py`.
	- Mode input: `--work-mode {minor-audit|full}` (already supported by the producer scripts).
	- Persisted mode marker: `- Work Mode: <value>` (must be written into `issue.md` by the producer flow so reviewers can branch deterministically).
	- Planner/executor mode input: resolved mode value derived from `issue.md` marker and validated during preflight.
- Outputs (artifacts, logs, telemetry)
	- Expanded `issue.md` containing required minor-audit sections and acceptance criteria.
	- Expanded `issue.md` metadata includes the persisted work-mode marker line above the first `##` heading.
	- Mode-aware plan content where acceptance and evidence gates branch by resolved work mode.
	- Preflight output indicating whether mode-specific requirements are satisfied (`PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`).
	- Minimum evidence artifacts under active feature evidence folders:
		- `evidence/baseline/` (before state)
		- `evidence/other/` (end-state + targeted verification)
	- Existing command/tool output for promotion/folder creation preserved.
- Config keys and defaults:
	- Proposed workflow default remains full-feature path.
	- Minor-audit path is opt-in and only valid when eligibility criteria are met.
- Versioning or backward-compatibility constraints:
	- Existing feature lifecycle scripts and labels remain backward-compatible for non-minor-audit work.
	- Existing evidence conventions (`Timestamp`, `Command`, `EXIT_CODE`) remain authoritative.

## API / CLI Surface

- Existing command surfaces (must continue to work):
	- Promote a potential doc to a GitHub issue (already supports `--work-mode`):
		- `poetry run python -m scripts.dev_tools.potential_to_issue --potential-path <path> --promotion-type feature --work-mode full`
		- `poetry run python -m scripts.dev_tools.potential_to_issue --potential-path <path> --promotion-type feature --work-mode minor-audit`
	- Create an active feature folder (already supports `--work-mode`):
		- `poetry run python -m scripts.dev_tools.new_active_feature_folder --feature-name <name> --type feature --issue-number <issue|auto> --work-mode full`
		- `poetry run python -m scripts.dev_tools.new_active_feature_folder --feature-name <name> --type feature --issue-number <issue|auto> --work-mode minor-audit`

- Flags and semantics (explicit contract):
	- `--work-mode full`
		- Behavior: produces/updates the standard active-feature doc set.
		- Persisted marker: `- Work Mode: full` MUST be written into `issue.md` metadata.
	- `--work-mode minor-audit`
		- Behavior: attempts Minor Change Audit Path; if eligibility fails, MUST fall back to `full` and emit a reason.
		- Persisted marker: `- Work Mode: minor-audit` MUST be written into `issue.md` metadata when minor-audit is actually selected.
		- Fallback marker behavior: if the tool falls back to full, it MUST write `- Work Mode: full` (so downstream agents see the actual selected mode).

- Eligibility validation contract (producer-side):
	- A `minor-audit` request is only accepted when eligibility criteria pass (bootstrapped/pre-cooked OR small scope + low integration risk).
	- If the request is rejected, the tool MUST:
		- select `full`
		- emit `Selected mode: full` plus `Fallback reason: ...`
		- persist `- Work Mode: full` into the resulting `issue.md`.

- Example: expected `issue.md` metadata snippet (illustrative and deterministic):
	- When minor-audit is selected:
		- `- Issue: #28`
		- `- Work Mode: minor-audit`
		- `- Owner: <name>`
	- When full is selected:
		- `- Issue: #28`
		- `- Work Mode: full`
		- `- Owner: <name>`

- Consumer branching contract (review/status automation):
	- Read `issue.md` metadata and branch based on `- Work Mode: ...`.
	- If absent/malformed, treat as `full`.
- Consumer branching contract (planning/execution automation):
	- Resolve mode from `issue.md` and enforce mode-specific plan requirements at preflight.
	- Reject mode-inconsistent plan content before execution starts.
	- If marker is absent/malformed, enforce `full` path requirements.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Potential issue content continues to be transformed into structured issue body sections during promotion.
	- Invariant: minor-audit mode cannot remove required audit fields from issue body.
	- Invariant: full-feature mode remains unchanged unless explicitly selected/elevated.
- Caching or persistence details:
	- No runtime cache introduced.
	- Persistent state remains markdown artifacts in feature docs and evidence folders.
	- New persisted state element: the `- Work Mode: ...` marker line in `issue.md` metadata.
	- No new required state files are introduced; determinism is enforced from existing persisted marker + existing plan/evidence artifacts.
- Migration or backfill requirements (if any):
	- No mandatory historical backfill required for prior features.
	- Existing active features may opt into minor-audit policy only when eligibility and evidence contracts are satisfied.

## Constraints & Risks

- Must remain compatible with existing Feature Playbook governance while adding a formal bootstrapped exception path.
- Risk: teams may over-classify work as "bootstrapped" to avoid appropriate design/testing rigor.
- Risk: reduced regression scope may miss adjacent breakage if boundaries are not clearly defined.
- Risk: mode drift between issue metadata and downstream plan/execution behavior may create false passes or false failures.
- Constraint: bootstrapped path should define clear eligibility criteria (pre-cooked solve, narrow blast radius, low integration risk).
- Constraint: no net loss of auditability; minimum evidence requirements must be explicit and enforceable.
- Constraint: agentic execution is probabilistic; reliability must come from constrained branch inputs, fail-closed defaults, and objective preflight checks.
- Limits (latency/throughput/memory) and acceptable trade-offs:
	- Primary objective is process overhead reduction, not runtime performance improvement.
	- Accept slight tooling complexity increase to reduce repeated documentation effort for qualifying work.
- Security/privacy considerations:
	- Evidence artifacts must avoid secrets/credentials and follow existing repository hygiene.
	- Issue-body expansion must not introduce unsafe automation that leaks private paths or tokens.
- Operational/rollout risks and mitigations:
	- Risk: ambiguous qualification decisions across maintainers.
		- Mitigation: deterministic gate checklist in `issue.md` plus reviewer confirmation requirement.
	- Risk: process fork confusion.
		- Mitigation: full path stays default; minor-audit requires explicit mode signal and eligibility pass.
	- Risk: over-constraining prompts without machine-checkable validation still allows nondeterministic misses.
		- Mitigation: enforce branch behavior through preflight acceptance criteria and contract tests, not prompt text alone.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Persist a deterministic work-mode marker into `issue.md` so downstream agents can branch without heuristics.
	- Align reviewers/status automation to branch acceptance-criteria extraction and doc-completeness expectations based on the marker.
	- Add mode-aware branching requirements to planning/execution agents and shared skills so plan generation and execution behavior matches persisted mode.
	- Preserve existing producer behavior (including existing `--work-mode` support and eligibility fallback) while making the chosen mode durable.
- New classes/functions/commands to add or update:
	- `scripts/dev_tools/potential_to_issue.py`
		- update issue body generation to include a persisted marker line (`- Work Mode: ...`) near the top of the created issue body.
		- ensure the marker reflects the selected mode (after eligibility evaluation), not just the requested mode.
	- `scripts/dev_tools/new_active_feature_folder.py`
		- update `issue.md` generation to persist the marker line above the first `##` heading.
		- ensure the marker reflects the selected mode (after eligibility evaluation), not just the requested mode.
	- `.vscode/tasks.json`
		- confirm `--work-mode` is passed through promotion and active-folder tasks (already present).
		- ensure task UX makes the selected mode obvious to the operator.
	- `.github/agents/feature-review.agent.md`
		- add mode-aware branching so minor-audit features extract AC from `issue.md` and do not require `spec.md`/`user-story.md`.
	- `.github/agents/epic-review.agent.md`
		- update doc-completeness rules so missing `spec.md`/`user-story.md` is “N/A by design” when `Work Mode: minor-audit`.
		- update AC extraction to use `issue.md` for `minor-audit` and `spec.md` + `user-story.md` for `full`.
	- `.github/agents/status_updater.agent.md`
		- update “Delivered” definition and evidence-writing targets to branch based on work mode (issue-centric for `minor-audit`).
	- `.github/agents/atomic_planning.agent.md`
		- require mode resolution from `issue.md` and require mode-specific plan requirements at preflight.
	- `.github/agents/atomic_executor.agent.md`
		- require preflight rejection when selected mode requirements are missing from the approved plan.
	- `.github/agents/python-typed-engineer.agent.md`
		- require mode-aware planning handoff expectations so baseline/verification shape matches selected mode.
	- `.github/agents/powershell-atomic-planning.agent.md`
		- require mode-aware plan structure and preflight criteria analogous to generic atomic planner.
	- `.github/agents/powershell-atomic-executor.agent.md`
		- require mode-aware preflight checks before execution loop starts.
	- `.github/skills/atomic-plan-contract/SKILL.md`
		- add explicit mode-branch preflight requirements and fail-closed routing semantics.
	- `.github/skills/feature-promotion-lifecycle/SKILL.md`
		- update canonical commands and required outputs to include `--work-mode` and to treat minor-audit as first-class.
	- `docs/engineering/Feature Playbook.md`
		- add explicit Minor Change Audit Path eligibility + evidence contract.
	- `docs/features/templates/README.md`
		- clarify usage decision tree: full feature vs refactor vs minor-audit.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime dependencies required; implement within existing Python/PowerShell/Markdown tooling.
- Logging/telemetry additions and locations:
	- Continue existing CLI/script output patterns.
	- Add explicit qualification/rejection messages for minor-audit mode decisions.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Roll out as opt-in mode for one pilot feature.
	- Validate reviewer experience and evidence sufficiency.
	- Keep fallback path as full-feature flow at all times.

## Definition of Done

- [ ] Acceptance criteria are documented in expanded `issue.md` and mapped to verification evidence.
- [ ] Behavior matches minor-audit path rules for qualifying work, and non-qualifying work is routed to full path.
- [ ] Producer tooling persists a deterministic work-mode marker in the resulting `issue.md` (and the created GitHub issue body) that reflects the selected mode.
- [ ] Review agents branch deterministically on the persisted marker and do not false-fail minor-audit work for missing full-doc artifacts.
- [ ] Status updater branches deterministically on the persisted marker when assessing Delivered and when appending evidence.
- [ ] Atomic planning/execution agents and typed-engineer planners enforce mode-aware preflight branching from `issue.md` marker and fail closed to `full` when marker is missing/malformed.
- [ ] Shared planning contract (`atomic-plan-contract`) requires mode-specific plan/evidence gates during preflight.
- [ ] Tests are updated/added for mode routing, eligibility checks, and issue/evidence validation behavior.
- [ ] Contract tests verify mode-aware requirements are present in all targeted agents/skills and smoke tests verify mode routing for valid and malformed markers.
- [ ] Edge cases are covered (eligibility failure, missing evidence, scope/risk escalation).
- [ ] Process docs are updated (`Feature Playbook` + templates guidance) to reflect deterministic mode selection.
- [ ] Script output clearly indicates selected mode and fallback reason when minor-audit is rejected.
- [ ] Toolchain pass is completed for touched code paths (format -> lint -> type-check -> test) per repo policy.

## Seeded Test Conditions (from potential)
- [ ] Pilot one bootstrapped change where the solution is effectively library-style plug-and-plan and document it using expanded `issue.md`.
- [ ] Capture baseline evidence before implementation (state/behavior relevant to the scoped change).
- [ ] Capture end-state evidence after implementation and confirm acceptance criteria pass.
- [ ] Run targeted verification for touched behavior only; document why broad regression is unnecessary for this case.
- [ ] Validate reviewer usability: another maintainer can approve based on `issue.md` + minimum evidence package.
- [ ] Validate planning preflight behavior for three marker states: `minor-audit`, `full`, and missing/malformed marker (must route to `full`).
- [ ] Validate generated plan content includes mode-aware evidence requirements for `minor-audit` and full-doc expectations for `full`.
