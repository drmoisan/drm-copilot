<!-- markdownlint-disable-file -->

Timestamp: 2026-02-10T12-56
Command: read-only scan of .github/skills, .github/agents, .github/instructions, .github/prompts
EXIT_CODE: 0
Output Summary: Verified skill files exist with required frontmatter; identified skill-name references in .github/agents; no path references in .github/agents, .github/instructions, or .github/prompts.

# Task Research Notes: Skill files + reference scan

## Research Executed

### File Analysis

- .github/skills/make-skill-template/SKILL.md
  - Frontmatter present with name/description; body documents skill scaffolding steps, frontmatter requirements, validation checklist, and template structure.
- .github/skills/skill-canonical-location-audit/SKILL.md
  - Frontmatter present with name/description; body defines audit workflow to detect canonical-location duplicates across skills.
- .github/skills/atomic-plan-contract/SKILL.md
  - Frontmatter present with name/description; body defines plan format, Phase 0 requirements, final QA loop, and preflight validation.
- .github/skills/evidence-and-timestamp-conventions/SKILL.md
  - Frontmatter present with name/description; body defines ISO-8601 timestamps, canonical evidence locations, discovery order, and issue update mirroring rules.
- .github/skills/policy-audit-template-usage/SKILL.md
  - Frontmatter present with name/description; body defines policy audit template usage and required steps.
- .github/skills/policy-compliance-order/SKILL.md
  - Frontmatter present with name/description; body defines required policy reading order and hard constraints.
- .github/skills/pr-context-artifacts/SKILL.md
  - Frontmatter present with name/description; body defines canonical PR context artifact locations and refresh rule.
- .github/skills/remediation-handoff-atomic-planner/SKILL.md
  - Frontmatter present with name/description; body defines remediation handoff inputs and delegation steps to atomic_planner.

### Code Search Results

- \.github/skills/(make-skill-template|skill-canonical-location-audit|atomic-plan-contract|evidence-and-timestamp-conventions|policy-audit-template-usage|policy-compliance-order|pr-context-artifacts|remediation-handoff-atomic-planner)
  - No path-reference matches in .github/agents/, .github/instructions/, or .github/prompts/.
- (make-skill-template|skill-canonical-location-audit|atomic-plan-contract|evidence-and-timestamp-conventions|policy-audit-template-usage|policy-compliance-order|pr-context-artifacts|remediation-handoff-atomic-planner)
  - .github/agents/ includes references by skill name (no path references). Matches in:
    - .github/agents/status_updater.agent.md (evidence-and-timestamp-conventions)
    - .github/agents/feature-review.agent.md (policy-compliance-order, evidence-and-timestamp-conventions, policy-audit-template-usage, remediation-handoff-atomic-planner, pr-context-artifacts)
    - .github/agents/epic-review.agent.md (policy-compliance-order, evidence-and-timestamp-conventions, policy-audit-template-usage, remediation-handoff-atomic-planner)
    - .github/agents/atomic_planning.agent.md (policy-compliance-order, atomic-plan-contract)
    - .github/agents/atomic_executor.agent.md (policy-compliance-order, atomic-plan-contract)
  - No matches in .github/instructions/ or .github/prompts/.

### External Research

- #githubRepo:"" 
  - Not applicable (no external repository research required).
- #fetch:
  - Not applicable (no external URLs required).

### Project Conventions

- Standards referenced: SKILL.md frontmatter with name/description (from skill templates).
- Instructions followed: Task Researcher mode; skills loaded prior to analysis.

## Key Discoveries

### Project Structure

All requested skill files exist under `.github/skills/` and include YAML frontmatter with `name` and `description`. The only references in the scanned directories are skill-name mentions within `.github/agents/`; no path references were found in `.github/agents/`, `.github/instructions/`, or `.github/prompts/`.

### Implementation Patterns

Each SKILL.md follows a consistent structure: YAML frontmatter (name/description) followed by a title and “When to Use” guidance, plus procedure-specific sections (workflows, requirements, or canonical locations).

### Complete Examples

```markdown
---
name: <skill-name>
description: '<What it does>. Use when <specific triggers, scenarios, keywords users might say>.'
---
```

### API and Schema Documentation

N/A (skill files are markdown guidance, not API schemas).

### Configuration Examples

```text
N/A
```

### Technical Requirements

- Skills are expected to include YAML frontmatter with `name` and `description` fields.

**Mandatory unachievable objective callout**:
- None.

## Recommended Approach

Summarize each skill file with focus on frontmatter presence and whether the body content aligns with the skill name/description. Report all references found in `.github/agents/` by skill name, and explicitly note that no path references were found in `.github/agents/`, `.github/instructions/`, or `.github/prompts/`.

## Implementation Guidance

- **Objectives**: Verify existence of specified skill files, confirm frontmatter, summarize contents, and identify references in the specified directories.
- **Key Tasks**: Read skill files; run targeted searches for name/path references; capture matches.
- **Dependencies**: None.
- **Success Criteria**: Provide concise report listing existence, frontmatter status, content summary alignment, and reference locations.
