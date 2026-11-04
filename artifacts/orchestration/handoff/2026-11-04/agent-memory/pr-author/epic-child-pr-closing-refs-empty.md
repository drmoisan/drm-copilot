---
name: epic-child-pr-closing-refs-empty
description: Epic-child PRs whose base is an epic integration branch return closingIssuesReferences [] even with a correct "- Closes #NNN" line
metadata:
  type: project
---

On an epic-child PR (base `epic/<slug>-integration`, not `main`), `gh pr view <N> --json closingIssuesReferences,body` returns `closingIssuesReferences: []` even when the body has a correct `- Closes #NNN` bullet. Observed on PR #1076 (issue #1033, base `epic/documentation-estate-tooling-integration`) on 2026-11-04.

**Why:** GitHub links closing keywords only for PRs that target the default branch. This is not a body-format defect.

**How to apply:** Report the empty list as a mismatch and name the non-default base as the probable cause. Do not edit the body to fix it. The issue closes later through the epic integration PR into `main` or by manual close.
