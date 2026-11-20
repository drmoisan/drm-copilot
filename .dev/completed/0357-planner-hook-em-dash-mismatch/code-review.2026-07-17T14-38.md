# Code Review: planner-hook-em-dash-mismatch-357 (#357)

**Review Date:** 2026-07-17
**Reviewer:** feature-review (Claude Code subagent)
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Feature Folder Selection Rule:** Selected as the active feature folder matching the issue-number suffix (`-357`) referenced in the delegated review scope and in `artifacts/pr_context.summary.txt`.
**Base Branch:** `main` (origin/main @ `070b1aaba8c4c312afacf52b75b18050532abe81`, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `f3e159043895305b4d10954aa06162261ba989ef`
**Review Type:** Initial review

---

## Executive Summary

The change fixes a real, systemic false-positive block in the `atomic-planner` `SubagentStop` hook: `.claude/hooks/validate-planner-output.ps1`'s `$phasePattern` regex required an ASCII hyphen in phase headings (`### Phase N - <Title>`) while the atomic-plan-contract, the `atomic-planner` agent instructions, and both other canonical structural validators (Python `PLAN_PHASE_RE`, TypeScript `PLAN_PHASE_RE`) require and accept an em dash (`### Phase N — <Title>`, U+2014). The fix is a minimal, well-scoped two-file change: the regex, its error message, and the `.DESCRIPTION` docstring were updated, and the test fixtures were brought into alignment with the real contract.

**What changed:**
- `.claude/hooks/validate-planner-output.ps1`: `$phasePattern` (line 121) and the phase-heading error message (line 137) changed from ASCII hyphen to em dash; `.DESCRIPTION` (line 17) updated to match; a UTF-8 BOM was added after the em-dash character was introduced (required to satisfy `PSUseBOMForUnicodeEncodedFile`).
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`: three existing fixtures updated from ASCII hyphen to em dash, and one new regression test added.

**Top 3 risks:**
1. The modified production file's line coverage (69.87%) remains below the repository's uniform 85%/75% threshold, and is not measured at all by the canonical `artifacts/pester/powershell-coverage.xml` artifact (see `policy-audit.2026-07-17T14-38.md` Section 8, Gap 1). This is a pre-existing condition, not a regression, but it is a genuine unresolved policy gap on a file this PR modifies.
2. The newly added regression test is now a byte-for-byte duplicate of a pre-existing test (see Findings Table below), reducing the signal value of the test suite without adding real coverage.
3. A vendored/bundled copy of the same hook (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1`) still contains the pre-fix ASCII-hyphen regex; this PR does not touch it, and it is unclear whether it is auto-synced at build/release time.

