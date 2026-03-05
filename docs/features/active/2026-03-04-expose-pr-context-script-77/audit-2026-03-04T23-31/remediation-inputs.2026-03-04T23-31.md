# Remediation Inputs — expose-pr-context-script (#77)

Timestamp: 2026-03-04T23-31

## Required Fixes (numbered, minimum scope)

1. **Restore formatting compliance for all changed scope files**
   - **Files:**
     - `tests/unit/hello-typescript.test.ts`
     - `extensions/scaffold-extension/package.json`
     - `extensions/scaffold-extension/resources/templates/collect_pr_context.py`
   - **Expected behavior:** Formatting checks pass with no warnings/failures.
   - **Acceptance criteria linkage:** Required for quality gate and policy compliance before merge.
   - **Verification commands:**
     - `npm run format:check`
     - `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
     - `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py`

2. **Bring test file size under 500 lines**
   - **Files:** `extensions/scaffold-extension/test/extension.test.ts`
   - **Expected behavior:** No test/production file exceeds 500 lines.
   - **Acceptance criteria linkage:** General code policy module/file structure requirement.
   - **Verification commands:**
     - line-count check showing file <= 500
     - `npm --prefix extensions/scaffold-extension run lint`
     - `npm --prefix extensions/scaffold-extension run typecheck`
     - `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs`

3. **Resolve or explicitly remediate TypeScript coverage regression**
   - **Files:** likely `extensions/scaffold-extension/src/extension.ts` and tests under `extensions/scaffold-extension/test/`
   - **Expected behavior:** No-regression coverage gate is satisfied with updated evidence; changed/new code coverage is measured and documented.
   - **Acceptance criteria linkage:** Quality/coverage policy and review-feature PASS gate requirements.
   - **Verification commands:**
     - `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs --coverage --coverageReporters=text-summary`
     - regenerate/update `evidence/qa-gates/ts-coverage-delta.<timestamp>.md` with numeric baseline/post/new-code values

4. **Add PR-command-specific failure-path tests**
   - **Files:**
     - `extensions/scaffold-extension/test/extension.test.ts` (or split test modules)
   - **Expected behavior:** Direct tests validate `collectPrContext` behavior for git-branch discovery failure and non-zero collector exit diagnostics.
   - **Acceptance criteria linkage:**
     - Runtime/Git/branch-selection failure handling AC
     - Non-zero collector exit logging AC
   - **Verification commands:**
     - targeted Jest test runs by test name
     - full extension Jest run

5. **Reconcile plan checklist with actual gate state**
   - **Files:** `docs/features/active/2026-03-04-expose-pr-context-script-77/plan.2026-03-04T23-07.md`
   - **Expected behavior:** Checkbox states and QA evidence references reflect true post-remediation status.
   - **Acceptance criteria linkage:** explicit user requirement to reconcile plan checklists.
   - **Verification commands:**
     - manual checklist review + evidence path validation

## Do Not Do

- Do not broaden feature scope beyond PR-context command, branch selection, and required QA/test/policy remediation.
- Do not weaken lint/type/test/coverage thresholds or disable checks.
- Do not add broad suppressions (`eslint-disable`, `# noqa`, `# type: ignore`) unless explicitly policy-authorized.
- Do not mark plan items complete without corresponding passing evidence.
- Do not skip rerunning full toolchain after changes.

## Acceptance Criteria Not Yet Fully Met

1. **Runtime/Git/branch-state failure diagnostics for `collectPrContext`** — currently PARTIAL due limited direct PR-path failure assertions.
   - **Minimum change to satisfy:** add explicit unit tests for git discovery failure and non-zero collector failure behavior on PR command path.

2. **Integration confidence for full PR flow including artifact write verification** — currently PARTIAL.
   - **Minimum change to satisfy:** add integration assertion that PR command execution path yields expected output artifact contract in destination context.

3. **Merge-quality gate readiness** — currently FAIL.
   - **Minimum change to satisfy:** achieve one clean pass of format -> lint -> typecheck -> tests/coverage and update evidence + plan checklist.
