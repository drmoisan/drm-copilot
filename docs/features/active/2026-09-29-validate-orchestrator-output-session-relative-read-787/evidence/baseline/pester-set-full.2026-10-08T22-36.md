# Pester Baseline, SET-FULL (P0-T24, second part)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path scripts,tests/scripts (run in the background)
EXIT_CODE: 0
Output Summary:
TotalCount=7596
PassedCount=7546
FailedCount=40
FailedContainersCount=0

BASE_FULL_TOTAL=7596

`FailedContainersCount=` line (verbatim): `FailedContainersCount=0`

## Classification of the 40 FAILED: lines

Every `FAILED:` line has exactly one `FAILED-FILE:` line with the same expanded path; no file is missing, ambiguous, or UNKNOWN.

- KL-ADOPT: 38 lines. Each begins "FAILED: Issue adoption " and its file is `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`.
- KL-HERMETIC: 2 lines. Each file is under `tests/scripts/codex-hooks/` or `tests/scripts/claude-hooks/`, is not a PLAN-TEST-FILES member, and is not UNKNOWN:
  1. `FAILED: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` (file `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`; the instance the plan names).
  2. `FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (file `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`). This suite reads the local orchestration checkpoint, which this run holds at route_id large for issue 787 (P0-T8), consistent with the KL-HERMETIC class tracked by #737.
- Other: 0 lines.

KL-ADOPT count: 38. KL-HERMETIC count: 2.

No line is classified as other, no file attribution is missing or ambiguous, and FailedContainersCount is 0, so no BASELINE-RED or A2-FILE-ATTRIBUTION stop applies. The SET-FULL baseline failure set is the 40 `FAILED:` lines below.

## Verbatim FAILED and FAILED-FILE lines

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
