# Code Review: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T09-23
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 1)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `65c068515b561ba8b965e189d870efbd31fcdb37`
- Base: `main`; merge-base `4776ccd9366d8f580ac9ac0fe164d75306785218`
- Scope: full branch diff `git diff 4776ccd93..HEAD` (146 files). Production code reviewed: `.claude/hooks/hook-docs-only-diff.ps1` (new; byte-identical at `.codex/hooks` and both bundle mirrors), `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1` (header), `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, both `pack-manifests/core.json`. Test code reviewed: all 17 changed suites, with full reads of the R1 additions (`hook-docs-only-diff.BoundedNative.Tests.ps1` and the R1 hunks of the MergeExemption, helper, Codex helper, and DocsOnly suites). Documentation reviewed: spec version 1.3, research copies, #901 evidence and `issue.md` edits.
- R1 change set: `git diff e4521e5a8 7966e1564` over hooks, mirrors, and suites (13 files, +659/-35).

## Executive Summary

The R1 changes address the prior code-review observations. The docs-only gh and git calls now run through `Invoke-DocsOnlyBoundedNative`, which starts the executable with an argument list (no command-line quoting), waits at most 7000 ms (gh) or 3000 ms (git) plus 1000 ms for output, stops the process tree on expiry, and reports exit code 124, which every M-condition treats as a deny. This closes the fail-open path recorded as CR-1, given the research finding that a timed-out Claude Code command hook does not block the tool call. The working-directory residual limit is documented in the three headers (CR-2). The test gaps (CR-3, CR-4) and Arrange markers (CR-9) are closed; CR-5 is retained with a reason that the reviewer accepts (the epic-state isolation discovery guard requires those mocks).

No code defect was found that blocks merge. The remaining observations are Low or Info. The one blocking finding of this review is the coverage-artifact finding PA-1R in `policy-audit.2026-10-16T09-23.md`; it does not identify a code defect.

## Prior Observation Disposition

| Prior ID | Disposition | Reviewer verification |
|---|---|---|
| CR-1 (timeout) | Closed | `hook-docs-only-diff.ps1:155-223` (bounded runner), `:248` and `:288` (default invokers); header time-limit paragraph `:50-56`; rows in `BoundedNative.Tests.ps1:117-160` and MergeExemption exit-124 rows. |
| CR-2 (working directory) | Closed (documented) | Header text in `hook-docs-only-diff.ps1:43-48`, `enforce-epic-merge-gate.ps1:43-47`, `.codex/hooks/enforce-epic-merge-gate.ps1:14-17`. |
| CR-3 (`-B=main` row) | Closed | `enforce-pr-author-skill.DocsOnly.Tests.ps1:71-72` now include `--base main`, so the rows deny only through the letter rule. |
| CR-4 (missing rows) | Closed | `hook-docs-only-diff.MergeExemption.Tests.ps1`: `--auto=true` row, mismatching and matching `--match-head-commit=` rows, `[]` lookup row. |
| CR-5 (Claude seams in the Codex suite) | Retained with reason | `evidence/qa-gates/r1-remediation-closure.2026-10-16T09-12.md:13`: removing the mocks failed the discovery guard J15a in loop pass 1. |
| CR-6 (duplicate research) | Closed (marked) | `research/research-addendum-merge-gate.2026-10-15T19-46.md:8` marks the file a superseded duplicate; both files remain. |
| CR-7 (gate size) | No action | `enforce-epic-merge-gate.ps1` is 491 lines. |
| CR-8 (duplicate seam) | No action | Spec Design item 3. |
| CR-9 (Arrange markers) | Closed | Reviewer diff of the two suites. |
| CR-10 (CI-dependent markers) | Closed | `spec.md:341` (AC-M23) and `:364` (AC-18) carry **[CI-dependent]**; revision note at `spec.md:18`. |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (non-blocking) | `.claude/hooks/hook-docs-only-diff.ps1` | `Invoke-DocsOnlyBoundedNative`, lines 199-222 | CR-R1: the `Process` object returned by the starter is never disposed on either the success or the expiry path. | Wrap lines 200-222 in `try { ... } finally { $process.Dispose() }` (the fake process object would need a no-op `Dispose` member), or record that the short-lived hook process releases the handle at exit. | Resource handling; the effect is small because the hook process ends after one decision. | Source read |
| Low (non-blocking) | `.claude/hooks/hook-docs-only-diff.ps1` | line 187 (default `-ProcessStarter`); CI coverage missed lines 187, 299, 343 | CR-R2: no test runs the real `[System.Diagnostics.Process]::Start` path, so tree termination (`Kill($true)`) and the asynchronous read after termination are verified only against the fake process object. | Consider one integration row, outside the unit suites, that runs the runner against a short-lived real executable with a 1 ms limit and asserts exit 124. | The bound is the fail-closed control for a gate; the fake verifies control flow but not the .NET process behavior. | CI artifact of run 38876469175 (reviewer parse) |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` | header lines 50-56; registration `.codex/config.toml:144` (`timeout = 30`) | CR-R3: the 20 s worst case excludes PowerShell start-up and the rest of the gate's work. The remaining margin under the Codex 30 s timeout is about 10 s. | No action in this item; revisit the bounds if additional calls are added to the docs-only branch. | Headroom record. | Header text and registration |
| Info | `.codex/hooks/enforce-epic-merge-gate.ps1` | line 403 | CR-R4: the changed entry-point statement is uncovered in CI (`ci=0`); the same statement was uncovered at baseline (line 377 in run 38852748136), so there is no regression. | No action. | No-regression rule satisfied. | Reviewer parse of both CI artifacts |
| Info | `.claude/hooks/enforce-epic-merge-gate.ps1` | whole file (491 lines) | CR-R5: 9 lines below the 500-line limit (carried from CR-7). | Plan the next change to this gate with an extraction. | File-size headroom. | `wc -l` |
| Info | `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` | lines 21-22, 26-28 | CR-R6: the Claude worktree-resolution imports and seam mocks remain because the discovery guard `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` computes Claude seams in the suite's closure. | If the discovery guard later distinguishes Codex suites, remove the Claude mocks then. | Records why the prior CR-5 recommendation was not applied. | `r1-remediation-closure.2026-10-16T09-12.md:13` |

