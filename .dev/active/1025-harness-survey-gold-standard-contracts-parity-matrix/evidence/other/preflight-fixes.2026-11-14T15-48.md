# Preflight Fixes (Plan B)

Timestamp: 2026-11-14T15-48
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/owner-decision-plan.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned to the planner separately)

## Fixes

1. [P1-T3] Acceptance counter alignment. `DeferredRefMismatch` required every entry whose runbook is deferred to stay `provisional`, while rule 9 (decision H2) settles an overridden `copilot:agent:*` entry without the E3 condition. With E3 deferred and such an override present, the counter could not reach 0. The counter now excepts that entry, matching rule 9; the assertion still checks the rule 9 deferred clause.
2. [P2-T3] Ambiguous term. `ChangedProductionFiles` now counts `.ps1` and `.psm1` production files, so the changed matrix JSON and contract Markdown are not read as production code.
3. [P1-T4] Contract removal. A deletion now also removes a `references/` folder it leaves empty in the repository tree or the bundle; no test or assertion changes.
