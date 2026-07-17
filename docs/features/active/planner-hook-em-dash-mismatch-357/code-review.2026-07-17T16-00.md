# Code Review: planner-hook-em-dash-mismatch-357 (#357)

**Review Date:** 2026-07-17T16-00
**Reviewer:** feature-review (Claude Code subagent)
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Base Branch:** `main` (origin/main, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `6e7bc63cf7941e82af09ca931ae066e2196b513f`
**Review Type:** Re-review following remediation cycle 1

---

## Executive Summary

This is a re-review of the same functional fix reviewed in `code-review.2026-07-17T14-38.md` (em-dash phase-heading regex/message/docstring correction in `.claude/hooks/validate-planner-output.ps1`), plus the changes introduced by remediation cycle 1 (commit `6e7bc63c`, `test(planner-hook): add coverage for malformed phase heading validation`):

- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`: added one new `It` case (`blocks when a phase heading is malformed (missing the em dash separator)`) exercising the previously-uncovered `-not $phaseMatch.Success` branch (lines 136-140), and removed the duplicate `It` case flagged as a Minor finding in the prior review.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: added `.claude/hooks/validate-planner-output.ps1` to the `CodeCoverage.Path` allowlist, with an issue-referencing comment matching the file's existing per-issue comment convention.

**What resolved from the prior review:**
1. The duplicate-test Minor finding is resolved — the test suite now contains 7 distinct test cases with no byte-identical duplicates (confirmed by direct read).
2. The specific uncovered line-137 error-message branch flagged in the prior review is now exercised and asserted on by the new test case.

**What remains open (carried forward as the Major finding, now with a more precise root cause):**

The Major coverage finding from the prior review is not resolved. Ad hoc line coverage improved from 69.87% to 73.72% (a real, verified +3.85 percentage-point gain), but this remains below the repository's uniform 85% line-coverage threshold. More significantly, the canonical `artifacts/pester/powershell-coverage.xml` artifact still does not measure this file at all, because `mcp__drm-copilot__run_poshqc_test` sources its Pester settings from `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (a bundled copy, distinct from the `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` this cycle edited), and that bundled copy was not updated. This audit independently confirmed this by direct `grep`/`diff` against both files and by `git log` on the bundled file's history, corroborating the remediation evidence's own root-cause analysis rather than merely restating it.

**PR readiness recommendation:** **Conditional Go, unchanged from prior review** — the functional fix remains correct, minimal, and well-tested for its intended behavior change, and the test-suite hygiene issue is now resolved. Merge readiness is still conditioned on closing the coverage gap, which requires work outside cycle 1's declared change budget (updating the bundled settings copy, plus additional tests to reach the threshold).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (carried over, root cause refined) | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` array | The repo's canonical `scripts/` settings copy now lists `.claude/hooks/validate-planner-output.ps1`, but the MCP `run_poshqc_test` tool actually reads the separate bundled `extensions/...` copy, which was not updated. As a result the canonical coverage artifact (`artifacts/pester/powershell-coverage.xml`) still has zero entries for this file, and the file's true coverage (73.72% ad hoc) remains below the 85% uniform threshold. | Add the same allowlist entry to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, matching the pattern established by commit `f3701f7f` (issue #344) and other prior issues that updated both copies together. Then add further tests (e.g., targeting `Get-PlanFileContent`'s real disk-read body, lines 45-57) to close the remaining gap to >= 85%. | `general-unit-test.md` states the 85%/75% coverage floor uniformly across tiers; a coverage allowlist edit that does not reach the tool actually invoked by the canonical toolchain does not satisfy this requirement. | `evidence/qa-gates/coverage-xml-post-check-remediation1.md`; independent `grep`/`diff` of both settings files and `git log` on the bundled copy performed by this review. |
| Info (unchanged, resolved from cycle 0's Minor finding) | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` | whole file | The cycle-0 duplicate-test finding is resolved: the byte-identical `It 'allows termination when phase headings use the canonical em dash (U+2014)'` case has been removed, leaving 7 distinct test cases. | None — resolved. | N/A | Direct read of the current test file (7 `It` blocks, no duplicates). |
| Info (unchanged from cycle 0) | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` | line ~121 | This is a distinct vendored copy of the *hook itself* (not the settings file discussed in the Major finding above) and still contains the pre-fix ASCII-hyphen regex. Correctly out of scope per the remediation plan's explicit declaration. | Track as a separate, non-blocking follow-up, as recommended in the prior review. | Distinct concern from the coverage-settings gap; should not be conflated with it. | `grep -n "phasePattern" extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` — unchanged ASCII-hyphen pattern, confirmed independently by this review. |

No Blocker findings.

---

## Implementation Audit

### PowerShell implementation audit (cycle-1 delta only; cycle-0 findings on the hook file itself are unchanged and were already reviewed)

#### What changed well

- The new `It 'blocks when a phase heading is malformed (missing the em dash separator)'` test case is well-targeted: its fixture (`'### Phase 1 Implement'`, no separator at all) exercises exactly the `-not $phaseMatch.Success` branch that was flagged as untested in the prior review, and its assertion (`Should -Match 'phase heading must match'`) verifies the actual fixed error-message text rather than a generic failure signal.
- The `pester.runsettings.psd1` edit follows the file's own established convention exactly: a one-line comment referencing the issue number, consistent with the pattern used for issues #272 and #305 already present in that file.
- The removal of the duplicate test is clean — the retained `It 'allows termination when the plan satisfies the structural contract'` test's fixture (already em-dash, from the AC-3 fixture updates) is unchanged and continues to serve as the positive-flow regression guard.

#### Root-cause investigation quality

- The discovery that `mcp__drm-copilot__run_poshqc_test` resolves settings from a bundled copy distinct from the repo's `scripts/` copy is a genuinely useful finding, documented with specific file paths and corroborated by this review's independent `git log`/`diff` checks. This is exactly the kind of investigation that should surface in remediation evidence rather than being silently absorbed or glossed over.
- The remediation cycle correctly declined to expand its own change budget to fix the newly-discovered root cause once it was outside the pre-declared scope, and instead escalated it explicitly in its evidence rather than quietly leaving the coverage claim unresolved. This is the correct behavior under this repository's "fail fast and explicitly" principle, though it does mean a second remediation cycle is now required.

#### API and safety notes

Unchanged from cycle 0: no public function signatures changed; no new parameter validation or `ShouldProcess` considerations; the `Test-TaskContainsExplicitPath`, `Test-HasPreflightSignal`, and `Get-PlanPathFromOutput` helper functions remain untouched.

---

## Test Quality Audit

The cycle-1 test-suite change is sound: the new test is deterministic (literal fixture strings, mocked filesystem boundary), isolated (its own `Mock` registration), and its name and fixture clearly communicate the scenario under test (a malformed phase heading missing the separator entirely). The duplicate-test removal is a clean maintainability improvement with no loss of test signal, since the two tests previously exercised identical inputs.

### Reviewed test and QA artifacts

- `evidence/qa-gates/poshqc-test-remediation1-final.md` — confirms 7/7 tests pass and documents the ad hoc coverage measurement and root-cause finding in detail.
- `evidence/qa-gates/coverage-delta-remediation1.md` — documents the +3.85pp coverage delta and the specific lines closed (137, 138, and incidentally 167/195/196).
- `evidence/qa-gates/coverage-xml-post-check-remediation1.md` — documents the canonical-artifact non-measurement finding with the correct root cause.
- `evidence/qa-gates/change-scope-check-remediation1.md` — confirms no file outside the declared cycle-1 change budget was modified.

### Quality assessment prompts

- **Determinism:** Unchanged — all test inputs remain literal fixture strings with the filesystem boundary mocked.
- **Isolation:** The new test registers its own `Mock -CommandName Get-PlanFileContent`; no shared state with other tests.
- **Speed:** No indication of slow tests; 7-test suite remains fast.
- **Diagnostics:** The new test's `Should -Match 'phase heading must match'` assertion produces a clear, specific failure message tied to the exact fixed error-message text.

---

## Security / Correctness Checks

Unchanged from cycle 0: no secrets, no unsafe subprocess construction, no boundary-validation changes, error handling unchanged, no new path/configuration parsing introduced by either cycle's changes.

---

## Research Log

This review independently re-derived the coverage-artifact-absence finding rather than accepting the remediation evidence's claim at face value: it ran `grep -n "sourcefilename=\"validate-planner-output" artifacts/pester/powershell-coverage.xml` (zero matches), `diff` between the two `pester.runsettings.psd1` copies (confirmed the only difference is the missing allowlist entry in the bundled copy), and `git log --oneline -- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (confirmed commit `f3701f7f` previously kept both copies in sync for issue #344). All three checks corroborate the remediation evidence's stated root cause.

---

## Verdict

The cycle-1 changes are a correct, well-scoped, and honestly-reported partial remediation: the duplicate-test finding is fully resolved, the specific previously-uncovered line-137/138 branch is now tested, and ad hoc coverage improved by a real +3.85 percentage points. The change is still not ready for unconditional merge because the canonical coverage artifact does not measure this file at all (a newly-precise root cause: two settings files must be kept in sync, and only one was updated), and even the ad hoc measurement remains below the 85% uniform threshold. Recommend a second remediation cycle that (a) syncs the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` copy and (b) adds further tests to close the remaining coverage gap, per `remediation-inputs.2026-07-17T16-00.md`.

---

**Review Completed By:** feature-review (Claude Code subagent)
**Review Date:** 2026-07-17T16-00
