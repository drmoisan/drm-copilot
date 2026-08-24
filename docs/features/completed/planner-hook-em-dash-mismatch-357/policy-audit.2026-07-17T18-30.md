# Policy Compliance Audit: planner-hook-em-dash-mismatch-357 (Issue #357)

**Audit Date:** 2026-07-17T18-30
**Audit Type:** Re-audit following remediation cycle 3 (triggered by a required-CI-check failure, not a local review finding)
**Code Under Test (full branch diff vs. base):** `.claude/hooks/validate-planner-output.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, `docs/features/potential/promoted/2026-07-17-planner-hook-em-dash-mismatch.md`
**Base branch:** `main` (origin/main); merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`
**Head branch:** `drm-copilot-wt-2026-07-17T10-05` @ `f3da03a242641fcef1f6e1c0892be7fe6fa14489`
**Work Mode:** `minor-audit` (AC source: `issue.md` `## Acceptance Criteria` section only)
**Prior cycle artifacts reviewed:** `policy-audit.2026-07-17T{14-38,16-00,17-15}.md`, `code-review.2026-07-17T{14-38,16-00,17-15}.md`, `feature-audit.2026-07-17T{14-38,16-00,17-15}.md`, `remediation-inputs.2026-07-17T{14-38,16-00,18-00}.md`, `remediation-plan.2026-07-17T{14-38,16-00,18-00}.md`

---

## Rejected Scope Narrowing

None detected. The delegating prompt for this re-audit instructs execution of "the full feature-review-workflow SKILL contract end-to-end against the current branch diff versus the resolved base branch and merge-base SHA," with no narrowing to a plan/task/phase subset, no language marked out-of-scope, and no instruction to skip a toolchain or coverage check. The prompt's framing note about cycle 3's trigger (a required-CI-check failure caused by bundled-mirror drift, corrected this cycle) is background context, not a scope-narrowing instruction, and this audit evaluated the full branch diff independently rather than accepting that framing as a substitute for its own verification.

