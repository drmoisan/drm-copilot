# Research: Issue #884 untouched-files coverage verification

SUPERSESSION-NOTE: the acceptance criteria AC1 to AC5 in issue.md supersede the acceptance-criteria proposal (AC1 to AC6) in this document.
TEMPLATE-STATEMENTS-HISTORICAL: YES (statements below that describe issue.md and the plan as unfilled templates describe the state when this research was written and are historical).

- Issue: #884 (bug, "untouched-files-coverage-below-floor")
- Branch: bug/untouched-files-coverage-verification-884
- Base: origin/main f6915d429
- Date (UTC): 2026-10-15

## Determination

**EVIDENCE-ONLY.** Both files named in #884 are at or above the uniform 85% line-coverage floor on the latest main CI run. No production-code or test change is required.

## Question

Issue #884 reported two production files below the 85% line floor (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`):

- (a) `.claude/lib/bash/compute-concurrency-batches.sh` at 81.82% (kcov, CI run 38057811190).
- (b) `.codex/hooks/validate-feature-review-coverage.ps1` at 7.30% (Pester, CI run 38022356096).

## Per-file results

| File | Reported | Current | Source |
|---|---|---|---|
| `.claude/lib/bash/compute-concurrency-batches.sh` | 81.82% (kcov) | 100.00% (44/44 lines hit) | CI run 38683717593, artifact `shell-coverage` (cov.xml) |
| `.codex/hooks/validate-feature-review-coverage.ps1` | 7.30% (Pester) | 100.00% (missed=0, covered=146) | CI run 38683717593, artifact `poshqc-test-results` (powershell-coverage.xml) |

### Orchestrator-observed measurements (CI run 38683717593)

These were read by the orchestrator through `gh`; the researcher did not run `gh` and has not independently reproduced them.

- Run: workflow `ci.yml` on main, head SHA f6915d429b5156783d1ee7eacbbe432de0f2700b, conclusion success, created 2026-10-15T04:52:04Z.
- Jobs `shell-coverage / Shell Coverage (Bats + kcov)` (job 116253715771) and `poshqc / PowerShell QC` (job 116253715765) both succeeded.
- kcov Cobertura (`shell-coverage`, cov.xml): class filename `.claude/lib/bash/compute-concurrency-batches.sh`, line-rate 1.000, 44 of 44 lines with hits > 0. Repository kcov aggregate line-rate 0.952 (3256/3421).
- Pester JaCoCo (`poshqc-test-results`, powershell-coverage.xml): sourcefile `.codex/hooks/validate-feature-review-coverage.ps1`, LINE counter missed=0 covered=146.
- The orchestrator reports no commits touching either production file after 5e79b589c (2026-10-12, "fix(896): read the Codex feature-review line floor from root CLAUDE.md (Refs #884)") and after the PR #917 merge commit 88946d10a (2026-10-12). The researcher's tool set had no shell, so `git log` was not re-run here; the committed evidence below is consistent with these dates.

## Corroborating repository evidence

### (a) Bash file

- `docs/features/active/2026-10-11-compute-concurrency-batches-coverage-884/evidence/qa-gates/ci-kcov-per-file-coverage.2026-10-12T13-16.md:4-6` records CI run 38281234678, class element `compute_concurrency_batches_sh__41`, baseline 81.82% (kcov CI run 38057811190) to 100.00% (line-rate 1.000, branch-rate 1.0), delta +18.18 points, with the production file unchanged.
- `docs/features/active/2026-10-11-compute-concurrency-batches-coverage-884/policy-audit.2026-10-12T14-00.md:11,31,49,51` states the same: the branch added only `tests/shell/compute_concurrency_batches_cli.bats` (5 new cases), the script is unchanged (line 117), and Coverage is PASS at 100.00% per file.
- `tests/shell/compute_concurrency_batches_cli.bats:22-50` contains the five cases: `--help`, `-h`, `--keys` without a value, `--max-concurrency` without a value, and an unknown option. They cover the usage and argument-error paths that were uncovered at 81.82%.
- The new measurement (100.00%, 44/44) is consistent with that result and holds on the later run 38683717593.

### (b) Codex hook

- `docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md:22,28` records `.codex/hooks/validate-feature-review-coverage.ps1` at 99.29% (covered=140, missed=1) on the 2026-10-11 merged tree.
- `docs/features/active/epic-852-main-sync/policy-audit.2026-10-11T01-33.md:142` records the Codex hook as "unchanged", 99.29% (140/141), PASS.
- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/pester-coverage.2026-10-11T23-30.md:6,8` records the baseline at 99.29% (140/141) and states: "A previously cited figure of 7.30% does not match this measurement and is not used."
- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/final-pester-coverage.2026-10-12T08-31.md:15` records post-change `.codex/hooks/validate-feature-review-coverage.ps1` at 100.00% (covered=146, missed=0), with COVERAGE-BELOW-85: NONE.
- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/coverage-delta.2026-10-12T08-38.md:17,28` records the delta 99.29% to 100.00%, with changed lines at 100.00% (9/9).
- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/policy-audit.2026-10-12T11-25.md:139,142` repeats the figures and states that the 7.30% Codex figure cited in #884 is superseded by the 99.29% baseline measurement.
- The post-change 146/146 matches the orchestrator-observed JaCoCo counter on run 38683717593 exactly (covered=146, missed=0).

