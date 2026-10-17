# Feature Audit: Handoff Failure-Cause Fallback and Name Gaps (Issue #844)

- Review timestamp: 2026-10-09T03-16 (host clock)
- Reviewer: feature-review agent

## Scope and Baseline

- Branch: `bug/handoff-failure-cause-fallback-and-name-gaps-844`, HEAD `b27a9f8c552a9c8fcdc61c78a2279ff027558cc9`.
- Resolved base: `origin/main` at `e7d3779b398604af919678c16c877c8539a86cc0`. The merge-base of `origin/main` and HEAD equals `origin/main`, so the branch is up to date with the base.
- Diff: `git diff origin/main...HEAD` (56 files, 3311 insertions, 373 deletions; 10 TypeScript files, remainder Markdown).
- Work mode: `full-bug` (marker `- Work Mode: full-bug` in `issue.md`). AC source: `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/spec.md` only (AC-1 to AC-18). No `user-story.md` exists for this folder, consistent with `full-bug`.
- Issue: #844 (to be closed). #846 is referenced for the CR-3 test split only.
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent, and the collector MCP tool is not available to this agent. The branch diff was read directly with `git diff` as the equivalent source.

## Acceptance Criteria Inventory

| AC | Summary | Verification method used by this review |
| --- | --- | --- |
| AC-1 | `describeEnvelopeParseFailure` exported; fallback file has three helper cases | Diff read; F1-F3 in fallback file; focused run |
| AC-2 | Authority envelope-parse catch uses the helper; A7 passes | Diff read; A7 row; focused run |
| AC-3 | `HandoffEnvelopeValidationResult.failureCause`; production catch returns helper code and cause; F4 passes | Diff read; F4; focused run |
| AC-4 | Validation-failure branch forwards `validation.failureCause`; F5 passes | Diff read; F5; focused run |
| AC-5 | Projection catch attaches `destination-projection` cause; F6 and F7 pass | Diff read; F6, F7; focused run |
| AC-6 | No blocked result after a caught error lacks a cause (two-strategy inventory) | Evidence artifact plus reviewer catch-site grep |
| AC-7 | Name pattern guard; rows (h), (i), (j) pass | Diff read; rows; focused run |
| AC-8 | Regression-first evidence: fail before, pass after | Evidence artifacts; commit order |
| AC-9 | Existing tests pass without assertion changes | Evidence artifact; reviewer diff of edited test files |
| AC-10 | Authority-service test split into three files, bodies verbatim, split committed first | Reviewer byte comparison against `origin/main`; commit log |
| AC-11 | Pre-split count equals post-split sum | Evidence (28); reviewer focused runs (11 + 17) |
| AC-12 | #645 AC-8 and US-1 name both files; checkbox state unchanged | Diff read |
| AC-13 | All in-scope extension files at or below 500 lines | Reviewer `wc -l` |
| AC-14 | Prettier check exits 0 | Evidence; reviewer Prettier check on changed files |
| AC-15 | `npm run lint` exits 0 | Reviewer run |
| AC-16 | `npm run typecheck` exits 0 including `typecheck:test` | Reviewer run |
| AC-17 | `npm run test:coverage` passes; per-file thresholds; no changed line uncovered | Evidence; reviewer read of `coverage/lcov.info` |
| AC-18 | Out-of-scope files unchanged; PR body closes #844 and references #846 | Reviewer diff of excluded paths; PR body not yet available |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-1 | PASS | `orchestration-handoff-materializer-request.ts` exports `describeEnvelopeParseFailure`. F1 asserts `{ code: "HANDOFF_HISTORY_INVALID", failureCause: "envelope-parse: HANDOFF_HISTORY_INVALID" }`; F2 asserts `{ code: "HANDOFF_UNSUPPORTED_VERSION", failureCause: "envelope-parse: TypeError" }`; F3 asserts `envelope-parse: non-error value` for a thrown string. Passed in the reviewer focused run. |
| AC-2 | PASS | Authority catch at `orchestration-handoff-authority-service.ts:152-157` calls the helper and passes `{ failureCause: failure.failureCause }` to `blocked`. A7 (`envelopeText: "{"`) asserts `HANDOFF_UNSUPPORTED_VERSION` and `envelope-parse: HANDOFF_UNSUPPORTED_VERSION`; passed. |
| AC-3 | PASS | `orchestration-handoff-materializer.ts:71` declares `readonly failureCause?: string`. Production catch returns `failure.code` and `failure.failureCause`. F4 asserts `validateEnvelope("{")` returns `failureCause: "envelope-parse: HANDOFF_UNSUPPORTED_VERSION"`; passed. |
| AC-4 | PASS | `orchestration-handoff-materializer.ts:200` forwards `failureCause: validation.failureCause`. F5 asserts the blocked result carries `envelope-parse: TypeError`; passed. |
| AC-5 | PASS | Projection catch adds `describeHandoffFailureCause("destination-projection", error)`. F6 asserts `HANDOFF_VALIDATOR_UNAVAILABLE` with `destination-projection: TypeError`; F7 asserts `HANDOFF_UNSUPPORTED_VERSION` with `destination-projection: HANDOFF_UNSUPPORTED_VERSION`; both passed. |
| AC-6 | PASS | `evidence/qa-gates/ac6-catch-site-inventory.2026-10-09T03-52.md` records two strategies (`catch \(` and `\bcatch\b`) with 16 identical members and 0 blocked-result sites lacking a cause. Reviewer grep returned the same 16 line numbers; sites 445, 457, 490 and production 33, 49 were read and confirmed. |
| AC-7 | PASS | `HANDOFF_ERROR_NAME_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/` is module-private; non-matching names return `${stage}: Error`. Rows (h) `checkpoint-read: Error`, (i) `checkpoint-read: CustomFailure`, (j) `checkpoint-read: Error` passed. |
| AC-8 | PASS | `evidence/regression-testing/regression-first-before-fix.2026-10-09T03-25.md`: exit 1, 10 failed (h, j, A7, F1-F7). `regression-first-after-fix.2026-10-09T03-36.md`: 45 passed. Commit order confirms tests (`75a653a4`) preceded the fix (`4be4a4f1`). Row (i) is a documented positive control that passes before and after. |
| AC-9 | PASS | `evidence/qa-gates/ac9-existing-assertions.2026-10-09T03-56.md`; reviewer diff shows the only removed line in the edited failure-cause files is the `envelopeText` assignment, replaced by an equivalent default. MCP handler test is unchanged and passed in the reviewer run. |
| AC-10 | PASS | Reviewer comparison against `origin/main`: support file equals lines 22-179 plus imports and four `export` keywords; reduced file equals lines 181-328 plus imports; binding file equals lines 330-500 plus imports. Only commit `59d4e2ba` touches the three files, and it precedes all #844 code commits. |
| AC-11 | PASS | `evidence/baseline/authority-service-test-count.2026-10-09T03-04.md` records 28. Reviewer focused runs: 11 + 17 = 28, all passed. |
| AC-12 | PASS | #645 `spec.md` AC-8 and `user-story.md` US-1 each name `orchestration-handoff-failure-cause.test.ts` and `orchestration-handoff-failure-cause-authority.test.ts`; both retain `[x]`. |
| AC-13 | PASS | Reviewer `wc -l`: 494, 390, 155, 138 (production); 469, 193, 179, 179, 170, 154 (test). All at or below 500. |
| AC-14 | PASS | `evidence/qa-gates/ts-prettier.2026-10-09T03-43.md` (full glob, exit 0). Reviewer Prettier check on the 10 changed files exited 0. |
| AC-15 | PASS | Reviewer `npm --prefix extensions/drm-copilot run lint` exited 0 with no output. |
| AC-16 | PASS | Reviewer `npm --prefix extensions/drm-copilot run typecheck` exited 0 (both `tsc -p ./` and `typecheck:test`). |
| AC-17 | PASS | `evidence/qa-gates/ts-jest-coverage.2026-10-09T03-47.md`: 256 suites, 3917 tests passed. Reviewer read of `coverage/lcov.info`: authority-service 98.97%/91.55%, materializer 98.99%/97.73%, materializer-production 100%/100%, materializer-request 100%/100%. Zero-hit DA lines in these modules (authority 59, 60, 79, 80; materializer 216-220) are not changed lines. `evidence/qa-gates/coverage-delta.2026-10-09T03-58.md`: 58/58 added lines covered. |
| AC-18 | PARTIAL (pending-PR) | Branch-diff half: reviewer `git diff --stat origin/main...HEAD` over `subagent-tree-command.test.ts`, `orchestration-handoff-contract.ts`, `CHANGELOG.md`, `extensions/drm-copilot/CHANGELOG.md`, `config/`, `extensions/drm-copilot/resources`, `mcp-repo-automation-tool-definitions-handoff.ts`, `tests/fixtures`, `extensions/drm-copilot/test/fixtures` is empty; consistent with `evidence/qa-gates/ac18-scope.2026-10-09T03-55.md`. PR-body half cannot be evaluated because the PR does not exist yet. This is a sequencing dependency, not a code defect, and is classified Non-blocking. |

