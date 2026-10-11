# Policy Audit: epic-852-main-sync (issue #852)

- Timestamp: 2026-10-11T01-33
- Review type: reaudit after remediation cycle 1 (prior artifacts `*.2026-10-11T00-49.md`, 3 blocking findings RT-1..RT-3)
- Branch: `chore/epic-852-main-sync-852` @ `a878d6b18`
- Base: `origin/epic/enforcement-hook-precision-integration` @ `8ee1b76e6` (merge base `8ee1b76e6`)
- Merge commit: `0ac05da8f` (parents `9add694e4` and `daa6436cd`; `origin/main` still resolves to `daa6436cd`)
- Work Mode: `minor-audit`
- PR context: `artifacts/pr_context.summary.txt` generated 2026-10-11 05:29:13 UTC for head `a878d6b18` (current; range `8ee1b76e6..a878d6b18`; not regenerated)

## Executive Summary

The three blocking findings from the 2026-10-11T00-49 review were coverage-artifact gaps for TypeScript, Python, and bash. All four coverage artifacts now exist in the workspace, and the reviewer re-parsed each one independently with a scratchpad parser (results below). Every language with changed files on the branch meets the uniform thresholds repo-wide and per changed production file:

- TypeScript: 97.25% line (51131/52575), 92.08% branch (7532/8180); 34/34 changed production files PASS.
- Python: 93.80% line (16539/17633), 88.10% branch (5607/6364); 13/13 changed production files PASS.
- PowerShell: 90.43% line (16116/17821); 14/14 changed canonical production files PASS.
- bash: 94.50% line (3049/3225); 8/8 changed canonical `.sh` files PASS.

No source file changed after the prior review (`git diff --stat e0cbb9bc9..HEAD -- . ':(exclude)docs'` is empty). The commits since then (`d1211a7ae`, `308fca553`, `6f4d48f5e`, `a878d6b18`) touch only the feature folder. The branch-authored code (merge resolution in `core.json`, guarded thresholds dot-source, ThresholdsGuard suite, Issue824 isolation restructure) is unchanged and still compliant.

Blocking findings: 0. RT-1, RT-2, and RT-3 are resolved.

## Rejected Scope Narrowing

- Caller text (verbatim): "the branch-authored changes are the merge resolution in pack-manifests/core.json and the post-merge commits 0ac05da8f..HEAD"
  - Justification: this sentence is accepted only as guidance on where to focus code-quality review depth. The audit scope stays the full branch diff `8ee1b76e6..a878d6b18` (1,580 paths), and coverage verdicts are recorded for every language with changed files in it.

## Evidence Location Compliance

