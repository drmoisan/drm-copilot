# Code Review: Bundled Coverage Path Portability Fix (#409)

---

**Review Date:** 2026-07-25
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-25-bundled-coverage-path-portability-409`
**Feature Folder Selection Rule:** Sole active feature folder whose suffix matches the issue number in the branch name (`bug/bundled-coverage-path-portability-409`).
**Base Branch:** `main` (merge-base `036daf8d5fa36a6655078f33e4313b0d2df9590b`)
**Head Branch:** `bug/bundled-coverage-path-portability-409` @ `dbf2e3f591e22c02013e90f764f278de713a2aac`
**Review Type:** Initial review

---

## Executive Summary

This branch fixes issue #409: `Invoke-PoshQCTest` forwarded every configured `CodeCoverage.Path` entry to Pester without an existence check, and Pester's `Resolve-CoverageInfo` raises a terminating error on the first unresolvable entry, aborting the run at RunStart in any consumer repository that lacks this repository's coverage layout. The fix inserts a single 20-line pruning block at the final authoritative coverage-path resolution site: paths are filtered through the existing injectable `$TestPathExists` seam, every pruned path is logged individually through the existing `$Logger` seam, and when no path survives, coverage is disabled for the invocation with one logged explanation and the run proceeds. The edit is applied byte-identically to the canonical module and its bundled mirror (verified: identical git blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`), preserving the parity contract enforced by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.

Evidence reviewed: the full branch diff (37 files, one production hunk mirrored twice plus one new 259-line test file and 34 docs/evidence files), the executor's complete evidence tree, and independent reviewer verification — PSScriptAnalyzer (0 diagnostics on all three changed files), check-only Invoke-Formatter comparison (clean), the new Pester file (4/4 pass), the parity pytest (1 pass), and independent parsing of both preserved coverage XMLs (repo-wide 90.22% line coverage; changed file 202/202 lines; 8/8 instrumented changed lines covered; per-file entry sets identical between baseline and post-change, 31 entries each, empty set difference). Implementation quality is high: the change is minimal, reuses existing seams, is fully covered, and carries fail-before evidence proving the tests detect the pre-fix behavior.

**What changed:**
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and its bundled mirror: one hunk at lines 346-366 adding pruning, per-path prune logging, and the empty-set coverage-disable rule (spec decision SD2).
- `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` (new): four deterministic seam-injected scenarios.
- Feature-folder documentation and evidence artifacts (no other production surface touched; `pester.runsettings.psd1` copies unchanged by design).

**Top 3 risks:**
1. The fix is not yet delivered to consumers: the npx-cached published `@danmoisan/drm-copilot-mcp` 1.0.18 bundle still contains the pre-fix module until the separate, explicitly out-of-scope release action (version bump, tag, npm publish) occurs.
2. Pre-existing relative-`-Root` double-join in the default `$ExpandCoveragePaths` seam (observed as `tests\tests\...` prune paths in the consumer scenario) remains unfixed by deliberate scope decision; it is masked in this repository (absolute `-Root`) and neutral to the pruning behavior, but remains a latent path-resolution defect for relative roots.
3. The SD1 latent `Run.Path` discovery-time portability risk (consumer repo with no scan config and nonexistent default `Run.Path`) is deliberately excluded and needs its own tracking issue per spec Rollout.

