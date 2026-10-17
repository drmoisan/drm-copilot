# Remediation status, cycle 1 (issue #952)

Timestamp: 2026-10-16T16-32
Task: [P5-T11]
Command: record of findings against cycle-1 evidence
EXIT_CODE: 0
Output Summary: executor tasks P0-T1 to P5-T12 complete; R1 PENDING-ORCH; CR-2, CR-3, CR-4 and R-MERGE LOCAL-PASS with CI rows PENDING-ORCH; CR-5, CR-7, CR-8 LOCAL-PASS; CR-6, CR-9 ORCH-OWNED; R2 PENDING-CI. No acceptance criterion was checked off by the executor.

| Finding | Evidence (FEATURE/evidence/...) | Status |
|---|---|---|
| R1 (Codex helper coverage) | regression-testing/codex-helper-coverage-diagnosis.2026-10-16T15-40.md (non-gating observation; STATIC_CAUSE=NOT-DETERMINED-STATICALLY); regression-testing/codex-selector-before.2026-10-16T15-47.md; regression-testing/codex-selector-after.2026-10-16T16-12.md; other/line-counts-tests.2026-10-16T15-43.md | PENDING-ORCH (ORCH-R1, ORCH-R3) |
| CR-2 (Claude helper lines 68, 160, 161) and CR-4 (non-numeric --merge=<value>) | regression-testing/claude-selector-before.2026-10-16T15-54.md; regression-testing/claude-selector-after.2026-10-16T16-12.md; regression-testing/codex-selector-before.2026-10-16T15-47.md; regression-testing/codex-selector-after.2026-10-16T16-12.md; qa-gates/rem-final-helper-hashes.2026-10-16T16-31.md (HELPER_COPIES_EQUAL=4/4) | LOCAL-PASS, CI rows PENDING-ORCH |
| CR-3 (parser lines 98, 101, 108, 128) | regression-testing/parser-cases-after.2026-10-16T15-55.md | LOCAL-PASS, CI rows PENDING-ORCH |
| CR-5 (file-supplied GraphQL limitation) | P3-T4 token count 1 (`is not visible to this text-based scope`, all four helper copies by hash); P4-T1 token count 1 (`is not visible to the text-based gh api scope` in spec.md, one added line) | LOCAL-PASS |
| CR-7 (scope deviation D10(a)) | other/scope-deviation-d10.2026-10-16T16-13.md | LOCAL-PASS |
| CR-8 (runbook capture path) | P4-T3 token checks (count 1; old text exit 1); qa-gates/runbook-sections.2026-10-16T16-13.md (TOKENS_FOUND=16/16) | LOCAL-PASS |
| CR-6 (cause statement) and CR-9 (repository-wide PowerShell figure) | none by the executor | ORCH-OWNED (ORCH-R3) |
| R-MERGE (#927 deny-text pins) | regression-testing/docs-only-pin-before.2026-10-16T15-43.md; P2-T7 and P2-T8 token checks; regression-testing/claude-selector-before.2026-10-16T15-54.md and regression-testing/codex-selector-before.2026-10-16T15-47.md (pinned rows listed Passed, JUnit fresh) | LOCAL-PASS, CI rows PENDING-ORCH (ORCH-R1 rows (k) and (l), ORCH-R2) |
| R2 (AC-28) | none | PENDING-CI (main plan ORCH-3 and ORCH-7 at S9) |

## Next step

The orchestrator runs ORCH-R1 (Windows per-suite results on a new `ci.yml` dispatch), ORCH-R2 (Linux per-suite results), ORCH-R3 (coverage comparison, CR-6 cause statement, CR-9 repository-wide figure, and the AC check-offs if all pass), and ORCH-R4 (re-audit).

Note for the orchestrator: `origin/main` advanced to d72ec6a1010223f7036b9c3d15dad102ae262f98 after P0-T2 (other/concurrency-recheck.2026-10-16T15-56.md); none of its new commits touch the eight merge-gate files. The executor did not merge it.

No acceptance criterion was checked off by the executor.
