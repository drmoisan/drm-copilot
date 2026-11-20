# Preflight Fixes (Issue #1025, Round 2)

Timestamp: 2026-10-30T22-15
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md
Preflight signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned separately)

## Fixes Applied In Place

1. [P5-T1] | literal formatting (ambiguous asserted value) | The text "`$schema` and `schema_version` `1.0.0`" could be read as setting `$schema` to `1.0.0`. It now states that `$schema` is set to the spec const `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json` and `schema_version` to `1.0.0`. The asserted spec value is unchanged.
2. [P9-T1] | evidence path rule | `Invoke-PoshQCFormat` logs `Formatted:` and `Already formatted:` with the absolute file path (`$file.FullName`), and evidence must not record an absolute path. The acceptance now requires each file to be recorded by its repository-relative path. The asserted tokens are unchanged.
3. `## Acceptance Criteria Traceability` | traceability citation | The table mapped only two of the 17 user-story criteria. A paragraph now maps each remaining user-story criterion to its spec rows and to plan B P2-T7, and states that the criterion beginning `The completeness gate fails on` is checked off by the orchestrator at S9, consistent with plan B P2-T7 (16 checked, one unchecked). No task or assertion changed.