**PR readiness recommendation:** **Go** — zero Blocker/Major findings; all toolchain gates clean; behavioral invariance in this repository and consumer-scenario completion both proven with reviewer-verified evidence.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | default `$ExpandCoveragePaths` seam (lines 215-240) + coverage-enabled block | Pre-existing double-join of relative coverage entries when `-Root` is itself relative: the default seam roots entries once, and the enabled block re-roots the still-relative result, producing `tests\tests\...` paths in the consumer scenario. Predates this change; deliberately left unfixed per recorded orchestrator ruling. | No action on this branch. Track alongside or as part of the SD1 follow-up issue so the relative-root behavior is fixed once, deliberately. | The reviewer agrees with the ruling: the defect is on a different resolution step, is masked whenever `-Root` is absolute (all first-party callers), and is behavior-neutral to the pruning under review — all 32 entries prune either way. Reporting it as a defect of this change would be inaccurate. | `evidence/regression-testing/consumer-scenario.2026-07-25T11-17.md` (observation paragraph); diff inspection of lines 215-240 vs 340-345 |
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | spec Scope & Non-Goals (SD1) | Latent `Run.Path` discovery-time abort for consumer repos without a scan config is excluded from #409 by documented decision; no code on this branch touches that path. | File the separate tracking issue named in spec Rollout & Follow-up before or at merge time. | Deliberate, documented exclusion of a distinct failure mode on a different code path; not an oversight. | `spec.md` Scope & Non-Goals SD1; Rollout & Follow-up |
| Info | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | whole file | Consumers keep the pre-fix behavior until a release ships: the MCP server resolves the npx-cached published 1.0.18 bundle, not this repository's mirror. Version bump/publish is explicitly out of scope for this branch. | Schedule the release action (`Invoke-FullRelease.ps1` PR, tag, CI publish) as the delivery step for #409. | Prevents a false assumption that merging this branch resolves the reported consumer failure immediately. | `spec.md` Dependencies (out-of-scope release); `evidence/qa-gates/final-poshqc-test.2026-07-25T11-26.md` harness note |
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | coverage XML counters | PowerShell branch coverage cannot be numerically gated: Pester 5.6.1's JaCoCo output emits `INSTRUCTION`/`LINE`/`METHOD`/`CLASS` counters only, no `BRANCH` counter (reviewer verified in all three coverage XMLs). Both branches of the new conditional are nonetheless executed by the seam tests. | None for this branch; documented limitation in `spec.md` Test Strategy. If branch-level gating for PowerShell becomes a requirement, it needs a toolchain change, not a test change. | The uniform branch-coverage threshold cannot be evaluated where the toolchain emits no branch data; the limitation is pre-existing and repo-wide, not introduced here. | Reviewer XML parse (counter-type inventory); `evidence/qa-gates/coverage-delta.2026-07-25T11-40.md` |
| Nit | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | lines 352-353 | Prune-set computation is O(n²): the `foreach` re-filters `$resolvedCoveragePaths` with `-notcontains` against the surviving array. With ~32 configured entries the cost is negligible. A duplicated missing entry would also be logged once per occurrence (arguably desirable for observability). | Optional only: a single-pass partition (one loop appending to surviving/pruned lists) would be linear and marginally clearer. Not required. | Readability/perf polish with no behavioral impact at this scale; changing it now would add churn to a verified, covered block. | Diff inspection lines 346-366 |

No Blocker or Major findings. Blocking-finding count: 0.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The pruning is placed at the single authoritative resolution site — after `$coverageEnabled` is computed and after rooted/unrooted entries are resolved, immediately before the config reaches `$InvokePester` — so there is exactly one pruning point and no second site to keep consistent.
- The fix reuses the module's existing injection seams (`$TestPathExists`, `$Logger`) instead of adding parameters or new abstractions; the public surface of `Invoke-PoshQCTest` is unchanged.
- The empty-surviving-set rule (SD2) is correctly defensive: it sets both `$config.CodeCoverage.Enabled = $false` and the local `$coverageEnabled = $false`, which also naturally suppresses the downstream coverage-artifact copy step (line 403 gate). The comment documents why enabled-but-empty would be worse (whole-directory `Run.Path` instrumentation in Pester).
- Rooted absolute entries are evaluated as-is and never re-joined to `-Root` (line 343 conditional feeding line 352), with a dedicated test scenario locking that behavior.
- The block comment explains the Pester failure mechanism (`Resolve-CoverageInfo` discards the whole set and raises a terminating error) and cites the issue number, which makes the intent auditable in place.

#### API and safety notes

- No signature changes; no new global or script-scoped state; all new variables are function-local.
- Logging goes through the injected `$Logger`, keeping the function testable and host-neutral; prune messages name the resolved path value, satisfying the no-silent-coverage-exclusion constraint from `.claude/rules/general-unit-test.md`.
- PSScriptAnalyzer with repo settings reports zero diagnostics on both mirrored copies and the test file (reviewer-run).

#### Error handling and logging

- No catch-all handlers introduced. The change removes an abort path by preventing invalid input from reaching Pester rather than by suppressing the error, and every removal is individually observable in run output.
- The disable case emits exactly one explanatory log line naming the root; the consumer-scenario evidence shows the expected shape in practice (32 prune lines + 1 disable line, run completes with exit 0).

