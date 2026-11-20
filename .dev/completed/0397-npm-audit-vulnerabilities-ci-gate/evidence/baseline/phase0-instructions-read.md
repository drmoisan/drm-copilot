# Phase 0 — Instructions Read

## [P0-T1] Spec Approval Confirmation

- **File:** `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md`
- **Status line quoted:** `- **Status:** Approved`
- **Version:** 0.2

## [P0-T2] Policy Reads

- **Timestamp:** 2026-07-22T12-15
- **Policy Order:**
  1. `CLAUDE.md`
  2. `.github/copilot-instructions.md`
  3. `.github/instructions/general-code-change.instructions.md`
  4. `.github/instructions/general-unit-test.instructions.md`
  5. `.github/instructions/typescript-code-change.instructions.md`
  6. `.github/instructions/typescript-unit-test.instructions.md`
- **Files read (exact order):**
  1. `c:\Users\DanMoisan\repos\drm-copilot\CLAUDE.md`
  2. `c:\Users\DanMoisan\repos\drm-copilot\.github\copilot-instructions.md`
  3. `c:\Users\DanMoisan\repos\drm-copilot\.github\instructions\general-code-change.instructions.md`
  4. `c:\Users\DanMoisan\repos\drm-copilot\.github\instructions\general-unit-test.instructions.md`
  5. `c:\Users\DanMoisan\repos\drm-copilot\.github\instructions\typescript-code-change.instructions.md`
  6. `c:\Users\DanMoisan\repos\drm-copilot\.github\instructions\typescript-unit-test.instructions.md`
- **Notes:** This is a `full-bug` work-mode dependency-manifest-only fix (npm `overrides` + lock regeneration in 3 manifests). No `.ts` source files are modified; TypeScript-specific formatting/lint/type-check gates are not standalone-applicable to this diff (see Phase 6 rationale artifact, `toolchain-stage-applicability.md`). Full toolchain loop (compile/build + Jest test suites) is still executed per the plan's Phase 0/5/6 tasks.
