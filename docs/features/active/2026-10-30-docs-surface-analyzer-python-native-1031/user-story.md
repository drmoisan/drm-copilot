# `2026-10-30-docs-surface-analyzer-python-native` — User Story

- Issue: #1031
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-38

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository with PowerShell lexical scanners (#1022 for Python and configuration surfaces). A lexical
scanner cannot fully classify Python constructs; constructs it cannot classify become diagnostics,
which is the documented precision limit of the baseline. The owner approved exception D3: a
language-native analyzer is allowed when it analyzes that same language and is pushed down only
with that language's pack. The Python-native analyzer is in the first release, and the PowerShell
scanner remains the always-available baseline.


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

- [ ] For the #1022 Python fixture, the native analyzer emits the same element identifiers as the scanner for every construct both classify, and additionally classifies the constructs the scanner reports as diagnostics.
- [ ] Without the python pack or without an interpreter, `inventory` succeeds with the scanner and records `analysis_method: scanner`; no error is raised.
- [ ] The helper never imports or executes analyzed code (`ast.parse` only).
- [ ] The Python helper is listed only in the python pack manifest; the core pack contains no Python.
- [ ] Python line coverage >= 85% and branch coverage >= 75%; Pester line coverage >= 85%.


## Non-Goals

Call out what is explicitly excluded from this feature.
