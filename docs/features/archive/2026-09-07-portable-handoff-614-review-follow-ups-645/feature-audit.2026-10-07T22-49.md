# Feature Audit: Portable Handoff #614 Review Follow-ups, R16-R19 (#645)

---

**Audit Date:** 2026-10-07
**Feature Folder:** `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645`
**Base Branch:** `main`
**Head Branch:** `feature/portable-handoff-614-review-follow-ups-645`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review (pass 1)

---

## Scope and Baseline

- **Base branch:** `main` (merge base `08ee030d9584bf15882fbb3654c8e38f34c7c359`)
- **Head branch/commit:** `feature/portable-handoff-614-review-follow-ups-645` (commit `38dac372`, pushed)
- **Merge base:** `08ee030d9584bf15882fbb3654c8e38f34c7c359`. `origin/main` was merged into the branch at `f5e96db8`. Every diff in this audit uses `08ee030d...HEAD`, so the merged main content is excluded.
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`. It was absent at review start, so the reviewer regenerated it with `poetry run python -m scripts.dev_tools.pr_context.collector --base 08ee030d9584bf15882fbb3654c8e38f34c7c359 --head HEAD` (head `38dac372`).
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same run) and direct `git diff 08ee030d...HEAD`.
  - Feature evidence: `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/{baseline,other,qa-gates,regression-testing}/` (58 files).
  - Additional evidence: `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, and `artifacts/pester/powershell-coverage.xml`. All three were written after the last code commit (22:24) and were independently parsed by the reviewer.
- **Feature folder used:** `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645`
- **Requirements source:** `spec.md` (AC-1 to AC-22) and `user-story.md` (US-1 to US-9)
- **Work mode resolution note:** `issue.md` line 10 carries the explicit marker `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources. The early-draft checklist in `issue.md` is not an AC source in this mode, and the spec states that it supersedes it.
- **Scope note:** R20 is out of scope by spec decision. The branch diff contains no R20 file, and the caller's R16-R19 scope statement matches the full branch diff, so no scope narrowing was applied. Plan deviations DEV-1 through DEV-13 were read and weighed. DEV-1 sets the diff base, and DEV-12(c) records the AC-8 two-file placement.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md` (primary; governs where the two differ)
- `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/user-story.md` (secondary)

### From spec.md