- Scan of `git diff --name-status 8ee1b76e6..HEAD` for paths under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: 0 matches.
- `python -I scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0, no violations reported.
- Remediation-cycle evidence is under `docs/features/active/epic-852-main-sync/evidence/{qa-gates,other,remediation-baseline}/`. Coverage outputs (`coverage/`, `artifacts/python/`, `artifacts/pester/`) are gitignored tool outputs, not committed evidence. Verdict: PASS.
- No absolute host path appears in the remediation evidence (a Grep for the user-profile path prefix matches only the prior policy audit's own grep-pattern text).

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Unchanged since prior review. ThresholdsGuard TG1-TG3 reset dependency-failure state and console redirection in `finally`; the Issue824 suite uses a file-level `BeforeAll` with `$null` default mocks. |
| Isolation | PASS | Each TG case fails only the thresholds dot-source via `Mock Join-Path -ParameterFilter`. |
| Fast execution | PASS | Targeted suite 6 passed (`evidence/qa-gates/p2-thresholds-guard.md`). |
| Determinism | PASS | No clock, RNG, sleep, network, or process start in the changed tests. |
| Readability | PASS | Arrange/Act/Assert comments in every `It`; `<Copy>`-parameterized names. |
| No temporary files | PASS | The suite creates, renames, moves, and deletes no file. |

### 1.2 Coverage Requirements

The reviewer re-parsed all four artifacts. Freshness:

- `coverage/lcov.info` (01:19 local, 212 `SF:` records; extension Jest project).
- `artifacts/python/lcov.info` (01:23 local, 214 `SF:` records = all 214 tracked files under `scripts/dev_tools`, the configured `[tool.coverage.run] source`).
- `artifacts/pester/kcov/cov.xml` (CI run `38112992719`, head `d1211a7ae`; reviewer confirmed via `gh run view`: `completed success`, 17/17 jobs success).
- `artifacts/pester/powershell-coverage.xml` (00:37 local, after fix commit `8cf45ada7` at 00:20).

No source file differs between `8cf45ada7`/`d1211a7ae` and `a878d6b18`, so each artifact represents the current head's source.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 34 production `.ts` + 31 test `.ts` (via merge from main) | 267 suites / 3981 tests (`evidence/qa-gates/rt1-jest-coverage.md`) | PASS | N/A (no base-branch artifact; TS sources byte-identical to `origin/main` `daa6436cd`) | 97.25% line, 92.08% branch (reviewer re-parse) | 34/34 changed files >= 85% line and >= 75% branch; lowest line 87.08% (`render-pr-helpers.ts`), lowest branch 84.78% (`engine-pipeline.ts`); new file `string-ordering.ts` 100.00% / 100.00% |
| Python | 13 production `.py` + 31 test `.py` (via merge from main) | full pytest run with `--cov=scripts.dev_tools --cov-branch` (`evidence/qa-gates/rt2-pytest-coverage.md`) | PASS | N/A (no base-branch artifact; production `.py` byte-identical to `origin/main` `daa6436cd`) | 93.80% line, 88.10% branch (reviewer re-parse) | 13/13 changed files >= 85% line and >= 75% branch; lowest line 91.76% (`validate_epic_planner_state.py`), lowest branch 83.33% (`push_down_claude_pack_selection.py`); new file `push_down_claude_gitignore_merge.py` 100.00% / 100.00% |
| PowerShell | 20 production `.ps1`/`.psm1` (14 canonical + 6 byte-identical bundle mirrors) plus test files | 9784 passed, 0 failed, 10 skipped (`evidence/qa-gates/final-pester-coverage.md`) | PASS | 87.97% repo line (P0 baseline) | 90.43% repo line (reviewer re-parse) | 14/14 canonical changed files >= 85% line; hook 98.62% (215/218), thresholds file 100.00% (21/21) |
| Bash | 8 canonical `.sh` + 7 byte-identical bundle mirrors + 1 test fixture (via merge from main) | CI `shell-coverage` job (Bats + kcov) success, run `38112992719` | PASS | N/A (no base-branch artifact; `.sh` files byte-identical to `origin/main` `daa6436cd`) | 94.50% line (reviewer re-parse of `cov.xml`) | 8/8 canonical changed files >= 85% line; lowest 87.27% (`cleanup_worktrees_scan_helper.sh`); new files `parallel-mutation.sh` 95.71%, `remove-parallel-item.sh` 99.12% |
| C# | 0 | 0 | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) |

Evidence checklist:

- TypeScript baseline coverage artifact: no base-branch lcov exists; the merged TS sources and Jest config are byte-identical to `origin/main` `daa6436cd` (`evidence/remediation-baseline/r0-main-identity.md`, reviewer re-confirmed with `git diff --name-only daa6436cd HEAD -- extensions/drm-copilot/src`, empty output)
- TypeScript post-change coverage artifact: `coverage/lcov.info`, reviewer re-parse 97.25% line / 92.08% branch, 34/34 changed production files PASS
- PowerShell baseline coverage artifact: `evidence/baseline/p0-pester-coverage.md` (87.97% XML line)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, reviewer re-parse 90.43% line
- Per-language comparison summary: TypeScript PASS, Python PASS, PowerShell PASS (+2.46 points), bash PASS; C# has no changed files

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: no base-branch figure (sources byte-identical to `origin/main`); Post-change: 97.25% line, 92.08% branch; Change: not computable against the base branch; every changed production file meets the absolute thresholds, and all 92 per-file `coverageThreshold` keys in `extensions/drm-copilot/jest.config.cjs` meet their configured values; New/changed-code coverage: 34/34 files >= 85% line (lowest 87.08%) and >= 75% branch (lowest 84.78%); Disposition: PASS; Evidence: `coverage/lcov.info`, `evidence/qa-gates/rt1-ts-figures.md`
- Python: Baseline: no base-branch figure (production files byte-identical to `origin/main`); Post-change: 93.80% line, 88.10% branch; Change: not computable against the base branch; every changed production file meets the absolute thresholds; New/changed-code coverage: 13/13 files >= 85% line (lowest 91.76%) and >= 75% branch (lowest 83.33%); Disposition: PASS; Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/rt2-py-figures.md`
- PowerShell: Baseline: 87.97% repo line; Post-change: 90.43% repo line; Change: +2.46 points repo-wide, `.claude/hooks/validate-feature-review-coverage.ps1` 97.22% -> 98.62%; New/changed-code coverage: 98.62% (hook), 100.00% (thresholds file); Disposition: PASS; Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-comparison.md`
- Bash: Baseline: no base-branch figure (`.sh` files byte-identical to `origin/main`); Post-change: 94.50% line; Change: not computable against the base branch; every changed canonical file meets the line threshold; New/changed-code coverage: 8/8 files >= 85% line (lowest 87.27%); Disposition: PASS; Evidence: `artifacts/pester/kcov/cov.xml` (CI run 38112992719), `evidence/qa-gates/rt3-bash-coverage.md`, `evidence/other/rt3-ci-run.md`

PowerShell (Pester) and bash (kcov) do not measure branch coverage; no branch threshold applies to them. The kcov `branch-rate="1.0"` attribute is a fixed placeholder and is not evaluated.

### 1.2.2 Jest Exit-Code Deviation

The remediation Jest run (`npx jest --config extensions/drm-copilot/jest.config.cjs --coverage ...` from the workspace root) exited 1 with 267/267 suites and 3981/3981 tests passing. Assessment:

- Cause: Jest resolves each per-file `coverageThreshold` key (`./src/...`) against the process working directory. From the workspace root the 92 keys resolve to `<root>/src/...`, which match no measured file, and Jest reports "Coverage data ... was not found" for each one. The repository's own script (`npm run test:coverage`, `node run-jest.cjs`) runs from `extensions/drm-copilot/`, where the keys resolve.
- Effect on verdict: none. Because Jest did not evaluate the thresholds in that run, the reviewer evaluated all 92 keys against `coverage/lcov.info` (scratchpad `thr.py`): 92 keys, 0 not found, 0 below the configured lines/branches/functions/statements values. The PR CI extension jobs (`drm-copilot Extension Tests`, ubuntu-latest and windows-latest) passed on run `38112992719` for a head with an identical source tree.
- Disposition: non-blocking observation (see section 8, G-1).

### 1.3 Scenario Completeness

| Scenario | Verdict | Evidence |
|---|---|---|
| Negative flow (dependency load failure) | PASS | TG1 (process route, exit 2), TG2 (recorded failure, no throw), TG3 (decision ExitCode 2). |
| Positive flow (dependency loads) | PASS | AC 3 scoped run 6461 passed, 0 failed (`evidence/qa-gates/final-ac3-pester.md`). |
| Fail-before / pass-after | PASS | `evidence/regression-testing/p2-thresholds-guard-fail-before.md` (6 failed) and `evidence/qa-gates/p2-thresholds-guard.md` (6 passed). |
| Both copies | PASS | Each TG case runs for the Claude copy and the bundle mirror. |

### 1.4 Test Location

PASS. The new suite is in `tests/scripts/claude-hooks/`. No test file is in a production tree.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | One-line guard change per hook copy, in the same form as existing 786 guards. |
| Fail fast / no silent error swallow | PASS | Line 47's catch records the failure via `Add-HookDependencyFailure`; line 351 (decision function) and lines 467-468 (script tail) block with exit 2. |
| File size <= 500 lines | PASS | Hook 477, thresholds 77, ThresholdsGuard suite 121, Issue824 suite 289 (`wc -l`). |
| No Python in hooks | PASS | The hook's `Python` occurrences are coverage-language labels and artifact paths, not interpreter invocations. |
| No new dependency | PASS | No package manifest change in the branch-authored commits. |
| Mirror parity | PASS | Byte-equal (md5/`cmp`) Claude vs bundle: hook, thresholds file, 4 changed `.claude/lib` PowerShell modules, 6 `.sh` files; Codex vs bundle: hook and `codex-web-setup.sh`. |
| Merge introduces only the union of parents | PASS | `git diff-tree --cc 0ac05da8f`: 0 lines new to both parents. |
| Coverage exclusion policy | PASS | No `omit`, `exclude`, `coveragePathIgnorePatterns`, or `collectCoverageFrom` change on the branch; `pyproject.toml` omits only test and cache paths. |
| No breaking API change | PASS | No public signature changed. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell (`.claude/rules/powershell.md`):

- PSScriptAnalyzer: 0 findings on the four branch-authored PowerShell files (`evidence/qa-gates/final-poshqc-analyze.md`). PASS.
- Formatting: 0 files reformatted (`evidence/qa-gates/final-poshqc-format.md`). PASS.
- Guard ordering: the guarded dot-source (line 47) precedes `$ErrorActionPreference = 'Stop'` (line 49). PASS.

TypeScript, Python, bash: no branch-authored changes. The files are byte-identical to `origin/main` `daa6436cd`, apart from two Python test files that carry integration-side content. CI run `38112992719` (17/17 success) ran their format, lint, type-check, and test jobs on an identical source tree. PASS.

## 4. Language-Specific Unit Test Policy Compliance

- Pester 5 `#Requires` present in the new suite. PASS.
- Mocks follow the reference isolation shape; the #737 isolation guard passes (`evidence/qa-gates/p2-isolation-guard.md`). PASS.
- TypeScript, Python, bash tests: inherited from `main`; CI jobs pass. PASS.

