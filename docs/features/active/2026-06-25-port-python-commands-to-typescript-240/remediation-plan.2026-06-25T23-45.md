# Remediation Plan — F2 ts-validate-orchestration-artifacts (Issue #240)

**Issue:** #240
**Feature:** F2 (ts-validate-orchestration-artifacts)
**Work Mode:** full-feature
**Entry timestamp:** 2026-06-25T23-45
**Plan path:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/remediation-plan.2026-06-25T23-45.md`
**Feature folder (`<FEATURE>`):** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Remediation inputs:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/remediation-inputs.2026-06-25T23-45.md`

## Scope Summary

Resolve the single Major remediation-required finding R1 from the 2026-06-25T23-45 audit cycle: `extensions/drm-copilot/src/repo-automation-service.ts` exceeds the 500-line production-file limit (526 lines; 484 at baseline). The fix extracts the in-process validation wiring of `validateOrchestrationArtifacts` into a small helper module so the service file returns to <= 500 lines, with no change to observable behavior, the public interface, or any other method. No other findings require action this cycle.

## Constraints (must hold for every task)

- No production or test file may exceed 500 lines.
- ES modules only; no `require`/`module.exports` in `src/`.
- Strong typing; no `any`; no new ESLint/TS suppressions.
- Do NOT change the `RepoAutomationService` public interface or any method other than the `validateOrchestrationArtifacts` wiring.
- Do NOT modify `command-runtime.ts`, the `"python"` runtime branch, or `buildValidateOrchestrationArtifactsOptions`.
- Do NOT modify any Python `scripts/dev_tools/**` file.
- Do NOT modify `.claude/rules/**` or `.github/instructions/**`.
- Do not weaken tests, lower coverage thresholds, or add production-path coverage excludes.
- Tests remain hermetic: no real subprocess, temp files, or real filesystem writes.
- Preserve the `validateOrchestrationArtifacts` observable behavior and message strings exactly.

## Evidence Location Invariant

All evidence artifacts MUST be written under `<FEATURE>/evidence/<kind>/`:
- Baseline: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/remediation-baseline/`
- QA gates: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/`
- Regression: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/regression-testing/`

Each command-step evidence artifact MUST include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage artifacts MUST record numeric line and branch coverage. Writing evidence to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` is a policy violation; substitute the canonical path and record `EVIDENCE_LOCATION_OVERRIDE_REJECTED`.

---

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read repository policy files in required order per `policy-compliance-order`: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`. Write `evidence/remediation-baseline/phase0-instructions-read.2026-06-25T23-45.md` with `Timestamp:`, `Policy Order:`, and an explicit `Files Read:` list. Acceptance: the artifact exists and lists every file read.

- [x] [P0-T2] Capture the baseline toolchain state from `extensions/drm-copilot/`: run `npx prettier --check "src/**/*.ts" "test/**/*.ts"`, `npm run lint`, `npm run typecheck`, and `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/validate/**/*.ts"`, and record the current `wc -l src/repo-automation-service.ts`. Write `evidence/remediation-baseline/baseline-toolchain.2026-06-25T23-45.md` with `Timestamp:`, `Command:` (each), `EXIT_CODE:` (each), and `Output Summary:` including the service-file line count (expected 526) and numeric line/branch coverage for `src/lib/validate/**`. Acceptance: artifact records all commands with exit codes and the numeric values.

---

### Phase 1 — Extract the in-process validation wiring

- [x] [P1-T1] Create `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts` exporting a pure helper that performs the in-process artifact validation currently inlined in `RepoAutomationService.validateOrchestrationArtifacts`. The helper accepts the injected `FileSystem`, the `workspaceRoot`, `artifactType`, `artifactPath`, and optional `requireComplete`; resolves the artifact path via `toPosixPath(path.join(workspaceRoot, artifactPath))`; reads the text; calls `validateArtifact(...)`; and either returns the preserved success result object `{ tool: "validate_orchestration_artifacts", workspaceRoot, summary }` (with the exact existing summary string) or throws an `Error` whose message lists the validation errors using the exact existing format. Reproduce the existing summary and error-message strings verbatim. Acceptance: file < 500 lines; format/lint/typecheck pass; the helper preserves the existing strings character-for-character.