**PR readiness recommendation:** **Conditional Go** — the functional fix itself is correct, minimal, and well-tested for the intended behavior change; readiness for merge is conditioned on resolving the coverage-threshold policy gap identified in the policy audit (or obtaining an explicit, documented exception), since `general-unit-test.md`/`quality-tiers.md`/`powershell.md` state the 85%/75% coverage floor uniformly across all tiers with no stated exception for "unchanged from baseline."

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/hooks/validate-planner-output.ps1` | whole file | Line coverage is 69.87% (109/156 commands), below the repository's uniform 85% line / 75% branch threshold (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`), and the file is absent from `artifacts/pester/powershell-coverage.xml`'s `CodeCoverage.Path` allowlist, so the canonical toolchain does not measure it at all. | Add `.claude/hooks/validate-planner-output.ps1` to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path`, and add tests targeting the currently-uncovered branches (see next finding) to raise measured coverage to >= 85%. | `general-unit-test.md` states coverage must "remain >= 85%" uniformly across tiers; this is not a tier-scoped exception and applies regardless of whether the gap predates this change. | `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/coverage-delta.md`; direct inspection of `artifacts/pester/powershell-coverage.xml` (no entry for this file). |
| Minor | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` | lines 84–105 vs. 107–128 | The new `It 'allows termination when phase headings use the canonical em dash (U+2014)'` test is now identical (fixture lines, payload, and assertions) to the pre-existing `It 'allows termination when the plan satisfies the structural contract'` test, because P2-T4 updated the older fixture to also use the em dash. Both tests now exercise exactly the same input and assert exactly the same output. | Either delete the duplicate and rely on the "satisfies the structural contract" test's fixture (already em-dash) to serve as the regression guard, or differentiate the new test's fixture from the pre-existing one (e.g., mix em-dash phase headings with other valid variations) so it adds distinct signal. | Duplicate tests add maintenance cost without adding coverage or defect-detection power; `general-code-change.md` calls for avoiding copy-paste and `general-unit-test.md` calls for readability/maintainability. | Direct diff/read comparison of lines 84–105 and 107–128 in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`. |
| Minor | `.claude/hooks/validate-planner-output.ps1` | line 137 | The fixed error-message text ("phase heading must match `### Phase N — <Title>`") remains untested — no fixture in the suite constructs a plan whose `### Phase` heading fails to match the pattern at all (as opposed to a heading that is simply absent). | Add a test case supplying a malformed phase heading (e.g. `### Phase 1 Implement` with no separator, or a heading using a plain hyphen post-fix) to exercise and assert on this specific error branch. | Covers a directly-fixed line and closes part of the coverage gap identified above. | `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/coverage-delta.md` (line 137 marked "not covered — unchanged"). |
| Info | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` | line ~121 | This vendored/bundled copy of the hook still contains the pre-fix ASCII-hyphen `$phasePattern` regex and is not touched by this branch diff. | Confirm (in a follow-up, not blocking for this minor-audit) whether this resource copy is regenerated from `.claude/hooks/` automatically at build/release time, or requires a parallel manual fix; file a follow-up issue if manual sync is required. | The packaged extension may distribute the same false-positive-blocking defect to consumers of the `drm-copilot` VS Code extension until this copy is resynced. | `grep -n "phasePattern" extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` shows the unmodified ASCII-hyphen pattern; confirmed no changes to this path in `git diff 67c871eb..HEAD`. |

No Blocker findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix is exactly as narrow as the bug requires: a two-character regex change (`-` -> `—`), a matching error-message string update, and a docstring correction — no unrelated refactoring or scope creep.
- The `.DESCRIPTION` comment-based help was kept in sync with the corrected regex, avoiding documentation drift.
- The fixture updates in the test file correctly propagate the em-dash convention to every phase heading in every existing test, so the suite as a whole now reflects the real contract instead of masking it (as the original ASCII-hyphen fixtures did).
- The BOM-encoding fix was handled correctly: `PSUseBOMForUnicodeEncodedFile` fired because the file now contains a literal non-ASCII character, and the response (add a BOM, verify via `git diff` that no other content changed, restart the toolchain loop from formatting) matches the required-restart-on-file-change discipline in `general-code-change.md`.

#### API and safety notes

- No public function signatures changed (`Get-PlanStructureValidationReport`, `Invoke-PlannerOutputValidation`, `Get-PlanFileContent`, etc. are all unchanged in shape).
- No new parameter validation or `ShouldProcess` considerations apply; this is a pure regex/string literal change with no new state-changing behavior.
- The `Test-TaskContainsExplicitPath`, `Test-HasPreflightSignal`, and `Get-PlanPathFromOutput` helper functions were not touched and remain out of scope, consistent with the two-file change budget in `plan.2026-07-17T10-11.md`.

#### Error handling and logging

- No error-handling logic was modified; the hook continues to return `@{ Ok = $false; Message = ... }` structures on failure and `exit 1`/`Write-Error` at the top-level invocation boundary, unchanged from baseline.

---

## Test Quality Audit

The test suite change is functionally sound but includes one redundancy (see Findings Table). The regression-proof methodology documented in the feature's evidence — running the new `It` case in isolation against the unfixed hook to observe a genuine failure (`evidence/regression-testing/em-dash-fail-before.md`), then against the fixed hook to observe a pass (`evidence/regression-testing/em-dash-pass-after.md`) — is a strong practice that directly demonstrates the fix closes the reported defect, independent of the later-discovered fixture duplication.

### Reviewed test and QA artifacts

- `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/regression-testing/em-dash-fail-before.md` — confirms the new em-dash test genuinely fails against the pre-fix regex (exit 1, assertion failure at the expected line), establishing that the regression test is meaningful and not vacuously true.
- `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/regression-testing/em-dash-pass-after.md` — confirms the same test passes post-fix, and that the full 7-test suite passes with 0 failures.
- `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/coverage-delta.md` — proves no coverage regression occurred (69.87% before and after, identical uncovered-line set), though it also documents the unresolved absolute-threshold gap.

### Quality assessment prompts

- **Determinism:** All test inputs are literal fixture strings with no time, randomness, or external-process dependency; the boundary (`Get-PlanFileContent`) is mocked, so results are deterministic across environments.
- **Isolation:** Each `It` block re-mocks `Get-PlanFileContent` independently; no shared mutable fixtures across tests.
- **Speed:** Evidence artifacts report sub-second-scale Pester execution for the full 7-test file (exact wall-clock time not captured in evidence, but no indication of slow tests).
- **Diagnostics:** Assertions use `Should -Match` with specific substrings (e.g. `'Phase 0'`, `'explicit path'`), so a failing assertion clearly identifies which validation branch broke.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff contains only a regex literal, an error-message string, and a docstring line; no credentials or secrets. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess/command invocation added or changed. |
| Input validation at boundaries | ✅ PASS | No boundary-validation logic changed; existing JSON-parse and null/empty checks remain intact. |
| Error handling remains explicit | ✅ PASS | `Write-Error`/`exit 1` failure path unchanged; no new silent catch-alls introduced. |
| Configuration / path handling is safe | ✅ PASS | No new path construction or configuration parsing introduced by this change. |

---

## Research Log

No external research was required. All findings in this review were derived from direct inspection of the branch diff (`git diff 67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2..HEAD`), the feature folder's evidence artifacts, and direct inspection of `artifacts/pester/powershell-coverage.xml`.

---

## Verdict

The implementation itself is a correct, minimal, well-evidenced fix for the reported false-positive block, and the toolchain (format/analyze/test) passes cleanly in its final recorded state with a properly-executed restart cycle for the BOM finding. The change is not ready for unconditional merge because it leaves an already-below-threshold coverage gap on the exact file it modifies without remediating or explicitly excepting it, and it introduces one duplicate test. Recommend resolving the coverage gap (Major finding above) before merge; the duplicate-test and vendored-copy findings (Minor/Info) can be addressed in this PR or tracked as fast follow-ups at the maintainer's discretion.
