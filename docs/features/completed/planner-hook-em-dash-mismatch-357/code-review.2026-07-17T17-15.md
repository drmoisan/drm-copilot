# Code Review: planner-hook-em-dash-mismatch-357 (#357)

**Review Date:** 2026-07-17T17-15
**Reviewer:** feature-review (Claude Code subagent)
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Base Branch:** `main` (origin/main, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `67cd49a6e380b25b00b5ad35f93d56d44d4488cf`
**Review Type:** Re-review following remediation cycle 2

---

## Executive Summary

This is a re-review covering the same functional fix reviewed in `code-review.2026-07-17T14-38.md` and `code-review.2026-07-17T16-00.md` (em-dash phase-heading regex/message/docstring correction in `.claude/hooks/validate-planner-output.ps1`), plus remediation cycle 2 (commit `67cd49a6`, `test(planner-hook): add coverage for plan validation paths and edge cases`):

- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`: grew from 126 to 277 lines (7 -> 21 `It` cases). New tests directly exercise `Get-PlanFileContent`'s real disk-read body (not-exists and exists-with-populated-Lines cases, using `$PSCommandPath` — the test file's own on-disk path — rather than a temporary file) and add multiple new `Get-PlanStructureValidationReport` direct-invocation cases covering task-number sequencing, phase-number mismatch, missing canonical task lines, and Phase-0/final-phase wording requirements.
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`: synced with the `scripts/` copy's `CodeCoverage.Path` allowlist entry for this file (confirmed byte-identical to the `scripts/` copy by this review's own `diff`).

**What resolved from the prior review:** The Major coverage finding carried forward through cycles 0-2 is resolved. This review independently reproduced the exact CI-equivalent toolchain invocation (`Invoke-PoshQCTest -Root <workspace>`, matching `.github/workflows/_poshqc.yml` verbatim) and confirmed the canonical `artifacts/pester/powershell-coverage.xml` now contains a real, non-zero entry for `.claude/hooks/validate-planner-output.ps1`: 107/114 lines = 93.86%, above the 85% uniform threshold. This is a change in disposition from the prior two reviews, made because this review was directed to independently verify the CI-equivalent path (which prior cycles had not attempted) and that verification succeeded.

**What remains open, non-blocking:** The interactive `mcp__drm-copilot__run_poshqc_test` MCP tool still resolves a separately npm-published, npx-cached package (`@danmoisan/drm-copilot-mcp`) independent of this workspace, so its own canonical-artifact output still shows zero coverage for this file. This is a real MCP-tool/workspace divergence defect, but it is orthogonal to this feature's code and test correctness — the file itself, and the CI gate that actually enforces coverage, are correct and covered. Recommended as a separate, new potential-bug entry rather than continued remediation under issue #357.

