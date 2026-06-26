# Remediation Inputs — F2 ts-validate-orchestration-artifacts (Issue #240)

**Issue:** #240
**Feature:** F2 (ts-validate-orchestration-artifacts)
**Work Mode:** full-feature
**Entry timestamp:** 2026-06-25T23-45
**Feature folder (`<FEATURE>`):** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base branch:** `main` (merge-base `f6af666ea9c160828d6f10d81c3591191b5c0800`)
**Head:** `feat/ts-port-validate-orchestration-240` @ `71f707983164f60bc321103512085b4b11d767fd`

## Source Audit Artifacts (this cycle)

- Policy audit: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/policy-audit.2026-06-25T23-45.md`
- Code review: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/code-review.2026-06-25T23-45.md`
- Feature audit: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/feature-audit.2026-06-25T23-45.md`

## Finding Summary

The F2 port is functionally complete and passes format, lint, typecheck, and the full Jest suite (619/619, 95% line / 88.73% branch on `src/lib/validate/**`). Exactly one remediation-required (Major) finding blocks PR readiness; no Blocker-level code defects exist.

## Enumerated Fix List

### R1 (Major, remediation-required) — File-size limit on the modified service file

- **File:** `extensions/drm-copilot/src/repo-automation-service.ts`
- **Problem:** The file is 526 lines after the F2 change (484 at baseline). `.claude/rules/general-code-change.md` sets a hard 500-line limit on production code files. The F2 edit (+48 net) pushed it over.
- **Expected behavior after fix:** `extensions/drm-copilot/src/repo-automation-service.ts` is <= 500 lines, with no change to the public `RepoAutomationService` interface, the `validateOrchestrationArtifacts` observable behavior (success returns `{ tool, workspaceRoot, summary }` with the preserved summary string; non-empty errors throw an `Error` listing the validation errors), or any other method.
- **Suggested approach (planner may choose another that satisfies the limit):** Extract the in-process validation wiring currently inside `validateOrchestrationArtifacts` (path resolution via `toPosixPath`/`path.join`, `FileSystem.readTextFile`, the `validateArtifact(...)` call, and the error-to-throw mapping) into a small new helper module under `extensions/drm-copilot/src/lib/validate/` (for example `validate-orchestration-service-call.ts`), and have the service method delegate to it. Keep the optional `fileSystem` constructor injection in the service.
- **Verification commands (run from `extensions/drm-copilot/`):**
  - `wc -l src/repo-automation-service.ts` (must report <= 500)
  - `npx prettier --check "src/**/*.ts" "test/**/*.ts"`
  - `npm run lint`
  - `npm run typecheck`
  - `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/validate/**/*.ts"` (619+ tests pass; line >= 85%, branch >= 75%)
- **Acceptance-criterion impact:** Re-satisfies AC-F2-14 (currently FAIL / reverted to unchecked in the plan).

## Do-Not-Do List

- Do NOT modify `.claude/rules/**` or `.github/instructions/**` (no policy weakening). The 500-line limit stands.
- Do NOT change the `RepoAutomationService` public interface signature or any method other than the wiring of `validateOrchestrationArtifacts`.
- Do NOT modify `command-runtime.ts`, the `"python"` runtime branch, or `buildValidateOrchestrationArtifactsOptions` (F11 scope).
- Do NOT modify any Python `scripts/dev_tools/**` file (must remain intact; AC-F2-15).
- Do NOT lower coverage thresholds, add production-path coverage excludes, or weaken any test.
- Do NOT introduce real subprocess calls or real-filesystem temp files in tests (tests stay hermetic).
- Do NOT split a file in a way that creates another file over 500 lines or introduces a circular import.
- Do NOT alter the observable behavior or message strings of `validateOrchestrationArtifacts`.

## Out-of-Scope (record only, no action this cycle)

- Epic ACs AC-E1/AC-E3/AC-E4 are realized incrementally and complete at F11; not part of this remediation.
- AC-E5 CI green run: capture after the refactor when CI runs against the branch head.
- `user-story.md` absence is a documentation gap tracked at the epic level; no code action.
- The remote-schema (`http`/`https`) divergence in `json-validator.ts` is an accepted, documented divergence; no action.