## Detailed Notes

### Bounded runner

- Start description: `ProcessStartInfo` with `ArgumentList` (each argument passed unchanged), `WorkingDirectory` from the current file-system location (the gh seam sets it with `Push-Location` at line 296; the git seam passes `-C <WorktreeRoot>` as the first arguments), `UseShellExecute = $false`, both streams redirected, UTF-8 output encoding.
- Waits: `WaitForExit($TimeoutMilliseconds)` and then `$output.Wait(1000)`; either expiry stops the tree, sets the global `LASTEXITCODE` to 124, and returns no output. Standard error is drained to avoid a pipe-buffer stall and discarded.
- Output shaping: one trailing LF removed; lines split on LF with trailing CR trimmed; NUL characters pass through, so the NUL-termination guard still applies.
- `-TimeoutMilliseconds` is range-validated to 1..10000.

### Gate placement and create side

- Unchanged in R1. The create-side seam `Invoke-PrAuthorDocsOnlyGitExe` remains unbounded by decision D-R1-3 (local git only); the create-side file hash is unchanged from the prior review (`f3e3300e9`).

### Coverage cross-check

- CI artifact of run 38876469175 (reviewer parse): helper copies 97.52% each; docs-only 100.00%; changed executable lines 28/29 across the five modified files. The contract-designated local artifact does not measure the helper copies or the docs-only file; see policy audit PA-1R.

## Verdict

No code-level blocker. Six non-blocking observations (CR-R1 to CR-R6; two Low, four Info). The review-level verdict is driven by policy audit PA-1R (coverage artifact) and is recorded in `remediation-inputs.2026-10-16T09-23.md`.
