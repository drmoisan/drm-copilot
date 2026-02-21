# `2026-02-19-minor-audit-small-change` — User Story

- Issue: #28
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-19T12-02

## Story Statement

- As a repository maintainer delivering a small or bootstrapped change, I want to complete work using an expanded `issue.md` plus a minimum evidence package, so that I can ship low-risk changes without full-spec overhead.
- As a reviewer responsible for merge safety, I want deterministic eligibility rules and minimum audit evidence (baseline/end-state/targeted verification), so that I can approve minor changes confidently without requiring full design artifacts.

## Problem / Why

Small or bootstrapped feature work currently has two sub-optimal choices:

1. Fill out full `user-story.md` + `spec.md` + `plan.md` templates with high authoring overhead for minor scope.
2. Skip active feature docs and lose the repository's required traceability and audit trail.

The repo's playbooks and templates expect an active feature folder before coding, but there is no explicit lightweight standard for minimal-scope feature documentation.


## Personas & Scenarios

- Persona: Maintainer implementing pre-cooked or low-blast-radius changes
  - who the user is: Core contributor working in active feature workflows and automation tasks.
  - what they care about: Fast delivery, policy compliance, and avoiding unnecessary documentation overhead.
  - their constraints: Must preserve repository traceability and existing quality gates.
  - their goals and frustrations: Wants a smaller process for minor work; frustrated by full template burden for tiny changes.
  - their context and motivations: Frequently executes automation-backed flow (potential -> issue -> active folder) and needs deterministic process branches.
- Persona: Reviewer enforcing quality and governance
  - who the user is: Maintainer/reviewer validating correctness, risk posture, and policy alignment.
  - what they care about: Reliable evidence and clear scope boundaries.
  - their constraints: Cannot allow process shortcuts that hide risk or skip needed verification.
  - their goals and frustrations: Wants clear pass/fail criteria without reviewing excessive documentation noise.
  - their context and motivations: Reviews mixed feature sizes and needs a consistent way to separate minor from full-feature requirements.
- Scenario: Minor pre-cooked change through issue-centric audit path
  - who is acting? A maintainer implementing a small, known solution from another project.
  - what triggered the action? A promoted issue in an active feature folder where scope is narrow and integration risk is low.
  - what steps do they take?
    1. Confirm eligibility against minor-audit criteria.
    2. Expand `issue.md` with implementation intent, AC, risks, verification, and evidence checklist.
    3. Capture baseline evidence before change.
    4. Implement and capture end-state + targeted verification evidence.
    5. Submit for review using issue + evidence artifacts as the decision package.
  - what obstacles or decisions occur? Reviewer may reject minor-audit mode if scope/risk is unclear, forcing full-feature path.
  - what outcome do they expect? Qualifying work is approved with lower documentation overhead while keeping auditable evidence.


## Acceptance Criteria

- [x] A bootstrapped work item can be completed and reviewed using an expanded `issue.md` without requiring full template completion (`user-story.md`, full `spec.md`, or deep plan) when scope remains small and pre-cooked.
- [x] Expanded `issue.md` includes minimum required sections: problem/why, implementation intent, acceptance criteria, dependencies/risks, verification steps, and evidence checklist.
- [x] Minimum audit evidence is explicitly defined and captured as baseline + end-state + targeted verification for changed behavior.
- [x] Policy for bootstrapped path explicitly states that broad regression and extended design documentation are not required by default.
- [x] A reviewer can determine whether the change is complete and safe from `issue.md` plus minimum evidence artifacts alone.


## Non-Goals

- Replacing the full-feature documentation path for medium/large or high-risk changes.
- Removing or weakening existing code-quality toolchain requirements for implemented code.
- Eliminating evidence requirements; this feature reduces scope to minimum viable evidence, not zero evidence.
- Introducing new runtime dependencies to implement the process change.
- Retroactively rewriting historical feature documentation for previously completed work.
