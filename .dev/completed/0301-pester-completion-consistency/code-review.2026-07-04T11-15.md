# Code Review: pester-completion-consistency (Issue #301)

**Review Date:** 2026-07-04
**Reviewer:** feature-review agent (Claude Sonnet 5)
**Feature Folder:** `docs/features/active/2026-07-03-pester-completion-consistency-301`
**Feature Folder Selection Rule:** Only active feature folder whose suffix (`301`) matches the issue number referenced in the branch name `bug/pester-completion-consistency-301`.
**Base Branch:** `main` (merge-base `97514a6f0c51cfb92d79db9544b33c2adec2b7af`)
**Head Branch:** `bug/pester-completion-consistency-301` @ `929ccfb896090c57f6a834a6a853046ce5647675`
**Review Type:** Initial review

---

## Executive Summary

This branch restores parity between the Codex-side `enforce-completion-consistency.ps1` `PreToolUse` hook and its already-hardened `.claude/hooks` counterpart. It adds a new `enforce-completion-helpers.ps1` module (dot-sourced by the hook) providing `Test-IsValidIssueNum`, `Test-IsValidFeatureFolder`, and `Test-RouteRequiresPrGate`; updates the hook to emit the modern `hookSpecificOutput.permissionDecision` JSON response shape instead of the legacy `decision`/`reason` shape; replaces the former issue-232 hardcoded special case with a route-driven `requires_pr_gate` check; and adds a read-then-validate path for Edit-tool calls via `Resolve-EditedCheckpointContent`. The same two files are mirrored into the bundled `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` resource copy, and one new Pester test file exercises the bundled Codex hook directly.

