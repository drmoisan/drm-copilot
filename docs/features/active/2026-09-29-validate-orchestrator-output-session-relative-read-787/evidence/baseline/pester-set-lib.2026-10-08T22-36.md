# Pester Baseline, SET-LIB (P0-T22)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/orchestrator-state
EXIT_CODE: 0
Output Summary:
TotalCount=774
PassedCount=736
FailedCount=38
FailedContainersCount=0

BASE_LIB_TOTAL=774

Classification: all 38 `FAILED:` lines begin "FAILED: Issue adoption " and are KL-ADOPT lines (docs/features/potential/2026-10-01-issue-adoption-pester-folder-scoped-command-not-found.md). Each has exactly one matching `FAILED-FILE:` line naming `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` (no missing, ambiguous, or UNKNOWN attribution). KL-ADOPT count: 38. No non-KL-ADOPT failure, so no BASELINE-RED and no A2-FILE-ATTRIBUTION stop.

The SET-LIB baseline failure set is the 38 `FAILED:` lines below (verbatim from A2 output).

## Verbatim FAILED and FAILED-FILE lines

FailedContainersCount=0
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
