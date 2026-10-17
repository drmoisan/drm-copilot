# Policy Audit (minor-audit) - Issue #884, bash half

- Timestamp: 2026-10-12T14-00
- Branch: bug/compute-concurrency-batches-coverage-884
- Reviewed head: 3fc983f03 (base main, merge-base 72ba7058b)
- Work mode: minor-audit (AC source: `issue.md` `## Acceptance Criteria`).
- Policies applied: CLAUDE.md, `.claude/rules/general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `shell.md`, `tonality.md`, plus the acceptance-criteria-tracking and evidence conventions.

## Executive Summary

The branch adds one bats test file, `tests/shell/compute_concurrency_batches_cli.bats` (50 lines), that exercises previously uncovered usage and error paths of `.claude/lib/bash/compute-concurrency-batches.sh`. The script is unchanged. Per-file kcov line coverage for the script rose from 81.82% to 100.00% in CI. All policy checks evaluated PASS. Two non-blocking findings are recorded (PA-NB-1, PA-NB-2). No blocking findings.

Verdict: PASS

## Rejected Scope Narrowing

None. The caller scoped the review to the bash half of #884 and declared the PowerShell half out of scope by operator decision. The branch diff contains no PowerShell file, so this does not narrow the audit of any language with changed files. The audit covers the full branch diff against origin/main.

## 1. General Unit Test Policy Compliance

| Check | Verdict | Evidence |
|---|---|---|
| Test location mirrors production | PASS | `tests/shell/compute_concurrency_batches_cli.bats` |
| No temporary files | PASS | Read of file: literal inputs only; static-check evidence agrees |
| Determinism | PASS | No clock, RNG, sleeps, or external services |
| AAA, descriptive names | PASS | See code-review |
| No production coverage exclusion | PASS | Diff changes no coverage configuration; no `exclude` entries added |

### 1.1 Coverage Requirements

Coverage: PASS. The only language with a changed file is bash (bats test file). The kcov line threshold is 85% and no bash branch gate applies. The production file exercised, `.claude/lib/bash/compute-concurrency-batches.sh`, reports 100.00% per-file line coverage (baseline 81.82%). No coverage exclusions were added.

### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: not applicable, no TypeScript file changed
- TypeScript post-change coverage artifact: not applicable, no TypeScript file changed
- PowerShell baseline coverage artifact: not applicable, no PowerShell file changed
- PowerShell post-change coverage artifact: not applicable, no PowerShell file changed
- Per-language comparison summary: not applicable for TypeScript, PowerShell, Python, and C# (zero changed files); bash (kcov) per-file coverage for `.claude/lib/bash/compute-concurrency-batches.sh` rose from 81.82% to 100.00% (threshold 85% line, no bash branch gate)

### 1.2.1 Per-Language Coverage Comparison

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 0 | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |
| Bash (kcov) | 1 (bats test file only) | 5 new cases | PASS (CI) | 81.82% (per file) | 100.00% (per file) | 100.00% (per file) |

- Bash (kcov): Baseline: 81.82%; Post-change: 100.00%; Change: +18.18 percentage points on `.claude/lib/bash/compute-concurrency-batches.sh`; New/changed-code coverage: 100.00% (only a test file changed and the production script is unchanged, so the changed-code figure equals the per-file figure); Disposition: PASS (threshold 85% line, no bash branch gate); Evidence: `evidence/qa-gates/ci-kcov-per-file-coverage.2026-10-12T13-16.md`

## 2. General Code Change Policy Compliance

| Check | Verdict | Evidence |
|---|---|---|
| 500-line limit | PASS | Bats file is 50 lines |
| No production behavior change | PASS | Script blob unchanged (`aa456265f35b756f606264cf4f203a4f6089bd1b`) |
| No policy file edited | PASS | Diff lists no path outside `tests/shell/` and the feature folder |
| Acceptance-criteria tracking: minor-audit AC source and check-off | PASS | `## Acceptance Criteria` in `issue.md`; 4 of 4 checked, each backed by evidence |
| Issue reference | PASS | Commits use "Refs #884" only; no closing keyword |

### Evidence Location Compliance

All evidence files live under `FEATURE/evidence/{baseline,regression-testing,qa-gates,other}/`. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears in the diff (`git diff --stat` file list). `validate_evidence_locations.py` was not run (no validator execution available to this reviewer). Verdict: PASS.

