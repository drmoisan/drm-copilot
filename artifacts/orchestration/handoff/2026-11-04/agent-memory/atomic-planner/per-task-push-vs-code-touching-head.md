---
name: per-task-push-vs-code-touching-head
description: Reconciling "commit+push after every task" with "final PR head must be a code-touching commit" when the plan must end with a docs-only self-review task
metadata:
  type: feedback
---

When the owner requires a commit and push after every task (Codespace may stop) and also a code-touching final PR head, the self-review task (always last) would otherwise produce a docs-only head commit. Resolution used for #1080 (2026-11-04): fold a small genuine code edit (a `.NOTES` help section) into the self-review task, re-run format/PSSA/new suites in that task, and commit the script and self-review together; assert `git diff --name-only HEAD~1 HEAD` lists the script plus `git status --porcelain` empty.

**Why:** a docs-only head skips heavy CI under the change-scope rule; the owner wants the final head to run CI in full, and all AC check-offs must precede that last code commit.
**How to apply:** check off ACs in the task before the self-review; never plan a CI-dependent AC check-off after the last code commit. Also avoid asserting zero matches for write-cmdlet names in a test file whose own constraint test lists them as data (see [[plan-literal-collisions]]).
