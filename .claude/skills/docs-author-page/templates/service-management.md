---
owner: "<owner-id>"
last_reviewed: "<yyyy-mm-dd>"
review_due: "<review-due-yyyy-mm-dd>"
audience: ["<audience-id>"]
diataxis_mode: "explanation"
surface_refs: []
---

# <Service name> Service Management

Keep the part that this page covers and delete the other two parts. Each part is one H2 section with its own subsections.

## SLI, SLO and SLA

### Service and User Journey

<Describe the service, its users and the journey the objectives protect.>

### SLI Specifications

| Indicator | Definition | Measurement point |
| --- | --- | --- |
| <indicator> | <ratio or measure that defines the indicator> | <where the measurement is taken> |

### Measurement Sources

<Name the data sources for each indicator and any instrumentation gap.>

### SLO Targets

| Indicator | Target | Window |
| --- | --- | --- |
| <indicator> | <target value> | <measurement window> |

### Error-Budget Policy

<State what happens when the budget is spent, who decides and which work stops or starts.>

### SLA

<State the commitment made to customers, the remedy for a miss and the owner of the agreement.>

### Review Cadence

<State how often targets and agreements are reviewed and who attends.>

## Change and Release Management

### Change Classes

| Class | Definition | Approval |
| --- | --- | --- |
| <class> | <what qualifies a change for the class> | <who approves the class> |

### Review per Class

<State the review each class requires before it proceeds.>

### Release Procedure

<Describe how a release is prepared, deployed and confirmed.>

### Rollback per Class

<State how each class is reversed and the condition that triggers a rollback.>

### Change Record

<State what each change record holds and where it is kept.>

### Freeze and Exceptions

<State when changes are frozen and how an exception is requested and approved.>

## Incident Management

### Severity Definitions

| Severity | Definition | Response expectation |
| --- | --- | --- |
| <severity level> | <impact that sets the level> | <expected response time and staffing> |

### Incident Lifecycle

<Describe the stages from detection to closure and the exit condition of each stage.>

### Roles

<List the incident roles and the responsibility of each.>

### Communication Expectations

<State who is informed, through which channel and how often.>

### Postmortem Practice

<State when a postmortem is held, who writes it and how follow-up actions are tracked.>
