---
name: green-ci-merge-must-be-unchained
description: The S9 green-CI standalone merge is denied with a misleading STANDALONE_MERGE_AUTHORIZATION_ABSENT when gh pr merge shares a command line with anything else
metadata:
  type: feedback
---

Issue `gh pr merge <N> --merge --match-head-commit <sha>` as the only command in its Bash call. A command such as `gh pr view ...; gh pr merge ...` fails green-CI condition 1 (single structural `gh pr merge`, no chain) in `.claude/hooks/enforce-epic-merge-gate.ps1`, and the hook then reports `STANDALONE_MERGE_AUTHORIZATION_ABSENT`, which points at writing an authorization record instead of the real cause.

**Why:** observed 2026-11-03 on PR #1065 (issue #1026). The checkpoint already satisfied every green-CI condition; the unchained retry merged without any authorization record.

**How to apply:** at S9 step 7, read the live head in one call, then merge in a separate call. Do not write a `standalone_merge_authorizations` record in response to that denial until you have ruled out a chained command.
