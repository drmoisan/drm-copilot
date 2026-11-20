# Acceptance Criteria Verification (issue #997)

Timestamp: 2026-10-29T16-56
Command: none (mapping of spec.md AC-01 to AC-32 to recorded evidence)
EXIT_CODE: 0
Output Summary: AC-01 to AC-30 verified against local evidence; AC-31 pending-CI; AC-32 deferred post-merge live verification, not claimed as passed.

Source: `FEATURE/spec.md` (work mode `full-bug`). Evidence paths are relative to `FEATURE/evidence/`. Suites are under `tests/scripts/claude-hooks/`.

| AC | Status | Evidence |
| --- | --- | --- |
| AC-01 | PASS | `GreenCiDecision` row `allows a standalone merge with a green S9 gate and a matching live head (issue #997)` (asserts allow and one live-head call); failed before Phase 2 (`regression-testing/expect-fail.2026-10-29T16-27.md`), passes after (`regression-testing/pass-after.2026-10-29T16-33.md`). |
| AC-02 | PASS | `GreenCiDecision` rows `allows when --match-head-commit equals the live head (issue #997)` and `allows when pr_gate.head_sha equals ci_gate.head_sha (issue #997)`; same two artifacts. |
| AC-03 | PASS | `GreenCiDecision` row `declines a live head that differs from ci_gate.head_sha with GREEN_CI_HEAD_STALE (issue #997)`; `GreenCi` row `Test-EpicMergeGateGreenCiHeadAgreement returns false for a differing live head`. |
| AC-04 | PASS | `GreenCi` rows `declines ci_gate case <Case>` (seven cases: pending, failure, absent, Success, SUCCESS, ci_gate absent, ci_gate a string). |
| AC-05 | PASS | `GreenCi` rows `declines step9_status case <Case>` (six cases). |
| AC-06 | PASS | `GreenCi` rows `declines pr_gate.pr_number case <Case>` (six cases, including pr_gate absent with a matching authorization record). |
| AC-07 | PASS | `GreenCiDecision` rows for item target NoTarget and Ambiguous, and per-feature checkpoint absent and unparseable; each asserts deny and zero live-head calls. |
| AC-08 | PASS | `GreenCiDecision` row `denies a bare gh pr merge with the final deny text (issue #997)` asserts the reason `-BeExactly` the new final text. |
| AC-09 | PASS | `GreenCi` rows `Get-EpicMergeGateLivePrHeadSha outcome <Case>` (exit 0 valid, exit 1, exit 124, exit -1, unparseable JSON, malformed headRefOid; each asserts one `gh` seam call with `pr view 42 --json headRefOid`); `GreenCiDecision` row `declines with GREEN_CI_LIVE_HEAD_UNRESOLVED when the live head is unresolved`. |
| AC-10 | PASS | `GreenCiDecision` row `declines a differing --match-head-commit with GREEN_CI_MATCH_HEAD_MISMATCH`; `GreenCi` row `Test-EpicMergeGateGreenCiHeadAgreement returns false for a differing pinned head`. |
| AC-11 | PASS | `GreenCi` rows `declines epic_mode true in the green check`, `declines epic_mode as the string false`, `declines epic_mode as the number 1`, and `accepts epic_mode JSON null`. |
| AC-12 | PASS | `GreenCi` rows `ci_gate.head_sha case <Case>` (eight cases with expected results). |
| AC-13 | PASS | `GreenCiDecision` rows for layer 1a (parallel target resolves; epic target Ambiguous), layer 1b (worktree recorded as a parallel item; worktree seam throws), and layer 2 (`parallel_mode` true; non-blank `parallel_slug`), each paired with the NoTarget allow row; matching `GreenCi` pure rows for layer 2. |
| AC-14 | PASS | `GreenCiDecision` rows `declines a non-structural merge command <Case>` (chain, shell wrapper, -R, --repo, /pull/ URL, inline environment prefix, --auto, gh api merge mutation), each with zero live-head calls. |
| AC-15 | PASS | `hook-dependency-failure.SpecialCases.Tests.ps1` row `C9: denies through the merge gate when enforce-epic-merge-gate-green-ci.ps1 fails to load`; failed before P2-T2, passes after; rows C1 to C8 unchanged and passing. |
| AC-16 | PASS | `GreenCiDecision` rows `makes no live-head call when stage A declines`, `... stage B ...`, `... stage C ...`. |
| AC-17 | PASS | `GreenCiRegression` suite (six rows, passing before and after Phase 2); all nine existing `enforce-epic-merge-gate*.Tests.ps1` suites pass in `regression-testing/pass-after.2026-10-29T16-33.md` with only the three deny-text pins changed; `Test-ChildCheckpointAllowsEpicMerge` has no diff. |
| AC-18 | PASS | `qa-gates/deny-text-pins.2026-10-29T16-56.md`: prior text has no match; new text appears in the gate and the Authorization, MergeQueue, DocsOnly, and GreenCiDecision suites. The MergeQueue variable holding the text is `$script:ClaudeDenyText`; the DocsOnly variable is `$script:BareDenyText`. |
| AC-19 | PASS | `qa-gates/python-dev-tools.2026-10-29T16-38.md` (7341 passed, 0 failed) and `qa-gates/push-down-contracts.2026-10-29T16-36.md` (34 passed). |
| AC-20 | PASS | `.claude/skills/orchestrate/SKILL.md` S9 step 7 and the `pr_merge` schema bullet (P3-T1, P3-T2); step 6 text unchanged; S9 documentation contracts pass. |
| AC-21 | PASS | PR Creation Gate condition 7 keeps the `epic_merge.merge_commit_sha` sentence and adds the `pr_merge.merge_commit_sha` standalone sentence; condition 2 unedited; `test_completion_gate_documentation_contracts.py` passes. |
| AC-22 | PASS | `.claude/skills/parallel-orchestrate/SKILL.md` (pinned sentence kept, #997 amendment sentence, kickoff `parallel_mode: true` instruction, five-condition merge-gate paragraph, #670 described as the no-green-S9 route); `.claude/rules/orchestrator-state.md` `## Green-CI standalone merge (issue #997)` and Enforcement bullet; `.claude/rules/parallel-orchestration.md` Enforcement bullet. Each states the exclusion is best-effort; none states it is mechanically closed. |
| AC-23 | PASS | Gate header lists branch 3b, rewrites the standalone sentence, and states the best-effort residual window (tokens `GREEN_CI` and `best-effort`); the sibling header states the same window. |
| AC-24 | PASS | `other/mirror-parity.2026-10-29T16-35.md` (six equal SHA-256 pairs); core.json entry; `qa-gates/scope-check.2026-10-29T16-39.md` shows no diff for epic-orchestrate, settings.json, the six brief copies, the Codex bundle, `.codex/`, the authorization helper, and `hook-docs-only-diff.ps1`. |
| AC-25 | PASS | `qa-gates/line-counts.2026-10-29T16-39.md`: gate 476 lines (at most 500). |
| AC-26 | PASS | Same artifact: sibling 321, GreenCi 267, GreenCiDecision 288, GreenCiRegression 109 lines. |
| AC-27 | PASS | Authorization helper 443 lines with no diff; `enforce-epic-merge-gate.Tests.ps1` 471 lines with no diff; `session-root-reads-850.Constraints.Tests.ps1` passes (`qa-gates/runtime-contracts.2026-10-29T16-39.md`). |
| AC-28 | PASS | `qa-gates/ps-format.2026-10-29T16-37.md`, `qa-gates/pssa.2026-10-29T16-37.md`, `qa-gates/boundary-contract-stages.2026-10-29T16-39.md`, `qa-gates/runtime-contracts.2026-10-29T16-39.md`, `qa-gates/pester-full.2026-10-29T16-54.md` (12198 tests, 0 failures from the JUnit file); the final loop passed in a single pass. |
| AC-29 | PASS | `qa-gates/coverage-comparison.2026-10-29T16-54.md`: gate 100.00 percent (132/132), sibling 100.00 percent (56/56). |
| AC-30 | PASS | `regression-testing/isolation.2026-10-29T16-55.md` (seeds 11, 23, 47, all 172 passed); `qa-gates/test-hygiene.2026-10-29T16-40.md` (no temporary-file API, no direct `gh` invocation). |
| AC-31 | PENDING-CI | Owner: this item's orchestrator at S9, after `ci_gate.conclusion` is `success` and before DONE, including `poshqc / PowerShell QC` (coverage on windows-latest) and `poshqc / PowerShell hook suites (Linux)` (tests/scripts/claude-hooks on ubuntu-latest). Not verified locally. |
| AC-32 | DEFERRED | Post-merge live verification from a non-isolated run of the merged tree (a standalone orchestration merging its own green PR; a parallel child not doing so). Isolated subagents run main's hooks, so this cannot be shown before merge. Not claimed as passed. |
