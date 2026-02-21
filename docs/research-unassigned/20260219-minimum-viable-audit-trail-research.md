<!-- markdownlint-disable-file -->

# Task Research Notes: Minimum viable audit trail for small/bootstrapped features

## Research Executed

### File Analysis

- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\engineering\Feature Playbook.md
  - Defines the canonical feature workflow and expects active feature folders with `user-story.md`, `spec.md`, and `plan.md` before coding; provides scripts to create these artifacts and emphasizes traceability.
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\templates\README.md
  - Reinforces that active feature folders should include `user-story.md`, `spec.md`, and `plan.md`; suggests refactor templates for non-user-facing changes.
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\potential\README.md
  - Defines the lightweight “potential” capture step and the expectation that promoted work becomes an active feature folder.
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\potential\template.md
  - Provides a minimal “potential” template including problem, proposed behavior, early acceptance criteria, constraints, and test conditions.
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\templates\feature\user-story.md
  - Defines acceptance criteria and a user-focused narrative (story statement + personas/scenarios) for features.
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\templates\feature\spec.md
  - Defines behavior, inputs/outputs, API surface, data/state, constraints/risks, and definition of done.
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\templates\feature\plan.yyyy-MM-ddTHH-mm.md
  - Requires an atomic plan and explicitly links to repo policies for compliance.
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\templates\refactor\spec.md
  - Provides a lighter-weight alternative for non-user-facing changes (invariants, scope, risks, test strategy).
- c:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\docs\features\templates\refactor\plan.yyyy-MM-ddTHH-mm.md
  - Provides a refactor plan structure with phases and minimal work breakdown.

### Code Search Results

- minimal|lightweight|shortcut|skip|template|bootstrap|audit|spec|user-story|plan
  - Matches found in: `docs/features/templates/README.md`, `docs/features/potential/README.md`, `docs/features/templates/feature/*`, `docs/features/templates/refactor/*`, `docs/features/templates/policy_audit/*`.

### External Research

- #githubRepo:"N/A"
  - Not executed (no external repositories referenced).
- #fetch:N/A
  - Not executed (no external URLs provided).

### Project Conventions

- Standards referenced: `docs/engineering/Feature Playbook.md`, `docs/features/templates/README.md`, `docs/features/potential/README.md`, `docs/features/templates/feature/*`, `docs/features/templates/refactor/*`.
- Instructions followed: `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md` (read for baseline policy awareness).

## Key Discoveries

### Project Structure

- Feature work is expected to flow from potential → issue → active feature folder with `user-story.md`, `spec.md`, and `plan.md` before coding, per Feature Playbook and templates.
- Non-user-facing changes should use the refactor templates rather than full feature templates.
- The “potential” template already provides a lightweight capture mechanism (problem, proposed behavior, early acceptance criteria, constraints, test conditions).

### Implementation Patterns

- The feature template expects a complete behavior spec and atomic plan, but there is no explicit “short-form” or “lite” spec template in the repo today.
- The refactor template provides a reduced scope for cases with no user-facing behavior changes, focusing on invariants and technical scope.

### Complete Examples

```markdown
## Acceptance Criteria (early draft)

- [ ] Criterion 1
- [ ] Criterion 2

## Constraints & Risks

List notable constraints (performance, compatibility, scope) or risks.

## Test Conditions to Consider

- [ ] Unit coverage areas
- [ ] Integration scenarios
- [ ] CLI/API examples
```

### API and Schema Documentation

- No dedicated “minimal audit” schema exists; standard templates define the expected fields.

### Configuration Examples

```markdown
## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
```

### Technical Requirements

- Feature docs are expected before coding; deviation would require a documented exception or a lighter-weight template that still captures acceptance criteria and test conditions.
- For non-user-facing changes, refactor templates are the intended minimal alternative.

**Mandatory unachievable objective callout**:
- None identified.

## Recommended Approach

**Selected recommendation (Option A):** Adopt a **“Lean Active Feature”** standard that still uses the existing active feature folder structure, but allows **minimal completion** of `user-story.md`, `spec.md`, and `plan.<timestamp>.md` by focusing only on: (1) problem/why, (2) acceptance criteria, (3) dependencies/risks, and (4) test conditions/verification steps. Sections not applicable should be explicitly marked as `N/A (bootstrapped)` or `N/A (not applicable)` to keep the audit trail compact while remaining traceable. This aligns with the Feature Playbook’s expectation of an active folder while minimizing authoring overhead.

### Rejected alternatives (brief)

- **Refactor templates (Option B)**: Rejected for this decision because the request is for minimal audits on *features*, not only non-user-facing refactors. The refactor templates remain suitable for purely structural changes, but they are not the chosen default for bootstrapped features.
- **Issue + potential only (Option C)**: Rejected because it conflicts with the Feature Playbook’s requirement for an active feature folder and would require explicit exceptions.

## Implementation Guidance

- **Objectives**: Provide a minimal, policy-compliant audit trail for small or bootstrapped features without producing full narrative specs.
- **Key Tasks**:
  - Define a “Lean Active Feature” checklist using the existing templates with explicit `N/A (bootstrapped)` markers where sections are not applicable.
  - Ensure acceptance criteria + test conditions are always present in at least one artifact (issue or minimal docs).
  - Keep the plan atomic but short: 3–6 tasks with verification steps (tests, comparisons, or toolchain pass).
- **Dependencies**: Existing feature templates and the Feature Playbook; no new tooling required.
- **Success Criteria**: A reviewer can identify the feature scope, acceptance criteria, and verification steps from the minimal documents without needing a full spec.