**What changed:**
- `.codex/hooks/enforce-completion-consistency.ps1`: +144/-28 lines. Confirmed byte-for-byte identical to `.claude/hooks/enforce-completion-consistency.ps1` (verified via `diff` in this review).
- `.codex/hooks/enforce-completion-helpers.ps1`: new, 163 lines. Confirmed byte-for-byte identical to `.claude/hooks/enforce-completion-helpers.ps1`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1` and `enforce-completion-helpers.ps1`: bundled resource copies, both confirmed byte-for-byte identical to the `.codex/hooks/` originals.
- `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`: new, 60 lines, 2 `It` blocks.

**Top 3 risks:**
1. The four in-scope hook files (2 modified, 2 new copies of each) are entirely excluded from the repository's Pester coverage measurement (`pester.runsettings.psd1`'s `CodeCoverage.Path` list omits them), so this change ships with zero measured line/branch coverage for new/modified production code, contrary to the repository's Coverage Exclusion Policy.
2. Three coverage-related evidence artifacts cite an aggregate figure (`LINE missed="1073" covered="0"`) that does not match the current `artifacts/pester/powershell-coverage.xml` report totals (`LINE missed="359" covered="714"`), which undermines confidence in the "no regression" claim as currently documented.
3. Low residual risk: the route-driven `Test-RouteRequiresPrGate` generalizes a previously hardcoded `issue-num -eq '232'` check; this is a behavior change beyond pure Codex/Claude parity restoration (see Findings Table), though it is limited to the shared, already-tested `.claude`-identical logic, not new Codex-only behavior.

**PR readiness recommendation:** **Conditional Go** — the hook implementation itself is sound, well-tested behaviorally, and verified byte-for-byte parity with the already-reviewed `.claude` hook. Coverage-measurement gaps (Findings 1–2 below) should be closed before merge per repository policy, but do not indicate a functional defect in the shipped behavior.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` array (lines 23-50) | The four in-scope hook files (`.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, and their bundled-resource copies) are absent from the `Path` array, so no coverage percentage is produced for new/modified production code in this branch. | Add the four in-scope hook files to `CodeCoverage.Path` (following the precedent already documented in the file's own comments for Issues #272/#214/#275), re-run the coverage-enabled Pester suite, and confirm >=85% line / >=75% branch coverage. | `.claude/rules/general-unit-test.md` Coverage Exclusion Policy: "No production file may be excluded from coverage measurement." A new file with 0% measured coverage fails the 90%-new-file threshold used by this review's coverage-verification procedure. | `grep -n -A 27 "CodeCoverage" scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; `grep -o '<sourcefile name="[^"]*"' artifacts/pester/powershell-coverage.xml` (returns 15 files, none matching `enforce-completion-*`), both run in this review. |
| Major | `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/coverage-comparison.2026-07-03T22-46.md`, `evidence/baseline/baseline-powershell-pester.2026-07-03T22-46.md`, `evidence/qa-gates/final-powershell-pester.2026-07-03T22-46.md` | full document text | All three artifacts assert the aggregate coverage figure `LINE missed="1073" covered="0"`, but the current `artifacts/pester/powershell-coverage.xml` report-level `<counter type="LINE">` is `missed="359" covered="714"` (66.5%), and the literal string `1073` does not appear anywhere in that file or `artifacts/pester/powershell-coverage.koverage.xml`. | Regenerate the coverage-enabled Pester run and re-transcribe the actual report-level counter values into the evidence artifacts before relying on the "no regression" conclusion. | Evidence-first policy (`.claude/rules/tonality.md`, `evidence-and-timestamp-conventions` skill) requires audit claims to match inspected artifacts; an unreproducible figure undermines the coverage-comparison conclusion regardless of the separate exclusion gap above. | `grep -o '<counter type="LINE"[^/]*/>' artifacts/pester/powershell-coverage.xml \| tail -5` and `grep -n "1073" artifacts/pester/powershell-coverage.xml artifacts/pester/powershell-coverage.koverage.xml` (no match), both run in this review. |
| Minor | `.codex/hooks/enforce-completion-helpers.ps1` (and bundled copy), function `Test-RouteRequiresPrGate` | lines 106-163 | The default `RoutingMatrixReader` scriptblock resolves `config/orchestration-routing.json` via a path relative to `$PSScriptRoot` two levels up (`../../config/orchestration-routing.json`) rather than repo-root-relative; this is inherited unchanged from the already-reviewed `.claude/hooks/enforce-completion-helpers.ps1` (confirmed byte-identical), so it is out of scope for this fix, but worth a follow-up check if `.codex/hooks/` and `.claude/hooks/` are ever nested at different depths in future restructuring. | No action required for this PR; flag for awareness only if hook directory depth changes in the future. | Path-relative defaults are fragile to directory restructuring; noting for traceability since this is the first time the Codex copy inherits this exact default. | Direct inspection of `.codex/hooks/enforce-completion-helpers.ps1` lines 127-131 in this review. |
| Info | `.codex/hooks/enforce-completion-consistency.ps1` | line ~416 (`$decision \| ConvertTo-Json -Compress -Depth 5`) | `-Depth 5` was added to accommodate the new nested `hookSpecificOutput` object; verified sufficient because the deepest emitted structure (`hookSpecificOutput.permissionDecisionReason`) is 2 levels deep. | No action required. | Confirms the JSON serialization change does not silently truncate the new nested shape. | Direct inspection of the diff and the emitted `[ordered]@{ hookSpecificOutput = [ordered]@{...} }` structures in this review. |

No Blockers found in the shipped hook/test code itself; the two Major findings are coverage-measurement/evidence-integrity gaps rather than functional defects.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix is minimally scoped: it dot-sources a new helper file and changes the JSON response shape, without unrelated refactoring of surrounding hook logic.
- `Test-RouteRequiresPrGate` cleanly replaces a hardcoded `issue-num -eq '232'` special case with a generalized, config-driven route lookup, with a docstring explicitly noting the generalization intent ("This generalizes the former issue-232 special-casing into a route-driven check").
- The Edit-tool "read-then-validate" path (`Resolve-EditedCheckpointContent`) correctly defers (`allow`) rather than blocking when the on-disk checkpoint cannot be read or the patch's `old_string` does not match, avoiding false-positive denials — consistent with the hook's stated backward-compatibility intent in its own header comment.
- All new functions use approved verbs (`Get-`, `Test-`, `Resolve-`) and are independently confirmed to produce zero PSScriptAnalyzer findings.

#### API and safety notes

- `Invoke-CompletionConsistencyDecision` exposes new optional `[scriptblock]` parameters (`FolderExistsCheck`, `CheckpointReader`, `RoutingMatrixReader`) with safe, production-equivalent defaults, following the repo's "injectable delegate/ScriptBlock seam" convention (`.claude/rules/powershell.md`) rather than introducing a generic runner framework.
- `Get-MissingCompletionEvidence`'s new `-missing` messages (e.g., `"issue-num value '$issueNum' is not a valid issue number (must be digits-only)"`) improve diagnosability over the prior bare `'issue-num'` string, which is a genuine usability improvement for anyone debugging a blocked write.
- The change from `decision`/`reason` to `hookSpecificOutput.hookEventName`/`permissionDecision`/`permissionDecisionReason` is a breaking shape change for any external consumer still expecting the old shape; this is scoped and intentional (per issue #301's stated goal of Codex/Claude parity), and no other in-repo consumer of the old shape was found for the Codex hook specifically.

#### Error handling and logging

- `Get-CheckpointFileContent` correctly distinguishes "file does not exist" (returns `$null`) from a genuine read error (`Get-Content -ErrorAction Stop`, which would propagate), avoiding a silent catch-all.
- The top-level `try/catch` around the dot-sourced hook invocation (unchanged in this diff, at the bottom of the script) still exits `1` on unexpected error, preserving fail-fast behavior for genuine hook faults while returning a structured `allow`/`deny` decision for expected validation outcomes.

---

## Test Quality Audit

The new test file `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` adds 2 focused `It` blocks against the bundled Codex hook path specifically (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`), complementing the pre-existing, unmodified 49-test `enforce-completion-consistency.Tests.ps1` suite that already exercises the byte-identical `.claude/hooks` logic. Both suites pass: 51/51 targeted, independently reproduced in this review via direct `Invoke-Pester`.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` — verifies the bundled Codex hook emits the correct deny shape for missing evidence and correctly applies the route-driven `pr_gate` gate; independently re-run in this review (2/2 pass).
- `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/regression-testing/fail-before-exception.2026-07-03T22-46.md` — substitutes a live fail-before run (structurally impossible because the fix and test were introduced together) with committed-baseline `git show`/`git ls-tree` proof that the dot-source wiring and helper file did not exist at the merge-base commit. This is a sound application of the fail-before-exception convention.
- `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/final-powershell-full-suite.2026-07-03T22-46.md` — 476/476 full-suite pass; independently reproduced in this review.
- `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/coverage-comparison.2026-07-03T22-46.md` — documents the coverage-configuration gap, but with an inaccurate aggregate figure (see Findings Table, Major #2).

### Quality assessment prompts

- **Determinism:** No wall-clock, RNG, or network dependency; injected scriptblocks (`FolderExistsCheck`, `RoutingMatrixReader`) make the route-gate test fully deterministic.
- **Isolation:** Each `It` targets `Invoke-CompletionConsistencyDecision` through a single, well-defined tool-input scenario; no shared mutable state across tests.
- **Speed:** 96ms for the 2 new tests; 1.16s for the full 51-test targeted run (both measured directly in this review).
- **Diagnostics:** `Should -Be`/`Should -Match` assertions target specific nested fields (`hookSpecificOutput.permissionDecision`, `.permissionDecisionReason`), giving precise failure diagnostics.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or connection strings in any of the 5 changed files (direct inspection). |
| No unsafe subprocess or command construction | ✅ PASS | No `Invoke-Expression` or shell-out calls introduced; all logic is in-process JSON/string manipulation. |
| Input validation at boundaries | ✅ PASS | `Test-IsValidIssueNum`/`Test-IsValidFeatureFolder` reject sentinel values (`n/a`, `none`, `tbd`) and non-digit/malformed input explicitly rather than treating any non-empty string as valid. |
| Error handling remains explicit | ✅ PASS | See Implementation Audit; JSON-parse failures and missing files are handled with specific branches, not broad catch-alls. |
| Configuration / path handling is safe | ✅ PASS | `Join-Path $PSScriptRoot ...` used for the helper dot-source path and the default routing-matrix path; no unsanitized external path input is used for file reads (the checkpoint path is a hardcoded literal, `'artifacts/orchestration/orchestrator-state.json'`, not derived from tool input). |

---

## Research Log

No external research was required. All findings are based on direct inspection of the diff (`git diff 97514a6..929ccfb`), direct byte-for-byte `diff` comparisons between the `.codex`/bundled files and their `.claude` counterparts, independent re-execution of PSScriptAnalyzer/Invoke-Formatter/Invoke-Pester in this review's environment, and direct inspection of `artifacts/pester/powershell-coverage.xml` and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

---

## Verdict

The shipped hook and test implementation is sound: it restores byte-for-byte parity between the Codex and Claude completion-consistency hooks (independently verified via `diff`), passes all 51 targeted and 476 full-suite Pester tests (independently reproduced), and introduces zero PSScriptAnalyzer or formatting findings (independently reproduced). The change follows repository PowerShell conventions for naming, seams, and error handling.

The review is not a clean Go because of two coverage-related gaps that are policy-blocking regardless of functional correctness: the four in-scope hook files remain outside the repository's coverage-measurement configuration, and three evidence artifacts cite a coverage aggregate that does not match the current coverage report. Both are documented as remediation-required findings; neither indicates a defect in the shipped hook behavior itself. Recommendation: **Conditional Go**, pending closure of the two Major findings via remediation.
