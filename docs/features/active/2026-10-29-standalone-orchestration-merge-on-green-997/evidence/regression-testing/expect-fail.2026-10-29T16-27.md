# Expect-Fail Run (issue #997, before Phase 2)

Timestamp: 2026-10-29T16-27
Command: sh SCRATCH/issue-997-expectfail.sh (one PowerShell 7 process, Invoke-Pester over the seven suites below, JUnit written to artifacts/pester/pester-junit.xml); then poetry run pytest "tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_section_states_its_required_obligations[merge-on-green-parent-executes-merge]" -q -p no:cacheprovider
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Pester (artifacts/pester/pester-junit.xml): 172 test cases, 82 failures, 90 passed, 0 skipped; no container-level error.
- pytest node: 1 failed; the assertion lists the missing fragment "Issue #997 amends `.claude/skills/orchestrate/SKILL.md` for standalone runs only".
- EXIT_CODE records the pytest node exit (1, the expected failure). The Pester launcher's process exit is 0 because Invoke-Pester runs without -EnableExit; counts are read from the JUnit file.

Per-suite outcome:

| Suite (`tests/scripts/claude-hooks/`) | Failed | Passed | Expected |
| --- | --- | --- | --- |
| `enforce-epic-merge-gate.GreenCi.Tests.ps1` | 50 | 1 (isolation probe) | every expect-fail row fails |
| `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` | 28 | 1 (isolation probe) | every expect-fail row fails |
| `enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` | 0 | 6 | every row passes (pins existing behavior) |
| `hook-dependency-failure.SpecialCases.Tests.ps1` | 1 (C9) | 14 | only C9 fails |
| `enforce-epic-merge-gate.Authorization.Tests.ps1` | 1 (`$script:Line433Text` row) | 15 | only the pin row fails |
| `enforce-epic-merge-gate.MergeQueue.Tests.ps1` | 1 (`$script:ClaudeDenyText` row) | 39 | only the pin row fails |
| `enforce-epic-merge-gate.DocsOnly.Tests.ps1` | 1 (`$script:BareDenyText` row) | 14 | only the pin row fails |

Failure reasons (read from the failure messages, confirming the behavior gap rather than a structural error):
- GreenCi suite: 39 rows report `The term 'Test-ChildCheckpointGreenCiRecorded' is not recognized`, 4 report `Test-EpicMergeGateGreenCiHeadAgreement`, 6 report `Get-EpicMergeGateLivePrHeadSha`, 1 reports `Resolve-EpicMergeGateParallelItemByWorktree`.
- GreenCiDecision suite: the three allow rows and the MATCH_HEAD row fail because the gate denies with `STANDALONE_MERGE_AUTHORIZATION_ABSENT` (no green-CI branch); the bare row fails on the old 521-character deny text against the new 778-character text; the remaining 23 rows fail with `Could not find Command Get-EpicMergeGateLivePrHeadSha` or `Resolve-EpicMergeGateParallelItemByWorktree`.
- SpecialCases C9: the reason does not contain `enforce-epic-merge-gate-green-ci.ps1` (the gate does not yet load it).
- Authorization, MergeQueue, DocsOnly pin rows: `Expected length: 778 Actual length: 521` (the gate still emits the prior deny text).

Failing test names:

GreenCi suite (50): Test-ChildCheckpointGreenCiRecorded returns true for a green standalone checkpoint; Test-ChildCheckpointGreenCiRecorded returns true when epic_mode is JSON false; accepts epic_mode JSON null; accepts parallel_mode JSON false with a blank parallel_slug; declines ci_gate case (conclusion pending, conclusion failure, conclusion absent, conclusion Success, conclusion SUCCESS, ci_gate absent, ci_gate a string); declines step9_status case (absent, pending, failed_remediation_required, blocked_ci_loop_limit, Passed, PASSED); declines pr_gate.pr_number case (absent, JSON null, fractional, non-numeric string, 43 against command 42, pr_gate absent with a matching authorization record); declines epic_mode true in the green check; declines epic_mode as the string false; declines epic_mode as the number 1; ci_gate.head_sha case (absent, blank, uppercase 40-hex, 39-hex, 41-hex, lowercase 64-hex, pr_gate.head_sha differing, pr_gate.head_sha JSON null); declines parallel_mode true in the green check; declines a non-blank parallel_slug in the green check; declines command PR number case (null, zero); declines a null checkpoint; Test-EpicMergeGateGreenCiHeadAgreement returns true for an equal live head and no pin; Test-EpicMergeGateGreenCiHeadAgreement returns false for a differing live head; Test-EpicMergeGateGreenCiHeadAgreement returns false for a differing pinned head; Test-EpicMergeGateGreenCiHeadAgreement returns false for an unresolved live head; Get-EpicMergeGateLivePrHeadSha outcome (exit 0 with a valid headRefOid, exit 1, exit 124 timeout, exit -1 missing root, unparseable JSON, malformed headRefOid); forwards the worktree root to the parallel worktree_path record lookup.

GreenCiDecision suite (28): allows a standalone merge with a green S9 gate and a matching live head (issue #997); allows when --match-head-commit equals the live head (issue #997); allows when pr_gate.head_sha equals ci_gate.head_sha (issue #997); declines a live head that differs from ci_gate.head_sha with GREEN_CI_HEAD_STALE (issue #997); declines with GREEN_CI_LIVE_HEAD_UNRESOLVED when the live head is unresolved; declines a differing --match-head-commit with GREEN_CI_MATCH_HEAD_MISMATCH; declines when the item target is NoTarget; declines when the item target is Ambiguous; declines when the per-feature checkpoint is absent; declines when the per-feature checkpoint is unparseable; denies a bare gh pr merge with the final deny text (issue #997); declines when the parallel run target resolves for the PR (layer 1a); declines when the epic run target is Ambiguous (layer 1a); declines when the child worktree is recorded as a parallel item (layer 1b); declines when the worktree seam throws (layer 1b); declines a checkpoint carrying parallel_mode true (layer 2); declines a checkpoint carrying a non-blank parallel_slug (layer 2); declines a non-structural merge command (chain, shell wrapper, -R override, --repo override, pull URL selector, inline environment prefix, --auto, gh api merge mutation); makes no live-head call when stage A declines; makes no live-head call when stage B declines; makes no live-head call when stage C declines.

Other suites (4): C9: denies through the merge gate when enforce-epic-merge-gate-green-ci.ps1 fails to load; keeps the existing fall-through text for a bare merge even with a valid record present (Authorization); denies a bare gh pr merge --squash with the method-agnostic message (MergeQueue); makes no docs-only call for a bare merge and keeps its exact deny text (issue #927) (DocsOnly).

Notes:
- The plan names the MergeQueue variable `$script:DenyText`; the variable that holds the text in that suite is `$script:ClaudeDenyText`, and that is the one updated.
- Rows beyond the plan's minimum (the parallel_mode false allow row, the command-number and null-checkpoint rows, the agreement true and unresolved rows, the worktree-seam forwarding row, and the layer 1b throw row) were added for line coverage of the new sibling; each also fails before Phase 2.
- The regression docs-only row first failed because the docs-only exemption requires an existing session directory; it now mocks the session root to the suite directory, as the DocsOnly suite does, and passes.