## 5. Test Coverage Detail

| File / scope | Status | Baseline | Post-change | Threshold | Verdict |
|---|---|---|---|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1` | modified | 97.22% | 98.62% (215/218) | >= 85% line, no regression | PASS |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` | new via merge | none | 100.00% (21/21) | >= 85% line | PASS |
| `.codex/hooks/validate-feature-review-coverage.ps1` | unchanged | 99.29% | 99.29% (140/141) | >= 85% line | PASS |
| Other 12 canonical changed PowerShell files | via merge | none | 94.74%-100.00% | >= 85% line | PASS |
| PowerShell repo-wide | - | 87.97% | 90.43% | >= 85% line | PASS |
| TypeScript repo-wide | - | none | 97.25% line / 92.08% branch | >= 85% / >= 75% | PASS |
| TypeScript changed production files (34) | via merge | none | min 87.08% line / 84.78% branch | >= 85% / >= 75% | PASS |
| Python repo-wide (`scripts/dev_tools`) | - | none | 93.80% line / 88.10% branch | >= 85% / >= 75% | PASS |
| Python changed production files (13) | via merge | none | min 91.76% line / 83.33% branch | >= 85% / >= 75% | PASS |
| bash repo-wide | - | none | 94.50% line | >= 85% line | PASS |
| bash changed canonical files (8) | via merge | none | min 87.27% line | >= 85% line | PASS |

