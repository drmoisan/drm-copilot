<!-- markdownlint-disable-file -->

# Task Research Notes: Feature review agent/prompt skill migration

## Research Executed

### File Analysis

- .github/agents/feature-review.agent.md
  - Defines detailed feature-branch review workflow, artifact outputs, remediation handoff, and baseline/evidence rules.
- .github/prompts/review-feature.prompt.md
  - Loader prompt that repeats many operational rules from the agent (baseline capture, deliverables, remediation plan delegation).

### Code Search Results

- feature-review.agent.md
  - Manual file read only; no codebase search executed.
- review-feature.prompt.md
  - Manual file read only; no codebase search executed.

### External Research

- #githubRepo:"N/A"
  - Not run (not required for this internal doc refactor).
- #fetch:N/A
  - Not run (not required for this internal doc refactor).

### Project Conventions

- Standards referenced: `.github/agents/*.agent.md` + `.github/prompts/*.prompt.md` patterns; Copilot skills location `.github/skills/` per VS Code customization docs.
- Instructions followed: repository instruction hierarchy and agent/prompt separation guidance from Copilot customization docs.

## Key Discoveries

### Project Structure

The repo already separates custom agents (`.github/agents/`) from prompt files (`.github/prompts/`). There is no existing `.github/skills/` directory, so introducing skills will be a new but standard structure.

### Implementation Patterns

Both the agent and the prompt currently encode operational workflow rules (baseline capture locations, remediation handoff structure, deliverable names). This is reusable workflow logic that is better represented as a **skill** so multiple agents/prompts can rely on the same canonical procedure without duplication.

### Complete Examples

```markdown
---
name: feature-review-workflow
description: Feature-branch review workflow: PR context collection, baseline evidence capture, audit artifact naming, and remediation handoff guidance.
---

# Feature Review Workflow

## When to use this skill
Use when performing a feature-branch review that produces PolicyAudit/CodeReview/FeatureAudit artifacts and may require remediation planning.

## Process
1) Generate or refresh PR context artifacts via `scripts.dev_tools.pr_context.collector`.
2) Store baseline and regression evidence in canonical `baseline/` and `regression-testing/` folders adjacent to the plan/audit outputs.
3) Produce audit artifacts with ISO-8601 timestamps.
4) If remediation is required, prepare remediation inputs and delegate plan creation to `atomic_planner` using the repo’s canonical plan prompt.
```

### API and Schema Documentation

No external APIs or schemas are introduced. The guidance only references existing repo scripts and artifacts:
- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `scripts.dev_tools.pr_context.collector`

### Configuration Examples

```yaml
# SKILL.md frontmatter
---
name: feature-review-workflow
description: Feature-branch review workflow: artifact generation, evidence storage, remediation handoff.
---
```

### Technical Requirements

- Skill location: `.github/skills/feature-review-workflow/SKILL.md`
- Prompt should become a thin loader (inputs + invoking agent).
- Agent should reference the skill rather than duplicating baseline/evidence rules.

**Mandatory unachievable objective callout**:
- **None identified.** All changes are doc-only and achievable within repo conventions.

## Recommended Approach

Create a reusable **feature-review workflow skill** and move the duplicated operational steps (PR context collection, baseline/evidence storage rules, artifact naming, remediation handoff scaffolding) out of both the prompt and agent. Keep role-specific responsibilities and output requirements inside the agent. Reduce the prompt to a concise loader with input expectations and a short deliverables summary.

Rationale:
- A skill prevents drift between the agent and the prompt.
- The prompt becomes a simple entry point that is easy to maintain.
- The agent keeps only role-specific constraints and outputs, improving clarity.

Rejected alternatives (summary):
- Keep duplication in both files: increases maintenance cost and inconsistency risk.
- Move all logic into the prompt: prompts are one-shot and not the right place for reusable workflow.

## Implementation Guidance

- **Objectives**: centralize reusable workflow logic in a skill; remove duplication; keep agent focused on role-specific requirements.
- **Key Tasks**:
  1) Create `.github/skills/feature-review-workflow/SKILL.md` with the reusable workflow steps (PR context generation, baseline/evidence storage, timestamping, remediation plan handoff scaffolding).
  2) Update `feature-review.agent.md` to reference the skill and remove duplicated operational steps that are now in the skill (baseline capture locations, artifact naming conventions, remediation delegation boilerplate).
  3) Update `review-feature.prompt.md` to a thin loader: required inputs (base branch), agent invocation, and short deliverables list; remove duplicated workflow rules.
  4) Optional: add a brief note in `review-feature.prompt.md` that the skill provides operational steps.
- **Dependencies**: None beyond adding `.github/skills/` directory and SKILL.md.
- **Success Criteria**:
  - A new skill exists under `.github/skills/feature-review-workflow/`.
  - The agent no longer duplicates workflow logic already in the skill.
  - The prompt is reduced to a short loader without operational duplication.
  - Review behavior remains functionally equivalent (no loss of required outputs or handoff).
