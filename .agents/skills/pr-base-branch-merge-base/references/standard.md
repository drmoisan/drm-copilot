# Gold Standard: pr-base-branch-merge-base

## Objective

Resolve PRBaseBranch for PR context collection using merge-base ancestry. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Selection Contract: `PRBaseBranch` MUST be resolved from git ancestry, not guessed.
- **OB-2** Deterministic Procedure: Enumerate candidate branches from local and remotes, excluding `HEAD` and detached refs.
- **OB-3** Guardrails: Do not default to `main` unless merge-base resolution fails for all candidates.
- **OB-4** Collector Invocation Rule: PR context collection is invoked with the resolved base passed explicitly as its `base` argument.
- **OB-5** Evidence Recommendation: The logs or checkpoint record the selected branch name, the selected merge-base SHA and its timestamp, and the top competing candidates with their timestamps when available.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Selection Contract, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Deterministic Procedure, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Guardrails, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Collector Invocation Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Evidence Recommendation, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