1. AC-1: `codex-planning-only-registry.Tests.ps1` contains three new `It` cases that call `Get-EpicPlanningRegisteredMcpTool` directly. Each case asserts `$_.Exception.Message` with `Should -BeExactly` against one throw: line 58 (absent sentinel), line 72 (`invalid-operation-...json`), line 77 (`invalid-alias-...json`). The Pester run reports `failures="0"` and `errors="0"` and lists the three cases as passed. The existing line-67 case is unchanged.
2. AC-2: `powershell-coverage.xml` shows lines 58, 72, and 77 as covered. The missed-line set is a subset of the Phase 0 set minus {58, 72, 77}. Report-level PowerShell line coverage is at or above the Phase 0 baseline.
3. AC-3: Exactly two new fixtures are added under `tests/fixtures/codex-hooks/`. The temp-file Grep over every added or changed test file returns zero matches. The purity hook does not deny the Pester file.
4. AC-4: `git diff --quiet origin/main -- <hook> <published copy>` exits 0, and `test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity` passes.
5. AC-5: `jest.config.cjs` `coverageThreshold` contains the 14 listed keys, each exactly `{ lines: 85, branches: 75 }`, with no `global` key and no `coveragePathIgnorePatterns`.
6. AC-6: `npm --prefix extensions/drm-copilot run test:coverage` exits 0. lcov reports each of the 14 files at or above 85% line and 75% branch. Any new production `.ts` file has its own entry.
7. AC-7: A Grep for `catch\s*\{` over the four modules returns zero matches, and the same Grep over every `src/**/*{handoff,semantic-mcp}*.ts` file returns zero matches.
8. AC-8: `orchestration-handoff-failure-cause.test.ts` covers each blocked result that follows a caught error, with at least one named case per result (materializer checkpoint-read, envelope-decode, git-status, archive-write plus archive-readback, candidate-write plus candidate-readback, candidate-validate, candidate-replace, candidate-cleanup appended; authority envelope-read and plan-read). Each case asserts the unchanged `primaryFailureCode` and the exact `failureCause`. The idempotent-retry case asserts that no `failureCause` is present.
9. AC-9: Decision D1 is implemented and verified by named tests. The `HandoffPathBoundary` declaration is unchanged. The existing path-boundary tests pass unchanged, and both helper arms are executed. Null path resolution carries `workspace-root: unresolved` / `target-path: unresolved` with `HANDOFF_PLAN_PATH_INVALID`. Authority plan-read carries `plan-read: <token>`. `validateDestinationProjection` returns one message containing the token, and the existing `toHaveLength(1)` passes unchanged. Materializer ~286 carries `destination-projection: invalid`.
10. AC-10: Table-driven tests of `describeHandoffFailureCause` cover the code, name, non-error, and non-matching-code branches. Path-bearing and env-like messages do not appear in the output, and the output contains no `/` or `\`.
11. AC-11: The handler tests verify that `failure_cause` is present when set, absent when unset (`not.toHaveProperty`), and that validated and materialized results carry no `failureCause`.
12. AC-12: Failure-code assignment and precedence are unchanged. The named precedence tests pass with their files unedited. `NEGATIVE_SCENARIOS` passes and is textually unchanged. The registry and `orchestration-handoff-contract.ts` are unchanged.
13. AC-13: No existing fixture or schema changes (`--diff-filter=MDR` lists nothing under the protected trees), and the `inputSchema` blocks are textually unchanged.
14. AC-14: The `git diff --name-only` output does not list `orchestration-handoff-materializer-path-boundary.test.ts`.
15. AC-15: `raw_file_sha256` is called in `test_taskmaster_469_fixture_hashes_and_source_history_are_pinned`, which passes. There are zero `hashlib` matches in the test file. The two production contract modules are unchanged.
16. AC-16: The pytest coverage run exits 0, and repo Python line and branch coverage are each at or above the Phase 0 baseline.
17. AC-17: Each R18 module is at or above its Phase 0 line and branch baseline and at or above 85% line / 75% branch.
18. AC-18: `mcp-server-prepack.test.ts` runs in `test:coverage`, and all its tests pass. No assertion was removed or weakened.
19. AC-19: Every added or modified non-Markdown, non-JSON-fixture file is at or under 500 lines (post-edit count recorded). The D2 extraction applies if materializer.ts exceeds 490 lines.
20. AC-20: The full toolchain loop passes in a single pass for Python, TypeScript, and PowerShell, and `tsconfig.jest.json` reports no diagnostic outside the Phase 0 list.
21. AC-21: No dependency is added or removed (`package.json` dependency blocks and `pyproject.toml` tables unchanged).
22. AC-22: Phase 0 baseline and final coverage evidence exist under `evidence/` in canonical `<kind>/` subfolders, and nothing is under `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/`.

### From user-story.md

23. US-1 (operator diagnosability): Every blocked handoff result that follows a caught error or a path-resolution sentinel failure carries a `failureCause` (`failure_cause` in MCP output) in the form `<stage>: <token>`, verified by the named cases in the failure-cause and handler test files (spec AC-8, AC-9, AC-11).
24. US-2 (redaction): Cause strings contain only `error.code` / `error.name` class tokens or fixed literals, with no absolute path, file content, or environment value (spec AC-10).
25. US-3 (no contract change): Result fields, `HANDOFF_*` assignment and precedence, fixtures, the envelope schema, MCP input schemas, and `HandoffPathBoundary` are unchanged, and validated and materialized results carry no cause (spec AC-9, AC-11, AC-12, AC-13).
26. US-4 (zero bare catch): (spec AC-7).
27. US-5 (enforced coverage floors): 14 per-file thresholds at `{ lines: 85, branches: 75 }`, no `global`, no `coveragePathIgnorePatterns`, and `test:coverage` exits 0 (spec AC-5, AC-6, AC-17).
28. US-6 (tested hook rejection contract): exact-message Pester cases for lines 58, 72, and 77 using committed fixtures. Those lines are covered. The hook and its published copy are byte-identical and unchanged (spec AC-1 to AC-4).
29. US-7 (no dead public API): `raw_file_sha256` is called by the pinned-fixture test, the inline `hashlib` is removed, and production Python is unchanged (spec AC-15).
30. US-8 (no regression): coverage is at or above baseline, every touched file is at or under 500 lines, prepack passes, and the single-pass loop has no new `tsconfig.jest.json` diagnostic (spec AC-16 to AC-20).
31. US-9 (scope boundary): the materializer-path-boundary test is not modified, and no dependency is added (spec AC-14, AC-21).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Pester exact-message cases | PASS | Diff of `codex-planning-only-registry.Tests.ps1` lines 262-315 shows 3 `It` cases with `Should -BeExactly`, matching hook lines 58, 72, and 77 verbatim. The `$script:MissingRegistryPath` sentinel is at Tests.ps1:15. `ps-pester.2026-10-07T22-30.md`: JUnit `failures="0" errors="0"` and the 3 names Passed. The diff adds content after line 258 only (no removed lines), so the line-67 case is unchanged. | `git diff 08ee030d...HEAD -- tests/`; read hook lines 50-81 | Hook text matches assertion text exactly. |
| 2 | AC-2 lines 58/72/77 covered; no new missed line; report line no lower | PASS | The reviewer parsed `artifacts/pester/powershell-coverage.xml` (22:36). Lines 58, 72, and 77 show `ci=1`. The missed set is {307, 336, 343, 344, 345, 350, 359}. Report LINE coverage is 11458/11885 = 96.41%, against a 96.38% baseline. | `python -I cov.py` (scratchpad) | Matches `ps-coverage.2026-10-07T22-38.md`. |
| 3 | AC-3 fixtures and test purity | PASS | `git diff --name-status` shows exactly 2 `A` entries under `tests/fixtures/` (the two codex-hooks fixtures). The reviewer's Grep with the AC pattern (plus `mkdtemp`, `writeFileSync`) over all 6 changed test files returned 0 matches, with a positive control matching all 6. The purity-hook acceptance is recorded in `r16-test-purity.2026-10-07T22-08.md`. | Grep (tool); `git diff --name-status 08ee030d...HEAD` | |
| 4 | AC-4 hook parity | PASS | `git diff --quiet 08ee030d HEAD -- <hook> <published copy>` exit 0 (in the combined reviewer run). `cmp` of the two files exit 0. The parity test passed in `py-parity-and-precedence.2026-10-07T22-27.md`. | `git diff --quiet ...`; `cmp ...` | The diff base is per DEV-1 rather than the literal `origin/main`. |
| 5 | AC-5 14 threshold keys | PASS | The `jest.config.cjs` diff adds exactly the 14 listed keys, each `{ lines: 85, branches: 75 }`. A Grep shows `global` only in comments, no `coveragePathIgnorePatterns`, and `collectCoverageFrom` unchanged. | `git diff ... -- extensions/drm-copilot/jest.config.cjs`; Grep | No existing entry changed (additions only). |
| 6 | AC-6 test:coverage exits 0; 14 files at floors | PASS | `ts-jest-coverage.2026-10-07T22-28.md`: exit 0, 3852/3852. The reviewer's parse of `coverage/lcov.info` shows all 14 at or above 85/75 (minimum branch is path-boundary.ts at 84.75%). No new production `.ts` file exists (`git diff --name-status` shows only `M` under `src/`). | `python -I cov.py` | |
| 7 | AC-7 zero bare catch | PASS | Base `git grep -cE "catch\s*\{"` found 15 sites in the four modules. At HEAD, the Grep for `catch` over `src/**/*{handoff,semantic-mcp}*.ts` lists only `catch (… : unknown)` forms (20 lines, none bare). | `git grep -cE ... 08ee030d -- extensions/drm-copilot/src/lib/validate/`; Grep | |
| 8 | AC-8 named failure-cause cases | PASS | `orchestration-handoff-failure-cause.test.ts` M1, M2, M3, M5, M7, M9, M10, and M11 (exact code and cause), and M12 asserts the key is absent. Authority envelope-read (A1) and plan-read (A2) are in `orchestration-handoff-failure-cause-authority.test.ts` with exact code and cause. Both files pass (`r18-authority-production-boundary.2026-10-07T22-23.md`, `ts-jest-coverage.2026-10-07T22-28.md`). | Read both test files | PASS with a non-blocking documentation note. The authority cases are in a sibling file under the plan's pre-approved overflow branch (P5-T11/P5-T12; DEV-12(c)), because the measured single file was 608 lines and the 500-line policy limit outranks the spec's file naming. Every enumerated result has a named, exact-assertion case. Recommend amending the AC-8 wording to name both files. |
| 9 | AC-9 Decision D1 | PASS | The path-boundary diff hunks start at old line 82 or later, and the interface is at lines 19-29, so the declaration is unchanged. `orchestration-handoff-path-boundary.test.ts` and `-materializer-production.test.ts` are unchanged (`git diff --quiet` exit 0) and pass. B1/B2 execute both `guardedResolution` arms. M13 / A3 cover `workspace-root: unresolved`, and M14, M15, A4, A5 cover `target-path: unresolved`, each with `HANDOFF_PLAN_PATH_INVALID`. A2 covers `plan-read: EACCES`. P1 covers the single message with `SyntaxError`. M4 covers `destination-projection: invalid` (materializer.ts:301). | `git diff --quiet 08ee030d HEAD -- <tests>`; diff inspection | |
| 10 | AC-10 helper table + redaction | PASS | failure-cause.test.ts:84-162: rows a (code), b (non-matching code), c (numeric), d (name), e and f (non-error), g (plain object code). The redaction case uses the Windows path, POSIX path, and `HOME=` messages, with and without a code, and asserts no message substring, `/`, `\`, or `operator`. | Read test file | Code inspection confirms the helper never reads `message` or `stack`. |
| 11 | AC-11 MCP additive output | PASS | handlers.test.ts:312-403: `failure_cause` is mapped for the topology and transition tools, and `not.toHaveProperty("failure_cause")` holds for validated and materialized results. M12, M17, and A6 assert no `failureCause` on materialized and validated results. | `git diff ... -- extensions/drm-copilot/test/mcp-handlers` | |
| 12 | AC-12 precedence unchanged | PASS | `git diff --quiet 08ee030d HEAD -- tests/scripts/dev_tools/test_orchestration_handoff_contract.py extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts config extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts` exit 0. The Python test diff hunks are `@@ -2,7`, `@@ -20,6`, `@@ -34,6`, and `@@ -71,10` (old ranges 2-8, 20-25, 34-39, 71-80), none of which intersects `NEGATIVE_SCENARIOS` (43-62). `ts-precedence-tests.2026-10-07T22-29.md` shows 2 passed, and `py-parity-and-precedence.2026-10-07T22-27.md` shows 58 passed. | `git diff --quiet ...` (reviewer re-run) | |
| 13 | AC-13 no fixture or schema change | PASS | `git diff --name-status` shows no M/D/R under `tests/fixtures/`, `extensions/drm-copilot/test/fixtures/`, `config/`, or `extensions/drm-copilot/resources/config/`. The tool-definitions diff is exactly two added `readonly failureCause?: string;` lines. | `git diff --name-status 08ee030d...HEAD`; diff | |
| 14 | AC-14 R20 file untouched | PASS | The changed-file list does not include `orchestration-handoff-materializer-path-boundary.test.ts`, and `git diff --quiet` on it exits 0. | `git diff --name-status ...` | |
| 15 | AC-15 raw_file_sha256 call | PASS | The test diff imports `raw_file_sha256` and calls it twice in the pinned test, and `import hashlib` is removed. Both contract modules are unchanged (`git diff --quiet` exit 0). `r19-focused-coverage.2026-10-07T22-09.md` shows line 62 is now covered and the tests pass. | `git diff ... -- tests/`; `git diff --quiet ...` | |
| 16 | AC-16 Python coverage no regression | PASS | Baseline 93.67% / 87.09%, post 93.67% / 87.09% (16444 to 16445 covered lines). The reviewer's parse of `artifacts/python/lcov.info` gives 93.67% / 87.09%. The pytest run exited 0 with 6583 passed. | `python -I cov.py`; `py-pytest-coverage.2026-10-07T22-25.md` | Coverage target `scripts.dev_tools` replaces the spec's `src` path, as the plan notes. No Python exists under `src/`. |
| 17 | AC-17 R18 modules at or above baseline and floors | PASS | Line and branch, baseline to post: materializer 98.42/94.87 to 98.98/96.43; authority 98.41/88.41 to 98.97/90.14; path-boundary 97.56/81.13 to 98.64/84.75; production 100/97.30 to 100/97.50; request 100/100 to 100/100. | `python -I cov.py`; `coverage-delta.2026-10-07T22-40.md` | |
| 18 | AC-18 prepack test | PASS | `ts-jest-coverage.2026-10-07T22-28.md` command 2: `Tests: 4 passed, 4 total`. The prepack test file is unchanged (`git diff --quiet` exit 0). | `git diff --quiet ...` | |
| 19 | AC-19 500-line limit | PASS | Reviewer `wc -l`: materializer.ts 488 (at or under 490, so D2 is not required), every other changed code or test file at or under 455. Recorded in `ac19-line-counts.2026-10-07T22-40.md` and `d2-materializer-line-count.2026-10-07T22-15.md`. | `wc -l <files>` | |
| 20 | AC-20 single-pass toolchain | PASS | `toolchain-loop-single-pass.2026-10-07T22-38.md`: 16 passing artifacts in one pass with identical Write Set hashes. The reviewer confirmed that the HEAD hashes equal the recorded ones. `tsconfig.jest.json` has 0 diagnostics at baseline and post (DEV-7). | `git hash-object <files>` | |
| 21 | AC-21 no dependency change | PASS | `git diff --quiet 08ee030d HEAD -- extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json pyproject.toml poetry.lock` exit 0 (reviewer run). | `git diff --quiet ...` | |
| 22 | AC-22 evidence location | PASS | 58 evidence files under canonical `evidence/{baseline,other,qa-gates,regression-testing}/`. No branch file is under `artifacts/{baselines,qa,coverage,evidence}`. `validate_evidence_locations.py --root .` exit 0. | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | |
| 23 | US-1 operator diagnosability | PASS | Verified through the method US-1 names (AC-8, AC-9, AC-11, all PASS). | as AC-8, AC-9, AC-11 | Non-blocking note: three pre-existing bound catch sites (authority-service.ts:150-156, materializer.ts:193-200 and 282-292) return fallback-code blocked results without a cause. They are outside the spec's 15-site scope and the AC-8 enumeration. Recommended as a follow-up. |
| 24 | US-2 redaction | PASS | AC-10 PASS. Code inspection shows every `failureCause` value is a fixed literal or a helper output, and the helper never reads `message` or `stack`. | as AC-10 | Non-blocking hardening: constrain `error.name` (materializer-request.ts:42-43). |
| 25 | US-3 no contract change | PASS | AC-9, AC-11, AC-12, and AC-13 PASS. Unchanged existing materializer and authority tests pass. | as cited | |
| 26 | US-4 zero bare catch | PASS | AC-7 PASS. | as AC-7 | |
| 27 | US-5 enforced coverage floors | PASS | AC-5, AC-6, and AC-17 PASS. | as cited | |
| 28 | US-6 tested hook rejection contract | PASS | AC-1 through AC-4 PASS. | as cited | |
| 29 | US-7 no dead public API | PASS | AC-15 PASS. | as AC-15 | |
| 30 | US-8 no regression | PASS | AC-16 through AC-20 PASS. PowerShell 96.38% to 96.41%. | as cited | |
| 31 | US-9 scope boundary | PASS | AC-14 and AC-21 PASS. | as cited | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 31 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm that CI (`ci.yml`) is green on head `38dac372` once the PR is opened.
2. File one follow-up issue covering the three non-blocking items:
   - constrain `error.name` in `describeHandoffFailureCause`;
   - add causes on the fallback arms of the three pre-existing bound catches;
   - amend the spec AC-8 wording to name both failure-cause test files.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source files if they are markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 31 criteria were already checked (`- [x]`) by the executor in Phase 9. Every one is evaluated PASS here, so no source-file change was made: no item was newly checked and no item was unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md`, `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/user-story.md`
- Total AC items: 31
- Checked off (delivered): 31
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md` | 22 | 22 | 0 | Checkbox-backed (`## Acceptance Criteria`, lines 156-225) |
| `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/user-story.md` | 9 | 9 | 0 | Checkbox-backed (`## Acceptance Criteria`, lines 53-61) |

The spec's `## Definition of Done` checklist (spec.md:236-239) is not an AC source and was not modified.
