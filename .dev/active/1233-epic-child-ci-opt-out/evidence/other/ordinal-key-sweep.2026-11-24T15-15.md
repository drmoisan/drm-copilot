# Ordinal key sweep of the PowerShell reads added by #1233 (P1-T1)

Timestamp: 2026-11-24T15-15
Command: sh SCRATCH/issue-1233-r1-sweep.sh (git diff -U0 origin/main...HEAD -- '.claude/*.ps1' '.claude/*.psm1' '.codex/*.ps1' '.codex/*.psm1', added lines only, filtered to lines holding Get-CheckpointObjectMember, Get-CheckpointObjectOrdinalMember, Get-MissingGateKey, Get-EpicMergeGateChildCiProperty, PSObject.Properties, or a member access on a parsed checkpoint variable; the added call sites Get-EpicMergeGateLastReviewOutcome and Test-EpicMergeGateReviewModeConcurrent and the $gate.$field read are added by reading the same added hunks)
EXIT_CODE: 0
Output Summary:
- 35 reads (twin and bundle copies of a byte-identical file counted once): fixed in P1-T2: 6; fixed in P1-T3: 15; already ordinal: 11; pre-#1233 or not a key read, out of scope: 3.
- Matches the plan's expectation; no read outside it. No tracked file changed (git status --porcelain listed only untracked evidence and the plan file before and after).

## Rows

| # | File | Function | Key | Accessor | Ordinal | Disposition |
|---|---|---|---|---|---|---|
| 1 | .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | Test-OrchestratorStateChildCiIntegrationOnly | epic_mode | Get-CheckpointObjectOrdinalMember | yes | already ordinal |
| 2 | same | Test-OrchestratorStateChildCiIntegrationOnly | child_ci | Get-CheckpointObjectOrdinalMember | yes | already ordinal |
| 3 | same | Get-OrchestratorStateCompletionLocalQcGateError | local_qc_gate | Get-CheckpointObjectOrdinalMember | yes | already ordinal |
| 4 | same | Get-OrchestratorStateCompletionLocalQcGateError | LOCAL_QC_GATE_KEYS presence | Get-MissingGateKey (Get-CheckpointObjectMember) | no | fixed in P1-T2 |
| 5 | same | Get-OrchestratorStateCompletionLocalQcGateError | conclusion | Get-CheckpointObjectMember | no | fixed in P1-T2 |
| 6 | same | Get-OrchestratorStateCompletionLocalQcGateError | review_mode | Get-CheckpointObjectOrdinalMember | yes | already ordinal |
| 7 | same | Get-OrchestratorStateCompletionLocalQcGateError | remediation_loop | Get-CheckpointObjectMember | no | fixed in P1-T2 |
| 8 | same | Get-OrchestratorStateCompletionLocalQcGateError | review_outcomes | Get-CheckpointObjectMember | no | fixed in P1-T2 |
| 9 | same | Get-OrchestratorStateCompletionLocalQcGateError | head_sha (last outcome) | Get-CheckpointObjectMember | no | fixed in P1-T2 |
| 10 | same | Get-OrchestratorStateCompletionLocalQcGateError | head_sha (gate) | Get-CheckpointObjectMember | no | fixed in P1-T2 |
| 11 | same | Get-OrchestratorStateCompletionCiGateError | ci_gate | Get-CheckpointObjectMember | no | pre-#1233 and out of scope (only the spacing changed; restored in P1-T2) |
| 12 | .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 (and its twin and bundles) | Test-EpicMergeGateChildCiOptOut | epic_mode | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 13 | same | Test-EpicMergeGateChildCiOptOut | child_ci | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 14 | same | Test-EpicMergeGateChildCiOptOut | epic_context | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 15 | same | Test-EpicMergeGateChildCiOptOut | integration_branch | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 16 | same | Get-EpicMergeGateChildCiLivePullRequest | headRefOid (gh JSON) | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 17 | same | Get-EpicMergeGateChildCiLivePullRequest | baseRefName (gh JSON) | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 18 | same | Get-EpicMergeGateChildLocalQcResult | epic_context | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 19 | same | Get-EpicMergeGateChildLocalQcResult | integration_branch | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 20 | same | Get-EpicMergeGateChildLocalQcResult | local_qc_gate | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 21 | same | Get-EpicMergeGateChildLocalQcResult | conclusion | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 22 | same | Get-EpicMergeGateChildLocalQcResult | head_sha (gate) | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 23 | same | Get-EpicMergeGateChildLocalQcResult | feature-folder | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 24 | same | Get-EpicMergeGateChildLocalQcResult | evidence_path | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 25 | same | Get-EpicMergeGateChildLocalQcResult (stage L2 call) | remediation_loop, review_outcomes | Get-EpicMergeGateLastReviewOutcome (member access) | no | fixed in P1-T3 |
| 26 | same | Get-EpicMergeGateChildLocalQcResult | head_sha (last outcome) | Get-EpicMergeGateChildCiProperty | no | fixed in P1-T3 |
| 27 | same | Get-EpicMergeGateChildLocalQcResult (stage R call) | review_mode | Test-EpicMergeGateReviewModeConcurrent (-cnotcontains on property names) | yes | already ordinal |
| 28 | same | Get-EpicMergeGateChildCiFailureDetail | PrNumber | member access on the internal ordered result of Get-EpicMergeGateChildCiPrNumber | n/a | not a checkpoint or gh JSON key; out of scope |
| 29 | same | Get-EpicMergeGateChildCiFailureDetail (stage 3 reuse line) | PrNumber | same | n/a | not a checkpoint or gh JSON key; out of scope |
| 30 | .claude/hooks/enforce-completion-helpers.ps1 (and its twin and bundles) | Test-CompletionChildCiIntegrationOnly | property names | PSObject.Properties.Name with -cnotcontains | yes | already ordinal |
| 31 | same | Test-CompletionChildCiIntegrationOnly | epic_mode | member access after the ordinal presence guard | yes | already ordinal (pinned by P1-T4) |
| 32 | same | Test-CompletionChildCiIntegrationOnly | child_ci | member access after the ordinal presence guard | yes | already ordinal (pinned by P1-T4) |
| 33 | same | Get-CompletionLocalQcGateMissing | local_qc_gate | -ccontains guard, then member access | yes | already ordinal (pinned by P1-T4) |
| 34 | same | Get-CompletionLocalQcGateMissing | conclusion | -ccontains guard, then member access | yes | already ordinal (pinned by P1-T4) |
| 35 | same | Get-CompletionLocalQcGateMissing | head_sha, evidence_path | -ccontains guard, then $gate.$field | yes | already ordinal (pinned by P1-T4) |

The two completion-consistency hooks add only calls to rows 30 to 35 and read no #1233 key themselves.
