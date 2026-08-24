# Policy Compliance Audit: planner-hook-em-dash-mismatch-357 (Issue #357)

**Audit Date:** 2026-07-17T16-00
**Audit Type:** Re-audit following remediation cycle 1
**Code Under Test:** `.claude/hooks/validate-planner-output.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
**Base branch:** `main` (origin/main); merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`
**Head branch:** `drm-copilot-wt-2026-07-17T10-05` @ `6e7bc63cf7941e82af09ca931ae066e2196b513f`
**Work Mode:** `minor-audit` (AC source: `issue.md` `## Acceptance Criteria` section only)
**Prior cycle artifacts reviewed:** `policy-audit.2026-07-17T14-38.md`, `code-review.2026-07-17T14-38.md`, `feature-audit.2026-07-17T14-38.md`, `remediation-inputs.2026-07-17T14-38.md`, `remediation-plan.2026-07-17T14-38.md`

---

## Rejected Scope Narrowing

None detected. The delegating prompt for this re-audit explicitly instructs execution of "the full feature-review-workflow SKILL contract end-to-end against the current branch diff versus the resolved base branch and merge-base SHA," with no narrowing to a plan/task/phase subset, no language marked out-of-scope, and no instruction to skip a toolchain or coverage check. This audit independently re-verified the full branch diff (`67c871eb..HEAD`) rather than relying solely on the caller's characterization of what changed.

---

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage (cycle 0) | Post-remediation-1 Coverage | Repo-wide canonical artifact |
|----------|--------------|-------|-------------|------------------------------|------------------------------|-------------------------------|
| PowerShell | 2 production/test files touched by remediation 1 (`.claude/hooks/validate-planner-output.ps1` carried unchanged from cycle 0; `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` newly touched in cycle 1) | 7 tests | PASS 7/7, 0 fail | 69.87% lines (109/156) | 73.72% lines (115/156), ad hoc measurement only | **Absent** — no `<class>`/`<sourcefile>` entry for `validate-planner-output.ps1` in `artifacts/pester/powershell-coverage.xml` |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A |
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- Cycle-1 remediation baseline: `evidence/remediation-baseline/poshqc-test-baseline.md`, `evidence/remediation-baseline/coverage-xml-baseline-check.md`.
- Cycle-1 remediation post-change: `evidence/qa-gates/poshqc-test-remediation1-final.md`, `evidence/qa-gates/coverage-xml-post-check-remediation1.md`, `evidence/qa-gates/coverage-delta-remediation1.md`.
- This audit independently re-confirmed both of the following, directly against the live repository state (not solely from feature-authored evidence):
  - `grep -n "sourcefilename=\"validate-planner-output" artifacts/pester/powershell-coverage.xml` — **zero matches**.
  - `grep -n "validate-planner-output" extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — the entry exists only in the `scripts/` copy; the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` copy (confirmed by `diff` to be otherwise byte-identical to the `scripts/` copy except for this one missing entry) does not contain it.
  - Confirmed via `git log --oneline -- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, which shows commit `f3701f7f` (issue #344) previously updated this exact bundled file when the `scripts/` copy's `CodeCoverage.Path` allowlist was extended — corroborating the remediation cycle's root-cause finding that these two files must be kept in sync for the canonical MCP-driven coverage artifact to measure a newly-added file.

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, and this audit reports FAIL below rather than suppressing the gap.

---

## Executive Summary

Remediation cycle 1 correctly implemented three of its four enumerated fixes: it added `.claude/hooks/validate-planner-output.ps1` to the `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` allowlist, added a new regression test exercising the previously-uncovered malformed-phase-heading branch (lines 136-140), and removed the duplicate em-dash test flagged in the prior code review. All format/analyze/test toolchain stages pass cleanly (7/7 tests). Ad hoc line coverage for `.claude/hooks/validate-planner-output.ps1` improved from 69.87% to 73.72% (a genuine, verified +3.85 percentage-point gain), and the originally-targeted lines 136-140 are now covered.

However, **the coverage-threshold gap identified in cycle 0 is not closed.** Two conditions remain true after this cycle:

1. 73.72% ad hoc line coverage remains below the uniform 85% line-coverage threshold (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/general-unit-test.md`).
2. The canonical coverage artifact (`artifacts/pester/powershell-coverage.xml`), produced by `mcp__drm-copilot__run_poshqc_test`, still does not measure this file at all — a root cause discovered and honestly documented during this remediation cycle: the MCP tool resolves its Pester settings from the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, a separate file from the cycle's budgeted `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and the remediation cycle's change budget did not include the bundled copy. This audit independently confirmed both facts directly against the repository.

This is the same Blocking finding as cycle 0, now partially — but not fully — remediated. A second remediation cycle is required.

