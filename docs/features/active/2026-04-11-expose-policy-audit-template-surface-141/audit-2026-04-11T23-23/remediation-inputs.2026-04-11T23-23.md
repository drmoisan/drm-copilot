# Remediation Inputs: expose-policy-audit-template-surface (#141)

## Authoritative Source

- This file is the authoritative remediation requirements source for the re-review dated `2026-04-11T23-23`.
- Base branch: `development`
- Feature folder: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`

## Fix List

1. **Close the failing changed/new-code coverage proof for the modified existing TypeScript production files.**
   - Affected evidence:
     - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md`
     - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md`
   - Expected behavior: the feature must be able to show a passing changed/new-code coverage disposition for the modified existing TypeScript production files, or cite an already approved exception that satisfies the review contract.
   - Current failing evidence:
     - `extensions/drm-copilot/src/mcp-tool-inputs.ts`: proof artifact reports uncovered changed lines `240, 241, 242, 243, 244, 245`
     - `extensions/drm-copilot/src/mcp-tools.ts`: proof artifact reports unmatched changed lines `525-531`
     - `extensions/drm-copilot/src/workflow-command-arguments.ts`: proof artifact reports uncovered changed lines `75, 164, 165, 166, 167, 254, 255, 256, 257` and unmatched changed lines `571-598`
   - Verification commands:
     - `npm run format`
     - `npm run lint`
     - `npm run typecheck`
     - `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`
     - the deterministic changed-line proof command used against `coverage/lcov.info`

2. **Refresh the QA disposition artifacts so they reflect the corrected proof result.**
   - Affected files:
     - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md`
     - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/qa-loop-summary.2026-04-11T22-03.md`
   - Expected behavior: the coverage summary and QA summary must report the final changed/new-code disposition accurately and consistently.
   - Verification commands:
     - `npm run format`
     - `npm run lint`
     - `npm run typecheck`
     - `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`

3. **Restore `AC-4` only if the refreshed proof or an approved exception supports it.**
   - Affected file: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`
   - Expected behavior: `AC-4` must remain unchecked unless the refreshed coverage-proof evidence supports PASS or an approved exception is cited.
   - Verification command:
     - inspect `user-story.md` after the coverage and QA disposition artifacts are refreshed

## Required Context Package

- Original feature plan: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md`
- Prior remediation plan: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/remediation-plan.2026-04-11T22-54.md`
- Updated review artifacts:
  - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/policy-audit.2026-04-11T23-23.md`
  - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/code-review.2026-04-11T23-23.md`
  - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/feature-audit.2026-04-11T23-23.md`
- PR context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`

## Do Not Do

- Do not widen scope into unrelated extension refactors.
- Do not weaken the changed-line proof rule by silently excluding failing lines without an explicit, repository-acceptable basis.
- Do not alter policy files or review criteria to force a PASS outcome.
- Do not mark `AC-4` complete without new evidence or an approved exception.