Per-file rows (reviewer re-parse; full list in the scratchpad output summarized here):

- PowerShell: `BlastRadiusExtraction.psm1` 100.00%, `BlastRadiusTokenShape.psm1` 100.00%, `Invoke-CiGateParser.ps1` 97.83%, `OrchestratorStateIssueAdoption.psm1` 100.00%, `HostBootstrap.psm1` 100.00%, `HostBootstrapWorkspace.psm1` 100.00%, `HostTooling.psm1` 94.74%, `HostVerification.psm1` 100.00%, `SideloadedExtensionPublish.psm1` 97.84%, `bootstrap-host.ps1` 100.00%, `publish-sideloaded-extension.ps1` 100.00%, `verify-host.ps1` 100.00%.
- bash: `parallel-cohorts.sh` 99.27%, `parallel-mutation.sh` 95.71%, `remove-parallel-item.sh` 99.12%, `cleanup_worktrees_detached_lib.sh` 100.00%, `cleanup_worktrees_enumerate_lib.sh` 95.38%, `cleanup_worktrees_scan_helper.sh` 87.27%, `.codex/codex-web-setup.sh` 95.67%, `scripts/bash/shell_qc_lib.sh` 90.53%.

## 6. Test Execution Metrics

- Jest (extension): 267/267 suites, 3981/3981 tests passed; process exit 1 attributable to threshold-key resolution only (section 1.2.2).
- Pytest with coverage: as recorded in `evidence/qa-gates/rt2-pytest-coverage.md`; artifact totals 93.80% / 88.10%.
- Pester full run: 9784 passed, 0 failed, 10 skipped.
- AC 3 scoped Pester run: 6461 passed, 0 failed.
- CI run `38112992719` on `d1211a7ae`: 17/17 jobs success (reviewer-verified via `gh run view`).

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Format (PowerShell) | PASS |
| Lint (PSScriptAnalyzer) | PASS, 0 findings |
| TS/Python/bash format, lint, type | PASS in CI run 38112992719 (identical source tree) |
| Architecture boundaries | Not affected by branch-authored change |
| Contract/schema | `core.json` parses as JSON (reviewer `json.load`); entry set equals union of parents |

