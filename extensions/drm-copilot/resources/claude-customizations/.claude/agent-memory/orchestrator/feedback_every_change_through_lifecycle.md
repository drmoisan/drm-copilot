---
name: every-change-through-lifecycle
description: Every change, including small tooling changes, goes through issue promotion, an active feature folder, and feature-review before commit; evidence lives only under the active feature folder.
metadata:
  type: feedback
  scope: general
---

Every change — including small tooling changes to hooks, skills, rules, or scripts — must go through the full orchestration lifecycle: open an issue (via MCP promotion), create the active feature folder, and pass feature-review before committing. "It's just a small change" is not an exemption.

Evidence may be written ONLY under the active feature folder at `docs/features/active/<date>-<short>-<issue>/evidence/<kind>/`. Any other location (including paths that are not in the forbidden list) is not approved.

**Why:** Bypassing the lifecycle produces changes with no feature folder, which causes engineers to place evidence in unapproved locations and creates review failures requiring full remediation.

**How to apply:** Before any implementation delegation, run promotion (new potential entry -> potential-to-issue -> new active feature folder). Pass the resulting feature folder's `evidence/<kind>/` path as the only permitted evidence sink.
