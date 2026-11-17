# Gold Standard: research-issue

## Objective

Investigate the best implementation approach for a feature or bug by analyzing the codebase and external references, then writing structured findings to the applicable tracked research folder. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill accepts one or more feature documents as context, `docs/features/active/<feature>/issue.md` as the primary document and `docs/features/active/<feature>/user-story.md` and `docs/features/active/<feature>/spec.md` when present.
- **OB-2** Output: The skill creates or updates a single research file in the applicable tracked research root, at the feature-associated path `docs/features/<feature>/research/<timestamp>-<short-name>-research.md` or the one-off path `docs/research/<timestamp>-<short-name>-research.md`, uses the repository's Task Researcher template exactly, and places rejected-alternatives summaries inside `## Recommended Approach` rather than as a separate top-level header.
- **OB-3** Investigation Areas: Identify implementation targets from the feature docs.
- **OB-4** Constraints: Do not implement changes.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Output, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Investigation Areas, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Constraints, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