### Why 7.30% was reported (partly verified, partly inference)

- Verified: the figure originates in `docs/features/potential/promoted/2026-10-08-powershell-aggregate-line-coverage-below-floor.md:35-52` (issue #847). It is "10/137 (7.30%)" for this file in CI run 36983551836 (run A), produced right after #527 (PR #821) widened the coverage population from 127 to 174 files. The #884 text cites CI run 38022356096, a later run.
- Verified: the same table lists `.claude/hooks/validate-feature-review-coverage.ps1` at 104/210 (49.52%), while the epic-852 and #896 baselines measured 98.62% for that file (`final-pester-coverage.md:20`). Both hooks therefore moved from low to high between the #847 report and the 2026-10-11 measurements.
- Verified: the Codex suite `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:4,13` is titled "coverage tests ... (issue #786)", so a dedicated coverage suite for this hook exists.
- Inference (not verified): the 7.30% figure came from a run that predated the `*.Coverage.Tests.ps1` suites, or from a run in which those suites did not reach the hook. Without `git log` access this researcher could not date the introduction of that suite. Supporting circumstance: the line total grew from 137 (run A) to 141 (2026-10-11) to 146 (post-#896), so the file also changed after the reported run.
- Conclusion: the 7.30% figure is stale and superseded; no uncovered-line analysis is needed.

## Test files covering each production file

Found by grepping `tests/` for the file names.

- `compute-concurrency-batches.sh` (bats, `tests/shell/`):
  - `compute_concurrency_batches_cli.bats` (the #884 usage and error paths)
  - `parallel_cohorts.bats`
  - `parallel_cohorts_parity.bats`
  - `parallel_payload_only.bats`
  - `parallel_bash_manifest_membership.bats`
- `.codex/hooks/validate-feature-review-coverage.ps1` (Pester, `tests/scripts/codex-hooks/`):
  - `validate-feature-review-coverage.Coverage.Tests.ps1` (primary coverage suite)
  - `feature-review-coverage-floor-parity.Tests.ps1`
  - `legacy-codex-hook-contracts.Tests.ps1`
  - `hook-dependency-failure.Codex.Tests.ps1`
  - `codex-bundle-hook-probe.Tests.ps1`

## Uncovered lines and tests needed

None. Both files report 100.00% line coverage on run 38683717593. The branch threshold does not apply to bash (kcov branch-rate was 1.0 on the earlier run) or to PowerShell (Pester has no branch measurement).

## Candidate approaches

1. **Evidence-only closure (recommended).** Record the CI measurements and the committed corroborating evidence under this feature folder's `evidence/` tree, then close #884 with a comment citing it. It meets the issue's expected outcome, adds no code, and matches the minor-audit work mode already set in `issue.md`.
2. **Add further tests to harden coverage.** Rejected: both files are at 100.00%, so extra tests would add no coverage and would exceed the issue's scope.

## Related follow-ups

- No follow-up that this item can fix was found. Both #884 files are resolved.
- Separate, pre-existing and out of scope: #847 (repository-wide PowerShell aggregate line coverage below the floor after the #527 population change) lists many other files. Its status was not re-checked here. It is not part of #884.
- Planning note: `plan.2026-10-15T07-41.md` is the unmodified template. Its Phase 2 (expect-fail regression test) and Phase 3 (minimal fix) do not apply to an evidence-only item and should be replaced with evidence-capture and verification tasks. Its `issue.md` is also unfilled template text (only `Work Mode: minor-audit` is set).

## Recommended work mode

`minor-audit`: evidence-only, with no production or test change.

## Proposed acceptance criteria for issue.md

- [ ] AC1: `.claude/lib/bash/compute-concurrency-batches.sh` per-file line coverage on main CI run 38683717593 (head f6915d429, kcov artifact `shell-coverage` cov.xml) is 100.00% (44/44 lines), at or above the 85% floor, with the figure recorded under `evidence/qa-gates/`.
- [ ] AC2: `.codex/hooks/validate-feature-review-coverage.ps1` per-file line coverage on the same run (Pester JaCoCo artifact `poshqc-test-results`, powershell-coverage.xml) is 100.00% (covered=146, missed=0), at or above the 85% floor, with the figure recorded under `evidence/qa-gates/`.
- [ ] AC3: The corroborating committed evidence is cited with file and line references: the #917 kcov record (81.82% to 100.00%), the epic #904 E4 / #896 Pester records (99.29% to 100.00%), and the explanation that the 7.30% figure is superseded.
- [ ] AC4: Neither production file is modified by this item (the diff against main touches only `docs/features/active/untouched-files-coverage-verification-884/`).
- [ ] AC5: Evidence artifacts live in the canonical `evidence/<kind>/` tree of the feature folder, with repository-relative paths and no absolute paths.
- [ ] AC6: Issue #884 is closed with a comment citing CI run 38683717593 and the evidence artifacts.
