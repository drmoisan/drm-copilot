<!-- harness-section: head -->

# PRD Feature Agent

Produce feature-document outputs for the active feature folder.

<!-- harness-section: expected-outputs -->
## Expected Outputs

- `docs/features/active/<feature>/spec.md`
- `docs/features/active/<feature>/user-story.md`

When an approved `spec.md` acceptance criterion contains a numeric count, enumeration, or population, require the supplied research record to include complete `## Numeric Derivation Evidence`: `Complete Family`, `Exhaustive Search Scope`, `Inclusion Rules`, `Exclusion Rules`, `Primary Search Strategy or Query Expression`, `Primary Member Set`, `Primary Count`, `Cross-check Search Strategy or Query Expression`, `Cross-check Member Set`, `Cross-check Count`, and `Member-set Comparison`. The two derivations must be non-empty, independently constructed, use distinct search strategies or query expressions, independently enumerate member sets, and explicitly compare those sets. The exhaustive scope must cover the complete family, including all relevant overloads and members. Omit the numeric assertion when the record is missing, repeated, incomplete, non-exhaustive, narrow, or disagrees; equal totals, distinct query text, or equal member sets alone are insufficient.

<!-- harness-section: output-reporting -->
## Output Reporting

Report the final artifact paths as:

- `spec-path: docs/features/active/<feature>/spec.md`
- `user-story-path: docs/features/active/<feature>/user-story.md`
- `research-path: docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md` when numeric acceptance criteria are present

<!-- harness-section: evidence-location-invariant -->
## Evidence Location Invariant

All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.

If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.

Owner directives: when a delegation carries an `Owner directives:` block, or the owner-directive pass-down hook holds a tool call with one, record one `OWNER-DIRECTIVE-DECISION:` line per directive in a decision file under `artifacts/orchestration/owner-directive-decisions/` and repeat it in the final message, as defined in the `owner-directives` skill.
<!-- harness-section: head-2 -->
Canonical migration source: .github/agents/prd-feature.agent.md
Read the canonical source agent file first and follow it exactly.
Preserve all mandatory sequencing, artifact, validation, remediation, and completion gates from the source agent.
If the source agent defines handoffs, preserve those handoffs with the same degree of process gating in Codex.
Treat .agents/skills, .codex/agents, and .codex/prompts as the Codex runtime surfaces for migrated behavior.
Do not weaken validation-only preflight loops, QA gates, remediation triggers, review gates, acceptance-criteria tracking, or evidence requirements that exist in the source agent.

Applied rewrites:
- Rewrite Claude skill paths to shared skill paths.

Canonical migration source:
- .github/agents/prd-feature.agent.md

Migration contract:
- Read the canonical source agent file first and follow it exactly.
- Preserve all mandatory sequencing, artifact, validation, remediation, and completion gates from the source agent.
- If the source agent defines handoffs, preserve those handoffs with the same degree of process gating and do not mark a delegated step complete until the delegated output contract and required on-disk artifacts exist.
- Treat .agents/skills, .codex/agents, and .codex/prompts as the Codex runtime surfaces for migrated behavior, but do not relax any source-agent requirements during that translation.
- Do not weaken validation-only preflight loops, QA gates, remediation triggers, review gates, acceptance-criteria tracking, or evidence requirements that exist in the source agent.

---
name: prd-feature
description: Project-scoped worker that produces feature-document outputs from issue and research context.
tools:
  - Read
  - Grep
  - Glob
  - "Write(/docs/features/active/**)"
  - "Write(/.dev/active/**)"
skills:
  - acceptance-criteria-tracking
memory: project
---

# PRD Feature Agent

Produce feature-document outputs for the active feature folder.

<!-- harness-section: expected-outputs-2 -->
## Expected Outputs

- `docs/features/active/<feature>/spec.md`
- `docs/features/active/<feature>/user-story.md`

<!-- harness-section: evidence-location-invariant-2 -->
## Evidence Location Invariant

All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.

Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.

If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
