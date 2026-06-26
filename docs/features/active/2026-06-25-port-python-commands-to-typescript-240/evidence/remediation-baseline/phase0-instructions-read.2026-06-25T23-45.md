# Phase 0 — Policy Instructions Read

Timestamp: 2026-06-25T23-45

Policy Order: Per `policy-compliance-order` skill — CLAUDE.md, general-code-change, general-unit-test, then TypeScript language-specific rules (TypeScript files in scope), then quality-tiers.

Files Read:
- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/typescript.md`
- `.claude/rules/typescript-suppressions.md`
- `.claude/rules/quality-tiers.md`

Notes:
- The package `extensions/drm-copilot/` uses Jest, not Vitest. The toolchain
  commands for this remediation are: `npm run format`, `npm run lint`,
  `npm run typecheck`, and `node run-jest.cjs` (with coverage flags). This
  overrides the generic Vitest reference in `typescript.md` for this package.
- Constraints from the plan: no production or test file may exceed 500 lines;
  ES modules only; no `any`; no new suppressions; preserve the
  `validateOrchestrationArtifacts` observable behavior and message strings
  verbatim; do not modify `command-runtime.ts`, the `"python"` runtime branch,
  `buildValidateOrchestrationArtifactsOptions`, Python `scripts/dev_tools/**`,
  or `.claude/rules/**`.
