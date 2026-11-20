# Remediation Inputs — F1 TypeScript Shared Utility Layer (Issue #240)

**Entry timestamp:** 2026-06-25T22-50
**Feature folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Branch:** `feat/ts-port-shared-utilities-240` @ `b7ca64197c13884e8ed9833ee6937b3a9d827c80`
**Base:** `main` @ `38a9c11ee34895e92b6e38ea5400e7dd07cddc9d`

## Source audit artifacts

- `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/policy-audit.2026-06-25T22-50.md`
- `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/code-review.2026-06-25T22-50.md`
- `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/feature-audit.2026-06-25T22-50.md`

## Finding classification

- **Blocking findings: 0.** No Blocker-severity code defects were identified. The F1 code passes format, lint, type-check, and coverage gates and was independently reproduced.
- **Material PARTIAL / Major (remediation-required): 2.**
- **Minor / Info (non-blocking, optional): 3.**

The two Major items are policy/scaffolding reconciliations, not code defects. They are recorded here because the feature-audit verdict is NEEDS REVISION and the policy-audit verdict is PARTIALLY COMPLIANT.

## Remediation-required findings

### R1 (Major) — Missing `full-feature` acceptance-criteria source files
- **Finding:** `issue.md` declares `- Work Mode: full-feature`, which requires `spec.md` and `user-story.md` as authoritative AC sources. Neither exists in the feature folder. AC tracking currently falls back to the F1 plan checklist.
- **Files:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/spec.md` (to create), `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/user-story.md` (to create).
- **Expected behavior:** Either (a) author `spec.md` and `user-story.md` for the epic with checkbox-backed acceptance criteria, or (b) if F1 is to be tracked independently, change the work-mode marker to the mode whose AC source matches the existing checkbox-backed F1 plan, with rationale recorded.
- **Verification:** AC source files exist and contain checkbox-format acceptance criteria; `feature-audit` can resolve AC sources without fallback. `ls docs/features/active/2026-06-25-port-python-commands-to-typescript-240/spec.md docs/features/active/.../user-story.md`.

### R2 (Major) — Test-framework policy divergence (Jest vs mandated Vitest)
- **Finding:** `extensions/drm-copilot/` uses Jest (`ts-jest`, `@jest/globals`, `run-jest.cjs`), but `.claude/rules/typescript.md` mandates Vitest and Vitest-only facilities (`vi.useFakeTimers`, `vi.spyOn`). The divergence is pre-existing and package-wide (41 suites), not introduced by F1.
- **Files:** `.claude/rules/typescript.md` (policy; do not edit without authorization), `extensions/drm-copilot/package.json`, `extensions/drm-copilot/jest.config.cjs`.
- **Expected behavior:** Reconcile the divergence. Preferred: document the extension package's Jest toolchain as an authorized exception in `typescript.md` (requires policy-owner approval, since policy files must not be edited unilaterally). Alternative: schedule a Vitest migration for the package as a separate initiative.
- **Verification:** Policy text and package toolchain agree; no unreconciled MAJOR divergence remains in a future policy audit.
- **Note:** This item requires a decision by the policy owner. The feature-review and atomic-executor agents must not modify `.claude/rules/typescript.md` without explicit approval.

## Optional (non-blocking) improvements

- **O1 (Minor):** `extensions/drm-copilot/src/lib/subprocess-runner.ts:8` — `CommandResult` JSDoc says "a single trailing newline stripped" but the implementation (and Python `rstrip("\n")`) strips all trailing newlines. Reword to "all trailing newline characters stripped." Verification: `npx tsc -p ./ --noEmit` still clean after edit.
- **O2 (Minor):** `extensions/drm-copilot/src/lib/markdown-label-formatter.ts:43-79` — `splitLines` covers `\n`/`\r`/`\r\n` only; Python `str.splitlines()` splits on additional Unicode boundaries. Document the intentional narrowing in JSDoc, or extend the boundary set if exotic separators are in-scope. Verification: a test asserting the documented behavior.
- **O3 (Info):** `artifacts/pr_context.summary.txt` is stale (reports 0 core logic changes). Regenerate PR context before relying on the summary. Verification: regenerated summary lists the 10 TypeScript files.

## CI verification (E5)

- E5 ("All CI gates pass") is UNVERIFIED: PR-context CI status is "(not available)" for the branch head. No `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` files changed on the branch, so the `modified-workflow-needs-green-run` rule does NOT fire and no green-run evidence is required by that rule. Recommend triggering a CI run against the branch head to resolve E5 before merge.

## Do-not-do list

- Do not modify `command-runtime.ts`, `repo-automation-service.ts`, or MCP handlers under F1; service wiring is a later epic feature (E3/E4).
- Do not modify `.claude/rules/**` or `.github/instructions/**` without explicit policy-owner approval (R2).
- Do not weaken or remove any existing test or assertion.
- Do not lower coverage thresholds or add coverage `exclude` entries for production paths.
- Do not expand scope beyond R1/R2 and the optional items above.
- Do not introduce new runtime dependencies.

## Handoff

Remediation plan authored at `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/remediation-plan.2026-06-25T22-50.md` per `remediation-handoff-atomic-planner` and `atomic-plan-contract`.
