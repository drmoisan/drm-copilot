# Feature Audit: F9 ts-pr-context (Issue #240)

**Audit Date:** 2026-06-26T11-05
**Work mode:** `full-feature` (from `issue.md`)

## Scope and Baseline

- **Resolved base branch:** `main`
- **Merge-base SHA:** `331de4a9364ba0971b486566e1f2992e47eba5d8`
- **Branch head:** `15a35c786993d4fd1cf50e0d19661f1d861e85db` (`feat/ts-port-pr-context-240`)
- **Diff range:** `331de4a9364ba0971b486566e1f2992e47eba5d8..15a35c786993d4fd1cf50e0d19661f1d861e85db`
- **Baseline establishment:** Authoritative `git diff --name-status` against the merge-base. The PR-context summary artifact misclassifies the TS changes as tooling; the audit uses the git diff name-status directly (recorded in `policy-audit.2026-06-26T11-05.md` under Rejected Scope Narrowing).
- **AC sources:** `full-feature` resolves to `spec.md` and `user-story.md`. No standalone `user-story.md` exists; the epic embeds the User Story in `spec.md`. The authoritative per-feature acceptance criteria are the F9 AC checklist in `plans/F9-pr-context.plan.md` (the epic spec directs that per-feature ACs are tracked in each feature's plan checklist). This audit evaluates both the F9 per-feature ACs and the epic-level ACs (E1–E5).
- **Languages with changed files:** TypeScript only.

## Acceptance Criteria Inventory

### F9 per-feature acceptance criteria (`plans/F9-pr-context.plan.md`)

- AC-F9-1: All ten `pr_context/*.py` modules ported to `src/lib/pr-context/` with behavior parity.
- AC-F9-2: `github.py` split into core+details, `collector.py` into core+output; no `src/lib/pr-context/**` or `test/lib/pr-context/**` file exceeds 500 lines.
- AC-F9-3: `RepoAutomationService.collectPrContext()` invokes the in-process TS port via `pr-context-service-call.ts`; no `runtimeKind: "python"` / `collect_pr_context.py` spawn remains in that method; `repo-automation-service.ts` <= 500 lines.
- AC-F9-4: Return contract preserved — `collectAndWrite` writes both artifact files; service result returns `tool: "collect_pr_context"`, the exact summary string, and both normalized artifact paths.
- AC-F9-5: All ported Jest tests are hermetic (injected `FileSystem` + `CommandRunner`, no real git/gh, no temp files) and live under `test/lib/pr-context/`.
- AC-F9-6: New `src/lib/pr-context/**` files meet coverage policy: line >= 85%, branch >= 75%, no regression on changed lines.
- AC-F9-7: Format, lint, type-check, and test all pass from `extensions/drm-copilot/` in a single clean toolchain pass.
- AC-F9-8: F1 `file-system.ts` / `subprocess-runner.ts` reused (extended only additively); `command-runtime.ts`, the `"python"` branch, and all `scripts/dev_tools/**` / `resources/**/*.py` unmodified.
- AC-F9-9: Reworked `extension.collect-pr-context.test.ts` and any repo-automation pr-context test assert the in-process path with zero `collect_pr_context.py` spawn assertions.

### Epic acceptance criteria (`spec.md`)

- AC-E1: Every invoked Python command script has a TS equivalent with behavior parity. (Incremental; F9 delivers the pr_context cluster.)
- AC-E2: TS test coverage for ported modules meets policy (line >= 85%, branch >= 75%).
- AC-E3: `RepoAutomationService` methods invoke in-process TS; `"python"` branch and bundled Python removed (delivered by F11).
- AC-E4: No remaining runtime dependency on a `python` interpreter (fully realized at F11).
- AC-E5: All CI gates pass on each feature PR.

## Acceptance Criteria Evaluation

| Criterion | Verdict | Evidence |
|-----------|---------|----------|
| AC-F9-1 | PASS | 16 modules under `src/lib/pr-context/**` port the 10 Python `pr_context` modules; `git diff --name-status` lists all. Behavior-parity and error-string preservation exercised by 14 hermetic test suites (1226/1226 pass). |
| AC-F9-2 | PASS | `gh-client-core.ts` (437) + `gh-client-details.ts` (398); `collector-core.ts` (472) + `collector-output.ts` (449). Independent `wc -l`: max production file 481 (`render-pr-helpers.ts`), max test 436 (`gh-client-details.test.ts`); no file > 500. |
| AC-F9-3 | PASS | `repo-automation-service.ts:217-225` delegates to `collectPrContextServiceCall`; `grep 'runtimeKind: "python"\|collect_pr_context.py'` in that file returns none; file is 481 lines. |
| AC-F9-4 | PASS | `pr-context-service-call.ts` returns `tool: "collect_pr_context"`, summary `` `Collected PR context against base '${base}'.` ``, and both normalized artifact paths; `collectAndWrite` writes `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` via injected FS. Covered by `pr-context-service-call.test.ts` (100% coverage). |
| AC-F9-5 | PASS | All 14 pr-context tests import `@jest/globals`; `grep` for `child_process`/`spawnSync`/`os.tmpdir`/`node:fs`/`mkdtemp` in `test/lib/pr-context/` returns none; in-memory `tree-file-system.ts` and `jest.fn()` runner fakes used. All under `test/lib/pr-context/`. |
| AC-F9-6 | PASS | pr-context aggregate 93.86% line / 87.59% branch; every new file exceeds 85%/75% except the pure re-export barrel `index.ts` (exempt per `general-unit-test.md`). No regression on `src/lib` aggregate (93.79% line / 87.58% branch). |
| AC-F9-7 | PASS | Reviewer-independent: format clean, lint exit 0 / 0 errors, typecheck exit 0, 1226/1226 tests pass across 99 suites. |
| AC-F9-8 | PASS | `git diff --name-only` shows `command-runtime.ts`, `scripts/dev_tools/**`, and `resources/**/*.py` unchanged; `file-system.ts` modified additively (3 new methods, no signature change); `subprocess-runner.ts` unchanged. |
| AC-F9-9 | PASS | `extension.collect-pr-context.test.ts` reworked; `grep` confirms no `collect_pr_context.py` spawn assertions remain. Negative-evidence search recorded in `evidence/other/repo-automation-pr-context-test-search.md`. |
| AC-E1 | PARTIAL (by design) | F9 delivers the pr_context cluster with parity; the epic AC is realized incrementally across F1–F11. F9's contribution is complete. |
| AC-E2 | PASS | Coverage for the F9 ported modules meets policy (see AC-F9-6). |
| AC-E3 | PARTIAL (by design) | `collectPrContext()` now invokes in-process TS; removal of the `"python"` branch and bundled Python is explicitly deferred to F11 per `spec.md`. F9 retains Python sources intentionally. |
| AC-E4 | PARTIAL (by design) | Fully realized at F11; F9 removes the Python spawn for the pr_context path only. |
| AC-E5 | UNVERIFIED | CI status at HEAD is "(not available)" in the PR-context artifact and no PR exists yet for this branch. Local toolchain (format/lint/typecheck/tests) passes; CI gate verification requires a PR/run. Not a blocker for code-quality readiness but cannot be marked PASS without a green CI run. |

## Summary

All nine F9 per-feature acceptance criteria are PASS, verified by reviewer-independent toolchain runs, file-size checks, coverage inspection, and targeted greps. The epic-level ACs that depend on full Python removal (AC-E3, AC-E4) and full-cluster parity (AC-E1) are correctly PARTIAL by design — their completion is scheduled for F11 per `spec.md`. AC-E2 (coverage) PASS for the F9 modules. AC-E5 (CI gates) is UNVERIFIED because no PR/CI run exists yet for the branch head; the local toolchain is green.

No blocking gaps. The feature is ready for PR from an acceptance standpoint; the only open item (AC-E5 CI green run) is satisfied by opening the PR and confirming the CI gate, which is outside the local review surface.

## Acceptance Criteria Check-off

The F9 per-feature ACs in `plans/F9-pr-context.plan.md` are already checked `[x]` by the executor and are confirmed PASS by this audit; no change is required to that file.

The epic ACs in `spec.md` (AC-E1 through AC-E5) remain `[ ]` and are intentionally left unchecked: they are realized incrementally and fully at F11 (AC-E1/E3/E4), or require a PR/CI run (AC-E5). Per `acceptance-criteria-tracking`, PARTIAL/UNVERIFIED items are left unchecked. No epic AC is fully delivered by F9 alone, so no `spec.md` check-off is performed in this audit.

### Acceptance Criteria Status
- Source: `plans/F9-pr-context.plan.md` (per-feature, authoritative) and `spec.md` (epic)
- Total AC items: 9 (F9) + 5 (epic) = 14
- Checked off (delivered/PASS): 9 (all F9 ACs; already `[x]` in plan) + AC-E2 (PASS but tracked at epic level, left `[ ]` pending full-epic realization)
- Remaining (unchecked): AC-E1, AC-E3, AC-E4 (PARTIAL by design, complete at F11), AC-E5 (UNVERIFIED pending CI run)
- Items remaining: AC-E1 (incremental), AC-E3 (Python removal — F11), AC-E4 (no python dependency — F11), AC-E5 (all CI gates pass — requires PR/CI run)
