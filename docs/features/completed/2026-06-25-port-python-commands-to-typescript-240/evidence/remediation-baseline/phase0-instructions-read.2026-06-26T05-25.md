# Phase 0 — Instructions Read (Remediation F8, Issue #240)

Timestamp: 2026-06-26T05-25

Policy Order: Per `policy-compliance-order` — CLAUDE.md (standing) → general-code-change → general-unit-test → TypeScript language-specific rules (TypeScript files in scope) → quality tiers.

Files Read:
- CLAUDE.md (standing instructions, loaded in context)
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/typescript.md
- .claude/rules/typescript-suppressions.md
- .claude/rules/quality-tiers.md
- .claude/rules/self-explanatory-code-commenting.md (Python-scoped; read for completeness per plan task list)

Notes:
- Files in scope are TypeScript under `extensions/drm-copilot/src/lib/new-active-feature-folder/`.
- File-size limit: no production/test file may exceed 500 lines (general-code-change).
- Coverage thresholds (uniform T1–T4): line >= 85%, branch >= 75% (quality-tiers, general-unit-test).
- No new suppressions; no `any`; ES modules only (typescript, typescript-suppressions).