- [x] [P1-T2] Update `extensions/drm-copilot/src/repo-automation-service.ts` so `validateOrchestrationArtifacts` delegates to the new helper, removing the inlined body. Keep the optional `fileSystem` constructor injection and the `RealFileSystem` default. Do not change the public interface, any other method, or imports beyond what the delegation requires. Confirm `wc -l src/repo-automation-service.ts` reports <= 500. Acceptance: file <= 500 lines; format/lint/typecheck pass; only the one method body and its imports change.

---

### Phase 2 — Tests for the extracted helper and regression confirmation

- [x] [P2-T1] Create `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` covering the helper with an injected in-memory `FileSystem`: success path returns the preserved `{ tool, workspaceRoot, summary }`; `requireComplete` reaches the orchestrator-state route; a document with validation errors throws with the expected aggregated error text; path resolution joins `workspaceRoot` and `artifactPath`. Use `@jest/globals` and AAA structure. Acceptance: tests pass; no real subprocess or temp files; file < 500 lines.

- [x] [P2-T2] Confirm the existing `extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts` still passes unchanged in behavior (the service method still returns the preserved summary on success and throws on validation errors). Update only if delegation changes a mock surface; do not weaken assertions. Acceptance: the suite passes; no assertion is removed or weakened.

---

### Phase 3 — Final QA Loop

Run the full toolchain in order from `extensions/drm-copilot/`. If any step changes files or fails, restart from P3-T1.

- [x] [P3-T1] Format. Run `npx prettier --check "src/**/*.ts" "test/**/*.ts"`. Write `evidence/qa-gates/remediation-qa-format.2026-06-25T23-45.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: exit 0; clean pass.

- [x] [P3-T2] Lint. Run `npm run lint`. Write `evidence/qa-gates/remediation-qa-lint.2026-06-25T23-45.md` with the four schema fields and 0-error summary. Acceptance: exit 0; 0 lint errors.

- [x] [P3-T3] Type-check. Run `npm run typecheck`. Write `evidence/qa-gates/remediation-qa-typecheck.2026-06-25T23-45.md` with the four schema fields. Acceptance: exit 0; 0 type errors.

- [x] [P3-T4] Test with coverage. Run `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/validate/**/*.ts"`. Write `evidence/qa-gates/remediation-qa-test-coverage.2026-06-25T23-45.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric aggregate line% and branch% and the passed/total test count. Acceptance: exit 0; line >= 85% and branch >= 75% on `src/lib/validate/**`; numeric values recorded.

- [x] [P3-T5] File-size verification. Record `wc -l` for `src/repo-automation-service.ts` and the new helper and test file. Write `evidence/qa-gates/remediation-file-size.2026-06-25T23-45.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming every production and test file is <= 500 lines. Acceptance: service file <= 500 lines; no file over the limit.

---

## F2 Remediation Acceptance Criteria Checklist

- [x] AC-R1: `extensions/drm-copilot/src/repo-automation-service.ts` is <= 500 lines, satisfying AC-F2-14, with the `validateOrchestrationArtifacts` observable behavior, message strings, and public interface unchanged.
- [x] AC-R2: Format, lint, type-check, and test pass from `extensions/drm-copilot/` in a single clean pass; coverage on `src/lib/validate/**` remains line >= 85% / branch >= 75% with numeric evidence.
- [x] AC-R3: No file (production or test) exceeds 500 lines; tests remain hermetic.
- [x] AC-R4: No Python `scripts/dev_tools/**` file, `.claude/rules/**`, `command-runtime.ts`, the `"python"` runtime branch, or `buildValidateOrchestrationArtifactsOptions` is modified.

## Validator Gate (run before treating this plan as approved)

- Run the `mcp__drm-copilot__validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path` = this plan path. Reject the plan if the validator exits non-zero.

## Preflight Handoff

- `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required signal: `PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`.
- On `PREFLIGHT: REVISIONS REQUIRED`, apply the precise delta and re-validate against this same file path until all clear.
