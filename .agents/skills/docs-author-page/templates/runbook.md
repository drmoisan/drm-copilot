---
owner: "<owner-id>"
last_reviewed: "<yyyy-mm-dd>"
review_due: "<review-due-yyyy-mm-dd>"
audience: ["<audience-id>"]
diataxis_mode: "how-to"
surface_refs: []
---

# Runbook: <Trigger or condition>

<One sentence that states the condition this runbook addresses and who runs it.>

## Purpose

<State the outcome the runbook restores or protects.>

## Trigger

<Name the alert, symptom or event that starts this runbook.>

## Severity and Ownership

| Severity | Condition | Owner | Escalation contact |
| --- | --- | --- | --- |
| <severity level> | <condition that sets the level> | <owning team or role> | <role or channel to escalate to> |

## Preconditions

- <Access, tool or state required before the first diagnostic step.>

## Diagnostics

1. <Check that narrows the cause; name the command or view it uses.>
2. <Next check and the result that rules a cause in or out.>

## Decision Points

- <Condition found in diagnostics>: <next action or the Remediation step to run.>

## Remediation

1. <Action that corrects the condition.>
2. <Next action.>
3. <Rollback action, run when an earlier action makes the condition worse.>

## Validation

<Describe the observable result that shows the condition is resolved.>

## Evidence and Follow-up

- <Record to capture, where to store it and the follow-up task to open.>
