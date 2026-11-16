# Gold Standard: commit-message

## Objective

Generate a conventional commit message from staged Git changes following the repository's commit message conventions. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: Staged Git changes are the primary source of truth.
- **OB-2** Context Gathering: Use the supplied commit-context artifact first when present.
- **OB-3** Classification: Follow Conventional Commits semantics.
- **OB-4** Message Format: Header rules: imperative mood, 72 characters or fewer, no trailing period, no filler words.
- **OB-5** Prohibitions: No commentary outside the fenced code block.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Context Gathering, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Classification, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Message Format, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Prohibitions, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