Evidence field check: every evidence file carries Timestamp, Command, EXIT_CODE, and Output Summary blocks (grep counts nonzero in all 14 files). `phase0-instructions-read.md` is an instructions-read record with a Timestamp but no Command/EXIT_CODE blocks and no timestamp in its filename; this is a non-blocking convention deviation (PA-NB-1).

### Absolute Path Check

A search of the feature folder for host-specific absolute path patterns (drive-letter, home-directory, and mount-point forms) returned no matches. PASS.

## 3. Language-Specific Code Change Policy Compliance

- Bash: `shell.md` tests live in `tests/shell/*.bats` with no temp files. PASS. shfmt and shellcheck: PASS (CI), step "Run shell-qc check (shfmt diff + shellcheck)" succeeded; not run locally by this reviewer.
- Python, PowerShell, TypeScript, C#: not applicable, no file of these languages changed.

## 4. Language-Specific Unit Test Policy Compliance

- Bash: the bats file follows `shell.md` (location under `tests/shell/`, no temporary files, literal inputs, descriptive `@test` names). PASS.
- Python, PowerShell, TypeScript, C#: not applicable, no file of these languages changed.

## 5. Test Coverage Detail

Shell (kcov, `artifacts/pester/kcov/cov.xml` from CI): repo-wide aggregate not read by this reviewer (job-log aggregate not used by the evidence). The new test file is under `tests/`, which is excluded from the denominator by policy. The only production file exercised, `.claude/lib/bash/compute-concurrency-batches.sh`, is unmodified; its per-file line coverage is 100.00% (>= 85%), no regression from 81.82% (CI run 38281234678). Per quality-tiers, no regression on changed lines: PASS (test-only change; per-file coverage rose by 18.18 pp). Bash has no branch gate.

Limit: the coverage artifact came from CI evidence recorded in the repository; no local kcov artifact exists and none was regenerated.

## 6. Test Execution Metrics

- Bats: job "Shell Coverage (Bats + kcov)" and step "Run shell-qc test with coverage" succeeded in CI run 38281234678 on head 9292d3d2b.
- All 17 required CI checks succeeded on 9292d3d2b.
- These results rely on CI evidence; this review did not rerun them.

## 7. Code Quality Checks

| Check | Verdict | Evidence |
|---|---|---|
| shfmt and shellcheck | PASS (CI) | CI step "Run shell-qc check (shfmt diff + shellcheck)" success; not run locally by this reviewer |
| Tone policy | PASS | Reviewed artifacts use neutral factual wording |

## 8. Gaps and Exceptions

No blocking findings.

Non-blocking findings:

- PA-NB-1: `evidence/baseline/phase0-instructions-read.md` lacks a filename timestamp and Command/EXIT_CODE/Output Summary fields. Informational record only.
- PA-NB-2: The `issue.md` Lifecycle record reference points to a file on another branch; the record is not in this branch. Disclosed in the document itself.

Limits: No validator tool was available to this reviewer. No sh, bash, pwsh, bats, kcov, or gh was run. CI evidence is taken from the orchestrator-supplied run 38281234678 (all 17 required checks success on head 9292d3d2b). The final-head CI gate is to be re-run by the orchestrator.

## 9. Summary of Changes

- Added `tests/shell/compute_concurrency_batches_cli.bats` (50 lines).
- All other changed paths are under the #884 feature folder (issue, plan, evidence, review artifacts).
- `.claude/lib/bash/compute-concurrency-batches.sh` is unchanged.

## 10. Compliance Verdict

All policy areas PASS. Blocking findings: 0. Non-blocking findings: 2 (PA-NB-1, PA-NB-2). No remediation required.

Verdict: PASS

## Appendix A: Test Inventory

- `tests/shell/compute_concurrency_batches_cli.bats`: five cases (`--help`, `-h`, `--keys` and `--max-concurrency` missing a value, unknown option); passed in CI.

## Appendix B: Toolchain Commands Reference

- Diff scope: `git diff --stat origin/main...HEAD`.
- Script-unchanged check: blob id comparison against baseline.
- Toolchain (CI evidence): shell-qc check (shfmt diff + shellcheck) and shell-qc test with coverage (bats + kcov).
- No command was run locally by this reviewer for sh, bash, pwsh, bats, kcov, or gh.
