# Policy Audit: epic-852-main-sync (issue #852)

- Timestamp: 2026-10-11T00-49
- Branch: `chore/epic-852-main-sync-852` @ `e0cbb9bc9`
- Base: `origin/epic/enforcement-hook-precision-integration` @ `8ee1b76e6` (merge base `8ee1b76e6`; base is an ancestor of PHASE0_HEAD `9add694e4`, verified with `git merge-base --is-ancestor`)
- Merge commit: `0ac05da8f` (parents `9add694e4` and `daa6436cd` = `origin/main`)
- Work Mode: `minor-audit`
- PR context: `artifacts/pr_context.summary.txt` generated 2026-10-11 04:45:27 UTC for head `e0cbb9bc9` (current; not regenerated)

## Executive Summary

The branch-authored content (merge conflict resolution, the guarded thresholds dot-source in both Claude hook copies, the new ThresholdsGuard Pester suite, the Issue824 suite isolation restructure, and feature-folder evidence) complies with the general code change, general unit test, PowerShell, and tonality policies. The merge commit introduces no line that is absent from both parents (`git diff-tree --cc 0ac05da8f` contains zero `++` lines). PowerShell coverage was independently re-parsed from `artifacts/pester/powershell-coverage.xml`: repo-wide line coverage 90.43%, changed files 98.62% and 100.00%.

Per the Scope Invariant, the audit scope is the full branch diff against the resolved base (1,559 changed paths, including 278 commits from `origin/main`). That diff contains TypeScript (34 production `.ts` files), Python (13 production `.py` files) and bash (16 `.sh` files) changes that arrived through the merge from `main`. No TypeScript, Python, or bash coverage artifact exists in the workspace (`coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/kcov/cov.xml` are absent). Those three coverage rows are therefore recorded as FAIL. These are the only blocking findings; they are evidence gaps, not observed coverage defects, and the content concerned was reviewed and merged on `main` before this sync.

Blocking findings: 3 (TypeScript, Python, and bash coverage artifacts absent).

## Rejected Scope Narrowing

- Caller text (verbatim): "The diff against the base therefore contains all of main's already-reviewed, already-merged changes. Review the branch-authored content only:"
  - Justification: the Scope Invariant fixes the audit scope at the full branch diff against the resolved base; code-quality review depth is focused on branch-authored content, but coverage verdicts are recorded for every language with changed files in that diff.

## Evidence Location Compliance

