---
owner: "<owner-id>"
last_reviewed: "<yyyy-mm-dd>"
review_due: "<review-due-yyyy-mm-dd>"
audience: ["<audience-id>"]
diataxis_mode: "explanation"
surface_refs: ["<element-id>"]
---

# <System name> Architecture

<One paragraph that states what the system does and who maintains it.>

## Components

| Component | Responsibility |
| --- | --- |
| <component> | <what it owns and what it does not> |

## Interactions

<Describe how the components exchange data and in which order. A diagram may be
added when it clarifies the flow.>

## Data Flow

<Describe how data moves through the system and where it is stored. Name where
untrusted input enters.>

| Stage | Input | Processing | Output | Trust level |
| --- | --- | --- | --- | --- |
| <stage> | <data the stage receives> | <what the stage does to it> | <data the stage produces> | <trusted or untrusted> |

## Trust Boundaries

| Boundary | What crosses | Controls |
| --- | --- | --- |
| <boundary> | <data or requests that cross it> | <checks applied at the crossing> |

## Failure Domains

| Domain | Blast radius | Degraded behavior | Recovery pointer |
| --- | --- | --- | --- |
| <domain> | <what a failure in the domain affects> | <how the system behaves while it fails> | <name of the page that describes recovery> |

## Boundaries and Constraints

<State the dependency rules, the external systems the components call and the
constraints that hold across components.>
