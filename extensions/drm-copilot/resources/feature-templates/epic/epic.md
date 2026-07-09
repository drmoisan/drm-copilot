---
# Epic manifest (source of truth).
#
# This YAML frontmatter is the machine-readable manifest for the epic: the
# dependency DAG (parsed deterministically by the epic-orchestrator agent) and an
# optional SAFe-style intent block. The Markdown body below the frontmatter is the
# single human-authored narrative and is not machine-parsed.
#
# The DAG is keyed by stable `issue_num`. `feature_folder` is a resolvable hint
# that may point into docs/features/active/<folder> OR docs/features/completed/<folder>;
# it is not a stable identifier and changes when a child is promoted.
epic: <epic-slug>
integration_branch: epic/<epic-slug>-integration
created_at: <iso8601>

# Optional additive SAFe-style intent block. Omit the whole `intent` block when
# not used; when present, `epic_type` and `business_outcome_hypothesis` are
# required, and `leading_indicators` / `nfrs` are optional lists of strings.
intent:
  epic_type: <business | enabler>
  business_outcome_hypothesis: <the measurable outcome this epic is expected to move>
  leading_indicators:
    - <early signal that the hypothesis is being validated>
  nfrs:
    - <non-functional requirement the epic must satisfy>

# Manifest DAG. Primary key is `issue_num`. `depends_on` lists the `issue_num`
# values of upstream siblings (each must be another entry in `features[]`).
features:
  - issue_num: <int>
    feature_folder: <resolvable-hint-basename>
    depends_on: []
  - issue_num: <int>
    feature_folder: <resolvable-hint-basename>
    depends_on: [<upstream-issue_num>]
---

# <epic-name> - Epic

- Issue: #<tracking-issue>
- Owner: <name>
- Last Updated: YYYY-MM-DD

## Goal

State the epic objective and the measurable outcomes. Keep it user/impact
oriented, not implementation detail. This is the source from which the epic
GitHub issue body is generated.

## Scope

Enumerate what is in scope for this epic. Reference the child features by their
`issue_num` so the narrative and the manifest DAG stay aligned.

## Non-Goals

List what is explicitly out of scope so child features and reviewers do not
scope-creep into adjacent work.

## Shared Design

Capture the cross-cutting design decisions every child feature must honor:

- Shared behaviors/algorithms that must stay aligned across children.
- Determinism/performance/compatibility guarantees.
- Data/artifact locations, formats, or tooling expectations.
- Quality gates (tests/lint/type-checks) required across all children.

## Decomposition

Describe the child features and their ordering. Each child keeps its own git
branch/worktree and its own independent active/ -> completed/ lifecycle; this
section is the human-readable projection of the `features[]` DAG above.

- <Child feature A> (Issue #<id>) - wave 0
- <Child feature B> (Issue #<id>) - depends on #<id>

`epic-status.md` in this same directory is a generated projection of the epic
checkpoint; it is never the source of the DAG and is never hand-authored.
