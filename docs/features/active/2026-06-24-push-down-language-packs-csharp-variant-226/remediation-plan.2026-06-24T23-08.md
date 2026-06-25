# Remediation Plan: push-down-language-packs-csharp-variant (#226)

**Plan Timestamp:** 2026-06-24T23-08
**Feature Folder:** `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226`
**Work Mode:** `full-feature`
**Base Branch:** `main` (merge base `ea94a068e0a071940858a0694c47e204244c09af`)
**Head:** `b7274bcb83ca291f766ad5d58f6f3653e162666a`
**Source Inputs:** `remediation-inputs.2026-06-24T23-08.md`; `code-review.2026-06-24T23-08.md` (Findings TS-1 / TS-2)

## Scope

Two TypeScript production files exceed the hard 500-line limit defined in `.claude/rules/general-code-change.md`:

- `extensions/drm-copilot/src/mcp-tool-inputs.ts` — 557 lines (limit 500; merge-base baseline 496).
- `extensions/drm-copilot/src/repo-automation-service.ts` — 507 lines (limit 500; merge-base baseline 488).

Each fix is a behavior-preserving structural extraction into a new kebab-case sibling ES module, re-exported (or call-site-delegated) so existing imports, MCP/extension wiring, and TypeScript tests continue to pass unchanged. New modules must themselves be `<= 500` lines and follow `.claude/rules/typescript.md` (kebab-case filenames, ES modules, strong typing, no `any`/`@ts-ignore`/file-level eslint-disable). No public MCP schema change, no `RepoAutomationService` signature change, no test weakening, no unrelated file edits.

## Evidence Locations (Non-Overridable)

All evidence artifacts MUST be written under the canonical feature evidence root `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/<kind>/`:

