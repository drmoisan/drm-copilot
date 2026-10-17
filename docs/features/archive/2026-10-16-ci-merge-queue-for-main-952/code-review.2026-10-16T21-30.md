# Code Review: CI merge queue for `main` (#952) - re-review after remediation cycle 2 (ORCH-R4)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-952` suffix matches the branch name.
**Base Branch:** `main`, resolved as `origin/main` @ `fa27cd5edcb39a5d5f63054c3e38cefef18ab316` (merge base `fa27cd5ed`)
**Head Branch:** `bug/ci-merge-queue-for-main-952` @ `b844048d9cbb0445b329ce220f1d4139a56910ae` (no PR yet)
**Review Type:** Re-review after remediation cycle 2 and the merge of `origin/main` (#945, #963); orchestrator gates ORCH-R1, ORCH-R2, ORCH-R3 on R_final_3 38967059138

---

## Executive Summary

Reviewed evidence: the full branch diff (288 files), `artifacts/pr_context.summary.txt` and appendix (regenerated 21:34:27 UTC at head `b844048d9`), the cycle-2 diff (`5c1e795a5..b844048d9`), the R2 before/after evidence, the R1 diagnosis artifact, the issue #936 research and its scoped and CI attribution evidence, `policy-followups.md` Record 4, and a reviewer download and parse of the R_final_3 `powershell-coverage.xml`.

**Cycle-2 verification:**

| Prior ID | State | Evidence |
|---|---|---|
| CR-12 (docs-only URL selector) | Resolved | M1 rule at `hook-docs-only-diff.ps1:372-374`, four copies blob `62e0d3529`; N1 to N4 failed before the change and pass on R_final_3 (Windows and Linux) |
| CR-13 (twin-identity comments) | Resolved | Helpers remain byte-identical, so the comments stay accurate; row (g) comment reworded to the provenance reason |
| CR-14 (cause statement) | Resolved | ORCH-R3 CauseStatement records the step-1 status and the `hook-docs-only-diff.ps1` counter-observation; the stated reason for not running step 1 is inaccurate (CR-15) |
| CR-1 (Codex helper coverage) | Open | 74.07% on R_final_3, covered set unchanged; reclassified `human_decision_required` (below) |

**Top 3 risks:**
1. The Codex helper's measured figure stays below the new-file threshold, and no autonomous change raises it within the constraints already set for this item; the remaining routes are an operator decision (CR-1).
2. The attribution mechanism used to justify CR-1 is not verified for this file, although the evidence that would verify it was obtainable in this session through the PoshQC MCP test tool (CR-15).
3. The M1 URL rule and the selector regex differ in case sensitivity (CR-16); no cross-repository exposure was identified, but the two checks are not aligned.

**PR readiness recommendation:** **Not ready** - one Blocker requiring an operator decision (CR-1); AC-28 pending CI.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.codex/hooks/enforce-epic-merge-gate-command.ps1` | lines 67, 68, 72, 165, 166, 171, 172, 179, 182-186, 189 | CR-1: new file at 74.07% (40/54) on R_final_3, below 85%. The covered set is identical to R_final_2. The uncredited set equals the lines inside `ConvertFrom-EpicMergeGateSelector` and `Get-EpicMergeGateSelectorPrNumber` that the first Codex-gate loader (CN-09) does not execute; each line is executed by a passing named assertion (14/14). The byte-identical Claude copy is at 100.00%. | Operator decision (remediation inputs R1). Before presenting it, record a scoped `codex-hooks` coverage run through `mcp__drm-copilot__run_poshqc_test` and the Codex helper's per-line `ci` values, as issue #936 did. | AC-27 states a threshold; the governing rules contain no attribution exception; the routes that would change the figure are a repository-wide configuration change or an order-dependent test arrangement that the #936 research reserved for or rejected on operator grounds. | Reviewer parse of R_final_3 `powershell-coverage.xml`; `codex-helper-coverage-diagnosis.2026-10-16T20-01.md` |
| Minor | `evidence/regression-testing/codex-helper-coverage-diagnosis.2026-10-16T20-01.md`; `evidence/qa-gates/coverage-comparison.2026-10-16T21-28.md` | Section 1; CauseStatement | CR-15: both state that the scoped coverage run (R1 step 1) could not run because no PowerShell launcher is available. Issue #936 produced its scoped run through `mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/codex-hooks"]` (`test-scoped.2026-10-16T01-28.md`), and this item's executor called that tool on the same folder three times in cycle 2. The local `artifacts/pester/powershell-coverage.xml` from the later `claude-runtime` run contains `sourcefile` entries for both helpers, so a scoped run records per-line values for the Codex helper. | Run the scoped `codex-hooks` MCP test, copy `artifacts/pester/powershell-coverage.xml` to the scratchpad, record the Codex helper lines' `ci` values in a new `evidence/regression-testing/` artifact, and correct the stated reason. | Evidence should state what was available; the result decides whether the #936 precedent applies on the same evidence basis. | `test-scoped.2026-10-16T01-28.md` (#936); `c2-url-selector-codex-before.2026-10-16T20-18.md`; reviewer parse of the local coverage file |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` (four copies) | line 372 | CR-16: `$text.Contains('/pull/')` is ordinal; `ConvertFrom-EpicMergeGateSelector` uses case-insensitive `-match '/pull/(\d+)...'`. `https://github.com/o/r/PULL/5` resolves to 5 and passes M1. The gh CLI pull-request URL pattern appears to be case-sensitive, so gh would treat that token as a branch name in the session repository rather than merging another repository's PR; not verified in this review. | Optionally use `$text.IndexOf('/pull/', [System.StringComparison]::OrdinalIgnoreCase) -ge 0`, applied to all four copies, with one N-row variant. | Aligns the refusal with the resolver. | Source reading of both files |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` (four copies) | whole file | CR-17: the file is at 497 lines after cycle 2, 3 lines below the 500-line limit. | No change in this item; the next edit to this file will need an extraction. | Visibility for later work. | Reviewer `wc -l` |
| Info | `tests/scripts/workflows/CiWorkflow.Tests.ps1` | lines 212-239 | CR-10 (carried): the call-graph test follows direct callees only; no nested reusable workflow exists today. | No change required. | Future-proofing only. | Initial review |
| Info | `.claude/settings.json` | permissions | CR-11 (carried, pre-existing): no project-level allow rule exists for the merge-confirmation parser, as none exists for `Invoke-CiGateParser.ps1`. | No change in this item. | Parity with the existing parser. | Initial review |

---

## Detailed Review Notes

### Correctness

- R2: the URL rule sits in the M1 token loop after the repository-override rules and before the `--auto` rule, so it applies to every token of the single segment. A `--body` value containing `/pull/` is also refused; that is a fail-closed outcome (the exemption is not applied and the normal gate decision stands). N2 and N3 set a docs-only diff seam so that only the URL rule can produce the deny, and they assert zero `gh` and `git` seam calls.
- R2 coverage: the new lines 372-374 are credited in both copies on R_final_3; the remaining missed lines in each copy map one-to-one to the R_base missed lines under the +1/+4 line shift recorded in ORCH-R3.
- R1: no production or configuration change. The two Codex suite headers now carry the attribution note with the line-to-assertion map.

### Mirrors and manifests

- `git ls-files -s`: the four `hook-docs-only-diff.ps1` copies share blob `62e0d3529`; the four helper copies share `94d2145cd`; each gate equals its bundle mirror (`462e73c25` Claude, `f70c75311` Codex).

### Policy constraints

- No edit under `.claude/rules/`, `.github/instructions/`, `_poshqc.yml`, `hook-command-invocation.ps1`, the PoshQC module or settings, or `config/poshqc-coverage.json`; no coverage exclusion; the ruleset is not applied.

---

## Typed-Python Review

The four Python files are test code and are unchanged since the cycle-1 review; Black, Ruff, and Pyright were clean then, and `quality-checks7` succeeds for 3.10 to 3.13 on R_final_3.

---

## Summary

| Severity | Count | IDs |
|---|---|---|
| Blocker | 1 | CR-1 |
| Major | 0 | - |
| Minor | 1 | CR-15 |
| Nit | 0 | - |
| Info | 4 | CR-10, CR-11, CR-16, CR-17 |

CR-1 is blocking and requires an operator decision. CR-15 is the recommended pre-decision evidence step. CR-16 is an optional alignment. CR-10, CR-11, and CR-17 require no change.
