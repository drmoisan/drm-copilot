# Phase 0 — Instructions Read Evidence (F3 `ts-push-down-customizations`)

Timestamp: 2026-06-26T00-05

Policy Order:
1. CLAUDE.md (standing instructions)
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/typescript.md
5. .claude/rules/typescript-suppressions.md
6. .claude/rules/quality-tiers.md
7. .claude/rules/architecture-boundaries.md
8. .claude/rules/self-explanatory-code-commenting.md
9. .claude/skills/evidence-and-timestamp-conventions/SKILL.md

Files read (explicit list):
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\CLAUDE.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\general-code-change.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\general-unit-test.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\typescript.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\typescript-suppressions.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\quality-tiers.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\architecture-boundaries.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\self-explanatory-code-commenting.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\skills\evidence-and-timestamp-conventions\SKILL.md

Notes:
- The plan names baseline artifacts without an F-prefix; this folder is shared
  across F1-F6. To preserve prior-feature audit artifacts, F3 evidence uses an
  `f3-` filename prefix in the same canonical `evidence/baseline/` and
  `evidence/qa-gates/` directories. This is a path-preservation micro-action; the
  canonical evidence location is unchanged.
- typescript.md names Vitest, but the `extensions/drm-copilot/` package uses Jest
  (ts-jest, run-jest.cjs). The plan and task directive explicitly override the
  framework choice for this package. Tests use `@jest/globals`, `jest.fn()`,
  `jest.mock`, and AAA structure.
- Coverage thresholds applied: line >= 85%, branch >= 75% (uniform across tiers).
- F1 shared lib reused where applicable; F3 introduces a dedicated
  `PushDownFileSystem` interface (distinct from F1 `FileSystem`).
