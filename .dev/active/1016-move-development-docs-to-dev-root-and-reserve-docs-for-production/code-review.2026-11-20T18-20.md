# Code Review: migrate_development_docs tool and the .dev move (#1016)

**Review Date:** 2026-11-20
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`
**Feature Folder Selection Rule:** named by the caller; it is the post-move path that the orchestrator checkpoint records
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration` (merge base `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3`)
**Head Branch:** `feature/dev-docs-root-migration-phases-2-3-1016` at `f744ce9e060a98dec1be9d393bba5c644e81ed61`
**Review Type:** Initial review

---

## Executive Summary

The branch adds a TypeScript migration tool (`extensions/drm-copilot/src/lib/development-docs-migration/`, nine modules, plus inputs, handler, tool definitions, CLI and `main()` dispatch) and applies it to this repository: 35183 renames move `docs/features/**`, `docs/research/`, `docs/engineering/` and `docs/discovery/` under `.dev/`, feature folders take `<NNNN>-<feature>` names, `development_docs_root` flips to `.dev` in three routing copies, and several hundred tests, prose surfaces, generator sources and ledger patches are updated. The hand-written production code is small outside the tool: a read-location fallback in `ProcessReductionChain.psm1`, a moved-template key mapping in `build_discovery_runtime.py`, and path-literal edits in hooks, libs and skills.

The tool is cleanly separated (pure planner, seam-based applier) and fully tested on its documented scenarios. One correctness defect remains in the planner's classification of records after the move, which breaks idempotence under the `links-only` scope that this repository chose.

**What changed:**
Stage A: tool, registration in both definition lists, optional `migrateDevelopmentDocs?` service method, `maxBuffer` on `CommandRunOptions`, coverage map `jest.development-docs-migration-coverage.json`, README documentation. Stage B: apply commit, flip, `.dev` in self-hosted `path_roots`, plan-template link depth, epic manifest `feature_folder` values, ledger patch regeneration, rejection fixture, two deterministic Pester suites and one pytest case added in the final QA loop.

**Top 3 risks:**
1. A second apply on this repository, or on a destination migrated with `links-only`, rewrites historical records that the in-tree scope decision protected (F1).
2. The frozen epic-orchestrator agent and the cleanup consolidation allowlist keep naming `docs/` paths after the move (recorded known limitations A15, A27, A30).
3. Stage 7 integration tests have not run; no CI run exists for the head.

**PR readiness recommendation:** **Needs Revision** — F1 is a correctness defect in the shipped tool and F2 leaves a user-story criterion unmet without a recorded supersession.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts` | `scanRewrites`, lines 571 to 584 | After the move, `mapPath(path)` returns the path unchanged for every file under `.dev/`, so each moved record is pushed to `scan.outside` and, in apply mode, to `scan.rewrites` with the full prefix rewrite. `in_tree_rewrite_scope` (`links-only`, decision A3) stops applying once the move is committed. A second apply with a valid decision file would rewrite 4570 records (37610 reference occurrences). | Classify a file as in-tree when its path lies under a mapping-table target (for example `.dev/active/`, `.dev/engineering/`) as well as when it maps to a new path, so the in-tree scope governs it on every run; add a `migration-apply.test.ts` or `migration-plan.test.ts` case that applies with `links-only` to a fixture whose moved record holds an old prefix and asserts an empty second plan. | Spec `### Idempotence` requires an empty plan and no write on a second apply; A3 forbids rewriting historical record text. | `evidence/other/post-apply-dry-run-check.2026-11-20T16-11.md` (4572 entries under `rewrites_outside_moved_trees`); code read at head |
| Major | `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/other/post-apply-dry-run-check.2026-11-20T16-11.md` | Decision D-P4T3-1 | D-P4T3-1 records the 4570 records as not rewrite candidates under `links-only`; the code treats them as outside-tree candidates. The two discovery test files that keep the A5 resource key are also listed and are not in the derived exclusions, so the R4 condition "zero rewrite candidates outside the excluded files" does not hold as stated. | After the F1 fix, re-run the R4 post-apply dry run with the two discovery test files added to the derived `rewrite_exclusions` as A5 Stay rows, and record a new evidence artifact (append-only; do not edit the existing one). | The empty-plan criteria in the spec and the user story depend on this record. | `tests/discovery_runtime/initialization_test_support.py`, `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` in the post-apply report |
| Major | `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/user-story.md` | scenario (c), first criterion | The criterion requires the orchestrator to present OQ-1 to OQ-13 to the owner. Spec decision A14 replaced the owner stop with an orchestrator decision step under OD-1, but the user story carries no supersession record, so the criterion is unmet as written. | Record in `user-story.md` and `spec.md` that A14 supersedes this criterion (a planner-authored supersession note citing A14 and OD-1), then grade the criterion against the decision step. | An AC that the recorded decisions make unsatisfiable leaves the item permanently partial. | `spec.md` `## Autonomous Decisions` A14; `user-story.md` line 70 |
| Minor | `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/qa-gates/self-review.2026-11-20T18-14.md` | row 3C | The self-review states that no `.sh` or `.bats` file changed; `.claude/lib/bash/report-lane-assertion.sh`, its bundle copy and `tests/shell/report_lane_assertion_dispatch.bats` changed. | No edit (evidence is append-only); the reviewer ran bats (14 of 14) and kcov (89.8% lines) and recorded them. | Self-review accuracy. | `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md` |
| Info | `testResults.xml` | line 332 | The tracked Pester result file at the repository root was rewritten by the migration (one test-name string). | None required; consider whether a generated result file belongs in the tree. | Harmless; not read by any gate found. | branch diff |
| Info | `extensions/drm-copilot/src/repo-automation-service-contract.ts` | added optional method | Reports 0/346 executable lines at base and head. | None; the file holds only type declarations. | Type-only module under the coverage policy. | `coverage/lcov.info` |

