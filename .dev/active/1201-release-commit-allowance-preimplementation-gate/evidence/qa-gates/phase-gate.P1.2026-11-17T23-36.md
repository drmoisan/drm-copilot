# Phase gate - Phase 1 (toolchain stages 1 to 6)

Timestamp: 2026-11-17T23-36
Command: the stages below, run in order through SCRATCH launcher scripts inside the worktree
EXIT_CODE: 0
Output Summary: one clean pass (pass 2) after one restart; zero failures in every stage.

## Pass 1 (restarted)

- Stage 1-2 PowerShell (format check and PSScriptAnalyzer over 17 files) and Invoke-PoshQCLeakScan: EXIT_CODE 0, 0 findings, leak scan 0 failures.
- Stage 5 Pester: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` EXIT_CODE 1. One failure: `enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree` (tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1) reported DynamicInvocation sites: the new hook files invoked local scriptblock variables with `&`, which the guard cannot verify statically. Fix: the local scriptblocks became the helper functions Get-ReleaseAllowanceInvalidConfigResult, Get-ReleaseAllowanceShapeResult, Get-ReleaseAllowanceDenialResult, and Get-OrchestrationReleaseAllowanceNotAppliedResult (named-parameter calls), and the decision's -Branch parameter is now a [scriptblock] reader. The four copies of each file were recopied. A verification selection (the guard plus the four new suites) passed 605 of 605 before the restart.

## Pass 2 (clean)

1. Stage 1 format and stage 2 lint, PowerShell: Command: sh SCRATCH/issue-1201-ps-static.sh over the four copies of hook-release-allowance-context.ps1, the four copies of enforce-orchestration-preimplementation-gate-release.ps1, the four gate copies, and the five new test files and the cases file. EXIT_CODE: 0. Findings: format drift 0, PSScriptAnalyzer 0.
2. Leak scan: Command: sh SCRATCH/issue-1201-leak-scan.sh (Invoke-PoshQCLeakScan -Root with the branch-current PoshQC module). EXIT_CODE: 0. "Leak scan: 864 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures."
3. Stages 1-3, Python and TypeScript: Command: sh SCRATCH/issue-1201-static-py-ts.sh pg1b (Black check, Ruff, Pyright on scripts/dev_tools/push_down_claude_customizations.py; Prettier check, ESLint, TSC for both extensions/drm-copilot projects). EXIT_CODE: 0 for each of the 7 steps; findings 0.
4. Stage 4 architecture boundaries: not applicable; the repository has no dependency-cruiser configuration (.dependency-cruiser.cjs absent at the root and in extensions/drm-copilot) and no .NET architecture tests. Finding count 0.
5. Stage 5 Pester: Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, 721.78 s, 2026-11-17T23-03 to 23-17). EXIT_CODE: 0. 28066 tests, 28048 passed, 0 failed, 18 skipped. Repo-wide line coverage 45276/47121 = 96.08%. Per file: .claude and .codex hook-release-allowance-context.ps1 171/171 = 100.00% each; .claude and .codex enforce-orchestration-preimplementation-gate-release.ps1 32/32 = 100.00% each; .claude gate 171/177 = 96.61%; .codex gate 182/182 = 100.00%.
6. Stage 5 pytest: Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1201-pg1-py-coverage.json (one pytest -n auto run). EXIT_CODE: 0. 16957 passed, 0 failed, 6 skipped. Lines 97.74%, branches 95.15%.
7. Stage 5 Jest: Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (normal parallel workers; one earlier attempt exited 75 on a busy lock, a queue timeout). EXIT_CODE: 0. 344 suites, 5681 tests passed, 0 failed; coverageThreshold map met.
8. Stage 6 contract checks: the push-down resource-contract, pack-manifest completeness and dependency-closure suites ran inside the pytest gate (all passed); the Codex generator check exited 0 with no drift in the P1-T5 task check and no generator input changed since; the dependency-guard completeness, Codex line-limit, discovery guard, and ledger chain suites ran inside the Pester gate (all passed).

## Physical line counts

- hook-release-allowance-context.ps1: 495 in each of the four roots (below 500).
- enforce-orchestration-preimplementation-gate-release.ps1: 166 in each of the four roots.
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and its bundle copy: 495.
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 and its bundle copy: 487 (at or under 500).
- New test files: hook-release-allowance-context.Tests.ps1 281; enforce-orchestration-preimplementation-gate-release.Tests.ps1 225; ReleaseAllowance.Cases.ps1 153; ReleaseAllowance.Tests.ps1 107; Codex release-allowance suite 108.
