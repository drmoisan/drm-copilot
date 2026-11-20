# Code Review: migrate_development_docs tool and the .dev move (#1016), re-audit after remediation cycle 1

**Review Date:** 2026-11-20
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`
**Feature Folder Selection Rule:** named by the caller; it is the post-move path that the orchestrator checkpoint records
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration` (merge base `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3`)
**Head Branch:** `feature/dev-docs-root-migration-phases-2-3-1016` at `7322bc6251aca5e9d2beb11e528f847da44b6764`
**Review Type:** Re-review after remediation cycle 1 (cycle range `f744ce9e0..7322bc625`)

---

## Executive Summary

The full branch scope is unchanged from the prior review except for the cycle's six code and test edits and its records. The cycle edits are small and targeted:

- `layout-map.ts` gains the exported pure predicate `isMappedTargetPath(path, discoveryTarget)`, derived from `LEGACY_LAYOUT_MAP` and `rowTarget`, so it follows any future mapping row without a second list.
- `scanRewrites` in `migration-plan.ts` sends a file to the outside-tree branch only when `mapPath` leaves it unchanged and the predicate is false. A record already at a `.dev` target therefore stays under the chosen in-tree scope on later runs, which closes F1.
- `Get-StageTimingReport.Tests.ps1` mocks the evidence read for the parameterless run and asserts one read of the resolver-supplied root, which removes the dependence on a `docs/features` directory on disk (F3).

Both F1 tests and the F3 test were shown to fail before their fixes (`fail-before-f1.2026-11-20T19-17.md`, `fail-before-f3.2026-11-20T19-29.md`). The F3 run reproduced the CI error text on an emulated clean checkout. The post-apply dry run from a branch build is empty in every plan category. The reviewer read the report JSON directly: `moves`, `renames`, `rewrites_outside_moved_trees`, `rewrites_in_tree_links_only` and `refusals` are empty arrays; the 4572 in-tree references-and-links entries are all under `.dev/` and carry 0 links in total; and all four Stay-row files are in `excluded_files`.

**What changed (cycle):** one predicate and one condition (F1), three Jest test blocks, one Pester case (F3), the A14 supersession in `user-story.md` and `spec.md` (F2), and append-only evidence.

**Top 3 risks:**
1. Stage 7 integration and the CI Pester shards were still running at review time; the TypeScript CI jobs had completed `success` on the head.
2. The predicate also treats a file that a destination already holds under a `.dev` target before its first migration as in-tree. Under `references-and-links` the result is the same text; under `links-only` such a file keeps its old-prefix text. This matches the A3 intent for development records and is noted for information.
3. The frozen epic-orchestrator agent and the cleanup consolidation allowlist still name `docs/` paths (known limitations A15, A27, A30; unchanged).