## 8. Gaps and Exceptions

- G-1 (non-blocking): the RT-1 Jest invocation ran from the workspace root, so Jest did not apply the per-file `coverageThreshold` keys and exited 1. The reviewer evaluated all 92 keys manually (0 below threshold), so the verdict is unaffected. For future evidence runs, use the extension's own script (`npm --prefix extensions/drm-copilot run test:coverage`), or run from `extensions/drm-copilot/` and copy the lcov output.
- G-2 (non-blocking): for TypeScript, Python, and bash, no base-branch coverage figure exists, so "no regression on changed lines" cannot be computed as a delta. Every changed production file meets the absolute thresholds, and the content is byte-identical to `origin/main`, which enforces the same per-file thresholds in CI.
- G-3 (non-blocking, informational): `evidence/qa-gates/rt-verdicts.md` has `Timestamp: 2026-10-11T01-46`, later than the local wall clock at this review (01-33). `evidence/other/rt3-ci-run.md` uses a UTC-like stamp (05-11). The stamps are inconsistent with each other; content is unaffected.
- Assumption: TypeScript, Python, and bash code quality was not re-reviewed in depth because the content is byte-identical to `main` (`daa6436cd`).

## 9. Summary of Changes

- Since the prior review: feature-folder documents only (remediation plan, RT-3 CI run record, RT-1..RT-3 coverage evidence, push record). No source, test, or configuration change.
- Branch overall: merge of `origin/main` with the `core.json` conflict resolved; guarded thresholds dot-source in the Claude hook and bundle mirror; new ThresholdsGuard suite; Issue824 suite isolation restructure; feature-folder evidence.

## 10. Compliance Verdict

PASS. Every changed language (TypeScript, Python, PowerShell, bash) has an explicit coverage PASS backed by figures the reviewer re-parsed. Branch-authored content complies with policy. Blocking findings: 0. Non-blocking observations: 3 (G-1 to G-3).

## Appendix A: Test Inventory

| Suite | Cases | Result |
|---|---|---|
| `validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` (new) | 6 | 6 passed |
| `validate-feature-review-coverage.Issue824.Tests.ps1` (modified) | unchanged `It` set | passed in AC 3 run |
| AC 3 scoped Pester set | 6461 | passed |
| Extension Jest project | 3981 | passed |
| CI run 38112992719 | 17 jobs | all success |

## Appendix B: Toolchain Commands Reference

- `git diff --stat e0cbb9bc9..HEAD -- . ':(exclude)docs'` (no source change since prior review; empty)
- `git diff --name-status 8ee1b76e6..HEAD` (full branch diff, 1,580 paths)
- `git diff-tree --cc 0ac05da8f` (merge union check)
- `git diff --name-only daa6436cd HEAD -- '*.py' '*.sh' extensions/drm-copilot/src` (identity with main; two Python test files only)
- `python -I <scratchpad>/cov.py <root> <scratchpad>/ns.txt` (lcov, Cobertura, and JaCoCo re-parse; repo-wide and per changed file)
- `python -I <scratchpad>/thr.py <root>` (evaluation of the 92 Jest per-file threshold keys against `coverage/lcov.info`)
- `gh run view 38112992719 --json status,conclusion,headSha,headBranch,jobs`
- `python -I scripts/dev_tools/validate_evidence_locations.py --root .`
- `cmp` / `md5sum` mirror parity checks
