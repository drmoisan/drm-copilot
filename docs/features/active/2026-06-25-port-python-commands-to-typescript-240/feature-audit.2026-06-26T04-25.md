# Feature Audit: F7 ts-potential-to-issue (Issue #240)

**Audit Date:** 2026-06-26

## Scope and Baseline

- Base branch: `main`.
- Merge-base SHA: `cfba7414203f8abff8be3a038e8df32f1f95d73e`.
- Head SHA: `f45cb5ea67e9fb677ed2c9c9e247ebafb3f73997`.
- Work mode: `full-feature` (from `issue.md` marker `- Work Mode: full-feature`).
- AC sources (full-feature): `spec.md` and `user-story.md`. The epic-level AC in `spec.md` (`AC-E1..AC-E5`) is satisfied incrementally across features F1–F11 and is not closed by F7 alone. The F7-scoped acceptance criteria are the `## F7 Acceptance Criteria Checklist` (`AC-F7-1..AC-F7-10`) in `plans/F7-potential-to-issue.plan.md`, which is the authoritative F7 delivery checklist and the subject of this audit.
- Scope is the full branch diff (TypeScript only): 5 new production files + 1 modified service file under `extensions/drm-copilot/src/lib/potential-to-issue/**` and `repo-automation-service.ts`, plus test and evidence files.

## Acceptance Criteria Inventory

F7-scoped (plan checklist):

- AC-F7-1: `content.ts` ports `potential_to_issue_content.py` (regexes, headings, smart-punctuation replace-all, body builders, metadata update, issue-reference parsing, deterministic `extractLastUpdated`).
- AC-F7-2: `gh-client.ts` ports the gh client (byte-identical arg vectors, missing-`gh` message, `allowError: true`, no real gh in tests).
- AC-F7-3: `promotion.ts` ports the workflow (error messages, emitted lines, body routing, missing-label recovery, metadata update + move, exit-code semantics; reuses F1 contract helpers).
- AC-F7-4: port-local `PotentialFileSystem` seam + injected `CommandRunner`; no direct `node:child_process`/`node:fs` outside injectable defaults; F1 shared interfaces unmodified.
- AC-F7-5: `potentialToIssue` calls the in-process helper instead of Python, preserving inputs and return contract; wiring extracted so `repo-automation-service.ts` stays <= 500 lines.
- AC-F7-6: new tests mirror every Python behavioral scenario; hermetic.
- AC-F7-7: extension tests inverted from Python-spawn to in-process; missing-python case inverted to success; tool name/handler/input schema unchanged.
- AC-F7-8: no file > 500 lines; ES modules; no `any`; kebab-case; AAA tests.
- AC-F7-9: format/lint/typecheck/coverage pass; new files >= 85% line / >= 75% branch; no `src/lib/**` regression.
- AC-F7-10: Python sources, `command-runtime.ts`, `executeScript`, `"python"` branch unmodified (removal is F11); scope containment evidenced.

Epic-level (`spec.md`, not closed by F7 alone): AC-E1, AC-E2, AC-E3, AC-E4, AC-E5.

## Acceptance Criteria Evaluation

| Criterion | Verdict | Evidence |
|-----------|---------|----------|
| AC-F7-1 | PASS | `content.ts` reviewed against `potential_to_issue_content.py`; coverage 99.16% line / 88.70% branch; `content.test.ts` covers all helpers. |
| AC-F7-2 | PASS | `gh-client.ts:281-329` arg vectors match Python `_run` builders; `GH_NOT_FOUND_MESSAGE` byte-identical; `allowError: true` via `CommandRunnerGhAdapter`; `gh-client.test.ts` uses a fake runner. Coverage 100% line / 79.31% branch. |
| AC-F7-3 | PASS | `promotion.ts:283-435` reproduces Python `promote_potential:210-372` step-for-step; missing-label recovery `promotion.ts:363-375` matches Python `:326-332`; reuses `normalizeRequestedWorkMode`/`ACCEPTED_WORK_MODES`. Coverage 98.85% / 81.96%. |
| AC-F7-4 | PASS | `PotentialFileSystem` is port-local in `promotion-filesystem.ts`; `node:child_process` confined to `SpawnSyncGhCommandRunner`/`defaultGhPathLookup`; `node:fs` confined to `RealPotentialFileSystem`. `git diff` shows F1 `file-system.ts`/`subprocess-runner.ts`/`prompt-mode-contract.ts` untouched. |
| AC-F7-5 | PASS | `repo-automation-service.ts` diff is a single delegation to `potentialToIssueServiceCall`; byte-identical `summary` preserved (`potential-to-issue-service-call.ts:178`); file is 496 lines (was 500). |
| AC-F7-6 | PASS | 6 new test files mirror `test_potential_to_issue*.py`; hermetic fakes in `promotion-test-support.ts`; 908/908 tests pass. |
| AC-F7-7 | PASS | `extension.potential-to-issue.test.ts` uses `expectNoPythonSpawn()`; the missing-python case is inverted to success; tool name/handler/input resolution unchanged (no diff to `mcp-handlers`/`mcp-tool-inputs.ts`). |
| AC-F7-8 | PASS | Max file 498 lines (`extension.potential-to-issue.test.ts`); content.ts 481; no `any` (grep); kebab-case filenames; AAA tests. |
| AC-F7-9 | PASS | Reviewer re-ran format (clean) / lint (0) / typecheck (0) / coverage. Every new file meets thresholds; `src/lib/**` 97.52% line / 90.66% branch, no regression. `evidence/qa-gates/f7-coverage-delta.md`. |
| AC-F7-10 | PASS | `git diff --name-status` shows no Python, `command-runtime.ts`, `executeScript`, or `"python"`-branch change; `evidence/qa-gates/f7-scope-verification.md`. |
| AC-E1 (epic) | PARTIAL (out of F7 closure) | F7 ports one command (`potential_to_issue`); other commands ship in other features. Not closed by F7. |
| AC-E2 (epic) | PASS for F7 modules | F7 modules meet coverage policy; epic rollup closes when all features land. |
| AC-E3 (epic) | PARTIAL (out of F7 closure) | `potentialToIssue` now in-process; remaining `runtimeKind: "python"` call sites (e.g. `collectPrContext`) are other features. |
| AC-E4 (epic) | PARTIAL (out of F7 closure) | The `python` runtime dependency is removed only for this command; full removal is F11. |
| AC-E5 (epic) | UNVERIFIED | CI gate status on a PR is outside this local review; no PR exists yet for the branch (per `pr_context.summary.txt`). Local toolchain passes. |

## Summary

All ten F7-scoped acceptance criteria (`AC-F7-1..AC-F7-10`) evaluate to PASS with concrete evidence. The epic-level criteria (`AC-E1..AC-E5`) are intentionally not closed by F7 alone; they remain open at the epic level and are tracked across the full feature set. No F7 criterion is FAIL or PARTIAL. No remediation is required.

Go/no-go: **GO** for F7 PR readiness, subject to the standard CI green gate (AC-E5) when the PR is opened.

### Acceptance Criteria Status
- Source: `plans/F7-potential-to-issue.plan.md` (F7 checklist); `spec.md` (epic AC, not F7-closing)
- Total AC items (F7-scoped): 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All F7 plan-checklist criteria (`AC-F7-1` through `AC-F7-10`) are already marked `[x]` in `plans/F7-potential-to-issue.plan.md` and are confirmed PASS by this audit; no check-off change was required. The epic-level `AC-E1..AC-E5` in `spec.md` remain `[ ]` because F7 does not close them at the epic level; they are intentionally left unchecked.