**PR readiness recommendation:** **Ready** — no blocking finding remains; CI-dependent criteria are pending CI.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts` | `isMappedTargetPath` | On a destination's first run, a file already under a `.dev` target is classified as in-tree rather than outside-tree. With `references-and-links` both branches write the same text; with `links-only` the file keeps its text. | None required. If a destination ever needs outside-tree treatment for pre-existing `.dev` content, document it in the tool README. | The behavior follows decision A3, which protects development-record text. | code read; `migration-plan.test.ts` post-move case |
| Info | `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/qa-gates/root-jest-coverage.2026-11-20T20-14.md` | root line total | The launcher root run reports 98.44% lines against 98.52% in the prior reviewer's direct run, because the launcher excludes the four integration-lane suites. | None; compare like-for-like launcher runs (no drop). | Recorded as a non-blocking deviation in `root-jest-baseline-deviation.2026-11-20T20-14.md`. | reviewer parse of `coverage/lcov.info`: 81575/82866 |
| Info | `testResults.xml` | line 332 | Unchanged from the prior review: the tracked Pester result file holds one migrated test-name string. | None required. | Not read by any gate found. | branch diff |

No blocking finding. No file-size Warning: no changed covered file is at or above 700 logical lines (cycle files: `migration-plan.ts` 589, `migration-plan.test.ts` 542, `migration-apply.test.ts` 268, `layout-map.test.ts` 185, `layout-map.ts` 181, `Get-StageTimingReport.Tests.ps1` 102; branch-wide largest 699).

### Prior findings disposition

| Prior finding | Disposition | Evidence |
|---|---|---|
| F1 (Major): moved records leave the in-tree scope after the move | Closed | commit `e49111fac`; fail-before 2 of 2 expected failures; CI `drm-copilot-extension-tests` success on both hosts; `post-apply-dry-run-check.2026-11-20T19-24.md` |
| D-P4T3-1 record mismatch and A5 files not excluded (Major) | Closed | successor record `post-apply-dry-run-check.2026-11-20T19-24.md` states the in-tree classification; four Stay rows in `excluded_files` (reviewer check); the 2026-11-20T16-11 record is unchanged |
| F2 (Major): user-story (c) 1 superseded without a record | Closed | `user-story.md` supersession note and restated criterion; `spec.md` A14 sentence |
| Self-review bash statement (Minor) | Closed | `self-review.2026-11-20T20-19.md` names the three bash files and cites the bats and kcov figures |
| F3 (orchestrator supplement): CI-only Pester failure | Closed locally; CI shards in progress | commit `f331c32ca`; `fail-before-f3.2026-11-20T19-29.md`; `phase-gate.P1.2026-11-20T19-55.md`; `pester-junit.xml` shows the case Passed |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python change in the cycle; the branch-level assessment of the prior review stands (`RESOURCE_ROOTS` and staged keys unchanged under A5).

#### Typing and API notes

- No change.

#### Error handling and logging

- No change.

### TypeScript implementation audit

#### What changed well

- `isMappedTargetPath` is pure, documented and derived from the table; the directory test uses `startsWith` on the slash-terminated target, so `.dev/activex/a.md` does not match `.dev/active/` (tested).
- The `scanRewrites` change is a single conjunct with a comment citing the reason; the outside branch keeps its existing behavior for every non-target path.
- The extra refusal-text case removes a branch-coverage variance created when the condition change lowered the v8 branch denominator from 148 to 147.

#### Type safety and maintainability

- No suppression, no `any`; the import list stays sorted.
- `migration-plan.ts` is 589 lines, below the 700 advisory tier.

#### Error handling and logging

- No change to refusal or error paths other than the newly pinned refusal text.

### PowerShell implementation audit

#### What changed well

- The F3 change is test-only. `Get-StageTimingReport.ps1` and `StageTiming.psm1` already resolve the default root through `Resolve-DevelopmentDocsRoot` (A23); the test now asserts that resolution instead of reading the disk.

#### API and safety notes

- `Should -Invoke Read-StageTimingEvidence -Times 1 -Exactly -ParameterFilter { (Split-Path -Path $Root -Leaf) -ceq 'features' }` uses the parameter variable `$Root` and a literal, so the filter is not subject to the same-name variable collision that a `$Root -eq $root` form would have.

#### Error handling and logging

- `STR-ENTRY-THROWS-ON-MISSING-ROOT` still covers the throw for an explicit absent root.

---

## Test Quality Audit

Evidence reviewed: fail-before records for F1 and F3, the [P1-T8] phase gate on the clean layout, the final-loop gate artifacts (2026-11-20T20-08 to 20-19), the coverage delta, and the reviewer's direct parse of the standing coverage and junit artifacts.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts` — the new case applies `links-only` to a moved record that keeps an old prefix and holds no link, then asserts an empty second plan, no added `git mv` and no added write; it failed before the fix with the record in `second.rewrites`.
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-plan.test.ts` — the post-move case asserts in-tree classification in the dry run and no rewrite in an apply-mode plan; it failed before the fix.
- `extensions/drm-copilot/test/lib/development-docs-migration/layout-map.test.ts` — the row-table case iterates every `LEGACY_LAYOUT_MAP` row, so a dropped row branch fails it; the two bare-directory rows (`.dev/active`, `.dev/discovery/templates`) pin the trailing-slash equality term.
- `tests/scripts/dev-tools/Get-StageTimingReport.Tests.ps1` — failed on the clean layout with the CI error text before the fix; passes after. A mock that did not take effect would reach the real read and throw on the clean layout, so the passing run on the clean layout also shows that the mock is effective.
- `evidence/other/moved-root-sweep.2026-11-20T19-34.md` — 65 integration-lane and bats files, 13 hits in one file, all non-reads.
- `evidence/qa-gates/phase-gate.P1.2026-11-20T19-55.md` — `Sweep: none`; the moved-root directories were absent before and after the full unit runs.

### Quality assessment prompts

- **Determinism:** in-memory fakes; one case-scoped mock.
- **Isolation:** one behavior per case.
- **Speed:** sub-second Jest selection; 0.114 s Pester case.
- **Diagnostics:** exact-value assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the cycle diff. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess change in the cycle. |
| Input validation at boundaries | ✅ PASS | Unchanged. |
| Error handling remains explicit | ✅ PASS | Unchanged; refusal text pinned. |
| Configuration / path handling is safe | ✅ PASS | The in-tree classification now holds after the move; the post-apply report is empty in every plan category. |

---

## Research Log

No external research was required. Findings rest on code reading at the head, the executor's evidence, the reviewer's parse of `coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `pester-junit.xml` and the post-apply report JSON, and the completed jobs of CI run 44810698464.

---

## Verdict

Remediation cycle 1 closes F1, F2 and F3 with fail-before and pass-after evidence, and the cycle diff introduces no regression. Static stages and unit tests are clean in every changed language, coverage meets the thresholds with no drop, and the TypeScript CI jobs pass on the head. The branch is ready for the PR gate; the CI-dependent criteria are checked off at S9.