- Baseline command artifacts: `evidence/remediation-baseline/`
- Phase 0 policy-read evidence: `evidence/baseline/phase0-instructions-read.remediation.2026-06-24T23-08.md`
- Final-QC command artifacts: `evidence/qa-gates/`

Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and is rejected. Any supplied non-canonical path is replaced with the canonical path and recorded as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied> replaced with <canonical>`.

## Mandatory TypeScript Toolchain Loop

For every code-change task and the final QC phase, run the full loop in order from `extensions/drm-copilot/`:

1. `npm run format`
2. `npm run lint`
3. `npm run typecheck`
4. `npm run test -- --coverage`

Restart from step 1 if any step fails or changes files. Do not stop until all four stages complete without errors in a single pass. Coverage must be maintained (line >= 85%, branch >= 75%, no regression on changed lines per `.claude/rules/quality-tiers.md`).

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the required policy files in order and record them in `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/baseline/phase0-instructions-read.remediation.2026-06-24T23-08.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/architecture-boundaries.md`. Acceptance: artifact exists and lists all seven files in order.
- [x] [P0-T2] Capture the current line count of both target files. Run `wc -l extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/repo-automation-service.ts`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/remediation-baseline/file-size.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording both line counts (expected: `mcp-tool-inputs.ts` 557, `repo-automation-service.ts` 507). Acceptance: artifact records both counts above 500.
- [x] [P0-T3] Capture the TypeScript format baseline. Run `npm run format` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/remediation-baseline/ts-format.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records EXIT_CODE and whether any file was reformatted.
- [x] [P0-T4] Capture the TypeScript lint baseline. Run `npm run lint` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/remediation-baseline/ts-lint.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records EXIT_CODE and error count.
- [x] [P0-T5] Capture the TypeScript type-check baseline. Run `npm run typecheck` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/remediation-baseline/ts-typecheck.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records EXIT_CODE and error count.
- [x] [P0-T6] Capture the TypeScript test+coverage baseline. Run `npm run test -- --coverage` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/remediation-baseline/ts-test.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including numeric headline coverage values (overall line %, overall branch %, and the line/branch % for `mcp-tool-inputs.ts` and `repo-automation-service.ts`). Acceptance: artifact records pass count and numeric baseline coverage values (not placeholders).

---

### Phase 1 — Extract Claude push-down resolvers from `mcp-tool-inputs.ts` (Finding TS-1)

Cohesive extraction target: the Claude push-down input resolver group — the field type-guards `resolveClaudePacksField`, `resolveCsharpVariantField`, `resolveMemoryModeField`, and the public resolver `resolvePushDownClaudeCustomizationsToolInput`, plus the `PushDownClaudeCustomizationsToolInput` interface — into a new sibling module. The public import surface of `./mcp-tool-inputs` must be preserved via re-export so `src/mcp-handlers/push-down-handlers.ts`, `src/mcp-tools.ts`, and `test/mcp-tool-inputs.test.ts` continue importing the same names from the same path unchanged.

- [x] [P1-T1] Create `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts` containing the moved `PushDownClaudeCustomizationsToolInput` interface, the three private field helpers (`resolveClaudePacksField`, `resolveCsharpVariantField`, `resolveMemoryModeField`), and the exported `resolvePushDownClaudeCustomizationsToolInput`. Import `WorkspaceToolInput` from `./mcp-tool-inputs` (or a shared types module) and `asToolArgumentObject`/`normalizeWorkspaceRoot`/`normalizeRequiredText` as needed from `./workflow-command-arguments` and `./mcp-tool-inputs`. Preserve every error message string, the `additionalProperties`/required schema semantics, and the spread-only-when-present field behavior byte-for-byte. No `any`, no `@ts-ignore`, no file-level eslint-disable. Files: create `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts`. Acceptance: new file exists, is `<= 500` lines, and exports `resolvePushDownClaudeCustomizationsToolInput` and `PushDownClaudeCustomizationsToolInput`.
- [x] [P1-T2] If `asToolArgumentObject` is required by the new module but is currently a non-exported helper in `mcp-tool-inputs.ts`, expose the minimal shared surface without changing existing public names: either export `asToolArgumentObject` from `./mcp-tool-inputs` and import it in the new module, or keep the helper inlined in the new module. Choose the option that introduces no behavior change and no duplicate divergent copy. Files: edit `extensions/drm-copilot/src/mcp-tool-inputs.ts`, edit `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts`. Acceptance: the new module compiles and `asToolArgumentObject` semantics (object-or-empty, throw on non-object) are identical to the original.
- [x] [P1-T3] Remove the now-moved interface and four functions from `extensions/drm-copilot/src/mcp-tool-inputs.ts` and add a re-export `export { resolvePushDownClaudeCustomizationsToolInput } from "./mcp-tool-inputs-push-down";` and `export type { PushDownClaudeCustomizationsToolInput } from "./mcp-tool-inputs-push-down";` so the original import path remains valid for all consumers. Files: edit `extensions/drm-copilot/src/mcp-tool-inputs.ts`. Acceptance: `mcp-tool-inputs.ts` is `<= 500` lines and re-exports both names; no consumer import statement in `src/` or `test/` requires editing.
- [x] [P1-T4] Run the full TypeScript toolchain loop from `extensions/drm-copilot/` in order: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test -- --coverage`. Restart from `npm run format` if any step fails or changes files. Acceptance: all four stages pass in a single clean pass with no test changes required; the existing `test/mcp-tool-inputs.test.ts` and `test/push-down-claude-handler.test.ts` suites pass unchanged.

---

### Phase 2 — Extract Claude push-down arg construction from `repo-automation-service.ts` (Finding TS-2)

Cohesive extraction target: the `pushDownClaudeCustomizations` CLI arg-vector construction (the additive `["--destination", workspaceRoot]` base plus the conditional `--packs`/`--csharp-variant`/`--memory-mode` flags) into a new dedicated module, keeping the service class method as a thin delegator. The `RepoAutomationService` interface and `DefaultRepoAutomationService` public method signatures and the backward-compatible no-field arg vector must be preserved.

