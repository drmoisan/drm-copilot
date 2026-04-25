# Remediation Inputs: expose-policy-audit-template-surface (#141)

## Authoritative Source

- This file is the authoritative remediation requirements source for the review run dated `2026-04-11T22-54`.
- Base branch: `development`
- Feature folder: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`

## Fix List

1. **Close the changed/new-code coverage proof gap for the modified existing TypeScript files.**
   - Affected evidence: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md`
   - Expected behavior: the remediation outcome must let the review state, with deterministic evidence, whether the repository coverage obligations are satisfied for the modified existing TypeScript source files touched by this feature.
   - Acceptable closure paths:
     - add deterministic evidence that isolates changed/new-code coverage for the modified existing TypeScript files, or
     - document and justify an approved exception if deterministic isolation is impossible under the repo toolchain.
   - Verification commands:
     - `npm run lint`
     - `npm run typecheck`
     - `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`
     - any additional deterministic coverage command needed to support the changed/new-code proof

2. **Refresh the QA disposition artifacts so they reflect the post-remediation evidence.**
   - Affected files:
     - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md`
     - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/qa-loop-summary.2026-04-11T22-03.md`
   - Expected behavior: the coverage summary and QA summary must align with the final post-remediation evidence and clearly state whether the feature now satisfies the approved plan and repository policy.
   - Verification commands:
     - `npm run lint`
     - `npm run typecheck`
     - `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`

3. **Restore the remaining acceptance criterion only after the evidence gap is closed.**
   - Affected file: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`
   - Expected behavior: AC-4 should remain unchecked until the changed/new-code coverage proof or approved exception is in place. Only then may it be checked back off.
   - Verification command:
     - inspect `user-story.md` after the evidence artifacts are refreshed

## Required Context Package

- Original feature plan: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md`
- Review artifacts:
  - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/policy-audit.2026-04-11T22-54.md`
  - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/code-review.2026-04-11T22-54.md`
  - `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/feature-audit.2026-04-11T22-54.md`
- PR context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`

## Do Not Do

- Do not widen scope into unrelated extension refactors.
- Do not rename or redesign the new MCP tool or the new VS Code command unless the coverage-proof work proves a functional defect.
- Do not weaken the repository coverage policy by changing policy files or review criteria.
- Do not silently mark AC-4 as complete without new deterministic evidence or an explicitly documented approved exception.
