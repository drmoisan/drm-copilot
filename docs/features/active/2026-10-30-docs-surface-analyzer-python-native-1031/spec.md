# 2026-10-30-docs-surface-analyzer-python-native — Spec

- **Issue:** #1031
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-38
- **Status:** Draft
- **Version:** 0.1

## Overview

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository with PowerShell lexical scanners (#1022 for Python and configuration surfaces). A lexical
scanner cannot fully classify Python constructs; constructs it cannot classify become diagnostics,
which is the documented precision limit of the baseline. The owner approved exception D3: a
language-native analyzer is allowed when it analyzes that same language and is pushed down only
with that language's pack. The Python-native analyzer is in the first release, and the PowerShell
scanner remains the always-available baseline.


## Behavior

- A Python helper, written in Python using only the standard library `ast` module (parse only;
  analyzed code is never imported or executed), reads in-memory sources passed as JSON on standard
  input and writes surface elements as JSON on standard output.
- The helper is shipped only in the python pack manifest
  (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json`, and the
  Codex python pack manifest if that pack carries libs); the core pack contains no Python.
- A PowerShell adapter `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` (core pack) detects the
  python pack and a Python interpreter, sends the sources to the helper, validates the JSON output,
  and falls back to the #1022 scanner when the pack, the interpreter, or valid output is absent.
- Native analysis covers the analyzer identifiers `python-cli`, `python-http`,
  `python-public-api` and `python-architecture`; `config-files` stays scanner-only.
- Each element records `analysis_method` `native` or `scanner`. Native elements carry the same
  identifiers, element kinds and declaration-lines digests as the scanner, so ledger pins stay valid
  when the method changes.
- The adapter is registered under the 900011 anchor in `DocsAnalyzerRegistry.psm1`.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- Language rule: pushed-down skills, hooks and libs are PowerShell or bash; the Python helper is
  the single owner-approved D3 exception and is tested under the Python gates (Black, Ruff,
  Pyright, Pytest).
- No new third-party Python or PowerShell dependency; standard library only.
- Tests create no temporary files.
- The #1022 plan is being re-prepared concurrently; identifiers, element kinds, the digest rule and
  fixtures are taken from the epic's #1022 analyzer decisions and the #1020 contracts.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: helper parsing per analyzer identifier, identifier and digest parity with the scanner, adapter detection and fallback paths
- [ ] Integration scenarios: `inventory` with and without the python pack and interpreter
- [ ] CLI/API examples: JSON on standard input and standard output contract
