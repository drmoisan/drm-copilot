# Task Check P3-T1

Timestamp: 2026-11-24T08-08
Command: grep -c over the three sources for `RELEASE_MERGE_`, `Get-EpicMergeGateReleaseDecision`, and the AC-35 tokens (absolute-path reads)
EXIT_CODE: 0
Output Summary:
- Changed files: `scripts/harness-generation/sources/rules/orchestrator-state.md` (`## Release-Commit Allowance Scope`: the not-covered sentence replaced by a release merge leg paragraph naming `Get-EpicMergeGateReleaseDecision`, both gates, the seventeen `RELEASE_MERGE_*` codes, the required `--match-head-commit`, the CI rule, and the policy-level-control disclosure); `.agents/skills/execution-environment/SKILL.md` (the #1231 bullet now points to the merge leg; new `Release merge leg (#1234)` bullet in `## Hook Execution Context`; `release-merge.Parity.Tests.ps1` added to `## Contract Tests That Pin Mirrored Files`); `.agents/skills/pr-author/SKILL.md` (the not-covered sentence of `## Checkpoint-Free Release Delegation (issue #1231)` replaced by a pointer to the merge leg; heading kept).
- The rule and pr-author edits were first written at 2026-11-24T07-4x, during the P2-T5 gate, out of order; they were set aside under SCRATCH/p3t1-stash/, the files restored for the P2-T5 re-run, and re-applied byte-identically here.
- Selection rule: a Markdown source change; its contract tests are the generator check and parity suites, which the plan runs in P3-T2 after regeneration (the generated copies are stale until then).
- Results: each source has `RELEASE_MERGE_` >= 1 and `Get-EpicMergeGateReleaseDecision` >= 1; the rule source still carries `RELEASE_EXEMPTION_`, `RELEASE_DELEGATION_`, `RELEASE_RECEIPT_`, `policy-level control` (7), and `destination-owned`; the pr-author heading is present once.