**Policy documents evaluated:**
- `.github/instructions/general-code-change.instructions.md` / `.claude/rules/general-code-change.md`
- `.github/instructions/general-unit-test.instructions.md` / `.claude/rules/general-unit-test.md`
- `.claude/rules/powershell.md`
- `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- N/A Python, TypeScript, C# (no files of these languages changed in the branch diff)
- PowerShell: functional toolchain PASS; coverage threshold FAIL (unresolved from cycle 0)

**Temporary artifacts cleanup:** No temporary/one-time scripts were created; ad hoc `Invoke-Pester` coverage measurements used a scratchpad `OutputPath` and did not modify tracked repository files (confirmed via `git status --short` in the cycle-1 evidence).

**Evidence Location Compliance:** `python scripts/dev_tools/validate_evidence_locations.py --root .` was run directly by this audit and exited 0 with no findings. A `git diff --name-only` scan of the full branch diff against the merge-base found no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence for this feature is correctly written under `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/**`. No violations found; no override rejections to record.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Each `It` block re-mocks `Get-PlanFileContent` independently; confirmed by direct read of `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (7 `It` blocks, each with its own `Mock` and fixture). |
| Isolation | PASS | Each test targets one behavior; the new test (`blocks when a phase heading is malformed (missing the em dash separator)`) targets exactly the `-not $phaseMatch.Success` branch. |
| Fast execution | PASS | In-process Pester run with mocked filesystem boundary; no network or real filesystem I/O. |
| Determinism | PASS | No wall-clock, RNG, or sleep usage; literal fixture strings only. |
| Readability & maintainability | PASS (improved from PARTIAL) | The duplicate `It 'allows termination when phase headings use the canonical em dash (U+2014)'` test identified in cycle 0's code review has been removed; the test file (verified by direct read) now contains 7 distinct `It` blocks with no byte-identical duplicates. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | `evidence/remediation-baseline/poshqc-test-baseline.md` restates the 69.87% cycle-0 baseline. |
| No coverage regression | PASS (no regression) / **FAIL (absolute threshold)** | `evidence/qa-gates/coverage-delta-remediation1.md`: line coverage improved from 69.87% to 73.72% ad hoc (+3.85pp, 109->115 of 156 commands). No regression occurred, and this is real forward progress. The absolute level remains below the 85% uniform-tier requirement and below the canonical-artifact measurement floor (which is effectively 0% for this file, since it is not measured at all). |
| New code coverage >= 90% | N/A | No new files added; both changed production/test files are modifications of pre-existing files. |
| Comprehensive coverage | PARTIAL (improved) | Lines 137-138 (the fixed error-message branch) and the incidental lines 167/195/196 are now covered, per `evidence/qa-gates/coverage-delta-remediation1.md`. 28 lines remain uncovered (down from 33), concentrated in `Get-PlanFileContent`'s real disk-read body (lines 45-57), which every test — before and after both cycles — mocks out rather than exercises. |
| Positive flows | PASS | `allows termination when the plan satisfies the structural contract`. |
| Negative flows | PASS | 5 `blocks when...` tests, including the new malformed-heading test. |
| Edge cases | PASS (closed from cycle 0) | The malformed-phase-heading edge case (line 137, flagged as a specific gap in cycle 0's code review) is now exercised by the new test case. |
| Error handling | PASS | JSON-parse failure and empty-payload paths remain exercised, unchanged from cycle 0. |
| Concurrency / State transitions | N/A | Unchanged from cycle 0; no concurrency or stateful surface in scope. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: cycle-0 baseline 69.87% lines (109/156) -> cycle-1 post-remediation 73.72% lines (115/156), ad hoc measurement. Change: **+3.85pp**, a genuine improvement, but the file remains below the uniform 85% line / 75% branch threshold, and remains entirely absent from the canonical `artifacts/pester/powershell-coverage.xml` artifact (confirmed independently by this audit via direct `grep`). Disposition: **FAIL** (absolute level below threshold; canonical artifact still does not measure this file). Evidence: `evidence/qa-gates/coverage-delta-remediation1.md`, `evidence/qa-gates/coverage-xml-post-check-remediation1.md`, and this audit's independent `grep` confirmation above.

### 1.3-1.5 Test Structure, External Dependencies, Policy Audit Requirement

Unchanged from cycle 0's PASS findings (Arrange-Act-Assert structure, descriptive test names, `Get-PlanFileContent` mocked as the sole filesystem boundary, no temporary files). Direct read of the current test file confirms these properties still hold after the cycle-1 edits (new test added, duplicate test removed).

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Design principles (simplicity, minimal change) | PASS | Cycle 1's change is a one-line allowlist addition plus one new/one removed test case — minimal and within its declared budget. |
| Module & file structure (<=500 lines) | PASS | `.claude/hooks/validate-planner-output.ps1`: 289 lines. `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`: 126 lines. Both well under the 500-line limit (confirmed by direct read). |
| Toolchain execution (format -> analyze -> test) | PASS | `evidence/qa-gates/poshqc-format-remediation1-final.md` (exit 0), `evidence/qa-gates/poshqc-analyze-remediation1-final.md` (exit 0), `evidence/qa-gates/poshqc-test-remediation1-final.md` (exit 0, 7/7 pass) — all independently corroborated by this audit's direct read of the current test file and hook file. |
| Change-scope discipline | PASS | `evidence/qa-gates/change-scope-check-remediation1.md`: scoped `git diff --stat` confirms only the three budgeted files plus this feature folder's evidence were modified; the vendored `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` copy was not touched (confirmed independently by this audit, see Section 8). |
| Honest reporting of unresolved gaps | PASS | The remediation cycle's own evidence (`coverage-delta-remediation1.md`, `coverage-xml-post-check-remediation1.md`) explicitly states the coverage gap remains unresolved and explains the root cause, rather than silently marking it resolved. This is the correct behavior under "fail fast and explicitly" and is treated favorably by this audit. |

---

## 3. PowerShell-Specific Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting (Invoke-Formatter) | PASS | `evidence/qa-gates/poshqc-format-remediation1-final.md`: exit 0, no unexpected diff. |
| Linting (PSScriptAnalyzer) | PASS | `evidence/qa-gates/poshqc-analyze-remediation1-final.md`: exit 0, zero findings across all three in-scope files. |
| PowerShell 7+ compatible | PASS | `#Requires -Version 7.0` retained; no version-specific syntax introduced. |
| Testing via Pester (v5.x), PoshQC config | PASS (MCP-wrapped) / **FAIL (canonical coverage measurement)** | `mcp__drm-copilot__run_poshqc_test` reports 7/7 pass, but resolves settings from the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, not the repo's `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` that this cycle edited. This means the canonical, MCP-tool-driven coverage measurement for this file is not actually wired up despite the allowlist edit landing in the repo. |
| Line coverage >= 85% / branch coverage >= 75% | **FAIL** | 73.72% ad hoc line coverage (canonical artifact: file not measured at all); branch coverage not emitted by Pester 5.6.1's coverage engine for any file in this repository (documented, accepted tooling limitation per `.claude/agent-memory/atomic-executor/project_powershell_coverage_gotchas.md`, not attributable to this change). |
| Coverage regression on changed lines | PASS (no regression) | Lines 121, 137 (the cycle-0 changed lines) and the newly-covering test's exercised lines show improvement, not regression. |

---

## 4. Test Coverage Detail

### `Get-PlanStructureValidationReport` / `Invoke-PlannerOutputValidation` (7 tests, post-remediation-1)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| blocks when CLAUDE_HOOK_INPUT is empty | Negative | PASS |
| blocks when the output is missing an exact preflight signal | Negative | PASS |
| blocks when the advertised plan-path does not exist on disk | Negative | PASS |
| blocks when Phase 0 baseline and policy-read tasks are missing | Edge case | PASS |
| blocks when a task omits an explicit path | Edge case | PASS |
| blocks when a phase heading is malformed (missing the em dash separator) | Edge case (new in cycle 1) | PASS |
| allows termination when the plan satisfies the structural contract | Positive | PASS |

**Coverage:** 73.72% of `.claude/hooks/validate-planner-output.ps1` (115/156 analyzed commands, ad hoc measurement), up from 69.87% at cycle-0 baseline. Canonical artifact still does not measure this file. Branch coverage not measurable with the current Pester 5.6.1 coverage engine (repository-wide tooling limitation).

**Not covered:** Lines 45-57 (the real-disk-read body of `Get-PlanFileContent`, mocked out by every test in this suite before and after both cycles); 28 unique lines total remain uncovered, per `evidence/qa-gates/coverage-delta-remediation1.md`.

---

## 5. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 7 | PASS |
| Tests Passed | 7 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Duplicate tests | 0 (removed in cycle 1) | PASS (improved from cycle 0's 1 duplicate) |
| Test File Size | 126 lines | PASS |
| Code Coverage (ad hoc) | 73.72% lines, branch not emitted by tooling | **FAIL** against 85%/75% uniform threshold |
| Code Coverage (canonical artifact) | File absent from `artifacts/pester/powershell-coverage.xml` | **FAIL** — mandatory coverage verification cannot be completed against the canonical artifact for this file |

---

## 6. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | exit 0 | PASS |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | exit 0 | PASS |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` | 7/7 pass | PASS |
| Canonical coverage measurement | direct `artifacts/pester/powershell-coverage.xml` inspection | file absent | **FAIL** |

---

## 7. Gaps and Exceptions

### Identified Gaps

1. **Coverage Compliance Finding (Blocking, carried over from cycle 0, partially remediated).** `.claude/hooks/validate-planner-output.ps1` ad hoc line coverage is now 73.72% (115/156 commands), an improvement over the cycle-0 baseline of 69.87%, but still below the uniform 85% line / 75% branch threshold (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`). The canonical PowerShell coverage artifact, `artifacts/pester/powershell-coverage.xml`, still does not include this file — the cycle-1 allowlist edit landed only in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, while `mcp__drm-copilot__run_poshqc_test` resolves settings from the separate bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, which was not edited (confirmed independently by this audit). **This is a FAIL finding requiring a second remediation cycle** (see `remediation-inputs.2026-07-17T16-00.md`).
2. **Duplicate test (Minor, resolved in cycle 1).** The duplicate `It 'allows termination when phase headings use the canonical em dash (U+2014)'` test identified in cycle 0's code review has been removed; the test file now contains 7 distinct test cases. No further action needed.
3. **Unfixed vendored copy (Informational, unchanged, out of scope).** `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` still contains the pre-fix ASCII-hyphen `$phasePattern` regex (confirmed via direct `grep` by this audit) and remains untouched by this branch diff, consistent with `remediation-plan.2026-07-17T14-38.md`'s explicit "Explicitly out of scope for this cycle" declaration. This is a distinct file from the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` discussed in Gap 1 (a settings file, not a hook copy); the two should not be conflated. This remains non-blocking Informational for this minor-audit's declared scope.

### Approved Exceptions

**None.** No exception has been granted for the unresolved coverage gap.

### Removed/Skipped Tests

**None removed** other than the intentional, policy-consistent removal of the byte-identical duplicate test (see Gap 2), which is a maintainability improvement, not a coverage reduction (both duplicate tests exercised the identical fixture; removing one does not reduce measured coverage).

---

## 8. Independent Verification Performed by This Audit

This audit did not rely solely on the feature's self-authored evidence for the central coverage claim. It independently ran:

- `grep -n "sourcefilename=\"validate-planner-output" artifacts/pester/powershell-coverage.xml` — zero matches, confirming the canonical artifact still does not measure this file.
- `grep -n "validate-planner-output" extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — confirmed the allowlist entry exists only in the `scripts/` copy.
- `diff extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — confirmed the only difference between the two files is the missing allowlist entry (a 3-line block) in the bundled copy.
- `git log --oneline -- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — confirmed commit `f3701f7f` (issue #344) previously updated this exact bundled file in tandem with the `scripts/` copy, corroborating that keeping both files synchronized is the established pattern for this repository, not a novel requirement invented by this audit.
- `grep -n "phasePattern\|Phase N" extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` — confirmed the vendored hook copy (Gap 3, distinct file) still uses the ASCII-hyphen regex and was correctly left untouched, matching the declared out-of-scope decision.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no evidence-location violations.
- Direct read of `.claude/hooks/validate-planner-output.ps1` and `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` in their current, post-remediation-1 state — confirmed the em-dash regex/message/docstring fix, the 7-test suite with no duplicates, and the new malformed-heading test case.

---

## 9. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT (unchanged disposition from cycle 0; incremental progress made, gap not closed)

Remediation cycle 1 made genuine, verified progress (test-suite deduplication complete; +3.85pp ad hoc coverage; the specific line-137/138 branch flagged in cycle 0 is now covered) but did not close the Blocking coverage-compliance gap. The root cause — a second, MCP-tool-resolved settings file that mirrors but is distinct from the repo's canonical `scripts/` settings file — was discovered and transparently documented by the remediation cycle itself, but fixing it was outside that cycle's declared change budget. A second remediation cycle is required to (a) bring the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` copy into sync, consistent with the established pattern from issues #272/#214/#275/#301/#305/#312/#328/#334/#344, and (b) add further test coverage (targeting `Get-PlanFileContent`'s real disk-read body or an equivalent uncovered surface) to close the remaining gap from 73.72% to >= 85%.

**Fail-closed reminder honored:** this audit does not report the coverage requirement as PASS or N/A; it reports FAIL with numeric evidence, independently re-verified, per Sections 4-8 above.

### Recommendation

**Needs revision (second coverage remediation cycle required before merge).**

See `remediation-inputs.2026-07-17T16-00.md` for the structured remediation trigger list for this cycle.

---

**Audit Completed By:** feature-review (Claude Code subagent)
**Audit Date:** 2026-07-17T16-00
