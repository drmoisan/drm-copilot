---
agent: 'orchestrator'
description: 'Fixture prompt that mixes launcher, workflow, and hard-gate content.'
---

# Mixed runtime prompt

Use this prompt to launch a deterministic runtime workflow.

## Hard Gate

Execution must not begin until the plan is validated.
Blocked if tests introduce tempfile or network usage.

## Workflow

1. Collect context.
2. Run the review workflow.
3. Record evidence paths.

## Launch Template

Use `/mixed-runtime <feature-root>` to invoke this launcher.
