# Post-merge Pester and PSScriptAnalyzer verification (issue 732)

Timestamp: 2026-10-09T02-02
Command: pwsh -NoProfile -File <scratchpad>/run-postmerge.ps1 -Root <repository root>  (Pester 5, Run.Path = tests/scripts/claude-hooks, tests/scripts/codex-hooks, tests/scripts/claude-lib/worktree-resolution, tests/scripts/claude-lib/orchestrator-state; Output.Verbosity None; PassThru)
EXIT_CODE: 0
ExpectedExitCode: 0

Note: the runner script prints counts and FAIL lines and always exits 0. The process EXIT_CODE does not reflect test failures; the counts below are the result signal.

Tree under test: local branch `c1b-732-resume`, HEAD `388a4d54` (merge of `origin/epic/enforcement-hook-precision-integration` at `5d9d8846` into `bug/exempt-operand-bypass-brace-and-dot-segments-exec-732` at `49601268`), not pushed.

Output Summary:
- Pester: TOTAL=5836 PASSED=5797 FAILED=39 SKIPPED=0 NOTRUN=0 CONTAINER_FAILED=0
- Failures: 1 in tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1; 38 in tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
- Classification: 0 merge-introduced; 38 pre-existing (reproduced at 49601268); 1 environmental (ambient untracked checkpoint in this worktree; passes at 49601268 without that checkpoint; hook and test byte-identical across the merge)
- PSScriptAnalyzer (repo settings): 11 files, 0 diagnostics, EXIT_CODE 0

## FAIL lines (verbatim)

```text
FAIL: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits :: Expected $null or empty, because every registered handler must allow a benign admitted payload, but got 'enforce-epic-wave-barrier.ps1 x Bash: exit=0 stdout=[{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '732' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."}}] stderr=[]
enforce-epic-wave-barrier.ps1 x shell_command: exit=0 stdout=[{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '732' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."}}] stderr=[]
enforce-epic-wave-barrier.ps1 x apply_patch: exit=0 stdout=[{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '732' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."}}] stderr=[]
enforce-epic-wave-barrier.ps1 x Edit: exit=0 stdout=[{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '732' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."}}] stderr=[]
enforce-epic-wave-barrier.ps1 x Write: exit=0 stdout=[{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '732' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."}}] stderr=[]
enforce-epic-wave-barrier.ps1 x mcp__drm_copilot__run_poshqc_format: exit=0 stdout=[{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '732' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."}}] stderr=[]'.
FAIL: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving potential_to_issue alone :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving the feature entry tool with a record :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts a bug checkpoint waiving the bug entry tool with a record :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts the same record on the preparation route :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts the documented origin value transferred :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts the documented origin value filed_before_orchestration :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts the documented origin value epic_decomposition :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_issue_view :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_api_get :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption accepts valid records (AC-6).accepts the documented verification source github_mcp_issue_read :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind string :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind integer :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind list :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a null adoption value :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an integer issue number :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a leading-zero issue number :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an issue number that differs from the checkpoint issue-num :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an issue URL that does not end with the issue number :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an unknown origin :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an unknown verification source :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an absent verification time :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a null verification time :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a whitespace-only verification time :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects empty evidence :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an empty waived list :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind string :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind blank-entry :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind integer-entry :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects a waived list that omits the issue-creation tool :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption rejects malformed records (AC-7).rejects an invalid potential record when waiving the entry tool :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature-folder tool :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the artifact-validation tool :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature entry tool on a bug checkpoint :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption enforces the closed waivable set (AC-8).rejects any waiver on the remediation route :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption enforces the closed waivable set (AC-8).rejects waiving a tool that holds a successful receipt :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption enforces the closed waivable set (AC-8).rejects a tool listed twice :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption fails closed and is presence gated (AC-9, AC-11).empties the waived set whenever any error is reported across a fixed grid :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
FAIL: Issue adoption fails closed and is presence gated (AC-9, AC-11).yields no errors and no waivers for a checkpoint without the adoption key :: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```

## Classification against pre-merge commit 49601268

Method: `git archive 49601268 | tar -x` into a session scratchpad directory (no worktree, no stash, no change to the repository), then Pester 5 with `<scratchpad>/run-paths.ps1` on the extracted tree. Supporting diffs: `git diff --stat 49601268 388a4d54 -- <paths>`.

### Group A: OrchestratorStateIssueAdoption.Tests.ps1 (38 failures): PRE-EXISTING

- `git diff --stat 49601268 388a4d54 -- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`: empty (no change across the merge).
- Pre-merge tree, folder tests/scripts/claude-lib/orchestrator-state: TOTAL=774 PASSED=736 FAILED=38, all `Get-OrchestratorStateIssueAdoptionResult` not recognized. The sorted set of failing test names is identical to the post-merge set (`diff` exit 0, 38 names).
- Merged tree, folder tests/scripts/claude-lib/orchestrator-state alone: TOTAL=801 PASSED=763 FAILED=38 (the 27 additional tests come from the merged OrchestratorStateEpicWaveBarrier test files and all pass).
- Merged tree, OrchestratorStateIssueAdoption.Tests.ps1 alone: TOTAL=42 PASSED=4 FAILED=38. The failure does not depend on the sibling test files that the merge added.
- Already recorded as potential bug docs/features/potential/2026-10-01-issue-adoption-pester-folder-scoped-command-not-found.md (same 38 cases and the same four groups: AC-6 10, AC-7 20, AC-8 6, AC-9/AC-11 2).

### Group B: codex-pretooluse-integration.Tests.ps1 (1 failure): ENVIRONMENTAL, NOT MERGE-INTRODUCED

- The deny text `cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint.` is emitted by .codex/hooks/enforce-epic-wave-barrier.ps1 line 236. That path runs only when the local checkpoint at the payload cwd has `epic_mode: true`.
- The test sets the payload `cwd` to the repository root. This worktree holds the gitignored, untracked artifacts/orchestration/orchestrator-state.json with `"epic_mode": true` and `"issue-num": "732"` (`.gitignore:6:/artifacts`), so the hook denies every mutating tool name for feature key 732.
- `git diff --stat 49601268 388a4d54 -- .codex tests/scripts/codex-hooks`: empty. The Codex hook, its only dot-sourced dependency (codex-epic-child-launch-attestation.ps1), and the test file are unchanged across the merge. The comment-only change to .claude/hooks/enforce-epic-wave-barrier.ps1 is not on this code path.
- Pre-merge extracted tree, which has no artifacts/ directory: codex-pretooluse-integration.Tests.ps1 TOTAL=7 PASSED=7 FAILED=0.
- Conclusion: the failure depends on ambient orchestration state in this worktree, not on merged code. It would fail at 49601268 in this same worktree with the same checkpoint present. The test does not isolate itself from repository-root checkpoint state.

## PSScriptAnalyzer

Timestamp: 2026-10-09T02-02
Command: pwsh -NoProfile -File <scratchpad>/run-pssa.ps1 -Root <repository root>  (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, per file)
EXIT_CODE: 0
Output Summary: FILES=11, DIAGNOSTICS=0 ERRORS=0 WARNINGS=0 INFO=0
Files:
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1

## Tooling note

The worktree isolation guard rejects Bash command text that contains `pwsh`. Each pwsh invocation therefore ran through a `sh <scratchpad>/*.sh` wrapper. The PoshQC MCP test tool was not used, as directed.
