---
name: potential-to-issue-creates-github-issue
description: The potential-to-issue MCP tool creates the GitHub issue as a side effect; do not also run gh issue create, which produces a duplicate.
metadata:
  type: feedback
  scope: general
---

The `potential_to_issue` MCP tool creates the GitHub issue as a side effect and returns a summary. The generated `issue.md` already carries the correct `Issue: #N` and `Issue URL` lines. Do NOT run `gh issue create` after `potential_to_issue` — it creates a duplicate issue.

**Why:** Running `gh issue create` after the MCP promotion step produces two issues for the same work item.

**How to apply:** After `potential_to_issue`, read the generated `issue.md` to get the assigned number. Pass that same number to the new-active-feature-folder step via the issue number. If the folder number and the tooling-created GitHub issue number disagree, align to the GitHub number.
