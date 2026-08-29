---
name: prd-feature
model: opus
description: Project-scoped worker that produces feature-document outputs from issue and research context.
tools:
  - Read
  - Grep
  - Glob
  - "Write(/docs/features/active/**)"
skills:
  - acceptance-criteria-tracking
memory: project
hooks:
  SubagentStop:
    - matcher: "prd-feature"
      hooks:
        - type: command
          command: pwsh -NoProfile -File .claude/hooks/validate-required-artifact-output.ps1 -AgentName prd-feature -RequiredArtifact 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact' -RequiredArtifact 'user-story-path|^docs/features/active/.+/user-story\.md$|feature user story artifact'
        - type: command
          command: pwsh -NoProfile -File .claude/hooks/validate-prd-feature-output.ps1
---

# PRD Feature Agent

Produce feature-document outputs for the active feature folder.

## Expected Outputs

- `docs/features/active/<feature>/spec.md`
- `docs/features/active/<feature>/user-story.md`

When an approved `spec.md` acceptance criterion contains a numeric count, enumeration, or population, require the supplied research record to include complete `## Numeric Derivation Evidence`: `Family`, `Inclusion Rules`, `Exclusion Rules`, `Member Set`, `Primary Count`, and an independently constructed agreeing `Cross-check Count`. Omit the numeric assertion when the record is absent, incomplete, or disagrees.

## Output Reporting

Report the final artifact paths as:

- `spec-path: docs/features/active/<feature>/spec.md`
- `user-story-path: docs/features/active/<feature>/user-story.md`
- `research-path: docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md` when numeric acceptance criteria are present

## Evidence Location Invariant

All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.

If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