- [x] [P2-T1] Create `extensions/drm-copilot/src/repo-automation-service-push-down.ts` exporting a pure builder function (suggested `buildPushDownClaudeCustomizationsOptions(input: PushDownClaudeCustomizationsInput): ScriptExecutionOptions & { tool: RepoAutomationToolName }`) that returns the exact `executeScript` options object currently constructed inline in `pushDownClaudeCustomizations` (lines 256-284), including the identical arg-vector logic, `tool`, `runtimeKind`, `bundledRelativePath`, `invocationId` default, `summary`, and `stdoutArtifactPattern`. Import `PushDownClaudeCustomizationsInput` from `./repo-automation-service`, `ScriptExecutionOptions` from `./repo-automation-service-support`, and `RepoAutomationToolName` from `./repo-automation-tool-names`, matching the existing `repo-automation-service-workflows.ts` import pattern. Preserve the arg-vector behavior exactly: base `["--destination", input.workspaceRoot]`; append `--packs <joined>` only when `packs` is defined and non-empty; append `--csharp-variant`/`--memory-mode` only when defined. No `any`, no suppressions. Files: create `extensions/drm-copilot/src/repo-automation-service-push-down.ts`. Acceptance: new file exists, is `<= 500` lines, and exports the builder.
- [x] [P2-T2] Replace the inline arg-construction body of `DefaultRepoAutomationService.pushDownClaudeCustomizations` in `extensions/drm-copilot/src/repo-automation-service.ts` with a thin delegation `return this.executeScript(buildPushDownClaudeCustomizationsOptions(input));`, and add the import of `buildPushDownClaudeCustomizationsOptions` from `./repo-automation-service-push-down`. Do not change the `RepoAutomationService` interface, the `pushDownClaudeCustomizations` signature, or any other method. Files: edit `extensions/drm-copilot/src/repo-automation-service.ts`. Acceptance: `repo-automation-service.ts` is `<= 500` lines; the method signature and the `PushDownClaudeCustomizationsInput` export are unchanged.
- [x] [P2-T3] Run the full TypeScript toolchain loop from `extensions/drm-copilot/` in order: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test -- --coverage`. Restart from `npm run format` if any step fails or changes files. Acceptance: all four stages pass in a single clean pass; the service backward-compatibility test in `test/repo-automation-service.push-down-claude.test.ts` ("no-field input spawns exactly the destination args" / `["--destination", workspaceRoot]`) passes unchanged.

---

### Phase 3 — Final QA Loop and Verification

- [x] [P3-T1] Verify both target files are `<= 500` lines. Run `wc -l extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/repo-automation-service.ts extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts extensions/drm-copilot/src/repo-automation-service-push-down.ts`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/qa-gates/file-size.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording all four line counts. Acceptance: all four `.ts` files are `<= 500` lines (both original targets reduced below 500; both new modules `<= 500`).
- [x] [P3-T2] Run the final TypeScript format gate. Run `npm run format` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/qa-gates/ts-format.remediation.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0 and no file reformatted on the final pass. This command must be executed; SKIPPED is invalid.
- [x] [P3-T3] Run the final TypeScript lint gate. Run `npm run lint` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/qa-gates/ts-lint.remediation.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0 and 0 errors. This command must be executed; SKIPPED is invalid.
- [x] [P3-T4] Run the final TypeScript type-check gate. Run `npm run typecheck` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/qa-gates/ts-typecheck.remediation.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0 and 0 errors. This command must be executed; SKIPPED is invalid.
- [x] [P3-T5] Run the final TypeScript test+coverage gate. Run `npm run test -- --coverage` from `extensions/drm-copilot/`. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/qa-gates/ts-test.remediation.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including numeric post-change coverage values (overall line %, overall branch %, and line/branch % for `mcp-tool-inputs.ts`, `mcp-tool-inputs-push-down.ts`, `repo-automation-service.ts`, `repo-automation-service-push-down.ts`). Acceptance: EXIT_CODE 0, all suites pass, and coverage is maintained (line >= 85%, branch >= 75%, no regression on changed lines versus the Phase 0 baseline). This command must be executed; SKIPPED is invalid.
- [x] [P3-T6] Confirm coverage delta is non-regressing. Compare the Phase 0 baseline (`evidence/remediation-baseline/ts-test.2026-06-24T23-08.md`) against the Phase 3 post-change values (`evidence/qa-gates/ts-test.remediation.2026-06-24T23-08.md`). Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/qa-gates/coverage-delta.2026-06-24T23-08.md` with `Timestamp:`, baseline line/branch %, post-change line/branch %, and changed-code coverage %. Acceptance: post-change coverage is >= baseline (no regression) and the new modules' lines are covered; if any required coverage value is unavailable, the outcome is remediation-required and MUST NOT be reported as PASS.
- [x] [P3-T7] Confirm no out-of-scope or prohibited changes. Run `git diff --name-only ea94a068e0a071940858a0694c47e204244c09af -- extensions/drm-copilot/src` plus a review of the staged diff to confirm: only `mcp-tool-inputs.ts`, `repo-automation-service.ts`, and the two new sibling modules changed; no edits to `.claude/rules/**` or `.github/instructions/**`; no MCP schema field change (`packs`/`csharp_variant`/`memory_mode` remain optional; `additionalProperties: false` retained; no field added to `required`); no `any`/`@ts-ignore`/`@ts-nocheck`/file-level eslint-disable introduced; no new runtime dependency; no temp files in tests. Write `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/qa-gates/scope-confirmation.2026-06-24T23-08.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing the changed files. Acceptance: only the four in-scope `.ts` files changed and none of the prohibited conditions are present.
