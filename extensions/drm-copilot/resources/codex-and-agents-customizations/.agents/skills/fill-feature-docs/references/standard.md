# Gold Standard: fill-feature-docs

## Objective

Invoke the prd-feature worker to produce feature-document outputs from issue and research inputs. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill takes the feature folder's issue and research context and the existing spec and user-story files when present.
- **OB-2** Output Paths: The skill writes two output files, `.dev/active/<feature>/spec.md` and `.dev/active/<feature>/user-story.md`.
- **OB-3** Worker Routing: Require the worker to report the authoritative `research-path` when a numeric acceptance criterion is written.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Output Paths, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Worker Routing, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