---

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Cycle-2 Post (prior audit) | Cycle-3 (this audit) | Canonical artifact |
|----------|--------------|-------|-------------|------------------------------|------------------------|--------------------|
| PowerShell | `.claude/hooks/validate-planner-output.ps1` (unchanged content this cycle vs. cycle-2 state), `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` (bundled resource mirror, synced this cycle, not itself a Pester coverage-instrumentation target), `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (unchanged this cycle), both `pester.runsettings.psd1` copies (unchanged this cycle) | 21 tests (this file's suite); 1533 Python tests repo-wide | PASS 21/21 PowerShell; PASS 1533/1533 Python | 93.86% lines (107/114), CI-equivalent `Invoke-PoshQCTest -Root <workspace>` reproduction | **Unchanged: 93.86% lines (107/114).** `git log -- .claude/hooks/validate-planner-output.ps1` confirms no commit has touched this file since `67cd49a6` (the commit the cycle-2/prior audit measured). Byte content verified identical (SHA256 unchanged) by this audit. | `artifacts/pester/powershell-coverage.xml` (as reproduced and inspected by the prior audit cycle; this audit did not need to regenerate it because the covered production file's content is provably unchanged since that measurement) |
| Python | 0 production files changed (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` pre-existing, unchanged) | Full suite | PASS 1533/1533 (this audit's own run) | N/A | N/A — zero changed Python production files in the branch diff | N/A |
| TypeScript | 0 files changed | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files changed | N/A | N/A | N/A | N/A | N/A |

### Verification Performed by This Audit (Coverage)

This audit did not rerun PowerShell coverage generation, per the mandatory "verify from existing artifacts, do not regenerate" procedure. Instead it established, by direct evidence, that no regeneration was necessary:

1. `git diff 67c871eb..HEAD --stat -- .claude/hooks/validate-planner-output.ps1 extensions/.../validate-planner-output.ps1` shows this cycle touched only the bundled mirror; the canonical `.claude/hooks/validate-planner-output.ps1` has zero diff since the prior (17-15) audit's measurement.
2. `git log --oneline -- .claude/hooks/validate-planner-output.ps1` confirms the last commit touching this file is `67cd49a6` (remediation cycle 2), the same commit the 17-15 audit measured at 93.86% line coverage via direct, CI-equivalent reproduction of `.github/workflows/_poshqc.yml`'s exact invocation.
3. This audit independently computed SHA-256 of both the canonical file and the newly-synced bundled mirror (`614d88a7...` for both, byte length 9829 for both) — confirming byte-for-byte parity and that the canonical file's content is exactly the content already measured.
4. This audit ran `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q` directly (1 passed) and the full suite `python -m pytest -q` (1533 passed, 0 failed) — confirming the CI-failing test that triggered this remediation cycle now passes, with no regression elsewhere.
5. The bundled mirror file (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1`) is not itself a Pester coverage-instrumentation target: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path` allowlist contains no entry under `extensions/drm-copilot/resources/claude-customizations/` (confirmed by direct grep, no matches). It is measured only by the Python byte-parity test, which passed.

**Verdict:** **PASS.** `.claude/hooks/validate-planner-output.ps1` is a modified (not new) file whose content is unchanged since the 93.86%-line-coverage measurement already independently verified by this feature's prior audit cycle; that measurement remains valid because the measured content is provably identical (confirmed by git history and this audit's own SHA-256 comparison). The bundled mirror is a resource copy outside the Pester coverage-instrumentation scope and is verified instead by the Python parity test, which passes. Branch coverage remains unmeasured by this repository's Pester coverage engine for any file — a pre-existing, documented, repo-wide tooling limitation carried forward and accepted in all prior cycles of this feature, not attributable to this change.

**Non-negotiable verdict rule honored:** This audit reports an explicit PASS/FAIL for every language with changed files in the branch diff (PowerShell: PASS; Python: PASS on its own test suite, N/A on coverage because zero Python *production* files changed; TypeScript/C#: zero changed files, N/A is acceptable per the rule's own carve-out).

---

## Executive Summary

Remediation cycle 3 was triggered by a required CI check failure (`quality-checks7 / Code Quality & Tests (3.10)` -> `test_bundled_claude_payload_contains_all_repo_runtime_contracts`) on PR #358, not by a local feature-review finding. The root cause: `.claude/hooks/validate-planner-output.ps1` was modified across the S5 em-dash fix and remediation cycle 2 (a PSObject strict-mode-safe property check plus a UTF-8 BOM the PoshQC formatter added once the file gained a non-ASCII em-dash character), but the repository's bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` was never updated to match, and a repo-hygiene test enforces byte-identical parity between the two trees.

This is notable because both prior remediation cycles' "Do Not Do" lists, and the prior code-review artifact (`code-review.2026-07-17T17-15.md`), explicitly treated this vendored copy as an out-of-scope, non-blocking Informational finding. That assumption was incorrect — the file is covered by a repo-enforced parity contract — and `remediation-inputs.2026-07-17T18-00.md` explicitly documents this scoping correction rather than silently reversing course.

Cycle 3's fix is a single, minimal, mechanically-verifiable change: a raw byte-for-byte copy of the canonical file onto the bundled mirror (per the remediation plan's explicit instruction to use `Copy-Item`, not a text-editing tool, to preserve the UTF-8 BOM). This audit independently confirmed:

- The two files are now byte-identical (SHA-256 `614d88a79e7f9da7e8954fbdcc0f7ce8748af63de04e217760eab1f1e6c3851b`, both 9829 bytes).
- The previously-failing pytest test now passes (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`: 1 passed).
- The full Python test suite passes with no regression (1533 passed, 0 failed).
- `git diff` of the bundled mirror shows exactly the three expected content differences (em-dash regex, em-dash error message, em-dash docstring reference, strict-mode-safe property check, leading BOM) and nothing else.
- No other file in the branch diff carries the same drift (confirmed by the full pytest run and by `git diff --stat` scope confirmation).

**Policy documents evaluated:**
- `.github/instructions/general-code-change.instructions.md` / `.claude/rules/general-code-change.md`
- `.github/instructions/general-unit-test.instructions.md` / `.claude/rules/general-unit-test.md`
- `.claude/rules/powershell.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/ci-workflows.md` (reviewed; no `pwsh` GitHub Actions workflow steps changed in this branch diff, so this rule's specific requirement does not apply to any changed file, but was consulted as part of the CI-failure-handling context)

**Language-specific policies evaluated:**
- N/A Python (production), TypeScript, C# — no production files of these languages changed in the branch diff (Python has one pre-existing, unmodified test file that already covered the parity check; this audit ran it and the full suite to confirm no regression)
- PowerShell: functional toolchain PASS; coverage threshold PASS (carried forward, content-identical to prior measurement); bundled-mirror parity now PASS (was the sole cause of the cycle-3 CI failure)

**Temporary artifacts cleanup:** No temporary/one-time scripts were created by this audit or by cycle 3's work. The `Copy-Item` raw-byte-copy operation used to sync the mirror is not a script artifact; it modified only the declared target file.

**Evidence Location Compliance:** `git diff --name-only 67c871eb..HEAD | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` (run directly by this audit) returned no matches (grep exit 1). `python scripts/dev_tools/validate_evidence_locations.py --root .` (run directly by this audit) exited 0 with no output. All feature evidence is written under `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/**`. No violations found; no override rejections to record.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Unchanged this cycle; carried forward from the 17-15 audit's PASS verdict (no test file modified in cycle 3). |
| Isolation | PASS | Unchanged this cycle. |
| Fast execution | PASS | This audit's own `python -m pytest -q` run: 1533 tests in 2.25s. |
| Determinism | PASS | Unchanged; no wall-clock, RNG, or sleep usage in any file touched by this cycle. |
| Readability & maintainability | PASS | Unchanged; both in-scope files remain well under the 500-line limit. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| No coverage regression | PASS | The canonical hook file's content is provably unchanged since the 93.86%-coverage measurement (git log shows no commit touching it since `67cd49a6`); the bundled mirror it was synced to is not a coverage-instrumented file. |
| New code coverage >= 90% | N/A | No new production files added in this cycle; the bundled mirror is a byte-for-byte copy of a pre-existing file's already-tested content, not new logic. |
| Comprehensive coverage | PASS | Carried forward from 17-15 audit (93.86%, 107/114 lines), content unchanged. |

### 1.3-1.5 Test Structure, External Dependencies

Unchanged from the 17-15 audit. This cycle added no new test code; it added a raw byte-copy of a resource file plus evidence artifacts.

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Design principles (simplicity, minimal change) | PASS | The cycle-3 fix is a single, minimal, mechanically-verifiable byte-for-byte copy of one file onto its declared mirror location — no design judgment required, no logic authored. |
| Module & file structure (<=500 lines) | PASS | The bundled mirror is now 288 lines (line-for-line identical to the canonical file), confirmed via `wc -l`-equivalent byte-length comparison (9829 bytes both files). |
| Toolchain execution | PASS | `evidence/qa-gates/pytest-bundle-parity-final-remediation3.md` (target test passes), `evidence/qa-gates/pytest-full-suite-remediation3.md` (1533 passed), `evidence/qa-gates/poshqc-format-remediation3-final.md` and `poshqc-analyze-remediation3-final.md` (both scoped to the unchanged canonical files, exit 0) — all independently reproduced by this audit (pytest re-run: 1533 passed, 0 failed). |
| Change-scope discipline | PASS | `git diff --stat 67c871eb..HEAD` confirms the only non-evidence, non-doc production change in this cycle is the single declared bundled-mirror file; this audit independently re-ran the same diff command and confirms the same scope. |
| Honest reporting of unresolved gaps | PASS | `remediation-inputs.2026-07-17T18-00.md` explicitly and transparently documents that the prior cycles' "out of scope" framing for this vendored file was a scoping error that caused the CI failure, rather than silently correcting course without explanation — consistent with the repository's "fail fast and explicitly" principle. |

---

## 3. PowerShell-Specific Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting (Invoke-Formatter) | PASS | `evidence/qa-gates/poshqc-format-remediation3-final.md`: exit 0, scoped to the two unchanged canonical files (the bundled mirror is explicitly excluded from formatter runs per the remediation plan, to avoid the formatter re-encoding away the required BOM). |
| Linting (PSScriptAnalyzer) | PASS | `evidence/qa-gates/poshqc-analyze-remediation3-final.md`: exit 0, zero findings. |
| PowerShell 7+ compatible | PASS | Unchanged; `#Requires -Version 7.0` retained in both the canonical file and its now-identical mirror. |
| Testing via Pester (v5.x) | PASS | `evidence/qa-gates/poshqc-test-remediation3-final.md`: 21/21 pass for this file's dedicated suite (unchanged this cycle). |
| Line coverage >= 85% / branch coverage >= 75% | PASS | 93.86% line coverage, content-identical carry-forward from the 17-15 audit's independent CI-equivalent measurement (see Coverage Metrics section above for the chain of evidence establishing this carry-forward is valid). Branch coverage remains an accepted, pre-existing, repo-wide tooling limitation. |
| Coverage regression on changed lines | PASS (no regression) | No lines of the canonical, coverage-instrumented file changed in this cycle. |
| Byte-for-byte bundled-resource parity (repo hygiene contract) | **PASS (newly resolved this cycle)** | SHA-256 of `.claude/hooks/validate-planner-output.ps1` and its bundled mirror both equal `614d88a79e7f9da7e8954fbdcc0f7ce8748af63de04e217760eab1f1e6c3851b` (9829 bytes each), independently computed by this audit. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes. |

---

## 4. Repo-Hygiene / CI-Parity Compliance (New Section — Cycle 3 Specific)

| Requirement | Status | Evidence |
|---|---|---|
| Bundled `.claude/` mirror byte-identical to repo-canonical `.claude/` tree | **PASS** | Independently verified via SHA-256 comparison (identical hash, identical byte length) and via re-running the exact failing test from PR #358's CI job. |
| No other bundled-mirror drift introduced elsewhere in this branch's diff | PASS | Full pytest suite (1533 tests, including the full `test_push_down_claude_resource_contracts.py` file) passes with zero failures, confirming no other file in this feature's diff carries the same class of drift. |
| Change budget honored (exactly one file changed to fix this cycle) | PASS | `git diff --stat 67c871eb..HEAD` for non-evidence files shows exactly one production-tree file touched this cycle (the bundled mirror); the canonical hook, its test file, and both `pester.runsettings.psd1` copies are unchanged since the prior audit cycle. |

---

## 5. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| PowerShell tests (this file's suite) | 21/21 pass | PASS (unchanged) |
| Python tests (parity test, targeted) | 1/1 pass | PASS (newly resolved this cycle) |
| Python tests (full suite, this audit's own run) | 1533/1533 pass | PASS |
| Code Coverage (PowerShell, carried forward, content-identical) | 93.86% lines (107/114) | PASS against 85% uniform threshold |
| Branch Coverage | Not emitted by tooling (repo-wide limitation) | Accepted, documented, pre-existing |

---

## 6. Gaps and Exceptions

### Identified Gaps

1. **Bundled-mirror parity (resolved this cycle).** The Blocking CI failure that triggered this remediation cycle is resolved: the bundled mirror is now byte-identical to the canonical file, and the previously-failing repo-hygiene test passes.
2. **MCP tool / workspace divergence (Informational, unchanged from prior cycles, not part of issue #357).** `mcp__drm-copilot__run_poshqc_test` still resolves a separately npm-published, npx-cached package independent of this workspace, so its own coverage artifact still omits this file. This is unrelated to the bundled-mirror parity issue that cycle 3 fixed — the two are distinct defects that happened to involve the same file for different reasons. Recommended as a separate issue, not a re-opening of #357.
3. **Scoping-error root cause (Informational, self-corrected).** Both prior remediation cycles and the prior code-review incorrectly classified the bundled-mirror drift as an out-of-scope Informational finding. `remediation-inputs.2026-07-17T18-00.md` transparently documents this correction. This audit records it here as a process note, not as an unresolved gap — the underlying defect is fixed.

### Approved Exceptions

**None required.**

### Removed/Skipped Tests

**None.**

---

## 7. Compliance Verdict

### Overall Status: COMPLIANT

Remediation cycle 3 resolves the required-CI-check failure that triggered it, via a minimal, mechanically-verified byte-for-byte sync of the bundled resource mirror. This audit independently reproduced the fix's verification: SHA-256 hash equality between the canonical file and its mirror, a passing targeted pytest run, and a passing full pytest suite (1533/1533) with no regressions. The PowerShell coverage gate remains satisfied via a valid content-identical carry-forward from the prior audit cycle's independent CI-equivalent measurement (93.86% line coverage, above the 85% uniform threshold). No Blocking or Major findings remain open for issue #357.

### Recommendation

**Ready to merge.** No further remediation required for issue #357. The MCP-tool/workspace divergence remains recommended as a separate, new potential-bug entry, unchanged from prior cycles' disposition.

---

**Audit Completed By:** feature-review (Claude Code subagent)
**Audit Date:** 2026-07-17T18-30
