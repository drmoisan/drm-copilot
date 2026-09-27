# Fail-Before Exception Dossier: Suite C ([P4-T6])

Timestamp: 2026-09-27T07-13
Subject: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 (rows C1 to C6 of plan section 4.3)

WhyFailingRunImpossible: Suite C pins behaviour that is already correct on the unchanged Codex gate-5 files `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1`, per spec decision D12. This change makes no production edit to gate 5, so there is no pre-change state in which the suite could fail and then pass.

## Alternative Proof

1. Unchanged production files. `evidence/regression-testing/gate5-pin-pass.md` records that `git diff --name-only daae7f796ebbd87e2170df3c86a9901ce11a4b68 -- .codex/hooks/enforce-completion-consistency.ps1 .codex/hooks/enforce-completion-helpers.ps1` and `git status --porcelain` over the same two paths both printed nothing. The files the suite exercises are byte-identical to BASE_SHA in both the committed history and the working tree.
2. Pin passes on those files. The same artifact records R-SCOPED over Suite C with `EXIT_CODE: 0`, `PassedCount: 6`, `FailedCount: 0`, and `FailedContainersCount: 0`, with every C1 to C6 name on a PASSED line.
3. The suite is discriminating. Rows C5 and C6 assert `deny` with a reason beginning `COMPLETION_CONSISTENCY_BLOCKED` for the per-feature checkpoint, and rows C1 to C4 assert `allow` or zero mapped records for the epic checkpoint. A gate-5 regression that intercepted the epic checkpoint would fail C1 to C4; a regression that stopped intercepting the per-feature checkpoint, or that accepted a feature-folder under `docs/features/epics/`, would fail C5 or C6.

SearchScope: docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/regression-testing/
SearchPatterns: fail-before-*.md, gate5-*.md
SearchResult: fail-before-b1-resolution.md and fail-before-b2-gate.md (gate 4 suites A and B only); gate5-pin-pass.md (this suite's pass-on-unchanged run). No failing run for Suite C exists, which is consistent with the reason above.
