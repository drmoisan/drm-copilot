# Gold Standard: owner-directives

## Objective

Owner-directive relay for coordinators and delegated agents. Use when the repository owner gives the coordinator an instruction that a delegated orchestrator or specialist must act on: record it in the item checkpoint, relay it as a fenced Owner directives block, and record an honored or refused decision for each directive acted on. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Framing (normative): The directive block conveys owner intent that the coordinator recorded.
- **OB-2** Checkpoint Schemas: Both keys are optional top-level keys of an `orchestrator-state`, `epic-orchestrator-state`, or `parallel-orchestrator-state` checkpoint.
- **OB-3** Directive Classes: Each directive carries exactly one class from a closed set, in which `scheduling`, `merge_timing`, `extra_planner_revision`, `scope_narrowing`, and `accept_nonblocking_deviation` are honorable and `gate_bypass`, `force_push`, `tag_or_publish`, `policy_or_settings_edit`, `evidence_alteration`, and `unclassified` are always refused.
- **OB-4** Coordinator Procedure (Record Before Relay): Record a directive only from the owner's own turns in the coordinator session.
- **OB-5** Coordinator Ledger: The ledger holds one directive object per line, in the same shape as an `owner_directives` entry.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Framing (normative), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Checkpoint Schemas, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Directive Classes, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Coordinator Procedure (Record Before Relay), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Coordinator Ledger, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