**PR readiness recommendation:** **Go.** The functional fix remains correct, minimal, and well-tested; the test-suite is now comprehensive; and the CI-enforced coverage gate is independently verified as satisfied.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Major) | `.claude/hooks/validate-planner-output.ps1` | whole file | The coverage gap carried forward from cycles 0-2 is resolved: 93.86% line coverage (107/114) in the canonical, CI-equivalent-produced `artifacts/pester/powershell-coverage.xml`, above the 85% uniform threshold. | None — resolved. | `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md` require >= 85% line coverage uniformly across tiers. | This review's own `Invoke-PoshQCTest -Root <workspace>` run and direct inspection of the resulting `powershell-coverage.xml`. |
| Info (new, non-blocking, out-of-scope for #357) | `.mcp.json` / MCP server resolution | `npx -y @danmoisan/drm-copilot-mcp` | The MCP-served `run_poshqc_test`/`run_poshqc_format`/`run_poshqc_analyze` tools resolve a separately npm-published, npx-cached package independent of this workspace's `extensions/drm-copilot/` source tree, so in-repo settings edits (either `pester.runsettings.psd1` copy) cannot reach the MCP tool's runtime coverage measurement until a new package version is published or `.mcp.json` is reconfigured. | File as a separate, new issue; do not treat as blocking for #357. | This is a pre-existing tooling-infrastructure defect discovered incidentally during remediation, unrelated to the em-dash fix's correctness. | `evidence/qa-gates/ci-equivalent-coverage-verification.md`, `evidence/qa-gates/coverage-delta-remediation2.md`; independently corroborated by this review's confirmation that the CI-equivalent path (bypassing the MCP wrapper) does measure the file correctly. |
| Info (unchanged from cycle 1, resolved) | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` | whole file | Cycle-0's duplicate-test finding remains resolved; the current 21-test suite (confirmed by direct read) contains no byte-identical duplicates. | None — resolved. | N/A | Direct read of the current test file. |
| Info (unchanged from cycle 0) | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` | line ~121 | This is a distinct vendored copy of the *hook itself* and still contains the pre-fix ASCII-hyphen regex. Correctly out of scope per the remediation plans' explicit declarations. | Track as a separate, non-blocking follow-up. | Distinct concern from the settings-file coverage gap; should not be conflated with it. | `grep -n "phasePattern" extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` (unchanged ASCII-hyphen pattern). |

No Blocker findings.

---

## Implementation Audit

### PowerShell implementation audit (cycle-2 delta only; the hook file's functional fix and cycle-1's test additions were already reviewed)

#### What changed well

- The new `Context 'Get-PlanFileContent direct invocation'` block exercises the function's real `Test-Path`/`Get-Content` logic directly, rather than mocking it as every prior test does. It correctly avoids creating a temporary file (prohibited by `.claude/rules/general-unit-test.md`) by using `"$PSCommandPath.does-not-exist"` for the negative case and `$PSCommandPath` itself (the test file's own stable, already-on-disk path) for the positive case — a clean, policy-compliant way to obtain a real, guaranteed-to-exist fixture path without violating the no-temporary-files rule.
- The new `Context 'Get-PlanStructureValidationReport direct invocation'` block (7 new `It` cases) targets specific, previously-uncovered validation branches directly — task-line pattern mismatch, phase-number mismatch, T1-skip detection, missing canonical task lines, and the Phase-0/final-phase wording checks — each asserting on a distinct, specific error-message substring rather than a generic failure signal. This is a well-targeted, minimal way to close coverage gaps without weakening any existing assertion.
- The `pester.runsettings.psd1` sync in `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` follows the established convention exactly (one-line issue-referencing comment, matching the `scripts/` copy's comment for the same entry) and this review's own `diff` confirms the two files remain otherwise byte-identical after the edit — no unrelated drift introduced.

#### Root-cause investigation quality

- Remediation cycle 2's discovery that the MCP tool resolves an npx-cached, separately-published package (not either in-repo settings copy) is a deeper and more accurate root cause than cycle 1's "two settings files, only one updated" hypothesis. The cycle transparently documented this supersession in its own evidence rather than silently replacing the earlier explanation, which is the correct behavior under this repository's "fail fast and explicitly" principle.
- This review's own independent verification — reproducing the exact CI workflow invocation rather than the MCP-wrapped tool — is what ultimately resolves the open question left by cycle 2: whether the *actual, CI-enforced* gate (as opposed to the MCP tool's convenience wrapper) is satisfied. It is.

#### API and safety notes

Unchanged from prior cycles: no public function signatures changed in this cycle; no new parameter validation or `ShouldProcess` considerations; the `Test-TaskContainsExplicitPath`, `Test-HasPreflightSignal`, and `Get-PlanPathFromOutput` helper functions remain untouched.

---

## Test Quality Audit

The cycle-2 test-suite additions are sound: deterministic (literal fixture strings; the one real-filesystem case uses a stable, already-on-disk path rather than a temporary file or wall-clock/RNG dependency), isolated (each new `It` registers its own mock where mocking is used, or exercises the real function directly with no shared state), and each new test's name and assertion clearly communicate the scenario under test and the specific expected error-message substring. No existing assertion was weakened to accommodate the new tests.

### Reviewed test and QA artifacts

