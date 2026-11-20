# Gold Standard: acceptance-criteria-tracking

## Objective

Track and check off acceptance criteria in requirement source files (issue.md, spec.md, user-story.md) as they are delivered. Use when executing plans, reviewing features, or validating delivery to keep AC checkboxes current. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** AC Source Resolution (by Work Mode): Deterministic mode rule: use the persisted `- Work Mode: ...` marker from `issue.md` as the single source of truth.
- **OB-2** AC Identification: Acceptance criteria are markdown checkbox items within AC source files.
- **OB-3** Check-Off Protocol: One-at-a-time: Check off each AC item individually as the corresponding work is verified.
- **OB-4** AC Status Summary (Required at Completion): At the end of plan execution or feature review, an acceptance-criteria status summary is reported that names the source file or files, the total number of criteria, the number checked off as delivered, the number remaining unchecked and the text of each remaining criterion, and it appears in both the executor's final completion report after the last plan task and the reviewer's feature-audit artifact (Phase F or equivalent).

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under AC Source Resolution (by Work Mode), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under AC Identification, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Check-Off Protocol, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under AC Status Summary (Required at Completion), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
