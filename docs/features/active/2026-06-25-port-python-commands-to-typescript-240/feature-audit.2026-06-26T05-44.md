# Feature Audit: F8 ts-new-active-feature-folder (Issue #240) — R4 Re-Audit

**Audit Date:** 2026-06-26T05-44
**Audit Cycle:** R4 (post-remediation re-audit)
**Reviewer:** feature-review agent

## Scope and Baseline

- **Resolved base branch:** `main`
- **Merge-base SHA:** `c432b69a294ef17ace8b64964b6b0cafb22bd450` (2026-06-26 04:43:02 -0400)
- **Branch head:** `6afaf7ec243d942d45ee3aadbfed39af8c2a2ce5` (`feat/ts-port-new-active-feature-folder-240`)
- **Work mode:** `full-feature` (persisted marker in `issue.md`).
- **AC sources (by work mode):** `full-feature` resolves to `spec.md` and `user-story.md`.
  - `spec.md` carries the **epic** acceptance criteria (AC-E1..E5) and the F1 feature ACs. The epic ACs are satisfied incrementally across features and fully realized at F11.
  - `user-story.md` **does not exist** in this feature folder (verified by `ls`). The epic-level user story is embedded in `spec.md` under `## User Story`. The per-feature F8 acceptance criteria are authored in the plan checklist `plans/F8-new-active-feature-folder.plan.md` `## F8 Acceptance Criteria Checklist` (AC-F8-1..12), consistent with the spec.md note: "Per-feature acceptance criteria are tracked in each feature's plan checklist under `plans/F#-*.plan.md`." This audit evaluates the F8 per-feature ACs as the authoritative feature-scoped criteria and the epic ACs for incremental-contribution status.
- **Scope determination:** full branch diff vs `main` (`git diff --name-status c432b69...HEAD`), authoritative over the PR-context summary which misclassifies TS files as tooling.
- **Prior-cycle finding:** R3 (`2026-06-26T05-25`) found 1 Blocking — `io.ts` = 542 lines. R4 verifies resolution.

### Changed files in scope (vs merge-base)

Production TS (new): `src/lib/new-active-feature-folder/{models,markdown,io,io-launcher,docs,flow,index,new-active-feature-folder-service-call}.ts`.
Production TS (modified): `src/repo-automation-service.ts`.
Tests (new): `test/extension.new-active-feature-folder-inprocess.test.ts`, `test/lib/new-active-feature-folder/{docs,flow,io,markdown,models,new-active-feature-folder-service-call}.test.ts`, `test/lib/new-active-feature-folder/fakes.ts`, `test/new-active-feature-folder-fs-harness.ts`.
Tests (modified): `test/extension.new-active-feature-folder.test.ts`, `test/extension.workflow-commands.test.ts`.
Docs/evidence: the F8 plan and `evidence/**` artifacts; R3 review artifacts.

## Acceptance Criteria Inventory

### Epic ACs (`spec.md`) — incremental contribution by F8

| ID | Criterion (abbreviated) | F8 contribution |
|----|-------------------------|-----------------|
| AC-E1 | Every Python command script has a TS equivalent with behavior parity | F8 adds the `new_active_feature_folder` cluster port |
| AC-E2 | TS coverage meets policy (line >= 85%, branch >= 75%) | F8 cluster meets thresholds |
| AC-E3 | `RepoAutomationService` invokes in-process TS; `"python"` branch + bundled resources removed (F11) | F8 wires `newActiveFeatureFolder` in-process; removal deferred to F11 |
| AC-E4 | No remaining `python` runtime dependency for command execution | F8 removes it for this one command |
| AC-E5 | All CI gates pass per feature PR | F8 toolchain green |

### F8 per-feature ACs (`plans/F8-new-active-feature-folder.plan.md`)

AC-F8-1 through AC-F8-12 (see plan `## F8 Acceptance Criteria Checklist`).

## Acceptance Criteria Evaluation

### Epic ACs (incremental)

| ID | Verdict | Evidence |
|----|---------|----------|
| AC-E1 | PASS (incremental) | The `new_active_feature_folder` cluster is ported with byte-identical regexes, messages, `gh --json` field list, and control flow; parity mapped in `evidence/regression-testing/f8-port-parity.md`. |
| AC-E2 | PASS (incremental) | Cluster coverage 97.36–100% line / 83.33–100% branch (reviewer re-run). |
| AC-E3 | PARTIAL (by design) | F8 wires `newActiveFeatureFolder` in-process; the `"python"` branch and bundled-resource removal are explicitly deferred to F11 per spec.md AC-E3 and the F8 scope constraints. Not an F8 defect. |
| AC-E4 | PASS (incremental) | The `new_active_feature_folder` command no longer spawns Python; the extension test that required a Python runtime is inverted to assert success without Python. Full epic-wide realization at F11. |
| AC-E5 | PASS | Format, lint, typecheck, and 999/999 tests pass (reviewer-independent). |

### F8 per-feature ACs

