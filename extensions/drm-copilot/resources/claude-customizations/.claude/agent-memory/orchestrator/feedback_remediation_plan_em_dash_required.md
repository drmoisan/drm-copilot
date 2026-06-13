---
name: remediation-plan-em-dash-required
description: The plan validator rejects any token between "Phase N" and the em-dash; only the canonical `### Phase N — <Title>` heading passes.
metadata:
  type: feedback
  scope: general
---

The plan validator (`validate_orchestration_artifacts` with `artifact_type: "plan"`) rejects any phase heading with tokens between "Phase N" and the em-dash. Only the canonical form `### Phase N — <Title>` passes. Parenthetical qualifiers like `(continued)` or `(part 2)` cause the validator to error with "phase heading must match ### Phase N — <Title>" followed by "task appears before a canonical phase heading".

**Why:** Encountered when a planner introduced `### Phase 1 (continued) — <Title>` to group tasks.

**How to apply:** Instruct the planner to use only canonical `### Phase N — <Title>` headings with no parenthetical qualifiers. Either fold task groups under a single phase title or use separate phase numbers. After the planner returns, always run the validator before delegating to executor preflight.
