# `2026-02-19-minor-audit-small-change` — User Story

- **Issue:** #28
- **Owner:** drmoisan
- **Status:** Locked
- **Last Updated:** 2026-02-19T12-02
- **Version:** 3.0

![Status: Locked](https://img.shields.io/badge/Status-Locked-brightgreen)

## Story Statement

- As a repository maintainer delivering a small or bootstrapped change, I want to complete work using an expanded `issue.md` plus a minimum evidence package, so that I can ship low-risk changes without full-spec overhead.
- As a reviewer responsible for merge safety, I want deterministic eligibility rules and minimum audit evidence (baseline/end-state/targeted verification), so that I can approve minor changes confidently without requiring full design artifacts.

## Problem / Why

Small or bootstrapped feature work currently has two sub-optimal choices:

1. Fill out full `user-story.md` + `spec.md` + `plan.md` templates with high authoring overhead for minor scope.
2. Skip active feature docs and lose the repository's required traceability and audit trail.

The repo's playbooks and templates expect an active feature folder before coding, but there is no explicit lightweight standard for minimal-scope feature documentation.

The producer flow now persists a machine-readable marker (`- Work Mode: ...`) in `issue.md`, but key planning/execution agents still do not consistently branch on that marker. This creates drift where issue-level mode selection says `minor-audit` while downstream plans and preflight validation still behave like generic `full` mode.


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

- [ ] A bootstrapped work item can be completed and reviewed using an expanded `issue.md` without requiring full template completion (`user-story.md`, full `spec.md`, or deep plan) when scope remains small and pre-cooked.
- [ ] Expanded `issue.md` includes minimum required sections: problem/why, implementation intent, acceptance criteria, dependencies/risks, verification steps, and evidence checklist.
- [ ] `issue.md` includes a persisted work-mode marker line above the first `##` heading in the exact format `- Work Mode: minor-audit` or `- Work Mode: full`.
- [ ] When a `minor-audit` request is rejected by eligibility checks, the producer flow falls back to `full` and the persisted marker reflects the selected mode (`- Work Mode: full`), not just the requested mode.
- [ ] Minimum audit evidence is explicitly defined and captured as baseline + end-state + targeted verification for changed behavior.
- [ ] Policy for bootstrapped path explicitly states that broad regression and extended design documentation are not required by default.
- [ ] A reviewer can determine whether the change is complete and safe from `issue.md` plus minimum evidence artifacts alone.
- [ ] Review automation does not mark minor-audit work as incomplete solely due to missing `spec.md`/`user-story.md` when the persisted marker is `- Work Mode: minor-audit`.
- [ ] Status determination for “Delivered” branches by work mode: `minor-audit` uses acceptance criteria in `issue.md`; `full` uses acceptance criteria in `spec.md` + `user-story.md`.
- [ ] Planning and execution agents that consume feature docs (`atomic_planner`, `atomic_executor`, `python-typed-engineer`, `powershell-atomic-planning`, `powershell-atomic-executor`) resolve mode from `issue.md` marker first and fail closed to `full` if marker is missing or malformed.
- [ ] Preflight validation rejects a `minor-audit` plan when mode-specific requirements are missing, including baseline evidence capture, targeted verification evidence, and end-state evidence tasks.
- [ ] A generated plan for `minor-audit` contains explicit mode-aware acceptance criteria and evidence gates, and does not require `spec.md`/`user-story.md` as completion blockers by default.
- [ ] A generated plan for `full` preserves existing full-document expectations (`spec.md` + `user-story.md`) and full QA toolchain requirements.
- [ ] Deterministic routing behavior is covered by contract tests and smoke tests for three marker states: valid `minor-audit`, valid `full`, and missing/malformed marker (must route to `full`).


## Non-Goals

- Replacing the full-feature documentation path for medium/large or high-risk changes.
- Removing or weakening existing code-quality toolchain requirements for implemented code.
- Eliminating evidence requirements; this feature reduces scope to minimum viable evidence, not zero evidence.
- Introducing new runtime dependencies to implement the process change.
- Retroactively rewriting historical feature documentation for previously completed work.
- Achieving perfect deterministic behavior from probabilistic LLM generation; the objective is bounded determinism through machine-readable control signals, fail-closed routing, and enforced preflight/evidence gates.
