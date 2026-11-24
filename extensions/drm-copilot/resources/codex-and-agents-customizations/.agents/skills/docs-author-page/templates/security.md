---
owner: "<owner-id>"
last_reviewed: "<yyyy-mm-dd>"
review_due: "<review-due-yyyy-mm-dd>"
audience: ["<audience-id>"]
diataxis_mode: "explanation"
surface_refs: []
---

# <System name> Security

<One paragraph that states the security posture of the system and who owns it.>

## Scope and Data Classification

<State which components and environments this page covers and classify the data the system handles.>

| Data class | Examples | Handling requirement |
| --- | --- | --- |
| <class> | <examples of data in the class> | <storage, transport and retention requirement> |

## Authentication and Authorization Model

<Describe how identities are established and how permissions are granted, checked and revoked.>

## Secrets Handling

<State where secrets are stored, how they are issued and rotated, and which practices are prohibited.>

## Privileged Operations

<List the operations that require elevated permission, who may perform them and how each use is approved and recorded.>

## Audit and Logging

<State which security events are logged, where the records are kept, how long they are retained and who reviews them.>

## Vulnerability Reporting

<Describe how a person reports a vulnerability, who triages it and the expected response times.>

## Control Mapping

| Control | Requirement | Evidence |
| --- | --- | --- |
| <control> | <requirement the control satisfies> | <where the evidence is kept> |

## Exceptions and Assumptions

- <Exception granted or assumption made, with its owner and the condition that ends it.>
