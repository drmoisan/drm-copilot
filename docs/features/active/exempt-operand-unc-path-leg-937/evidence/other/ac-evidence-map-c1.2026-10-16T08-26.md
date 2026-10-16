# Acceptance Criteria Evidence Map, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T08-26
Command: mapping per the AC-MAPPING table of remediation-plan.2026-10-16T03-39.md, with each evidence artifact read for its acceptance result
EXIT_CODE: 0
Output Summary: All ten IDs (AC-16, AC-17, AC-18, AC-19, RI-1 to RI-6) are mapped to existing evidence artifacts, and every mapped evidence acceptance condition is met. AC-16 to AC-19 are eligible for check-off in spec.md. AC-15 stays unchecked (CI-dependent; checked off at S9 against the PR head).

Task: P3-T15 (remediation-plan.2026-10-16T03-39.md). Evidence paths are relative to `FEATURE/evidence/`.

## Map

| ID | Implementation | Tests | Evidence artifacts | Observed status |
|---|---|---|---|---|
| AC-16 | P2-T1 (`^\s` and `\s$` alternatives), P2-T2 | U27 `leading-space-unc`, `leading-space-absolute`, `trailing-space-absolute` on `.claude/hooks` and `.codex/hooks` | `regression-testing/ps-fail-before-c1.2026-10-16T07-02.md`; `qa-gates/ci-pass-after-c1.2026-10-16T08-22.md` | met: the 6 testcases failed before the fix (`but got $true`) and pass in run 38870746395 (F1 68/68 passed) |
| AC-17 | P2-T1 (`file:`, `~` alternatives), P2-T2 | U27 `file-uri-drive`, `file-uri-unc`, `tilde-forward`, `tilde-backslash` on both surfaces; Claude and Codex gate rows `(issue #937 RI-4)` | `regression-testing/ps-fail-before-c1.2026-10-16T07-02.md`; `qa-gates/ci-pass-after-c1.2026-10-16T08-22.md` | met: 8 unit and 4 gate testcases failed before (`$true` / `'allow'`) and pass after |
| AC-18 | P2-T1 (single-backslash alternative), P2-T2 | U27 `root-relative-backslash` on both surfaces; gate rows `(issue #937 RI-5)`; U01 | `regression-testing/ps-fail-before-c1.2026-10-16T07-02.md`; `qa-gates/ci-pass-after-c1.2026-10-16T08-22.md`; `other/targets-diff-shape-c1.2026-10-16T07-06.md`; `qa-gates/invariants-diff-c1.2026-10-16T07-51.md` | met: 2 unit and 2 gate testcases failed before and pass after; U01 passes on both surfaces (invariant run 29/29); `OrchestrationTargetAbsolutePattern` unchanged (HEAD hunk `@@ -39,2 +39,4 @@` only); merge-base numstat `9 0` per copy (additions only) |
| AC-19 | P1-T3, P1-T9, P1-T11 | the 22 F2 testcases | `regression-testing/ps-fail-before-c1.2026-10-16T07-02.md`; `regression-testing/poshqc-test-fail-before-c1.2026-10-16T06-32.md` | met: CI job `poshqc / PowerShell hook suites (Linux)` on 3c6b38fb5 recorded F2 22/22 failed and the unfiltered failed set equal to F2; local run recorded the same 22 failures |
| RI-1 | P3-T3 (full-suite `run_poshqc_test`) | all suites under `tests/scripts` and `tests/powershell` | `qa-gates/coverage-canonical.2026-10-16T08-24.md`; `remediation-baseline/coverage-local-baseline.2026-10-16T06-11.md`; `qa-gates/coverage-delta-c1.2026-10-16T08-25.md` | met under the recorded OrchestratorDecision: local repo-wide report 94.57 (11613 / 667), TESTCASES 10444, FAILED 0; per-copy 99.40 from the CI artifact; lines 41, 230, 231 covered with `ci` > 0 |
| RI-2 | same as AC-16 | same as AC-16 | same as AC-16 | met (as AC-16) |
| RI-3 | P1-T6 | U30 on both surfaces | `qa-gates/ci-pass-after-c1.2026-10-16T08-22.md`; `other/test-edit-shape-c1.2026-10-16T06-16.md` | met: U30 passes on `.claude/hooks` and `.codex/hooks` in run 38870746395 with the completed assertions |
| RI-4 | same as AC-17 | same as AC-17 | same as AC-17 | met (as AC-17) |
| RI-5 | same as AC-18 | same as AC-18; existing-row classification | same as AC-18; `remediation-baseline/pathleg-rows-baseline.2026-10-16T05-30.md`; `other/pathleg-rows-after-edit-c1.2026-10-16T06-17.md` | met (as AC-18); existing rows: `COUNT_NEW=0` at baseline, OLD and NONE counts unchanged after edit, the 14 NEW lines are only the new rows |
| RI-6 | P1-T4 to P1-T8, P1-T10 | unchanged row names and values in all three suites | `other/test-edit-shape-c1.2026-10-16T06-16.md`; `other/pathleg-rows-after-edit-c1.2026-10-16T06-17.md`; `qa-gates/ci-pass-after-c1.2026-10-16T08-22.md` | met: removed lines are exactly the 11 long lines; merge-base long added-line count 0; all F1 testcases (including the 6 cycle 0 gate rows) pass |

## Criteria left unchecked

| ID | Gap |
|---|---|
| AC-15 | CI-dependent: verified against the PR head at S9. Run 38870746395 is provisional evidence only. |

## Acceptance evaluation

| Condition | Result |
|---|---|
| All ten IDs appear once in the map | met |
| Each ID has at least one evidence artifact name that exists under `FEATURE/evidence/` | met |
