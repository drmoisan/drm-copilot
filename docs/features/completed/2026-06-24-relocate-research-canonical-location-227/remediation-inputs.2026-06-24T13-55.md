# Remediation Inputs — relocate-research-canonical-location (Issue #227)

- **Timestamp:** 2026-06-24T13-55
- **Base branch (resolved):** origin/main @ ea94a068e0a071940858a0694c47e204244c09af
- **Head:** d200d8961843f8b9d040f6c847b8ae186035dc90
- **Source artifacts:**
  - policy-audit: docs/features/active/2026-06-24-relocate-research-canonical-location-227/policy-audit.2026-06-24T13-55.md
  - code-review: docs/features/active/2026-06-24-relocate-research-canonical-location-227/code-review.2026-06-24T13-55.md
  - feature-audit: docs/features/active/2026-06-24-relocate-research-canonical-location-227/feature-audit.2026-06-24T13-55.md

## Remediation Trigger

Coverage threshold not met for a modified file. Per the feature-review-workflow SKILL coverage contract, modified files must reach line coverage >= 85%. `enforce-evidence-locations.ps1` is at 81.5% line coverage.

## Blocking Findings

### Finding 1 — enforce-evidence-locations.ps1 line coverage below threshold

- **Severity: Blocking**
- **File:** .claude/hooks/enforce-evidence-locations.ps1 (and its byte-identical Claude bundled mirror at extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1)
- **Location:** entry-point execution block, lines 146, 148, 149, 152, 154
- **Measurement:** Modified-file line coverage 81.5% (22/27 lines), below the uniform 85% line threshold (quality-tiers.md, general-unit-test.md). Reviewer Pester re-run corroborates: the only uncovered commands are the script entry-point dispatch block, unreachable when the script is dot-sourced by the unit tests.
- **Context:** The feature's changed line (the added `'artifacts/research/'` forbidden prefix) is inside the fully covered `Test-EvidenceLocationForbidden` function. There is no regression on changed lines. The shortfall is in the pre-existing entry-point wiring, not in the feature change. Coverage improved +11.1 points from the 70.4% baseline.
- **Evidence:** docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/qa-gates/coverage-delta.2026-06-24T13-09.md; reviewer-run Invoke-Pester with CodeCoverage scoped to the two hooks (uncovered lines 146,148,149,152,154).
- **Required remediation:** Bring `enforce-evidence-locations.ps1` line coverage to >= 85% by one of:
  1. Adding a process-level/integration test that invokes the script as a separate process with a representative `CLAUDE_TOOL_INPUT`, exercising the entry-point dispatch block (lines 146-154); or
  2. Refactoring the entry-point wiring so the dispatch path is invokable and asserted by the existing dot-sourced unit tests (extract the entry-point block into a thin, testable function and assert its decision-to-output mapping).
  Apply the same change to the byte-identical Claude bundled mirror to preserve cross-ecosystem equality (AC7). The Codex bundled copy is a translation; mirror the testable-wiring change if it affects shared logic.
- **Acceptance for closure:** Re-run targeted Pester coverage for enforce-evidence-locations.ps1; line coverage >= 85% with no regression on changed lines; root and Claude-bundled mirror remain byte-identical; full claude-hooks Pester suite remains green.

## Non-Blocking Observations (not gating)

- Low: trailing blank line with mixed line ending at end of validate-task-researcher-output.ps1. Cosmetic; passes Invoke-Formatter; byte-identical in mirror. Optional cleanup on next edit.

## Acceptance Criteria Status

All 7 acceptance criteria and 3 seeded test conditions evaluate PASS (see feature-audit.2026-06-24T13-55.md). No acceptance criterion is blocked. The only Blocking item is the coverage threshold above.

## Go / No-Go

No-go for PR until Finding 1 is resolved. All functional acceptance criteria are met; the single gating item is the modified-file coverage threshold.
