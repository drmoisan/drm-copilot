# Code Review: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T11-19
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 2)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `d7b4da0759cff1d47c302019122f3cac33cb3457`
- Base: `main`; merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`
- Scope: full branch diff `git diff 5bdf22d0f..HEAD` (176 files). Production code reviewed: `.claude/hooks/hook-docs-only-diff.ps1` (new; byte-identical at `.codex/hooks` and both bundle mirrors, hash `64d472beb`), `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1` (header), `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, both `pack-manifests/core.json`. Test code reviewed: all changed suites, with full reads of the R2 hunks in `hook-docs-only-diff.BoundedNative.Tests.ps1` and `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. Documentation reviewed: R2 evidence and decisions.
- R2 change set: `git show bf3c5e310` (helper at four paths, +25/-19 each; two runner suites; R2 evidence).

## Executive Summary

The R2 code change closes CR-R1. `Invoke-DocsOnlyBoundedNative` now wraps everything after the process start in `try { ... } finally { $process.Dispose() }` (`.claude/hooks/hook-docs-only-diff.ps1:200-228`). The start call stays outside the `try`, so a start failure still throws to the calling seam and no dispose is attempted on a null object. The expiry path, the normal path, and the empty-output path all reach the `finally`. The fake process objects in both runner suites gain a `Dispose` script method that records the call, and every row that starts a process asserts `Disposed`. An expect-fail run confirmed 14 failing rows before the edit.

The full-population local run and CI run `38890377723` both report tests=10606, failures=0, errors=0. Coverage of every changed hook file is at or above 85% and at or above its baseline.

No code defect blocks merge. The observations below are Low or Info.

## Prior Observation Disposition

| Prior ID | Disposition | Reviewer verification |
|---|---|---|
| CR-R1 (dispose) | Closed | Source read of `hook-docs-only-diff.ps1:200-228`; `Disposed` assertions at `BoundedNative.Tests.ps1:85, 104, 118, 137, 165` and `codex-hooks/hook-docs-only-diff.Tests.ps1:215`; line 227 `ci=1` in the local and CI coverage artifacts. |
| CR-R2 (real process path) | NO_ACTION with reason (D-R2 CR-R2) | Carried as CR-R2 below. |
| CR-R3 (Codex timeout margin) | NO_ACTION | Carried as Info. |
| CR-R4 (Codex entry-point line) | NO_ACTION | Line 403 `ci=0` in CI run `38890377723`, also uncovered at baseline. |
| CR-R5 (gate size) | NO_ACTION | `enforce-epic-merge-gate.ps1` still 491 lines; not edited in R2. |
| CR-R6 (Claude seams in Codex suite) | NO_ACTION | Carried as Info. |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (non-blocking) | `.claude/hooks/hook-docs-only-diff.ps1` | line 188 (default `-ProcessStarter`); missed lines 188, 305, 349 | CR-R2 (carried): no test runs the real `[System.Diagnostics.Process]::Start` path, so tree termination (`Kill($true)`) and disposal of a real process are verified only against the fake. | No action in this item (decision recorded in `evidence/other/r2-decisions.2026-10-16T10-21.md`); consider an integration row outside the unit suites if the runner changes again. | The fake verifies control flow, not .NET process behavior. | Local and CI coverage artifacts (reviewer parse) |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` | lines 202-212 and 226-228 | CR-N1 (new): on the expiry path, and on the path where `Kill` throws, the asynchronous `ReadToEndAsync` tasks for stdout and stderr may still be pending when `Dispose()` runs. Disposal closes the redirected streams; the pending tasks then fault and are not observed. | No action required; the faulted tasks are not observed and do not affect the decision. If the runner is reused in a long-lived host, observe or cancel the read tasks before disposal. | The hook process ends after one decision, and .NET does not terminate the process for unobserved task exceptions. | Source read |
| Info | `.codex/hooks/hook-docs-only-diff.ps1` | line 217 | CR-N2 (new): the trailing-LF trim statement `$text = $text.Substring(...)` is not executed by the Codex-copy suite (`ci=0`, `mi=1`), while the Claude copy covers it (`ci=1`). Whole-file coverage of the Codex copy is 97.54%. | Optional: add an LF-terminated output row to the Codex-copy runner rows in `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. | The two copies are byte-identical, so the behavior is covered on the Claude copy; the gap is per-path measurement only. | `evidence/qa-gates/r2-coverage-delta.2026-10-16T10-53.md` (CHANGED_CODE_INFO); reviewer parse |
| Info | `artifacts/pester/powershell-coverage.xml` (gitignored) | mtime 2026-10-16 06:50:30 -04:00 | CR-N3 (new): the local coverage artifact predates the merge `d7b4da075` (07:14:19 -04:00). The merge changed no file of this item, and no CI run exists on `d7b4da075`. | The PR-head CI run at S9 measures the merged tree; no local action. | Repo-wide figures for files outside this item may differ slightly on the merged tree. | `git diff --name-only bf3c5e310 HEAD -- <item code paths>`; `gh run list` |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` | header lines 50-56; registration `.codex/config.toml:144` (`timeout = 30`) | CR-R3 (carried): the 20 s worst case leaves about 10 s under the Codex 30 s timeout once start-up is included. | No action; revisit if more calls are added to the docs-only branch. | Headroom record. | Header text and registration |
| Info | `.codex/hooks/enforce-epic-merge-gate.ps1` | line 403 | CR-R4 (carried): the changed entry-point statement is uncovered (`ci=0`) in CI run `38890377723`; also uncovered at baseline (line 377), and named as the exception in AC-M24. | No action. | No-regression rule satisfied. | Reviewer parse of CI artifacts |
| Info | `.claude/hooks/enforce-epic-merge-gate.ps1` | whole file (491 lines) | CR-R5 (carried): 9 lines below the 500-line limit. | Plan the next change to this gate with an extraction. | File-size headroom. | `wc -l` |
| Info | `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` | lines 21-28 | CR-R6 (carried): Claude seam mocks retained because the epic-state isolation discovery guard requires them. | Remove if the discovery guard later distinguishes Codex suites. | Records why the earlier recommendation was not applied. | `evidence/qa-gates/r1-remediation-closure.2026-10-16T09-12.md:13` |

## Detailed Notes

### R2 change

- Structure: `$process = & $ProcessStarter $startInfo` (line 200) precedes `try` (line 201); the body runs inside the `try`; `finally { $process.Dispose() }` (lines 226-228). Early `return` statements at lines 212 and 220 and the normal completion after the output loop all run the `finally`.
- Help: `.DESCRIPTION` adds "The process object is disposed on every return path once it has started." (line 169).
- Tests: the start-failure row has no `Disposed` assertion, which matches the code, because no process object exists in that case.

### Coverage cross-check

- Local artifact (route B) and CI artifact of run `38890377723` agree for all seven changed files: helper copies 97.54%, docs-only 100.00%, pr-author 92.98%, Claude gate 99.29%, resolution sibling 95.65%, Codex gate 88.41%. AC-9 lines 78, 79, 82, 84 of `enforce-pr-author-skill.docs-only.ps1` have `ci` 2, 1, 1, 4 in the CI artifact.

## Verdict

No code-level blocker. Eight non-blocking observations (CR-R2 Low; CR-N1, CR-N2, CR-N3, CR-R3, CR-R4, CR-R5, CR-R6 Info). The review-level verdict is PASS.
