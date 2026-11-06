# 2026-11-06-docs-tokenizer-scaling - Remediation Plan (cycle 1)

- **Issue:** #1019
- **Parent (optional):** epic/documentation-estate-tooling-integration
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T18-47
- **Status:** Target created by feature-review; awaiting authoring by `atomic-planner`
- **Version:** 0.1
- **Remediation-Mode:** proportionate
- **Requirements source (sole):** `remediation-inputs.2026-11-06T18-47.md` in this folder

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Handoff

This file is the target for the `remediation-handoff-atomic-planner` chain. It contains no tasks yet, and execution must not start from it. `atomic-planner` replaces this content with a plan that conforms to `.claude/skills/atomic-plan-contract/SKILL.md`, covering finding F1 and the related non-blocking items in the remediation inputs, and validates it with `artifact_type: "plan"` before preflight.

Context: `policy-audit.2026-11-06T18-47.md`, `code-review.2026-11-06T18-47.md`, `feature-audit.2026-11-06T18-47.md`, `evidence/qa-gates/review-reverification.2026-11-06T18-47.md`, and `plan.2026-11-06T12-15.md`.
