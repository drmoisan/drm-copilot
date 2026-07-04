# Feature Audit: F8 ts-new-active-feature-folder (Issue #240)

**Audit Date:** 2026-06-26
**Feature Folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-06-25-22-10`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (merge-base commit `c432b69a294ef17ace8b64964b6b0cafb22bd450`)
- **Head branch/commit:** `drm-copilot-wt-2026-06-25-22-10` (HEAD)
- **Merge base:** `c432b69a294ef17ace8b64964b6b0cafb22bd450`
- **Evidence sources:**
  - Primary: `git diff --name-status c432b69...HEAD` (authoritative scope; the PR-context summary misclassifies TS production files as tooling per agent memory, so it was not relied upon)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/**`
  - Reviewer-independent toolchain runs (format, lint, typecheck, coverage-enabled Jest, `wc -l`)
- **Feature folder used:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
- **Requirements source:** F8 plan AC checklist in `plans/F8-new-active-feature-folder.plan.md` (primary, per the caller's authoritative AC pointer); `spec.md` epic AC (AC-E1…AC-E5; satisfied incrementally, fully realized at F11).
- **Work mode resolution note:** `issue.md` records `- Work Mode: full-feature`. The `full-feature` AC sources are `spec.md` and `user-story.md`. `user-story.md` does not exist in this epic feature folder (the epic uses `initiative.md`); the epic-level user story is embedded in `spec.md`. The per-feature F8 AC is the checklist in the F8 plan file, which the caller designated as authoritative for F8. This audit evaluates the F8 plan AC (AC-F8-1…AC-F8-12) as the primary feature criteria and the epic AC in `spec.md` for incremental status.
- **Scope note:** Branch diff is TypeScript only (8 production .ts + 11 test .ts) plus docs/evidence/plan markdown. No Python/PowerShell/C# source changed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `plans/F8-new-active-feature-folder.plan.md` — primary (F8 per-feature AC checklist, AC-F8-1…AC-F8-12)
- `spec.md` — secondary (epic AC AC-E1…AC-E5; incremental)
- `user-story.md` — not present (epic folder uses `initiative.md`; epic user story embedded in `spec.md`)

### Acceptance criteria (F8 plan checklist)

1. AC-F8-1: `models.ts` ports `new_active_feature_folder_models.py` with byte-identical constants/types, the `FolderFileSystem` seam + `RealFolderFileSystem`, and `resolveWorkspace`/`getEstTimestamp`/`extractDateFromTimestamp`/`validateFeatureName`.
2. AC-F8-2: `markdown.ts` ports the markdown helpers with byte-identical regexes/formats, escape-safe `setSection`/`updateSectionBody`, and the full `setHeaderPlaceholder` chain.
3. AC-F8-3: `io.ts` ports the I/O helpers, guarded `defaultIssueFetcher`, and the injectable launcher seam (P2-T1 acceptance includes "file < 500 lines").
4. AC-F8-4: `docs.ts` ports per-type section mappings/ordering, bug concatenation, `Test Strategy` seeding, `files_to_open` ordering, and `shouldUseMinorAuditMode`.
5. AC-F8-5: `flow.ts` ports `create_active_folder` with byte-identical control flow/messages/emits and routing; `index.ts` re-exports the public surface.
6. AC-F8-6: Port-local `FolderFileSystem` seam (no F1 widening), injected `CommandRunner`/lookups/clock; no direct `child_process`/`fs`/`Date.now()` except injectable defaults; F1 interfaces unmodified.
7. AC-F8-7: `newActiveFeatureFolder` calls the in-process helper instead of spawning Python, preserving inputs and return contract, with wiring extracted so `repo-automation-service.ts` stays <= 500 lines.
8. AC-F8-8: New tests mirror every Python behavioral scenario using Jest with in-memory fakes; hermetic.
9. AC-F8-9: Extension tests asserting a Python spawn updated to in-process; missing-python case inverted; tool name/handler/input schema unchanged.
10. AC-F8-10: No file exceeds 500 lines (including `repo-automation-service.ts`, `extension.new-active-feature-folder.test.ts`, and all new files); ES modules; no `any`; kebab-case; AAA.
11. AC-F8-11: Format/lint/typecheck/coverage-enabled test all pass; every new executable file meets line >= 85% / branch >= 75% with no `src/lib/**` regression.
12. AC-F8-12: Python sources, `command-runtime.ts`, `executeScript`, the `"python"` branch, the `buildNewActiveFeatureFolderOptions` body, and `repo-automation-args.ts` are unmodified (removal is F11); scope containment evidenced.

### From spec.md (epic AC — incremental)

- AC-E1: Every Python command script has a TS equivalent with parity. (Partial across epic; F8 delivers the `new_active_feature_folder` cluster.)
- AC-E2: TS coverage for ported modules meets policy (line >= 85%, branch >= 75%).
- AC-E3: Service methods invoke in-process TS; `"python"` branch and bundled Python removed (removal delivered by F11).
- AC-E4: No remaining runtime dependency on `python` for command execution (fully at F11).
- AC-E5: All CI gates pass on each feature PR.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-F8-1 | models.ts port | PASS | `models.ts` (379 lines) exports the constants/types, `FolderFileSystem`+`RealFolderFileSystem`, and the four helpers; tests assert `copyTree`/`listFiles`/`move` order, `getEstTimestamp` = `2024-02-03T04-05`, byte-identical `validateFeatureName` message. | `node run-jest.cjs --coverage` | models.ts 97.36% line / 83.33% branch. |
| AC-F8-2 | markdown.ts port | PASS | `markdown.ts` (437 lines); escape-safe `setSection`/`updateSectionBody` (function-form callbacks); full `setHeaderPlaceholder`. Backslash regressions covered. | `node run-jest.cjs --coverage` | markdown.ts 100% line / 93.1% branch. |
| AC-F8-3 | io.ts port | PARTIAL | Functional port is correct and fully covered (`io.ts` 98.89% line / 88.88% branch; `findPotentialFile`/`buildFolderSlug`/`copyTemplate` bug-break/`defaultIssueFetcher`/launcher all tested). However, P2-T1 acceptance explicitly requires "file < 500 lines"; `io.ts` is 542 lines. | `wc -l .../io.ts` → 542; `node run-jest.cjs --coverage` | Size constraint within this AC is unmet; see AC-F8-10. |
| AC-F8-4 | docs.ts port | PASS | `docs.ts` (350 lines) 100% line / 100% branch; per-type sections, bug concatenation, `Test Strategy` seeding, `files_to_open` ordering, `shouldUseMinorAuditMode` covered. | `node run-jest.cjs --coverage` | |
| AC-F8-5 | flow.ts + index.ts | PASS | `flow.ts` (438 lines) 99.54% line / 92.1% branch; control-flow, error messages, emits, routing covered. `index.ts` re-exports the public surface (no CLI entrypoint). | `node run-jest.cjs --coverage` | |
| AC-F8-6 | seam/injection; F1 unmodified | PASS | Port-local `FolderFileSystem` in `models.ts`; injected runner/lookups/clock; no executable `Date.now()`/`child_process`/`fs` outside injectable defaults (grep). `git diff` shows `file-system.ts`/`subprocess-runner.ts`/`prompt-mode-contract.ts` unchanged. | `git diff --name-status`; grep | |
| AC-F8-7 | in-process service wiring; <= 500 lines | PASS | `repo-automation-service.ts:350` delegates to `newActiveFeatureFolderServiceCall`; file = 499 lines; helper preserves the summary and return contract. | `git diff`; `wc -l` (499) | |
| AC-F8-8 | hermetic Jest scenario parity | PASS | Cluster test files mirror the Python suites with `Map`-backed fakes and injected seams; 999/999 pass. | `node run-jest.cjs` | |
| AC-F8-9 | extension tests inverted/in-process | PASS | `extension.new-active-feature-folder-inprocess.test.ts` (218 lines) + updated `extension.new-active-feature-folder.test.ts`; tool name/handler/input-schema tests unchanged and passing. | `node run-jest.cjs` | |
| AC-F8-10 | no file > 500 lines; ES modules; no any; kebab; AAA | FAIL | `io.ts` = **542 lines** > 500 hard limit. All other files within limit (service 499, flow 438, markdown 437, models 379, docs 350, service-call 134, index 50; test files all < 500). ES modules, no `any`, kebab-case, AAA otherwise satisfied. | `wc -l` | Blocking; plan-mandated `io-launcher.ts` split not performed. |
| AC-F8-11 | toolchain + coverage thresholds | PASS | Format clean; lint 0; typecheck 0; 999/999 tests; new executable files line 97.36%–100%, branch 83.33%–100%; `src/lib/**` 97.73%/88.29% (no regression). | `npx prettier --check`; `npm run lint`; `npm run typecheck`; `node run-jest.cjs --coverage` | Toolchain gates are green; this AC concerns gates, not file size. |
| AC-F8-12 | scope containment; prohibited paths unmodified | PASS | `git diff --name-status` shows only the allowed cluster files, the service delegation, tests, and evidence; no Python source, `command-runtime.ts`, `executeScript`, `"python"` branch, `repo-automation-args.ts`, or F1 interfaces changed. | `git diff --name-status c432b69...HEAD` | |
| AC-E1 (epic) | per-script TS parity | PARTIAL | F8 delivers the `new_active_feature_folder` cluster; epic completes incrementally. | — | Incremental; not an F8 gate. |
| AC-E2 (epic) | ported-module coverage policy | PASS | F8 cluster meets line >= 85% / branch >= 75%. | `node run-jest.cjs --coverage` | |
| AC-E3 (epic) | in-process; Python removal | PARTIAL | F8 wires `newActiveFeatureFolder` in-process; bundled-Python removal and `"python"`-branch removal are explicitly F11. | — | By design; F11 scope. |
| AC-E4 (epic) | no python runtime dependency | PARTIAL | F8 removes the dependency for this one command (inverted missing-python test passes); full removal at F11. | `node run-jest.cjs` | |
| AC-E5 (epic) | CI gates pass on PR | UNVERIFIED | Local toolchain is green; the CI/PR-context green run is the orchestrator's S9 gate, not verified by this local review. | — | No workflow files changed; `modified-workflow-needs-green-run` does not fire. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary (F8 plan AC, AC-F8-1…12):**
- **PASS:** 10 criteria (AC-F8-1, -2, -4, -5, -6, -7, -8, -9, -11, -12)
- **PARTIAL:** 1 criterion (AC-F8-3 — functional port complete and covered, but the in-criterion file-size acceptance is unmet because `io.ts` = 542 lines)
- **UNVERIFIED:** 0 (F8 plan AC)
- **FAIL:** 1 criterion (AC-F8-10 — `io.ts` exceeds the 500-line limit)

(Epic AC: AC-E2 PASS; AC-E1/E3/E4 PARTIAL by design; AC-E5 UNVERIFIED — CI is the orchestrator gate.)

**Top gaps preventing PASS:**

1. `io.ts` = 542 lines violates the 500-line hard limit (AC-F8-10 FAIL; AC-F8-3 PARTIAL). The plan-mandated `io-launcher.ts` split was not performed.

**Recommended follow-up verification steps:**

1. Extract the VS Code launcher seam from `io.ts` into `io-launcher.ts`, re-export from `io.ts`, and confirm both files < 500 lines via `wc -l`.
2. Re-run `npx prettier --check` → `npm run lint` → `npm run typecheck` → `node run-jest.cjs --coverage` and confirm 999/999 still pass with thresholds met; then re-check off AC-F8-3 and AC-F8-10.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if represented as markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All twelve F8 plan AC checkboxes were already marked `[x]` by the executor at plan-completion time. This audit found AC-F8-10 to be **FAIL** and AC-F8-3 to be **PARTIAL** (the `io.ts` 542-line violation). Because the reviewer must not weaken a passing record into an incorrect state by editing executor check-offs without authority, and because policy forbids checking off non-PASS items, the reviewer records here that **AC-F8-10 and AC-F8-3 should be reverted to `[ ]` during remediation**; the remaining ten F8 AC remain validly checked. No source-file checkbox was newly checked by this review (all PASS items were already checked); the two non-PASS items are flagged for un-check during remediation and are routed through `remediation-inputs.2026-06-26T05-25.md`.

### AC Status Summary

- Source: `plans/F8-new-active-feature-folder.plan.md` (primary); `spec.md` (epic, incremental)
- Total AC items (F8 plan): 12
- Checked off (delivered, validated PASS by this review): 10
- Remaining (should be unchecked pending remediation): 2 (AC-F8-3 PARTIAL, AC-F8-10 FAIL)
- Items remaining: AC-F8-3 (io.ts size acceptance), AC-F8-10 (no file > 500 lines)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `plans/F8-new-active-feature-folder.plan.md` | 12 | 10 | 2 (flagged for un-check) | Checkbox-backed; AC-F8-3 PARTIAL, AC-F8-10 FAIL due to `io.ts` = 542 lines. |
| `spec.md` (epic AC) | 5 | 0 newly checked | 5 | Epic-level, incremental; not F8-gating. Left as-is. |
| `user-story.md` | n/a | n/a | n/a | Not present (epic uses `initiative.md`). |
