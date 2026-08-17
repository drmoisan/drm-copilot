# PowerShell Branch-Coverage One-Time Exception Runbook

## Cue

Apply this runbook only when the issue #467 orchestration checkpoint records the exact user instruction `Please enable a one-time exception for the branch requirement and continue`, dated 2026-08-16. The exception applies only to the PowerShell branch-coverage requirement for issue #467 on `feature/codex-native-parallel-orchestration-467`.

The triggering measurement remains factual and unchanged: `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`, source-attributable PowerShell branch coverage is `0/0`, and no measured result demonstrates the repository's 75% branch threshold. The exception changes only the compliance disposition for that unavailable measurement; it does not create a branch percentage or change repository policy.

## Prerequisites

- The canonical issue is #467 and the active feature folder is `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`.
- The current delivery branch is `feature/codex-native-parallel-orchestration-467`.
- The checkpoint preserves the exact authorization text and records this runbook in `human_interaction.requirements[]` with `response: exception`.
- The existing branch-capability inventory, deterministic probes, and fail-closed decision remain available under the feature's canonical `evidence/` folders.
- PowerShell tests remain mandatory. The retained baseline is 2,456 total tests, 2,447 passed, 9 disabled, and zero failures or errors.
- PowerShell line coverage remains mandatory. The retained measurement is 4,040 covered lines out of 4,260, or 94.835681%.
- Formatting, analysis, owner coverage, all non-PowerShell language gates, acceptance criteria unrelated to raw PowerShell branch coverage, full feature review, hosted CI, and checkpoint validation remain mandatory.
- No policy file, threshold, exclusion, suppression, dependency, or synthetic coverage calculation may be changed to implement this exception.

## Step-by-step Instructions

1. Verify that the checkpoint, active branch, feature folder, and all artifact paths identify issue #467. Stop if the exception is being applied to another issue, branch, feature, or delivery.
2. Verify the recorded evidence still states `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO` and reports source-attributable PowerShell branch numerator and denominator as `0/0`. Do not convert the absent denominator into 0%, 100%, or any synthetic percentage.
3. Verify that `artifacts/orchestration/orchestrator-state.json` contains one requirement for this authorization with `response: exception`, the exact user instruction, authorization date `2026-08-16`, and this runbook's repository-relative path.
4. Treat only the raw PowerShell branch-coverage requirement as satisfied by an authorized one-time compliance disposition. In every plan, QA receipt, audit, and status report, distinguish `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE` from `COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED`.
5. Execute every retained gate without waiver: PowerShell formatting, analysis, tests, line coverage, owner coverage, required non-PowerShell toolchains, acceptance-criteria verification, full feature review, hosted CI, and checkpoint validation.
6. Require the full feature review to evaluate the complete feature diff against the resolved base branch. A review may return `REVIEW_STATUS: PASS` under this exception only when the raw `0/0` result is disclosed, the exception is cited, and no other blocker or unmet acceptance criterion remains.
7. Expire the exception when issue #467's current delivery is merged, closed, abandoned, replaced, or moved to another branch or issue. Do not copy, generalize, or reuse it for another issue, feature, pull request, coverage type, threshold, or delivery.
8. If the authorization is withdrawn, the scope changes, or any prerequisite becomes false, roll back the exception disposition by restoring `POWERSHELL_BRANCH_POLICY_UNRESOLVED` as a blocking review result. Do not alter the historical authorization record or the raw `0/0` evidence.

## Verification

1. Confirm this file exists at `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/runbooks/powershell-branch-coverage-one-time-exception.runbook.md` and contains the five required sections in the required order.
2. Validate `artifacts/orchestration/orchestrator-state.json` with the repository-local strict topology/model validator and the authoritative MCP validator. Preserve the known historical MCP `commit-steward` incompatibility as a separate checkpoint-validation blocker; do not report it as passed.
3. Confirm the latest PowerShell QA evidence reports zero test failures or errors and line coverage of 4,040/4,260 (94.835681%).
4. Confirm every audit and review records both `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE` and `COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED`, without claiming a measured branch PASS.
5. Confirm the latest full feature review has no blocker other than the excepted raw PowerShell branch measurement before advancing to PR or CI gates.
6. Confirm the exception is not referenced outside issue #467's feature folder, checkpoint record, delivery artifacts, and PR context.

## Source and Citation

- Issue authorization and delivery scope: [drm-copilot issue #467](https://github.com/drmoisan/drm-copilot/issues/467), captured 2026-08-16.
- Pester's current code-coverage documentation describes command/line-oriented coverage, configuration, reports, and targets: [Generating Code Coverage Metrics](https://pester.dev/docs/usage/code-coverage), captured 2026-08-16.
- Repository exception contract: [human-exception-runbook skill](../../../../../.agents/skills/human-exception-runbook/SKILL.md), captured 2026-08-16.
- Repository coverage and evidence contract: [atomic-plan-contract skill](../../../../../.agents/skills/atomic-plan-contract/SKILL.md), captured 2026-08-16.

`updated_at: 2026-08-16`
