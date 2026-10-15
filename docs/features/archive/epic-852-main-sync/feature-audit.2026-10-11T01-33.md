# Feature Audit: epic-852-main-sync (issue #852)

- Timestamp: 2026-10-11T01-33
- Review type: reaudit after remediation cycle 1
- Work Mode: `minor-audit` (marker `- Work Mode: minor-audit` in `issue.md`)
- AC source: `docs/features/active/epic-852-main-sync/issue.md`, section `## Acceptance Criteria`

## Scope and Baseline

- Base: `origin/epic/enforcement-hook-precision-integration` @ `8ee1b76e6` (merge base); head `a878d6b18`; full diff 1,580 paths.
- Merge commit `0ac05da8f`: parents `9add694e4` (integration tip plus Phase 0 evidence) and `daa6436cd` (`origin/main`; still the tip at review time).
- Post-merge commits: `2b28c2946`, `8cf45ada7` (guard fix and tests), `8fa060b7a`, `e0cbb9bc9`, then remediation cycle 1 `d1211a7ae`, `308fca553`, `6f4d48f5e`, `a878d6b18` (feature-folder documents only).
- Baseline evidence: `evidence/baseline/` (pre-merge AC 3 run 6421 passed) and `evidence/remediation-baseline/` (remediation inputs, head, main identity).
- Prior review: `*.2026-10-11T00-49.md` with 3 blocking coverage-artifact findings (RT-1 TypeScript, RT-2 Python, RT-3 bash). All three are resolved in this reaudit (see `policy-audit.2026-10-11T01-33.md`).

## Acceptance Criteria Inventory

| AC | Criterion (abridged) | State in issue.md before review |
|---|---|---|
| AC 1 | origin/main merged with a merge commit; no rebase, no force-push | checked |
| AC 2 | `core.json` conflict resolved keeping all three entries in sorted order; further conflicts recorded | checked |
| AC 3 | 786 completeness, exemption guard and FailClosed, bundle-parity, Claude and Codex hook Pester suites pass on merged tree; before and after recorded | checked |
| AC 4 | Feature-review coverage hook satisfies 786 rules; parity; no Python in hooks; 500-line cap; line coverage >= 85% on changed PowerShell files | checked |
| AC 5 | PR into integration branch green on all checks and merged | unchecked (orchestrator-owned) |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence (reviewer-verified unless noted) |
|---|---|---|
| AC 1 | PASS | `git diff-tree --cc 0ac05da8f` header and `git log` show merge commit `0ac05da8f` with two parents (`9add694e4`, `daa6436cd`). `8ee1b76e6` is the merge base of HEAD and the base ref. The history from `8ee1b76e6` through `a878d6b18` is linear on top of the merge, and the PR context confirms range `8ee1b76e6..a878d6b18`. No-force-push evidence: `evidence/other/commits.md` and `evidence/other/rt-commit.md` (executor). |
| AC 2 | PASS | The resolved `core.json` hunk in `git diff-tree --cc 0ac05da8f` contains `feature-folder-resolution.ps1`, `feature-review-coverage-thresholds.ps1`, `hook-command-heredoc.ps1` on consecutive lines in sorted order; no line is new to both parents; the file parses as JSON. Additional conflicts: none (`evidence/other/p1-conflict-resolution.md`). |
| AC 3 | PASS | Before: `evidence/baseline/p0-ac3-pester.md` (6421 passed). Pre-fix: `evidence/regression-testing/p1-ac3-pester-pre-fix.md` (7 expected failures). After: `evidence/qa-gates/final-ac3-pester.md` (6461 passed, 0 failed). The source tree is unchanged since then. CI run `38112992719` (`poshqc / PowerShell hook suites (Linux)` and `poshqc / PowerShell QC` success) on an identical source tree corroborates the result; reviewer-verified via `gh run view`. |
| AC 4 | PASS | Uniform guard at line 47 with `Add-HookDependencyFailure`; exit-2 paths at lines 351 and 467-468. Fail-before/pass-after recorded (`p2-thresholds-guard-fail-before.md`: 6 failed; `p2-thresholds-guard.md`: 6 passed). Parity: Claude and bundle hook md5 `e69546ab...` equal; thresholds md5 `b63389a3...` equal; Codex pair md5 `02ad20cf...` equal, and the Codex copy does not dot-source the thresholds file but carries the guard (line 43) and fail-closed tail (lines 233-234). No Python invocation in the hook. Line counts 477 / 77 / 121 / 289. Coverage (reviewer re-parse of `artifacts/pester/powershell-coverage.xml`): hook 98.62%, thresholds 100.00%, Codex hook 99.29%, and all 14 canonical changed PowerShell files >= 85%. |
| AC 5 | UNVERIFIED | Orchestrator-owned PR, CI, and merge. Left unchecked as instructed. |

## Summary

AC 1 to AC 4 are verified PASS on head `a878d6b18`. AC 5 is orchestrator-owned and remains unchecked. The three prior blocking findings (coverage artifacts absent for TypeScript, Python, bash) are resolved. Reviewer re-parse results:

- TypeScript: 97.25% line / 92.08% branch.
- Python: 93.80% / 88.10%.
- bash: 94.50% line.
- PowerShell: 90.43% line.

Every changed production file in each language meets the thresholds. The policy audit and the code review record no blocking finding. Non-blocking observations concern the Jest invocation's working directory, the TS branch rounding difference, and inconsistent evidence timestamps.

## Acceptance Criteria Check-off

- AC 1 to AC 4 were already checked; the reviewer confirms each as PASS and made no edit to `issue.md`.
- AC 5 remains unchecked (orchestrator-owned).
- Newly checked off by the reviewer: none.

### Acceptance Criteria Status
- Source: `docs/features/active/epic-852-main-sync/issue.md`
- Total AC items: 5
- Checked off (delivered): 4
- Remaining (unchecked): 1
- Items remaining: AC 5 "The PR into the integration branch is green on ALL checks (positive assertion; a non-zero check count with every check SUCCESS) and is merged."
