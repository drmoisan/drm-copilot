# Post-sync targeted check (issue #1233)

Timestamp: 2026-11-24T14-09
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <43 targeted suites listed below>
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 220.82s; merged JUnit tests=2019, failures=0, errors=0, disabled=0. Attempts 1-22 exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT, lock held by suite pester from worktree drm-copilot-wt-targeted-test-cadence); recorded as queue timeouts, not failures. Attempt 23 exited 0.

Context: feature branch synced with origin/main by merge commit 8dccd6cdf (issue #1234 release merge leg). The merge left .claude/hooks/enforce-epic-merge-gate.ps1 at 502 lines against the 500-line cap in session-root-reads-850.Constraints.Tests.ps1. The #1233 header note in condition 1 was condensed from four lines to three (the two #1233 lines to one line plus the tail of the prior line), and header condition 4 (#670 text) was reflowed with whitespace only; the file is now 500 lines. The bundle mirror is byte-identical, and the 0014 ledger revert block Current for the header text was updated in the same commit. No #1234 code or wording changed.

Pester selection:
- tests/scripts/claude-hooks: enforce-epic-merge-gate.{Authorization, AuthorizationFields, ChildCi, ChildCiOptOut, Coverage, DocsOnly, EpicModeStrict, GreenCi, GreenCiDecision, GreenCiRegression, ItemResolution, MergeQueue, Regeneration, Release, ReviewGuard, ReviewPaths, (base), TriggerScoping, WorktreeResolution}.Tests.ps1, enforce-epic-merge-gate-release.Ci.Tests.ps1, enforce-epic-merge-gate-release.Tests.ps1, release-merge.Parity.Tests.ps1, session-root-reads-850.Constraints.Tests.ps1, hook-dependency-failure.Claude.Tests.ps1, hook-dependency-failure.SpecialCases.Tests.ps1
- tests/scripts/codex-hooks: enforce-epic-merge-gate-{authorization, child-ci, child-ci-opt-out, command, decision-surface, docs-only, merge-queue, regeneration, release, review, trigger-scoping}.Tests.ps1, cross-tree-helper-identity.Tests.ps1, codex-epic-runtime-contracts.Tests.ps1, hook-dependency-failure.Codex.Tests.ps1
- tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1
- tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1
- tests/scripts/dev-tools: ProcessReductionChain.Ledger.Tests.ps1, ProcessReductionLedger.Tests.ps1, ProcessReductionLedger.Index.Tests.ps1, ProcessReductionLedger.Replay.Tests.ps1 (run after the fix commit 16022bae3, against the committed tree)

Timestamp: 2026-11-24T14-09
Command: pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
EXIT_CODE: 0
Output Summary: harness-generation: no drift

Timestamp: 2026-11-24T14-09
Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, for .claude/hooks/enforce-epic-merge-gate.ps1 and extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE: 0
Output Summary: 0 findings across 2 files.

Timestamp: 2026-11-24T14-09
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
EXIT_CODE: 0
Output Summary: 23 passed, 0 failed (24 xdist workers). Attempt 1 exited 75 (queue timeout, lock held by another worktree's pester suite); attempt 2 exited 0.

Deviations: none. No environment-coupled pre-existing failure was observed.
