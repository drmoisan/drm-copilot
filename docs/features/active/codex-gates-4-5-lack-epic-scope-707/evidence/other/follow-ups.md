# Follow-up Candidates ([P7-T28])

Timestamp: 2026-09-27T07-47

1. AC-16 CI check-off (issue #707, `docs/features/active/codex-gates-4-5-lack-epic-scope-707/spec.md` AC-16): owed to `parallel-orchestrator`. AC-16 requires the pull-request CI Pester run on the Linux runner; after that run passes for the new suites of AC-15 and the D10-modified suites of AC-14, `parallel-orchestrator` checks off AC-16. Local proxy evidence: `qa-gates/p5-hermeticity-scan.md` and `qa-gates/final-pester-coverage.md`.
2. Optional manual Codex epic main-sync rerun (issue #707; same kind as #663 follow-up 5): a manual rerun of a Codex epic main-sync through the patched gate 4 (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`) to observe the epic-scope allow path end to end. Optional; not required by any AC.
3. Extend the no-Python guard scan roots (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`) to include `.codex/hooks` (spec `## Rollout & Follow-up`). Candidate follow-up; not part of #707.
4. Sibling rebase re-verification (plan tasks [P5-T1] to [P5-T7]): if this branch is rebased onto a `main` that has absorbed a sibling (#708, #709, #710, #713), re-run [P5-T1] to [P5-T7] against the new merge base before merging.
