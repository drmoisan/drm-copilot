# Remediation Inputs — Cycle 1 (issue #647)

Timestamp: 2026-10-02T00-06
Source: feature-review initial audit of branch `bug/test-tree-typecheck-not-gated-647`, head `8a40275c2b43ea88eae0384aea1b873af329f7df`.
Base for diffs: `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9` (merge base with `origin/main`).
Review verdict: NEEDS REVISION. blocking_count = 2 (1 `autonomous`, 1 `awaiting_ci`).

Audit artifacts that produced the findings:
- `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/policy-audit.2026-10-02T00-06.md` (PA-1, PA-2)
- `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/code-review.2026-10-02T00-06.md` (CR-1, CR-2)
- `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/feature-audit.2026-10-02T00-06.md` (AC-15 UNVERIFIED)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (generated 2026-10-02 04:06:28 UTC, head 8a40275c)

## Remediation-required findings

### F1 — CR-1 / PA-1: explicit-undefined scenario lost in a retained test

- Remediability: autonomous
- File: `extensions/drm-copilot/test/lib/validate/build-validate-orchestration-service-call-input.test.ts`
- Location: lines 82-102, test `omits an optional key when its value is explicitly undefined`
- Rules: `.claude/rules/general-unit-test.md` (Scenario Completeness: edge cases; Documentation: the test name must communicate the scenario; "Untested critical behavior is not acceptable even if the overall percentage looks good"); spec.md Boundaries ("Test runtime behavior does not change").
- Defect: at base the input object carried `requireComplete`, `requireModelRouting`, `requireCodexModelRouting`, `requireCodexTopology`, and `requireReadyForExecution` with explicit `undefined` values. The #647 change deleted those keys to satisfy `exactOptionalPropertyTypes`. The test now duplicates the absent-keys test at lines 60-80, the title no longer matches the arrangement, and the line-83 comment contradicts the title.
- Required behavior:
  - The input passed to `buildValidateOrchestrationServiceCallInput` has all five optional keys present as own enumerable properties whose value is `undefined`.
  - An arrange-guard assertion proves the keys are present before the Act step, for example `expect(Object.keys(input)).toEqual(expect.arrayContaining(["requireComplete", "requireModelRouting", "requireCodexModelRouting", "requireCodexTopology", "requireReadyForExecution"]))`.
  - The five existing `expect("<key>" in result).toBe(false)` assertions and the test title remain unchanged.
  - The line-83 comment describes the present-with-undefined arrangement.
- Suggested implementation (no `any`, no suppression): build the base object as now, then for each of the five keys call `Object.defineProperty(input, key, { value: undefined, enumerable: true, writable: true, configurable: true })`. An acceptable alternative is a typed literal cast through `unknown` to `Parameters<typeof buildValidateOrchestrationServiceCallInput>[1]`.
- Verification commands:
  - `npm --prefix extensions/drm-copilot run test -- test/lib/validate/build-validate-orchestration-service-call-input.test.ts` exits 0 with 5 passed.
  - Temporarily confirm the guard fails if the keys are omitted (or reason it from the assertion); do not commit that probe.
  - `npm --prefix extensions/drm-copilot run typecheck` exits 0.
  - `npm --prefix extensions/drm-copilot run lint` exits 0.
  - From `extensions/drm-copilot`: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` exits 0.
  - `npm --prefix extensions/drm-copilot run test` exits 0 with at least 3786 passing tests.
  - AC-12 added-line scan against `1b1e349f` returns no match.
  - File stays at or under 500 lines (currently 163).

### F2 — CR-2 / PA-2: workflow change has no green run at the head

- Remediability: awaiting_ci
- Remediability-Evidence: awaited workflow `ci.yml` (job `drm-copilot-extension-tests`, legs windows-latest and ubuntu-latest, step `Type-check extension source and test tree`); `gh run list --branch bug/test-tree-typecheck-not-gated-647` returned `[]` and no PR exists at 2026-10-02T00-06.
- File: `.github/workflows/_drm-copilot-extension-tests.yml`, lines 29-30
- Rule: `modified-workflow-needs-green-run` (`.claude/skills/feature-review-workflow/SKILL.md`); spec.md AC-15.
- Resolution path: wait path, not a remediation task. After F1 lands, open the PR, record the green `ci.yml` run ID and `gh run view <run-id> --json jobs` output in `evidence/qa-gates/`, and check off AC-15. A green `workflow_dispatch` run at the head also satisfies the rule.

## Do not do

- Do not change production code under `extensions/drm-copilot/src/`.
- Do not add `any`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck`, or `eslint-disable`.
- Do not delete, rename, skip, or focus the affected test, and do not merge it into the absent-keys test.
- Do not change `tsconfig.json`, `tsconfig.jest.json`, `jest.config.cjs`, `package.json`, or the workflow.
- Do not create temporary files in tests.
- Do not widen scope to the informational findings CR-3 through CR-9.

## Exit gate

Reaudit with `blocking_count` limited to F2 (`awaiting_ci`) or zero once the PR CI run is green; F1 recorded as resolved; AC-10, AC-12, AC-13, and AC-14 re-verified against the new head.

## Handoff note

This reviewer session has no delegation tool, so the remediation plan is not authored here. Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the orchestrator delegates F1 to `atomic-planner` for the remediation plan, followed by `atomic-executor` preflight and execution and a `feature-review` reaudit.
