---
name: orchestrator-memory-index
description: Index of orchestrator agent memories.
metadata:
  type: index
  scope: repo
---

- [Policy requirements are not optional gaps](feedback_policy_compliance_not_optional.md) — never frame skipped policy requirements as "known gaps" or defer them; comply before reporting completion.
- [test-files-count-against-500-cap](feedback_test_files_count_against_500_cap.md) — the 500-line file cap applies to test files too; QA must scan changed/created production AND test files.
- [every-change-through-lifecycle](feedback_every_change_through_lifecycle.md) — every change, including small tooling changes, goes through issue promotion, an active feature folder, and feature-review before commit.
- [remediation-plan-em-dash-required](feedback_remediation_plan_em_dash_required.md) — the plan validator rejects any token between "Phase N" and the em-dash; only `### Phase N — <Title>` passes.
- [branch-base-check-unmerged-pr-deps](feedback_branch_base_check_unmerged_pr_deps.md) — verify required symbols/files exist on the chosen branch base; if they only exist in an open PR, stack or merge first.
- [potential-to-issue-creates-github-issue](feedback_potential_to_issue_creates_github_issue.md) — potential-to-issue creates the GitHub issue as a side effect; do not also run gh issue create.
- [small-bug-uses-minor-audit](feedback_small_bug_uses_minor_audit.md) — a ~1-3 production-file bug fix uses the small path with Work Mode minor-audit, not full-bug.
- [commit-and-push-agent-memory-before-pr](feedback_commit_push_memory_before_pr.md) — commit/push .claude/agent-memory/ changes before opening the PR, and again before merge if the CI/remediation cycle adds more.
