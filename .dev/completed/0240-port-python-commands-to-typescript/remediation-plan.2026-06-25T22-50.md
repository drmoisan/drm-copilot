# Remediation Plan — F1 TypeScript Shared Utility Layer (Issue #240)

**Issue:** #240
**Feature:** F1 (ts-shared-subprocess-and-utility-layer)
**Work Mode:** full-feature
**Entry timestamp:** 2026-06-25T22-50
**Plan path:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/remediation-plan.2026-06-25T22-50.md`
**Feature folder (`<FEATURE>`):** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Remediation inputs:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/remediation-inputs.2026-06-25T22-50.md`

## Scope Summary

Address the two Major policy-reconciliation findings (R1, R2) and three optional non-blocking improvements (O1-O3) from the 2026-06-25T22-50 audit cycle. No Blocking code defects were found; the F1 implementation passes the full toolchain. This plan does not change F1 runtime behavior except for the documentation-accuracy edits in O1/O2.

## Constraints (must hold for every task)

- No production or test file may exceed 500 lines.
- ES modules only; no `require`/`module.exports` in `src/`.
- Strong typing; no `any`.
- Do NOT modify `command-runtime.ts`, `repo-automation-service.ts`, or MCP handlers (epic-scope, deferred).
- Do NOT modify `.claude/rules/**` or `.github/instructions/**` without explicit policy-owner approval (applies to R2).
- Do not weaken tests, lower coverage thresholds, or add production-path coverage excludes.
- Tests remain hermetic: no real subprocess, temp files, or real filesystem writes.

## Evidence Location Invariant

All evidence artifacts MUST be written under `<FEATURE>/evidence/<kind>/`:
- Baseline: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/`
- QA gates: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/`
- Regression: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/regression-testing/`

Each command-step evidence artifact MUST include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage artifacts MUST record numeric line and branch coverage values. Writing evidence to `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/` is a policy violation.

---

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Read repository policy files in required order per `policy-compliance-order`: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/self-explanatory-code-commenting.md`. Write `evidence/baseline/remediation-phase0-instructions-read.2026-06-25T22-50.md` with `Timestamp:`, `Policy Order:`, and `Files Read:`. Acceptance: evidence file exists and lists every file.
- [ ] [P0-T2] Capture baseline toolchain state from `extensions/drm-copilot/`: run `npm run format`, `npm run lint`, `npm run typecheck`, and `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`. Write `evidence/baseline/remediation-baseline-toolchain.2026-06-25T22-50.md` with `Timestamp:`, `Command:` (each), `EXIT_CODE:` (each), and `Output Summary:` including numeric line and branch coverage for `src/lib/**`. Acceptance: artifact records all four commands with exit codes and numeric coverage.

---

### Phase 1 — R1: Acceptance-Criteria Source Reconciliation

- [ ] [P1-T1] Resolve the AC-source gap for `full-feature` work mode. Decide with the issue owner between: (a) author `spec.md` and `user-story.md` for the epic with checkbox-backed acceptance criteria, or (b) record a documented determination that the F1 plan checklist is the operative AC source for this folder. If (a): create `<FEATURE>/spec.md` and `<FEATURE>/user-story.md` with checkbox AC that cover the F1 deliverables and reference the epic AC. If (b): record the determination in `<FEATURE>/issue.md` (or a decision note) without weakening the work-mode contract. Acceptance: `feature-review` can resolve AC sources without fallback; the chosen artifacts exist and contain checkbox-format AC.

---

### Phase 2 — R2: Test-Framework Policy Reconciliation (decision-gated)

- [ ] [P2-T1] Prepare a policy-reconciliation proposal for the Jest-vs-Vitest divergence. Document the two options: (a) author an authorized exception in `.claude/rules/typescript.md` acknowledging the extension package's Jest toolchain (requires policy-owner approval — DO NOT edit the policy file without it), or (b) scope a Vitest migration for `extensions/drm-copilot/` as a separate initiative. Write the proposal and the chosen path to `evidence/regression-testing/r2-framework-reconciliation-decision.2026-06-25T22-50.md`. Acceptance: the decision artifact records both options and the owner-approved path. No policy file is edited without recorded approval.

---

### Phase 3 — Optional Documentation/Parity Fixes (O1, O2)

- [ ] [P3-T1] (O1) Correct the `CommandResult` JSDoc in `extensions/drm-copilot/src/lib/subprocess-runner.ts` (line 8) to state that all trailing newline characters are stripped (matching the `stripTrailingNewlines` helper and Python `rstrip("\n")`). Acceptance: `npx tsc -p ./ --noEmit` clean; JSDoc accurately describes the helper behavior.
- [ ] [P3-T2] (O2) In `extensions/drm-copilot/src/lib/markdown-label-formatter.ts`, document in the `splitLines` JSDoc that only `\n`/`\r`/`\r\n` boundaries are handled (intentional narrowing relative to Python `str.splitlines()` Unicode boundaries), or extend the boundary set if exotic separators are in-scope. If behavior changes, add a covering test in `test/lib/markdown-label-formatter.test.ts`. Acceptance: JSDoc or test reflects the decided behavior; toolchain remains clean.

---

### Phase 4 — Final QA Loop and Coverage Verification

Run the full toolchain in order from `extensions/drm-copilot/`. If any step fails or changes files, fix and restart from P4-T1.

- [ ] [P4-T1] Run `npm run format`. Write `evidence/qa-gates/remediation-final-format.2026-06-25T22-50.md` with the four required fields. Acceptance: EXIT_CODE 0; if files changed, restart.
- [ ] [P4-T2] Run `npm run lint`. Write `evidence/qa-gates/remediation-final-lint.2026-06-25T22-50.md`. Acceptance: EXIT_CODE 0 and 0 lint errors.
- [ ] [P4-T3] Run `npm run typecheck`. Write `evidence/qa-gates/remediation-final-typecheck.2026-06-25T22-50.md`. Acceptance: EXIT_CODE 0 and 0 type errors.
- [ ] [P4-T4] Run `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`. Write `evidence/qa-gates/remediation-final-test-coverage.2026-06-25T22-50.md` recording numeric line and branch coverage. Acceptance: EXIT_CODE 0, all tests pass, line coverage >= 85% and branch coverage >= 75% for `src/lib/**`.
- [ ] [P4-T5] Verify scope containment via `git status --porcelain` and `git diff --name-only`. Confirm no changes outside `extensions/drm-copilot/src/lib/`, `extensions/drm-copilot/test/lib/`, the feature folder, and (only with recorded approval) the policy decision artifacts. Write `evidence/qa-gates/remediation-scope-verification.2026-06-25T22-50.md`. Acceptance: no out-of-scope modifications.

---

## Acceptance Criteria Checklist (Remediation)

- [ ] R1: `full-feature` AC sources resolved (files created or determination recorded); `feature-review` resolves AC without fallback.
- [ ] R2: Jest-vs-Vitest divergence reconciled via owner-approved path; no unauthorized policy-file edit.
- [ ] O1: `CommandResult` JSDoc corrected.
- [ ] O2: `splitLines` parity documented or extended (with test if behavior changed).
- [ ] Full toolchain passes (format, lint, typecheck, tests) with `src/lib/**` line >= 85% and branch >= 75%.
- [ ] No out-of-scope files modified; no policy file edited without recorded approval.
- [ ] All evidence artifacts written under `<FEATURE>/evidence/<kind>/` with required schema fields.