- `git diff --name-only 8ee1b76e6 e0cbb9bc9 -- artifacts/baselines artifacts/qa artifacts/evidence artifacts/coverage`: no output (no non-canonical evidence file on the branch).
- `python -I scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0, no violations reported.
- All feature evidence lives under `docs/features/active/epic-852-main-sync/evidence/{baseline,other,qa-gates,regression-testing}/`. Verdict: PASS.
- No absolute host paths appear in the feature folder (Grep for `C:[/\\]Users|DanMoisan`: 0 matches).

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | ThresholdsGuard TG1-TG3 reset `$script:HookDependencyFailures` and `$script:HookDependencyGuardLoadFailed` in `finally` (`Initialize-ThresholdsGuardDependencyState`); TG1 restores `[Console]::Error` and `CLAUDE_HOOK_INPUT` in `finally`. The Issue824 restructure moves the hook dot-source to a file-level `BeforeAll` with `$null` mocks so the suite no longer reaches real artifact reads by default (#737 isolation shape). |
| Isolation | PASS | Each TG case fails only the `feature-review-coverage-thresholds.ps1` dot-source via `Mock Join-Path -ParameterFilter { $ChildPath -eq '...' }`. |
| Fast execution | PASS | Targeted suite: 6 passed (`evidence/qa-gates/p2-thresholds-guard.md`). |
| Determinism | PASS | No clock, RNG, sleep, network, or process start in the changed tests. |
| Readability | PASS | Arrange/Act/Assert comments in every `It`; descriptive `TG1`/`TG2`/`TG3` names with `<Copy>` parameterization. |
| No temporary files | PASS | New suite states and implements "No test creates, renames, moves, or deletes a file". |

### 1.2 Coverage Requirements

Coverage artifact parsed by the reviewer: `artifacts/pester/powershell-coverage.xml` (written 2026-10-11 00:37 local, after code commit `8cf45ada7` at 00:20; source paths resolve to this worktree).

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 30 `.ps1` + 11 `.psm1` (branch diff); 2 branch-authored hook copies | 9784 passed, 0 failed, 10 skipped (full Pester run) | PASS | 87.97% repo line (XML LINE counter, P0) | 90.43% repo line (reviewer re-parse) | 98.62% `.claude/hooks/validate-feature-review-coverage.ps1`; 100.00% `.claude/hooks/feature-review-coverage-thresholds.ps1`; changed line 47 covered (ci=3, mi=0) |
| TypeScript | 34 production `.ts` + 31 test `.ts` (via merge from main) | not executed in this review | FAIL | N/A (coverage/lcov.info absent from workspace) | N/A (coverage/lcov.info absent from workspace) | N/A (coverage/lcov.info absent from workspace) |
| Python | 13 production `.py` + 31 test `.py` (via merge from main) | 33 passed (guard subset only, `evidence/qa-gates/final-pytest-guards.md`) | FAIL | N/A (artifacts/python/lcov.info absent from workspace) | N/A (artifacts/python/lcov.info absent from workspace) | N/A (artifacts/python/lcov.info absent from workspace) |
| Bash | 16 `.sh` + 12 `.bats` (via merge from main) | not executed in this review | FAIL | N/A (artifacts/pester/kcov/cov.xml absent from workspace) | N/A (artifacts/pester/kcov/cov.xml absent from workspace) | N/A (artifacts/pester/kcov/cov.xml absent from workspace) |
| C# | 0 | 0 | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) |

Evidence checklist:

- TypeScript baseline coverage artifact: none in workspace; `coverage/lcov.info` absent (FAIL, remediation trigger RT-1)
- TypeScript post-change coverage artifact: none in workspace; `coverage/lcov.info` absent (FAIL, remediation trigger RT-1)
- PowerShell baseline coverage artifact: `evidence/baseline/p0-pester-coverage.md` (87.97% XML line, 87.07% command)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` re-parsed by reviewer (90.43% line); recorded in `evidence/qa-gates/final-pester-coverage.md`
- Per-language comparison summary: PowerShell 87.97% -> 90.43% (+2.46 points) PASS; TypeScript, Python, bash FAIL (no artifact)

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 87.97% repo line; Post-change: 90.43% repo line; Change: +2.46 points repo-wide, `.claude/hooks/validate-feature-review-coverage.ps1` 97.22% -> 98.62%; New/changed-code coverage: 98.62% (hook), 100.00% (thresholds file, new via merge), guarded line 47 covered; Disposition: PASS; Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-comparison.md`
- TypeScript: Baseline: N/A; Post-change: N/A; Change: not measurable, no artifact in workspace; Disposition: FAIL; Evidence: `coverage/lcov.info` absent, coverage artifact absent for TypeScript; coverage verification is mandatory for all languages with changed files
- Python: Baseline: N/A; Post-change: N/A; Change: not measurable, no artifact in workspace; Disposition: FAIL; Evidence: `artifacts/python/lcov.info` absent, coverage artifact absent for Python; coverage verification is mandatory for all languages with changed files
- Bash: Baseline: N/A; Post-change: N/A; Change: not measurable, no artifact in workspace; Disposition: FAIL; Evidence: `artifacts/pester/kcov/cov.xml` absent, coverage artifact absent for bash; coverage verification is mandatory for all languages with changed files

PowerShell is not branch-capable (Pester measures command and line coverage only); no branch threshold applies.

### 1.3 Scenario Completeness

| Scenario | Verdict | Evidence |
|---|---|---|
| Negative flow (dependency load failure) | PASS | TG1 (process route, exit 2, stderr prefix and dependency name), TG2 (recorded failure, no throw), TG3 (decision function returns ExitCode 2). |
| Positive flow (dependency loads) | PASS | Existing Coverage, Tests and Issue824 suites run against the guarded hook: AC 3 scoped run 6461 passed, 0 failed (`evidence/qa-gates/final-ac3-pester.md`). |
| Fail-before / pass-after | PASS | `evidence/regression-testing/p2-thresholds-guard-fail-before.md` (6 failed against unguarded hook) and `evidence/qa-gates/p2-thresholds-guard.md` (6 passed). |
| Both copies | PASS | Every TG case runs for the Claude copy and the bundle mirror via `-ForEach`. |

### 1.4 Test Location

PASS. New suite is at `tests/scripts/claude-hooks/`, the established location for `.claude/hooks` suites; no test in a production tree.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | One-line change per hook copy, identical in form to existing 786 guards (e.g. `.claude/hooks/enforce-completion-consistency.ps1:55`). |
| Fail fast / no silent error swallow | PASS | The catch records the failure via `Add-HookDependencyFailure`; the decision function (line 351) and the script tail (lines 467-469) block with exit 2. |
| File size <= 500 lines | PASS | Hook copies 477 lines each; ThresholdsGuard suite 121; Issue824 suite 289; thresholds file 77. |
| No Python in hooks | PASS | `git ls-files '*hooks/*.py'` returns only a converter test fixture (`tests/fixtures/codex_native_converter/...`), not a hook; added hook lines contain no `python`/`poetry`. |
| No new dependency | PASS | No package manifest change in the branch-authored commits. |
| Mirror parity | PASS | Blob `814104838` for both Claude hook copies; `eb343cfb5` for both thresholds copies; `49f8f70ea` for both Codex copies (`git ls-files -s`). |
| Merge introduces only the union of parents | PASS | `git diff-tree --cc 0ac05da8f`: 0 lines new relative to both parents; combined hunks only in the two hook copies (auto-merge of adjacent lines) and `core.json` (resolved conflict). |
| No breaking API change | PASS | No public signature changed. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell (`.claude/rules/powershell.md`):

- PSScriptAnalyzer: 0 findings on the four branch-authored PowerShell files (`evidence/qa-gates/final-poshqc-analyze.md`). PASS.
- Formatting: 0 files reformatted, porcelain unchanged (`evidence/qa-gates/final-poshqc-format.md`). PASS.
- Type checking: not applicable to PowerShell.
- Guard ordering: the guarded dot-source (line 47) precedes `$ErrorActionPreference = 'Stop'` (line 49), so a missing `Add-HookDependencyFailure` (guard load failure) produces a statement-terminating error and execution reaches the line-467 fail-closed exit. PASS.

TypeScript, Python, bash: no branch-authored changes; files arrived through the merge from `main`. Their toolchain results are inherited from `main` and from the PR CI run (AC 5, pending).

## 4. Language-Specific Unit Test Policy Compliance

- Pester 5 `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` present. PASS.
- Mocks scoped inside `It`; file-level `BeforeAll` mocks follow the reference isolation shape used by `hook-dependency-failure.Claude.Tests.ps1`. PASS.
- `#737` isolation guard passes (`evidence/qa-gates/p2-isolation-guard.md`). PASS.

