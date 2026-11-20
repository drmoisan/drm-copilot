# Feature Audit: migrate_development_docs tool and the .dev move (#1016)

**Audit Date:** 2026-11-20
**Feature Folder:** `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/dev-docs-root-migration-phases-2-3-1016`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (commit `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3`)
- **Head branch/commit:** `feature/dev-docs-root-migration-phases-2-3-1016` (commit `f744ce9e060a98dec1be9d393bba5c644e81ed61`)
- **Merge base:** `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-20 18:18 UTC for the head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/**`
  - Additional evidence: reviewer runs in `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md`; code reading of `migration-plan.ts` and `migration-apply.ts` at the head
- **Feature folder used:** `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`.
- **Scope note:** the audit covers the full branch diff (both stages). Executor-checked criteria were re-graded: the reviewer spot-checked the flip in three copies, the empty bundle `path_roots`, the epic manifest `feature_folder` values, the `.dev/active` names, both template link depths, the `docs/` listing, the fixture diff and the coverage figures directly; the remaining checked criteria were graded from the named evidence artifacts.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/spec.md` — primary (`## Acceptance Criteria`, 44 items)
- `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/user-story.md` — secondary (23 items)

### Acceptance criteria

The criteria are the checkbox items of the two files, transcribed as abbreviated labels in the evaluation table below (S-A1 to S-A20 stage A, S-O1 owner stop, S-B1 to S-B17 stage B, S-E1 to S-E6 epic; U-a1 to U-d9 user story by scenario).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S-A1 | `layout-map.test.ts` asserts mapping rows, ordering, OQ-1 input, unmapped | PASS | suite in root Jest run | `node run-jest.cjs --coverage` | 6717 passed |
| S-A2 | `folder-rename-plan.test.ts` rules 1 to 8 with F-1 to F-6, N-3 to N-5 | PASS | suite in root run | same | |
| S-A3 | `reference-rewrite.test.ts` order, boundary, protected literal, links at depths 3 to 5, idempotent own output | PASS | suite in root run | same | |
| S-A4 | `migration-git.test.ts` argv, `-z`, `maxBuffer`; `subprocess-runner.test.ts` forwards `maxBuffer` | PASS | suites in root run; argv read in `migration-git.ts` | same | |
| S-A5 | `migration-decisions.test.ts` schema, digest, refusals | PASS | suite in root run | same | |
| S-A6 | `migration-plan.test.ts` every refusal rule, merge planning, exclusions, three scopes, dry-run defaults | PASS | suite in root run | same | scopes tested on pre-move trees only (see F1) |
| S-A7 | `migration-apply.test.ts` in-memory apply, empty second plan, moves-then-rewrites | PASS | suite in root run | same | criterion as written is met; its fixture does not reach F1 |
| S-A8 | `migration-report.test.ts` every report category, `decision_skeleton` nulls | PASS | suite in root run | same | |
| S-A9 | service call, inputs, handler, CLI suites; exit codes 0, 1, 2; `main()` stdio fallback | PASS | suites in root run | same | |
| S-A10 | No temp file or real git in the new suites | PASS | `migration-test-fakes.ts` read | code read | |
| S-A11 | `mcp-server.test.ts` lists the tool; definitions test passes | PASS | root run | same | |
| S-A12 | optional `migrateDevelopmentDocs`; type check passes with fakes unchanged | PASS | contract diff; `ts-static.2026-11-20T18-10.md` | `git diff` of the contract | |
| S-A13 | packaging tests pass with `bin` and `files` unchanged | PASS | root run; `packages/mcp-server/package.json` not in diff | `git diff --stat` | |
| S-A14 | no `vscode` import, asserted by a test | PASS | `development-docs-migration-coverage-contracts.test.ts` and suites | root run | |
| S-A15 | `coverageThreshold` 85/75 per new file; evidence meets it | PASS | `jest.development-docs-migration-coverage.json`; per-file figures 100% lines, branches 85.71% or higher | coverage summary parse | |
| S-A16 | READMEs document inputs, `npx`, decision-file requirement | PASS | executor task check; README diff | `git diff` | |
| S-A17 | branch-build dry run writes md and json with digest and skeleton; no other change | PASS | `dev-docs-migration-dry-run.2026-11-20T07-40.*`, `dev-docs-migration-dry-run-command.2026-11-20T07-41.md` | artifact read | |
| S-A18 | stage A adds no Python file, hook or bash script | PASS | `language-scope.2026-11-20T07-49.md` | name-status diff | |
| S-A19 | seven-stage toolchain passes for changed TypeScript; no file above 800 | UNVERIFIED | stages 1 to 6 clean; stage 7 runs in CI | pending CI | pending-CI criterion, checked off at S9 |
| S-A20 | Phase 0 artifact records merges and re-checks | PASS | `evidence/baseline/execution-preconditions.2026-11-20T06-50.md`, `tree-recheck.*` | artifact read | |
| S-O1 | decision file exists, follows schema, names report, digest, all held items, global answers | PASS | `folder-rename-decisions.2026-11-20T12-24.json`; `decision-file-check.2026-11-20T08-00.md` | artifact read | |
| S-B1 | stage B Phase 0 gate artifact, fresh digest equal | PASS | `stage-b-gate.2026-11-20T07-58.md`, `digest-comparison.2026-11-20T12-28.md` | artifact read | |
| S-B2 | `.dev/` layout, `docs/README.md` only, `git mv` renames | PASS | `git ls-files docs` lists only `docs/README.md`; 35183 renames; `layout-check.2026-11-20T16-07.md` | `git ls-files docs` | |
| S-B3 | renamed folders match rule or decision; comparison stored | PASS | `layout-check.2026-11-20T16-07.md` (0 mismatches); 95 of 95 `.dev/active` folders issue-first | `ls .dev/active` | |
| S-B4 | second dry run reports an empty plan (no moves, renames or rewrites) | PARTIAL | `post-apply-dry-run-check.2026-11-20T16-11.md`: 0 moves, 0 renames, but 4572 files listed as outside-tree rewrite candidates | code read of `scanRewrites` | F1 |
| S-B5 | `development_docs_root` is `.dev` in three copies; parity test passes | PASS | reviewer grep of three copies; pytest run | `grep development_docs_root` | |
| S-B6 | self-hosted `path_roots` has `.dev`; bundle empty; tests pass | PASS | `config/blast-radius.json` diff; bundle `"path_roots": []` | `git diff`, grep | |
| S-B7 | both template copies link at the right depth; link check clean | PASS | both copies use `../../../.github/instructions/`; `template-link-check.2026-11-20T15-10.md` | grep | |
| S-B8 | epic manifest `feature_folder` for child 2 renamed; validation passes | PASS | `.dev/epics/shared-agent-harness-layer/epic.md` line 25; `epic-manifest-check.2026-11-20T15-11.md` | grep | |
| S-B9 | frozen hashes and identity fragments; surface tests pass | PASS | `exclusion-integrity.2026-11-20T16-09.md`, `manual-literal-edits.2026-11-20T15-19.md`; pytest run | artifact read | |
| S-B10 | historical fixtures unchanged; tests pass through matchers | PASS | `git diff --stat` on `tests/fixtures` shows one added A23 rejection fixture and no change to an existing fixture | `git diff --stat` | addition authorized by A23 |
| S-B11 | write-scope checker passes three directions; both root forms | PASS | `ts-test-coverage.2026-11-20T18-10.md` | root run | |
| S-B12 | mirrors, manifests, Codex counterparts, generator checks, contract tests | PASS | `brief-fact-check.2026-11-20T15-39.md`, `phase-gate.P3.2026-11-20T16-04.md`, final gates | artifact read | |
| S-B13 | production-root search and link check stored | PASS | `production-root-search.2026-11-20T16-13.md`; 0 links broken by the move | artifact read | |
| S-B14 | checkpoint records post-move path; later evidence under it | PASS | `checkpoint-path-verified.2026-11-20T14-11.md` | artifact read | |
| S-B15 | seven-stage toolchain for TypeScript, Python, PowerShell with key at `.dev` | UNVERIFIED | stages 1 to 6 clean in pass 5; stage 7 in CI | pending CI | pending-CI criterion |
| S-B16 | stage B adds no Python file | PASS | name-status diff; reviewer confirmed no added `.py` | `git diff --name-status` | |
| S-B17 | each implied `global_decisions` answer implemented or recorded as no change | PASS | `scope-size-decisions.2026-11-20T18-12.md` | artifact read | |
| S-E1 | `.dev/` holds all records; `docs/` production plus README | PASS | as S-B2 | `git ls-files` | |
| S-E2 | migration command moves with `git mv`, rewrites, second run changes nothing | PARTIAL | apply-test case passes; post-apply run lists 4572 outside-tree candidates; a second apply would rewrite them | code read | F1 |
| S-E3 | migration command and tests need no Python | PASS | `language-scope.2026-11-20T07-49.md` | artifact read | |
| S-E4 | with key at `.dev`, the full toolchain passes | UNVERIFIED | stages 1 to 6 clean; stage 7 in CI | pending CI | pending-CI criterion |
| S-E5 | historical fixtures frozen and pass through the fallback | PASS | as S-B10 | `git diff --stat` | |
| S-E6 | mirrored and bundled files, manifests, Codex counterparts, contract tests pass | PASS | as S-B12 | artifact read | |
| U-a1 | dry run writes md and json under `evidence/other/`; no other change | PASS | as S-A17 | artifact read | |
| U-a2 | report lists every category, asserted by `migration-report.test.ts` | PASS | root run | same | |
| U-a3 | counts derived mechanically at run time | PASS | report generated from `listTrackedFiles` | code read | |
| U-a4 | default OQ-1 target and OQ-2, OQ-12 alternatives reported | PASS | `migration-plan.test.ts` | root run | |
| U-b1 | `npx` subcommand with exit codes 0, 1, 2 | PASS | CLI suite | root run | |
| U-b2 | `bin` and `files` unchanged; packaging test passes | PASS | as S-A13 | root run | |
| U-b3 | apply refuses on each listed condition | PASS | plan and decisions suites | root run | |
| U-b4 | in-memory apply moves, renames, rewrites, links, README; second apply no move or write | PASS | `migration-apply.test.ts` | root run | criterion names the suite; F1 is outside its fixture |
| U-b5 | no Python, no `vscode` import | PASS | as S-A14, S-E3 | root run | |
| U-b6 | `packages/mcp-server/README.md` documents the subcommand | PASS | README diff | `git diff` | |
| U-c1 | orchestrator presents the report and OQ-1 to OQ-13 to the owner; neither plan decides them | PARTIAL | A14 replaced the owner stop with an orchestrator decision step; the decision file is orchestrator-written and neither plan decides | spec read | F2: no recorded supersession of this criterion |
| U-c2 | decision file records actions, digest, exclusions, global answers | PASS | as S-O1 | artifact read | |
| U-c3 | apply honors each decision; comparison stored | PASS | `layout-check.2026-11-20T16-07.md` | artifact read | |
| U-c4 | tree change after approval makes apply refuse on digest | PASS | digest-mismatch case in `migration-decisions.test.ts` | root run | |
| U-d1 | `.dev/` layout; `docs/README.md` only | PASS | as S-B2 | `git ls-files docs` | |
| U-d2 | key is `.dev` in three copies; parity test passes | PASS | as S-B5 | grep | |
| U-d3 | `<NNNN>-<feature>` names except kept folders; other areas keep names | PASS | as S-B3 | `ls` | |
| U-d4 | plan from template has working links; both copies same depth | PASS | as S-B7 | grep | |
| U-d5 | historical fixtures unchanged and passing | PASS | as S-B10 | `git diff --stat` | |
| U-d6 | write-scope checker, generator checks, contract tests pass | PASS | as S-B11, S-B12 | artifact read | |
| U-d7 | full seven-stage toolchain for three languages with key at `.dev` | UNVERIFIED | stages 1 to 6 clean; stage 7 in CI | pending CI | pending-CI criterion |
| U-d8 | post-apply dry run reports an empty plan | PARTIAL | as S-B4 | code read | F1 |
| U-d9 | no new Python file | PASS | as S-B16 | `git diff --name-status` | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 59 criteria
- **PARTIAL:** 4 criteria
- **UNVERIFIED:** 4 criteria (all pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F1: the planner classifies moved records as outside-tree after the move, so `links-only` no longer protects them and a second apply is not empty (S-B4, S-E2, U-d8).
2. F2: user-story criterion U-c1 is superseded in substance by A14 but carries no recorded supersession.
3. Pending CI: S-A19, S-B15, S-E4, U-d7 (stage 7 integration tests), checked off at S9.

**Recommended follow-up verification steps:**

1. After the F1 fix, add a Jest case applying `links-only` twice to a fixture whose moved record holds an old prefix, and re-run the R4 post-apply dry run with the two A5 discovery test files in the derived exclusions; record the result as a new evidence artifact.
2. After the F2 supersession record, re-grade U-c1 against the A14 decision step.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

No source-file change was made by this review: every PASS criterion was already checked by the executor, and every PARTIAL or pending-CI criterion is already unchecked.

### Acceptance Criteria Status

- Source: `spec.md`, `user-story.md`
- Total AC items: 67
- Checked off (delivered): 59
- Remaining (unchecked): 8
- Items remaining: spec stage A seven-stage toolchain criterion; spec "A second dry run after apply reports an empty plan"; spec stage B seven-stage toolchain criterion; spec epic "The TypeScript migration command moves ... and a second run changes nothing"; spec epic "With `development_docs_root` set to `.dev`, the full toolchain passes"; user-story (c) owner presentation of OQ-1 to OQ-13; user-story (d) full seven-stage toolchain; user-story (d) post-apply dry run reports an empty plan.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 44 | 39 | 5 | Checkbox-backed |
| `user-story.md` | 23 | 20 | 3 | Checkbox-backed |
