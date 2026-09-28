# Feature Audit — Issue #711 (remaining-cannot-fail-count-assertions)

- Timestamp: 2026-09-27T15-50
- Branch: `bug/remaining-cannot-fail-count-assertions-711`
- Work mode: `full-bug` (per `issue.md`'s `- Work Mode: full-bug` marker)
- Authoritative AC source (per work-mode routing): `spec.md` (9 items). `issue.md`'s 6-item list is a secondary checklist, also independently checked off and evaluated below.

## AC Evaluation Table (spec.md — authoritative source)

| AC | Requirement | Verdict | Evidence |
|---|---|---|---|
| AC-1 | `mandate_reads` assertion in `BlastRadius.TruthTable.Tests.ps1` fails on empty/null | PASS | `evidence/regression-testing/ac1-before-after-token-check.2026-09-27T16-00.md`, `ac1-existing-negative-controls.2026-09-27T15-45.md`; independently verified by reading the edited line and the `Test-NonVacuousCollection` helper body |
| AC-2 | `enforcement-hooks-no-python-invocation.Tests.ps1` assertion fails on empty/null | PASS | `evidence/regression-testing/ac2-before-after-token-check.2026-09-27T16-00.md`, `ac2-ac3-ac4-inline-old-vs-new-form.2026-09-27T15-45.md`; independently verified against `Get-GuardedPowerShellFile`'s `return , $x.ToArray()` producer contract |
| AC-3 | `DiscoveryValidation.Tests.ps1` (line 155 area) assertion fails on empty/null | PASS | `evidence/regression-testing/ac3-before-after-token-check.2026-09-27T16-00.md`, `ac2-ac3-ac4-inline-old-vs-new-form.2026-09-27T15-45.md`; independently verified against `Get-DiscoveryProfileValidationError`'s producer contract |
| AC-4 | `DiscoveryValidation.Tests.ps1` (line 333 area) assertion fails on empty/null | PASS | `evidence/regression-testing/ac4-before-after-token-check.2026-09-27T16-00.md`, `ac2-ac3-ac4-inline-old-vs-new-form.2026-09-27T15-45.md`; independently verified against `Get-DiscoverySchemaArtifactValidationError`'s producer contract |
| AC-5 | `codex-pretooluse-integration.Tests.ps1` assertion fails on empty/null | PASS | `evidence/regression-testing/ac5-assertion-before-after-token-check.2026-09-27T16-05.md`; independently verified against `Get-CodexPreToolUseRegistration`'s producer body (missing leading comma confirmed at line 55) |
| AC-6 | All four suites pass, no reduction in test count, baseline-relative | PASS | `evidence/regression-testing/final-per-file-pester-and-ac6-comparison.2026-09-27T16-30.md`, `final-per-directory-pester.2026-09-27T16-35.md`; baseline-relative comparison correctly used the actually-observed Phase 0 baseline (TotalCount=6 for codex-pretooluse-integration.Tests.ps1, not the plan's stated expectation of 5), per spec.md Decision D9, and the +1 delta is fully accounted for by the one new AC-5 documentation `It` |
| AC-7 | All four files at or under 500 lines | PASS | `evidence/qa-gates/final-line-count-invariant.2026-09-27T16-35.md`; independently spot-checked (391/500/476/210 lines) |
| AC-8 | Fail-before evidence exists for each site | PASS | AC-1's existing negative controls, AC-5's new `Context`/`It` pair (verified present and correctly demonstrating the old-vs-new discrimination), and AC-2/3/4's inline `pwsh -NoProfile -Command` evidence, all present under `evidence/regression-testing/` |
| AC-9 | No production file under `.claude/lib`, `.claude/hooks`, or `scripts` modified | PASS | `evidence/qa-gates/ac9-scope-check.2026-09-27T16-40.md`; independently confirmed via `git diff origin/main...HEAD --stat -- .claude .codex scripts` (no output) |

**spec.md totals: 9/9 PASS. All 9 items already checked off `[x]` in `spec.md`; no additional check-off action was required by this review.**

## AC Evaluation Table (issue.md — secondary checklist)

| AC | Requirement | Verdict |
|---|---|---|
| AC-1 | `mandate_reads` assertion fails on empty/null | PASS |
| AC-2 | `enforcement-hooks-no-python-invocation.Tests.ps1` assertion fails on empty/null | PASS |
| AC-3 | `DiscoveryValidation.Tests.ps1` (line 155) assertion fails on empty/null | PASS |
| AC-4 | `DiscoveryValidation.Tests.ps1` (line 333) assertion fails on empty/null | PASS |
| AC-5 | `codex-pretooluse-integration.Tests.ps1` assertion fails on empty/null | PASS |
| AC-6 | All four suites pass, no reduction in test count | PASS |

**issue.md totals: 6/6 PASS. All 6 items already checked off `[x]` in `issue.md`; no additional check-off action was required by this review.**

## Baseline Comparison

The branch's baseline is `origin/main` at `bd4284c57be52d222eec3983671fc7e444f9a88b`, confirmed by direct `git fetch`/`git rev-parse`. Against this baseline, the four test files are the only production-adjacent files modified (they are test code, not production code), and the change is additive/corrective to existing assertions with no new production behavior. No feature drift beyond the nine ACs was observed in the diff.

## Deviations From Plan (evaluated)

1. **Seventh helper script** (`select-string-count.ps1`): documented deviation, mechanically necessary substitution for an unavailable bare-PowerShell execution surface, verified to reproduce byte-identical command semantics. Does not affect AC satisfaction.
2. **Batch-budget counter reset**: touched only a gitignored (`.claude/state/`), untracked file; verified independently via `.gitignore` inspection and `git ls-files`. No tracked or production file affected.
3. **Baseline mismatch for `codex-pretooluse-integration.Tests.ps1`**: the actual freshly captured baseline (`TotalCount=6, FailedCount=0`) differs from the plan's documented expectation (`TotalCount=5, FailedCount=1`), but spec.md Decision D9 requires baseline-relative comparison rather than a hard-coded numeric baseline, and this is what was applied. The Phase 4 final count of 7 is exactly baseline + 1, matching the one new AC-5 documentation test. No regression is masked.
4. **Commit-message reword**: cosmetic, does not affect source content or any AC; not independently verifiable from committed artifacts but is consistent with the final (professional, policy-compliant) commit messages observed.

None of these deviations affect AC satisfaction or introduce unaccounted risk.

## AC Status Summary

### Source: `spec.md` (authoritative, full-bug work mode)
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: none

### Source: `issue.md` (secondary checklist)
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: none

## Overall Feature-Audit Verdict

**PASS.** All 9 `spec.md` acceptance criteria and all 6 `issue.md` acceptance criteria are satisfied with verifiable, evidence-backed support, independently cross-checked against the actual producer code and the actual current file content (not merely accepted from the plan's or executor's own claims). No unmet or unsupported check-offs were found.

**Blocking finding count: 0.**
