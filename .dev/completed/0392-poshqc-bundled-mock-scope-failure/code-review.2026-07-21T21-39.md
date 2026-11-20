# Code Review: PoshQC Bundled Mock-Scope Failure Fix — Post-Remediation Re-Review R4 (Issue #392)

**Review Date:** 2026-07-21
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/`
**Feature Folder Selection Rule:** Single active feature folder matching the issue number supplied by the caller and the branch's changed scoping docs.
**Base Branch:** `main` (merge-base `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`)
**Head Branch:** `drm-copilot-wt-2026-07-21T17-18` @ `821f338db1c3f2f8d32712cf9004c27581167184`
**Review Type:** Post-remediation re-review (R4, exit re-audit for remediation cycle 1)

**Template source note:** MCP tools are unavailable in this review session, so the `resolve_policy_audit_template_asset` resolver could not be invoked; the template was read directly from the bundled asset source file `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`, which is the same file the resolver returns for the `code-review-template` selector.

---

## Executive Summary

This branch fixes issue #392 (31 `Mock data are not setup for this scope` failures occurring only through the bundled PoshQC entry point) and completes one remediation cycle for the coverage floor finding raised in the initial review. The production delta is small and targeted: two default seam scriptblocks in `Invoke-PoshQCTest` (`PoshQC.Testing.psm1`) now host the Pester run in the global session state, and the `PoshQC.psm1` bootstrap loop now caches parsed sub-module ScriptBlocks in a process-lifetime AppDomain slot so repeated `Import-Module -Force` re-parses no longer erase Pester coverage hit credit. Three new test files close the previously uncovered seam-default and branch paths; three pre-existing Koverage tests gain an injected `-InvokePester` stub so their module-scope mocks keep intercepting.

The reviewer independently re-ran the full toolchain at head (format, analyzer, 1350-test suite with coverage — exit 0, 1341/0/9, 41.07s), all three bundled-mirror parity pairs, the Python parity gate, and the evidence-location validator. The prior cycle's Blocking finding is resolved: `PoshQC.Testing.psm1` is at 100.00% line coverage (195/195) with zero regression elsewhere. Implementation quality is high: the mechanism was selected via discriminating experiments, the rationale comments are thorough, and no assertion was weakened anywhere in the diff.

**What changed:**
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (+24/-2) and byte-identical bundled mirror: `-Global` on the `$EnsureModule` default import; global-scope trampoline `Invoke-PoshQCPesterRun` with try/finally removal in the `$InvokePester` default.
- `scripts/powershell/PoshQC/PoshQC.psm1` (+34/-6) and mirror: parse-once AppDomain cache for sub-module ScriptBlocks; dot-sourcing unchanged per `-Force` reimport; parse errors still throw at import.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (+5) and mirror: `PoshQC.Testing.psm1` added to `CodeCoverage.Path`.
- Tests: 3 new files (122/191/141 lines) plus +3/-3 seam injections in `PoshQC.Comprehensive.Tests.ps1`.

**Top 3 risks:**
1. The AppDomain ScriptBlock cache never invalidates within a process, so a long-lived host that edits a sub-module file and re-imports with `-Force` would execute the stale cached definition (not reachable in the repo's CLI/CI usage, where each run is a fresh `pwsh -NoProfile` process).
2. `PoshQC.psm1` (modified production file) has no per-file coverage counter because it is not in the CodeCoverage measured set; its changed lines are verified behaviorally, not numerically (non-blocking; see policy audit section 8 item 2).
3. The installed MCP extension still bundles the pre-fix module snapshot, so MCP PoshQC gates report pre-fix failures until the extension is repackaged from merged main (environmental).

**PR readiness recommendation:** **Go** — the defect fix and the coverage remediation are both verified fresh by the reviewer; zero Blocker or Major findings remain.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | lines 160-165, 261-279 | Prior cycle's Blocking finding (76.41% per-file line coverage) is resolved: file now at 100.00% (195/195); all changed seam lines covered. | None; resolved. | Confirms the remediation objective was met with zero regression. | Reviewer-parsed `artifacts/pester/powershell-coverage.xml` (fresh run 2026-07-21T21-39); `evidence/qa-gates/remediation2-coverage-delta.2026-07-21T21-11.md` |
| Minor | `scripts/powershell/PoshQC/PoshQC.psm1` | lines 106-132 | Process-lifetime AppDomain ScriptBlock cache has no invalidation: if a sub-module file changes on disk within one PowerShell process, a subsequent `Import-Module -Force` dot-sources the stale cached ScriptBlock. | Accept for current CLI/CI usage (fresh process per run). If a long-lived-host edit loop ever becomes a supported scenario, key the cache on path + last-write-time. | Stale definitions in a persistent host would be confusing to debug; the inline comment explains the cache but not this specific staleness boundary. | Diff inspection `git diff 193864d8...HEAD -- scripts/powershell/PoshQC/PoshQC.psm1` |
| Minor | `scripts/powershell/PoshQC/PoshQC.psm1` | lines 106-132 | No dedicated unit test asserts the parse-once semantics (parse invoked at most once per path per process; cache-miss parse error still throws). Correctness is currently evidenced behaviorally via the coverage restoration and full-suite runs. | Add a small unit test in a follow-up (for example, seeding the AppDomain slot with a marker and asserting reimport reuses it), or fold into the follow-up coverage-measurement issue. | Behavioral evidence is strong but indirect; a direct test would pin the contract against future bootstrap edits. | `evidence/baseline/e-c-candidate-parse-cache.2026-07-21T21-11.md`; `evidence/regression-testing/remediation2-*.2026-07-21T21-11.md` |
| Minor | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` list | Modified production file `PoshQC.psm1` is not in the coverage measured set, so no per-file percentage exists for it (condition pre-dates this branch; remediation plan prohibited runsettings edits in cycle 1; first-import parse lines are structurally pre-window in the canonical bundled run). | Open a follow-up issue to add the file to the measured set with a documented in-window caveat, or extract bootstrap logic into a measurable helper. | Keeps the per-issue measured-set convention consistent and makes future bootstrap changes numerically auditable. | Coverage XML sourcefile inventory (no `PoshQC.psm1` entry); `remediation-plan.2026-07-21T19-23.md` scope constraints |
| Info | `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | whole file | File is 766 lines, over the 500-line limit, unchanged in size by this branch (+3/-3). Pre-existing condition. | Track decomposition as follow-up debt. | The limit violation exists at both merge base and head; this diff did not worsen it. | `wc -l`; diff inspection |
| Info | environment | MCP PoshQC gates | `mcp__drm-copilot__run_poshqc_test`/`run_poshqc_suite` load the stale pre-fix bundle from the main-repo extension install and fail with the pre-fix signature. | Repackage the extension from merged main post-merge, then re-run MCP gates. | Environmental; not attributable to branch code. The authoritative worktree check (`scripts/dev-tools/run-poshqc-suite.ps1`) passes. | `spec.md` AC 7 note; prior audit section 7 notes |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The root cause (module-session-state hosting of discovered containers) was isolated empirically (experiments E1a/E1b/E2/E3/E4) before any production edit, and the fix lands at exactly the identified seam with no signature changes.
- The remediation mechanism (parse-once cache) was likewise selected via discriminating experiments (E-B/E-C) with an explicit decision artifact, and the plan's fallback/escalation gates were honored.
- Rationale comments are exemplary: the trampoline block documents why an unbound ScriptBlock is required and why removal must use the `Function:\` provider path; the cache block documents the coverage-merge mechanism, why an AppDomain slot is used instead of a `$global:` variable, and why dot-sourcing must still run per reimport.
- Mirror discipline held: all three bundled pairs are byte-identical (reviewer `cmp`) and the Python parity gate passes.

#### API and safety notes

- `Invoke-PoshQCTest` keeps `CmdletBinding()` and its full seam-injection surface; injected-seam callers bypass both changed defaults, which the 3 modified Koverage tests demonstrate.
- The only new command name, `Invoke-PoshQCPesterRun`, uses an approved verb and exists only for the duration of the Pester call; the no-leak end state is asserted by a regression test.
- Analyzer: 0 findings repo-wide with repo settings (reviewer fresh run), including the deliberate-global-state sites.

#### Error handling and logging

- try/finally guarantees trampoline removal on both success and failure paths; `-ErrorAction SilentlyContinue` on the removal is a narrow idempotent-cleanup guard.
- Cache-miss parse errors still throw the original fail-fast import error with the sub-module name; no error path was broadened or silenced.
- The `$Logger` seam and summary output are unchanged.

---

## Test Quality Audit

The remediation tests are precise: each `It` in the two new branch-coverage files names the production line numbers it exercises, injects only the seams needed to reach that branch, and captures flowed arguments rather than asserting on internals. The seam-defaults file exercises the real default values via AST extraction of the parameter defaults, which is the only way to test defaults without a live nested Pester run; the coupling is documented inline.

### Reviewed test and QA artifacts

- `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` — trampoline lifecycle + PassThru integrity, `-Global` import, throw-on-unavailable, line-98 early return. Deterministic; cleans up global stubs in `AfterEach`; creates no files (asserts the derived output path is never written).
- `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` — pre-run config/path branches (default `$Root`, ScanFolders resolution, Run.Path application, coverage path resolution) via injected seams with captured arguments.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` — post-run summary branches with shaped `-InvokePester` result objects (counts, duration, coverage-disabled vs enabled logging).
- `evidence/qa-gates/remediation2-coverage-delta.2026-07-21T21-11.md` — line-level no-regression comparison against the cycle-1 baseline; corrected the revision-1 artifact's mislabeled target-line count (21 -> 45) rather than propagating it.
- Reviewer fresh run 2026-07-21T21-39: `scripts/dev-tools/run-poshqc-suite.ps1` exit 0; 1341/0/9; coverage XML regenerated and parsed (Testing 195/195; ScanConfig 44/46; aggregate 2143/2376).