| ID | Verdict | Evidence |
|----|---------|----------|
| AC-F8-1 (`models.ts` port) | PASS | `models.ts` (379 lines) ports constants/types/`FolderFileSystem`+`RealFolderFileSystem`/helpers; `models.test.ts` covers copyTree/listFiles/move ordering, `getEstTimestamp`, `extractDateFromTimestamp`, `validateFeatureName`. Coverage 97.36/83.33. |
| AC-F8-2 (`markdown.ts` port) | PASS | `markdown.ts` (437 lines) ports the helpers with function-form replacements; backslash-preservation regressions covered in `markdown.test.ts`. Coverage 100/93.1. |
| AC-F8-3 (`io.ts` port) | PASS | `io.ts` (386 lines) ports `findPotentialFile`/`parseIssueNumber`/`buildFolderSlug`/`copyTemplate` (bug-break)/`copyFeatureTemplateForMinorAudit`/`materializePlanFile`/`defaultIssueFetcher` (verified arg vector `gh issue view <n> --json number,title,url,author,updatedAt`, `allowError: true`, null-on-error). The launcher seam is now in `io-launcher.ts` (188 lines) and re-exported from `io.ts`. Coverage `io.ts` 99.48/91.04, `io-launcher.ts` 97.87/84.61. |
| AC-F8-4 (`docs.ts` port) | PASS | `docs.ts` (350 lines) ports per-type section mappings, bug concatenation, `Test Strategy` seeding, `files_to_open` ordering, `shouldUseMinorAuditMode`; `docs.test.ts` covers each type. Coverage 100/100. |
| AC-F8-5 (`flow.ts` + `index.ts`) | PASS | `flow.ts` (438 lines) ports `createActiveFolder` control flow, error messages, emits, minor-audit vs full routing; `index.ts` (50 lines) re-exports the public surface (no CLI `main`/`parseArgs`). Coverage `flow.ts` 99.54/92.1. |
| AC-F8-6 (seams, no shared-interface widening) | PASS | Port-local `FolderFileSystem`; injected F1 `CommandRunner`; injectable `gh`/env/which lookups; injectable `nowProvider`; no direct `node:child_process`/`node:fs`/`Date.now()` outside injectable defaults; F1 shared interfaces unmodified (confirmed by `git diff` filter). |
| AC-F8-7 (service wiring, <= 500 lines) | PASS | `repo-automation-service.ts` (499 lines) delegates to `newActiveFeatureFolderServiceCall`; `--template-root` forwarded via `this.templateRoot`; return contract preserved; wiring extracted to the service-call helper (134 lines). |
| AC-F8-8 (test mirroring + hermetic) | PASS | Cluster tests mirror the Python scenarios (including markdown-escape and models-coverage edge cases) using `@jest/globals` and `Map`-backed fakes; no real `gh`/`git`/`code`/temp files. |
| AC-F8-9 (extension tests updated) | PASS | Python-spawn assertions reworked to the in-process expectation; the missing-python case inverted; tool name, MCP handler, and input schema unchanged. 999/999 pass. |
| AC-F8-10 (no file > 500 lines; ESM; no `any`; kebab-case; AAA) | PASS | Reviewer `wc -l`: all F8-scope files <= 500 (`io.ts` 386, `io-launcher.ts` 188, `repo-automation-service.ts` 499, all tests <= 447). ES modules, no `any`, kebab-case, AAA confirmed. (Pre-existing `test/extension.workflow-commands.test.ts` at 775 is out of F8 scope — was 790 at merge-base, reduced by F8.) |
| AC-F8-11 (toolchain + coverage) | PASS | Format/lint/typecheck/coverage-test all pass; every new executable file line >= 85% / branch >= 75%; no regression on `src/lib/**` (97.52/90.7 vs 97.36/87.55). `evidence/qa-gates/f8-coverage-delta.md`. |
| AC-F8-12 (Python/runtime untouched; scope contained) | PASS | `command-runtime.ts`, `executeScript`, the `"python"` branch, `repo-automation-args.ts`, `repo-automation-service-workflows.ts` body, and the Python sources are unmodified (confirmed by `git diff --name-only` filter — no matches); `validate_evidence_locations.py` exit 0. |

## Summary

The prior R3 Blocking finding (`io.ts` = 542 lines) is **resolved**: the launcher seam is extracted into `io-launcher.ts` (188 lines), `io.ts` is 386 lines, and all F8-scope files are under the 500-line limit. All 12 F8 per-feature ACs are PASS. The epic ACs are satisfied incrementally; AC-E3 remains PARTIAL by design (the `"python"` branch and bundled-resource removal are deferred to F11, as the spec and plan explicitly scope). The toolchain is fully green (999/999 tests; format/lint/typecheck clean) and coverage meets policy with no regression.

**Blocking findings: 0.** Recommendation: **APPROVE for merge.**

### Acceptance Criteria Status
- Source: `spec.md` (epic ACs; user-story embedded), `plans/F8-new-active-feature-folder.plan.md` (F8 per-feature ACs). `user-story.md` not present (epic user story in `spec.md`).
- Total AC items: 5 epic + 12 F8 = 17
- Checked off (delivered): 12 F8 ACs (all `[x]` in the plan, re-verified this cycle); epic ACs remain epic-level tracking items, satisfied incrementally (4 PASS-incremental, 1 PARTIAL-by-design for F11).
- Remaining (unchecked): epic ACs AC-E1..E5 remain `[ ]` in `spec.md` by design (they are realized fully at F11, not at F8); no F8-blocking item remains.
- Items remaining: AC-E1..E5 (epic-level, intentionally not checked at F8 per spec.md).

## Acceptance Criteria Check-off

- F8 per-feature ACs (AC-F8-1..AC-F8-12) in `plans/F8-new-active-feature-folder.plan.md` are all evaluated PASS this cycle and remain checked `[x]` (already checked off by the executor; re-verified by the reviewer — no change needed).
- Epic ACs (AC-E1..AC-E5) in `spec.md` are intentionally left unchecked: per the spec.md note, they are realized incrementally and fully at F11, not at F8. The reviewer does not check epic ACs off for a single contributing feature.
- No newly checked-off items this cycle (all F8 ACs were already correctly checked and verified PASS).