- `evidence/qa-gates/poshqc-test-remediation2-final.md` — confirms 21/21 tests pass via the MCP tool and documents the ad hoc coverage measurement (94.23%) and the deeper MCP/npx root-cause finding.
- `evidence/qa-gates/coverage-delta-remediation2.md` — documents the coverage delta (73.72% -> 94.23% ad hoc) and enumerates which previously-uncovered lines are now closed versus which remain justified exceptions.
- `evidence/qa-gates/poshqc-analyze-remediation2-final.md`, `evidence/qa-gates/poshqc-format-remediation2-final.md` — confirm clean analyzer/formatter passes.
- `evidence/qa-gates/change-scope-check-remediation2.md`, `evidence/qa-gates/settings-diff-post-remediation2.md` — confirm change-budget discipline and settings-file sync correctness.
- `evidence/qa-gates/ci-equivalent-coverage-verification.md` — the new evidence this review was directed to independently verify; this review reproduced its central claim directly rather than accepting it at face value (see Research Log below).

### Quality assessment prompts

- **Determinism:** All new test inputs are literal fixture strings or a stable, pre-existing on-disk path (`$PSCommandPath`); no wall-clock, RNG, or sleep usage introduced.
- **Isolation:** Each new test either registers its own `Mock` or exercises the real function directly with no shared mutable state.
- **Speed:** The full 21-test suite for this file, and the repo-wide 1286-test suite, both complete well within a normal CI timeout (this review's own run: 62.31s total for format+analyze+full repo Pester run).
- **Diagnostics:** Each new assertion targets a specific, distinct error-message substring (e.g., `'task line must match'`, `'does not match current phase'`, `'expected task number'`, `'canonical task lines'`, `'policy-read task'`, `'baseline task'`, `'QA or toolchain validation'`), giving clear, actionable failure messages if a regression breaks a specific validation branch.

---

## Security / Correctness Checks

Unchanged from prior cycles: no secrets, no unsafe subprocess construction, no boundary-validation changes, error handling unchanged, no new path/configuration parsing introduced by any cycle's changes.

---

## Research Log

This review did not accept the new `ci-equivalent-coverage-verification.md` evidence file's central claim at face value. It:

1. Read `.github/workflows/_poshqc.yml` directly to confirm the CI gate's exact invocation (`Import-Module ".../PoshQC.psm1"; Invoke-PoshQCTest -Root "..."`, no MCP/`npx` involvement).
2. Read `scripts/powershell/PoshQC/PoshQC.psm1` to confirm its settings-file resolution (`Join-Path $ModuleRoot 'settings/pester.runsettings.psd1'`).
3. Ran that exact invocation itself in this workspace: `Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path`.
4. Directly inspected the resulting `artifacts/pester/powershell-coverage.xml` (not the evidence file's restatement) and confirmed `<counter type="LINE" missed="7" covered="107" />` for `validate-planner-output.ps1` (93.86%), and repo-wide `1286 passed, 0 failed, 9 skipped`, `89.02%` overall coverage across 28 files — all matching the evidence file's claims exactly.
5. Confirmed zero `BRANCH` counters exist anywhere in the artifact (all 28 files), independently corroborating the repo-wide branch-coverage tooling limitation rather than accepting it as asserted.
6. Confirmed both `pester.runsettings.psd1` copies remain byte-identical (`diff` returned no output) and the working tree is clean (`git status --porcelain`).

---

## Verdict

The cycle-2 changes are a correct, well-scoped, and thorough remediation: 14 new test cases close nearly all previously-identified coverage gaps in a targeted way (real disk-read exercise for `Get-PlanFileContent`, direct invocation coverage for seven distinct `Get-PlanStructureValidationReport` validation branches), and the settings-file sync is clean with no unrelated drift. Combined with this review's own independent, CI-equivalent verification — which confirms the actual repository/CI-enforced coverage gate (93.86% line coverage) is satisfied, distinct from the MCP tool's own still-stale measurement — this feature is ready to merge. The MCP-tool/workspace divergence is a real but separate defect, recommended for a new issue rather than further work under #357.

---

**Review Completed By:** feature-review (Claude Code subagent)
**Review Date:** 2026-07-17T17-15
