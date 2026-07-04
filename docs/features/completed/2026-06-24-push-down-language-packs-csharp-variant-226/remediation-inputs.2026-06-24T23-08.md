# Remediation Inputs: push-down-language-packs-csharp-variant (#226)

**Entry Timestamp:** 2026-06-24T23-08
**Feature Folder:** `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226`
**Base Branch:** `main` (merge base `ea94a068e0a071940858a0694c47e204244c09af`)
**Head:** `b7274bcb83ca291f766ad5d58f6f3653e162666a`
**Work Mode:** `full-feature`

## Source Audit Artifacts (findings origin)

- `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/policy-audit.2026-06-24T23-08.md` (Section 2.3, Section 8, Finding TS-1)
- `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/code-review.2026-06-24T23-08.md` (Findings Table, Major TS-1 / TS-2)
- `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/feature-audit.2026-06-24T23-08.md` (all 23 ACs PASS; no AC remediation required)

## Why Remediation Is Triggered

The feature meets all 23 acceptance criteria and all toolchains are green. Remediation is triggered by a meaningful PARTIAL policy result: two TypeScript production files exceed the hard 500-line file-size limit defined in `.claude/rules/general-code-change.md` ("No production code, test code, or reusable script file may exceed 500 lines"), with no applicable exception. Both files were under the limit at the merge base and this feature grew them past it.

This is a policy-compliance (maintainability) remediation, not an acceptance-criterion failure. No feature behavior changes; the fix is a structural extraction that preserves behavior and keeps the green toolchain.

## Enumerated Fix List

### Fix 1 — `extensions/drm-copilot/src/mcp-tool-inputs.ts` exceeds 500 lines (557)

- **File:** `extensions/drm-copilot/src/mcp-tool-inputs.ts`
- **Current state:** 557 lines (merge-base baseline: 496).
- **Expected behavior after fix:** File is <= 500 lines with no behavior change. Extract a cohesive subset (for example, the push-down tool input resolution `resolvePushDownClaudeCustomizationsToolInput` and/or other per-tool input resolvers and their argument-narrowing helpers) into a new sibling module (suggested: `mcp-tool-inputs-push-down.ts` or a shared `mcp-tool-input-helpers.ts`), re-exported from `mcp-tool-inputs.ts` if needed to preserve the public import surface. The extracted module must also be <= 500 lines.
- **Constraints:** Preserve exported names and import paths consumed elsewhere; keep `additionalProperties`/required schema semantics unchanged; no `any`, no file-level suppressions.
- **Verification commands (from `extensions/drm-copilot/`):**
  - `npm run format`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run test -- --coverage`
  - File-size check: each resulting `.ts` file is <= 500 lines.

### Fix 2 — `extensions/drm-copilot/src/repo-automation-service.ts` exceeds 500 lines (507)

- **File:** `extensions/drm-copilot/src/repo-automation-service.ts`
- **Current state:** 507 lines (merge-base baseline: 488).
- **Expected behavior after fix:** File is <= 500 lines with no behavior change. Extract the `pushDownClaudeCustomizations` CLI arg-vector construction (and, if helpful, related service arg builders) into a small dedicated module (suggested: `repo-automation-service-push-down.ts`), keeping the service class method as a thin delegator.
- **Constraints:** Preserve the `RepoAutomationService` public method signatures and the backward-compatible no-field arg vector (`["--destination", workspaceRoot]`); no behavior change to existing commands.
- **Verification commands (from `extensions/drm-copilot/`):**
  - `npm run format`
  - `npm run lint`
  - `npm run typecheck`
  - `npm run test -- --coverage`
  - File-size check: each resulting `.ts` file is <= 500 lines.
  - Confirm the service backward-compatibility test ("no-field input spawns exactly the destination args") still passes.

## Coverage Note (no remediation required)

- Repo-wide Python branch coverage is 74.77% (0.23pp below the 75% repo-wide policy floor). This is attributable entirely to pre-existing out-of-scope modules (for example `shell_qc.py` 0%, `tk_dialog_helpers.py` ~45%) that this feature does not touch. All feature-owned Python modules meet line >= 85% and branch >= 75%, and there is no regression on changed lines. No feature-code remediation is required for this; raising repo-wide branch coverage is out of this feature's scope.

## Do-Not-Do List

- Do not modify any policy document under `.claude/rules/` or `.github/instructions/`.
- Do not weaken, relax, or add exceptions to the 500-line limit.
- Do not change feature behavior, acceptance-criteria semantics, or the public MCP schema (`packs`/`csharp_variant`/`memory_mode` remain optional; `additionalProperties: false` retained; no field added to `required`).
- Do not reduce typing strictness, add `any`, `@ts-ignore`, or file-level eslint-disable to make checks pass.
- Do not introduce runtime temp files in tests or new runtime dependencies.
- Do not address the pre-existing repo-wide Python branch coverage by editing out-of-scope modules; it is out of scope.
- Do not narrow the reaudit scope; the reaudit is full feature-vs-base.

## Handoff

Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the orchestrator authors the remediation plan handoff: delegate to `atomic-planner` to author `remediation-plan.2026-06-24T23-08.md` (conforming to `.claude/skills/atomic-plan-contract/SKILL.md`), preflight via `atomic-executor`, execute task-by-task, then re-delegate to `feature-review` for exit-timestamp reaudit artifacts. This feature-review agent does not author the plan file or invoke workers directly.
