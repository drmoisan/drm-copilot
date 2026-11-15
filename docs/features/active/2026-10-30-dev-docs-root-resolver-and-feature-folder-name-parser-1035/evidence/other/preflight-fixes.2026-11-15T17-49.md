# Preflight Fixes - Confirming Preflight After Revision (2026-11-15)

Timestamp: 2026-11-15T17-49
Plan: docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/plan.2026-10-30T17-11.md
Validator: MCP `validate_orchestration_artifacts` (plan) ok; branch-current Python CLI `plan` subcommand exit 0 before and after the fix (82 tasks, 427 lines, `## Size Justification` present).

## Fix 1

- Location: [P6-T6], `Tests:` bullet.
- Defect class: changed-behavior test disposition (validator-blind class); the task left `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` unchanged although the case runs the entry without `-EvidenceRoot` and would reach the new `Resolve-DevelopmentDocsRoot` call, reading the real `config/orchestration-routing.json`. That contradicts the Pre-Mortem `Test isolation` statement and the D-P16 rule that suites whose existing cases reach a new resolver call mock it in `BeforeEach`.
- Change made: the bullet now states that the suite's `BeforeAll` imports `DevelopmentDocsRoot.psm1` and its `BeforeEach` mocks `Resolve-DevelopmentDocsRoot` to return `Succeeded` true and `Root` `docs/features`, as a setup change with every expectation unchanged. No task was added, removed, or reordered, and no assertion changed.
- Self-check: the fix applies a rule the plan already states (D-P16) and keeps the Pre-Mortem statement true; its prose follows the tonality rule.
