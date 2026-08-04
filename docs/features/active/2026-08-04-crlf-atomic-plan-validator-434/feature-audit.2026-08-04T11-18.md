# Feature Audit: CRLF Atomic Plan Validator (#434)

**Audit Date:** 2026-08-04
**Feature Folder:** docs/features/active/2026-08-04-crlf-atomic-plan-validator-434
**Base Branch:** origin/main
**Head Branch:** bug/crlf-atomic-plan-validator-434
**Work Mode:** full-bug
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** origin/main at 7428fddb57343efe42bbcd463e11deb66cf8091f.
- **Head branch/commit:** bug/crlf-atomic-plan-validator-434 at b845c5058ae03ccb4b171523617837dae679595a.
- **Merge base:** 7428fddb57343efe42bbcd463e11deb66cf8091f.
- **Evidence sources:**
  - Primary: artifacts/pr_context.summary.txt, freshly generated at 2026-08-04 15:18:52 UTC.
  - Secondary baseline diff: artifacts/pr_context.appendix.txt, freshly generated at the same time.
  - Feature evidence: docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/evidence/**.
  - Additional: direct git diff origin/main...HEAD and independent review checks.
- **Feature folder used:** docs/features/active/2026-08-04-crlf-atomic-plan-validator-434.
- **Requirements source:** docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/spec.md.
- **Work mode resolution note:** issue.md explicitly records - Work Mode: full-bug; therefore spec.md is the sole authoritative acceptance-criteria source.
- **Scope note:** The branch modifies only the approved validator and Jest test files outside the feature folder. git diff --check origin/main...HEAD passed.

## Acceptance Criteria Inventory

**Authoritative AC source file:**

- docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/spec.md — only source for full-bug.

1. validatePlanText returns [] for the same canonical completed plan encoded with LF, CRLF, and lone-CR separators.
2. extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts contains and passes accepts a valid plan with LF, CRLF, or CR line endings, using the existing completed-task fixture for all three variants.
3. Existing malformed-plan and numbering tests pass with their current error-message contracts, proving phase/task grammar and diagnostics were not weakened.
4. The production change is limited to replacing the source-line delimiter in validatePlanText; no public MCP schema, dispatcher route, dependency, configuration, or unrelated artifact validator changes.
5. npm run format, npm run lint, npm run typecheck, npm run test:unit, and npm run test:coverage pass in one final sequence from extensions/drm-copilot.
6. Extension MCP bundling, package prepack, package build, and a normal stdio smoke of the generated package MCP server verify successful plan validation for LF, CRLF, and CR before npm publication.
7. No logging, telemetry, documentation, configuration, or data migration update is required; the release evidence records that this was verified.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | LF, CRLF, and CR canonical plans return [] | PASS | Post-fix regression and generated-package smoke each record the three successful variants. | Focused Jest; generated MCP stdio smoke | Expected fail-before evidence independently demonstrates the regression. |
| 2 | Required table-driven Jest test exists and passes | PASS | Direct diff adds it.each with LF/CRLF/CR and existing VALID_PLAN; focused review run reports 28 passing tests. | npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestration-artifacts.test.ts | Completed task fixture remains included. |
| 3 | Existing malformed-plan and numbering contracts remain | PASS | Post-fix evidence reports existing malformed assertions; direct test inspection confirms prior cases remain. | Focused Jest command above | No grammar regular expression changed. |
| 4 | Production change is delimiter-only | PASS | Direct base diff changes only text.split("\\n") to text.split(/\r\n|\n|\r/) in production code. | git diff origin/main...HEAD -- extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts | No schema, dispatcher, dependency, config, or unrelated validator diff. |
| 5 | Final TypeScript quality sequence passes | PASS | Post-rebase QA: format unchanged; lint/typecheck passed; 169 suites/2,061 tests; 96.34% lines/89.27% branches. | Commands listed in post-rebase-typescript-mcp-qa.2026-08-04T11-15.md | Independent lint/typecheck/focused Jest checks also passed. |
| 6 | Bundle, package, and stdio smoke pass | PASS | Post-rebase QA records successful bundle, prepack, build, and LF/CRLF/CR generated-package MCP smoke. | Bundle/prepack/build/smoke commands in post-rebase QA artifact | Package version 1.0.20 was locally generated; publication remains post-merge. |
| 7 | No ancillary update is required and evidence records verification | PASS | Direct diff contains no logging, telemetry, documentation, configuration, or migration change; package smoke and QA evidence are recorded. | git diff --name-status origin/main...HEAD | This criterion does not require pre-merge npm publication. |

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**

- **PASS:** 7 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:** None.

**Recommended follow-up verification steps:**

1. After merge, complete the planned tag-driven npm publication and immutable-package verification in P5-T3 and P5-T4.
2. Retain the post-merge release receipts in the canonical feature evidence root.

## Acceptance Criteria Check-off

No source-file checkbox was changed during this review because all seven authoritative spec.md acceptance criteria were already checked and the evaluated results confirm those check-offs.

### Acceptance Criteria Status

- Source: docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/spec.md
- Total AC items: 7
- Checked off (delivered): 7
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
| --- | ---: | ---: | ---: | --- |
| docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/spec.md | 7 | 7 | 0 | Checkbox-backed; no review mutation needed. |
