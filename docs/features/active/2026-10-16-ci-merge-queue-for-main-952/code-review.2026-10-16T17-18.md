# Code Review: CI merge queue for `main` (#952) - re-review after remediation cycle 1

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-952` suffix matches the branch name.
**Base Branch:** `main`, resolved as `origin/main` @ `d72ec6a1010223f7036b9c3d15dad102ae262f98` (merge base `d72ec6a10`)
**Head Branch:** `bug/ci-merge-queue-for-main-952` @ `5c1e795a54031a8247cd8a324668de3fb089b84c` (no PR yet)
**Review Type:** Re-review after remediation cycle 1 and the merge of `origin/main` (#927, #937, #946); orchestrator gates ORCH-R1, ORCH-R2, ORCH-R3 on R_final_2 38933561015

---

## Executive Summary

Reviewed evidence: the full branch diff (227 files; 50 outside the feature folder), `artifacts/pr_context.summary.txt` and appendix (regenerated 17:18:11 UTC at head `5c1e795a5`), the cycle-1 evidence and ORCH-R1 to ORCH-R3 artifacts, the merge resolution in both gates (`f03bc9b72`), a reviewer download and parse of the R_final_2 `powershell-coverage.xml`, and reviewer re-runs of Black, Ruff, Pyright, the full Python suite with coverage, and the contract suites.

**Cycle-1 verification:**

| Prior ID | State | Evidence |
|---|---|---|
| CR-1 (Codex helper coverage) | Open | 74.07% on R_final_2 (CR-1 below) |
| CR-2 (Claude `--` and branch-name cases) | Resolved | `enforce-epic-merge-gate.MergeQueue.Tests.ps1:142-145`; Claude helper 100.00% |
| CR-3 (parser null, empty, time cases) | Resolved | `Invoke-MergeConfirmationParser.Tests.ps1:124,135,143,149`; parser 100.00%; row (i) PASS |
| CR-4 (`--merge=<non-number>` ends the scan) | Resolved | Helper lines 170-173 return only when the value converts; rows (h) PASS on both runtimes; four copies blob `94d2145cd` |
| CR-5 (file-supplied GraphQL not visible) | Resolved | Helper header lines 16-18 (four copies); `spec.md:337` Rollout follow-up |
| CR-6 (cause statement) | Partially resolved | ORCH-R3 withdrew the cycle-0 statement; its replacement hypothesis is contradicted in its general form (CR-14) |
| CR-7 (D10(a) scope deviation) | Resolved | `evidence/other/scope-deviation-d10.2026-10-16T16-13.md` |
| CR-8 (runbook capture path) | Resolved | `ruleset/runbook.md:23` (scratch directory, not committed); `runbook-sections.2026-10-16T16-13.md` |
| CR-9 (repository-wide PowerShell figure) | Resolved | `REPO_PS_LINE=89.90` in ORCH-R3; reviewer re-parse 16720/18598 = 89.90% |

**Top 3 risks:**
1. The Codex helper coverage figure has not moved across two dispatched runs although every uncovered line is executed by passing in-process cases; a third CI cycle on an unverified hypothesis may repeat the result (CR-1).
2. After the #927 merge, the docs-only branch can allow a merge of a pull request in another repository named through a `/pull/<n>` URL selector, because the URL resolves to a number and the docs-only check reads the local pull request of that number (CR-12).
3. Under a queue, a merge-group failure leaves the PR head green; the procedures route it through `not_queued` (carried from the initial review; Info).

**PR readiness recommendation:** **Not ready** - two Blockers (CR-1, CR-12); AC-28 pending CI.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.codex/hooks/enforce-epic-merge-gate-command.ps1` | lines 67, 68, 72, 165, 166, 171, 172, 179, 182-186, 189 | CR-1: new file at 74.07% (40/54) on R_final_2, below 85%. The covered set is the cycle-0 set renumbered. Row (g) proves the functions are defined by the Codex file; row (j) calls `ConvertFrom-EpicMergeGateSelector` with a URL and passes, yet line 67-68 is uncovered. The byte-identical Claude copy is at 100.00%. | Cycle 2, in order: (1) local discriminating run in the main session through the PowerShell tool (not the PoshQC MCP runner, whose results carry no output): `Invoke-Pester` with a scratch configuration, `CodeCoverage.Enabled = $true`, `CodeCoverage.Path` = both helper files, output under the session scratchpad; run A `Run.Path` = `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1` only; run B = the Claude MergeQueue suite followed by the same Codex suite; record the Codex helper's covered lines for each. (2) If run A credits lines 67-68 and 165-189 and run B does not, the loss is a cross-file interaction: make the Codex helper's text differ from the Claude helper's (for example a Codex-specific `.DESCRIPTION` sentence) with identical executable statements, keep each copy byte-identical to its own bundle mirror, and update the twin-identity comments (CR-13). If run A does not credit them either, the loss is inside the Codex suites' load sequence: change those suites to load the helper once through the gate (as the credited suites `-trigger-scoping`, `-authorization`, `-decision-surface`, `-docs-only` do) and re-check row (g). (3) Re-run the local configuration with the full Codex and Claude merge-gate suite set and confirm the Codex helper at >= 85% before dispatching `ci.yml`; then repeat ORCH-R1 to ORCH-R3. | `.claude/rules/general-unit-test.md` and `.claude/rules/powershell.md` require >= 85% line coverage for new files. Two CI cycles have not moved the figure; a local discriminating run costs minutes and selects the remedy before the next CI dispatch. | ORCH-R3 per-line data; reviewer parse of R_final_2 `powershell-coverage.xml` |
| Blocker | `.claude/hooks/hook-docs-only-diff.ps1` (M1, four byte-identical copies) as reached from both gates | `Get-DocsOnlyMergeShapeViolation` lines 353-375; Claude gate `:389-395`; Codex gate `:177-181` | CR-12: since #952, `ConvertFrom-EpicMergeGateSelector` resolves `gh pr merge https://github.com/<other-owner>/<other-repo>/pull/5 --merge` to 5. When no checkpoint records 5, both gates call `Get-DocsOnlyMergeExemption`; M1 rejects `-R`, `--repo`, and `GH_REPO=` overrides but not a URL selector, and M3 runs `gh pr view 5` in the session repository (`:403`). If the local PR 5 is docs-only, the gate allows a command that merges PR 5 of the other repository. On `main` a URL selector yields `$null` and the docs-only branch is not reached, so the exposure is created by the combined #952 and #927 scope. No DocsOnly suite contains a URL case. | Add to M1 a rejection of any selector token containing `/pull/` (reason text in the existing `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: the repository override '<token>' is not accepted.` form or a dedicated "URL selector" sentence), apply it byte-identically to all four `hook-docs-only-diff.ps1` copies (the H11/#927 parity test enforces identity), and add cases: `hook-docs-only-diff.Tests.ps1` M1 row for `gh pr merge https://github.com/o/r/pull/5 --merge`; one Claude and one Codex DocsOnly gate case with no recording target and a docs-only diff mock, expecting deny with the `(docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED...)` suffix and no `gh pr view` call. Update the M1 header text. Keep the DocsOnly suites' existing Passed counts plus the new rows in the ORCH baselines. | The #927 design intent (M1) is that the docs-only exemption never applies to a repository other than the session repository; the URL route defeats it. The fix is small and local to the files the combined scope uses. | Source reading of `hook-docs-only-diff.ps1:353-375,403`; `enforce-epic-merge-gate-command.ps1:64-72`; `git grep "pull/" -- <DocsOnly suites>`: no match |
| Minor | `.claude/hooks/enforce-epic-merge-gate-command.ps1` (four copies); `.codex/hooks/enforce-epic-merge-gate.ps1`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` | helper lines 5-6; Codex gate lines 33-34 and 73-74; suite line 69 | CR-13 (in-item, same files): these comments state that the Claude and Codex helpers are byte-identical. The spec requires only each helper to be byte-identical to its bundle mirror (AC-20) and one helper per runtime (AC-5); no parity test asserts Claude/Codex helper identity. | If CR-1 step (2) differentiates the Codex helper, reword these comments to state that the two helpers carry the same executable statements and that each is mirrored byte-identically. Otherwise no change. | Keeps comments accurate after cycle 2. | `git grep -n "byte-identical"` over the helper, gate, and suite |
| Info | `evidence/qa-gates/coverage-comparison.2026-10-16T17-08.md` | CauseStatement | CR-14 (same feature): the hypothesis that hits on the Codex helper are credited to the first-loaded byte-identical Claude copy is contradicted in its general form by the same report: `hook-docs-only-diff.ps1` (blob `7e429ae6c` in both runtimes at `fd1913a0d`) shows Claude missed {189, 314, 358} and Codex missed {189, 217, 314}; the Codex copy is credited with line 358 that the Claude copy misses. | Record the CR-1 step (1) result and the hook-docs-only-diff observation in the next coverage-comparison artifact. | Evidence should match observed data. | Reviewer parse of R_final_2 `powershell-coverage.xml` |
| Info | `tests/scripts/workflows/CiWorkflow.Tests.ps1` | lines 212-239 | CR-10 (carried): the call-graph test follows direct callees only; no nested reusable workflow exists today. | No change required. | Future-proofing only. | Initial review |
| Info | `.claude/settings.json` | permissions | CR-11 (carried, pre-existing): no project-level allow rule exists for the merge-confirmation parser, as none exists for `Invoke-CiGateParser.ps1`. | No change in this item. | Parity with the existing parser. | Initial review |

---

## Detailed Review Notes

### Correctness

- CR-4 fix: `gh pr merge --merge=true 5` now scans past the non-numeric value and returns 5; `--merge=5` still returns 5 (helper lines 170-173). The fix is applied to all four helper copies (blob `94d2145cd`).
- Merge resolution: both gates load the #952 helper before `hook-docs-only-diff.ps1`, gate scope through `Test-EpicMergeGateCommandInScope`, and evaluate the #927 docs-only branch only for an explicit number with no recording target (Claude) or no root checkpoint (Codex). M1 excludes `gh api` spellings (structural `gh pr merge` required) and `--auto`; `--squash`, `--rebase`, and `--admin` spellings of a docs-only PR are newly eligible, which is consistent with the method-agnostic scope because `--merge --admin` was already eligible. The URL-selector gap is CR-12.
- Deny text: the #927 bare-merge pins now carry the #952 text; rows (k) and (l) pass on Windows and Linux.
- Release flow and parser: unchanged since the initial review except added tests.

### Mirrors and manifests

- 13/13 changed files under `.claude/`, `.codex/`, `.agents/` are byte-identical to their bundle mirrors (reviewer `git hash-object`).

### Policy constraints

- No edit under `.claude/rules/`, `.github/instructions/`, `_poshqc.yml`, `hook-command-invocation.ps1`, the PoshQC module, or its settings; no coverage exclusion; the ruleset is not applied.

---

## Typed-Python Review

The four Python files are test code; no change since the initial review affects them. Black, Ruff, and Pyright are clean on the reviewer re-run; the eight contract suites pass (117).

---

## Summary

| Severity | Count | IDs |
|---|---|---|
| Blocker | 2 | CR-1, CR-12 |
| Major | 0 | - |
| Minor | 1 | CR-13 |
| Nit | 0 | - |
| Info | 3 | CR-10, CR-11, CR-14 |

CR-1 and CR-12 are blocking and autonomous. CR-13 and CR-14 are in-item and are carried into the remediation inputs for cycle 2. CR-10 and CR-11 require no change.
