# Feature Audit: Bundled Coverage Path Portability Fix (#409)

---

**Audit Date:** 2026-07-25
**Feature Folder:** `docs/features/active/2026-07-25-bundled-coverage-path-portability-409`
**Base Branch:** `main`
**Head Branch:** `bug/bundled-coverage-path-portability-409`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `036daf8d5fa36a6655078f33e4313b0d2df9590b`)
- **Head branch/commit:** `bug/bundled-coverage-path-portability-409` (commit `dbf2e3f591e22c02013e90f764f278de713a2aac`)
- **Merge base:** `036daf8d5fa36a6655078f33e4313b0d2df9590b` (reviewer confirmed the supplied resolution; per the tie-breaker record, top candidates tie at this merge-base and `main` is selected because no `development` branch exists)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (fresh; head SHA matches current branch head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (fresh; same range) plus direct `git diff 036daf8d..dbf2e3f5` inspection
  - Feature evidence: `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/**` (baseline, qa-gates, regression-testing, other)
  - Additional evidence: reviewer-executed commands (git hash-object, Invoke-Pester, pytest, Invoke-ScriptAnalyzer, Invoke-Formatter comparison, independent coverage-XML parsing, `validate_evidence_locations.py`)
- **Feature folder used:** `docs/features/active/2026-07-25-bundled-coverage-path-portability-409` (sole active folder matching the issue number in the branch name)
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** explicit persisted marker `- Work Mode: full-bug` in `issue.md` (line 12). Per the acceptance-criteria tracking rules, `full-bug` resolves the AC source to `spec.md` only; `user-story.md` is intentionally absent in this mode and its absence is not a finding.
- **Scope note:** the audit scope is the full branch diff vs. the merge-base (37 files, +9050/-2). No caller-supplied scope narrowing was detected. The spec records deliberate feature-scope exclusions (SD1 `Run.Path` risk, no version bump/publish, `pester.runsettings.psd1` unchanged); these are documented decisions in the authoritative AC source, examined and accepted, not audit-scope reductions.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/spec.md` — only source (`## Acceptance Criteria`, 8 checkbox items, all currently checked `[x]` by the executor)

### Acceptance criteria

1. Nonexistent configured coverage paths are pruned inside `Invoke-PoshQCTest` before Pester is invoked (via the `$TestPathExists` seam in the coverage-enabled block), and existing paths are passed through unchanged.
2. Pruning is observable: each pruned path is logged individually through the existing `$Logger` seam, so removal is never silent. Rationale: `.claude/rules/general-unit-test.md` prohibits excluding production files from coverage measurement; silent pruning would be an undetectable coverage exclusion.
3. When pruning removes every configured coverage path, code coverage is disabled for that invocation (`CodeCoverage.Enabled` false at the `$InvokePester` boundary) with a logged explanation, and the test run proceeds. Coverage is never handed to Pester as an enabled-but-empty path set, which would trigger whole-directory `Run.Path` instrumentation (`Pester.psm1:8567-8588`).
4. Behavior is unchanged when every configured coverage path exists: this repository's measured per-file coverage set is identical before and after the fix, proven by comparing the per-file entries of `artifacts/pester/powershell-coverage.xml` between a baseline run (copied to `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/`) and a post-change run (copied to `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/`), with zero prune messages in the post-change run log.
5. The bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` is byte-identical to `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes.
6. Unit tests exercise the pruning behavior deterministically via the injectable seams (`$TestPathExists`, `$Logger`, `$InvokePester`), covering the four required scenarios (all-exist pass-through, mixed set, empty surviving set, rooted absolute entry), with no temp files and no filesystem dependence; fail-before evidence per decision SD3 is captured under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/`.
7. The consumer-repository scenario completes: a Pester run against a workspace root that contains Pester tests but none of the configured coverage paths finishes test execution instead of aborting at RunStart, with output captured under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/`.
8. Full toolchain pass completed for the changed surfaces (`run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`, plus the parity pytest), all stages clean in a single pass.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Prune nonexistent paths via `$TestPathExists` before Pester; pass existing paths unchanged | PASS | Diff hunk `PoshQC.Testing.psm1:346-366`: `$survivingCoveragePaths = @($resolvedCoveragePaths \| Where-Object { & $TestPathExists $_ })` placed after final resolution and before `$InvokePester`. Test scenarios 1, 2, 4 assert the forwarded set (full pass-through, mixed-set survival in original order, rooted entry kept as-is). | `git diff 036daf8d..dbf2e3f5 -- scripts/powershell/PoshQC/PoshQC.Testing.psm1`; `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 -Output Normal"` (reviewer: 4/4 passed) | Pruning occurs at the single authoritative site in the coverage-enabled block. |
| 2 | Each pruned path logged individually via `$Logger`; never silent | PASS | Line 355: `& $Logger "Pruned nonexistent code coverage path: $prunedPath"` inside a per-path `foreach`. Scenario 2 asserts the exact message text with the resolved value; scenario 3 asserts count 2 for two pruned paths; consumer-scenario run shows 32 individual prune lines. | Reviewer Pester run (above); inspection of `evidence/regression-testing/consumer-scenario.2026-07-25T11-17.md` | Satisfies the no-silent-coverage-exclusion rationale from `.claude/rules/general-unit-test.md`. |
| 3 | Empty surviving set disables coverage at the `$InvokePester` boundary with logged explanation; run proceeds; never enabled-but-empty | PASS | Lines 358-366: else-branch sets `$config.CodeCoverage.Enabled = $false` and `$coverageEnabled = $false`, logs one explanation. Scenario 3 asserts `Enabled` false at the injected `$InvokePester`, disable message exactly once, summary replay occurred, and `$CopyCoverage` not invoked (with non-null `OutputPath` so the assertion is attributable to the disable flag). Consumer scenario: exactly one disable line, run completed. | Reviewer Pester run; `evidence/regression-testing/consumer-scenario.2026-07-25T11-17.md` (EXIT_CODE 0, 111 tests executed) | Enabled-but-empty handoff is structurally impossible: the only path that leaves coverage enabled assigns a non-empty `Path`. |
| 4 | Behavioral invariance in this repo: identical per-file coverage set, zero prune messages post-change | PASS | Reviewer independently parsed both preserved XMLs: 31 per-file entries each, set difference empty in both directions; line coverage 90.19% → 90.22% (missed lines unchanged at 233). Zero prune and zero disable messages in the post-change direct-run log per `evidence/qa-gates/direct-module-post-change-run.2026-07-25T11-30.md` (grep count 0), corroborated by the settings-file check (`missing under repo root: 0`, 31 unique entries). Harness parity documented: baseline and post-change runs used the identical direct repo-root invocation, differing only in module blob (`53756b61` → `e8d9a396`). | Reviewer Python XML comparison over `evidence/baseline/powershell-coverage.baseline.xml` and `evidence/qa-gates/powershell-coverage.post-change.xml`; artifacts `coverage-file-set-delta.2026-07-25T11-32.md`, `coverage-delta.2026-07-25T11-40.md` | The zero-prune-message claim rests on the executor's captured run log (reviewer did not re-execute the 36 s full direct run); it is corroborated by the reviewer-verified identical entry sets and the settings-file existence check, which make a prune arithmetically inconsistent. |
| 5 | Bundled mirror byte-identical; parity pytest passes | PASS | `git hash-object` on both files returns the identical blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`; parity pytest passed in reviewer re-run. | `git hash-object scripts/powershell/PoshQC/PoshQC.Testing.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`; `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` (reviewer: 1 passed in 0.02 s) | Both verifications performed independently by the reviewer on the current working tree at head. |
| 6 | Deterministic seam-injected unit tests for all four scenarios; no temp files; fail-before evidence per SD3 | PASS | Test file review: four `It` blocks exactly matching the required scenarios; all collaborators injected; `New-Item` mocked inside `InModuleScope` (no filesystem writes); no temp files, sleeps, or subprocesses. Fail-before artifact `evidence/regression-testing/fail-before.2026-07-25T11-05.md` records the pre-fix run (blob `53756b61`): 1 expected pass (pass-through) and 3 expected failures with verbatim assertion diagnostics; pass-after artifact `pass-after.2026-07-25T11-14.md` and reviewer re-run (4/4) confirm post-fix. | Reviewer file inspection; reviewer Pester run; artifact inspection under `evidence/regression-testing/` | Fail-before evidence also honestly documents Pester's default exit-code behavior and supplies an exit-code-bearing variant (EXIT_CODE 3). |
| 7 | Consumer-repository scenario completes instead of aborting at RunStart; output captured | PASS | `evidence/regression-testing/consumer-scenario.2026-07-25T11-17.md`: bundled entry script run with `-WorkspaceRoot tests` (contains 10 Pester suite files, none of the configured coverage paths); RunStart passed, 111 passed / 0 failed / 7 skipped, 32 prune lines, 1 disable line, EXIT_CODE 0. Tool-output churn under `tests/artifacts/` was cleaned up (`evidence/other/consumer-scenario-cleanup.2026-07-25T11-18.md`); reviewer confirmed `tests/artifacts` absent and working tree clean. | Artifact inspection; `git status --porcelain` (empty); `ls tests/artifacts` (does not exist) | The run exercised the fixed in-repo bundled mirror (blob `e8d9a396`), reproducing the reported condition without an external checkout. |
| 8 | Full toolchain pass for changed surfaces, all stages clean in a single pass | PASS | Final chain: `final-poshqc-format.2026-07-25T11-22.md` (EXIT_CODE 0, no reformats) → `final-poshqc-analyze.2026-07-25T11-23.md` (EXIT_CODE 0) → `final-poshqc-test.2026-07-25T11-26.md` (EXIT_CODE 0; 1354 tests, 0 failures); parity pytest clean standalone (`parity-pytest.2026-07-25T11-12.md`) and inside the full Python run (`final-python-pytest.2026-07-25T11-38.md`, 2084 passed). No stage changed files, so no loop restart was required. Reviewer independently re-verified format (check-only comparison, clean), lint (PSSA per changed file, 0 diagnostics), the new tests (4/4), and the parity pytest (1 passed). | Artifact inspection; reviewer commands listed in policy audit Appendix B | Single-pass claim is consistent across the artifact chain and reviewer spot checks. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After merge, execute the out-of-scope release action (version bump and npm publish of `@danmoisan/drm-copilot-mcp` > 1.0.18) and re-run the original TaskMaster reproduction against the published version to close the consumer-facing loop on issue #409.
2. File the separate tracking issue for the SD1 latent `Run.Path` discovery-time portability risk named in `spec.md` Rollout & Follow-up, and consider covering the pre-existing relative-`-Root` double-join (recorded in `evidence/regression-testing/consumer-scenario.2026-07-25T11-17.md`) in the same issue.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 8 criteria evaluated PASS. All 8 were already checked `[x]` in `spec.md` by the executor with per-task verification; the reviewer verified each against evidence and confirms the check-off state is correct. No source-file checkbox change was made by this audit because no unchecked PASS item remained.
- No criterion is PARTIAL, FAIL, or UNVERIFIED, so no item was left or reverted to unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/spec.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/spec.md` | 8 | 8 | 0 | Checkbox-backed; sole authoritative source under `full-bug` work mode |
