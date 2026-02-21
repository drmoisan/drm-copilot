# 2026-02-19-minor-audit-small-change — Spec

- **Issue:** #28
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-19T12-02
- **Status:** Superceded by 2.0
- **Version:** 1.0

![Status: Superceded](https://img.shields.io/badge/Status-Superceded-orange)

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


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Source issue context: `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md`.
	- Research context: `docs/features/active/2026-02-19-minor-audit-small-change-28/research.md`.
	- Existing promotion input file: potential markdown consumed by `scripts/dev_tools/potential_to_issue.py`.
	- Existing active-folder input: feature name/type/issue number consumed by `scripts/dev_tools/new_active_feature_folder.py`.
	- Proposed mode input: minor-audit vs full (mode signal in tooling/task layer).
- Outputs (artifacts, logs, telemetry)
	- Expanded `issue.md` containing required minor-audit sections and acceptance criteria.
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

List commands, flags, request/response shapes, and examples.
- Existing command surfaces (must continue to work):
	- `poetry run python -m scripts.dev_tools.potential_to_issue --potential-path <path> --promotion-type feature`
	- `poetry run python -m scripts.dev_tools.new_active_feature_folder --feature-name <name> --type feature --issue-number <issue|auto>`
- Proposed extension points:
	- Add a mode control to promotion/active-folder flow (for example: `--work-mode minor-audit|full`).
	- Add eligibility validation contract before minor-audit acceptance.
- Example invocations with expected outputs (concise):
	- Promotion (full default):
		- Input: potential feature file with problem/behavior/AC/constraints/tests.
		- Output: GitHub issue created; potential moved to promoted; issue metadata injected.
	- Active folder creation with minor-audit mode:
		- Input: feature name + issue number + mode signal.
		- Output: active folder with canonical `issue.md`; evidence directories used for minimum audit package.
- Contracts and validation rules:
	- Minor-audit requires explicit implementation intent + AC + risks + verification steps + evidence checklist in `issue.md`.
	- Minor-audit review cannot pass without baseline and end-state evidence plus targeted verification.
	- Eligibility failure forces full-feature path.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Potential issue content continues to be transformed into structured issue body sections during promotion.
	- Invariant: minor-audit mode cannot remove required audit fields from issue body.
	- Invariant: full-feature mode remains unchanged unless explicitly selected/elevated.
- Caching or persistence details:
	- No runtime cache introduced.
	- Persistent state remains markdown artifacts in feature docs and evidence folders.
- Migration or backfill requirements (if any):
	- No mandatory historical backfill required for prior features.
	- Existing active features may opt into minor-audit policy only when eligibility and evidence contracts are satisfied.

## Constraints & Risks

- Must remain compatible with existing Feature Playbook governance while adding a formal bootstrapped exception path.
- Risk: teams may over-classify work as "bootstrapped" to avoid appropriate design/testing rigor.
- Risk: reduced regression scope may miss adjacent breakage if boundaries are not clearly defined.
- Constraint: bootstrapped path should define clear eligibility criteria (pre-cooked solve, narrow blast radius, low integration risk).
- Constraint: no net loss of auditability; minimum evidence requirements must be explicit and enforceable.
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


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Add minor-audit mode handling to issue promotion + active-folder creation surfaces.
	- Add issue-body section contract for minor-audit required content.
	- Add minimum evidence contract and reviewer gate language in feature process docs.
- New classes/functions/commands to add or update:
	- `scripts/dev_tools/potential_to_issue.py`
		- extend body generation/validation for minor-audit required sections.
		- accept mode indicator.
	- `scripts/dev_tools/new_active_feature_folder.py`
		- add mode-aware branching for minor-audit vs full-feature doc materialization.
	- `.vscode/tasks.json`
		- pass mode input through promotion/active-folder tasks.
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
- [ ] Tests are updated/added for mode routing, eligibility checks, and issue/evidence validation behavior.
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
