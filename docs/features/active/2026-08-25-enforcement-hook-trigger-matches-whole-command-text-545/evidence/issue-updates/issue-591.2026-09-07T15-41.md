# [P11-T7] Issue #591 supersession record

Timestamp: 2026-09-07T15-41

PostedAs: unknown

Command: not applicable — this task composes the update text and mirrors it locally; it invokes no command.

EXIT_CODE: 0

## POSTING BLOCKED

The text below was not posted to GitHub during this execution. Reason: this delegation is scoped to Phase 11 and the non-coverage tasks of Phase 12, and issue-posting is not part of that scope. The task requires the artifact to carry `Timestamp:`, the exact text intended for posting, and a `PostedAs:` value; `unknown` is recorded because no post has been made and no comment URL exists. Posting, if it happens, is performed by the orchestrator at merge time.

## Exact text intended for posting

> **Superseded by issue #545.**
>
> This issue (#591) is superseded by issue #545, `enforcement-hook-trigger-matches-whole-command-text`.
>
> The defect recorded here — the epic merge gate mis-parsing its PR-number operand, so that a relocated or wrapper-led `gh pr merge` line yields the wrong operand or no operand at all — is delivered as part of the issue #545 change rather than separately. Issue #545 replaces the whole-command-text matching in the affected enforcement hooks with a shared segment-and-token parser, and the merge-gate operand extraction is rebuilt on that parser. The acceptance case pinning the behaviour is AT-2, which drives `Get-EpicMergeGateCommandPrNumber` with `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688` and asserts `688`, together with the paired negatives asserting that `gh pr merge --merge` returns `$null` and `gh pr merge 410 --merge` returns `410`.
>
> Issue #545 additionally covers the five other hooks that shared the same over-match and under-match root cause, so no separate follow-up is filed for them.
>
> Action requested: close #591 as superseded when the issue #545 work merges. No separate fix, branch, or PR is required for #591.
>
> References:
> - Issue #545: https://github.com/drmoisan/drm-copilot/issues/545
> - Issue #591: https://github.com/drmoisan/drm-copilot/issues/591
> - Specification: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
> - Plan: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md`

## Output Summary

The supersession text is composed and mirrored locally. It names issue #591 and issue #545 explicitly, states that the merge-gate operand mis-parse is delivered in the issue #545 change, and requests that #591 be closed as superseded when this work merges. `PostedAs:` is `unknown` because no GitHub post was made from this execution; a `POSTING BLOCKED` header and its reason are recorded above.

Because `PostedAs:` is not `body`, no mirroring into the feature `issue.md` is required by the evidence conventions.