## 5. Test Coverage Detail

| File | Status | Baseline | Post-change | Threshold | Verdict |
|---|---|---|---|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1` | modified (merge + guard) | 97.22% | 98.62% (215/218) | >= 85% line, no regression | PASS |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` | new via merge | none | 100.00% (21/21) | >= 85% line | PASS |
| `.codex/hooks/validate-feature-review-coverage.ps1` | unchanged | 99.29% | 99.29% | >= 85% line | PASS |
| bundle mirror of the Claude hook | modified | outside coverage roots | byte-identical to measured copy | parity | PASS |
| PowerShell repo-wide | - | 87.97% | 90.43% | >= 85% line | PASS |
| TypeScript repo-wide | - | none | none | >= 85% line, >= 75% branch | FAIL (artifact absent) |
| Python repo-wide | - | none | none | >= 85% line, >= 75% branch | FAIL (artifact absent) |
| Bash repo-wide | - | none | none | >= 85% line | FAIL (artifact absent) |

## 6. Test Execution Metrics

- Full Pester run: 9784 passed, 0 failed, 10 skipped (`evidence/qa-gates/final-pester-coverage.md`).
- AC 3 scoped run (`tests/scripts/claude-runtime`, `claude-hooks`, `codex-hooks`): baseline 6421 passed; post-merge pre-fix 6447 passed / 7 failed (expected); final 6461 passed / 0 failed.
- Pytest guard subset: 33 passed (`evidence/qa-gates/final-pytest-guards.md`).

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Format (PowerShell) | PASS |
| Lint (PSScriptAnalyzer) | PASS, 0 findings |
| Architecture boundaries | Not affected by branch-authored change |
| Contract/schema | `core.json` entry set equals union (216 = 216), JSON parses |

## 8. Gaps and Exceptions

- G-1 (blocking): TypeScript coverage artifact absent for 34 changed production files.
- G-2 (blocking): Python coverage artifact absent for 13 changed production files.
- G-3 (blocking): bash coverage artifact absent for 16 changed `.sh` files.
- Assumption: TypeScript, Python, and bash changes are byte-identical to `origin/main` (`daa6436cd`); the reviewer did not re-review their code quality.

## 9. Summary of Changes

- Merge of `origin/main` into the integration-sync branch, conflict resolved in `pack-manifests/core.json`.
- Guarded thresholds dot-source in `.claude/hooks/validate-feature-review-coverage.ps1` and its bundle mirror.
- New suite `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`.
- Issue824 suite isolation restructure.
- Feature-folder plan, issue, and evidence.

## 10. Compliance Verdict

PARTIAL. Branch-authored content: PASS. Full-branch coverage verification: FAIL for TypeScript, Python, and bash because no coverage artifact is present. Blocking findings: 3.

## Appendix A: Test Inventory

| Suite | Cases | Result |
|---|---|---|
| `validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` (new) | 6 (TG1-TG3 x 2 copies) | 6 passed |
| `validate-feature-review-coverage.Issue824.Tests.ps1` (modified) | unchanged `It` set | passed in AC 3 run |
| `hook-dependency-guard-completeness.Tests.ps1` | completeness rows incl. S2 | passed (failed pre-fix as expected) |
| AC 3 scoped Pester set | 6461 | passed |

## Appendix B: Toolchain Commands Reference

- `git diff-tree --cc 0ac05da8f` (merge union check)
- `git diff 9add694e4 0ac05da8f -- <core.json>`; `git diff daa6436cd 0ac05da8f -- <core.json>`
- `git ls-files -s '*validate-feature-review-coverage.ps1' '*feature-review-coverage-thresholds.ps1'` (parity)
- `python -I <scratchpad>/cov.py artifacts/pester/powershell-coverage.xml <files>` (JaCoCo re-parse)
- `python -I scripts/dev_tools/validate_evidence_locations.py --root .`
- Executor commands as recorded in `evidence/qa-gates/*.md`