---

## Test Quality Audit

The four new scenarios exactly match the spec's required test matrix, and fail-before evidence proves they detect the pre-fix defect: run against blob `53756b61` (pre-fix), the pass-through scenario passes (required invariance proof) while the mixed-set, empty-set, and rooted-entry scenarios fail with quoted assertion output naming the forwarded nonexistent path. Post-fix, all four pass (reviewer re-ran: 4/4 in 705 ms).

### Reviewed test and QA artifacts

- `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` — four seam-injected scenarios; module-collision-guard `BeforeAll`; `New-Item` mocked inside `InModuleScope` so no filesystem writes occur; path-discriminating `$TestPathExists` predicate correctly keeps the settings-existence check passing while classifying coverage entries. Scenario 3 deliberately sets a non-null `CodeCoverage.OutputPath` so the copy-not-invoked assertion is attributable to the disable flag rather than a null output path.
- `evidence/regression-testing/fail-before.2026-07-25T11-05.md` — fail-before proof (SD3) with pre-fix blob hash, expected 1-pass/3-fail breakdown, and verbatim assertion diagnostics; also records honestly that the plan's literal command returns exit 0 (Pester default) and supplies an exit-code-bearing variant (EXIT_CODE 3).
- `evidence/regression-testing/consumer-scenario.2026-07-25T11-17.md` — integration reproduction using the bundled entry script against a workspace root (`tests/`) containing Pester suites but none of the configured coverage paths: RunStart passes, 111 tests execute, 32 prune lines, exactly one disable line, exit 0.
- `evidence/baseline/powershell-coverage.baseline.xml` + `evidence/qa-gates/powershell-coverage.post-change.xml` — invariance proof inputs; reviewer independently re-parsed both: 31 identical per-file entries, empty set difference, line coverage 90.19% → 90.22%.
- `evidence/qa-gates/coverage-delta.2026-07-25T11-40.md` — per-language delta and changed-line table (8/8 covered); numbers match the reviewer's independent parse exactly.
- `evidence/qa-gates/final-poshqc-format/analyze/test.*.md` — final single-pass toolchain chain, all EXIT_CODE 0.

### Quality assessment prompts

- **Determinism:** all collaborators injected; no wall clock, RNG, network, subprocess, or temp files; `New-Item` mocked to prevent directory creation.
- **Isolation:** one scenario per `It`; each re-arranges its own captured state.
- **Speed:** 4 tests in 705 ms standalone (reviewer-measured).
- **Diagnostics:** `Should -Be` on full arrays and exact log strings; the fail-before artifact demonstrates failures name the exact offending path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: paths and log strings only; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | ✅ PASS | No new process invocation; scriptblock seams invoked with `&` on already-typed parameters. |
| Input validation at boundaries | ✅ PASS | The change is itself boundary validation: config-supplied paths are existence-checked before being handed to Pester. |
| Error handling remains explicit | ✅ PASS | No suppression; the previously-terminating condition is now prevented and logged per path plus one disable notice. |
| Configuration / path handling is safe | ✅ PASS | Rooted entries tested as-is; relative entries joined to `-Root` exactly as before; no string-concatenation path building added. Pre-existing relative-`-Root` double-join noted as Info (out of scope, predates change). |

---

## Research Log

No external research was required for this review. All conclusions derive from the branch diff, the feature folder's spec/plan/research artifacts, the preserved coverage XMLs, and reviewer-executed local commands (PSScriptAnalyzer, Invoke-Formatter comparison, Invoke-Pester, pytest, git hash-object, XML parsing).

---

## Verdict

The change is ready for normal PR flow. It is a minimal, well-commented, seam-based fix applied byte-identically to both mirrored copies, with 100% changed-line coverage, fail-before/pass-after regression evidence, a completed consumer-scenario integration run, and reviewer-verified behavioral invariance in this repository. The five recorded findings are one optional Nit and four Info items, three of which document deliberate, spec-recorded scope decisions (double-join, SD1, release delivery) that the reviewer examined and agrees with. Blocking-finding count: 0; no remediation plan is required. The one follow-through obligation outside this branch is the release action that actually delivers the fix to consumers, plus filing the SD1 tracking issue named in the spec.
