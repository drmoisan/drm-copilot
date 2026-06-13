---
name: small-bug-uses-minor-audit
description: A bug fix of roughly 1-3 production files uses the small path with Work Mode minor-audit, not full-bug; requirements and acceptance criteria live in issue.md.
metadata:
  type: feedback
  scope: general
---

A bug fix whose scope is roughly 1-3 production files must be delivered on the small path with Work Mode `minor-audit`, not `full-bug`. On the small path there is no `spec.md`; requirements (summary, repro, scope, test strategy, and acceptance criteria) live in `issue.md`. The feature-review agent in minor-audit mode reads the `## Acceptance Criteria` section of `issue.md` as the AC source.

**Why:** Using the full-bug path for a small change requires `spec.md`, adds unnecessary overhead, and risks marking a change done without on-disk audit artifacts.

**How to apply:** At change-budget routing, if a bug impacts only 1-3 production files, select small path + minor-audit. Confirm `issue.md` carries an explicit `## Acceptance Criteria` section before delegating to feature-review. Do not create `spec.md` for small-path bugs.
