---
name: feature-promotion-lifecycle
description: Deterministic promotion workflow from potential feature/bug entry to issue, branch, active feature folder, and downstream spec/research handoffs.
---

# Feature Promotion Lifecycle

Canonical variable model and command sequence for promoting potential feature/bug entries and initializing active feature delivery.

## When to Use This Skill

Use this skill when:
- A large-scope change requires feature/bug promotion workflow.
- An orchestrator must create potential docs, promote to issue, branch, and active feature folder.
- Downstream research/spec agents depend on deterministic paths and identifiers.

## Canonical Variables

- `${promotion-type}`: `feature` or `bug`
- `${short-name}`: lowercase slug, hyphen-separated
- `${relativeFile}`: workspace-relative path to created potential entry markdown
- `${long-name}`: `${relativeFile}` filename without `.md`
- `${issue-num}`: promoted GitHub issue number
- `${feature-folder}`: active feature folder path

## Canonical Command Sequence

1) Create potential entry by type:
- feature: `${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1 -ShortName ${short-name}`
- bug: `${workspaceFolder}/scripts/dev_tools/new_potential_bug_entry.py --short-name ${short-name}`

2) Promote potential doc:
- `poetry run python -m scripts.dev_tools.potential_to_issue --potential-path ${relativeFile} --promotion-type ${promotion-type}`

3) Create branch:
- `${promotion-type}/${short-name}-${issue-num}`

4) Create active feature folder:
- `poetry run python -m scripts.dev_tools.new_active_feature_folder --feature-name ${long-name} --type ${promotion-type} --issue-number ${issue-num}`

## Required Outputs for Downstream Handoffs

Before delegating research/spec/planning, provide:
- `${feature-folder}/issue.md`
- `${feature-folder}/spec.md` (or expected target path)
- `${feature-folder}/user-story.md` (or explicit `NONE`)
- latest research artifact path(s)
- constraints/APIs/invariants to preserve
