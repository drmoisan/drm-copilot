# Gold Standard: research-issue

## Objective

Investigate the best implementation approach for a feature or bug by analyzing the codebase and external references, then writing structured findings to the applicable tracked research folder. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: `docs/features/active/<feature>/issue.md` (primary).
- **OB-2** Output: Feature-associated path: `docs/features/<feature>/research/<timestamp>-<short-name>-research.md`.
- **OB-3** Investigation Areas: Identify implementation targets from the feature docs.
- **OB-4** Constraints: Do not implement changes.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Output, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Investigation Areas, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Constraints, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