## Findings

| ID | Severity | Finding |
| --- | --- | --- |
| FA-1 | Non-blocking | AC-18 PR-body half pending PR creation; orchestrator checks AC-18 after PR authoring (plan task P7-T18). |
| FA-2 | Non-blocking | Evidence filename timestamps were composed rather than read from the host clock (37 of 39 files later than their commit time). Gate results were re-verified by this reviewer, so no verdict depends on them. |
| FA-3 | Non-blocking | PR-context artifacts are absent; the review used the direct branch diff. Refresh before PR authoring. |

Total blocking count: **0**.

## Summary

17 of 18 acceptance criteria are PASS and verified against the diff, reviewer-run commands, and evidence artifacts. AC-18 is PARTIAL only because its PR-body clause depends on a pull request that does not exist yet; its branch-diff clause passes. No criterion is FAIL. No remediation is required. The branch is ready for PR authoring, after which AC-18 should be re-evaluated and checked.

## Acceptance Criteria Check-off

- AC-1 through AC-17 were evaluated PASS and are already `[x]` in `spec.md` (checked by commit `b27a9f8c`). This review confirmed each against evidence and made no further change to `spec.md`.
- AC-18 is left `[ ]` (pending-PR). It must not be checked until `gh pr view --json body` shows a closing keyword for #844 and a non-closing reference to #846.
- Newly checked off by this review: none.

### Acceptance Criteria Status
- Source: docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/spec.md
- Total AC items: 18
- Checked off (delivered): 17
- Remaining (unchecked): 1
- Items remaining: AC-18 (branch diff contains no change to the excluded files, and the PR body closes #844 and references #846 without a closing keyword) - pending PR creation; branch-diff half verified.