### Quality assessment prompts

- **Determinism:** all new tests stub boundary commands or inject seams; no wall-clock, network, or filesystem-write dependencies; reviewer counts reproduce executor counts exactly.
- **Isolation:** one behavior per `It`, with target lines named; module-collision guard keeps exactly one PoshQC instance loaded.
- **Speed:** the three new files run in 117ms/98ms/153ms; full suite 41.07s.
- **Diagnostics:** assertions compare captured values against named expectations with literal throw-message patterns, so failures identify the seam and branch directly.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection of all 10 changed code files; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | PASS | No `Invoke-Expression`, no string-built commands; the trampoline ScriptBlock is a fixed literal (`'param($c) Invoke-Pester -Configuration $c'`) with no interpolation. |
| Input validation at boundaries | PASS | `Invoke-PoshQCTest` throw paths for missing Pester/settings/scan folders preserved and tested. |
| Error handling remains explicit | PASS | Cache-miss parse failure throws with sub-module name; try/finally cleanup; no new catch-alls. |
| Configuration / path handling is safe | PASS | Cache keyed by absolute `Join-Path`-resolved path; `Function:\` provider path removal documented and tested; runsettings addition is an append-only measured-set entry. |
| Global-state hygiene | PASS | Both deliberate global-state sites (trampoline, AppDomain slot) are narrowly scoped, documented, analyzer-clean, and (for the trampoline) leak-tested. |

---

## Research Log

No new external research was required for this re-review. The remediation relied on the plan's cited primary-source reading of the installed Pester 5.6.1 coverage implementation (`Get-CoveragePlugin`, `Enter-CoverageAnalysis`, `Get-CoverageBreakpoints`, hit accounting), confirmed against the installed file in `evidence/other/remediation2-mechanism-background.2026-07-21T21-11.md`; the reviewer verified the artifact exists and that its conclusions match the observed coverage behavior.

---

## Verdict

The branch is ready for normal PR flow. The original defect fix was already verified in the initial review; this re-review confirms the remediation resolved the single Blocking coverage finding (Testing.psm1 at 100.00% per-file lines, aggregate 90.19%, zero line-level regression) with a mechanism fix that addresses the root cause of the measurement loss rather than masking it. Remaining findings are three Minor/Info items (cache staleness boundary in long-lived hosts, absent per-file counter for `PoshQC.psm1`, pre-existing over-limit test file) plus the environmental stale-bundle condition; none blocks merge, and each has a concrete follow-up recorded here and in the policy audit.
