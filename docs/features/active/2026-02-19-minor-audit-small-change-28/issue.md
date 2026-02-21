# minor-audit-small-change (Issue #28)

- Date captured: 2026-02-19
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/minor-audit-small-change/ (Issue #28)

- Issue: #28
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/28
- Last Updated: 2026-02-19
- Work Mode: full

## Problem / Why

Small or bootstrapped feature work currently has two sub-optimal choices:

1. Fill out full `user-story.md` + `spec.md` + `plan.md` templates with high authoring overhead for minor scope.
2. Skip active feature docs and lose the repository's required traceability and audit trail.

The repo's playbooks and templates expect an active feature folder before coding, but there is no explicit lightweight standard for minimal-scope feature documentation.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [ ] A bootstrapped work item can be completed and reviewed using an expanded `issue.md` without requiring full template completion (`user-story.md`, full `spec.md`, or deep plan) when scope remains small and pre-cooked.
- [ ] Expanded `issue.md` includes minimum required sections: problem/why, implementation intent, acceptance criteria, dependencies/risks, verification steps, and evidence checklist.
- [ ] Minimum audit evidence is explicitly defined and captured as baseline + end-state + targeted verification for changed behavior.
- [ ] Policy for bootstrapped path explicitly states that broad regression and extended design documentation are not required by default.
- [ ] A reviewer can determine whether the change is complete and safe from `issue.md` plus minimum evidence artifacts alone.

## Constraints & Risks

- Must remain compatible with existing Feature Playbook governance while adding a formal bootstrapped exception path.
- Risk: teams may over-classify work as "bootstrapped" to avoid appropriate design/testing rigor.
- Risk: reduced regression scope may miss adjacent breakage if boundaries are not clearly defined.
- Constraint: bootstrapped path should define clear eligibility criteria (pre-cooked solve, narrow blast radius, low integration risk).
- Constraint: no net loss of auditability; minimum evidence requirements must be explicit and enforceable.

## Test Conditions to Consider

- [ ] Pilot one bootstrapped change where the solution is effectively library-style plug-and-plan and document it using expanded `issue.md`.
- [ ] Capture baseline evidence before implementation (state/behavior relevant to the scoped change).
- [ ] Capture end-state evidence after implementation and confirm acceptance criteria pass.
- [ ] Run targeted verification for touched behavior only; document why broad regression is unnecessary for this case.
- [ ] Validate reviewer usability: another maintainer can approve based on `issue.md` + minimum evidence package.

## Next Step

- [ ] Promote to GitHub issue (feature request template), referencing the research recommendation in `docs/research-unassigned/20260219-minimum-viable-audit-trail-research.md`.
- [ ] In the promoted `issue.md`, define the Bootstrapped Audit Path sections and required minimum evidence checklist.
- [ ] Propose and document bootstrapped eligibility criteria (pre-cooked solve, narrow blast radius, low integration risk).
- [ ] Draft a minimal evidence contract (baseline, end-state, targeted verification) and note when expanded regression is required.
- [ ] Update playbook/template guidance so bootstrapped path is explicit and consistently applied.


## Evidence Contract

Canonical folders:
- evidence/baseline/
- evidence/regression-testing/
- evidence/other/
- evidence/qa-gates/

Required schema fields in each evidence artifact:
- Timestamp
- Command
- EXIT_CODE

## PR Recovery Note

- Branch recovery: if a PR reports "Branch is either deleted or invalid", push a fresh commit from the current working branch before reopening.
