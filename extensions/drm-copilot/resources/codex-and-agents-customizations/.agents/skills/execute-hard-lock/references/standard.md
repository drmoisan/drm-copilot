# Gold Standard: execute-hard-lock

## Objective

Place the session in atomic execution mode bound to a specific plan-of-record. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill requires two inputs, `plan-path` (the absolute or repo-relative path of the plan-of-record markdown file) and `work-mode` (`minor-audit`, `full-feature` or `full-bug`, with legacy `full` normalized to `full-feature` and a missing or malformed value failing closed to `full-feature`).
- **OB-2** Invocation Flow: As its first action the skill resolves the hard-lock prompt from two required inputs, the plan-of-record path and the absolute root of the calling checkout or worktree, then reads the resolved prompt file that the resolver returns and treats its contents as the authoritative hard-lock instruction set, and then delegates to the plan executor with the resolved prompt as its kickoff directive followed by the plan path and the work mode, stopping with a `BLOCKED: execute-hard-lock` report when the plan executor is unavailable.
- **OB-3** Abort Conditions: The skill stops immediately and reports `BLOCKED: execute-hard-lock <cause>` when the prompt-resolution tool is unavailable or not permitted, when its response is not ok, is malformed, or omits the artifact path, or when reading the artifact fails, and it never reconstructs the hard-lock prompt from another source.
- **OB-4** Equivalent Entry Points (Reference): Every entry point to the hard-lock prompt resolver produces the same resolved hard-lock prompt for a given plan path, and this skill uses the form that writes the prompt to a file artifact.
- **OB-5** Delegation Contract: Execution is delegated to the plan executor, which enforces anti-replanning, preflight-only blocking, persistence across turns and resume, and preloads four shared skills: `policy-compliance-order` for the mandatory policy reading order, `atomic-plan-contract` for plan format, Phase 0 requirements, preflight signals, the validator gate and mode-specific plan gates, `acceptance-criteria-tracking` for the check-off protocol and status summary format, and `evidence-and-timestamp-conventions` for baseline and final-QC artifact paths and required fields.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Invocation Flow, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Abort Conditions, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Equivalent Entry Points (Reference), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Delegation Contract, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