No file-size Warning: no changed covered file is at or above 700 logical lines (largest 699).

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `build_discovery_runtime.py` keeps `RESOURCE_ROOTS`, the staged member keys and the manifest unchanged and maps a moved key to its new source through two pure helpers (A5 amendment).
- `init_models.py` resolves the template root at `.dev/discovery/templates`.

#### Typing and API notes

- No new public API beyond the two helpers; full annotations.

#### Error handling and logging

- `validate_resource_path` still runs on every key before the source mapping.

### TypeScript implementation audit

#### What changed well

- The planner is pure over injected inputs (`trackedFiles`, `readText`, decisions); the applier calls `ensureDir` before each `git mv` and never commits.
- Owner-question choices are decision-file inputs; the dry run reports every category with a `decision_skeleton`.
- Tool definitions live in a new module spread into both lists, so `mcp-tools.ts` gains one case.

#### Type safety and maintainability

- No suppressions in the new modules; readonly interfaces; discriminated `kind` on mapping results.
- `migration-plan.ts` is 587 lines; a further rule would push it toward the 700 advisory tier.

#### Error handling and logging

- Refusals are collected and returned, and the handler converts errors through `toFailureToolResult`. The F1 defect is a classification error, not an error-handling gap.

### PowerShell implementation audit

#### What changed well

- `Resolve-ProcessReductionLivePath` changes only the read location of an absent recorded path and keeps every `LiveText` key at its recorded value, so ledger stored patches stay revertible.

#### API and safety notes

- `CmdletBinding`, `OutputType`, mandatory parameters, `ValidateSet` on `PathType`; read-only, so `ShouldProcess` is not required.

#### Error handling and logging

- Unchanged behavior for present paths; an absent path with an absent moved location returns the recorded path, so the existing missing-file handling applies.

---

## Test Quality Audit

Evidence reviewed: the executor's five-pass final QA loop, the per-file coverage delta, and the reviewer's root Jest coverage run, Python and Pester artifact parse, and bats plus kcov run.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts` — second-apply case passes, but its fixture uses `references-and-links` and no moved record holds an old prefix, so it does not exercise F1.
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-plan.test.ts` — every refusal rule and the three scope values on a pre-move tree.
- `evidence/qa-gates/coverage-delta.2026-11-20T18-10.md` — 46 changed production files, 0 violations; reproduced from the standing artifacts.
- `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md` — reviewer runs.
- `evidence/other/layout-check.2026-11-20T16-07.md` — post-apply folder list matches the rule and the decision file.

### Quality assessment prompts

- **Determinism:** in-memory fakes; two variance sources removed by added tests.
- **Isolation:** one behavior per case.
- **Speed:** Jest 19 s root.
- **Diagnostics:** exact `toEqual` assertions on plan contents and file maps.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the hand-written diff. |
| No unsafe subprocess or command construction | ✅ PASS | `createMigrationGit` passes argv arrays with `--` separators through `CommandRunner`; no shell string. |
| Input validation at boundaries | ✅ PASS | `mcp-tool-inputs-development-docs.ts` validates mode and paths; decision-file schema validation. |
| Error handling remains explicit | ✅ PASS | Refusals are explicit messages; apply changes nothing when any refusal exists. |
| Configuration / path handling is safe | ⚠️ PARTIAL | Repository-relative forward-slash paths; the post-move in-tree classification (F1) lets a later apply rewrite records the decision protected. |

---

## Research Log

No external research was required. Findings rest on code reading at the head, the executor's evidence, and the reviewer's local runs.

---

## Verdict

The tool design, the move, and the dependent updates are of good quality and are fully tested on their stated scenarios; static stages and unit tests are clean in every changed language and coverage meets the thresholds. The change is not ready for the PR gate: F1 is a correctness defect in shipped tool code that breaks the spec idempotence rule under the in-tree scope this repository chose, and the post-apply evidence must be regenerated after the fix. F2 needs a recorded supersession of the user-story owner-presentation criterion under A14.
