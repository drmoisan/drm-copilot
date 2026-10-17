# Remediation Inputs — Cycle 1

- Timestamp: 2026-10-13T14-46
- Issue: #903
- Branch: bug/round-2-review-nits-and-evidence-timestamps-903
- Source audits: `policy-audit.2026-10-13T14-41.md`, `code-review.2026-10-13T14-41.md`, `feature-audit.2026-10-13T14-41.md`
- Blocking count at entry: 1

## Blocking Findings

### RI-1 (PA-1 / CR-A / FA-1) — Codex targets hook lines lost baseline coverage

- File: `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`, lines 356 (`target-ambiguous` return) and 370 (final "cannot be resolved" return).
- Baseline: covered at PHASE0 as lines 318 and 327 (`ci` 1) per `evidence/baseline/ps-catch-lines-baseline.*.md`.
- Head: `ci` 0 in the CI coverage XML of run 38410234897 (`evidence/qa-gates/ps-coverage.2026-10-13T14-28.md`).
- Rule violated: changed lines must not reduce coverage (`.claude/rules/general-unit-test.md`); plan task P12-T24.
- Suggested fix (from the reviewer): add rows to the surface-parameterized suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` asserting the exact deny-reason text for `target-ambiguous` and for the fall-through case, so the Codex leg registers coverage on the Codex copy.

## Included Non-blocking Item (same fix surface)

### RI-2 — Codex epic-scope deny branch uncovered

- File: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, lines 206-207 (deny branch of the CR-3 tail).
- No regression (the replaced statements were uncovered at baseline; file rose from 78.33% to 89.09%), but plan task P12-T24 still records them as failing.
- Required outcome: either cover them with a test that drives the Codex epic-scope decision to a deny outcome, or record a documented exemption with the reason the coverage XML does not attribute hits to these lines.

## Exit Condition

- P12-T24 and P12-T28 acceptance met on a new CI run on the remediated head.
- Reaudit artifacts (code-review, feature-audit, policy-audit) report blocking count 0.
