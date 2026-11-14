# docs-surface-analyzer-python-native (Issue #1031)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-surface-analyzer-python-native/ (Issue #1031)
- Parent epic: #1019 (documentation-estate-tooling), child 900011, wave 2, band C3
- Depends on: #1022 (PowerShell baseline scanner for Python and configuration surfaces), and transitively #1020
- Authorization: owner decision D3 (2026-10-30), the language-native analyzer exception recorded in the epic manifest `docs/features/epics/documentation-estate-tooling/epic.md`

- Issue: #1031
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1031
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository with PowerShell lexical scanners (#1022 for Python and configuration surfaces). A lexical
scanner cannot fully classify Python constructs; constructs it cannot classify become diagnostics,
which is the documented precision limit of the baseline. The owner approved exception D3: a
language-native analyzer is allowed when it analyzes that same language and is pushed down only
with that language's pack. The Python-native analyzer is in the first release, and the PowerShell
scanner remains the always-available baseline.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [ ] For the #1022 Python fixture, the native analyzer emits the same element identifiers as the scanner for every construct both classify, and additionally classifies the constructs the scanner reports as diagnostics.
- [ ] Without the python pack or without an interpreter, `inventory` succeeds with the scanner and records `analysis_method: scanner`; no error is raised.
- [ ] The helper never imports or executes analyzed code (`ast.parse` only).
- [ ] The Python helper is listed only in the python pack manifest; the core pack contains no Python.
- [ ] Python line coverage >= 85% and branch coverage >= 75%; Pester line coverage >= 85%.

## Constraints & Risks

- Language rule: pushed-down skills, hooks and libs are PowerShell or bash; the Python helper is
  the single owner-approved D3 exception and is tested under the Python gates (Black, Ruff,
  Pyright, Pytest).
- No new third-party Python or PowerShell dependency; standard library only.
- Tests create no temporary files.
- The #1022 plan is being re-prepared concurrently; identifiers, element kinds, the digest rule and
  fixtures are taken from the epic's #1022 analyzer decisions and the #1020 contracts.

## Test Conditions to Consider

- [ ] Unit coverage areas: helper parsing per analyzer identifier, identifier and digest parity with the scanner, adapter detection and fallback paths
- [ ] Integration scenarios: `inventory` with and without the python pack and interpreter
- [ ] CLI/API examples: JSON on standard input and standard output contract

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-surface-analyzer-python-native/` folder from the template
