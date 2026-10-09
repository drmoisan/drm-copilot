# Final Pester Counts (P6-T6), pass 1

Timestamp: 2026-10-08T22-36

## SET-HOOK

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path <the seven SET-HOOK files>
EXIT_CODE: 0
Output Summary: TotalCount=93 PassedCount=93 FailedCount=0 FailedContainersCount=0 (expected BASE_HOOK_TOTAL 57 + 36 + 0 rows added under P3-T13 = 93)

## SET-LIB

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/orchestrator-state
EXIT_CODE: 0
Output Summary: TotalCount=801 PassedCount=763 FailedCount=38 FailedContainersCount=0 (expected BASE_LIB_TOTAL 774 + 27 + 0 rows added under P2-T6 = 801)
FAILED set: the 38 KL-ADOPT lines only. `SCRATCH/failed-set-compare.ps1` against the P0-T22 output printed `FAILED-SET baseline=38 final=38 new=0 cleared=0`. The P3-T12 manifest-membership line no longer fails.

## SET-WRR

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution
EXIT_CODE: 0
Output Summary: TotalCount=254 PassedCount=254 FailedCount=0 FailedContainersCount=0 (empty FAILED set, a subset of the empty baseline set)

## SET-GUARD

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path <the ten SET-GUARD files>
EXIT_CODE: 0
Output Summary: TotalCount=166 PassedCount=166 FailedCount=0 FailedContainersCount=0 (empty FAILED set, a subset of the empty baseline set)

## SET-FULL (run in the background)

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path scripts,tests/scripts
EXIT_CODE: 0
Output Summary:
TotalCount=7659
PassedCount=7609
FailedCount=40
FailedContainersCount=0

- TotalCount is BASE_FULL_TOTAL 7596 + 63 (S1 14, S2 12, S3 12, S4 20, S5 7, minus the 2 rows removed from T-MAIN).
- `SCRATCH/failed-set-compare.ps1` against the P0-T24 output printed `FAILED-SET baseline=40 final=40 new=0 cleared=0`. The FAILED set is a subset of (equal to) the baseline set, so the re-run rule is not triggered.
- Classification: 38 KL-ADOPT lines (file `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`) and 2 KL-HERMETIC lines present in the baseline set (files `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`). No FAILED line has a missing, ambiguous, or UNKNOWN file, and no FAILED line has a PLAN-TEST-FILES member as its file.
- `FailedContainersCount=0`.

Recorded for P6-T21: SET-FULL TotalCount=7659, FailedCount=40.

Result: PASS (every P6-T6 condition is met).

## Verbatim SET-FULL FAILED and FAILED-FILE lines

FailedContainersCount=0
FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving potential_to_issue alone
FAILED: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving the feature entry tool with a record
FAILED: Issue adoption accepts valid records (AC-6).accepts a bug checkpoint waiving the bug entry tool with a record
FAILED: Issue adoption accepts valid records (AC-6).accepts the same record on the preparation route
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value transferred
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value filed_before_orchestration
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value epic_decomposition
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_issue_view
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_api_get
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source github_mcp_issue_read
FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind string
FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind integer
FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind list
FAILED: Issue adoption rejects malformed records (AC-7).rejects a null adoption value
FAILED: Issue adoption rejects malformed records (AC-7).rejects an integer issue number
FAILED: Issue adoption rejects malformed records (AC-7).rejects a leading-zero issue number
FAILED: Issue adoption rejects malformed records (AC-7).rejects an issue number that differs from the checkpoint issue-num
FAILED: Issue adoption rejects malformed records (AC-7).rejects an issue URL that does not end with the issue number
FAILED: Issue adoption rejects malformed records (AC-7).rejects an unknown origin
FAILED: Issue adoption rejects malformed records (AC-7).rejects an unknown verification source
FAILED: Issue adoption rejects malformed records (AC-7).rejects an absent verification time
FAILED: Issue adoption rejects malformed records (AC-7).rejects a null verification time
FAILED: Issue adoption rejects malformed records (AC-7).rejects a whitespace-only verification time
FAILED: Issue adoption rejects malformed records (AC-7).rejects empty evidence
FAILED: Issue adoption rejects malformed records (AC-7).rejects an empty waived list
FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind string
FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind blank-entry
FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind integer-entry
FAILED: Issue adoption rejects malformed records (AC-7).rejects a waived list that omits the issue-creation tool
FAILED: Issue adoption rejects malformed records (AC-7).rejects an invalid potential record when waiving the entry tool
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature-folder tool
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the artifact-validation tool
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature entry tool on a bug checkpoint
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects any waiver on the remediation route
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving a tool that holds a successful receipt
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects a tool listed twice
FAILED: Issue adoption fails closed and is presence gated (AC-9, AC-11).empties the waived set whenever any error is reported across a fixed grid
FAILED: Issue adoption fails closed and is presence gated (AC-9, AC-11).yields no errors and no waivers for a checkpoint without the adoption key
FAILED: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving potential_to_issue alone
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving the feature entry tool with a record
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts a bug checkpoint waiving the bug entry tool with a record
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts the same record on the preparation route
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts the documented origin value transferred
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts the documented origin value filed_before_orchestration
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts the documented origin value epic_decomposition
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_issue_view
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_api_get
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption accepts valid records (AC-6).accepts the documented verification source github_mcp_issue_read
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind string
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind integer
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind list
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a null adoption value
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an integer issue number
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a leading-zero issue number
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an issue number that differs from the checkpoint issue-num
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an issue URL that does not end with the issue number
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an unknown origin
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an unknown verification source
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an absent verification time
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a null verification time
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a whitespace-only verification time
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects empty evidence
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an empty waived list
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind string
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind blank-entry
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind integer-entry
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects a waived list that omits the issue-creation tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption rejects malformed records (AC-7).rejects an invalid potential record when waiving the entry tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature-folder tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption enforces the closed waivable set (AC-8).rejects waiving the artifact-validation tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature entry tool on a bug checkpoint
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption enforces the closed waivable set (AC-8).rejects any waiver on the remediation route
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption enforces the closed waivable set (AC-8).rejects waiving a tool that holds a successful receipt
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption enforces the closed waivable set (AC-8).rejects a tool listed twice
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption fails closed and is presence gated (AC-9, AC-11).empties the waived set whenever any error is reported across a fixed grid
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | Issue adoption fails closed and is presence gated (AC-9, AC-11).yields no errors and no waivers for a checkpoint without the adoption key
FAILED-FILE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
