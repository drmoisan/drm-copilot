---
name: epic-integration-pr-gate-gap
description: The epic integration-to-main PR cannot pass enforce-pr-author-skill.ps1, because that gate reads orchestrator-state.json and its epic-mode check would force the integration branch as the base; escalate rather than fabricate a checkpoint.
metadata:
  type: project
---

The documented epic completion path cannot execute as designed. `.claude/skills/epic-orchestrate/SKILL.md`
says `epic-orchestrator` drives the final integration-to-`main` PR by delegating to
`Agent(pr-author)`. But `.claude/hooks/enforce-pr-author-skill.ps1` hardcodes
`artifacts/orchestration/orchestrator-state.json` and runs single-feature PR-creation-readiness
validation against it. It never reads `artifacts/orchestration/epic-orchestrator-state.json`, which is
where the epic's actual state lives. So `gh pr create` for the integration PR is denied with
`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`.

**Why you must not clear it by writing a checkpoint.** Two independent reasons:

1. Passing requires asserting the ~17 `REQUIRED_STATE_KEYS` of a single-feature workflow
   (`change_budget_estimate`, `step5_status` through `step8_status`, and so on) that an epic
   integration merge never performed in that shape. Filling them to open a gate is fabrication
   regardless of who holds the write permission.
2. Worse, the gate's check 6 keys off `epic_mode`. With `epic_mode: true` and
   `epic_context.integration_branch` set, it *requires* `--base <integration_branch>` — which is
   exactly wrong for this PR, whose base is `main`. To pass, you would have to record `epic_mode` as
   absent or false while it is true. That is not a workaround, it is falsifying the one field the gate
   uses to reason about epic runs.

**Why:** On 2026-08-09 the `parallel-orchestration` epic reached this point with all nine child
features merged. `pr-author` authored the body and receipt, dry-ran the hook, hit the deny, and
refused to repair the checkpoint on exactly this reasoning — correctly. The stale
`orchestrator-state.json` in the main checkout still held an unrelated **aborted duplicate** record
from 2026-08-07 (`blocked_reason: aborted_duplicate_run_superseded_by_issue_447`), so clearing the
gate would also have meant destroying another run's audit trail.

**How to apply:**
- Treat this as a contract gap between the epic skill and the hook, and escalate it to the human with
  concrete options. Do not improvise past it.
- The `pr-author` output is still valuable: the body and receipt are written to
  `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json` and remain reusable **provided
  the PR-context bundle is not refreshed**. If the bundle is refreshed, the receipt needs a newer
  `created_at`. If the real PR number differs from the predicted `<N>`, both files must be renamed
  before any `gh pr edit --body-file`.
- The cleanest immediate unblock is for the human to open the PR with the already-authored body.
- The proper fix is to teach the hook to read `epic-orchestrator-state.json` when the head ref is an
  epic integration branch, and to make check 6 expect `main` for that case.
- Related: [[layer1-pretooluse-gates-may-be-inert]]. This gate enforced; another did not.
