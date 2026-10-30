# `2026-10-30-docs-surface-analyzers-python-config` — User Story

- Issue: #1022
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T16-46

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The documentation-estate-tooling epic (#1019) needs an inventory of the documentable surface of a
destination repository before a coverage ledger, parity matrix or reference pages can be built. Issue
#1020 defines the surface element model, the analyzer protocol and registry table, and the
`surface-inventory-snapshot` schema, but no analyzer yet produces surface elements. Without analyzers
for Python command-line interfaces, HTTP routes, public APIs, configuration files and architecture, the
`dev.docs.inventory` command cannot report what a Python repository exposes, and documentation drift
must be counted by hand.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] Each analyzer emits the expected elements for an in-memory fixture covering argparse, Click, Typer, FastAPI, Flask, `pyproject.toml`, `.env`, JSON Schema and YAML inputs.
- [ ] Re-running over identical bytes produces a byte-identical snapshot (property test).
- [ ] No configuration value is exported; only keys and shapes.
- [ ] An input above the size bound yields a diagnostic, not a partial result.
- [ ] The snapshot validates against `surface-inventory-snapshot.schema.json` and records the captured input digests.
- [ ] Line coverage >= 85% and branch coverage >= 75% for the analyzers.


## Non-Goals

Call out what is explicitly excluded from this feature.
