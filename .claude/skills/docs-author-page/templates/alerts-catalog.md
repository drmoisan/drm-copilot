---
owner: "<owner-id>"
last_reviewed: "<yyyy-mm-dd>"
review_due: "<review-due-yyyy-mm-dd>"
audience: ["<audience-id>"]
diataxis_mode: "reference"
surface_refs: []
---

# <System name> Alerts Catalog

<One sentence that states which system the alerts belong to and who maintains the catalog.>

## Purpose

<State what the catalog lets a responder find: the meaning of each alert, its severity and the runbook to run.>

## Catalog

| Alert ID | Condition | Detection Signal | Severity | Owner | Responding Runbook |
| --- | --- | --- | --- | --- | --- |
| <alert id> | <condition that fires the alert> | <metric, log or check that detects it> | <severity level> | <owning team or role> | <name of the runbook page> |

## Severity Scale

| Severity | Meaning | Response expectation |
| --- | --- | --- |
| <severity level> | <impact that sets the level> | <expected response time> |

## Related

- <Name of the runbook, playbook or service-management page the catalog relies on.>
