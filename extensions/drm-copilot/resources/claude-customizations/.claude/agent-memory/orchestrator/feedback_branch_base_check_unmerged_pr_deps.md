---
name: branch-base-check-unmerged-pr-deps
description: Before choosing a branch base, verify the plan's required symbols and files exist on that base; if they only exist in an open PR, stack on it or merge it first.
metadata:
  type: feedback
  scope: general
---

Before choosing a branch base for a new feature, verify that the symbols and files the plan relies on exist on that base. If they only exist in an open PR, either (a) base on that PR's branch (stack), or (b) recommend merging it first.

Check existence with: `git cat-file -e origin/main:<file>`
Check file overlap with: `git diff --name-only origin/main...<branch>`

**Why:** Branching off the default branch when a required symbol only exists in an unmerged PR forces the implementation to use a fallback or stub, which the reviewer will catch.

**How to apply:** At orchestration start-up, when the plan references files or modules that appear to be part of a separate ongoing feature, run the cat-file check before setting the branch base in the orchestrator state.
